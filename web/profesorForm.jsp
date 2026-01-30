<%@ page import="modelo.Profesor" %>
<%@ page import="modelo.ProfesorDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    Profesor p = (Profesor) request.getAttribute("profesor");
    boolean esEdicion = (p != null && p.getId() > 0);
    
    List<ProfesorDAO.Turno> turnos = (List<ProfesorDAO.Turno>) request.getAttribute("turnos");
    List<ProfesorDAO.Area> areas = (List<ProfesorDAO.Area>) request.getAttribute("areas");
    
    String mensaje = (String) session.getAttribute("mensaje");
    String error = (String) session.getAttribute("error");
    
    if (mensaje != null) {
        session.removeAttribute("mensaje");
    }
    if (error != null) {
        session.removeAttribute("error");
    }
    
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    String fechaNacimientoStr = "";
    String fechaContratacionStr = "";
    
    if (esEdicion) {
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
    <title><%= esEdicion ? "Editar Profesor" : "Registrar Profesor"%> - Colegio SA</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="assets/css/estilos.css">
    <style>
        :root {
            --primary-color: #2563eb;
            --primary-dark: #1e40af;
            --secondary-color: #64748b;
            --success-color: #10b981;
            --danger-color: #ef4444;
            --warning-color: #f59e0b;
            --info-color: #3b82f6;
            --background-light: #f8fafc;
            --card-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            --card-shadow-hover: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
        }

        body.dashboard-page {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        .form-container {
            max-width: 950px;
            margin: 2rem auto;
            padding: 0 1rem;
            flex: 1;
        }

        .form-card {
            background: white;
            border-radius: 20px;
            box-shadow: var(--card-shadow-hover);
            overflow: hidden;
            animation: slideUp 0.5s ease-out;
        }

        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .form-header {
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-dark) 100%);
            color: white;
            padding: 2rem;
            text-align: center;
        }

        .form-header h2 {
            margin: 0;
            font-size: 1.75rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.75rem;
        }

        .form-header .icon {
            font-size: 2rem;
        }

        .form-body {
            padding: 2.5rem;
        }

        .section-title {
            color: #1e293b;
            font-size: 1.25rem;
            font-weight: 700;
            margin: 2rem 0 1.5rem 0;
            padding-bottom: 0.75rem;
            border-bottom: 3px solid var(--primary-color);
            display: flex;
            align-items: center;
            gap: 0.75rem;
            animation: fadeIn 0.5s ease-out;
        }

        .section-title:first-of-type {
            margin-top: 0;
        }

        .section-title i {
            font-size: 1.5rem;
            color: var(--primary-color);
        }

        .form-label {
            font-weight: 600;
            color: #334155;
            margin-bottom: 0.5rem;
            font-size: 0.95rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .form-label i {
            color: var(--primary-color);
        }

        .required-field::after {
            content: " *";
            color: var(--danger-color);
            font-weight: 700;
        }

        .form-control, .form-select, textarea.form-control {
            border: 2px solid #e2e8f0;
            border-radius: 10px;
            padding: 0.75rem 1rem;
            font-size: 1rem;
            transition: all 0.3s ease;
        }

        .form-control:focus, .form-select:focus, textarea.form-control:focus {
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
        }

        .form-control.is-invalid {
            border-color: var(--danger-color);
        }

        .form-control.is-valid {
            border-color: var(--success-color);
        }

        .form-select {
            cursor: pointer;
            background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3e%3cpath fill='none' stroke='%232563eb' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M2 5l6 6 6-6'/%3e%3c/svg%3e");
        }

        .input-icon {
            position: relative;
        }

        .input-icon i {
            position: absolute;
            left: 1rem;
            top: 50%;
            transform: translateY(-50%);
            color: var(--secondary-color);
            z-index: 10;
        }

        .input-icon .form-control,
        .input-icon .form-select,
        .input-icon textarea.form-control {
            padding-left: 2.75rem;
        }

        .mb-3 {
            margin-bottom: 1.5rem !important;
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

        .alert {
            border-radius: 12px;
            border: none;
            padding: 1rem 1.25rem;
            margin-bottom: 1.5rem;
            animation: slideDown 0.4s ease-out;
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        @keyframes slideDown {
            from {
                opacity: 0;
                transform: translateY(-20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .alert i {
            font-size: 1.5rem;
        }

        .alert-success {
            background: #d1fae5;
            color: #065f46;
            border-left: 4px solid var(--success-color);
        }

        .alert-danger {
            background: #fee2e2;
            color: #991b1b;
            border-left: 4px solid var(--danger-color);
        }

        small.form-text {
            color: #64748b;
            font-size: 0.85rem;
            display: block;
            margin-top: 0.25rem;
        }

        .btn-group-custom {
            display: flex;
            gap: 1rem;
            margin-top: 2.5rem;
            padding-top: 1.5rem;
            border-top: 2px solid #e5e7eb;
            flex-wrap: wrap;
            justify-content: space-between;
            align-items: center;
        }

        .btn {
            border-radius: 10px;
            padding: 0.75rem 1.75rem;
            font-weight: 600;
            font-size: 1rem;
            transition: all 0.3s ease;
            border: none;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            justify-content: center;
            text-decoration: none;
        }

        .btn-submit {
            background: linear-gradient(135deg, var(--success-color) 0%, #059669 100%);
            color: white;
        }

        .btn-submit:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(16, 185, 129, 0.3);
            color: white;
        }

        .btn-primary-custom {
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-dark) 100%);
            color: white;
        }

        .btn-primary-custom:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(37, 99, 235, 0.3);
            color: white;
        }

        .btn-cancel {
            background: var(--secondary-color);
            color: white;
        }

        .btn-cancel:hover {
            background: #475569;
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(100, 116, 139, 0.3);
            color: white;
        }

        .btn-outline-danger {
            border: 2px solid var(--danger-color);
            color: var(--danger-color);
            background: transparent;
        }

        .btn-outline-danger:hover {
            background: var(--danger-color);
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(239, 68, 68, 0.3);
        }

        .tooltip-info {
            cursor: help;
            color: var(--info-color);
            margin-left: 0.25rem;
        }

        footer {
            margin-top: auto;
            background-color: #1a1a1a !important;
        }

        footer .logo-container img {
            border-radius: 15px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.3);
            background-color: white;
            padding: 5px;
        }

        footer h5 {
            font-weight: 700;
            margin-bottom: 1rem;
            color: #fff;
            font-size: 1.1rem;
        }

        footer p {
            color: #d1d5db;
            line-height: 1.8;
        }

        footer a {
            text-decoration: none;
            transition: all 0.3s ease;
            display: inline-block;
            color: #d1d5db;
        }

        footer a:hover {
            transform: translateX(5px);
            color: #60a5fa !important;
        }

        footer .border-top {
            border-color: #374151 !important;
        }

        footer i {
            color: #60a5fa;
        }

        @media (max-width: 768px) {
            .form-body {
                padding: 1.5rem;
            }

            .form-header h2 {
                font-size: 1.5rem;
            }

            .btn-group-custom {
                flex-direction: column;
            }

            .btn {
                width: 100%;
            }

            .section-title {
                font-size: 1.1rem;
            }
        }

        /* Animación para los campos del formulario */
        .row {
            animation: fadeIn 0.5s ease-out backwards;
        }

        .row:nth-child(1) {
            animation-delay: 0.1s;
        }

        .row:nth-child(2) {
            animation-delay: 0.2s;
        }

        .row:nth-child(3) {
            animation-delay: 0.3s;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
    </style>
</head>
<body class="dashboard-page">
    <jsp:include page="header.jsp" />

    <div class="form-container">
        <div class="form-card">
            <div class="form-header">
                <h2>
                    <i class="bi <%= esEdicion ? "bi-person-fill-gear" : "bi-person-plus-fill"%> icon"></i>
                    <%= esEdicion ? "Editar Profesor" : "Registrar Nuevo Profesor"%>
                </h2>
            </div>
            
            <div class="form-body">
                <!-- Mensajes de éxito/error -->
                <% if (mensaje != null) { %>
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <i class="bi bi-check-circle-fill"></i>
                        <div>
                            <strong>¡Éxito!</strong><br>
                            <%= mensaje %>
                        </div>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                <% } %>
                
                <% if (error != null) { %>
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <i class="bi bi-exclamation-triangle-fill"></i>
                        <div>
                            <strong>Error</strong><br>
                            <%= error %>
                        </div>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                <% } %>

                <form action="ProfesorServlet" method="post" id="profesorForm">
                    <input type="hidden" name="id" value="<%= esEdicion ? p.getId() : "" %>">
                    <input type="hidden" name="persona_id" value="<%= esEdicion ? p.getPersonaId() : "" %>">
                    
                    <!-- SECCIÓN: INFORMACIÓN PERSONAL -->
                    <h4 class="section-title">
                        <i class="bi bi-person-badge-fill"></i>
                        Información Personal
                    </h4>
                    
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label required-field">
                                <i class="bi bi-person-fill"></i>
                                Nombres
                            </label>
                            <div class="input-icon">
                                <i class="bi bi-pencil"></i>
                                <input type="text" class="form-control" name="nombres" id="nombres"
                                       value="<%= esEdicion && p.getNombres() != null ? p.getNombres() : "" %>" 
                                       required maxlength="100" placeholder="Ingrese los nombres">
                            </div>
                            <div class="invalid-feedback"></div>
                        </div>

                        <div class="col-md-6 mb-3">
                            <label class="form-label required-field">
                                <i class="bi bi-person-fill"></i>
                                Apellidos
                            </label>
                            <div class="input-icon">
                                <i class="bi bi-pencil"></i>
                                <input type="text" class="form-control" name="apellidos" id="apellidos"
                                       value="<%= esEdicion && p.getApellidos() != null ? p.getApellidos() : "" %>" 
                                       required maxlength="100" placeholder="Ingrese los apellidos">
                            </div>
                            <div class="invalid-feedback"></div>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label required-field">
                                <i class="bi bi-envelope-fill"></i>
                                Correo Electrónico
                            </label>
                            <div class="input-icon">
                                <i class="bi bi-at"></i>
                                <input type="email" class="form-control" name="correo" id="correo"
                                       value="<%= esEdicion && p.getCorreo() != null ? p.getCorreo() : "" %>" 
                                       required maxlength="100" placeholder="ejemplo@email.com">
                            </div>
                            <div class="invalid-feedback"></div>
                            <div class="valid-feedback"></div>
                        </div>

                        <div class="col-md-6 mb-3">
                            <label class="form-label">
                                <i class="bi bi-card-text"></i>
                                DNI
                                <i class="bi bi-info-circle tooltip-info" title="Opcional - 8 dígitos numéricos"></i>
                            </label>
                            <div class="input-icon">
                                <i class="bi bi-credit-card-2-front"></i>
                                <input type="text" class="form-control" name="dni" id="dni"
                                       value="<%= esEdicion && p.getDni() != null ? p.getDni() : "" %>" 
                                       maxlength="8" placeholder="12345678">
                            </div>
                            <small class="form-text">Opcional, 8 dígitos numéricos</small>
                            <div class="invalid-feedback"></div>
                            <div class="valid-feedback"></div>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label">
                                <i class="bi bi-calendar-event-fill"></i>
                                Fecha de Nacimiento
                            </label>
                            <div class="input-icon">
                                <i class="bi bi-calendar3"></i>
                                <input type="date" class="form-control" name="fecha_nacimiento" id="fecha_nacimiento"
                                       value="<%= fechaNacimientoStr %>">
                            </div>
                        </div>

                        <div class="col-md-6 mb-3">
                            <label class="form-label">
                                <i class="bi bi-telephone-fill"></i>
                                Teléfono
                            </label>
                            <div class="input-icon">
                                <i class="bi bi-phone"></i>
                                <input type="tel" class="form-control" name="telefono" id="telefono"
                                       value="<%= esEdicion && p.getTelefono() != null ? p.getTelefono() : "" %>" 
                                       maxlength="20" placeholder="987654321">
                            </div>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">
                            <i class="bi bi-geo-alt-fill"></i>
                            Dirección
                        </label>
                        <div class="input-icon">
                            <i class="bi bi-map"></i>
                            <textarea class="form-control" name="direccion" id="direccion" rows="2" maxlength="255" 
                                      placeholder="Av. Principal 123, Distrito, Ciudad"><%= esEdicion && p.getDireccion() != null ? p.getDireccion() : "" %></textarea>
                        </div>
                    </div>

                    <!-- SECCIÓN: INFORMACIÓN PROFESIONAL -->
                    <h4 class="section-title">
                        <i class="bi bi-briefcase-fill"></i>
                        Información Profesional
                    </h4>
                    
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label required-field">
                                <i class="bi bi-book-fill"></i>
                                Área / Especialidad
                            </label>
                            <div class="input-icon">
                                <i class="bi bi-journal-bookmark"></i>
                                <select class="form-select" name="area_id" id="area_id" required>
                                    <option value="">Seleccione un área</option>
                                    <% 
                                        if (areas != null && !areas.isEmpty()) {
                                            for (ProfesorDAO.Area area : areas) {
                                                boolean selected = esEdicion && p.getAreaId() == area.getId();
                                    %>
                                        <option value="<%= area.getId() %>" <%= selected ? "selected" : "" %>>
                                            <%= area.getNombre() %> 
                                            <% if (area.getNivel() != null && !area.getNivel().equals("TODOS")) { %>
                                                (<%= area.getNivel() %>)
                                            <% } %>
                                        </option>
                                    <% 
                                            }
                                        } else {
                                    %>
                                        <option value="" disabled>No hay áreas disponibles</option>
                                    <% 
                                        }
                                    %>
                                </select>
                            </div>
                            <small class="form-text">Seleccione el área de especialización del profesor</small>
                            <div class="invalid-feedback"></div>
                        </div>

                        <div class="col-md-6 mb-3">
                            <label class="form-label required-field">
                                <i class="bi bi-mortarboard-fill"></i>
                                Nivel que Enseña
                            </label>
                            <div class="input-icon">
                                <i class="bi bi-diagram-3"></i>
                                <select class="form-select" name="nivel" id="nivel" required>
                                    <option value="">Seleccione un nivel</option>
                                    <option value="INICIAL" <%= (esEdicion && "INICIAL".equals(p.getNivel())) ? "selected" : "" %>>🎨 Inicial</option>
                                    <option value="PRIMARIA" <%= (esEdicion && "PRIMARIA".equals(p.getNivel())) ? "selected" : "" %>>📚 Primaria</option>
                                    <option value="SECUNDARIA" <%= (esEdicion && "SECUNDARIA".equals(p.getNivel())) ? "selected" : "" %>>🎓 Secundaria</option>
                                    <option value="TODOS" <%= (esEdicion && "TODOS".equals(p.getNivel())) ? "selected" : "" %>>🌟 Todos los Niveles</option>
                                </select>
                            </div>
                            <div class="invalid-feedback"></div>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label required-field">
                                <i class="bi bi-clock-fill"></i>
                                Turno
                            </label>
                            <div class="input-icon">
                                <i class="bi bi-clock-history"></i>
                                <select class="form-select" name="turno_id" id="turno_id" required>
                                    <option value="">Seleccione un turno</option>
                                    <% 
                                        if (turnos != null && !turnos.isEmpty()) {
                                            for (ProfesorDAO.Turno turno : turnos) {
                                                boolean selected = esEdicion && p.getTurnoId() == turno.getId();
                                    %>
                                        <option value="<%= turno.getId() %>" <%= selected ? "selected" : "" %>>
                                            <%= turno.getNombre() %> 
                                            (<%= new SimpleDateFormat("HH:mm").format(turno.getHoraInicio()) %> - 
                                             <%= new SimpleDateFormat("HH:mm").format(turno.getHoraFin()) %>)
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
                            </div>
                            <div class="invalid-feedback"></div>
                        </div>

                        <div class="col-md-6 mb-3">
                            <label class="form-label">
                                <i class="bi bi-upc-scan"></i>
                                Código de Profesor
                            </label>
                            <div class="input-icon">
                                <i class="bi bi-hash"></i>
                                <input type="text" class="form-control" name="codigo_profesor" id="codigo_profesor"
                                       value="<%= esEdicion && p.getCodigoProfesor() != null ? p.getCodigoProfesor() : "" %>" 
                                       maxlength="20" placeholder="PROF-001">
                            </div>
                            <small class="form-text">Opcional, se generará automáticamente</small>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label">
                                <i class="bi bi-calendar-check-fill"></i>
                                Fecha de Contratación
                            </label>
                            <div class="input-icon">
                                <i class="bi bi-calendar-plus"></i>
                                <input type="date" class="form-control" name="fecha_contratacion" id="fecha_contratacion"
                                       value="<%= fechaContratacionStr %>">
                            </div>
                        </div>

                        <div class="col-md-6 mb-3">
                            <label class="form-label">
                                <i class="bi bi-toggle-on"></i>
                                Estado
                            </label>
                            <div class="input-icon">
                                <i class="bi bi-activity"></i>
                                <select name="estado" id="estado" class="form-select">
                                    <option value="ACTIVO" <%= (esEdicion && "ACTIVO".equals(p.getEstado())) ? "selected" : "" %>>✅ ACTIVO</option>
                                    <option value="INACTIVO" <%= (esEdicion && "INACTIVO".equals(p.getEstado())) ? "selected" : "" %>>⛔ INACTIVO</option>
                                    <option value="LICENCIA" <%= (esEdicion && "LICENCIA".equals(p.getEstado())) ? "selected" : "" %>>🏥 LICENCIA</option>
                                    <option value="JUBILADO" <%= (esEdicion && "JUBILADO".equals(p.getEstado())) ? "selected" : "" %>>🎖️ JUBILADO</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <!-- BOTONES -->
                    <div class="btn-group-custom">
                        <div style="display: flex; gap: 1rem; flex-wrap: wrap;">
                            <button type="submit" class="btn <%= esEdicion ? "btn-primary-custom" : "btn-submit" %>">
                                <i class="bi <%= esEdicion ? "bi-check-circle" : "bi-save"%>"></i>
                                <%= esEdicion ? "Actualizar Profesor" : "Registrar Profesor" %>
                            </button>
                            <a href="ProfesorServlet?accion=listar" class="btn btn-cancel">
                                <i class="bi bi-x-circle"></i>
                                Cancelar
                            </a>
                        </div>
                        
                        <% if (esEdicion) { %>
                        <a href="ProfesorServlet?accion=eliminar&id=<%= p.getId() %>" 
                           class="btn btn-outline-danger"
                           onclick="return confirm('¿Está seguro de eliminar este profesor?')">
                            <i class="bi bi-trash"></i>
                            Eliminar
                        </a>
                        <% } %>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <footer class="text-white py-4 mt-5" style="background-color: #1a1a1a;">
        <div class="container text-center text-md-start">
            <div class="row">
                <div class="col-md-4 mb-3">
                    <div class="logo-container text-center">
                        <img src="assets/img/logosa.png" alt="Logo Colegio SA" class="img-fluid mb-2" width="90" height="auto">
                        <p class="fs-6 fw-light fst-italic">"Líderes en educación de calidad al más alto nivel"</p>
                    </div>
                </div>
                <div class="col-md-4 mb-3">
                    <h5 class="fs-6"><i class="bi bi-envelope-fill me-2"></i>Contacto</h5>
                    <p class="fs-6 mb-2"><i class="bi bi-geo-alt-fill me-2"></i>Av. El Sol 461, San Juan de Lurigancho 15434</p>
                    <p class="fs-6 mb-2"><i class="bi bi-telephone-fill me-2"></i>987 654 321</p>
                    <p class="fs-6 mb-0"><i class="bi bi-envelope-at-fill me-2"></i>colegiosanantonio@gmail.com</p>
                </div>
                <div class="col-md-4 mb-3">
                    <h5 class="fs-6"><i class="bi bi-share-fill me-2"></i>Síguenos</h5>
                    <a href="https://www.facebook.com/" class="text-white d-block fs-6 mb-2">
                        <i class="bi bi-facebook me-2"></i>Facebook
                    </a>
                    <a href="https://www.instagram.com/" class="text-white d-block fs-6 mb-2">
                        <i class="bi bi-instagram me-2"></i>Instagram
                    </a>
                    <a href="https://twitter.com/" class="text-white d-block fs-6 mb-2">
                        <i class="bi bi-twitter-x me-2"></i>Twitter
                    </a>
                    <a href="https://www.youtube.com/" class="text-white d-block fs-6 mb-2">
                        <i class="bi bi-youtube me-2"></i>YouTube
                    </a>
                </div>
            </div>
            <div class="text-center mt-3 pt-3 border-top">
                <p class="fs-6 mb-0">
                    <i class="bi bi-c-circle me-1"></i>2025 Colegio SA - Todos los derechos reservados
                </p>
            </div>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const form = document.getElementById('profesorForm');
            const dniInput = document.getElementById('dni');
            const correoInput = document.getElementById('correo');
            const fechaNacInput = document.getElementById('fecha_nacimiento');
            const fechaContInput = document.getElementById('fecha_contratacion');
            
            console.log('=== FORMULARIO PROFESOR INICIALIZADO (SIN CREDENCIALES) ===');
            console.log('Modo edición:', <%= esEdicion %>);
            
            // Establecer fechas por defecto si no estamos editando
            if (!<%= esEdicion %>) {
                if (!fechaNacInput.value) {
                    const hace30Anios = new Date();
                    hace30Anios.setFullYear(hace30Anios.getFullYear() - 30);
                    fechaNacInput.valueAsDate = hace30Anios;
                }
                
                if (!fechaContInput.value) {
                    fechaContInput.valueAsDate = new Date();
                }
            }
            
            // Validación del DNI
            if (dniInput) {
                dniInput.addEventListener('input', function() {
                    this.value = this.value.replace(/[^0-9]/g, '');
                    if (this.value.length > 8) {
                        this.value = this.value.slice(0, 8);
                    }
                });
                
                dniInput.addEventListener('blur', function() {
                    const dni = this.value.trim();
                    const feedback = this.parentElement.parentElement.querySelector('.invalid-feedback');
                    const validFeedback = this.parentElement.parentElement.querySelector('.valid-feedback');
                    
                    if (dni.length === 0) {
                        this.classList.remove('is-invalid', 'is-valid');
                        if (feedback) feedback.textContent = '';
                        if (validFeedback) validFeedback.textContent = '';
                        return;
                    }
                    
                    if (dni.length !== 8) {
                        this.classList.add('is-invalid');
                        this.classList.remove('is-valid');
                        if (feedback) feedback.textContent = '❌ El DNI debe tener exactamente 8 dígitos';
                    } else {
                        this.classList.remove('is-invalid');
                        this.classList.add('is-valid');
                        if (feedback) feedback.textContent = '';
                        if (validFeedback) validFeedback.textContent = '✓ DNI válido';
                    }
                });
            }
            
            // Validación del correo
            if (correoInput) {
                correoInput.addEventListener('blur', function() {
                    const correo = this.value.trim();
                    const feedback = this.parentElement.parentElement.querySelector('.invalid-feedback');
                    const validFeedback = this.parentElement.parentElement.querySelector('.valid-feedback');
                    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                    
                    if (correo.length === 0) {
                        this.classList.add('is-invalid');
                        if (feedback) feedback.textContent = '❌ El correo electrónico es obligatorio';
                        return;
                    }
                    
                    if (!emailRegex.test(correo)) {
                        this.classList.add('is-invalid');
                        this.classList.remove('is-valid');
                        if (feedback) feedback.textContent = '❌ Ingrese un correo electrónico válido';
                    } else {
                        this.classList.remove('is-invalid');
                        this.classList.add('is-valid');
                        if (feedback) feedback.textContent = '';
                        if (validFeedback) validFeedback.textContent = '✓ Correo válido';
                    }
                });
            }
            
            // Validación del teléfono (solo números)
            const telefonoInput = document.getElementById('telefono');
            if (telefonoInput) {
                telefonoInput.addEventListener('input', function() {
                    this.value = this.value.replace(/[^0-9]/g, '');
                });
            }
            
            // Validación antes de enviar el formulario
            form.addEventListener('submit', function(event) {
                console.log('=== VALIDANDO FORMULARIO ===');
                
                let errores = [];
                
                // Obtener valores
                const nombres = document.getElementById('nombres').value.trim();
                const apellidos = document.getElementById('apellidos').value.trim();
                const correo = correoInput.value.trim();
                const areaId = document.getElementById('area_id').value;
                const nivel = document.getElementById('nivel').value;
                const turnoId = document.getElementById('turno_id').value;
                const dni = dniInput.value.trim();
                const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                
                console.log('Valores del formulario:');
                console.log('- Nombres:', nombres);
                console.log('- Apellidos:', apellidos);
                console.log('- Correo:', correo);
                console.log('- Área ID:', areaId);
                console.log('- Nivel:', nivel);
                console.log('- Turno ID:', turnoId);
                console.log('- DNI:', dni);
                
                // Validar campos obligatorios
                if (!nombres) errores.push('Nombres es obligatorio');
                if (!apellidos) errores.push('Apellidos es obligatorio');
                
                if (!correo) {
                    errores.push('Correo electrónico es obligatorio');
                } else if (!emailRegex.test(correo)) {
                    errores.push('Correo electrónico no es válido');
                }
                
                if (!areaId || areaId === '' || areaId === '0') {
                    errores.push('Área / Especialidad es obligatoria');
                }
                
                if (!nivel || nivel === '') {
                    errores.push('Nivel es obligatorio');
                }
                
                if (!turnoId || turnoId === '' || turnoId === '0') {
                    errores.push('Turno es obligatorio');
                }
                
                // Validar DNI si se proporciona
                if (dni.length > 0) {
                    if (dni.length !== 8) {
                        errores.push('El DNI debe tener exactamente 8 dígitos');
                    } else if (!/^\d+$/.test(dni)) {
                        errores.push('El DNI solo debe contener números');
                    }
                }
                
                if (errores.length > 0) {
                    event.preventDefault();
                    
                    console.error('❌ ERRORES DE VALIDACIÓN:', errores);
                    
                    // Mostrar errores
                    const mensajeError = 'Por favor corrija los siguientes errores:\n\n• ' + errores.join('\n• ');
                    alert(mensajeError);
                    
                    // Hacer scroll al primer error
                    const primerCampoInvalido = form.querySelector('.is-invalid') || 
                                                 form.querySelector('[required]:invalid');
                    if (primerCampoInvalido) {
                        primerCampoInvalido.scrollIntoView({ behavior: 'smooth', block: 'center' });
                        primerCampoInvalido.focus();
                    }
                    
                    return false;
                }
                
                console.log('✅ Validación exitosa - Enviando formulario');
                console.log('NOTA: Las credenciales de usuario se gestionan por separado');
                return true;
            });
        });
    </script>
</body>
</html>
