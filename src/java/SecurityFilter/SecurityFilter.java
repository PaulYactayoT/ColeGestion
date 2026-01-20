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

        HttpSession session = httpRequest.getSession(false);
        String requestURI = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();

        System.out.println("SecurityFilter: Processing URI: " + requestURI);

        // Excluir páginas públicas y recursos estáticos del filtro
        if (isPublicResource(requestURI)) {
            chain.doFilter(request, response);
            return;
        }

        // Si no hay sesión, redirigir al login
        if (session == null || session.getAttribute("usuario") == null) {
            System.out.println("SecurityFilter: No session, redirecting to login");
            httpResponse.sendRedirect(contextPath + "/login.jsp");
            return;
        }

        String rol = (String) session.getAttribute("rol");

        if (rol == null) {
            System.out.println("SecurityFilter: No role found, redirecting to login");
            httpResponse.sendRedirect(contextPath + "/login.jsp");
            return;
        }

        System.out.println("SecurityFilter: User role: " + rol + ", URI: " + requestURI);

        // MEJORA: Agregar headers de seguridad
        httpResponse.setHeader("X-Frame-Options", "DENY");
        httpResponse.setHeader("X-Content-Type-Options", "nosniff");
        httpResponse.setHeader("X-XSS-Protection", "1; mode=block");

        // Verificar permisos según el rol
        boolean accessGranted = checkAccess(rol, requestURI, httpRequest);

        if (!accessGranted) {
            System.out.println("SecurityFilter: Access DENIED for role: " + rol + " to: " + requestURI);
            httpResponse.sendRedirect(contextPath + "/acceso_denegado.jsp");
            return;
        }

        System.out.println("SecurityFilter: Access GRANTED for role: " + rol + " to: " + requestURI);
        chain.doFilter(request, response);
    }

    /**
     * VERIFICAR SI ES UN RECURSO PÚBLICO
     */
    private boolean isPublicResource(String requestURI) {
        return requestURI.endsWith("login.jsp")
                || requestURI.endsWith("index.jsp")
                || requestURI.contains("/LoginServlet")
                || requestURI.endsWith("acceso_denegado.jsp")
                || requestURI.contains("/css/")
                || requestURI.contains("/js/")
                || requestURI.contains("/images/")
                || requestURI.contains("/assets/")
                || requestURI.matches(".*\\.(css|js|png|jpg|jpeg|gif|ico|woff|woff2|ttf|eot|svg)$");
    }

    /**
     * VERIFICAR ACCESO SEGÚN ROL
     */
    private boolean checkAccess(String rol, String requestURI, HttpServletRequest request) {
        System.out.println("SecurityFilter: Checking access for role " + rol + " to " + requestURI);

        switch (rol) {
            case "admin":
                return hasAdminAccess(requestURI);
            case "docente":
                return hasDocenteAccess(requestURI);
            case "padre":
                return hasPadreAccess(requestURI);
            default:
                return false;
        }
    }

    /**
     * PERMISOS PARA ADMIN - ACCESO COMPLETO
     */
    private boolean hasAdminAccess(String requestURI) {
        // Admin tiene acceso completo a todo
        return true;
    }

    /**
     * PERMISOS PARA DOCENTE
     */
    private boolean hasDocenteAccess(String requestURI) {
        // URLs PERMITIDAS para docente
        boolean isAllowed = requestURI.contains("/docente/")
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
                || requestURI.contains("/TareaServlet")
                || requestURI.contains("/ObservacionServlet")
                || requestURI.contains("/JustificacionServlet")
                || requestURI.contains("/NotaServlet")
                || requestURI.contains("/AlumnoServlet"); // SOLO para obtenerPorCurso (AJAX)

        // URLs BLOQUEADAS para docente
        boolean isBlocked = requestURI.contains("/admin/")
                || requestURI.contains("/usuarios.jsp")
                || requestURI.contains("/usuarioForm.jsp")
                || requestURI.contains("/cursos.jsp")
                || requestURI.contains("/cursoForm.jsp")
                || requestURI.contains("/profesores.jsp")
                || requestURI.contains("/profesorForm.jsp")
                || requestURI.contains("/alumnos.jsp")
                || requestURI.contains("/alumnoForm.jsp")
                || requestURI.contains("/dashboard.jsp")
                || requestURI.contains("/CursoServlet")
                || requestURI.contains("/ProfesorServlet")
                || requestURI.contains("/UsuarioServlet")
                || requestURI.contains("/GradoServlet");

        return isAllowed && !isBlocked;
    }

    /**
     * PERMISOS PARA PADRE
     */
    private boolean hasPadreAccess(String requestURI) {
        // URLs PERMITIDAS para padre
        boolean isAllowed = requestURI.contains("/padre/")
                || requestURI.contains("/justificacionesPadre.jsp")
                || requestURI.contains("/albumPadre.jsp")
                || requestURI.contains("/asistenciasPadre.jsp")
                || requestURI.contains("/justificarAusencia.jsp")
                || requestURI.contains("/notasPadre.jsp")
                || requestURI.contains("/observacionesPadre.jsp")
                || requestURI.contains("/tareaPadre.jsp")
                || requestURI.contains("/uploadImage.jsp")
                || requestURI.contains("/padreDashboard.jsp")
                || requestURI.contains("/JustificacionServlet")
                || requestURI.contains("/NotasPadreServlet")
                || requestURI.contains("/ObservacionesPadreServlet")
                || requestURI.contains("/TareasPadreServlet")
                || requestURI.contains("/AsistenciaServlet"); // Para ver asistencias de su hijo

        // URLs BLOQUEADAS para padre
        boolean isBlocked = requestURI.contains("/admin/")
                || requestURI.contains("/docente/")
                || requestURI.contains("/usuarios.jsp")
                || requestURI.contains("/cursos.jsp")
                || requestURI.contains("/profesores.jsp")
                || requestURI.contains("/alumnos.jsp")
                || requestURI.contains("/dashboard.jsp")
                || requestURI.contains("/docenteDashboard.jsp")
                || requestURI.contains("/asistenciasDocente.jsp")
                || requestURI.contains("/notasDocente.jsp")
                || requestURI.contains("/observacionesDocente.jsp")
                || requestURI.contains("/tareaDocente.jsp")
                || requestURI.contains("/CursoServlet")
                || requestURI.contains("/ProfesorServlet")
                || requestURI.contains("/UsuarioServlet")
                || requestURI.contains("/AlumnoServlet")
                || requestURI.contains("/NotaServlet")
                || requestURI.contains("/TareaServlet")
                || requestURI.contains("/ObservacionServlet")
                || requestURI.contains("/GradoServlet");

        return isAllowed && !isBlocked;
    }

    public void destroy() {
    }
}