package controlador;

import conexion.Conexion;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import modelo.UsuarioDAO;
import modelo.Usuario;
import modelo.ProfesorDAO;
import modelo.Profesor;
import modelo.PadreDAO;
import modelo.Padre;
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
        System.out.println("Intento de login: " + user);
        System.out.println("Contraseña recibida (primeros 20 chars): " + 
                          (hashedPasswordFromFrontend != null && hashedPasswordFromFrontend.length() > 20 ? 
                           hashedPasswordFromFrontend.substring(0, 20) + "..." : 
                           (hashedPasswordFromFrontend != null ? hashedPasswordFromFrontend : "null")));
        System.out.println("═══════════════════════════════════════");

        try {
            // Desbloquear usuarios expirados
            usuarioDAO.desbloquearUsuariosExpirados(TIEMPO_BLOQUEO_MINUTOS);

            // Verificar si el usuario está bloqueado
            if (usuarioDAO.estaBloqueado(user)) {
                System.out.println("Usuario bloqueado: " + user);
                long tiempoRestante = calcularTiempoRestanteBloqueo(user);
                String json = "{\"success\": false, \"error\": \"Usuario bloqueado. Intente más tarde.\", \"tipoError\": \"bloqueado\", \"tiempoRestante\": " + tiempoRestante + "}";
                response.getWriter().write(json);
                return;
            }

            // Obtener usuario
            Usuario usuario = usuarioDAO.obtenerPorUsername(user);
            
            if (usuario == null) {
                System.out.println("Usuario no encontrado: " + user);
                manejarCredencialesInvalidas(user, response);
                return;
            }

            System.out.println("Usuario encontrado:");
            System.out.println("  - ID: " + usuario.getId());
            System.out.println("  - Persona ID: " + usuario.getPersonaId());
            System.out.println("  - Rol: " + usuario.getRol());
            System.out.println("  - Activo: " + usuario.isActivo());

            // Verificar si está activo
            if (!usuario.isActivo()) {
                System.out.println("Usuario inactivo: " + user);
                enviarJson(response, false, "Usuario inactivo. Contacte al administrador.", "inactivo");
                return;
            }

            // Validar credenciales
            System.out.println("Comparando contraseñas...");
            boolean credencialesCorrectas = usuario.getPassword().equals(hashedPasswordFromFrontend);
            
            if (!credencialesCorrectas) {
                System.out.println("Credenciales incorrectas para: " + user);
                manejarCredencialesInvalidas(user, response);
                return;
            }

            System.out.println("Credenciales correctas");

            // Validar CAPTCHA
            if (captchaInput == null || captchaHidden == null || !captchaInput.trim().equalsIgnoreCase(captchaHidden.trim())) {
                System.out.println("CAPTCHA incorrecto");
                String json = "{\"success\": false, \"error\": \"Código de verificación incorrecto\", \"tipoError\": \"requiere_captcha\"}";
                response.getWriter().write(json);
                return;
            }

            System.out.println("CAPTCHA validado");

            // Login exitoso
            usuarioDAO.resetearIntentosUsuario(user);
            
            HttpSession session = request.getSession();
            session.setAttribute("usuario", user);
            session.setAttribute("usuarioId", usuario.getId());
            session.setAttribute("rol", usuario.getRol());
            session.setMaxInactiveInterval(TIEMPO_INACTIVIDAD_SEGUNDOS);

            String redirectUrl = determinarRedireccion(usuario.getRol(), user, request, response);
            
            if (redirectUrl != null) {
                System.out.println("LOGIN EXITOSO → " + redirectUrl);
                System.out.println("═══════════════════════════════════════");
                enviarJson(response, true, redirectUrl);
            } else {
                enviarJson(response, false, "No se pudo determinar la redirección", "redireccion");
            }

        } catch (Exception e) {
            System.err.println("ERROR EN LOGIN:");
            e.printStackTrace();
            enviarJson(response, false, "Error interno del servidor", "sistema");
        }
    }

    private void manejarCredencialesInvalidas(String username, HttpServletResponse response) throws IOException {
        usuarioDAO.incrementarIntentoFallido(username);
        int intentosRestantes = getIntentosRestantes(username);

        System.out.println("Intentos restantes: " + intentosRestantes);

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
        response.setContentType("text/html; charset=UTF-8");

        String accion = request.getParameter("accion");
        HttpSession session = request.getSession(false);

        System.out.println("GET Request - Acción: " + accion);

        if ("test".equals(accion)) {
            testProfesorConnection(request, response);
            return;
        }
        
        if ("debugPadre".equals(accion)) {
            debugPadre(request, response);
            return;
        }
        
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

    private void testProfesorConnection(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String username = request.getParameter("username");
        if (username == null) username = "juantapia";
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        out.println("<html><head><style>");
        out.println("body { font-family: Arial, sans-serif; margin: 20px; }");
        out.println(".success { color: green; }");
        out.println(".error { color: red; }");
        out.println(".info { color: blue; }");
        out.println("</style></head><body>");
        out.println("<h1>Test de conexión para usuario: " + username + "</h1>");
        
        try {
            out.println("<h2>1. Verificando tabla usuario...</h2>");
            Usuario usuario = usuarioDAO.obtenerPorUsername(username);
            if (usuario == null) {
                out.println("<p class='error'>Usuario no encontrado en tabla usuario</p>");
            } else {
                out.println("<p class='success'>Usuario encontrado:</p>");
                out.println("<ul>");
                out.println("<li>ID: " + usuario.getId() + "</li>");
                out.println("<li>Persona ID: " + usuario.getPersonaId() + "</li>");
                out.println("<li>Rol: " + usuario.getRol() + "</li>");
                out.println("<li>Activo: " + usuario.isActivo() + "</li>");
                out.println("</ul>");
            }
            
            out.println("<h2>2. Verificando tabla persona...</h2>");
            if (usuario != null && usuario.getPersonaId() > 0) {
                String personaSql = "SELECT * FROM persona WHERE id = ?";
                try (Connection conn = Conexion.getConnection();
                     PreparedStatement ps = conn.prepareStatement(personaSql)) {
                    ps.setInt(1, usuario.getPersonaId());
                    ResultSet rs = ps.executeQuery();
                    if (rs.next()) {
                        out.println("<p class='success'>Persona encontrada:</p>");
                        out.println("<ul>");
                        out.println("<li>Nombres: " + rs.getString("nombres") + "</li>");
                        out.println("<li>Apellidos: " + rs.getString("apellidos") + "</li>");
                        out.println("<li>Correo: " + rs.getString("correo") + "</li>");
                        out.println("<li>DNI: " + rs.getString("dni") + "</li>");
                        out.println("</ul>");
                    }
                }
            }
            
            out.println("<h2>3. Probando ProfesorDAO.obtenerPorUsername...</h2>");
            ProfesorDAO profesorDAO = new ProfesorDAO();
            Profesor docente = profesorDAO.obtenerPorUsername(username);
            if (docente == null) {
                out.println("<p class='error'>ProfesorDAO.obtenerPorUsername devolvió null</p>");
            } else {
                out.println("<p class='success'>Profesor obtenido correctamente:</p>");
                out.println("<ul>");
                out.println("<li>Nombre: " + docente.getNombreCompleto() + "</li>");
                out.println("<li>Foto: " + docente.getFoto() + "</li>");
                out.println("</ul>");
            }
            
        } catch (Exception e) {
            out.println("<p class='error'>Error: " + e.getMessage() + "</p>");
            e.printStackTrace();
        }
        
        out.println("<form method='get' style='margin-top: 20px;'>");
        out.println("<input type='hidden' name='accion' value='test'>");
        out.println("<input type='text' name='username' value='" + username + "'>");
        out.println("<button type='submit'>Probar</button>");
        out.println("</form>");
        out.println("</body></html>");
    }

    private void debugPadre(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String username = request.getParameter("username");
        if (username == null) username = "milagroscandela";
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        out.println("<html><body>");
        out.println("<h1>DEBUG - Padre: " + username + "</h1>");
        
        try {
            Usuario usuario = usuarioDAO.obtenerPorUsername(username);
            if (usuario == null) {
                out.println("<p style='color:red'>Usuario no encontrado</p>");
                return;
            }
            out.println("<p style='color:green'>Usuario encontrado - Rol: " + usuario.getRol() + "</p>");
            
            PadreDAO padreDAO = new PadreDAO();
            Padre padre = padreDAO.obtenerPorUsername(username);
            if (padre == null) {
                out.println("<p style='color:red'>PadreDAO devolvió null</p>");
            } else {
                out.println("<p style='color:green'>Padre: " + padre.getNombreCompleto() + "</p>");
                out.println("<p>Alumno: " + padre.getAlumnoNombre() + "</p>");
                out.println("<p>Foto alumno: " + padre.getAlumnoFoto() + "</p>");
            }
        } catch (Exception e) {
            out.println("<p style='color:red'>Error: " + e.getMessage() + "</p>");
        }
        
        out.println("<form method='get'><input type='hidden' name='accion' value='debugPadre'>");
        out.println("<input type='text' name='username' value='" + username + "'>");
        out.println("<button type='submit'>Probar</button></form>");
        out.println("</body></html>");
    }

    private void verificarBloqueo(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
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
            response.getWriter().write("{\"bloqueado\": true}");
        }
    }

    private void verificarPassword(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        String password = request.getParameter("password");
        if (password == null) return;

        try {
            boolean esFuerte = ValidacionContraseña.esPasswordFuerte(password);
            String mensaje = esFuerte ? "Contraseña segura" : ValidacionContraseña.obtenerRequisitosPassword();
            response.getWriter().write("{\"esFuerte\": " + esFuerte + ", \"mensaje\": \"" + mensaje + "\"}");
        } catch (Exception e) {
            response.getWriter().write("{\"esFuerte\": false, \"mensaje\": \"Error al validar contraseña\"}");
        }
    }

    private void accederDashboard(HttpSession session, HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        if (session == null) { response.sendRedirect("index.jsp"); return; }
        String user = (String) session.getAttribute("usuario");
        if (user == null) { response.sendRedirect("index.jsp"); return; }

        String rol = (String) session.getAttribute("rol");
        if ("docente".equalsIgnoreCase(rol)) {
            modelo.Profesor docente = (modelo.Profesor) session.getAttribute("docente");
            if (docente == null) {
                docente = new modelo.ProfesorDAO().obtenerPorUsername(user);
                if (docente != null) session.setAttribute("docente", docente);
            }
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
            modelo.Padre padre = (modelo.Padre) session.getAttribute("padre");
            if (padre == null) {
                padre = new modelo.PadreDAO().obtenerPorUsername(user);
                if (padre != null) session.setAttribute("padre", padre);
            }
            response.sendRedirect("padreDashboard.jsp");
            return;
        }
        response.sendRedirect("index.jsp?error=rol_desconocido");
    }

    private void cerrarSesion(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            System.out.println("Cerrando sesión: " + session.getAttribute("usuario"));
            session.invalidate();
        }
        response.sendRedirect("index.jsp?mensaje=Sesión cerrada");
    }

    private String determinarRedireccion(String rol, String user, HttpServletRequest request, HttpServletResponse response) throws Exception {
        System.out.println("→ Determinando redirección - Rol: " + rol);

        
        // ══════════════════════════════════════════
        // ROL: ADMIN
        // ══════════════════════════════════════════
        if ("admin".equalsIgnoreCase(rol)) {
            // Obtener foto del admin desde persona
            try (Connection conn = Conexion.getConnection()) {
                String fotoSql = """
                    SELECT p.foto 
                    FROM persona p 
                    JOIN usuario u ON u.persona_id = p.id 
                    WHERE u.username = ?
                    """;
                try (PreparedStatement ps = conn.prepareStatement(fotoSql)) {
                    ps.setString(1, user);
                    ResultSet rs = ps.executeQuery();
                    if (rs.next()) {
                        String foto = rs.getString("foto");
                        HttpSession session = request.getSession();
                        // Admin muestra su propia foto
                        session.setAttribute("fotoUsuario", foto != null ? foto : "");
                        System.out.println("  Foto admin: " + foto);
                    }
                }
            } catch (SQLException e) {
                System.err.println("  Error obteniendo foto admin: " + e.getMessage());
            }
            return "dashboard.jsp";
        }
        
        // ══════════════════════════════════════════
        // ROL: ADMINISTRATIVO
        // ══════════════════════════════════════════
        if ("administrativo".equalsIgnoreCase(rol)) {
            try (Connection conn = Conexion.getConnection()) {
                String fotoSql = "SELECT p.foto FROM persona p JOIN usuario u ON u.persona_id = p.id WHERE u.username = ?";
                try (PreparedStatement ps = conn.prepareStatement(fotoSql)) {
                    ps.setString(1, user);
                    ResultSet rs = ps.executeQuery();
                    if (rs.next()) {
                        String foto = rs.getString("foto");
                        HttpSession session = request.getSession();
                        session.setAttribute("fotoUsuario", foto != null ? foto : "");
                        System.out.println("  Foto administrativo: " + foto);
                    }
                }
            } catch (SQLException e) {
                System.err.println("  Error obteniendo foto administrativo: " + e.getMessage());
            }
            return "administrativoDashboard.jsp";
        }

        // ══════════════════════════════════════════
        // ROL: DOCENTE
        // ══════════════════════════════════════════
        if ("docente".equalsIgnoreCase(rol)) {
            ProfesorDAO profesorDAO = new ProfesorDAO();
            Profesor docente = profesorDAO.obtenerPorUsername(user);

            if (docente != null) {
                HttpSession session = request.getSession();
                session.setAttribute("docente", docente);
                // ✅ Docente muestra su propia foto
                session.setAttribute("fotoUsuario", docente.getFoto() != null ? docente.getFoto() : "");
                System.out.println("  Docente encontrado: " + docente.getNombreCompleto());
                System.out.println("  Foto docente: " + docente.getFoto());
                return "DocenteDashboardServlet";
            } else {
                System.out.println("  Docente no encontrado para usuario: " + user);
                return "index.jsp?error=docente_no_encontrado";
            }
        }

        // ══════════════════════════════════════════
        // ROL: PADRE
        // ══════════════════════════════════════════
        if ("padre".equalsIgnoreCase(rol)) {
            System.out.println("  Buscando información del padre: " + user);
            
            Usuario usuario = usuarioDAO.obtenerPorUsername(user);
            if (usuario == null) {
                return "index.jsp?error=usuario_no_encontrado";
            }

            // Verificar y corregir tipo de persona si es necesario
            try (Connection conn = Conexion.getConnection()) {
                String tipoSql = "SELECT tipo FROM persona WHERE id = ?";
                try (PreparedStatement ps = conn.prepareStatement(tipoSql)) {
                    ps.setInt(1, usuario.getPersonaId());
                    ResultSet rs = ps.executeQuery();
                    if (rs.next()) {
                        String tipoPersona = rs.getString("tipo");
                        if (!"PADRE".equals(tipoPersona) && "ALUMNO".equals(tipoPersona)) {
                            String updateSql = "UPDATE persona SET tipo = 'PADRE' WHERE id = ?";
                            try (PreparedStatement psUpdate = conn.prepareStatement(updateSql)) {
                                psUpdate.setInt(1, usuario.getPersonaId());
                                psUpdate.executeUpdate();
                                System.out.println("  Tipo corregido a PADRE");
                            }
                        }
                    }
                }
                
                // Verificar relación familiar
                String relacionSql = "SELECT COUNT(*) as count FROM relacion_familiar WHERE persona_id = ? AND eliminado = 0";
                try (PreparedStatement ps = conn.prepareStatement(relacionSql)) {
                    ps.setInt(1, usuario.getPersonaId());
                    ResultSet rs = ps.executeQuery();
                    if (rs.next() && rs.getInt("count") == 0) {
                        // Asociar con primer alumno disponible
                        String alumnoSql = "SELECT id FROM alumno WHERE eliminado = 0 LIMIT 1";
                        try (PreparedStatement psAlumno = conn.prepareStatement(alumnoSql)) {
                            ResultSet rsAlumno = psAlumno.executeQuery();
                            if (rsAlumno.next()) {
                                int alumnoId = rsAlumno.getInt("id");
                                String insertRelacion = "INSERT INTO relacion_familiar (alumno_id, persona_id, parentesco, es_contacto_principal) VALUES (?, ?, 'PADRE', 1)";
                                try (PreparedStatement psInsert = conn.prepareStatement(insertRelacion)) {
                                    psInsert.setInt(1, alumnoId);
                                    psInsert.setInt(2, usuario.getPersonaId());
                                    psInsert.executeUpdate();
                                    System.out.println("  Relación familiar creada con alumno: " + alumnoId);
                                }
                            }
                        }
                    }
                }
            } catch (SQLException e) {
                System.err.println("  Error verificando datos del padre: " + e.getMessage());
            }
            
            // Obtener padre completo (ya incluye alumnoFoto del PadreDAO)
            PadreDAO padreDAO = new PadreDAO();
            Padre padre = padreDAO.obtenerPorUsername(user);
            
            if (padre != null) {
                HttpSession session = request.getSession();
                session.setAttribute("padre", padre);
                
                // ✅ PADRE: mostrar foto del HIJO (alumno) en el header
                String fotoAlumno = padre.getAlumnoFoto();
                session.setAttribute("fotoUsuario", fotoAlumno != null ? fotoAlumno : "");
                System.out.println("  Padre encontrado: " + padre.getNombreCompleto());
                System.out.println("  Alumno asociado: " + padre.getAlumnoNombre());
                System.out.println("  Foto del alumno (hijo): " + fotoAlumno);
                return "padreDashboard.jsp";
            } else {
                // Crear objeto padre básico si no se puede obtener completo
                try (Connection conn = Conexion.getConnection()) {
                    String personaSql = "SELECT nombres, apellidos FROM persona WHERE id = ?";
                    try (PreparedStatement ps = conn.prepareStatement(personaSql)) {
                        ps.setInt(1, usuario.getPersonaId());
                        ResultSet rs = ps.executeQuery();
                        if (rs.next()) {
                            Padre padreBasico = new Padre();
                            padreBasico.setId(usuario.getPersonaId());
                            padreBasico.setNombres(rs.getString("nombres"));
                            padreBasico.setApellidos(rs.getString("apellidos"));
                            padreBasico.setUsername(user);
                            
                            HttpSession session = request.getSession();
                            session.setAttribute("padre", padreBasico);
                            session.setAttribute("fotoUsuario", ""); // Sin foto
                            return "padreDashboard.jsp";
                        }
                    }
                } catch (SQLException e) {
                    System.err.println("  Error creando padre básico: " + e.getMessage());
                }
                return "index.jsp?error=padre_invalido";
            }
        }

        System.out.println("Rol desconocido: " + rol);
        return "index.jsp?error=rol_no_reconocido";
    }
}