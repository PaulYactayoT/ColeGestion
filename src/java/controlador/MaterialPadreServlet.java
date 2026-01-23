package controlador;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import modelo.Material;
import modelo.MaterialDAO;
import modelo.Curso;
import modelo.CursoDAO;
import modelo.Padre;
import modelo.AlumnoDAO;
import modelo.Alumno;

@WebServlet("/MaterialPadreServlet")
public class MaterialPadreServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Padre padre = (Padre) session.getAttribute("padre");
        
        // Validar sesión de padre
        if (padre == null) {
            response.sendRedirect("index.jsp");
            return;
        }
        
        String accion = request.getParameter("accion");
        
        try {
            if (accion == null || accion.isEmpty()) {
                accion = "seleccionarCurso";
            }
            
            switch (accion) {
                case "seleccionarCurso":
                    mostrarCursosDelAlumno(request, response, padre);
                    break;
                case "verMateriales":
                    mostrarMaterialesPorCurso(request, response, padre);
                    break;
                default:
                    mostrarCursosDelAlumno(request, response, padre);
                    break;
            }
        } catch (Exception e) {
            System.err.println("❌ ERROR en MaterialPadreServlet: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("error", "Error al cargar materiales: " + e.getMessage());
            response.sendRedirect("padreDashboard.jsp");
        }
    }
    
    /**
     * MOSTRAR CURSOS DEL ALUMNO (hijo del padre)
     */
    private void mostrarCursosDelAlumno(HttpServletRequest request, HttpServletResponse response,
                                        Padre padre) throws ServletException, IOException {
        
        int alumnoId = padre.getAlumnoId();
        
        System.out.println("🔍 DEBUG: Alumno ID del padre: " + alumnoId);
        
        // Obtener información del alumno
        AlumnoDAO alumnoDAO = new AlumnoDAO();
        Alumno alumno = alumnoDAO.obtenerPorId(alumnoId);
        
        if (alumno == null) {
            request.setAttribute("error", "No se pudo obtener la información del alumno");
            request.getRequestDispatcher("materialPadreSeleccion.jsp").forward(request, response);
            return;
        }
        
        String alumnoNombre = alumno.getNombres() + " " + alumno.getApellidos();
        int gradoId = alumno.getGradoId();
        
        System.out.println("👨‍🎓 DEBUG: Alumno: " + alumnoNombre + ", Grado ID: " + gradoId);
        
        // Obtener cursos del grado del alumno usando el método listarPorGrado
        CursoDAO cursoDAO = new CursoDAO();
        List<Curso> cursosDelAlumno = cursoDAO.listarPorGrado(gradoId);
        
        System.out.println("📚 DEBUG: Cursos encontrados: " + (cursosDelAlumno != null ? cursosDelAlumno.size() : 0));
        
        // Contar materiales por curso
        MaterialDAO materialDAO = new MaterialDAO();
        Map<Integer, Integer> contadorMateriales = new HashMap<>();
        
        if (cursosDelAlumno != null && !cursosDelAlumno.isEmpty()) {
            for (Curso curso : cursosDelAlumno) {
                int cantidad = materialDAO.contarPorCurso(curso.getId());
                contadorMateriales.put(curso.getId(), cantidad);
                System.out.println("📄 Curso: " + curso.getNombre() + " - Materiales: " + cantidad);
            }
        }
        
        request.setAttribute("cursos", cursosDelAlumno);
        request.setAttribute("contadorMateriales", contadorMateriales);
        request.setAttribute("alumnoNombre", alumnoNombre);
        
        request.getRequestDispatcher("materialPadreSeleccion.jsp").forward(request, response);
    }
    
    /**
     * MOSTRAR MATERIALES DE UN CURSO ESPECÍFICO
     */
    private void mostrarMaterialesPorCurso(HttpServletRequest request, HttpServletResponse response,
                                          Padre padre) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String cursoIdStr = request.getParameter("curso_id");
        
        if (cursoIdStr == null || cursoIdStr.isEmpty()) {
            session.setAttribute("error", "Debe seleccionar un curso");
            response.sendRedirect("MaterialPadreServlet?accion=seleccionarCurso");
            return;
        }
        
        try {
            int cursoId = Integer.parseInt(cursoIdStr);
            int alumnoId = padre.getAlumnoId();
            
            // Obtener información del alumno
            AlumnoDAO alumnoDAO = new AlumnoDAO();
            Alumno alumno = alumnoDAO.obtenerPorId(alumnoId);
            
            if (alumno == null) {
                session.setAttribute("error", "No se pudo obtener la información del alumno");
                response.sendRedirect("MaterialPadreServlet?accion=seleccionarCurso");
                return;
            }
            
            String alumnoNombre = alumno.getNombres() + " " + alumno.getApellidos();
            int gradoId = alumno.getGradoId();
            
            // Obtener el curso seleccionado
            CursoDAO cursoDAO = new CursoDAO();
            Curso cursoSeleccionado = null;
            
            // Primero obtener todos los cursos del grado
            List<Curso> cursosDelGrado = cursoDAO.listarPorGrado(gradoId);
            
            // Buscar el curso específico
            for (Curso c : cursosDelGrado) {
                if (c.getId() == cursoId) {
                    cursoSeleccionado = c;
                    break;
                }
            }
            
            if (cursoSeleccionado == null) {
                session.setAttribute("error", "No tiene permiso para ver materiales de este curso");
                response.sendRedirect("MaterialPadreServlet?accion=seleccionarCurso");
                return;
            }
            
            // Obtener materiales del curso
            MaterialDAO materialDAO = new MaterialDAO();
            List<Material> materiales = materialDAO.listarPorCurso(cursoId);
            
            System.out.println("📚 Materiales del curso " + cursoSeleccionado.getNombre() + ": " + materiales.size());
            
            request.setAttribute("curso", cursoSeleccionado);
            request.setAttribute("materiales", materiales);
            request.setAttribute("alumnoNombre", alumnoNombre);
            
            request.getRequestDispatcher("materialPadreVista.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            session.setAttribute("error", "ID de curso inválido");
            response.sendRedirect("MaterialPadreServlet?accion=seleccionarCurso");
        } catch (Exception e) {
            System.err.println("❌ ERROR en mostrarMaterialesPorCurso: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("error", "Error al cargar materiales: " + e.getMessage());
            response.sendRedirect("MaterialPadreServlet?accion=seleccionarCurso");
        }
    }
}