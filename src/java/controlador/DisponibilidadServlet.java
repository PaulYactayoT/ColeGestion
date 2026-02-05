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
            // === CASOS PARA EDITAR ===
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
        
        // CORREGIDO: Apunta a tu archivo disponibilidadDocente.jsp
        request.getRequestDispatcher("disponibilidadDocente.jsp").forward(request, response);
    }

    private void guardarHorario(HttpServletRequest request, HttpServletResponse response, Profesor docente) 
            throws ServletException, IOException {
        
        try {
            int profesorId = docente.getId();
            int turnoId = Integer.parseInt(request.getParameter("cboTurno")); 
            String dia = request.getParameter("cboDia");
            String inicioStr = request.getParameter("txtInicio") + ":00"; 
            String finStr = request.getParameter("txtFin") + ":00";
            
            Time horaInicio = Time.valueOf(inicioStr);
            Time horaFin = Time.valueOf(finStr);

            if (validarHorario(turnoId, horaInicio, horaFin, request)) {
                Disponibilidad d = new Disponibilidad();
                d.setProfesorId(profesorId);
                d.setTurnoId(turnoId);
                d.setDiaSemana(dia);
                d.setHoraInicio(horaInicio);
                d.setHoraFin(horaFin);
                
                boolean exito = dao.registrarDisponibilidad(d);
                setMensaje(request, exito, "Horario registrado correctamente.", "Error al guardar.");
            }
            
        } catch (Exception e) {
            request.setAttribute("mensaje", "Error de datos: " + e.getMessage());
            request.setAttribute("tipoMensaje", "danger");
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

    // === LÓGICA DE EDICIÓN ===

    private void cargarDatosEdicion(HttpServletRequest request, HttpServletResponse response, Profesor docente) 
            throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            Disponibilidad d = dao.obtenerPorId(id);
            request.setAttribute("disponibilidadEditar", d); // Enviamos el objeto al JSP
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
            Time horaInicio = Time.valueOf(request.getParameter("txtInicio") + ":00");
            Time horaFin = Time.valueOf(request.getParameter("txtFin") + ":00");

            if (validarHorario(turnoId, horaInicio, horaFin, request)) {
                Disponibilidad d = new Disponibilidad();
                d.setId(id);
                d.setTurnoId(turnoId);
                d.setDiaSemana(dia);
                d.setHoraInicio(horaInicio);
                d.setHoraFin(horaFin);

                boolean exito = dao.actualizarDisponibilidad(d);
                setMensaje(request, exito, "Horario actualizado correctamente.", "Error al actualizar.");
            } else {
                // Si falla la validación, mantenemos los datos en el formulario
                Disponibilidad dError = new Disponibilidad();
                dError.setId(id); dError.setTurnoId(turnoId); dError.setDiaSemana(dia);
                dError.setHoraInicio(horaInicio); dError.setHoraFin(horaFin);
                request.setAttribute("disponibilidadEditar", dError);
            }

        } catch (Exception e) {
            request.setAttribute("mensaje", "Error: " + e.getMessage());
            request.setAttribute("tipoMensaje", "danger");
        }
        listarHorarios(request, response, docente);
    }

    // Método auxiliar para no repetir validaciones
    private boolean validarHorario(int turnoId, Time inicio, Time fin, HttpServletRequest request) {
        if (!fin.after(inicio)) {
            request.setAttribute("mensaje", "La hora Fin debe ser mayor a Inicio.");
            request.setAttribute("tipoMensaje", "danger");
            return false;
        }
        if (turnoId == 1) { // Mañana 08-13
            if (inicio.before(Time.valueOf("08:00:00")) || fin.after(Time.valueOf("13:00:00"))) {
                request.setAttribute("mensaje", "Turno MAÑANA es de 08:00 a 13:00.");
                request.setAttribute("tipoMensaje", "danger");
                return false;
            }
        } else if (turnoId == 2) { // Tarde 13-18
            if (inicio.before(Time.valueOf("13:00:00")) || fin.after(Time.valueOf("18:00:00"))) {
                request.setAttribute("mensaje", "Turno TARDE es de 13:00 a 18:00.");
                request.setAttribute("tipoMensaje", "danger");
                return false;
            }
        }
        return true;
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