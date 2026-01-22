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

        try {
            switch (accion) {
                case "nuevo":
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
            session.setAttribute("error", "ID de usuario inválido");
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

        // VALIDACIÓN CRÍTICA: Solo admin puede gestionar usuarios
        String rol = (String) session.getAttribute("rol");
        if (!"admin".equals(rol)) {
            response.sendRedirect("acceso_denegado.jsp");
            return;
        }

        String idParam = request.getParameter("id");
        String username = request.getParameter("username");
        String hashedPasswordFromFrontend = request.getParameter("password");
        String rolUsuario = request.getParameter("rol");
        String personaIdParam = request.getParameter("persona_id");

        System.out.println("Datos recibidos - ID: " + idParam + ", Username: " + username + 
                         ", Rol: " + rolUsuario + ", Persona ID: " + personaIdParam);

        // Validaciones básicas
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
                session.setAttribute("error", "ID de usuario inválido");
                response.sendRedirect("UsuarioServlet");
                return;
            }
        }

        int personaId = 0;
        if (personaIdParam != null && !personaIdParam.trim().isEmpty()) {
            try {
                personaId = Integer.parseInt(personaIdParam);
            } catch (NumberFormatException e) {
                // Persona ID no es obligatorio en algunos casos
                System.out.println("Persona ID no válido o no proporcionado");
            }
        }

        try {
            if (id == 0) {
                // CREAR NUEVO USUARIO
                System.out.println("Creando nuevo usuario: " + username);

                if (dao.existeUsuario(username.trim())) {
                    System.out.println("Usuario ya existe: " + username);
                    session.setAttribute("error", "No se pudo registrar el usuario. El nombre de usuario '" + username + "' ya existe.");
                    response.sendRedirect("UsuarioServlet?accion=nuevo");
                    return;
                }

                if (hashedPasswordFromFrontend == null || hashedPasswordFromFrontend.trim().isEmpty()) {
                    session.setAttribute("error", "La contraseña es obligatoria para nuevos usuarios");
                    response.sendRedirect("UsuarioServlet?accion=nuevo");
                    return;
                }

                // Crear nuevo objeto Usuario
                Usuario nuevoUsuario = new Usuario();
                nuevoUsuario.setPersonaId(personaId);
                nuevoUsuario.setUsername(username.trim());
                nuevoUsuario.setPassword(hashedPasswordFromFrontend.trim());
                nuevoUsuario.setRol(rolUsuario.trim());
                nuevoUsuario.setActivo(true);
                nuevoUsuario.setEliminado(false);
                nuevoUsuario.setIntentosFallidos(0);
                
                // Establecer fechas
                java.util.Date ahora = new java.util.Date();
                nuevoUsuario.setFechaRegistro(ahora);
                nuevoUsuario.setUltimaConexion(ahora);

                if (dao.agregar(nuevoUsuario)) {
                    System.out.println("Usuario creado exitosamente: " + username);
                    session.setAttribute("mensaje", "Usuario registrado exitosamente");
                } else {
                    System.out.println("Error al crear usuario: " + username);
                    session.setAttribute("error", "No se pudo registrar el usuario. Error del sistema.");
                }

            } else {
                // ACTUALIZAR USUARIO EXISTENTE
                System.out.println("Actualizando usuario ID: " + id);

                // Obtener usuario actual de la base de datos
                Usuario usuarioActual = dao.obtenerPorId(id);
                if (usuarioActual == null) {
                    session.setAttribute("error", "Usuario no encontrado");
                    response.sendRedirect("UsuarioServlet");
                    return;
                }

                // Verificar si el username cambió
                if (!usuarioActual.getUsername().equals(username.trim())) {
                    if (dao.existeUsuario(username.trim())) {
                        System.out.println("Nombre de usuario ya existe: " + username);
                        session.setAttribute("error", "No se pudo actualizar el usuario. El nombre de usuario '" + username + "' ya existe.");
                        response.sendRedirect("UsuarioServlet?accion=editar&id=" + id);
                        return;
                    }
                }

                // Actualizar los campos
                usuarioActual.setPersonaId(personaId);
                usuarioActual.setUsername(username.trim());
                usuarioActual.setRol(rolUsuario.trim());
                
                // Manejar la contraseña
                if (hashedPasswordFromFrontend != null && !hashedPasswordFromFrontend.trim().isEmpty()) {
                    usuarioActual.setPassword(hashedPasswordFromFrontend.trim());
                    System.out.println("Actualizando contraseña para usuario: " + username);
                }
                // Si no se proporciona contraseña, se mantiene la actual (no se modifica el campo)

                // Actualizar la última conexión
                usuarioActual.setUltimaConexion(new java.util.Date());

                if (dao.actualizar(usuarioActual)) {
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