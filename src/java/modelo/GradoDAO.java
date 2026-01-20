/*
 * DAO PARA GESTION DE GRADOS ACADEMICOS
 * 
 * Funcionalidades:
 * - CRUD completo de grados académicos
 * - Consulta por niveles educativos (INICIAL, PRIMARIA, SECUNDARIA)
 * - Integración con stored procedures
 * - Consultas estadísticas y reportes
 * - Validación de datos
 * 
 * @author Tu Nombre
 */
package modelo;

import conexion.Conexion;
import java.sql.*;
import java.util.*;

public class GradoDAO {

    /**
     * LISTAR TODOS LOS GRADOS ACADÉMICOS
     * Utiliza el stored procedure: obtener_grados
     * Retorna todos los grados ordenados por nivel y orden
     * 
     * @return Lista completa de grados disponibles
     */
    public List<Grado> listar() {
        List<Grado> lista = new ArrayList<>();
        String sql = "{CALL obtener_grados()}";
        
        try (Connection con = Conexion.getConnection();
             CallableStatement cs = con.prepareCall(sql);
             ResultSet rs = cs.executeQuery()) {
            
            while (rs.next()) {
                Grado g = mapearResultSet(rs);
                lista.add(g);
            }
            
        } catch (SQLException e) {
            System.err.println("Error al listar grados: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }

    /**
     * LISTAR SOLO GRADOS ACTIVOS
     * 
     * @return Lista de grados activos ordenados
     */
    public List<Grado> listarActivos() {
        List<Grado> lista = new ArrayList<>();
        String sql = "SELECT * FROM grado WHERE activo = 1 ORDER BY nivel, orden";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Grado g = mapearResultSet(rs);
                lista.add(g);
            }
            
        } catch (SQLException e) {
            System.err.println("Error al listar grados activos: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }

    /**
     * AGREGAR NUEVO GRADO ACADÉMICO
     * Utiliza el stored procedure: crear_grado
     * 
     * @param g Objeto Grado con datos del nuevo grado
     * @return ID del grado creado, o -1 si falla
     */
    public int agregar(Grado g) {
        String sql = "{CALL crear_grado(?, ?)}";
        
        try (Connection con = Conexion.getConnection();
             CallableStatement cs = con.prepareCall(sql)) {
            
            cs.setString(1, g.getNombre());
            cs.setString(2, g.getNivel());
            
            ResultSet rs = cs.executeQuery();
            if (rs.next()) {
                return rs.getInt("id");
            }
            
        } catch (SQLException e) {
            System.err.println("Error al agregar grado: " + e.getMessage());
            e.printStackTrace();
        }
        
        return -1;
    }

    /**
     * AGREGAR GRADO CON ORDEN ESPECÍFICO
     * Para mayor control sobre el ordenamiento
     * 
     * @param g Objeto Grado con todos los datos
     * @return ID del grado creado, o -1 si falla
     */
    public int agregarConOrden(Grado g) {
        String sql = "INSERT INTO grado (nombre, nivel, orden, activo) VALUES (?, ?, ?, ?)";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setString(1, g.getNombre());
            ps.setString(2, g.getNivel());
            ps.setInt(3, g.getOrden());
            ps.setBoolean(4, g.isActivo());
            
            int filasAfectadas = ps.executeUpdate();
            
            if (filasAfectadas > 0) {
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
            
        } catch (SQLException e) {
            System.err.println("Error al agregar grado con orden: " + e.getMessage());
            e.printStackTrace();
        }
        
        return -1;
    }

    /**
     * OBTENER GRADO POR ID
     * Utiliza el stored procedure: obtener_grado_por_id
     * 
     * @param id Identificador único del grado
     * @return Objeto Grado o null si no existe
     */
    public Grado obtenerPorId(int id) {
        String sql = "{CALL obtener_grado_por_id(?)}";
        
        try (Connection con = Conexion.getConnection();
             CallableStatement cs = con.prepareCall(sql)) {
            
            cs.setInt(1, id);
            ResultSet rs = cs.executeQuery();
            
            if (rs.next()) {
                return mapearResultSet(rs);
            }
            
        } catch (SQLException e) {
            System.err.println("Error al obtener grado por ID: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }

    /**
     * ACTUALIZAR DATOS DE GRADO EXISTENTE
     * Utiliza el stored procedure: actualizar_grado
     * 
     * @param g Objeto Grado con datos actualizados
     * @return true si la actualización fue exitosa
     */
    public boolean actualizar(Grado g) {
        String sql = "{CALL actualizar_grado(?, ?, ?)}";
        
        try (Connection con = Conexion.getConnection();
             CallableStatement cs = con.prepareCall(sql)) {
            
            cs.setInt(1, g.getId());
            cs.setString(2, g.getNombre());
            cs.setString(3, g.getNivel());
            
            cs.executeUpdate();
            return true;
            
        } catch (SQLException e) {
            System.err.println("Error al actualizar grado: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * ACTUALIZAR GRADO COMPLETO (incluyendo orden y estado)
     * 
     * @param g Objeto Grado con todos los datos actualizados
     * @return true si la actualización fue exitosa
     */
    public boolean actualizarCompleto(Grado g) {
        String sql = "UPDATE grado SET nombre = ?, nivel = ?, orden = ?, activo = ? WHERE id = ?";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, g.getNombre());
            ps.setString(2, g.getNivel());
            ps.setInt(3, g.getOrden());
            ps.setBoolean(4, g.isActivo());
            ps.setInt(5, g.getId());
            
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("Error al actualizar grado completo: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * ELIMINAR GRADO POR ID
     * Utiliza el stored procedure: eliminar_grado
     * 
     * @param id Identificador del grado a eliminar
     * @return true si la eliminación fue exitosa
     */
    public boolean eliminar(int id) {
        String sql = "{CALL eliminar_grado(?)}";
        
        try (Connection con = Conexion.getConnection();
             CallableStatement cs = con.prepareCall(sql)) {
            
            cs.setInt(1, id);
            cs.executeUpdate();
            return true;
            
        } catch (SQLException e) {
            System.err.println("Error al eliminar grado: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * DESACTIVAR GRADO (Soft Delete - Recomendado)
     * Marca el grado como inactivo sin eliminarlo físicamente
     * 
     * @param id Identificador del grado
     * @return true si se desactivó correctamente
     */
    public boolean desactivar(int id) {
        String sql = "UPDATE grado SET activo = 0 WHERE id = ?";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("Error al desactivar grado: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * ACTIVAR GRADO
     * Reactiva un grado previamente desactivado
     * 
     * @param id Identificador del grado
     * @return true si se activó correctamente
     */
    public boolean activar(int id) {
        String sql = "UPDATE grado SET activo = 1 WHERE id = ?";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("Error al activar grado: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * LISTAR GRADOS POR NIVEL
     * Obtiene todos los grados de un nivel específico
     * 
     * @param nivel Nivel educativo (INICIAL, PRIMARIA, SECUNDARIA)
     * @return Lista de grados del nivel especificado
     */
    public List<Grado> listarPorNivel(String nivel) {
        List<Grado> lista = new ArrayList<>();
        String sql = "SELECT * FROM grado WHERE nivel = ? AND activo = 1 ORDER BY orden";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, nivel.toUpperCase());
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Grado g = mapearResultSet(rs);
                lista.add(g);
            }
            
        } catch (SQLException e) {
            System.err.println("Error al listar grados por nivel: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }

    /**
     * OBTENER GRADOS DE INICIAL
     * 
     * @return Lista de grados de nivel inicial
     */
    public List<Grado> obtenerGradosInicial() {
        return listarPorNivel("INICIAL");
    }

    /**
     * OBTENER GRADOS DE PRIMARIA
     * 
     * @return Lista de grados de nivel primaria
     */
    public List<Grado> obtenerGradosPrimaria() {
        return listarPorNivel("PRIMARIA");
    }

    /**
     * OBTENER GRADOS DE SECUNDARIA
     * 
     * @return Lista de grados de nivel secundaria
     */
    public List<Grado> obtenerGradosSecundaria() {
        return listarPorNivel("SECUNDARIA");
    }

    /**
     * OBTENER GRADO CON ESTADÍSTICAS
     * Incluye contadores de alumnos y cursos
     * 
     * @param id Identificador del grado
     * @return Grado con estadísticas o null
     */
    public Grado obtenerConEstadisticas(int id) {
        String sql = "SELECT g.*, " +
                     "(SELECT COUNT(*) FROM alumno a WHERE a.grado_id = g.id AND a.estado = 'ACTIVO') as cant_alumnos, " +
                     "(SELECT COUNT(*) FROM curso c WHERE c.grado_id = g.id AND c.activo = 1) as cant_cursos " +
                     "FROM grado g WHERE g.id = ?";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                Grado g = mapearResultSet(rs);
                g.setCantidadAlumnos(rs.getInt("cant_alumnos"));
                g.setCantidadCursos(rs.getInt("cant_cursos"));
                return g;
            }
            
        } catch (SQLException e) {
            System.err.println("Error al obtener grado con estadísticas: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }

    /**
     * LISTAR TODOS LOS GRADOS CON ESTADÍSTICAS
     * 
     * @return Lista de grados con contadores de alumnos y cursos
     */
    public List<Grado> listarConEstadisticas() {
        List<Grado> lista = new ArrayList<>();
        String sql = "SELECT g.*, " +
                     "(SELECT COUNT(*) FROM alumno a WHERE a.grado_id = g.id AND a.estado = 'ACTIVO') as cant_alumnos, " +
                     "(SELECT COUNT(*) FROM curso c WHERE c.grado_id = g.id AND c.activo = 1) as cant_cursos " +
                     "FROM grado g WHERE g.activo = 1 ORDER BY g.nivel, g.orden";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Grado g = mapearResultSet(rs);
                g.setCantidadAlumnos(rs.getInt("cant_alumnos"));
                g.setCantidadCursos(rs.getInt("cant_cursos"));
                lista.add(g);
            }
            
        } catch (SQLException e) {
            System.err.println("Error al listar grados con estadísticas: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }

    /**
     * BUSCAR GRADOS POR NOMBRE
     * 
     * @param nombre Nombre o parte del nombre a buscar
     * @return Lista de grados que coinciden
     */
    public List<Grado> buscarPorNombre(String nombre) {
        List<Grado> lista = new ArrayList<>();
        String sql = "SELECT * FROM grado WHERE nombre LIKE ? AND activo = 1 ORDER BY nivel, orden";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, "%" + nombre + "%");
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Grado g = mapearResultSet(rs);
                lista.add(g);
            }
            
        } catch (SQLException e) {
            System.err.println("Error al buscar grados por nombre: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }

    /**
     * CONTAR GRADOS POR NIVEL
     * 
     * @param nivel Nivel educativo
     * @return Cantidad de grados en ese nivel
     */
    public int contarPorNivel(String nivel) {
        String sql = "SELECT COUNT(*) as total FROM grado WHERE nivel = ? AND activo = 1";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, nivel.toUpperCase());
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("total");
            }
            
        } catch (SQLException e) {
            System.err.println("Error al contar grados por nivel: " + e.getMessage());
            e.printStackTrace();
        }
        
        return 0;
    }

    /**
     * VERIFICAR SI EXISTE GRADO
     * 
     * @param nombre Nombre del grado
     * @param nivel Nivel del grado
     * @return true si ya existe
     */
    public boolean existeGrado(String nombre, String nivel) {
        String sql = "SELECT COUNT(*) as total FROM grado WHERE nombre = ? AND nivel = ?";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, nombre);
            ps.setString(2, nivel.toUpperCase());
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("total") > 0;
            }
            
        } catch (SQLException e) {
            System.err.println("Error al verificar existencia de grado: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }

    /**
     * VERIFICAR SI GRADO TIENE ALUMNOS
     * Útil antes de eliminar
     * 
     * @param id Identificador del grado
     * @return true si tiene alumnos asociados
     */
    public boolean tieneAlumnos(int id) {
        String sql = "SELECT COUNT(*) as total FROM alumno WHERE grado_id = ? AND estado = 'ACTIVO'";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("total") > 0;
            }
            
        } catch (SQLException e) {
            System.err.println("Error al verificar alumnos del grado: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }

    /**
     * VERIFICAR SI GRADO TIENE CURSOS
     * 
     * @param id Identificador del grado
     * @return true si tiene cursos asociados
     */
    public boolean tieneCursos(int id) {
        String sql = "SELECT COUNT(*) as total FROM curso WHERE grado_id = ? AND activo = 1";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("total") > 0;
            }
            
        } catch (SQLException e) {
            System.err.println("Error al verificar cursos del grado: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }

    /**
     * OBTENER SIGUIENTE ORDEN DISPONIBLE
     * Para asignar automáticamente el orden al crear un grado
     * 
     * @return Siguiente número de orden
     */
    public int obtenerSiguienteOrden() {
        String sql = "SELECT COALESCE(MAX(orden), 0) + 1 as siguiente FROM grado";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            if (rs.next()) {
                return rs.getInt("siguiente");
            }
            
        } catch (SQLException e) {
            System.err.println("Error al obtener siguiente orden: " + e.getMessage());
            e.printStackTrace();
        }
        
        return 1;
    }

    /**
     * MÉTODO AUXILIAR: Mapear ResultSet a Grado
     * Centraliza la lógica de mapeo
     * 
     * @param rs ResultSet con los datos
     * @return Objeto Grado mapeado
     * @throws SQLException si hay error al leer
     */
    private Grado mapearResultSet(ResultSet rs) throws SQLException {
        Grado g = new Grado();
        g.setId(rs.getInt("id"));
        g.setNombre(rs.getString("nombre"));
        g.setNivel(rs.getString("nivel"));
        
        // Campos opcionales (pueden no existir en todos los queries)
        try {
            g.setOrden(rs.getInt("orden"));
            g.setActivo(rs.getBoolean("activo"));
        } catch (SQLException e) {
            // Si no existen estos campos, usar valores por defecto
            g.setActivo(true);
        }
        
        return g;
    }

    /**
     * OBTENER TOTAL DE GRADOS ACTIVOS
     * 
     * @return Cantidad total de grados activos
     */
    public int contarTotal() {
        String sql = "SELECT COUNT(*) as total FROM grado WHERE activo = 1";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            if (rs.next()) {
                return rs.getInt("total");
            }
            
        } catch (SQLException e) {
            System.err.println("Error al contar total de grados: " + e.getMessage());
            e.printStackTrace();
        }
        
        return 0;
    }
}