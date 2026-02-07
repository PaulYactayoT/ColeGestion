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
            Integer id = (idStr != null && !idStr.isEmpty()) ? Integer.parseInt(idStr) : null;

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

            // 2. VALIDAR CAMPOS OBLIGATORIOS
            if (nombres == null || nombres.trim().isEmpty() ||
                apellidos == null || apellidos.trim().isEmpty() ||
                correo == null || correo.trim().isEmpty() ||
                nivel == null || nivel.trim().isEmpty() ||
                areaIdStr == null || areaIdStr.trim().isEmpty()
                ) {

                session.setAttribute("error", "Los campos obligatorios no pueden estar vacíos");
                response.sendRedirect("ProfesorServlet?accion=" + (id != null ? "editar&id=" + id : "nuevo"));
                return;
            }

            // 3. CREAR Y CONFIGURAR EL OBJETO PROFESOR
            Profesor profesor = new Profesor();

            if (id != null) {
                profesor.setId(id);
                Profesor profExistente = dao.obtenerPorId(id);
                if (profExistente != null) {
                    profesor.setPersonaId(profExistente.getPersonaId());
                }
            }

            profesor.setNombres(nombres.trim());
            profesor.setApellidos(apellidos.trim());
            profesor.setCorreo(correo.trim());
            profesor.setDni(dni != null ? dni.trim() : "");
            profesor.setTelefono(telefono != null ? telefono.trim() : "");
            profesor.setDireccion(direccion != null ? direccion.trim() : "");

            // Fecha de nacimiento
            if (fechaNacimientoStr != null && !fechaNacimientoStr.isEmpty()) {
                try {
                    LocalDate fechaNac = LocalDate.parse(fechaNacimientoStr);
                    profesor.setFechaNacimiento(java.sql.Date.valueOf(fechaNac));
                } catch (Exception e) {
                    System.err.println("Error al parsear fecha de nacimiento: " + e.getMessage());
                }
            }

            // Información profesional
            profesor.setNivel(nivel.trim());
            profesor.setAreaId(Integer.parseInt(areaIdStr));
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

            // ========== NUEVO: CAPTURAR DISPONIBILIDADES Y AGREGARLAS AL OBJETO PROFESOR ==========
            List<Disponibilidad> disponibilidades = capturarDisponibilidades(request, 0);
            if (!disponibilidades.isEmpty()) {
                profesor.setDisponibilidades(disponibilidades);
                System.out.println("📅 " + disponibilidades.size() + " disponibilidades agregadas al objeto Profesor");
            }
            // ======================================================================================

            // 4. GUARDAR O ACTUALIZAR PROFESOR
            boolean exito = false;

            if (id != null) {
                // ACTUALIZAR
                System.out.println("\n🔄 ACTUALIZANDO profesor ID: " + id);
                exito = dao.actualizar(profesor);

                // Para actualización, guardar disponibilidades por separado (como antes)
                if (exito) {
                    boolean dispGuardadas = dao.guardarDisponibilidades(id, disponibilidades);
                    if (dispGuardadas) {
                        session.setAttribute("mensaje", "Profesor actualizado correctamente");
                    } else {
                        session.setAttribute("error", "Profesor actualizado pero hubo un error al guardar las disponibilidades");
                    }
                } else {
                    session.setAttribute("error", "Error al actualizar el profesor");
                }
            } else {
                // CREAR NUEVO
                System.out.println("\n➕ CREANDO nuevo profesor");
                exito = dao.crear(profesor);  // crear() ahora guarda las disponibilidades automáticamente

                if (exito) {
                    session.setAttribute("mensaje", "Profesor registrado correctamente");
                    System.out.println("✅ Profesor creado exitosamente con sus disponibilidades");
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