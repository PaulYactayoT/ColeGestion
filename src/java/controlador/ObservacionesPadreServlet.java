/*
 * SERVLET PARA CONSULTA DE OBSERVACIONES DESDE LA VISTA DE PADRES
 * 
 * Funcionalidades: Listar observaciones del alumno para vista de padres
 * Roles: Padre
 * Integracion: Relacion con alumno y cursos
 */
package controlador;

import modelo.Observacion;
import modelo.ObservacionDAO;
import modelo.Padre;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

public class ObservacionesPadreServlet extends HttpServlet {

    /**
     * METODO GET - LISTAR OBSERVACIONES DEL ALUMNO (VISTA PADRES)
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

        // Obtener observaciones del alumno desde la base de datos
        ObservacionDAO dao = new ObservacionDAO();
        List<Observacion> lista = dao.listarPorAlumno(padre.getAlumnoId());
        request.setAttribute("observaciones", lista);

        // Cargar vista especifica para padres
        request.getRequestDispatcher("observacionesPadre.jsp").forward(request, response);
    }
}