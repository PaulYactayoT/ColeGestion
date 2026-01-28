package controlador;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import modelo.Padre;
import modelo.PadreDAO;

@WebServlet("/SeleccionarAlumnoServlet")
public class SeleccionarAlumnoServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Padre padre = (Padre) session.getAttribute("padre");
        
        if (padre == null) {
            response.sendRedirect("index.jsp");
            return;
        }
        
        // Obtener todos los hijos del padre
        PadreDAO padreDAO = new PadreDAO();
        List<Map<String, Object>> hijos = padreDAO.obtenerHijosPorPadre(padre.getId());
        
        if (hijos.size() == 1) {
            // Si solo tiene un hijo, seleccionarlo automáticamente
            Map<String, Object> hijo = hijos.get(0);
            padre.setAlumnoId((Integer) hijo.get("alumno_id"));
            padre.setAlumnoCodigo((String) hijo.get("codigo_alumno"));
            padre.setAlumnoNombre((String) hijo.get("alumno_nombre"));
            padre.setGradoNombre((String) hijo.get("grado_nombre"));
            
            session.setAttribute("padre", padre);
            response.sendRedirect("padreDashboard.jsp");
            
        } else if (hijos.size() > 1) {
            // Si tiene múltiples hijos, mostrar selección
            request.setAttribute("hijos", hijos);
            request.getRequestDispatcher("seleccionarAlumno.jsp").forward(request, response);
            
        } else {
            // No tiene hijos asociados
            request.setAttribute("error", "No tiene alumnos asociados");
            request.getRequestDispatcher("padreDashboard.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Padre padre = (Padre) session.getAttribute("padre");
        
        if (padre == null) {
            response.sendRedirect("index.jsp");
            return;
        }
        
        String alumnoIdStr = request.getParameter("alumno_id");
        
        if (alumnoIdStr != null && !alumnoIdStr.isEmpty()) {
            try {
                int alumnoId = Integer.parseInt(alumnoIdStr);
                
                // Buscar información del alumno seleccionado
                PadreDAO padreDAO = new PadreDAO();
                List<Map<String, Object>> hijos = padreDAO.obtenerHijosPorPadre(padre.getId());
                
                for (Map<String, Object> hijo : hijos) {
                    if ((Integer) hijo.get("alumno_id") == alumnoId) {
                        padre.setAlumnoId(alumnoId);
                        padre.setAlumnoCodigo((String) hijo.get("codigo_alumno"));
                        padre.setAlumnoNombre((String) hijo.get("alumno_nombre"));
                        padre.setGradoNombre((String) hijo.get("grado_nombre"));
                        break;
                    }
                }
                
                session.setAttribute("padre", padre);
                session.setAttribute("mensaje", "Alumno seleccionado correctamente");
                
            } catch (NumberFormatException e) {
                session.setAttribute("error", "ID de alumno inválido");
            }
        }
        
        response.sendRedirect("padreDashboard.jsp");
    }
}