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
        
        System.out.println("=".repeat(60));
        System.out.println("📘 DisponibilidadServlet (DOCENTE) - Petición recibida");
        System.out.println("=".repeat(60));
        
        HttpSession session = request.getSession();

        // ✅ VALIDACIÓN DE ROL: Solo docentes pueden acceder
        String rol = (String) session.getAttribute("rol");
        if (rol == null) {
            System.out.println("❌ No hay sesión activa, redirigiendo...");
            response.sendRedirect("index.jsp");
            return;
        }
        if (!"docente".equals(rol)) {
            System.out.println("❌ ACCESO DENEGADO: Rol '" + rol + "' intentó acceder a DisponibilidadServlet");
            response.sendRedirect("acceso_denegado.jsp");
            return;
        }

        Profesor docente = (Profesor) session.getAttribute("docente");

        if (docente == null) {
            System.out.println("❌ No hay sesión de docente, redirigiendo...");
            response.sendRedirect("index.jsp");
            return;
        }

        System.out.println("👤 Docente: " + docente.getNombres() + " (ID: " + docente.getId() + ")");

        String accion = request.getParameter("accion");
        if (accion == null) {
            accion = "listar";
        }
        
        System.out.println("📋 Acción: " + accion);

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
        
        System.out.println("=".repeat(60));
    }

    private void listarHorarios(HttpServletRequest request, HttpServletResponse response, Profesor docente) 
            throws ServletException, IOException {
        
        int profesorId = docente.getId();
        
        System.out.println("📂 Consultando horarios del profesor ID: " + profesorId);
        
        // ✅ CRÍTICO: SIEMPRE consulta la BD, NUNCA usa caché
        List<Disponibilidad> lista = dao.listarPorProfesor(profesorId);
        
        System.out.println("📊 Total de horarios encontrados: " + (lista != null ? lista.size() : 0));
        
        if (lista != null && !lista.isEmpty()) {
            System.out.println("📝 Detalle de horarios:");
            for (Disponibilidad d : lista) {
                System.out.println("   - ID: " + d.getId() + 
                                 " | Día: " + d.getDiaSemana() + 
                                 " | Estado: " + d.getEstado());
            }
        }
        
        // ✅ IMPORTANTE: Pasa la lista al JSP
        request.setAttribute("listaHorarios", lista);
        
        System.out.println("✅ Lista enviada al JSP");
        
        request.getRequestDispatcher("disponibilidadDocente.jsp").forward(request, response);
    }

    private void guardarHorario(HttpServletRequest request, HttpServletResponse response, Profesor docente) 
            throws ServletException, IOException {
        
        try {
            int profesorId = docente.getId();
            int turnoId = Integer.parseInt(request.getParameter("cboTurno")); 
            String dia = request.getParameter("cboDia");
            
            String inicioStr = request.getParameter("txtInicio");
            String finStr = request.getParameter("txtFin");
            
            if (inicioStr != null && inicioStr.length() == 5) { inicioStr += ":00"; }
            if (finStr != null && finStr.length() == 5) { finStr += ":00"; }
            
            Time horaInicio = Time.valueOf(inicioStr);
            Time horaFin = Time.valueOf(finStr);

            if (validarHorario(turnoId, horaInicio, horaFin, request)) {
                Disponibilidad d = new Disponibilidad();
                d.setProfesorId(profesorId);
                d.setTurnoId(turnoId);
                d.setDiaSemana(dia);
                d.setHoraInicio(horaInicio);
                d.setHoraFin(horaFin);
                
                // FIX: usar mensaje real del procedimiento almacenado
                DisponibilidadDAO.ResultadoDisponibilidad resultado = dao.registrarDisponibilidadConMensaje(d);
                request.setAttribute("mensaje", resultado.mensaje);
                request.setAttribute("tipoMensaje", resultado.exito ? "success" : "danger");
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
            
            String inicioStr = request.getParameter("txtInicio");
            String finStr = request.getParameter("txtFin");
            
            if (inicioStr != null && inicioStr.length() == 5) { inicioStr += ":00"; }
            if (finStr != null && finStr.length() == 5) { finStr += ":00"; }
            
            Time horaInicio = Time.valueOf(inicioStr);
            Time horaFin = Time.valueOf(finStr);

            if (validarHorario(turnoId, horaInicio, horaFin, request)) {
                Disponibilidad d = new Disponibilidad();
                d.setId(id);
                d.setTurnoId(turnoId);
                d.setDiaSemana(dia);
                d.setHoraInicio(horaInicio);
                d.setHoraFin(horaFin);

                boolean exito = dao.actualizarDisponibilidad(d);
                
                setMensaje(request, exito, "Horario corregido y re-enviado a revisión.", "Error al actualizar.");
            } else {
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

    private boolean validarHorario(int turnoId, Time inicio, Time fin, HttpServletRequest request) {
        if (!fin.after(inicio)) {
            request.setAttribute("mensaje", "Error: La hora Fin debe ser mayor a la hora de Inicio.");
            request.setAttribute("tipoMensaje", "danger");
            return false;
        }

        if (turnoId == 1) {
            if (inicio.before(Time.valueOf("08:00:00")) || fin.after(Time.valueOf("13:00:00"))) {
                request.setAttribute("mensaje", "Error: El turno MAÑANA es estrictamente de 08:00 a 13:00.");
                request.setAttribute("tipoMensaje", "danger");
                return false;
            }
        } else if (turnoId == 2) {
            if (inicio.before(Time.valueOf("13:00:00")) || fin.after(Time.valueOf("18:00:00"))) {
                request.setAttribute("mensaje", "Error: El turno TARDE es estrictamente de 13:00 a 18:00.");
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