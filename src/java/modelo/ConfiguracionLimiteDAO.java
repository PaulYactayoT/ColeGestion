package modelo;

import conexion.Conexion;
import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.DayOfWeek;
import java.util.*;

/**
 * DAO para gestionar configuración de límites de edición de asistencia
 */
public class ConfiguracionLimiteDAO {
    
    /**
     * VERIFICAR SI SE PUEDE EDITAR UNA ASISTENCIA
     * Valida si el tiempo límite ya pasó
     * 
     * @param cursoId ID del curso
     * @param turnoId ID del turno
     * @param fecha Fecha de la asistencia
     * @param horaClase Hora de la clase
     * @return true si se puede editar, false si ya pasó el límite
     */
    public boolean puedeEditarAsistencia(int cursoId, int turnoId, LocalDate fecha, LocalTime horaClase) {
        // Si la fecha es futura, siempre se puede editar
        LocalDate hoy = LocalDate.now();
        if (fecha.isAfter(hoy)) {
            return true;
        }
        
        // Si la fecha es pasada (no hoy), no se puede editar
        if (fecha.isBefore(hoy)) {
            return false;
        }
        
        // Si es hoy, verificar hora límite
        LocalTime ahora = LocalTime.now();
        
        // Obtener configuración
        ConfiguracionLimiteEdicion config = obtenerConfiguracion(cursoId, turnoId, fecha, horaClase);
        
        if (config == null) {
            // Si no hay configuración, usar límite por defecto de 2 horas
            LocalTime limiteDefecto = horaClase.plusHours(2);
            return ahora.isBefore(limiteDefecto);
        }
        
        // Calcular hora límite según configuración
        LocalTime horaLimite = horaClase.plusMinutes(config.getLimiteEdicionMinutos());
        return ahora.isBefore(horaLimite);
    }
    
    /**
     * OBTENER CONFIGURACIÓN PARA UNA CLASE ESPECÍFICA
     * 
     * @param cursoId ID del curso
     * @param turnoId ID del turno
     * @param fecha Fecha de la clase
     * @param horaClase Hora de la clase
     * @return Configuración o null si no existe
     */
    public ConfiguracionLimiteEdicion obtenerConfiguracion(int cursoId, int turnoId, 
                                                          LocalDate fecha, LocalTime horaClase) {
        // Obtener día de la semana
        DayOfWeek diaSemana = fecha.getDayOfWeek();
        String diaStr = diaSemana.toString();
        
        String sql = "SELECT c.*, " +
                     "cur.nombre as curso_nombre, " +
                     "t.nombre as turno_nombre " +
                     "FROM configuracion_limite_edicion_asistencia c " +
                     "LEFT JOIN curso cur ON c.curso_id = cur.id " +
                     "INNER JOIN turno t ON c.turno_id = t.id " +
                     "WHERE c.turno_id = ? " +
                     "AND c.dia_semana = ? " +
                     "AND c.hora_inicio_clase = ? " +
                     "AND (c.curso_id = ? OR c.aplica_todos_cursos = 1) " +
                     "AND c.activo = 1 " +
                     "ORDER BY c.aplica_todos_cursos ASC " +
                     "LIMIT 1";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, turnoId);
            ps.setString(2, diaStr);
            ps.setTime(3, Time.valueOf(horaClase));
            ps.setInt(4, cursoId);
            
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return mapearConfiguracion(rs);
            }
            
        } catch (SQLException e) {
            System.out.println(" Error al obtener configuración: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * CREAR NUEVA CONFIGURACIÓN
     * 
     * @param config Objeto ConfiguracionLimiteEdicion
     * @return true si se creó exitosamente
     */
    public boolean crearConfiguracion(ConfiguracionLimiteEdicion config) {
        String sql = "INSERT INTO configuracion_limite_edicion_asistencia " +
                     "(curso_id, turno_id, dia_semana, hora_inicio_clase, " +
                     "limite_edicion_minutos, aplica_todos_cursos, descripcion, activo) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, 1)";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setInt(1, config.getCursoId());
            ps.setInt(2, config.getTurnoId());
            ps.setString(3, config.getDiaSemanaString());
            ps.setTime(4, Time.valueOf(config.getHoraInicioClase()));
            ps.setInt(5, config.getLimiteEdicionMinutos());
            ps.setBoolean(6, config.isAplicaTodosCursos());
            ps.setString(7, config.getDescripcion());
            
            int filasAfectadas = ps.executeUpdate();
            
            if (filasAfectadas > 0) {
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    config.setId(rs.getInt(1));
                }
                System.out.println(" Configuración creada con ID: " + config.getId());
                return true;
            }
            
        } catch (SQLException e) {
            System.out.println(" Error al crear configuración: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * ACTUALIZAR CONFIGURACIÓN
     * 
     * @param config Objeto con datos actualizados
     * @return true si se actualizó exitosamente
     */
    public boolean actualizarConfiguracion(ConfiguracionLimiteEdicion config) {
        String sql = "UPDATE configuracion_limite_edicion_asistencia " +
                     "SET curso_id = ?, turno_id = ?, dia_semana = ?, " +
                     "hora_inicio_clase = ?, limite_edicion_minutos = ?, " +
                     "aplica_todos_cursos = ?, descripcion = ? " +
                     "WHERE id = ?";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, config.getCursoId());
            ps.setInt(2, config.getTurnoId());
            ps.setString(3, config.getDiaSemanaString());
            ps.setTime(4, Time.valueOf(config.getHoraInicioClase()));
            ps.setInt(5, config.getLimiteEdicionMinutos());
            ps.setBoolean(6, config.isAplicaTodosCursos());
            ps.setString(7, config.getDescripcion());
            ps.setInt(8, config.getId());
            
            int filasAfectadas = ps.executeUpdate();
            
            if (filasAfectadas > 0) {
                System.out.println(" Configuración actualizada: " + config.getId());
                return true;
            }
            
        } catch (SQLException e) {
            System.out.println(" Error al actualizar configuración: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * OBTENER TODAS LAS CONFIGURACIONES POR TURNO
     * 
     * @param turnoId ID del turno
     * @return Lista de configuraciones
     */
    public List<ConfiguracionLimiteEdicion> obtenerConfiguracionesPorTurno(int turnoId) {
        List<ConfiguracionLimiteEdicion> lista = new ArrayList<>();
        String sql = "SELECT c.*, " +
                     "cur.nombre as curso_nombre, " +
                     "t.nombre as turno_nombre " +
                     "FROM configuracion_limite_edicion_asistencia c " +
                     "LEFT JOIN curso cur ON c.curso_id = cur.id " +
                     "INNER JOIN turno t ON c.turno_id = t.id " +
                     "WHERE c.turno_id = ? AND c.activo = 1 " +
                     "ORDER BY c.dia_semana, c.hora_inicio_clase";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, turnoId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                lista.add(mapearConfiguracion(rs));
            }
            
        } catch (SQLException e) {
            System.out.println(" Error al obtener configuraciones: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }
    
    /**
     * ELIMINAR CONFIGURACIÓN (desactivar)
     * 
     * @param id ID de la configuración
     * @return true si se eliminó exitosamente
     */
    public boolean eliminarConfiguracion(int id) {
        String sql = "UPDATE configuracion_limite_edicion_asistencia " +
                     "SET activo = 0 WHERE id = ?";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            int filasAfectadas = ps.executeUpdate();
            
            if (filasAfectadas > 0) {
                System.out.println("✅ Configuración eliminada: " + id);
                return true;
            }
            
        } catch (SQLException e) {
            System.out.println("❌ Error al eliminar configuración: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * OBTENER MENSAJE DE TIEMPO LÍMITE
     * Devuelve un mensaje informativo sobre el tiempo restante para editar
     * 
     * @param cursoId ID del curso
     * @param turnoId ID del turno
     * @param fecha Fecha de la asistencia
     * @param horaClase Hora de la clase
     * @return Mensaje informativo
     */
    public String obtenerMensajeTiempoLimite(int cursoId, int turnoId, 
                                            LocalDate fecha, LocalTime horaClase) {
        LocalDate hoy = LocalDate.now();
        LocalTime ahora = LocalTime.now();
        
        if (fecha.isBefore(hoy)) {
            return " No se puede editar. La asistencia es de una fecha pasada.";
        }
        
        if (fecha.isAfter(hoy)) {
            return " Puede editar libremente. La fecha es futura.";
        }
        
        // Es hoy
        ConfiguracionLimiteEdicion config = obtenerConfiguracion(cursoId, turnoId, fecha, horaClase);
        LocalTime horaLimite;
        
        if (config == null) {
            horaLimite = horaClase.plusHours(2);
        } else {
            horaLimite = horaClase.plusMinutes(config.getLimiteEdicionMinutos());
        }
        
        if (ahora.isBefore(horaLimite)) {
            long minutosRestantes = java.time.Duration.between(ahora, horaLimite).toMinutes();
            if (minutosRestantes > 60) {
                long horas = minutosRestantes / 60;
                long minutos = minutosRestantes % 60;
                return String.format(" Tiempo restante para editar: %d hora%s y %d minuto%s", 
                                   horas, horas > 1 ? "s" : "", 
                                   minutos, minutos > 1 ? "s" : "");
            } else {
                return String.format(" Tiempo restante para editar: %d minuto%s", 
                                   minutosRestantes, minutosRestantes > 1 ? "s" : "");
            }
        } else {
            return " No se puede editar. Ya pasó el tiempo límite.";
        }
    }
    
    /**
     * MÉTODO AUXILIAR PARA MAPEAR ResultSet
     */
    private ConfiguracionLimiteEdicion mapearConfiguracion(ResultSet rs) throws SQLException {
        ConfiguracionLimiteEdicion config = new ConfiguracionLimiteEdicion();
        config.setId(rs.getInt("id"));
        config.setCursoId(rs.getInt("curso_id"));
        config.setTurnoId(rs.getInt("turno_id"));
        config.setDiaSemanaFromString(rs.getString("dia_semana"));
        config.setHoraInicioClase(rs.getTime("hora_inicio_clase").toLocalTime());
        config.setLimiteEdicionMinutos(rs.getInt("limite_edicion_minutos"));
        config.setAplicaTodosCursos(rs.getBoolean("aplica_todos_cursos"));
        config.setDescripcion(rs.getString("descripcion"));
        config.setActivo(rs.getBoolean("activo"));
        
        // Campos opcionales
        try {
            config.setCursoNombre(rs.getString("curso_nombre"));
            config.setTurnoNombre(rs.getString("turno_nombre"));
        } catch (SQLException e) {
            // Campos opcionales
        }
        
        return config;
    }
}