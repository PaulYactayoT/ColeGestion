package controlador;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import modelo.Usuario;
import modelo.UsuarioDAO;

@WebServlet("/UsuarioServlet")
public class UsuarioServlet extends HttpServlet {

    private UsuarioDAO dao = new UsuarioDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        String rol = (String) session.getAttribute("rol");
        if (!tieneAccesoModulo(session, rol)) {
            System.out.println("ACCESO DENEGADO (GET): Rol '" + rol + "' sin modulo UsuarioServlet asignado");
            response.sendRedirect("acceso_denegado.jsp");
            return;
        }

        String accion = request.getParameter("accion");

        if (accion == null || accion.isEmpty()) {
            request.setAttribute("lista", dao.listar());
            request.getRequestDispatcher("usuarios.jsp").forward(request, response);
            return;
        }

        try {
            switch (accion) {
                case "nuevo":
                    request.setAttribute("profesoresSinUsuario", dao.obtenerProfesoresSinUsuario());
                    request.setAttribute("alumnosSinUsuario", dao.obtenerAlumnosSinUsuario());
                    request.setAttribute("administrativosSinUsuario", dao.obtenerAdministrativosSinUsuario());
                    request.getRequestDispatcher("usuarioForm.jsp").forward(request, response);
                    break;

                case "editar":
                    int idEditar = Integer.parseInt(request.getParameter("id"));
                    Usuario u = dao.obtenerPorId(idEditar);
                    if (u != null) {
                        request.setAttribute("usuario", u);
                        request.getRequestDispatcher("usuarioForm.jsp").forward(request, response);
                    } else {
                        session.setAttribute("error", "Usuario no encontrado");
                        response.sendRedirect("UsuarioServlet");
                    }
                    break;

                case "eliminar":
                    int idEliminar = Integer.parseInt(request.getParameter("id"));
                    if (dao.eliminar(idEliminar)) {
                        session.setAttribute("mensaje", "Usuario eliminado exitosamente");
                    } else {
                        session.setAttribute("error", "No se pudo eliminar el usuario");
                    }
                    response.sendRedirect("UsuarioServlet");
                    break;

                case "bloquear":
                    int idBloquear = Integer.parseInt(request.getParameter("id"));
                    Usuario usuarioBloquear = dao.obtenerPorId(idBloquear);
                    if (usuarioBloquear != null) {
                        if (dao.bloquearUsuario(usuarioBloquear.getUsername())) {
                            session.setAttribute("mensaje", "Usuario bloqueado exitosamente");
                        } else {
                            session.setAttribute("error", "No se pudo bloquear el usuario");
                        }
                    }
                    response.sendRedirect("UsuarioServlet");
                    break;

                case "desbloquear":
                    int idDesbloquear = Integer.parseInt(request.getParameter("id"));
                    Usuario usuarioDesbloquear = dao.obtenerPorId(idDesbloquear);
                    if (usuarioDesbloquear != null) {
                        if (dao.resetearIntentosUsuario(usuarioDesbloquear.getUsername())) {
                            session.setAttribute("mensaje", "Usuario desbloqueado exitosamente");
                        } else {
                            session.setAttribute("error", "No se pudo desbloquear el usuario");
                        }
                    }
                    response.sendRedirect("UsuarioServlet");
                    break;

                default:
                    response.sendRedirect("UsuarioServlet");
            }
        } catch (NumberFormatException e) {
            session.setAttribute("error", "ID de usuario invalido");
            response.sendRedirect("UsuarioServlet");
        } catch (Exception e) {
            session.setAttribute("error", "Error en el sistema: " + e.getMessage());
            response.sendRedirect("UsuarioServlet");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        String rol = (String) session.getAttribute("rol");
        if (!tieneAccesoModulo(session, rol)) {
            System.out.println("ACCESO DENEGADO (POST): Rol '" + rol + "' sin modulo UsuarioServlet asignado");
            response.sendRedirect("acceso_denegado.jsp");
            return;
        }

        String idParam = request.getParameter("id");
        String username = request.getParameter("username");
        String hashedPasswordFromFrontend = request.getParameter("password");
        String rolUsuario = request.getParameter("rol");
        String personaIdParam = request.getParameter("persona_id");

        if (username == null || username.trim().isEmpty() ||
            rolUsuario == null || rolUsuario.trim().isEmpty()) {
            session.setAttribute("error", "Nombre de usuario y rol son obligatorios");
            response.sendRedirect("UsuarioServlet");
            return;
        }

        int id = 0;
        if (idParam != null && !idParam.trim().isEmpty()) {
            try {
                id = Integer.parseInt(idParam);
            } catch (NumberFormatException e) {
                session.setAttribute("error", "ID de usuario invalido");
                response.sendRedirect("UsuarioServlet");
                return;
            }
        }

        int personaId = 0;
        if (personaIdParam != null && !personaIdParam.trim().isEmpty()) {
            try {
                personaId = Integer.parseInt(personaIdParam);
            } catch (NumberFormatException e) {
                System.out.println("Persona ID no valido o no proporcionado");
            }
        }

        try {
            if (id == 0) {
                System.out.println("CREANDO NUEVO USUARIO: " + username);

                if (personaId <= 0) {
                    session.setAttribute("error", "Debe seleccionar una persona para asociar el usuario");
                    response.sendRedirect("UsuarioServlet?accion=nuevo");
                    return;
                }

                if (dao.existeUsuario(username.trim())) {
                    session.setAttribute("error", "El nombre de usuario '" + username + "' ya existe");
                    response.sendRedirect("UsuarioServlet?accion=nuevo");
                    return;
                }

                if (hashedPasswordFromFrontend == null || hashedPasswordFromFrontend.trim().isEmpty()) {
                    session.setAttribute("error", "La contrasena es obligatoria para nuevos usuarios");
                    response.sendRedirect("UsuarioServlet?accion=nuevo");
                    return;
                }

                Usuario nuevoUsuario = new Usuario();
                nuevoUsuario.setPersonaId(personaId);
                nuevoUsuario.setUsername(username.trim());
                nuevoUsuario.setPassword(hashedPasswordFromFrontend.trim());
                nuevoUsuario.setRol(rolUsuario.trim());
                nuevoUsuario.setActivo(true);
                nuevoUsuario.setEliminado(false);
                nuevoUsuario.setIntentosFallidos(0);

                java.util.Date ahora = new java.util.Date();
                nuevoUsuario.setFechaRegistro(ahora);
                nuevoUsuario.setUltimaConexion(ahora);

                if (dao.agregar(nuevoUsuario)) {
                    session.setAttribute("mensaje", "Usuario registrado exitosamente y asociado a la persona");
                } else {
                    session.setAttribute("error", "No se pudo registrar el usuario");
                }

            } else {
                System.out.println("ACTUALIZANDO USUARIO ID: " + id);

                Usuario usuarioActual = dao.obtenerPorId(id);
                if (usuarioActual == null) {
                    session.setAttribute("error", "Usuario no encontrado");
                    response.sendRedirect("UsuarioServlet");
                    return;
                }

                if (!usuarioActual.getUsername().equals(username.trim())) {
                    if (dao.existeUsuario(username.trim())) {
                        session.setAttribute("error", "El nombre de usuario '" + username + "' ya existe");
                        response.sendRedirect("UsuarioServlet?accion=editar&id=" + id);
                        return;
                    }
                }

                usuarioActual.setUsername(username.trim());
                usuarioActual.setRol(rolUsuario.trim());

                if (hashedPasswordFromFrontend != null && !hashedPasswordFromFrontend.trim().isEmpty()) {
                    usuarioActual.setPassword(hashedPasswordFromFrontend.trim());
                }

                usuarioActual.setUltimaConexion(new java.util.Date());

                if (dao.actualizar(usuarioActual)) {
                    session.setAttribute("mensaje", "Usuario actualizado exitosamente");
                } else {
                    session.setAttribute("error", "No se pudo actualizar el usuario");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "Error en el sistema: " + e.getMessage());
        }

        response.sendRedirect("UsuarioServlet");
    }

    /**
     * Verifica si el usuario tiene el modulo UsuarioServlet asignado en BD.
     * Replica la logica del SecurityFilter (hasModuleAccess).
     */
    private boolean tieneAccesoModulo(HttpSession session, String rol) {
        if (rol == null) return false;
        if ("admin".equals(rol) || "administrativo".equals(rol)) return true;

        Object uidObj = session.getAttribute("usuarioId");
        if (uidObj == null) {
            System.out.println("UsuarioServlet: ERROR - usuarioId NULL en sesion");
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
                if (modUrl != null && modUrl.contains("UsuarioServlet")) {
                    System.out.println("UsuarioServlet: Modulo CONFIRMADO para usuarioId=" + usuarioId);
                    return true;
                }
            }

        } catch (Exception e) {
            System.err.println("UsuarioServlet: Error BD al verificar modulo: " + e.getMessage());
        }

        System.out.println("UsuarioServlet: Modulo NO asignado para usuarioId=" + usuarioId);
        return false;
    }
}