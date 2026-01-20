package controlador;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import modelo.Profesor;
import modelo.ProfesorDAO;

@WebServlet("/ProfesorServlet")
public class ProfesorServlet extends HttpServlet {

    ProfesorDAO dao = new ProfesorDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String rol = (String) session.getAttribute("rol");

        // VALIDACIÓN: Solo admin puede acceder a ProfesorServlet
        if (!"admin".equals(rol)) {
            System.out.println("ACCESO DENEGADO: Rol " + rol + " intentó acceder a ProfesorServlet");
            response.sendRedirect("acceso_denegado.jsp");
            return;
        }

        String accion = request.getParameter("accion");

        // Acción por defecto: listar todos los profesores
        if (accion == null || accion.equals("listar")) {
            request.setAttribute("lista", dao.listar());
            request.getRequestDispatcher("profesores.jsp").forward(request, response);
            return;
        }

        // Ejecutar acción específica según parámetro
        switch (accion) {
            case "editar":
                int idEditar = Integer.parseInt(request.getParameter("id"));
                Profesor p = dao.obtenerPorId(idEditar);
                request.setAttribute("profesor", p);
                request.getRequestDispatcher("profesorForm.jsp").forward(request, response);
                break;

            case "eliminar":
                int idEliminar = Integer.parseInt(request.getParameter("id"));
                dao.eliminar(idEliminar);
                response.sendRedirect("ProfesorServlet");
                break;
                
            case "nuevo":
                request.getRequestDispatcher("profesorForm.jsp").forward(request, response);
                break;

            default:
                response.sendRedirect("ProfesorServlet");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String rol = (String) session.getAttribute("rol");

        // VALIDACIÓN: Solo admin puede crear/actualizar profesores
        if (!"admin".equals(rol)) {
            System.out.println("ACCESO DENEGADO POST: Rol " + rol + " intentó modificar profesores");
            response.sendRedirect("acceso_denegado.jsp");
            return;
        }

        // Resto del código POST original...
        int id = request.getParameter("id") != null && !request.getParameter("id").isEmpty()
                ? Integer.parseInt(request.getParameter("id")) : 0;

        Profesor p = new Profesor();
        p.setNombres(request.getParameter("nombres"));
        p.setApellidos(request.getParameter("apellidos"));
        p.setCorreo(request.getParameter("correo"));
        p.setEspecialidad(request.getParameter("especialidad"));

        if (id == 0) {
            dao.agregar(p);
            System.out.println("Nuevo profesor creado por admin: " + p.getNombres() + " " + p.getApellidos());
        } else {
            p.setId(id);
            dao.actualizar(p);
            System.out.println("Profesor actualizado por admin: " + p.getNombres() + " " + p.getApellidos() + " (ID: " + id + ")");
        }

        response.sendRedirect("ProfesorServlet");
    }
}