/*
 * SERVLET PARA GESTIÓN DE TAREAS Y ACTIVIDADES ACADÉMICAS
 * 
 * Funcionalidades: CRUD completo de tareas, asignación por curso, fechas de entrega
 * Roles: Docente (gestión completa), Padre (consulta de tareas de su hijo)
 * Integración: Relación con cursos, alumnos y calificaciones
 */
package controlador;

import modelo.Tarea;
import modelo.TareaDAO;
import modelo.Curso;
import modelo.CursoDAO;
import modelo.Profesor;
// En TareaServlet.java, falta esta importación:
import java.util.ArrayList;
import java.util.List;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;

public class TareaServlet extends HttpServlet {

    // DAO para operaciones con la tabla de tareas
    TareaDAO dao = new TareaDAO();
    CursoDAO cursoDao = new CursoDAO();

    /**
     * MÉTODO GET - CONSULTAS Y GESTIÓN DE TAREAS
     * 
     * Acciones soportadas:
     * - ver: Listar tareas de un curso específico
     * - registrar: Formulario para crear nueva tarea
     * - editar: Formulario para modificar tarea existente
     * - eliminar: Eliminar tarea del sistema
     * - listar: Listar todas las tareas (admin)
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        String rol = (String) session.getAttribute("rol");
        String accion = request.getParameter("accion");
        
        // Validar permisos según rol
        if (!esRolValidoParaTareas(rol)) {
            session.setAttribute("error", "No tiene permisos para acceder a esta sección");
            response.sendRedirect("dashboard.jsp");
            return;
        }

        try {
            if (accion == null || accion.isEmpty()) {
                accion = "listar";
            }

            switch (accion) {
                case "ver":
                    manejarVerTarea(request, response, session);
                    break;
                    
                case "registrar":
                    manejarRegistrarTarea(request, response, session);
                    break;
                    
                case "editar":
                    manejarEditarTarea(request, response, session);
                    break;
                    
                case "eliminar":
                    manejarEliminarTarea(request, response, session);
                    break;
                    
                case "listar":
                    manejarListarTareas(request, response, session);
                    break;
                    
                case "detalle":
                    manejarDetalleTarea(request, response, session);
                    break;
                    
                default:
                    session.setAttribute("error", "Acción no válida");
                    response.sendRedirect("dashboard.jsp");
            }

        } catch (NumberFormatException e) {
            session.setAttribute("error", "ID inválido");
            response.sendRedirect("dashboard.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "Error en el sistema: " + e.getMessage());
            response.sendRedirect("dashboard.jsp");
        }
    }

    /**
     * MÉTODO POST - CREAR Y ACTUALIZAR TAREAS
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        String rol = (String) session.getAttribute("rol");
        if (!esRolValidoParaTareas(rol)) {
            session.setAttribute("error", "No tiene permisos para realizar esta acción");
            response.sendRedirect("dashboard.jsp");
            return;
        }

        String accion = request.getParameter("accion");
        if (accion == null) {
            accion = "guardar";
        }

        try {
            switch (accion) {
                case "guardar":
                    guardarTarea(request, response, session);
                    break;
                    
                case "actualizar":
                    actualizarTarea(request, response, session);
                    break;
                    
                case "cambiarEstado":
                    cambiarEstadoTarea(request, response, session);
                    break;
                    
                default:
                    session.setAttribute("error", "Acción no válida");
                    response.sendRedirect("TareaServlet?accion=listar");
            }

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "Error al procesar la solicitud: " + e.getMessage());
            response.sendRedirect("TareaServlet?accion=listar");
        }
    }

    /**
     * MÉTODOS PRIVADOS PARA MANEJAR LAS ACCIONES
     */

    private boolean esRolValidoParaTareas(String rol) {
        return rol != null && (rol.equals("admin") || rol.equals("docente") || rol.equals("profesor"));
    }

    private void manejarVerTarea(HttpServletRequest request, HttpServletResponse response, HttpSession session) 
            throws ServletException, IOException {
        
        String cursoIdParam = request.getParameter("curso_id");
        if (cursoIdParam == null || cursoIdParam.isEmpty()) {
            session.setAttribute("error", "Debe especificar un curso");
            response.sendRedirect("dashboard.jsp");
            return;
        }

        int cursoId = Integer.parseInt(cursoIdParam);
        Curso curso = cursoDao.obtenerPorId(cursoId);
        
        if (curso == null) {
            session.setAttribute("error", "Curso no encontrado");
            response.sendRedirect("dashboard.jsp");
            return;
        }

        // Verificar que el docente tiene permiso para ver este curso
        Profesor docente = (Profesor) session.getAttribute("docente");
        String rol = (String) session.getAttribute("rol");
        
        if (rol.equals("docente") || rol.equals("profesor")) {
            if (docente == null || !tieneAccesoAlCurso(docente, cursoId)) {
                session.setAttribute("error", "No tiene permisos para ver las tareas de este curso");
                response.sendRedirect("dashboard.jsp");
                return;
            }
        }

        request.setAttribute("curso", curso);
        request.setAttribute("lista", dao.listarPorCurso(cursoId));
        request.getRequestDispatcher("tareasDocente.jsp").forward(request, response);
    }

    private void manejarRegistrarTarea(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        
        String cursoIdParam = request.getParameter("curso_id");
        if (cursoIdParam == null || cursoIdParam.isEmpty()) {
            session.setAttribute("error", "Debe especificar un curso");
            response.sendRedirect("dashboard.jsp");
            return;
        }

        int cursoId = Integer.parseInt(cursoIdParam);
        Curso curso = cursoDao.obtenerPorId(cursoId);
        
        if (curso == null) {
            session.setAttribute("error", "Curso no encontrado");
            response.sendRedirect("dashboard.jsp");
            return;
        }

        // Verificar permisos del docente
        Profesor docente = (Profesor) session.getAttribute("docente");
        String rol = (String) session.getAttribute("rol");
        
        if (rol.equals("docente") || rol.equals("profesor")) {
            if (docente == null || !tieneAccesoAlCurso(docente, cursoId)) {
                session.setAttribute("error", "No tiene permisos para crear tareas en este curso");
                response.sendRedirect("dashboard.jsp");
                return;
            }
        }

        request.setAttribute("curso", curso);
        request.setAttribute("fechaActual", LocalDate.now().toString());
        request.setAttribute("fechaMinima", LocalDate.now().plusDays(1).toString());
        request.getRequestDispatcher("tareaForm.jsp").forward(request, response);
    }

    private void manejarEditarTarea(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            session.setAttribute("error", "Debe especificar una tarea");
            response.sendRedirect("dashboard.jsp");
            return;
        }

        int id = Integer.parseInt(idParam);
        Tarea tarea = dao.obtenerPorId(id);
        
        if (tarea == null) {
            session.setAttribute("error", "Tarea no encontrada");
            response.sendRedirect("dashboard.jsp");
            return;
        }

        // Verificar permisos
        Profesor docente = (Profesor) session.getAttribute("docente");
        String rol = (String) session.getAttribute("rol");
        
        if (rol.equals("docente") || rol.equals("profesor")) {
            if (docente == null || !tieneAccesoAlCurso(docente, tarea.getCursoId())) {
                session.setAttribute("error", "No tiene permisos para editar esta tarea");
                response.sendRedirect("dashboard.jsp");
                return;
            }
        }

        Curso curso = cursoDao.obtenerPorId(tarea.getCursoId());
        request.setAttribute("tarea", tarea);
        request.setAttribute("curso", curso);
        request.setAttribute("fechaActual", LocalDate.now().toString());
        request.getRequestDispatcher("tareaForm.jsp").forward(request, response);
    }

    private void manejarEliminarTarea(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            session.setAttribute("error", "Debe especificar una tarea");
            response.sendRedirect("dashboard.jsp");
            return;
        }

        int id = Integer.parseInt(idParam);
        Tarea tarea = dao.obtenerPorId(id);
        
        if (tarea == null) {
            session.setAttribute("error", "Tarea no encontrada");
            response.sendRedirect("dashboard.jsp");
            return;
        }

        // Verificar permisos
        Profesor docente = (Profesor) session.getAttribute("docente");
        String rol = (String) session.getAttribute("rol");
        
        if (rol.equals("docente") || rol.equals("profesor")) {
            if (docente == null || !tieneAccesoAlCurso(docente, tarea.getCursoId())) {
                session.setAttribute("error", "No tiene permisos para eliminar esta tarea");
                response.sendRedirect("dashboard.jsp");
                return;
            }
        }

        if (dao.eliminar(id)) {
            session.setAttribute("mensaje", "Tarea eliminada exitosamente");
        } else {
            session.setAttribute("error", "No se pudo eliminar la tarea");
        }
        
        response.sendRedirect("TareaServlet?accion=ver&curso_id=" + tarea.getCursoId());
    }

    private void manejarListarTareas(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        
        String rol = (String) session.getAttribute("rol");
        
        if (rol.equals("admin")) {
            // Admin puede ver todas las tareas
            // Aquí deberías implementar un método para listar todas las tareas
            request.setAttribute("lista", new ArrayList<Tarea>()); // Placeholder
            request.getRequestDispatcher("tareasAdmin.jsp").forward(request, response);
        } else if (rol.equals("docente") || rol.equals("profesor")) {
            // Docente ve solo sus cursos
            Profesor docente = (Profesor) session.getAttribute("docente");
            if (docente != null) {
                // Obtener cursos del docente y mostrar tareas
                request.setAttribute("mensaje", "Seleccione un curso para ver sus tareas");
                request.getRequestDispatcher("seleccionarCurso.jsp").forward(request, response);
            } else {
                session.setAttribute("error", "Información de docente no disponible");
                response.sendRedirect("dashboard.jsp");
            }
        } else {
            session.setAttribute("error", "Rol no válido para esta acción");
            response.sendRedirect("dashboard.jsp");
        }
    }

    private void manejarDetalleTarea(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            session.setAttribute("error", "Debe especificar una tarea");
            response.sendRedirect("dashboard.jsp");
            return;
        }

        int id = Integer.parseInt(idParam);
        Tarea tarea = dao.obtenerPorId(id);
        
        if (tarea == null) {
            session.setAttribute("error", "Tarea no encontrada");
            response.sendRedirect("dashboard.jsp");
            return;
        }

        Curso curso = cursoDao.obtenerPorId(tarea.getCursoId());
        request.setAttribute("tarea", tarea);
        request.setAttribute("curso", curso);
        request.getRequestDispatcher("tareaDetalle.jsp").forward(request, response);
    }

    private void guardarTarea(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        
        // Validar campos obligatorios
        String nombre = request.getParameter("nombre");
        String descripcion = request.getParameter("descripcion");
        String fechaEntrega = request.getParameter("fecha_entrega");
        String cursoIdParam = request.getParameter("curso_id");
        
        if (nombre == null || nombre.trim().isEmpty() ||
            descripcion == null || descripcion.trim().isEmpty() ||
            fechaEntrega == null || fechaEntrega.trim().isEmpty() ||
            cursoIdParam == null || cursoIdParam.trim().isEmpty()) {
            
            session.setAttribute("error", "Todos los campos son obligatorios");
            response.sendRedirect("TareaServlet?accion=registrar&curso_id=" + cursoIdParam);
            return;
        }

        try {
            // Validar formato de fecha
            LocalDate fecha = LocalDate.parse(fechaEntrega);
            if (fecha.isBefore(LocalDate.now())) {
                session.setAttribute("error", "La fecha de entrega no puede ser anterior a hoy");
                response.sendRedirect("TareaServlet?accion=registrar&curso_id=" + cursoIdParam);
                return;
            }
        } catch (DateTimeParseException e) {
            session.setAttribute("error", "Formato de fecha inválido. Use YYYY-MM-DD");
            response.sendRedirect("TareaServlet?accion=registrar&curso_id=" + cursoIdParam);
            return;
        }

        int cursoId = Integer.parseInt(cursoIdParam);
        
        // Verificar permisos
        Profesor docente = (Profesor) session.getAttribute("docente");
        String rol = (String) session.getAttribute("rol");
        
        if (rol.equals("docente") || rol.equals("profesor")) {
            if (docente == null || !tieneAccesoAlCurso(docente, cursoId)) {
                session.setAttribute("error", "No tiene permisos para crear tareas en este curso");
                response.sendRedirect("dashboard.jsp");
                return;
            }
        }

        // Crear objeto Tarea
        Tarea t = new Tarea();
        t.setNombre(nombre.trim());
        t.setDescripcion(descripcion.trim());
        t.setFechaEntrega(fechaEntrega.trim());
        t.setCursoId(cursoId);
        t.setActivo(true);

        if (dao.agregar(t)) {
            session.setAttribute("mensaje", "Tarea creada exitosamente");
            System.out.println("Nueva tarea creada: " + t.getNombre() + " (Curso: " + t.getCursoId() + ")");
        } else {
            session.setAttribute("error", "No se pudo crear la tarea");
        }

        response.sendRedirect("TareaServlet?accion=ver&curso_id=" + cursoId);
    }

    private void actualizarTarea(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            session.setAttribute("error", "ID de tarea no especificado");
            response.sendRedirect("dashboard.jsp");
            return;
        }

        int id = Integer.parseInt(idParam);
        Tarea tareaExistente = dao.obtenerPorId(id);
        
        if (tareaExistente == null) {
            session.setAttribute("error", "Tarea no encontrada");
            response.sendRedirect("dashboard.jsp");
            return;
        }

        // Validar campos obligatorios
        String nombre = request.getParameter("nombre");
        String descripcion = request.getParameter("descripcion");
        String fechaEntrega = request.getParameter("fecha_entrega");
        
        if (nombre == null || nombre.trim().isEmpty() ||
            descripcion == null || descripcion.trim().isEmpty() ||
            fechaEntrega == null || fechaEntrega.trim().isEmpty()) {
            
            session.setAttribute("error", "Todos los campos son obligatorios");
            response.sendRedirect("TareaServlet?accion=editar&id=" + id);
            return;
        }

        try {
            // Validar formato de fecha
            LocalDate fecha = LocalDate.parse(fechaEntrega);
            if (fecha.isBefore(LocalDate.now())) {
                session.setAttribute("error", "La fecha de entrega no puede ser anterior a hoy");
                response.sendRedirect("TareaServlet?accion=editar&id=" + id);
                return;
            }
        } catch (DateTimeParseException e) {
            session.setAttribute("error", "Formato de fecha inválido. Use YYYY-MM-DD");
            response.sendRedirect("TareaServlet?accion=editar&id=" + id);
            return;
        }

        // Verificar permisos
        Profesor docente = (Profesor) session.getAttribute("docente");
        String rol = (String) session.getAttribute("rol");
        
        if (rol.equals("docente") || rol.equals("profesor")) {
            if (docente == null || !tieneAccesoAlCurso(docente, tareaExistente.getCursoId())) {
                session.setAttribute("error", "No tiene permisos para editar esta tarea");
                response.sendRedirect("dashboard.jsp");
                return;
            }
        }

        // Actualizar objeto Tarea
        tareaExistente.setNombre(nombre.trim());
        tareaExistente.setDescripcion(descripcion.trim());
        tareaExistente.setFechaEntrega(fechaEntrega.trim());

        if (dao.actualizar(tareaExistente)) {
            session.setAttribute("mensaje", "Tarea actualizada exitosamente");
            System.out.println("Tarea actualizada: " + tareaExistente.getNombre() + " (ID: " + id + ")");
        } else {
            session.setAttribute("error", "No se pudo actualizar la tarea");
        }

        response.sendRedirect("TareaServlet?accion=ver&curso_id=" + tareaExistente.getCursoId());
    }

    private void cambiarEstadoTarea(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        String estadoParam = request.getParameter("estado");
        
        if (idParam == null || idParam.isEmpty() || estadoParam == null || estadoParam.isEmpty()) {
            session.setAttribute("error", "Parámetros incompletos");
            response.sendRedirect("dashboard.jsp");
            return;
        }

        int id = Integer.parseInt(idParam);
        boolean activo = Boolean.parseBoolean(estadoParam);
        
        Tarea tarea = dao.obtenerPorId(id);
        if (tarea == null) {
            session.setAttribute("error", "Tarea no encontrada");
            response.sendRedirect("dashboard.jsp");
            return;
        }

        // Verificar permisos
        Profesor docente = (Profesor) session.getAttribute("docente");
        String rol = (String) session.getAttribute("rol");
        
        if (rol.equals("docente") || rol.equals("profesor")) {
            if (docente == null || !tieneAccesoAlCurso(docente, tarea.getCursoId())) {
                session.setAttribute("error", "No tiene permisos para cambiar el estado de esta tarea");
                response.sendRedirect("dashboard.jsp");
                return;
            }
        }

        tarea.setActivo(activo);
        
        if (dao.actualizar(tarea)) {
            String mensaje = activo ? "Tarea activada exitosamente" : "Tarea desactivada exitosamente";
            session.setAttribute("mensaje", mensaje);
        } else {
            session.setAttribute("error", "No se pudo cambiar el estado de la tarea");
        }

        response.sendRedirect("TareaServlet?accion=ver&curso_id=" + tarea.getCursoId());
    }

    /**
     * Método auxiliar para verificar si un docente tiene acceso a un curso
     * Debes implementar esta lógica según tu base de datos
     */
    private boolean tieneAccesoAlCurso(Profesor docente, int cursoId) {
        // Aquí debes implementar la lógica para verificar si el docente
        // tiene asignado el curso especificado
        // Por ahora, devolvemos true como placeholder
        // Deberías tener un método en ProfesorDAO o CursoDAO para esto
        return true;
    }
}