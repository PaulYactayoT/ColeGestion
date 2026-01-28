/*
 * DAO PARA GESTION DE AULAS
 * 
 * Funcionalidades:
 * - CRUD completo de aulas
 * - Consulta de aulas por sede
 * - Obtención de información de capacidad y ubicación
 * - Validaciones de disponibilidad
 */
package modelo;

import conexion.Conexion;
import java.sql.*;
import java.util.*;

public class AulaDAO {
    
    /**
     * OBTENER TODAS LAS AULAS ACTIVAS
     * 
     * @return Lista de todas las aulas activas del sistema
     */
    public List<Aula> obtenerTodasLasAulas() {
        List<Aula> lista = new ArrayList<>();
        String sql = "SELECT a.id, a.nombre, a.capacidad, a.sede_id, a.activo, " +
                     "s.nombre as sede_nombre, s.direccion as sede_direccion, " +
                     "s.telefono as sede_telefono " +
                     "FROM aula a " +
                     "INNER JOIN sede s ON a.sede_id = s.id " +
                     "WHERE a.activo = 1 " +
                     "ORDER BY s.nombre, a.nombre";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                lista.add(mapearAula(rs));
            }
            
        } catch (SQLException e) {
            System.out.println("Error al obtener todas las aulas: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }
    
    /**
     * OBTENER AULAS POR SEDE ESPECIFICA
     * 
     * @param sedeId Identificador de la sede
     * @return Lista de aulas pertenecientes a la sede
     */
    public List<Aula> obtenerAulasPorSede(int sedeId) {
        List<Aula> lista = new ArrayList<>();
        String sql = "SELECT a.id, a.nombre, a.capacidad, a.sede_id, a.activo, " +
                     "s.nombre as sede_nombre, s.direccion as sede_direccion, " +
                     "s.telefono as sede_telefono " +
                     "FROM aula a " +
                     "INNER JOIN sede s ON a.sede_id = s.id " +
                     "WHERE a.sede_id = ? AND a.activo = 1 " +
                     "ORDER BY a.nombre";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, sedeId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                lista.add(mapearAula(rs));
            }
            
        } catch (SQLException e) {
            System.out.println("Error al obtener aulas por sede: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }
    
    /**
     * OBTENER AULA POR ID
     * 
     * @param id Identificador del aula
     * @return Objeto Aula o null si no existe
     */
    public Aula obtenerAulaPorId(int id) {
        Aula aula = null;
        String sql = "SELECT a.id, a.nombre, a.capacidad, a.sede_id, a.activo, " +
                     "s.nombre as sede_nombre, s.direccion as sede_direccion, " +
                     "s.telefono as sede_telefono " +
                     "FROM aula a " +
                     "INNER JOIN sede s ON a.sede_id = s.id " +
                     "WHERE a.id = ?";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                aula = mapearAula(rs);
            }
            
        } catch (SQLException e) {
            System.out.println("Error al obtener aula por ID: " + e.getMessage());
            e.printStackTrace();
        }
        
        return aula;
    }
    
    /**
     * CREAR NUEVA AULA
     * 
     * @param aula Objeto Aula con los datos a insertar
     * @return true si se creó exitosamente, false en caso contrario
     */
    public boolean crearAula(Aula aula) {
        String sql = "INSERT INTO aula (nombre, capacidad, sede_id, activo) " +
                     "VALUES (?, ?, ?, ?)";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setString(1, aula.getNombre());
            ps.setInt(2, aula.getCapacidad());
            ps.setInt(3, aula.getSedeId());
            ps.setBoolean(4, aula.isActivo());
            
            int filasAfectadas = ps.executeUpdate();
            
            if (filasAfectadas > 0) {
                // Obtener el ID generado
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    aula.setId(rs.getInt(1));
                }
                System.out.println("Aula creada exitosamente con ID: " + aula.getId());
                return true;
            }
            
        } catch (SQLException e) {
            System.out.println("Error al crear aula: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * ACTUALIZAR AULA EXISTENTE
     * 
     * @param aula Objeto Aula con los datos actualizados
     * @return true si se actualizó exitosamente, false en caso contrario
     */
    public boolean actualizarAula(Aula aula) {
        String sql = "UPDATE aula SET nombre = ?, capacidad = ?, sede_id = ?, activo = ? " +
                     "WHERE id = ?";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, aula.getNombre());
            ps.setInt(2, aula.getCapacidad());
            ps.setInt(3, aula.getSedeId());
            ps.setBoolean(4, aula.isActivo());
            ps.setInt(5, aula.getId());
            
            int filasAfectadas = ps.executeUpdate();
            
            if (filasAfectadas > 0) {
                System.out.println("Aula actualizada exitosamente: " + aula.getId());
                return true;
            }
            
        } catch (SQLException e) {
            System.out.println("Error al actualizar aula: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * ELIMINAR AULA (Desactivar lógicamente)
     * 
     * @param id Identificador del aula a eliminar
     * @return true si se eliminó exitosamente, false en caso contrario
     */
    public boolean eliminarAula(int id) {
        String sql = "UPDATE aula SET activo = 0 WHERE id = ?";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            
            int filasAfectadas = ps.executeUpdate();
            
            if (filasAfectadas > 0) {
                System.out.println("Aula desactivada exitosamente: " + id);
                return true;
            }
            
        } catch (SQLException e) {
            System.out.println("Error al eliminar aula: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * ELIMINAR AULA PERMANENTEMENTE
     * 
     * @param id Identificador del aula a eliminar
     * @return true si se eliminó exitosamente, false en caso contrario
     */
    public boolean eliminarAulaPermanente(int id) {
        String sql = "DELETE FROM aula WHERE id = ?";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            
            int filasAfectadas = ps.executeUpdate();
            
            if (filasAfectadas > 0) {
                System.out.println("Aula eliminada permanentemente: " + id);
                return true;
            }
            
        } catch (SQLException e) {
            System.out.println("Error al eliminar aula permanentemente: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * VERIFICAR SI UN AULA ESTÁ SIENDO UTILIZADA EN HORARIOS
     * 
     * @param aulaId Identificador del aula
     * @return true si el aula tiene horarios asignados, false en caso contrario
     */
    public boolean aulaEnUso(int aulaId) {
        String sql = "SELECT COUNT(*) as total FROM horario_clase " +
                     "WHERE aula_id = ? AND activo = 1";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, aulaId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("total") > 0;
            }
            
        } catch (SQLException e) {
            System.out.println("Error al verificar uso del aula: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * OBTENER AULAS DISPONIBLES (sin horarios asignados)
     * 
     * @param sedeId Identificador de la sede (0 para todas las sedes)
     * @return Lista de aulas disponibles
     */
    public List<Aula> obtenerAulasDisponibles(int sedeId) {
        List<Aula> lista = new ArrayList<>();
        String sql = "SELECT a.id, a.nombre, a.capacidad, a.sede_id, a.activo, " +
                     "s.nombre as sede_nombre, s.direccion as sede_direccion, " +
                     "s.telefono as sede_telefono " +
                     "FROM aula a " +
                     "INNER JOIN sede s ON a.sede_id = s.id " +
                     "LEFT JOIN horario_clase h ON a.id = h.aula_id AND h.activo = 1 " +
                     "WHERE a.activo = 1 " +
                     (sedeId > 0 ? "AND a.sede_id = ? " : "") +
                     "GROUP BY a.id " +
                     "HAVING COUNT(h.id) = 0 " +
                     "ORDER BY s.nombre, a.nombre";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            if (sedeId > 0) {
                ps.setInt(1, sedeId);
            }
            
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                lista.add(mapearAula(rs));
            }
            
        } catch (SQLException e) {
            System.out.println("Error al obtener aulas disponibles: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }
    
    /**
     * OBTENER ESTADÍSTICAS DE OCUPACIÓN DE AULAS
     * 
     * @return Lista de aulas con información de ocupación
     */
    public List<Map<String, Object>> obtenerEstadisticasOcupacion() {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql = "SELECT a.id, a.nombre, a.capacidad, s.nombre as sede_nombre, " +
                     "COUNT(DISTINCT h.id) as horarios_asignados, " +
                     "ROUND((COUNT(DISTINCT h.id) * 100.0 / " +
                     "(SELECT COUNT(DISTINCT CONCAT(dia_semana, '-', hora_inicio)) " +
                     "FROM horario_clase WHERE activo = 1)), 2) as porcentaje_uso " +
                     "FROM aula a " +
                     "INNER JOIN sede s ON a.sede_id = s.id " +
                     "LEFT JOIN horario_clase h ON a.id = h.aula_id AND h.activo = 1 " +
                     "WHERE a.activo = 1 " +
                     "GROUP BY a.id, a.nombre, a.capacidad, s.nombre " +
                     "ORDER BY porcentaje_uso DESC";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Map<String, Object> stats = new HashMap<>();
                stats.put("id", rs.getInt("id"));
                stats.put("nombre", rs.getString("nombre"));
                stats.put("capacidad", rs.getInt("capacidad"));
                stats.put("sede_nombre", rs.getString("sede_nombre"));
                stats.put("horarios_asignados", rs.getInt("horarios_asignados"));
                stats.put("porcentaje_uso", rs.getDouble("porcentaje_uso"));
                lista.add(stats);
            }
            
        } catch (SQLException e) {
            System.out.println("Error al obtener estadísticas de ocupación: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }
    
    /**
     * BUSCAR AULAS POR NOMBRE
     * 
     * @param nombre Nombre o parte del nombre del aula
     * @return Lista de aulas que coinciden con la búsqueda
     */
    public List<Aula> buscarAulasPorNombre(String nombre) {
        List<Aula> lista = new ArrayList<>();
        String sql = "SELECT a.id, a.nombre, a.capacidad, a.sede_id, a.activo, " +
                     "s.nombre as sede_nombre, s.direccion as sede_direccion, " +
                     "s.telefono as sede_telefono " +
                     "FROM aula a " +
                     "INNER JOIN sede s ON a.sede_id = s.id " +
                     "WHERE a.nombre LIKE ? AND a.activo = 1 " +
                     "ORDER BY s.nombre, a.nombre";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, "%" + nombre + "%");
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                lista.add(mapearAula(rs));
            }
            
        } catch (SQLException e) {
            System.out.println("Error al buscar aulas por nombre: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }
    
    /**
     * MÉTODO AUXILIAR PARA MAPEAR ResultSet A OBJETO AULA
     * 
     * @param rs ResultSet con los datos del aula
     * @return Objeto Aula mapeado
     * @throws SQLException
     */
    private Aula mapearAula(ResultSet rs) throws SQLException {
        Aula aula = new Aula();
        aula.setId(rs.getInt("id"));
        aula.setNombre(rs.getString("nombre"));
        aula.setCapacidad(rs.getInt("capacidad"));
        aula.setSedeId(rs.getInt("sede_id"));
        aula.setActivo(rs.getBoolean("activo"));
        aula.setSedeNombre(rs.getString("sede_nombre"));
        
        // Campos opcionales de sede
        try {
            aula.setSedeDireccion(rs.getString("sede_direccion"));
            aula.setSedeTelefono(rs.getString("sede_telefono"));
        } catch (SQLException e) {
            // Estos campos pueden no estar presentes en todas las consultas
        }
        
        return aula;
    }
}