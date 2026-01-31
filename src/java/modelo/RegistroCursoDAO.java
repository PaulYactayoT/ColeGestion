package modelo;

import java.sql.*;
import java.util.*;
import conexion.Conexion;


public class RegistroCursoDAO {

    /**
     * ============================================================
     * MÉTODO: obtenerTurnos
     * ============================================================
     * Razón: Obtener los turnos disponibles (MAÑANA, TARDE) para
     * mostrarlos en el select del formulario
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
     * Razón: Cuando el usuario selecciona un nivel (INICIAL, PRIMARIA, 
     * SECUNDARIA), este método retorna solo los grados de ese nivel.
     * 
     * Ejemplo:
     * - INICIAL → 3 años, 4 años, 5 años
     * - PRIMARIA → 1°, 2°, 3°, 4°, 5°, 6°
     * - SECUNDARIA → 1°, 2°, 3°, 4°, 5°
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
     * Razón: Cada nivel educativo tiene sus propios cursos según
     * el área académica:
     * 
     * - INICIAL: Psicomotricidad, Lenguaje Oral, Números Básicos, etc.
     * - PRIMARIA: Matemática, Comunicación, Personal Social, etc.
     * - SECUNDARIA: Álgebra, Geometría, Física, Química, etc.
     * 
     * Este método evita duplicados agrupando por nombre y área.
     */
        public List<Map<String, Object>> obtenerCursosPorNivel(String nivel) {
             List<Map<String, Object>> cursos = new ArrayList<>();

             // CONSULTA DIRECTA CON COLLATE
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

                 System.out.println(" DAO - Cursos obtenidos para nivel " + nivel + ": " + cursos.size());

             } catch (SQLException e) {
                 System.err.println(" Error al obtener cursos por nivel: " + e.getMessage());
                 e.printStackTrace();
             }

             return cursos;
         }

    /**
     * ============================================================
     * MÉTODO: obtenerProfesoresPorCursoTurnoNivel
     * ============================================================
     * Razón: Los profesores deben filtrarse por 3 criterios:
     * 
     * 1. TURNO: Solo profesores que trabajen en ese turno
     *    (un profesor de MAÑANA no puede dar clases en TARDE)
     * 
     * 2. NIVEL: Solo profesores que enseñen en ese nivel
     *    (un profesor de INICIAL no puede dar clases en SECUNDARIA,
     *     a menos que tenga nivel 'TODOS')
     * 
     * 3. ESPECIALIDAD: Debe coincidir con el área del curso
     *    (un profesor de Matemática no puede dar Historia)
     * 
     * Ejemplo:
     * Si selecciono "Computación" (área: Tecnología) en turno TARDE
     * para nivel PRIMARIA, solo veré profesores que:
     * - Trabajen en turno TARDE
     * - Enseñen en PRIMARIA (o TODOS)
     * - Su especialidad sea Computación/Tecnología
     */
    public List<Map<String, Object>> obtenerProfesoresPorCursoTurnoNivel(
            String nombreCurso, int turnoId, String nivel) {
        
        List<Map<String, Object>> profesores = new ArrayList<>();
        
        // CONSULTA DIRECTA - más confiable que stored procedure
        String sql = "SELECT DISTINCT " +
                    "    p.id, " +
                    "    per.apellidos, " +                          
                    "    per.nombres, " +                            
                    "    CONCAT(per.nombres, ' ', per.apellidos) as nombre_completo, " +
                    "    a.nombre as especialidad, " +
                    "    p.codigo_profesor " +
                    "FROM profesor p " +
                    "INNER JOIN persona per ON p.persona_id = per.id " +
                    "INNER JOIN area a ON p.area_id = a.id " +
                    "WHERE p.activo = 1 AND p.eliminado = 0 " +
                    "AND p.estado = 'ACTIVO' " +
                    "AND p.turno_id = ? " +
                    "AND (p.nivel COLLATE utf8mb4_unicode_ci = ? COLLATE utf8mb4_unicode_ci " +
                    "     OR p.nivel COLLATE utf8mb4_unicode_ci = 'TODOS') " +
                    "AND a.nombre COLLATE utf8mb4_unicode_ci = (" +
                    "    SELECT DISTINCT a2.nombre " +
                    "    FROM curso c2 " +
                    "    INNER JOIN area a2 ON c2.area_id = a2.id " +
                    "    WHERE c2.nombre COLLATE utf8mb4_unicode_ci = ? COLLATE utf8mb4_unicode_ci " +
                    "    AND c2.activo = 1 AND c2.eliminado = 0 " +
                    "    LIMIT 1" +
                    ") " +
                    "ORDER BY per.apellidos, per.nombres";

        try (Connection conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, turnoId);
            ps.setString(2, nivel);
            ps.setString(3, nombreCurso);
            
            System.out.println(" DAO - Buscando profesores para:");
            System.out.println("  Curso: " + nombreCurso);
            System.out.println("  Turno ID: " + turnoId);
            System.out.println("  Nivel: " + nivel);
            
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> profesor = new HashMap<>();
                profesor.put("id", rs.getInt("id"));
                profesor.put("nombre_completo", rs.getString("nombre_completo"));
                profesor.put("especialidad", rs.getString("especialidad"));
                profesor.put("codigo_profesor", rs.getString("codigo_profesor"));
                profesores.add(profesor);
            }
            
            System.out.println(" DAO - Profesores encontrados: " + profesores.size());
            
        } catch (SQLException e) {
            System.err.println(" Error al obtener profesores: " + e.getMessage());
            e.printStackTrace();
        }
        
        return profesores;
    }

    /**
     * ============================================================
     * MÉTODO: validarLimiteCursos
     * ============================================================
     * Razón: Un profesor NO puede tener más de 4 cursos en un mismo día.
     * 
     * Esto es para evitar sobrecarga de trabajo y garantizar la calidad
     * de la enseñanza.
     * 
     * Ejemplo:
     * Si el profesor ya tiene 4 cursos el LUNES en turno MAÑANA,
     * no puede agregar un 5to curso ese mismo día.
     */
    public int validarLimiteCursos(int profesorId, int turnoId, String diaSemana) {
        int cursosEnDia = 0;
        String sql = "CALL validar_limite_cursos_profesor(?, ?, ?)";
        
        try (Connection conn = Conexion.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            
            cs.setInt(1, profesorId);
            cs.setInt(2, turnoId);
            cs.setString(3, diaSemana);
            
            ResultSet rs = cs.executeQuery();
            
            if (rs.next()) {
                cursosEnDia = rs.getInt("cursos_en_dia");
            }
            
            System.out.println("DAO - Profesor " + profesorId + " tiene " + cursosEnDia + " cursos el " + diaSemana);
            
        } catch (SQLException e) {
            System.err.println("Error al validar límite de cursos: " + e.getMessage());
            e.printStackTrace();
        }
        
        return cursosEnDia;
    }

    /**
     * ============================================================
     * MÉTODO: validarConflictoHorario
     * ============================================================
     * Razón: Un profesor NO puede estar en dos lugares al mismo tiempo.
     * 
     * Se verifica que el nuevo horario NO se solape con horarios existentes.
     * 
     * Fórmula de detección de solapamiento:
     * (hora_inicio_nueva < hora_fin_existente) AND 
     * (hora_fin_nueva > hora_inicio_existente)
     * 
     * Ejemplo de conflicto:
     * - Horario existente: LUNES 08:00-09:30
     * - Nuevo horario: LUNES 09:00-10:00
     * HAY CONFLICTO (se solapan de 09:00-09:30)
     * 
     * Ejemplo sin conflicto:
     * - Horario existente: LUNES 08:00-09:00
     * - Nuevo horario: LUNES 09:00-10:00
     * NO HAY CONFLICTO (uno termina cuando empieza el otro)
     */
    public boolean validarConflictoHorario(int profesorId, int turnoId, 
            String diaSemana, String horaInicio, String horaFin) {
        
        boolean hayConflicto = false;
        String sql = "CALL validar_conflicto_horario_profesor(?, ?, ?, ?, ?)";
        
        try (Connection conn = Conexion.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            
            cs.setInt(1, profesorId);
            cs.setInt(2, turnoId);
            cs.setString(3, diaSemana);
            cs.setString(4, horaInicio);
            cs.setString(5, horaFin);
            
            ResultSet rs = cs.executeQuery();
            
            if (rs.next()) {
                hayConflicto = rs.getInt("conflictos") > 0;
            }
            
            System.out.println("DAO - Validación de conflicto:");
            System.out.println("  Día: " + diaSemana);
            System.out.println("  Horario: " + horaInicio + " - " + horaFin);
            System.out.println("  Conflicto: " + (hayConflicto ? "SÍ" : "NO"));
            
        } catch (SQLException e) {
            System.err.println("Error al validar conflicto de horario: " + e.getMessage());
            e.printStackTrace();
        }
        
        return hayConflicto;
    }

    /**
     * ============================================================
     * MÉTODO: registrarCursoCompleto
     * ============================================================
     * Razón: Guardar el curso con todos sus datos y horarios.
     * 
     * Este método:
     * 1. Llama al stored procedure que valida todo
     * 2. Inserta el curso en la tabla `curso`
     * 3. Inserta los horarios en la tabla `horario_clase`
     * 4. Registra la relación en `curso_profesor`
     * 5. Usa ELIMINACIÓN LÓGICA (eliminado=0, activo=1)
     * 
     * El stored procedure valida:
     * - Horarios dentro del turno (no antes ni después)
     * - Duración válida: 30min, 1h, 1.5h, 2h
     * - Máximo 4 cursos por día
     * - Sin conflictos de horarios
     * - Asignación de aula disponible
     */
    public Map<String, Object> registrarCursoCompleto(
            String nombre, int gradoId, int profesorId, int turnoId,
            String descripcion, String area, String horariosJson) {
        
        Map<String, Object> resultado = new HashMap<>();
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
                    
                    // Extraer el ID del curso desde el detalle (formato: "ID: 123")
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
     * Razón: NO eliminamos físicamente (DELETE FROM...) porque:
     * 
     * 1. Se perdería el historial académico
     * 2. Los reportes de años anteriores fallarían
     * 3. No podríamos recuperar el curso si fue error
     * 4. Es mejor práctica en sistemas empresariales
     * 
     * En su lugar, hacemos ELIMINACIÓN LÓGICA:
     * - Marcamos eliminado = 1
     * - Marcamos activo = 0
     * 
     * El curso sigue en la BD pero no aparece en las consultas
     * normales (porque todas filtran por eliminado = 0)
     */
    public boolean eliminarCurso(int cursoId) {
        String sql = "CALL eliminar_curso_logico(?)";
        
        System.out.println("\n=== ELIMINANDO CURSO ===");
        System.out.println("Curso ID: " + cursoId);
        
        try (Connection conn = Conexion.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            
            cs.setInt(1, cursoId);
            ResultSet rs = cs.executeQuery();
            
            if (rs.next()) {
                boolean exito = rs.getInt("resultado") == 1;
                System.out.println(exito ? " Curso eliminado" : "❌ Error al eliminar");
                return exito;
            }
            
        } catch (SQLException e) {
            System.err.println(" Error al eliminar curso: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }

    /**
     * ============================================================
     * MÉTODO: actualizarCurso
     * ============================================================
     * Razón: Permitir modificar un curso existente.
     * 
     * El proceso es:
     * 1. Actualizar los datos básicos del curso
     * 2. Marcar los horarios antiguos como eliminados
     * 3. Insertar los nuevos horarios
     * 4. Validar las mismas reglas que al crear
     */
    public Map<String, Object> actualizarCurso(
            int cursoId, String nombre, int gradoId, int profesorId, 
            int turnoId, String descripcion, String area, String horariosJson) {
        
        Map<String, Object> resultado = new HashMap<>();
        String sql = "CALL actualizar_curso_completo(?, ?, ?, ?, ?, ?, ?, ?)";
        
        System.out.println("\n=== ACTUALIZANDO CURSO ===");
        System.out.println("Curso ID: " + cursoId);
        System.out.println("Nuevo nombre: " + nombre);
        System.out.println("Grado ID: " + gradoId);
        System.out.println("Profesor ID: " + profesorId);
        System.out.println("Turno ID: " + turnoId);
        System.out.println("Área: " + area);
        System.out.println("Horarios JSON: " + horariosJson);
        
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
                
                if (exito == 1) {
                    resultado.put("exito", true);
                    resultado.put("mensaje", rs.getString("mensaje"));
                    resultado.put("detalle", rs.getString("detalle"));
                    System.out.println("Curso actualizado exitosamente");
                } else {
                    resultado.put("exito", false);
                    resultado.put("mensaje", rs.getString("mensaje"));
                    resultado.put("detalle", rs.getString("detalle"));
                    System.out.println("Error al actualizar: " + rs.getString("detalle"));
                }
            }
            
        } catch (SQLException e) {
            System.err.println("Error SQL al actualizar curso: " + e.getMessage());
            e.printStackTrace();
            resultado.put("exito", false);
            resultado.put("mensaje", "Error al actualizar curso");
            resultado.put("detalle", e.getMessage());
        }
        
        return resultado;
    }

    /**
     * ============================================================
     * MÉTODO: obtenerLimitesTurno
     * ============================================================
     * Razón: Para validar en JavaScript que los horarios estén
     * dentro del rango del turno seleccionado.
     * 
     * Retorna la hora de inicio y fin del turno para que
     * el formulario no permita seleccionar horarios fuera de rango.
     */
    public Map<String, Object> obtenerLimitesTurno(int turnoId) {
        Map<String, Object> limites = new HashMap<>();
        String sql = "SELECT hora_inicio, hora_fin FROM turno WHERE id = ?";
        
        try (Connection conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, turnoId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                limites.put("hora_inicio", rs.getTime("hora_inicio"));
                limites.put("hora_fin", rs.getTime("hora_fin"));
            }
            
        } catch (SQLException e) {
            System.err.println("Error al obtener límites de turno: " + e.getMessage());
            e.printStackTrace();
        }
        
        return limites;
    }
    
            /**
         * ============================================================
         * MÉTODO: obtenerAreasPorNivel
         * ============================================================
         * Obtiene las áreas académicas según el nivel educativo
         */
            public List<Map<String, Object>> obtenerAreasPorNivel(String nivel) {
            List<Map<String, Object>> areas = new ArrayList<>();

            // CONSULTA DIRECTA CON COLLATE EXPLÍCITO
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

                System.out.println(" DAO - Áreas obtenidas para nivel " + nivel + ": " + areas.size());

            } catch (SQLException e) {
                System.err.println(" Error al obtener áreas por nivel: " + e.getMessage());
                e.printStackTrace();
            }

            return areas;
        }

        /**
         * ============================================================
         * MÉTODO: obtenerCursosPorArea
         * ============================================================
         * Obtiene los cursos que pertenecen a un área específica
         */
       public List<Map<String, Object>> obtenerCursosPorArea(String area) {
            List<Map<String, Object>> cursos = new ArrayList<>();

            if (area == null || area.trim().isEmpty() || "undefined".equalsIgnoreCase(area) || "0".equals(area)) {
                System.err.println(" ADVERTENCIA: El parámetro 'area' es inválido: " + area);
                return cursos;
            }

            System.out.println(" Buscando cursos para área: '" + area + "'");

            // ✅ CONSULTA MEJORADA: Solo retorna UN curso por nombre
            String sql = "SELECT " +
                        "    MIN(c.id) as id, " +              
                        "    c.nombre, " +
                        "    a.nombre as area_nombre, " +
                        "    MIN(c.descripcion) as descripcion, " +
                        "    MIN(c.creditos) as creditos, " +
                        "    COUNT(DISTINCT g.id) as cantidad_grados " +
                        "FROM curso c " +
                        "INNER JOIN area a ON c.area_id = a.id " +
                        "INNER JOIN grado g ON c.grado_id = g.id " +
                        "WHERE a.nombre COLLATE utf8mb4_unicode_ci = ? COLLATE utf8mb4_unicode_ci " +
                        "AND c.activo = 1 AND c.eliminado = 0 " +
                        "GROUP BY c.nombre, a.nombre " +
                        "ORDER BY c.nombre";

            try (Connection conn = Conexion.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {

                ps.setString(1, area.trim());
                ResultSet rs = ps.executeQuery();

                while (rs.next()) {
                    Map<String, Object> curso = new HashMap<>();
                    curso.put("id", rs.getInt("id"));
                    curso.put("nombre", rs.getString("nombre"));
                    curso.put("area", rs.getString("area_nombre"));
                    curso.put("descripcion", rs.getString("descripcion"));
                    curso.put("creditos", rs.getInt("creditos"));
                    cursos.add(curso);
                }

                System.out.println(" Cursos únicos: " + cursos.size());

            } catch (SQLException e) {
                System.err.println(" Error: " + e.getMessage());
                e.printStackTrace();
            }

            return cursos;
        }

        /**
         * ============================================================
         * MÉTODO: validarHorarioEnTurno
         * ============================================================
         * Valida que el horario esté dentro del rango del turno
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
        * MÉTODO: obtenerCursosPorAreaYGrado
        * ============================================================
        * Obtiene los cursos de un área específica filtrados por el grado seleccionado.
        * Esto evita que aparezcan cursos de otros niveles educativos.
        * 
        * Por ejemplo:
        * - Si el usuario selecciona "3ero - PRIMARIA" y área "Idiomas"
        * - Solo debe ver "Inglés - Building Stage"
        * - NO debe ver "Discovery Stage" (Inicial) ni "Expansion & Fluency" (Secundaria)
        * 
        * @param area Nombre del área académica
        * @param gradoId ID del grado seleccionado
        * @return Lista de cursos que pertenecen al área y grado especificados
        */
       public List<Map<String, Object>> obtenerCursosPorAreaYGrado(String area, int gradoId) {
           List<Map<String, Object>> cursos = new ArrayList<>();

           // VALIDACIÓN ROBUSTA
           if (area == null || area.trim().isEmpty() || "undefined".equalsIgnoreCase(area) || "0".equals(area)) {
               System.err.println(" ADVERTENCIA: El parámetro 'area' es inválido: " + area);
               return cursos; // Retornar lista vacía
           }

           if (gradoId <= 0) {
               System.err.println(" ADVERTENCIA: El parámetro 'gradoId' es inválido: " + gradoId);
               return cursos; // Retornar lista vacía
           }

           System.out.println("Buscando cursos para área: '" + area + "' y gradoId: " + gradoId);

           String sql = "SELECT DISTINCT " +
                       "    c.id, " +
                       "    c.nombre, " +
                       "    a.nombre as area_nombre, " +
                       "    c.descripcion, " +
                       "    c.creditos, " +
                       "    c.horas_semanales, " +
                       "    g.nombre as grado_nombre, " +
                       "    g.nivel " +
                       "FROM curso c " +
                       "INNER JOIN area a ON c.area_id = a.id " +
                       "INNER JOIN grado g ON c.grado_id = g.id " +
                       "WHERE a.nombre = ? " +
                       "AND c.grado_id = ? " +           
                       "AND c.activo = 1 " +
                       "AND c.eliminado = 0 " +
                       "ORDER BY c.nombre";

           try (Connection conn = Conexion.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

               ps.setString(1, area.trim());
               ps.setInt(2, gradoId);
               ResultSet rs = ps.executeQuery();

               while (rs.next()) {
                   Map<String, Object> curso = new HashMap<>();
                   curso.put("id", rs.getInt("id"));
                   curso.put("nombre", rs.getString("nombre"));
                   curso.put("area", rs.getString("area_nombre"));
                   curso.put("descripcion", rs.getString("descripcion"));
                   curso.put("creditos", rs.getInt("creditos"));
                   curso.put("horas_semanales", rs.getInt("horas_semanales"));
                   curso.put("grado_nombre", rs.getString("grado_nombre"));
                   curso.put("nivel", rs.getString("nivel"));
                   cursos.add(curso);
               }

               System.out.println(" DAO - Cursos encontrados para área '" + area + "' y grado " + gradoId + ": " + cursos.size());

           } catch (SQLException e) {
               System.err.println(" Error al obtener cursos por área y grado: " + e.getMessage());
               e.printStackTrace();
           }

           return cursos;
           
       }
       
       /**
     * Obtener lista de aulas disponibles desde la BD
     */
    public List<Map<String, Object>> obtenerAulas() {
        List<Map<String, Object>> aulas = new ArrayList<>();
        String sql = "{CALL sp_listar_aulas()}"; // Llamamos al SP nuevo

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
            
            System.out.println(" DAO - Aulas obtenidas: " + aulas.size());
            
        } catch (SQLException e) {
            System.err.println(" Error al obtener aulas: " + e.getMessage());
            e.printStackTrace();
        }
        return aulas;
    }
}