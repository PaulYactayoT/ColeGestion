package controlador;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import javax.servlet.RequestDispatcher;
import java.io.IOException;
import java.util.*;
import modelo.RegistroCursoDAO;
import com.google.gson.Gson;

/**
 * ============================================================
 * SERVLET DE REGISTRO DE CURSOS
 * ============================================================
 * Este servlet maneja todas las peticiones relacionadas con
 * el registro, actualización y eliminación de cursos.
 * 
 * Funcionalidades:
 * 1. Cargar formulario inicial
 * 2. Obtener grados por nivel (AJAX)
 * 3. Obtener cursos por nivel (AJAX)
 * 4. Obtener profesores filtrados (AJAX)
 * 5. Validar disponibilidad del profesor (AJAX)
 * 6. Registrar curso completo
 * 7. Actualizar curso
 * 8. Eliminar curso (lógicamente)
 * 
 * @author Tu nombre
 * @version 1.0
 */
@WebServlet("/RegistroCursoServlet")
public class RegistroCursoServlet extends HttpServlet {

    // DAO para acceso a datos
    private RegistroCursoDAO dao = new RegistroCursoDAO();
    
    // Gson para convertir objetos Java a JSON
    private Gson gson = new Gson();

    /**
     * ============================================================
     * MÉTODO: doGet
     * ============================================================
     * Razón: Maneja todas las peticiones GET (consultas)
     * 
     * Acciones disponibles:
     * - cargarFormulario: Carga la página inicial
     * - obtenerGrados: Retorna grados según nivel (AJAX)
     * - obtenerCursos: Retorna cursos según nivel (AJAX)
     * - obtenerProfesores: Retorna profesores filtrados (AJAX)
     * - validarDisponibilidad: Valida si profesor está disponible (AJAX)
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String accion = request.getParameter("accion");
        System.out.println("\n========================================");
        System.out.println("GET - Acción recibida: " + accion);
        System.out.println("========================================");
        
        // Determinar qué acción ejecutar
        if ("cargarFormulario".equals(accion)) {
            cargarFormulario(request, response);
        } 
        else if ("obtenerGrados".equals(accion)) {
            obtenerGradosPorNivel(request, response);
        }
        else if ("obtenerCursos".equals(accion)) {
            obtenerCursos(request, response); 
        }
        else if ("obtenerProfesores".equals(accion)) {
            obtenerProfesores(request, response);
        } 
        else if ("validarDisponibilidad".equals(accion)) {
            validarDisponibilidad(request, response);
        } 
        else if ("obtenerAreas".equals(accion)) {
            obtenerAreasPorNivel(request, response);
        }
        else if ("validarHorario".equals(accion)) {
            validarHorarioEnTurno(request, response);
        }
        else {
            // Si no hay acción o es desconocida, cargar formulario
            cargarFormulario(request, response);
        }
        
    }

    /**
     * ============================================================
     * MÉTODO: doPost
     * ============================================================
     * Razón: Maneja todas las peticiones POST (envío de datos)
     * 
     * Acciones disponibles:
     * - registrar: Registra un nuevo curso
     * - actualizar: Actualiza un curso existente
     * - eliminar: Elimina un curso (lógicamente)
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String accion = request.getParameter("accion");
        System.out.println("\n========================================");
        System.out.println("POST - Acción recibida: " + accion);
        System.out.println("========================================");
        
        if ("registrar".equals(accion)) {
            registrarCurso(request, response);
        }
        else if ("actualizar".equals(accion)) {
            actualizarCurso(request, response);
        }
        else if ("eliminar".equals(accion)) {
            eliminarCurso(request, response);
        }
    }

    /**
     * ============================================================
     * MÉTODO: cargarFormulario
     * ============================================================
     * Razón: Carga la página inicial del formulario de registro.
     * 
     * Solo carga los TURNOS inicialmente, porque:
     * - Los grados se cargan cuando se selecciona el NIVEL
     * - Los cursos se cargan cuando se selecciona el NIVEL
     * - Los profesores se cargan cuando se selecciona CURSO + TURNO
     * 
     * Esto mejora el rendimiento y la experiencia del usuario.
     */
    private void cargarFormulario(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Configurar codificación UTF-8 para caracteres especiales
            request.setCharacterEncoding("UTF-8");
            response.setCharacterEncoding("UTF-8");

            System.out.println("=== CARGANDO FORMULARIO INICIAL ===");

            // Solo obtener turnos al inicio
            List<Map<String, Object>> turnos = dao.obtenerTurnos();

            // Verificar que no sea null
            if (turnos == null) {
                turnos = new ArrayList<>();
            }

            System.out.println("Turnos cargados: " + turnos.size());

            // Establecer atributo para el JSP
            request.setAttribute("turnos", turnos);

            // Forward al JSP
            RequestDispatcher dispatcher = request.getRequestDispatcher("registroCurso.jsp");
            dispatcher.forward(request, response);

            System.out.println("✅ Formulario cargado correctamente");

        } catch (Exception e) {
            System.err.println("❌ ERROR al cargar formulario:");
            e.printStackTrace();
            
            // Enviar página de error
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().println("<html><body>");
            response.getWriter().println("<h1>Error al cargar formulario</h1>");
            response.getWriter().println("<p>" + e.getMessage() + "</p>");
            response.getWriter().println("<a href='CursoServlet'>Volver a Cursos</a>");
            response.getWriter().println("</body></html>");
        }
    }

    /**
     * ============================================================
     * MÉTODO: obtenerGradosPorNivel
     * ============================================================
     * Razón: Petición AJAX para obtener grados según el nivel.
     * 
     * Flujo:
     * 1. Usuario selecciona "INICIAL" en el select
     * 2. JavaScript hace una petición AJAX a este método
     * 3. Este método consulta la BD
     * 4. Retorna JSON con los grados: [{"id":12,"nombre":"3 años"}...]
     * 5. JavaScript actualiza el select de grados
     * 
     * Ejemplo de URL:
     * RegistroCursoServlet?accion=obtenerGrados&nivel=PRIMARIA
     */
    private void obtenerGradosPorNivel(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String nivel = request.getParameter("nivel");
        
        System.out.println("=== OBTENIENDO GRADOS ===");
        System.out.println("Nivel: " + nivel);

        // Validar que el nivel no sea nulo
        if (nivel == null || nivel.isEmpty()) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("[]"); // Array vacío
            return;
        }

        // Obtener grados de la BD
        List<Map<String, Object>> grados = dao.obtenerGradosPorNivel(nivel);

        System.out.println("Grados encontrados: " + grados.size());

        // Convertir a JSON y enviar
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(gson.toJson(grados));
        
        System.out.println("✅ JSON enviado al cliente");
    }

        /**
         * ============================================================
         * MÉTODO: obtenerCursos (UNIFICADO)
         * ============================================================
         * Razón: Maneja tanto la obtención por nivel como por área
         * según los parámetros recibidos
         */
        private void obtenerCursos(HttpServletRequest request, HttpServletResponse response)
                throws ServletException, IOException {

            // Obtener TODOS los parámetros posibles
            String nivel = request.getParameter("nivel");
            String area = request.getParameter("area");
            String turno = request.getParameter("turno");

            System.out.println("\n=== OBTENIENDO CURSOS ===");
            System.out.println(" Parámetros recibidos:");
            System.out.println("  Nivel: " + (nivel != null ? nivel : "(null)"));
            System.out.println("  Área: " + (area != null ? area : "(null)"));
            System.out.println("  Turno: " + (turno != null ? turno : "(null)"));

            // Mostrar TODOS los parámetros para diagnóstico
            System.out.println(" Todos los parámetros de la petición:");
            Enumeration<String> paramNames = request.getParameterNames();
            while (paramNames.hasMoreElements()) {
                String paramName = paramNames.nextElement();
                System.out.println("  - " + paramName + ": " + request.getParameter(paramName));
            }

            List<Map<String, Object>> cursos = new ArrayList<>();

            try {
                // ESTRATEGIA: Si viene área, usar obtenerCursosPorArea
                // Si no viene área pero viene nivel, usar obtenerCursosPorNivel
                // Si no viene ninguno, retornar vacío

                if (area != null && !area.trim().isEmpty() && !"undefined".equals(area) && !"0".equals(area)) {
                    // CASO 1: Tenemos área específica
                    System.out.println(" Usando obtenerCursosPorArea");
                    cursos = dao.obtenerCursosPorArea(area.trim());

                } else if (nivel != null && !nivel.trim().isEmpty() && !"undefined".equals(nivel)) {
                    // CASO 2: Tenemos solo nivel
                    System.out.println(" Usando obtenerCursosPorNivel");
                    cursos = dao.obtenerCursosPorNivel(nivel.trim());

                } else {
                    // CASO 3: No hay parámetros válidos
                    System.out.println("️ No se recibieron parámetros válidos para filtrar cursos");
                    System.out.println("   Área válida?: " + (area != null && !area.trim().isEmpty() && !"undefined".equals(area) && !"0".equals(area)));
                    System.out.println("   Nivel válido?: " + (nivel != null && !nivel.trim().isEmpty() && !"undefined".equals(nivel)));
                }

                System.out.println(" Cursos encontrados: " + cursos.size());

                // Convertir a JSON
                String json = gson.toJson(cursos);

                // Enviar respuesta
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write(json);

            } catch (Exception e) {
                System.err.println(" Error al obtener cursos:");
                e.printStackTrace();

                // Enviar array vacío en caso de error
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("[]");
            }
        }

    /**
     * ============================================================
     * MÉTODO: obtenerProfesores
     * ============================================================
     * Razón: Petición AJAX para obtener profesores filtrados.
     * 
     * Filtros aplicados:
     * 1. TURNO: Solo profesores que trabajen en ese turno
     * 2. NIVEL: Solo profesores que enseñen en ese nivel (o 'TODOS')
     * 3. ESPECIALIDAD: Debe coincidir con el área del curso
     * 
     * Ejemplo:
     * Si selecciono:
     * - Nivel: PRIMARIA
     * - Curso: Computación (área: Tecnología)
     * - Turno: TARDE
     * 
     * Solo veré profesores que:
     * - Trabajen en turno TARDE
     * - Enseñen en PRIMARIA (o TODOS)
     * - Su especialidad sea Computación/Tecnología
     */
    private void obtenerProfesores(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String curso = request.getParameter("curso");
        String turnoIdStr = request.getParameter("turno");
        String nivel = request.getParameter("nivel");

        System.out.println("=== OBTENIENDO PROFESORES ===");
        System.out.println("Curso: " + curso);
        System.out.println("Turno ID: " + turnoIdStr);
        System.out.println("Nivel: " + nivel);

        // Validar parámetros
        if (curso == null || turnoIdStr == null || nivel == null ||
            curso.isEmpty() || turnoIdStr.isEmpty() || nivel.isEmpty()) {
            
            System.out.println("❌ Parámetros incompletos");
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("[]");
            return;
        }

        try {
            int turnoId = Integer.parseInt(turnoIdStr);
            
            // Obtener profesores filtrados
            List<Map<String, Object>> profesores = 
                dao.obtenerProfesoresPorCursoTurnoNivel(curso, turnoId, nivel);

            System.out.println("Profesores encontrados: " + profesores.size());

            // Convertir a JSON y enviar
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(gson.toJson(profesores));
            
            System.out.println("✅ JSON enviado al cliente");
            
        } catch (NumberFormatException e) {
            System.err.println("❌ Error: turnoId no es un número válido");
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("[]");
        }
    }

    /**
     * ============================================================
     * MÉTODO: validarDisponibilidad
     * ============================================================
     * Razón: Petición AJAX para validar si el profesor puede dar
     * clase en ese día y horario.
     * 
     * Validaciones:
     * 1. Que no tenga más de 4 cursos ese día
     * 2. Que no tenga conflicto de horarios
     * 
     * Retorna JSON con:
     * {
     *   "disponible": true/false,
     *   "cursosEnDia": 2,
     *   "excedeLimite": false,
     *   "hayConflicto": false,
     *   "mensaje": "Disponible"
     * }
     */
    private void validarDisponibilidad(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            // Obtener parámetros
            int profesorId = Integer.parseInt(request.getParameter("profesorId"));
            int turnoId = Integer.parseInt(request.getParameter("turnoId"));
            String diaSemana = request.getParameter("diaSemana");
            String horaInicio = request.getParameter("horaInicio");
            String horaFin = request.getParameter("horaFin");
            
            System.out.println("=== VALIDANDO DISPONIBILIDAD ===");
            System.out.println("Profesor ID: " + profesorId);
            System.out.println("Turno ID: " + turnoId);
            System.out.println("Día: " + diaSemana);
            System.out.println("Horario: " + horaInicio + " - " + horaFin);
            
            // VALIDACIÓN 1: Límite de 4 cursos por día
            int cursosEnDia = dao.validarLimiteCursos(profesorId, turnoId, diaSemana);
            boolean excedeLimite = cursosEnDia >= 4;
            
            System.out.println("Cursos en el día: " + cursosEnDia);
            System.out.println("Excede límite: " + (excedeLimite ? "SÍ" : "NO"));
            
            // VALIDACIÓN 2: Conflicto de horarios
            boolean hayConflicto = dao.validarConflictoHorario(
                profesorId, turnoId, diaSemana, horaInicio, horaFin
            );
            
            System.out.println("Hay conflicto: " + (hayConflicto ? "SÍ" : "NO"));
            
            // Construir respuesta JSON
            Map<String, Object> resultado = new HashMap<>();
            resultado.put("disponible", !excedeLimite && !hayConflicto);
            resultado.put("cursosEnDia", cursosEnDia);
            resultado.put("excedeLimite", excedeLimite);
            resultado.put("hayConflicto", hayConflicto);
            resultado.put("mensaje", 
                excedeLimite ? "El profesor ya tiene 4 cursos este día" :
                hayConflicto ? "Conflicto de horario con otra clase" :
                "Disponible"
            );
            
            // Enviar JSON
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(gson.toJson(resultado));
            
            System.out.println("✅ Validación completada");
            
        } catch (Exception e) {
            System.err.println("❌ Error en validación:");
            e.printStackTrace();
            
            // Enviar error en JSON
            Map<String, Object> error = new HashMap<>();
            error.put("disponible", false);
            error.put("mensaje", "Error en validación: " + e.getMessage());
            
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(gson.toJson(error));
        }
    }

    /**
     * ============================================================
     * MÉTODO: registrarCurso
     * ============================================================
     * Razón: Registrar un nuevo curso en la base de datos.
     * 
     * Datos recibidos:
     * - Nombre del curso
     * - Grado
     * - Profesor
     * - Turno
     * - Descripción
     * - Área
     * - Horarios (array de días y horas)
     * 
     * Proceso:
     * 1. Capturar todos los datos del formulario
     * 2. Construir JSON con los horarios
     * 3. Llamar al DAO que ejecuta el stored procedure
     * 4. El stored procedure valida:
     *    - Horarios dentro del turno
     *    - Duración válida (30min, 1h, 1.5h, 2h)
     *    - Máximo 4 cursos por día
     *    - Sin conflictos de horarios
     * 5. Si todo está OK, inserta en la BD
     * 6. Redirige a la lista de cursos
     */
    private void registrarCurso(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        try {
            System.out.println("\n========================================");
            System.out.println("REGISTRANDO CURSO");
            System.out.println("========================================");
            
            // Capturar datos del formulario (SIN créditos)
            String nombreCurso = request.getParameter("curso");
            int gradoId = Integer.parseInt(request.getParameter("grado"));
            int profesorId = Integer.parseInt(request.getParameter("profesor"));
            int turnoId = Integer.parseInt(request.getParameter("turno"));
            String descripcion = request.getParameter("descripcion");
            String area = request.getParameter("area");
            
            // Capturar horarios (arrays)
            String[] dias = request.getParameterValues("dias[]");
            String[] horasInicio = request.getParameterValues("horasInicio[]");
            String[] horasFin = request.getParameterValues("horasFin[]");
            
            // Log de datos recibidos
            System.out.println("Datos recibidos:");
            System.out.println("  Curso: " + nombreCurso);
            System.out.println("  Grado ID: " + gradoId);
            System.out.println("  Profesor ID: " + profesorId);
            System.out.println("  Turno ID: " + turnoId);
            System.out.println("  Área: " + area);
            System.out.println("  Días: " + Arrays.toString(dias));
            System.out.println("  Horas inicio: " + Arrays.toString(horasInicio));
            System.out.println("  Horas fin: " + Arrays.toString(horasFin));

            // Validar que haya horarios
            if (dias == null || dias.length == 0) {
                session.setAttribute("error", "Debe agregar al menos un horario");
                response.sendRedirect("RegistroCursoServlet?accion=cargarFormulario");
                return;
            }
            
            // Construir JSON de horarios
            // Formato: [{"dia":"LUNES","hora_inicio":"08:00","hora_fin":"09:00"}]
            StringBuilder horariosJson = new StringBuilder("[");
            
            for (int i = 0; i < dias.length; i++) {
                if (i > 0) {
                    horariosJson.append(",");
                }
                horariosJson.append("{")
                    .append("\"dia\":\"").append(dias[i]).append("\",")
                    .append("\"hora_inicio\":\"").append(horasInicio[i]).append("\",")
                    .append("\"hora_fin\":\"").append(horasFin[i]).append("\"")
                    .append("}");
            }
            horariosJson.append("]");
            
            System.out.println("JSON generado: " + horariosJson.toString());
            
            // Llamar al DAO para registrar (SIN créditos)
            Map<String, Object> resultado = dao.registrarCursoCompleto(
                nombreCurso, gradoId, profesorId, turnoId, 
                descripcion, area, horariosJson.toString()
            );
            
            System.out.println("Resultado del DAO: " + resultado);
            
            // Verificar resultado
            if ((Boolean) resultado.get("exito")) {
                session.setAttribute("mensaje", resultado.get("mensaje"));
                System.out.println("✅ CURSO REGISTRADO EXITOSAMENTE");
            } else {
                session.setAttribute("error", 
                    resultado.get("mensaje") + ": " + resultado.get("detalle"));
                System.out.println("❌ ERROR: " + resultado.get("detalle"));
            }
            
            // Redirigir a la lista de cursos
            response.sendRedirect("CursoServlet");
            
        } catch (NumberFormatException e) {
            System.err.println("❌ Error de formato en números:");
            e.printStackTrace();
            session.setAttribute("error", "Error en los datos: valores numéricos inválidos");
            response.sendRedirect("RegistroCursoServlet?accion=cargarFormulario");
            
        } catch (Exception e) {
            System.err.println("❌ ERROR GENERAL:");
            e.printStackTrace();
            session.setAttribute("error", "Error al registrar curso: " + e.getMessage());
            response.sendRedirect("RegistroCursoServlet?accion=cargarFormulario");
        }
    }

    /**
     * ============================================================
     * MÉTODO: actualizarCurso
     * ============================================================
     * Razón: Actualizar un curso existente.
     * 
     * Similar a registrar, pero con un ID de curso existente.
     */
    private void actualizarCurso(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        try {
            System.out.println("\n========================================");
            System.out.println("ACTUALIZANDO CURSO");
            System.out.println("========================================");
            
            // Capturar ID del curso a actualizar
            int cursoId = Integer.parseInt(request.getParameter("curso_id"));
            
            // Capturar otros datos (similar a registrar)
            String nombreCurso = request.getParameter("curso");
            int gradoId = Integer.parseInt(request.getParameter("grado"));
            int profesorId = Integer.parseInt(request.getParameter("profesor"));
            int turnoId = Integer.parseInt(request.getParameter("turno"));
            String descripcion = request.getParameter("descripcion");
            String area = request.getParameter("area");
            
            String[] dias = request.getParameterValues("dias[]");
            String[] horasInicio = request.getParameterValues("horasInicio[]");
            String[] horasFin = request.getParameterValues("horasFin[]");
            
            // Construir JSON
            StringBuilder horariosJson = new StringBuilder("[");
            if (dias != null) {
                for (int i = 0; i < dias.length; i++) {
                    if (i > 0) horariosJson.append(",");
                    horariosJson.append("{")
                        .append("\"dia\":\"").append(dias[i]).append("\",")
                        .append("\"hora_inicio\":\"").append(horasInicio[i]).append("\",")
                        .append("\"hora_fin\":\"").append(horasFin[i]).append("\"")
                        .append("}");
                }
            }
            horariosJson.append("]");
            
            // Llamar al DAO para actualizar
            Map<String, Object> resultado = dao.actualizarCurso(
                cursoId, nombreCurso, gradoId, profesorId, turnoId,
                descripcion, area, horariosJson.toString()
            );
            
            if ((Boolean) resultado.get("exito")) {
                session.setAttribute("mensaje", "Curso actualizado correctamente");
                System.out.println("✅ CURSO ACTUALIZADO");
            } else {
                session.setAttribute("error", resultado.get("mensaje"));
                System.out.println("❌ ERROR AL ACTUALIZAR");
            }
            
            response.sendRedirect("CursoServlet");
            
        } catch (Exception e) {
            System.err.println("❌ ERROR AL ACTUALIZAR:");
            e.printStackTrace();
            session.setAttribute("error", "Error al actualizar curso: " + e.getMessage());
            response.sendRedirect("CursoServlet");
        }
    }

    /**
     * ============================================================
     * MÉTODO: eliminarCurso
     * ============================================================
     * Razón: Eliminar un curso de forma LÓGICA (no física).
     * 
     * NO hace DELETE FROM curso WHERE id = ...
     * 
     * En su lugar hace:
     * UPDATE curso SET eliminado = 1, activo = 0 WHERE id = ...
     * 
     * ¿Por qué?
     * - Se mantiene el historial académico
     * - Los reportes no fallan
     * - Se puede recuperar si fue error
     * - Es la mejor práctica en sistemas empresariales
     */
    private void eliminarCurso(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        try {
            System.out.println("\n========================================");
            System.out.println("ELIMINANDO CURSO");
            System.out.println("========================================");
            
            // Obtener ID del curso
            int cursoId = Integer.parseInt(request.getParameter("curso_id"));
            
            System.out.println("Curso ID: " + cursoId);
            
            // Llamar al DAO para eliminar lógicamente
            boolean exito = dao.eliminarCurso(cursoId);
            
            if (exito) {
                session.setAttribute("mensaje", "Curso eliminado correctamente");
                System.out.println("✅ CURSO ELIMINADO (lógicamente)");
            } else {
                session.setAttribute("error", "Error al eliminar curso");
                System.out.println("❌ ERROR AL ELIMINAR");
            }
            
            response.sendRedirect("CursoServlet");
            
        } catch (Exception e) {
            System.err.println("❌ ERROR AL ELIMINAR:");
            e.printStackTrace();
            session.setAttribute("error", "Error al eliminar curso: " + e.getMessage());
            response.sendRedirect("CursoServlet");
        }
    }
    
            /**
         * Obtener áreas por nivel (AJAX)
         */
        private void obtenerAreasPorNivel(HttpServletRequest request, HttpServletResponse response)
                throws IOException {

            String nivel = request.getParameter("nivel");
            System.out.println("📥 Obteniendo áreas para nivel: " + nivel);

            if (nivel == null || nivel.isEmpty()) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("[]");
                return;
            }

            List<Map<String, Object>> areas = dao.obtenerAreasPorNivel(nivel);

            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(gson.toJson(areas));
        }

        /**
         * Obtener cursos por área (AJAX)
         */
        private void obtenerCursosPorArea(HttpServletRequest request, HttpServletResponse response)
                throws IOException {

            String area = request.getParameter("area");
            System.out.println("📥 Obteniendo cursos para área: " + area);

            if (area == null || area.isEmpty()) {
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("[]");
                return;
            }

            List<Map<String, Object>> cursos = dao.obtenerCursosPorArea(area);

            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(gson.toJson(cursos));
        }

        /**
         * Validar horario en turno (AJAX)
         */
        private void validarHorarioEnTurno(HttpServletRequest request, HttpServletResponse response)
                throws IOException {

            try {
                int turnoId = Integer.parseInt(request.getParameter("turnoId"));
                String horaInicio = request.getParameter("horaInicio");
                String horaFin = request.getParameter("horaFin");

                Map<String, Object> resultado = dao.validarHorarioEnTurno(turnoId, horaInicio, horaFin);

                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write(gson.toJson(resultado));

            } catch (Exception e) {
                Map<String, Object> error = new HashMap<>();
                error.put("dentro_rango", false);
                error.put("mensaje", "Error en validación");
                response.setContentType("application/json");
                response.getWriter().write(gson.toJson(error));
            }
        }
}