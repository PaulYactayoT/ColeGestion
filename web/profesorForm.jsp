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
    <title><%= esEdicion ? "Editar Profesor" : "Registrar Profesor"%></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="assets/css/estilos.css">
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
        }

        .form-wrapper {
            max-width: 900px;
            margin: 2rem auto;
            padding: 0 15px;
        }

        .form-header {
            background: linear-gradient(135deg, var(--dark-color), #374151);
            border-radius: 15px 15px 0 0;
            padding: 1.5rem 2rem;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            border-bottom: 3px solid var(--primary-color);
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
        }

        .form-control.is-valid {
            border-color: var(--success-color);
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

        .btn-success-modern {
            background: linear-gradient(135deg, #10b981, #059669);
            color: white;
        }

        .btn-success-modern:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 15px rgba(16, 185, 129, 0.3);
            color: white;
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

        .input-group-icon .form-control,
        .input-group-icon .form-select {
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
        <!-- Mensajes -->
        <% if (mensaje != null) { %>
            <div class="alert-modern alert-success alert-dismissible fade show" role="alert">
                <i class="fas fa-check-circle"></i>
                <div>
                    <strong>¡Éxito!</strong><br>
                    <%= mensaje %>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } %>
        
        <% if (error != null) { %>
            <div class="alert-modern alert-danger alert-dismissible fade show" role="alert">
                <i class="fas fa-exclamation-circle"></i>
                <div>
                    <strong>Error</strong><br>
                    <%= error %>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } %>

        <!-- Header del Formulario -->
        <div class="form-header">
            <h2>
                <div class="icon">
                    <i class="fas <%= esEdicion ? "fa-user-edit" : "fa-user-plus" %>"></i>
                </div>
                <%= esEdicion ? "Editar Profesor" : "Registrar Nuevo Profesor"%>
            </h2>
        </div>

        <!-- Formulario -->
        <div class="form-card">
            <form action="ProfesorServlet" method="post" id="profesorForm">
                <input type="hidden" name="id" value="<%= esEdicion ? p.getId() : "" %>">
                <input type="hidden" name="persona_id" value="<%= esEdicion ? p.getPersonaId() : "" %>">
                
                <!-- SECCIÓN: INFORMACIÓN PERSONAL -->
                <div class="section-title">
                    <i class="fas fa-user"></i>
                    Información Personal
                </div>
                
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label required-field">Nombres</label>
                        <div class="input-group-icon">
                            <i class="fas fa-user"></i>
                            <input type="text" class="form-control" name="nombres" id="nombres"
                                   value="<%= esEdicion && p.getNombres() != null ? p.getNombres() : "" %>" 
                                   required maxlength="100" placeholder="Ingrese los nombres">
                        </div>
                        <div class="invalid-feedback"></div>
                    </div>

                    <div class="col-md-6 mb-3">
                        <label class="form-label required-field">Apellidos</label>
                        <div class="input-group-icon">
                            <i class="fas fa-user"></i>
                            <input type="text" class="form-control" name="apellidos" id="apellidos"
                                   value="<%= esEdicion && p.getApellidos() != null ? p.getApellidos() : "" %>" 
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
                                   value="<%= esEdicion && p.getCorreo() != null ? p.getCorreo() : "" %>" 
                                   required maxlength="100" placeholder="ejemplo@email.com">
                        </div>
                        <div class="invalid-feedback"></div>
                        <div class="valid-feedback"></div>
                    </div>

                    <div class="col-md-6 mb-3">
                        <label class="form-label">
                            DNI
                            <i class="fas fa-info-circle tooltip-info" title="Opcional - 8 dígitos numéricos"></i>
                        </label>
                        <div class="input-group-icon">
                            <i class="fas fa-id-card"></i>
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
                        <label class="form-label">Fecha de Nacimiento</label>
                        <div class="input-group-icon">
                            <i class="fas fa-calendar"></i>
                            <input type="date" class="form-control" name="fecha_nacimiento" id="fecha_nacimiento"
                                   value="<%= fechaNacimientoStr %>">
                        </div>
                    </div>

                    <div class="col-md-6 mb-3">
                        <label class="form-label">Teléfono</label>
                        <div class="input-group-icon">
                            <i class="fas fa-phone"></i>
                            <input type="tel" class="form-control" name="telefono" id="telefono"
                                   value="<%= esEdicion && p.getTelefono() != null ? p.getTelefono() : "" %>" 
                                   maxlength="20" placeholder="987654321">
                        </div>
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label">Dirección</label>
                    <div class="input-group-icon">
                        <i class="fas fa-map-marker-alt"></i>
                        <textarea class="form-control" name="direccion" id="direccion" rows="2" maxlength="255" 
                                  placeholder="Av. Principal 123, Distrito, Ciudad"><%= esEdicion && p.getDireccion() != null ? p.getDireccion() : "" %></textarea>
                    </div>
                </div>

                <hr class="section-divider">

                <!-- SECCIÓN: INFORMACIÓN PROFESIONAL -->
                <div class="section-title">
                    <i class="fas fa-briefcase"></i>
                    Información Profesional
                </div>
                
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label required-field">Área / Especialidad</label>
                        <div class="input-group-icon">
                            <i class="fas fa-book"></i>
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
                        <label class="form-label required-field">Nivel que Enseña</label>
                        <div class="input-group-icon">
                            <i class="fas fa-graduation-cap"></i>
                            <select class="form-select" name="nivel" id="nivel" required>
                                <option value="">Seleccione un nivel</option>
                                <option value="INICIAL" <%= (esEdicion && "INICIAL".equals(p.getNivel())) ? "selected" : "" %>>Inicial</option>
                                <option value="PRIMARIA" <%= (esEdicion && "PRIMARIA".equals(p.getNivel())) ? "selected" : "" %>>Primaria</option>
                                <option value="SECUNDARIA" <%= (esEdicion && "SECUNDARIA".equals(p.getNivel())) ? "selected" : "" %>>Secundaria</option>
                                <option value="TODOS" <%= (esEdicion && "TODOS".equals(p.getNivel())) ? "selected" : "" %>>Todos los Niveles</option>
                            </select>
                        </div>
                        <div class="invalid-feedback"></div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label required-field">Turno</label>
                        <div class="input-group-icon">
                            <i class="fas fa-clock"></i>
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
                        <label class="form-label">Código de Profesor</label>
                        <div class="input-group-icon">
                            <i class="fas fa-barcode"></i>
                            <input type="text" class="form-control" name="codigo_profesor" id="codigo_profesor"
                                   value="<%= esEdicion && p.getCodigoProfesor() != null ? p.getCodigoProfesor() : "" %>" 
                                   maxlength="20" placeholder="PROF-001">
                        </div>
                        <small class="form-text">Opcional, se generará automáticamente</small>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Fecha de Contratación</label>
                        <div class="input-group-icon">
                            <i class="fas fa-calendar-check"></i>
                            <input type="date" class="form-control" name="fecha_contratacion" id="fecha_contratacion"
                                   value="<%= fechaContratacionStr %>">
                        </div>
                    </div>

                    <div class="col-md-6 mb-3">
                        <label class="form-label">Estado</label>
                        <div class="input-group-icon">
                            <i class="fas fa-toggle-on"></i>
                            <select name="estado" id="estado" class="form-select">
                                <option value="ACTIVO" <%= (esEdicion && "ACTIVO".equals(p.getEstado())) ? "selected" : "" %>>ACTIVO</option>
                                <option value="INACTIVO" <%= (esEdicion && "INACTIVO".equals(p.getEstado())) ? "selected" : "" %>>INACTIVO</option>
                                <option value="LICENCIA" <%= (esEdicion && "LICENCIA".equals(p.getEstado())) ? "selected" : "" %>>LICENCIA</option>
                                <option value="JUBILADO" <%= (esEdicion && "JUBILADO".equals(p.getEstado())) ? "selected" : "" %>>JUBILADO</option>
                            </select>
                        </div>
                    </div>
                </div>

                <!-- BOTONES -->
                <div class="d-flex justify-content-between align-items-center mt-4 pt-3" style="border-top: 2px solid #e5e7eb;">
                    <div class="d-flex gap-2">
                        <button type="submit" class="btn-modern <%= esEdicion ? "btn-primary-modern" : "btn-success-modern" %>">
                            <i class="fas <%= esEdicion ? "fa-save" : "fa-check" %>"></i>
                            <%= esEdicion ? "Actualizar Profesor" : "Registrar Profesor" %>
                        </button>
                        <a href="ProfesorServlet?accion=listar" class="btn-modern btn-secondary-modern">
                            <i class="fas fa-times"></i>
                            Cancelar
                        </a>
                    </div>
                    
                    <% if (esEdicion) { %>
                    <a href="ProfesorServlet?accion=eliminar&id=<%= p.getId() %>" 
                       class="btn-modern btn-danger-modern"
                       onclick="return confirm('¿Está seguro de eliminar este profesor?')">
                        <i class="fas fa-trash"></i>
                        Eliminar
                    </a>
                    <% } %>
                </div>
            </form>
        </div>
    </div>

    <footer class="bg-dark text-white py-4 mt-5">
        <div class="container text-center">
            <p class="mb-0">&copy; 2025 Colegio SA - Todos los derechos reservados</p>
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
