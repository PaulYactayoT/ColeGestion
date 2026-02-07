package controlador;

import java.io.IOException;
import java.sql.Time;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import modelo.Disponibilidad;
import modelo.DisponibilidadDAO;
import modelo.Profesor;

@WebServlet(name = "DisponibilidadServlet", urlPatterns = {"/DisponibilidadServlet"})
public class DisponibilidadServlet extends HttpServlet {

    private DisponibilidadDAO dao = new DisponibilidadDAO();

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Profesor docente = (Profesor) session.getAttribute("docente");
        
        if (docente == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        String accion = request.getParameter("accion");
        if (accion == null) {
            accion = "listar";
        }

        switch (accion) {
            case "listar":
                listarHorarios(request, response, docente);
                break;
            case "guardar":
                guardarHorario(request, response, docente);
                break;
            case "eliminar":
                eliminarHorario(request, response, docente);
                break;
            case "editar":
                cargarDatosEdicion(request, response, docente);
                break;
            case "actualizar":
                actualizarHorario(request, response, docente);
                break;
            default:
                listarHorarios(request, response, docente);
        }
    }

    private void listarHorarios(HttpServletRequest request, HttpServletResponse response, Profesor docente) 
            throws ServletException, IOException {
        
        int profesorId = docente.getId(); 
        List<Disponibilidad> lista = dao.listarPorProfesor(profesorId);
        request.setAttribute("listaHorarios", lista);
        
        // Asegúrate que este sea el nombre correcto de tu JSP del docente
        request.getRequestDispatcher("disponibilidadDocente.jsp").forward(request, response);
    }

    private void guardarHorario(HttpServletRequest request, HttpServletResponse response, Profesor docente) 
            throws ServletException, IOException {
        
        try {
            int profesorId = docente.getId();
            int turnoId = Integer.parseInt(request.getParameter("cboTurno")); 
            String dia = request.getParameter("cboDia");
            
            // --- CORRECCIÓN HORA (PARCHE DE SEGURIDAD HTML5) ---
            String inicioStr = request.getParameter("txtInicio");
            String finStr = request.getParameter("txtFin");
            
            // Si la hora viene como "08:00" (5 letras), le agregamos ":00"
            if (inicioStr != null && inicioStr.length() == 5) { inicioStr += ":00"; }
            if (finStr != null && finStr.length() == 5) { finStr += ":00"; }
            // ----------------------------------------------------
            
            Time horaInicio = Time.valueOf(inicioStr);
            Time horaFin = Time.valueOf(finStr);

            // AQUI SE LLAMA A LA VALIDACIÓN STRICTA
            if (validarHorario(turnoId, horaInicio, horaFin, request)) {
                Disponibilidad d = new Disponibilidad();
                d.setProfesorId(profesorId);
                d.setTurnoId(turnoId);
                d.setDiaSemana(dia);
                d.setHoraInicio(horaInicio);
                d.setHoraFin(horaFin);
                
                boolean exito = dao.registrarDisponibilidad(d);
                setMensaje(request, exito, "Horario registrado correctamente.", "Error al guardar (posible duplicado).");
            }
            
        } catch (Exception e) {
            request.setAttribute("mensaje", "Error de datos: " + e.getMessage());
            request.setAttribute("tipoMensaje", "danger");
            e.printStackTrace();
        }
        listarHorarios(request, response, docente);
    }

    private void eliminarHorario(HttpServletRequest request, HttpServletResponse response, Profesor docente) 
            throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            boolean exito = dao.eliminarDisponibilidad(id);
            setMensaje(request, exito, "Horario eliminado correctamente.", "No se pudo eliminar.");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("mensaje", "Error al eliminar.");
            request.setAttribute("tipoMensaje", "danger");
        }
        listarHorarios(request, response, docente);
    }

    private void cargarDatosEdicion(HttpServletRequest request, HttpServletResponse response, Profesor docente) 
            throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            Disponibilidad d = dao.obtenerPorId(id);
            request.setAttribute("disponibilidadEditar", d); 
        } catch (Exception e) {
            e.printStackTrace();
        }
        listarHorarios(request, response, docente);
    }

    private void actualizarHorario(HttpServletRequest request, HttpServletResponse response, Profesor docente) 
            throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            int turnoId = Integer.parseInt(request.getParameter("cboTurno")); 
            String dia = request.getParameter("cboDia");
            
            // --- CORRECCIÓN HORA (PARCHE DE SEGURIDAD HTML5) ---
            String inicioStr = request.getParameter("txtInicio");
            String finStr = request.getParameter("txtFin");
            
            if (inicioStr != null && inicioStr.length() == 5) { inicioStr += ":00"; }
            if (finStr != null && finStr.length() == 5) { finStr += ":00"; }
            
            Time horaInicio = Time.valueOf(inicioStr);
            Time horaFin = Time.valueOf(finStr);
            // ----------------------------------------------------

            // AQUI SE LLAMA A LA VALIDACIÓN STRICTA
            if (validarHorario(turnoId, horaInicio, horaFin, request)) {
                Disponibilidad d = new Disponibilidad();
                d.setId(id);
                d.setTurnoId(turnoId);
                d.setDiaSemana(dia);
                d.setHoraInicio(horaInicio);
                d.setHoraFin(horaFin);

                boolean exito = dao.actualizarDisponibilidad(d);
                
                // NOTA: El DAO ya se encarga de cambiar el estado a 'PENDIENTE'
                setMensaje(request, exito, "Horario corregido y re-enviado a revisión.", "Error al actualizar.");
            } else {
                // Si falla validación, NO GUARDAMOS NADA y el mensaje de error ya está en el request
                // Para mantener los datos en el formulario (opcional pero recomendado):
                Disponibilidad dError = new Disponibilidad();
                dError.setId(id); dError.setTurnoId(turnoId); dError.setDiaSemana(dia);
                dError.setHoraInicio(horaInicio); dError.setHoraFin(horaFin);
                request.setAttribute("disponibilidadEditar", dError);
            }

        } catch (Exception e) {
            request.setAttribute("mensaje", "Error al actualizar: " + e.getMessage());
            request.setAttribute("tipoMensaje", "danger");
            e.printStackTrace();
        }
        listarHorarios(request, response, docente);
    }

    // =========================================================================
    // MÉTODO DE VALIDACIÓN ESTRICTA (CORREGIDO)
    // =========================================================================
    private boolean validarHorario(int turnoId, Time inicio, Time fin, HttpServletRequest request) {
        // 1. Validar lógica básica de tiempo (Fin debe ser después de Inicio)
        if (!fin.after(inicio)) {
            request.setAttribute("mensaje", "Error: La hora Fin debe ser mayor a la hora de Inicio.");
            request.setAttribute("tipoMensaje", "danger");
            return false;
        }

        // 2. Validación ESTRICTA por Turno
        if (turnoId == 1) { // Turno MAÑANA (ID 1)
            // Regla: No antes de las 08:00 y no después de las 13:00
            if (inicio.before(Time.valueOf("08:00:00")) || fin.after(Time.valueOf("13:00:00"))) {
                request.setAttribute("mensaje", "Error: El turno MAÑANA es estrictamente de 08:00 a 13:00.");
                request.setAttribute("tipoMensaje", "danger");
                return false; // <--- ESTO BLOQUEA EL GUARDADO
            }
        } else if (turnoId == 2) { // Turno TARDE (ID 2)
            // Regla: No antes de las 13:00 y no después de las 18:00
            if (inicio.before(Time.valueOf("13:00:00")) || fin.after(Time.valueOf("18:00:00"))) {
                request.setAttribute("mensaje", "Error: El turno TARDE es estrictamente de 13:00 a 18:00.");
                request.setAttribute("tipoMensaje", "danger");
                return false; // <--- ESTO BLOQUEA EL GUARDADO
            }
        }
        
        return true; // Si pasa todas las reglas, permite guardar
    }

    private void setMensaje(HttpServletRequest request, boolean exito, String msjOk, String msjError) {
        if (exito) {
            request.setAttribute("mensaje", msjOk);
            request.setAttribute("tipoMensaje", "success");
        } else {
            request.setAttribute("mensaje", msjError);
            request.setAttribute("tipoMensaje", "danger");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }
}