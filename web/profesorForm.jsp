<%@ page import="modelo.Profesor" %>
<%@ page import="modelo.Turno" %>
<%@ page import="modelo.Area" %>
<%@ page import="java.util.List" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.time.LocalTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="modelo.Disponibilidad" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

   Profesor p = (Profesor) request.getAttribute("profesor");
    List<Turno> turnos = (List<Turno>) request.getAttribute("turnos");
    List<Area> areas = (List<Area>) request.getAttribute("areas");
    boolean editar = (p != null);
    
    String fechaNacimientoStr = "";
   
    String fechaContratacionStr = "";
    
    if (editar) {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        if (p.getFechaNacimiento() != null) {
            fechaNacimientoStr = sdf.format(p.getFechaNacimiento());
        }
        if (p.getFechaContratacion() != null) {
            fechaContratacionStr = sdf.format(p.getFechaContratacion());
        }
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= editar ? "Editar Profesor" : "Registrar Profesor"%></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="assets/css/estilos.css?v=1.5">
    <style>
        :root {
            --primary-color: #4f46e5;
            --primary-dark: #4338ca;
            --success-color: #10b981;
            --danger-color: #ef4444;
            --warning-color: #f59e0b;
            --info-color: #3b82f6;
            --dark-color: #1f2937;
            --light-bg: #f9fafb;
            --border-color: #e5e7eb;
        }

        body {
            background: #ffffff;
            min-height: 100vh;
            padding: 0;
            margin: 0;
        }

        .form-wrapper {
            max-width: 900px;
            margin: 0 auto;
            padding: 1.5rem 15px;
        }

        .form-header {
            background: #1f2937;
            border-radius: 15px 15px 0 0;
            padding: 1.5rem 2rem;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            border-bottom: 3px solid var(--primary-color);
            margin-top: 1rem;
        }

        .form-header h2 {
            color: #ffffff;
            font-weight: 700;
            margin: 0;
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        .form-header .icon {
            width: 50px;
            height: 50px;
            background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 1.5rem;
        }

        .form-card {
            background: white;
            border-radius: 0 0 15px 15px;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
            padding: 2.5rem;
        }

        .section-divider {
            border: none;
            height: 2px;
            background: linear-gradient(90deg, var(--primary-color), transparent);
            margin: 2rem 0 1.5rem 0;
        }

        .section-title {
            color: var(--primary-color);
            font-weight: 600;
            font-size: 1.2rem;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .section-title i {
            font-size: 1.4rem;
        }

        .form-label {
            font-weight: 600;
            color: var(--dark-color);
            margin-bottom: 0.5rem;
            font-size: 0.9rem;
        }

        .required-field::after {
            content: " *";
            color: var(--danger-color);
            font-weight: bold;
        }

        .form-control, .form-select {
            border: 2px solid var(--border-color);
            border-radius: 8px;
            padding: 0.75rem;
            transition: all 0.3s ease;
            font-size: 0.95rem;
        }

        .form-control:focus, .form-select:focus {
            border-color: var(--primary-color);
            box-shadow: 0 0 0 0.2rem rgba(79, 70, 229, 0.15);
        }

        .form-control.is-invalid {
            border-color: var(--danger-color);
            padding-right: calc(1.5em + 0.75rem);
            background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 12 12' width='12' height='12' fill='none' stroke='%23dc3545'%3e%3ccircle cx='6' cy='6' r='4.5'/%3e%3cpath stroke-linejoin='round' d='M5.8 3.6h.4L6 6.5z'/%3e%3ccircle cx='6' cy='8.2' r='.6' fill='%23dc3545' stroke='none'/%3e%3c/svg%3e");
            background-repeat: no-repeat;
            background-position: right calc(0.375em + 0.1875rem) center;
            background-size: calc(0.75em + 0.375rem) calc(0.75em + 0.375rem);
        }

        .form-control.is-valid {
            border-color: var(--success-color);
            padding-right: calc(1.5em + 0.75rem);
            background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 8 8'%3e%3cpath fill='%2310b981' d='M2.3 6.73L.6 4.53c-.4-1.04.46-1.4 1.1-.8l1.1 1.4 3.4-3.8c.6-.63 1.6-.27 1.2.7l-4 4.6c-.43.5-.8.4-1.1.1z'/%3e%3c/svg%3e");
            background-repeat: no-repeat;
            background-position: right calc(0.375em + 0.1875rem) center;
            background-size: calc(0.75em + 0.375rem) calc(0.75em + 0.375rem);
        }

        .invalid-feedback {
            display: block;
            color: var(--danger-color);
            font-size: 0.85rem;
            margin-top: 0.25rem;
            font-weight: 500;
        }

        .valid-feedback {
            display: block;
            color: var(--success-color);
            font-size: 0.85rem;
            margin-top: 0.25rem;
            font-weight: 500;
        }

        .alert-modern {
            border: none;
            border-radius: 10px;
            padding: 1rem 1.25rem;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 1rem;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }

        .alert-modern i {
            font-size: 1.5rem;
        }

        .alert-danger {
            background: linear-gradient(135deg, #fee2e2, #fecaca);
            color: #991b1b;
            border-left: 4px solid var(--danger-color);
        }

        .alert-success {
            background: linear-gradient(135deg, #d1fae5, #a7f3d0);
            color: #065f46;
            border-left: 4px solid var(--success-color);
        }

        .alert-warning {
            background: linear-gradient(135deg, #fef3c7, #fde68a);
            color: #92400e;
            border-left: 4px solid var(--warning-color);
        }

        .btn-modern {
            padding: 0.75rem 2rem;
            border-radius: 10px;
            font-weight: 600;
            font-size: 0.95rem;
            border: none;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            text-decoration: none;
        }

        .btn-primary-modern {
            background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
            color: white;
        }

        .btn-primary-modern:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 15px rgba(79, 70, 229, 0.3);
            color: white;
        }

        .btn-success-modern {
            background: linear-gradient(135deg, #10b981, #059669);
            color: white;
        }

        .btn-success-modern:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 15px rgba(16, 185, 129, 0.3);
            color: white;
        }

        .btn-secondary-modern {
            background: #6b7280;
            color: white;
        }

        .btn-secondary-modern:hover {
            background: #4b5563;
            transform: translateY(-2px);
            color: white;
        }

        .btn-danger-modern {
            background: linear-gradient(135deg, var(--danger-color), #dc2626);
            color: white;
        }

        .btn-danger-modern:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 15px rgba(239, 68, 68, 0.3);
            color: white;
        }

        .form-text {
            color: #6b7280;
            font-size: 0.8rem;
            margin-top: 0.25rem;
        }

        .input-group-icon {
            position: relative;
        }

        .input-group-icon i {
            position: absolute;
            left: 15px;
            top: 50%;
            transform: translateY(-50%);
            color: #9ca3af;
            z-index: 10;
        }

        .input-group-icon .form-control {
            padding-left: 2.75rem;
        }

        .tooltip-info {
            cursor: help;
            color: var(--info-color);
            margin-left: 0.25rem;
        }

        @media (max-width: 768px) {
            .form-card {
                padding: 1.5rem;
            }
            
            .form-header {
                padding: 1.5rem;
            }
        }

        /* Animaciones */
        @keyframes slideIn {
            from {
                opacity: 0;
                transform: translateY(-20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .form-wrapper {
            animation: slideIn 0.5s ease;
        }
    </style>
</head>
<body>
    <jsp:include page="header.jsp" />

    <div class="form-wrapper">
        <!-- Header del Formulario -->
        <div class="form-header">
            <h2>
                <div class="icon">
                    <i class="fas <%= editar ? "fa-user-edit" : "fa-user-plus" %>"></i>
                </div>
                <%= editar ? "Editar Profesor" : "Registrar Nuevo Profesor"%>
            </h2>
        </div>

        <!-- Formulario -->
        <div class="form-card">
            <form action="ProfesorServlet" method="post" id="profesorForm">
                <input type="hidden" name="id" value="<%= editar ? p.getId() : "" %>">
                
                <!-- SECCIÓN: INFORMACIÓN PERSONAL -->
                <div class="section-title">
                    <i class="fas fa-user"></i>
                    Informacion Personal
                </div>
                
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label required-field">Nombres</label>
                        <div class="input-group-icon">
                            <i class="fas fa-user"></i>
                            <input type="text" class="form-control" name="nombres" id="nombres"
                                   value="<%= editar && p.getNombres() != null ? p.getNombres() : "" %>" 
                                   required maxlength="100" placeholder="Ingrese los nombres">
                        </div>
                        <div class="invalid-feedback"></div>
                    </div>

                    <div class="col-md-6 mb-3">
                        <label class="form-label required-field">Apellidos</label>
                        <div class="input-group-icon">
                            <i class="fas fa-user"></i>
                            <input type="text" class="form-control" name="apellidos" id="apellidos"
                                   value="<%= editar && p.getApellidos() != null ? p.getApellidos() : "" %>" 
                                   required maxlength="100" placeholder="Ingrese los apellidos">
                        </div>
                        <div class="invalid-feedback"></div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label required-field">Correo Electrónico</label>
                        <div class="input-group-icon">
                            <i class="fas fa-envelope"></i>
                            <input type="email" class="form-control" name="correo" id="correo"
                                   value="<%= editar && p.getCorreo() != null ? p.getCorreo() : "" %>" 
                                   required maxlength="100" placeholder="ejemplo@email.com">
                        </div>
                        <div class="invalid-feedback"></div>
                        <div class="valid-feedback"></div>
                    </div>

                    <div class="col-md-6 mb-3">
                        <label class="form-label">
                            DNI
                            <i class="fas fa-info-circle tooltip-info" title="Opcional - 8 digitos numericos"></i>
                        </label>
                        <div class="input-group-icon">
                            <i class="fas fa-id-card"></i>
                            <input type="text" class="form-control" name="dni" id="dni"
                                   value="<%= editar && p.getDni() != null ? p.getDni() : "" %>" 
                                   maxlength="8" placeholder="12345678">
                        </div>
                        <small class="form-text">Opcional, 8 digitos numericos</small>
                        <div class="invalid-feedback"></div>
                        <div class="valid-feedback"></div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Fecha de Nacimiento</label>
                        <div class="input-group-icon">
                            <i class="fas fa-calendar"></i>
                            <input type="date" class="form-control" name="fecha_nacimiento" id="fecha_nacimiento"
                                   value="<%= fechaNacimientoStr %>">
                        </div>
                    </div>

                    <div class="col-md-6 mb-3">
                        <label class="form-label">Telefono</label>
                        <div class="input-group-icon">
                            <i class="fas fa-phone"></i>
                            <input type="tel" class="form-control" name="telefono" id="telefono"
                                   value="<%= editar && p.getTelefono() != null ? p.getTelefono() : "" %>" 
                                   maxlength="20" placeholder="987654321">
                        </div>
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label">Direccion</label>
                    <div class="input-group-icon">
                        <i class="fas fa-map-marker-alt"></i>
                        <textarea class="form-control" name="direccion" id="direccion" rows="2" maxlength="255" 
                                  placeholder="Av. Principal 123, Distrito, Ciudad"><%= editar && p.getDireccion() != null ? p.getDireccion() : "" %></textarea>
                    </div>
                </div>

                <hr class="section-divider">

                <!-- SECCION: INFORMACION PROFESIONAL -->
                <div class="section-title">
                    <i class="fas fa-briefcase"></i>
                    Informacion Profesional
                </div>
                
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label required-field">Nivel que Enseña</label>
                        <select class="form-select" name="nivel" id="nivel" required>
                            <option value="">Seleccione un nivel</option>
                            <option value="INICIAL" <%= (editar && "INICIAL".equals(p.getNivel())) ? "selected" : "" %>>Inicial</option>
                            <option value="PRIMARIA" <%= (editar && "PRIMARIA".equals(p.getNivel())) ? "selected" : "" %>>Primaria</option>
                            <option value="SECUNDARIA" <%= (editar && "SECUNDARIA".equals(p.getNivel())) ? "selected" : "" %>>Secundaria</option>
                            <option value="TODOS" <%= (editar && "TODOS".equals(p.getNivel())) ? "selected" : "" %>>Todos los Niveles</option>
                        </select>
                        <div class="invalid-feedback"></div>
                    </div>
                    
                    <div class="col-md-6 mb-3">
                        <label class="form-label required-field">area</label>
                        <select class="form-select" name="area_id" id="area_id" required>
                            <option value="">Primero seleccione un nivel</option>
                            <% 
                                if (areas != null && !areas.isEmpty()) {
                                    for (Area area : areas) {
                                        boolean selected = editar && p.getAreaId() == area.getId();
                            %>
                                <option value="<%= area.getId() %>" 
                                        data-nivel="<%= area.getNivel() %>"
                                        <%= selected ? "selected" : "" %>
                                        style="display: none;">
                                    <%= area.getNombre() %>
                                </option>
                            <% 
                                    }
                                } else {
                            %>
                                <option value="" disabled>No hay areas disponibles</option>
                            <% 
                                }
                            %>
                        </select>
                        <small class="form-text">Las áreas se filtran segun el nivel seleccionado</small>
                        <div class="invalid-feedback"></div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label required-field">Turno</label>
                        <select class="form-select" name="turno_id" id="turno_id" required>
                            <option value="">Seleccione un turno</option>
                            <% 
                                if (turnos != null && !turnos.isEmpty()) {
                                    for (Turno turno : turnos) {
                                        boolean selected = editar && p.getTurnoId() == turno.getId();
                                        
                                        // Formatear las horas usando LocalTime directamente
                                        String horaInicio = "";
                                        String horaFin = "";
                                        if (turno.getHoraInicio() != null) {
                                            horaInicio = turno.getHoraInicio().format(DateTimeFormatter.ofPattern("HH:mm"));
                                        }
                                        if (turno.getHoraFin() != null) {
                                            horaFin = turno.getHoraFin().format(DateTimeFormatter.ofPattern("HH:mm"));
                                        }
                            %>
                                <option value="<%= turno.getId() %>" <%= selected ? "selected" : "" %>>
                                    <%= turno.getNombre() %> (<%= horaInicio %> - <%= horaFin %>)
                                </option>
                            <% 
                                    }
                                } else {
                            %>
                                <option value="" disabled>No hay turnos disponibles</option>
                            <%
                                }
                            %>
                        </select>
                        <div class="invalid-feedback"></div>
                    </div>
                    
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Codigo de Profesor</label>
                        <div class="input-group-icon">
                            <i class="fas fa-barcode"></i>
                            <input type="text" class="form-control" name="codigo_profesor"
                                   value="<%= editar && p.getCodigoProfesor() != null ? p.getCodigoProfesor() : "" %>" 
                                   maxlength="20" placeholder="PROF-001">
                        </div>
                        <small class="form-text">Opcional, se generar automaticamente</small>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Fecha de Contratacion</label>
                        <div class="input-group-icon">
                            <i class="fas fa-calendar-check"></i>
                            <input type="date" class="form-control" name="fecha_contratacion" id="fecha_contratacion"
                                   value="<%= fechaContratacionStr %>">
                        </div>
                    </div>

                    <div class="col-md-6 mb-3">
                        <label class="form-label">Estado</label>
                        <select name="estado" class="form-select">
                            <option value="ACTIVO" <%= (editar && "ACTIVO".equals(p.getEstado())) ? "selected" : "" %>>ACTIVO</option>
                            <option value="INACTIVO" <%= (editar && "INACTIVO".equals(p.getEstado())) ? "selected" : "" %>>INACTIVO</option>
                            <option value="LICENCIA" <%= (editar && "LICENCIA".equals(p.getEstado())) ? "selected" : "" %>>LICENCIA</option>
                            <option value="JUBILADO" <%= (editar && "JUBILADO".equals(p.getEstado())) ? "selected" : "" %>>JUBILADO</option>
                        </select>
                    </div>
                </div> 
                
                <!-- ========================================
                        SECCION: DISPONIBILIDAD HORARIA
                        ======================================== -->
                <hr class="section-divider">
                <div class="section-title">
                    <i class="fas fa-calendar-alt"></i>
                    Disponibilidad Horaria
                </div>

                <div class="alert alert-info alert-modern">
                    <i class="fas fa-info-circle"></i>
                    Selecciona los dias y horarios en los que el profesor esta disponible para dictar clases.
                </div>

                <div id="disponibilidad-container">
                    <!-- Tabla para mostrar disponibilidades existentes -->
                    <table class="table table-bordered" id="tabla-disponibilidades">
                        <thead>
                            <tr>
                                <th>Dia</th>
                                <th>Hora Inicio</th>
                                <th>Hora Fin</th>
                            </tr>
                        </thead>
                        <tbody id="disponibilidades-body">
                            <!-- Se llenaran dinamicamente -->
                            <tr id="sin-disponibilidades">
                                <td colspan="3" class="text-center text-muted">
                                    <i class="fas fa-info-circle"></i> No hay disponibilidades registradas
                                </td>
                            </tr>
                        </tbody>
                    </table>

                    <button type="button" class="btn btn-success-modern" id="btn-agregar-disponibilidad">
                        <i class="fas fa-plus"></i> Agregar Horario Disponible
                    </button>
                </div>

                <!-- Modal para agregar disponibilidad -->
                <div class="modal fade" id="modalDisponibilidad" tabindex="-1">
                    <div class="modal-dialog">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5 class="modal-title">Agregar Horario Disponible</h5>
                                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                            </div>
                            <div class="modal-body">
                                <div class="mb-3">
                                    <label class="form-label required-field">Dia de la Semana</label>
                                    <select class="form-select" id="modal-dia" required>
                                        <option value="">Seleccione un dia</option>
                                        <option value="LUNES">Lunes</option>
                                        <option value="MARTES">Martes</option>
                                        <option value="MIERCOLES">Miercoles</option>
                                        <option value="JUEVES">Jueves</option>
                                        <option value="VIERNES">Viernes</option>
                                        <option value="SABADO">Sabado</option>
                                    </select>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label required-field">Hora de Inicio</label>
                                    <input type="time" class="form-control" id="modal-hora-inicio" required>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label required-field">Hora de Fin</label>
                                    <input type="time" class="form-control" id="modal-hora-fin" required>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn-modern btn-secondary-modern" data-bs-dismiss="modal">
                                    <i class="fas fa-times"></i> Cancelar
                                </button>
                                <button type="button" class="btn-modern btn-primary-modern" id="btn-guardar-disponibilidad">
                                    <i class="fas fa-save"></i> Guardar Horario
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Campos ocultos para enviar disponibilidades al servidor -->
                <div id="disponibilidades-hidden"></div>
                
                <!-- BOTONES -->
                <div class="d-flex justify-content-between align-items-center mt-4 pt-3" style="border-top: 1px solid #e5e7eb;">
                    <div class="d-flex gap-2">
                        <button type="submit" class="btn-modern <%= editar ? "btn-primary-modern" : "btn-success-modern" %>">
                            <i class="fas <%= editar ? "fa-save" : "fa-check" %>"></i>
                            <%= editar ? "Actualizar Profesor" : "Registrar Profesor" %>
                        </button>
                        <a href="ProfesorServlet" class="btn-modern btn-secondary-modern">
                            <i class="fas fa-times"></i>
                            Cancelar
                        </a>
                    </div>
                    
                    <% if (editar) { %>
                    <a href="ProfesorServlet?accion=eliminar&id=<%= p.getId() %>" 
                       class="btn-modern btn-danger-modern"
                       onclick="return confirm('¿Esta seguro de eliminar este profesor?')">
                        <i class="fas fa-trash"></i>
                        Eliminar
                    </a>
                    <% } %>
                </div>
            </form>
        </div>
    </div>

    <footer class="bg-dark text-white py-4 mt-5">
        <div class="container text-center text-md-start">
            <div class="row">
                <div class="col-md-4 mb-3">
                    <div class="logo-container text-center">
                        <img src="assets/img/logosa.png" alt="Logo" class="img-fluid mb-2" width="80" height="auto">
                        <p class="fs-6 mb-0">"Lideres en educacion de calidad al mas alto nivel"</p>
                    </div>
                </div>

                <div class="col-md-4 mb-3">
                    <h5 class="fs-6 fw-bold">Contacto:</h5>
                    <p class="fs-6 mb-1">Direccion: Av. El Sol 461, San Juan de Lurigancho 15434</p>
                    <p class="fs-6 mb-1">Telefono: 987654321</p>
                    <p class="fs-6 mb-1">Correo: colegiosanantonio@gmail.com</p>
                </div>

                <div class="col-md-4 mb-3">
                    <h5 class="fs-6 fw-bold">Siguenos:</h5>
                    <a href="https://www.facebook.com/" class="text-white d-block fs-6 mb-1">Facebook</a>
                    <a href="https://www.instagram.com/" class="text-white d-block fs-6 mb-1">Instagram</a>
                    <a href="https://twitter.com/" class="text-white d-block fs-6 mb-1">Twitter</a>
                    <a href="https://www.youtube.com/" class="text-white d-block fs-6 mb-1">YouTube</a>
                </div>
            </div>

            <div class="text-center mt-3 pt-3" style="border-top: 1px solid rgba(255,255,255,0.1);">
                <p class="fs-6 mb-0">&copy; 2025 Colegio SA - Todos los derechos reservados</p>
            </div>
        </div>
    </footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
// ============================================================
// VARIABLES GLOBALES - FUERA DE DOMContentLoaded
// ============================================================
let disponibilidadesArray = [];
let modalDisponibilidad;

// ============================================================
// FUNCIONES GLOBALES - FUERA DE DOMContentLoaded
// ============================================================

function actualizarCamposOcultos() {
    const container = document.getElementById('disponibilidades-hidden');
    
    if (!container) {
        console.error('? ERROR: No se encontró el contenedor disponibilidades-hidden');
        return;
    }
    
    container.innerHTML = '';
    
    console.log('? Actualizando campos ocultos...');
    console.log('   ? Total disponibilidades en array:', disponibilidadesArray.length);
    console.log('   ? Array completo:', JSON.stringify(disponibilidadesArray, null, 2));
    
    const inputTotal = document.createElement('input');
    inputTotal.type = 'hidden';
    inputTotal.name = 'total_disponibilidades';
    inputTotal.value = disponibilidadesArray.length;
    container.appendChild(inputTotal);
    console.log('? Campo total_disponibilidades creado:', inputTotal.value);
    
        DisponibilidadesArray.forEach((disp, index) => {
            console.log(`? Disponibilidad ${index}:`, disp);
            console.log(`   - dia: "${disp.dia}" (tipo: ${typeof disp.dia})`);
            console.log(`   - turnoId: "${disp.turnoId}" (tipo: ${typeof disp.turnoId})`);
            console.log(`   - horaInicio: "${disp.horaInicio}" (tipo: ${typeof disp.horaInicio})`);
            console.log(`   - horaFin: "${disp.horaFin}" (tipo: ${typeof disp.horaFin})`);

        const inputDia = document.createElement('input');
        inputDia.type = 'hidden';
        inputDia.name = `disp_dia_${index}`;
        inputDia.value = disp.dia !== undefined && disp.dia !== null ? disp.dia : '';
        container.appendChild(inputDia);
        console.log(`   ? disp_dia_${index} = "${inputDia.value}"`);
        
        const inputTurno = document.createElement('input');
        inputTurno.type = 'hidden';
        inputTurno.name = `disp_turno_${index}`;
        inputTurno.value = disp.turnoId !== undefined && disp.turnoId !== null ? disp.turnoId : '';
        container.appendChild(inputTurno);
        console.log(`   ? disp_turno_${index} = "${inputTurno.value}"`);
        
        const inputHoraInicio = document.createElement('input');
        inputHoraInicio.type = 'hidden';
        inputHoraInicio.name = `disp_hora_inicio_${index}`;
        inputHoraInicio.value = disp.horaInicio !== undefined && disp.horaInicio !== null ? disp.horaInicio : '';
        container.appendChild(inputHoraInicio);
        console.log(`   ? disp_hora_inicio_${index} = "${inputHoraInicio.value}"`);
        
        const inputHoraFin = document.createElement('input');
        inputHoraFin.type = 'hidden';
        inputHoraFin.name = `disp_hora_fin_${index}`;
        inputHoraFin.value = disp.horaFin !== undefined && disp.horaFin !== null ? disp.horaFin : '';
        container.appendChild(inputHoraFin);
        console.log(`   ? disp_hora_fin_${index} = "${inputHoraFin.value}"`);
        
        const inputDisponible = document.createElement('input');
        inputDisponible.type = 'hidden';
        inputDisponible.name = `disp_disponible_${index}`;
        inputDisponible.value = disp.disponible !== undefined && disp.disponible !== null ? disp.disponible : true;
        container.appendChild(inputDisponible);
        console.log(`   ? disp_disponible_${index} = "${inputDisponible.value}"`);
    });
    
    console.log(`? Campos ocultos actualizados: ${disponibilidadesArray.length} disponibilidades`);
    console.log('? Contenedor HTML preview:', container.innerHTML.substring(0, 800));
}

function actualizarTablaDisponibilidades() {
    const tbody = document.getElementById('disponibilidades-body');
    const filaSinDatos = document.getElementById('sin-disponibilidades');
    
    if (disponibilidadesArray.length === 0) {
        if (filaSinDatos) {
            filaSinDatos.style.display = '';
        }
        actualizarCamposOcultos();
        return;
    }
    
    if (filaSinDatos) {
        filaSinDatos.style.display = 'none';
    }
    
    Array.from(tbody.children).forEach(row => {
        if (row.id !== 'sin-disponibilidades') {
            row.remove();
        }
    });
    
    disponibilidadesArray.forEach((disp, index) => {
        const fila = document.createElement('tr');
        fila.innerHTML = `
            <td>${disp.dia}</td>
            <td>${disp.horaInicio}</td>
            <td>${disp.horaFin}</td>
        `;
        tbody.appendChild(fila);
    });
    
    actualizarCamposOcultos();
}

function cargarDisponibilidadesExistentes(disponibilidades) {
    disponibilidadesArray = disponibilidades;
    actualizarTablaDisponibilidades();
}

// ============================================================
// CÓDIGO QUE SE EJECUTA AL CARGAR LA PÁGINA
// ============================================================
document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementById('profesorForm');
    const dniInput = document.getElementById('dni');
    const correoInput = document.getElementById('correo');
    const fechaNacInput = document.getElementById('fecha_nacimiento');
    const fechaContInput = document.getElementById('fecha_contratacion');
    const nivelSelect = document.getElementById('nivel');
    const areaSelect = document.getElementById('area_id');
    
    function filtrarAreas() {
        const nivelSeleccionado = nivelSelect.value;
        const opciones = areaSelect.querySelectorAll('option');
        let areasVisibles = 0;

        areaSelect.value = '';

        opciones.forEach(function(opcion) {
            if (opcion.value === '') {
                opcion.style.display = '';
                if (nivelSeleccionado === '') {
                    opcion.textContent = 'Primero seleccione un nivel';
                } else {
                    opcion.textContent = 'Seleccione el area';
                }
                return;
            }

            const nivelArea = opcion.getAttribute('data-nivel');

            if (nivelSeleccionado === 'TODOS') {
                if (nivelArea === 'TODOS') {
                    opcion.style.display = '';
                    areasVisibles++;
                } else {
                    opcion.style.display = 'none';
                }
            } else {
                if (nivelArea === 'TODOS' || nivelArea === nivelSeleccionado) {
                    opcion.style.display = '';
                    areasVisibles++;
                } else {
                    opcion.style.display = 'none';
                }
            }
        });

        if (areasVisibles === 0 && nivelSeleccionado !== '') {
            const placeholder = areaSelect.querySelector('option[value=""]');
            placeholder.textContent = 'No hay areas disponibles para este nivel';
        }
    }
    
    nivelSelect.addEventListener('change', filtrarAreas);
    filtrarAreas();
    
    if (!<%= editar %>) {
        if (!fechaNacInput.value) {
            const hace30Anios = new Date();
            hace30Anios.setFullYear(hace30Anios.getFullYear() - 30);
            fechaNacInput.valueAsDate = hace30Anios;
        }
        
        if (!fechaContInput.value) {
            fechaContInput.valueAsDate = new Date();
        }
    }
    
    if (dniInput) {
        dniInput.addEventListener('input', function() {
            this.value = this.value.replace(/[^0-9]/g, '');
            if (this.value.length > 8) {
                this.value = this.value.slice(0, 8);
            }
        });
        
        dniInput.addEventListener('blur', function() {
            const dni = this.value.trim();
            const feedback = this.parentElement.nextElementSibling.nextElementSibling;
            const validFeedback = feedback.nextElementSibling;
            
            if (dni.length === 0) {
                this.classList.remove('is-invalid', 'is-valid');
                feedback.textContent = '';
                if (validFeedback) validFeedback.textContent = '';
                return;
            }
            
            if (dni.length !== 8) {
                this.classList.add('is-invalid');
                this.classList.remove('is-valid');
                feedback.textContent = 'El DNI debe tener exactamente 8 digitos';
            } else {
                this.classList.remove('is-invalid');
                this.classList.add('is-valid');
                feedback.textContent = '';
                if (validFeedback) validFeedback.textContent = ' DNI valido';
            }
        });
    }
    
    if (correoInput) {
        correoInput.addEventListener('blur', function() {
            const correo = this.value.trim();
            const feedback = this.parentElement.nextElementSibling;
            const validFeedback = feedback.nextElementSibling;
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            
            if (correo.length === 0) {
                this.classList.add('is-invalid');
                feedback.textContent = 'El correo electronico es obligatorio';
                return;
            }
            
            if (!emailRegex.test(correo)) {
                this.classList.add('is-invalid');
                this.classList.remove('is-valid');
                feedback.textContent = 'Ingrese un correo electrónico válido';
            } else {
                this.classList.remove('is-invalid');
                this.classList.add('is-valid');
                feedback.textContent = '';
                if (validFeedback) validFeedback.textContent = ' Correo válido';
            }
        });
    }
    
    const telefonoInput = document.getElementById('telefono');
    if (telefonoInput) {
        telefonoInput.addEventListener('input', function() {
            this.value = this.value.replace(/[^0-9]/g, '');
        });
    }
    
    form.addEventListener('submit', function(event) {
        console.log("? FORMULARIO A PUNTO DE ENVIARSE");
        console.log("? Actualizando campos ocultos ANTES de validar...");
        actualizarCamposOcultos();
        console.log("? Campos ocultos actualizados");

        let errores = [];
        console.log("? Disponibilidades en array:", disponibilidadesArray.length);
        console.log("? Contenido del array:", disponibilidadesArray);
        
        const container = document.getElementById("disponibilidades-hidden");
        if (container) {
            console.log("? Campos ocultos HTML:", container.innerHTML.substring(0, 500));
            const inputs = container.querySelectorAll("input");
            console.log("? Total de inputs ocultos:", inputs.length);
            inputs.forEach(input => console.log(`   ${input.name} = ${input.value}`));
        }

        const nombres = document.getElementById('nombres').value.trim();
        const apellidos = document.getElementById('apellidos').value.trim();
        const correo = correoInput.value.trim();
        const areaId = areaSelect.value;
        const nivel = nivelSelect.value;
        const turnoId = document.getElementById('turno_id').value;
        const dni = dniInput.value.trim();
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

        if (!nombres) errores.push('Nombres es obligatorio');
        if (!apellidos) errores.push('Apellidos es obligatorio');

        if (!correo) {
            errores.push('Correo electrónico es obligatorio');
        } else if (!emailRegex.test(correo)) {
            errores.push('Correo electrónico no es válido');
        }

        if (!nivel || nivel === '') {
            errores.push('Nivel es obligatorio');
        }

        if (!areaId || areaId === '') {
            errores.push('Área es obligatoria');
        }

        if (!turnoId) errores.push('Turno es obligatorio');

        if (dni.length > 0) {
            if (dni.length !== 8) {
                errores.push('El DNI debe tener exactamente 8 dígitos');
            } else if (!/^\d+$/.test(dni)) {
                errores.push('El DNI solo debe contener números');
            }
        }

        if (errores.length > 0) {
            event.preventDefault();
            const mensajeError = 'Por favor corrija los siguientes errores:\n\n? ' + errores.join('\n? ');
            alert(mensajeError);

            const primerCampoInvalido = form.querySelector('.is-invalid');
            if (primerCampoInvalido) {
                primerCampoInvalido.scrollIntoView({ behavior: 'smooth', block: 'center' });
                primerCampoInvalido.focus();
            }

            return false;
        }

        return true;
    });
    
    const modalElement = document.getElementById('modalDisponibilidad');
    if (modalElement) {
        modalDisponibilidad = new bootstrap.Modal(modalElement);
        
        modalElement.addEventListener('hide.bs.modal', function(event) {
            const focusedElement = modalElement.querySelector(':focus');
            if (focusedElement) {
                focusedElement.blur();
            }
        });
        
        modalElement.addEventListener('hidden.bs.modal', function(event) {
            const btnAgregar = document.getElementById('btn-agregar-disponibilidad');
            if (btnAgregar) {
                setTimeout(() => btnAgregar.focus(), 100);
            }
        });
    }
    
    const btnAgregarDisponibilidad = document.getElementById('btn-agregar-disponibilidad');
    if (btnAgregarDisponibilidad) {
        btnAgregarDisponibilidad.addEventListener('click', function() {
            const turnoId = document.getElementById('turno_id').value;
            if (!turnoId) {
                alert('?? Por favor seleccione un TURNO en el formulario principal antes de agregar disponibilidades');
                document.getElementById('turno_id').focus();
                document.getElementById('turno_id').scrollIntoView({ behavior: 'smooth', block: 'center' });
                return;
            }
            
            document.getElementById('modal-dia').value = '';
            document.getElementById('modal-hora-inicio').value = '';
            document.getElementById('modal-hora-fin').value = '';
            
            modalDisponibilidad.show();
            
            setTimeout(() => {
                document.getElementById('modal-dia').focus();
            }, 300);
        });
    }
    
    const btnGuardarDisponibilidad = document.getElementById('btn-guardar-disponibilidad');
    if (btnGuardarDisponibilidad) {
        btnGuardarDisponibilidad.addEventListener('click', function() {
            const dia = document.getElementById('modal-dia').value;
            const horaInicio = document.getElementById('modal-hora-inicio').value;
            const horaFin = document.getElementById('modal-hora-fin').value;
            
            if (!dia || !horaInicio || !horaFin) {
                alert('?? Por favor complete todos los campos');
                return;
            }
            
            if (horaInicio >= horaFin) {
                alert('?? La hora de inicio debe ser menor que la hora de fin');
                return;
            }
            
            const turnoId = document.getElementById('turno_id').value;
            
            const disponibilidad = {
                dia: dia,
                turnoId: turnoId,
                horaInicio: horaInicio,
                horaFin: horaFin,
                disponible: true
            };
            
            disponibilidadesArray.push(disponibilidad);
            actualizarTablaDisponibilidades();
            
            document.getElementById('modal-dia').blur();
            document.getElementById('modal-hora-inicio').blur();
            document.getElementById('modal-hora-fin').blur();
            document.getElementById('btn-guardar-disponibilidad').blur();
            
            modalDisponibilidad.hide();
            
            console.log('? Disponibilidad agregada:', disponibilidad);
        });
    }
    
    console.log('? Sistema de disponibilidades inicializado');
    
    <% if (editar && p.getDisponibilidades() != null && !p.getDisponibilidades().isEmpty()) { %>
        console.log('? Cargando disponibilidades existentes del profesor...');
        
        const disponibilidadesExistentes = [
            <% 
            java.util.List<modelo.Disponibilidad> disponibilidades = p.getDisponibilidades();
            for (int i = 0; i < disponibilidades.size(); i++) {
                modelo.Disponibilidad disp = disponibilidades.get(i);
                
                String horaInicio = disp.getHoraInicio() != null ? disp.getHoraInicio().toString().substring(0, 5) : "";
                String horaFin = disp.getHoraFin() != null ? disp.getHoraFin().toString().substring(0, 5) : "";
            %>
            {
                dia: '<%= disp.getDiaSemana() %>',
                turnoId: <%= disp.getTurnoId() %>,
                horaInicio: '<%= horaInicio %>',
                horaFin: '<%= horaFin %>',
                disponible: <%= disp.isDisponible() %>
            }<%= (i < disponibilidades.size() - 1) ? "," : "" %>
            <% } %>
        ];
        
        console.log('? Disponibilidades cargadas:', disponibilidadesExistentes);
        cargarDisponibilidadesExistentes(disponibilidadesExistentes);
        console.log('? ' + disponibilidadesExistentes.length + ' disponibilidades cargadas en el formulario');
    <% } else if (editar) { %>
        console.log('?? Este profesor no tiene disponibilidades registradas');
    <% } else { %>
        console.log('?? Modo NUEVO profesor - Sin disponibilidades para cargar');
    <% } %>
});
</script>
</body>
</html>
