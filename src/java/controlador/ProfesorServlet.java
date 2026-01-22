package controlador;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

import modelo.Profesor;
import modelo.ProfesorDAO;

@WebServlet("/ProfesorServlet")
public class ProfesorServlet extends HttpServlet {

    ProfesorDAO dao = new ProfesorDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
 // AÑADIR ESTO AL INICIO DEL MÉTODO doPost
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    response.setContentType("text/html; charset=UTF-8");

    
        HttpSession session = request.getSession();
        String rol = (String) session.getAttribute("rol");

        // VALIDACIÓN: Solo admin puede acceder a ProfesorServlet
        if (!"admin".equals(rol)) {
            System.out.println("ACCESO DENEGADO: Rol " + rol + " intentó acceder a ProfesorServlet");
            response.sendRedirect("acceso_denegado.jsp");
            return;
        }

        String accion = request.getParameter("accion");

        // Acción por defecto: listar todos los profesores
        if (accion == null || accion.equals("listar")) {
            request.setAttribute("lista", dao.listar());
            request.getRequestDispatcher("profesores.jsp").forward(request, response);
            return;
        }

        // Mostrar formulario para nuevo profesor
        if ("nuevo".equals(accion)) {
            request.getRequestDispatcher("profesorForm.jsp").forward(request, response);
            return;
        }

        // Ejecutar acción específica según parámetro
        switch (accion) {
            case "editar":
                int idEditar = Integer.parseInt(request.getParameter("id"));
                Profesor p = dao.obtenerPorId(idEditar);
                if (p != null) {
                    request.setAttribute("profesor", p);
                    request.getRequestDispatcher("profesorForm.jsp").forward(request, response);
                } else {
                    session.setAttribute("error", "Profesor no encontrado");
                    response.sendRedirect("ProfesorServlet");
                }
                break;

            case "eliminar":
                int idEliminar = Integer.parseInt(request.getParameter("id"));
                boolean eliminado = dao.eliminar(idEliminar);
                if (eliminado) {
                    session.setAttribute("mensaje", "Profesor eliminado correctamente");
                } else {
                    session.setAttribute("error", "Error al eliminar el profesor");
                }
                response.sendRedirect("ProfesorServlet");
                break;

            default:
                response.sendRedirect("ProfesorServlet");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String rol = (String) session.getAttribute("rol");
   request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    response.setContentType("text/html; charset=UTF-8");
        // VALIDACIÓN: Solo admin puede crear/actualizar profesores
        if (!"admin".equals(rol)) {
            System.out.println("ACCESO DENEGADO POST: Rol " + rol + " intentó modificar profesores");
            response.sendRedirect("acceso_denegado.jsp");
            return;
        }

        try {
            // Determinar si es creación (id=0) o actualización (id>0)
            int id = request.getParameter("id") != null && !request.getParameter("id").isEmpty()
                    ? Integer.parseInt(request.getParameter("id")) : 0;

            // Construir objeto profesor con datos del formulario
            Profesor p = new Profesor();
            p.setNombres(request.getParameter("nombres"));
            p.setApellidos(request.getParameter("apellidos"));
            p.setCorreo(request.getParameter("correo"));
            p.setDni(request.getParameter("dni"));
            p.setTelefono(request.getParameter("telefono"));
            p.setDireccion(request.getParameter("direccion"));
            p.setEspecialidad(request.getParameter("especialidad"));
            p.setCodigoProfesor(request.getParameter("codigo_profesor"));
            p.setUsername(request.getParameter("username"));
            
            // Convertir fecha de nacimiento de String a java.sql.Date
            String fechaNacStr = request.getParameter("fecha_nacimiento");
            if (fechaNacStr != null && !fechaNacStr.isEmpty()) {
                try {
                    LocalDate fechaNac = LocalDate.parse(fechaNacStr);
                    p.setFechaNacimiento(java.sql.Date.valueOf(fechaNac));
                } catch (Exception e) {
                    System.out.println("Error al parsear fecha de nacimiento: " + fechaNacStr);
                }
            }
            
            // Convertir fecha de contratación
            String fechaContStr = request.getParameter("fecha_contratacion");
            if (fechaContStr != null && !fechaContStr.isEmpty()) {
                try {
                    LocalDate fechaCont = LocalDate.parse(fechaContStr);
                    p.setFechaContratacion(java.sql.Date.valueOf(fechaCont));
                } catch (Exception e) {
                    System.out.println("Error al parsear fecha de contratación: " + fechaContStr);
                }
            }
            
            p.setEstado(request.getParameter("estado"));

            // Validar datos obligatorios
            if (p.getNombres() == null || p.getNombres().trim().isEmpty() ||
                p.getApellidos() == null || p.getApellidos().trim().isEmpty()) {
                session.setAttribute("error", "Nombre y apellidos son obligatorios");
                response.sendRedirect("ProfesorServlet?accion=" + (id == 0 ? "nuevo" : "editar&id=" + id));
                return;
            }

            // Ejecutar operación en base de datos
            boolean resultado;
            if (id == 0) {
                System.out.println("Creando nuevo profesor: " + p.getNombres() + " " + p.getApellidos());
                resultado = dao.crear(p);
                if (resultado) {
                    System.out.println("Nuevo profesor creado por admin: " + p.getNombres() + " " + p.getApellidos());
                    session.setAttribute("mensaje", "Profesor creado correctamente");
                } else {
                    session.setAttribute("error", "Error al crear el profesor. Verifique que el correo o DNI no existan.");
                }
            } else {
                p.setId(id);
                System.out.println("Actualizando profesor ID " + id + ": " + p.getNombres() + " " + p.getApellidos());
                resultado = dao.actualizar(p);
                if (resultado) {
                    System.out.println("Profesor actualizado por admin: " + p.getNombres() + " " + p.getApellidos());
                    session.setAttribute("mensaje", "Profesor actualizado correctamente");
                } else {
                    session.setAttribute("error", "Error al actualizar el profesor");
                }
            }

            // Redirigir a la lista principal de profesores
            response.sendRedirect("ProfesorServlet");

        } catch (Exception e) {
            System.out.println("Error en ProfesorServlet doPost:");
            e.printStackTrace();
            session.setAttribute("error", "Error al procesar la solicitud: " + e.getMessage());
            response.sendRedirect("ProfesorServlet");
        }
    }
}