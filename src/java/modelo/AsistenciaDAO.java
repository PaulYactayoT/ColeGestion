/*
 * DAO PARA GESTION DE ASISTENCIAS ESCOLARES
 * 
 * Funcionalidades:
 * - Registro individual y grupal de asistencias
 * - Consultas por curso, alumno y fecha
 * - Reportes y resumenes estadisticos
 * - Gestion de ausencias por justificar
 */
package modelo;

import conexion.Conexion;
import java.sql.*;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.LocalDateTime;
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

            int resultado = cs.executeUpdate();
            System.out.println("Asistencia registrada. Filas afectadas: " + resultado);
            return resultado > 0;

        } catch (SQLException e) {
            System.out.println("Error SQL al registrar asistencia:");
            System.out.println("   Codigo: " + e.getErrorCode());
            System.out.println("   Estado: " + e.getSQLState());
            System.out.println("   Mensaje: " + e.getMessage());
            e.printStackTrace();
            return false;
        } catch (Exception e) {
            System.out.println("Error general al registrar asistencia");
            e.printStackTrace();
            return false;
        }
    }

    /**
     * REGISTRAR ASISTENCIAS GRUPALES (MULTIPLES ALUMNOS)
     * 
     * @param cursoId Identificador del curso
     * @param turnoId Identificador del turno
     * @param fecha Fecha de la asistencia
     * @param horaClase Hora de la clase
     * @param alumnosJson Datos de alumnos en formato JSON
     * @param registradoPor ID del usuario que registra
     * @return true si al menos un registro fue exitoso
     */
    public boolean registrarAsistenciaGrupal(int cursoId, int turnoId, String fecha, 
                                            String horaClase, String alumnosJson, 
                                            int registradoPor) {
        System.out.println("INICIANDO DAO REGISTRO GRUPAL");
        System.out.println("   cursoId: " + cursoId);
        System.out.println("   turnoId: " + turnoId);
        System.out.println("   fecha: " + fecha);
        System.out.println("   horaClase: " + horaClase);
        System.out.println("   registradoPor: " + registradoPor);

        Connection con = null;
        CallableStatement cs = null;

        try {
            con = Conexion.getConnection();
            con.setAutoCommit(false); // Iniciar transaccion

            // Validar JSON
            if (alumnosJson == null || alumnosJson.trim().isEmpty()) {
                System.out.println("ERROR: JSON de alumnos esta vacio");
                return false;
            }

            String jsonContent = alumnosJson.trim();
            if (!jsonContent.startsWith("[") || !jsonContent.endsWith("]")) {
                System.out.println("ERROR: Formato JSON invalido - no es un array");
                return false;
            }

            // Parsear JSON manualmente
            String contenido = jsonContent.substring(1, jsonContent.length() - 1);
            String[] objetos = contenido.split("\\},\\{");

            System.out.println("Total de alumnos a procesar: " + objetos.length);

            // Preparar el stored procedure
            String sql = "{CALL registrar_asistencia(?, ?, ?, ?, ?, ?, ?, ?)}";
            cs = con.prepareCall(sql);

            // Convertir fecha y hora a tipos SQL
            java.sql.Date sqlFecha = java.sql.Date.valueOf(fecha);
            java.sql.Time sqlHora = java.sql.Time.valueOf(horaClase);

            int exitosos = 0;
            int errores = 0;

            for (int i = 0; i < objetos.length; i++) {
                String objeto = objetos[i];
                
                // Limpiar el objeto
                if (i == 0) {
                    objeto = objeto.substring(1); // Quitar { inicial
                }
                if (i == objetos.length - 1) {
                    objeto = objeto.substring(0, objeto.length() - 1); // Quitar } final
                }
                
                // Parsear manualmente
                int alumnoId = 0;
                String estado = "";

                try {
                    String[] propiedades = objeto.split(",");
                    for (String prop : propiedades) {
                        String[] keyValue = prop.split(":");
                        if (keyValue.length == 2) {
                            String key = keyValue[0].replace("\"", "").trim();
                            String value = keyValue[1].replace("\"", "").trim();

                            if ("alumno_id".equals(key)) {
                                alumnoId = Integer.parseInt(value);
                            } else if ("estado".equals(key)) {
                                estado = value;
                            }
                        }
                    }

                    System.out.println("   Procesando alumno " + alumnoId + " - Estado: " + estado);

                    // Validar datos
                    if (alumnoId <= 0 || estado.isEmpty()) {
                        System.out.println("   Datos invalidos para alumno, saltando...");
                        errores++;
                        continue;
                    }

                    // Ejecutar stored procedure
                    cs.setInt(1, alumnoId);
                    cs.setInt(2, cursoId);
                    cs.setInt(3, turnoId);
                    cs.setDate(4, sqlFecha);
                    cs.setTime(5, sqlHora);
                    cs.setString(6, estado);
                    cs.setString(7, ""); // Observaciones vacias para registro grupal
                    cs.setInt(8, registradoPor);

                    int resultado = cs.executeUpdate();
                    if (resultado > 0) {
                        exitosos++;
                        System.out.println("   Alumno " + alumnoId + " guardado exitosamente");
                    } else {
                        errores++;
                        System.out.println("   Alumno " + alumnoId + " no se pudo guardar");
                    }

                } catch (Exception e) {
                    errores++;
                    System.out.println("   Error procesando alumno: " + e.getMessage());
                }
            }

            // Confirmar transaccion
            con.commit();
            System.out.println("Transaccion completada. Exitosos: " + exitosos + 
                             ", Errores: " + errores + ", Total: " + objetos.length);

            return exitosos > 0;

        } catch (SQLException e) {
            System.out.println("ERROR SQL en transaccion: " + e.getMessage());
            e.printStackTrace();

            if (con != null) {
                try {
                    con.rollback();
                    System.out.println("Transaccion revertida");
                } catch (SQLException ex) {
                    System.out.println("Error al revertir transaccion: " + ex.getMessage());
                }
            }
            return false;

        } catch (Exception e) {
            System.out.println("ERROR general en transaccion: " + e.getMessage());
            e.printStackTrace();

            if (con != null) {
                try {
                    con.rollback();
                } catch (SQLException ex) {
                    System.out.println("Error al revertir transaccion: " + ex.getMessage());
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
                System.out.println("Error cerrando recursos: " + e.getMessage());
            }
        }
    }

    /**
     * OBTENER ASISTENCIAS POR CURSO, TURNO Y FECHA
     */
    public List<Asistencia> obtenerAsistenciasPorCursoTurnoFecha(int cursoId, int turnoId, 
                                                                  String fecha) {
        List<Asistencia> lista = new ArrayList<>();
        String sql = "{CALL obtener_asistencias_por_curso_turno_fecha(?, ?, ?)}";

        try (Connection con = Conexion.getConnection(); 
             CallableStatement cs = con.prepareCall(sql)) {

            cs.setInt(1, cursoId);
            cs.setInt(2, turnoId);
            cs.setDate(3, java.sql.Date.valueOf(fecha));
            
            ResultSet rs = cs.executeQuery();

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
                a.setAlumnoNombre(rs.getString("alumno_nombre"));
                a.setAlumnoApellidos(rs.getString("alumno_apellidos"));
                a.setProfesorNombre(rs.getString("profesor_nombre"));
                a.setTurnoNombre(rs.getString("turno_nombre"));
                
                lista.add(a);
            }

            System.out.println("Asistencias encontradas: " + lista.size());

        } catch (SQLException e) {
            System.out.println("Error SQL al obtener asistencias:");
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
                a.setCursoNombre(rs.getString("curso_nombre"));
                a.setTurnoNombre(rs.getString("turno_nombre"));
                a.setGradoNombre(rs.getString("grado_nombre"));
                
                lista.add(a);
            }

            System.out.println("Asistencias encontradas: " + lista.size());

        } catch (SQLException e) {
            System.out.println("Error SQL al obtener asistencias por alumno:");
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
        String sql = "{CALL obtener_ausencias_por_justificar(?)}";

        System.out.println("Obteniendo ausencias por justificar para alumno: " + alumnoId);

        try (Connection con = Conexion.getConnection(); 
             CallableStatement cs = con.prepareCall(sql)) {

            cs.setInt(1, alumnoId);
            ResultSet rs = cs.executeQuery();

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
                System.out.println("Ausencia: " + a.getFechaFormateada() + " - " + a.getCursoNombre());
            }

            System.out.println("Total ausencias encontradas: " + lista.size());

        } catch (SQLException e) {
            System.out.println("Error SQL al obtener ausencias:");
            System.out.println("   Mensaje: " + e.getMessage());
            e.printStackTrace();
        }

        return lista;
    }

    /**
     * OBTENER RESUMEN DE ASISTENCIA (si existe el SP en tu BD)
     */
    public Map<String, Object> obtenerResumenAsistenciaAlumnoTurno(int alumnoId, int turnoId, 
                                                                    int mes, int anio) {
        Map<String, Object> resumen = new HashMap<>();
        
        // Nota: Este SP no está en tu BD actual, puedes crearlo o calcularlo manualmente
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
        
        System.out.println("Resumen - Asistencia: " + String.format("%.2f", porcentaje) + "%");
        
        return resumen;
    }
    
    /**
     * VERIFICAR SI SE PUEDE EDITAR ASISTENCIA (según límite de tiempo)
     */
    public Map<String, Object> verificarLimiteEdicion(int cursoId, int turnoId, 
                                                      String diaSemana, String horaClase, 
                                                      String fecha) {
        Map<String, Object> resultado = new HashMap<>();
        String sql = "{CALL verificar_limite_edicion_asistencia(?, ?, ?, ?, ?)}";
        
        try (Connection con = Conexion.getConnection(); 
             CallableStatement cs = con.prepareCall(sql)) {
            
            cs.setInt(1, cursoId);
            cs.setInt(2, turnoId);
            cs.setString(3, diaSemana);
            cs.setTime(4, java.sql.Time.valueOf(horaClase));
            cs.setDate(5, java.sql.Date.valueOf(fecha));
            
            ResultSet rs = cs.executeQuery();
            
            if (rs.next()) {
                resultado.put("puedeEditar", rs.getBoolean("puede_editar"));
                resultado.put("fechaLimite", rs.getTimestamp("fecha_limite"));
                resultado.put("limiteMinutos", rs.getInt("limite_minutos"));
                resultado.put("fechaActual", rs.getTimestamp("fecha_actual"));
            }
            
        } catch (SQLException e) {
            System.out.println("Error al verificar límite de edición:");
            System.out.println("   Mensaje: " + e.getMessage());
            e.printStackTrace();
            resultado.put("puedeEditar", false);
        }
        
        return resultado;
    }
}