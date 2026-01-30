package SecurityFilter;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import modelo.*;

/**
 * NUEVO FILTRO: Valida autorización a nivel de recurso
 * Verifica que el usuario autenticado tenga acceso al recurso específico
 */
public class AuthorizationFilter implements Filter {

    public void init(FilterConfig filterConfig) throws ServletException {
    }

    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);
        String requestURI = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();

        if (session == null) {
            chain.doFilter(request, response);
            return;
        }

        String rol = (String) session.getAttribute("rol");
        String username = (String) session.getAttribute("usuario");

        // Validaciones específicas por rol
        
        if ("docente".equals(rol)) {
            if (isDocenteAccessingOthersCourse(httpRequest, session)) {
                System.out.println("[AUTORIZACIÓN] DENEGADA: Docente " + username + 
                    " intentó acceder a curso que no le pertenece");
                httpResponse.sendRedirect(contextPath + "/acceso_denegado.jsp");
                return;
            }
        }

        if ("padre".equals(rol)) {
            if (isPadreAccessingOthersData(httpRequest, session)) {
                System.out.println("[AUTORIZACIÓN] DENEGADA: Padre " + username + 
                    " intentó acceder a datos que no le pertenecen");
                httpResponse.sendRedirect(contextPath + "/acceso_denegado.jsp");
                return;
            }
        }

        chain.doFilter(request, response);
    }

    /**
     * Valida: ¿El docente está intentando acceder a un curso que no le pertenece?
     */
    private boolean isDocenteAccessingOthersCourse(HttpServletRequest request, HttpSession session) {
        Profesor docente = (Profesor) session.getAttribute("docente");
        if (docente == null) return false;

        String cursoIdParam = request.getParameter("curso_id");
        
        if (cursoIdParam == null || cursoIdParam.isEmpty()) {
            return false;
        }

        try {
            int cursoId = Integer.parseInt(cursoIdParam);
            Curso curso = new CursoDAO().obtenerPorId(cursoId);
            
            if (curso != null && curso.getProfesorId() != docente.getId()) {
                System.out.println("[SEGURIDAD] Docente " + docente.getNombres() + 
                    " intentó acceder a curso " + cursoId + " (pertenece a profesor " + curso.getProfesorId() + ")");
                return true;
            }
        } catch (NumberFormatException e) {
            System.out.println("[SEGURIDAD] Formato inválido de curso_id");
        }

        return false;
    }

    /**
     * Valida: ¿El padre está intentando acceder a datos de otro alumno?
     */
    private boolean isPadreAccessingOthersData(HttpServletRequest request, HttpSession session) {
        Padre padre = (Padre) session.getAttribute("padre");
        if (padre == null) return false;

        String alumnoIdParam = request.getParameter("alumno_id");

        if (alumnoIdParam == null || alumnoIdParam.isEmpty()) {
            return false;
        }

        try {
            int alumnoIdSolicitado = Integer.parseInt(alumnoIdParam);
            int alumnoIdDelPadre = padre.getAlumnoId();

            if (alumnoIdSolicitado != alumnoIdDelPadre) {
                System.out.println("[SEGURIDAD] Padre " + padre.getId() + 
                    " intentó acceder a datos del alumno " + alumnoIdSolicitado + 
                    " (su alumno es " + alumnoIdDelPadre + ")");
                return true;
            }
        } catch (NumberFormatException e) {
            System.out.println("[SEGURIDAD] Formato inválido de alumno_id");
        }

        return false;
    }

    public void destroy() {
    }
}
