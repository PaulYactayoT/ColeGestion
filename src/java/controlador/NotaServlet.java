/*
 * SERVLET PARA GESTION DE CALIFICACIONES ACADEMICAS
 * 
 * Funcionalidades: CRUD completo de notas, registro por tarea y alumno
 * Roles: Docente (gestion completa), Padre (consulta de notas de su hijo)
 * Integracion: Relacion con tareas, alumnos, cursos y profesores
 * 
 * VERSIÓN FINAL CORREGIDA
 */
package controlador;

import modelo.Nota;
import modelo.NotaDAO;
import modelo.TareaDAO;
import modelo.AlumnoDAO;
import modelo.Curso;
import modelo.CursoDAO;
import modelo.Profesor;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/NotaServlet")
public class NotaServlet extends HttpServlet {

    // DAO para operaciones con la tabla de notas
    private final NotaDAO dao = new NotaDAO();
    private final CursoDAO cursoDAO = new CursoDAO();
    private final TareaDAO tareaDAO = new TareaDAO();
    private final AlumnoDAO alumnoDAO = new AlumnoDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String rol = (String) session.getAttribute("rol");
        String accion = request.getParameter("accion");
        
        System.out.println("NotaServlet - Acción: " + accion + ", Rol: " + rol);

        // Validar rol
        if (rol == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int cursoId = 0;
        
        try {
            String cursoIdParam = request.getParameter("curso_id");
            if (cursoIdParam == null || cursoIdParam.isEmpty()) {
                throw new NumberFormatException("curso_id no proporcionado");
            }
            cursoId = Integer.parseInt(cursoIdParam);
        } catch (NumberFormatException e) {
            System.out.println("ERROR: curso_id inválido: " + e.getMessage());
            session.setAttribute("error", "ID de curso inválido");
            
            if ("docente".equals(rol)) {
                response.sendRedirect("docenteDashboard.jsp");
            } else {
                response.sendRedirect("padreDashboard.jsp");
            }
            return;
        }

        // Validar que el curso exista
        Curso curso = cursoDAO.obtenerPorId(cursoId);
        if (curso == null) {
            System.out.println("ERROR: Curso no encontrado con ID: " + cursoId);
            session.setAttribute("error", "Curso no encontrado");
            response.sendRedirect("docenteDashboard.jsp");
            return;
        }

        // VALIDACIÓN DE PERMISOS: Docente solo puede ver sus cursos
        if ("docente".equals(rol)) {
            Profesor docente = (Profesor) session.getAttribute("docente");
            if (docente == null || curso.getProfesorId() != docente.getId()) {
                System.out.println("ACCESO DENEGADO: Docente " + 
                    (docente != null ? docente.getId() : "null") + 
                    " intentó acceder a curso " + cursoId);
                session.setAttribute("error", "No tienes permisos para acceder a este curso");
                response.sendRedirect("acceso_denegado.jsp");
                return;
            }
        }

        request.setAttribute("curso", curso);

        // Acción por defecto: listar
        if (accion == null) {
            accion = "listar";
        }

        switch (accion) {
            case "listar":
                listarNotas(request, response, cursoId);
                break;

            case "nuevo":
                mostrarFormularioNuevo(request, response, session, rol, cursoId);
                break;

            case "editar":
                mostrarFormularioEditar(request, response, session, rol, cursoId);
                break;

            case "eliminar":
                eliminarNota(request, response, session, rol, cursoId);
                break;

            default:
                System.out.println("ADVERTENCIA: Acción desconocida: " + accion);
                response.sendRedirect("NotaServlet?curso_id=" + cursoId);
        }
    }

    /**
     * LISTAR NOTAS DEL CURSO
     */
    private void listarNotas(HttpServletRequest request, HttpServletResponse response, int cursoId)
            throws ServletException, IOException {
        
        List<Nota> listaNotas = dao.listarPorCurso(cursoId);
        request.setAttribute("lista", listaNotas);
        
        // Calcular estadísticas manualmente
        if (listaNotas != null && !listaNotas.isEmpty()) {
            double suma = 0;
            double notaMaxima = listaNotas.get(0).getNota();
            double notaMinima = listaNotas.get(0).getNota();
            int aprobados = 0;
            
            for (Nota notaObj : listaNotas) {
                double valorNota = notaObj.getNota();
                suma += valorNota;
                
                if (valorNota > notaMaxima) notaMaxima = valorNota;
                if (valorNota < notaMinima) notaMinima = valorNota;
                if (valorNota >= 11) aprobados++;
            }
            
            double promedio = suma / listaNotas.size();
            
            request.setAttribute("promedio", String.format("%.2f", promedio));
            request.setAttribute("notaMaxima", String.format("%.2f", notaMaxima));
            request.setAttribute("notaMinima", String.format("%.2f", notaMinima));
            request.setAttribute("totalNotas", listaNotas.size());
            request.setAttribute("aprobados", aprobados);
            request.setAttribute("desaprobados", listaNotas.size() - aprobados);
        }
        
        request.getRequestDispatcher("notasDocente.jsp").forward(request, response);
    }

    /**
     * MOSTRAR FORMULARIO PARA NUEVA NOTA
     */
    private void mostrarFormularioNuevo(HttpServletRequest request, HttpServletResponse response,
                                       HttpSession session, String rol, int cursoId)
            throws ServletException, IOException {
        
        if (!"docente".equals(rol)) {
            response.sendRedirect("acceso_denegado.jsp");
            return;
        }
        
        request.setAttribute("tareas", tareaDAO.listarPorCurso(cursoId));
        request.setAttribute("alumnos", alumnoDAO.obtenerAlumnosPorCurso(cursoId));
        request.getRequestDispatcher("notaForm.jsp").forward(request, response);
    }

    /**
     * MOSTRAR FORMULARIO PARA EDITAR NOTA
     */
    private void mostrarFormularioEditar(HttpServletRequest request, HttpServletResponse response,
                                        HttpSession session, String rol, int cursoId)
            throws ServletException, IOException {
        
        if (!"docente".equals(rol)) {
            response.sendRedirect("acceso_denegado.jsp");
            return;
        }
        
        try {
            int idEditar = Integer.parseInt(request.getParameter("id"));
            Nota notaEditar = dao.obtenerPorId(idEditar);
            
            if (notaEditar == null) {
                System.out.println("ERROR: Nota no encontrada con ID: " + idEditar);
                session.setAttribute("error", "Nota no encontrada");
                response.sendRedirect("NotaServlet?curso_id=" + cursoId);
                return;
            }
            
            request.setAttribute("nota", notaEditar);
            request.setAttribute("tareas", tareaDAO.listarPorCurso(cursoId));
            request.setAttribute("alumnos", alumnoDAO.obtenerAlumnosPorCurso(cursoId));
            request.getRequestDispatcher("notaForm.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            System.out.println("ERROR: ID de nota inválido");
            session.setAttribute("error", "ID de nota inválido");
            response.sendRedirect("NotaServlet?curso_id=" + cursoId);
        }
    }

    /**
     * ELIMINAR NOTA
     */
    private void eliminarNota(HttpServletRequest request, HttpServletResponse response,
                             HttpSession session, String rol, int cursoId)
            throws IOException {
        
        if (!"docente".equals(rol)) {
            response.sendRedirect("acceso_denegado.jsp");
            return;
        }
        
        try {
            int idEliminar = Integer.parseInt(request.getParameter("id"));
            boolean resultado = dao.eliminar(idEliminar);
            
            if (resultado) {
                System.out.println("Nota eliminada exitosamente: ID " + idEliminar);
                session.setAttribute("mensaje", "Nota eliminada correctamente");
            } else {
                System.out.println("ERROR: No se pudo eliminar la nota " + idEliminar);
                session.setAttribute("error", "Error al eliminar la nota");
            }
            
        } catch (NumberFormatException e) {
            System.out.println("ERROR: ID de nota inválido para eliminar");
            session.setAttribute("error", "ID de nota inválido");
        }
        
        response.sendRedirect("NotaServlet?curso_id=" + cursoId);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String rol = (String) session.getAttribute("rol");

        if (!"docente".equals(rol)) {
            System.out.println("ACCESO DENEGADO POST: Rol " + rol + " intentó modificar notas");
            response.sendRedirect("acceso_denegado.jsp");
            return;
        }

        int cursoId;
        try {
            cursoId = Integer.parseInt(request.getParameter("curso_id"));
        } catch (NumberFormatException e) {
            System.out.println("ERROR: curso_id inválido en POST");
            session.setAttribute("error", "ID de curso inválido");
            response.sendRedirect("docenteDashboard.jsp");
            return;
        }

        // Validar que el curso pertenezca al docente
        Curso curso = cursoDAO.obtenerPorId(cursoId);
        Profesor docente = (Profesor) session.getAttribute("docente");
        
        if (curso == null || docente == null || curso.getProfesorId() != docente.getId()) {
            System.out.println("ACCESO DENEGADO: Docente intentó modificar nota de curso no asignado");
            response.sendRedirect("acceso_denegado.jsp");
            return;
        }

        // Determinar si es creacion o actualizacion
        int id = 0;
        String idParam = request.getParameter("id");
        if (idParam != null && !idParam.isEmpty()) {
            try {
                id = Integer.parseInt(idParam);
            } catch (NumberFormatException e) {
                System.out.println("ERROR: ID de nota inválido");
            }
        }

        // Construir objeto nota con validaciones
        Nota n = new Nota();
        
        try {
            String tareaIdStr = request.getParameter("tarea_id");
            if (tareaIdStr == null || tareaIdStr.isEmpty()) {
                throw new IllegalArgumentException("Debe seleccionar una tarea");
            }
            n.setTareaId(Integer.parseInt(tareaIdStr));

            String alumnoIdStr = request.getParameter("alumno_id");
            if (alumnoIdStr == null || alumnoIdStr.isEmpty()) {
                throw new IllegalArgumentException("Debe seleccionar un alumno");
            }
            n.setAlumnoId(Integer.parseInt(alumnoIdStr));

            String notaStr = request.getParameter("nota");
            if (notaStr == null || notaStr.trim().isEmpty()) {
                throw new IllegalArgumentException("La nota no puede estar vacía");
            }
            
            double nota = Double.parseDouble(notaStr.trim());
            
            if (nota < 0 || nota > 20) {
                throw new IllegalArgumentException("La nota debe estar entre 0 y 20");
            }
            
            n.setNota(nota);

        } catch (NumberFormatException e) {
            System.out.println("ERROR: Formato numérico inválido");
            session.setAttribute("error", "Datos inválidos. Verifica los campos numéricos.");
            response.sendRedirect("NotaServlet?accion=" + (id == 0 ? "nuevo" : "editar&id=" + id) + 
                                "&curso_id=" + cursoId);
            return;
        } catch (IllegalArgumentException e) {
            System.out.println("ERROR: " + e.getMessage());
            session.setAttribute("error", e.getMessage());
            response.sendRedirect("NotaServlet?accion=" + (id == 0 ? "nuevo" : "editar&id=" + id) + 
                                "&curso_id=" + cursoId);
            return;
        }

        boolean resultado;
        if (id == 0) {
            // Verificar duplicados
            List<Nota> notasExistentes = dao.listarPorAlumno(n.getAlumnoId());
            boolean existeDuplicado = false;
            
            for (Nota notaExistente : notasExistentes) {
                if (notaExistente.getTareaId() == n.getTareaId()) {
                    existeDuplicado = true;
                    break;
                }
            }
            
            if (existeDuplicado) {
                System.out.println("ERROR: Ya existe una nota para este alumno en esta tarea");
                session.setAttribute("error", 
                    "Ya existe una calificación para este alumno en esta tarea. Usa 'Editar' para modificarla.");
                response.sendRedirect("NotaServlet?accion=nuevo&curso_id=" + cursoId);
                return;
            }
            
            // Crear nueva nota
            resultado = dao.agregar(n);
            
            if (resultado) {
                System.out.println("Nueva calificación registrada - Alumno: " + n.getAlumnoId() + 
                                 ", Tarea: " + n.getTareaId() + ", Nota: " + n.getNota());
                session.setAttribute("mensaje", "Calificación registrada correctamente");
            } else {
                System.out.println("ERROR: No se pudo registrar la calificación");
                session.setAttribute("error", "Error al registrar la calificación");
            }
        } else {
            // Actualizar nota existente
            n.setId(id);
            resultado = dao.actualizar(n);
            
            if (resultado) {
                System.out.println("Calificación actualizada - ID: " + id + ", Nueva nota: " + n.getNota());
                session.setAttribute("mensaje", "Calificación actualizada correctamente");
            } else {
                System.out.println("ERROR: No se pudo actualizar la calificación " + id);
                session.setAttribute("error", "Error al actualizar la calificación");
            }
        }

        response.sendRedirect("NotaServlet?curso_id=" + cursoId);
    }
}