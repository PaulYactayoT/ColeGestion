/*
 * SERVLET PARA GESTIÓN DE TAREAS Y ACTIVIDADES ACADÉMICAS
 */
package controlador;

import modelo.Tarea;
import modelo.TareaDAO;
import modelo.Curso;
import modelo.CursoDAO;
import java.io.File;
import java.util.List;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import javax.servlet.*;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.*;

@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 10,       // 10MB
    maxRequestSize = 1024 * 1024 * 15     // 15MB
)
public class TareaServlet extends HttpServlet {
      
    private static final String UPLOAD_DIR = "uploads/tareas";
    TareaDAO dao = new TareaDAO();
    CursoDAO cursoDao = new CursoDAO();

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
        
        if (!esRolValidoParaTareas(rol)) {
            session.setAttribute("error", "No tiene permisos para acceder a esta sección");
            response.sendRedirect("DocenteDashboardServlet");
            return;
        }

        try {
            if (accion == null || accion.isEmpty()) accion = "listar";

            switch (accion) {
                case "ver": manejarVerTarea(request, response, session); break;
                case "registrar": manejarRegistrarTarea(request, response, session); break;
                case "editar": manejarEditarTarea(request, response, session); break;
                case "eliminar": manejarEliminarTarea(request, response, session); break;
                case "listar": manejarListarTareas(request, response, session); break;
                case "detalle": manejarDetalleTarea(request, response, session); break;
                default: response.sendRedirect("DocenteDashboardServlet");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("DocenteDashboardServlet");
        }
    }

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
            response.sendRedirect("DocenteDashboardServlet");
            return;
        }

        String accion = request.getParameter("accion");
        if (accion == null) accion = "guardar";

        try {
            switch (accion) {
                case "guardar": guardarTarea(request, response, session); break;
                case "actualizar": actualizarTarea(request, response, session); break;
                case "cambiarEstado": cambiarEstadoTarea(request, response, session); break;
                default: response.sendRedirect("TareaServlet?accion=listar");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "Error: " + e.getMessage());
            response.sendRedirect("TareaServlet?accion=listar");
        }
    }

    // --- MÉTODOS PRIVADOS ---

    private boolean esRolValidoParaTareas(String rol) {
        return rol != null && (rol.equals("admin") || rol.equals("docente") || rol.equals("profesor"));
    }

    private void manejarVerTarea(HttpServletRequest request, HttpServletResponse response, HttpSession session) throws ServletException, IOException {
        String cursoIdParam = request.getParameter("curso_id");
        if (cursoIdParam == null || cursoIdParam.isEmpty()) { response.sendRedirect("DocenteDashboardServlet"); return; }
        
        int cursoId = Integer.parseInt(cursoIdParam);
        Curso curso = cursoDao.obtenerPorId(cursoId);
        if (curso == null) { response.sendRedirect("DocenteDashboardServlet"); return; }

        request.setAttribute("curso", curso);
        // Aquí dao.listarPorCurso ya trae el estado calculado y la hora
        request.setAttribute("lista", dao.listarPorCurso(cursoId));
        request.getRequestDispatcher("tareasDocente.jsp").forward(request, response);
    }

    private void manejarRegistrarTarea(HttpServletRequest request, HttpServletResponse response, HttpSession session) throws ServletException, IOException {
        String cursoIdParam = request.getParameter("curso_id");
        if (cursoIdParam != null) {
            Curso curso = cursoDao.obtenerPorId(Integer.parseInt(cursoIdParam));
            request.setAttribute("curso", curso);
            request.getRequestDispatcher("tareaForm.jsp").forward(request, response);
        }
    }

    private void manejarEditarTarea(HttpServletRequest request, HttpServletResponse response, HttpSession session) throws ServletException, IOException {
        String idParam = request.getParameter("id");
        if (idParam != null) {
            Tarea tarea = dao.obtenerPorId(Integer.parseInt(idParam));
            Curso curso = cursoDao.obtenerPorId(tarea.getCursoId());
            request.setAttribute("tarea", tarea);
            request.setAttribute("curso", curso);
            request.getRequestDispatcher("tareaForm.jsp").forward(request, response);
        }
    }

    private void manejarEliminarTarea(HttpServletRequest request, HttpServletResponse response, HttpSession session) throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Tarea tarea = dao.obtenerPorId(id);
        if (tarea != null) {
            dao.eliminar(id);
            response.sendRedirect("TareaServlet?accion=ver&curso_id=" + tarea.getCursoId());
        }
    }

    private void manejarListarTareas(HttpServletRequest request, HttpServletResponse response, HttpSession session) throws ServletException, IOException {
        modelo.Profesor docente = (modelo.Profesor) session.getAttribute("docente");
        if (docente == null) { response.sendRedirect("DocenteDashboardServlet"); return; }

        List<Curso> cursos = cursoDao.listarPorProfesor(docente.getId());
        if (cursos.size() == 1) {
            response.sendRedirect("TareaServlet?accion=ver&curso_id=" + cursos.get(0).getId());
        } else {
            request.setAttribute("cursos", cursos);
            request.setAttribute("moduloDestino", "TareaServlet");
            request.setAttribute("moduloAccion", "ver");  // ✅ FIX: el JSP usará ?accion=ver
            request.setAttribute("moduloNombre", "Tareas");
            request.getRequestDispatcher("seleccionarCurso.jsp").forward(request, response);
        }
    }

    private void manejarDetalleTarea(HttpServletRequest request, HttpServletResponse response, HttpSession session) throws ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Tarea tarea = dao.obtenerPorId(id);
        Curso curso = cursoDao.obtenerPorId(tarea.getCursoId());
        request.setAttribute("tarea", tarea);
        request.setAttribute("curso", curso);
        request.getRequestDispatcher("tareaDetalle.jsp").forward(request, response);
    }

    private void cambiarEstadoTarea(HttpServletRequest request, HttpServletResponse response, HttpSession session) throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        boolean activo = Boolean.parseBoolean(request.getParameter("estado"));
        Tarea t = dao.obtenerPorId(id);
        if (t != null) {
            dao.cambiarEstado(id, activo);
            response.sendRedirect("TareaServlet?accion=ver&curso_id=" + t.getCursoId());
        }
    }

    // --- LÓGICA DE ARCHIVOS ---
    
    private String guardarArchivo(HttpServletRequest request) throws ServletException, IOException {
        Part filePart = request.getPart("archivo");
        if (filePart == null || filePart.getSize() == 0) return null;
        
        // Obtener nombre original
        String fileName = extractFileName(filePart); 
        if (fileName == null || fileName.isEmpty()) return null;

        // VALIDACIÓN DE EXTENSIONES (PDF, Word, Imágenes)
        String nameLower = fileName.toLowerCase();
        if (!nameLower.endsWith(".pdf") && 
            !nameLower.endsWith(".doc") && 
            !nameLower.endsWith(".docx") && 
            !nameLower.endsWith(".jpg") && 
            !nameLower.endsWith(".jpeg") && 
            !nameLower.endsWith(".png")) {
            // Puedes lanzar excepción o retornar null y manejar error
            throw new ServletException("Formato no permitido. Solo se permiten archivos PDF, Word o Imágenes.");
        }
        
        // Generar nombre único para evitar colisiones
        String uniqueFileName = System.currentTimeMillis() + "_" + fileName;
        
        // Ruta absoluta donde se guardará
        String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdir();
        
        String filePath = uploadPath + File.separator + uniqueFileName;
        
        // Guardar archivo en disco
        Files.copy(filePart.getInputStream(), new File(filePath).toPath(), StandardCopyOption.REPLACE_EXISTING);
        
        return uniqueFileName;
    }
    
    // Método auxiliar para obtener nombre del archivo desde el Part
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

    // --- GUARDAR Y ACTUALIZAR ---

    private void guardarTarea(HttpServletRequest request, HttpServletResponse response, HttpSession session) throws ServletException, IOException {
        // Recolección de datos
        try {
            String nombre = request.getParameter("nombre");
            String descripcion = request.getParameter("descripcion");
            String fechaEntrega = request.getParameter("fecha_entrega");
            
            // ✅ CAPTURA DE HORA (Asegúrate de que en el JSP el name sea "hora_entrega")
            String horaEntrega = request.getParameter("hora_entrega"); 
            
            int cursoId = Integer.parseInt(request.getParameter("curso_id"));
            String tipo = request.getParameter("tipo");
            String instrucciones = request.getParameter("instrucciones");
            double peso = Double.parseDouble(request.getParameter("peso"));

            // Validaciones básicas
            if (horaEntrega == null || horaEntrega.isEmpty()) {
                horaEntrega = "23:59:59"; // Valor por defecto si no envían hora
            }

            // Guardar archivo
            String nombreArchivo = null;
            try {
                nombreArchivo = guardarArchivo(request); // Llama al método auxiliar
            } catch (Exception e) {
                session.setAttribute("error", "Error al subir archivo: " + e.getMessage());
                response.sendRedirect("TareaServlet?accion=registrar&curso_id=" + cursoId);
                return;
            }

            Tarea t = new Tarea();
            t.setNombre(nombre);
            t.setDescripcion(descripcion);
            t.setFechaEntrega(fechaEntrega);
            t.setHoraEntrega(horaEntrega); // ✅ Seteamos la hora
            t.setCursoId(cursoId);
            t.setTipo(tipo);
            t.setPeso(peso);
            t.setInstrucciones(instrucciones);
            t.setArchivoAdjunto(nombreArchivo);
            t.setActivo(true);

            if(dao.agregar(t)) {
                session.setAttribute("mensaje", "Tarea creada exitosamente");
            } else {
                session.setAttribute("error", "Error al crear tarea en base de datos");
            }
            response.sendRedirect("TareaServlet?accion=ver&curso_id=" + cursoId);
            
        } catch (NumberFormatException e) {
            session.setAttribute("error", "Error en formato de datos numéricos");
            response.sendRedirect("DocenteDashboardServlet");
        }
    }

    private void actualizarTarea(HttpServletRequest request, HttpServletResponse response, HttpSession session) throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            Tarea t = dao.obtenerPorId(id);
            
            if (t != null) {
                t.setNombre(request.getParameter("nombre"));
                t.setDescripcion(request.getParameter("descripcion"));
                t.setFechaEntrega(request.getParameter("fecha_entrega"));
                
                // ✅ CAPTURA Y ACTUALIZACIÓN DE HORA
                String hora = request.getParameter("hora_entrega");
                if(hora != null && !hora.isEmpty()) {
                    t.setHoraEntrega(hora);
                }
                
                t.setTipo(request.getParameter("tipo"));
                t.setPeso(Double.parseDouble(request.getParameter("peso")));
                t.setInstrucciones(request.getParameter("instrucciones"));

                // Archivo: si suben uno nuevo, se reemplaza. Si no, se mantiene el anterior.
                try {
                    String nuevoArchivo = guardarArchivo(request);
                    if (nuevoArchivo != null) {
                        t.setArchivoAdjunto(nuevoArchivo);
                    }
                } catch (Exception e) {
                    session.setAttribute("error", "Error al subir archivo: " + e.getMessage());
                    response.sendRedirect("TareaServlet?accion=editar&id=" + id);
                    return;
                }

                if(dao.actualizar(t)) {
                    session.setAttribute("mensaje", "Tarea actualizada correctamente");
                } else {
                    session.setAttribute("error", "Error al actualizar en base de datos");
                }
                response.sendRedirect("TareaServlet?accion=ver&curso_id=" + t.getCursoId());
            } else {
                session.setAttribute("error", "Tarea no encontrada");
                response.sendRedirect("DocenteDashboardServlet");
            }
        } catch (NumberFormatException e) {
            session.setAttribute("error", "Error en formato de datos numéricos");
            response.sendRedirect("DocenteDashboardServlet");
        }
    }
}