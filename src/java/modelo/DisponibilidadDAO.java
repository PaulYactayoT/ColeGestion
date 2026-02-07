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

    // ==========================================
    // PARTE 1: FUNCIONALIDAD DOCENTE (HU-10) - ¡INTACTO!
    // ==========================================

    public boolean registrarDisponibilidad(Disponibilidad dispo) {
        boolean exito = false;
        Connection con = null;
        CallableStatement cs = null;
        PreparedStatement ps = null; 
        ResultSet rs = null;
        String sql = "{CALL sp_gestion_disponibilidad_hu10(?, ?, ?, ?, ?)}";
        String sqlFix = "UPDATE disponibilidad_profesor SET eliminado = 0, activo = 1 WHERE profesor_id = ? AND dia_semana = ? AND hora_inicio = ? AND hora_fin = ?";

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
                if (rs.next()) exito = rs.getInt("exito") == 1;
                
                ps = con.prepareStatement(sqlFix);
                ps.setInt(1, dispo.getProfesorId());
                ps.setString(2, dispo.getDiaSemana());
                ps.setTime(3, dispo.getHoraInicio());
                ps.setTime(4, dispo.getHoraFin());
                if (ps.executeUpdate() > 0) exito = true; 
            }
        } catch (SQLException e) { System.out.println("Error registro: " + e.getMessage()); } 
        finally { try { if(rs != null) rs.close(); if(cs != null) cs.close(); if(ps != null) ps.close(); if(con != null) con.close(); } catch(Exception e) {} }
        return exito;
    }

    public List<Disponibilidad> listarPorProfesor(int profesorId) {
        List<Disponibilidad> lista = new ArrayList<>();
        Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
        String sql = "SELECT d.*, t.nombre as nombre_turno FROM disponibilidad_profesor d INNER JOIN turno t ON d.turno_id = t.id WHERE d.profesor_id = ? AND d.activo = 1 AND d.eliminado = 0 ORDER BY FIELD(d.dia_semana, 'LUNES', 'MARTES', 'MIERCOLES', 'JUEVES', 'VIERNES', 'SABADO'), d.hora_inicio";
        try {
            con = Conexion.getConnection();
            if (con != null) {
                ps = con.prepareStatement(sql); ps.setInt(1, profesorId); rs = ps.executeQuery();
                while (rs.next()) {
                    Disponibilidad d = new Disponibilidad();
                    d.setId(rs.getInt("id")); d.setProfesorId(rs.getInt("profesor_id")); d.setTurnoId(rs.getInt("turno_id"));
                    d.setTurnoNombre(rs.getString("nombre_turno")); d.setDiaSemana(rs.getString("dia_semana"));
                    d.setHoraInicio(rs.getTime("hora_inicio")); d.setHoraFin(rs.getTime("hora_fin"));
                    d.setEstado(rs.getString("estado")); d.setActivo(rs.getBoolean("activo")); d.setObservaciones(rs.getString("observaciones"));
                    lista.add(d);
                }
            }
        } catch (SQLException e) { System.out.println("Error listar: " + e.getMessage()); }
        finally { try { if(rs != null) rs.close(); if(ps != null) ps.close(); if(con != null) con.close(); } catch(Exception e) {} }
        return lista;
    }

    public boolean eliminarDisponibilidad(int id) {
        boolean exito = false; Connection con = null; PreparedStatement ps = null;
        try { con = Conexion.getConnection(); if (con != null) { ps = con.prepareStatement("UPDATE disponibilidad_profesor SET eliminado = 1, activo = 0 WHERE id = ?"); ps.setInt(1, id); exito = (ps.executeUpdate() > 0); } } catch (SQLException e) { } finally { try { if(ps != null) ps.close(); if(con != null) con.close(); } catch(Exception e) {} } return exito;
    }

    public Disponibilidad obtenerPorId(int id) {
        Disponibilidad d = null; Connection con = null; PreparedStatement ps = null; ResultSet rs = null;
        try { con = Conexion.getConnection(); if (con != null) { ps = con.prepareStatement("SELECT * FROM disponibilidad_profesor WHERE id = ?"); ps.setInt(1, id); rs = ps.executeQuery(); if (rs.next()) { d = new Disponibilidad(); d.setId(rs.getInt("id")); d.setProfesorId(rs.getInt("profesor_id")); d.setTurnoId(rs.getInt("turno_id")); d.setDiaSemana(rs.getString("dia_semana")); d.setHoraInicio(rs.getTime("hora_inicio")); d.setHoraFin(rs.getTime("hora_fin")); d.setEstado(rs.getString("estado")); d.setObservaciones(rs.getString("observaciones")); } } } catch (SQLException e) { } finally { try { if(rs != null) rs.close(); if(ps != null) ps.close(); if(con != null) con.close(); } catch(Exception e) {} } return d;
    }

    public boolean actualizarDisponibilidad(Disponibilidad d) {
        boolean exito = false; Connection con = null; PreparedStatement ps = null;
        try { con = Conexion.getConnection(); if (con != null) { ps = con.prepareStatement("UPDATE disponibilidad_profesor SET turno_id=?, dia_semana=?, hora_inicio=?, hora_fin=?, estado='PENDIENTE' WHERE id=?"); ps.setInt(1, d.getTurnoId()); ps.setString(2, d.getDiaSemana()); ps.setTime(3, d.getHoraInicio()); ps.setTime(4, d.getHoraFin()); ps.setInt(5, d.getId()); exito = (ps.executeUpdate() > 0); } } catch (SQLException e) { } finally { try { if(ps != null) ps.close(); if(con != null) con.close(); } catch(Exception e) {} } return exito;
    }

    // =========================================================
    // PARTE 2: FUNCIONALIDAD ADMIN (HU-11)
    // =========================================================

    public List<Disponibilidad> listarPendientes() {
        List<Disponibilidad> lista = new ArrayList<>();
        Connection con = null; PreparedStatement ps = null; ResultSet rs = null;

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
                    
                    // BUSQUEDA DEL NOMBRE USANDO LA RELACIÓN CON 'PERSONA'
                    String nombreProfe = obtenerNombreProfesor(con, d.getProfesorId());
                    d.setNombreProfesor(nombreProfe);
                    
                    lista.add(d);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); } 
        finally { try { if(rs != null) rs.close(); if(ps != null) ps.close(); if(con != null) con.close(); } catch(Exception e) {} }
        return lista;
    }

    // --- MÉTODO ACTUALIZADO: BUSCA EN TABLA 'PERSONA' ---
    private String obtenerNombreProfesor(Connection con, int profesorId) {
        String nombre = "Docente (ID: " + profesorId + ")";
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            // PASO 1: Obtener el persona_id de la tabla PROFESOR
            int personaId = -1;
            ps = con.prepareStatement("SELECT persona_id FROM profesor WHERE id = ?");
            ps.setInt(1, profesorId);
            rs = ps.executeQuery();
            if (rs.next()) {
                personaId = rs.getInt("persona_id");
            }
            rs.close(); // Cerramos para reusar

            // PASO 2: Si tenemos el persona_id, buscamos el nombre en la tabla PERSONA
            if (personaId != -1) {
                ps = con.prepareStatement("SELECT * FROM persona WHERE id = ?");
                ps.setInt(1, personaId);
                rs = ps.executeQuery();
                
                if (rs.next()) {
                    // INTENTO 1: Buscamos columnas 'nombres' y 'apellidos' (Plural)
                    try {
                        nombre = rs.getString("nombres") + " " + rs.getString("apellidos");
                    } catch (Exception e1) {
                        // INTENTO 2: Buscamos columnas 'nombre' y 'apellido' (Singular)
                        try {
                            nombre = rs.getString("nombre") + " " + rs.getString("apellido");
                        } catch (Exception e2) {
                             // Si falla, al menos sabemos que la tabla existe
                             nombre = "Persona encontrada (ID: " + personaId + ")";
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.out.println("Error buscando nombre en persona: " + e.getMessage());
        } finally {
            try { if(rs != null) rs.close(); if(ps != null) ps.close(); } catch(Exception e) {}
        }
        return nombre;
    }

    public boolean evaluarDisponibilidad(int id, String nuevoEstado, String observacion) {
        boolean exito = false; Connection con = null; PreparedStatement ps = null;
        try { con = Conexion.getConnection(); if (con != null) { ps = con.prepareStatement("UPDATE disponibilidad_profesor SET estado = ?, observaciones = ? WHERE id = ?"); ps.setString(1, nuevoEstado); ps.setString(2, observacion); ps.setInt(3, id); exito = (ps.executeUpdate() > 0); } } catch (SQLException e) { } finally { try { if(ps != null) ps.close(); if(con != null) con.close(); } catch(Exception e) {} } return exito;
    }
}