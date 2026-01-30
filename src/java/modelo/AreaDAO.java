
package modelo;

import conexion.Conexion;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.*;

public class AreaDAO {
    
    /**
     * OBTENER TODAS LAS ÁREAS ACTIVAS DEL SISTEMA
     * 
     * @return Lista de áreas con estado activo y no eliminadas
     */
    public List<Area> obtenerAreasActivas() {
        List<Area> lista = new ArrayList<>();
        String sql = "SELECT id, nombre, descripcion, nivel, " +
                     "fecha_registro, activo, eliminado " +
                     "FROM area " +
                     "WHERE activo = 1 AND eliminado = 0 " +
                     "ORDER BY nombre";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Area area = mapearResultSet(rs);
                lista.add(area);
            }
            
        } catch (SQLException e) {
            System.err.println("Error al obtener áreas activas: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }
    
    /**
     * OBTENER TODAS LAS ÁREAS (INCLUYENDO INACTIVAS)
     * 
     * @return Lista de todas las áreas no eliminadas
     */
    public List<Area> obtenerTodasAreas() {
        List<Area> lista = new ArrayList<>();
        String sql = "SELECT id, nombre, descripcion, nivel, " +
                     "fecha_registro, activo, eliminado " +
                     "FROM area " +
                     "WHERE eliminado = 0 " +
                     "ORDER BY nombre";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Area area = mapearResultSet(rs);
                lista.add(area);
            }
            
        } catch (SQLException e) {
            System.err.println("Error al obtener todas las áreas: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }
    
    /**
     * OBTENER ÁREAS POR NIVEL EDUCATIVO
     * 
     * @param nivel Nivel educativo (INICIAL, PRIMARIA, SECUNDARIA, TODOS)
     * @return Lista de áreas del nivel especificado
     */
    public List<Area> obtenerAreasPorNivel(String nivel) {
        List<Area> lista = new ArrayList<>();
        String sql = "SELECT id, nombre, descripcion, nivel, " +
                     "fecha_registro, activo, eliminado " +
                     "FROM area " +
                     "WHERE (nivel = ? OR nivel = 'TODOS') " +
                     "AND activo = 1 AND eliminado = 0 " +
                     "ORDER BY nombre";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, nivel);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Area area = mapearResultSet(rs);
                    lista.add(area);
                }
            }
            
        } catch (SQLException e) {
            System.err.println("Error al obtener áreas por nivel: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }
    
    /**
     * OBTENER ÁREA POR ID
     * 
     * @param id ID del área
     * @return Objeto Area o null si no existe
     */
    public Area obtenerAreaPorId(int id) {
        String sql = "SELECT id, nombre, descripcion, nivel, " +
                     "fecha_registro, activo, eliminado " +
                     "FROM area " +
                     "WHERE id = ? AND eliminado = 0";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapearResultSet(rs);
                }
            }
            
        } catch (SQLException e) {
            System.err.println("Error al obtener área por ID: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * BUSCAR ÁREA POR NOMBRE
     * 
     * @param nombre Nombre del área
     * @return Objeto Area o null si no existe
     */
    public Area buscarPorNombre(String nombre) {
        String sql = "SELECT id, nombre, descripcion, nivel, " +
                     "fecha_registro, activo, eliminado " +
                     "FROM area " +
                     "WHERE nombre = ? AND eliminado = 0";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, nombre);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapearResultSet(rs);
                }
            }
            
        } catch (SQLException e) {
            System.err.println("Error al buscar área por nombre: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * CREAR NUEVA ÁREA
     * 
     * @param area Objeto Area a insertar
     * @return true si se insertó correctamente
     */
    public boolean crear(Area area) {
        String sql = "INSERT INTO area (nombre, descripcion, nivel, activo) " +
                     "VALUES (?, ?, ?, ?)";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setString(1, area.getNombre());
            ps.setString(2, area.getDescripcion());
            ps.setString(3, area.getNivel() != null ? area.getNivel() : "TODOS");
            ps.setBoolean(4, area.isActivo());
            
            int filasAfectadas = ps.executeUpdate();
            
            // Obtener el ID generado
            if (filasAfectadas > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        area.setId(rs.getInt(1));
                    }
                }
                return true;
            }
            
        } catch (SQLException e) {
            System.err.println("Error al crear área: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * ACTUALIZAR ÁREA EXISTENTE
     * 
     * @param area Objeto Area con datos actualizados
     * @return true si se actualizó correctamente
     */
    public boolean actualizar(Area area) {
        String sql = "UPDATE area SET nombre = ?, descripcion = ?, nivel = ?, " +
                     "activo = ? " +
                     "WHERE id = ? AND eliminado = 0";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, area.getNombre());
            ps.setString(2, area.getDescripcion());
            ps.setString(3, area.getNivel());
            ps.setBoolean(4, area.isActivo());
            ps.setInt(5, area.getId());
            
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("Error al actualizar área: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * ELIMINAR ÁREA (ELIMINACIÓN LÓGICA)
     * 
     * @param id ID del área a eliminar
     * @return true si se eliminó correctamente
     */
    public boolean eliminarLogico(int id) {
        String sql = "UPDATE area SET eliminado = 1, activo = 0 " +
                     "WHERE id = ? AND eliminado = 0";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("Error al eliminar área: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * ACTIVAR/DESACTIVAR ÁREA
     * 
     * @param id ID del área
     * @param activo Estado deseado
     * @return true si se actualizó correctamente
     */
    public boolean cambiarEstado(int id, boolean activo) {
        String sql = "UPDATE area SET activo = ? WHERE id = ? AND eliminado = 0";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setBoolean(1, activo);
            ps.setInt(2, id);
            
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("Error al cambiar estado del área: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * VERIFICAR SI UN ÁREA TIENE PROFESORES ASOCIADOS
     * 
     * @param areaId ID del área
     * @return true si tiene profesores asociados
     */
    public boolean tieneProfesoresAsociados(int areaId) {
        String sql = "SELECT COUNT(*) as total FROM profesor " +
                     "WHERE area_id = ? AND eliminado = 0";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, areaId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total") > 0;
                }
            }
            
        } catch (SQLException e) {
            System.err.println("Error al verificar profesores asociados: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * VERIFICAR SI UN ÁREA TIENE CURSOS ASOCIADOS
     * 
     * @param areaId ID del área
     * @return true si tiene cursos asociados
     */
    public boolean tieneCursosAsociados(int areaId) {
        String sql = "SELECT COUNT(*) as total FROM curso " +
                     "WHERE area_id = ? AND eliminado = 0";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, areaId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total") > 0;
                }
            }
            
        } catch (SQLException e) {
            System.err.println("Error al verificar cursos asociados: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * OBTENER ESTADÍSTICAS DEL ÁREA
     * 
     * @param areaId ID del área
     * @return Map con estadísticas (total_profesores, total_cursos, etc.)
     */
    public Map<String, Integer> obtenerEstadisticas(int areaId) {
        Map<String, Integer> stats = new HashMap<>();
        String sql = "SELECT " +
                     "(SELECT COUNT(*) FROM profesor WHERE area_id = ? AND eliminado = 0) as total_profesores, " +
                     "(SELECT COUNT(*) FROM curso WHERE area_id = ? AND eliminado = 0) as total_cursos";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, areaId);
            ps.setInt(2, areaId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stats.put("total_profesores", rs.getInt("total_profesores"));
                    stats.put("total_cursos", rs.getInt("total_cursos"));
                }
            }
            
        } catch (SQLException e) {
            System.err.println("Error al obtener estadísticas del área: " + e.getMessage());
            e.printStackTrace();
        }
        
        return stats;
    }
    
    /**
     * MAPEAR RESULTSET A OBJETO AREA
     * 
     * @param rs ResultSet con datos del área
     * @return Objeto Area mapeado
     * @throws SQLException
     */
    private Area mapearResultSet(ResultSet rs) throws SQLException {
        Area area = new Area();
        area.setId(rs.getInt("id"));
        area.setNombre(rs.getString("nombre"));
        area.setDescripcion(rs.getString("descripcion"));
        area.setNivel(rs.getString("nivel"));
        
        Timestamp fechaRegistro = rs.getTimestamp("fecha_registro");
        if (fechaRegistro != null) {
            area.setFechaRegistro(fechaRegistro.toLocalDateTime());
        }
        
        area.setActivo(rs.getBoolean("activo"));
        area.setEliminado(rs.getBoolean("eliminado"));
        
        return area;
    }
}