package controlador;

import modelo.Observacion;
import modelo.ObservacionDAO;
import modelo.Padre;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet; // Importante para que funcione el enlace
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "ObservacionesPadreServlet", urlPatterns = {"/ObservacionesPadreServlet"})
public class ObservacionesPadreServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Padre padre = (session != null) ? (Padre) session.getAttribute("padre") : null;

        // 1. Verificar autenticación
        if (padre == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        // 2. Obtener observaciones usando el método del DAO que ya tienes
        ObservacionDAO dao = new ObservacionDAO();
        List<Observacion> lista = dao.listarPorAlumno(padre.getAlumnoId());
        
        // 3. Pasar los datos a la vista (OJO: Usamos "listaObservaciones" para coincidir con el JSP)
   request.setAttribute("observaciones", lista);
        request.setAttribute("nombreAlumno", padre.getAlumnoNombre());

        // 4. Redirigir a la interfaz del padre
        request.getRequestDispatcher("observacionesPadre.jsp").forward(request, response);
    }
}