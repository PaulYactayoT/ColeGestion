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
    
    System.out.println("SecurityFilter: Processing URI: " + requestURI);

    // 🔥 DETECTAR PETICIONES AJAX/JSON
    String requestedWith = httpRequest.getHeader("X-Requested-With");
    String acceptHeader = httpRequest.getHeader("Accept");
    
    boolean isAjax = "XMLHttpRequest".equals(requestedWith) || 
                     (acceptHeader != null && acceptHeader.contains("application/json"));
    
    if (isAjax) {
        System.out.println("📱 AJAX Request detected - URI: " + requestURI);
    }

    // Excluir páginas públicas y recursos estáticos
    if (isPublicResource(requestURI)) {
        chain.doFilter(request, response);
        return;
    }

    HttpSession session = httpRequest.getSession(false);

    // Verificar sesión
    if (session == null || session.getAttribute("usuario") == null) {
        System.out.println("SecurityFilter: No session");
        if (isAjax) {
            // Para AJAX, devolver JSON con error 401
            httpResponse.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            httpResponse.setContentType("application/json;charset=UTF-8");
            httpResponse.getWriter().write("{\"exito\":false,\"mensaje\":\"Sesión no válida\"}");
            return;
        } else {
            httpResponse.sendRedirect(contextPath + "/login.jsp");
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
            httpResponse.sendRedirect(contextPath + "/login.jsp");
            return;
        }
    }

    System.out.println("SecurityFilter: User role: " + rol + ", URI: " + requestURI);

    // Agregar headers de seguridad SOLO para respuestas HTML
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
    
    // IMPORTANTE: No modificar headers para AJAX
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
            case "administrativo":
                return hasAdministrativoAccess(requestURI);
            default:
                return false;
        }
    }

    /**
     * PERMISOS PARA ADMIN - ACCESO COMPLETO
     */
    private boolean hasAdminAccess(String requestURI) {
    // Admin tiene acceso completo a todo
    // Pero podemos ser explícitos para debug
    if (requestURI.contains("ModuloServlet")) {
        System.out.println("SecurityFilter: Admin access to ModuloServlet GRANTED");
    }
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
                || requestURI.contains("/AlumnoServlet") // SOLO para obtenerPorCurso (AJAX)
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

        // URLs BLOQUEADAS para docente
        boolean isBlocked = requestURI.contains("/admin/")
                || requestURI.contains("/usuarios.jsp")
                || requestURI.contains("/usuarioForm.jsp")
                || requestURI.contains("/dashboard.jsp")
                || requestURI.contains("/UsuarioServlet");

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
                || requestURI.contains("/CursoServlet")
                || requestURI.contains("/ProfesorServlet")
                || requestURI.contains("/UsuarioServlet")
                || requestURI.contains("/GradoServlet")
                || requestURI.contains("/AdministrativoServlet")
                || requestURI.contains("/ModuloServlet")
                || requestURI.contains("/AdminDisponibilidadServlet")
                || requestURI.contains("/RegistroCursoServlet");

        return isAllowed && !isBlocked;
    }

    /**
     * PERMISOS PARA ADMINISTRATIVO
     * Acceso a gestión general + módulos de docente y padre que le asignen
     */
    private boolean hasAdministrativoAccess(String requestURI) {
        // Puede acceder a todo lo que puede docente y padre
        // más las páginas administrativas
        boolean isAllowed =
                // Dashboard administrativo
                requestURI.contains("/administrativoDashboard")
                // Gestión (mismos que admin)
                || requestURI.contains("/AlumnoServlet")
                || requestURI.contains("/ProfesorServlet")
                || requestURI.contains("/CursoServlet")
                || requestURI.contains("/GradoServlet")
                || requestURI.contains("/UsuarioServlet")
                || requestURI.contains("/AdministrativoServlet")
                || requestURI.contains("/ModuloServlet")
                || requestURI.contains("/AdminDisponibilidadServlet")
                // Módulos de docente
                || requestURI.contains("/AsistenciaServlet")
                || requestURI.contains("/JustificacionServlet")
                || requestURI.contains("/MaterialServlet")
                || requestURI.contains("/DisponibilidadServlet")
                || requestURI.contains("/NotaServlet")
                || requestURI.contains("/TareaServlet")
                || requestURI.contains("/ObservacionServlet")
                || requestURI.contains("/revisarJustificaciones.jsp")
                // JSPs de padre
                || requestURI.contains("/notasPadre.jsp")
                || requestURI.contains("/observacionesPadre.jsp")
                || requestURI.contains("/albumPadre.jsp")
                || requestURI.contains("/asistenciasPadre.jsp")
                || requestURI.contains("/tareasPadre.jsp")
                || requestURI.contains("/MaterialPadreServlet")
                // JSPs generales admin
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
                || requestURI.contains("/gestionModulos.jsp");

        // Bloqueado: solo el admin puro puede hacer esto
        boolean isBlocked = requestURI.endsWith("/dashboard.jsp");

        return isAllowed && !isBlocked;
    }

    public void destroy() {
    }
}