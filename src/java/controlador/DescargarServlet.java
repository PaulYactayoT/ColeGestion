package controlador;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "DescargarServlet", urlPatterns = {"/DescargarServlet"})
public class DescargarServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Tomcat decodifica automáticamente los %20 a espacios aquí
        String nombreArchivo = request.getParameter("archivo");
        String tipo = request.getParameter("tipo"); // "tarea" o "entrega"
        
        if (nombreArchivo == null || nombreArchivo.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Nombre de archivo no válido");
            return;
        }

        String subCarpeta = "tarea".equals(tipo) ? "tareas" : "entregas";
        
        // Buscamos la ruta real
        String applicationPath = request.getServletContext().getRealPath("");
        String basePath = applicationPath + File.separator + "uploads" + File.separator + subCarpeta;
        
        File file = new File(basePath, nombreArchivo);

        // Imprimimos en consola para monitorear
        System.out.println("Intentando descargar: " + file.getAbsolutePath());

        if (!file.exists()) {
            System.out.println("❌ ERROR: El archivo no existe físicamente.");
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "El archivo ya no se encuentra en el servidor.");
            return;
        }

        // Forzar la descarga
        String mimeType = getServletContext().getMimeType(file.getAbsolutePath());
        if (mimeType == null) {
            mimeType = "application/octet-stream";
        }
        
        response.setContentType(mimeType);
        response.setContentLength((int) file.length());
        
        // Evita errores con espacios en el nombre de descarga
        response.setHeader("Content-Disposition", "attachment; filename=\"" + nombreArchivo + "\"");

        try (FileInputStream inStream = new FileInputStream(file);
             OutputStream outStream = response.getOutputStream()) {
            
            byte[] buffer = new byte[4096];
            int bytesRead;
            while ((bytesRead = inStream.read(buffer)) != -1) {
                outStream.write(buffer, 0, bytesRead);
            }
        }
    }
}