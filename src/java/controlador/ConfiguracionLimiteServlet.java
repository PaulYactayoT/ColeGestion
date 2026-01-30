package controlador;

import modelo.*;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.*;
import java.time.LocalTime;

/**
 * Servlet para gestionar configuraciones de límites de edición
 */
@WebServlet("/ConfiguracionLimiteServlet")
public class ConfiguracionLimiteServlet extends HttpServlet {
    
    private ConfiguracionLimiteDAO configuracionDAO;
    
    @Override
    public void init() throws ServletException {
        configuracionDAO = new ConfiguracionLimiteDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String accion = request.getParameter("accion");
        
        if (accion == null) {
            response.sendRedirect("configurarLimitesEdicion.jsp");
            return;
        }
        
        switch (accion) {
            case "eliminar":
                eliminarConfiguracion(request, response);
                break;
            default:
                response.sendRedirect("configurarLimitesEdicion.jsp");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String accion = request.getParameter("accion");
        
        if (accion == null) {
            response.sendRedirect("configurarLimitesEdicion.jsp");
            return;
        }
        
        switch (accion) {
            case "crear":
                crearConfiguracion(request, response);
                break;
            case "actualizar":
                actualizarConfiguracion(request, response);
                break;
            default:
                response.sendRedirect("configurarLimitesEdicion.jsp");
        }
    }
    
    /**
     * CREAR NUEVA CONFIGURACIÓN
     */
    private void crearConfiguracion(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            String rol = (String) session.getAttribute("rol");
            
            if (rol == null || (!rol.equals("admin") && !rol.equals("docente"))) {
                response.sendRedirect("login.jsp");
                return;
            }
            
            // Obtener parámetros
            int turnoId = Integer.parseInt(request.getParameter("turnoId"));
            String diaSemana = request.getParameter("diaSemana");
            String horaInicioClaseStr = request.getParameter("horaInicioClase");
            int limiteEdicionMinutos = Integer.parseInt(request.getParameter("limiteEdicionMinutos"));
            String cursoIdStr = request.getParameter("cursoId");
            String descripcion = request.getParameter("descripcion");
            
            int cursoId = cursoIdStr != null ? Integer.parseInt(cursoIdStr) : 0;
            LocalTime horaInicioClase = LocalTime.parse(horaInicioClaseStr);
            
            // Crear objeto ConfiguracionLimiteEdicion
            ConfiguracionLimiteEdicion config = new ConfiguracionLimiteEdicion();
            config.setTurnoId(turnoId);
            config.setDiaSemanaFromString(diaSemana);
            config.setHoraInicioClase(horaInicioClase);
            config.setLimiteEdicionMinutos(limiteEdicionMinutos);
            config.setCursoId(cursoId);
            config.setAplicaTodosCursos(cursoId == 0);
            config.setDescripcion(descripcion);
            
            // Guardar en base de datos
            boolean resultado = configuracionDAO.crearConfiguracion(config);
            
            if (resultado) {
                response.sendRedirect("configurarLimitesEdicion.jsp?turnoId=" + turnoId + 
                                    "&mensaje=Configuración creada exitosamente&tipo=success");
            } else {
                response.sendRedirect("configurarLimitesEdicion.jsp?turnoId=" + turnoId + 
                                    "&mensaje=Error al crear configuración&tipo=error");
            }
            
        } catch (Exception e) {
            System.out.println(" Error al crear configuración: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("configurarLimitesEdicion.jsp?mensaje=Error: " + 
                                e.getMessage() + "&tipo=error");
        }
    }
    
    /**
     * ACTUALIZAR CONFIGURACIÓN
     */
    private void actualizarConfiguracion(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            String rol = (String) session.getAttribute("rol");
            
            if (rol == null || (!rol.equals("admin") && !rol.equals("docente"))) {
                response.sendRedirect("login.jsp");
                return;
            }
            
            // Obtener parámetros
            int id = Integer.parseInt(request.getParameter("id"));
            int turnoId = Integer.parseInt(request.getParameter("turnoId"));
            String diaSemana = request.getParameter("diaSemana");
            String horaInicioClaseStr = request.getParameter("horaInicioClase");
            int limiteEdicionMinutos = Integer.parseInt(request.getParameter("limiteEdicionMinutos"));
            String cursoIdStr = request.getParameter("cursoId");
            String descripcion = request.getParameter("descripcion");
            
            int cursoId = cursoIdStr != null ? Integer.parseInt(cursoIdStr) : 0;
            LocalTime horaInicioClase = LocalTime.parse(horaInicioClaseStr);
            
            // Crear objeto ConfiguracionLimiteEdicion
            ConfiguracionLimiteEdicion config = new ConfiguracionLimiteEdicion();
            config.setId(id);
            config.setTurnoId(turnoId);
            config.setDiaSemanaFromString(diaSemana);
            config.setHoraInicioClase(horaInicioClase);
            config.setLimiteEdicionMinutos(limiteEdicionMinutos);
            config.setCursoId(cursoId);
            config.setAplicaTodosCursos(cursoId == 0);
            config.setDescripcion(descripcion);
            
            // Actualizar en base de datos
            boolean resultado = configuracionDAO.actualizarConfiguracion(config);
            
            if (resultado) {
                response.sendRedirect("configurarLimitesEdicion.jsp?turnoId=" + turnoId + 
                                    "&mensaje=Configuración actualizada exitosamente&tipo=success");
            } else {
                response.sendRedirect("configurarLimitesEdicion.jsp?turnoId=" + turnoId + 
                                    "&mensaje=Error al actualizar configuración&tipo=error");
            }
            
        } catch (Exception e) {
            System.out.println(" Error al actualizar configuración: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("configurarLimitesEdicion.jsp?mensaje=Error: " + 
                                e.getMessage() + "&tipo=error");
        }
    }
    
    /**
     * ELIMINAR CONFIGURACIÓN
     */
    private void eliminarConfiguracion(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            HttpSession session = request.getSession();
            String rol = (String) session.getAttribute("rol");
            
            if (rol == null || (!rol.equals("admin") && !rol.equals("docente"))) {
                response.sendRedirect("login.jsp");
                return;
            }
            
            int id = Integer.parseInt(request.getParameter("id"));
            int turnoId = Integer.parseInt(request.getParameter("turnoId"));
            
            boolean resultado = configuracionDAO.eliminarConfiguracion(id);
            
            if (resultado) {
                response.sendRedirect("configurarLimitesEdicion.jsp?turnoId=" + turnoId + 
                                    "&mensaje=Configuración eliminada exitosamente&tipo=success");
            } else {
                response.sendRedirect("configurarLimitesEdicion.jsp?turnoId=" + turnoId + 
                                    "&mensaje=Error al eliminar configuración&tipo=error");
            }
            
        } catch (Exception e) {
            System.out.println(" Error al eliminar configuración: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("configurarLimitesEdicion.jsp?mensaje=Error: " + 
                                e.getMessage() + "&tipo=error");
        }
    }
}