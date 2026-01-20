package controlador;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import modelo.Curso;
import modelo.CursoDAO;
import modelo.GradoDAO;
import modelo.ProfesorDAO;
import modelo.Profesor;

@WebServlet("/CursoServlet")
public class CursoServlet extends HttpServlet {

    CursoDAO dao = new CursoDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String rol = (String) session.getAttribute("rol");
        String accion = request.getParameter("accion");

        System.out.println("CursoServlet - Acción: " + accion + ", Rol: " + rol);

        // VALIDACIÓN: Solo admin puede gestionar cursos (crear, editar, eliminar)
        if (("nuevo".equals(accion) || "editar".equals(accion) || "eliminar".equals(accion)) 
            && !"admin".equals(rol)) {
            System.out.println("ACCESO DENEGADO: Rol " + rol + " intentó acción administrativa");
            response.sendRedirect("acceso_denegado.jsp");
            return;
        }

        // Para docentes que quieren ver cursos, validar ownership
        if ("docente".equals(rol) && ("editar".equals(accion) || "eliminar".equals(accion))) {
            Profesor docente = (Profesor) session.getAttribute("docente");
            if (docente != null) {
                try {
                    int cursoId = Integer.parseInt(request.getParameter("id"));
                    
                    // Usar el método del DAO en lugar de SQL directo
                    if (!dao.isCursoAssignedToProfesor(cursoId, docente.getId())) {
                        System.out.println("ACCESO DENEGADO: Profesor " + docente.getId() + 
                                         " intentó acceder a curso " + cursoId + " no asignado");
                        session.setAttribute("error", "No tienes permisos para acceder a este curso.");
                        response.sendRedirect("acceso_denegado.jsp");
                        return;
                    }
                } catch (NumberFormatException e) {
                    System.out.println("ERROR: ID de curso inválido");
                    session.setAttribute("error", "ID de curso inválido.");
                    response.sendRedirect("cursos.jsp");
                    return;
                }
            }
        }

        // Acción por defecto: listar todos los cursos
        if (accion == null || accion.equals("listar")) {
            // Si es docente, mostrar solo sus cursos
            if ("docente".equals(rol)) {
                Profesor docente = (Profesor) session.getAttribute("docente");
                if (docente != null) {
                    request.setAttribute("lista", dao.listarPorProfesor(docente.getId()));
                } else {
                    request.setAttribute("error", "No se pudo cargar información del profesor");
                    request.setAttribute("lista", new java.util.ArrayList<>());
                }
            } else {
                // Admin ve todos los cursos
                request.setAttribute("grados", new GradoDAO().listar());
                request.setAttribute("lista", dao.listar());
            }
            
            request.getRequestDispatcher("cursos.jsp").forward(request, response);
            return;
        }

        // Filtrar cursos por grado (SOLO ADMIN)
        if (accion.equals("filtrar")) {
            if (!"admin".equals(rol)) {
                response.sendRedirect("acceso_denegado.jsp");
                return;
            }

            String gradoStr = request.getParameter("grado_id");
            request.setAttribute("grados", new GradoDAO().listar());

            if (gradoStr == null || gradoStr.isEmpty()) {
                request.setAttribute("lista", dao.listar());
            } else {
                try {
                    int gradoId = Integer.parseInt(gradoStr);
                    request.setAttribute("lista", dao.listarPorGrado(gradoId));
                    request.setAttribute("gradoSeleccionado", gradoId);
                } catch (NumberFormatException e) {
                    System.out.println("ERROR: grado_id inválido: " + gradoStr);
                    session.setAttribute("error", "ID de grado inválido");
                    request.setAttribute("lista", dao.listar());
                }
            }

            request.getRequestDispatcher("cursos.jsp").forward(request, response);
            return;
        }

        // Formulario para nuevo curso (SOLO ADMIN)
        if (accion.equals("nuevo")) {
            if (!"admin".equals(rol)) {
                response.sendRedirect("acceso_denegado.jsp");
                return;
            }
            
            request.setAttribute("grados", new GradoDAO().listar());
            request.setAttribute("profesores", new ProfesorDAO().listar());
            request.getRequestDispatcher("cursoForm.jsp").forward(request, response);
            return;
        }

        // Editar curso existente
        if (accion.equals("editar")) {
            try {
                int idEditar = Integer.parseInt(request.getParameter("id"));
                Curso c = dao.obtenerPorId(idEditar);
                
                if (c == null) {
                    System.out.println("ERROR: Curso no encontrado con ID: " + idEditar);
                    session.setAttribute("error", "Curso no encontrado.");
                    response.sendRedirect("CursoServlet");
                    return;
                }
                
                // Si es docente, verificar que sea su curso
                if ("docente".equals(rol)) {
                    Profesor docente = (Profesor) session.getAttribute("docente");
                    if (docente == null || c.getProfesorId() != docente.getId()) {
                        response.sendRedirect("acceso_denegado.jsp");
                        return;
                    }
                }
                
                request.setAttribute("curso", c);
                request.setAttribute("grados", new GradoDAO().listar());
                request.setAttribute("profesores", new ProfesorDAO().listar());
                request.getRequestDispatcher("cursoForm.jsp").forward(request, response);
                
            } catch (NumberFormatException e) {
                System.out.println("ERROR: ID de curso inválido para editar");
                session.setAttribute("error", "ID de curso inválido.");
                response.sendRedirect("CursoServlet");
            }
            return;
        }

        // Eliminar curso (SOLO ADMIN)
        if (accion.equals("eliminar")) {
            if (!"admin".equals(rol)) {
                response.sendRedirect("acceso_denegado.jsp");
                return;
            }
            
            try {
                int idEliminar = Integer.parseInt(request.getParameter("id"));
                
                // Verificar si tiene dependencias antes de eliminar
                if (dao.tieneTareas(idEliminar) || dao.tieneHorarios(idEliminar)) {
                    System.out.println("ADVERTENCIA: Intento de eliminar curso " + idEliminar + 
                                     " con tareas/horarios asociados");
                    session.setAttribute("error", 
                        "No se puede eliminar el curso porque tiene tareas o horarios asociados. " +
                        "Considera desactivarlo en su lugar.");
                    response.sendRedirect("CursoServlet?accion=listar");
                    return;
                }
                
                boolean resultado = dao.eliminar(idEliminar);
                
                if (resultado) {
                    System.out.println("Curso eliminado exitosamente: ID " + idEliminar);
                    session.setAttribute("mensaje", "Curso eliminado correctamente");
                } else {
                    System.out.println("ERROR: No se pudo eliminar el curso " + idEliminar);
                    session.setAttribute("error", "Error al eliminar el curso");
                }
                
            } catch (NumberFormatException e) {
                System.out.println("ERROR: ID de curso inválido para eliminar");
                session.setAttribute("error", "ID de curso inválido.");
            }
            
            response.sendRedirect("CursoServlet?accion=listar");
            return;
        }

        // Acción desconocida
        System.out.println("ADVERTENCIA: Acción desconocida: " + accion);
        response.sendRedirect("CursoServlet?accion=listar");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String rol = (String) session.getAttribute("rol");

        // Solo admin puede crear/editar cursos
        if (!"admin".equals(rol)) {
            System.out.println("ACCESO DENEGADO POST: Rol " + rol + " intentó modificar cursos");
            response.sendRedirect("acceso_denegado.jsp");
            return;
        }

        // Determinar si es creación o actualización
        int id = 0;
        String idParam = request.getParameter("id");
        if (idParam != null && !idParam.isEmpty()) {
            try {
                id = Integer.parseInt(idParam);
            } catch (NumberFormatException e) {
                System.out.println("ERROR: ID de curso inválido: " + idParam);
                session.setAttribute("error", "ID de curso inválido");
                response.sendRedirect("CursoServlet?accion=nuevo");
                return;
            }
        }

        // Construir objeto curso
        Curso c = new Curso();
        c.setNombre(request.getParameter("nombre"));

        // Validar y parsear campos obligatorios
        try {
            String gradoStr = request.getParameter("grado_id");
            String profesorStr = request.getParameter("profesor_id");

            if (gradoStr == null || gradoStr.isEmpty()) {
                throw new IllegalArgumentException("Debes seleccionar un grado");
            }
            if (profesorStr == null || profesorStr.isEmpty()) {
                throw new IllegalArgumentException("Debes seleccionar un profesor");
            }

            c.setGradoId(Integer.parseInt(gradoStr));
            c.setProfesorId(Integer.parseInt(profesorStr));

        } catch (NumberFormatException e) {
            System.out.println("ERROR: Formato numérico inválido en grado o profesor");
            session.setAttribute("error", "Error: Formato de datos inválido para grado o profesor");
            response.sendRedirect("CursoServlet?accion=" + (id == 0 ? "nuevo" : "editar&id=" + id));
            return;
        } catch (IllegalArgumentException e) {
            System.out.println("ERROR: " + e.getMessage());
            session.setAttribute("error", e.getMessage());
            response.sendRedirect("CursoServlet?accion=" + (id == 0 ? "nuevo" : "editar&id=" + id));
            return;
        }

        // Parsear créditos (opcional)
        try {
            String creditosStr = request.getParameter("creditos");
            if (creditosStr != null && !creditosStr.isEmpty()) {
                c.setCreditos(Integer.parseInt(creditosStr));
            } else {
                c.setCreditos(1); // Valor por defecto
            }
        } catch (NumberFormatException e) {
            System.out.println("ADVERTENCIA: Créditos inválidos, usando 1 por defecto");
            c.setCreditos(1);
        }

        // Campos opcionales
        String area = request.getParameter("area");
        if (area != null && !area.isEmpty()) {
            c.setArea(area);
        }

        // Validar nombre del curso
        if (c.getNombre() == null || c.getNombre().trim().isEmpty()) {
            session.setAttribute("error", "El nombre del curso es obligatorio");
            response.sendRedirect("CursoServlet?accion=" + (id == 0 ? "nuevo" : "editar&id=" + id));
            return;
        }

        // Ejecutar operación en base de datos
        boolean resultado;
        if (id == 0) {
            // Crear nuevo curso
            int nuevoId = dao.agregar(c);
            resultado = nuevoId > 0;
            
            if (resultado) {
                System.out.println("Nuevo curso creado: " + c.getNombre() + " (ID: " + nuevoId + ")");
                session.setAttribute("mensaje", "Curso creado correctamente");
            } else {
                System.out.println("ERROR: No se pudo crear el curso: " + c.getNombre());
                session.setAttribute("error", "Error al crear el curso");
            }
        } else {
            // Actualizar curso existente
            c.setId(id);
            resultado = dao.actualizar(c);
            
            if (resultado) {
                System.out.println("Curso actualizado: " + c.getNombre() + " (ID: " + id + ")");
                session.setAttribute("mensaje", "Curso actualizado correctamente");
            } else {
                System.out.println("ERROR: No se pudo actualizar el curso " + id);
                session.setAttribute("error", "Error al actualizar el curso");
            }
        }

        response.sendRedirect("CursoServlet?accion=listar");
    }
}