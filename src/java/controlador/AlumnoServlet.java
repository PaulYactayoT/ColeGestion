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
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String rol = (String) session.getAttribute("rol");
        String accion = request.getParameter("accion");
  request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    response.setContentType("text/html; charset=UTF-8");
        System.out.println("AlumnoServlet - Acción: " + accion + ", Rol: " + rol);

        // VALIDACIÓN DE PERMISOS POR ROL
        if (!tienePermiso(rol, accion, request)) {
            System.out.println("ACCESO DENEGADO: Rol " + rol + " intentó acceder a AlumnoServlet con acción: " + accion);
            response.sendRedirect("acceso_denegado.jsp");
            return;
        }

        try {
            // Acción por defecto: listar todos los alumnos con filtros de grado
            if (accion == null || accion.isEmpty()) {
                // Solo admin puede listar todos los alumnos
                if (!"admin".equals(rol)) {
                    response.sendRedirect("acceso_denegado.jsp");
                    return;
                }
                
                // Cargar grados para el filtro
                GradoDAO gradoDAO = new GradoDAO();
                List<modelo.Grado> grados = gradoDAO.listar();
                System.out.println("DEBUG: Número de grados obtenidos: " + (grados != null ? grados.size() : 0));
                request.setAttribute("grados", grados);
                
                // Obtener todos los alumnos
                List<Alumno> alumnos = dao.listar();
                System.out.println("Alumnos encontrados: " + alumnos.size());
                
                request.setAttribute("lista", alumnos);
                request.getRequestDispatcher("alumnos.jsp").forward(request, response);
                return;
            }

            // Filtrar alumnos por grado específico (SOLO ADMIN)
            if ("filtrar".equals(accion)) {
                if (!"admin".equals(rol)) {
                    response.sendRedirect("acceso_denegado.jsp");
                    return;
                }

                String gradoStr = request.getParameter("grado_id");
                GradoDAO gradoDAO = new GradoDAO();
                request.setAttribute("grados", gradoDAO.listar());

                if (gradoStr == null || gradoStr.isEmpty()) {
                    List<Alumno> alumnos = dao.listar();
                    System.out.println("Mostrando todos los alumnos: " + alumnos.size());
                    request.setAttribute("lista", alumnos);
                } else {
                    int gradoId = Integer.parseInt(gradoStr);
                    System.out.println("Filtrando por grado ID: " + gradoId);
                    
                    List<Alumno> alumnos = dao.listarPorGrado(gradoId);
                    System.out.println("Alumnos encontrados para grado " + gradoId + ": " + alumnos.size());
                    
                    request.setAttribute("gradoSeleccionado", gradoId);
                    request.setAttribute("lista", alumnos);
                }

                request.getRequestDispatcher("alumnos.jsp").forward(request, response);
                return;
            }

            // Endpoint AJAX: obtener alumnos por curso (para registro de asistencias/notas)
            // PERMITIDO para docente y admin
            if ("obtenerPorCurso".equals(accion)) {
                obtenerAlumnosPorCurso(request, response);
                return;
            }

            // Las siguientes acciones SOLO para ADMIN
            if (!"admin".equals(rol)) {
                response.sendRedirect("acceso_denegado.jsp");
                return;
            }

            // Mostrar formulario para nuevo alumno
            if ("nuevo".equals(accion)) {
                GradoDAO gradoDAO = new GradoDAO();
                request.setAttribute("grados", gradoDAO.listar());
                request.getRequestDispatcher("alumnoForm.jsp").forward(request, response);
                return;
            }

            // Procesar acciones restantes (SOLO ADMIN)
            switch (accion) {
                case "editar":
                    // Cargar formulario de edición de alumno
                    int idEditar = Integer.parseInt(request.getParameter("id"));
                    Alumno alumno = dao.obtenerPorId(idEditar);
                    if (alumno != null) {
                        request.setAttribute("alumno", alumno);
                        GradoDAO gradoDAO = new GradoDAO();
                        request.setAttribute("grados", gradoDAO.listar());
                        request.getRequestDispatcher("alumnoForm.jsp").forward(request, response);
                    } else {
                        session.setAttribute("error", "Alumno no encontrado");
                        response.sendRedirect("AlumnoServlet");
                    }
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
                    // Redirección por defecto
                    response.sendRedirect("AlumnoServlet");
            }
        } catch (Exception e) {
            System.out.println("Error en AlumnoServlet doGet:");
            e.printStackTrace();
            session.setAttribute("error", "Error al procesar la solicitud: " + e.getMessage());
            response.sendRedirect("AlumnoServlet");
        }
    }

    /**
     * METODO POST - CREAR Y ACTUALIZAR ALUMNOS
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String rol = (String) session.getAttribute("rol");
  request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    response.setContentType("text/html; charset=UTF-8");
        System.out.println("AlumnoServlet POST - Rol: " + rol);

        // VALIDACIÓN: Solo admin puede crear/actualizar alumnos
        if (!"admin".equals(rol)) {
            System.out.println("ACCESO DENEGADO POST: Rol " + rol + " intentó modificar alumnos");
            response.sendRedirect("acceso_denegado.jsp");
            return;
        }

        try {
            // Determinar si es creación (id=0) o actualización (id>0)
            int id = request.getParameter("id") != null && !request.getParameter("id").isEmpty()
                    ? Integer.parseInt(request.getParameter("id")) : 0;

            // Construir objeto alumno con datos del formulario
            Alumno a = new Alumno();
            a.setNombres(request.getParameter("nombres"));
            a.setApellidos(request.getParameter("apellidos"));
            a.setCorreo(request.getParameter("correo"));
            a.setDni(request.getParameter("dni"));
            a.setTelefono(request.getParameter("telefono"));
            a.setDireccion(request.getParameter("direccion"));
            
            // Convertir fecha de String a LocalDate
            String fechaNacStr = request.getParameter("fecha_nacimiento");
            if (fechaNacStr != null && !fechaNacStr.isEmpty()) {
                try {
                    a.setFechaNacimiento(LocalDate.parse(fechaNacStr));
                    
                    // Validar que no sea fecha futura
                    if (a.getFechaNacimiento().isAfter(LocalDate.now())) {
                        session.setAttribute("error", "La fecha de nacimiento no puede ser futura");
                        response.sendRedirect("AlumnoServlet?accion=" + (id == 0 ? "nuevo" : "editar&id=" + id));
                        return;
                    }
                } catch (Exception e) {
                    System.out.println("Error al parsear fecha de nacimiento: " + fechaNacStr);
                    session.setAttribute("error", "Formato de fecha inválido. Use YYYY-MM-DD");
                    response.sendRedirect("AlumnoServlet?accion=" + (id == 0 ? "nuevo" : "editar&id=" + id));
                    return;
                }
            }
            
            a.setGradoId(Integer.parseInt(request.getParameter("grado_id")));

            // Validar datos obligatorios
            if (a.getNombres() == null || a.getNombres().trim().isEmpty() ||
                a.getApellidos() == null || a.getApellidos().trim().isEmpty() ||
                a.getCorreo() == null || a.getCorreo().trim().isEmpty()) {
                session.setAttribute("error", "Nombre, apellidos y correo son obligatorios");
                response.sendRedirect("AlumnoServlet?accion=" + (id == 0 ? "nuevo" : "editar&id=" + id));
                return;
            }

            // Validar DNI (si se proporciona, debe ser 8 dígitos)
            if (a.getDni() != null && !a.getDni().isEmpty()) {
                if (!a.getDni().matches("\\d{8}")) {
                    session.setAttribute("error", "DNI debe tener 8 dígitos numéricos");
                    response.sendRedirect("AlumnoServlet?accion=" + (id == 0 ? "nuevo" : "editar&id=" + id));
                    return;
                }
            }

            // Ejecutar operación en base de datos
            boolean resultado;
            if (id == 0) {
                System.out.println("Creando nuevo alumno: " + a.getNombres() + " " + a.getApellidos());
                resultado = dao.agregar(a);
                if (resultado) {
                    System.out.println("Nuevo alumno creado por admin: " + a.getNombres() + " " + a.getApellidos());
                    session.setAttribute("mensaje", "Alumno creado correctamente");
                } else {
                    session.setAttribute("error", "Error al crear el alumno. Verifique que el DNI o correo no existan.");
                }
            } else {
                // Para edición, primero obtener el alumno existente
                Alumno alumnoExistente = dao.obtenerPorId(id);
                if (alumnoExistente != null) {
                    a.setId(id);
                    a.setPersonaId(alumnoExistente.getPersonaId()); // IMPORTANTE: setear persona_id
                    System.out.println("Actualizando alumno ID " + id + ": " + a.getNombres() + " " + a.getApellidos());
                    resultado = dao.actualizar(a);
                    if (resultado) {
                        System.out.println("Alumno actualizado por admin: " + a.getNombres() + " " + a.getApellidos());
                        session.setAttribute("mensaje", "Alumno actualizado correctamente");
                    } else {
                        session.setAttribute("error", "Error al actualizar el alumno");
                    }
                } else {
                    session.setAttribute("error", "Alumno no encontrado");
                }
            }

            // Redirigir a la lista principal de alumnos
            response.sendRedirect("AlumnoServlet");

        } catch (Exception e) {
            System.out.println("Error en AlumnoServlet doPost:");
            e.printStackTrace();
            session.setAttribute("error", "Error al procesar la solicitud: " + e.getMessage());
            response.sendRedirect("AlumnoServlet");
        }
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
     */
    private void obtenerAlumnosPorCurso(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Configurar respuesta como JSON
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        System.out.println("INICIANDO obtenerAlumnosPorCurso");

        try {
            // Capturar y validar parámetro curso_id
            String cursoIdParam = request.getParameter("curso_id");
            System.out.println("Parámetro curso_id recibido: '" + cursoIdParam + "'");

            // Validar parámetro obligatorio
            if (cursoIdParam == null || cursoIdParam.isEmpty()) {
                System.out.println("ERROR: curso_id es nulo o vacío");
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().print("{\"error\": \"Parámetro curso_id requerido\"}");
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
            // Error en formato de parámetro
            System.out.println("ERROR: curso_id no es un número válido");
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().print("{\"error\": \"ID de curso inválido: debe ser un número\"}");
        } catch (Exception e) {
            // Error general en el procesamiento
            System.out.println("ERROR inesperado en obtenerAlumnosPorCurso:");
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().print("{\"error\": \"Error interno del servidor: " + e.getMessage() + "\"}");
        }
    }

    /**
     * MÉTODO AUXILIAR - CONVERTIR LISTA DE ALUMNOS A JSON MANUALMENTE
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
                    .append("\"dni\":\"").append(escapeJson(a.getDni())).append("\",")
                    .append("\"telefono\":\"").append(escapeJson(a.getTelefono())).append("\",")
                    .append("\"direccion\":\"").append(escapeJson(a.getDireccion())).append("\",")
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

            // Agregar coma entre elementos (excepto último)
            if (i < alumnos.size() - 1) {
                json.append(",");
            }
        }

        json.append("]");
        return json.toString();
    }

    /**
     * MÉTODO AUXILIAR - ESCAPAR CARACTERES ESPECIALES EN JSON
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