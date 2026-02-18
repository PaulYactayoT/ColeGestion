/*
 * SERVLET PARA SUBIDA DE IMAGENES AL ALBUM DEL ALUMNO
 */
package controlador;

import modelo.ImageDAO;
import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import javax.servlet.ServletException;
import javax.servlet.annotation.*;
import javax.servlet.http.*;

@WebServlet("/UploadImageServlet")
@MultipartConfig(
  fileSizeThreshold = 1024 * 1024,    // 1 MB
  maxFileSize = 5 * 1024 * 1024,      // 5 MB
  maxRequestSize = 6 * 1024 * 1024    // 6 MB
)
public class UploadImageServlet extends HttpServlet {
    private static final String UPLOAD_DIR = "uploads";

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        try {
            // Obtener alumno_id - VERIFICAR QUE NO SEA NULL
            String alumnoIdParam = req.getParameter("alumno_id");
            if (alumnoIdParam == null || alumnoIdParam.isEmpty()) {
                resp.sendRedirect("uploadImage.jsp?error=Falta el ID del alumno");
                return;
            }
            
            int alumnoId = Integer.parseInt(alumnoIdParam);
            
            // Obtener el archivo - VERIFICAR QUE NO SEA NULL
            Part filePart = req.getPart("file");
            if (filePart == null || filePart.getSize() == 0) {
                resp.sendRedirect("uploadImage.jsp?alumno_id=" + alumnoId + "&error=No se seleccionó ningún archivo");
                return;
            }
            
            // Validar tipo de archivo (opcional)
            String contentType = filePart.getContentType();
            if (contentType == null || !contentType.startsWith("image/")) {
                resp.sendRedirect("uploadImage.jsp?alumno_id=" + alumnoId + "&error=Solo se permiten archivos de imagen");
                return;
            }
            
            String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            String uniqueName = System.currentTimeMillis() + "_" + fileName;

            // Crear directorio de subidas
            String appPath = req.getServletContext().getRealPath("");
            String uploadPath = appPath + File.separator + UPLOAD_DIR;
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdirs();

            // Guardar archivo
            filePart.write(uploadPath + File.separator + uniqueName);

            // Guardar en BD
            String dbPath = UPLOAD_DIR + "/" + uniqueName;
            boolean guardado = new ImageDAO().guardarImagen(alumnoId, dbPath);
            
            if (guardado) {
                resp.sendRedirect("albumPadre.jsp?alumno_id=" + alumnoId + "&mensaje=Foto subida exitosamente");
            } else {
                resp.sendRedirect("uploadImage.jsp?alumno_id=" + alumnoId + "&error=Error al guardar en la base de datos");
            }
            
        } catch (NumberFormatException e) {
            e.printStackTrace();
            resp.sendRedirect("uploadImage.jsp?error=ID de alumno inválido");
        } catch (Exception e) {
            e.printStackTrace();
            // Intentar obtener alumno_id para redirección
            String alumnoIdParam = req.getParameter("alumno_id");
            if (alumnoIdParam != null && !alumnoIdParam.isEmpty()) {
                resp.sendRedirect("uploadImage.jsp?alumno_id=" + alumnoIdParam + "&error=Error al subir la imagen: " + e.getMessage());
            } else {
                resp.sendRedirect("uploadImage.jsp?error=Error al subir la imagen");
            }
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED, "GET no soportado. Use POST.");
    }
}