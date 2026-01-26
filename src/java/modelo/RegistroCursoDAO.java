/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */

package modelo;

import conexion.Conexion;
import java.sql.*;
import java.util.*;


public class RegistroCursoDAO {

    /**
     * Obtener lista de nombres de cursos disponibles
     */
    /**
 * Obtener lista de nombres de cursos disponibles
 */
        public List<Map<String, Object>> obtenerCursosBase() {
            List<Map<String, Object>> cursos = new ArrayList<>();

            // Usar query directa en lugar de stored procedure para evitar problemas de codificación
            String sql = "SELECT DISTINCT nombre, area " +
                         "FROM curso " +
                         "WHERE activo = 1 AND eliminado = 0 " +
                         "ORDER BY nombre";

            try (Connection con = Conexion.getConnection();
                 PreparedStatement ps = con.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    Map<String, Object> curso = new HashMap<>();
                    String nombre = rs.getString("nombre");
                    String area = rs.getString("area");

                    curso.put("nombre", nombre != null ? nombre : "");
                    curso.put("area", area != null ? area : "");
                    cursos.add(curso);

                    System.out.println("✓ " + nombre + " - " + area);
                }

                System.out.println("Total cursos base obtenidos: " + cursos.size());

            } catch (SQLException e) {
                System.err.println("Error al obtener cursos base: " + e.getMessage());
                e.printStackTrace();
            }

            return cursos;
        }

    /**
    * Obtener profesores disponibles para un curso específico
    */
        public List<Map<String, Object>> obtenerProfesoresPorCurso(String nombreCurso) {
            List<Map<String, Object>> profesores = new ArrayList<>();
            String sql = "{CALL obtener_profesores_por_nombre_curso(?)}";

            try (Connection con = Conexion.getConnection();
                 CallableStatement cs = con.prepareCall(sql)) {

                cs.setString(1, nombreCurso);
                ResultSet rs = cs.executeQuery();

                while (rs.next()) {
                    Map<String, Object> profesor = new HashMap<>();
                    profesor.put("id", rs.getInt("id"));
                    profesor.put("nombre_completo", rs.getString("nombre_completo"));
                    profesor.put("especialidad", rs.getString("especialidad"));
                    profesor.put("codigo", rs.getString("codigo_profesor"));
                    profesores.add(profesor);
                }

                System.out.println("Profesores encontrados para '" + nombreCurso + "': " + profesores.size());

                // Si no encontró profesores, mostrar mensaje
                if (profesores.isEmpty()) {
                    System.out.println(" No se encontraron profesores para el curso: " + nombreCurso);
                }

            } catch (SQLException e) {
                System.err.println("Error al obtener profesores: " + e.getMessage());
                e.printStackTrace();
            }

            return profesores;
        }

    /**
     * Obtener todos los grados activos
     */
    public List<Map<String, Object>> obtenerGrados() {
        List<Map<String, Object>> grados = new ArrayList<>();
        String sql = "{CALL obtener_grados()}";
        
        try (Connection con = Conexion.getConnection();
             CallableStatement cs = con.prepareCall(sql);
             ResultSet rs = cs.executeQuery()) {
            
            while (rs.next()) {
                Map<String, Object> grado = new HashMap<>();
                grado.put("id", rs.getInt("id"));
                grado.put("nombre", rs.getString("nombre"));
                grado.put("nivel", rs.getString("nivel"));
                grados.add(grado);
            }
            
            System.out.println("Grados obtenidos: " + grados.size());
            
        } catch (SQLException e) {
            System.err.println("Error al obtener grados: " + e.getMessage());
            e.printStackTrace();
        }
        
        return grados;
    }

    /**
     * Obtener turnos disponibles
     */
    public List<Map<String, Object>> obtenerTurnos() {
        List<Map<String, Object>> turnos = new ArrayList<>();
        String sql = "SELECT id, nombre, TIME_FORMAT(hora_inicio, '%H:%i') as hora_inicio, " +
                     "TIME_FORMAT(hora_fin, '%H:%i') as hora_fin FROM turno " +
                     "WHERE activo = 1 AND eliminado = 0";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Map<String, Object> turno = new HashMap<>();
                turno.put("id", rs.getInt("id"));
                turno.put("nombre", rs.getString("nombre"));
                turno.put("hora_inicio", rs.getString("hora_inicio"));
                turno.put("hora_fin", rs.getString("hora_fin"));
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
     * Validar límite de cursos por día
     */
    public int validarLimiteCursos(int profesorId, int turnoId, String diaSemana) {
        String sql = "{CALL validar_limite_cursos_profesor(?, ?, ?)}";
        
        try (Connection con = Conexion.getConnection();
             CallableStatement cs = con.prepareCall(sql)) {
            
            cs.setInt(1, profesorId);
            cs.setInt(2, turnoId);
            cs.setString(3, diaSemana);
            
            ResultSet rs = cs.executeQuery();
            if (rs.next()) {
                int cursos = rs.getInt("cursos_en_dia");
                System.out.println("📊 Cursos del profesor en " + diaSemana + ": " + cursos);
                return cursos;
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error al validar límite: " + e.getMessage());
            e.printStackTrace();
        }
        
        return -1;
    }

    /**
     * Validar conflicto de horarios
     */
    public boolean validarConflictoHorario(int profesorId, int turnoId, 
            String diaSemana, String horaInicio, String horaFin) {
        String sql = "{CALL validar_conflicto_horario_profesor(?, ?, ?, ?, ?)}";
        
        try (Connection con = Conexion.getConnection();
             CallableStatement cs = con.prepareCall(sql)) {
            
            cs.setInt(1, profesorId);
            cs.setInt(2, turnoId);
            cs.setString(3, diaSemana);
            cs.setString(4, horaInicio);
            cs.setString(5, horaFin);
            
            ResultSet rs = cs.executeQuery();
            if (rs.next()) {
                int conflictos = rs.getInt("conflictos");
                System.out.println("⚠️ Conflictos encontrados: " + conflictos);
                return conflictos > 0;
            }
            
        } catch (SQLException e) {
            System.err.println("Error al validar conflicto: " + e.getMessage());
            e.printStackTrace();
        }
        
        return true; // En caso de error, asumir conflicto
    }

    /**
     * Registrar curso completo con horarios
     */
    public Map<String, Object> registrarCurso(String nombre, int gradoId, int profesorId,
            int creditos, int turnoId, String descripcion, String area, String horariosJson) {
        
        Map<String, Object> resultado = new HashMap<>();
        String sql = "{CALL registrar_curso_completo(?, ?, ?, ?, ?, ?, ?, ?)}";
        
        try (Connection con = Conexion.getConnection();
             CallableStatement cs = con.prepareCall(sql)) {
            
            cs.setString(1, nombre);
            cs.setInt(2, gradoId);
            cs.setInt(3, profesorId);
            cs.setInt(4, creditos);
            cs.setInt(5, turnoId);
            cs.setString(6, descripcion);
            cs.setString(7, area);
            cs.setString(8, horariosJson);
            
            ResultSet rs = cs.executeQuery();
            if (rs.next()) {
                resultado.put("curso_id", rs.getInt("curso_id"));
                resultado.put("mensaje", rs.getString("mensaje"));
                resultado.put("detalle", rs.getString("detalle"));
                resultado.put("exito", rs.getInt("curso_id") > 0);
                
                System.out.println("✅ " + rs.getString("mensaje"));
            }
            
        } catch (SQLException e) {
            System.err.println("Error al registrar curso: " + e.getMessage());
            resultado.put("exito", false);
            resultado.put("mensaje", "Error al registrar curso");
            resultado.put("detalle", e.getMessage());
            e.printStackTrace();
        }
        
        return resultado;
    }
    
    /**
 * Obtiene profesores disponibles según el curso Y el turno
 */
            public List<Map<String, Object>> obtenerProfesoresPorCursoYTurno(String nombreCurso, int turnoId) {
            List<Map<String, Object>> profesores = new ArrayList<>();

            // Primero obtenemos el área del curso
            String sqlArea = "SELECT area FROM curso WHERE nombre = ? AND activo = 1 AND eliminado = 0 LIMIT 1";
            String areaCurso = null;

            try (Connection conn = Conexion.getConnection();
                 PreparedStatement pstmt = conn.prepareStatement(sqlArea)) {

                pstmt.setString(1, nombreCurso);
                ResultSet rs = pstmt.executeQuery();

                if (rs.next()) {
                    areaCurso = rs.getString("area");
                    System.out.println("Área del curso '" + nombreCurso + "': " + areaCurso);
                } else {
                    System.out.println("No se encontró el curso: " + nombreCurso);
                    return profesores;
                }

            } catch (SQLException e) {
                System.err.println("Error al obtener área del curso: " + e.getMessage());
                return profesores;
            }

            // Ahora buscamos profesores 
            String sql = "SELECT DISTINCT " +
                         "    prof.id, " +
                         "    CONCAT(p.nombres, ' ', p.apellidos) as nombre_completo, " +
                         "    prof.especialidad, " +
                         "    prof.codigo_profesor, " +
                         "    p.apellidos, " + 
                         "    p.nombres " +      
                         "FROM profesor prof " +
                         "INNER JOIN persona p ON prof.persona_id = p.id " +
                         "WHERE prof.activo = 1 " +
                         "AND prof.eliminado = 0 " +
                         "AND prof.estado = 'ACTIVO' " +
                         "AND prof.turno_id = ? " +
                         "AND ( " +
                         "    LOWER(prof.especialidad) LIKE LOWER(CONCAT('%', ?, '%')) " +
                         "    OR LOWER(?) LIKE LOWER(CONCAT('%', prof.especialidad, '%')) " +
                         "    OR LOWER(prof.especialidad) IN ('general', 'multidisciplinario') " +
                         ") " +
                         "ORDER BY p.apellidos, p.nombres";  

            try (Connection conn = Conexion.getConnection();
                 PreparedStatement pstmt = conn.prepareStatement(sql)) {

                pstmt.setInt(1, turnoId);
                pstmt.setString(2, areaCurso);
                pstmt.setString(3, areaCurso);

                System.out.println("Buscando profesores con:");
                System.out.println("   - Turno ID: " + turnoId);
                System.out.println("   - Área/Especialidad: " + areaCurso);

                ResultSet rs = pstmt.executeQuery();

                while (rs.next()) {
                    Map<String, Object> profesor = new HashMap<>();
                    profesor.put("id", rs.getInt("id"));
                    profesor.put("nombre_completo", rs.getString("nombre_completo"));
                    profesor.put("especialidad", rs.getString("especialidad"));
                    profesor.put("codigo_profesor", rs.getString("codigo_profesor"));
                    profesores.add(profesor);

                    System.out.println("   ✅ " + rs.getString("nombre_completo") + " - " + rs.getString("especialidad"));
                }

                System.out.println("Total profesores encontrados: " + profesores.size());

            } catch (SQLException e) {
                System.err.println("Error al obtener profesores: " + e.getMessage());
                e.printStackTrace();
            }

            return profesores;
        }
}