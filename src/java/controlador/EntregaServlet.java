package controlador;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

import modelo.Padre;
import modelo.Tarea;
import modelo.TareaDAO;
import modelo.Entrega;
import modelo.EntregaDAO;

@WebServlet(name = "EntregaServlet", urlPatterns = {"/EntregaServlet"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB (Memoria temporal)
    maxFileSize = 1024 * 1024 * 10,       // 10MB (Límite por archivo - HU-14)
    maxRequestSize = 1024 * 1024 * 15     // 15MB (Límite total de la petición)
)
public class EntregaServlet extends HttpServlet {

    private EntregaDAO entregaDAO = new EntregaDAO();
    private TareaDAO tareaDAO = new TareaDAO();

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String accion = request.getParameter("accion");
        HttpSession session = request.getSession();
        
        // Validación de Sesión
        Padre padre = (Padre) session.getAttribute("padre");
        if (padre == null || padre.getAlumnoId() <= 0) {
            response.sendRedirect("index.jsp");
            return;
        }
        
        int alumnoId = padre.getAlumnoId();

        if ("ver".equals(accion)) {
            // --- MOSTRAR EL FORMULARIO DE SUBIDA ---
            String idStr = request.getParameter("id");
            if (idStr != null) {
                int tareaId = Integer.parseInt(idStr);
                
                // 1. Validar que no la haya entregado ya (Seguridad)
                if (entregaDAO.existeEntrega(tareaId, alumnoId)) {
                    session.setAttribute("error", "Ya realizaste la entrega definitiva de esta tarea.");
                    response.sendRedirect("TareasPadreServlet");
                    return;
                }
                
                // 2. Cargar datos de la tarea y enviar a la vista
                Tarea tarea = tareaDAO.obtenerPorId(tareaId);
                request.setAttribute("tarea", tarea);
                request.getRequestDispatcher("detalleTarea.jsp").forward(request, response);
            } else {
                response.sendRedirect("TareasPadreServlet");
            }
            
        } else if ("subir".equals(accion)) {
            // --- PROCESAR EL ARCHIVO ENVIADO ---
            try {
                int tareaId = Integer.parseInt(request.getParameter("id_tarea"));
                
                // 1. Doble validación: Evitar doble envío accidental
                if (entregaDAO.existeEntrega(tareaId, alumnoId)) {
                    session.setAttribute("error", "Ya has enviado esta tarea anteriormente.");
                    response.sendRedirect("TareasPadreServlet");
                    return;
                }

                // 2. Obtener el archivo del formulario
                Part filePart = request.getPart("archivo");
                String fileName = getSubmittedFileName(filePart);
                
                if (fileName == null || fileName.trim().isEmpty()) {
                    session.setAttribute("error", "Debes seleccionar un archivo para enviar.");
                    response.sendRedirect("EntregaServlet?accion=ver&id=" + tareaId);
                    return;
                }

                // 3. Validar extensión permitida y rechazar ejecutables (EP-14.4)
                if (!esExtensionValida(fileName)) {
                    session.setAttribute("error", "Formato no permitido. Por favor, sube un archivo PDF, Word o Imagen válida.");
                    response.sendRedirect("EntregaServlet?accion=ver&id=" + tareaId);
                    return;
                }

                // 4. Crear carpeta física en el servidor si no existe (Carpeta ENTREGAS)
                String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads" + File.separator + "entregas";
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }

                // 5. Guardar archivo con nombre único (IDAlumno_IDTarea_Timestamp_Nombre) para evitar sobreescritura
                String finalFileName = "ALU" + alumnoId + "_TAR" + tareaId + "_" + System.currentTimeMillis() + "_" + fileName.replaceAll("\\s+", "_");
                String fullPath = uploadPath + File.separator + finalFileName;
                
                try (InputStream input = filePart.getInputStream()) {
                    Files.copy(input, new File(fullPath).toPath(), StandardCopyOption.REPLACE_EXISTING);
                }

                // 6. Registrar en Base de Datos
                // ✅ CORRECCIÓN: Guardamos SOLO el nombre del archivo (finalFileName) para que el DescargarServlet lo encuentre sin problemas
                Entrega entrega = new Entrega(tareaId, alumnoId, finalFileName, fileName);
                boolean exito = entregaDAO.registrarEntrega(entrega);

                if (exito) {
                    session.setAttribute("mensaje", "¡Tarea subida correctamente!"); // EP-14.3
                } else {
                    session.setAttribute("error", "Ocurrió un error al guardar en la base de datos.");
                }
                
                // Retornar a la lista principal (donde ahora se verá el candado)
                response.sendRedirect("TareasPadreServlet");

            } catch (IllegalStateException e) {
                // Captura error de tamaño excedido bloqueado por @MultipartConfig
                session.setAttribute("error", "El archivo supera el límite permitido de 10MB.");
                response.sendRedirect("TareasPadreServlet");
            } catch (Exception e) {
                e.printStackTrace();
                session.setAttribute("error", "Error al procesar la entrega: " + e.getMessage());
                response.sendRedirect("TareasPadreServlet");
            }
        }
    }

    // Método para extraer el nombre del archivo del input type="file"
    private String getSubmittedFileName(Part part) {
        for (String cd : part.getHeader("content-disposition").split(";")) {
            if (cd.trim().startsWith("filename")) {
                return cd.substring(cd.indexOf('=') + 1).trim().replace("\"", "");
            }
        }
        return null;
    }

    // Validación de Formatos Seguros (Criterio de Aceptación)
    private boolean esExtensionValida(String fileName) {
        String name = fileName.toLowerCase();
        
        // Rechazar ejecutables explícitamente (Criterio de seguridad)
        if (name.endsWith(".exe") || name.endsWith(".bat") || name.endsWith(".sh") || name.endsWith(".js") || name.endsWith(".cmd")) {
            return false;
        }
        // Permitir solo documentos e imágenes
        return name.endsWith(".pdf") || name.endsWith(".doc") || name.endsWith(".docx") || 
               name.endsWith(".jpg") || name.endsWith(".jpeg") || name.endsWith(".png");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }
}