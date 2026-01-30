package modelo;

import conexion.Conexion;
import java.sql.*;
import java.util.*;

public class PadreDAO {
    
    public Padre obtenerPorUsername(String username) {
        Padre padre = null;
        String sql = """
            SELECT 
                p.id as persona_id,
                p.nombres,
                p.apellidos,
                p.correo,
                p.dni,
                p.telefono,
                u.rol,
                u.username,
                rf.alumno_id,
                rf.parentesco,
                rf.es_contacto_principal,
                a.codigo_alumno,
                a.estado as alumno_estado,
                CONCAT(pa.nombres, ' ', pa.apellidos) as alumno_nombre_completo,
                g.nombre as grado_nombre,
                g.nivel as grado_nivel
            FROM usuario u
            JOIN persona p ON u.persona_id = p.id
            LEFT JOIN relacion_familiar rf ON p.id = rf.persona_id AND rf.eliminado = 0
            LEFT JOIN alumno a ON rf.alumno_id = a.id AND a.eliminado = 0
            LEFT JOIN persona pa ON a.persona_id = pa.id
            LEFT JOIN grado g ON a.grado_id = g.id
            WHERE u.username = ?
            AND u.eliminado = 0
            AND u.activo = 1
            AND p.eliminado = 0
            AND p.activo = 1
            LIMIT 1
            """;
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, username);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    padre = new Padre();
                    padre.setId(rs.getInt("persona_id"));
                    padre.setNombres(rs.getString("nombres"));
                    padre.setApellidos(rs.getString("apellidos"));
                    padre.setCorreo(rs.getString("correo"));
                    padre.setDni(rs.getString("dni"));
                    padre.setTelefono(rs.getString("telefono"));
                    padre.setRol(rs.getString("rol"));
                    padre.setUsername(rs.getString("username"));
                    
                    // Información del alumno asociado
                    padre.setAlumnoId(rs.getInt("alumno_id"));
                    padre.setAlumnoCodigo(rs.getString("codigo_alumno"));
                    padre.setAlumnoNombre(rs.getString("alumno_nombre_completo"));
                    padre.setGradoNombre(rs.getString("grado_nombre"));
                    
                    // Información de la relación familiar
                    padre.setParentesco(rs.getString("parentesco"));
                    padre.setEsContactoPrincipal(rs.getBoolean("es_contacto_principal"));
                }
            }
            
        } catch (Exception e) {
            System.err.println("Error al obtener padre por username: " + e.getMessage());
            e.printStackTrace();
        }
        
        return padre;
    }
    
    // Método para obtener múltiples hijos (si un padre tiene más de un hijo)
    public List<Map<String, Object>> obtenerHijosPorPadre(int personaId) {
        List<Map<String, Object>> hijos = new ArrayList<>();
        String sql = """
            SELECT 
                a.id as alumno_id,
                a.codigo_alumno,
                CONCAT(pa.nombres, ' ', pa.apellidos) as alumno_nombre,
                g.nombre as grado_nombre,
                g.nivel as grado_nivel,
                rf.parentesco,
                rf.es_contacto_principal
            FROM relacion_familiar rf
            JOIN alumno a ON rf.alumno_id = a.id
            JOIN persona pa ON a.persona_id = pa.id
            JOIN grado g ON a.grado_id = g.id
            WHERE rf.persona_id = ?
            AND rf.eliminado = 0
            AND rf.activo = 1
            AND a.eliminado = 0
            AND a.activo = 1
            ORDER BY a.codigo_alumno
            """;
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, personaId);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> hijo = new HashMap<>();
                    hijo.put("alumno_id", rs.getInt("alumno_id"));
                    hijo.put("codigo_alumno", rs.getString("codigo_alumno"));
                    hijo.put("alumno_nombre", rs.getString("alumno_nombre"));
                    hijo.put("grado_nombre", rs.getString("grado_nombre"));
                    hijo.put("grado_nivel", rs.getString("grado_nivel"));
                    hijo.put("parentesco", rs.getString("parentesco"));
                    hijo.put("es_contacto_principal", rs.getBoolean("es_contacto_principal"));
                    
                    hijos.add(hijo);
                }
            }
            
        } catch (Exception e) {
            System.err.println("Error al obtener hijos del padre: " + e.getMessage());
            e.printStackTrace();
        }
        
        return hijos;
    }
    
    // Método para verificar si un usuario es padre
    public boolean esPadre(String username) {
        String sql = """
            SELECT COUNT(*) as count
            FROM usuario u
            JOIN persona p ON u.persona_id = p.id
            WHERE u.username = ?
            AND p.tipo = 'PADRE'
            AND u.eliminado = 0
            AND u.activo = 1
            AND p.eliminado = 0
            """;
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, username);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count") > 0;
                }
            }
            
        } catch (Exception e) {
            System.err.println("Error al verificar si es padre: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
}