/*
 * SERVLET PARA GESTION DE TAREAS Y ACTIVIDADES ACADEMICAS
 * 
 * Funcionalidades: CRUD completo de tareas, asignacion por curso, fechas de entrega
 * Roles: Docente (gestion completa), Padre (consulta de tareas de su hijo)
 * Integracion: Relacion con cursos, alumnos y calificaciones
 */
package controlador;

import modelo.Tarea;
import modelo.TareaDAO;
import modelo.Curso;
import modelo.CursoDAO;
import modelo.Profesor;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;

public class TareaServlet extends HttpServlet {

    // DAO para operaciones con la tabla de tareas
    TareaDAO dao = new TareaDAO();

    /**
     * METODO GET - CONSULTAS Y GESTION DE TAREAS
     * 
     * Acciones soportadas:
     * - ver: Listar tareas de un curso especifico
     * - registrar: Formulario para crear nueva tarea
     * - editar: Formulario para modificar tarea existente
     * - eliminar: Eliminar tarea del sistema
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String accion = request.getParameter("accion");
        HttpSession session = request.getSession();
        Profesor docente = (Profesor) session.getAttribute("docente");

        try {
            // Obtener ID del curso (parametro obligatorio para la mayoria de acciones)
            int cursoId = Integer.parseInt(request.getParameter("curso_id"));
            Curso curso = new CursoDAO().obtenerPorId(cursoId);
            request.setAttribute("curso", curso);

            // Ejecutar accion segun parametro
            if ("ver".equals(accion)) {
                // Listar todas las tareas del curso
                request.setAttribute("lista", dao.listarPorCurso(cursoId));
                request.getRequestDispatcher("tareasDocente.jsp").forward(request, response);
                return;
            }

            if ("registrar".equals(accion)) {
                // Mostrar formulario para nueva tarea
                request.getRequestDispatcher("tareaForm.jsp").forward(request, response);
                return;
            }

            if ("editar".equals(accion)) {
                // Cargar formulario de edicion de tarea
                int id = Integer.parseInt(request.getParameter("id"));
                Tarea tarea = dao.obtenerPorId(id);
                curso = new CursoDAO().obtenerPorId(tarea.getCursoId());
                request.setAttribute("tarea", tarea);
                request.setAttribute("curso", curso);
                request.getRequestDispatcher("tareaForm.jsp").forward(request, response);
                return;
            }

            if ("eliminar".equals(accion)) {
                // Eliminar tarea del sistema
                int id = Integer.parseInt(request.getParameter("id"));
                dao.eliminar(id);
                response.sendRedirect("TareaServlet?accion=ver&curso_id=" + cursoId);
                return;
            }

            // Fallback: si no hay accion especifica, listar tareas
            request.setAttribute("lista", dao.listarPorCurso(cursoId));
            request.getRequestDispatcher("tareasDocente.jsp").forward(request, response);

        } catch (Exception e) {
            // Manejo de errores - redirigir al dashboard
            e.printStackTrace();
            response.sendRedirect("docenteDashboard.jsp");
        }
    }

    /**
     * METODO POST - CREAR Y ACTUALIZAR TAREAS
     * 
     * Maneja el envio de formularios para crear nuevas tareas
     * y actualizar tareas existentes
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Determinar si es creacion (id=0) o actualizacion (id>0)
        int id = request.getParameter("id") != null && !request.getParameter("id").isEmpty()
                ? Integer.parseInt(request.getParameter("id")) : 0;

        // Construir objeto tarea con datos del formulario
        Tarea t = new Tarea();
        t.setNombre(request.getParameter("nombre"));
        t.setDescripcion(request.getParameter("descripcion"));
        t.setFechaEntrega(request.getParameter("fecha_entrega"));
        t.setActivo(Boolean.parseBoolean(request.getParameter("activo")));
        t.setCursoId(Integer.parseInt(request.getParameter("curso_id")));

        // Ejecutar operacion en base de datos
        boolean resultado;
        if (id == 0) {
            resultado = dao.agregar(t); // Crear nueva tarea
            System.out.println("Nueva tarea creada: " + t.getNombre() + " (Curso: " + t.getCursoId() + ")");
        } else {
            t.setId(id);
            resultado = dao.actualizar(t); // Actualizar tarea existente
            System.out.println("Tarea actualizada: " + t.getNombre() + " (ID: " + id + ")");
        }

        // Redirigir a la lista de tareas del curso
        response.sendRedirect("TareaServlet?curso_id=" + t.getCursoId());
    }
}