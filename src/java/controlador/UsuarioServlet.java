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

        // VALIDACIÓN CRÍTICA: Solo admin puede gestionar usuarios
        String rol = (String) session.getAttribute("rol");
        if (!"admin".equals(rol)) {
            response.sendRedirect("acceso_denegado.jsp");
            return;
        }

        String accion = request.getParameter("accion");

        if (accion == null || accion.isEmpty()) {
            request.setAttribute("lista", dao.listar());
            request.getRequestDispatcher("usuarios.jsp").forward(request, response);
            return;
        }

        switch (accion) {
            case "nuevo":
                request.getRequestDispatcher("usuarioForm.jsp").forward(request, response);
                break;
                
            case "editar":
                try {
                    int idEditar = Integer.parseInt(request.getParameter("id"));
                    Usuario u = dao.obtenerPorId(idEditar);
                    if (u != null) {
                        request.setAttribute("usuario", u);
                        request.getRequestDispatcher("usuarioForm.jsp").forward(request, response);
                    } else {
                        session.setAttribute("error", "Usuario no encontrado");
                        response.sendRedirect("UsuarioServlet");
                    }
                } catch (NumberFormatException e) {
                    session.setAttribute("error", "ID de usuario invalido");
                    response.sendRedirect("UsuarioServlet");
                }
                break;

            case "eliminar":
                try {
                    int idEliminar = Integer.parseInt(request.getParameter("id"));
                    if (dao.eliminar(idEliminar)) {
                        session.setAttribute("mensaje", "Usuario eliminado exitosamente");
                    } else {
                        session.setAttribute("error", "No se pudo eliminar el usuario");
                    }
                } catch (NumberFormatException e) {
                    session.setAttribute("error", "ID de usuario invalido");
                }
                response.sendRedirect("UsuarioServlet");
                break;

            default:
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

        // VALIDACIÓN CRÍTICA: Solo admin puede gestionar usuarios
        String rol = (String) session.getAttribute("rol");
        if (!"admin".equals(rol)) {
            response.sendRedirect("acceso_denegado.jsp");
            return;
        }

        if (!dao.verificarConexion()) {
            session.setAttribute("error", "Error de conexion a la base de datos. Contacte al administrador.");
            response.sendRedirect("UsuarioServlet");
            return;
        }

        String idParam = request.getParameter("id");
        String username = request.getParameter("username");
        String hashedPasswordFromFrontend = request.getParameter("password");
        String rolUsuario = request.getParameter("rol");

        System.out.println("Datos recibidos - ID: " + idParam + ", Username: " + username + ", Rol: " + rolUsuario);

        if (username == null || username.trim().isEmpty() || rolUsuario == null || rolUsuario.trim().isEmpty()) {
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

        Usuario u = new Usuario();
        u.setId(id);
        u.setUsername(username.trim());
        u.setRol(rolUsuario.trim());

        try {
            if (id == 0) {
                System.out.println("Creando nuevo usuario: " + username);

                if (dao.existeUsuario(username.trim())) {
                    System.out.println("Usuario ya existe: " + username);
                    session.setAttribute("error", "No se pudo registrar el usuario. El nombre de usuario '" + username + "' ya existe.");
                    response.sendRedirect("UsuarioServlet");
                    return;
                }

                if (hashedPasswordFromFrontend == null || hashedPasswordFromFrontend.trim().isEmpty()) {
                    session.setAttribute("error", "La contraseña es obligatoria para nuevos usuarios");
                    response.sendRedirect("UsuarioServlet");
                    return;
                }

                u.setPassword(hashedPasswordFromFrontend.trim());

                if (dao.agregar(u)) {
                    System.out.println("Usuario creado exitosamente: " + username);
                    session.setAttribute("mensaje", "Usuario registrado exitosamente");
                } else {
                    System.out.println("Error al crear usuario: " + username);
                    session.setAttribute("error", "No se pudo registrar el usuario. Error del sistema.");
                }

            } else {
                System.out.println("Actualizando usuario ID: " + id);

                Usuario usuarioActual = dao.obtenerPorId(id);
                if (usuarioActual == null) {
                    session.setAttribute("error", "Usuario no encontrado");
                    response.sendRedirect("UsuarioServlet");
                    return;
                }

                if (!usuarioActual.getUsername().equals(username.trim())) {
                    if (dao.existeUsuario(username.trim())) {
                        System.out.println("Nombre de usuario ya existe: " + username);
                        session.setAttribute("error", "No se pudo actualizar el usuario. El nombre de usuario '" + username + "' ya existe.");
                        response.sendRedirect("UsuarioServlet?accion=editar&id=" + id);
                        return;
                    }
                }

                if (hashedPasswordFromFrontend != null && !hashedPasswordFromFrontend.trim().isEmpty()) {
                    u.setPassword(hashedPasswordFromFrontend.trim());
                    System.out.println("Actualizando contraseña para usuario: " + username);
                } else {
                    u.setPassword(null);
                    System.out.println("Manteniendo contraseña actual para usuario: " + username);
                }

                if (dao.actualizar(u)) {
                    System.out.println("Usuario actualizado exitosamente: " + username);
                    session.setAttribute("mensaje", "Usuario actualizado exitosamente");
                } else {
                    System.out.println("Error al actualizar usuario: " + username);
                    session.setAttribute("error", "No se pudo actualizar el usuario. Verifique los datos o contacte al administrador.");
                }
            }

        } catch (Exception e) {
            System.err.println("Error en el servlet UsuarioServlet:");
            e.printStackTrace();
            session.setAttribute("error", "Error en el sistema: " + e.getMessage());
        }

        response.sendRedirect("UsuarioServlet");
    }
}