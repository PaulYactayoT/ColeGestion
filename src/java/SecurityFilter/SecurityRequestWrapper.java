package SecurityFilter;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletRequestWrapper;
import javax.servlet.http.HttpSession;

public class SecurityRequestWrapper extends HttpServletRequestWrapper {
    private final HttpSession session;

    public SecurityRequestWrapper(HttpServletRequest request, HttpSession session) {
        super(request);
        this.session = session;
    }

    @Override
    public String getParameter(String name) {
        String value = super.getParameter(name);
        
        // Validar parámetros sensibles en tiempo real
        if (("curso_id".equals(name) || "id".equals(name)) && value != null) {
            if (!validateOwnership(name, value)) {
                throw new SecurityException("Acceso no autorizado al recurso: " + name + "=" + value);
            }
        }
        
        if ("alumno_id".equals(name) && value != null) {
            if (!validateAlumnoOwnership(value)) {
                throw new SecurityException("Acceso no autorizado al alumno: " + value);
            }
        }
        
        return value;
    }

    private boolean validateOwnership(String paramName, String paramValue) {
        String rol = (String) session.getAttribute("rol");
        
        try {
            if (("curso_id".equals(paramName) || "id".equals(paramName)) && "docente".equals(rol)) {
                int cursoId = Integer.parseInt(paramValue);
                Object docenteObj = session.getAttribute("docente");
                
                // Usar reflexión para evitar dependencia directa
                if (docenteObj != null) {
                    try {
                        java.lang.reflect.Method getIdMethod = docenteObj.getClass().getMethod("getId");
                        Integer docenteId = (Integer) getIdMethod.invoke(docenteObj);
                        
                        // Verificar asignación curso-profesor
                        return isCursoAssignedToProfesor(cursoId, docenteId);
                    } catch (Exception e) {
                        System.out.println("Error en validación de ownership: " + e.getMessage());
                        return false;
                    }
                }
            }
        } catch (NumberFormatException e) {
            return false;
        }
        
        return true; // Admin y otros casos
    }

    private boolean validateAlumnoOwnership(String alumnoIdValue) {
        String rol = (String) session.getAttribute("rol");
        
        try {
            if ("padre".equals(rol)) {
                int alumnoId = Integer.parseInt(alumnoIdValue);
                Object padreObj = session.getAttribute("padre");
                
                if (padreObj != null) {
                    try {
                        java.lang.reflect.Method getAlumnoIdMethod = padreObj.getClass().getMethod("getAlumnoId");
                        Integer padreAlumnoId = (Integer) getAlumnoIdMethod.invoke(padreObj);
                        
                        return padreAlumnoId != null && padreAlumnoId == alumnoId;
                    } catch (Exception e) {
                        System.out.println("Error en validación de alumno ownership: " + e.getMessage());
                        return false;
                    }
                }
            }
        } catch (NumberFormatException e) {
            return false;
        }
        
        return true; // Admin y docente pueden acceder
    }

    private boolean isCursoAssignedToProfesor(int cursoId, int profesorId) {
        // Consulta directa a la base de datos para evitar dependencias
        String sql = "SELECT COUNT(*) as count FROM cursos WHERE id = ? AND profesor_id = ?";
        
        try (java.sql.Connection con = conexion.Conexion.getConnection();
             java.sql.PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, cursoId);
            ps.setInt(2, profesorId);
            java.sql.ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("count") > 0;
            }
            
        } catch (Exception e) {
            System.out.println("Error al verificar asignación curso-profesor: " + e.getMessage());
        }
        
        return false;
    }
}