/*
 * SERVLET PARA CONSULTA DE TAREAS DESDE LA VISTA DE PADRES
 * 
 * Funcionalidades: Listar tareas del alumno para vista de padres
 * Roles: Padre
 * Integracion: Relacion con alumno y cursos
 */
package controlador;

import modelo.Tarea;
import modelo.TareaDAO;
import modelo.Padre;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

public class TareasPadreServlet extends HttpServlet {

    /**
     * METODO GET - LISTAR TAREAS DEL ALUMNO (VISTA PADRES)
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Padre padre = (Padre) session.getAttribute("padre");

        // Verificar autenticacion y datos de padre
        if (padre == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        // Obtener tareas del alumno desde la base de datos
        TareaDAO dao = new TareaDAO();
        List<Tarea> lista = dao.listarPorAlumno(padre.getAlumnoId());
        request.setAttribute("tareas", lista);

        // Cargar vista especifica para padres
        request.getRequestDispatcher("tareasPadre.jsp").forward(request, response);
    }
}