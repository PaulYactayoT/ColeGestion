package controlador;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import javax.servlet.RequestDispatcher;
import java.io.IOException;
import java.util.*;
import modelo.RegistroCursoDAO;
import modelo.CursoDAO;
import modelo.Curso;
import com.google.gson.Gson;

/**
 * SERVLET DE REGISTRO Y EDICIÓN DE CURSOS - VERSIÓN CORREGIDA
 * 
 * Funcionalidades:
 * 1. Cargar formulario inicial (nuevo curso)
 * 2. Cargar formulario para edición (curso existente)
 * 3. Obtener datos dinámicos (AJAX):
 *    - Grados por nivel
 *    - Áreas por nivel
 *    - Cursos por área
 *    - Profesores filtrados
 * 4. Validaciones:
 *    - Disponibilidad del profesor
 *    - Horario dentro del turno
 * 5. Registrar nuevo curso
 * 6. Actualizar curso existente
 * 7. Eliminar curso (lógico)
 */
@WebServlet("/RegistroCursoServlet")
public class RegistroCursoServlet extends HttpServlet {

    private RegistroCursoDAO dao = new RegistroCursoDAO();
    private CursoDAO cursoDAO = new CursoDAO(); // ✅ NUEVO
    private Gson gson = new Gson();

    /**
     * ============================================================
     * MÉTODO: doGet
     * ============================================================
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String accion = request.getParameter("accion");
        System.out.println("\n========================================");
        System.out.println("GET - Acción recibida: " + accion);
        System.out.println("========================================");
        
        if ("cargarFormulario".equals(accion)) {
            cargarFormulario(request, response);
        }
        else if ("editar".equals(accion)) {  // ✅ NUEVO
            cargarFormularioEdicion(request, response);
        }
        else if ("obtenerGrados".equals(accion)) {
            obtenerGradosPorNivel(request, response);
        }
        else if ("obtenerCursos".equals(accion)) {
            obtenerCursosPorArea(request, response);
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
            cargarFormulario(request, response);
        }
    }

    /**
     * ============================================================
     * MÉTODO: doPost
     * ============================================================
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
     * CARGAR FORMULARIO INICIAL (NUEVO CURSO)
     * ============================================================
     */
    private void cargarFormulario(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            request.setCharacterEncoding("UTF-8");
            response.setCharacterEncoding("UTF-8");

            System.out.println("=== CARGANDO FORMULARIO INICIAL ===");

            List<Map<String, Object>> turnos = dao.obtenerTurnos();

            if (turnos == null) {
                turnos = new ArrayList<>();
            }

            System.out.println("Turnos cargados: " + turnos.size());

            request.setAttribute("turnos", turnos);
            request.setAttribute("modoEdicion", false); // ✅ Modo nuevo

            RequestDispatcher dispatcher = request.getRequestDispatcher("registroCurso.jsp");
            dispatcher.forward(request, response);

            System.out.println("✅ Formulario cargado correctamente");

        } catch (Exception e) {
            System.err.println("❌ ERROR al cargar formulario:");
            e.printStackTrace();
            
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
     * CARGAR FORMULARIO PARA EDICIÓN (CURSO EXISTENTE)
     * ============================================================
     */
    private void cargarFormularioEdicion(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int cursoId = Integer.parseInt(request.getParameter("id"));
            
            System.out.println("=== CARGANDO CURSO PARA EDICIÓN ===");
            System.out.println("Curso ID: " + cursoId);

            // 1. Obtener datos del curso
            Curso curso = cursoDAO.obtenerCursoCompletoPorId(cursoId);

            if (curso == null) {
                request.getSession().setAttribute("error", "No se encontró el curso con ID " + cursoId);
                response.sendRedirect("CursoServlet");
                return;
            }

            // 2. Obtener horarios del curso
            List<Map<String, Object>> horarios = cursoDAO.obtenerHorariosPorCurso(cursoId);

            // 3. Obtener turnos
            List<Map<String, Object>> turnos = dao.obtenerTurnos();

            // 4. Establecer atributos para el JSP
            request.setAttribute("cursoEditar", curso);
            request.setAttribute("horariosEditar", horarios);
            request.setAttribute("turnos", turnos);
            request.setAttribute("modoEdicion", true); // ✅ Modo edición

            System.out.println("✅ Datos cargados para edición:");
            System.out.println("   Curso: " + curso.getNombre());
            System.out.println("   Grado: " + curso.getGradoNombre());
            System.out.println("   Nivel: " + curso.getNivel());
            System.out.println("   Área: " + curso.getArea());
            System.out.println("   Turno: " + curso.getTurnoNombre() + " (ID: " + curso.getTurnoId() + ")");
            System.out.println("   Horarios: " + horarios.size());

            // 5. Forward al JSP
            RequestDispatcher dispatcher = request.getRequestDispatcher("registroCurso.jsp");
            dispatcher.forward(request, response);

        } catch (NumberFormatException e) {
            System.err.println("❌ ID de curso inválido");
            request.getSession().setAttribute("error", "ID de curso inválido");
            response.sendRedirect("CursoServlet");
        } catch (Exception e) {
            System.err.println("❌ Error al cargar curso para edición:");
            e.printStackTrace();
            request.getSession().setAttribute("error", "Error al cargar curso: " + e.getMessage());
            response.sendRedirect("CursoServlet");
        }
    }

    /**
     * ============================================================
     * OBTENER GRADOS POR NIVEL (AJAX)
     * ============================================================
     */
    private void obtenerGradosPorNivel(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String nivel = request.getParameter("nivel");
        
        System.out.println("=== OBTENIENDO GRADOS ===");
        System.out.println("Nivel: " + nivel);

        if (nivel == null || nivel.isEmpty()) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("[]");
            return;
        }

        List<Map<String, Object>> grados = dao.obtenerGradosPorNivel(nivel);

        System.out.println("Grados encontrados: " + grados.size());

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(gson.toJson(grados));
        
        System.out.println("✅ JSON enviado al cliente");
    }

    /**
     * ============================================================
     * OBTENER ÁREAS POR NIVEL (AJAX)
     * ============================================================
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
     * ============================================================
     * OBTENER CURSOS POR ÁREA (AJAX)
     * ============================================================
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
     * ============================================================
     * OBTENER PROFESORES FILTRADOS (AJAX)
     * ============================================================
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
            
            List<Map<String, Object>> profesores = 
                dao.obtenerProfesoresPorCursoTurnoNivel(curso, turnoId, nivel);

            System.out.println("Profesores encontrados: " + profesores.size());

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
     * VALIDAR DISPONIBILIDAD DEL PROFESOR (AJAX)
     * ============================================================
     */
    private void validarDisponibilidad(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
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
            
            int cursosEnDia = dao.validarLimiteCursos(profesorId, turnoId, diaSemana);
            boolean excedeLimite = cursosEnDia >= 4;
            
            System.out.println("Cursos en el día: " + cursosEnDia);
            System.out.println("Excede límite: " + (excedeLimite ? "SÍ" : "NO"));
            
            boolean hayConflicto = dao.validarConflictoHorario(
                profesorId, turnoId, diaSemana, horaInicio, horaFin
            );
            
            System.out.println("Hay conflicto: " + (hayConflicto ? "SÍ" : "NO"));
            
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
            
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(gson.toJson(resultado));
            
            System.out.println("✅ Validación completada");
            
        } catch (Exception e) {
            System.err.println("❌ Error en validación:");
            e.printStackTrace();
            
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
     * VALIDAR HORARIO EN TURNO (AJAX)
     * ============================================================
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
     * ============================================================
     * REGISTRAR NUEVO CURSO
     * ============================================================
     */
    private void registrarCurso(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        try {
            System.out.println("\n========================================");
            System.out.println("REGISTRANDO CURSO");
            System.out.println("========================================");
            
            String nombreCurso = request.getParameter("curso");
            int gradoId = Integer.parseInt(request.getParameter("grado"));
            int profesorId = Integer.parseInt(request.getParameter("profesor"));
            int turnoId = Integer.parseInt(request.getParameter("turno"));
            String descripcion = request.getParameter("descripcion");
            String area = request.getParameter("area");
            
            String[] dias = request.getParameterValues("dias[]");
            String[] horasInicio = request.getParameterValues("horasInicio[]");
            String[] horasFin = request.getParameterValues("horasFin[]");
            
            System.out.println("Datos recibidos:");
            System.out.println("  Curso: " + nombreCurso);
            System.out.println("  Grado ID: " + gradoId);
            System.out.println("  Profesor ID: " + profesorId);
            System.out.println("  Turno ID: " + turnoId);
            System.out.println("  Área: " + area);
            System.out.println("  Días: " + Arrays.toString(dias));

            if (dias == null || dias.length == 0) {
                session.setAttribute("error", "Debe agregar al menos un horario");
                response.sendRedirect("RegistroCursoServlet?accion=cargarFormulario");
                return;
            }
            
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
            
            Map<String, Object> resultado = dao.registrarCursoCompleto(
                nombreCurso, gradoId, profesorId, turnoId, 
                descripcion, area, horariosJson.toString()
            );
            
            System.out.println("Resultado del DAO: " + resultado);
            
            if ((Boolean) resultado.get("exito")) {
                session.setAttribute("mensaje", resultado.get("mensaje"));
                System.out.println("✅ CURSO REGISTRADO EXITOSAMENTE");
            } else {
                session.setAttribute("error", 
                    resultado.get("mensaje") + ": " + resultado.get("detalle"));
                System.out.println("❌ ERROR: " + resultado.get("detalle"));
            }
            
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
     * ACTUALIZAR CURSO EXISTENTE
     * ============================================================
     */
    private void actualizarCurso(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        try {
            System.out.println("\n========================================");
            System.out.println("ACTUALIZANDO CURSO");
            System.out.println("========================================");
            
            int cursoId = Integer.parseInt(request.getParameter("curso_id"));
            
            String nombreCurso = request.getParameter("curso");
            int gradoId = Integer.parseInt(request.getParameter("grado"));
            int profesorId = Integer.parseInt(request.getParameter("profesor"));
            int turnoId = Integer.parseInt(request.getParameter("turno"));
            String descripcion = request.getParameter("descripcion");
            String area = request.getParameter("area");
            
            String[] dias = request.getParameterValues("dias[]");
            String[] horasInicio = request.getParameterValues("horasInicio[]");
            String[] horasFin = request.getParameterValues("horasFin[]");
            
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
     * ELIMINAR CURSO (LÓGICO)
     * ============================================================
     */
    private void eliminarCurso(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        try {
            System.out.println("\n========================================");
            System.out.println("ELIMINANDO CURSO");
            System.out.println("========================================");
            
            int cursoId = Integer.parseInt(request.getParameter("curso_id"));
            
            System.out.println("Curso ID: " + cursoId);
            
            boolean exito = cursoDAO.eliminar(cursoId);
            
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
}