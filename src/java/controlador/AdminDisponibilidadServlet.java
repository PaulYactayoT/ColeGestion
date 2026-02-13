package controlador;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import modelo.Disponibilidad;
import modelo.DisponibilidadDAO;

@WebServlet(name = "AdminDisponibilidadServlet", urlPatterns = {"/AdminDisponibilidadServlet"})
public class AdminDisponibilidadServlet extends HttpServlet {
    
    private DisponibilidadDAO dao = new DisponibilidadDAO();
    
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("=".repeat(60));
        System.out.println("PETICIÓN RECIBIDA EN AdminDisponibilidadServlet");
        System.out.println("=".repeat(60));
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            System.out.println("Sesión inválida, redirigiendo a login");
            response.sendRedirect("index.jsp");
            return;
        }
        
        String accion = request.getParameter("accion");
        if (accion == null) accion = "listar";
        
        System.out.println("Acción solicitada: " + accion);
        System.out.println("Parámetros recibidos:");
        System.out.println("   - id: " + request.getParameter("id"));
        System.out.println("   - observacion: " + request.getParameter("observacion"));
        System.out.println("-".repeat(60));
        
        switch (accion) {
            case "listar":
                listarPendientes(request, response);
                break;
                
            case "aprobar":
                System.out.println("Entrando a APROBAR...");
                cambiarEstado(request, response, "APROBADO");
                break;
                
            case "rechazar":
                System.out.println("Entrando a RECHAZAR...");
                cambiarEstado(request, response, "RECHAZADO");
                break;
                
            default:
                System.out.println("Acción desconocida, listando pendientes");
                listarPendientes(request, response);
        }
    }
    
    private void listarPendientes(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        System.out.println("Listando horarios pendientes...");
        List<Disponibilidad> lista = dao.listarPendientes();
        System.out.println("Total pendientes encontrados: " + (lista != null ? lista.size() : 0));
        
        request.setAttribute("listaPendientes", lista);
        request.getRequestDispatcher("gestion_disponibilidad.jsp").forward(request, response);
        System.out.println("Respuesta enviada a JSP");
        System.out.println("=".repeat(60));
    }
    
    private void cambiarEstado(HttpServletRequest request, HttpServletResponse response, String estado) 
            throws ServletException, IOException {
        
        System.out.println("INICIANDO CAMBIO DE ESTADO");
        System.out.println("   Estado objetivo: " + estado);
        
        try {
            String idParam = request.getParameter("id");
            String obsParam = request.getParameter("observacion");
            
            System.out.println("Parámetros capturados:");
            System.out.println("   - id (raw): " + idParam);
            System.out.println("   - observacion (raw): " + obsParam);
            
            if (idParam == null || idParam.trim().isEmpty()) {
                System.err.println("ERROR CRÍTICO: ID es NULL o vacío");
                request.setAttribute("mensaje", "Error: No se recibió el ID del horario.");
                request.setAttribute("tipoMensaje", "danger");
                listarPendientes(request, response);
                return;
            }
            
            int id = Integer.parseInt(idParam);
            String obs = (obsParam == null || obsParam.trim().isEmpty()) ? "-" : obsParam;
            
            System.out.println("Parámetros procesados:");
            System.out.println("   - ID (int): " + id);
            System.out.println("   - Observación (string): " + obs);
            System.out.println("   - Estado (string): " + estado);
            
            System.out.println("Llamando a dao.evaluarDisponibilidad(" + id + ", \"" + estado + "\", \"" + obs + "\")");
            
            boolean exito = dao.evaluarDisponibilidad(id, estado, obs);
            
            System.out.println("Respuesta del DAO: " + (exito ? "✅ TRUE (éxito)" : "❌ FALSE (falló)"));
            
            if (exito) {
                System.out.println("ESTADO CAMBIADO EXITOSAMENTE");
                request.setAttribute("mensaje", "Solicitud procesada correctamente (" + estado + ").");
                request.setAttribute("tipoMensaje", "success");
            } else {
                System.err.println("ERROR: El DAO retornó FALSE");
                request.setAttribute("mensaje", "Error al procesar. Verifique la base de datos.");
                request.setAttribute("tipoMensaje", "danger");
            }
            
        } catch (NumberFormatException e) {
            System.err.println("ERROR DE FORMATO: ID no es un número válido");
            System.err.println("   Excepción: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("mensaje", "Error: ID inválido.");
            request.setAttribute("tipoMensaje", "danger");
        } catch (Exception e) {
            System.err.println("ERROR INESPERADO");
            System.err.println("   Excepción: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("mensaje", "Error inesperado: " + e.getMessage());
            request.setAttribute("tipoMensaje", "danger");
        }
        
        System.out.println("Redirigiendo a lista de pendientes...");
        listarPendientes(request, response);
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        System.out.println("Método: GET");
        processRequest(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        System.out.println("Método: POST");
        processRequest(request, response);
    }
}