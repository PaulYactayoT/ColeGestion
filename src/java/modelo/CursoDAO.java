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
        String sql = "SELECT * FROM vista_cursos_activos ORDER BY ciclo, grado_nombre, nombre";

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
        
        String sql = "SELECT * FROM vista_cursos_activos WHERE profesor_principal = ? ORDER BY ciclo, nombre";

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
     * LISTAR CURSOS POR GRADO ACADÉMICO
     * 
     * @param gradoId Identificador del grado
     * @return Lista de cursos del grado especificado
     */
    /*public List<Curso> listarPorGrado(int gradoId) {
        List<Curso> lista = new ArrayList<>();
        
        // Primero obtener el nombre del grado
        String gradoNombre = obtenerNombreGradoPorId(gradoId);
        if (gradoNombre == null) {
            return lista;
        }
        
        String sql = "SELECT * FROM vista_cursos_activos WHERE grado_nombre = ? ORDER BY ciclo, nombre";

        try (Connection con = Conexion.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, gradoNombre);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Curso c = mapearDesdeVista(rs);
                lista.add(c);
            }
            
            System.out.println("Cursos encontrados para grado " + gradoId + ": " + lista.size());
            
        } catch (SQLException e) {
            System.err.println("Error al listar cursos por grado desde vista: " + e.getMessage());
            e.printStackTrace();
        }

        return lista;
    }
*/
    /**
 * LISTAR CURSOS POR GRADO (para padres/alumnos)
 */
public List<Curso> listarPorGrado(int gradoId) {
    List<Curso> lista = new ArrayList<>();
    
    String sql = "SELECT c.*, " +
                 "g.nombre as grado_nombre, " +
                 "CONCAT(p.nombres, ' ', p.apellidos) as profesor_nombre " +
                 "FROM curso c " +
                 "LEFT JOIN grado g ON c.grado_id = g.id " +
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
            c.setArea(rs.getString("area"));
            c.setDescripcion(rs.getString("descripcion"));
            c.setCiclo(rs.getString("ciclo"));
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
        c.setArea(rs.getString("area"));
        c.setCiclo(rs.getString("ciclo"));
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
        
        // Obtener IDs adicionales
        int gradoId = obtenerGradoIdPorNombre(rs.getString("grado_nombre"));
        c.setGradoId(gradoId);
        
        int profesorId = obtenerProfesorIdPorNombre(rs.getString("profesor_principal"));
        c.setProfesorId(profesorId);
        
        return c;
    }

    /**
     * OBTENER CURSO COMPLETO POR ID (desde tabla curso, no vista)
     * Incluye el campo descripción que no está en la vista
     * 
     * @param id Identificador único del curso
     * @return Objeto Curso completo o null si no existe
     */
        public Curso obtenerCursoCompletoPorId(int id) {
            Curso curso = null;
            String sql = "SELECT c.id, c.nombre, c.grado_id, c.profesor_id, " +
                         "c.creditos, c.area, c.descripcion, c.activo, " +
                         "g.nombre AS grado_nombre, " +
                         "CONCAT(p.nombres, ' ', p.apellidos) AS profesor_nombre " +
                         "FROM curso c " +
                         "INNER JOIN grado g ON c.grado_id = g.id " +
                         "LEFT JOIN profesor prof ON c.profesor_id = prof.id " +
                         "LEFT JOIN persona p ON prof.persona_id = p.id " +
                         "WHERE c.id = ? AND c.eliminado = 0";

            try (Connection conn = Conexion.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {

                ps.setInt(1, id);
                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    curso = new Curso();
                    curso.setId(rs.getInt("id"));
                    curso.setNombre(rs.getString("nombre"));
                    curso.setGradoId(rs.getInt("grado_id"));
                    curso.setProfesorId(rs.getInt("profesor_id"));
                    curso.setCreditos(rs.getInt("creditos"));
                    curso.setArea(rs.getString("area"));
                    curso.setDescripcion(rs.getString("descripcion"));
                    curso.setGradoNombre(rs.getString("grado_nombre"));
                    curso.setProfesorNombre(rs.getString("profesor_nombre"));

                    System.out.println("✅ Curso obtenido para edición: " + curso.getNombre());
                    System.out.println("   ID: " + curso.getId());
                    System.out.println("   Grado: " + curso.getGradoNombre());
                    System.out.println("   Profesor: " + curso.getProfesorNombre());
                    System.out.println("   Área: " + curso.getArea());

                } else {
                    System.err.println("No se encontró curso con ID: " + id);
                }

            } catch (SQLException e) {
                System.err.println("Error al obtener curso completo: " + e.getMessage());
                e.printStackTrace();
            }

            return curso;
        }

    /**
     * OBTENER NOMBRE DE PROFESOR POR ID
     */
    private String obtenerNombreProfesorPorId(int profesorId) {
        String sql = "SELECT CONCAT(p.nombres, ' ', p.apellidos) as nombre_completo " +
                     "FROM profesor prof " +
                     "JOIN persona p ON prof.persona_id = p.id " +
                     "WHERE prof.id = ? AND prof.activo = 1 AND prof.eliminado = 0";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, profesorId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getString("nombre_completo");
            }
            
        } catch (Exception e) {
            System.err.println("Error al obtener nombre de profesor: " + e.getMessage());
        }
        
        return null;
    }

    /**
     * OBTENER ID DE PROFESOR POR NOMBRE
     */
    private int obtenerProfesorIdPorNombre(String profesorNombre) {
        if (profesorNombre == null || profesorNombre.isEmpty()) {
            return 0;
        }
        
        String sql = "SELECT prof.id FROM profesor prof " +
                     "JOIN persona p ON prof.persona_id = p.id " +
                     "WHERE CONCAT(p.nombres, ' ', p.apellidos) = ? " +
                     "AND prof.activo = 1 AND prof.eliminado = 0";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, profesorNombre);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("id");
            }
            
        } catch (Exception e) {
            System.err.println("Error al obtener ID de profesor: " + e.getMessage());
        }
        
        return 0;
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
            
        } catch (Exception e) {
            System.err.println("Error al obtener nombre de grado: " + e.getMessage());
        }
        
        return null;
    }

    /**
     * OBTENER ID DE GRADO POR NOMBRE
     */
    private int obtenerGradoIdPorNombre(String gradoNombre) {
        String sql = "SELECT id FROM grado WHERE nombre = ? AND activo = 1 AND eliminado = 0";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, gradoNombre);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("id");
            }
            
        } catch (Exception e) {
            System.err.println("Error al obtener ID de grado: " + e.getMessage());
        }
        
        return 0;
    }

    /**
     * OBTENER CURSO POR ID
     * Usa la vista vista_cursos_activos
     * 
     * @param id Identificador único del curso
     * @return Objeto Curso o null si no existe
     */
        public Curso obtenerPorId(int id) {
        String sql = "SELECT c.*, g.nombre as grado_nombre, g.nivel, " +
                     "CONCAT(p.nombres, ' ', p.apellidos) as profesor_nombre, " +
                     "(SELECT turno_id FROM horario_clase WHERE curso_id = c.id AND eliminado = 0 LIMIT 1) as turno_id " +
                     "FROM curso c " +
                     "INNER JOIN grado g ON c.grado_id = g.id " +
                     "LEFT JOIN profesor prof ON c.profesor_id = prof.id " +
                     "LEFT JOIN persona p ON prof.persona_id = p.id " +
                     "WHERE c.id = ? AND c.eliminado = 0";

        try (Connection con = Conexion.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Curso c = new Curso();
                c.setId(rs.getInt("id"));
                c.setNombre(rs.getString("nombre"));
                c.setGradoId(rs.getInt("grado_id"));
                c.setGradoNombre(rs.getString("grado_nombre"));
                c.setNivel(rs.getString("nivel"));
                c.setProfesorId(rs.getInt("profesor_id"));
                c.setProfesorNombre(rs.getString("profesor_nombre"));
                c.setCreditos(rs.getInt("creditos"));
                c.setArea(rs.getString("area"));
                c.setDescripcion(rs.getString("descripcion"));

                Integer turnoId = rs.getInt("turno_id");
                if (!rs.wasNull()) {
                    c.setTurnoId(turnoId);
                }

                System.out.println(" Curso obtenido: " + c.getNombre());
                System.out.println("   Turno ID: " + c.getTurnoId());

                return c;
            }

        } catch (SQLException e) {
            System.err.println(" Error al obtener curso por ID: " + e.getMessage());
            e.printStackTrace();
        }

        return null;
    }

    /**
     * @param c Objeto Curso con los datos
     * @return ID del curso creado, o -1 si falla
     */
    public int agregar(Curso c) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = Conexion.getConnection();
            
            // Usar stored procedure si existe, o consulta directa
            String sql = "{CALL crear_curso(?, ?, ?, ?, ?, ?, ?, ?, ?)}";
            
            ps = conn.prepareCall(sql);

            ps.setString(1, c.getNombre());
            ps.setInt(2, c.getGradoId());
            ps.setInt(3, c.getProfesorId());
            ps.setInt(4, c.getCreditos());
            ps.setInt(5, c.getHorasSemanales());
            ps.setString(6, c.getArea());
            ps.setString(7, c.getCiclo());
            ps.setDate(8, c.getFechaInicio());
            ps.setDate(9, c.getFechaFin());

            rs = ps.executeQuery();
            if (rs.next()) {
                int idGenerado = rs.getInt("id");
                System.out.println("Curso creado con ID: " + idGenerado);
                return idGenerado;
            }

        } catch (SQLException e) {
            System.err.println("Error al agregar curso: " + e.getMessage());
            e.printStackTrace();
            
            // Fallback: intentar con INSERT directo
            return agregarDirecto(c);
        } finally {
            cerrarRecursos(rs, ps, conn);
        }
        
        return -1;
    }

    /**
     * AGREGAR CURSO DIRECTO (fallback)
     */
    private int agregarDirecto(Curso c) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = Conexion.getConnection();
            
            String sql = "INSERT INTO curso (nombre, grado_id, profesor_id, creditos, " +
                        "horas_semanales, area, descripcion, ciclo, fecha_inicio, fecha_fin, activo, eliminado) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1, 0)";
            
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);

            ps.setString(1, c.getNombre());
            ps.setInt(2, c.getGradoId());
            ps.setInt(3, c.getProfesorId());
            ps.setInt(4, c.getCreditos());
            ps.setInt(5, c.getHorasSemanales());
            ps.setString(6, c.getArea());
            ps.setString(7, c.getDescripcion()); // NUEVO: descripción
            ps.setString(8, c.getCiclo());
            ps.setDate(9, c.getFechaInicio());
            ps.setDate(10, c.getFechaFin());

            int filasAfectadas = ps.executeUpdate();
            
            if (filasAfectadas > 0) {
                rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    int idGenerado = rs.getInt(1);
                    System.out.println("Curso creado (directo) con ID: " + idGenerado);
                    return idGenerado;
                }
            }

        } catch (SQLException e) {
            System.err.println("Error al agregar curso directo: " + e.getMessage());
            e.printStackTrace();
        } finally {
            cerrarRecursos(rs, ps, conn);
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
                     "area = ?, " +
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
     * ELIMINAR CURSO (ELIMINACIÓN LÓGICA)
     * 
     * @param id Identificador del curso a eliminar
     * @return true si la eliminación fue exitosa
     */
    public boolean eliminar(int cursoId) {
        String sql = "{CALL eliminar_curso_logico(?)}";
        
        try (Connection conn = Conexion.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            
            cs.setInt(1, cursoId);
            ResultSet rs = cs.executeQuery();
            
            if (rs.next()) {
                int exito = rs.getInt("resultado");
                String mensaje = rs.getString("mensaje");
                
                System.out.println("Resultado de eliminación:");
                System.out.println("  Éxito: " + (exito == 1 ? "SÍ" : "NO"));
                System.out.println("  Mensaje: " + mensaje);
                
                return exito == 1;
            }
            
            return false;
            
        } catch (SQLException e) {
            System.err.println("Error al eliminar curso ID " + cursoId);
            System.err.println("   Error SQL: " + e.getMessage());
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
        // Primero obtener el curso
        Curso curso = obtenerPorId(cursoId);
        if (curso == null) {
            return false;
        }
        
        // Comparar el profesor_id del curso con el profesorId proporcionado
        return curso.getProfesorId() == profesorId;
    }

    /**
     * VERIFICAR EXISTENCIA DE CURSO
     * 
     * @param cursoId Identificador del curso
     * @return true si el curso existe
     */
    public boolean existeCurso(int cursoId) {
        String sql = "SELECT COUNT(*) as count FROM curso WHERE id = ? AND activo = 1 AND eliminado = 0";
        
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
        String sql = "SELECT * FROM vista_cursos_activos WHERE nivel = ? ORDER BY ciclo, grado_nombre, nombre";

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, nivel.toUpperCase());
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
     * LISTAR CURSOS POR ÁREA
     * 
     * @param area Área curricular
     * @return Lista de cursos del área especificada
     */
    public List<Curso> listarPorArea(String area) {
        List<Curso> lista = new ArrayList<>();
        String sql = "SELECT * FROM vista_cursos_activos WHERE area = ? ORDER BY ciclo, grado_nombre, nombre";

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, area);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Curso c = mapearDesdeVista(rs);
                lista.add(c);
            }

            System.out.println("Cursos encontrados para área " + area + ": " + lista.size());

        } catch (SQLException e) {
            System.err.println("Error al listar cursos por área desde vista: " + e.getMessage());
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
        String sql = "SELECT * FROM vista_cursos_activos WHERE nombre LIKE ? ORDER BY nombre";

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, "%" + nombre + "%");
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Curso c = mapearDesdeVista(rs);
                lista.add(c);
            }

            System.out.println("Cursos encontrados en búsqueda: " + lista.size());

        } catch (SQLException e) {
            System.err.println("Error al buscar cursos por nombre desde vista: " + e.getMessage());
            e.printStackTrace();
        }

        return lista;
    }

    /**
     * OBTENER CURSO CON ESTADÍSTICAS COMPLETAS
     * 
     * @param id Identificador del curso
     * @return Curso con estadísticas o null
     */
    public Curso obtenerConEstadisticas(int id) {
        // Ya la vista incluye estadísticas básicas
        Curso curso = obtenerPorId(id);
        
        if (curso != null) {
            // Obtener estadísticas adicionales
            int alumnos = contarAlumnosPorCurso(id);
            int tareas = contarTareasPorCurso(id);
            
            curso.setCantidadAlumnos(alumnos);
            curso.setCantidadTareas(tareas);
        }
        
        return curso;
    }

    /**
     * CONTAR ALUMNOS POR CURSO
     */
    private int contarAlumnosPorCurso(int cursoId) {
        // Primero obtener el grado del curso
        Curso curso = obtenerPorId(cursoId);
        if (curso == null) {
            return 0;
        }
        
        String sql = "SELECT COUNT(*) as total FROM alumno a " +
                     "WHERE a.grado_id = ? AND a.estado = 'ACTIVO' " +
                     "AND a.activo = 1 AND a.eliminado = 0";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, curso.getGradoId());
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt("total");
            }

        } catch (SQLException e) {
            System.err.println("Error al contar alumnos por curso: " + e.getMessage());
            e.printStackTrace();
        }

        return 0;
    }

    /**
     * CONTAR TAREAS POR CURSO
     */
    private int contarTareasPorCurso(int cursoId) {
        String sql = "SELECT COUNT(*) as total FROM tarea WHERE curso_id = ? AND activo = 1 AND eliminado = 0";

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, cursoId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt("total");
            }

        } catch (SQLException e) {
            System.err.println("Error al contar tareas por curso: " + e.getMessage());
            e.printStackTrace();
        }

        return 0;
    }

    /**
     * CONTAR CURSOS POR PROFESOR
     * 
     * @param profesorId Identificador del profesor
     * @return Cantidad de cursos asignados
     */
    public int contarPorProfesor(int profesorId) {
        String sql = "SELECT COUNT(*) as total FROM curso WHERE profesor_id = ? AND activo = 1 AND eliminado = 0";

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
        String sql = "SELECT COUNT(*) as total FROM curso WHERE grado_id = ? AND activo = 1 AND eliminado = 0";

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
        String sql = "SELECT COUNT(*) as total FROM curso WHERE activo = 1 AND eliminado = 0";

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
        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            conn = Conexion.getConnection();
            
            String sql = "UPDATE curso SET profesor_id = ? WHERE id = ?";
            
            ps = conn.prepareStatement(sql);
            ps.setInt(1, nuevoProfesorId);
            ps.setInt(2, cursoId);

            int filasAfectadas = ps.executeUpdate();
            
            if (filasAfectadas > 0) {
                System.out.println("Profesor cambiado en curso " + cursoId + " a profesor " + nuevoProfesorId);
                return true;
            }

        } catch (SQLException e) {
            System.err.println("Error al cambiar profesor del curso: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            cerrarRecursos(null, ps, conn);
        }
        
        return false;
    }

    /**
     * CERRAR RECURSOS
     */
    private void cerrarRecursos(ResultSet rs, PreparedStatement ps, Connection conn) {
        try {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            System.err.println("Error cerrando recursos: " + e.getMessage());
        }
    }

    /**
     * VERIFICAR SI UN CURSO TIENE TAREAS ASOCIADAS
     * 
     * @param cursoId Identificador del curso
     * @return true si el curso tiene tareas activas
     */
    public boolean tieneTareas(int cursoId) {
        return contarTareasPorCurso(cursoId) > 0;
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
    // AGREGAR ESTE MÉTODO A TU CursoDAO.java EXISTENTE

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
                             "creditos = ?, area = ?, descripcion = ? WHERE id = ?";
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
}