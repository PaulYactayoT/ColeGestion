package modelo;

import conexion.Conexion;
import java.sql.*;
import java.util.*;

/**
 * DAO PARA REGISTRO DE CURSOS
 * Contiene métodos auxiliares para el formulario de registro
 */
public class RegistroCursoDAO {

    /**
     * OBTENER GRADOS POR NIVEL
     */
    public List<Map<String, Object>> obtenerGradosPorNivel(String nivel) {
        List<Map<String, Object>> grados = new ArrayList<>();
        
        String sql = "SELECT id, nombre, nivel, orden " +
                     "FROM grado " +
                     "WHERE nivel = ? " +
                     "AND activo = 1 " +
                     "AND eliminado = 0 " +
                     "ORDER BY orden";
        
        try (Connection conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, nivel.toUpperCase());
            
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> grado = new HashMap<>();
                grado.put("id", rs.getInt("id"));
                grado.put("nombre", rs.getString("nombre"));
                grado.put("nivel", rs.getString("nivel"));
                grado.put("orden", rs.getInt("orden"));
                
                grados.add(grado);
            }
            
            System.out.println("✅ Grados obtenidos para nivel " + nivel + ": " + grados.size());
            
            for (Map<String, Object> g : grados) {
                System.out.println("   - ID: " + g.get("id") + ", Nombre: " + g.get("nombre"));
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error al obtener grados por nivel: " + e.getMessage());
            e.printStackTrace();
        }
        
        return grados;
    }

    /**
     * OBTENER TURNOS
     */
    public List<Map<String, Object>> obtenerTurnos() {
        List<Map<String, Object>> turnos = new ArrayList<>();
        
        String sql = "SELECT id, nombre, hora_inicio, hora_fin " +
                     "FROM turno " +
                     "WHERE activo = 1 " +
                     "AND eliminado = 0 " +
                     "ORDER BY hora_inicio";
        
        try (Connection conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Map<String, Object> turno = new HashMap<>();
                turno.put("id", rs.getInt("id"));
                turno.put("nombre", rs.getString("nombre"));
                turno.put("hora_inicio", rs.getTime("hora_inicio").toString());
                turno.put("hora_fin", rs.getTime("hora_fin").toString());
                
                turnos.add(turno);
            }
            
            System.out.println("✅ Turnos obtenidos: " + turnos.size());
            
        } catch (SQLException e) {
            System.err.println("❌ Error al obtener turnos: " + e.getMessage());
            e.printStackTrace();
        }
        
        return turnos;
    }

    /**
     * OBTENER ÁREAS POR NIVEL
     */
    public List<Map<String, Object>> obtenerAreasPorNivel(String nivel) {
        List<Map<String, Object>> areas = new ArrayList<>();
        
        String sql = "SELECT DISTINCT a.nombre as area " +
                     "FROM area a " +
                     "WHERE (a.nivel = ? OR a.nivel = 'TODOS') " +
                     "AND a.activo = 1 " +
                     "AND a.eliminado = 0 " +
                     "ORDER BY a.nombre";
        
        try (Connection conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, nivel.toUpperCase());
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> area = new HashMap<>();
                area.put("area", rs.getString("area"));
                areas.add(area);
            }
            
            System.out.println("✅ Áreas obtenidas para nivel " + nivel + ": " + areas.size());
            
        } catch (SQLException e) {
            System.err.println("❌ Error al obtener áreas: " + e.getMessage());
            e.printStackTrace();
        }
        
        return areas;
    }

    /**
     * OBTENER CURSOS POR ÁREA
     */
    public List<Map<String, Object>> obtenerCursosPorArea(String area) {
        List<Map<String, Object>> cursos = new ArrayList<>();
        
        String sql = "SELECT DISTINCT c.nombre, a.nombre as area_nombre, c.descripcion " +
                     "FROM curso c " +
                     "INNER JOIN area a ON c.area_id = a.id " +
                     "WHERE a.nombre = ? " +
                     "AND c.activo = 1 " +
                     "AND c.eliminado = 0 " +
                     "ORDER BY c.nombre";
        
        try (Connection conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, area);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> curso = new HashMap<>();
                curso.put("nombre", rs.getString("nombre"));
                curso.put("area", rs.getString("area_nombre"));
                curso.put("descripcion", rs.getString("descripcion"));
                cursos.add(curso);
            }
            
            System.out.println("✅ Cursos obtenidos para área " + area + ": " + cursos.size());
            
        } catch (SQLException e) {
            System.err.println("❌ Error al obtener cursos: " + e.getMessage());
            e.printStackTrace();
        }
        
        return cursos;
    }

    /**
     * OBTENER PROFESORES POR CURSO, TURNO Y NIVEL
     */
    public List<Map<String, Object>> obtenerProfesoresPorCursoTurnoNivel(String curso, int turnoId, String nivel) {
        List<Map<String, Object>> profesores = new ArrayList<>();
        
        String sql = "SELECT DISTINCT " +
                     "prof.id, " +
                     "CONCAT(p.nombres, ' ', p.apellidos) as nombre_completo, " +
                     "a.nombre as especialidad " +
                     "FROM profesor prof " +
                     "INNER JOIN persona p ON prof.persona_id = p.id " +
                     "LEFT JOIN area a ON prof.area_id = a.id " +
                     "WHERE prof.turno_id = ? " +
                     "AND (prof.nivel = ? OR prof.nivel = 'TODOS') " +
                     "AND prof.activo = 1 " +
                     "AND prof.eliminado = 0 " +
                     "AND prof.estado = 'ACTIVO' " +
                     "ORDER BY p.apellidos, p.nombres";
        
        try (Connection conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, turnoId);
            ps.setString(2, nivel.toUpperCase());
            
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> profesor = new HashMap<>();
                profesor.put("id", rs.getInt("id"));
                profesor.put("nombre_completo", rs.getString("nombre_completo"));
                profesor.put("especialidad", rs.getString("especialidad"));
                profesores.add(profesor);
            }
            
            System.out.println("✅ Profesores obtenidos: " + profesores.size());
            
        } catch (SQLException e) {
            System.err.println("❌ Error al obtener profesores: " + e.getMessage());
            e.printStackTrace();
        }
        
        return profesores;
    }

    /**
     * VALIDAR LÍMITE DE CURSOS POR DÍA
     */
    public int validarLimiteCursos(int profesorId, int turnoId, String diaSemana) {
        String sql = "SELECT COUNT(DISTINCT h.curso_id) as total " +
                     "FROM horario_clase h " +
                     "WHERE h.profesor_id = ? " +
                     "AND h.turno_id = ? " +
                     "AND h.dia_semana = ? " +
                     "AND h.activo = 1 " +
                     "AND h.eliminado = 0";
        
        try (Connection conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, profesorId);
            ps.setInt(2, turnoId);
            ps.setString(3, diaSemana.toUpperCase());
            
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("total");
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error al validar límite de cursos: " + e.getMessage());
            e.printStackTrace();
        }
        
        return 0;
    }

    /**
     * VALIDAR CONFLICTO DE HORARIO
     */
    public boolean validarConflictoHorario(int profesorId, int turnoId, String diaSemana, 
                                           String horaInicio, String horaFin) {
        String sql = "SELECT COUNT(*) as conflictos " +
                     "FROM horario_clase h " +
                     "WHERE h.profesor_id = ? " +
                     "AND h.turno_id = ? " +
                     "AND h.dia_semana = ? " +
                     "AND h.activo = 1 " +
                     "AND h.eliminado = 0 " +
                     "AND (" +
                     "  (h.hora_inicio < ? AND h.hora_fin > ?) OR " +
                     "  (h.hora_inicio < ? AND h.hora_fin > ?) OR " +
                     "  (h.hora_inicio >= ? AND h.hora_fin <= ?)" +
                     ")";
        
        try (Connection conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, profesorId);
            ps.setInt(2, turnoId);
            ps.setString(3, diaSemana.toUpperCase());
            ps.setString(4, horaFin);
            ps.setString(5, horaInicio);
            ps.setString(6, horaFin);
            ps.setString(7, horaInicio);
            ps.setString(8, horaInicio);
            ps.setString(9, horaFin);
            
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("conflictos") > 0;
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error al validar conflicto: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }

    /**
     * VALIDAR HORARIO EN TURNO
     */
    public Map<String, Object> validarHorarioEnTurno(int turnoId, String horaInicio, String horaFin) {
        Map<String, Object> resultado = new HashMap<>();
        
        String sql = "SELECT hora_inicio, hora_fin " +
                     "FROM turno " +
                     "WHERE id = ? " +
                     "AND activo = 1 " +
                     "AND eliminado = 0";
        
        try (Connection conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, turnoId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                Time turnoInicio = rs.getTime("hora_inicio");
                Time turnoFin = rs.getTime("hora_fin");
                Time claseInicio = Time.valueOf(horaInicio + ":00");
                Time claseFin = Time.valueOf(horaFin + ":00");
                
                boolean dentroRango = !claseInicio.before(turnoInicio) && !claseFin.after(turnoFin);
                
                resultado.put("dentro_rango", dentroRango);
                resultado.put("mensaje", dentroRango ? "Horario válido" : "Horario fuera del rango del turno");
            } else {
                resultado.put("dentro_rango", false);
                resultado.put("mensaje", "Turno no encontrado");
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error al validar horario: " + e.getMessage());
            resultado.put("dentro_rango", false);
            resultado.put("mensaje", "Error en validación");
        }
        
        return resultado;
    }

    /**
     * REGISTRAR CURSO COMPLETO
     */
    public Map<String, Object> registrarCursoCompleto(String nombreCurso, int gradoId, 
                                                       int profesorId, int turnoId, 
                                                       String descripcion, String area, 
                                                       String horariosJson) {
        Map<String, Object> resultado = new HashMap<>();
        
        String sql = "{CALL registrar_curso_completo(?, ?, ?, ?, ?, ?, ?)}";
        
        try (Connection conn = Conexion.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            
            cs.setString(1, nombreCurso);
            cs.setInt(2, gradoId);
            cs.setInt(3, profesorId);
            cs.setInt(4, turnoId);
            cs.setString(5, descripcion);
            cs.setString(6, area);
            cs.setString(7, horariosJson);
            
            ResultSet rs = cs.executeQuery();
            
            if (rs.next()) {
                resultado.put("exito", rs.getBoolean("exito"));
                resultado.put("mensaje", rs.getString("mensaje"));
                resultado.put("detalle", rs.getString("detalle"));
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error al registrar curso: " + e.getMessage());
            resultado.put("exito", false);
            resultado.put("mensaje", "Error en base de datos");
            resultado.put("detalle", e.getMessage());
        }
        
        return resultado;
    }

    /**
     * ACTUALIZAR CURSO
     */
    public Map<String, Object> actualizarCurso(int cursoId, String nombreCurso, int gradoId, 
                                                int profesorId, int turnoId, String descripcion, 
                                                String area, String horariosJson) {
        Map<String, Object> resultado = new HashMap<>();
        
        String sql = "{CALL actualizar_curso_completo(?, ?, ?, ?, ?, ?, ?, ?)}";
        
        try (Connection conn = Conexion.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            
            cs.setInt(1, cursoId);
            cs.setString(2, nombreCurso);
            cs.setInt(3, gradoId);
            cs.setInt(4, profesorId);
            cs.setInt(5, turnoId);
            cs.setString(6, descripcion);
            cs.setString(7, area);
            cs.setString(8, horariosJson);
            
            ResultSet rs = cs.executeQuery();
            
            if (rs.next()) {
                resultado.put("exito", rs.getBoolean("exito"));
                resultado.put("mensaje", rs.getString("mensaje"));
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error al actualizar curso: " + e.getMessage());
            resultado.put("exito", false);
            resultado.put("mensaje", "Error: " + e.getMessage());
        }
        
        return resultado;
    }
}