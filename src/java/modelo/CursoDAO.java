package modelo;

import conexion.Conexion;
import java.sql.*;
import java.util.*;

/**
 * DAO PARA GESTIÓN DE CURSOS ACADÉMICOS
 * 
 * Funcionalidades:
 * - CRUD completo de cursos
 * - Consultas por grado, profesor y nivel
 * - Integración con stored procedures
 * - Consultas estadísticas y reportes
 * - Validación de datos
 * 
 * @author Tu Nombre
 */
public class CursoDAO {

    /**
     * LISTAR CURSOS POR GRADO ACADÉMICO
     * Utiliza el stored procedure: obtener_cursos_por_grado
     * 
     * @param gradoId Identificador del grado
     * @return Lista de cursos del grado especificado
     */
    public List<Curso> listarPorGrado(int gradoId) {
        List<Curso> lista = new ArrayList<>();
        String sql = "{CALL obtener_cursos_por_grado(?)}";

        try (Connection con = Conexion.getConnection(); 
             CallableStatement cs = con.prepareCall(sql)) {
            
            cs.setInt(1, gradoId);
            ResultSet rs = cs.executeQuery();
            
            while (rs.next()) {
                Curso c = mapearResultSet(rs);
                lista.add(c);
            }
            
        } catch (SQLException e) {
            System.err.println("Error al listar cursos por grado: " + e.getMessage());
            e.printStackTrace();
        }

        return lista;
    }

    /**
     * LISTAR CURSOS ASIGNADOS A PROFESOR ESPECÍFICO
     * Utiliza el stored procedure: obtener_cursos_por_profesor
     * 
     * @param profesorId Identificador del profesor
     * @return Lista de cursos asignados al profesor
     */
    public List<Curso> listarPorProfesor(int profesorId) {
        List<Curso> lista = new ArrayList<>();
        String sql = "{CALL obtener_cursos_por_profesor(?)}";

        try (Connection con = Conexion.getConnection(); 
             CallableStatement cs = con.prepareCall(sql)) {

            cs.setInt(1, profesorId);
            ResultSet rs = cs.executeQuery();

            while (rs.next()) {
                Curso c = mapearResultSet(rs);
                lista.add(c);
                
                System.out.println("Curso encontrado: " + c.getNombre() + 
                                 " - Grado: " + c.getGradoNombre());
            }

            System.out.println("Total cursos encontrados para profesor " + 
                             profesorId + ": " + lista.size());

        } catch (SQLException e) {
            System.err.println("Error SQL en listarPorProfesor:");
            System.err.println("   Código: " + e.getErrorCode());
            System.err.println("   Estado: " + e.getSQLState());
            System.err.println("   Mensaje: " + e.getMessage());
            e.printStackTrace();
        }

        return lista;
    }

    /**
     * LISTAR TODOS LOS CURSOS REGISTRADOS
     * Utiliza el stored procedure: obtener_cursos
     * 
     * @return Lista completa de cursos
     */
    public List<Curso> listar() {
        List<Curso> lista = new ArrayList<>();
        String sql = "{CALL obtener_cursos()}";

        try (Connection con = Conexion.getConnection(); 
             CallableStatement cs = con.prepareCall(sql); 
             ResultSet rs = cs.executeQuery()) {

            while (rs.next()) {
                Curso c = mapearResultSet(rs);
                lista.add(c);
            }

        } catch (SQLException e) {
            System.err.println("Error al listar cursos: " + e.getMessage());
            e.printStackTrace();
        }

        return lista;
    }

    /**
     * LISTAR SOLO CURSOS ACTIVOS
     * 
     * @return Lista de cursos activos ordenados
     */
    public List<Curso> listarActivos() {
        List<Curso> lista = new ArrayList<>();
        String sql = "SELECT c.*, g.nombre as grado_nombre, g.nivel, " +
                     "CONCAT(p.nombres, ' ', p.apellidos) as profesor_nombre " +
                     "FROM curso c " +
                     "JOIN grado g ON c.grado_id = g.id " +
                     "JOIN profesor prof ON c.profesor_id = prof.id " +
                     "JOIN persona p ON prof.persona_id = p.id " +
                     "WHERE c.activo = 1 " +
                     "ORDER BY g.nivel, g.orden, c.nombre";

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Curso c = mapearResultSetCompleto(rs);
                lista.add(c);
            }

        } catch (SQLException e) {
            System.err.println("Error al listar cursos activos: " + e.getMessage());
            e.printStackTrace();
        }

        return lista;
    }

    /**
     * OBTENER CURSO POR ID
     * Utiliza el stored procedure: obtener_curso_por_id
     * 
     * @param id Identificador único del curso
     * @return Objeto Curso o null si no existe
     */
    public Curso obtenerPorId(int id) {
        String sql = "{CALL obtener_curso_por_id(?)}";

        try (Connection con = Conexion.getConnection(); 
             CallableStatement cs = con.prepareCall(sql)) {
            
            cs.setInt(1, id);
            ResultSet rs = cs.executeQuery();

            if (rs.next()) {
                Curso c = mapearResultSetCompleto(rs);
                return c;
            }

        } catch (SQLException e) {
            System.err.println("Error al obtener curso por ID: " + e.getMessage());
            e.printStackTrace();
        }

        return null;
    }

    /**
     * AGREGAR NUEVO CURSO
     * Utiliza el stored procedure: crear_curso
     * 
     * @param c Objeto Curso con los datos
     * @return ID del curso creado, o -1 si falla
     */
    public int agregar(Curso c) {
        String sql = "{CALL crear_curso(?, ?, ?, ?)}";
        
        try (Connection con = Conexion.getConnection(); 
             CallableStatement cs = con.prepareCall(sql)) {

            cs.setString(1, c.getNombre());
            cs.setInt(2, c.getGradoId());
            cs.setInt(3, c.getProfesorId());
            cs.setInt(4, c.getCreditos());

            ResultSet rs = cs.executeQuery();
            if (rs.next()) {
                return rs.getInt("id");
            }

        } catch (SQLException e) {
            System.err.println("Error al agregar curso: " + e.getMessage());
            e.printStackTrace();
        }
        
        return -1;
    }

    /**
     * AGREGAR CURSO CON ÁREA
     * Para mayor control sobre los datos
     * 
     * @param c Objeto Curso con todos los datos
     * @return ID del curso creado, o -1 si falla
     */
    public int agregarConArea(Curso c) {
        String sql = "INSERT INTO curso (nombre, grado_id, profesor_id, creditos, area, activo) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, c.getNombre());
            ps.setInt(2, c.getGradoId());
            ps.setInt(3, c.getProfesorId());
            ps.setInt(4, c.getCreditos());
            ps.setString(5, c.getArea());
            ps.setBoolean(6, c.isActivo());

            int filasAfectadas = ps.executeUpdate();
            
            if (filasAfectadas > 0) {
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }

        } catch (SQLException e) {
            System.err.println("Error al agregar curso con área: " + e.getMessage());
            e.printStackTrace();
        }
        
        return -1;
    }

    /**
     * ACTUALIZAR DATOS DE CURSO EXISTENTE
     * Utiliza el stored procedure: actualizar_curso
     * 
     * @param c Objeto Curso con los datos actualizados
     * @return true si la actualización fue exitosa
     */
    public boolean actualizar(Curso c) {
        String sql = "{CALL actualizar_curso(?, ?, ?, ?, ?)}";
        
        try (Connection con = Conexion.getConnection(); 
             CallableStatement cs = con.prepareCall(sql)) {

            cs.setInt(1, c.getId());
            cs.setString(2, c.getNombre());
            cs.setInt(3, c.getGradoId());
            cs.setInt(4, c.getProfesorId());
            cs.setInt(5, c.getCreditos());

            return cs.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("Error al actualizar curso: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * ACTUALIZAR CURSO COMPLETO (incluyendo área y estado)
     * 
     * @param c Objeto Curso con todos los datos actualizados
     * @return true si la actualización fue exitosa
     */
    public boolean actualizarCompleto(Curso c) {
        String sql = "UPDATE curso SET nombre = ?, grado_id = ?, profesor_id = ?, " +
                     "creditos = ?, area = ?, activo = ? WHERE id = ?";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, c.getNombre());
            ps.setInt(2, c.getGradoId());
            ps.setInt(3, c.getProfesorId());
            ps.setInt(4, c.getCreditos());
            ps.setString(5, c.getArea());
            ps.setBoolean(6, c.isActivo());
            ps.setInt(7, c.getId());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("Error al actualizar curso completo: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * ELIMINAR CURSO POR ID
     * Utiliza el stored procedure: eliminar_curso
     * 
     * @param id Identificador del curso a eliminar
     * @return true si la eliminación fue exitosa
     */
    public boolean eliminar(int id) {
        String sql = "{CALL eliminar_curso(?)}";
        
        try (Connection con = Conexion.getConnection(); 
             CallableStatement cs = con.prepareCall(sql)) {

            cs.setInt(1, id);
            return cs.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("Error al eliminar curso: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * DESACTIVAR CURSO (Soft Delete - Recomendado)
     * 
     * @param id Identificador del curso
     * @return true si se desactivó correctamente
     */
    public boolean desactivar(int id) {
        String sql = "UPDATE curso SET activo = 0 WHERE id = ?";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("Error al desactivar curso: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * ACTIVAR CURSO
     * 
     * @param id Identificador del curso
     * @return true si se activó correctamente
     */
    public boolean activar(int id) {
        String sql = "UPDATE curso SET activo = 1 WHERE id = ?";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("Error al activar curso: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * VERIFICAR SI UN CURSO ESTÁ ASIGNADO A UN PROFESOR
     * 
     * @param cursoId Identificador del curso
     * @param profesorId Identificador del profesor
     * @return true si el curso está asignado al profesor
     */
    public boolean isCursoAssignedToProfesor(int cursoId, int profesorId) {
        String sql = "SELECT COUNT(*) as count FROM curso WHERE id = ? AND profesor_id = ? AND activo = 1";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, cursoId);
            ps.setInt(2, profesorId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("count") > 0;
            }
            
        } catch (SQLException e) {
            System.err.println("Error al verificar asignación curso-profesor: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }

    /**
     * VERIFICAR EXISTENCIA DE CURSO
     * 
     * @param cursoId Identificador del curso
     * @return true si el curso existe
     */
    public boolean existeCurso(int cursoId) {
        String sql = "SELECT COUNT(*) as count FROM curso WHERE id = ?";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, cursoId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("count") > 0;
            }
            
        } catch (SQLException e) {
            System.err.println("Error al verificar existencia de curso: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }

    /**
     * LISTAR CURSOS POR NIVEL EDUCATIVO
     * 
     * @param nivel Nivel educativo (INICIAL, PRIMARIA, SECUNDARIA)
     * @return Lista de cursos del nivel especificado
     */
    public List<Curso> listarPorNivel(String nivel) {
        List<Curso> lista = new ArrayList<>();
        String sql = "SELECT c.*, g.nombre as grado_nombre, g.nivel, " +
                     "CONCAT(p.nombres, ' ', p.apellidos) as profesor_nombre " +
                     "FROM curso c " +
                     "JOIN grado g ON c.grado_id = g.id " +
                     "JOIN profesor prof ON c.profesor_id = prof.id " +
                     "JOIN persona p ON prof.persona_id = p.id " +
                     "WHERE g.nivel = ? AND c.activo = 1 " +
                     "ORDER BY g.orden, c.nombre";

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, nivel.toUpperCase());
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Curso c = mapearResultSetCompleto(rs);
                lista.add(c);
            }

        } catch (SQLException e) {
            System.err.println("Error al listar cursos por nivel: " + e.getMessage());
            e.printStackTrace();
        }

        return lista;
    }

    /**
     * LISTAR CURSOS POR ÁREA
     * 
     * @param area Área curricular
     * @return Lista de cursos del área especificada
     */
    public List<Curso> listarPorArea(String area) {
        List<Curso> lista = new ArrayList<>();
        String sql = "SELECT c.*, g.nombre as grado_nombre, g.nivel, " +
                     "CONCAT(p.nombres, ' ', p.apellidos) as profesor_nombre " +
                     "FROM curso c " +
                     "JOIN grado g ON c.grado_id = g.id " +
                     "JOIN profesor prof ON c.profesor_id = prof.id " +
                     "JOIN persona p ON prof.persona_id = p.id " +
                     "WHERE c.area = ? AND c.activo = 1 " +
                     "ORDER BY g.nivel, g.orden, c.nombre";

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, area);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Curso c = mapearResultSetCompleto(rs);
                lista.add(c);
            }

        } catch (SQLException e) {
            System.err.println("Error al listar cursos por área: " + e.getMessage());
            e.printStackTrace();
        }

        return lista;
    }

    /**
     * OBTENER CURSO CON ESTADÍSTICAS
     * 
     * @param id Identificador del curso
     * @return Curso con estadísticas o null
     */
    public Curso obtenerConEstadisticas(int id) {
        String sql = "SELECT c.*, g.nombre as grado_nombre, g.nivel, " +
                     "CONCAT(p.nombres, ' ', p.apellidos) as profesor_nombre, " +
                     "(SELECT COUNT(DISTINCT a.id) FROM alumno a WHERE a.grado_id = c.grado_id AND a.estado = 'ACTIVO') as cant_alumnos, " +
                     "(SELECT COUNT(*) FROM tarea t WHERE t.curso_id = c.id AND t.activo = 1) as cant_tareas, " +
                     "(SELECT COUNT(*) FROM horario_clase h WHERE h.curso_id = c.id AND h.activo = 1) as cant_horarios " +
                     "FROM curso c " +
                     "JOIN grado g ON c.grado_id = g.id " +
                     "JOIN profesor prof ON c.profesor_id = prof.id " +
                     "JOIN persona p ON prof.persona_id = p.id " +
                     "WHERE c.id = ?";

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Curso c = mapearResultSetCompleto(rs);
                c.setCantidadAlumnos(rs.getInt("cant_alumnos"));
                c.setCantidadTareas(rs.getInt("cant_tareas"));
                c.setCantidadHorarios(rs.getInt("cant_horarios"));
                return c;
            }

        } catch (SQLException e) {
            System.err.println("Error al obtener curso con estadísticas: " + e.getMessage());
            e.printStackTrace();
        }

        return null;
    }

    /**
     * LISTAR TODOS LOS CURSOS CON ESTADÍSTICAS
     * 
     * @return Lista de cursos con estadísticas
     */
    public List<Curso> listarConEstadisticas() {
        List<Curso> lista = new ArrayList<>();
        String sql = "SELECT c.*, g.nombre as grado_nombre, g.nivel, " +
                     "CONCAT(p.nombres, ' ', p.apellidos) as profesor_nombre, " +
                     "(SELECT COUNT(DISTINCT a.id) FROM alumno a WHERE a.grado_id = c.grado_id AND a.estado = 'ACTIVO') as cant_alumnos, " +
                     "(SELECT COUNT(*) FROM tarea t WHERE t.curso_id = c.id AND t.activo = 1) as cant_tareas, " +
                     "(SELECT COUNT(*) FROM horario_clase h WHERE h.curso_id = c.id AND h.activo = 1) as cant_horarios " +
                     "FROM curso c " +
                     "JOIN grado g ON c.grado_id = g.id " +
                     "JOIN profesor prof ON c.profesor_id = prof.id " +
                     "JOIN persona p ON prof.persona_id = p.id " +
                     "WHERE c.activo = 1 " +
                     "ORDER BY g.nivel, g.orden, c.nombre";

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Curso c = mapearResultSetCompleto(rs);
                c.setCantidadAlumnos(rs.getInt("cant_alumnos"));
                c.setCantidadTareas(rs.getInt("cant_tareas"));
                c.setCantidadHorarios(rs.getInt("cant_horarios"));
                lista.add(c);
            }

        } catch (SQLException e) {
            System.err.println("Error al listar cursos con estadísticas: " + e.getMessage());
            e.printStackTrace();
        }

        return lista;
    }

    /**
     * BUSCAR CURSOS POR NOMBRE
     * 
     * @param nombre Nombre o parte del nombre a buscar
     * @return Lista de cursos que coinciden
     */
    public List<Curso> buscarPorNombre(String nombre) {
        List<Curso> lista = new ArrayList<>();
        String sql = "SELECT c.*, g.nombre as grado_nombre, g.nivel, " +
                     "CONCAT(p.nombres, ' ', p.apellidos) as profesor_nombre " +
                     "FROM curso c " +
                     "JOIN grado g ON c.grado_id = g.id " +
                     "JOIN profesor prof ON c.profesor_id = prof.id " +
                     "JOIN persona p ON prof.persona_id = p.id " +
                     "WHERE c.nombre LIKE ? AND c.activo = 1 " +
                     "ORDER BY c.nombre";

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, "%" + nombre + "%");
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Curso c = mapearResultSetCompleto(rs);
                lista.add(c);
            }

        } catch (SQLException e) {
            System.err.println("Error al buscar cursos por nombre: " + e.getMessage());
            e.printStackTrace();
        }

        return lista;
    }

    /**
     * VERIFICAR SI CURSO TIENE TAREAS
     * 
     * @param id Identificador del curso
     * @return true si tiene tareas asociadas
     */
    public boolean tieneTareas(int id) {
        String sql = "SELECT COUNT(*) as total FROM tarea WHERE curso_id = ? AND activo = 1";

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt("total") > 0;
            }

        } catch (SQLException e) {
            System.err.println("Error al verificar tareas del curso: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    /**
     * VERIFICAR SI CURSO TIENE HORARIOS
     * 
     * @param id Identificador del curso
     * @return true si tiene horarios asociados
     */
    public boolean tieneHorarios(int id) {
        String sql = "SELECT COUNT(*) as total FROM horario_clase WHERE curso_id = ? AND activo = 1";

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt("total") > 0;
            }

        } catch (SQLException e) {
            System.err.println("Error al verificar horarios del curso: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    /**
     * CONTAR CURSOS POR PROFESOR
     * 
     * @param profesorId Identificador del profesor
     * @return Cantidad de cursos asignados
     */
    public int contarPorProfesor(int profesorId) {
        String sql = "SELECT COUNT(*) as total FROM curso WHERE profesor_id = ? AND activo = 1";

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, profesorId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt("total");
            }

        } catch (SQLException e) {
            System.err.println("Error al contar cursos por profesor: " + e.getMessage());
            e.printStackTrace();
        }

        return 0;
    }

    /**
     * CONTAR CURSOS POR GRADO
     * 
     * @param gradoId Identificador del grado
     * @return Cantidad de cursos en el grado
     */
    public int contarPorGrado(int gradoId) {
        String sql = "SELECT COUNT(*) as total FROM curso WHERE grado_id = ? AND activo = 1";

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, gradoId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt("total");
            }

        } catch (SQLException e) {
            System.err.println("Error al contar cursos por grado: " + e.getMessage());
            e.printStackTrace();
        }

        return 0;
    }

    /**
     * OBTENER TOTAL DE CURSOS ACTIVOS
     * 
     * @return Cantidad total de cursos activos
     */
    public int contarTotal() {
        String sql = "SELECT COUNT(*) as total FROM curso WHERE activo = 1";

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt("total");
            }

        } catch (SQLException e) {
            System.err.println("Error al contar total de cursos: " + e.getMessage());
            e.printStackTrace();
        }

        return 0;
    }

    /**
     * CAMBIAR PROFESOR ASIGNADO A UN CURSO
     * 
     * @param cursoId Identificador del curso
     * @param nuevoProfesorId Identificador del nuevo profesor
     * @return true si el cambio fue exitoso
     */
    public boolean cambiarProfesor(int cursoId, int nuevoProfesorId) {
        String sql = "UPDATE curso SET profesor_id = ? WHERE id = ?";

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, nuevoProfesorId);
            ps.setInt(2, cursoId);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("Error al cambiar profesor del curso: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * MÉTODO AUXILIAR: Mapear ResultSet a Curso (básico)
     * 
     * @param rs ResultSet con los datos
     * @return Objeto Curso mapeado
     * @throws SQLException si hay error al leer
     */
    private Curso mapearResultSet(ResultSet rs) throws SQLException {
        Curso c = new Curso();
        c.setId(rs.getInt("id"));
        c.setNombre(rs.getString("nombre"));
        c.setGradoId(rs.getInt("grado_id"));
        c.setProfesorId(rs.getInt("profesor_id"));
        
        try {
            c.setCreditos(rs.getInt("creditos"));
            c.setGradoNombre(rs.getString("grado_nombre"));
            c.setProfesorNombre(rs.getString("profesor_nombre"));
            c.setArea(rs.getString("area"));
            c.setActivo(rs.getBoolean("activo"));
        } catch (SQLException e) {
            // Campos opcionales pueden no existir
        }
        
        return c;
    }

    /**
     * MÉTODO AUXILIAR: Mapear ResultSet a Curso (completo)
     * 
     * @param rs ResultSet con los datos
     * @return Objeto Curso mapeado
     * @throws SQLException si hay error al leer
     */
    private Curso mapearResultSetCompleto(ResultSet rs) throws SQLException {
        Curso c = new Curso();
        c.setId(rs.getInt("id"));
        c.setNombre(rs.getString("nombre"));
        c.setGradoId(rs.getInt("grado_id"));
        c.setProfesorId(rs.getInt("profesor_id"));
        c.setCreditos(rs.getInt("creditos"));
        
        try {
            c.setArea(rs.getString("area"));
            c.setActivo(rs.getBoolean("activo"));
            c.setGradoNombre(rs.getString("grado_nombre"));
            c.setProfesorNombre(rs.getString("profesor_nombre"));
            c.setNivel(rs.getString("nivel"));
        } catch (SQLException e) {
            // Campos opcionales pueden no existir
        }
        
        return c;
    }
}