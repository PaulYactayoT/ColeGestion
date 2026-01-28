/*
 * SERVLET PARA CONSULTA DE ALUMNOS POR GRADO (VISTA PUBLICA/ADMIN)
 * 
 * Funcionalidades: Listar alumnos con filtro por grado
 * Roles: Admin, Docente (posiblemente)
 * Integracion: Relacion con grados
 */
package controlador;

import modelo.Alumno;
import modelo.AlumnoDAO;
import modelo.Grado;
import modelo.GradoDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/VerAlumnosServlet")
public class VerAlumnosServlet extends HttpServlet {

    // DAO para operaciones con alumnos y grados
    AlumnoDAO alumnoDAO = new AlumnoDAO();
    GradoDAO gradoDAO = new GradoDAO();

    /**
     * METODO GET - LISTAR ALUMNOS CON FILTRO POR GRADO
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Obtener parametro de filtro (opcional)
        String gradoIdParam = request.getParameter("grado");

        // Cargar lista de grados para el formulario
        List<Grado> grados = gradoDAO.listar();
        request.setAttribute("grados", grados);

        // Aplicar filtro si se especifico un grado
        if (gradoIdParam != null && !gradoIdParam.isEmpty()) {
            int gradoId = Integer.parseInt(gradoIdParam);
            List<Alumno> alumnos = alumnoDAO.listarPorGrado(gradoId);
            request.setAttribute("alumnos", alumnos);
            request.setAttribute("gradoSeleccionado", gradoId);
        }

        // Cargar vista de lista de alumnos
        request.getRequestDispatcher("verAlumnos.jsp").forward(request, response);
    }
}