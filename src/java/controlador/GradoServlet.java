package controlador;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import modelo.Grado;
import modelo.GradoDAO;

@WebServlet("/GradoServlet")
public class GradoServlet extends HttpServlet {

    GradoDAO dao = new GradoDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        
        // VALIDACIÓN CRÍTICA: Solo admin puede gestionar grados
        String rol = (String) session.getAttribute("rol");
        if (!"admin".equals(rol)) {
            response.sendRedirect("acceso_denegado.jsp");
            return;
        }

        String accion = request.getParameter("accion");

        if (accion == null || accion.isEmpty()) {
            request.setAttribute("lista", dao.listar());
            request.getRequestDispatcher("grados.jsp").forward(request, response);
            return;
        }

        switch (accion) {
            case "editar":
                int idEditar = Integer.parseInt(request.getParameter("id"));
                Grado g = dao.obtenerPorId(idEditar);
                request.setAttribute("grado", g);
                request.getRequestDispatcher("gradoForm.jsp").forward(request, response);
                break;

            case "eliminar":
                int idEliminar = Integer.parseInt(request.getParameter("id"));
                dao.eliminar(idEliminar);
                response.sendRedirect("GradoServlet");
                break;

            default:
                response.sendRedirect("GradoServlet");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        
        // VALIDACIÓN CRÍTICA: Solo admin puede gestionar grados
        String rol = (String) session.getAttribute("rol");
        if (!"admin".equals(rol)) {
            response.sendRedirect("acceso_denegado.jsp");
            return;
        }

        int id = request.getParameter("id") != null && !request.getParameter("id").isEmpty()
                ? Integer.parseInt(request.getParameter("id")) : 0;

        Grado g = new Grado();
        g.setNombre(request.getParameter("nombre"));
        g.setNivel(request.getParameter("nivel"));

        if (id == 0) {
            dao.agregar(g);
        } else {
            g.setId(id);
            dao.actualizar(g);
        }

        response.sendRedirect("GradoServlet");
    }
}