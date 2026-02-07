package controlador;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import modelo.Padre;

@WebServlet("/PadreDashboardServlet")
public class PadreDashboardServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Padre padre = (Padre) session.getAttribute("padre");
        
        if (padre == null) {
            // Intentar obtener el padre desde la sesión de usuario
            String username = (String) session.getAttribute("usuario");
            if (username != null) {
                modelo.PadreDAO padreDAO = new modelo.PadreDAO();
                padre = padreDAO.obtenerPorUsername(username);
                if (padre != null) {
                    session.setAttribute("padre", padre);
                    // AQUÍ ESTÁ EL CAMBIO IMPORTANTE:
                    session.setAttribute("personaId", padre.getId());
                }
            }
            
            if (padre == null) {
                response.sendRedirect("index.jsp");
                return;
            }
        } else {
            // Asegurarnos de que personaId esté en la sesión
            if (session.getAttribute("personaId") == null) {
                session.setAttribute("personaId", padre.getId());
            }
        }
        
        // Redirigir al dashboard del padre
        request.getRequestDispatcher("padreDashboard.jsp").forward(request, response);
    }
}