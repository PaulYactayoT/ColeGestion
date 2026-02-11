package modelo;

import java.sql.*;
import java.util.*;
import conexion.Conexion;

public class RegistroCursoDAO {

    /**
     * ============================================================
     * MÉTODO: obtenerTurnos
     * ============================================================
     */
    public List<Map<String, Object>> obtenerTurnos() {
        List<Map<String, Object>> turnos = new ArrayList<>();
        String sql = "SELECT id, nombre, hora_inicio, hora_fin " +
                     "FROM turno " +
                     "WHERE activo = 1 AND eliminado = 0 " +
                     "ORDER BY id";
        
        try (Connection conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Map<String, Object> turno = new HashMap<>();
                turno.put("id", rs.getInt("id"));
                turno.put("nombre", rs.getString("nombre"));
                turno.put("hora_inicio", rs.getTime("hora_inicio"));
                turno.put("hora_fin", rs.getTime("hora_fin"));
                turnos.add(turno);
            }
            
            System.out.println("DAO - Turnos obtenidos: " + turnos.size());
            
        } catch (SQLException e) {
            System.err.println("Error al obtener turnos: " + e.getMessage());
            e.printStackTrace();
        }
        
        return turnos;
    }

    /**
     * ============================================================
     * MÉTODO: obtenerGradosPorNivel
     * ============================================================
     */
    public List<Map<String, Object>> obtenerGradosPorNivel(String nivel) {
        List<Map<String, Object>> grados = new ArrayList<>();
        String sql = "CALL obtener_grados_por_nivel(?)";
        
        try (Connection conn = Conexion.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            
            cs.setString(1, nivel);
            ResultSet rs = cs.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> grado = new HashMap<>();
                grado.put("id", rs.getInt("id"));
                grado.put("nombre", rs.getString("nombre"));
                grado.put("nivel", rs.getString("nivel"));
                grado.put("orden", rs.getInt("orden"));
                grados.add(grado);
            }
            
            System.out.println("DAO - Grados obtenidos para nivel " + nivel + ": " + grados.size());
            
        } catch (SQLException e) {
            System.err.println("Error al obtener grados por nivel: " + e.getMessage());
            e.printStackTrace();
        }
        
        return grados;
    }

    /**
     * ============================================================
     * MÉTODO: obtenerCursosPorNivel
     * ============================================================
     */
    public List<Map<String, Object>> obtenerCursosPorNivel(String nivel) {
        List<Map<String, Object>> cursos = new ArrayList<>();

        String sql = "SELECT DISTINCT " +
                    "    c.nombre, " +
                    "    a.nombre as area, " +
                    "    MIN(c.id) as id_ejemplo " +
                    "FROM curso c " +
                    "INNER JOIN grado g ON c.grado_id = g.id " +
                    "INNER JOIN area a ON c.area_id = a.id " +
                    "WHERE c.activo = 1 AND c.eliminado = 0 " +
                    "AND (g.nivel COLLATE utf8mb4_unicode_ci = ? COLLATE utf8mb4_unicode_ci " +
                    "     OR ? = 'TODOS') " +
                    "GROUP BY c.nombre, a.nombre " +
                    "ORDER BY a.nombre, c.nombre";

        try (Connection conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, nivel);
            ps.setString(2, nivel);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Map<String, Object> curso = new HashMap<>();
                curso.put("nombre", rs.getString("nombre"));
                curso.put("area", rs.getString("area"));
                curso.put("id_ejemplo", rs.getInt("id_ejemplo"));
                cursos.add(curso);
            }

            System.out.println("DAO - Cursos obtenidos para nivel " + nivel + ": " + cursos.size());

        } catch (SQLException e) {
            System.err.println("Error al obtener cursos por nivel: " + e.getMessage());
            e.printStackTrace();
        }

        return cursos;
    }

    /**
     * ============================================================
     * MÉTODO: obtenerProfesoresPorCursoTurnoNivel
     * ============================================================
     */
    public List<Map<String, Object>> obtenerProfesoresPorCursoTurnoNivel(String curso, int turnoId, String nivel) {
        List<Map<String, Object>> profesores = new ArrayList<>();
        String sql = "CALL obtener_profesores_por_curso_turno_nivel(?, ?, ?)";
        
        System.out.println("\n=== DAO: OBTENIENDO PROFESORES ===");
        System.out.println("📋 Parámetros recibidos:");
        System.out.println("  - Curso: '" + curso + "'");
        System.out.println("  - Turno ID: " + turnoId);
        System.out.println("  - Nivel: '" + nivel + "'");
        
        try (Connection conn = Conexion.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            
            cs.setString(1, curso);
            cs.setInt(2, turnoId);
            cs.setString(3, nivel);
            
            System.out.println("📡 Ejecutando stored procedure: " + sql);
            
            ResultSet rs = cs.executeQuery();
            
            int count = 0;
            while (rs.next()) {
                count++;
                Map<String, Object> profesor = new HashMap<>();
                profesor.put("id", rs.getInt("id"));
                profesor.put("nombre_completo", rs.getString("nombre_completo"));
                profesor.put("especialidad", rs.getString("especialidad"));
                profesor.put("email", rs.getString("email"));
                profesor.put("telefono", rs.getString("telefono"));
                profesores.add(profesor);
                
                System.out.println("  Profesor " + count + ": " + rs.getString("nombre_completo"));
            }
            
            System.out.println("✅ Total profesores encontrados: " + profesores.size());
            
        } catch (SQLException e) {
            System.err.println("Error en DAO obtenerProfesoresPorCursoTurnoNivel: " + e.getMessage());
            e.printStackTrace();
        }
        
        return profesores;
    }

    /**
     * ============================================================
     * MÉTODO NUEVO: validarConflictosHorario
     * ============================================================
     */
    public Map<String, Object> validarConflictosHorario(
            int profesorId, int turnoId, String horariosJson) {
        
        Map<String, Object> resultado = new HashMap<>();
        resultado.put("tiene_conflicto", false);
        resultado.put("mensaje", "");
        
        String sql = "{CALL validar_conflicto_horario_completo(?, ?, ?, ?, ?)}";
        
        try (Connection conn = Conexion.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            
            // Parámetros IN
            cs.setInt(1, profesorId);
            cs.setInt(2, turnoId);
            cs.setString(3, horariosJson);
            
            // Parámetros OUT
            cs.registerOutParameter(4, Types.BOOLEAN); // p_tiene_conflicto
            cs.registerOutParameter(5, Types.VARCHAR); // p_mensaje_conflicto
            
            cs.execute();
            
            boolean tieneConflicto = cs.getBoolean(4);
            String mensajeConflicto = cs.getString(5);
            
            resultado.put("tiene_conflicto", tieneConflicto);
            resultado.put("mensaje", mensajeConflicto != null ? mensajeConflicto : "");
            
            if (tieneConflicto) {
                System.out.println("⚠️ Conflicto detectado: " + mensajeConflicto);
            } else {
                System.out.println("✅ No hay conflictos de horario");
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error al validar conflictos: " + e.getMessage());
            e.printStackTrace();
            resultado.put("tiene_conflicto", true);
            resultado.put("mensaje", "Error al validar horarios: " + e.getMessage());
        }
        
        return resultado;
    }

    /**
     * ============================================================
     * MÉTODO ACTUALIZADO: registrarCursoCompleto
     * ============================================================
     */
    public Map<String, Object> registrarCursoCompleto(
            String nombre, int gradoId, int profesorId, int turnoId,
            String descripcion, String area, String horariosJson) {
        
        Map<String, Object> resultado = new HashMap<>();
        
        // Primero validar conflictos
        System.out.println("\n=== VALIDANDO CONFLICTOS DE HORARIO ===");
        Map<String, Object> validacion = validarConflictosHorario(profesorId, turnoId, horariosJson);
        
        if ((Boolean) validacion.get("tiene_conflicto")) {
            resultado.put("exito", false);
            resultado.put("mensaje", "Conflicto de horario");
            resultado.put("detalle", validacion.get("mensaje"));
            System.out.println("❌ Registro cancelado por conflicto");
            return resultado;
        }
        
        // Si no hay conflictos, proceder con el registro usando el procedimiento V2
        String sql = "CALL registrar_curso_completo(?, ?, ?, ?, ?, ?, ?)";
        
        System.out.println("\n=== REGISTRANDO CURSO EN BD ===");
        System.out.println("Nombre: " + nombre);
        System.out.println("Grado ID: " + gradoId);
        System.out.println("Profesor ID: " + profesorId);
        System.out.println("Turno ID: " + turnoId);
        System.out.println("Área: " + area);
        System.out.println("Horarios JSON: " + horariosJson);
        
        try (Connection conn = Conexion.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            
            cs.setString(1, nombre);
            cs.setInt(2, gradoId);
            cs.setInt(3, profesorId);
            cs.setInt(4, turnoId);
            cs.setString(5, descripcion);
            cs.setString(6, area);
            cs.setString(7, horariosJson);
            
            ResultSet rs = cs.executeQuery();
            
            if (rs.next()) {
                int exito = rs.getInt("exito");
                String mensaje = rs.getString("mensaje");
                String detalle = rs.getString("detalle");
                
                if (exito == 1) {
                    resultado.put("exito", true);
                    resultado.put("mensaje", mensaje);
                    resultado.put("detalle", detalle);
                    
                    if (detalle != null && detalle.startsWith("ID: ")) {
                        try {
                            int cursoId = Integer.parseInt(detalle.substring(4).trim());
                            resultado.put("curso_id", cursoId);
                            System.out.println("✅ Curso registrado exitosamente - ID: " + cursoId);
                        } catch (NumberFormatException e) {
                            System.out.println("✅ Curso registrado exitosamente");
                        }
                    } else {
                        System.out.println("✅ Curso registrado exitosamente");
                    }
                } else {
                    resultado.put("exito", false);
                    resultado.put("mensaje", mensaje);
                    resultado.put("detalle", detalle);
                    System.out.println("❌ Error al registrar: " + detalle);
                }
            }
            
        } catch (SQLException e) {
            System.err.println("Error SQL al registrar curso: " + e.getMessage());
            e.printStackTrace();
            resultado.put("exito", false);
            resultado.put("mensaje", "Error al registrar curso");
            resultado.put("detalle", e.getMessage());
        }
        
        return resultado;
    }

    /**
     * ============================================================
     * MÉTODO: eliminarCurso
     * ============================================================
     */
    public boolean eliminarCurso(int cursoId) {
        String sql = "UPDATE curso SET eliminado = 1, activo = 0 WHERE id = ?";
        
        try (Connection conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, cursoId);
            int filasAfectadas = ps.executeUpdate();
            
            return filasAfectadas > 0;
            
        } catch (SQLException e) {
            System.err.println("Error al eliminar curso: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * ============================================================
     * MÉTODO: actualizarCurso
     * ============================================================
     */
    public Map<String, Object> actualizarCurso(
            int cursoId, String nombre, int gradoId, int profesorId, int turnoId,
            String descripcion, String area, String horariosJson) {
        
        Map<String, Object> resultado = new HashMap<>();
        String sql = "CALL actualizar_curso_completo(?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = Conexion.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            
            cs.setInt(1, cursoId);
            cs.setString(2, nombre);
            cs.setInt(3, gradoId);
            cs.setInt(4, profesorId);
            cs.setInt(5, turnoId);
            cs.setString(6, descripcion);
            cs.setString(7, area);
            cs.setString(8, horariosJson);
            
            ResultSet rs = cs.executeQuery();
            
            if (rs.next()) {
                int exito = rs.getInt("exito");
                String mensaje = rs.getString("mensaje");
                
                resultado.put("exito", exito == 1);
                resultado.put("mensaje", mensaje);
            }
            
        } catch (SQLException e) {
            System.err.println("Error al actualizar curso: " + e.getMessage());
            e.printStackTrace();
            resultado.put("exito", false);
            resultado.put("mensaje", "Error al actualizar curso: " + e.getMessage());
        }
        
        return resultado;
    }

    /**
     * ============================================================
     * MÉTODO: obtenerAulas
     * ============================================================
     */
    public List<Map<String, Object>> obtenerAulas() {
        List<Map<String, Object>> aulas = new ArrayList<>();
        String sql = "{CALL sp_listar_aulas()}";

        try (Connection conn = Conexion.getConnection();
             CallableStatement cs = conn.prepareCall(sql);
             ResultSet rs = cs.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> aula = new HashMap<>();
                aula.put("id", rs.getInt("id"));
                aula.put("nombre", rs.getString("nombre"));
                aula.put("capacidad", rs.getInt("capacidad")); 
                aulas.add(aula);
            }
            
            System.out.println("DAO - Aulas obtenidas: " + aulas.size());
            
        } catch (SQLException e) {
            System.err.println("Error al obtener aulas: " + e.getMessage());
            e.printStackTrace();
        }
        return aulas;
    }

    /**
     * ============================================================
     * MÉTODO: obtenerDisponibilidadAprobada
     * ============================================================
     */
    public List<Map<String, Object>> obtenerDisponibilidadAprobada(int profesorId) {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql = "SELECT dia_semana, hora_inicio, hora_fin FROM disponibilidad_profesor " +
                     "WHERE profesor_id = ? AND estado = 'APROBADO' AND activo = 1";
        
        try (Connection conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, profesorId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> d = new HashMap<>();
                    d.put("dia", rs.getString("dia_semana"));
                    d.put("inicio", rs.getTime("hora_inicio").toString());
                    d.put("fin", rs.getTime("hora_fin").toString());
                    lista.add(d);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }

    /**
     * ============================================================
     * MÉTODO: obtenerDisponibilidadAprobadaDetallada
     * ============================================================
     */
    public List<Map<String, Object>> obtenerDisponibilidadAprobadaDetallada(int profesorId) {
        List<Map<String, Object>> lista = new ArrayList<>();

        String sql = "SELECT " +
                    "    d.id, " +
                    "    d.dia_semana, " +
                    "    d.hora_inicio, " +
                    "    d.hora_fin, " +
                    "    d.turno_id, " +
                    "    t.nombre as turno_nombre " +
                    "FROM disponibilidad_profesor d " +
                    "INNER JOIN turno t ON d.turno_id = t.id " +
                    "WHERE d.profesor_id = ? " +
                    "AND d.estado = 'APROBADO' " +
                    "AND d.activo = 1 " +
                    "AND d.eliminado = 0 " +
                    "ORDER BY " +
                    "    FIELD(d.dia_semana, 'LUNES', 'MARTES', 'MIERCOLES', 'JUEVES', 'VIERNES', 'SABADO', 'DOMINGO'), " +
                    "    d.hora_inicio";

        try (Connection conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, profesorId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> disponibilidad = new HashMap<>();
                    disponibilidad.put("id", rs.getInt("id"));
                    disponibilidad.put("dia", rs.getString("dia_semana"));
                    disponibilidad.put("hora_inicio", rs.getTime("hora_inicio").toString());
                    disponibilidad.put("hora_fin", rs.getTime("hora_fin").toString());
                    disponibilidad.put("turno_id", rs.getInt("turno_id"));
                    disponibilidad.put("turno_nombre", rs.getString("turno_nombre"));

                    lista.add(disponibilidad);
                }
            }

            System.out.println("DAO - Disponibilidades aprobadas para profesor " + profesorId + ": " + lista.size());

        } catch (SQLException e) {
            System.err.println("Error al obtener disponibilidad aprobada: " + e.getMessage());
            e.printStackTrace();
        }

        return lista;
    }

    /**
     * ============================================================
     * MÉTODO: validarDisponibilidadProfesor
     * ============================================================
     */
    public Map<String, Object> validarDisponibilidadProfesor(
            int profesorId, int turnoId, String diaSemana, 
            String horaInicio, String horaFin) {

        Map<String, Object> resultado = new HashMap<>();
        resultado.put("disponible", false);
        resultado.put("mensaje", "Profesor no disponible");

        String sql = "SELECT COUNT(*) as total " +
                    "FROM disponibilidad_profesor " +
                    "WHERE profesor_id = ? " +
                    "AND turno_id = ? " +
                    "AND dia_semana = ? " +
                    "AND estado = 'APROBADO' " +
                    "AND activo = 1 " +
                    "AND eliminado = 0 " +
                    "AND ? >= hora_inicio " +
                    "AND ? <= hora_fin";

        try (Connection conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, profesorId);
            ps.setInt(2, turnoId);
            ps.setString(3, diaSemana.toUpperCase());
            ps.setString(4, horaInicio);
            ps.setString(5, horaFin);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt("total") > 0) {
                    resultado.put("disponible", true);
                    resultado.put("mensaje", "Profesor disponible en ese horario");
                } else {
                    resultado.put("mensaje", "El profesor no tiene disponibilidad APROBADA para " + 
                                           diaSemana + " de " + horaInicio + " a " + horaFin);
                }
            }

        } catch (SQLException e) {
            System.err.println("Error al validar disponibilidad: " + e.getMessage());
            resultado.put("mensaje", "Error al validar disponibilidad: " + e.getMessage());
            e.printStackTrace();
        }

        return resultado;
    }

    /**
     * ============================================================
     * MÉTODO: obtenerHorariosProfesor
     * ============================================================
     */
    public List<Map<String, Object>> obtenerHorariosProfesor(int profesorId, int turnoId) {
        List<Map<String, Object>> horarios = new ArrayList<>();
        
        String sql = "SELECT " +
                    "    c.nombre as curso, " +
                    "    hc.dia_semana, " +
                    "    hc.hora_inicio, " +
                    "    hc.hora_fin, " +
                    "    a.nombre as aula " +
                    "FROM horario_clase hc " +
                    "INNER JOIN curso c ON hc.curso_id = c.id " +
                    "LEFT JOIN aula a ON hc.aula_id = a.id " +
                    "WHERE hc.profesor_id = ? " +
                    "AND hc.turno_id = ? " +
                    "AND hc.activo = 1 " +
                    "AND hc.eliminado = 0 " +
                    "AND c.activo = 1 " +
                    "AND c.eliminado = 0 " +
                    "ORDER BY " +
                    "    FIELD(hc.dia_semana, 'LUNES', 'MARTES', 'MIERCOLES', 'JUEVES', 'VIERNES', 'SABADO', 'DOMINGO'), " +
                    "    hc.hora_inicio";
        
        try (Connection conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, profesorId);
            ps.setInt(2, turnoId);
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> horario = new HashMap<>();
                    horario.put("curso", rs.getString("curso"));
                    horario.put("dia", rs.getString("dia_semana"));
                    horario.put("hora_inicio", rs.getTime("hora_inicio").toString());
                    horario.put("hora_fin", rs.getTime("hora_fin").toString());
                    horario.put("aula", rs.getString("aula"));
                    horarios.add(horario);
                }
            }
            
        } catch (SQLException e) {
            System.err.println("Error al obtener horarios del profesor: " + e.getMessage());
            e.printStackTrace();
        }
        
        return horarios;
    }

    /**
     * ============================================================
     * MÉTODO: obtenerAreasPorNivel
     * ============================================================
     */
    public List<Map<String, Object>> obtenerAreasPorNivel(String nivel) {
        List<Map<String, Object>> areas = new ArrayList<>();

        String sql = "SELECT " +
                    "    a.id, " +
                    "    a.nombre, " +
                    "    a.descripcion, " +
                    "    a.nivel, " +
                    "    COUNT(DISTINCT c.id) as total_cursos " +
                    "FROM area a " +
                    "LEFT JOIN curso c ON a.id = c.area_id AND c.activo = 1 AND c.eliminado = 0 " +
                    "WHERE a.activo = 1 AND a.eliminado = 0 " +
                    "AND (a.nivel COLLATE utf8mb4_unicode_ci = ? COLLATE utf8mb4_unicode_ci " +
                    "     OR a.nivel COLLATE utf8mb4_unicode_ci = 'TODOS' " +
                    "     OR ? = 'TODOS') " +
                    "GROUP BY a.id, a.nombre, a.descripcion, a.nivel " +
                    "ORDER BY a.nombre";

        try (Connection conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, nivel);
            ps.setString(2, nivel);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Map<String, Object> area = new HashMap<>();
                area.put("id", rs.getInt("id"));
                area.put("nombre", rs.getString("nombre"));
                area.put("descripcion", rs.getString("descripcion"));
                area.put("nivel", rs.getString("nivel"));
                area.put("total_cursos", rs.getInt("total_cursos"));
                areas.add(area);
            }

            System.out.println("DAO - Áreas obtenidas para nivel " + nivel + ": " + areas.size());

        } catch (SQLException e) {
            System.err.println("Error al obtener áreas por nivel: " + e.getMessage());
            e.printStackTrace();
        }

        return areas;
    }

    /**
     * ============================================================
     * MÉTODO: obtenerCursosPorArea
     * ============================================================
     */
    public List<Map<String, Object>> obtenerCursosPorArea(String area) {
        List<Map<String, Object>> cursos = new ArrayList<>();
        
        String sql = "SELECT DISTINCT c.nombre, MIN(c.id) as id_ejemplo " +
                     "FROM curso c " +
                     "INNER JOIN area a ON c.area_id = a.id " +
                     "WHERE c.activo = 1 AND c.eliminado = 0 " +
                     "AND a.nombre = ? " +
                     "GROUP BY c.nombre " +
                     "ORDER BY c.nombre";
        
        try (Connection conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, area);
            
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> curso = new HashMap<>();
                curso.put("nombre", rs.getString("nombre"));
                curso.put("id_ejemplo", rs.getInt("id_ejemplo"));
                curso.put("area", area);
                cursos.add(curso);
            }
            
            System.out.println("DAO - Cursos obtenidos para área " + area + ": " + cursos.size());
            
        } catch (SQLException e) {
            System.err.println("Error al obtener cursos por área: " + e.getMessage());
            e.printStackTrace();
        }
        
        return cursos;
    }

    /**
     * ============================================================
     * MÉTODO: validarHorarioEnTurno
     * ============================================================
     */
    public Map<String, Object> validarHorarioEnTurno(int turnoId, String horaInicio, String horaFin) {
        Map<String, Object> resultado = new HashMap<>();
        String sql = "SELECT hora_inicio, hora_fin FROM turno WHERE id = ?";

        try (Connection conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, turnoId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Time turnoInicio = rs.getTime("hora_inicio");
                Time turnoFin = rs.getTime("hora_fin");
                Time inicio = Time.valueOf(horaInicio + ":00");
                Time fin = Time.valueOf(horaFin + ":00");

                boolean dentroRango = !inicio.before(turnoInicio) && !fin.after(turnoFin);

                resultado.put("dentro_rango", dentroRango);
                resultado.put("turno_inicio", turnoInicio.toString());
                resultado.put("turno_fin", turnoFin.toString());
                resultado.put("mensaje", dentroRango ? "Horario válido" : 
                    "El horario debe estar entre " + turnoInicio + " y " + turnoFin);
            }

        } catch (SQLException e) {
            System.err.println("Error al validar horario en turno: " + e.getMessage());
            resultado.put("dentro_rango", false);
            resultado.put("mensaje", "Error en validación");
        }

        return resultado;
    }
    
    /**
         * ============================================================
         * MÉTODO: obtenerCursosPorArea
         * ============================================================
         * Obtiene los cursos que pertenecen a un área específica
         */
       public List<Map<String, Object>> obtenerCursosPorAreaYNivel(String area, String nivel) {
        List<Map<String, Object>> cursos = new ArrayList<>();

        // VALIDACIÓN
        if (area == null || area.trim().isEmpty() || "undefined".equalsIgnoreCase(area)) {
            System.err.println("️ ADVERTENCIA: El parámetro 'area' es inválido: " + area);
            return cursos;
        }

        if (nivel == null || nivel.trim().isEmpty() || "undefined".equalsIgnoreCase(nivel)) {
            System.err.println("️ ADVERTENCIA: El parámetro 'nivel' es inválido: " + nivel);
            return cursos;
        }

        System.out.println("? Buscando cursos para área: '" + area + "' y nivel: '" + nivel + "'");

        // ✅ CONSULTA CORREGIDA: Sin usar grado_id
        String sql = "SELECT DISTINCT " +
                    "    c.id, " +
                    "    c.nombre, " +
                    "    a.nombre as area_nombre, " +
                    "    c.descripcion, " +
                    "    c.creditos, " +
                    "    c.horas_semanales, " +
                    "    c.nivel " +
                    "FROM curso c " +
                    "INNER JOIN area a ON c.area_id = a.id " +
                    "WHERE a.nombre = ? " +
                    "AND c.nivel = ? " +
                    "AND c.activo = 1 " +
                    "AND c.eliminado = 0 " +
                    "ORDER BY c.nombre";

        try (Connection conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, area.trim());
            ps.setString(2, nivel.trim());

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Map<String, Object> curso = new HashMap<>();
                curso.put("id", rs.getInt("id"));
                curso.put("nombre", rs.getString("nombre"));
                curso.put("area", rs.getString("area_nombre"));
                curso.put("descripcion", rs.getString("descripcion"));
                curso.put("creditos", rs.getInt("creditos"));
                curso.put("horas_semanales", rs.getInt("horas_semanales"));
                curso.put("nivel", rs.getString("nivel"));
                cursos.add(curso);
            }

            System.out.println(" Cursos encontrados para área '" + area + "' y nivel '" + nivel + "': " + cursos.size());

            // Debug: Mostrar los cursos encontrados
            if (cursos.isEmpty()) {
                System.out.println("️ No se encontraron cursos. Verifica que:");
                System.out.println("   1. El área existe en la tabla 'area' con nombre exacto: " + area);
                System.out.println("   2. Existen cursos activos para esa área");
                System.out.println("   3. Los cursos tienen el nivel correcto: " + nivel);
            } else {
                cursos.forEach(c -> System.out.println("   - " + c.get("nombre")));
            }

        } catch (SQLException e) {
            System.err.println(" Error SQL al obtener cursos: " + e.getMessage());
            e.printStackTrace();
        }

        return cursos;
    }
}