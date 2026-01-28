package modelo;

import conexion.Conexion;
import java.sql.*;
import java.util.*;

/**
 * DAO PARA GESTIÓN DE CURSOS ACADÉMICOS - VERSIÓN CORREGIDA
 * 
 * Funcionalidades:
 * - CRUD completo de cursos
 * - Consultas por grado, profesor y nivel
 * - Integración con stored procedures
 * - Soporte para area_id (FK) y turno_id
 * - Consultas estadísticas y reportes
 */
public class CursoDAO {

    /**
     * LISTAR TODOS LOS CURSOS ACTIVOS
     */
    public List<Curso> listar() {
        List<Curso> lista = new ArrayList<>();
        String sql = "SELECT " +
                     "c.id, c.nombre, c.creditos, c.horas_semanales, c.descripcion, " +
                     "g.id as grado_id, g.nombre as grado_nombre, g.nivel, " +
                     "a.id as area_id, a.nombre as area_nombre, " +
                     "c.profesor_id, CONCAT(p.nombres, ' ', p.apellidos) as profesor_nombre, " +
                     "c.fecha_inicio, c.fecha_fin " +
                     "FROM curso c " +
                     "INNER JOIN grado g ON c.grado_id = g.id " +
                     "LEFT JOIN area a ON c.area_id = a.id " +
                     "LEFT JOIN profesor prof ON c.profesor_id = prof.id " +
                     "LEFT JOIN persona p ON prof.persona_id = p.id " +
                     "WHERE c.eliminado = 0 AND c.activo = 1 " +
                     "ORDER BY g.nivel, g.orden, c.nombre";

        try (Connection con = Conexion.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql); 
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Curso c = new Curso();
                c.setId(rs.getInt("id"));
                c.setNombre(rs.getString("nombre"));
                c.setCreditos(rs.getInt("creditos"));
                c.setHorasSemanales(rs.getInt("horas_semanales"));
                c.setDescripcion(rs.getString("descripcion"));
                c.setGradoId(rs.getInt("grado_id"));
                c.setGradoNombre(rs.getString("grado_nombre"));
                c.setNivel(rs.getString("nivel"));
                c.setArea(rs.getString("area_nombre")); // Nombre del área
                c.setProfesorId(rs.getInt("profesor_id"));
                c.setProfesorNombre(rs.getString("profesor_nombre"));
                c.setFechaInicio(rs.getDate("fecha_inicio"));
                c.setFechaFin(rs.getDate("fecha_fin"));
                
                lista.add(c);
            }

            System.out.println("✅ Cursos encontrados: " + lista.size());

        } catch (SQLException e) {
            System.err.println("❌ Error al listar cursos: " + e.getMessage());
            e.printStackTrace();
        }

        return lista;
    }

    /**
     * LISTAR CURSOS POR PROFESOR
     */
    public List<Curso> listarPorProfesor(int profesorId) {
        List<Curso> lista = new ArrayList<>();
        String sql = "SELECT " +
                     "c.id, c.nombre, c.creditos, c.descripcion, " +
                     "g.nombre as grado_nombre, g.nivel, " +
                     "a.nombre as area_nombre " +
                     "FROM curso c " +
                     "INNER JOIN grado g ON c.grado_id = g.id " +
                     "LEFT JOIN area a ON c.area_id = a.id " +
                     "WHERE c.profesor_id = ? AND c.eliminado = 0 AND c.activo = 1 " +
                     "ORDER BY c.nombre";

        try (Connection con = Conexion.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, profesorId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Curso c = new Curso();
                c.setId(rs.getInt("id"));
                c.setNombre(rs.getString("nombre"));
                c.setCreditos(rs.getInt("creditos"));
                c.setDescripcion(rs.getString("descripcion"));
                c.setGradoNombre(rs.getString("grado_nombre"));
                c.setNivel(rs.getString("nivel"));
                c.setArea(rs.getString("area_nombre"));
                c.setProfesorId(profesorId);
                
                lista.add(c);
            }

            System.out.println("✅ Cursos del profesor " + profesorId + ": " + lista.size());

        } catch (SQLException e) {
            System.err.println("❌ Error en listarPorProfesor: " + e.getMessage());
            e.printStackTrace();
        }

        return lista;
    }

    /**
     * LISTAR CURSOS POR GRADO
     */
    public List<Curso> listarPorGrado(int gradoId) {
        List<Curso> lista = new ArrayList<>();
        String sql = "SELECT " +
                     "c.id, c.nombre, c.creditos, c.descripcion, c.grado_id, " +
                     "c.horas_semanales, c.fecha_inicio, c.fecha_fin, " +
                     "g.nombre as grado_nombre, " +
                     "a.nombre as area_nombre, " +
                     "c.profesor_id, CONCAT(p.nombres, ' ', p.apellidos) as profesor_nombre " +
                     "FROM curso c " +
                     "INNER JOIN grado g ON c.grado_id = g.id " +
                     "LEFT JOIN area a ON c.area_id = a.id " +
                     "LEFT JOIN profesor prof ON c.profesor_id = prof.id " +
                     "LEFT JOIN persona p ON prof.persona_id = p.id " +
                     "WHERE c.grado_id = ? AND c.eliminado = 0 AND c.activo = 1 " +
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
                c.setCreditos(rs.getInt("creditos"));
                c.setHorasSemanales(rs.getInt("horas_semanales"));
                c.setArea(rs.getString("area_nombre"));
                c.setDescripcion(rs.getString("descripcion"));
                c.setProfesorId(rs.getInt("profesor_id"));
                c.setProfesorNombre(rs.getString("profesor_nombre"));
                c.setFechaInicio(rs.getDate("fecha_inicio"));
                c.setFechaFin(rs.getDate("fecha_fin"));
                
                lista.add(c);
            }

            System.out.println("✅ Cursos del grado " + gradoId + ": " + lista.size());

        } catch (SQLException e) {
            System.err.println("❌ Error en listarPorGrado: " + e.getMessage());
            e.printStackTrace();
        }

        return lista;
    }

    /**
     * LISTAR CURSOS POR ALUMNO
     */
    public List<Curso> listarPorAlumno(int alumnoId) {
        List<Curso> cursos = new ArrayList<>();
        
        String sqlGrado = "SELECT grado_id FROM alumno WHERE id = ? AND activo = 1 AND eliminado = 0";
        
        String sqlCursos = "SELECT " +
                          "c.id, c.nombre, c.descripcion, c.grado_id, " +
                          "g.nombre as grado_nombre, " +
                          "c.profesor_id, CONCAT(p.nombres, ' ', p.apellidos) as profesor_nombre " +
                          "FROM curso c " +
                          "INNER JOIN grado g ON c.grado_id = g.id " +
                          "LEFT JOIN profesor pr ON c.profesor_id = pr.id " +
                          "LEFT JOIN persona p ON pr.persona_id = p.id " +
                          "WHERE c.grado_id = ? AND c.activo = 1 AND c.eliminado = 0 " +
                          "ORDER BY c.nombre";
        
        try (Connection con = Conexion.getConnection()) {
            
            int gradoId = 0;
            try (PreparedStatement psGrado = con.prepareStatement(sqlGrado)) {
                psGrado.setInt(1, alumnoId);
                ResultSet rsGrado = psGrado.executeQuery();
                
                if (rsGrado.next()) {
                    gradoId = rsGrado.getInt("grado_id");
                } else {
                    System.out.println("⚠️ No se encontró el alumno con ID: " + alumnoId);
                    return cursos;
                }
            }
            
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
                
                System.out.println("✅ Cursos del alumno " + alumnoId + ": " + cursos.size());
            }
            
        } catch (SQLException e) {
            System.err.println("❌ ERROR en listarPorAlumno: " + e.getMessage());
            e.printStackTrace();
        }
        
        return cursos;
    }

    /**
     * OBTENER CURSO COMPLETO POR ID (para edición)
     * Incluye área, turno y nivel
     */
    public Curso obtenerCursoCompletoPorId(int id) {
        String sql = "SELECT " +
                     "c.id, c.nombre, c.grado_id, c.profesor_id, c.creditos, " +
                     "c.area_id, c.descripcion, c.activo, " +
                     "g.nombre AS grado_nombre, g.nivel, " +
                     "a.nombre AS area_nombre, " +
                     "CONCAT(p.nombres, ' ', p.apellidos) AS profesor_nombre, " +
                     "h.turno_id, t.nombre AS turno_nombre " +
                     "FROM curso c " +
                     "INNER JOIN grado g ON c.grado_id = g.id " +
                     "LEFT JOIN area a ON c.area_id = a.id " +
                     "LEFT JOIN profesor prof ON c.profesor_id = prof.id " +
                     "LEFT JOIN persona p ON prof.persona_id = p.id " +
                     "LEFT JOIN horario_clase h ON c.id = h.curso_id AND h.eliminado = 0 AND h.activo = 1 " +
                     "LEFT JOIN turno t ON h.turno_id = t.id " +
                     "WHERE c.id = ? AND c.eliminado = 0 " +
                     "LIMIT 1";

        try (Connection conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Curso curso = new Curso();
                curso.setId(rs.getInt("id"));
                curso.setNombre(rs.getString("nombre"));
                curso.setGradoId(rs.getInt("grado_id"));
                curso.setGradoNombre(rs.getString("grado_nombre"));
                curso.setNivel(rs.getString("nivel"));
                curso.setProfesorId(rs.getInt("profesor_id"));
                curso.setProfesorNombre(rs.getString("profesor_nombre"));
                curso.setCreditos(rs.getInt("creditos"));
                curso.setArea(rs.getString("area_nombre"));
                curso.setDescripcion(rs.getString("descripcion"));

                // Asignar turno si existe
                Integer turnoId = rs.getInt("turno_id");
                if (!rs.wasNull()) {
                    curso.setTurnoId(turnoId);
                    curso.setTurnoNombre(rs.getString("turno_nombre"));
                }

                System.out.println("✅ Curso obtenido para edición:");
                System.out.println("   ID: " + curso.getId());
                System.out.println("   Nombre: " + curso.getNombre());
                System.out.println("   Grado: " + curso.getGradoNombre());
                System.out.println("   Nivel: " + curso.getNivel());
                System.out.println("   Área: " + curso.getArea());
                System.out.println("   Turno: " + curso.getTurnoNombre() + " (ID: " + curso.getTurnoId() + ")");

                return curso;
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al obtener curso completo: " + e.getMessage());
            e.printStackTrace();
        }

        return null;
    }

    /**
     * OBTENER CURSO POR ID (alias del método completo)
     */
    public Curso obtenerPorId(int id) {
        return obtenerCursoCompletoPorId(id);
    }

    /**
     * OBTENER HORARIOS DE UN CURSO
     */
    public List<Map<String, Object>> obtenerHorariosPorCurso(int cursoId) {
        List<Map<String, Object>> horarios = new ArrayList<>();
        String sql = "SELECT " +
                     "h.id, h.dia_semana, " +
                     "TIME_FORMAT(h.hora_inicio, '%H:%i') AS hora_inicio, " +
                     "TIME_FORMAT(h.hora_fin, '%H:%i') AS hora_fin, " +
                     "h.turno_id, t.nombre AS turno_nombre, " +
                     "h.aula_id, a.nombre AS aula_nombre " +
                     "FROM horario_clase h " +
                     "INNER JOIN turno t ON h.turno_id = t.id " +
                     "LEFT JOIN aula a ON h.aula_id = a.id " +
                     "WHERE h.curso_id = ? AND h.eliminado = 0 AND h.activo = 1 " +
                     "ORDER BY FIELD(h.dia_semana, 'LUNES','MARTES','MIERCOLES','JUEVES','VIERNES','SABADO'), h.hora_inicio";

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
                
                Integer aulaId = rs.getInt("aula_id");
                if (!rs.wasNull()) {
                    horario.put("aula_id", aulaId);
                    horario.put("aula_nombre", rs.getString("aula_nombre"));
                }
                
                horarios.add(horario);
            }

            System.out.println("✅ Horarios obtenidos para curso " + cursoId + ": " + horarios.size());

        } catch (SQLException e) {
            System.err.println("❌ Error al obtener horarios: " + e.getMessage());
            e.printStackTrace();
        }

        return horarios;
    }

    /**
     * AGREGAR NUEVO CURSO
     */
    public int agregar(Curso c) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = Conexion.getConnection();
            
            String sql = "INSERT INTO curso (nombre, grado_id, profesor_id, creditos, " +
                        "horas_semanales, area_id, descripcion, fecha_inicio, fecha_fin, activo, eliminado) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 1, 0)";
            
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);

            ps.setString(1, c.getNombre());
            ps.setInt(2, c.getGradoId());
            ps.setInt(3, c.getProfesorId());
            ps.setInt(4, c.getCreditos());
            
            // Horas semanales (si es null, usar 0)
            if (c.getHorasSemanales() > 0) {
                ps.setInt(5, c.getHorasSemanales());
            } else {
                ps.setInt(5, 0);
            }
            
            // Area ID - obtener desde el nombre del área
            Integer areaId = obtenerAreaIdPorNombre(c.getArea());
            if (areaId != null) {
                ps.setInt(6, areaId);
            } else {
                ps.setNull(6, Types.INTEGER);
            }
            
            ps.setString(7, c.getDescripcion());
            
            // Fechas
            if (c.getFechaInicio() != null) {
                ps.setDate(8, c.getFechaInicio());
            } else {
                ps.setNull(8, Types.DATE);
            }
            
            if (c.getFechaFin() != null) {
                ps.setDate(9, c.getFechaFin());
            } else {
                ps.setNull(9, Types.DATE);
            }

            int filasAfectadas = ps.executeUpdate();
            
            if (filasAfectadas > 0) {
                rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    int idGenerado = rs.getInt(1);
                    System.out.println("✅ Curso creado con ID: " + idGenerado);
                    return idGenerado;
                }
            }

        } catch (SQLException e) {
            System.err.println("❌ Error al agregar curso: " + e.getMessage());
            e.printStackTrace();
        } finally {
            cerrarRecursos(rs, ps, conn);
        }
        
        return -1;
    }

    /**
     * OBTENER AREA_ID POR NOMBRE
     */
    private Integer obtenerAreaIdPorNombre(String areaNombre) {
        if (areaNombre == null || areaNombre.trim().isEmpty()) {
            return null;
        }
        
        String sql = "SELECT id FROM area WHERE nombre = ? AND activo = 1 AND eliminado = 0";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, areaNombre.trim());
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("id");
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error al obtener area_id: " + e.getMessage());
        }
        
        return null;
    }

    /**
     * CERRAR RECURSOS DE BD
     */
    private void cerrarRecursos(ResultSet rs, PreparedStatement ps, Connection conn) {
        try {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            System.err.println("❌ Error cerrando recursos: " + e.getMessage());
        }
    }

    /**
     * ACTUALIZAR CURSO (sin horarios)
     */
    public boolean actualizar(Curso c) {
        String sql = "UPDATE curso SET " +
                     "nombre = ?, grado_id = ?, profesor_id = ?, " +
                     "creditos = ?, descripcion = ? " +
                     "WHERE id = ? AND eliminado = 0";
        
        try (Connection conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, c.getNombre());
            ps.setInt(2, c.getGradoId());
            ps.setInt(3, c.getProfesorId());
            ps.setInt(4, c.getCreditos());
            ps.setString(5, c.getDescripcion());
            ps.setInt(6, c.getId());
            
            int filas = ps.executeUpdate();
            
            if (filas > 0) {
                System.out.println("✅ Curso actualizado: ID " + c.getId());
                return true;
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error al actualizar curso: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }

    /**
     * ACTUALIZAR CURSO CON HORARIOS
     */
    public boolean actualizarConHorarios(Curso c, String horariosJson) {
        Connection conn = null;
        
        try {
            conn = Conexion.getConnection();
            conn.setAutoCommit(false);
            
            // 1. Actualizar datos del curso
            String sqlCurso = "UPDATE curso SET nombre = ?, grado_id = ?, profesor_id = ?, " +
                             "creditos = ?, descripcion = ? WHERE id = ?";
            PreparedStatement psCurso = conn.prepareStatement(sqlCurso);
            psCurso.setString(1, c.getNombre());
            psCurso.setInt(2, c.getGradoId());
            psCurso.setInt(3, c.getProfesorId());
            psCurso.setInt(4, c.getCreditos());
            psCurso.setString(5, c.getDescripcion());
            psCurso.setInt(6, c.getId());
            psCurso.executeUpdate();
            psCurso.close();
            
            // 2. Marcar horarios antiguos como eliminados
            String sqlEliminar = "UPDATE horario_clase SET eliminado = 1, activo = 0 WHERE curso_id = ?";
            PreparedStatement psEliminar = conn.prepareStatement(sqlEliminar);
            psEliminar.setInt(1, c.getId());
            psEliminar.executeUpdate();
            psEliminar.close();
            
            conn.commit();
            System.out.println("✅ Curso y horarios actualizados: ID " + c.getId());
            return true;
            
        } catch (SQLException e) {
            System.err.println("❌ Error al actualizar curso con horarios: " + e.getMessage());
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

    /**
     * ELIMINAR CURSO (LÓGICO)
     */
    public boolean eliminar(int cursoId) {
        String sql = "{CALL eliminar_curso_logico(?)}";
        
        try (Connection conn = Conexion.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            
            cs.setInt(1, cursoId);
            ResultSet rs = cs.executeQuery();
            
            if (rs.next()) {
                int resultado = rs.getInt("resultado");
                String mensaje = rs.getString("mensaje");
                
                System.out.println("Eliminación de curso " + cursoId + ":");
                System.out.println("  Resultado: " + (resultado == 1 ? "✅ ÉXITO" : "❌ ERROR"));
                System.out.println("  Mensaje: " + mensaje);
                
                return resultado == 1;
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error al eliminar curso: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }

    /**
     * VERIFICAR SI CURSO ESTÁ ASIGNADO A PROFESOR
     */
    public boolean isCursoAssignedToProfesor(int cursoId, int profesorId) {
        Curso curso = obtenerPorId(cursoId);
        if (curso == null) {
            return false;
        }
        return curso.getProfesorId() == profesorId;
    }

    /**
     * VERIFICAR SI CURSO EXISTE
     */
    public boolean existeCurso(int cursoId) {
        String sql = "SELECT COUNT(*) as total FROM curso WHERE id = ? AND activo = 1 AND eliminado = 0";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, cursoId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("total") > 0;
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error al verificar curso: " + e.getMessage());
        }
        
        return false;
    }

    /**
     * CONTAR CURSOS POR PROFESOR
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
            System.err.println("❌ Error al contar cursos: " + e.getMessage());
        }

        return 0;
    }

    /**
     * VERIFICAR SI CURSO TIENE HORARIOS
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
            System.err.println("❌ Error al verificar horarios: " + e.getMessage());
        }

        return false;
    }
}