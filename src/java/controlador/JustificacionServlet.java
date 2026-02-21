package controlador;

import modelo.*;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.*;
import java.time.LocalDateTime;
import java.util.List;

@WebServlet("/JustificacionServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,
    maxFileSize = 1024 * 1024 * 5,
    maxRequestSize = 1024 * 1024 * 10
)
public class JustificacionServlet extends HttpServlet {
    
    private JustificacionDAO justificacionDAO;
    private AsistenciaDAO asistenciaDAO;
    private AlumnoDAO alumnoDAO;
    
    @Override
    public void init() throws ServletException {
        justificacionDAO = new JustificacionDAO();
        asistenciaDAO = new AsistenciaDAO();
        alumnoDAO = new AlumnoDAO();
        System.out.println("✅ JustificacionServlet inicializado");
    }
    
    /**
     * MANEJO DE PETICIONES GET
     * Controla las acciones que solo muestran información (sin modificar datos):
     * - "form"     → Muestra el formulario para que el padre justifique una ausencia
     * - "historial"→ Muestra el historial de justificaciones enviadas por el padre
     * - "listar"   → Muestra las justificaciones pendientes para el docente
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String accion = request.getParameter("accion");
        
        System.out.println("🔍 JustificacionServlet - GET - Acción: " + accion);
        
        if (accion == null) accion = "listar";
        
        switch (accion) {
            case "form":
                // Carga las ausencias del alumno para que el padre pueda justificarlas
                mostrarFormulario(request, response);
                break;
            case "historial":
                // Carga el historial de justificaciones enviadas por el padre
                mostrarHistorialPadre(request, response);
                break;
            case "listar":
            case "pending":
                request.getRequestDispatcher("revisarJustificaciones.jsp").forward(request, response);
                break;
            default:
                request.getRequestDispatcher("revisarJustificaciones.jsp").forward(request, response);
        }
    }
    
    /**
     * MANEJO DE PETICIONES POST
     * Controla las acciones que modifican datos:
     * - "crear"    → El padre envía una nueva justificación
     * - "aprobar"  → El docente aprueba una justificación pendiente
     * - "rechazar" → El docente rechaza una justificación pendiente
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String accion = request.getParameter("accion");
        
        System.out.println("JustificacionServlet - POST - Acción: " + accion);
        
        if (accion == null) {
            request.getRequestDispatcher("revisarJustificaciones.jsp").forward(request, response);
            return;
        }
        
        switch (accion) {
            case "crear":
                crearJustificacion(request, response);
                break;
            case "aprobar":
                aprobarJustificacion(request, response);
                break;
            case "rechazar":
                rechazarJustificacion(request, response);
                break;
            default:
                request.getRequestDispatcher("revisarJustificaciones.jsp").forward(request, response);
        }
    }
    
    /**
     * MOSTRAR FORMULARIO DE JUSTIFICACIÓN (panel del padre)
     * Busca al alumno asociado al padre logueado y carga sus ausencias
     * sin justificar para que el padre pueda seleccionar cuál justificar.
     */
    private void mostrarFormulario(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            Integer personaId = (Integer) session.getAttribute("personaId");
            
            if (personaId == null) {
                System.out.println("PersonaId es null - Redirigiendo a login");
                response.sendRedirect("index.jsp");
                return;
            }
            
            System.out.println("Buscando alumno para personaId (padre): " + personaId);
            
            Alumno alumno = alumnoDAO.obtenerAlumnoPorPadreId(personaId);
            
            if (alumno == null) {
                System.out.println("No se encontró alumno asociado al padre: " + personaId);
                request.setAttribute("error", "No se encontró información del estudiante asociado a su cuenta.");
                request.setAttribute("ausencias", new java.util.ArrayList<>());
                request.setAttribute("alumnoId", null);
                request.getRequestDispatcher("justificarAusencia.jsp").forward(request, response);
                return;
            }
            
            int alumnoId = alumno.getId();
            String alumnoNombre = alumno.getNombreCompleto();
            System.out.println("Alumno encontrado: ID=" + alumnoId + " - " + alumnoNombre);
            
            List<Asistencia> ausencias = asistenciaDAO.obtenerAusenciasSinJustificar(alumnoId);
            
            System.out.println("Total de ausencias sin justificar: " + ausencias.size());
            
            request.setAttribute("ausencias", ausencias);
            request.setAttribute("alumnoId", alumnoId);
            request.setAttribute("alumnoNombre", alumnoNombre);
            
            if (ausencias.isEmpty()) {
                request.setAttribute("mensaje", 
                    "El estudiante " + alumnoNombre + " no tiene ausencias pendientes de justificación.");
            }
            
            request.getRequestDispatcher("justificarAusencia.jsp").forward(request, response);
            
        } catch (Exception e) {
            System.out.println("Error en mostrarFormulario: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Error al cargar el formulario: " + e.getMessage());
            request.setAttribute("ausencias", new java.util.ArrayList<>());
            request.getRequestDispatcher("justificarAusencia.jsp").forward(request, response);
        }
    }

    /**
     * MOSTRAR HISTORIAL DE JUSTIFICACIONES (panel del padre)
     * Obtiene todas las justificaciones que el padre ha enviado para su hijo,
     * incluyendo las PENDIENTES, APROBADAS y RECHAZADAS, y las manda
     * a justificacionesPadre.jsp para mostrarlas con su estado actual.
     */
    private void mostrarHistorialPadre(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            Padre padre = (Padre) session.getAttribute("padre");

            if (padre == null) {
                System.out.println("❌ Padre no encontrado en sesión - Redirigiendo a login");
                response.sendRedirect("index.jsp");
                return;
            }

            int alumnoId = padre.getAlumnoId();
            System.out.println("📋 Cargando historial de justificaciones para alumno ID: " + alumnoId);

            // Obtiene todas las justificaciones del alumno (todos los estados)
            List<Justificacion> justificaciones = justificacionDAO.obtenerHistorialPorAlumno(alumnoId);

            System.out.println("✅ Justificaciones encontradas: " + justificaciones.size());

            request.setAttribute("justificaciones", justificaciones);
            request.getRequestDispatcher("justificacionesPadre.jsp").forward(request, response);

        } catch (Exception e) {
            System.out.println("❌ Error en mostrarHistorialPadre: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("justificaciones", new java.util.ArrayList<>());
            request.setAttribute("error", "Error al cargar el historial: " + e.getMessage());
            request.getRequestDispatcher("justificacionesPadre.jsp").forward(request, response);
        }
    }
    
    /**
     * CREAR JUSTIFICACIÓN (acción del padre)
     * Recibe los datos del formulario de justificación enviado por el padre,
     * guarda el archivo adjunto si existe, y registra la justificación en la BD
     * con estado PENDIENTE para que el docente la revise.
     */
    private void crearJustificacion(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            Integer personaId = (Integer) session.getAttribute("personaId");
            
            if (personaId == null) {
                response.sendRedirect("index.jsp");
                return;
            }
            
            int asistenciaId = Integer.parseInt(request.getParameter("asistenciaId"));
            int alumnoId = Integer.parseInt(request.getParameter("alumnoId"));
            String tipoStr = request.getParameter("tipoJustificacion");
            String descripcion = request.getParameter("descripcion");
            
            System.out.println(" Creando justificación:");
            System.out.println("   - AsistenciaId: " + asistenciaId);
            System.out.println("   - AlumnoId: " + alumnoId);
            System.out.println("   - Tipo: " + tipoStr);
            System.out.println("   - JustificadoPor: " + personaId);
            
            Justificacion justificacion = new Justificacion();
            justificacion.setAsistenciaId(asistenciaId);
            justificacion.setTipoJustificacionFromString(tipoStr);
            justificacion.setDescripcion(descripcion);
            justificacion.setJustificadoPor(personaId);
            justificacion.setFechaJustificacion(LocalDateTime.now());
            
            Part filePart = request.getPart("archivo");
            if (filePart != null && filePart.getSize() > 0) {
                String fileName = getFileName(filePart);
                
                String extension = fileName.substring(fileName.lastIndexOf(".")).toLowerCase();
                String[] allowedExtensions = {".pdf", ".doc", ".docx", ".jpg", ".jpeg", ".png"};
                boolean isValidFormat = false;
                
                for (String ext : allowedExtensions) {
                    if (extension.equals(ext)) {
                        isValidFormat = true;
                        break;
                    }
                }
                
                if (!isValidFormat) {
                    session.setAttribute("error", "Formato de archivo no permitido. Solo se aceptan: PDF, Word (.doc, .docx) e imágenes (JPG, PNG)");
                    response.sendRedirect("JustificacionServlet?accion=form");
                    return;
                }
                
                long fileSize = filePart.getSize();
                long maxSize = 5 * 1024 * 1024;
                
                if (fileSize > maxSize) {
                    session.setAttribute("error", "El archivo es demasiado grande. Tamaño máximo: 5MB");
                    response.sendRedirect("JustificacionServlet?accion=form");
                    return;
                }
                
                String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads" + 
                                   File.separator + "justificaciones";
                
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }
                
                String timestamp = String.valueOf(System.currentTimeMillis());
                String newFileName = "just_" + asistenciaId + "_" + timestamp + extension;
                String filePath = uploadPath + File.separator + newFileName;
                
                filePart.write(filePath);
                
                String relativePath = "uploads/justificaciones/" + newFileName;
                justificacion.setDocumentoAdjunto(relativePath);
            }
            
            int justificacionId = justificacionDAO.crearJustificacion(justificacion);
            
            if (justificacionId > 0) {
                session.setAttribute("mensaje", "Justificación enviada exitosamente. Será revisada por el docente.");
                response.sendRedirect("JustificacionServlet?accion=historial");  // ← va al historial para ver el estado
            } else {
                session.setAttribute("error", "Error al enviar la justificación. Intente nuevamente.");
                response.sendRedirect("JustificacionServlet?accion=form");
            }
            
        } catch (Exception e) {
            System.out.println("Error al crear justificación: " + e.getMessage());
            e.printStackTrace();
            HttpSession session = request.getSession();
            session.setAttribute("error", "Error: " + e.getMessage());
            response.sendRedirect("JustificacionServlet?accion=form");
        }
    }
    
    /**
     * APROBAR JUSTIFICACIÓN (acción del docente)
     * El docente aprueba una justificación pendiente. Actualiza el estado
     * de la justificación a APROBADO y la asistencia correspondiente a JUSTIFICADO.
     */
    private void aprobarJustificacion(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            Integer personaId = (Integer) session.getAttribute("personaId");
            
            if (personaId == null) {
                response.sendRedirect("index.jsp");
                return;
            }
            
            int justificacionId = Integer.parseInt(request.getParameter("justificacionId"));
            String observaciones = request.getParameter("observaciones");
            int cursoId = Integer.parseInt(request.getParameter("cursoId"));
            int turnoId = Integer.parseInt(request.getParameter("turnoId"));
            
            System.out.println("✅ Aprobando justificación ID: " + justificacionId);
            
            boolean resultado = justificacionDAO.aprobarJustificacion(
                justificacionId, personaId, observaciones
            );
            
            if (resultado) {
                session.setAttribute("mensaje", "Justificación aprobada exitosamente");
            } else {
                session.setAttribute("error", "Error al aprobar justificación");
            }
            
            request.getRequestDispatcher("revisarJustificaciones.jsp?cursoId=" + cursoId + "&turnoId=" + turnoId).forward(request, response);
            
        } catch (Exception e) {
            System.out.println("Error al aprobar: " + e.getMessage());
            e.printStackTrace();
            HttpSession session = request.getSession();
            session.setAttribute("error", "Error: " + e.getMessage());
            request.getRequestDispatcher("revisarJustificaciones.jsp").forward(request, response);
        }
    }
    
    /**
     * RECHAZAR JUSTIFICACIÓN (acción del docente)
     * El docente rechaza una justificación indicando el motivo.
     * Es obligatorio ingresar observaciones para poder rechazar.
     */
    private void rechazarJustificacion(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            Integer personaId = (Integer) session.getAttribute("personaId");
            
            if (personaId == null) {
                response.sendRedirect("index.jsp");
                return;
            }
            
            int justificacionId = Integer.parseInt(request.getParameter("justificacionId"));
            String observaciones = request.getParameter("observaciones");
            int cursoId = Integer.parseInt(request.getParameter("cursoId"));
            int turnoId = Integer.parseInt(request.getParameter("turnoId"));
            
            if (observaciones == null || observaciones.trim().isEmpty()) {
                session.setAttribute("error", "Debe especificar el motivo del rechazo");
                request.getRequestDispatcher("revisarJustificaciones.jsp?cursoId=" + cursoId + "&turnoId=" + turnoId).forward(request, response);
                return;
            }
            
            System.out.println("Rechazando justificación ID: " + justificacionId);
            
            boolean resultado = justificacionDAO.rechazarJustificacion(
                justificacionId, personaId, observaciones
            );
            
            if (resultado) {
                session.setAttribute("mensaje", "Justificación rechazada");
            } else {
                session.setAttribute("error", "Error al rechazar justificación");
            }
            
            request.getRequestDispatcher("revisarJustificaciones.jsp?cursoId=" + cursoId + "&turnoId=" + turnoId).forward(request, response);
            
        } catch (Exception e) {
            System.out.println("Error al rechazar: " + e.getMessage());
            e.printStackTrace();
            HttpSession session = request.getSession();
            session.setAttribute("error", "Error: " + e.getMessage());
            request.getRequestDispatcher("revisarJustificaciones.jsp").forward(request, response);
        }
    }
    
    /**
     * OBTENER NOMBRE DE ARCHIVO
     * Método auxiliar que extrae el nombre del archivo del header
     * de la parte multipart del formulario de subida de archivos.
     */
    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] tokens = contentDisp.split(";");
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return "";
    }
}