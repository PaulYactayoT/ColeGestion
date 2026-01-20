package controlador;

import conexion.Conexion;
import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import modelo.UsuarioDAO;
import modelo.Usuario;
import util.ValidacionContraseña;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    private static final int MAX_INTENTOS = 3;
    private static final int TIEMPO_BLOQUEO_MINUTOS = 1;
    private static final int TIEMPO_INACTIVIDAD_SEGUNDOS = 30 * 60;

    private UsuarioDAO usuarioDAO = new UsuarioDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");

        String user = request.getParameter("username");
        String hashedPasswordFromFrontend = request.getParameter("password");
        String captchaInput = request.getParameter("captchaInput");
        String captchaHidden = request.getParameter("captchaHidden");

        System.out.println("═══════════════════════════════════════");
        System.out.println("🔐 Intento de login: " + user);
        System.out.println("═══════════════════════════════════════");

        try {
            // Desbloquear usuarios expirados
            usuarioDAO.desbloquearUsuariosExpirados(TIEMPO_BLOQUEO_MINUTOS);

            // Verificar si el usuario esta bloqueado
            if (usuarioDAO.estaBloqueado(user)) {
                System.out.println("⛔ Usuario bloqueado: " + user);
                long tiempoRestante = calcularTiempoRestanteBloqueo(user);
                String json = "{\"success\": false, \"error\": \"Usuario bloqueado. Intente mas tarde.\", \"tipoError\": \"bloqueado\", \"tiempoRestante\": " + tiempoRestante + "}";
                response.getWriter().write(json);
                return;
            }

            // Obtener usuario
            Usuario usuario = usuarioDAO.obtenerPorUsername(user);
            
            if (usuario == null) {
                System.out.println("✗ Usuario no encontrado: " + user);
                manejarCredencialesInvalidas(user, response);
                return;
            }

            System.out.println("✓ Usuario encontrado: " + user);

            // Verificar si esta activo
            if (!usuario.isActivo()) {
                System.out.println("⚠️ Usuario inactivo: " + user);
                enviarJson(response, false, "Usuario inactivo. Contacte al administrador.", "inactivo");
                return;
            }

            // Validar credenciales
            boolean credencialesCorrectas = usuario.getPassword().equals(hashedPasswordFromFrontend);
            
            if (!credencialesCorrectas) {
                System.out.println("✗ Credenciales incorrectas para: " + user);
                manejarCredencialesInvalidas(user, response);
                return;
            }

            System.out.println("✓ Credenciales correctas");

            // Validar CAPTCHA
            if (captchaInput == null || captchaHidden == null || !captchaInput.trim().equalsIgnoreCase(captchaHidden.trim())) {
                System.out.println("✗ CAPTCHA incorrecto");
                String json = "{\"success\": false, \"error\": \"Codigo de verificacion incorrecto\", \"tipoError\": \"requiere_captcha\"}";
                response.getWriter().write(json);
                return;
            }

            System.out.println("✓ CAPTCHA validado");

            // Login exitoso
            usuarioDAO.resetearIntentosUsuario(user);
            
            HttpSession session = request.getSession();
            session.setAttribute("usuario", user);
            session.setAttribute("usuarioId", usuario.getId());
            session.setAttribute("rol", usuario.getRol());
            session.setMaxInactiveInterval(TIEMPO_INACTIVIDAD_SEGUNDOS);

            String redirectUrl = determinarRedireccion(usuario.getRol(), user, request, response);
            
            if (redirectUrl != null) {
                System.out.println("✓ LOGIN EXITOSO → " + redirectUrl);
                System.out.println("═══════════════════════════════════════");
                enviarJson(response, true, redirectUrl);
            } else {
                enviarJson(response, false, "No se pudo determinar la redireccion", "redireccion");
            }

        } catch (Exception e) {
            System.err.println("❌ ERROR EN LOGIN:");
            e.printStackTrace();
            enviarJson(response, false, "Error interno del servidor", "sistema");
        }
    }

    private void manejarCredencialesInvalidas(String username, HttpServletResponse response) throws IOException {
        usuarioDAO.incrementarIntentoFallido(username);
        int intentosRestantes = getIntentosRestantes(username);

        System.out.println("⚠️ Intentos restantes: " + intentosRestantes);

        if (intentosRestantes <= 0) {
            usuarioDAO.bloquearUsuario(username);
            long tiempoRestante = TIEMPO_BLOQUEO_MINUTOS * 60 * 1000;
            String json = "{\"success\": false, \"error\": \"Usuario bloqueado por intentos fallidos.\", \"tipoError\": \"bloqueado\", \"tiempoRestante\": " + tiempoRestante + "}";
            response.getWriter().write(json);
        } else {
            String json = "{\"success\": false, \"error\": \"Credenciales incorrectas. Intentos restantes: " + intentosRestantes + "\", \"tipoError\": \"credenciales\", \"intentosRestantes\": " + intentosRestantes + "}";
            response.getWriter().write(json);
        }
    }

    private int getIntentosRestantes(String username) {
        Usuario usuario = usuarioDAO.obtenerDatosBloqueo(username);
        if (usuario != null) {
            int intentosUsados = usuario.getIntentosFallidos();
            int restantes = MAX_INTENTOS - intentosUsados;
            return Math.max(0, restantes);
        }
        return MAX_INTENTOS;
    }

    private long calcularTiempoRestanteBloqueo(String username) {
        Usuario usuario = usuarioDAO.obtenerDatosBloqueo(username);
        if (usuario != null && usuario.getFechaBloqueo() != null) {
            long transcurrido = System.currentTimeMillis() - usuario.getFechaBloqueo().getTime();
            long total = TIEMPO_BLOQUEO_MINUTOS * 60 * 1000;
            long restante = Math.max(0, total - transcurrido);
            return restante;
        }
        return TIEMPO_BLOQUEO_MINUTOS * 60 * 1000;
    }

    private void enviarJson(HttpServletResponse response, boolean success, String mensaje) throws IOException {
        response.getWriter().write("{\"success\": " + success + ", \"redirect\": \"" + mensaje + "\"}");
    }

    private void enviarJson(HttpServletResponse response, boolean success, String mensaje, String tipoError) throws IOException {
        response.getWriter().write("{\"success\": " + success + ", \"error\": \"" + mensaje + "\", \"tipoError\": \"" + tipoError + "\"}");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");

        String accion = request.getParameter("accion");
        HttpSession session = request.getSession(false);

        System.out.println("GET Request - Accion: " + accion);

        switch (accion != null ? accion : "") {
            case "verificarBloqueo":
                verificarBloqueo(request, response);
                break;
            case "verificarPassword":
                verificarPassword(request, response);
                break;
            case "dashboard":
                accederDashboard(session, request, response);
                break;
            case "logout":
                cerrarSesion(request, response);
                break;
            default:
                response.sendRedirect("index.jsp");
        }
    }

    private void verificarBloqueo(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String username = request.getParameter("username");
        if (username == null) {
            response.getWriter().write("{\"bloqueado\": true}");
            return;
        }

        try {
            usuarioDAO.desbloquearUsuariosExpirados(TIEMPO_BLOQUEO_MINUTOS);
            boolean bloqueado = usuarioDAO.estaBloqueado(username);
            response.getWriter().write("{\"bloqueado\": " + bloqueado + "}");
        } catch (Exception e) {
            System.err.println("Error verificando bloqueo: " + e.getMessage());
            response.getWriter().write("{\"bloqueado\": true}");
        }
    }

    private void verificarPassword(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String password = request.getParameter("password");
        if (password == null) {
            return;
        }

        try {
            boolean esFuerte = ValidacionContraseña.esPasswordFuerte(password);
            String mensaje = esFuerte ? "Contraseña segura" : ValidacionContraseña.obtenerRequisitosPassword();
            response.getWriter().write("{\"esFuerte\": " + esFuerte + ", \"mensaje\": \"" + mensaje + "\"}");
        } catch (Exception e) {
            System.err.println("Error validando password: " + e.getMessage());
            response.getWriter().write("{\"esFuerte\": false, \"mensaje\": \"Error al validar contraseña\"}");
        }
    }

    private void accederDashboard(HttpSession session, HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        if (session == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        String user = (String) session.getAttribute("usuario");
        if (user == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        String rol = (String) session.getAttribute("rol");
        if ("docente".equalsIgnoreCase(rol)) {
            modelo.Profesor docente = (modelo.Profesor) session.getAttribute("docente");
            if (docente != null) {
                java.util.List<modelo.Curso> misCursos = new modelo.CursoDAO().listarPorProfesor(docente.getId());
                request.setAttribute("misCursos", misCursos);
                request.getRequestDispatcher("docenteDashboard.jsp").forward(request, response);
                return;
            }
        } else if ("admin".equalsIgnoreCase(rol)) {
            response.sendRedirect("dashboard.jsp");
            return;
        } else if ("padre".equalsIgnoreCase(rol)) {
            response.sendRedirect("padreDashboard.jsp");
            return;
        }
        response.sendRedirect("index.jsp?error=rol_desconocido");
    }

    private void cerrarSesion(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            String usuario = (String) session.getAttribute("usuario");
            System.out.println("👋 Cerrando sesión: " + usuario);
            session.invalidate();
        }
        response.sendRedirect("index.jsp?mensaje=Sesion cerrada");
    }

    private String determinarRedireccion(String rol, String user, HttpServletRequest request, HttpServletResponse response) throws Exception {
        System.out.println("→ Determinando redireccion - Rol: " + rol);

        if ("admin".equalsIgnoreCase(rol)) {
            return "dashboard.jsp";
        }

        if ("docente".equalsIgnoreCase(rol)) {
            modelo.Profesor docente = new modelo.ProfesorDAO().obtenerPorUsername(user);

            if (docente != null) {
                HttpSession session = request.getSession();
                session.setAttribute("docente", docente);
                System.out.println("  ✓ Docente: " + docente.getNombres() + " " + docente.getApellidos());

                java.util.List<modelo.Curso> misCursos = new modelo.CursoDAO().listarPorProfesor(docente.getId());
                session.setAttribute("misCursos", misCursos);
                System.out.println("  ✓ Cursos: " + (misCursos != null ? misCursos.size() : 0));

                return "docenteDashboard.jsp";
            } else {
                System.out.println("  ✗ Docente no encontrado");
                return "index.jsp?error=docente_no_encontrado";
            }
        }

        if ("padre".equalsIgnoreCase(rol)) {
            modelo.Padre padre = new modelo.PadreDAO().obtenerPorUsername(user);
            if (padre != null) {
                request.getSession().setAttribute("padre", padre);
                System.out.println("  ✓ Padre - Alumno: " + padre.getAlumnoNombre());
                return "padreDashboard.jsp";
            } else {
                System.out.println("  ✗ Padre no encontrado");
                return "index.jsp?error=padre_invalido";
            }
        }

        System.out.println("✗ Rol desconocido: " + rol);
        return "index.jsp?error=rol_no_reconocido";
    }
}