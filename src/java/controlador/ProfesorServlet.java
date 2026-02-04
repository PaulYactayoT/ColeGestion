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
import java.util.Enumeration;

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
                        System.out.println("    - dia: " + request.getParameter("disp_dia_" + i));
                        System.out.println("    - turno: " + request.getParameter("disp_turno_" + i));
                        System.out.println("    - hora_inicio: " + request.getParameter("disp_hora_inicio_" + i));
                        System.out.println("    - hora_fin: " + request.getParameter("disp_hora_fin_" + i));
                        System.out.println("    - disponible: " + request.getParameter("disp_disponible_" + i));
                    }
                } catch (NumberFormatException e) {
                    System.out.println("  ⚠️ Error al parsear total_disponibilidades");
                }
            }
            System.out.println("========================================");
            System.out.println();
            // Determinar si es creación (id=0) o actualización (id>0)
            int id = request.getParameter("id") != null && !request.getParameter("id").isEmpty()
                    ? Integer.parseInt(request.getParameter("id")) : 0;

            // ========== CONSTRUIR OBJETO PROFESOR ==========
            Profesor p = new Profesor();
            p.setNombres(request.getParameter("nombres"));
            p.setApellidos(request.getParameter("apellidos"));
            p.setCorreo(request.getParameter("correo"));
            p.setDni(request.getParameter("dni"));
            p.setTelefono(request.getParameter("telefono"));
            p.setDireccion(request.getParameter("direccion"));
            
            // Capturar area_id
           String areaIdStr = request.getParameter("area_id");
            if (areaIdStr != null && !areaIdStr.isEmpty() && !areaIdStr.equals("0")) {
                try {
                    int areaId = Integer.parseInt(areaIdStr);
                    p.setAreaId(areaId);
                    System.out.println(" Área ID capturada: " + areaId);
                } catch (NumberFormatException e) {
                    System.out.println("️ Error al parsear area_id: " + areaIdStr);
                    p.setAreaId(0); // Valor por defecto
                }
            } else {
                System.out.println("ℹ️ Área no seleccionada (opcional)");
                p.setAreaId(0); 
            }
            
            p.setNivel(request.getParameter("nivel")); 
            p.setCodigoProfesor(request.getParameter("codigo_profesor"));
            p.setUsername(request.getParameter("username"));
                    
            // ========== TURNO ==========
            String turnoIdStr = request.getParameter("turno_id");
            if (turnoIdStr != null && !turnoIdStr.isEmpty() && !turnoIdStr.equals("0")) {
                try {
                    int turnoId = Integer.parseInt(turnoIdStr);
                    p.setTurnoId(turnoId);
                    System.out.println(" Turno ID capturado: " + turnoId);
                } catch (NumberFormatException e) {
                    System.out.println("️ Error al parsear turno_id: " + turnoIdStr);
                    p.setTurnoId(0); // Valor por defecto
                }
            } else {
                System.out.println("ℹ️ Turno no seleccionado (opcional)");
                p.setTurnoId(0); 
            }
            
            // ========== FECHA DE NACIMIENTO ==========
            String fechaNacStr = request.getParameter("fecha_nacimiento");
            if (fechaNacStr != null && !fechaNacStr.isEmpty()) {
                try {
                    LocalDate fechaNac = LocalDate.parse(fechaNacStr);
                    p.setFechaNacimiento(java.sql.Date.valueOf(fechaNac));
                    System.out.println("Fecha nacimiento: " + fechaNacStr);
                } catch (Exception e) {
                    System.out.println("Error al parsear fecha de nacimiento: " + fechaNacStr);
                }
            }
            
            // ========== FECHA DE CONTRATACIÓN ==========
            String fechaContStr = request.getParameter("fecha_contratacion");
            if (fechaContStr != null && !fechaContStr.isEmpty()) {
                try {
                    LocalDate fechaCont = LocalDate.parse(fechaContStr);
                    p.setFechaContratacion(java.sql.Date.valueOf(fechaCont));
                    System.out.println("Fecha contratación: " + fechaContStr);
                } catch (Exception e) {
                    System.out.println("Error al parsear fecha de contratación: " + fechaContStr);
                }
            }
            
            // ========== ESTADO ==========
            String estadoParam = request.getParameter("estado");
            if (estadoParam != null && !estadoParam.isEmpty()) {
                p.setEstado(estadoParam);
            } else {
                p.setEstado("ACTIVO");
            }

            // ========== VALIDAR DATOS OBLIGATORIOS ==========
            if (p.getNombres() == null || p.getNombres().trim().isEmpty() ||
                p.getApellidos() == null || p.getApellidos().trim().isEmpty()) {
                session.setAttribute("error", "Nombre y apellidos son obligatorios");
                response.sendRedirect("ProfesorServlet?accion=" + (id == 0 ? "nuevo" : "editar&id=" + id));
                return;
            }

            if (p.getCorreo() == null || p.getCorreo().trim().isEmpty()) {
                session.setAttribute("error", "El correo electrónico es obligatorio");
                response.sendRedirect("ProfesorServlet?accion=" + (id == 0 ? "nuevo" : "editar&id=" + id));
                return;
            }

            if (p.getAreaId() <= 0) {
                session.setAttribute("error", "Debe seleccionar un área");
                response.sendRedirect("ProfesorServlet?accion=" + (id == 0 ? "nuevo" : "editar&id=" + id));
                return;
            }

            if (p.getTurnoId() <= 0) {
                session.setAttribute("error", "Debe seleccionar un turno");
                response.sendRedirect("ProfesorServlet?accion=" + (id == 0 ? "nuevo" : "editar&id=" + id));
                return;
            }

            // ========== EJECUTAR OPERACIÓN ==========
            boolean resultado;
            if (id == 0) {
                // ========== CREAR NUEVO PROFESOR ==========
                System.out.println("========================================");
                System.out.println(" CREANDO NUEVO PROFESOR");
                System.out.println("Nombres: " + p.getNombres());
                System.out.println("Apellidos: " + p.getApellidos());
                System.out.println("Correo: " + p.getCorreo());
                System.out.println("Área ID: " + p.getAreaId());
                System.out.println("Turno ID: " + p.getTurnoId());
                System.out.println("Username: " + (p.getUsername() != null ? p.getUsername() : "AUTO"));
                System.out.println("Password: " + (p.getPassword() != null ? "SET" : "AUTO"));
                System.out.println("========================================");
                
                resultado = dao.crear(p);

                if (resultado) {
                    System.out.println(" PROFESOR CREADO EXITOSAMENTE");

                    // ========== DEBUGGING: Verificar el ID ==========
                    System.out.println(" Verificando ID del profesor...");
                    System.out.println("   - ID del objeto p: " + p.getId());

                    if (p.getId() > 0) {
                        System.out.println(" ID del profesor generado correctamente: " + p.getId());

                        // ========== PROCESAR DISPONIBILIDADES (NUEVO PROFESOR) ==========
                        System.out.println("Iniciando procesamiento de disponibilidades...");
                        procesarDisponibilidades(request, p.getId());

                        session.setAttribute("mensaje", "Profesor creado correctamente");
                    } else {
                        //  Si el ID no se estableció, intentar recuperarlo de la BD
                        System.out.println("ADVERTENCIA: El ID del profesor no se estableció automáticamente");
                        System.out.println("Intentando recuperar el profesor recién creado...");

                        // Buscar el profesor recién creado por correo (que es único)
                        Profesor profesorCreado = dao.obtenerPorCorreo(p.getCorreo());

                        if (profesorCreado != null && profesorCreado.getId() > 0) {
                            System.out.println("Profesor recuperado con ID: " + profesorCreado.getId());
                            procesarDisponibilidades(request, profesorCreado.getId());
                            session.setAttribute("mensaje", "Profesor creado correctamente");
                        } else {
                            System.out.println("ERROR CRÍTICO: No se pudo recuperar el ID del profesor");
                            System.out.println("   El profesor fue creado pero las disponibilidades NO se guardaron");
                            session.setAttribute("error", "Profesor creado pero no se pudieron guardar las disponibilidades. Por favor, edite el profesor para agregarlas.");
                        }
                    }
                } else {
                    System.out.println("ERROR AL CREAR PROFESOR");
                    session.setAttribute("error", "Error al crear el profesor. Verifique que el correo o DNI no existan.");
                }
            } else {
                // ========== ACTUALIZAR PROFESOR ==========
                p.setId(id);
                System.out.println("Actualizando profesor ID " + id);
                resultado = dao.actualizar(p);
                
                if (resultado) {
                    System.out.println(" Profesor actualizado");
                    
                    // ========== PROCESAR DISPONIBILIDADES (ACTUALIZACIÓN) ==========
                    procesarDisponibilidades(request, id);
                    
                    session.setAttribute("mensaje", "Profesor actualizado correctamente");
                } else {
                    session.setAttribute("error", "Error al actualizar el profesor");
                }
            }

            // Redirigir a la lista
            response.sendRedirect("ProfesorServlet?accion=listar");

        } catch (Exception e) {
            System.out.println(" EXCEPCIÓN EN doPost:");
            e.printStackTrace();
            session.setAttribute("error", "Error al procesar la solicitud: " + e.getMessage());
            response.sendRedirect("ProfesorServlet?accion=listar");
        }
    }
    
        /**
         * ========================================
         * MÉTODO AUXILIAR: PROCESAR DISPONIBILIDADES
         * ========================================
         * Extrae las disponibilidades del request y las guarda en la base de datos
         */
    private boolean procesarDisponibilidades(HttpServletRequest request, int profesorId) {
        System.out.println("🔍 === PROCESANDO DISPONIBILIDADES - INICIO ===");

        // Imprimir TODOS los parámetros para debugging
        Enumeration<String> paramNames = request.getParameterNames();
        while (paramNames.hasMoreElements()) {
            String paramName = paramNames.nextElement();
            if (paramName.startsWith("disp_") || paramName.equals("total_disponibilidades")) {
                System.out.println("📋 " + paramName + " = " + request.getParameter(paramName));
            }
        }
        String totalDispStr = request.getParameter("total_disponibilidades");

    if (totalDispStr != null && !totalDispStr.isEmpty()) {
        try {
            int totalDisp = Integer.parseInt(totalDispStr);
            System.out.println("📊 Total de disponibilidades a procesar: " + totalDisp);

            if (totalDisp == 0) {
                System.out.println("ℹ️ No hay disponibilidades para guardar (total = 0)");
                return true;
            }

            List<Disponibilidad> disponibilidades = new ArrayList<>();

            for (int i = 0; i < totalDisp; i++) {
                String dia = request.getParameter("disp_dia_" + i);
                String turnoIdStr = request.getParameter("disp_turno_" + i);
                String horaInicioStr = request.getParameter("disp_hora_inicio_" + i);
                String horaFinStr = request.getParameter("disp_hora_fin_" + i);
                String disponibleStr = request.getParameter("disp_disponible_" + i);

                System.out.println("   📝 Disponibilidad " + (i+1) + ":");
                System.out.println("     - Día: " + dia);
                System.out.println("     - Turno ID: " + turnoIdStr);
                System.out.println("     - Hora inicio: " + horaInicioStr);
                System.out.println("     - Hora fin: " + horaFinStr);
                System.out.println("     - Disponible: " + disponibleStr);

                // Verificar que todos los campos obligatorios tengan valor
                if (dia != null && !dia.trim().isEmpty() && 
                    turnoIdStr != null && !turnoIdStr.trim().isEmpty() && 
                    horaInicioStr != null && !horaInicioStr.trim().isEmpty() && 
                    horaFinStr != null && !horaFinStr.trim().isEmpty()) {

                    try {
                        Disponibilidad disp = new Disponibilidad();
                        disp.setProfesorId(profesorId);
                        
                        // Parsear turno ID (usar valor del formulario si está vacío)
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
import java.util.Enumeration;

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
                        System.out.println("    - dia: " + request.getParameter("disp_dia_" + i));
                        System.out.println("    - turno: " + request.getParameter("disp_turno_" + i));
                        System.out.println("    - hora_inicio: " + request.getParameter("disp_hora_inicio_" + i));
                        System.out.println("    - hora_fin: " + request.getParameter("disp_hora_fin_" + i));
                        System.out.println("    - disponible: " + request.getParameter("disp_disponible_" + i));
                    }
                } catch (NumberFormatException e) {
                    System.out.println("  ⚠️ Error al parsear total_disponibilidades");
                }
            }
            System.out.println("========================================");
            System.out.println();
            // Determinar si es creación (id=0) o actualización (id>0)
            int id = request.getParameter("id") != null && !request.getParameter("id").isEmpty()
                    ? Integer.parseInt(request.getParameter("id")) : 0;

            // ========== CONSTRUIR OBJETO PROFESOR ==========
            Profesor p = new Profesor();
            p.setNombres(request.getParameter("nombres"));
            p.setApellidos(request.getParameter("apellidos"));
            p.setCorreo(request.getParameter("correo"));
            p.setDni(request.getParameter("dni"));
            p.setTelefono(request.getParameter("telefono"));
            p.setDireccion(request.getParameter("direccion"));
            
            // Capturar area_id
           String areaIdStr = request.getParameter("area_id");
            if (areaIdStr != null && !areaIdStr.isEmpty() && !areaIdStr.equals("0")) {
                try {
                    int areaId = Integer.parseInt(areaIdStr);
                    p.setAreaId(areaId);
                    System.out.println(" Área ID capturada: " + areaId);
                } catch (NumberFormatException e) {
                    System.out.println("️ Error al parsear area_id: " + areaIdStr);
                    p.setAreaId(0); // Valor por defecto
                }
            } else {
                System.out.println("ℹ️ Área no seleccionada (opcional)");
                p.setAreaId(0); 
            }
            
            p.setNivel(request.getParameter("nivel")); 
            p.setCodigoProfesor(request.getParameter("codigo_profesor"));
            p.setUsername(request.getParameter("username"));
                    
            // ========== TURNO ==========
            String turnoIdStr = request.getParameter("turno_id");
            if (turnoIdStr != null && !turnoIdStr.isEmpty() && !turnoIdStr.equals("0")) {
                try {
                    int turnoId = Integer.parseInt(turnoIdStr);
                    p.setTurnoId(turnoId);
                    System.out.println(" Turno ID capturado: " + turnoId);
                } catch (NumberFormatException e) {
                    System.out.println("️ Error al parsear turno_id: " + turnoIdStr);
                    p.setTurnoId(0); // Valor por defecto
                }
            } else {
                System.out.println("ℹ️ Turno no seleccionado (opcional)");
                p.setTurnoId(0); 
            }
            
            // ========== FECHA DE NACIMIENTO ==========
            String fechaNacStr = request.getParameter("fecha_nacimiento");
            if (fechaNacStr != null && !fechaNacStr.isEmpty()) {
                try {
                    LocalDate fechaNac = LocalDate.parse(fechaNacStr);
                    p.setFechaNacimiento(java.sql.Date.valueOf(fechaNac));
                    System.out.println("Fecha nacimiento: " + fechaNacStr);
                } catch (Exception e) {
                    System.out.println("Error al parsear fecha de nacimiento: " + fechaNacStr);
                }
            }
            
            // ========== FECHA DE CONTRATACIÓN ==========
            String fechaContStr = request.getParameter("fecha_contratacion");
            if (fechaContStr != null && !fechaContStr.isEmpty()) {
                try {
                    LocalDate fechaCont = LocalDate.parse(fechaContStr);
                    p.setFechaContratacion(java.sql.Date.valueOf(fechaCont));
                    System.out.println("Fecha contratación: " + fechaContStr);
                } catch (Exception e) {
                    System.out.println("Error al parsear fecha de contratación: " + fechaContStr);
                }
            }
            
            // ========== ESTADO ==========
            String estadoParam = request.getParameter("estado");
            if (estadoParam != null && !estadoParam.isEmpty()) {
                p.setEstado(estadoParam);
            } else {
                p.setEstado("ACTIVO");
            }

            // ========== VALIDAR DATOS OBLIGATORIOS ==========
            if (p.getNombres() == null || p.getNombres().trim().isEmpty() ||
                p.getApellidos() == null || p.getApellidos().trim().isEmpty()) {
                session.setAttribute("error", "Nombre y apellidos son obligatorios");
                response.sendRedirect("ProfesorServlet?accion=" + (id == 0 ? "nuevo" : "editar&id=" + id));
                return;
            }

            if (p.getCorreo() == null || p.getCorreo().trim().isEmpty()) {
                session.setAttribute("error", "El correo electrónico es obligatorio");
                response.sendRedirect("ProfesorServlet?accion=" + (id == 0 ? "nuevo" : "editar&id=" + id));
                return;
            }

            if (p.getAreaId() <= 0) {
                session.setAttribute("error", "Debe seleccionar un área");
                response.sendRedirect("ProfesorServlet?accion=" + (id == 0 ? "nuevo" : "editar&id=" + id));
                return;
            }

            if (p.getTurnoId() <= 0) {
                session.setAttribute("error", "Debe seleccionar un turno");
                response.sendRedirect("ProfesorServlet?accion=" + (id == 0 ? "nuevo" : "editar&id=" + id));
                return;
            }

            // ========== EJECUTAR OPERACIÓN ==========
            boolean resultado;
            if (id == 0) {
                // ========== CREAR NUEVO PROFESOR ==========
                System.out.println("========================================");
                System.out.println(" CREANDO NUEVO PROFESOR");
                System.out.println("Nombres: " + p.getNombres());
                System.out.println("Apellidos: " + p.getApellidos());
                System.out.println("Correo: " + p.getCorreo());
                System.out.println("Área ID: " + p.getAreaId());
                System.out.println("Turno ID: " + p.getTurnoId());
                System.out.println("Username: " + (p.getUsername() != null ? p.getUsername() : "AUTO"));
                System.out.println("Password: " + (p.getPassword() != null ? "SET" : "AUTO"));
                System.out.println("========================================");
                
                resultado = dao.crear(p);

                if (resultado) {
                    System.out.println(" PROFESOR CREADO EXITOSAMENTE");

                    // ========== DEBUGGING: Verificar el ID ==========
                    System.out.println(" Verificando ID del profesor...");
                    System.out.println("   - ID del objeto p: " + p.getId());

                    if (p.getId() > 0) {
                        System.out.println(" ID del profesor generado correctamente: " + p.getId());

                        // ========== PROCESAR DISPONIBILIDADES (NUEVO PROFESOR) ==========
                        System.out.println("Iniciando procesamiento de disponibilidades...");
                        procesarDisponibilidades(request, p.getId());

                        session.setAttribute("mensaje", "Profesor creado correctamente");
                    } else {
                        //  Si el ID no se estableció, intentar recuperarlo de la BD
                        System.out.println("ADVERTENCIA: El ID del profesor no se estableció automáticamente");
                        System.out.println("Intentando recuperar el profesor recién creado...");

                        // Buscar el profesor recién creado por correo (que es único)
                        Profesor profesorCreado = dao.obtenerPorCorreo(p.getCorreo());

                        if (profesorCreado != null && profesorCreado.getId() > 0) {
                            System.out.println("Profesor recuperado con ID: " + profesorCreado.getId());
                            procesarDisponibilidades(request, profesorCreado.getId());
                            session.setAttribute("mensaje", "Profesor creado correctamente");
                        } else {
                            System.out.println("ERROR CRÍTICO: No se pudo recuperar el ID del profesor");
                            System.out.println("   El profesor fue creado pero las disponibilidades NO se guardaron");
                            session.setAttribute("error", "Profesor creado pero no se pudieron guardar las disponibilidades. Por favor, edite el profesor para agregarlas.");
                        }
                    }
                } else {
                    System.out.println("ERROR AL CREAR PROFESOR");
                    session.setAttribute("error", "Error al crear el profesor. Verifique que el correo o DNI no existan.");
                }
            } else {
                // ========== ACTUALIZAR PROFESOR ==========
                p.setId(id);
                System.out.println("Actualizando profesor ID " + id);
                resultado = dao.actualizar(p);
                
                if (resultado) {
                    System.out.println(" Profesor actualizado");
                    
                    // ========== PROCESAR DISPONIBILIDADES (ACTUALIZACIÓN) ==========
                    procesarDisponibilidades(request, id);
                    
                    session.setAttribute("mensaje", "Profesor actualizado correctamente");
                } else {
                    session.setAttribute("error", "Error al actualizar el profesor");
                }
            }

            // Redirigir a la lista
            response.sendRedirect("ProfesorServlet?accion=listar");

        } catch (Exception e) {
            System.out.println(" EXCEPCIÓN EN doPost:");
            e.printStackTrace();
            session.setAttribute("error", "Error al procesar la solicitud: " + e.getMessage());
            response.sendRedirect("ProfesorServlet?accion=listar");
        }
    }
    
        /**
         * ========================================
         * MÉTODO AUXILIAR: PROCESAR DISPONIBILIDADES
         * ========================================
         * Extrae las disponibilidades del request y las guarda en la base de datos
         */
    private boolean procesarDisponibilidades(HttpServletRequest request, int profesorId) {
        System.out.println("🔍 === PROCESANDO DISPONIBILIDADES - INICIO ===");

        // Imprimir TODOS los parámetros para debugging
        Enumeration<String> paramNames = request.getParameterNames();
        while (paramNames.hasMoreElements()) {
            String paramName = paramNames.nextElement();
            if (paramName.startsWith("disp_") || paramName.equals("total_disponibilidades")) {
                System.out.println("📋 " + paramName + " = " + request.getParameter(paramName));
            }
        }
        String totalDispStr = request.getParameter("total_disponibilidades");

    if (totalDispStr != null && !totalDispStr.isEmpty()) {
        try {
            int totalDisp = Integer.parseInt(totalDispStr);
            System.out.println("📊 Total de disponibilidades a procesar: " + totalDisp);

            if (totalDisp == 0) {
                System.out.println("ℹ️ No hay disponibilidades para guardar (total = 0)");
                return true;
            }

            List<Disponibilidad> disponibilidades = new ArrayList<>();

            for (int i = 0; i < totalDisp; i++) {
                String dia = request.getParameter("disp_dia_" + i);
                String turnoIdStr = request.getParameter("disp_turno_" + i);
                String horaInicioStr = request.getParameter("disp_hora_inicio_" + i);
                String horaFinStr = request.getParameter("disp_hora_fin_" + i);
                String disponibleStr = request.getParameter("disp_disponible_" + i);

                System.out.println("   📝 Disponibilidad " + (i+1) + ":");
                System.out.println("     - Día: " + dia);
                System.out.println("     - Turno ID: " + turnoIdStr);
                System.out.println("     - Hora inicio: " + horaInicioStr);
                System.out.println("     - Hora fin: " + horaFinStr);
                System.out.println("     - Disponible: " + disponibleStr);

                // Verificar que todos los campos obligatorios tengan valor
                if (dia != null && !dia.trim().isEmpty() && 
                    turnoIdStr != null && !turnoIdStr.trim().isEmpty() && 
                    horaInicioStr != null && !horaInicioStr.trim().isEmpty() && 
                    horaFinStr != null && !horaFinStr.trim().isEmpty()) {

                    try {
                        Disponibilidad disp = new Disponibilidad();
                        disp.setProfesorId(profesorId);
                        
                        // Parsear turno ID (usar valor del formulario si está vacío)
                        int turnoId;
                        if (turnoIdStr.trim().isEmpty()) {
                            // Si no viene en la disponibilidad, usar el del formulario principal
                            String turnoPrincipal = request.getParameter("turno_id");
                            turnoId = turnoPrincipal != null ? Integer.parseInt(turnoPrincipal) : 0;
                        } else {
                            turnoId = Integer.parseInt(turnoIdStr.trim());
                        }
                        disp.setTurnoId(turnoId);
                        
                        disp.setDiaSemana(dia.trim());

                        // Asegurar formato HH:mm:ss para Time.valueOf()
                        String horaInicioCompleta = horaInicioStr.trim();
                        String horaFinCompleta = horaFinStr.trim();
                        
                        // Si no tiene segundos, agregar :00
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
                        System.out.println("      ✅ Disponibilidad agregada a la lista");
                    } catch (Exception ex) {
                        System.out.println("      ❌ Error al parsear disponibilidad " + (i+1) + ": " + ex.getMessage());
                        ex.printStackTrace();
                    }
                } else {
                    System.out.println("    ⚠️ Disponibilidad " + (i+1) + " tiene campos vacíos, se omite");
                }
            }

            // Guardar todas las disponibilidades
            if (!disponibilidades.isEmpty()) {
                System.out.println("💾 Guardando " + disponibilidades.size() + " disponibilidades en la base de datos...");
                boolean dispGuardadas = dao.guardarDisponibilidades(profesorId, disponibilidades);
                if (dispGuardadas) {
                    System.out.println("✅ " + disponibilidades.size() + " disponibilidades guardadas correctamente");
                    return true;
                } else {
                    System.out.println("❌ ERROR: No se pudieron guardar las disponibilidades");
                    return false;
                }
            } else {
                System.out.println("ℹ️ No hay disponibilidades válidas para guardar");
                return true;
            }
            } catch (Exception e) {
                System.err.println("❌ ERROR PROCESANDO DISPONIBILIDADES:");
                e.printStackTrace();
                return false;
            }
                } else {
                    System.out.println("ℹ️ No se enviaron disponibilidades en el formulario");
                    return true;
                }
            }    


                        // Asegurar formato HH:mm:ss para Time.valueOf()
                        String horaInicioCompleta = horaInicioStr.trim();
                        String horaFinCompleta = horaFinStr.trim();
                        
                        // Si no tiene segundos, agregar :00
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
                        System.out.println("      ✅ Disponibilidad agregada a la lista");
                    } catch (Exception ex) {
                        System.out.println("      ❌ Error al parsear disponibilidad " + (i+1) + ": " + ex.getMessage());
                        ex.printStackTrace();
                    }
                } else {
                    System.out.println("    ⚠️ Disponibilidad " + (i+1) + " tiene campos vacíos, se omite");
                }
            }

            // Guardar todas las disponibilidades
            if (!disponibilidades.isEmpty()) {
                System.out.println("💾 Guardando " + disponibilidades.size() + " disponibilidades en la base de datos...");
                boolean dispGuardadas = dao.guardarDisponibilidades(profesorId, disponibilidades);
                if (dispGuardadas) {
                    System.out.println("✅ " + disponibilidades.size() + " disponibilidades guardadas correctamente");
                    return true;
                } else {
                    System.out.println("❌ ERROR: No se pudieron guardar las disponibilidades");
                    return false;
                }
            } else {
                System.out.println("ℹ️ No hay disponibilidades válidas para guardar");
                return true;
            }
        } catch (Exception e) {
            System.err.println("❌ ERROR PROCESANDO DISPONIBILIDADES:");
            e.printStackTrace();
            return false;
        }
    } else {
        System.out.println("ℹ️ No se enviaron disponibilidades en el formulario");
        return true;
    }
}    

}