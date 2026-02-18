package controlador;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import modelo.Profesor;
import modelo.Curso;
import modelo.CursoDAO;
import modelo.MaterialDAO; 

@WebServlet("/DocenteDashboardServlet")
public class DocenteDashboardServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Profesor docente = (Profesor) session.getAttribute("docente");
        
        if (docente == null) {
            System.out.println("❌ ERROR: No hay docente en sesión");
            response.sendRedirect("index.jsp");
            return;
        }
        
        try {
            System.out.println("✅ Docente encontrado:");
            System.out.println("   - Profesor ID: " + docente.getId());
            System.out.println("   - Persona ID: " + docente.getPersonaId());
            System.out.println("   - Nombre: " + docente.getNombres() + " " + docente.getApellidos());
            
            // 🔥 CRÍTICO: Establecer personaId en sesión
            if (session.getAttribute("personaId") == null) {
                System.out.println("⚠️ ESTABLECIENDO personaId en sesión");
                session.setAttribute("personaId", docente.getPersonaId());
            }
            
            if (session.getAttribute("nombres") == null) {
                session.setAttribute("nombres", docente.getNombres());
            }
            if (session.getAttribute("apellidos") == null) {
                session.setAttribute("apellidos", docente.getApellidos());
            }
            if (session.getAttribute("rol") == null) {
                session.setAttribute("rol", "docente");
            }
            
            System.out.println("📋 Cargando cursos para profesor ID: " + docente.getId());
            
            CursoDAO cursoDAO = new CursoDAO();
            List<Curso> cursos = cursoDAO.listarPorProfesor(docente.getId());
            
            System.out.println("✅ Cursos encontrados: " + (cursos != null ? cursos.size() : 0));
            
            if (cursos != null && !cursos.isEmpty()) {
                for (Curso curso : cursos) {
                    System.out.println("   - " + curso.getNombre() + " (Grado: " + curso.getGradoNombre() + ")");
                }
            }
            
            request.setAttribute("misCursos", cursos);

            // =================================================================
            // INICIO CÓDIGO NUEVO: Obtener conteo de materiales
            // =================================================================
            MaterialDAO materialDAO = new MaterialDAO();
            int totalMateriales = materialDAO.contarMaterialesPorDocente(docente.getId());
            request.setAttribute("totalMateriales", totalMateriales);
            System.out.println("✅ Total materiales cargados para dashboard: " + totalMateriales);
            // =================================================================
            // FIN CÓDIGO NUEVO
            // =================================================================
            
            System.out.println("📊 Estado de sesión:");
            System.out.println("   - personaId: " + session.getAttribute("personaId"));
            System.out.println("   - rol: " + session.getAttribute("rol"));
            System.out.println("   - docente: " + (session.getAttribute("docente") != null ? "OK" : "NULL"));
            
            request.getRequestDispatcher("docenteDashboard.jsp").forward(request, response);
            
        } catch (Exception e) {
            System.out.println("❌ ERROR: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("error", "Error al cargar los cursos: " + e.getMessage());
            response.sendRedirect("error.jsp");
        }
    }
}