package controlador;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import modelo.Disponibilidad;
import modelo.DisponibilidadDAO;

@WebServlet(name = "AdminDisponibilidadServlet", urlPatterns = {"/AdminDisponibilidadServlet"})
public class AdminDisponibilidadServlet extends HttpServlet {

    private DisponibilidadDAO dao = new DisponibilidadDAO();

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String accion = request.getParameter("accion");
        if (accion == null) accion = "listar";

        switch (accion) {
            case "listar":
                listarPendientes(request, response);
                break;
                
            case "aprobar":
                // Lógica para el botón VERDE
                cambiarEstado(request, response, "APROBADO");
                break;
                
            case "rechazar":
                // Lógica para el botón ROJO
                cambiarEstado(request, response, "RECHAZADO");
                break;
                
            default:
                listarPendientes(request, response);
        }
    }

    private void listarPendientes(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Obtenemos la lista del DAO
        List<Disponibilidad> lista = dao.listarPendientes();
        
        // La enviamos al JSP
        request.setAttribute("listaPendientes", lista);
        request.getRequestDispatcher("gestion_disponibilidad.jsp").forward(request, response);
    }

    private void cambiarEstado(HttpServletRequest request, HttpServletResponse response, String estado) 
            throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String obs = request.getParameter("observacion"); 
            
            // Si no hay observación, ponemos un guion
            if(obs == null || obs.trim().isEmpty()) obs = "-";

            // Llamamos al DAO para actualizar la BD
            boolean exito = dao.evaluarDisponibilidad(id, estado, obs);
            
            String mensaje = exito ? "Solicitud procesada correctamente (" + estado + ")." : "Error al procesar.";
            String tipo = exito ? "success" : "danger";
            
            request.setAttribute("mensaje", mensaje);
            request.setAttribute("tipoMensaje", tipo);
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        // Recargamos la lista para ver que el registro desaparece (porque ya no es pendiente)
        listarPendientes(request, response);
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