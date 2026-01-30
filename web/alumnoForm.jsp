<%-- 
    Document   : alumnoForm
    Created on : 1 may. 2025, 8:09:43 p. m.
    Author     : Paul
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Alumno" %>
<%@ page import="modelo.Grado" %>
<%@ page import="java.util.List" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    Alumno a = (Alumno) request.getAttribute("alumno");
    List<Grado> grados = (List<Grado>) request.getAttribute("grados");
    boolean editar = (a != null);
    
    // Formatear fecha para input date (yyyy-MM-dd)
    String fechaNacimientoStr = "";
    if (editar && a.getFechaNacimiento() != null) {
        fechaNacimientoStr = a.getFechaNacimiento().toString();
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= editar ? "Editar Alumno" : "Registrar Alumno"%> - Colegio SA</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="assets/css/estilos.css?v=1.4">
    <style>
        :root {
            --primary-color: #2563eb;
            --primary-dark: #1e40af;
            --secondary-color: #64748b;
            --success-color: #10b981;
            --danger-color: #ef4444;
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
            max-width: 900px;
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
        }

        .input-icon .form-control,
        .input-icon .form-select {
            padding-left: 2.75rem;
        }

        .mb-3 {
            margin-bottom: 1.5rem !important;
        }

        .btn-group-custom {
            display: flex;
            gap: 1rem;
            margin-top: 2.5rem;
            flex-wrap: wrap;
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

        .alert {
            border-radius: 12px;
            border: none;
            padding: 1rem 1.25rem;
            margin-bottom: 1.5rem;
            animation: slideDown 0.4s ease-out;
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
                    <i class="bi <%= editar ? "bi-pencil-square" : "bi-person-plus"%> icon"></i>
                    <%= editar ? "Editar Alumno" : "Registrar Nuevo Alumno"%>
                </h2>
            </div>
            
            <div class="form-body">
                <!-- Mensajes de éxito/error -->
                <% if (request.getAttribute("error") != null) { %>
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <i class="bi bi-exclamation-triangle-fill me-2"></i>
                        <%= request.getAttribute("error") %>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                <% } %>
                
                <% if (request.getAttribute("mensaje") != null) { %>
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <i class="bi bi-check-circle-fill me-2"></i>
                        <%= request.getAttribute("mensaje") %>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                <% } %>

                <form action="AlumnoServlet" method="post">
                    <input type="hidden" name="id" value="<%= editar ? a.getId() : "" %>">
                    
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
                                <input type="text" class="form-control" name="nombres" 
                                       value="<%= editar && a.getNombres() != null ? a.getNombres() : "" %>" 
                                       required maxlength="100" placeholder="Ingrese los nombres">
                            </div>
                        </div>

                        <div class="col-md-6 mb-3">
                            <label class="form-label required-field">
                                <i class="bi bi-person-fill"></i>
                                Apellidos
                            </label>
                            <div class="input-icon">
                                <i class="bi bi-pencil"></i>
                                <input type="text" class="form-control" name="apellidos" 
                                       value="<%= editar && a.getApellidos() != null ? a.getApellidos() : "" %>" 
                                       required maxlength="100" placeholder="Ingrese los apellidos">
                            </div>
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
                                <input type="email" class="form-control" name="correo" 
                                       value="<%= editar && a.getCorreo() != null ? a.getCorreo() : "" %>" 
                                       required maxlength="100" placeholder="ejemplo@email.com">
                            </div>
                        </div>

                        <div class="col-md-6 mb-3">
                            <label class="form-label">
                                <i class="bi bi-card-text"></i>
                                DNI
                            </label>
                            <div class="input-icon">
                                <i class="bi bi-credit-card-2-front"></i>
                                <input type="text" class="form-control" name="dni" 
                                       value="<%= editar && a.getDni() != null ? a.getDni() : "" %>" 
                                       maxlength="8" pattern="[0-9]{8}" 
                                       placeholder="8 dígitos (ej: 12345678)">
                            </div>
                            <small class="form-text">Opcional, 8 dígitos numéricos</small>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label required-field">
                                <i class="bi bi-calendar-event-fill"></i>
                                Fecha de Nacimiento
                            </label>
                            <div class="input-icon">
                                <i class="bi bi-calendar3"></i>
                                <input type="date" class="form-control" name="fecha_nacimiento" 
                                       value="<%= fechaNacimientoStr %>" required>
                            </div>
                        </div>

                        <div class="col-md-6 mb-3">
                            <label class="form-label">
                                <i class="bi bi-telephone-fill"></i>
                                Teléfono
                            </label>
                            <div class="input-icon">
                                <i class="bi bi-phone"></i>
                                <input type="tel" class="form-control" name="telefono" 
                                       value="<%= editar && a.getTelefono() != null ? a.getTelefono() : "" %>" 
                                       maxlength="20" placeholder="987654321">
                            </div>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">
                            <i class="bi bi-geo-alt-fill"></i>
                            Dirección
                        </label>
                        <textarea class="form-control" name="direccion" rows="3" maxlength="255" 
                                  placeholder="Av. Principal 123, Distrito, Ciudad"><%= editar && a.getDireccion() != null ? a.getDireccion() : "" %></textarea>
                    </div>

                    <!-- SECCIÓN: INFORMACIÓN ACADÉMICA -->
                    <h4 class="section-title">
                        <i class="bi bi-mortarboard-fill"></i>
                        Información Académica
                    </h4>
                    
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label required-field">
                                <i class="bi bi-book-fill"></i>
                                Grado/Salón
                            </label>
                            <div class="input-icon">
                                <i class="bi bi-list-ul"></i>
                                <select name="grado_id" class="form-select" required>
                                    <option value="">-- Selecciona un grado --</option>
                                    <% for (Grado g : grados) { 
                                        boolean selected = editar && a.getGradoId() == g.getId();
                                    %>
                                    <option value="<%= g.getId() %>" <%= selected ? "selected" : "" %>>
                                        <%= g.getNombre() %> - <%= g.getNivel() %>
                                    </option>
                                    <% } %>
                                </select>
                            </div>
                        </div>
                        
                        <% if (editar && a.getCodigoAlumno() != null) { %>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">
                                <i class="bi bi-hash"></i>
                                Código de Alumno
                            </label>
                            <div class="input-icon">
                                <i class="bi bi-key"></i>
                                <input type="text" class="form-control" value="<%= a.getCodigoAlumno() %>" readonly>
                            </div>
                            <small class="form-text">Código generado automáticamente</small>
                        </div>
                        <% } %>
                    </div>

                    <!-- BOTONES -->
                    <div class="btn-group-custom">
                        <div style="display: flex; gap: 1rem; flex: 1; flex-wrap: wrap;">
                            <button type="submit" class="btn btn-submit" style="flex: 1; min-width: 200px;">
                                <i class="bi <%= editar ? "bi-check-circle" : "bi-save"%>"></i>
                                <%= editar ? "Actualizar Alumno" : "Registrar Alumno" %>
                            </button>
                            <a href="AlumnoServlet" class="btn btn-cancel" style="flex: 1; min-width: 150px;">
                                <i class="bi bi-x-circle"></i>
                                Cancelar
                            </a>
                        </div>
                        
                        <% if (editar) { %>
                        <a href="AlumnoServlet?accion=eliminar&id=<%= a.getId() %>" 
                           class="btn btn-outline-danger"
                           onclick="return confirm('¿Está seguro de eliminar este alumno?')"
                           style="min-width: 180px;">
                            <i class="bi bi-trash"></i>
                            Eliminar Alumno
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
        // Establecer fecha por defecto (hace 10 años) si no estamos editando
        document.addEventListener('DOMContentLoaded', function() {
            const fechaInput = document.querySelector('input[name="fecha_nacimiento"]');
            
            if (!<%= editar %> && (!fechaInput.value || fechaInput.value === '')) {
                const hoy = new Date();
                const hace10Anios = new Date(hoy.getFullYear() - 10, hoy.getMonth(), hoy.getDate());
                const fechaFormateada = hace10Anios.toISOString().split('T')[0];
                fechaInput.value = fechaFormateada;
            }
            
            // Validación del DNI (solo números, 8 dígitos)
            const dniInput = document.querySelector('input[name="dni"]');
            if (dniInput) {
                dniInput.addEventListener('input', function() {
                    this.value = this.value.replace(/[^0-9]/g, '');
                    if (this.value.length > 8) {
                        this.value = this.value.slice(0, 8);
                    }
                });
            }
            
            // Validación del teléfono (solo números)
            const telefonoInput = document.querySelector('input[name="telefono"]');
            if (telefonoInput) {
                telefonoInput.addEventListener('input', function() {
                    this.value = this.value.replace(/[^0-9]/g, '');
                });
            }
            
            // Confirmación antes de enviar el formulario
            const form = document.querySelector('form');
            form.addEventListener('submit', function(event) {
                const nombres = document.querySelector('input[name="nombres"]').value.trim();
                const apellidos = document.querySelector('input[name="apellidos"]').value.trim();
                const correo = document.querySelector('input[name="correo"]').value.trim();
                const fecha = document.querySelector('input[name="fecha_nacimiento"]').value;
                const grado = document.querySelector('select[name="grado_id"]').value;
                
                let errores = [];
                
                if (nombres === '') errores.push('Nombres es obligatorio');
                if (apellidos === '') errores.push('Apellidos es obligatorio');
                if (correo === '' || !correo.includes('@')) errores.push('Correo electrónico válido es obligatorio');
                if (fecha === '') errores.push('Fecha de nacimiento es obligatoria');
                if (grado === '') errores.push('Debe seleccionar un grado');
                
                if (errores.length > 0) {
                    event.preventDefault();
                    alert('Por favor corrija los siguientes errores:\n\n• ' + errores.join('\n• '));
                }
            });
        });
    </script>
</body>
</html>
