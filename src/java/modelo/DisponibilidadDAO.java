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
    // MÉTODO 1: REGISTRAR (Con corrección para revivir ocultos)
    // ==========================================
    public boolean registrarDisponibilidad(Disponibilidad dispo) {
        boolean exito = false;
        Connection con = null;
        CallableStatement cs = null;
        PreparedStatement ps = null; // Necesario para el parche de reactivación
        ResultSet rs = null;
        
        // 1. Llamada al Stored Procedure
        String sql = "{CALL sp_gestion_disponibilidad_hu10(?, ?, ?, ?, ?)}";

        // 2. SQL de Corrección: "Revivir" registro si estaba eliminado
        String sqlFix = "UPDATE disponibilidad_profesor SET eliminado = 0, activo = 1 " +
                        "WHERE profesor_id = ? AND dia_semana = ? AND hora_inicio = ? AND hora_fin = ?";

        try {
            con = Conexion.getConnection(); 
            
            if (con != null) {
                // PASO A: Intentar registrar con el SP
                cs = con.prepareCall(sql);
                cs.setInt(1, dispo.getProfesorId());
                cs.setInt(2, dispo.getTurnoId());
                cs.setString(3, dispo.getDiaSemana());
                cs.setTime(4, dispo.getHoraInicio());
                cs.setTime(5, dispo.getHoraFin());
                
                rs = cs.executeQuery();
                
                if (rs.next()) {
                    exito = rs.getInt("exito") == 1;
                }
                
                // PASO B: Asegurar que sea visible (Parche de seguridad)
                // Si el registro ya existía pero estaba en la papelera, esto lo saca.
                ps = con.prepareStatement(sqlFix);
                ps.setInt(1, dispo.getProfesorId());
                ps.setString(2, dispo.getDiaSemana());
                ps.setTime(3, dispo.getHoraInicio());
                ps.setTime(4, dispo.getHoraFin());
                
                int reactivados = ps.executeUpdate();
                if (reactivados > 0) {
                    exito = true; 
                }
            }
            
        } catch (SQLException e) {
            System.out.println("Error al registrar disponibilidad: " + e.getMessage());
        } finally {
            try { if(rs != null) rs.close(); } catch(Exception e) {}
            try { if(cs != null) cs.close(); } catch(Exception e) {}
            try { if(ps != null) ps.close(); } catch(Exception e) {}
            try { if(con != null) con.close(); } catch(Exception e) {}
        }
        return exito;
    }

    // ==========================================
    // MÉTODO 2: LISTAR
    // ==========================================
    public List<Disponibilidad> listarPorProfesor(int profesorId) {
        List<Disponibilidad> lista = new ArrayList<>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        // Filtra los que NO están eliminados
        String sql = "SELECT d.*, t.nombre as nombre_turno " +
                     "FROM disponibilidad_profesor d " +
                     "INNER JOIN turno t ON d.turno_id = t.id " +
                     "WHERE d.profesor_id = ? AND d.activo = 1 AND d.eliminado = 0 " + 
                     "ORDER BY FIELD(d.dia_semana, 'LUNES', 'MARTES', 'MIERCOLES', 'JUEVES', 'VIERNES', 'SABADO'), d.hora_inicio";
        
        try {
            con = Conexion.getConnection();
            if (con != null) {
                ps = con.prepareStatement(sql);
                ps.setInt(1, profesorId);
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
                    d.setActivo(rs.getBoolean("activo"));
                    lista.add(d);
                }
            }
        } catch (SQLException e) {
            System.out.println("Error al listar: " + e.getMessage());
        } finally {
             try { if(rs != null) rs.close(); if(ps != null) ps.close(); if(con != null) con.close(); } catch(Exception e) {}
        }
        return lista;
    }

    // ==========================================
    // MÉTODO 3: ELIMINAR (Borrado lógico correcto)
    // ==========================================
    public boolean eliminarDisponibilidad(int id) {
        boolean exito = false;
        Connection con = null;
        PreparedStatement ps = null;
        
        // Apaga ambos interruptores
        String sql = "UPDATE disponibilidad_profesor SET eliminado = 1, activo = 0 WHERE id = ?";
        
        try {
            con = Conexion.getConnection();
            if (con != null) {
                ps = con.prepareStatement(sql);
                ps.setInt(1, id);
                int filas = ps.executeUpdate();
                exito = (filas > 0);
            }
        } catch (SQLException e) {
            System.out.println("Error al eliminar: " + e.getMessage());
        } finally {
            try { if(ps != null) ps.close(); if(con != null) con.close(); } catch(Exception e) {}
        }
        return exito;
    }

    // ==========================================
    // MÉTODO 4: OBTENER POR ID (Para editar)
    // ==========================================
    public Disponibilidad obtenerPorId(int id) {
        Disponibilidad d = null;
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sql = "SELECT * FROM disponibilidad_profesor WHERE id = ?";
        
        try {
            con = Conexion.getConnection();
            if (con != null) {
                ps = con.prepareStatement(sql);
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
                }
            }
        } catch (SQLException e) {
            System.out.println("Error al obtener por ID: " + e.getMessage());
        } finally {
             try { if(rs != null) rs.close(); if(ps != null) ps.close(); if(con != null) con.close(); } catch(Exception e) {}
        }
        return d;
    }

    // ==========================================
    // MÉTODO 5: ACTUALIZAR (Resetea estado a PENDIENTE)
    // ==========================================
    public boolean actualizarDisponibilidad(Disponibilidad d) {
        boolean exito = false;
        Connection con = null;
        PreparedStatement ps = null;
        
        // IMPORTANTE: Al editar, volvemos a poner estado='PENDIENTE'
        String sql = "UPDATE disponibilidad_profesor SET turno_id=?, dia_semana=?, hora_inicio=?, hora_fin=?, estado='PENDIENTE' WHERE id=?";
        
        try {
            con = Conexion.getConnection();
            if (con != null) {
                ps = con.prepareStatement(sql);
                ps.setInt(1, d.getTurnoId());
                ps.setString(2, d.getDiaSemana());
                ps.setTime(3, d.getHoraInicio());
                ps.setTime(4, d.getHoraFin());
                ps.setInt(5, d.getId());
                
                int filas = ps.executeUpdate();
                exito = (filas > 0);
            }
        } catch (SQLException e) {
            System.out.println("Error al actualizar: " + e.getMessage());
        } finally {
            try { if(ps != null) ps.close(); if(con != null) con.close(); } catch(Exception e) {}
        }
        return exito;
    }
}