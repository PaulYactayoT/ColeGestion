package util;

import modelo.*;

/**
 * NUEVA CLASE: Utilidades para validar autorización en Servlets
 */
public class AuthorizationUtil {

    /**
     * Valida que un docente tenga acceso a un curso específico
     */
    public static boolean isDocenteOwnerOfCourse(javax.servlet.http.HttpSession session, int cursoId) {
        Profesor docente = (Profesor) session.getAttribute("docente");
        if (docente == null) return false;

        Curso curso = new CursoDAO().obtenerPorId(cursoId);
        if (curso == null) return false;

        boolean isOwner = curso.getProfesorId() == docente.getId();
        
        if (!isOwner) {
            System.out.println("[AUTORIZACIÓN] Docente " + docente.getId() + 
                " NO es dueño del curso " + cursoId);
        }
        
        return isOwner;
    }

    /**
     * Valida que un padre tenga acceso a datos de su alumno
     */
    public static boolean isPadreOwnerOfAlumno(javax.servlet.http.HttpSession session, int alumnoId) {
        Padre padre = (Padre) session.getAttribute("padre");
        if (padre == null) return false;

        boolean isOwner = padre.getAlumnoId() == alumnoId;
        
        if (!isOwner) {
            System.out.println("[AUTORIZACIÓN] Padre " + padre.getId() + 
                " NO es padre del alumno " + alumnoId);
        }
        
        return isOwner;
    }

    /**
     * Valida que solo ADMIN puede acceder
     */
    public static boolean isAdmin(javax.servlet.http.HttpSession session) {
        String rol = (String) session.getAttribute("rol");
        return "admin".equals(rol);
    }

    /**
     * Valida que sea DOCENTE
     */
    public static boolean isDocente(javax.servlet.http.HttpSession session) {
        String rol = (String) session.getAttribute("rol");
        return "docente".equals(rol);
    }

    /**
     * Valida que sea PADRE
     */
    public static boolean isPadre(javax.servlet.http.HttpSession session) {
        String rol = (String) session.getAttribute("rol");
        return "padre".equals(rol);
    }
}
