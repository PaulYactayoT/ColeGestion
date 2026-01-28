/*
 * SERVLET PARA CARGAR EL DASHBOARD ESPECIFICO DE DOCENTES
 * 
 * Funcionalidades: Cargar cursos del docente y redirigir a dashboard
 * Roles: Docente
 * Integracion: Relacion con cursos y profesores
 */
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

@WebServlet("/DocenteDashboardServlet")
public class DocenteDashboardServlet extends HttpServlet {

    /**
     * METODO GET - CARGAR DASHBOARD DEL DOCENTE
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Profesor docente = (Profesor) session.getAttribute("docente");
        
        // Verificar que el usuario este autenticado como docente
        if (docente == null) {
            response.sendRedirect("index.jsp");
            return;
        }
        
        try {
            System.out.println("Cargando cursos para profesor ID: " + docente.getId());
            
            // Cargar los cursos del docente
            CursoDAO cursoDAO = new CursoDAO();
            List<Curso> cursos = cursoDAO.listarPorProfesor(docente.getId());
            
            System.out.println("Cursos encontrados: " + (cursos != null ? cursos.size() : 0));
            
            // Log detallado de cursos
            if (cursos != null) {
                for (Curso curso : cursos) {
                    System.out.println("   - " + curso.getNombre() + " (Grado: " + curso.getGradoNombre() + ")");
                }
            }
            
            // Poner los cursos en el request para que los use el JSP
            request.setAttribute("misCursos", cursos);
            
            // Redirigir al dashboard del docente
            request.getRequestDispatcher("docenteDashboard.jsp").forward(request, response);
            
        } catch (Exception e) {
            System.out.println("Error en DocenteDashboardServlet:");
            e.printStackTrace();
            session.setAttribute("error", "Error al cargar los cursos: " + e.getMessage());
            response.sendRedirect("error.jsp");
        }
    }
}