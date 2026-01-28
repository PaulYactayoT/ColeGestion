/*
 * SERVLET DE PRUEBA PARA VERIFICAR RECEPCION DE DATOS DE ASISTENCIA
 * 
 * Proposito: Probar el envio de datos desde el formulario de asistencias
 * Uso: Solo para desarrollo, remover en produccion
 */
package controlador;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/TestAsistenciaServlet")
public class TestAsistenciaServlet extends HttpServlet {
    
    /**
     * METODO POST - PROBAR RECEPCION DE DATOS DE ASISTENCIA
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("TEST SERVLET INICIADO");
        System.out.println("Parametros recibidos:");
        
        // Mostrar todos los parametros recibidos
        request.getParameterMap().forEach((key, values) -> {
            System.out.println("   " + key + ": " + String.join(", ", values));
        });
        
        // Mostrar el JSON de alumnos (parcial por logs)
        String alumnosJson = request.getParameter("alumnos_json");
        System.out.println("alumnos_json: " + (alumnosJson != null ? alumnosJson.substring(0, Math.min(200, alumnosJson.length())) + "..." : "NULL"));
        
        // Responder con JSON de exito
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        PrintWriter out = response.getWriter();
        out.print("{\"status\":\"success\",\"message\":\"Test recibido correctamente\"}");
        out.flush();
        
        System.out.println("TEST SERVLET FINALIZADO");
    }
}