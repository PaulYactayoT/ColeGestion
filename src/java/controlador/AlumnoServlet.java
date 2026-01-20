package controlador;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.util.List;

import modelo.Alumno;
import modelo.AlumnoDAO;
import modelo.GradoDAO;

public class AlumnoServlet extends HttpServlet {

    // DAO para operaciones con la tabla de alumnos
    AlumnoDAO dao = new AlumnoDAO();

    /**
     * METODO GET - CONSULTAS Y NAVEGACION DE ALUMNOS
     * 
     * Acciones soportadas:
     * - listar: Mostrar todos los alumnos (accion por defecto)
     * - filtrar: Filtrar alumnos por grado especifico
     * - nuevo: Formulario para crear nuevo alumno
     * - editar: Formulario para modificar alumno existente
     * - eliminar: Eliminar alumno del sistema
     * - obtenerPorCurso: Endpoint AJAX para obtener alumnos por curso
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String rol = (String) session.getAttribute("rol");
        String accion = request.getParameter("accion");

        System.out.println("AlumnoServlet - Acción: " + accion + ", Rol: " + rol);

        // VALIDACIÓN DE PERMISOS POR ROL
        if (!tienePermiso(rol, accion, request)) {
            System.out.println("ACCESO DENEGADO: Rol " + rol + " intentó acceder a AlumnoServlet con acción: " + accion);
            response.sendRedirect("acceso_denegado.jsp");
            return;
        }

        // Accion por defecto: listar todos los alumnos con filtros de grado
        if (accion == null) {
            // Solo admin puede listar todos los alumnos
            if (!"admin".equals(rol)) {
                response.sendRedirect("acceso_denegado.jsp");
                return;
            }
            request.setAttribute("grados", new GradoDAO().listar());
            request.setAttribute("lista", dao.listar());
            request.getRequestDispatcher("alumnos.jsp").forward(request, response);
            return;
        }

        // Filtrar alumnos por grado especifico (SOLO ADMIN)
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
                int gradoId = Integer.parseInt(gradoStr);
                request.setAttribute("gradoSeleccionado", gradoId);
                request.setAttribute("lista", dao.listarPorGrado(gradoId));
            }

            request.getRequestDispatcher("alumnos.jsp").forward(request, response);
            return;
        }

        // Endpoint AJAX: obtener alumnos por curso (para registro de asistencias/notas)
        // PERMITIDO para docente y admin
        if (accion.equals("obtenerPorCurso")) {
            obtenerAlumnosPorCurso(request, response);
            return;
        }

        // Las siguientes acciones SOLO para ADMIN
        if (!"admin".equals(rol)) {
            response.sendRedirect("acceso_denegado.jsp");
            return;
        }

        // Mostrar formulario para nuevo alumno
        if (accion.equals("nuevo")) {
            request.setAttribute("grados", new GradoDAO().listar());
            request.getRequestDispatcher("alumnoForm.jsp").forward(request, response);
            return;
        }

        // Procesar acciones restantes (SOLO ADMIN)
        switch (accion) {
            case "editar":
                // Cargar formulario de edicion de alumno
                int idEditar = Integer.parseInt(request.getParameter("id"));
                Alumno alumno = dao.obtenerPorId(idEditar);
                request.setAttribute("alumno", alumno);
                request.setAttribute("grados", new GradoDAO().listar());
                request.getRequestDispatcher("alumnoForm.jsp").forward(request, response);
                break;

            case "eliminar":
                // Eliminar alumno del sistema
                int idEliminar = Integer.parseInt(request.getParameter("id"));
                boolean eliminado = dao.eliminar(idEliminar);
                if (eliminado) {
                    session.setAttribute("mensaje", "Alumno eliminado correctamente");
                } else {
                    session.setAttribute("error", "Error al eliminar el alumno");
                }
                response.sendRedirect("AlumnoServlet");
                break;

            default:
                // Redireccion por defecto
                response.sendRedirect("AlumnoServlet");
        }
    }

    /**
     * METODO POST - CREAR Y ACTUALIZAR ALUMNOS
     * 
     * Maneja el envio de formularios para crear nuevos alumnos
     * y actualizar informacion de alumnos existentes
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String rol = (String) session.getAttribute("rol");

        // VALIDACIÓN: Solo admin puede crear/actualizar alumnos
        if (!"admin".equals(rol)) {
            System.out.println("ACCESO DENEGADO POST: Rol " + rol + " intentó modificar alumnos");
            response.sendRedirect("acceso_denegado.jsp");
            return;
        }

        // Determinar si es creacion (id=0) o actualizacion (id>0)
        int id = request.getParameter("id") != null && !request.getParameter("id").isEmpty()
                ? Integer.parseInt(request.getParameter("id")) : 0;

        // Construir objeto alumno con datos del formulario
        Alumno a = new Alumno();
        a.setNombres(request.getParameter("nombres"));
        a.setApellidos(request.getParameter("apellidos"));
        a.setCorreo(request.getParameter("correo"));
        
        // Convertir fecha de String a LocalDate
        String fechaNacStr = request.getParameter("fecha_nacimiento");
        if (fechaNacStr != null && !fechaNacStr.isEmpty()) {
            try {
                a.setFechaNacimiento(LocalDate.parse(fechaNacStr));
            } catch (Exception e) {
                System.out.println("Error al parsear fecha de nacimiento: " + fechaNacStr);
                session.setAttribute("error", "Formato de fecha inválido");
                response.sendRedirect("AlumnoServlet?accion=" + (id == 0 ? "nuevo" : "editar&id=" + id));
                return;
            }
        }
        
        a.setGradoId(Integer.parseInt(request.getParameter("grado_id")));

        // Validar datos obligatorios
        if (a.getNombres() == null || a.getNombres().trim().isEmpty() ||
            a.getApellidos() == null || a.getApellidos().trim().isEmpty()) {
            session.setAttribute("error", "Nombre y apellidos son obligatorios");
            response.sendRedirect("AlumnoServlet?accion=" + (id == 0 ? "nuevo" : "editar&id=" + id));
            return;
        }

        // Ejecutar operacion en base de datos
        boolean resultado;
        if (id == 0) {
            resultado = dao.agregar(a);
            if (resultado) {
                System.out.println("Nuevo alumno creado por admin: " + a.getNombreCompleto());
                session.setAttribute("mensaje", "Alumno creado correctamente");
            } else {
                session.setAttribute("error", "Error al crear el alumno");
            }
        } else {
            a.setId(id);
            resultado = dao.actualizar(a);
            if (resultado) {
                System.out.println("Alumno actualizado por admin: " + a.getNombreCompleto() + " (ID: " + id + ")");
                session.setAttribute("mensaje", "Alumno actualizado correctamente");
            } else {
                session.setAttribute("error", "Error al actualizar el alumno");
            }
        }

        // Redirigir a la lista principal de alumnos
        response.sendRedirect("AlumnoServlet");
    }

    /**
     * VALIDAR PERMISOS SEGUN ROL Y ACCION
     */
    private boolean tienePermiso(String rol, String accion, HttpServletRequest request) {
        if (rol == null) return false;

        switch (rol) {
            case "admin":
                // Admin tiene acceso completo
                return true;

            case "docente":
                // Docente solo puede usar obtenerPorCurso (AJAX)
                return "obtenerPorCurso".equals(accion);

            case "padre":
                // Padre NO tiene acceso a AlumnoServlet
                return false;

            default:
                return false;
        }
    }

    /**
     * ENDPOINT AJAX - OBTENER ALUMNOS POR CURSO (JSON)
     * 
     * Proposito: Proveer datos para interfaces dinamicas como:
     * - Registro de asistencias por curso
     * - Asignacion de calificaciones
     * - Listas de estudiantes por clase
     * 
     * @return JSON array con datos de alumnos
     */
    private void obtenerAlumnosPorCurso(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Configurar respuesta como JSON
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        System.out.println("INICIANDO DEBUG obtenerAlumnosPorCurso");

        try {
            // Capturar y validar parametro curso_id
            String cursoIdParam = request.getParameter("curso_id");
            System.out.println("Parametro curso_id recibido: '" + cursoIdParam + "'");

            // Validar parametro obligatorio
            if (cursoIdParam == null || cursoIdParam.isEmpty()) {
                System.out.println("ERROR: curso_id es nulo o vacio");
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().print("{\"error\": \"Parametro curso_id requerido\"}");
                return;
            }

            // Convertir y ejecutar consulta
            int cursoId = Integer.parseInt(cursoIdParam);
            System.out.println("Buscando alumnos para curso ID: " + cursoId);

            List<Alumno> alumnos = dao.obtenerAlumnosPorCurso(cursoId);

            System.out.println("Alumnos encontrados: " + alumnos.size());

            // Convertir resultados a JSON y enviar respuesta
            String json = convertirAlumnosAJson(alumnos);
            System.out.println("JSON enviado para curso " + cursoId + ": " + alumnos.size() + " alumnos");

            PrintWriter out = response.getWriter();
            out.print(json);
            out.flush();

        } catch (NumberFormatException e) {
            // Error en formato de parametro
            System.out.println("ERROR: curso_id no es un numero valido");
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().print("{\"error\": \"ID de curso invalido: debe ser un numero\"}");
        } catch (Exception e) {
            // Error general en el procesamiento
            System.out.println("ERROR inesperado en obtenerAlumnosPorCurso:");
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().print("{\"error\": \"Error interno del servidor: " + e.getMessage() + "\"}");
        }
    }

    /**
     * METODO AUXILIAR - CONVERTIR LISTA DE ALUMNOS A JSON MANUALMENTE
     * 
     * Proposito: Generar JSON sin dependencias externas
     * Formato: Array de objetos alumno con todos sus atributos
     */
    private String convertirAlumnosAJson(List<Alumno> alumnos) {
        StringBuilder json = new StringBuilder("[");

        for (int i = 0; i < alumnos.size(); i++) {
            Alumno a = alumnos.get(i);
            json.append("{")
                    .append("\"id\":").append(a.getId()).append(",")
                    .append("\"nombres\":\"").append(escapeJson(a.getNombres())).append("\",")
                    .append("\"apellidos\":\"").append(escapeJson(a.getApellidos())).append("\",")
                    .append("\"correo\":\"").append(escapeJson(a.getCorreo())).append("\",")
                    // Convertir LocalDate a String formato ISO (yyyy-MM-dd)
                    .append("\"fechaNacimiento\":\"")
                    .append(a.getFechaNacimiento() != null ? a.getFechaNacimiento().toString() : "")
                    .append("\",")
                    .append("\"gradoId\":").append(a.getGradoId());
            
            // Campos opcionales
            if (a.getCodigoAlumno() != null) {
                json.append(",\"codigoAlumno\":\"").append(escapeJson(a.getCodigoAlumno())).append("\"");
            }
            if (a.getGradoNombre() != null) {
                json.append(",\"gradoNombre\":\"").append(escapeJson(a.getGradoNombre())).append("\"");
            }
            
            json.append("}");

            // Agregar coma entre elementos (excepto ultimo)
            if (i < alumnos.size() - 1) {
                json.append(",");
            }
        }

        json.append("]");
        return json.toString();
    }

    /**
     * METODO AUXILIAR - ESCAPAR CARACTERES ESPECIALES EN JSON
     * 
     * Proposito: Prevenir errores de sintaxis JSON y ataques de inyeccion
     * Caracteres escapados: comillas, barras invertidas, saltos de linea, etc.
     */
    private String escapeJson(String text) {
        if (text == null) {
            return "";
        }
        return text.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\b", "\\b")
                .replace("\f", "\\f")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}