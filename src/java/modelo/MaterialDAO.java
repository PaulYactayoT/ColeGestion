package modelo;

import conexion.Conexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MaterialDAO {
    
    /**
     * CONTAR MATERIALES POR CURSO
     */
    public int contarPorCurso(int cursoId) {
        String sql = "SELECT COUNT(*) as total FROM curso_material " +
                     "WHERE curso_id = ? AND activo = 1 AND eliminado = 0";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, cursoId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("total");
            }
            
        } catch (SQLException e) {
            System.err.println("Error al contar materiales por curso: " + e.getMessage());
            e.printStackTrace();
        }
        
        return 0;
    }
    
    /**
     * LISTAR MATERIALES POR CURSO
     */
    public List<Material> listarPorCurso(int cursoId) {
        List<Material> lista = new ArrayList<>();
        String sql = "SELECT m.*, " +
                     "CONCAT(p.nombres, ' ', p.apellidos) as profesor_nombre, " +
                     "c.nombre as curso_nombre " +
                     "FROM curso_material m " +
                     "JOIN profesor prof ON m.profesor_id = prof.id " +
                     "JOIN persona p ON prof.persona_id = p.id " +
                     "JOIN curso c ON m.curso_id = c.id " +
                     "WHERE m.curso_id = ? " +
                     "AND m.activo = 1 " +
                     "AND m.eliminado = 0 " +
                     "ORDER BY m.fecha_subida DESC";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, cursoId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Material m = new Material();
                m.setId(rs.getInt("id"));
                m.setCursoId(rs.getInt("curso_id"));
                m.setProfesorId(rs.getInt("profesor_id"));
                m.setNombreArchivo(rs.getString("nombre_archivo"));
                m.setRutaArchivo(rs.getString("ruta_archivo"));
                m.setTipoArchivo(rs.getString("tipo_archivo"));
                m.setTamanioArchivo(rs.getLong("tamanio_archivo"));
                m.setDescripcion(rs.getString("descripcion"));
                m.setFechaSubida(rs.getTimestamp("fecha_subida"));
                m.setProfesorNombre(rs.getString("profesor_nombre"));
                m.setCursoNombre(rs.getString("curso_nombre"));
                
                lista.add(m);
            }
            
        } catch (SQLException e) {
            System.err.println("Error al listar materiales por curso: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }
    
    /**
     * LISTAR MATERIALES POR CURSO Y PROFESOR
     */
    public List<Material> listarPorCursoYProfesor(int cursoId, int profesorId) {
        List<Material> lista = new ArrayList<>();
        String sql = "SELECT m.*, " +
                     "CONCAT(p.nombres, ' ', p.apellidos) as profesor_nombre, " +
                     "c.nombre as curso_nombre " +
                     "FROM curso_material m " +
                     "JOIN profesor prof ON m.profesor_id = prof.id " +
                     "JOIN persona p ON prof.persona_id = p.id " +
                     "JOIN curso c ON m.curso_id = c.id " +
                     "WHERE m.curso_id = ? " +
                     "AND m.profesor_id = ? " +
                     "AND m.activo = 1 " +
                     "AND m.eliminado = 0 " +
                     "ORDER BY m.fecha_subida DESC";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, cursoId);
            ps.setInt(2, profesorId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Material m = new Material();
                m.setId(rs.getInt("id"));
                m.setCursoId(rs.getInt("curso_id"));
                m.setProfesorId(rs.getInt("profesor_id"));
                m.setNombreArchivo(rs.getString("nombre_archivo"));
                m.setRutaArchivo(rs.getString("ruta_archivo"));
                m.setTipoArchivo(rs.getString("tipo_archivo"));
                m.setTamanioArchivo(rs.getLong("tamanio_archivo"));
                m.setDescripcion(rs.getString("descripcion"));
                m.setFechaSubida(rs.getTimestamp("fecha_subida"));
                m.setProfesorNombre(rs.getString("profesor_nombre"));
                m.setCursoNombre(rs.getString("curso_nombre"));
                
                lista.add(m);
            }
            
        } catch (SQLException e) {
            System.err.println("Error al listar materiales por curso y profesor: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }
    
    /**
     * OBTENER MATERIAL POR ID
     */
    public Material obtenerPorId(int id) {
        String sql = "SELECT m.*, " +
                     "CONCAT(p.nombres, ' ', p.apellidos) as profesor_nombre, " +
                     "c.nombre as curso_nombre " +
                     "FROM curso_material m " +
                     "JOIN profesor prof ON m.profesor_id = prof.id " +
                     "JOIN persona p ON prof.persona_id = p.id " +
                     "JOIN curso c ON m.curso_id = c.id " +
                     "WHERE m.id = ? " +
                     "AND m.activo = 1 " +
                     "AND m.eliminado = 0";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                Material m = new Material();
                m.setId(rs.getInt("id"));
                m.setCursoId(rs.getInt("curso_id"));
                m.setProfesorId(rs.getInt("profesor_id"));
                m.setNombreArchivo(rs.getString("nombre_archivo"));
                m.setRutaArchivo(rs.getString("ruta_archivo"));
                m.setTipoArchivo(rs.getString("tipo_archivo"));
                m.setTamanioArchivo(rs.getLong("tamanio_archivo"));
                m.setDescripcion(rs.getString("descripcion"));
                m.setFechaSubida(rs.getTimestamp("fecha_subida"));
                m.setProfesorNombre(rs.getString("profesor_nombre"));
                m.setCursoNombre(rs.getString("curso_nombre"));
                
                return m;
            }
            
        } catch (SQLException e) {
            System.err.println("Error al obtener material por ID: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * AGREGAR NUEVO MATERIAL
     */
    public boolean agregar(Material material) {
        String sql = "INSERT INTO curso_material " +
                     "(curso_id, profesor_id, nombre_archivo, ruta_archivo, " +
                     "tipo_archivo, tamanio_archivo, descripcion) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, material.getCursoId());
            ps.setInt(2, material.getProfesorId());
            ps.setString(3, material.getNombreArchivo());
            ps.setString(4, material.getRutaArchivo());
            ps.setString(5, material.getTipoArchivo());
            ps.setLong(6, material.getTamanioArchivo());
            ps.setString(7, material.getDescripcion());
            
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("Error al agregar material: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * ELIMINAR MATERIAL (lógicamente)
     */
    public boolean eliminar(int id) {
        String sql = "UPDATE curso_material SET activo = 0, eliminado = 1 WHERE id = ?";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("Error al eliminar material: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * ACTUALIZAR MATERIAL
     */
    public boolean actualizar(Material material) {
        String sql = "UPDATE curso_material SET " +
                     "nombre_archivo = ?, " +
                     "tipo_archivo = ?, " +
                     "tamanio_archivo = ?, " +
                     "descripcion = ? " +
                     "WHERE id = ?";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, material.getNombreArchivo());
            ps.setString(2, material.getTipoArchivo());
            ps.setLong(3, material.getTamanioArchivo());
            ps.setString(4, material.getDescripcion());
            ps.setInt(5, material.getId());
            
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("Error al actualizar material: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * LISTAR MATERIALES POR PROFESOR
     */
    public List<Material> listarPorProfesor(int profesorId) {
        List<Material> lista = new ArrayList<>();
        String sql = "SELECT m.*, " +
                     "CONCAT(p.nombres, ' ', p.apellidos) as profesor_nombre, " +
                     "c.nombre as curso_nombre " +
                     "FROM curso_material m " +
                     "JOIN profesor prof ON m.profesor_id = prof.id " +
                     "JOIN persona p ON prof.persona_id = p.id " +
                     "JOIN curso c ON m.curso_id = c.id " +
                     "WHERE m.profesor_id = ? " +
                     "AND m.activo = 1 " +
                     "AND m.eliminado = 0 " +
                     "ORDER BY m.fecha_subida DESC";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, profesorId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Material m = new Material();
                m.setId(rs.getInt("id"));
                m.setCursoId(rs.getInt("curso_id"));
                m.setProfesorId(rs.getInt("profesor_id"));
                m.setNombreArchivo(rs.getString("nombre_archivo"));
                m.setRutaArchivo(rs.getString("ruta_archivo"));
                m.setTipoArchivo(rs.getString("tipo_archivo"));
                m.setTamanioArchivo(rs.getLong("tamanio_archivo"));
                m.setDescripcion(rs.getString("descripcion"));
                m.setFechaSubida(rs.getTimestamp("fecha_subida"));
                m.setProfesorNombre(rs.getString("profesor_nombre"));
                m.setCursoNombre(rs.getString("curso_nombre"));
                
                lista.add(m);
            }
            
        } catch (SQLException e) {
            System.err.println("Error al listar materiales por profesor: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }
}