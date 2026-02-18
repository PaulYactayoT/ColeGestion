package controlador;

import com.google.gson.Gson;
import modelo.Modulo;
import modelo.ModuloDAO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/ModuloServlet")
public class ModuloServlet extends HttpServlet {

    private final ModuloDAO moduloDAO = new ModuloDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException { processRequest(req, res); }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException { processRequest(req, res); }

    private void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String accion = request.getParameter("accion");

        System.out.println("##################################################");
        System.out.println("### accion: [" + accion + "]");
        System.out.println("### Metodo HTTP: " + request.getMethod());
        System.out.println("##################################################");

        if (accion == null) accion = "listar";

        if ("obtenerModulosUsuario".equals(accion)) {
            obtenerModulosUsuario(request, response);
            return;
        }
        if ("guardarModulos".equals(accion)) {
            guardarModulos(request, response);
            return;
        }
        if ("eliminarModulos".equals(accion)) {
            eliminarModulos(request, response);
            return;
        }

        try {
            listarUsuarios(request, response);
        } catch (SQLException e) {
            e.printStackTrace();
            try {
                request.setAttribute("error", "Error: " + e.getMessage());
                request.getRequestDispatcher("error.jsp").forward(request, response);
            } catch (Exception ex) { ex.printStackTrace(); }
        }
    }

    private void listarUsuarios(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        // VALIDACION DE ROL: Solo admin y administrativo pueden gestionar modulos
        String rolSesionActual = (String) session.getAttribute("rol");
        if (!"admin".equals(rolSesionActual) && !"administrativo".equals(rolSesionActual)) {
            System.out.println("ACCESO DENEGADO: Rol '" + rolSesionActual + "' intento acceder a ModuloServlet");
            response.sendRedirect("acceso_denegado.jsp");
            return;
        }

        String sql =
            "SELECT u.id, u.username, u.rol, u.activo, " +
            "       CONCAT(p.nombres, ' ', p.apellidos) AS nombre_completo, " +
            "       p.correo, " +
            "       (SELECT COUNT(*) FROM usuario_modulo um " +
            "        WHERE um.usuario_id = u.id AND um.activo = 1) AS modulos_asignados " +
            "FROM usuario u " +
            "INNER JOIN persona p ON u.persona_id = p.id " +
            "WHERE u.eliminado = 0 AND u.activo = 1 " +
            "  AND u.rol IN ('docente', 'padre', 'administrativo') " +
            "ORDER BY u.rol, p.apellidos, p.nombres";

        List<Map<String, Object>> usuarios = new ArrayList<>();

        try (java.sql.Connection conn = conexion.Conexion.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql);
             java.sql.ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> u = new HashMap<>();
                u.put("id",               rs.getInt("id"));
                u.put("username",         rs.getString("username"));
                u.put("rol",              rs.getString("rol"));
                u.put("nombreCompleto",   rs.getString("nombre_completo"));
                u.put("correo",           rs.getString("correo"));
                u.put("activo",           rs.getBoolean("activo"));
                u.put("modulosAsignados", rs.getInt("modulos_asignados"));
                usuarios.add(u);
            }

            request.setAttribute("usuarios", usuarios);
            request.getRequestDispatcher("gestionModulos.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.setContentType("text/html;charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.println("<h2 style='color:red;'>Error: " + e.getMessage() + "</h2>");
        }
    }

    private void obtenerModulosUsuario(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        try {
            int usuarioId = Integer.parseInt(request.getParameter("usuarioId"));
            String rol = request.getParameter("rol");
            HttpSession session = request.getSession(false);
            String rolSesion = (session != null) ? (String) session.getAttribute("rol") : null;

            System.out.println("=== obtenerModulosUsuario ===");
            System.out.println("usuarioId: " + usuarioId + " | rol: " + rol);

            List<Modulo> modulos = moduloDAO.listarParaAsignacion(usuarioId, rol, rolSesion);
            System.out.println("Modulos encontrados: " + modulos.size());

            out.print(new Gson().toJson(modulos));

        } catch (Exception e) {
            System.err.println("ERROR obtenerModulosUsuario: " + e.getMessage());
            e.printStackTrace();
            out.print("[]");
        } finally {
            out.flush();
        }
    }

    private void guardarModulos(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        try {
            String usuarioIdParam = request.getParameter("usuarioId");
            String[] modulosParam = request.getParameterValues("modulos[]");

            System.out.println("=== guardarModulos VERSION NUEVA ===");
            System.out.println("usuarioId: " + usuarioIdParam);
            System.out.println("modulos[]: " + (modulosParam != null ? Arrays.toString(modulosParam) : "null"));

            if (usuarioIdParam == null || usuarioIdParam.trim().isEmpty()) {
                respondError(out, "Falta usuarioId.");
                return;
            }

            int usuarioId = Integer.parseInt(usuarioIdParam.trim());

            HttpSession session = request.getSession(false);
            int adminId = 1;
            try {
                if (session != null && session.getAttribute("usuarioId") != null) {
                    adminId = Integer.parseInt(session.getAttribute("usuarioId").toString());
                }
            } catch (NumberFormatException e) {
                System.out.println("adminId no parseado, usando 1");
            }

            List<Integer> moduloIds = new ArrayList<>();
            if (modulosParam != null) {
                for (String id : modulosParam) {
                    try { moduloIds.add(Integer.parseInt(id.trim())); }
                    catch (NumberFormatException e) { System.out.println("ID invalido: " + id); }
                }
            }

            System.out.println("IDs a guardar: " + moduloIds + " | adminId: " + adminId);

            if (moduloIds.isEmpty()) {
                respondError(out, "Selecciona al menos un modulo.");
                return;
            }

            moduloDAO.asignarModulosMultiples(usuarioId, moduloIds, adminId);

            Map<String, Object> res = new HashMap<>();
            res.put("exito", true);
            res.put("mensaje", "Modulos asignados correctamente.");
            res.put("cantidadModulos", moduloIds.size());
            out.print(new Gson().toJson(res));

        } catch (Exception e) {
            System.err.println("ERROR guardarModulos: " + e.getMessage());
            e.printStackTrace();
            respondError(out, "Error al guardar: " + e.getMessage());
        } finally {
            out.flush();
        }
    }

    private void eliminarModulos(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        try {
            String param = request.getParameter("usuarioId");
            if (param == null || param.trim().isEmpty()) {
                respondError(out, "Falta usuarioId.");
                return;
            }
            int usuarioId = Integer.parseInt(param.trim());
            System.out.println("=== eliminarModulos === usuarioId: " + usuarioId);

            boolean exito = moduloDAO.eliminarModulosDeUsuario(usuarioId);

            Map<String, Object> res = new HashMap<>();
            res.put("exito", exito);
            res.put("mensaje", exito ? "Modulos eliminados." : "Error al eliminar.");
            out.print(new Gson().toJson(res));

        } catch (Exception e) {
            System.err.println("ERROR eliminarModulos: " + e.getMessage());
            e.printStackTrace();
            respondError(out, "Error: " + e.getMessage());
        } finally {
            out.flush();
        }
    }

    private void respondError(PrintWriter out, String mensaje) {
        Map<String, Object> error = new HashMap<>();
        error.put("exito", false);
        error.put("mensaje", mensaje);
        out.print(new Gson().toJson(error));
    }
}