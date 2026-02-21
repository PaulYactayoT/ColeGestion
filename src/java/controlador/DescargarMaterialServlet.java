package controlador;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import modelo.Material;
import modelo.MaterialDAO;

/**
 * SERVLET DE DESCARGA DE MATERIALES
 * Busca el archivo en la carpeta "materiales" dentro del deploy de Tomcat
 */
@WebServlet("/DescargarMaterialServlet")
public class DescargarMaterialServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Falta el ID del material");
            return;
        }

        try {
            int materialId = Integer.parseInt(idStr);

            MaterialDAO dao = new MaterialDAO();
            Material material = dao.obtenerPorId(materialId);

            if (material == null || material.getRutaArchivo() == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Material no encontrado");
                return;
            }

            // Buscar en la carpeta "materiales" dentro del deploy de Tomcat
            String appPath = request.getServletContext().getRealPath("");
            String nombreArchivo = new File(material.getRutaArchivo()).getName();
            
            // Intentar en varias rutas posibles
            String[] posiblesRutas = {
                appPath + File.separator + "materiales" + File.separator + nombreArchivo,
                appPath + File.separator + material.getRutaArchivo().replace("/", File.separator),
                "C:\\materiales_master4" + File.separator + nombreArchivo
            };

            File archivo = null;
            for (String ruta : posiblesRutas) {
                File f = new File(ruta);
                System.out.println("Buscando en: " + ruta + " -> existe: " + f.exists());
                if (f.exists()) {
                    archivo = f;
                    break;
                }
            }

            if (archivo == null) {
                System.err.println("Archivo no encontrado en ninguna ruta. appPath: " + appPath);
                response.sendError(HttpServletResponse.SC_NOT_FOUND,
                        "El archivo no est\u00e1 disponible en el servidor");
                return;
            }

            // Determinar content type
            String contentType = material.getTipoArchivo();
            if (contentType == null || contentType.isEmpty()) {
                contentType = getServletContext().getMimeType(archivo.getName());
            }
            if (contentType == null) contentType = "application/octet-stream";

            response.setContentType(contentType);
            response.setContentLengthLong(archivo.length());
            response.setHeader("Content-Disposition",
                    "attachment; filename=\"" + material.getNombreArchivo() + "\"");
            response.setHeader("Cache-Control", "no-cache");

            try (FileInputStream fis = new FileInputStream(archivo);
                 OutputStream out = response.getOutputStream()) {
                byte[] buffer = new byte[8192];
                int bytesRead;
                while ((bytesRead = fis.read(buffer)) != -1) {
                    out.write(buffer, 0, bytesRead);
                }
                out.flush();
            }

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID inv\u00e1lido");
        } catch (Exception e) {
            System.err.println("ERROR en DescargarMaterialServlet: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Error al descargar el archivo");
        }
    }
}