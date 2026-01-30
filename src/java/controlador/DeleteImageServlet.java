/*
 * SERVLET PARA ELIMINACION DE IMAGENES DEL ALBUM
 * 
 * Funcionalidades: Eliminar imagenes del sistema de archivos y BD
 * Roles: Padre
 * Integracion: Relacion con alumno y sistema de archivos
 */
package controlador;

import modelo.ImageDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/DeleteImageServlet")
public class DeleteImageServlet extends HttpServlet {
    
    /**
     * METODO POST - ELIMINAR IMAGEN
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        int imgId = idParam != null ? Integer.parseInt(idParam) : 0;

        // Obtener ruta absoluta al directorio de la aplicacion
        String contextPath = getServletContext().getRealPath("/");

        // Eliminar imagen (archivo y registro BD)
        boolean ok = new ImageDAO().eliminarImagen(imgId, contextPath);
        
        // Redirigir al album
        response.sendRedirect("albumPadre.jsp");
    }
}