package controlador;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Collection;
import java.util.Scanner;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.io.File;
import java.nio.file.Paths;
import java.sql.Time;
import java.time.LocalDate;

import modelo.Disponibilidad;
import modelo.Profesor;
import modelo.ProfesorDAO;
import modelo.ProfesorNivelArea;
import modelo.Turno;
import modelo.Area;

@WebServlet(name = "ProfesorServlet", urlPatterns = {"/ProfesorServlet"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class ProfesorServlet extends HttpServlet {

    ProfesorDAO dao = new ProfesorDAO();

    // ==========================================
    // ✅ HELPER PARA LEER TEXTOS EN MULTIPART
    // ==========================================
    private String getValue(HttpServletRequest request, Part part) throws IOException {
        if (part == null) return null;
        try (InputStream is = part.getInputStream()) {
            Scanner s = new Scanner(is, StandardCharsets.UTF_8.name());
            return s.useDelimiter("\\A").hasNext() ? s.next() : "";
        }
    }

    private String getParam(HttpServletRequest request, String name) {
        try {
            // Intentar método estándar primero
            String val = request.getParameter(name);
            if (val != null) return val;
            
            // Si es multipart y falló el estándar, buscar en parts
            if (request.getContentType() != null && request.getContentType().toLowerCase().startsWith("multipart/")) {
                Part part = request.getPart(name);
                if (part != null && part.getSize() > 0 && part.getSubmittedFileName() == null) { // Es campo de texto
                    return getValue(request, part);
                }
            }
        } catch (Exception e) {}
        return null;
    }
    
    // Helper para arrays (checkboxes/selects múltiples)
    private String[] getParamValues(HttpServletRequest request, String name) {
        try {
            String[] vals = request.getParameterValues(name);
            if (vals != null) return vals;

            if (request.getContentType() != null && request.getContentType().toLowerCase().startsWith("multipart/")) {
                List<String> values = new ArrayList<>();
                Collection<Part> parts = request.getParts();
                for (Part part : parts) {
                    if (name.equals(part.getName()) && part.getSubmittedFileName() == null) {
                        values.add(getValue(request, part));
                    }
                }
                if (!values.isEmpty()) return values.toArray(new String[0]);
            }
        } catch (Exception e) {}
        return null;
    }
    // ==========================================

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        HttpSession session = request.getSession();
        String rol = (String) session.getAttribute("rol");

        // Acceso controlado por SecurityFilter según módulos asignados

        String accion = request.getParameter("accion");

        if (accion == null || accion.equals("listar")) {
            String terminoBusqueda = request.getParameter("txtBuscar");
            List<Profesor> lista;

            if (terminoBusqueda != null && !terminoBusqueda.trim().isEmpty()) {
                lista = dao.buscar(terminoBusqueda.trim());
            } else {
                lista = dao.listar();
            }

            request.setAttribute("lista", lista);
            request.getRequestDispatcher("profesores.jsp").forward(request, response);
            return;
        }

        if ("nuevo".equals(accion)) {
            List<Turno> turnos = dao.listarTurnos();
            List<Area> areas = dao.listarAreas();
            request.setAttribute("turnos", turnos);
            request.setAttribute("areas", areas);
            request.getRequestDispatcher("profesorForm.jsp").forward(request, response);
            return;
        }

        switch (accion) {
            case "editar":
                try {
                    int idEditar = Integer.parseInt(request.getParameter("id"));
                    Profesor p = dao.obtenerPorId(idEditar);
                    if (p != null) {
                        List<ProfesorNivelArea> asignaciones = dao.obtenerAsignaciones(idEditar);
                        p.setAsignaciones(asignaciones);
                        
                        List<Turno> turnos = dao.listarTurnos();
                        List<Area> areas = dao.listarAreas();
                        
                        request.setAttribute("profesor", p);
                        request.setAttribute("turnos", turnos);
                        request.setAttribute("areas", areas);
                        request.getRequestDispatcher("profesorForm.jsp").forward(request, response);
                    } else {
                        session.setAttribute("error", "Profesor no encontrado");
                        response.sendRedirect("ProfesorServlet?accion=listar");
                    }
                } catch (Exception e) {
                    response.sendRedirect("ProfesorServlet?accion=listar");
                }
                break;

            case "eliminar":
                try {
                    int idEliminar = Integer.parseInt(request.getParameter("id"));
                    if (dao.eliminar(idEliminar)) {
                        session.setAttribute("mensaje", "Profesor eliminado correctamente");
                    } else {
                        session.setAttribute("error", "Error al eliminar profesor");
                    }
                } catch (Exception e) {
                    session.setAttribute("error", "ID inválido");
                }
                response.sendRedirect("ProfesorServlet?accion=listar");
                break;
                
            case "ver":
                try {
                    int idVer = Integer.parseInt(request.getParameter("id"));
                    Profesor pVer = dao.obtenerPorId(idVer);
                    if (pVer != null) {
                        List<ProfesorNivelArea> asignaciones = dao.obtenerAsignaciones(idVer);
                        pVer.setAsignaciones(asignaciones);
                        request.setAttribute("profesor", pVer);
                        request.getRequestDispatcher("profesorDetalle.jsp").forward(request, response);
                    } else {
                        response.sendRedirect("ProfesorServlet?accion=listar");
                    }
                } catch (Exception e) {
                    response.sendRedirect("ProfesorServlet?accion=listar");
                }
                break;

            default:
                response.sendRedirect("ProfesorServlet?accion=listar");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String rol = (String) session.getAttribute("rol");
        
        request.setCharacterEncoding("UTF-8");
        
        // Acceso controlado por SecurityFilter según módulos asignados

        try {
            // ✅ USAMOS LA FUNCIÓN getParam() PARA ASEGURAR QUE SE LEAN LOS DATOS AUN CON FOTO
            String idStr = getParam(request, "id");
            String accionForm = getParam(request, "accion");
            
            String nombres = getParam(request, "nombres");
            if (nombres != null) nombres = nombres.trim(); else nombres = "";
            
            String apellidos = getParam(request, "apellidos");
            if (apellidos != null) apellidos = apellidos.trim(); else apellidos = "";
            
            String correo = getParam(request, "correo");
            if (correo != null) correo = correo.trim(); else correo = "";
            
            String dni = getParam(request, "dni");
            if (dni != null) dni = dni.trim(); else dni = "";
            
            String telefono = getParam(request, "telefono");
            if (telefono != null) telefono = telefono.trim(); else telefono = "";
            
            String direccion = getParam(request, "direccion");
            if (direccion != null) direccion = direccion.trim(); else direccion = "";
            
            String fechaNacimientoStr = getParam(request, "fecha_nacimiento");
            String turnoIdStr = getParam(request, "turno_id");
            String codigoProfesor = getParam(request, "codigo_profesor");
            String fechaContratacionStr = getParam(request, "fecha_contratacion");
            String estado = getParam(request, "estado");
            String username = getParam(request, "username"); 
            String totalDispStr = getParam(request, "total_disponibilidades"); // Para método aux
            
            // ========== LÓGICA DE FOTO ========== 
            String nombreFoto = null;
            try {
                if (request.getContentType() != null && request.getContentType().toLowerCase().startsWith("multipart/")) {
                    Part filePart = request.getPart("foto"); 
                    if (filePart != null && filePart.getSize() > 0 && filePart.getSubmittedFileName() != null && !filePart.getSubmittedFileName().isEmpty()) {
                        String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                        String ext = "";
                        int i = fileName.lastIndexOf('.');
                        if (i > 0) { ext = fileName.substring(i); }
                        
                        nombreFoto = "prof_" + System.currentTimeMillis() + ext;
                        
                        String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
                        File uploadDir = new File(uploadPath);
                        if (!uploadDir.exists()) uploadDir.mkdir();
                        
                        filePart.write(uploadPath + File.separator + nombreFoto);
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            // ===================================

            // 2. Crear objeto Profesor
            Profesor profesor = new Profesor();
            Integer id = null;
            if (idStr != null && !idStr.trim().isEmpty()) {
                try {
                    id = Integer.parseInt(idStr);
                    profesor.setId(id);
                } catch(NumberFormatException e) {}
            }

            profesor.setNombres(nombres);
            profesor.setApellidos(apellidos);
            profesor.setCorreo(correo);
            profesor.setDni(dni);
            profesor.setTelefono(telefono);
            profesor.setDireccion(direccion);
            
            if (nombreFoto != null) {
                profesor.setFoto(nombreFoto);
            }

            if (turnoIdStr != null && !turnoIdStr.isEmpty()) {
                try { profesor.setTurnoId(Integer.parseInt(turnoIdStr)); } catch(Exception e){}
            }

            if (fechaNacimientoStr != null && !fechaNacimientoStr.isEmpty()) {
                try {
                    profesor.setFechaNacimiento(java.sql.Date.valueOf(LocalDate.parse(fechaNacimientoStr)));
                } catch (Exception e) {}
            }

            // 3. Procesar Asignaciones Múltiples (USANDO HELPER ROBUSTO)
            List<ProfesorNivelArea> asignaciones = parsearAsignaciones(request);
            
            // Validación
            if (asignaciones.isEmpty()) {
                session.setAttribute("error", "Debe seleccionar al menos un nivel y área para el profesor");
                // ✅ REDIRECCIÓN CORREGIDA: Si tenemos ID o la acción es actualizar, volvemos a editar
                if (id != null || (accionForm != null && accionForm.equals("actualizar"))) {
                    String idFinal = (id != null) ? id.toString() : idStr;
                    response.sendRedirect("ProfesorServlet?accion=editar&id=" + idFinal);
                } else {
                    response.sendRedirect("ProfesorServlet?accion=nuevo");
                }
                return;
            }
            
            profesor.setAsignaciones(asignaciones);
            
            // Datos principales
            ProfesorNivelArea principal = asignaciones.get(0);
            profesor.setNivel(principal.getNivel());
            profesor.setAreaId(principal.getAreaId());
            
            profesor.setCodigoProfesor(codigoProfesor != null ? codigoProfesor.trim() : "");

            if (fechaContratacionStr != null && !fechaContratacionStr.isEmpty()) {
                try {
                    profesor.setFechaContratacion(java.sql.Date.valueOf(LocalDate.parse(fechaContratacionStr)));
                } catch (Exception e) { }
            }

            profesor.setEstado(estado != null && !estado.isEmpty() ? estado : "ACTIVO");
            profesor.setUsername(username != null ? username.trim() : "");

            // 4. Capturar Disponibilidades (Pasamos el totalDispStr que ya leímos seguro)
            List<Disponibilidad> disponibilidades = capturarDisponibilidades(request, 0, totalDispStr);
            if (!disponibilidades.isEmpty()) {
                profesor.setDisponibilidades(disponibilidades);
            }

            // 5. Guardar o Actualizar
            boolean exito = false;

            if (id != null) {
                // ACTUALIZAR
                exito = dao.actualizar(profesor);
                if (exito) {
                    dao.guardarDisponibilidades(id, disponibilidades);
                    
                    for (ProfesorNivelArea asig : asignaciones) {
                        asig.setProfesorId(id);
                    }
                    dao.guardarAsignaciones(id, asignaciones);
                    
                    session.setAttribute("mensaje", "Profesor actualizado correctamente");
                } else {
                    session.setAttribute("error", "Error al actualizar profesor");
                }
            } else {
                // NUEVO
                exito = dao.crear(profesor);
                if (exito) {
                    session.setAttribute("mensaje", "Profesor creado correctamente");
                } else {
                    session.setAttribute("error", "Error al crear profesor");
                }
            }

            response.sendRedirect("ProfesorServlet?accion=listar");

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "Error del sistema: " + e.getMessage());
            response.sendRedirect("ProfesorServlet?accion=listar");
        }
    }

    // ==========================================
    // MÉTODOS AUXILIARES MODIFICADOS PARA USAR HELPERS
    // ==========================================

    private List<ProfesorNivelArea> parsearAsignaciones(HttpServletRequest request) {
        List<ProfesorNivelArea> asignaciones = new ArrayList<>();
        
        // ✅ Usamos getParamValues para leer arrays incluso con multipart
        String[] niveles = getParamValues(request, "asignacion_nivel[]");
        String[] areas = getParamValues(request, "asignacion_area[]");
        
        if (niveles != null && areas != null && niveles.length == areas.length) {
            for (int i = 0; i < niveles.length; i++) {
                if (niveles[i] != null && !niveles[i].trim().isEmpty() && 
                    areas[i] != null && !areas[i].trim().isEmpty()) {
                    
                    try {
                        ProfesorNivelArea asignacion = new ProfesorNivelArea();
                        asignacion.setNivel(niveles[i].trim());
                        asignacion.setAreaId(Integer.parseInt(areas[i].trim()));
                        asignacion.setEsPrincipal(i == 0);
                        
                        asignaciones.add(asignacion);
                    } catch (NumberFormatException e) {
                        System.err.println("Error al parsear asignación " + i);
                    }
                }
            }
        }
        return asignaciones;
    }

    // Modificado para recibir totalDispStr directamente
    private List<Disponibilidad> capturarDisponibilidades(HttpServletRequest request, int profesorId, String totalDispStr) {
        List<Disponibilidad> disponibilidades = new ArrayList<>();

        if (totalDispStr != null && !totalDispStr.isEmpty()) {
            try {
                int totalDisp = Integer.parseInt(totalDispStr);
                
                for (int i = 0; i < totalDisp; i++) {
                    // Usamos getParam para cada campo dinámico
                    String dia = getParam(request, "disp_dia_semana_" + i);
                    String turnoIdStr = getParam(request, "disp_turno_" + i);
                    String horaInicioStr = getParam(request, "disp_hora_inicio_" + i);
                    String horaFinStr = getParam(request, "disp_hora_fin_" + i);
                    String disponibleStr = getParam(request, "disp_disponible_" + i);

                    if (dia != null && !dia.trim().isEmpty() && 
                        horaInicioStr != null && !horaInicioStr.trim().isEmpty() && 
                        horaFinStr != null && !horaFinStr.trim().isEmpty()) {
                        
                        try {
                            Disponibilidad disp = new Disponibilidad();
                            disp.setProfesorId(profesorId);
                            
                            int turnoId = 0;
                            if (turnoIdStr != null && !turnoIdStr.trim().isEmpty()) {
                                turnoId = Integer.parseInt(turnoIdStr.trim());
                            } else {
                                String tMain = getParam(request, "turno_id");
                                if(tMain!=null) turnoId = Integer.parseInt(tMain);
                            }
                            disp.setTurnoId(turnoId);
                            disp.setDiaSemana(normalizarDia(dia.trim()));

                            String hi = horaInicioStr.trim();
                            if(hi.length()==5) hi+=":00";
                            
                            String hf = horaFinStr.trim();
                            if(hf.length()==5) hf+=":00";
                            
                            disp.setHoraInicio(Time.valueOf(hi));
                            disp.setHoraFin(Time.valueOf(hf));
                            
                            disp.setDisponible(disponibleStr != null ? Boolean.parseBoolean(disponibleStr) : true);
                            
                            disponibilidades.add(disp);
                        } catch (Exception ex) {
                            System.err.println("Error procesando disponibilidad " + i);
                        }
                    }
                }
            } catch (Exception e) {}
        }
        return disponibilidades;
    }

    private String normalizarDia(String dia) {
        if (dia == null || dia.isEmpty()) return "";
        return dia.toUpperCase()
                .replace("Á", "A")
                .replace("É", "E")
                .replace("Í", "I")
                .replace("Ó", "O")
                .replace("Ú", "U");
    }
}