package modelo;

import conexion.Conexion;
import java.sql.*;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

public class AsistenciaDAO {

    /**
     * REGISTRAR ASISTENCIA INDIVIDUAL
     * 
     * @param a Objeto Asistencia con datos completos
     * @return true si el registro fue exitoso
     */
    public boolean registrarAsistencia(Asistencia a) {
        String sql = "{CALL registrar_asistencia(?, ?, ?, ?, ?, ?, ?, ?)}";

        try (Connection con = Conexion.getConnection(); 
             CallableStatement cs = con.prepareCall(sql)) {

            cs.setInt(1, a.getAlumnoId());
            cs.setInt(2, a.getCursoId());
            cs.setInt(3, a.getTurnoId());
            cs.setDate(4, java.sql.Date.valueOf(a.getFecha()));
            cs.setTime(5, java.sql.Time.valueOf(a.getHoraClase()));
            cs.setString(6, a.getEstadoString());
            cs.setString(7, a.getObservaciones());
            cs.setInt(8, a.getRegistradoPor());

            boolean tieneResultados = cs.execute();
            int resultado = 0;
            
            if (tieneResultados) {
                ResultSet rs = cs.getResultSet();
                if (rs.next()) {
                    resultado = rs.getInt("filas_afectadas");
                }
                rs.close();
            } else {
                resultado = cs.getUpdateCount();
            }
            
            System.out.println("✅ Asistencia registrada. Filas afectadas: " + resultado);
            return resultado > 0;

        } catch (SQLException e) {
            System.out.println("❌ Error SQL al registrar asistencia:");
            System.out.println("   Código: " + e.getErrorCode());
            System.out.println("   Estado: " + e.getSQLState());
            System.out.println("   Mensaje: " + e.getMessage());
            e.printStackTrace();
            return false;
        } catch (Exception e) {
            System.out.println("❌ Error general al registrar asistencia");
            e.printStackTrace();
            return false;
        }
    }

    /**
     * REGISTRAR ASISTENCIAS GRUPALES (MÚLTIPLES ALUMNOS)
     * 
     * @param cursoId Identificador del curso
     * @param turnoId Identificador del turno
     * @param fecha Fecha de la asistencia
     * @param horaClase Hora de la clase
     * @param alumnosJson Datos de alumnos en formato JSON
     * @param registradoPor ID del usuario que registra
     * @return true si al menos un registro fue exitoso
     */
    public boolean registrarAsistenciaGrupal(int cursoId, int turnoId, LocalDate fecha, 
                                            String horaClase, String alumnosJson, 
                                            int registradoPor) {
        System.out.println("🔄 INICIANDO DAO REGISTRO GRUPAL");
        System.out.println("   📅 Curso ID: " + cursoId);
        System.out.println("   ⏰ Turno ID: " + turnoId);
        System.out.println("   📅 Fecha: " + fecha);
        System.out.println("   ⏰ Hora Clase: " + horaClase);
        System.out.println("   👤 Registrado por: " + registradoPor);
        System.out.println("   📊 JSON recibido (primeros 500 chars): " + 
                         (alumnosJson != null ? alumnosJson.substring(0, Math.min(alumnosJson.length(), 500)) : "NULL"));

        Connection con = null;
        CallableStatement cs = null;

        try {
            con = Conexion.getConnection();
            con.setAutoCommit(false); // Iniciar transacción

            // Validar JSON
            if (alumnosJson == null || alumnosJson.trim().isEmpty()) {
                System.out.println("❌ ERROR: JSON de alumnos está vacío");
                return false;
            }

            // Parsear JSON manualmente
            List<Map<String, Object>> alumnosList = parseJsonManual(alumnosJson);
            
            if (alumnosList.isEmpty()) {
                System.out.println("❌ ERROR: No se pudieron parsear datos del JSON");
                return false;
            }

            System.out.println("✅ Total de alumnos a procesar: " + alumnosList.size());

            // Preparar el stored procedure
            String sql = "{CALL registrar_asistencia(?, ?, ?, ?, ?, ?, ?, ?)}";
            cs = con.prepareCall(sql);

            // Convertir fecha y hora a tipos SQL
            java.sql.Date sqlFecha = java.sql.Date.valueOf(fecha);
            java.sql.Time sqlHora = java.sql.Time.valueOf(horaClase + ":00"); // Asegurar formato HH:MM:SS

            int exitosos = 0;
            int errores = 0;
            int duplicados = 0;

            for (Map<String, Object> alumnoMap : alumnosList) {
                try {
                    Integer alumnoId = null;
                    String estado = null;
                    
                    // Buscar alumno_id en diferentes formatos posibles
                    if (alumnoMap.containsKey("alumno_id")) {
                        alumnoId = ((Number) alumnoMap.get("alumno_id")).intValue();
                    } else if (alumnoMap.containsKey("id")) {
                        alumnoId = ((Number) alumnoMap.get("id")).intValue();
                    } else if (alumnoMap.containsKey("alumnoId")) {
                        alumnoId = ((Number) alumnoMap.get("alumnoId")).intValue();
                    }
                    
                    if (alumnoMap.containsKey("estado")) {
                        estado = (String) alumnoMap.get("estado");
                    }
                    
                    if (alumnoId == null || alumnoId <= 0 || estado == null || estado.isEmpty()) {
                        System.out.println("⚠️ Datos inválidos para alumno: " + alumnoMap);
                        errores++;
                        continue;
                    }

                    System.out.println("   👤 Procesando alumno " + alumnoId + " - Estado: " + estado);

                    // Ejecutar stored procedure
                    cs.setInt(1, alumnoId);
                    cs.setInt(2, cursoId);
                    cs.setInt(3, turnoId);
                    cs.setDate(4, sqlFecha);
                    cs.setTime(5, sqlHora);
                    cs.setString(6, estado);
                    cs.setString(7, ""); // Observaciones vacías
                    cs.setInt(8, registradoPor);

                    // Ejecutar y obtener resultado
                    boolean tieneResultados = cs.execute();
                    int resultado = 0;
                    
                    if (tieneResultados) {
                        ResultSet rs = cs.getResultSet();
                        if (rs.next()) {
                            resultado = rs.getInt("filas_afectadas");
                        }
                        rs.close();
                    } else {
                        resultado = cs.getUpdateCount();
                    }
                    
                    if (resultado > 0) {
                        exitosos++;
                        System.out.println("   ✅ Alumno " + alumnoId + " guardado exitosamente");
                    } else {
                        // Puede ser un duplicado que no actualizó
                        duplicados++;
                        System.out.println("   ⚠️ Alumno " + alumnoId + " ya tenía registro o no se actualizó");
                    }

                } catch (SQLException e) {
                    // Manejar error de duplicado (código 1062 para MySQL)
                    if (e.getErrorCode() == 1062) {
                        duplicados++;
                        System.out.println("   ⚠️ Alumno duplicado (ya existe registro)");
                    } else {
                        errores++;
                        System.out.println("   ❌ Error SQL procesando alumno: " + e.getMessage());
                    }
                } catch (Exception e) {
                    errores++;
                    System.out.println("   ❌ Error procesando alumno: " + e.getMessage());
                }
            }

            // Confirmar transacción
            con.commit();
            System.out.println("✅ Transacción completada. Exitosos: " + exitosos + 
                             ", Errores: " + errores + ", Duplicados: " + duplicados + 
                             ", Total: " + alumnosList.size());

            return exitosos > 0 || duplicados > 0; // Considerar exitoso si hay exitosos o duplicados

        } catch (SQLException e) {
            System.out.println("❌ ERROR SQL en transacción: " + e.getMessage());
            e.printStackTrace();

            if (con != null) {
                try {
                    con.rollback();
                    System.out.println("🔄 Transacción revertida");
                } catch (SQLException ex) {
                    System.out.println("❌ Error al revertir transacción: " + ex.getMessage());
                }
            }
            return false;

        } catch (Exception e) {
            System.out.println("❌ ERROR general en transacción: " + e.getMessage());
            e.printStackTrace();

            if (con != null) {
                try {
                    con.rollback();
                } catch (SQLException ex) {
                    System.out.println("❌ Error al revertir transacción: " + ex.getMessage());
                }
            }
            return false;

        } finally {
            try {
                if (cs != null) cs.close();
                if (con != null) {
                    con.setAutoCommit(true);
                    con.close();
                }
            } catch (SQLException e) {
                System.out.println("⚠️ Error cerrando recursos: " + e.getMessage());
            }
        }
    }

    /**
     * MÉTODO AUXILIAR: PARSEAR JSON MANUALMENTE
     */
    private List<Map<String, Object>> parseJsonManual(String alumnosJson) {
        List<Map<String, Object>> lista = new ArrayList<>();
        
        try {
            String jsonContent = alumnosJson.trim();
            
            // Validar formato básico
            if (!jsonContent.startsWith("[") || !jsonContent.endsWith("]")) {
                System.out.println("⚠️ JSON no tiene formato de array");
                return lista;
            }
            
            // Quitar corchetes y limpiar
            jsonContent = jsonContent.substring(1, jsonContent.length() - 1).trim();
            
            if (jsonContent.isEmpty()) {
                System.out.println("⚠️ JSON vacío después de quitar corchetes");
                return lista;
            }
            
            // Dividir por objetos
            String[] objetos = jsonContent.split("\\},\\{");
            
            for (int i = 0; i < objetos.length; i++) {
                String objeto = objetos[i];
                
                // Limpiar el objeto
                if (i == 0) {
                    objeto = objeto.replaceFirst("^\\{", "");
                }
                if (i == objetos.length - 1) {
                    objeto = objeto.replaceFirst("\\}$", "");
                }
                
                objeto = objeto.trim();
                
                if (objeto.isEmpty()) {
                    continue;
                }
                
                Map<String, Object> alumnoMap = new HashMap<>();
                String[] propiedades = objeto.split(",");
                
                for (String prop : propiedades) {
                    String[] keyValue = prop.split(":", 2);
                    if (keyValue.length == 2) {
                        String key = keyValue[0].trim()
                                .replace("\"", "")
                                .replace("'", "")
                                .replace("{", "")
                                .replace("}", "");
                        String value = keyValue[1].trim()
                                .replace("\"", "")
                                .replace("'", "")
                                .replace("}", "");
                        
                        // Manejar diferentes tipos de valores
                        if (key.equals("alumno_id") || key.equals("id") || key.equals("alumnoId")) {
                            try {
                                alumnoMap.put("alumno_id", Integer.parseInt(value));
                            } catch (NumberFormatException e) {
                                alumnoMap.put("alumno_id", 0);
                            }
                        } else if (key.equals("estado")) {
                            alumnoMap.put("estado", value);
                        }
                    }
                }
                
                if (alumnoMap.containsKey("alumno_id") && alumnoMap.containsKey("estado")) {
                    lista.add(alumnoMap);
                }
            }
            
            System.out.println("✅ JSON parseado correctamente. Encontrados: " + lista.size() + " alumnos");
            
        } catch (Exception e) {
            System.out.println("❌ Error parseando JSON: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }

    /**
     * REGISTRAR ASISTENCIAS GRUPALES SIMPLIFICADO (sin procedimiento almacenado)
     * Método alternativo usando PreparedStatement
     */
    public boolean registrarAsistenciaGrupalSimple(int cursoId, int turnoId, LocalDate fecha, 
                                                  String horaClase, String alumnosJson, 
                                                  int registradoPor) {
        System.out.println("🔄 REGISTRO GRUPAL SIMPLIFICADO (Batch)");
        
        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = Conexion.getConnection();
            con.setAutoCommit(false);
            
            // SQL para insertar o actualizar (UPSERT)
            String sql = "INSERT INTO asistencia " +
                        "(alumno_id, curso_id, turno_id, fecha, hora_clase, estado, observaciones, registrado_por, fecha_registro) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW()) " +
                        "ON DUPLICATE KEY UPDATE " +
                        "estado = VALUES(estado), " +
                        "observaciones = VALUES(observaciones), " +
                        "registrado_por = VALUES(registrado_por), " +
                        "fecha_actualizacion = NOW()";
            
            ps = con.prepareStatement(sql);
            
            // Parsear JSON
            List<Map<String, Object>> alumnosList = parseJsonManual(alumnosJson);
            
            if (alumnosList.isEmpty()) {
                System.out.println("❌ No hay alumnos para procesar");
                return false;
            }
            
            java.sql.Date sqlFecha = java.sql.Date.valueOf(fecha);
            java.sql.Time sqlHora = java.sql.Time.valueOf(horaClase + ":00");
            
            int batchCount = 0;
            
            for (Map<String, Object> alumnoMap : alumnosList) {
                try {
                    Integer alumnoId = null;
                    String estado = null;
                    
                    if (alumnoMap.containsKey("alumno_id")) {
                        alumnoId = ((Number) alumnoMap.get("alumno_id")).intValue();
                    }
                    
                    if (alumnoMap.containsKey("estado")) {
                        estado = (String) alumnoMap.get("estado");
                    }
                    
                    if (alumnoId != null && alumnoId > 0 && estado != null && !estado.isEmpty()) {
                        ps.setInt(1, alumnoId);
                        ps.setInt(2, cursoId);
                        ps.setInt(3, turnoId);
                        ps.setDate(4, sqlFecha);
                        ps.setTime(5, sqlHora);
                        ps.setString(6, estado);
                        ps.setString(7, ""); // Observaciones
                        ps.setInt(8, registradoPor);
                        
                        ps.addBatch();
                        batchCount++;
                        
                        // Ejecutar batch cada 50 registros para no sobrecargar memoria
                        if (batchCount % 50 == 0) {
                            ps.executeBatch();
                        }
                    }
                } catch (Exception e) {
                    System.out.println("⚠️ Error agregando alumno a batch: " + e.getMessage());
                }
            }
            
            // Ejecutar batch final
            int[] resultados = ps.executeBatch();
            con.commit();
            
            int exitosos = 0;
            for (int resultado : resultados) {
                if (resultado >= 0 || resultado == Statement.SUCCESS_NO_INFO) {
                    exitosos++;
                }
            }
            
            System.out.println("✅ Batch completado. Exitosos: " + exitosos + " de " + batchCount);
            return exitosos > 0;
            
        } catch (Exception e) {
            System.out.println("❌ Error en registro batch: " + e.getMessage());
            e.printStackTrace();
            
            if (con != null) {
                try { 
                    con.rollback(); 
                    System.out.println("🔄 Transacción revertida");
                } catch (SQLException ex) {
                    System.out.println("❌ Error al revertir: " + ex.getMessage());
                }
            }
            return false;
            
        } finally {
            try { 
                if (ps != null) ps.close(); 
            } catch (SQLException e) {}
            try { 
                if (con != null) { 
                    con.setAutoCommit(true); 
                    con.close(); 
                } 
            } catch (SQLException e) {}
        }
    }

    /**
     * OBTENER ASISTENCIAS POR CURSO, TURNO Y FECHA
     */
    public List<Asistencia> obtenerAsistenciasPorCursoTurnoFecha(int cursoId, int turnoId, 
                                                                  String fecha) {
        List<Asistencia> lista = new ArrayList<>();
        
        // SQL directo para evitar problemas con stored procedure
        String sql = "SELECT " +
                    "a.id, a.alumno_id, a.curso_id, a.turno_id, a.fecha, a.hora_clase, " +
                    "a.estado, a.observaciones, a.registrado_por, a.fecha_registro, " +
                    "a.fecha_actualizacion, a.activo, a.eliminado, " +
                    "CONCAT(p.nombres, ' ', p.apellidos) as alumno_nombre, " +
                    "p.apellidos as alumno_apellidos, " +
                    "c.nombre as curso_nombre, " +
                    "t.nombre as turno_nombre, " +
                    "g.nombre as grado_nombre, " +
                    "CONCAT(prof_p.nombres, ' ', prof_p.apellidos) as profesor_nombre " +
                    "FROM asistencia a " +
                    "INNER JOIN alumno al ON a.alumno_id = al.id " +
                    "INNER JOIN persona p ON al.persona_id = p.id " +
                    "INNER JOIN curso c ON a.curso_id = c.id " +
                    "INNER JOIN turno t ON a.turno_id = t.id " +
                    "LEFT JOIN profesor prof ON a.registrado_por = prof.id " +
                    "LEFT JOIN persona prof_p ON prof.persona_id = prof_p.id " +
                    "LEFT JOIN grado g ON c.grado_id = g.id " +
                    "WHERE a.curso_id = ? " +
                    "AND a.turno_id = ? " +
                    "AND a.fecha = ? " +
                    "AND a.eliminado = 0 " +
                    "AND a.activo = 1 " +
                    "ORDER BY p.apellidos, p.nombres, a.hora_clase";

        try (Connection con = Conexion.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, cursoId);
            ps.setInt(2, turnoId);
            ps.setDate(3, java.sql.Date.valueOf(fecha));
            
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Asistencia a = new Asistencia();
                a.setId(rs.getInt("id"));
                a.setAlumnoId(rs.getInt("alumno_id"));
                a.setCursoId(rs.getInt("curso_id"));
                a.setTurnoId(rs.getInt("turno_id"));
                
                // Convertir SQL Date/Time a LocalDate/LocalTime
                java.sql.Date sqlFecha = rs.getDate("fecha");
                if (sqlFecha != null) {
                    a.setFecha(sqlFecha.toLocalDate());
                }
                
                java.sql.Time sqlHora = rs.getTime("hora_clase");
                if (sqlHora != null) {
                    a.setHoraClase(sqlHora.toLocalTime());
                }
                
                a.setEstadoFromString(rs.getString("estado"));
                a.setObservaciones(rs.getString("observaciones"));
                a.setRegistradoPor(rs.getInt("registrado_por"));
                
                // Manejar fechas de registro y actualización como Timestamp
                Timestamp fechaRegistro = rs.getTimestamp("fecha_registro");
                if (fechaRegistro != null) {
                    a.setFechaRegistro(fechaRegistro);
                }
                
                Timestamp fechaActualizacion = rs.getTimestamp("fecha_actualizacion");
                if (fechaActualizacion != null) {
                    a.setFechaActualizacion(fechaActualizacion);
                }
                
                a.setActivo(rs.getBoolean("activo"));
                
                // Campos adicionales
                a.setAlumnoNombre(rs.getString("alumno_nombre"));
                a.setAlumnoApellidos(rs.getString("alumno_apellidos"));
                a.setProfesorNombre(rs.getString("profesor_nombre"));
                a.setTurnoNombre(rs.getString("turno_nombre"));
                a.setCursoNombre(rs.getString("curso_nombre"));
                a.setGradoNombre(rs.getString("grado_nombre"));
                
                lista.add(a);
            }

            System.out.println("✅ Asistencias encontradas: " + lista.size() + 
                             " para curso " + cursoId + ", fecha " + fecha);

        } catch (SQLException e) {
            System.out.println("❌ Error SQL al obtener asistencias:");
            System.out.println("   Mensaje: " + e.getMessage());
            e.printStackTrace();
        }

        return lista;
    }

    /**
     * OBTENER ASISTENCIAS POR ALUMNO Y TURNO
     */
    public List<Asistencia> obtenerAsistenciasPorAlumnoTurno(int alumnoId, int turnoId, 
                                                              int mes, int anio) {
        List<Asistencia> lista = new ArrayList<>();
        String sql = "{CALL obtener_asistencias_por_alumno_turno(?, ?, ?, ?)}";

        try (Connection con = Conexion.getConnection(); 
             CallableStatement cs = con.prepareCall(sql)) {

            cs.setInt(1, alumnoId);
            cs.setInt(2, turnoId);
            cs.setInt(3, mes);
            cs.setInt(4, anio);
            
            ResultSet rs = cs.executeQuery();

            while (rs.next()) {
                Asistencia a = new Asistencia();
                a.setId(rs.getInt("id"));
                a.setAlumnoId(rs.getInt("alumno_id"));
                a.setCursoId(rs.getInt("curso_id"));
                a.setTurnoId(rs.getInt("turno_id"));
                
                java.sql.Date sqlFecha = rs.getDate("fecha");
                if (sqlFecha != null) {
                    a.setFecha(sqlFecha.toLocalDate());
                }
                
                java.sql.Time sqlHora = rs.getTime("hora_clase");
                if (sqlHora != null) {
                    a.setHoraClase(sqlHora.toLocalTime());
                }
                
                a.setEstadoFromString(rs.getString("estado"));
                a.setObservaciones(rs.getString("observaciones"));
                a.setRegistradoPor(rs.getInt("registrado_por"));
                
                // Manejar fechas de registro y actualización como Timestamp
                Timestamp fechaRegistro = rs.getTimestamp("fecha_registro");
                if (fechaRegistro != null) {
                    a.setFechaRegistro(fechaRegistro);
                }
                
                Timestamp fechaActualizacion = rs.getTimestamp("fecha_actualizacion");
                if (fechaActualizacion != null) {
                    a.setFechaActualizacion(fechaActualizacion);
                }
                
                a.setActivo(rs.getBoolean("activo"));
                
                a.setCursoNombre(rs.getString("curso_nombre"));
                a.setTurnoNombre(rs.getString("turno_nombre"));
                a.setGradoNombre(rs.getString("grado_nombre"));
                a.setAlumnoNombre(rs.getString("alumno_nombre"));
                a.setAlumnoApellidos(rs.getString("alumno_apellidos"));
                a.setSedeNombre(rs.getString("sede_nombre"));
                a.setAulaNombre(rs.getString("aula_nombre"));
                
                lista.add(a);
            }

            System.out.println("✅ Asistencias encontradas para alumno " + alumnoId + ": " + lista.size());

        } catch (SQLException e) {
            System.out.println("❌ Error SQL al obtener asistencias por alumno:");
            System.out.println("   Mensaje: " + e.getMessage());
            e.printStackTrace();
        }

        return lista;
    }

    /**
     * OBTENER AUSENCIAS POR JUSTIFICAR
     */
    public List<Asistencia> obtenerAusenciasPorJustificar(int alumnoId) {
        List<Asistencia> lista = new ArrayList<>();
        
        String sql = "SELECT " +
                    "a.id, a.fecha, a.hora_clase, a.estado, " +
                    "c.nombre as curso_nombre, a.alumno_id " +
                    "FROM asistencia a " +
                    "JOIN curso c ON a.curso_id = c.id " +
                    "WHERE a.alumno_id = ? " +
                    "AND a.estado = 'AUSENTE' " +
                    "AND a.id NOT IN (SELECT asistencia_id FROM justificacion WHERE estado = 'APROBADO') " +
                    "AND a.eliminado = 0 " +
                    "AND a.activo = 1 " +
                    "ORDER BY a.fecha DESC, a.hora_clase DESC";

        System.out.println("🔍 Obteniendo ausencias por justificar para alumno: " + alumnoId);

        try (Connection con = Conexion.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, alumnoId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Asistencia a = new Asistencia();
                a.setId(rs.getInt("id"));
                
                java.sql.Date sqlFecha = rs.getDate("fecha");
                if (sqlFecha != null) {
                    a.setFecha(sqlFecha.toLocalDate());
                }
                
                java.sql.Time sqlHora = rs.getTime("hora_clase");
                if (sqlHora != null) {
                    a.setHoraClase(sqlHora.toLocalTime());
                }
                
                a.setEstadoFromString(rs.getString("estado"));
                a.setCursoNombre(rs.getString("curso_nombre"));
                a.setAlumnoId(rs.getInt("alumno_id"));
                
                lista.add(a);
                System.out.println("   📅 Ausencia: " + a.getFechaFormateada() + " - " + a.getCursoNombre());
            }

            System.out.println("✅ Total ausencias encontradas: " + lista.size());

        } catch (SQLException e) {
            System.out.println("❌ Error SQL al obtener ausencias:");
            System.out.println("   Mensaje: " + e.getMessage());
            e.printStackTrace();
        }

        return lista;
    }

    /**
     * OBTENER RESUMEN DE ASISTENCIA
     */
    public Map<String, Object> obtenerResumenAsistenciaAlumnoTurno(int alumnoId, int turnoId, 
                                                                    int mes, int anio) {
        Map<String, Object> resumen = new HashMap<>();
        
        List<Asistencia> asistencias = obtenerAsistenciasPorAlumnoTurno(alumnoId, turnoId, mes, anio);
        
        int totalClases = asistencias.size();
        int presentes = 0;
        int tardanzas = 0;
        int ausentes = 0;
        int justificados = 0;
        
        for (Asistencia a : asistencias) {
            switch (a.getEstado()) {
                case PRESENTE:
                    presentes++;
                    break;
                case TARDANZA:
                    tardanzas++;
                    break;
                case AUSENTE:
                    ausentes++;
                    break;
                case JUSTIFICADO:
                    justificados++;
                    break;
            }
        }
        
        double porcentaje = totalClases > 0 
            ? ((presentes + tardanzas + justificados) * 100.0) / totalClases 
            : 0.0;
        
        resumen.put("totalClases", totalClases);
        resumen.put("presentes", presentes);
        resumen.put("tardanzas", tardanzas);
        resumen.put("ausentes", ausentes);
        resumen.put("justificados", justificados);
        resumen.put("porcentajeAsistencia", porcentaje);
        resumen.put("alumnoId", alumnoId);
        resumen.put("turnoId", turnoId);
        resumen.put("mes", mes);
        resumen.put("anio", anio);
        
        System.out.println("📊 Resumen - Alumno " + alumnoId + ": " + 
                         String.format("%.2f", porcentaje) + "% de asistencia");
        
        return resumen;
    }
    
    /**
     * OBTENER RESUMEN DE ASISTENCIA POR CURSO
     */
    public Map<String, Object> obtenerResumenAsistenciaCurso(int cursoId, int turnoId, 
                                                             String fecha) {
        Map<String, Object> resumen = new HashMap<>();
        List<Asistencia> asistencias = obtenerAsistenciasPorCursoTurnoFecha(cursoId, turnoId, fecha);
        
        int totalAlumnos = asistencias.size();
        int presentes = 0;
        int tardanzas = 0;
        int ausentes = 0;
        int justificados = 0;
        
        for (Asistencia a : asistencias) {
            switch (a.getEstado()) {
                case PRESENTE:
                    presentes++;
                    break;
                case TARDANZA:
                    tardanzas++;
                    break;
                case AUSENTE:
                    ausentes++;
                    break;
                case JUSTIFICADO:
                    justificados++;
                    break;
            }
        }
        
        double porcentaje = totalAlumnos > 0 
            ? ((presentes + tardanzas + justificados) * 100.0) / totalAlumnos 
            : 0.0;
        
        resumen.put("totalAlumnos", totalAlumnos);
        resumen.put("presentes", presentes);
        resumen.put("tardanzas", tardanzas);
        resumen.put("ausentes", ausentes);
        resumen.put("justificados", justificados);
        resumen.put("porcentajeAsistencia", porcentaje);
        resumen.put("cursoId", cursoId);
        resumen.put("turnoId", turnoId);
        resumen.put("fecha", fecha);
        
        System.out.println("📊 Resumen - Curso " + cursoId + ": " + 
                         totalAlumnos + " alumnos, " + 
                         String.format("%.2f", porcentaje) + "% de asistencia");
        
        return resumen;
    }
    
    /**
     * ACTUALIZAR ESTADO DE ASISTENCIA
     */
    public boolean actualizarAsistencia(int asistenciaId, Asistencia.EstadoAsistencia estado, 
                                        String observaciones) {
        String sql = "UPDATE asistencia SET estado = ?, observaciones = ?, fecha_actualizacion = NOW() " +
                    "WHERE id = ? AND eliminado = 0";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, estado.name());
            ps.setString(2, observaciones);
            ps.setInt(3, asistenciaId);
            
            int resultado = ps.executeUpdate();
            System.out.println("✅ Asistencia actualizada. Filas afectadas: " + resultado);
            return resultado > 0;
            
        } catch (SQLException e) {
            System.out.println("❌ Error SQL al actualizar asistencia:");
            System.out.println("   Mensaje: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * OBTENER ASISTENCIA POR ID
     */
    public Asistencia obtenerAsistenciaPorId(int asistenciaId) {
        String sql = "SELECT " +
                    "a.*, " +
                    "CONCAT(p.nombres, ' ', p.apellidos) as alumno_nombre, " +
                    "p.apellidos as alumno_apellidos, " +
                    "c.nombre as curso_nombre, " +
                    "t.nombre as turno_nombre, " +
                    "CONCAT(prof_p.nombres, ' ', prof_p.apellidos) as profesor_nombre, " +
                    "g.nombre as grado_nombre " +
                    "FROM asistencia a " +
                    "INNER JOIN alumno al ON a.alumno_id = al.id " +
                    "INNER JOIN persona p ON al.persona_id = p.id " +
                    "INNER JOIN curso c ON a.curso_id = c.id " +
                    "INNER JOIN turno t ON a.turno_id = t.id " +
                    "LEFT JOIN profesor prof ON a.registrado_por = prof.id " +
                    "LEFT JOIN persona prof_p ON prof.persona_id = prof_p.id " +
                    "LEFT JOIN grado g ON c.grado_id = g.id " +
                    "WHERE a.id = ? " +
                    "AND a.eliminado = 0";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, asistenciaId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                Asistencia a = new Asistencia();
                a.setId(rs.getInt("id"));
                a.setAlumnoId(rs.getInt("alumno_id"));
                a.setCursoId(rs.getInt("curso_id"));
                a.setTurnoId(rs.getInt("turno_id"));
                
                java.sql.Date sqlFecha = rs.getDate("fecha");
                if (sqlFecha != null) {
                    a.setFecha(sqlFecha.toLocalDate());
                }
                
                java.sql.Time sqlHora = rs.getTime("hora_clase");
                if (sqlHora != null) {
                    a.setHoraClase(sqlHora.toLocalTime());
                }
                
                a.setEstadoFromString(rs.getString("estado"));
                a.setObservaciones(rs.getString("observaciones"));
                a.setRegistradoPor(rs.getInt("registrado_por"));
                
                // Manejar fechas de registro y actualización como Timestamp
                Timestamp fechaRegistro = rs.getTimestamp("fecha_registro");
                if (fechaRegistro != null) {
                    a.setFechaRegistro(fechaRegistro);
                }
                
                Timestamp fechaActualizacion = rs.getTimestamp("fecha_actualizacion");
                if (fechaActualizacion != null) {
                    a.setFechaActualizacion(fechaActualizacion);
                }
                
                a.setActivo(rs.getBoolean("activo"));
                
                // Campos adicionales
                a.setAlumnoNombre(rs.getString("alumno_nombre"));
                a.setAlumnoApellidos(rs.getString("alumno_apellidos"));
                a.setCursoNombre(rs.getString("curso_nombre"));
                a.setTurnoNombre(rs.getString("turno_nombre"));
                a.setProfesorNombre(rs.getString("profesor_nombre"));
                a.setGradoNombre(rs.getString("grado_nombre"));
                
                return a;
            }
            
        } catch (SQLException e) {
            System.out.println("❌ Error SQL al obtener asistencia por ID:");
            System.out.println("   Mensaje: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * OBTENER ASISTENCIAS POR RANGO DE FECHAS
     */
    public List<Asistencia> obtenerAsistenciasPorRangoFechas(String fechaInicio, String fechaFin, 
                                                               int cursoId, int turnoId) {
        List<Asistencia> lista = new ArrayList<>();
        String sql = "SELECT " +
                    "a.id, a.alumno_id, a.curso_id, a.turno_id, a.fecha, a.hora_clase, " +
                    "a.estado, a.observaciones, a.registrado_por, " +
                    "CONCAT(p.nombres, ' ', p.apellidos) as alumno_nombre, " +
                    "p.apellidos as alumno_apellidos, " +
                    "c.nombre as curso_nombre, " +
                    "t.nombre as turno_nombre " +
                    "FROM asistencia a " +
                    "INNER JOIN alumno al ON a.alumno_id = al.id " +
                    "INNER JOIN persona p ON al.persona_id = p.id " +
                    "INNER JOIN curso c ON a.curso_id = c.id " +
                    "INNER JOIN turno t ON a.turno_id = t.id " +
                    "WHERE a.curso_id = ? " +
                    "AND a.turno_id = ? " +
                    "AND a.fecha BETWEEN ? AND ? " +
                    "AND a.eliminado = 0 " +
                    "AND a.activo = 1 " +
                    "ORDER BY a.fecha, a.hora_clase, p.apellidos";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, cursoId);
            ps.setInt(2, turnoId);
            ps.setDate(3, java.sql.Date.valueOf(fechaInicio));
            ps.setDate(4, java.sql.Date.valueOf(fechaFin));
            
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Asistencia a = new Asistencia();
                a.setId(rs.getInt("id"));
                a.setAlumnoId(rs.getInt("alumno_id"));
                a.setCursoId(rs.getInt("curso_id"));
                a.setTurnoId(rs.getInt("turno_id"));
                
                java.sql.Date sqlFecha = rs.getDate("fecha");
                if (sqlFecha != null) {
                    a.setFecha(sqlFecha.toLocalDate());
                }
                
                java.sql.Time sqlHora = rs.getTime("hora_clase");
                if (sqlHora != null) {
                    a.setHoraClase(sqlHora.toLocalTime());
                }
                
                a.setEstadoFromString(rs.getString("estado"));
                a.setObservaciones(rs.getString("observaciones"));
                a.setRegistradoPor(rs.getInt("registrado_por"));
                
                // Campos adicionales
                a.setAlumnoNombre(rs.getString("alumno_nombre"));
                a.setAlumnoApellidos(rs.getString("alumno_apellidos"));
                a.setCursoNombre(rs.getString("curso_nombre"));
                a.setTurnoNombre(rs.getString("turno_nombre"));
                
                lista.add(a);
            }
            
            System.out.println("✅ Asistencias encontradas en rango: " + lista.size());
            
        } catch (SQLException e) {
            System.out.println("❌ Error SQL al obtener asistencias por rango:");
            System.out.println("   Mensaje: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }
    
    /**
     * VERIFICAR SI HAY ASISTENCIAS REGISTRADAS PARA UN CURSO EN UNA FECHA
     */
    public boolean existenAsistenciasParaCursoFecha(int cursoId, int turnoId, LocalDate fecha) {
        String sql = "SELECT COUNT(*) as total FROM asistencia " +
                    "WHERE curso_id = ? AND turno_id = ? AND fecha = ? " +
                    "AND activo = 1 AND eliminado = 0";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, cursoId);
            ps.setInt(2, turnoId);
            ps.setDate(3, java.sql.Date.valueOf(fecha));
            
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                int total = rs.getInt("total");
                System.out.println("ℹ️ Asistencias existentes para curso " + cursoId + 
                                 ", fecha " + fecha + ": " + total);
                return total > 0;
            }
            
        } catch (SQLException e) {
            System.out.println("❌ Error al verificar asistencias existentes: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * OBTENER ESTADO DE ASISTENCIA DE UN ALUMNO ESPECÍFICO
     */
    public String obtenerEstadoAsistenciaAlumno(int alumnoId, int cursoId, int turnoId, LocalDate fecha) {
        String sql = "SELECT estado FROM asistencia " +
                    "WHERE alumno_id = ? AND curso_id = ? AND turno_id = ? AND fecha = ? " +
                    "AND activo = 1 AND eliminado = 0 " +
                    "ORDER BY hora_clase DESC LIMIT 1";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, alumnoId);
            ps.setInt(2, cursoId);
            ps.setInt(3, turnoId);
            ps.setDate(4, java.sql.Date.valueOf(fecha));
            
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getString("estado");
            }
            
        } catch (SQLException e) {
            System.out.println("❌ Error al obtener estado de asistencia: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * ELIMINAR ASISTENCIA (ELIMINACIÓN LÓGICA)
     */
    public boolean eliminarAsistencia(int asistenciaId) {
        String sql = "UPDATE asistencia SET eliminado = 1, activo = 0, fecha_actualizacion = NOW() " +
                    "WHERE id = ?";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, asistenciaId);
            int resultado = ps.executeUpdate();
            
            System.out.println("🗑️ Asistencia eliminada lógicamente. ID: " + asistenciaId + 
                             ", Filas afectadas: " + resultado);
            return resultado > 0;
            
        } catch (SQLException e) {
            System.out.println("❌ Error al eliminar asistencia: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * OBTENER ESTADÍSTICAS DE ASISTENCIA PARA REPORTES
     */
    public Map<String, Object> obtenerEstadisticasAsistencia(int cursoId, int turnoId, 
                                                             String mes, String anio) {
        Map<String, Object> estadisticas = new HashMap<>();
        
        String sql = "SELECT " +
                    "COUNT(*) as total_asistencias, " +
                    "SUM(CASE WHEN estado = 'PRESENTE' THEN 1 ELSE 0 END) as presentes, " +
                    "SUM(CASE WHEN estado = 'TARDANZA' THEN 1 ELSE 0 END) as tardanzas, " +
                    "SUM(CASE WHEN estado = 'AUSENTE' THEN 1 ELSE 0 END) as ausentes, " +
                    "SUM(CASE WHEN estado = 'JUSTIFICADO' THEN 1 ELSE 0 END) as justificados " +
                    "FROM asistencia " +
                    "WHERE curso_id = ? " +
                    "AND turno_id = ? " +
                    "AND YEAR(fecha) = ? " +
                    "AND MONTH(fecha) = ? " +
                    "AND activo = 1 " +
                    "AND eliminado = 0";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, cursoId);
            ps.setInt(2, turnoId);
            ps.setString(3, anio);
            ps.setString(4, mes);
            
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                int total = rs.getInt("total_asistencias");
                int presentes = rs.getInt("presentes");
                int tardanzas = rs.getInt("tardanzas");
                int ausentes = rs.getInt("ausentes");
                int justificados = rs.getInt("justificados");
                
                double porcentajeAsistencia = total > 0 
                    ? ((presentes + tardanzas + justificados) * 100.0) / total 
                    : 0.0;
                
                estadisticas.put("total_asistencias", total);
                estadisticas.put("presentes", presentes);
                estadisticas.put("tardanzas", tardanzas);
                estadisticas.put("ausentes", ausentes);
                estadisticas.put("justificados", justificados);
                estadisticas.put("porcentaje_asistencia", porcentajeAsistencia);
                estadisticas.put("mes", mes);
                estadisticas.put("anio", anio);
                estadisticas.put("curso_id", cursoId);
                estadisticas.put("turno_id", turnoId);
                
                System.out.println("📈 Estadísticas obtenidas: " + total + " registros totales");
            }
            
        } catch (SQLException e) {
            System.out.println("❌ Error al obtener estadísticas: " + e.getMessage());
            e.printStackTrace();
        }
        
        return estadisticas;
    }
}