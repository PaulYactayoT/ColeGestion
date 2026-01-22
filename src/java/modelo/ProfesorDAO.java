package modelo;

import conexion.Conexion;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ProfesorDAO {

    /**
     * Obtener profesor por username - METODO PRINCIPAL PARA LOGIN
     */
    public Profesor obtenerPorUsername(String username) {
        Profesor profesor = null;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = Conexion.getConnection();
            
            // Consulta directa - mas confiable que el stored procedure
            String sql = "SELECT " +
                        "    prof.id, " +
                        "    p.nombres, " +
                        "    p.apellidos, " +
                        "    p.correo, " +
                        "    prof.especialidad, " +
                        "    prof.codigo_profesor, " +
                        "    prof.fecha_contratacion, " +
                        "    prof.estado " +
                        "FROM usuario u " +
                        "INNER JOIN persona p ON u.persona_id = p.id " +
                        "INNER JOIN profesor prof ON p.id = prof.persona_id " +
                        "WHERE u.username = ? " +
                        "  AND u.rol = 'docente' " +
                        "  AND u.activo = 1";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, username);
            
            System.out.println("═══════════════════════════════════════");
            System.out.println("🔍 Buscando profesor: " + username);
            
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                profesor = new Profesor();
                
                int id = rs.getInt("id");
                String nombres = rs.getString("nombres");
                String apellidos = rs.getString("apellidos");
                String correo = rs.getString("correo");
                String especialidad = rs.getString("especialidad");
                String codigoProfesor = rs.getString("codigo_profesor");
                String estado = rs.getString("estado");
                
                profesor.setId(id);
                profesor.setNombres(nombres);
                profesor.setApellidos(apellidos);
                profesor.setCorreo(correo);
                profesor.setEspecialidad(especialidad);
                profesor.setCodigoProfesor(codigoProfesor);
                profesor.setEstado(estado);
                
                // Manejar fecha que puede ser NULL
                try {
                    Date fechaContratacion = rs.getDate("fecha_contratacion");
                    if (fechaContratacion != null && !rs.wasNull()) {
                        profesor.setFechaContratacion(fechaContratacion);
                    }
                } catch (SQLException e) {
                    System.out.println("⚠️ Fecha contratacion NULL o invalida - continuando...");
                }
                
                System.out.println("✅ PROFESOR ENCONTRADO:");
                System.out.println("   ID: " + id);
                System.out.println("   Nombre: " + nombres + " " + apellidos);
                System.out.println("   Email: " + correo);
                System.out.println("   Codigo: " + codigoProfesor);
                System.out.println("   Especialidad: " + especialidad);
                System.out.println("   Estado: " + estado);
                System.out.println("═══════════════════════════════════════");
                
            } else {
                System.out.println("❌ NO SE ENCONTRO PROFESOR");
                System.out.println("═══════════════════════════════════════");
                
                // Diagnostico detallado
                realizarDiagnostico(conn, username);
            }
            
        } catch (SQLException e) {
            System.err.println("═══════════════════════════════════════");
            System.err.println("❌ ERROR SQL en obtenerPorUsername");
            System.err.println("   Username: " + username);
            System.err.println("   SQLState: " + e.getSQLState());
            System.err.println("   Error Code: " + e.getErrorCode());
            System.err.println("   Mensaje: " + e.getMessage());
            System.err.println("═══════════════════════════════════════");
            e.printStackTrace();
        } finally {
            cerrarRecursos(rs, pstmt, conn);
        }
        
        return profesor;
    }

    /**
     * Diagnostico cuando no se encuentra el profesor
     */
    private void realizarDiagnostico(Connection conn, String username) {
        PreparedStatement pstmtDiag = null;
        ResultSet rsDiag = null;
        
        try {
            String sqlDiag = "SELECT " +
                            "    u.id as usuario_id, " +
                            "    u.username, " +
                            "    u.rol, " +
                            "    u.activo, " +
                            "    u.persona_id, " +
                            "    p.id as persona_existe, " +
                            "    p.nombres, " +
                            "    p.tipo, " +
                            "    prof.id as profesor_id " +
                            "FROM usuario u " +
                            "LEFT JOIN persona p ON u.persona_id = p.id " +
                            "LEFT JOIN profesor prof ON p.id = prof.persona_id " +
                            "WHERE u.username = ?";
            
            pstmtDiag = conn.prepareStatement(sqlDiag);
            pstmtDiag.setString(1, username);
            rsDiag = pstmtDiag.executeQuery();
            
            if (rsDiag.next()) {
                System.out.println("📊 DIAGNOSTICO DETALLADO:");
                System.out.println("   Usuario ID: " + rsDiag.getInt("usuario_id"));
                System.out.println("   Username: " + rsDiag.getString("username"));
                System.out.println("   Rol: " + rsDiag.getString("rol"));
                System.out.println("   Activo: " + rsDiag.getBoolean("activo"));
                System.out.println("   Persona ID: " + rsDiag.getInt("persona_id"));
                
                Object personaExiste = rsDiag.getObject("persona_existe");
                Object profesorId = rsDiag.getObject("profesor_id");
                
                System.out.println("   Persona existe: " + (personaExiste != null ? "SI" : "NO"));
                if (personaExiste != null) {
                    System.out.println("   Nombres: " + rsDiag.getString("nombres"));
                    System.out.println("   Tipo: " + rsDiag.getString("tipo"));
                }
                System.out.println("   Profesor existe: " + (profesorId != null ? "SI (ID: " + profesorId + ")" : "NO"));
                
                if (profesorId == null) {
                    System.out.println("");
                    System.out.println("PROBLEMA DETECTADO:");
                    System.out.println("   El usuario existe pero NO tiene registro en tabla 'profesor'");
                }
            } else {
                System.out.println("Usuario '" + username + "' NO EXISTE en la base de datos");
            }
            
        } catch (SQLException e) {
            System.err.println("Error en diagnostico: " + e.getMessage());
        } finally {
            try {
                if (rsDiag != null) rsDiag.close();
                if (pstmtDiag != null) pstmtDiag.close();
            } catch (SQLException e) {
                System.err.println("Error cerrando recursos de diagnostico: " + e.getMessage());
            }
        }
    }

    /**
     * Cerrar recursos de base de datos
     */
    private void cerrarRecursos(ResultSet rs, PreparedStatement pstmt, Connection conn) {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            System.err.println("Error cerrando recursos: " + e.getMessage());
        }
    }

    /**
     * Obtener profesor por ID
     */
    public Profesor obtenerPorId(int id) {
        Profesor profesor = null;
        Connection conn = null;
        CallableStatement cstmt = null;
        ResultSet rs = null;
        
        try {
            conn = Conexion.getConnection();
            cstmt = conn.prepareCall("{CALL obtener_profesor_por_id(?)}");
            cstmt.setInt(1, id);
            rs = cstmt.executeQuery();
            
            if (rs.next()) {
                profesor = new Profesor();
                profesor.setId(rs.getInt("id"));
                profesor.setNombres(rs.getString("nombres"));
                profesor.setApellidos(rs.getString("apellidos"));
                profesor.setCorreo(rs.getString("correo"));
                profesor.setEspecialidad(rs.getString("especialidad"));
                profesor.setCodigoProfesor(rs.getString("codigo_profesor"));
                
                Date fechaContratacion = rs.getDate("fecha_contratacion");
                if (fechaContratacion != null) {
                    profesor.setFechaContratacion(fechaContratacion);
                }
                
                profesor.setEstado(rs.getString("estado"));
            }
            
        } catch (SQLException e) {
            System.err.println("Error en obtenerPorId: " + e.getMessage());
            e.printStackTrace();
        } finally {
            cerrarRecursos(rs, cstmt, conn);
        }
        
        return profesor;
    }

    /**
     * Listar todos los profesores
     */
    public List<Profesor> listar() {
        List<Profesor> profesores = new ArrayList<>();
        Connection conn = null;
        CallableStatement cstmt = null;
        ResultSet rs = null;
        
        try {
            conn = Conexion.getConnection();
            cstmt = conn.prepareCall("{CALL obtener_profesores()}");
            rs = cstmt.executeQuery();
            
            while (rs.next()) {
                Profesor profesor = new Profesor();
                profesor.setId(rs.getInt("id"));
                profesor.setNombres(rs.getString("nombres"));
                profesor.setApellidos(rs.getString("apellidos"));
                profesor.setCorreo(rs.getString("correo"));
                profesor.setEspecialidad(rs.getString("especialidad"));
                profesor.setCodigoProfesor(rs.getString("codigo_profesor"));
                
                Date fechaContratacion = rs.getDate("fecha_contratacion");
                if (fechaContratacion != null) {
                    profesor.setFechaContratacion(fechaContratacion);
                }
                
                profesor.setEstado(rs.getString("estado"));
                
                profesores.add(profesor);
            }
            
        } catch (SQLException e) {
            System.err.println("Error en listar: " + e.getMessage());
            e.printStackTrace();
        } finally {
            cerrarRecursos(rs, cstmt, conn);
        }
        
        return profesores;
    }

    /**
     * Crear nuevo profesor
     */
    public boolean crear(Profesor profesor) {
        Connection conn = null;
        CallableStatement cstmt = null;
        
        try {
            conn = Conexion.getConnection();
            cstmt = conn.prepareCall("{CALL crear_profesor(?, ?, ?, ?)}");
            cstmt.setString(1, profesor.getNombres());
            cstmt.setString(2, profesor.getApellidos());
            cstmt.setString(3, profesor.getCorreo());
            cstmt.setString(4, profesor.getEspecialidad());
            
            cstmt.execute();
            return true;
            
        } catch (SQLException e) {
            System.err.println("Error en crear: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (cstmt != null) cstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * Actualizar profesor
     */
    public boolean actualizar(Profesor profesor) {
        Connection conn = null;
        CallableStatement cstmt = null;
        
        try {
            conn = Conexion.getConnection();
            cstmt = conn.prepareCall("{CALL actualizar_profesor(?, ?, ?, ?, ?)}");
            cstmt.setInt(1, profesor.getId());
            cstmt.setString(2, profesor.getNombres());
            cstmt.setString(3, profesor.getApellidos());
            cstmt.setString(4, profesor.getCorreo());
            cstmt.setString(5, profesor.getEspecialidad());
            
            cstmt.execute();
            return true;
            
        } catch (SQLException e) {
            System.err.println("Error en actualizar: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (cstmt != null) cstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * Eliminar profesor
     */
    public boolean eliminar(int id) {
        Connection conn = null;
        CallableStatement cstmt = null;
        
        try {
            conn = Conexion.getConnection();
            cstmt = conn.prepareCall("{CALL eliminar_profesor(?)}");
            cstmt.setInt(1, id);
            
            cstmt.execute();
            return true;
            
        } catch (SQLException e) {
            System.err.println("Error en eliminar: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (cstmt != null) cstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}