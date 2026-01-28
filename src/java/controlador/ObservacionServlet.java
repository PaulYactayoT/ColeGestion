/*
 * SERVLET PARA GESTION DE OBSERVACIONES SOBRE ALUMNOS
 * 
 * Funcionalidades: CRUD completo de observaciones, por curso y alumno
 * Roles: Docente (gestion), Padre (consulta)
 * Integracion: Relacion con cursos, alumnos y profesores
 */
package controlador;

import modelo.Observacion;
import modelo.ObservacionDAO;
import modelo.AlumnoDAO;
import modelo.Curso;
import modelo.CursoDAO;
import modelo.Profesor;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class ObservacionServlet extends HttpServlet {

    // DAO para operaciones con la tabla de observaciones
    ObservacionDAO dao = new ObservacionDAO();

    /**
     * METODO GET - CONSULTAS Y GESTION DE OBSERVACIONES
     * 
     * Acciones soportadas:
     * - listar: Listar observaciones de un curso
     * - registrar: Formulario para crear nueva observacion
     * - editar: Formulario para modificar observacion existente
     * - eliminar: Eliminar observacion
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Profesor docente = (Profesor) session.getAttribute("docente");

        String accion = request.getParameter("accion");
        if (accion == null) {
            accion = "listar"; // Accion por defecto
        }

        try {
            // Obtener ID del curso (parametro obligatorio)
            int cursoId = Integer.parseInt(request.getParameter("curso_id"));
            Curso curso = new CursoDAO().obtenerPorId(cursoId);
            request.setAttribute("curso", curso);

            // Ejecutar accion segun parametro
            switch (accion) {
                case "listar":
                    // Listar observaciones del curso
                    request.setAttribute("lista", dao.listarPorCurso(cursoId));
                    request.getRequestDispatcher("observacionesDocente.jsp").forward(request, response);
                    break;

                case "registrar":
                    // Formulario para nueva observacion
                    request.setAttribute("alumnos", new AlumnoDAO().listarPorGrado(curso.getGradoId()));
                    request.getRequestDispatcher("observacionForm.jsp").forward(request, response);
                    break;

                case "editar":
                    // Formulario para editar observacion existente
                    int idEditar = Integer.parseInt(request.getParameter("id"));
                    Observacion obs = dao.obtenerPorId(idEditar);
                    request.setAttribute("observacion", obs);
                    request.setAttribute("alumnos", new AlumnoDAO().listarPorGrado(curso.getGradoId()));
                    request.getRequestDispatcher("observacionForm.jsp").forward(request, response);
                    break;

                case "eliminar":
                    // Eliminar observacion
                    int idEliminar = Integer.parseInt(request.getParameter("id"));
                    dao.eliminar(idEliminar);
                    response.sendRedirect("ObservacionServlet?accion=listar&curso_id=" + cursoId);
                    break;

                default:
                    // Redireccion por defecto
                    response.sendRedirect("docenteDashboard.jsp");
            }

        } catch (Exception e) {
            // Manejo de errores
            e.printStackTrace();
            response.sendRedirect("docenteDashboard.jsp");
        }
    }

    /**
     * METODO POST - CREAR Y ACTUALIZAR OBSERVACIONES
     * 
     * Maneja el envio de formularios para crear nuevas observaciones
     * y actualizar observaciones existentes
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Determinar si es creacion (id=0) o actualizacion (id>0)
        int id = request.getParameter("id") != null && !request.getParameter("id").isEmpty()
                ? Integer.parseInt(request.getParameter("id")) : 0;

        // Construir objeto observacion con datos del formulario
        Observacion o = new Observacion();
        o.setCursoId(Integer.parseInt(request.getParameter("curso_id")));
        o.setAlumnoId(Integer.parseInt(request.getParameter("alumno_id")));
        o.setTexto(request.getParameter("texto"));

        // Ejecutar operacion en base de datos
        boolean resultado;
        if (id == 0) {
            resultado = dao.agregar(o); // Nueva observacion
            System.out.println("Nueva observacion creada para alumno ID: " + o.getAlumnoId());
        } else {
            o.setId(id);
            resultado = dao.actualizar(o); // Actualizar observacion
            System.out.println("Observacion actualizada (ID: " + id + ")");
        }

        // Redirigir a la lista de observaciones del curso
        response.sendRedirect("ObservacionServlet?accion=listar&curso_id=" + o.getCursoId());
    }
}