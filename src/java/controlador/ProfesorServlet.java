package controlador;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Time;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

// ========== IMPORT AGREGADO PARA MANEJAR ASIGNACIONES ==========
import modelo.ProfesorNivelArea;  // ⭐ NUEVO: Para manejar niveles y áreas múltiples
// ================================================================

import modelo.Disponibilidad;
import modelo.Profesor;
import modelo.ProfesorDAO;

@WebServlet("/ProfesorServlet")
public class ProfesorServlet extends HttpServlet {

    ProfesorDAO dao = new ProfesorDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
                throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        HttpSession session = request.getSession();
        String rol = (String) session.getAttribute("rol");

        //SOLO ADMINISTRADOR PUEDE INGRESAR A ESTE PANEL
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
            request.setAttribute("turnos", dao.listarTurnos());
            request.setAttribute("areas", dao.listarAreas());
            request.getRequestDispatcher("profesorForm.jsp").forward(request, response);
            return;
        }

        // Ejecutar acción específica según parámetro
        switch (accion) {
            case "editar":
                int idEditar = Integer.parseInt(request.getParameter("id"));
                Profesor p = dao.obtenerPorId(idEditar);
                if (p != null) {
                    // IMPORTANTE: Cargar las asignaciones del profesor
                    List<ProfesorNivelArea> asignaciones = dao.obtenerAsignaciones(idEditar);
                    p.setAsignaciones(asignaciones);

                    request.setAttribute("profesor", p);
                    request.setAttribute("turnos", dao.listarTurnos());
                    request.setAttribute("areas", dao.listarAreas());
                    request.getRequestDispatcher("profesorForm.jsp").forward(request, response);
                } else {
                    session.setAttribute("error", "Profesor no encontrado");
                    response.sendRedirect("ProfesorServlet?accion=listar");
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
                response.sendRedirect("ProfesorServlet?accion=listar");
                break;
                
            case "ver":
                int idVer = Integer.parseInt(request.getParameter("id"));
                Profesor pVer = dao.obtenerPorId(idVer);
                if (pVer != null) {
                    // IMPORTANTE: Cargar las asignaciones del profesor
                    List<ProfesorNivelArea> asignaciones = dao.obtenerAsignaciones(idVer);
                    pVer.setAsignaciones(asignaciones);

                    request.setAttribute("profesor", pVer);
                    request.getRequestDispatcher("profesorDetalle.jsp").forward(request, response);
                } else {
                    session.setAttribute("error", "Profesor no encontrado");
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
        response.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        // VALIDACIÓN: Solo admin puede crear/actualizar profesores
        if (!"admin".equals(rol)) {
            System.out.println("ACCESO DENEGADO POST: Rol " + rol + " intentó modificar profesores");
            response.sendRedirect("acceso_denegado.jsp");
            return;
        }

        try {

            // ========== DEBUGGING COMPLETO DE PARÁMETROS ==========
            System.out.println("========================================");
            System.out.println(" PARÁMETROS RECIBIDOS EN doPost:");
            System.out.println("========================================");
            System.out.println("ID: " + request.getParameter("id"));
            System.out.println("nombres: " + request.getParameter("nombres"));
            System.out.println("apellidos: " + request.getParameter("apellidos"));
            System.out.println("correo: " + request.getParameter("correo"));
            System.out.println("dni: " + request.getParameter("dni"));
            System.out.println("telefono: " + request.getParameter("telefono"));
            System.out.println("direccion: " + request.getParameter("direccion"));
            System.out.println("fecha_nacimiento: " + request.getParameter("fecha_nacimiento"));
            System.out.println("----------------------------------------");
            System.out.println("INFORMACIÓN PROFESIONAL:");
            System.out.println("nivel: " + request.getParameter("nivel"));
            System.out.println("area_id: " + request.getParameter("area_id"));
            System.out.println("turno_id: " + request.getParameter("turno_id"));
            System.out.println("codigo_profesor: " + request.getParameter("codigo_profesor"));
            System.out.println("fecha_contratacion: " + request.getParameter("fecha_contratacion"));
            System.out.println("estado: " + request.getParameter("estado"));
            System.out.println("username: " + request.getParameter("username"));
            
            // ========== DEBUGGING DE ASIGNACIONES (NUEVO) ==========
            System.out.println("----------------------------------------");
            System.out.println("ASIGNACIONES MÚLTIPLES:");
            String[] niveles = request.getParameterValues("asignacion_nivel[]");
            String[] areas = request.getParameterValues("asignacion_area[]");
            if (niveles != null && areas != null) {
                System.out.println("Total de asignaciones recibidas: " + niveles.length);
                for (int i = 0; i < niveles.length; i++) {
                    System.out.println("  Asignación " + (i+1) + ": " + niveles[i] + " -> Área ID: " + areas[i]);
                }
            } else {
                System.out.println("  No se recibieron asignaciones múltiples (usando método antiguo)");
            }
            // ========================================================
            
            System.out.println("----------------------------------------");
            System.out.println("DISPONIBILIDADES:");
            System.out.println("total_disponibilidades: " + request.getParameter("total_disponibilidades"));

            // Listar todas las disponibilidades si existen
            String totalDispStr = request.getParameter("total_disponibilidades");
            if (totalDispStr != null && !totalDispStr.isEmpty()) {
                try {
                    int totalDisp = Integer.parseInt(totalDispStr);
                    for (int i = 0; i < totalDisp; i++) {
                        System.out.println("  Disponibilidad " + i + ":");
                        System.out.println("    - dia: " + request.getParameter("disp_dia_semana_" + i));
                        System.out.println("    - turno: " + request.getParameter("disp_turno_" + i));
                        System.out.println("    - hora_inicio: " + request.getParameter("disp_hora_inicio_" + i));
                        System.out.println("    - hora_fin: " + request.getParameter("disp_hora_fin_" + i));
                        System.out.println("    - disponible: " + request.getParameter("disp_disponible_" + i));
                    }
                } catch (NumberFormatException e) {
                    System.out.println("  ⚠️ Error al parsear total_disponibilidades");
                }
            }
            System.out.println("========================================\n");

            // 1. OBTENER PARÁMETROS DEL FORMULARIO
            String idStr = request.getParameter("id");
            String nombres = request.getParameter("nombres");
            String apellidos = request.getParameter("apellidos");
            String correo = request.getParameter("correo");
            String dni = request.getParameter("dni");
            String telefono = request.getParameter("telefono");
            String direccion = request.getParameter("direccion");
            String fechaNacimientoStr = request.getParameter("fecha_nacimiento");
            String nivel = request.getParameter("nivel");
            String areaIdStr = request.getParameter("area_id");
            String turnoIdStr = request.getParameter("turno_id");
            String codigoProfesor = request.getParameter("codigo_profesor");
            String fechaContratacionStr = request.getParameter("fecha_contratacion");
            String estado = request.getParameter("estado");
            String username = request.getParameter("username");
            String password = request.getParameter("password");

            // 2. VALIDACIONES BÁSICAS
            if (nombres == null || nombres.trim().isEmpty() ||
                apellidos == null || apellidos.trim().isEmpty() ||
                dni == null || dni.trim().isEmpty()) {

                session.setAttribute("error", "Los campos nombres, apellidos y DNI son obligatorios");
                response.sendRedirect("ProfesorServlet?accion=nuevo");
                return;
            }

            // 3. CREAR OBJETO PROFESOR Y ASIGNAR VALORES
            Profesor profesor = new Profesor();

            // Si hay ID, es una actualización
            Integer id = null;
            if (idStr != null && !idStr.isEmpty()) {
                id = Integer.parseInt(idStr);
                profesor.setId(id);
            }

            // Datos personales
            profesor.setNombres(nombres.trim());
            profesor.setApellidos(apellidos.trim());
            profesor.setCorreo(correo != null ? correo.trim() : "");
            profesor.setDni(dni.trim());
            profesor.setTelefono(telefono != null ? telefono.trim() : "");
            profesor.setDireccion(direccion != null ? direccion.trim() : "");
            profesor.setPassword(password != null ? password.trim() : "");

            // Turno
            if (turnoIdStr != null && !turnoIdStr.isEmpty()) {
                profesor.setTurnoId(Integer.parseInt(turnoIdStr));
            }

            // Fecha de nacimiento
            if (fechaNacimientoStr != null && !fechaNacimientoStr.isEmpty()) {
                try {
                    LocalDate fechaNac = LocalDate.parse(fechaNacimientoStr);
                    profesor.setFechaNacimiento(java.sql.Date.valueOf(fechaNac));
                } catch (Exception e) {
                    System.err.println("Error al parsear fecha de nacimiento: " + e.getMessage());
                }
            }

            // ========== MANEJO DE ASIGNACIONES MÚLTIPLES (NUEVO) ==========
            List<ProfesorNivelArea> asignaciones = parsearAsignaciones(request);
            
            // Si no hay asignaciones múltiples, usar el método antiguo como fallback
            if (asignaciones.isEmpty()) {
                System.out.println("⚠️ No se encontraron asignaciones múltiples, usando método antiguo...");
                if (nivel != null && !nivel.isEmpty() && areaIdStr != null && !areaIdStr.isEmpty()) {
                    ProfesorNivelArea asignacion = new ProfesorNivelArea();
                    asignacion.setNivel(nivel.trim());
                    asignacion.setAreaId(Integer.parseInt(areaIdStr));
                    asignacion.setEsPrincipal(true);
                    asignaciones.add(asignacion);
                    
                    // También establecer en el profesor para compatibilidad
                    profesor.setNivel(nivel.trim());
                    profesor.setAreaId(Integer.parseInt(areaIdStr));
                }
            }
            
            // Validar que haya al menos una asignación
            if (asignaciones.isEmpty()) {
                session.setAttribute("error", "Debe seleccionar al menos un nivel y área para el profesor");
                response.sendRedirect(id != null ? 
                    "ProfesorServlet?accion=editar&id=" + id : 
                    "ProfesorServlet?accion=nuevo");
                return;
            }
            
            // Establecer asignaciones en el profesor
            profesor.setAsignaciones(asignaciones);
            
            System.out.println("✅ Total de asignaciones a guardar: " + asignaciones.size());
            for (int i = 0; i < asignaciones.size(); i++) {
                ProfesorNivelArea asig = asignaciones.get(i);
                System.out.println("  " + (i+1) + ". " + asig.getNivel() + " -> Área ID: " + 
                                 asig.getAreaId() + " (Principal: " + asig.isEsPrincipal() + ")");
            }
            // ================================================================

            // Información profesional (valores de la primera asignación como principal)
            if (!asignaciones.isEmpty()) {
                ProfesorNivelArea principal = asignaciones.get(0);
                profesor.setNivel(principal.getNivel());
                profesor.setAreaId(principal.getAreaId());
            }
            
            profesor.setCodigoProfesor(codigoProfesor != null ? codigoProfesor.trim() : "");

            // Fecha de contratación
            if (fechaContratacionStr != null && !fechaContratacionStr.isEmpty()) {
                try {
                    LocalDate fechaCont = LocalDate.parse(fechaContratacionStr);
                    profesor.setFechaContratacion(java.sql.Date.valueOf(fechaCont));
                } catch (Exception e) {
                    System.err.println("Error al parsear fecha de contratación: " + e.getMessage());
                }
            }

            profesor.setEstado(estado != null && !estado.isEmpty() ? estado : "ACTIVO");
            profesor.setUsername(username != null ? username.trim() : "");

            // ========== CAPTURAR DISPONIBILIDADES Y AGREGARLAS AL OBJETO PROFESOR ==========
            List<Disponibilidad> disponibilidades = capturarDisponibilidades(request, 0);
            if (!disponibilidades.isEmpty()) {
                profesor.setDisponibilidades(disponibilidades);
                System.out.println("📅 " + disponibilidades.size() + " disponibilidades agregadas al objeto Profesor");
            }
            // ======================================================================================

            // 4. GUARDAR O ACTUALIZAR PROFESOR
            boolean exito = false;

            if (id != null) {
                // ========== ACTUALIZAR ==========
                System.out.println("\n🔄 ACTUALIZANDO profesor ID: " + id);
                exito = dao.actualizar(profesor);

                if (exito) {
                    // Guardar disponibilidades
                    boolean dispGuardadas = dao.guardarDisponibilidades(id, disponibilidades);
                    
                    // ========== GUARDAR ASIGNACIONES (NUEVO) ==========
                    // Establecer el profesor_id en cada asignación antes de guardar
                    for (ProfesorNivelArea asig : asignaciones) {
                        asig.setProfesorId(id);
                    }
                    
                    boolean asigGuardadas = dao.guardarAsignaciones(id, asignaciones);
                    // ==================================================
                    
                    if (dispGuardadas && asigGuardadas) {
                        session.setAttribute("mensaje", "Profesor actualizado correctamente con " + 
                                           asignaciones.size() + " asignación(es) de nivel-área");
                    } else if (!dispGuardadas) {
                        session.setAttribute("error", "Profesor actualizado pero hubo un error al guardar las disponibilidades");
                    } else {
                        session.setAttribute("error", "Profesor actualizado pero hubo un error al guardar las asignaciones");
                    }
                } else {
                    session.setAttribute("error", "Error al actualizar el profesor");
                }
            } else {
                // ========== CREAR NUEVO ==========
                System.out.println("\n➕ CREANDO nuevo profesor");
                exito = dao.crear(profesor);  // crear() ahora guarda las disponibilidades Y asignaciones automáticamente

                if (exito) {
                    session.setAttribute("mensaje", "Profesor registrado correctamente con " + 
                                       asignaciones.size() + " asignación(es) de nivel-área");
                    System.out.println("✅ Profesor creado exitosamente con sus disponibilidades y asignaciones");
                } else {
                    session.setAttribute("error", "Error al crear el profesor");
                }
            }

            response.sendRedirect("ProfesorServlet?accion=listar");

        } catch (Exception e) {
            System.err.println("❌ ERROR GENERAL EN doPost:");
            e.printStackTrace();
            session.setAttribute("error", "Error del sistema: " + e.getMessage());
            response.sendRedirect("ProfesorServlet?accion=listar");
        }
    }

    // ========================================================================
    // ⭐ MÉTODO NUEVO: PARSEAR ASIGNACIONES MÚLTIPLES DESDE EL FORMULARIO
    // ========================================================================
    /**
     * Parsea las asignaciones de nivel-área desde los parámetros del request
     * 
     * Los parámetros llegan en formato:
     * - asignacion_nivel[]: ["INICIAL", "INICIAL", "PRIMARIA"]
     * - asignacion_area[]: ["1", "2", "3"]
     * 
     * Donde cada índice corresponde a una asignación
     */
    private List<ProfesorNivelArea> parsearAsignaciones(HttpServletRequest request) {
        List<ProfesorNivelArea> asignaciones = new ArrayList<>();
        
        String[] niveles = request.getParameterValues("asignacion_nivel[]");
        String[] areas = request.getParameterValues("asignacion_area[]");
        
        if (niveles != null && areas != null && niveles.length == areas.length) {
            System.out.println("\n📋 Parseando " + niveles.length + " asignaciones del formulario...");
            
            for (int i = 0; i < niveles.length; i++) {
                if (niveles[i] != null && !niveles[i].trim().isEmpty() && 
                    areas[i] != null && !areas[i].trim().isEmpty()) {
                    
                    try {
                        ProfesorNivelArea asignacion = new ProfesorNivelArea();
                        asignacion.setNivel(niveles[i].trim());
                        asignacion.setAreaId(Integer.parseInt(areas[i].trim()));
                        asignacion.setEsPrincipal(i == 0); // La primera es principal
                        
                        asignaciones.add(asignacion);
                        System.out.println("  ✓ Asignación " + (i+1) + ": " + niveles[i] + " - Área ID: " + areas[i]);
                    } catch (NumberFormatException e) {
                        System.err.println("  ✗ Error al parsear área ID: " + areas[i]);
                    }
                }
            }
        } else {
            System.out.println("\n⚠️ No se encontraron parámetros asignacion_nivel[] o asignacion_area[]");
        }
        
        System.out.println("Total asignaciones parseadas correctamente: " + asignaciones.size() + "\n");
        return asignaciones;
    }
    // ========================================================================

    /**
     * CAPTURAR DISPONIBILIDADES DEL REQUEST
     * (Refactorización del método guardarDisponibilidades para reutilizar lógica)
     */
    private List<Disponibilidad> capturarDisponibilidades(HttpServletRequest request, int profesorId) {
        List<Disponibilidad> disponibilidades = new ArrayList<>();
        String totalDispStr = request.getParameter("total_disponibilidades");

        if (totalDispStr != null && !totalDispStr.isEmpty()) {
            try {
                int totalDisp = Integer.parseInt(totalDispStr);
                System.out.println("📊 Total de disponibilidades a procesar: " + totalDisp);

                for (int i = 0; i < totalDisp; i++) {
                    String dia = request.getParameter("disp_dia_semana" + i);
                    String turnoIdStr = request.getParameter("disp_turno_" + i);
                    String horaInicioStr = request.getParameter("disp_hora_inicio_" + i);
                    String horaFinStr = request.getParameter("disp_hora_fin_" + i);
                    String disponibleStr = request.getParameter("disp_disponible_" + i);

                    // Verificar que todos los campos obligatorios tengan valor
                    if (dia != null && !dia.trim().isEmpty() && 
                        turnoIdStr != null && !turnoIdStr.trim().isEmpty() && 
                        horaInicioStr != null && !horaInicioStr.trim().isEmpty() && 
                        horaFinStr != null && !horaFinStr.trim().isEmpty()) {

                        try {
                            Disponibilidad disp = new Disponibilidad();
                            disp.setProfesorId(profesorId); // Puede ser 0 si aún no se ha creado

                            // Parsear turno ID
                            int turnoId;
                            if (turnoIdStr.trim().isEmpty()) {
                                String turnoPrincipal = request.getParameter("turno_id");
                                turnoId = turnoPrincipal != null ? Integer.parseInt(turnoPrincipal) : 0;
                            } else {
                                turnoId = Integer.parseInt(turnoIdStr.trim());
                            }
                            disp.setTurnoId(turnoId);

                            // NORMALIZAR DÍA
                            String diaNormalizado = normalizarDia(dia.trim());
                            disp.setDiaSemana(diaNormalizado);

                            // Asegurar formato HH:mm:ss para Time.valueOf()
                            String horaInicioCompleta = horaInicioStr.trim();
                            String horaFinCompleta = horaFinStr.trim();

                            if (horaInicioCompleta.split(":").length == 2) {
                                horaInicioCompleta += ":00";
                            }
                            if (horaFinCompleta.split(":").length == 2) {
                                horaFinCompleta += ":00";
                            }

                            disp.setHoraInicio(Time.valueOf(horaInicioCompleta));
                            disp.setHoraFin(Time.valueOf(horaFinCompleta));
                            disp.setDisponible(disponibleStr != null ? Boolean.parseBoolean(disponibleStr) : true);
                            disp.setObservaciones("");

                            disponibilidades.add(disp);
                        } catch (Exception ex) {
                            System.err.println("Error al parsear disponibilidad " + (i+1) + ": " + ex.getMessage());
                        }
                    }
                }
            } catch (Exception e) {
                System.err.println("Error procesando disponibilidades: " + e.getMessage());
            }
        }

        return disponibilidades;
    }

    /**
     * NORMALIZAR DÍA DE LA SEMANA
     */
    private String normalizarDia(String dia) {
        if (dia == null || dia.isEmpty()) {
            return "";
        }

        return dia.toUpperCase()
            .replace("Á", "A")
            .replace("É", "E")
            .replace("Í", "I")
            .replace("Ó", "O")
            .replace("Ú", "U");
    }
}