package controlador;

import modelo.*;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.*;
import java.time.LocalDateTime;
import java.nio.file.*;

/**
 * Servlet para gestionar justificaciones de asistencia
 */
@WebServlet("/JustificacionServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 5,        // 5MB
    maxRequestSize = 1024 * 1024 * 10     // 10MB
)

public class JustificacionServlet extends HttpServlet {
    
    private JustificacionDAO justificacionDAO;
    
    @Override
    public void init() throws ServletException {
        justificacionDAO = new JustificacionDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String accion = request.getParameter("accion");
        
        if (accion == null) {
            accion = "listar";
        }
        
        switch (accion) {
            case "listar":
                listarJustificaciones(request, response);
                break;
            case "ver":
                verJustificacion(request, response);
                break;
            default:
                listarJustificaciones(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String accion = request.getParameter("accion");
        
        if (accion == null) {
            response.sendRedirect("revisarJustificaciones.jsp");
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
                response.sendRedirect("revisarJustificaciones.jsp");
        }
    }
    
    /**
     * CREAR NUEVA JUSTIFICACIÓN (desde padre)
     */
    private void crearJustificacion(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            Integer personaId = (Integer) session.getAttribute("personaId");
            
            if (personaId == null) {
                response.sendRedirect("login.jsp");
                return;
            }
            
            // Obtener parámetros
            int asistenciaId = Integer.parseInt(request.getParameter("asistenciaId"));
            int alumnoId = Integer.parseInt(request.getParameter("alumnoId"));
            String tipoStr = request.getParameter("tipoJustificacion");
            String descripcion = request.getParameter("descripcion");
            
            // Crear objeto Justificacion
            Justificacion justificacion = new Justificacion();
            justificacion.setAsistenciaId(asistenciaId);
            justificacion.setTipoJustificacionFromString(tipoStr);
            justificacion.setDescripcion(descripcion);
            justificacion.setJustificadoPor(personaId);
            justificacion.setFechaJustificacion(LocalDateTime.now());
            
            // Manejar archivo adjunto
            Part filePart = request.getPart("archivo");
            if (filePart != null && filePart.getSize() > 0) {
                String fileName = getFileName(filePart);
                String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads" + 
                                   File.separator + "justificaciones";
                
                // Crear directorio si no existe
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }
                
                // Generar nombre único para el archivo
                String timestamp = String.valueOf(System.currentTimeMillis());
                String extension = fileName.substring(fileName.lastIndexOf("."));
                String newFileName = "just_" + asistenciaId + "_" + timestamp + extension;
                String filePath = uploadPath + File.separator + newFileName;
                
                // Guardar archivo
                filePart.write(filePath);
                
                // Guardar ruta relativa en la base de datos
                String relativePath = "uploads/justificaciones/" + newFileName;
                justificacion.setDocumentoAdjunto(relativePath);
                
                System.out.println(" Archivo guardado: " + filePath);
            }
            
            // Guardar en base de datos
            int justificacionId = justificacionDAO.crearJustificacion(justificacion);
            
            if (justificacionId > 0) {
                response.sendRedirect("justificarAusencia.jsp?alumnoId=" + alumnoId + 
                                    "&mensaje=Justificación enviada exitosamente&tipo=success");
            } else {
                response.sendRedirect("justificarAusencia.jsp?alumnoId=" + alumnoId + 
                                    "&mensaje=Error al enviar justificación&tipo=error");
            }
            
        } catch (Exception e) {
            System.out.println(" Error al crear justificación: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("justificarAusencia.jsp?mensaje=Error: " + 
                                e.getMessage() + "&tipo=error");
        }
    }
    
    /**
     * APROBAR JUSTIFICACIÓN (desde docente)
     */
    private void aprobarJustificacion(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            Integer personaId = (Integer) session.getAttribute("personaId");
            
            if (personaId == null) {
                response.sendRedirect("login.jsp");
                return;
            }
            
            int justificacionId = Integer.parseInt(request.getParameter("justificacionId"));
            String observaciones = request.getParameter("observaciones");
            int cursoId = Integer.parseInt(request.getParameter("cursoId"));
            int turnoId = Integer.parseInt(request.getParameter("turnoId"));
            
            boolean resultado = justificacionDAO.aprobarJustificacion(
                justificacionId, personaId, observaciones
            );
            
            if (resultado) {
                response.sendRedirect("revisarJustificaciones.jsp?cursoId=" + cursoId + 
                                    "&turnoId=" + turnoId + 
                                    "&mensaje=Justificación aprobada exitosamente&tipo=success");
            } else {
                response.sendRedirect("revisarJustificaciones.jsp?cursoId=" + cursoId + 
                                    "&turnoId=" + turnoId + 
                                    "&mensaje=Error al aprobar justificación&tipo=error");
            }
            
        } catch (Exception e) {
            System.out.println(" Error al aprobar justificación: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("revisarJustificaciones.jsp?mensaje=Error: " + 
                                e.getMessage() + "&tipo=error");
        }
    }
    
    /**
     * RECHAZAR JUSTIFICACIÓN (desde docente)
     */
    private void rechazarJustificacion(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            Integer personaId = (Integer) session.getAttribute("personaId");
            
            if (personaId == null) {
                response.sendRedirect("login.jsp");
                return;
            }
            
            int justificacionId = Integer.parseInt(request.getParameter("justificacionId"));
            String observaciones = request.getParameter("observaciones");
            int cursoId = Integer.parseInt(request.getParameter("cursoId"));
            int turnoId = Integer.parseInt(request.getParameter("turnoId"));
            
            if (observaciones == null || observaciones.trim().isEmpty()) {
                response.sendRedirect("revisarJustificaciones.jsp?cursoId=" + cursoId + 
                                    "&turnoId=" + turnoId + 
                                    "&mensaje=Debe especificar el motivo del rechazo&tipo=error");
                return;
            }
            
            boolean resultado = justificacionDAO.rechazarJustificacion(
                justificacionId, personaId, observaciones
            );
            
            if (resultado) {
                response.sendRedirect("revisarJustificaciones.jsp?cursoId=" + cursoId + 
                                    "&turnoId=" + turnoId + 
                                    "&mensaje=Justificación rechazada&tipo=success");
            } else {
                response.sendRedirect("revisarJustificaciones.jsp?cursoId=" + cursoId + 
                                    "&turnoId=" + turnoId + 
                                    "&mensaje=Error al rechazar justificación&tipo=error");
            }
            
        } catch (Exception e) {
            System.out.println(" Error al rechazar justificación: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("revisarJustificaciones.jsp?mensaje=Error: " + 
                                e.getMessage() + "&tipo=error");
        }
    }
    
    /**
     * LISTAR JUSTIFICACIONES
     */
    private void listarJustificaciones(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("revisarJustificaciones.jsp");
    }
    
    /**
     * VER DETALLE DE JUSTIFICACIÓN
     */
    private void verJustificacion(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int justificacionId = Integer.parseInt(request.getParameter("id"));
            Justificacion justificacion = justificacionDAO.obtenerJustificacionPorId(justificacionId);
            
            request.setAttribute("justificacion", justificacion);
            request.getRequestDispatcher("detalleJustificacion.jsp").forward(request, response);
            
        } catch (Exception e) {
            System.out.println(" Error al ver justificación: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("revisarJustificaciones.jsp");
        }
    }
    
    /**
     * MÉTODO AUXILIAR PARA OBTENER NOMBRE DE ARCHIVO
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