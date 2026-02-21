package controlador;

import modelo.Alumno;
import modelo.Curso;
import modelo.CursoDAO;
import modelo.Observacion;
import modelo.ObservacionDAO;
import modelo.Grado;
import modelo.GradoDAO;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.file.Paths;
import java.util.List;
import java.util.ArrayList;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import javax.servlet.http.HttpSession;

@WebServlet(name = "ObservacionServlet", urlPatterns = {"/ObservacionServlet"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1, // 1MB
    maxFileSize = 1024 * 1024 * 5,       // 5MB
    maxRequestSize = 1024 * 1024 * 10    // 10MB
)
public class ObservacionServlet extends HttpServlet {

    private ObservacionDAO dao = new ObservacionDAO();
    private CursoDAO cursoDAO = new CursoDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String accion = request.getParameter("accion");
        if (accion == null) accion = "listar";

        try {
            String cursoIdParam = request.getParameter("curso_id");
           
            if (cursoIdParam == null || cursoIdParam.isEmpty()) {
            HttpSession sess = request.getSession(false);

            modelo.Profesor docente = (modelo.Profesor) sess.getAttribute("docente");
            if (docente == null) {
                response.sendRedirect("DocenteDashboardServlet");
                return;
            }
            int profesorId = docente.getId();
            System.out.println(">>> profesorId obtenido: " + profesorId);

            List<Curso> cursos = cursoDAO.listarPorProfesor(profesorId);
            if (cursos.size() == 1) {
                response.sendRedirect("ObservacionServlet?accion=listar&curso_id=" + cursos.get(0).getId());
            } else {
                request.setAttribute("cursos", cursos);
                request.setAttribute("moduloDestino", "ObservacionServlet");
                request.setAttribute("moduloNombre", "Observaciones");
                request.getRequestDispatcher("seleccionarCurso.jsp").forward(request, response);
            }
            return;
        }
            int cursoId = Integer.parseInt(cursoIdParam);
            Curso curso = cursoDAO.obtenerPorId(cursoId);
            request.setAttribute("curso", curso);

            // Recuperamos parámetros de filtro
            String nivel = request.getParameter("nivel");
            String gradoIdStr = request.getParameter("grado_id");
            String turnoIdStr = request.getParameter("turno_id");

            switch (accion) {
                case "listar":
                    request.setAttribute("lista", dao.listarPorCurso(cursoId));
                    request.getRequestDispatcher("observacionesDocente.jsp").forward(request, response);
                    break;

                case "registrar":
                case "editar":
                    System.out.println(">>> gradoIdStr = [" + gradoIdStr + "]");
                    System.out.println(">>> turnoIdStr = [" + turnoIdStr + "]");
                    
                    GradoDAO gradoDAO = new GradoDAO();
                    List<Grado> listaGrados = gradoDAO.listarActivos();
                    request.setAttribute("listaGrados", listaGrados);

                    if (accion.equals("editar")) {
                        String idEditarStr = request.getParameter("id");
                        if (idEditarStr != null) {
                            int idEditar = Integer.parseInt(idEditarStr);
                            Observacion obs = dao.obtenerPorId(idEditar);
                            request.setAttribute("observacion", obs);
                        }
                    }

                    // Lógica de filtrado: Solo filtramos si el usuario envió el grado
                    if (gradoIdStr != null && !gradoIdStr.isEmpty()) {
                        int gId = Integer.parseInt(gradoIdStr);
                        int tId = (turnoIdStr != null && !turnoIdStr.isEmpty()) ? Integer.parseInt(turnoIdStr) : 1;
                        
                        List<Alumno> alumnosFiltrados = dao.listarAlumnosPorFiltro(nivel, gId, tId);
                        request.setAttribute("alumnos", alumnosFiltrados);
                        
                        // Devolvemos los valores para mantener los SELECTS seleccionados
                        request.setAttribute("nivel_sel", nivel);
                        request.setAttribute("grado_sel", gId);
                        request.setAttribute("turno_sel", tId);
                    } else {
                        request.setAttribute("alumnos", new ArrayList<Alumno>());
                        if (curso != null) {
                            int turnoAutomatico = cursoDAO.obtenerTurnoIdPorCurso(curso.getId());
                            System.out.println(">>> TURNO DETECTADO: " + turnoAutomatico);

                            String nivelCurso = curso.getNivel();
                            int gradoCurso = curso.getGradoId();

                            // Buscar alumnos automáticamente
                            List<Alumno> alumnosAuto = dao.listarAlumnosPorFiltro(nivelCurso, gradoCurso, turnoAutomatico);
                            request.setAttribute("alumnos", alumnosAuto);

                            request.setAttribute("nivel_sel", nivelCurso);
                            request.setAttribute("grado_sel", gradoCurso);
                            request.setAttribute("turno_sel", turnoAutomatico);
                        }
                    }
                    request.getRequestDispatcher("observacionForm.jsp").forward(request, response);
                    break;

                case "eliminar":
                    int idEliminar = Integer.parseInt(request.getParameter("id"));
                    dao.eliminar(idEliminar);
                    response.sendRedirect("ObservacionServlet?accion=listar&curso_id=" + cursoId);
                    break;
            }
        } catch (Exception e) {
            mostrarErrorEnPantalla(response, e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");

        try {
            String idStr = request.getParameter("id");
            int id = (idStr != null && !idStr.isEmpty()) ? Integer.parseInt(idStr) : 0;
            int cursoId = Integer.parseInt(request.getParameter("curso_id"));
            
            // Validar que se haya seleccionado un alumno
            String alumnoIdStr = request.getParameter("alumno_id");
            if (alumnoIdStr == null || alumnoIdStr.isEmpty()) {
                throw new Exception("Debe seleccionar un alumno de la lista filtrada.");
            }
            int alumnoId = Integer.parseInt(alumnoIdStr);
            
            String texto = request.getParameter("texto");
            String tipo = request.getParameter("tipo");

            if(texto == null || texto.trim().isEmpty()) {
                throw new Exception("La descripción de la observación es obligatoria.");
            }

            // Gestionar archivo
            String nombreArchivo = null;
            if (id > 0) {
                Observacion obsExistente = dao.obtenerPorId(id);
                if (obsExistente != null) nombreArchivo = obsExistente.getRutaEvidencia();
            }

            String nuevoArchivo = subirArchivoManual(request);
            if (nuevoArchivo != null) nombreArchivo = nuevoArchivo;

            Observacion o = new Observacion();
            o.setId(id);
            o.setCursoId(cursoId);
            o.setAlumnoId(alumnoId);
            o.setTexto(texto);
            o.setTipo(tipo);
            o.setRutaEvidencia(nombreArchivo);

            boolean exito = (id == 0) ? dao.agregar(o) : dao.actualizar(o);

            if (exito) {
                response.sendRedirect("ObservacionServlet?accion=listar&curso_id=" + cursoId + "&success=true");
            } else {
                throw new Exception("Error al guardar en la base de datos.");
            }
        } catch (Exception e) {
            mostrarErrorEnPantalla(response, e);
        }
    }

        private String subirArchivoManual(HttpServletRequest request) {
        try {
            Part filePart = request.getPart("evidencia");
            if (filePart != null && filePart.getSize() > 0) {
                String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();

                // ✅ VALIDAR EXTENSIÓN - AGREGAR AQUÍ
                String ext = fileName.toLowerCase();
                if (!ext.endsWith(".jpg") && !ext.endsWith(".jpeg") && 
                    !ext.endsWith(".png") && !ext.endsWith(".pdf") && 
                    !ext.endsWith(".docx")) {
                    System.err.println("Archivo rechazado: " + fileName);
                    return null;
                }

                String limpio = java.text.Normalizer.normalize(fileName, java.text.Normalizer.Form.NFD)
                                .replaceAll("[^\\p{ASCII}]", "").replaceAll("\\s+", "_");

                String uniqueFileName = System.currentTimeMillis() + "_" + limpio;
                String applicationPath = request.getServletContext().getRealPath("");
                String uploadDir = "assets" + File.separator + "evidencias";
                String uploadFilePath = applicationPath + File.separator + uploadDir;
                File uploadDirFile = new File(uploadFilePath);
                if (!uploadDirFile.exists()) uploadDirFile.mkdirs();
                filePart.write(uploadFilePath + File.separator + uniqueFileName);
                return uniqueFileName;
            }
        } catch (Exception e) { 
            System.err.println("Error subiendo archivo: " + e.getMessage());
        }
        return null;
    }
    private void mostrarErrorEnPantalla(HttpServletResponse response, Exception e) throws IOException {
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        out.println("<html><body style='font-family:sans-serif; padding:40px; background:#fef2f2;'>");
        out.println("<div style='max-width:600px; margin:auto; border:2px solid #ef4444; padding:20px; border-radius:12px; background:white;'>");
        out.println("<h2 style='color:#b91c1c; margin-top:0;'>⚠️ Error de Validación</h2>");
        out.println("<p style='color:#4b5563;'><b>Detalle:</b> " + e.getMessage() + "</p>");
        out.println("<hr style='border:1px solid #fee2e2;'>");
        out.println("<button onclick='history.back()' style='background:#ef4444; color:white; border:none; padding:10px 20px; border-radius:6px; cursor:pointer; font-weight:bold;'>Intentar de nuevo</button>");
        out.println("</div></body></html>");
    }
}