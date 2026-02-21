package modelo;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import conexion.Conexion; 

public class DisponibilidadDAO {

    // Resultado con éxito + mensaje real del procedimiento almacenado
    public static class ResultadoDisponibilidad {
        public final boolean exito;
        public final String mensaje;
        public ResultadoDisponibilidad(boolean exito, String mensaje) {
            this.exito   = exito;
            this.mensaje = mensaje;
        }
    }

    /**
     * Registra disponibilidad y devuelve el mensaje REAL del SP.
     * Antes se perdía el mensaje "Bloqueado: No puedes editar un horario APROBADO"
     * y se mostraba el genérico "Error al guardar (posible duplicado)".
     */
    public ResultadoDisponibilidad registrarDisponibilidadConMensaje(Disponibilidad dispo) {
        Connection con = null;
        CallableStatement cs = null;
        ResultSet rs = null;
        String sql = "{CALL sp_gestion_disponibilidad_hu10(?, ?, ?, ?, ?)}";

        try {
            con = Conexion.getConnection();
            if (con != null) {
                cs = con.prepareCall(sql);
                cs.setInt(1, dispo.getProfesorId());
                cs.setInt(2, dispo.getTurnoId());
                cs.setString(3, dispo.getDiaSemana());
                cs.setTime(4, dispo.getHoraInicio());
                cs.setTime(5, dispo.getHoraFin());

                rs = cs.executeQuery();

                if (rs.next()) {
                    boolean exito   = rs.getInt("exito") == 1;
                    String  mensaje = rs.getString("mensaje");
                    System.out.println("SP → exito=" + exito + " | mensaje=" + mensaje);
                    return new ResultadoDisponibilidad(exito, mensaje);
                }
            }
        } catch (SQLException e) {
            System.out.println("Error registro: " + e.getMessage());
            return new ResultadoDisponibilidad(false, "Error de base de datos: " + e.getMessage());
        } finally {
            try {
                if (rs  != null) rs.close();
                if (cs  != null) cs.close();
                if (con != null) con.close();
            } catch (Exception e) {
                System.out.println("Error cerrando recursos: " + e.getMessage());
            }
        }
        return new ResultadoDisponibilidad(false, "No se pudo conectar a la base de datos.");
    }

    // Mantener compatibilidad con código existente
    public boolean registrarDisponibilidad(Disponibilidad dispo) {
        return registrarDisponibilidadConMensaje(dispo).exito;
    }

    public List<Disponibilidad> listarPorProfesor(int profesorId) {
        List<Disponibilidad> lista = new ArrayList<>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        System.out.println("📂 [DAO] listarPorProfesor - Profesor ID: " + profesorId);
        
        // ✅ QUERY SIN CACHÉ - Siempre trae datos frescos
        String sql = "SELECT d.*, t.nombre as nombre_turno " +
                     "FROM disponibilidad_profesor d " +
                     "INNER JOIN turno t ON d.turno_id = t.id " +
                     "WHERE d.profesor_id = ? AND d.eliminado = 0 " +
                     "ORDER BY FIELD(d.dia_semana, 'LUNES', 'MARTES', 'MIERCOLES', 'JUEVES', 'VIERNES', 'SABADO'), d.hora_inicio";
        
        try {
            // ✅ IMPORTANTE: Nueva conexión cada vez (sin caché)
            con = Conexion.getConnection();
            
            if (con != null) {
                System.out.println("   ✅ Conexión obtenida");
                
                // ✅ Desactivar auto-commit para evitar caché
                con.setAutoCommit(true);
                
                ps = con.prepareStatement(sql, 
                    ResultSet.TYPE_SCROLL_INSENSITIVE,  // ✅ No sensitivo a cambios
                    ResultSet.CONCUR_READ_ONLY);         // ✅ Solo lectura
                
                ps.setInt(1, profesorId);
                
                System.out.println("   🔍 Ejecutando query...");
                rs = ps.executeQuery();
                
                int contador = 0;
                while (rs.next()) {
                    Disponibilidad d = new Disponibilidad();
                    d.setId(rs.getInt("id")); 
                    d.setProfesorId(rs.getInt("profesor_id")); 
                    d.setTurnoId(rs.getInt("turno_id"));
                    d.setTurnoNombre(rs.getString("nombre_turno")); 
                    d.setDiaSemana(rs.getString("dia_semana"));
                    d.setHoraInicio(rs.getTime("hora_inicio")); 
                    d.setHoraFin(rs.getTime("hora_fin"));
                    
                    // ✅ CRÍTICO: Leer el estado directamente de la BD
                    String estadoFromDB = rs.getString("estado");
                    d.setEstado(estadoFromDB);
                    
                    d.setActivo(rs.getBoolean("activo")); 
                    d.setObservaciones(rs.getString("observaciones"));
                    
                    System.out.println("   📝 Registro " + (++contador) + ": ID=" + d.getId() + 
                                     " | Estado=" + estadoFromDB);
                    
                    lista.add(d);
                }
                
                System.out.println("   ✅ Total registros procesados: " + contador);
            } else {
                System.err.println("   ❌ Conexión es NULL");
            }
        } catch (SQLException e) { 
            System.err.println("   ❌ Error SQL: " + e.getMessage());
            e.printStackTrace();
        } finally { 
            try { 
                if(rs != null) { rs.close(); System.out.println("   🔒 ResultSet cerrado"); }
                if(ps != null) { ps.close(); System.out.println("   🔒 PreparedStatement cerrado"); }
                if(con != null) { con.close(); System.out.println("   🔒 Conexión cerrada"); }
            } catch(Exception e) {
                System.err.println("   ❌ Error cerrando recursos: " + e.getMessage());
            } 
        }
        
        return lista;
    }

    public boolean eliminarDisponibilidad(int id) {
        boolean exito = false; 
        Connection con = null; 
        PreparedStatement ps = null;
        
        try { 
            con = Conexion.getConnection(); 
            if (con != null) { 
                ps = con.prepareStatement("UPDATE disponibilidad_profesor SET eliminado = 1, activo = 0 WHERE id = ?"); 
                ps.setInt(1, id); 
                exito = (ps.executeUpdate() > 0); 
            } 
        } catch (SQLException e) { } 
        finally { 
            try { 
                if(ps != null) ps.close(); 
                if(con != null) con.close(); 
            } catch(Exception e) {} 
        } 
        return exito;
    }

    public Disponibilidad obtenerPorId(int id) {
        Disponibilidad d = null; 
        Connection con = null; 
        PreparedStatement ps = null; 
        ResultSet rs = null;
        
        try { 
            con = Conexion.getConnection(); 
            if (con != null) { 
                ps = con.prepareStatement("SELECT * FROM disponibilidad_profesor WHERE id = ?"); 
                ps.setInt(1, id); 
                rs = ps.executeQuery(); 
                
                if (rs.next()) { 
                    d = new Disponibilidad(); 
                    d.setId(rs.getInt("id")); 
                    d.setProfesorId(rs.getInt("profesor_id")); 
                    d.setTurnoId(rs.getInt("turno_id")); 
                    d.setDiaSemana(rs.getString("dia_semana")); 
                    d.setHoraInicio(rs.getTime("hora_inicio")); 
                    d.setHoraFin(rs.getTime("hora_fin")); 
                    d.setEstado(rs.getString("estado")); 
                    d.setObservaciones(rs.getString("observaciones")); 
                } 
            } 
        } catch (SQLException e) { } 
        finally { 
            try { 
                if(rs != null) rs.close(); 
                if(ps != null) ps.close(); 
                if(con != null) con.close(); 
            } catch(Exception e) {} 
        } 
        return d;
    }

    public boolean actualizarDisponibilidad(Disponibilidad d) {
        boolean exito = false; 
        Connection con = null; 
        PreparedStatement ps = null;
        
        try { 
            con = Conexion.getConnection(); 
            if (con != null) { 
                ps = con.prepareStatement("UPDATE disponibilidad_profesor SET turno_id=?, dia_semana=?, hora_inicio=?, hora_fin=?, estado='PENDIENTE' WHERE id=?"); 
                ps.setInt(1, d.getTurnoId()); 
                ps.setString(2, d.getDiaSemana()); 
                ps.setTime(3, d.getHoraInicio()); 
                ps.setTime(4, d.getHoraFin()); 
                ps.setInt(5, d.getId()); 
                exito = (ps.executeUpdate() > 0); 
            } 
        } catch (SQLException e) { } 
        finally { 
            try { 
                if(ps != null) ps.close(); 
                if(con != null) con.close(); 
            } catch(Exception e) {} 
        } 
        return exito;
    }

    public List<Disponibilidad> listarPendientes() {
        List<Disponibilidad> lista = new ArrayList<>();
        Connection con = null; 
        PreparedStatement ps = null; 
        ResultSet rs = null;

        String sql = "SELECT d.*, t.nombre as nombre_turno " +
                     "FROM disponibilidad_profesor d " +
                     "LEFT JOIN turno t ON d.turno_id = t.id " +
                     "WHERE d.estado = 'PENDIENTE' AND d.eliminado = 0 " +
                     "ORDER BY d.fecha_registro ASC";

        try {
            con = Conexion.getConnection();
            if (con != null) {
                ps = con.prepareStatement(sql);
                rs = ps.executeQuery();
                
                while (rs.next()) {
                    Disponibilidad d = new Disponibilidad();
                    d.setId(rs.getInt("id"));
                    d.setProfesorId(rs.getInt("profesor_id"));
                    d.setTurnoId(rs.getInt("turno_id"));
                    d.setTurnoNombre(rs.getString("nombre_turno"));
                    d.setDiaSemana(rs.getString("dia_semana"));
                    d.setHoraInicio(rs.getTime("hora_inicio"));
                    d.setHoraFin(rs.getTime("hora_fin"));
                    d.setEstado(rs.getString("estado"));
                    
                    String nombreProfe = obtenerNombreProfesor(con, d.getProfesorId());
                    d.setNombreProfesor(nombreProfe);
                    
                    lista.add(d);
                }
            }
        } catch (SQLException e) { 
            e.printStackTrace(); 
        } 
        finally { 
            try { 
                if(rs != null) rs.close(); 
                if(ps != null) ps.close(); 
                if(con != null) con.close(); 
            } catch(Exception e) {} 
        }
        return lista;
    }

    private String obtenerNombreProfesor(Connection con, int profesorId) {
        String nombre = "Docente (ID: " + profesorId + ")";
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            int personaId = -1;
            ps = con.prepareStatement("SELECT persona_id FROM profesor WHERE id = ?");
            ps.setInt(1, profesorId);
            rs = ps.executeQuery();
            if (rs.next()) {
                personaId = rs.getInt("persona_id");
            }
            rs.close();

            if (personaId != -1) {
                ps = con.prepareStatement("SELECT * FROM persona WHERE id = ?");
                ps.setInt(1, personaId);
                rs = ps.executeQuery();
                
                if (rs.next()) {
                    try {
                        nombre = rs.getString("nombres") + " " + rs.getString("apellidos");
                    } catch (Exception e1) {
                        try {
                            nombre = rs.getString("nombre") + " " + rs.getString("apellido");
                        } catch (Exception e2) {
                             nombre = "Persona encontrada (ID: " + personaId + ")";
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.out.println("Error buscando nombre en persona: " + e.getMessage());
        } finally {
            try { 
                if(rs != null) rs.close(); 
                if(ps != null) ps.close(); 
            } catch(Exception e) {}
        }
        return nombre;
    }

    public boolean evaluarDisponibilidad(int id, String nuevoEstado, String observacion) {
        boolean exito = false; 
        Connection con = null; 
        PreparedStatement ps = null;
        
        System.out.println("📝 DisponibilidadDAO.evaluarDisponibilidad()");
        System.out.println("   - ID: " + id);
        System.out.println("   - Estado: " + nuevoEstado);
        System.out.println("   - Observación: " + observacion);
        
        try { 
            con = Conexion.getConnection();
            
            if (con != null) {
                System.out.println("   - Conexión: ✅ Obtenida");
                
                String sql = "UPDATE disponibilidad_profesor SET estado = ?, observaciones = ? WHERE id = ?";
                ps = con.prepareStatement(sql);
                
                ps.setString(1, nuevoEstado); 
                ps.setString(2, observacion); 
                ps.setInt(3, id);
                
                System.out.println("   - SQL: " + sql);
                System.out.println("   - Parámetros: [" + nuevoEstado + ", " + observacion + ", " + id + "]");
                
                int filasAfectadas = ps.executeUpdate();
                exito = (filasAfectadas > 0);
                
                System.out.println("   - Filas afectadas: " + filasAfectadas);
                System.out.println("   - Resultado: " + (exito ? "✅ ÉXITO" : "❌ NO SE ACTUALIZÓ NADA"));
                
            } else {
                System.err.println("   - Conexión: ❌ NULL");
            }
            
        } catch (SQLException e) {
            System.err.println("   - ❌ SQLException: " + e.getMessage());
            e.printStackTrace();
        } finally { 
            try { 
                if(ps != null) ps.close(); 
                if(con != null) con.close(); 
            } catch(Exception e) {
                System.err.println("   - ❌ Error cerrando recursos: " + e.getMessage());
            } 
        } 
        
        return exito;
    }
}