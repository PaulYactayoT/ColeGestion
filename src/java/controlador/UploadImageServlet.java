/*
 * SERVLET PARA SUBIDA DE IMAGENES AL ALBUM DEL ALUMNO
 * 
 * Funcionalidades: Subir imagenes, almacenar en sistema de archivos y BD
 * Roles: Padre
 * Integracion: Relacion con alumno y sistema de archivos
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

    /**
     * METODO POST - SUBIR IMAGEN AL SERVIDOR
     */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Obtener datos del formulario
        int alumnoId = Integer.parseInt(req.getParameter("alumno_id"));
        Part filePart = req.getPart("imagen");
        String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
        String uniqueName = System.currentTimeMillis() + "_" + fileName; // Nombre unico

        // Crear directorio de subidas si no existe
        String appPath = req.getServletContext().getRealPath("");
        String uploadPath = appPath + File.separator + UPLOAD_DIR;
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdirs();

        // Escribir archivo en el servidor
        filePart.write(uploadPath + File.separator + uniqueName);

        // Guardar ruta en base de datos
        String dbPath = UPLOAD_DIR + "/" + uniqueName;
        new ImageDAO().guardarImagen(alumnoId, dbPath);

        // Redirigir al album del padre
        resp.sendRedirect("albumPadre.jsp");
    }
}