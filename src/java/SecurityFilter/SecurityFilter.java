package SecurityFilter;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;

public class SecurityFilter implements Filter {

    public void init(FilterConfig filterConfig) throws ServletException {
    }

    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
        throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String requestURI = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();

        System.out.println("@@@@@@@@@@@@@@@@@@@@@@");
        System.out.println("@@ SECURITY FILTER @@");
        System.out.println("@@ URI: " + requestURI);
        System.out.println("@@@@@@@@@@@@@@@@@@@@@@");
        System.out.println("SecurityFilter: Processing URI: " + requestURI);

        // Capturar Referer para depuración (útil para rastrear de dónde vienen peticiones inesperadas)
        String referer = httpRequest.getHeader("Referer");
        if (referer != null) {
            System.out.println("SecurityFilter: Referer: " + referer);
        }

        // Detectar peticiones AJAX/JSON
        String requestedWith = httpRequest.getHeader("X-Requested-With");
        String acceptHeader  = httpRequest.getHeader("Accept");
        boolean isAjax = "XMLHttpRequest".equals(requestedWith)
                || (acceptHeader != null && acceptHeader.contains("application/json"));

        if (isAjax) {
            System.out.println("AJAX Request detected - URI: " + requestURI);
        }

        // Excluir páginas públicas y recursos estáticos
        if (isPublicResource(requestURI)) {
            chain.doFilter(request, response);
            return;
        }

        // Excluir FORWARDS internos (servlet → JSP): ya fueron validados antes
        if (httpRequest.getAttribute("javax.servlet.forward.request_uri") != null) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = httpRequest.getSession(false);

        // Verificar sesión
        if (session == null || session.getAttribute("usuario") == null) {
            System.out.println("SecurityFilter: No session");
            if (isAjax) {
                httpResponse.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                httpResponse.setContentType("application/json;charset=UTF-8");
                httpResponse.getWriter().write("{\"exito\":false,\"mensaje\":\"Sesión no válida\"}");
                return;
            } else {
                httpResponse.sendRedirect(contextPath + "/index.jsp");
                return;
            }
        }

        String rol = (String) session.getAttribute("rol");

        if (rol == null) {
            System.out.println("SecurityFilter: No role found");
            if (isAjax) {
                httpResponse.setStatus(HttpServletResponse.SC_FORBIDDEN);
                httpResponse.setContentType("application/json;charset=UTF-8");
                httpResponse.getWriter().write("{\"exito\":false,\"mensaje\":\"Rol no encontrado\"}");
                return;
            } else {
                httpResponse.sendRedirect(contextPath + "/index.jsp");
                return;
            }
        }

        System.out.println("SecurityFilter: User role: " + rol + ", URI: " + requestURI);

        // Headers de seguridad solo para respuestas HTML
        if (!isAjax && !requestURI.contains("ModuloServlet")) {
            httpResponse.setHeader("X-Frame-Options", "DENY");
            httpResponse.setHeader("X-Content-Type-Options", "nosniff");
            httpResponse.setHeader("X-XSS-Protection", "1; mode=block");
        }

        // Verificar permisos según el rol
        boolean accessGranted = checkAccess(rol, requestURI, httpRequest);

        if (!accessGranted) {
            System.out.println("SecurityFilter: Access DENIED for role: " + rol + " to: " + requestURI);
            if (isAjax) {
                httpResponse.setStatus(HttpServletResponse.SC_FORBIDDEN);
                httpResponse.setContentType("application/json;charset=UTF-8");
                httpResponse.getWriter().write("{\"exito\":false,\"mensaje\":\"Acceso denegado\"}");
                return;
            } else {
                httpResponse.sendRedirect(contextPath + "/acceso_denegado.jsp");
                return;
            }
        }

        System.out.println("SecurityFilter: Access GRANTED for role: " + rol + " to: " + requestURI);
        chain.doFilter(request, response);
    }

    // =========================================================================
    // RECURSOS PÚBLICOS
    // =========================================================================

    private boolean isPublicResource(String requestURI) {
        return requestURI.endsWith("/")
                || requestURI.endsWith("login.jsp")
                || requestURI.endsWith("index.jsp")
                || requestURI.contains("/LoginServlet")
                || requestURI.endsWith("acceso_denegado.jsp")
                || requestURI.contains("/css/")
                || requestURI.contains("/js/")
                || requestURI.contains("/images/")
                || requestURI.contains("/assets/")
                || requestURI.contains("/materiales/")   // ← archivos de material de apoyo
                || requestURI.matches(".*\\.(css|js|png|jpg|jpeg|gif|ico|woff|woff2|ttf|eot|svg|pdf|docx|doc|pptx|xlsx)$");
    }

    // =========================================================================
    // VERIFICACIÓN DE ACCESO CENTRAL
    // =========================================================================

    private boolean checkAccess(String rol, String requestURI, HttpServletRequest request) {
        System.out.println("SecurityFilter: Checking access for role " + rol + " to " + requestURI);

        // Admin: acceso total
        if ("admin".equals(rol)) return true;

        // Recursos comunes a todos los roles autenticados
        if (requestURI.contains("/LogoutServlet"))                        return true;
        if (requestURI.contains("/uploads/") || requestURI.contains("/includes/")) return true;

        // ─────────────────────────────────────────────────────────────────────
        // BLOQUEO EXPLÍCITO: páginas exclusivas de padre
        // Ningún otro rol (docente, administrativo) puede acceder a ellas.
        // ─────────────────────────────────────────────────────────────────────
        boolean esPaginaExclusivaPadre =
                requestURI.contains("/albumPadre.jsp")
                || requestURI.contains("/observacionesPadre.jsp")
                || requestURI.contains("/asistenciasPadre.jsp")
                || requestURI.contains("/notasPadre.jsp")
                || requestURI.contains("/justificacionesPadre.jsp")
                || requestURI.contains("/tareasPadre.jsp")
                || requestURI.contains("/tareaPadre.jsp")
                || requestURI.contains("/padreDashboard.jsp")
                || requestURI.contains("/uploadImage.jsp")
                || requestURI.contains("/justificarAusencia.jsp")
                || requestURI.contains("/detalleTarea.jsp")
                || requestURI.contains("/ObservacionesPadreServlet")
                || requestURI.contains("/NotasPadreServlet")
                || requestURI.contains("/TareasPadreServlet")
                || requestURI.contains("/MaterialPadreServlet")
                || requestURI.contains("/EntregaServlet")
                || requestURI.contains("/ExportServlet")
                || requestURI.contains("/DescargarServlet");

        if (esPaginaExclusivaPadre && !"padre".equals(rol)) {
            System.out.println("[SEGURIDAD] Rol '" + rol + "' intentó acceder a página exclusiva de padre: " + requestURI);
            return false;
        }

        // ─────────────────────────────────────────────────────────────────────
        // BLOQUEO EXPLÍCITO: páginas exclusivas de docente
        // El padre no puede acceder a ellas.
        // ─────────────────────────────────────────────────────────────────────
        boolean esPaginaExclusivaDocente =
                requestURI.contains("/docenteDashboard")
                || requestURI.contains("/asistenciasDocente.jsp")
                || requestURI.contains("/notasDocente.jsp")
                || requestURI.contains("/observacionesDocente.jsp")
                || requestURI.contains("/tareaDocente.jsp")
                || requestURI.contains("/registrarAsistencia.jsp")
                || requestURI.contains("/justificacionesPendientes.jsp")
                || requestURI.contains("/revisarJustificaciones.jsp")
                || requestURI.contains("/reporteAsistencia.jsp")
                || requestURI.contains("/verAlumnos.jsp")
                || requestURI.contains("/asistenciasCurso.jsp")
                || requestURI.contains("/materialApoyo.jsp")
                || requestURI.contains("/materialSeleccionCurso.jsp")
                || requestURI.contains("/notaForm.jsp")
                || requestURI.contains("/tareaForm.jsp");

        if (esPaginaExclusivaDocente && "padre".equals(rol)) {
            System.out.println("[SEGURIDAD] Padre intentó acceder a página exclusiva de docente: " + requestURI);
            return false;
        }

        // ─────────────────────────────────────────────────────────────────────
        // DASHBOARDS por rol
        // ─────────────────────────────────────────────────────────────────────
        if ("docente".equals(rol) && (requestURI.contains("DocenteDashboardServlet") || requestURI.contains("docenteDashboard"))) return true;
        if ("padre".equals(rol)   && (requestURI.contains("padreDashboard") || requestURI.contains("PadreDashboardServlet")))    return true;
        if ("administrativo".equals(rol) && requestURI.contains("administrativoDashboard"))                                      return true;

        // ─────────────────────────────────────────────────────────────────────
        // DOCENTE: disponibilidad propia → NO pasa por hasModuleAccess de admin
        // FIX PRINCIPAL: antes esta línea mezclaba disponibilidadDocente.jsp
        // con AdminDisponibilidadServlet, bloqueando al docente.
        // ─────────────────────────────────────────────────────────────────────
        if ("docente".equals(rol) && requestURI.contains("/disponibilidadDocente.jsp")) {
            return true; // El docente siempre puede ver su propia disponibilidad
        }
        if ("docente".equals(rol) && requestURI.contains("/DisponibilidadServlet")) {
            return true; // Servlet de disponibilidad del docente
        }
        // revisarJustificaciones.jsp se protege con el módulo "JustificacionServlet" de la BD
        // así solo docentes que tengan ese módulo asignado pueden acceder
        if ("docente".equals(rol) && requestURI.contains("/revisarJustificaciones.jsp")) {
            return hasModuleAccess("JustificacionServlet", request);
        }

        // PADRE: AsistenciaServlet es llamado internamente por asistenciasPadre.jsp (filtros).
        // Se valida contra el módulo "asistenciasPadre.jsp" que el padre sí tiene en BD.
        if ("padre".equals(rol) && requestURI.contains("/AsistenciaServlet")) {
            return hasModuleAccess("asistenciasPadre.jsp", request);
        }

        // ─────────────────────────────────────────────────────────────────────
        // PÁGINAS QUE REQUIEREN MÓDULO ASIGNADO EN BD
        // Solo admin/administrativo pasan por aquí; docente y padre ya fueron
        // manejados arriba o caerán en sus métodos específicos abajo.
        // ─────────────────────────────────────────────────────────────────────
        if (requestURI.contains("/RegistroCursoServlet") || requestURI.contains("/registroCurso.jsp")) {
            return hasModuleAccess("CursoServlet", request);
        }
        if (requestURI.contains("/cursos.jsp") || requestURI.contains("/cursoForm.jsp")) {
            return hasModuleAccess("CursoServlet", request);
        }
        if (requestURI.contains("/alumnos.jsp") || requestURI.contains("/alumnoForm.jsp") || requestURI.contains("/alumnoDetalle.jsp")) {
            return hasModuleAccess("AlumnoServlet", request);
        }
        if (requestURI.contains("/profesores.jsp") || requestURI.contains("/profesorForm.jsp")) {
            return hasModuleAccess("ProfesorServlet", request);
        }
        if (requestURI.contains("/grados.jsp") || requestURI.contains("/gradoForm.jsp")) {
            return hasModuleAccess("GradoServlet", request);
        }
        if (requestURI.contains("/usuarios.jsp") || requestURI.contains("/usuarioForm.jsp")) {
            return hasModuleAccess("UsuarioServlet", request);
        }
        if (requestURI.contains("/gestionModulos.jsp")) {
            return hasModuleAccess("ModuloServlet", request);
        }
        // gestion_disponibilidad.jsp es del panel admin — AdminDisponibilidadServlet
        if (requestURI.contains("/gestion_disponibilidad.jsp")) {
            return hasModuleAccess("AdminDisponibilidadServlet", request);
        }
        // ─────────────────────────────────────────────────────────────────────
        // FALLBACK POR ROL
        // ─────────────────────────────────────────────────────────────────────
        return hasModuleAccess(requestURI, request);
    }

    // =========================================================================
    // VALIDACIÓN POR MÓDULOS EN BD
    // =========================================================================

    private boolean hasModuleAccess(String requestURI, HttpServletRequest request) {
        HttpSession sess = request.getSession(false);
        if (sess == null) return false;

        Object uidObj = sess.getAttribute("usuarioId");
        if (uidObj == null) {
            System.out.println("SecurityFilter: ERROR - usuarioId NULL en sesión. URI: " + requestURI);
            return false;
        }

        int usuarioId;
        try {
            usuarioId = Integer.parseInt(uidObj.toString());
        } catch (NumberFormatException e) {
            return false;
        }

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
                if (modUrl != null && !modUrl.isEmpty()) {
                    String modBase = modUrl.split("\\?")[0].trim();
                    if (!modBase.isEmpty() && requestURI.contains(modBase)) {
                        System.out.println("SecurityFilter: GRANTED via módulo [" + modBase + "]");
                        return true;
                    }
                }
            }

        } catch (Exception e) {
            System.err.println("SecurityFilter: Error BD: " + e.getMessage());
            String r = (String) sess.getAttribute("rol");
            if ("docente".equals(r))        return hasDocenteAccess(requestURI);
            if ("padre".equals(r))          return hasPadreAccess(requestURI);
            if ("administrativo".equals(r)) return hasAdministrativoAccess(requestURI);
        }

        System.out.println("SecurityFilter: ===== DENIED FINAL =====");
        System.out.println("SecurityFilter: URL bloqueada: " + requestURI);
        System.out.println("SecurityFilter: usuarioId: " + usuarioId);
        return false;
    }

    // =========================================================================
    // PERMISOS ESTÁTICOS POR ROL (fallback cuando no se usan módulos en BD)
    // =========================================================================

    private boolean hasDocenteAccess(String requestURI) {
        boolean isAllowed =
                requestURI.contains("/docente/")
                || requestURI.contains("/asistenciasDocente.jsp")
                || requestURI.contains("/docenteDashboard.jsp")
                || requestURI.contains("/justificacionesPendientes.jsp")
                || requestURI.contains("/notasDocente.jsp")
                || requestURI.contains("/notaForm.jsp")
                || requestURI.contains("/observacionesDocente.jsp")
                || requestURI.contains("/registrarAsistencia.jsp")
                || requestURI.contains("/reporteAsistencia.jsp")
                || requestURI.contains("/tareaForm.jsp")
                || requestURI.contains("/tareaDocente.jsp")
                || requestURI.contains("/verAlumnos.jsp")
                || requestURI.contains("/asistenciasCurso.jsp")
                || requestURI.contains("/AsistenciaServlet")
                || requestURI.contains("/MaterialServlet")
                || requestURI.contains("/materialApoyo.jsp")
                || requestURI.contains("/materialSeleccionCurso.jsp")
                || requestURI.contains("/DisponibilidadServlet")       // ← Servlet del docente
                || requestURI.contains("/disponibilidadDocente.jsp")   // ← JSP del docente
                || requestURI.contains("/TareaServlet")
                || requestURI.contains("/ObservacionServlet")
                || requestURI.contains("/JustificacionServlet")
                || requestURI.contains("/revisarJustificaciones.jsp")
                || requestURI.contains("/NotaServlet")
                || requestURI.contains("/AlumnoServlet")
                || requestURI.contains("/CursoServlet")
                || requestURI.contains("/ProfesorServlet")
                || requestURI.contains("/GradoServlet")
                || requestURI.contains("/cursos.jsp")
                || requestURI.contains("/cursoForm.jsp")
                || requestURI.contains("/profesores.jsp")
                || requestURI.contains("/profesorForm.jsp")
                || requestURI.contains("/alumnos.jsp")
                || requestURI.contains("/alumnoForm.jsp")
                || requestURI.contains("/alumnoDetalle.jsp");

        boolean isBlocked =
                requestURI.contains("/admin/")
                || requestURI.contains("/usuarios.jsp")
                || requestURI.contains("/usuarioForm.jsp")
                || requestURI.contains("/dashboard.jsp")
                || requestURI.contains("/UsuarioServlet")
                // Bloquear explícitamente páginas de padre
                || requestURI.contains("/albumPadre.jsp")
                || requestURI.contains("/observacionesPadre.jsp")
                || requestURI.contains("/asistenciasPadre.jsp")
                || requestURI.contains("/notasPadre.jsp")
                || requestURI.contains("/tareasPadre.jsp")
                || requestURI.contains("/padreDashboard.jsp")
                // Bloquear gestión admin de disponibilidad
                || requestURI.contains("/AdminDisponibilidadServlet")
                || requestURI.contains("/gestion_disponibilidad.jsp");

        return isAllowed && !isBlocked;
    }

    private boolean hasPadreAccess(String requestURI) {
        boolean isAllowed =
                requestURI.contains("/padre/")
                || requestURI.contains("/justificacionesPadre.jsp")
                || requestURI.contains("/albumPadre.jsp")
                || requestURI.contains("/asistenciasPadre.jsp")
                || requestURI.contains("/justificarAusencia.jsp")
                || requestURI.contains("/notasPadre.jsp")
                || requestURI.contains("/observacionesPadre.jsp")
                || requestURI.contains("/tareaPadre.jsp")
                || requestURI.contains("/tareasPadre.jsp")
                || requestURI.contains("/detalleTarea.jsp")
                || requestURI.contains("/MaterialPadreServlet")
                || requestURI.contains("/LogoutServlet")
                || requestURI.contains("/uploadImage.jsp")
                || requestURI.contains("/padreDashboard.jsp")
                || requestURI.contains("/JustificacionServlet")
                || requestURI.contains("/NotasPadreServlet")
                || requestURI.contains("/ObservacionesPadreServlet")
                || requestURI.contains("/TareasPadreServlet")
                || requestURI.contains("/EntregaServlet")
                || requestURI.contains("/ExportServlet")
                || requestURI.contains("/AsistenciaServlet")
                || requestURI.contains("/DescargarServlet")
                || requestURI.contains("/ImagenServlet")             // ← Álbum de fotos
                || requestURI.contains("/UploadImageServlet")        // ← Subir fotos al álbum
                || requestURI.contains("/DescargarMaterialServlet"); // ← Descargar material de apoyo

        boolean isBlocked =
                requestURI.contains("/admin/")
                || requestURI.contains("/docente/")
                || requestURI.contains("/usuarios.jsp")
                || requestURI.contains("/cursos.jsp")
                || requestURI.contains("/cursoForm.jsp")
                || requestURI.contains("/profesores.jsp")
                || requestURI.contains("/profesorForm.jsp")
                || requestURI.contains("/alumnos.jsp")
                || requestURI.contains("/alumnoForm.jsp")
                || requestURI.contains("/grados.jsp")
                || requestURI.contains("/gradoForm.jsp")
                || requestURI.endsWith("/dashboard.jsp")
                || requestURI.contains("/docenteDashboard.jsp")
                || requestURI.contains("/asistenciasDocente.jsp")
                || requestURI.contains("/notasDocente.jsp")
                || requestURI.contains("/observacionesDocente.jsp")
                || requestURI.contains("/tareaDocente.jsp")
                || requestURI.contains("/disponibilidadDocente.jsp")
                || requestURI.contains("/CursoServlet")
                || requestURI.contains("/ProfesorServlet")
                || requestURI.contains("/UsuarioServlet")
                || requestURI.contains("/GradoServlet")
                || requestURI.contains("/AdministrativoServlet")
                || requestURI.contains("/ModuloServlet")
                || requestURI.contains("/AdminDisponibilidadServlet")
                || requestURI.contains("/DisponibilidadServlet")
                || requestURI.contains("/RegistroCursoServlet");

        return isAllowed && !isBlocked;
    }

    private boolean hasAdministrativoAccess(String requestURI) {
        boolean isAllowed =
                requestURI.contains("/administrativoDashboard")
                || requestURI.contains("/AlumnoServlet")
                || requestURI.contains("/ProfesorServlet")
                || requestURI.contains("/CursoServlet")
                || requestURI.contains("/GradoServlet")
                || requestURI.contains("/UsuarioServlet")
                || requestURI.contains("/AdministrativoServlet")
                || requestURI.contains("/ModuloServlet")
                || requestURI.contains("/AdminDisponibilidadServlet")
                || requestURI.contains("/AsistenciaServlet")
                || requestURI.contains("/JustificacionServlet")
                || requestURI.contains("/MaterialServlet")
                || requestURI.contains("/DisponibilidadServlet")
                || requestURI.contains("/NotaServlet")
                || requestURI.contains("/TareaServlet")
                || requestURI.contains("/ObservacionServlet")
                || requestURI.contains("/revisarJustificaciones.jsp")
                || requestURI.contains("/notasPadre.jsp")
                || requestURI.contains("/observacionesPadre.jsp")
                || requestURI.contains("/albumPadre.jsp")
                || requestURI.contains("/asistenciasPadre.jsp")
                || requestURI.contains("/tareasPadre.jsp")
                || requestURI.contains("/MaterialPadreServlet")
                || requestURI.contains("/alumnos.jsp")
                || requestURI.contains("/alumnoForm.jsp")
                || requestURI.contains("/alumnoDetalle.jsp")
                || requestURI.contains("/profesores.jsp")
                || requestURI.contains("/profesorForm.jsp")
                || requestURI.contains("/cursos.jsp")
                || requestURI.contains("/cursoForm.jsp")
                || requestURI.contains("/grados.jsp")
                || requestURI.contains("/gradoForm.jsp")
                || requestURI.contains("/usuarios.jsp")
                || requestURI.contains("/usuarioForm.jsp")
                || requestURI.contains("/gestionModulos.jsp")
                || requestURI.contains("/gestion_disponibilidad.jsp");

        boolean isBlocked = requestURI.endsWith("/dashboard.jsp");

        return isAllowed && !isBlocked;
    }

    private boolean hasAdminAccess(String requestURI) {
        return true;
    }

    public void destroy() {
    }
}