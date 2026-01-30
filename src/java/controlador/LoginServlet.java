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
            System.out.println("  - Password en BD: " + 
                              (usuario.getPassword() != null && usuario.getPassword().length() > 20 ? 
                               usuario.getPassword().substring(0, 20) + "..." : 
                               (usuario.getPassword() != null ? usuario.getPassword() : "null")));

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
                System.out.println("  - Hash en BD: " + usuario.getPassword());
                System.out.println("  - Hash recibido: " + hashedPasswordFromFrontend);
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
            // 1. Verificar usuario en tabla usuario
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
                out.println("<li>Eliminado: " + usuario.isEliminado() + "</li>");
                out.println("<li>Password (primeros 20): " + 
                           (usuario.getPassword() != null && usuario.getPassword().length() > 20 ? 
                            usuario.getPassword().substring(0, 20) + "..." : usuario.getPassword()) + "</li>");
                out.println("</ul>");
            }
            
            // 2. Verificar persona
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
                        out.println("<li>Activo: " + rs.getBoolean("activo") + "</li>");
                        out.println("</ul>");
                    } else {
                        out.println("<p class='error'>No existe persona con ID: " + usuario.getPersonaId() + "</p>");
                    }
                }
            } else {
                out.println("<p class='error'>Usuario no tiene persona_id válido</p>");
            }
            
            // 3. Verificar profesor
            out.println("<h2>3. Verificando tabla profesor...</h2>");
            if (usuario != null && usuario.getPersonaId() > 0) {
                String profesorSql = "SELECT * FROM profesor WHERE persona_id = ?";
                try (Connection conn = Conexion.getConnection();
                     PreparedStatement ps = conn.prepareStatement(profesorSql)) {
                    ps.setInt(1, usuario.getPersonaId());
                    ResultSet rs = ps.executeQuery();
                    if (rs.next()) {
                        out.println("<p class='success'>✅ Profesor encontrado:</p>");
                        out.println("<ul>");
                        out.println("<li>ID: " + rs.getInt("id") + "</li>");
                        out.println("<li>Especialidad: " + rs.getString("especialidad") + "</li>");
                        out.println("<li>Código: " + rs.getString("codigo_profesor") + "</li>");
                        out.println("<li>Activo: " + rs.getBoolean("activo") + "</li>");
                        out.println("<li>Eliminado: " + rs.getBoolean("eliminado") + "</li>");
                        out.println("</ul>");
                    } else {
                        out.println("<p class='error'>No existe profesor para persona_id: " + usuario.getPersonaId() + "</p>");
                    }
                }
            }
            
            // 4. Usar el método obtenerPorUsername de ProfesorDAO
            out.println("<h2>4. Probando método ProfesorDAO.obtenerPorUsername...</h2>");
            ProfesorDAO profesorDAO = new ProfesorDAO();
            Profesor docente = profesorDAO.obtenerPorUsername(username);
            if (docente == null) {
                out.println("<p class='error'>ProfesorDAO.obtenerPorUsername devolvió null</p>");
            } else {
                out.println("<p class='success'>Profesor obtenido correctamente:</p>");
                out.println("<ul>");
                out.println("<li>Nombre: " + docente.getNombreCompleto() + "</li>");
                out.println("<li>Especialidad: " + docente.getEspecialidad() + "</li>");
                out.println("<li>Email: " + docente.getCorreo() + "</li>");
                out.println("<li>Rol: " + docente.getRol() + "</li>");
                out.println("<li>Username: " + docente.getUsername() + "</li>");
                out.println("</ul>");
            }
            
        } catch (Exception e) {
            out.println("<p class='error'>Error: " + e.getMessage() + "</p>");
            e.printStackTrace();
        }
        
        out.println("<hr>");
        out.println("<h3>Probar otro usuario:</h3>");
        out.println("<form method='get' style='margin-top: 20px;'>");
        out.println("<input type='hidden' name='accion' value='test'>");
        out.println("<input type='text' name='username' placeholder='Nombre de usuario' value='" + username + "'>");
        out.println("<button type='submit'>Probar</button>");
        out.println("</form>");
        
        out.println("</body></html>");
    }

    private void debugPadre(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String username = request.getParameter("username");
        if (username == null) username = "milagroscandela";
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        out.println("<html><head><style>");
        out.println("body { font-family: Arial, sans-serif; margin: 20px; }");
        out.println(".success { color: green; }");
        out.println(".error { color: red; }");
        out.println(".info { color: blue; }");
        out.println(".warning { color: orange; }");
        out.println("</style></head><body>");
        out.println("<h1>DEBUG - Padre/Aprendiz: " + username + "</h1>");
        
        try {
            // 1. Verificar usuario
            out.println("<h2>1. Verificando usuario...</h2>");
            Usuario usuario = usuarioDAO.obtenerPorUsername(username);
            if (usuario == null) {
                out.println("<p class='error'>Usuario no encontrado en tabla usuario</p>");
                return;
            } else {
                out.println("<p class='success'>✅ Usuario encontrado:</p>");
                out.println("<ul>");
                out.println("<li>ID: " + usuario.getId() + "</li>");
                out.println("<li>Persona ID: " + usuario.getPersonaId() + "</li>");
                out.println("<li>Rol: " + usuario.getRol() + "</li>");
                out.println("<li>Activo: " + usuario.isActivo() + "</li>");
                out.println("</ul>");
            }
            
            // 2. Verificar persona
            out.println("<h2>2. Verificando tabla persona...</h2>");
            String personaSql = "SELECT * FROM persona WHERE id = ?";
            try (Connection conn = Conexion.getConnection();
                 PreparedStatement ps = conn.prepareStatement(personaSql)) {
                ps.setInt(1, usuario.getPersonaId());
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    out.println("<p class='success'>✅ Persona encontrada:</p>");
                    out.println("<ul>");
                    out.println("<li>ID: " + rs.getInt("id") + "</li>");
                    out.println("<li>Tipo: <span class='" + ("PADRE".equals(rs.getString("tipo")) ? "success" : "error") + "'>" + rs.getString("tipo") + "</span></li>");
                    out.println("<li>Nombres: " + rs.getString("nombres") + "</li>");
                    out.println("<li>Apellidos: " + rs.getString("apellidos") + "</li>");
                    out.println("<li>DNI: " + rs.getString("dni") + "</li>");
                    out.println("</ul>");
                } else {
                    out.println("<p class='error'>❌ No existe persona con ID: " + usuario.getPersonaId() + "</p>");
                }
            }
            
            // 3. Verificar si existe en relación familiar
            out.println("<h2>3. Verificando relación familiar...</h2>");
            String relacionSql = "SELECT rf.*, a.id as alumno_id, a.codigo_alumno, " +
                                "p_alumno.nombres as alumno_nombres, p_alumno.apellidos as alumno_apellidos " +
                                "FROM relacion_familiar rf " +
                                "LEFT JOIN alumno a ON rf.alumno_id = a.id " +
                                "LEFT JOIN persona p_alumno ON a.persona_id = p_alumno.id " +
                                "WHERE rf.persona_id = ? AND rf.eliminado = 0";
            try (Connection conn = Conexion.getConnection();
                 PreparedStatement ps = conn.prepareStatement(relacionSql)) {
                ps.setInt(1, usuario.getPersonaId());
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    out.println("<p class='success'>✅ Relación familiar encontrada:</p>");
                    out.println("<ul>");
                    out.println("<li>Alumno ID: " + rs.getInt("alumno_id") + "</li>");
                    out.println("<li>Código Alumno: " + rs.getString("codigo_alumno") + "</li>");
                    out.println("<li>Alumno: " + rs.getString("alumno_nombres") + " " + rs.getString("alumno_apellidos") + "</li>");
                    out.println("<li>Parentesco: " + rs.getString("parentesco") + "</li>");
                    out.println("<li>Contacto principal: " + rs.getBoolean("es_contacto_principal") + "</li>");
                    out.println("</ul>");
                } else {
                    out.println("<p class='error'>❌ No tiene relación familiar (no está asociado a ningún alumno)</p>");
                }
            }
            
            // 4. Verificar PadreDAO
            out.println("<h2>4. Probando método PadreDAO.obtenerPorUsername...</h2>");
            PadreDAO padreDAO = new PadreDAO();
            Padre padre = padreDAO.obtenerPorUsername(username);
            if (padre == null) {
                out.println("<p class='error'>PadreDAO.obtenerPorUsername devolvió null</p>");
            } else {
                out.println("<p class='success'>Padre obtenido correctamente:</p>");
                out.println("<ul>");
                out.println("<li>ID: " + padre.getId() + "</li>");
                out.println("<li>Nombre: " + padre.getNombreCompleto() + "</li>");
                out.println("<li>Alumno asociado: " + padre.getAlumnoNombre() + "</li>");
                out.println("<li>Código alumno: " + padre.getAlumnoCodigo() + "</li>");
                out.println("</ul>");
            }
            
        } catch (Exception e) {
            out.println("<p class='error'>Error: " + e.getMessage() + "</p>");
            e.printStackTrace();
        }
        
        out.println("<hr>");
        out.println("<h3>Probar otro usuario:</h3>");
        out.println("<form method='get' style='margin-top: 20px;'>");
        out.println("<input type='hidden' name='accion' value='debugPadre'>");
        out.println("<input type='text' name='username' placeholder='Nombre de usuario' value='" + username + "'>");
        out.println("<button type='submit'>Probar</button>");
        out.println("</form>");
        
        out.println("<hr>");
        out.println("<h3>Soluciones:</h3>");
        out.println("<ol>");
        out.println("<li><strong>Si el tipo de persona no es 'PADRE':</strong><br>");
        out.println("UPDATE persona SET tipo = 'PADRE' WHERE id = [persona_id];</li>");
        out.println("<li><strong>Si no tiene relación familiar:</strong><br>");
        out.println("INSERT INTO relacion_familiar (alumno_id, persona_id, parentesco, es_contacto_principal) VALUES ([alumno_id], [persona_id], 'PADRE', 1);</li>");
        out.println("</ol>");
        
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
            System.err.println("Error verificando bloqueo: " + e.getMessage());
            response.getWriter().write("{\"bloqueado\": true}");
        }
    }

    private void verificarPassword(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
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
            } else {
                modelo.ProfesorDAO profesorDAO = new modelo.ProfesorDAO();
                docente = profesorDAO.obtenerPorUsername(user);
                if (docente != null) {
                    session.setAttribute("docente", docente);
                    java.util.List<modelo.Curso> misCursos = new modelo.CursoDAO().listarPorProfesor(docente.getId());
                    request.setAttribute("misCursos", misCursos);
                    request.getRequestDispatcher("docenteDashboard.jsp").forward(request, response);
                    return;
                }
            }
        } else if ("admin".equalsIgnoreCase(rol)) {
            response.sendRedirect("dashboard.jsp");
            return;
        } else if ("padre".equalsIgnoreCase(rol)) {
            // Verificar si el padre está en sesión
            modelo.Padre padre = (modelo.Padre) session.getAttribute("padre");
            if (padre == null) {
                // Intentar obtenerlo de nuevo
                modelo.PadreDAO padreDAO = new modelo.PadreDAO();
                padre = padreDAO.obtenerPorUsername(user);
                if (padre != null) {
                    session.setAttribute("padre", padre);
                }
            }
            response.sendRedirect("padreDashboard.jsp");
            return;
        }
        response.sendRedirect("index.jsp?error=rol_desconocido");
    }

    private void cerrarSesion(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            String usuario = (String) session.getAttribute("usuario");
            System.out.println("Cerrando sesión: " + usuario);
            session.invalidate();
        }
        response.sendRedirect("index.jsp?mensaje=Sesión cerrada");
    }

    private String determinarRedireccion(String rol, String user, HttpServletRequest request, HttpServletResponse response) throws Exception {
        System.out.println("→ Determinando redirección - Rol: " + rol);

        if ("admin".equalsIgnoreCase(rol)) {
            return "dashboard.jsp";
        }

        if ("docente".equalsIgnoreCase(rol)) {
            ProfesorDAO profesorDAO = new ProfesorDAO();
            Profesor docente = profesorDAO.obtenerPorUsername(user);

            if (docente != null) {
                HttpSession session = request.getSession();
                session.setAttribute("docente", docente);
                System.out.println("  Docente encontrado: " + docente.getNombreCompleto());
                System.out.println("  Profesor ID: " + docente.getId());
                System.out.println("  Persona ID: " + docente.getPersonaId());
                System.out.println("  Especialidad: " + docente.getEspecialidad());
                
                return "DocenteDashboardServlet";
            } else {
                System.out.println(" Docente no encontrado en la base de datos para usuario: " + user);
                
                Usuario usuario = usuarioDAO.obtenerPorUsername(user);
                if (usuario != null) {
                    System.out.println("  Usuario existe:");
                    System.out.println("     - ID: " + usuario.getId());
                    System.out.println("     - Persona ID: " + usuario.getPersonaId());
                    System.out.println("     - Rol: " + usuario.getRol());
                    
                    try (Connection conn = Conexion.getConnection()) {
                        String checkSql = "SELECT COUNT(*) as count FROM profesor WHERE persona_id = ?";
                        try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                            ps.setInt(1, usuario.getPersonaId());
                            ResultSet rs = ps.executeQuery();
                            if (rs.next()) {
                                int count = rs.getInt("count");
                                System.out.println("  Profesores encontrados para persona_id " + usuario.getPersonaId() + ": " + count);
                            }
                        }
                        
                        String detailSql = "SELECT * FROM profesor WHERE persona_id = ?";
                        try (PreparedStatement ps = conn.prepareStatement(detailSql)) {
                            ps.setInt(1, usuario.getPersonaId());
                            ResultSet rs = ps.executeQuery();
                            if (rs.next()) {
                                System.out.println("  Detalles del profesor:");
                                System.out.println("     - ID: " + rs.getInt("id"));
                                System.out.println("     - Activo: " + rs.getBoolean("activo"));
                                System.out.println("     - Eliminado: " + rs.getBoolean("eliminado"));
                                System.out.println("     - Especialidad: " + rs.getString("especialidad"));
                            } else {
                                System.out.println("  No hay registro en la tabla profesor para persona_id: " + usuario.getPersonaId());
                            }
                        }
                    } catch (SQLException e) {
                        System.err.println("  Error al verificar profesor: " + e.getMessage());
                    }
                } else {
                    System.out.println("  Usuario no encontrado en usuarioDAO");
                }
                
                return "index.jsp?error=docente_no_encontrado";
            }
        }

        if ("padre".equalsIgnoreCase(rol)) {
            System.out.println("  Buscando información del padre: " + user);
            
            // Primero obtener el usuario
            Usuario usuario = usuarioDAO.obtenerPorUsername(user);
            if (usuario == null) {
                System.out.println("  Usuario no encontrado en usuarioDAO");
                return "index.jsp?error=usuario_no_encontrado";
            }
            
            System.out.println("  ?Usuario obtenido:");
            System.out.println("     - Persona ID: " + usuario.getPersonaId());
            
            // Verificar si la persona tiene tipo correcto
            try (Connection conn = Conexion.getConnection()) {
                String tipoSql = "SELECT tipo FROM persona WHERE id = ?";
                try (PreparedStatement ps = conn.prepareStatement(tipoSql)) {
                    ps.setInt(1, usuario.getPersonaId());
                    ResultSet rs = ps.executeQuery();
                    if (rs.next()) {
                        String tipoPersona = rs.getString("tipo");
                        System.out.println("   Tipo de persona: " + tipoPersona);
                        
                        if (!"PADRE".equals(tipoPersona)) {
                            System.out.println("  ⚠️ Persona no es de tipo PADRE, es: " + tipoPersona);
                            // Podemos intentar corregirlo automáticamente
                            if ("ALUMNO".equals(tipoPersona)) {
                                System.out.println("  🔄 Intentando corregir tipo de ALUMNO a PADRE...");
                                String updateSql = "UPDATE persona SET tipo = 'PADRE' WHERE id = ?";
                                try (PreparedStatement psUpdate = conn.prepareStatement(updateSql)) {
                                    psUpdate.setInt(1, usuario.getPersonaId());
                                    int updated = psUpdate.executeUpdate();
                                    if (updated > 0) {
                                        System.out.println("  ✅ Tipo corregido a PADRE");
                                    }
                                }
                            }
                        }
                    } else {
                        System.out.println("  No se encontró persona con ID: " + usuario.getPersonaId());
                    }
                }
                
                // Verificar relación familiar
                String relacionSql = "SELECT COUNT(*) as count FROM relacion_familiar WHERE persona_id = ? AND eliminado = 0";
                try (PreparedStatement ps = conn.prepareStatement(relacionSql)) {
                    ps.setInt(1, usuario.getPersonaId());
                    ResultSet rs = ps.executeQuery();
                    if (rs.next()) {
                        int count = rs.getInt("count");
                        System.out.println("   Relaciones familiares encontradas: " + count);
                        
                        if (count == 0) {
                            System.out.println("   No tiene relación familiar, buscando alumno para asociar...");
                            
                            // Buscar un alumno para asociar (podría ser el primer alumno disponible)
                            String alumnoSql = "SELECT id FROM alumno WHERE eliminado = 0 LIMIT 1";
                            try (PreparedStatement psAlumno = conn.prepareStatement(alumnoSql)) {
                                ResultSet rsAlumno = psAlumno.executeQuery();
                                if (rsAlumno.next()) {
                                    int alumnoId = rsAlumno.getInt("id");
                                    System.out.println("   Asociando con alumno ID: " + alumnoId);
                                    
                                    String insertRelacion = "INSERT INTO relacion_familiar (alumno_id, persona_id, parentesco, es_contacto_principal) VALUES (?, ?, 'PADRE', 1)";
                                    try (PreparedStatement psInsert = conn.prepareStatement(insertRelacion)) {
                                        psInsert.setInt(1, alumnoId);
                                        psInsert.setInt(2, usuario.getPersonaId());
                                        int inserted = psInsert.executeUpdate();
                                        if (inserted > 0) {
                                            System.out.println("  ✅ Relación familiar creada");
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } catch (SQLException e) {
                System.err.println("  Error verificando datos del padre: " + e.getMessage());
            }
            
            // Ahora intentar obtener el padre
            PadreDAO padreDAO = new PadreDAO();
            Padre padre = padreDAO.obtenerPorUsername(user);
            
            if (padre != null) {
                HttpSession session = request.getSession();
                session.setAttribute("padre", padre);
                System.out.println("  Padre encontrado: " + padre.getNombreCompleto());
                System.out.println("  Alumno asociado: " + padre.getAlumnoNombre());
                System.out.println("  Código alumno: " + padre.getAlumnoCodigo());
                return "padreDashboard.jsp";
            } else {
                System.out.println("  Padre no encontrado en PadreDAO");
                
                // Crear un objeto padre básico con la información disponible
                try (Connection conn = Conexion.getConnection()) {
                    String personaSql = "SELECT nombres, apellidos FROM persona WHERE id = ?";
                    try (PreparedStatement ps = conn.prepareStatement(personaSql)) {
                        ps.setInt(1, usuario.getPersonaId());
                        ResultSet rs = ps.executeQuery();
                        if (rs.next()) {
                            String nombres = rs.getString("nombres");
                            String apellidos = rs.getString("apellidos");
                            
                            // Crear objeto padre mínimo
                            Padre padreBasico = new Padre();
                            padreBasico.setId(usuario.getPersonaId());
                            padreBasico.setNombres(nombres);
                            padreBasico.setApellidos(apellidos);
                            padreBasico.setUsername(user);
                            
                            HttpSession session = request.getSession();
                            session.setAttribute("padre", padreBasico);
                            System.out.println("  Padre básico creado: " + nombres + " " + apellidos);
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