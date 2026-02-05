package modelo;

import conexion.Conexion;
import java.sql.*;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.LocalDateTime;
import java.time.DayOfWeek;
import java.util.*;

public class ConfiguracionAsistenciaDAO {
    
    /**
     * OBTENER CONFIGURACIÓN ACTIVA DE ASISTENCIA DESDE MASTER_TABLE
     */
    public Map<String, Object> obtenerConfiguracionActiva() {
        Map<String, Object> config = new HashMap<>();
        String sql = "SELECT mt.AdditionalOne as tipo_limite, mt.AdditionalTwo as valor, " +
                    "mt.AdditionalThree as alcance, mt.AdditionalFour as referencia_id " +
                    "FROM master_table mt " +
                    "INNER JOIN ( " +
                    "    SELECT AdditionalTwo as config_activa " +
                    "    FROM master_table " +
                    "    WHERE Category = 'ConfiguracionAsistencia' " +
                    "    AND Value = 'MODO_ACTIVO' " +
                    "    AND Status = 'A' " +
                    ") modo " +
                    "WHERE mt.Category = 'ConfiguracionAsistencia' " +
                    "AND mt.Value = modo.config_activa " +
                    "AND mt.Status = 'A' " +
                    "LIMIT 1";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                config.put("tipo_limite", rs.getString("tipo_limite"));
                config.put("valor", rs.getString("valor"));
                config.put("alcance", rs.getString("alcance"));
                config.put("referencia_id", rs.getString("referencia_id"));
            } else {
                // Configuración por defecto si no hay configurada
                config.put("tipo_limite", "MINUTOS_DESPUES_FIN");
                config.put("valor", "120"); // 120 minutos por defecto
                config.put("alcance", "GLOBAL");
                config.put("referencia_id", null);
            }
            
        } catch (SQLException e) {
            System.out.println("❌ Error al obtener configuración activa: " + e.getMessage());
            e.printStackTrace();
        }
        
        return config;
    }
    
    /**
     * VERIFICAR SI SE PUEDE EDITAR UNA ASISTENCIA
     * Implementa los criterios de la historia de usuario
     */
    public boolean puedeEditarAsistencia(int cursoId, int turnoId, LocalDate fecha, LocalTime horaInicioClase) {
        try {
            // 1. Obtener configuración activa
            Map<String, Object> config = obtenerConfiguracionActiva();
            String tipoLimite = (String) config.get("tipo_limite");
            String valor = (String) config.get("valor");
            
            // 2. Obtener hora de fin de la clase
            LocalTime horaFinClase = obtenerHoraFinClase(cursoId, turnoId, fecha);
            if (horaFinClase == null) {
                // Si no se encuentra horario, asumir 2 horas de clase
                horaFinClase = horaInicioClase.plusHours(2);
            }
            
            // 3. Calcular tiempo límite según configuración
            LocalDateTime limite = calcularLimiteEdicion(fecha, horaInicioClase, horaFinClase, tipoLimite, valor);
            
            // 4. Verificar si el tiempo actual está antes del límite
            LocalDateTime ahora = LocalDateTime.now();
            
            System.out.println("🕒 Verificación de límite:");
            System.out.println("   Fecha clase: " + fecha);
            System.out.println("   Hora inicio: " + horaInicioClase);
            System.out.println("   Hora fin: " + horaFinClase);
            System.out.println("   Tipo límite: " + tipoLimite);
            System.out.println("   Valor: " + valor);
            System.out.println("   Límite calculado: " + limite);
            System.out.println("   Ahora: " + ahora);
            System.out.println("   ¿Puede editar? " + !ahora.isAfter(limite));
            
            return !ahora.isAfter(limite);
            
        } catch (Exception e) {
            System.out.println("❌ Error en puedeEditarAsistencia: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * OBTENER MENSAJE INFORMATIVO SOBRE EL LÍMITE
     */
    public String obtenerMensajeLimite(int cursoId, int turnoId, LocalDate fecha, LocalTime horaInicioClase) {
        try {
            Map<String, Object> config = obtenerConfiguracionActiva();
            String tipoLimite = (String) config.get("tipo_limite");
            String valor = (String) config.get("valor");
            
            LocalTime horaFinClase = obtenerHoraFinClase(cursoId, turnoId, fecha);
            if (horaFinClase == null) {
                horaFinClase = horaInicioClase.plusHours(2);
            }
            
            LocalDateTime limite = calcularLimiteEdicion(fecha, horaInicioClase, horaFinClase, tipoLimite, valor);
            LocalDateTime ahora = LocalDateTime.now();
            
            if (ahora.isAfter(limite)) {
                return "⛔ Tiempo límite excedido. No se puede editar la asistencia.";
            } else {
                long minutosRestantes = java.time.Duration.between(ahora, limite).toMinutes();
                
                if (minutosRestantes > 60) {
                    long horas = minutosRestantes / 60;
                    long minutos = minutosRestantes % 60;
                    return String.format("✅ Puede editar por %d horas y %d minutos más", horas, minutos);
                } else if (minutosRestantes > 30) {
                    return String.format("✅ Puede editar por %d minutos más", minutosRestantes);
                } else if (minutosRestantes > 10) {
                    return String.format("⚠️ Atención: Le quedan %d minutos para editar", minutosRestantes);
                } else {
                    return String.format("⏳ ¡Apúrese! Solo %d minutos para editar", minutosRestantes);
                }
            }
            
        } catch (Exception e) {
            return "⚠️ No se pudo verificar el tiempo límite";
        }
    }
    
    /**
     * CALCULAR LÍMITE DE EDICIÓN SEGÚN CONFIGURACIÓN
     */
    private LocalDateTime calcularLimiteEdicion(LocalDate fecha, LocalTime horaInicio, 
                                                LocalTime horaFin, String tipoLimite, String valor) {
        
        switch (tipoLimite) {
            case "MINUTOS_DESPUES_INICIO":
                // Límite: X minutos después del inicio
                int minutosDesdeInicio = Integer.parseInt(valor);
                return LocalDateTime.of(fecha, horaInicio)
                        .plusMinutes(minutosDesdeInicio);
                
            case "MINUTOS_DESPUES_FIN":
                // Límite: X minutos después del fin
                int minutosDesdeFin = Integer.parseInt(valor);
                return LocalDateTime.of(fecha, horaFin)
                        .plusMinutes(minutosDesdeFin);
                
            case "HORA_FIJA":
                // Límite: Hora fija del día (formato HH:MM)
                LocalTime horaFija = LocalTime.parse(valor);
                return LocalDateTime.of(fecha, horaFija);
                
            default:
                // Por defecto: 120 minutos después del fin
                return LocalDateTime.of(fecha, horaFin)
                        .plusMinutes(120);
        }
    }
    
    /**
     * OBTENER HORA DE FIN DE LA CLASE
     */
    private LocalTime obtenerHoraFinClase(int cursoId, int turnoId, LocalDate fecha) {
        String diaSemana = convertirDiaSemana(fecha.getDayOfWeek());
        
        String sql = "SELECT hora_fin FROM horario_clase " +
                    "WHERE curso_id = ? AND turno_id = ? " +
                    "AND dia_semana = ? AND activo = 1 " +
                    "LIMIT 1";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, cursoId);
            ps.setInt(2, turnoId);
            ps.setString(3, diaSemana);
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getTime("hora_fin").toLocalTime();
            }
            
        } catch (SQLException e) {
            System.out.println("❌ Error al obtener hora fin: " + e.getMessage());
        }
        
        return null;
    }
    
    /**
     * CONVERTIR DayOfWeek A STRING (para comparar con la BD)
     */
    private String convertirDiaSemana(DayOfWeek dayOfWeek) {
        switch (dayOfWeek) {
            case MONDAY: return "LUNES";
            case TUESDAY: return "MARTES";
            case WEDNESDAY: return "MIERCOLES";
            case THURSDAY: return "JUEVES";
            case FRIDAY: return "VIERNES";
            case SATURDAY: return "SABADO";
            case SUNDAY: return "DOMINGO";
            default: return "LUNES";
        }
    }
    
    /**
     * OBTENER TODAS LAS CONFIGURACIONES DISPONIBLES
     */
    public List<Map<String, Object>> obtenerTodasConfiguraciones() {
        List<Map<String, Object>> configs = new ArrayList<>();
        
        String sql = "SELECT IdMasterTable as id, Value as codigo, Name as nombre, " +
                    "Description as descripcion, AdditionalOne as tipo_limite, " +
                    "AdditionalTwo as valor, AdditionalThree as alcance, " +
                    "AdditionalFour as referencia_id, Status as estado " +
                    "FROM master_table " +
                    "WHERE Category = 'ConfiguracionAsistencia' " +
                    "AND IdMasterTableParent IS NOT NULL " +
                    "AND Value != 'MODO_ACTIVO' " +
                    "ORDER BY OrderIndex";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> config = new HashMap<>();
                config.put("id", rs.getInt("id"));
                config.put("codigo", rs.getString("codigo"));
                config.put("nombre", rs.getString("nombre"));
                config.put("descripcion", rs.getString("descripcion"));
                config.put("tipo_limite", rs.getString("tipo_limite"));
                config.put("valor", rs.getString("valor"));
                config.put("alcance", rs.getString("alcance"));
                config.put("referencia_id", rs.getString("referencia_id"));
                config.put("estado", rs.getString("estado"));
                
                configs.add(config);
            }
            
        } catch (SQLException e) {
            System.out.println("❌ Error al obtener configuraciones: " + e.getMessage());
            e.printStackTrace();
        }
        
        return configs;
    }
    
    /**
     * CAMBIAR CONFIGURACIÓN ACTIVA
     */
    public boolean cambiarConfiguracionActiva(String codigoConfig) {
        String sql = "UPDATE master_table SET AdditionalTwo = ? " +
                    "WHERE Category = 'ConfiguracionAsistencia' " +
                    "AND Value = 'MODO_ACTIVO'";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, codigoConfig);
            int filas = ps.executeUpdate();
            
            System.out.println("✅ Configuración cambiada a: " + codigoConfig);
            return filas > 0;
            
        } catch (SQLException e) {
            System.out.println("❌ Error al cambiar configuración: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * OBTENER ESTADO DE EDICIÓN CON DETALLES
     */
    public Map<String, Object> obtenerEstadoEdicionDetallado(int cursoId, int turnoId, 
                                                             LocalDate fecha, LocalTime horaInicioClase) {
        Map<String, Object> estado = new HashMap<>();
        
        try {
            // Obtener configuración
            Map<String, Object> config = obtenerConfiguracionActiva();
            
            // Obtener hora fin
            LocalTime horaFinClase = obtenerHoraFinClase(cursoId, turnoId, fecha);
            if (horaFinClase == null) {
                horaFinClase = horaInicioClase.plusHours(2);
            }
            
            // Calcular límite
            LocalDateTime limite = calcularLimiteEdicion(
                fecha, horaInicioClase, horaFinClase, 
                (String)config.get("tipo_limite"), 
                (String)config.get("valor")
            );
            
            LocalDateTime ahora = LocalDateTime.now();
            boolean puedeEditar = !ahora.isAfter(limite);
            
            // Calcular tiempo restante
            long minutosRestantes = 0;
            if (puedeEditar) {
                minutosRestantes = java.time.Duration.between(ahora, limite).toMinutes();
            }
            
            // Preparar respuesta
            estado.put("puede_editar", puedeEditar);
            estado.put("limite", limite);
            estado.put("hora_inicio_clase", horaInicioClase);
            estado.put("hora_fin_clase", horaFinClase);
            estado.put("tipo_limite", config.get("tipo_limite"));
            estado.put("valor_config", config.get("valor"));
            estado.put("minutos_restantes", minutosRestantes);
            estado.put("mensaje", obtenerMensajeLimite(cursoId, turnoId, fecha, horaInicioClase));
            
        } catch (Exception e) {
            estado.put("puede_editar", false);
            estado.put("mensaje", "Error al calcular límite: " + e.getMessage());
        }
        
        return estado;
    }
}