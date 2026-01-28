/*
 * SERVLET PARA DEPURACION Y DIAGNOSTICO DEL SISTEMA
 * 
 * Proposito: Probar funcionalidades especificas y verificar datos en sesion
 * Uso: Solo para desarrollo, no usar en produccion
 */
package controlador;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import modelo.Padre;
import modelo.Asistencia;
import modelo.AsistenciaDAO;

@WebServlet("/DebugServlet")
public class DebugServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Padre padre = (Padre) session.getAttribute("padre");
        
        response.setContentType("text/plain");
        PrintWriter out = response.getWriter();
        
        out.println("=== DEBUG INFO ===");
        out.println("Padre en sesion: " + (padre != null ? "SI" : "NO"));
        if (padre != null) {
            out.println("Padre ID: " + padre.getId());
            out.println("Alumno ID: " + padre.getAlumnoId());
            out.println("Username: " + padre.getUsername());
            out.println("Alumno Nombre: " + padre.getAlumnoNombre());
        } else {
            out.println("ERROR: No hay padre en sesion");
            return;
        }
        
        // Probar la consulta directamente
        try {
            AsistenciaDAO dao = new AsistenciaDAO();
            List<Asistencia> ausencias = dao.obtenerAusenciasPorJustificar(padre.getAlumnoId());
            out.println("Ausencias encontradas: " + ausencias.size());
            
            for (Asistencia a : ausencias) {
                out.println(" - ID: " + a.getId() + ", Fecha: " + a.getFecha() + 
                           ", Curso: " + a.getCursoNombre() + ", Estado: " + a.getEstado());
            }
        } catch (Exception e) {
            out.println("Error en consulta: " + e.getMessage());
            e.printStackTrace(out);
        }
    }
}