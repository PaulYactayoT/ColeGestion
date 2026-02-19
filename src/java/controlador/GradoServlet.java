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
        String rol = (String) session.getAttribute("rol");

        if (!tieneAccesoModulo(session, rol)) {
            System.out.println("ACCESO DENEGADO GET GradoServlet: Rol " + rol + " sin módulo asignado");
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
        String rol = (String) session.getAttribute("rol");

        if (!tieneAccesoModulo(session, rol)) {
            System.out.println("ACCESO DENEGADO POST GradoServlet: Rol " + rol + " sin módulo asignado");
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

    /**
     * Verifica si el usuario tiene el módulo GradoServlet asignado en BD.
     * Replica la lógica del SecurityFilter (hasModuleAccess).
     * - Admin y administrativo: siempre permitido.
     * - Otros roles: consulta usuario_modulo en BD.
     */
    private boolean tieneAccesoModulo(HttpSession session, String rol) {
        if (rol == null) return false;
        if ("admin".equals(rol) || "administrativo".equals(rol)) return true;

        Object uidObj = session.getAttribute("usuarioId");
        if (uidObj == null) {
            System.out.println("GradoServlet: ERROR - usuarioId NULL en sesión");
            return false;
        }

        int usuarioId;
        try { usuarioId = Integer.parseInt(uidObj.toString()); }
        catch (NumberFormatException e) { return false; }

        String sql =
            "SELECT m.url FROM modulo m " +
            "INNER JOIN usuario_modulo um ON m.id = um.modulo_id " +
            "WHERE um.usuario_id = ? AND um.activo = 1 AND m.activo = 1 AND m.eliminado = 0";

        try (java.sql.Connection conn = conexion.Conexion.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, usuarioId);
            java.sql.ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                String modUrl = rs.getString("url");
                if (modUrl != null && modUrl.contains("GradoServlet")) {
                    System.out.println("GradoServlet: Módulo GradoServlet CONFIRMADO para usuarioId=" + usuarioId);
                    return true;
                }
            }

        } catch (Exception e) {
            System.err.println("GradoServlet: Error BD al verificar módulo: " + e.getMessage());
        }

        System.out.println("GradoServlet: Módulo GradoServlet NO asignado para usuarioId=" + usuarioId);
        return false;
    }
}