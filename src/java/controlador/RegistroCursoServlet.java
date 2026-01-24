package controlador;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.*;
import modelo.RegistroCursoDAO;
import com.google.gson.Gson;

@WebServlet("/RegistroCursoServlet")
public class RegistroCursoServlet extends HttpServlet {

    private RegistroCursoDAO dao = new RegistroCursoDAO();
    private Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String accion = request.getParameter("accion");
        System.out.println("GET - Acción: " + accion);
        
        if ("cargarFormulario".equals(accion)) {
            cargarFormulario(request, response);
        } else if ("obtenerProfesores".equals(accion)) {
            obtenerProfesores(request, response);
        } else if ("validarDisponibilidad".equals(accion)) {
            validarDisponibilidad(request, response);
        } else {
            cargarFormulario(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String accion = request.getParameter("accion");
        System.out.println("POST - Acción: " + accion);
        
        if ("registrar".equals(accion)) {
            registrarCurso(request, response);
        }
    }

    /**
     * Cargar datos iniciales del formulario
     */
    private void cargarFormulario(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("Cargando formulario de registro de curso...");
        
        request.setAttribute("cursos", dao.obtenerCursosBase());
        request.setAttribute("grados", dao.obtenerGrados());
        request.setAttribute("turnos", dao.obtenerTurnos());
        
        request.getRequestDispatcher("registroCurso.jsp").forward(request, response);
    }

    /**
     * Obtener profesores según curso seleccionado (AJAX)
     */
    private void obtenerProfesores(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String curso = request.getParameter("curso");
        System.out.println("Buscando profesores para: " + curso);
        
        List<Map<String, Object>> profesores = dao.obtenerProfesoresPorCurso(curso);
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(gson.toJson(profesores));
    }

    /**
     * Validar disponibilidad del profesor (AJAX)
     */
    private void validarDisponibilidad(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            int profesorId = Integer.parseInt(request.getParameter("profesorId"));
            int turnoId = Integer.parseInt(request.getParameter("turnoId"));
            String diaSemana = request.getParameter("diaSemana");
            String horaInicio = request.getParameter("horaInicio");
            String horaFin = request.getParameter("horaFin");
            
            System.out.println("Validando: Profesor=" + profesorId + ", Día=" + diaSemana);
            
            // Validar límite de cursos
            int cursosEnDia = dao.validarLimiteCursos(profesorId, turnoId, diaSemana);
            boolean excedeLimite = cursosEnDia >= 4;
            
            // Validar conflicto de horarios
            boolean hayConflicto = dao.validarConflictoHorario(
                profesorId, turnoId, diaSemana, horaInicio, horaFin
            );
            
            Map<String, Object> resultado = new HashMap<>();
            resultado.put("disponible", !excedeLimite && !hayConflicto);
            resultado.put("cursosEnDia", cursosEnDia);
            resultado.put("excedeLimite", excedeLimite);
            resultado.put("hayConflicto", hayConflicto);
            resultado.put("mensaje", 
                excedeLimite ? "El profesor ya tiene 4 cursos este día" :
                hayConflicto ? "Conflicto de horario con otra clase" :
                "Disponible"
            );
            
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(gson.toJson(resultado));
            
        } catch (Exception e) {
            System.err.println("Error en validación: " + e.getMessage());
            e.printStackTrace();
            
            Map<String, Object> error = new HashMap<>();
            error.put("disponible", false);
            error.put("mensaje", "Error en validación");
            
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write(gson.toJson(error));
        }
    }

    /**
     * Registrar nuevo curso
     */
    private void registrarCurso(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        try {
            // Capturar datos del formulario
            String nombreCurso = request.getParameter("curso");
            int gradoId = Integer.parseInt(request.getParameter("grado"));
            int profesorId = Integer.parseInt(request.getParameter("profesor"));
            int creditos = Integer.parseInt(request.getParameter("creditos"));
            int turnoId = Integer.parseInt(request.getParameter("turno"));
            String descripcion = request.getParameter("descripcion");
            String area = request.getParameter("area");
            
            // Capturar horarios
            String[] dias = request.getParameterValues("dias[]");
            String[] horasInicio = request.getParameterValues("horasInicio[]");
            String[] horasFin = request.getParameterValues("horasFin[]");
            
            System.out.println("DATOS RECIBIDOS:");
            System.out.println("   Curso: " + nombreCurso);
            System.out.println("   Grado: " + gradoId);
            System.out.println("   Profesor: " + profesorId);
            System.out.println("   Turno: " + turnoId);
            System.out.println("   Días: " + Arrays.toString(dias));
            System.out.println("   Horas inicio: " + Arrays.toString(horasInicio));
            System.out.println("   Horas fin: " + Arrays.toString(horasFin));

            
           // Construir JSON de horarios
        StringBuilder horariosJson = new StringBuilder("[");
        if (dias != null && dias.length > 0) {
            for (int i = 0; i < dias.length; i++) {
                if (i > 0) horariosJson.append(",");
                horariosJson.append("{")
                    .append("\"dia\":\"").append(dias[i]).append("\",")
                    .append("\"hora_inicio\":\"").append(horasInicio[i]).append("\",")
                    .append("\"hora_fin\":\"").append(horasFin[i]).append("\"")
                    .append("}");
            }
        }
        horariosJson.append("]");
        
        System.out.println("JSON generado: " + horariosJson.toString());
        
        // Registrar en base de datos
        Map<String, Object> resultado = dao.registrarCurso(
            nombreCurso, gradoId, profesorId, creditos, 
            turnoId, descripcion, area, horariosJson.toString()
        );
        
        System.out.println("Resultado: " + resultado);
            
            if ((Boolean) resultado.get("exito")) {
                session.setAttribute("mensaje", resultado.get("mensaje"));
                System.out.println("Curso registrado exitosamente");
            } else {
                session.setAttribute("error", resultado.get("mensaje") + ": " + resultado.get("detalle"));
                System.out.println("Error: " + resultado.get("detalle"));
            }
            
            response.sendRedirect("RegistroCursoServlet?accion=cargarFormulario");
            
         } catch (Exception e) {
            System.err.println("ERROR COMPLETO:");
            e.printStackTrace();
            session.setAttribute("error", "Error detallado: " + e.getMessage());
            response.sendRedirect("RegistroCursoServlet?accion=cargarFormulario");
        }
    }
}