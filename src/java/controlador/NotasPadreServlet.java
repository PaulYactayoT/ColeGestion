/*
 * SERVLET PARA CONSULTA DE NOTAS DESDE LA VISTA DE PADRES
 * 
 * Funcionalidades: Listar notas del alumno para vista de padres
 * Roles: Padre
 * Integracion: Relacion con alumno, cursos y tareas
 */
package controlador;

import modelo.Nota;
import modelo.NotaDAO;
import modelo.Padre;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

public class NotasPadreServlet extends HttpServlet {

    /**
     * METODO GET - LISTAR NOTAS DEL ALUMNO (VISTA PADRES)
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

        // Obtener notas del alumno desde la base de datos
        NotaDAO dao = new NotaDAO();
        List<Nota> lista = dao.listarPorAlumno(padre.getAlumnoId());
        request.setAttribute("notas", lista);

        // Cargar vista especifica para padres
        request.getRequestDispatcher("notasPadre.jsp").forward(request, response);
    }
}