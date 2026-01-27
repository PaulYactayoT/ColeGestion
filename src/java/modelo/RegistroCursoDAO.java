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
        String sql = "CALL obtener_cursos_por_nivel(?)";
        
        try (Connection conn = Conexion.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            
            cs.setString(1, nivel);
            ResultSet rs = cs.executeQuery();
            
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
        String sql = "CALL obtener_profesores_por_curso_turno_nivel(?, ?, ?)";
        
        try (Connection conn = Conexion.getConnection();
             CallableStatement cs = conn.prepareCall(sql)) {
            
            cs.setString(1, nombreCurso);
            cs.setInt(2, turnoId);
            cs.setString(3, nivel);
            
            System.out.println("DAO - Buscando profesores para:");
            System.out.println("  Curso: " + nombreCurso);
            System.out.println("  Turno ID: " + turnoId);
            System.out.println("  Nivel: " + nivel);
            
            ResultSet rs = cs.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> profesor = new HashMap<>();
                profesor.put("id", rs.getInt("id"));
                profesor.put("nombre_completo", rs.getString("nombre_completo"));
                profesor.put("especialidad", rs.getString("especialidad"));
                profesor.put("codigo_profesor", rs.getString("codigo_profesor"));
                profesores.add(profesor);
            }
            
            System.out.println("DAO - Profesores encontrados: " + profesores.size());
            
        } catch (SQLException e) {
            System.err.println("Error al obtener profesores: " + e.getMessage());
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
        String sql = "CALL registrar_curso_completo_v2(?, ?, ?, ?, ?, ?, ?)";
        
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
                int cursoId = rs.getInt("curso_id");
                
                if (cursoId > 0) {
                    resultado.put("exito", true);
                    resultado.put("mensaje", rs.getString("mensaje"));
                    resultado.put("detalle", rs.getString("detalle"));
                    resultado.put("curso_id", cursoId);
                    System.out.println("✅ Curso registrado exitosamente - ID: " + cursoId);
                } else {
                    resultado.put("exito", false);
                    resultado.put("mensaje", rs.getString("mensaje"));
                    resultado.put("detalle", rs.getString("detalle"));
                    System.out.println(" Error al registrar: " + rs.getString("detalle"));
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
            String sql = "{CALL obtener_areas_por_nivel(?)}";

            try (Connection conn = Conexion.getConnection();
                 CallableStatement cs = conn.prepareCall(sql)) {

                cs.setString(1, nivel);
                ResultSet rs = cs.executeQuery();

                while (rs.next()) {
                    Map<String, Object> area = new HashMap<>();
                    area.put("area", rs.getString("area"));
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
         * Obtiene los cursos que pertenecen a un área específica
         */
        public List<Map<String, Object>> obtenerCursosPorArea(String area) {
            List<Map<String, Object>> cursos = new ArrayList<>();
            String sql = "{CALL obtener_cursos_por_area(?)}";

            try (Connection conn = Conexion.getConnection();
                 CallableStatement cs = conn.prepareCall(sql)) {

                cs.setString(1, area);
                ResultSet rs = cs.executeQuery();

                while (rs.next()) {
                    Map<String, Object> curso = new HashMap<>();
                    curso.put("nombre", rs.getString("nombre"));
                    curso.put("area", rs.getString("area"));
                    curso.put("descripcion", rs.getString("descripcion"));
                    cursos.add(curso);
                }

                System.out.println("DAO - Cursos obtenidos para área '" + area + "': " + cursos.size());

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
        
            public List<Curso> obtenerCursosPorArea(String area, String nivel) {
            List<Curso> cursos = new ArrayList<>();
            String sql = "{CALL obtener_cursos_por_area(?, ?)}";

            try (Connection conn = Conexion.getConnection();
                CallableStatement cs = conn.prepareCall(sql)) {    
                cs.setString(1, area);
                cs.setString(2, nivel); 

                ResultSet rs = cs.executeQuery();
                while (rs.next()) {
                    Curso curso = new Curso();
                    curso.setNombre(rs.getString("nombre"));
                    curso.setArea(rs.getString("area"));
                    curso.setDescripcion(rs.getString("descripcion"));
                    cursos.add(curso);
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
            return cursos;
        }
}
