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
        System.out.println("GET - Acción recibida: " + accion);

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
        else if ("obtenerDisponibilidad".equals(accion)) {
            try {
                int profId = Integer.parseInt(request.getParameter("profesorId"));
                // Llama al nuevo método que creaste en el DAO
                List<Map<String, Object>> disponibilidad = dao.obtenerDisponibilidadAprobada(profId);

                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write(gson.toJson(disponibilidad));
            } catch (Exception e) {
                response.setStatus(500);
                response.getWriter().write("{\"error\": \"" + e.getMessage() + "\"}");
            }
        }
        else if ("jsonAulas".equals(accion)) {
            List<Map<String, Object>> aulas = dao.obtenerAulas();
            String json = new Gson().toJson(aulas);
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(json);
        }
        else if ("obtenerDisponibilidadProfesor".equals(accion)) {
            obtenerDisponibilidadProfesor(request, response);
        }
        else {
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

           List<Map<String, Object>> turnos = dao.obtenerTurnos();
           List<Map<String, Object>> aulas = dao.obtenerAulas(); 

            // Verificar que no sea null
            if (turnos == null) {
                turnos = new ArrayList<>();
            }
            if (aulas == null) {
                aulas = new ArrayList<>();
            }

            System.out.println("Turnos cargados: " + turnos.size());
            System.out.println("Aulas cargadas: " + aulas.size());

            // Establecer atributos para el JSP
            request.setAttribute("turnos", turnos);
            request.setAttribute("aulas", aulas);

            // Forward al JSP
            RequestDispatcher dispatcher = request.getRequestDispatcher("registroCurso.jsp");
            dispatcher.forward(request, response);

            System.out.println(" Formulario cargado correctamente");

        } catch (Exception e) {
            System.err.println(" ERROR al cargar formulario:");
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

            System.out.println("\n=== OBTENIENDO GRADOS ===");
            System.out.println("📥 Parámetro 'nivel' recibido: " + nivel);
            System.out.println("📥 Parámetro 'nivel' (raw): " + request.getParameter("nivel"));

            // Mostrar TODOS los parámetros recibidos
            System.out.println("📥 Todos los parámetros de la petición:");
            Enumeration<String> paramNames = request.getParameterNames();
            while (paramNames.hasMoreElements()) {
                String paramName = paramNames.nextElement();
                System.out.println("  - " + paramName + " = " + request.getParameter(paramName));
            }

            // Validar que el nivel no sea nulo
            if (nivel == null || nivel.isEmpty()) {
                System.err.println("❌ ERROR: Nivel es nulo o vacío");
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("[]");
                return;
            }

            System.out.println("📥 Nivel procesado: '" + nivel + "'");

            // Obtener grados de la BD
            List<Map<String, Object>> grados = dao.obtenerGradosPorNivel(nivel);

            System.out.println("✅ Grados encontrados: " + grados.size());
            if (!grados.isEmpty()) {
                for (Map<String, Object> grado : grados) {
                    System.out.println("  - ID: " + grado.get("id") + ", Nombre: " + grado.get("nombre"));
                }
            }

            // Convertir a JSON y enviar
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            String json = gson.toJson(grados);
            System.out.println("📤 JSON enviado: " + json);
            response.getWriter().write(json);
        }

        /**
            * ============================================================
            * MÉTODO: obtenerCursos (CORREGIDO)
            * ============================================================
            * Razón: Ahora filtra los cursos por área Y grado para evitar
            * que aparezcan cursos de otros niveles educativos.
            * 
            * Ejemplo:
            * - Usuario selecciona: Nivel PRIMARIA, Grado 3ero, Área Idiomas
            * - ANTES: Mostraba Discovery Stage, Building Stage, Expansion & Fluency
            * - AHORA: Solo muestra Building Stage (correspondiente a Primaria)
            */
           private void obtenerCursos(HttpServletRequest request, HttpServletResponse response)
                   throws ServletException, IOException {

               // Obtener TODOS los parámetros posibles
               String nivel = request.getParameter("nivel");
               String area = request.getParameter("area");
               String turno = request.getParameter("turno");
               String gradoIdStr = request.getParameter("grado");  // ✅ NUEVO: Obtener el grado

               System.out.println("\n=== OBTENIENDO CURSOS ===");
               System.out.println(" Parámetros recibidos:");
               System.out.println("  Nivel: " + (nivel != null ? nivel : "(null)"));
               System.out.println("  Área: " + (area != null ? area : "(null)"));
               System.out.println("  Turno: " + (turno != null ? turno : "(null)"));
               System.out.println("  Grado: " + (gradoIdStr != null ? gradoIdStr : "(null)"));  // ✅ NUEVO

               // Mostrar TODOS los parámetros para diagnóstico
               System.out.println("Todos los parámetros de la petición:");
               Enumeration<String> paramNames = request.getParameterNames();
               while (paramNames.hasMoreElements()) {
                   String paramName = paramNames.nextElement();
                   System.out.println("  - " + paramName + ": " + request.getParameter(paramName));
               }

               List<Map<String, Object>> cursos = new ArrayList<>();

               try {
                   // NUEVA ESTRATEGIA: Si viene área Y grado, usar obtenerCursosPorAreaYGrado
                   // Si viene solo área, usar obtenerCursosPorArea
                   // Si viene solo nivel, usar obtenerCursosPorNivel

                   if (area != null && !area.trim().isEmpty() && !"undefined".equals(area) && !"0".equals(area)) {

                       // CASO 1: Tenemos área Y grado (ÓPTIMO)
                       if (nivel != null && !nivel.trim().isEmpty() && !"undefined".equals(nivel)) {
                            System.out.println("✓ Usando obtenerCursosPorAreaYNivel");
                            cursos = dao.obtenerCursosPorAreaYNivel(area.trim(), nivel.trim());
                        } else {
                            // Fallback si no hay nivel
                            System.out.println("✓ Fallback: Usando obtenerCursosPorArea");
                            cursos = dao.obtenerCursosPorArea(area.trim());
                        }

                   } else if (nivel != null && !nivel.trim().isEmpty() && !"undefined".equals(nivel)) {
                       // CASO 3: Tenemos solo nivel
                       System.out.println(" Usando obtenerCursosPorNivel");
                       cursos = dao.obtenerCursosPorNivel(nivel.trim());

                   } else {
                       // CASO 4: No hay parámetros válidos
                       System.out.println("   No se recibieron parámetros válidos para filtrar cursos");
                       System.out.println("   Área válida?: " + (area != null && !area.trim().isEmpty() && !"undefined".equals(area) && !"0".equals(area)));
                       System.out.println("   Nivel válido?: " + (nivel != null && !nivel.trim().isEmpty() && !"undefined".equals(nivel)));
                       System.out.println("   Grado válido?: " + (gradoIdStr != null && !gradoIdStr.trim().isEmpty() && !"undefined".equals(gradoIdStr)));
                   }

                   System.out.println("✅ Cursos encontrados: " + cursos.size());

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

    System.out.println("\n=== OBTENIENDO PROFESORES ===");
    System.out.println(" Curso recibido: " + curso);
    System.out.println(" Turno ID recibido: " + turnoIdStr);
    System.out.println(" Nivel recibido: " + nivel);
    
    // Mostrar TODOS los parámetros
    System.out.println(" Todos los parámetros:");
    Enumeration<String> params = request.getParameterNames();
    while (params.hasMoreElements()) {
        String param = params.nextElement();
        System.out.println("  - " + param + " = " + request.getParameter(param));
    }

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
        
        System.out.println(" Llamando a DAO con:");
        System.out.println("  - Curso: " + curso);
        System.out.println("  - Turno ID: " + turnoId);
        System.out.println("  - Nivel: " + nivel);
        
        // Obtener profesores filtrados
        List<Map<String, Object>> profesores = 
            dao.obtenerProfesoresPorCursoTurnoNivel(curso, turnoId, nivel);

        System.out.println("✅ Profesores encontrados: " + profesores.size());
        
        if (!profesores.isEmpty()) {
            for (Map<String, Object> profesor : profesores) {
                System.out.println("  - ID: " + profesor.get("id") + 
                                 ", Nombre: " + profesor.get("nombre_completo") +
                                 ", Especialidad: " + profesor.get("especialidad"));
            }
        } else {
            System.out.println(" No se encontraron profesores con esos criterios");
        }

        // Convertir a JSON y enviar
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        String json = gson.toJson(profesores);
        System.out.println(" JSON enviado: " + json);
        response.getWriter().write(json);
        
    } catch (NumberFormatException e) {
        System.err.println(" Error: turnoId no es un número válido");
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
        throws IOException {
    
        try {
            int profesorId = Integer.parseInt(request.getParameter("profesorId"));
            int turnoId = Integer.parseInt(request.getParameter("turnoId"));
            String diaSemana = request.getParameter("diaSemana");
            String horaInicio = request.getParameter("horaInicio");
            String horaFin = request.getParameter("horaFin");

            System.out.println(" Validando disponibilidad:");
            System.out.println("   Profesor: " + profesorId);
            System.out.println("   Turno: " + turnoId);
            System.out.println("   Día: " + diaSemana);
            System.out.println("   Horario: " + horaInicio + " - " + horaFin);

            // Validar usando el método actualizado del DAO
            Map<String, Object> resultado = dao.validarDisponibilidadProfesor(
                profesorId, turnoId, diaSemana, horaInicio, horaFin
            );

            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(gson.toJson(resultado));

        } catch (Exception e) {
            System.err.println(" Error en validación: " + e.getMessage());
            e.printStackTrace();

            Map<String, Object> error = new HashMap<>();
            error.put("disponible", false);
            error.put("mensaje", "Error al validar disponibilidad: " + e.getMessage());

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
            System.out.println("REGISTRANDO CURSO (CORREGIDO)");
            System.out.println("========================================");
            
            // 1. Capturar datos del formulario
            String nombreCurso = request.getParameter("curso");
            int gradoId = Integer.parseInt(request.getParameter("grado"));
            int profesorId = Integer.parseInt(request.getParameter("profesor"));
            int turnoId = Integer.parseInt(request.getParameter("turno"));
            String descripcion = request.getParameter("descripcion");
            String area = request.getParameter("area");
            
            // 2. Capturar horarios (arrays) Y AULAS
        String[] dias = request.getParameterValues("dias[]");
        String[] horasInicio = request.getParameterValues("horasInicio[]");
        String[] horasFin = request.getParameterValues("horasFin[]");
        String[] aulas = request.getParameterValues("aulas[]");
            
            // Validaciones básicas
            if (dias == null || dias.length == 0) {
                session.setAttribute("error", "Debe agregar al menos un horario");
                response.sendRedirect("RegistroCursoServlet?accion=cargarFormulario");
                return;
            }
            
            if (aulas == null || aulas.length != dias.length) {
            session.setAttribute("error", "Debe seleccionar un aula para cada horario");
            response.sendRedirect("RegistroCursoServlet?accion=cargarFormulario");
            return;
           
            }
            
            // 3. Construir JSON de horarios INCLUYENDO EL AULA_ID
            // El Store Procedure espera: [{"dia":"LUNES", "hora_inicio":"...", "hora_fin":"...", "aula_id": 1}]
            StringBuilder horariosJson = new StringBuilder("[");
            
            for (int i = 0; i < dias.length; i++) {
                if (i > 0) {
                    horariosJson.append(",");
                }
                horariosJson.append("{")
                .append("\"dia\":\"").append(dias[i]).append("\",")
                .append("\"hora_inicio\":\"").append(horasInicio[i]).append("\",")
                .append("\"hora_fin\":\"").append(horasFin[i]).append("\",")
                .append("\"aula_id\":").append(aulas[i]) // ✅ CRÍTICO
                .append("}");
                
            }
            horariosJson.append("]");
            
            System.out.println("JSON generado (Con Aulas): " + horariosJson.toString());
            
            // 4. Llamar al DAO
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
            String[] aulas = request.getParameterValues("aulas[]");
            
            if (aulas == null || aulas.length != dias.length) {
            session.setAttribute("error", "Debe seleccionar un aula para cada horario");
            response.sendRedirect("RegistroCursoServlet?accion=cargarFormulario");
            return;
}
            
            // Construir JSON
            StringBuilder horariosJson = new StringBuilder("[");
            if (dias != null) {
                for (int i = 0; i < dias.length; i++) {
                    if (i > 0) horariosJson.append(",");
                  horariosJson.append("{")
                    .append("\"dia\":\"").append(dias[i]).append("\",")
                    .append("\"hora_inicio\":\"").append(horasInicio[i]).append("\",")
                    .append("\"hora_fin\":\"").append(horasFin[i]).append("\",")
                    .append("\"aula_id\":").append(aulas[i]) 
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
        
        /**
        * Obtiene la disponibilidad APROBADA del profesor en formato JSON
        */
       private void obtenerDisponibilidadProfesor(HttpServletRequest request, HttpServletResponse response)
               throws IOException {

           try {
               int profesorId = Integer.parseInt(request.getParameter("profesorId"));

               System.out.println(" Obteniendo disponibilidad para profesor ID: " + profesorId);

               // Obtener disponibilidad detallada del profesor
               List<Map<String, Object>> disponibilidad = dao.obtenerDisponibilidadAprobadaDetallada(profesorId);

               System.out.println(" Disponibilidades encontradas: " + disponibilidad.size());

               // Retornar JSON
               response.setContentType("application/json");
               response.setCharacterEncoding("UTF-8");
               response.getWriter().write(gson.toJson(disponibilidad));

           } catch (NumberFormatException e) {
               System.err.println(" Error: profesorId inválido");
               response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
               response.getWriter().write("{\"error\": \"ID de profesor inválido\"}");
           } catch (Exception e) {
               System.err.println(" Error al obtener disponibilidad: " + e.getMessage());
               e.printStackTrace();
               response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
               response.getWriter().write("{\"error\": \"" + e.getMessage() + "\"}");
           }
       }
}