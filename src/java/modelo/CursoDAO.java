package modelo;

import conexion.Conexion;
import java.sql.*;
import java.util.*;

/**
 * DAO PARA GESTIÓN DE CURSOS ACADÉMICOS
 * 
 * Funcionalidades:
 * - CRUD completo de cursos usando vista vista_cursos_activos
 * - Consultas por grado, profesor y nivel
 * - Integración con stored procedures para operaciones de escritura
 * - Consultas estadísticas y reportes
 * - Validación de datos
 */
public class CursoDAO {

    /**
     * LISTAR TODOS LOS CURSOS ACTIVOS
     * Usa la vista vista_cursos_activos
     * 
     * @return Lista completa de cursos activos
     */
    public List<Curso> listar() {
        List<Curso> lista = new ArrayList<>();
        // CORREGIDO: Eliminada referencia a 'ciclo' que no existe en la BD
        String sql = "SELECT * FROM vista_cursos_activos ORDER BY grado_nombre, nombre";

        try (Connection con = Conexion.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql); 
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Curso c = mapearDesdeVista(rs);
                lista.add(c);
            }

            System.out.println("Cursos encontrados en vista: " + lista.size());

        } catch (SQLException e) {
            System.err.println("Error al listar cursos desde vista: " + e.getMessage());
            e.printStackTrace();
        }

        return lista;
    }

    /**
     * LISTAR CURSOS ASIGNADOS A PROFESOR ESPECÍFICO
     * 
     * @param profesorId Identificador del profesor
     * @return Lista de cursos asignados al profesor
     */
    public List<Curso> listarPorProfesor(int profesorId) {
        List<Curso> lista = new ArrayList<>();
        
        // Primero obtener el nombre del profesor
        String profesorNombre = obtenerNombreProfesorPorId(profesorId);
        if (profesorNombre == null) {
            return lista;
        }
        
        // CORREGIDO: Eliminada referencia a 'ciclo'
        String sql = "SELECT * FROM vista_cursos_activos WHERE profesor_principal = ? ORDER BY nombre";

        try (Connection con = Conexion.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, profesorNombre);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Curso c = mapearDesdeVista(rs);
                lista.add(c);
                
                System.out.println("Curso encontrado para profesor " + profesorId + ": " + c.getNombre());
            }

            System.out.println("Total cursos encontrados para profesor " + profesorId + ": " + lista.size());

        } catch (SQLException e) {
            System.err.println("Error en listarPorProfesor desde vista:");
            System.err.println("   Código: " + e.getErrorCode());
            System.err.println("   Estado: " + e.getSQLState());
            System.err.println("   Mensaje: " + e.getMessage());
            e.printStackTrace();
        }

        return lista;
    }

    /**
 * LISTAR CURSOS POR GRADO (para padres/alumnos)
 */
public List<Curso> listarPorGrado(int gradoId) {
    List<Curso> lista = new ArrayList<>();
    
    String sql = "SELECT c.*, " +
                 "g.nombre as grado_nombre, " +
                 "a.nombre as area_nombre, " +
                 "CONCAT(p.nombres, ' ', p.apellidos) as profesor_nombre " +
                 "FROM curso c " +
                 "LEFT JOIN grado g ON c.grado_id = g.id " +
                 "LEFT JOIN area a ON c.area_id = a.id " +
                 "LEFT JOIN profesor prof ON c.profesor_id = prof.id " +
                 "LEFT JOIN persona p ON prof.persona_id = p.id " +
                 "WHERE c.grado_id = ? " +
                 "AND c.activo = 1 " +
                 "AND c.eliminado = 0 " +
                 "ORDER BY c.nombre";
    
    try (Connection con = Conexion.getConnection();
         PreparedStatement ps = con.prepareStatement(sql)) {
        
        ps.setInt(1, gradoId);
        ResultSet rs = ps.executeQuery();
        
        while (rs.next()) {
            Curso c = new Curso();
            c.setId(rs.getInt("id"));
            c.setNombre(rs.getString("nombre"));
            c.setGradoId(rs.getInt("grado_id"));
            c.setGradoNombre(rs.getString("grado_nombre"));
            c.setProfesorId(rs.getInt("profesor_id"));
            c.setProfesorNombre(rs.getString("profesor_nombre"));
            c.setCreditos(rs.getInt("creditos"));
            c.setHorasSemanales(rs.getInt("horas_semanales"));
            c.setArea(rs.getString("area_nombre"));
            c.setDescripcion(rs.getString("descripcion"));
            // CORREGIDO: No intentamos obtener 'ciclo'
            c.setFechaInicio(rs.getDate("fecha_inicio"));
            c.setFechaFin(rs.getDate("fecha_fin"));
            
            lista.add(c);
        }
        
        System.out.println("✅ Cursos encontrados para grado " + gradoId + ": " + lista.size());
        
    } catch (SQLException e) {
        System.err.println("❌ ERROR en listarPorGrado: " + e.getMessage());
        e.printStackTrace();
    }
    
    return lista;
}
    /**
     * MAPEAR CURSO DESDE LA VISTA
     */
    private Curso mapearDesdeVista(ResultSet rs) throws SQLException {
        Curso c = new Curso();
        c.setId(rs.getInt("id"));
        c.setNombre(rs.getString("nombre"));
        c.setCreditos(rs.getInt("creditos"));
        c.setHorasSemanales(rs.getInt("horas_semanales"));
        //c.setArea(rs.getString("area"));
        c.setGradoNombre(rs.getString("grado_nombre"));
        c.setNivel(rs.getString("nivel"));
        c.setProfesorNombre(rs.getString("profesor_principal"));
        
        // Fechas - CORREGIDO: Usar directamente rs.getDate()
        // rs.getDate() ya devuelve java.sql.Date, que es compatible con Curso
        c.setFechaInicio(rs.getDate("fecha_inicio"));
        c.setFechaFin(rs.getDate("fecha_fin"));
        
        // Estadísticas
        c.setTotalProfesores(rs.getInt("total_profesores"));
        c.setTotalHorarios(rs.getInt("total_horarios"));
        c.setCantidadAlumnos(rs.getInt("cantidad_alumnos"));
        c.setCantidadTareas(rs.getInt("cantidad_tareas"));
        
        return c;
    }

    /**
     * OBTENER UN CURSO POR ID
     * 
     * @param id Identificador del curso
     * @return Objeto Curso o null si no existe
     */
    public Curso obtenerPorId(int id) {
        String sql = "SELECT * FROM vista_cursos_activos WHERE id = ?";
        
        try (Connection con = Conexion.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return mapearDesdeVista(rs);
            }
            
        } catch (SQLException e) {
            System.err.println("Error al obtener curso por ID desde vista: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }

    /**
     * LISTAR CURSOS POR NIVEL EDUCATIVO
     * 
     * @param nivel Nivel educativo (INICIAL, PRIMARIA, SECUNDARIA)
     * @return Lista de cursos del nivel especificado
     */
    public List<Curso> listarPorNivel(String nivel) {
        List<Curso> lista = new ArrayList<>();
        String sql = "SELECT * FROM vista_cursos_activos WHERE nivel = ? ORDER BY grado_nombre, nombre";

        try (Connection con = Conexion.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, nivel);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Curso c = mapearDesdeVista(rs);
                lista.add(c);
            }

            System.out.println("Cursos encontrados para nivel " + nivel + ": " + lista.size());

        } catch (SQLException e) {
            System.err.println("Error al listar cursos por nivel desde vista: " + e.getMessage());
            e.printStackTrace();
        }

        return lista;
    }

    /**
     * BUSCAR CURSOS POR NOMBRE
     * 
     * @param termino Término de búsqueda
     * @return Lista de cursos que coinciden con el término
     */
    public List<Curso> buscarPorNombre(String termino) {
        List<Curso> lista = new ArrayList<>();
        String sql = "SELECT * FROM vista_cursos_activos WHERE nombre LIKE ? ORDER BY nombre";

        try (Connection con = Conexion.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, "%" + termino + "%");
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Curso c = mapearDesdeVista(rs);
                lista.add(c);
            }

        } catch (SQLException e) {
            System.err.println("Error al buscar cursos por nombre: " + e.getMessage());
            e.printStackTrace();
        }

        return lista;
    }

    /**
     * REGISTRAR CURSO COMPLETO (usando stored procedure)
     * 
     * @param nombre Nombre del curso
     * @param gradoId ID del grado
     * @param profesorId ID del profesor principal
     * @param turnoId ID del turno
     * @param descripcion Descripción del curso
     * @param areaNombre Nombre del área curricular
     * @param horariosJson JSON con los horarios
     * @return Resultado de la operación
     */
    public Map<String, Object> registrarCursoCompleto(
            String nombre, 
            int gradoId, 
            int profesorId, 
            int turnoId, 
            String descripcion, 
            String areaNombre, 
            String horariosJson) {
        
        Map<String, Object> resultado = new HashMap<>();
        
        try (Connection con = Conexion.getConnection(); 
             CallableStatement cs = con.prepareCall("{CALL registrar_curso_completo(?, ?, ?, ?, ?, ?, ?)}")) {
            
            cs.setString(1, nombre);
            cs.setInt(2, gradoId);
            cs.setInt(3, profesorId);
            cs.setInt(4, turnoId);
            cs.setString(5, descripcion);
            cs.setString(6, areaNombre);
            cs.setString(7, horariosJson);
            
            ResultSet rs = cs.executeQuery();
            
            if (rs.next()) {
                resultado.put("exito", rs.getInt("exito") == 1);
                resultado.put("mensaje", rs.getString("mensaje"));
                if (rs.getMetaData().getColumnCount() > 2) {
                    resultado.put("detalle", rs.getString("detalle"));
                }
            }
            
            System.out.println("Resultado registro curso: " + resultado);
            
        } catch (SQLException e) {
            System.err.println("Error al registrar curso completo: " + e.getMessage());
            e.printStackTrace();
            resultado.put("exito", false);
            resultado.put("mensaje", "Error en la base de datos: " + e.getMessage());
        }
        
        return resultado;
    }

    /**
     * ACTUALIZAR CURSO COMPLETO (usando stored procedure)
     * 
     * @param cursoId ID del curso a actualizar
     * @param nombre Nuevo nombre del curso
     * @param gradoId Nuevo ID del grado
     * @param profesorId Nuevo ID del profesor
     * @param turnoId Nuevo ID del turno
     * @param descripcion Nueva descripción
     * @param areaNombre Nuevo nombre del área
     * @param horariosJson Nuevos horarios en JSON
     * @return Resultado de la operación
     */
    public Map<String, Object> actualizarCursoCompleto(
            int cursoId,
            String nombre, 
            int gradoId, 
            int profesorId, 
            int turnoId, 
            String descripcion, 
            String areaNombre, 
            String horariosJson) {
        
        Map<String, Object> resultado = new HashMap<>();
        
        try (Connection con = Conexion.getConnection(); 
             CallableStatement cs = con.prepareCall("{CALL actualizar_curso_completo(?, ?, ?, ?, ?, ?, ?, ?)}")) {
            
            cs.setInt(1, cursoId);
            cs.setString(2, nombre);
            cs.setInt(3, gradoId);
            cs.setInt(4, profesorId);
            cs.setInt(5, turnoId);
            cs.setString(6, descripcion);
            cs.setString(7, areaNombre);
            cs.setString(8, horariosJson);
            
            ResultSet rs = cs.executeQuery();
            
            if (rs.next()) {
                resultado.put("exito", rs.getInt("exito") == 1);
                resultado.put("mensaje", rs.getString("mensaje"));
            }
            
            System.out.println("Resultado actualización curso: " + resultado);
            
        } catch (SQLException e) {
            System.err.println("Error al actualizar curso completo: " + e.getMessage());
            e.printStackTrace();
            resultado.put("exito", false);
            resultado.put("mensaje", "Error en la base de datos: " + e.getMessage());
        }
        
        return resultado;
    }

    /**
     * ELIMINAR CURSO (eliminación lógica)
     * 
     * @param id Identificador del curso
     * @return true si se eliminó correctamente
     */
    public boolean eliminar(int id) {
        String sql = "UPDATE curso SET eliminado = 1, activo = 0 WHERE id = ?";

        try (Connection con = Conexion.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            int filasAfectadas = ps.executeUpdate();

            System.out.println("Curso eliminado (ID: " + id + "): " + (filasAfectadas > 0));
            return filasAfectadas > 0;

        } catch (SQLException e) {
            System.err.println("Error al eliminar curso: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    /**
     * AGREGAR NUEVO CURSO
     * 
     * @param c Objeto Curso con los datos
     * @return ID del curso creado, o -1 si falla
     */
    public int agregar(Curso c) {
        String sql = "INSERT INTO curso (nombre, grado_id, profesor_id, creditos, " +
                    "horas_semanales, area_id, descripcion, fecha_inicio, fecha_fin, activo, eliminado) " +
                    "VALUES (?, ?, ?, ?, 0, " +
                    "(SELECT id FROM area WHERE nombre = ? AND activo = 1 AND eliminado = 0 LIMIT 1), " +
                    "?, CURDATE(), NULL, 1, 0)";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, c.getNombre());
            ps.setInt(2, c.getGradoId());
            ps.setInt(3, c.getProfesorId());
            ps.setInt(4, c.getCreditos());
            ps.setString(5, c.getArea());
            ps.setString(6, c.getDescripcion());

            int filasAfectadas = ps.executeUpdate();
            
            if (filasAfectadas > 0) {
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    int idGenerado = rs.getInt(1);
                    System.out.println("Curso creado con ID: " + idGenerado);
                    return idGenerado;
                }
            }

        } catch (SQLException e) {
            System.err.println("Error al agregar curso: " + e.getMessage());
            e.printStackTrace();
        }
        
        return -1;
    }

    /**
     * ACTUALIZAR DATOS DE CURSO EXISTENTE
     * 
     * @param c Objeto Curso con los datos actualizados
     * @return true si la actualización fue exitosa
     */
    public boolean actualizar(Curso c) {
        String sql = "UPDATE curso SET " +
                     "nombre = ?, " +
                     "grado_id = ?, " +
                     "profesor_id = ?, " +
                     "creditos = ?, " +
                     "area_id = (SELECT id FROM area WHERE nombre = ? AND activo = 1 AND eliminado = 0 LIMIT 1), " +
                     "descripcion = ? " +
                     "WHERE id = ? AND eliminado = 0";
        
        try (Connection conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, c.getNombre());
            ps.setInt(2, c.getGradoId());
            ps.setInt(3, c.getProfesorId());
            ps.setInt(4, c.getCreditos());
            ps.setString(5, c.getArea());
            ps.setString(6, c.getDescripcion());
            ps.setInt(7, c.getId());
            
            int filasActualizadas = ps.executeUpdate();
            
            if (filasActualizadas > 0) {
                System.out.println("Curso actualizado correctamente: ID " + c.getId());
                return true;
            } else {
                System.err.println("No se pudo actualizar el curso ID " + c.getId());
                return false;
            }
            
        } catch (SQLException e) {
            System.err.println("Error al actualizar curso: " + e.getMessage());
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
        String sql = "SELECT COUNT(*) as total FROM curso " +
                     "WHERE id = ? AND profesor_id = ? AND activo = 1 AND eliminado = 0";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, cursoId);
            ps.setInt(2, profesorId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("total") > 0;
            }
            
        } catch (SQLException e) {
            System.err.println("Error al verificar asignación de curso: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }

    /**
     * ACTIVAR/DESACTIVAR CURSO
     * 
     * @param id Identificador del curso
     * @param activo Estado deseado
     * @return true si se actualizó correctamente
     */
    public boolean cambiarEstado(int id, boolean activo) {
        String sql = "UPDATE curso SET activo = ? WHERE id = ? AND eliminado = 0";

        try (Connection con = Conexion.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setBoolean(1, activo);
            ps.setInt(2, id);
            int filasAfectadas = ps.executeUpdate();

            System.out.println("Estado cambiado para curso " + id + ": " + activo);
            return filasAfectadas > 0;

        } catch (SQLException e) {
            System.err.println("Error al cambiar estado del curso: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    /**
     * OBTENER ESTADÍSTICAS DE UN CURSO
     * 
     * @param cursoId Identificador del curso
     * @return Mapa con estadísticas del curso
     */
    public Map<String, Integer> obtenerEstadisticas(int cursoId) {
        Map<String, Integer> stats = new HashMap<>();
        
        String sql = "SELECT " +
                    "(SELECT COUNT(*) FROM curso_profesor WHERE curso_id = ? AND activo = 1 AND eliminado = 0) as profesores, " +
                    "(SELECT COUNT(*) FROM horario_clase WHERE curso_id = ? AND activo = 1 AND eliminado = 0) as horarios, " +
                    "(SELECT COUNT(*) FROM tarea WHERE curso_id = ? AND activo = 1 AND eliminado = 0) as tareas, " +
                    "(SELECT COUNT(DISTINCT a.id) FROM alumno a " +
                    " INNER JOIN grado g ON a.grado_id = g.id " +
                    " INNER JOIN curso c ON c.grado_id = g.id " +
                    " WHERE c.id = ? AND a.activo = 1 AND a.eliminado = 0) as alumnos";

        try (Connection con = Conexion.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, cursoId);
            ps.setInt(2, cursoId);
            ps.setInt(3, cursoId);
            ps.setInt(4, cursoId);
            
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                stats.put("profesores", rs.getInt("profesores"));
                stats.put("horarios", rs.getInt("horarios"));
                stats.put("tareas", rs.getInt("tareas"));
                stats.put("alumnos", rs.getInt("alumnos"));
            }

        } catch (SQLException e) {
            System.err.println("Error al obtener estadísticas del curso: " + e.getMessage());
            e.printStackTrace();
        }

        return stats;
    }

    /**
     * OBTENER NOMBRE DE PROFESOR POR ID
     */
    private String obtenerNombreProfesorPorId(int profesorId) {
        String sql = "SELECT CONCAT(p.nombres, ' ', p.apellidos) as nombre_completo " +
                    "FROM profesor pr " +
                    "INNER JOIN persona p ON pr.persona_id = p.id " +
                    "WHERE pr.id = ? AND pr.activo = 1 AND pr.eliminado = 0";
        
        try (Connection con = Conexion.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, profesorId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getString("nombre_completo");
            }
            
        } catch (SQLException e) {
            System.err.println("Error al obtener nombre de profesor: " + e.getMessage());
        }
        
        return null;
    }

    /**
     * OBTENER NOMBRE DE GRADO POR ID
     */
    private String obtenerNombreGradoPorId(int gradoId) {
        String sql = "SELECT nombre FROM grado WHERE id = ? AND activo = 1 AND eliminado = 0";
        
        try (Connection con = Conexion.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, gradoId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getString("nombre");
            }
            
        } catch (SQLException e) {
            System.err.println("Error al obtener nombre de grado: " + e.getMessage());
        }
        
        return null;
    }

    /**
     * VERIFICAR SI UN CURSO TIENE TAREAS ASOCIADAS
     * 
     * @param cursoId Identificador del curso
     * @return true si el curso tiene tareas activas
     */
    public boolean tieneTareas(int cursoId) {
        String sql = "SELECT COUNT(*) as total FROM tarea WHERE curso_id = ? AND activo = 1 AND eliminado = 0";

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, cursoId);
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
     * VERIFICAR SI UN CURSO TIENE HORARIOS ASOCIADOS
     * 
     * @param cursoId Identificador del curso
     * @return true si el curso tiene horarios activos
     */
    public boolean tieneHorarios(int cursoId) {
        String sql = "SELECT COUNT(*) as total FROM horario_clase WHERE curso_id = ? AND activo = 1 AND eliminado = 0";

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, cursoId);
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
 * LISTAR CURSOS DE UN ALUMNO ESPECÍFICO
 * Obtiene todos los cursos del grado en el que está inscrito el alumno
 */
public List<Curso> listarPorAlumno(int alumnoId) {
    List<Curso> cursos = new ArrayList<>();
    
    // Primero obtenemos el grado_id del alumno
    String sqlGrado = "SELECT grado_id FROM alumno WHERE id = ? AND activo = 1 AND eliminado = 0";
    
    String sqlCursos = "SELECT " +
                      "    c.id, " +
                      "    c.nombre, " +
                      "    c.descripcion, " +
                      "    c.grado_id, " +
                      "    g.nombre as grado_nombre, " +
                      "    c.profesor_id, " +
                      "    CONCAT(p.nombres, ' ', p.apellidos) as profesor_nombre " +
                      "FROM curso c " +
                      "INNER JOIN grado g ON c.grado_id = g.id " +
                      "LEFT JOIN profesor pr ON c.profesor_id = pr.id " +
                      "LEFT JOIN persona p ON pr.persona_id = p.id " +
                      "WHERE c.grado_id = ? " +
                      "AND c.activo = 1 " +
                      "AND c.eliminado = 0 " +
                      "ORDER BY c.nombre";
    
    try (Connection con = Conexion.getConnection()) {
        
        // Obtener grado_id del alumno
        int gradoId = 0;
        try (PreparedStatement psGrado = con.prepareStatement(sqlGrado)) {
            psGrado.setInt(1, alumnoId);
            ResultSet rsGrado = psGrado.executeQuery();
            
            if (rsGrado.next()) {
                gradoId = rsGrado.getInt("grado_id");
            } else {
                System.out.println("⚠️ No se encontró el alumno con ID: " + alumnoId);
                return cursos; // Lista vacía
            }
        }
        
        // Obtener cursos del grado
        try (PreparedStatement psCursos = con.prepareStatement(sqlCursos)) {
            psCursos.setInt(1, gradoId);
            ResultSet rs = psCursos.executeQuery();
            
            while (rs.next()) {
                Curso curso = new Curso();
                curso.setId(rs.getInt("id"));
                curso.setNombre(rs.getString("nombre"));
                curso.setDescripcion(rs.getString("descripcion"));
                curso.setGradoId(rs.getInt("grado_id"));
                curso.setGradoNombre(rs.getString("grado_nombre"));
                curso.setProfesorId(rs.getInt("profesor_id"));
                curso.setProfesorNombre(rs.getString("profesor_nombre"));
                
                cursos.add(curso);
            }
            
            System.out.println("Cursos encontrados para alumno " + alumnoId + ": " + cursos.size());
        }
        
    } catch (SQLException e) {
        System.err.println("ERROR en listarPorAlumno: " + e.getMessage());
        e.printStackTrace();
    }
    
    return cursos;
}

    public List<Map<String, Object>> obtenerHorariosPorCurso(int cursoId) {
           List<Map<String, Object>> horarios = new ArrayList<>();
           String sql = "SELECT h.id, h.dia_semana, " +
                        "TIME_FORMAT(h.hora_inicio, '%H:%i') AS hora_inicio, " +
                        "TIME_FORMAT(h.hora_fin, '%H:%i') AS hora_fin, " +
                        "h.turno_id, t.nombre AS turno_nombre, " +
                        "a.id AS aula_id, a.nombre AS aula_nombre " +
                        "FROM horario_clase h " +
                        "INNER JOIN turno t ON h.turno_id = t.id " +
                        "LEFT JOIN aula a ON h.aula_id = a.id " +
                        "WHERE h.curso_id = ? AND h.eliminado = 0 AND h.activo = 1 " +
                        "ORDER BY FIELD(h.dia_semana, 'LUNES','MARTES','MIERCOLES','JUEVES','VIERNES','SABADO'), " +
                        "h.hora_inicio";

           try (Connection conn = Conexion.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

               ps.setInt(1, cursoId);
               ResultSet rs = ps.executeQuery();

               while (rs.next()) {
                   Map<String, Object> horario = new HashMap<>();
                   horario.put("id", rs.getInt("id"));
                   horario.put("dia_semana", rs.getString("dia_semana"));
                   horario.put("hora_inicio", rs.getString("hora_inicio"));
                   horario.put("hora_fin", rs.getString("hora_fin"));
                   horario.put("turno_id", rs.getInt("turno_id"));
                   horario.put("turno_nombre", rs.getString("turno_nombre"));
                   horario.put("aula_id", rs.getInt("aula_id"));
                   horario.put("aula_nombre", rs.getString("aula_nombre"));
                   horarios.add(horario);
               }

               System.out.println("Horarios obtenidos para curso " + cursoId + ": " + horarios.size());

           } catch (SQLException e) {
               System.err.println("Error al obtener horarios del curso: " + e.getMessage());
               e.printStackTrace();
           }

           return horarios;
       }
    
            public boolean actualizarConHorarios(Curso c, String horariosJson) {
            Connection conn = null;

            try {
                conn = Conexion.getConnection();
                conn.setAutoCommit(false);

                // 1. Actualizar datos del curso
                String sqlCurso = "UPDATE curso SET nombre = ?, grado_id = ?, profesor_id = ?, " +
                                 "creditos = ?, area_id = (SELECT id FROM area WHERE nombre = ? LIMIT 1), descripcion = ? WHERE id = ?";
                PreparedStatement psCurso = conn.prepareStatement(sqlCurso);
                psCurso.setString(1, c.getNombre());
                psCurso.setInt(2, c.getGradoId());
                psCurso.setInt(3, c.getProfesorId());
                psCurso.setInt(4, c.getCreditos());
                psCurso.setString(5, c.getArea());
                psCurso.setString(6, c.getDescripcion());
                psCurso.setInt(7, c.getId());
                psCurso.executeUpdate();
                psCurso.close();

                // 2. Marcar horarios antiguos como eliminados
                String sqlEliminar = "UPDATE horario_clase SET eliminado = 1, activo = 0 WHERE curso_id = ?";
                PreparedStatement psEliminar = conn.prepareStatement(sqlEliminar);
                psEliminar.setInt(1, c.getId());
                psEliminar.executeUpdate();
                psEliminar.close();

                // 3. Insertar nuevos horarios (procesar JSON si lo pasas)
                // ... aquí procesarías el JSON de horarios ...

                conn.commit();
                System.out.println("Curso y horarios actualizados: ID " + c.getId());
                return true;

            } catch (SQLException e) {
                System.err.println("Error al actualizar curso con horarios: " + e.getMessage());
                e.printStackTrace();

                if (conn != null) {
                    try {
                        conn.rollback();
                    } catch (SQLException ex) {
                        ex.printStackTrace();
                    }
                }
                return false;

            } finally {
                if (conn != null) {
                    try {
                        conn.setAutoCommit(true);
                        conn.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                }
            }
        }
            
            public List<Curso> listarConFiltros(Integer gradoId, String nivel, String turno) {
            List<Curso> lista = new ArrayList<>();
            StringBuilder sql = new StringBuilder(
                "SELECT c.*, " +
                "g.nombre as grado_nombre, " +
                "g.nivel as nivel_nombre, " +
                "CONCAT(p.nombres, ' ', p.apellidos) as profesor_nombre, " +
                "a.nombre as area_nombre " +
                "FROM curso c " +
                "LEFT JOIN grado g ON c.grado_id = g.id " +
                "LEFT JOIN profesor prof ON c.profesor_id = prof.id " +
                "LEFT JOIN persona p ON prof.persona_id = p.id " +
                "LEFT JOIN area a ON c.area_id = a.id " +
                "WHERE c.eliminado = 0 AND c.activo = 1"
            );

            // Agregar filtros dinámicamente
            if (nivel != null && !nivel.isEmpty()) {
                sql.append(" AND g.nivel = ?");
            }

            if (turno != null && !turno.isEmpty()) {
                sql.append(" AND EXISTS (SELECT 1 FROM horario_clase hc " +
                          "INNER JOIN turno t ON hc.turno_id = t.id " +
                          "WHERE hc.curso_id = c.id AND t.nombre = ? AND hc.eliminado = 0)");
            }

            if (gradoId != null) {
                sql.append(" AND c.grado_id = ?");
            }

            sql.append(" ORDER BY g.nivel, g.nombre, c.nombre");

            try (Connection conn = Conexion.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql.toString())) {

                int paramIndex = 1;

                if (nivel != null && !nivel.isEmpty()) {
                    ps.setString(paramIndex++, nivel);
                }

                if (turno != null && !turno.isEmpty()) {
                    ps.setString(paramIndex++, turno);
                }

                if (gradoId != null) {
                    ps.setInt(paramIndex++, gradoId);
                }

                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    //  MAPEAR RESULTADOS A OBJETO CURSO
                    Curso c = new Curso();
                    c.setId(rs.getInt("id"));
                    c.setNombre(rs.getString("nombre"));
                    c.setGradoId(rs.getInt("grado_id"));
                    c.setGradoNombre(rs.getString("grado_nombre"));
                    c.setNivel(rs.getString("nivel_nombre"));
                    c.setProfesorId(rs.getInt("profesor_id"));
                    c.setProfesorNombre(rs.getString("profesor_nombre"));
                    c.setCreditos(rs.getInt("creditos"));
                    c.setHorasSemanales(rs.getInt("horas_semanales"));
                    c.setArea(rs.getString("area_nombre"));
                    c.setDescripcion(rs.getString("descripcion"));
                    c.setFechaInicio(rs.getDate("fecha_inicio"));
                    c.setFechaFin(rs.getDate("fecha_fin"));

                    lista.add(c);
                }

                System.out.println(" Filtros aplicados - Cursos encontrados: " + lista.size());

            } catch (SQLException e) {
                System.err.println(" Error en listarConFiltros: " + e.getMessage());
                e.printStackTrace();
            }

            return lista;
        }
}