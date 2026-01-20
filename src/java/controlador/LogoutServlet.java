/*
 * SERVLET PARA CIERRE SEGURO DE SESIONES DE USUARIO
 * 
 * Proposito: Invalidar sesiones de manera segura y prevenir acceso no autorizado
 * Caracteristicas: Eliminacion completa de datos de sesion, headers de cache
 * Seguridad: Previene ataques de replay y acceso con sesiones expiradas
 */
package controlador;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/LogoutServlet")
public class LogoutServlet extends HttpServlet {

    /**
     * METODO GET - PROCESA SOLICITUDES DE CERRAR SESION
     * 
     * Flujo de cierre de sesion:
     * 1. Invalidar sesion actual del usuario
     * 2. Eliminar cookies y datos de sesion
     * 3. Configurar headers para prevenir cache
     * 4. Redirigir al login
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Obtener sesion actual sin crear una nueva (false = no crear nueva)
        HttpSession session = request.getSession(false);
        
        // Invalidar sesion existente - elimina todos los datos de sesion
        if (session != null) {
            session.invalidate(); // Destruye completamente la sesion
            System.out.println("Sesion invalidada correctamente");
        } else {
            System.out.println("No habia sesion activa para invalidar");
        }

        // Configurar headers de seguridad - previene uso de cache
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
        response.setHeader("Pragma", "no-cache"); // HTTP 1.0
        response.setDateHeader("Expires", 0); // Fecha de expiracion en el pasado

        System.out.println("Headers de seguridad configurados - Cache deshabilitado");

        // Redirigir al login con interfaz limpia
        response.sendRedirect("index.jsp");
        System.out.println("Usuario redirigido a pagina de login");
    }
}