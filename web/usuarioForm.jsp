<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Usuario" %>
<%@ page import="modelo.UsuarioDAO.PersonaSinUsuario" %>
<%@ page import="java.util.List" %>
<%@ page import="javax.servlet.http.HttpSession" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    Usuario u = (Usuario) request.getAttribute("usuario");
    boolean esEditar = u != null;
    
    // Obtener listas de personas sin usuario
    List<PersonaSinUsuario> profesoresSinUsuario = 
        (List<PersonaSinUsuario>) request.getAttribute("profesoresSinUsuario");
    List<PersonaSinUsuario> alumnosSinUsuario = 
        (List<PersonaSinUsuario>) request.getAttribute("alumnosSinUsuario");
    List<PersonaSinUsuario> administrativosSinUsuario = 
        (List<PersonaSinUsuario>) request.getAttribute("administrativosSinUsuario");
    
    String username = "";
    String rol = "";
    int id = 0;
    int personaId = 0;
    
    if (esEditar && u != null) {
        username = u.getUsername() != null ? u.getUsername() : "";
        rol = u.getRol() != null ? u.getRol() : "";
        id = u.getId();
        personaId = u.getPersonaId();
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= esEditar ? "Editar Usuario" : "Registrar Usuario"%> - Colegio SA</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="assets/css/estilos.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/crypto-js/4.1.1/crypto-js.min.js"></script>
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

        .form-label.required::after {
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

        .form-control:focus, .form-select:focus {
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
        }

        .form-control:disabled, .form-control:read-only {
            background-color: #f1f5f9;
            cursor: not-allowed;
            opacity: 0.7;
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
        .input-icon .form-select {
            padding-left: 2.75rem;
        }

        small.help-text {
            color: #64748b;
            font-size: 0.85rem;
            display: block;
            margin-top: 0.25rem;
        }

        .filter-section {
            background: linear-gradient(135deg, #f0f9ff 0%, #e0f2fe 100%);
            border: 2px solid #bae6fd;
            border-radius: 15px;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
        }

        .filter-section label {
            font-weight: 700;
            color: #0c4a6e;
            margin-bottom: 1rem;
            display: block;
        }

        .tipo-badge {
            cursor: pointer;
            padding: 1rem 1.5rem;
            border-radius: 12px;
            border: 3px solid #e2e8f0;
            background: white;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 0.75rem;
            margin: 0.5rem;
            font-weight: 600;
        }

        .tipo-badge:hover {
            border-color: var(--primary-color);
            background: #f0f9ff;
            transform: translateY(-3px);
            box-shadow: 0 8px 16px rgba(37, 99, 235, 0.2);
        }

        .tipo-badge.active {
            border-color: var(--primary-color);
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-dark) 100%);
            color: white;
            transform: translateY(-3px);
            box-shadow: 0 8px 16px rgba(37, 99, 235, 0.3);
        }

        .tipo-badge i {
            font-size: 1.5rem;
        }

        .tipo-badge .badge {
            font-size: 0.9rem;
            padding: 0.35rem 0.65rem;
        }

        .persona-info {
            background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
            border: 2px solid #e2e8f0;
            border-radius: 15px;
            padding: 1.5rem;
            margin-top: 1rem;
            display: none;
        }

        .persona-info.active {
            display: block;
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

        .persona-info > strong {
            color: var(--primary-color);
            display: block;
            margin-bottom: 1rem;
            font-size: 1.1rem;
        }

        .persona-detail {
            display: flex;
            justify-content: space-between;
            padding: 0.75rem;
            margin-bottom: 0.5rem;
            background: white;
            border-radius: 8px;
            border: 1px solid #e2e8f0;
        }

        .persona-detail strong {
            color: #475569;
        }

        .persona-detail span {
            color: #64748b;
            font-weight: 500;
        }

        .requisitos-password {
            background: linear-gradient(135deg, #fef3c7 0%, #fde68a 100%);
            border: 2px solid #fbbf24;
            border-radius: 12px;
            padding: 1.5rem;
            display: none;
            margin-top: 1rem;
        }

        .requisitos-password.show {
            display: block;
        }

        .requisitos-password > strong {
            color: #92400e;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin-bottom: 1rem;
        }

        .requisitos-password ul {
            list-style: none;
            padding-left: 0;
        }

        .criterio-item {
            transition: all 0.3s ease;
            margin-bottom: 0.5rem;
            padding: 0.5rem;
            border-radius: 8px;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .requisito-cumplido {
            background: #d1fae5;
            color: #065f46;
            font-weight: 600;
        }

        .requisito-incumplido {
            background: #fee2e2;
            color: #991b1b;
        }

        .requisito-pendiente {
            background: #f3f4f6;
            color: #6b7280;
        }

        #indicadorPassword {
            font-weight: 600;
            font-size: 0.95rem;
            padding: 0.5rem;
            border-radius: 8px;
            display: inline-block;
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

        .alert-info {
            background: #dbeafe;
            color: #1e40af;
            border-left: 4px solid var(--info-color);
        }

        .btn {
            border-radius: 10px;
            padding: 0.75rem 2rem;
            font-weight: 600;
            font-size: 1rem;
            transition: all 0.3s ease;
            border: none;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            justify-content: center;
        }

        .btn-primary-custom {
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-dark) 100%);
            color: white;
        }

        .btn-primary-custom:hover:not(:disabled) {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(37, 99, 235, 0.3);
            color: white;
        }

        .btn-secondary {
            background: var(--secondary-color);
            color: white;
        }

        .btn-secondary:hover {
            background: #475569;
            transform: translateY(-2px);
            color: white;
        }

        .btn:disabled {
            opacity: 0.5;
            cursor: not-allowed;
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

            .tipo-badge {
                width: 100%;
                justify-content: center;
            }

            .section-title {
                font-size: 1.1rem;
            }
        }
    </style>
</head>
<body class="dashboard-page">
    <jsp:include page="header.jsp" />

    <div class="form-container">
        <div class="form-card">
            <!-- Header del Formulario -->
            <div class="form-header">
                <h2>
                    <i class="bi <%= esEditar ? "bi-person-fill-gear" : "bi-person-plus-fill"%> icon"></i>
                    <%= esEditar ? "Editar Usuario" : "Registrar Nuevo Usuario"%>
                </h2>
            </div>

            <div class="form-body">
                <!-- Mensajes -->
                <% if (session.getAttribute("mensaje") != null) { %>
                    <div class="alert alert-success alert-dismissible fade show">
                        <i class="bi bi-check-circle-fill"></i>
                        <div><%= session.getAttribute("mensaje") %></div>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                    <% session.removeAttribute("mensaje"); %>
                <% } %>
                
                <% if (session.getAttribute("error") != null) { %>
                    <div class="alert alert-danger alert-dismissible fade show">
                        <i class="bi bi-exclamation-triangle-fill"></i>
                        <div><%= session.getAttribute("error") %></div>
                        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    </div>
                    <% session.removeAttribute("error"); %>
                <% } %>

                <!-- Formulario -->
                <form action="UsuarioServlet" method="post" id="usuarioForm">
                    <input type="hidden" name="id" value="<%= id %>">
                    <input type="hidden" name="persona_id" id="persona_id_hidden" value="<%= personaId %>">
                    <input type="hidden" name="rol" id="rol_hidden" value="<%= rol %>">

                    <% if (!esEditar) { %>
                    <!-- SECCIÓN: SELECCIONAR PERSONA -->
                    <div class="section-title">
                        <i class="bi bi-person-badge-fill"></i>
                        Asociar a Persona
                    </div>

                    <div class="filter-section">
                        <label>
                            <i class="bi bi-funnel-fill"></i>
                            Seleccione el tipo de persona:
                        </label>
                        <div class="d-flex flex-wrap justify-content-center">
                            <div class="tipo-badge" data-tipo="PROFESOR" data-rol="docente">
                                <i class="bi bi-easel-fill"></i>
                                <span>Profesor</span>
                                <span class="badge bg-primary"><%= profesoresSinUsuario != null ? profesoresSinUsuario.size() : 0 %></span>
                            </div>
                            <div class="tipo-badge" data-tipo="ALUMNO" data-rol="padre">
                                <i class="bi bi-mortarboard-fill"></i>
                                <span>Alumno (Padre)</span>
                                <span class="badge bg-success"><%= alumnosSinUsuario != null ? alumnosSinUsuario.size() : 0 %></span>
                            </div>
                            <div class="tipo-badge" data-tipo="ADMINISTRATIVO" data-rol="administrativo">
                                <i class="bi bi-gear-fill"></i>
                                <span>Administrativo</span>
                                <span class="badge bg-warning"><%= administrativosSinUsuario != null ? administrativosSinUsuario.size() : 0 %></span>
                            </div>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label required">
                            <i class="bi bi-person-fill"></i>
                            Persona
                        </label>
                        <div class="input-icon">
                            <i class="bi bi-search"></i>
                            <select class="form-select" id="persona_id_select" required>
                                <option value="">Primero seleccione un tipo de persona</option>
                            </select>
                        </div>
                        <small class="help-text">
                            <i class="bi bi-info-circle"></i>
                            Solo se muestran personas que NO tienen usuario asignado
                        </small>
                    </div>

                    <!-- INFO DE PERSONA SELECCIONADA -->
                    <div class="persona-info" id="personaInfo">
                        <strong>
                            <i class="bi bi-info-circle-fill"></i>
                            Información de la Persona
                        </strong>
                        <div class="persona-detail">
                            <strong>Nombre Completo:</strong>
                            <span id="infoNombre">-</span>
                        </div>
                        <div class="persona-detail">
                            <strong>Correo:</strong>
                            <span id="infoCorreo">-</span>
                        </div>
                        <div class="persona-detail">
                            <strong>DNI:</strong>
                            <span id="infoDni">-</span>
                        </div>
                        <div class="persona-detail">
                            <strong>Código:</strong>
                            <span id="infoCodigo">-</span>
                        </div>
                        <div class="persona-detail">
                            <strong>Información Adicional:</strong>
                            <span id="infoAdicional">-</span>
                        </div>
                    </div>
                    <% } else { %>
                        <!-- EN EDICIÓN: MOSTRAR PERSONA ASOCIADA (READONLY) -->
                        <div class="alert alert-info">
                            <i class="bi bi-info-circle-fill"></i>
                            <div>
                                <strong>Persona Asociada:</strong> No se puede cambiar en modo edición
                            </div>
                        </div>
                    <% } %>

                    <!-- SECCIÓN: CREDENCIALES -->
                    <div class="section-title">
                        <i class="bi bi-key-fill"></i>
                        Credenciales de Acceso
                    </div>

                    <div class="mb-3">
                        <label class="form-label required">
                            <i class="bi bi-person-circle"></i>
                            Nombre de Usuario
                        </label>
                        <div class="input-icon">
                            <i class="bi bi-at"></i>
                            <input type="text" 
                                   class="form-control" 
                                   name="username" 
                                   id="username"
                                   value="<%= username %>" 
                                   required
                                   maxlength="50"
                                   <%= esEditar ? "readonly" : "" %>
                                   placeholder="usuario.profesor">
                        </div>
                        <% if (esEditar) { %>
                            <small class="help-text">
                                <i class="bi bi-lock-fill"></i>
                                El nombre de usuario no se puede modificar
                            </small>
                        <% } else { %>
                            <small class="help-text">
                                <i class="bi bi-lightbulb-fill"></i>
                                Se sugiere usar el formato: nombre.apellido o correo sin @dominio
                            </small>
                        <% } %>
                    </div>

                    <div class="mb-3">
                        <label class="form-label <%= esEditar ? "" : "required" %>">
                            <i class="bi bi-shield-lock-fill"></i>
                            Contraseña
                        </label>
                        <div class="input-icon">
                            <i class="bi bi-key"></i>
                            <input type="password" 
                                   class="form-control" 
                                   name="password" 
                                   id="passwordInput" 
                                   <%= esEditar ? "" : "required" %>
                                   oninput="validarPasswordEnTiempoReal(this.value)"
                                   placeholder="<%= esEditar ? "Dejar vacío para mantener contraseña actual" : "Ingrese una contraseña segura"%>">
                        </div>
                        
                        <div id="indicadorPassword" class="help-text mt-2"></div>
                        
                        <div class="requisitos-password" id="requisitosPassword">
                            <strong>
                                <i class="bi bi-shield-check"></i>
                                Requisitos de contraseña segura:
                            </strong>
                            <ul>
                                <li id="reqLongitud" class="criterio-item requisito-pendiente">
                                    <i class="bi bi-circle"></i> Mínimo 8 caracteres
                                </li>
                                <li id="reqMayuscula" class="criterio-item requisito-pendiente">
                                    <i class="bi bi-circle"></i> Al menos una letra mayúscula
                                </li>
                                <li id="reqMinuscula" class="criterio-item requisito-pendiente">
                                    <i class="bi bi-circle"></i> Al menos una letra minúscula
                                </li>
                                <li id="reqNumero" class="criterio-item requisito-pendiente">
                                    <i class="bi bi-circle"></i> Al menos un número
                                </li>
                                <li id="reqEspecial" class="criterio-item requisito-pendiente">
                                    <i class="bi bi-circle"></i> Al menos un carácter especial (!@#$%^&*)
                                </li>
                                <li id="reqCriterios" class="criterio-item requisito-pendiente">
                                    <i class="bi bi-circle"></i> Cumplir al menos 3 de los 4 criterios anteriores
                                </li>
                            </ul>
                            <div class="mt-2 p-2 bg-white rounded text-center">
                                <strong>Criterios cumplidos:</strong> 
                                <span id="criteriosCumplidos" class="badge bg-secondary">0</span>/4
                            </div>
                        </div>
                        
                        <% if (esEditar) { %>
                            <small class="help-text">
                                <i class="bi bi-info-circle"></i>
                                Dejar en blanco para mantener la contraseña actual
                            </small>
                        <% } %>
                    </div>

                    <!-- BOTONES -->
                    <div class="d-flex justify-content-between gap-2 mt-4 pt-3" style="border-top: 2px solid #e5e7eb;">
                        <a href="UsuarioServlet" class="btn btn-secondary">
                            <i class="bi bi-x-circle"></i>
                            Cancelar
                        </a>
                        <button type="submit" class="btn btn-primary-custom" id="submitBtn">
                            <i class="bi <%= esEditar ? "bi-check-circle" : "bi-save"%>"></i>
                            <%= esEditar ? "Actualizar Usuario" : "Registrar Usuario"%>
                        </button>
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
        // ===================================================================
        // DATOS DE PERSONAS SIN USUARIO (desde JSP)
        // ===================================================================
        const profesoresSinUsuario = [
            <% if (profesoresSinUsuario != null) {
                for (int i = 0; i < profesoresSinUsuario.size(); i++) {
                    PersonaSinUsuario p = profesoresSinUsuario.get(i);
            %>
            {
                personaId: <%= p.getPersonaId() %>,
                nombres: "<%= p.getNombres() != null ? p.getNombres().replace("\"", "\\\"") : "" %>",
                apellidos: "<%= p.getApellidos() != null ? p.getApellidos().replace("\"", "\\\"") : "" %>",
                correo: "<%= p.getCorreo() != null ? p.getCorreo().replace("\"", "\\\"") : "" %>",
                dni: "<%= p.getDni() != null ? p.getDni().replace("\"", "\\\"") : "" %>",
                codigo: "<%= p.getCodigo() != null ? p.getCodigo().replace("\"", "\\\"") : "" %>",
                infoAdicional: "<%= p.getInformacionAdicional() != null ? p.getInformacionAdicional().replace("\"", "\\\"") : "" %>"
            }<%= i < profesoresSinUsuario.size() - 1 ? "," : "" %>
            <% }
            } %>
        ];

        const alumnosSinUsuario = [
            <% if (alumnosSinUsuario != null) {
                for (int i = 0; i < alumnosSinUsuario.size(); i++) {
                    PersonaSinUsuario p = alumnosSinUsuario.get(i);
            %>
            {
                personaId: <%= p.getPersonaId() %>,
                nombres: "<%= p.getNombres() != null ? p.getNombres().replace("\"", "\\\"") : "" %>",
                apellidos: "<%= p.getApellidos() != null ? p.getApellidos().replace("\"", "\\\"") : "" %>",
                correo: "<%= p.getCorreo() != null ? p.getCorreo().replace("\"", "\\\"") : "" %>",
                dni: "<%= p.getDni() != null ? p.getDni().replace("\"", "\\\"") : "" %>",
                codigo: "<%= p.getCodigo() != null ? p.getCodigo().replace("\"", "\\\"") : "" %>",
                infoAdicional: "<%= p.getInformacionAdicional() != null ? p.getInformacionAdicional().replace("\"", "\\\"") : "" %>"
            }<%= i < alumnosSinUsuario.size() - 1 ? "," : "" %>
            <% }
            } %>
        ];

        const administrativosSinUsuario = [
            <% if (administrativosSinUsuario != null) {
                for (int i = 0; i < administrativosSinUsuario.size(); i++) {
                    PersonaSinUsuario p = administrativosSinUsuario.get(i);
            %>
            {
                personaId: <%= p.getPersonaId() %>,
                nombres: "<%= p.getNombres() != null ? p.getNombres().replace("\"", "\\\"") : "" %>",
                apellidos: "<%= p.getApellidos() != null ? p.getApellidos().replace("\"", "\\\"") : "" %>",
                correo: "<%= p.getCorreo() != null ? p.getCorreo().replace("\"", "\\\"") : "" %>",
                dni: "<%= p.getDni() != null ? p.getDni().replace("\"", "\\\"") : "" %>",
                codigo: "<%= p.getCodigo() != null ? p.getCodigo().replace("\"", "\\\"") : "" %>",
                infoAdicional: "<%= p.getInformacionAdicional() != null ? p.getInformacionAdicional().replace("\"", "\\\"") : "" %>"
            }<%= i < administrativosSinUsuario.size() - 1 ? "," : "" %>
            <% }
            } %>
        ];

        console.log('📊 Profesores sin usuario cargados:', profesoresSinUsuario);
        console.log('📊 Total profesores:', profesoresSinUsuario.length);
        console.log('📊 Alumnos sin usuario cargados:', alumnosSinUsuario);
        console.log('📊 Total alumnos:', alumnosSinUsuario.length);
        console.log('📊 Administrativos sin usuario cargados:', administrativosSinUsuario);
        console.log('📊 Total administrativos:', administrativosSinUsuario.length);

        // ===================================================================
        // MANEJO DE SELECCIÓN DE TIPO DE PERSONA
        // ===================================================================
        const esEdicion = <%= esEditar %>;
        
        if (!esEdicion) {
            document.querySelectorAll('.tipo-badge').forEach(badge => {
                badge.addEventListener('click', function() {
                    console.log('🖱️ Badge clickeado:', this.dataset.tipo);
                    
                    // Remover active de todos
                    document.querySelectorAll('.tipo-badge').forEach(b => b.classList.remove('active'));
                    
                    // Agregar active al seleccionado
                    this.classList.add('active');
                    
                    const tipo = this.dataset.tipo;
                    const rol = this.dataset.rol;
                    
                    // ✅ ACTUALIZAR EL ROL OCULTO
                    document.getElementById('rol_hidden').value = rol;
                    console.log('✅ Rol establecido:', rol);
                    
                    cargarPersonasPorTipo(tipo);
                });
            });
        }

        // ✅ FUNCIÓN CORREGIDA PARA MOSTRAR NOMBRES REALES
        function cargarPersonasPorTipo(tipo) {
            const select = document.getElementById('persona_id_select');
            
            console.log('='.repeat(60));
            console.log('🔄 INICIANDO CARGA DE PERSONAS');
            console.log('='.repeat(60));
            
            // Limpiar select
            select.innerHTML = '';
            console.log('✅ Select limpiado');
            
            let personas = [];
            
            // Determinar qué array usar
            if (tipo === 'PROFESOR') {
                personas = profesoresSinUsuario;
            } else if (tipo === 'ALUMNO') {
                personas = alumnosSinUsuario;
            } else if (tipo === 'ADMINISTRATIVO') {
                personas = administrativosSinUsuario;
            }
            
            console.log('🔍 Tipo seleccionado:', tipo);
            console.log('📊 Total personas encontradas:', personas.length);
            console.log('📊 Array completo:', personas);
            
            // Validar que hay personas
            if (personas.length === 0) {
                const optionVacia = document.createElement('option');
                optionVacia.value = '';
                optionVacia.textContent = 'No hay personas disponibles de este tipo';
                select.appendChild(optionVacia);
                select.disabled = true;
                console.log('⚠️ No hay personas disponibles de tipo:', tipo);
                return;
            }
            
            // Agregar opción por defecto
            const optionDefault = document.createElement('option');
            optionDefault.value = '';
            optionDefault.textContent = '-- Seleccione una persona --';
            select.appendChild(optionDefault);
            console.log('✅ Opción por defecto agregada');
            
            console.log('\n📋 PROCESANDO PERSONAS:');
            console.log('-'.repeat(60));
            
            // ✅ AGREGAR PERSONAS CON VALIDACIÓN DE DATOS MEJORADA
            personas.forEach((p, index) => {
                console.log('\n[' + (index + 1) + '] Procesando persona:', p);
                
                const option = document.createElement('option');
                option.value = p.personaId;
                
                // ✅ VALIDAR que los datos no sean undefined/null/vacíos/false/"false"
                const apellidos = (p.apellidos && 
                                  p.apellidos !== 'false' && 
                                  p.apellidos !== false && 
                                  String(p.apellidos).trim() !== '' &&
                                  String(p.apellidos).trim() !== 'null') 
                                 ? String(p.apellidos).trim() : '';
                                 
                const nombres = (p.nombres && 
                                p.nombres !== 'false' && 
                                p.nombres !== false && 
                                String(p.nombres).trim() !== '' &&
                                String(p.nombres).trim() !== 'null') 
                               ? String(p.nombres).trim() : '';
                               
                const codigo = (p.codigo && String(p.codigo).trim() !== '') ? String(p.codigo).trim() : '';
                const infoAdicional = (p.infoAdicional && String(p.infoAdicional).trim() !== '') ? String(p.infoAdicional).trim() : '';
                
                console.log('  - Apellidos RAW:', p.apellidos);
                console.log('  - Apellidos PROCESADO: "' + apellidos + '"');
                console.log('  - Nombres RAW:', p.nombres);
                console.log('  - Nombres PROCESADO: "' + nombres + '"');
                console.log('  - Código: "' + codigo + '"');
                console.log('  - Info adicional: "' + infoAdicional + '"');
                
                // Construir el texto de la opción
                let textoOpcion = '';
                
                // Priorizar mostrar apellidos y nombres
                if (apellidos !== '' && nombres !== '') {
                    textoOpcion = apellidos + ', ' + nombres;
                    console.log('  ✅ Opción A: Apellido + Nombre = "' + textoOpcion + '"');
                } else if (apellidos !== '') {
                    textoOpcion = apellidos;
                    console.log('  ✅ Opción B: Solo Apellido = "' + textoOpcion + '"');
                } else if (nombres !== '') {
                    textoOpcion = nombres;
                    console.log('  ✅ Opción C: Solo Nombre = "' + textoOpcion + '"');
                } else {
                    textoOpcion = 'Persona ID: ' + p.personaId;
                    console.log('  ⚠️ Opción D: Sin nombre, usando ID = "' + textoOpcion + '"');
                }
                
                // Agregar código si existe
                if (codigo !== '') {
                    textoOpcion = textoOpcion + ' [' + codigo + ']';
                    console.log('  ✅ Agregado código: "' + textoOpcion + '"');
                }
                
                // Agregar información adicional si existe
                if (infoAdicional !== '') {
                    textoOpcion = textoOpcion + ' - ' + infoAdicional;
                    console.log('  ✅ Agregada info adicional: "' + textoOpcion + '"');
                }
                
                console.log('  🎯 TEXTO FINAL: "' + textoOpcion + '"');
                console.log('  🔢 VALOR (ID): ' + p.personaId);
                
                option.textContent = textoOpcion;
                option.dataset.persona = JSON.stringify(p);
                select.appendChild(option);
                
                console.log('  ✅ Opción agregada al select');
            });
            
            select.disabled = false;
            
            console.log('\n' + '='.repeat(60));
            console.log('✅ CARGA COMPLETADA');
            console.log('📊 Total opciones en el select:', select.options.length);
            console.log('📊 Personas procesadas:', personas.length);
            console.log('📊 Tipo:', tipo);
            console.log('='.repeat(60) + '\n');
        }

        // Cuando se selecciona una persona, mostrar su información
        if (!esEdicion) {
            document.getElementById('persona_id_select').addEventListener('change', function() {
                console.log('📝 Select cambiado, valor:', this.value);
                
                const selectedOption = this.options[this.selectedIndex];
                const personaId = this.value;
                
                // Actualizar hidden input
                document.getElementById('persona_id_hidden').value = personaId;
                console.log('✅ Hidden input actualizado:', personaId);
                
                if (personaId && selectedOption.dataset.persona) {
                    const persona = JSON.parse(selectedOption.dataset.persona);
                    console.log('👤 Persona seleccionada:', persona);
                    mostrarInfoPersona(persona);
                    
                    // Auto-sugerir username
                    if (persona.correo && persona.correo.trim() !== '') {
                        const usernamesugerido = persona.correo.split('@')[0];
                        document.getElementById('username').value = usernamesugerido;
                        console.log('✅ Username sugerido:', usernamesugerido);
                    } else if (persona.nombres && persona.apellidos) {
                        // Alternativa: usar primera letra del nombre + apellido
                        const usernamesugerido = (persona.nombres.charAt(0) + persona.apellidos).toLowerCase().replace(/\s/g, '');
                        document.getElementById('username').value = usernamesugerido;
                        console.log('✅ Username alternativo sugerido:', usernamesugerido);
                    }
                } else {
                    console.log('⚠️ No se seleccionó persona válida');
                    ocultarInfoPersona();
                }
            });
        }

        function mostrarInfoPersona(persona) {
            console.log('📋 Mostrando información de persona:', persona);
            
            const nombreCompleto = (persona.nombres || '') + ' ' + (persona.apellidos || '');
            document.getElementById('infoNombre').textContent = nombreCompleto.trim() || '-';
            document.getElementById('infoCorreo').textContent = persona.correo || '-';
            document.getElementById('infoDni').textContent = persona.dni || '-';
            document.getElementById('infoCodigo').textContent = persona.codigo || '-';
            document.getElementById('infoAdicional').textContent = persona.infoAdicional || '-';
            
            document.getElementById('personaInfo').classList.add('active');
            console.log('✅ Información de persona mostrada');
        }

        function ocultarInfoPersona() {
            console.log('🙈 Ocultando información de persona');
            document.getElementById('personaInfo').classList.remove('active');
        }

        // ===================================================================
        // VALIDACIÓN DE CONTRASEÑA
        // ===================================================================
        function encriptarPasswordSHA256(password) {
            return CryptoJS.SHA256(password).toString();
        }

        const textosOriginales = {
            reqLongitud: "Mínimo 8 caracteres",
            reqMayuscula: "Al menos una letra mayúscula",
            reqMinuscula: "Al menos una letra minúscula", 
            reqNumero: "Al menos un número",
            reqEspecial: "Al menos un carácter especial (!@#$%^&*)",
            reqCriterios: "Cumplir al menos 3 de los 4 criterios anteriores"
        };

        function validarPasswordEnTiempoReal(password) {
            const indicador = document.getElementById('indicadorPassword');
            const requisitos = document.getElementById('requisitosPassword');
            const submitBtn = document.getElementById('submitBtn');
            
            if (password.length > 0) {
                requisitos.classList.add('show');
            } else {
                if (esEdicion) {
                    indicador.innerHTML = '<span class="text-success"><i class="bi bi-check-circle-fill"></i> Se mantendrá la contraseña actual</span>';
                    submitBtn.disabled = false;
                } else {
                    indicador.innerHTML = '<span class="text-warning"><i class="bi bi-exclamation-triangle-fill"></i> Ingrese una contraseña</span>';
                    submitBtn.disabled = true;
                }
                requisitos.classList.remove('show');
                resetearRequisitos();
                return;
            }
            
            const longitudValida = password.length >= 8;
            const tieneMayuscula = /[A-Z]/.test(password);
            const tieneMinuscula = /[a-z]/.test(password);
            const tieneNumero = /[0-9]/.test(password);
            const tieneEspecial = /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(password);
            
            actualizarRequisito('reqLongitud', longitudValida);
            actualizarRequisito('reqMayuscula', tieneMayuscula);
            actualizarRequisito('reqMinuscula', tieneMinuscula);
            actualizarRequisito('reqNumero', tieneNumero);
            actualizarRequisito('reqEspecial', tieneEspecial);
            
            let criteriosCumplidos = 0;
            if (tieneMayuscula) criteriosCumplidos++;
            if (tieneMinuscula) criteriosCumplidos++;
            if (tieneNumero) criteriosCumplidos++;
            if (tieneEspecial) criteriosCumplidos++;
            
            const criteriosValidos = criteriosCumplidos >= 3;
            actualizarRequisito('reqCriterios', criteriosValidos);
            
            document.getElementById('criteriosCumplidos').textContent = criteriosCumplidos;
            
            const esFuerte = longitudValida && criteriosValidos;
            
            if (esFuerte) {
                indicador.innerHTML = '<span class="text-success"><i class="bi bi-check-circle-fill"></i> Contraseña segura</span>';
                submitBtn.disabled = false;
            } else {
                let mensajesError = [];
                if (!longitudValida) mensajesError.push('mínimo 8 caracteres');
                if (!criteriosValidos) mensajesError.push('cumplir 3 de 4 criterios');
                
                indicador.innerHTML = '<span class="text-danger"><i class="bi bi-x-circle-fill"></i> Faltan: ' + mensajesError.join(', ') + '</span>';
                submitBtn.disabled = true;
            }
        }
        
        function actualizarRequisito(elementId, cumple) {
            const elemento = document.getElementById(elementId);
            const textoBase = textosOriginales[elementId];
            
            if (cumple) {
                elemento.className = 'criterio-item requisito-cumplido';
                elemento.innerHTML = '<i class="bi bi-check-circle-fill"></i> ' + textoBase;
            } else {
                elemento.className = 'criterio-item requisito-incumplido';
                elemento.innerHTML = '<i class="bi bi-x-circle-fill"></i> ' + textoBase;
            }
        }
        
        function resetearRequisitos() {
            Object.keys(textosOriginales).forEach(elementId => {
                const elemento = document.getElementById(elementId);
                if (elemento) {
                    elemento.className = 'criterio-item requisito-pendiente';
                    elemento.innerHTML = '<i class="bi bi-circle"></i> ' + textosOriginales[elementId];
                }
            });
            document.getElementById('criteriosCumplidos').textContent = '0';
        }
        
        // ===================================================================
        // ENVÍO DEL FORMULARIO
        // ===================================================================
        document.getElementById('usuarioForm').addEventListener('submit', async function(e) {
            e.preventDefault();
            
            console.log('=== VALIDANDO FORMULARIO ===');
            
            // Validar persona_id solo si NO es edición
            if (!esEdicion) {
                const personaId = document.getElementById('persona_id_hidden').value;
                console.log('🔍 Validando persona_id:', personaId);
                
                if (!personaId || personaId === '0' || personaId === '') {
                    alert('❌ Debe seleccionar una persona para asociar el usuario');
                    return false;
                }
                console.log('✅ Persona ID válido:', personaId);
                
                // Validar que se haya seleccionado un rol
                const rol = document.getElementById('rol_hidden').value;
                console.log('🔍 Validando rol:', rol);
                
                if (!rol || rol === '') {
                    alert('❌ Debe seleccionar un tipo de persona (esto establece el rol automáticamente)');
                    return false;
                }
                console.log('✅ Rol válido:', rol);
            }
            
            const password = document.getElementById('passwordInput').value;
            
            if (!esEdicion && password.length === 0) {
                alert('❌ La contraseña es obligatoria para nuevos usuarios');
                return false;
            }
            
            if (password.length > 0) {
                const longitudValida = password.length >= 8;
                const tieneMayuscula = /[A-Z]/.test(password);
                const tieneMinuscula = /[a-z]/.test(password);
                const tieneNumero = /[0-9]/.test(password);
                const tieneEspecial = /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(password);
                
                let criteriosCumplidos = 0;
                if (tieneMayuscula) criteriosCumplidos++;
                if (tieneMinuscula) criteriosCumplidos++;
                if (tieneNumero) criteriosCumplidos++;
                if (tieneEspecial) criteriosCumplidos++;
                
                const criteriosValidos = criteriosCumplidos >= 3;
                const esFuerte = longitudValida && criteriosValidos;
                
                if (!esFuerte) {
                    alert('❌ La contraseña no cumple con los requisitos de seguridad');
                    return false;
                }

                // Encriptar contraseña
                try {
                    const hashedPassword = encriptarPasswordSHA256(password);
                    document.getElementById('passwordInput').value = hashedPassword;
                    console.log('🔐 Contraseña encriptada con SHA256');
                } catch (error) {
                    alert('❌ Error encriptando la contraseña');
                    console.error('Error:', error);
                    return false;
                }
            }
            
            console.log('✅ Validación exitosa - Enviando formulario');
            this.submit();
        });

        // Mostrar/ocultar requisitos al enfocar
        document.getElementById('passwordInput').addEventListener('focus', function() {
            if (this.value.length > 0) {
                document.getElementById('requisitosPassword').classList.add('show');
            }
        });
        
        // DEBUG: Al cargar la página
        console.log('🚀 Página cargada - Estado inicial:');
        console.log('Es edición:', esEdicion);
        console.log('Profesores:', profesoresSinUsuario);
        console.log('Alumnos:', alumnosSinUsuario);
        console.log('Administrativos:', administrativosSinUsuario);
    </script>
</body>
</html>
