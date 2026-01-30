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
import java.util.ArrayList;
import java.util.List;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;

@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 10,        // 10MB
    maxRequestSize = 1024 * 1024 * 15      // 15MB
)
public class TareaServlet extends HttpServlet {
     
    // Ruta donde se guardarán los archivos
    private static final String UPLOAD_DIR = "uploads";
    
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

        request.setAttribute("curso", curso);
        request.getRequestDispatcher("tareaForm.jsp").forward(request, response);
    }

    private void manejarEditarTarea(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            session.setAttribute("error", "ID de tarea no especificado");
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
        request.getRequestDispatcher("tareaForm.jsp").forward(request, response);
    }

    private void manejarEliminarTarea(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            session.setAttribute("error", "ID de tarea no especificado");
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

        int cursoId = tarea.getCursoId();
        
        if (dao.eliminar(id)) {
            session.setAttribute("mensaje", "Tarea eliminada exitosamente");
            System.out.println("Tarea eliminada - ID: " + id + " del curso: " + cursoId);
        } else {
            session.setAttribute("error", "No se pudo eliminar la tarea");
        }

        response.sendRedirect("TareaServlet?accion=ver&curso_id=" + cursoId);
    }

    private void manejarListarTareas(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        
        // Esta acción solo está disponible para administradores
        String rol = (String) session.getAttribute("rol");
        if (!rol.equals("admin")) {
            session.setAttribute("error", "Acceso denegado");
            response.sendRedirect("dashboard.jsp");
            return;
        }

        // Lista todas las tareas del sistema
        // Por ahora redirigimos al dashboard, ya que no hay un método listarTodas
        response.sendRedirect("dashboard.jsp");
    }

    private void manejarDetalleTarea(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            session.setAttribute("error", "ID de tarea no especificado");
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
                session.setAttribute("error", "No tiene permisos para ver esta tarea");
                response.sendRedirect("dashboard.jsp");
                return;
            }
        }

        Curso curso = cursoDao.obtenerPorId(tarea.getCursoId());
        request.setAttribute("tarea", tarea);
        request.setAttribute("curso", curso);
        request.getRequestDispatcher("tareaDetalle.jsp").forward(request, response);
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

            // Usar el método cambiarEstado() del DAO en lugar de actualizar()
            if (dao.cambiarEstado(id, activo)) {
                String mensaje = activo ? "Tarea activada exitosamente" : "Tarea desactivada exitosamente";
                session.setAttribute("mensaje", mensaje);
                System.out.println("Estado de tarea cambiado: ID=" + id + ", Activo=" + activo);
            } else {
                session.setAttribute("error", "No se pudo cambiar el estado de la tarea");
                System.out.println("Error al cambiar estado de tarea: ID=" + id);
            }

            response.sendRedirect("TareaServlet?accion=ver&curso_id=" + tarea.getCursoId());
        }

            /**
             * Método auxiliar para verificar si un docente tiene acceso a un curso
             */
            private boolean tieneAccesoAlCurso(Profesor docente, int cursoId) {
                return true;
            }
            
            
            /**
     * MÉTODO AUXILIAR PARA GUARDAR ARCHIVO SUBIDO
     */
    private String guardarArchivo(HttpServletRequest request) throws ServletException, IOException {
        Part filePart = request.getPart("archivo");
        
        if (filePart == null || filePart.getSize() == 0) {
            return null; // No se subió ningún archivo
        }
        
        String fileName = extractFileName(filePart);
        
        if (fileName == null || fileName.isEmpty()) {
            return null;
        }
        
        // Validar extensión
        if (!fileName.toLowerCase().endsWith(".pdf")) {
            throw new ServletException("Solo se permiten archivos PDF");
        }
        
        // Generar nombre único para evitar conflictos
        String uniqueFileName = System.currentTimeMillis() + "_" + fileName;
        
        // Obtener ruta absoluta del directorio de uploads
        String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
        
        // Crear directorio si no existe
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdir();
        }
        
        // Guardar el archivo
        String filePath = uploadPath + File.separator + uniqueFileName;
        Files.copy(filePart.getInputStream(), 
                   new File(filePath).toPath(), 
                   StandardCopyOption.REPLACE_EXISTING);
        
        System.out.println("Archivo guardado en: " + filePath);
        
        return uniqueFileName;
    }
    
    /**
     * EXTRAER NOMBRE DE ARCHIVO DEL PART
     */
    private String extractFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] items = contentDisp.split(";");
        for (String s : items) {
            if (s.trim().startsWith("filename")) {
                return s.substring(s.indexOf("=") + 2, s.length() - 1);
            }
        }
        return null;
    }
    
    /**
     * MÉTODO ACTUALIZADO PARA GUARDAR TAREA CON ARCHIVO
     */
    private void guardarTarea(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        
        // Validar campos obligatorios
        String nombre = request.getParameter("nombre");
        String descripcion = request.getParameter("descripcion");
        String fechaEntrega = request.getParameter("fecha_entrega");
        String cursoIdParam = request.getParameter("curso_id");
        
        // NUEVOS CAMPOS AGREGADOS
        String tipo = request.getParameter("tipo");
        String pesoParam = request.getParameter("peso");
        String instrucciones = request.getParameter("instrucciones");
        
        if (nombre == null || nombre.trim().isEmpty() ||
            descripcion == null || descripcion.trim().isEmpty() ||
            fechaEntrega == null || fechaEntrega.trim().isEmpty() ||
            cursoIdParam == null || cursoIdParam.trim().isEmpty()) {
            
            session.setAttribute("error", "Los campos nombre, descripción, fecha de entrega y curso son obligatorios");
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
        
        // Validar y parsear peso
        double peso = 1.0;
        if (pesoParam != null && !pesoParam.trim().isEmpty()) {
            try {
                peso = Double.parseDouble(pesoParam);
                if (peso < 0 || peso > 100) {
                    session.setAttribute("error", "El peso debe estar entre 0 y 100");
                    response.sendRedirect("TareaServlet?accion=registrar&curso_id=" + cursoIdParam);
                    return;
                }
            } catch (NumberFormatException e) {
                session.setAttribute("error", "El peso debe ser un número válido");
                response.sendRedirect("TareaServlet?accion=registrar&curso_id=" + cursoIdParam);
                return;
            }
        }
        
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

        // GUARDAR ARCHIVO SI SE SUBIÓ UNO
        String nombreArchivo = null;
        try {
            nombreArchivo = guardarArchivo(request);
        } catch (Exception e) {
            session.setAttribute("error", "Error al guardar el archivo: " + e.getMessage());
            response.sendRedirect("TareaServlet?accion=registrar&curso_id=" + cursoId);
            return;
        }

        // Crear objeto Tarea con TODOS los campos
        Tarea t = new Tarea();
        t.setNombre(nombre.trim());
        t.setDescripcion(descripcion.trim());
        t.setFechaEntrega(fechaEntrega.trim());
        t.setCursoId(cursoId);
        t.setActivo(true);
        t.setTipo(tipo != null && !tipo.trim().isEmpty() ? tipo.trim() : "TAREA");
        t.setPeso(peso);
        t.setInstrucciones(instrucciones != null ? instrucciones.trim() : "");
        t.setArchivoAdjunto(nombreArchivo); // NUEVO CAMPO

        if (dao.agregar(t)) {
            session.setAttribute("mensaje", "Tarea creada exitosamente" + (nombreArchivo != null ? " con archivo adjunto" : ""));
            System.out.println("Nueva tarea creada: " + t.getNombre() + " (Curso: " + t.getCursoId() + ")");
        } else {
            session.setAttribute("error", "No se pudo crear la tarea");
        }

        response.sendRedirect("TareaServlet?accion=ver&curso_id=" + cursoId);
    }

    /**
     * MÉTODO ACTUALIZADO PARA ACTUALIZAR TAREA CON ARCHIVO
     */
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
        String tipo = request.getParameter("tipo");
        String pesoParam = request.getParameter("peso");
        String instrucciones = request.getParameter("instrucciones");
        
        if (nombre == null || nombre.trim().isEmpty() ||
            descripcion == null || descripcion.trim().isEmpty() ||
            fechaEntrega == null || fechaEntrega.trim().isEmpty()) {
            
            session.setAttribute("error", "Los campos nombre, descripción y fecha de entrega son obligatorios");
            response.sendRedirect("TareaServlet?accion=editar&id=" + id);
            return;
        }

        try {
            LocalDate fecha = LocalDate.parse(fechaEntrega);
            if (fecha.isBefore(LocalDate.now())) {
                session.setAttribute("error", "La fecha de entrega no puede ser anterior a hoy");
                response.sendRedirect("TareaServlet?accion=editar&id=" + id);
                return;
            }
        } catch (DateTimeParseException e) {
            session.setAttribute("error", "Formato de fecha inválido");
            response.sendRedirect("TareaServlet?accion=editar&id=" + id);
            return;
        }

        double peso = 1.0;
        if (pesoParam != null && !pesoParam.trim().isEmpty()) {
            try {
                peso = Double.parseDouble(pesoParam);
                if (peso < 0 || peso > 100) {
                    session.setAttribute("error", "El peso debe estar entre 0 y 100");
                    response.sendRedirect("TareaServlet?accion=editar&id=" + id);
                    return;
                }
            } catch (NumberFormatException e) {
                session.setAttribute("error", "El peso debe ser un número válido");
                response.sendRedirect("TareaServlet?accion=editar&id=" + id);
                return;
            }
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

        // GUARDAR NUEVO ARCHIVO SI SE SUBIÓ UNO
        String nombreArchivo = tareaExistente.getArchivoAdjunto(); // Mantener el archivo anterior por defecto
        try {
            String nuevoArchivo = guardarArchivo(request);
            if (nuevoArchivo != null) {
                nombreArchivo = nuevoArchivo; // Actualizar si se subió un nuevo archivo
            }
        } catch (Exception e) {
            session.setAttribute("error", "Error al guardar el archivo: " + e.getMessage());
            response.sendRedirect("TareaServlet?accion=editar&id=" + id);
            return;
        }

        // Actualizar objeto Tarea con TODOS los campos
        tareaExistente.setNombre(nombre.trim());
        tareaExistente.setDescripcion(descripcion.trim());
        tareaExistente.setFechaEntrega(fechaEntrega.trim());
        tareaExistente.setTipo(tipo != null && !tipo.trim().isEmpty() ? tipo.trim() : "TAREA");
        tareaExistente.setPeso(peso);
        tareaExistente.setInstrucciones(instrucciones != null ? instrucciones.trim() : "");
        tareaExistente.setArchivoAdjunto(nombreArchivo); // NUEVO CAMPO

        if (dao.actualizar(tareaExistente)) {
            session.setAttribute("mensaje", "Tarea actualizada exitosamente");
            System.out.println("Tarea actualizada: " + tareaExistente.getNombre() + " (ID: " + id + ")");
        } else {
            session.setAttribute("error", "No se pudo actualizar la tarea");
        }

        response.sendRedirect("TareaServlet?accion=ver&curso_id=" + tareaExistente.getCursoId());
    }
}


