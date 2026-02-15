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
    
    // Título para el header dinámico
    request.setAttribute("pageTitle", esEditar ? "Editar Usuario" : "Registrar Usuario");
%>

<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= esEditar ? "Editar Usuario" : "Registrar Usuario"%> - San Antonio</title>
    
    <%-- ✅ Incluir HEAD común (Tailwind, fuentes, estilos globales) --%>
    <%@ include file="includes/head.jsp" %>
    
    <!-- Crypto-JS para encriptar contraseñas -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/crypto-js/4.1.1/crypto-js.min.js"></script>
    
    <style>
        /* Mejoras de accesibilidad */
        .reduce-motion * { 
            animation-duration: 0.01ms !important; 
            animation-iteration-count: 1 !important; 
            transition-duration: 0.01ms !important; 
        }
        .high-contrast-invert { 
            filter: invert(1) hue-rotate(180deg); 
        }
        .high-contrast-yellow { 
            background-color: #000000 !important; 
            color: #ffff00 !important; 
        }
        .beige-background { 
            background-color: #f5f5dc !important; 
        }
        .large-text { 
            font-size: 18px !important; 
        }
        .larger-text { 
            font-size: 20px !important; 
        }
        .largest-text { 
            font-size: 22px !important; 
        }
        .dyslexia-font { 
            font-family: Arial !important; 
            font-size: 1.1em !important; 
            line-height: 1.6 !important; 
            letter-spacing: 0.5px !important; 
        }
        
        /* Panel de accesibilidad */
        .accessibility-panel {
            transform: translateX(100%);
            transition: transform 0.3s ease;
        }
        .accessibility-panel.open {
            transform: translateX(0);
        }
        
        /* Skip to content link */
        .skip-to-content {
            position: absolute;
            top: -40px;
            left: 0;
            background: #135bec;
            color: white;
            padding: 8px;
            z-index: 100;
        }
        .skip-to-content:focus {
            top: 0;
        }
        
        /* Focus styles */
        :focus {
            outline: 3px solid #135bec !important;
            outline-offset: 2px;
        }

        .form-wrapper {
            max-width: 800px;
            margin: 2rem auto;
            padding: 0 15px;
        }

        .form-header {
            background: linear-gradient(135deg, #1f2937, #374151);
            border-radius: 15px 15px 0 0;
            padding: 1.5rem 2rem;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            border-bottom: 3px solid var(--primary);
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
            background: linear-gradient(135deg, #135bec, #0d47a1);
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

        .dark .form-card {
            background: #1a2233;
        }

        .section-title {
            color: #135bec;
            font-weight: 600;
            font-size: 1.1rem;
            margin: 1.5rem 0 1rem 0;
            padding-bottom: 0.5rem;
            border-bottom: 2px solid #e5e7eb;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .dark .section-title {
            color: #60a5fa;
            border-bottom-color: #374151;
        }

        .form-label {
            font-weight: 600;
            color: #374151;
            margin-bottom: 0.5rem;
        }

        .dark .form-label {
            color: #d1d5db;
        }

        .form-label.required::after {
            content: " *";
            color: #ef4444;
        }

        .form-control, .form-select {
            border: 2px solid #e5e7eb;
            border-radius: 8px;
            padding: 0.75rem;
            transition: all 0.3s ease;
            width: 100%;
        }

        .dark .form-control, 
        .dark .form-select {
            background: #374151;
            border-color: #4b5563;
            color: #f9fafb;
        }

        .form-control:focus, .form-select:focus {
            border-color: #135bec;
            box-shadow: 0 0 0 0.2rem rgba(19, 91, 236, 0.15);
            outline: none;
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

        .persona-badge {
            display: inline-block;
            padding: 0.25rem 0.75rem;
            border-radius: 6px;
            font-size: 0.75rem;
            font-weight: 600;
            margin-left: 0.5rem;
        }

        .badge-profesor { background: #dbeafe; color: #1e40af; }
        .badge-alumno { background: #dcfce7; color: #166534; }
        .badge-administrativo { background: #fef3c7; color: #92400e; }

        .persona-info {
            background: #f9fafb;
            border: 1px solid #e5e7eb;
            border-radius: 8px;
            padding: 1rem;
            margin-top: 1rem;
            display: none;
        }

        .dark .persona-info {
            background: #374151;
            border-color: #4b5563;
        }

        .persona-info.active {
            display: block;
        }

        .persona-detail {
            display: flex;
            justify-content: space-between;
            padding: 0.5rem 0;
            border-bottom: 1px solid #e5e7eb;
        }

        .dark .persona-detail {
            border-bottom-color: #4b5563;
        }

        .persona-detail:last-child {
            border-bottom: none;
        }

        .persona-detail strong {
            color: #374151;
        }

        .dark .persona-detail strong {
            color: #f3f4f6;
        }

        .persona-detail span {
            color: #6b7280;
        }

        .dark .persona-detail span {
            color: #9ca3af;
        }

        .requisito-cumplido { 
            color: #10b981; 
            font-weight: 500; 
        }
        
        .requisito-incumplido { 
            color: #ef4444; 
        }
        
        .requisito-pendiente { 
            color: #6c757d; 
        }
        
        .criterio-item { 
            transition: all 0.3s ease; 
            margin-bottom: 5px;
            padding: 2px 5px;
            border-radius: 3px;
            list-style: none;
        }
        
        .requisitos-password {
            background: #f9fafb;
            border: 1px solid #e5e7eb;
            border-radius: 8px;
        }

        .dark .requisitos-password {
            background: #374151;
            border-color: #4b5563;
        }

        .btn-modern {
            padding: 0.75rem 2rem;
            border-radius: 10px;
            font-weight: 600;
            border: none;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            cursor: pointer;
        }

        .btn-primary-modern {
            background: linear-gradient(135deg, #135bec, #0d47a1);
            color: white;
        }

        .btn-primary-modern:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 15px rgba(19, 91, 236, 0.3);
        }

        .btn-secondary-modern {
            background: #6b7280;
            color: white;
        }

        .btn-secondary-modern:hover {
            background: #4b5563;
            transform: translateY(-2px);
        }

        .help-text {
            color: #6b7280;
            font-size: 0.875rem;
            margin-top: 0.25rem;
        }

        .dark .help-text {
            color: #9ca3af;
        }

        .filter-section {
            background: #f9fafb;
            border: 2px dashed #e5e7eb;
            border-radius: 10px;
            padding: 1.5rem;
            margin-bottom: 1rem;
        }

        .dark .filter-section {
            background: #374151;
            border-color: #4b5563;
        }

        .tipo-badge {
            cursor: pointer;
            padding: 0.5rem 1rem;
            border-radius: 8px;
            border: 2px solid #e5e7eb;
            background: white;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            margin: 0.25rem;
        }

        .dark .tipo-badge {
            background: #4b5563;
            border-color: #6b7280;
            color: #f9fafb;
        }

        .tipo-badge:hover {
            border-color: #135bec;
            background: #f0f9ff;
        }

        .dark .tipo-badge:hover {
            border-color: #60a5fa;
            background: #1e3a8a;
        }

        .tipo-badge.active {
            border-color: #135bec;
            background: #135bec;
            color: white;
        }

        .accessibility-toggle {
            transition: all 0.3s ease;
        }

        .accessibility-toggle:hover {
            transform: scale(1.1);
        }

        .badge {
            padding: 0.25rem 0.5rem;
            border-radius: 0.375rem;
            font-size: 0.75rem;
            font-weight: 600;
        }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark text-[#111318] dark:text-white min-h-screen" id="main-content">
    <!-- Skip to content link -->
    <a href="#main-content" class="skip-to-content focus:top-0">Saltar al contenido principal</a>
    
    <!-- Accessibility Panel -->
    <div class="fixed top-20 right-0 z-50 accessibility-panel bg-white dark:bg-gray-800 shadow-xl rounded-l-lg p-4 w-80">
        <div class="flex justify-between items-center mb-4">
            <h3 class="font-bold text-lg">Opciones de Accesibilidad</h3>
            <button onclick="toggleAccessibilityPanel()" class="text-gray-500 hover:text-gray-700">
                <span class="material-symbols-outlined">close</span>
            </button>
        </div>
        
        <div class="space-y-4">
            <div class="space-y-2">
                <h4 class="font-medium">Tamaño de texto</h4>
                <div class="flex gap-2">
                    <button onclick="setTextSize('normal')" class="px-3 py-2 bg-gray-100 rounded hover:bg-gray-200 text-sm">Normal</button>
                    <button onclick="setTextSize('large')" class="px-3 py-2 bg-gray-100 rounded hover:bg-gray-200 text-sm">Grande</button>
                    <button onclick="setTextSize('larger')" class="px-3 py-2 bg-gray-100 rounded hover:bg-gray-200 text-sm">Más Grande</button>
                </div>
            </div>
            
            <div class="space-y-2">
                <h4 class="font-medium">Contraste</h4>
                <div class="flex gap-2">
                    <button onclick="setContrast('normal')" class="px-3 py-2 bg-gray-100 rounded hover:bg-gray-200 text-sm">Normal</button>
                    <button onclick="setContrast('high')" class="px-3 py-2 bg-gray-100 rounded hover:bg-gray-200 text-sm">Alto Contraste</button>
                    <button onclick="setContrast('yellow')" class="px-3 py-2 bg-gray-100 rounded hover:bg-gray-200 text-sm">Amarillo/Negro</button>
                </div>
            </div>
            
            <div class="space-y-2">
                <h4 class="font-medium">Otros ajustes</h4>
                <div class="flex flex-col gap-2">
                    <label class="flex items-center gap-2">
                        <input type="checkbox" id="reduceMotion" onchange="toggleMotion()">
                        <span>Reducir movimiento</span>
                    </label>
                    <label class="flex items-center gap-2">
                        <input type="checkbox" id="dyslexiaFont" onchange="toggleDyslexiaFont()">
                        <span>Fuente para dislexia</span>
                    </label>
                    <label class="flex items-center gap-2">
                        <input type="checkbox" id="beigeBackground" onchange="toggleBeigeBackground()">
                        <span>Fondo beige</span>
                    </label>
                </div>
            </div>
            
            <button onclick="resetAccessibility()" class="w-full py-2 bg-gray-800 text-white rounded hover:bg-gray-900">
                Restablecer ajustes
            </button>
        </div>
    </div>
    
    <!-- Accessibility Toggle Button -->
    <button onclick="toggleAccessibilityPanel()" 
            class="fixed top-20 right-0 z-40 bg-primary text-white p-3 rounded-l-lg shadow-lg hover:bg-blue-700 transition-colors accessibility-toggle"
            aria-label="Abrir panel de accesibilidad">
        <span class="material-symbols-outlined">accessibility_new</span>
    </button>

    <div class="flex h-screen overflow-hidden">
        
        <%-- ✅ SIDEBAR: barra lateral con navegación y roles --%>
        <%@ include file="includes/sidebar.jsp" %>
        
        <main class="flex-1 flex flex-col overflow-y-auto">
            
            <%-- ✅ HEADER: barra superior con foto dinámica del usuario --%>
            <%@ include file="includes/header.jsp" %>

            <div class="form-wrapper">
                <!-- Mensajes -->
                <% if (session.getAttribute("mensaje") != null) { %>
                    <div class="alert-modern alert-success mb-6" role="alert">
                        <i class="fas fa-check-circle text-xl"></i>
                        <div><%= session.getAttribute("mensaje") %></div>
                    </div>
                    <% session.removeAttribute("mensaje"); %>
                <% } %>
                
                <% if (session.getAttribute("error") != null) { %>
                    <div class="alert-modern alert-danger mb-6" role="alert">
                        <i class="fas fa-exclamation-circle text-xl"></i>
                        <div><%= session.getAttribute("error") %></div>
                    </div>
                    <% session.removeAttribute("error"); %>
                <% } %>

                <!-- Header del Formulario -->
                <div class="form-header">
                    <h2>
                        <div class="icon">
                            <i class="fas <%= esEditar ? "fa-user-edit" : "fa-user-plus" %>"></i>
                        </div>
                        <%= esEditar ? "Editar Usuario" : "Registrar Nuevo Usuario"%>
                    </h2>
                </div>

                <!-- Formulario -->
                <div class="form-card">
                    <form action="UsuarioServlet" method="post" id="usuarioForm">
                        <input type="hidden" name="id" value="<%= id %>">
                        <input type="hidden" name="persona_id" id="persona_id_hidden" value="<%= personaId %>">
                        <input type="hidden" name="rol" id="rol_hidden" value="<%= rol %>">

                        <% if (!esEditar) { %>
                        <!-- SECCIÓN: SELECCIONAR PERSONA -->
                        <div class="section-title">
                            <i class="fas fa-user-tie"></i>
                            Asociar a Persona
                        </div>

                        <div class="filter-section">
                            <label class="form-label">Seleccione el tipo de persona:</label>
                            <div class="flex flex-wrap gap-2">
                                <div class="tipo-badge" data-tipo="PROFESOR" data-rol="docente">
                                    <i class="fas fa-chalkboard-teacher"></i>
                                    Profesor
                                    <span class="badge bg-primary text-white"><%= profesoresSinUsuario != null ? profesoresSinUsuario.size() : 0 %></span>
                                </div>
                                <div class="tipo-badge" data-tipo="ALUMNO" data-rol="padre">
                                    <i class="fas fa-user-graduate"></i>
                                    Alumno (Padre)
                                    <span class="badge bg-success text-white"><%= alumnosSinUsuario != null ? alumnosSinUsuario.size() : 0 %></span>
                                </div>
                                <div class="tipo-badge" data-tipo="ADMINISTRATIVO" data-rol="administrativo">
                                    <i class="fas fa-user-cog"></i>
                                    Administrativo
                                    <span class="badge bg-warning text-white"><%= administrativosSinUsuario != null ? administrativosSinUsuario.size() : 0 %></span>
                                </div>
                            </div>
                        </div>

                        <div class="mb-4">
                            <label class="form-label required">Persona:</label>
                            <div class="input-group-icon">
                                <i class="fas fa-user"></i>
                                <select class="form-select" id="persona_id_select" required>
                                    <option value="">Primero seleccione un tipo de persona</option>
                                </select>
                            </div>
                            <small class="help-text">
                                <i class="fas fa-info-circle"></i>
                                Solo se muestran personas que NO tienen usuario asignado
                            </small>
                        </div>

                        <!-- INFO DE PERSONA SELECCIONADA -->
                        <div class="persona-info" id="personaInfo">
                            <strong><i class="fas fa-id-card"></i> Información de la Persona:</strong>
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
                            <div class="alert-modern alert-info">
                                <i class="fas fa-info-circle"></i>
                                <div><strong>Persona Asociada:</strong> No se puede cambiar en modo edición</div>
                            </div>
                        <% } %>

                        <hr class="my-8 border-gray-300 dark:border-gray-600">

                        <!-- SECCIÓN: CREDENCIALES -->
                        <div class="section-title">
                            <i class="fas fa-key"></i>
                            Credenciales de Acceso
                        </div>

                        <div class="mb-4">
                            <label class="form-label required">Nombre de Usuario:</label>
                            <div class="input-group-icon">
                                <i class="fas fa-user-circle"></i>
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
                                    <i class="fas fa-lock"></i>
                                    El nombre de usuario no se puede modificar
                                </small>
                            <% } else { %>
                                <small class="help-text">
                                    <i class="fas fa-lightbulb"></i>
                                    Se sugiere usar el formato: nombre.apellido o correo sin @dominio
                                </small>
                            <% } %>
                        </div>

                        <div class="mb-4">
                            <label class="form-label <%= esEditar ? "" : "required" %>">Contraseña:</label>
                            <div class="input-group-icon">
                                <i class="fas fa-lock"></i>
                                <input type="password" 
                                       class="form-control" 
                                       name="password" 
                                       id="passwordInput" 
                                       <%= esEditar ? "" : "required" %>
                                       oninput="validarPasswordEnTiempoReal(this.value)"
                                       placeholder="<%= esEditar ? "Dejar vacío para mantener contraseña actual" : "Ingrese una contraseña segura"%>">
                            </div>
                            
                            <div id="indicadorPassword" class="help-text mt-2"></div>
                            
                            <div class="requisitos-password mt-2 p-3" style="display: none;" id="requisitosPassword">
                                <strong><i class="fas fa-shield-alt"></i> Requisitos de contraseña segura:</strong>
                                <ul class="mb-0 mt-2" style="padding-left: 1.2em;">
                                    <li id="reqLongitud" class="criterio-item requisito-pendiente">
                                        <i class="fas fa-circle"></i> Mínimo 8 caracteres
                                    </li>
                                    <li id="reqMayuscula" class="criterio-item requisito-pendiente">
                                        <i class="fas fa-circle"></i> Al menos una letra mayúscula
                                    </li>
                                    <li id="reqMinuscula" class="criterio-item requisito-pendiente">
                                        <i class="fas fa-circle"></i> Al menos una letra minúscula
                                    </li>
                                    <li id="reqNumero" class="criterio-item requisito-pendiente">
                                        <i class="fas fa-circle"></i> Al menos un número
                                    </li>
                                    <li id="reqEspecial" class="criterio-item requisito-pendiente">
                                        <i class="fas fa-circle"></i> Al menos un carácter especial (!@#$%^&*)
                                    </li>
                                    <li id="reqCriterios" class="criterio-item requisito-pendiente">
                                        <i class="fas fa-circle"></i> Cumplir al menos 3 de los 4 criterios anteriores
                                    </li>
                                </ul>
                                <div class="mt-2 p-2 bg-white dark:bg-gray-700 rounded">
                                    <small><strong>Criterios cumplidos:</strong> <span id="criteriosCumplidos" class="badge bg-gray-500 text-white">0</span>/4</small>
                                </div>
                            </div>
                            
                            <% if (esEditar) { %>
                                <small class="help-text">
                                    <i class="fas fa-info-circle"></i>
                                    Dejar en blanco para mantener la contraseña actual
                                </small>
                            <% } %>
                        </div>

                        <!-- BOTONES -->
                        <div class="flex justify-between mt-6 pt-6 border-t border-gray-300 dark:border-gray-600">
                            <a href="UsuarioServlet" class="btn-modern btn-secondary-modern">
                                <i class="fas fa-times"></i>
                                Cancelar
                            </a>
                            <button type="submit" class="btn-modern btn-primary-modern" id="submitBtn">
                                <i class="fas <%= esEditar ? "fa-save" : "fa-check" %>"></i>
                                <%= esEditar ? "Actualizar Usuario" : "Registrar Usuario"%>
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </main>
    </div>

    <script>
        // Accessibility Functions
        function toggleAccessibilityPanel() {
            const panel = document.querySelector('.accessibility-panel');
            panel.classList.toggle('open');
        }
        
        function setTextSize(size) {
            document.body.classList.remove('large-text', 'larger-text', 'largest-text');
            if (size !== 'normal') {
                document.body.classList.add(size + '-text');
            }
        }
        
        function setContrast(mode) {
            document.body.classList.remove('high-contrast-invert', 'high-contrast-yellow');
            if (mode === 'high') {
                document.body.classList.add('high-contrast-invert');
            } else if (mode === 'yellow') {
                document.body.classList.add('high-contrast-yellow');
            }
        }
        
        function toggleMotion() {
            document.body.classList.toggle('reduce-motion', document.getElementById('reduceMotion').checked);
        }
        
        function toggleDyslexiaFont() {
            document.body.classList.toggle('dyslexia-font', document.getElementById('dyslexiaFont').checked);
        }
        
        function toggleBeigeBackground() {
            document.body.classList.toggle('beige-background', document.getElementById('beigeBackground').checked);
        }
        
        function resetAccessibility() {
            document.body.classList.remove('large-text','larger-text','largest-text','high-contrast-invert','high-contrast-yellow','reduce-motion','dyslexia-font','beige-background');
            ['reduceMotion','dyslexiaFont','beigeBackground'].forEach(id => document.getElementById(id).checked = false);
        }
        
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                document.querySelector('.accessibility-panel').classList.remove('open');
            }
        });
        
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
        console.log('📊 Alumnos sin usuario cargados:', alumnosSinUsuario);
        console.log('📊 Administrativos sin usuario cargados:', administrativosSinUsuario);

        // ===================================================================
        // MANEJO DE SELECCIÓN DE TIPO DE PERSONA
        // ===================================================================
        const esEdicion = <%= esEditar %>;
        
        if (!esEdicion) {
            document.querySelectorAll('.tipo-badge').forEach(badge => {
                badge.addEventListener('click', function() {
                    console.log('🖱️ Badge clickeado:', this.dataset.tipo);
                    
                    document.querySelectorAll('.tipo-badge').forEach(b => b.classList.remove('active'));
                    this.classList.add('active');
                    
                    const tipo = this.dataset.tipo;
                    const rol = this.dataset.rol;
                    
                    document.getElementById('rol_hidden').value = rol;
                    console.log('✅ Rol establecido:', rol);
                    
                    cargarPersonasPorTipo(tipo);
                });
            });
        }

        function cargarPersonasPorTipo(tipo) {
            const select = document.getElementById('persona_id_select');
            select.innerHTML = '';
            
            let personas = [];
            if (tipo === 'PROFESOR') personas = profesoresSinUsuario;
            else if (tipo === 'ALUMNO') personas = alumnosSinUsuario;
            else if (tipo === 'ADMINISTRATIVO') personas = administrativosSinUsuario;
            
            console.log('🔍 Cargando personas tipo:', tipo, '- Total:', personas.length);
            
            if (personas.length === 0) {
                const optionVacia = document.createElement('option');
                optionVacia.value = '';
                optionVacia.textContent = 'No hay personas disponibles de este tipo';
                select.appendChild(optionVacia);
                select.disabled = true;
                return;
            }
            
            const optionDefault = document.createElement('option');
            optionDefault.value = '';
            optionDefault.textContent = '-- Seleccione una persona --';
            select.appendChild(optionDefault);
            
            personas.forEach((p) => {
                const option = document.createElement('option');
                option.value = p.personaId;
                
                const apellidos = (p.apellidos && String(p.apellidos).trim() !== '' && String(p.apellidos).trim() !== 'null') ? String(p.apellidos).trim() : '';
                const nombres = (p.nombres && String(p.nombres).trim() !== '' && String(p.nombres).trim() !== 'null') ? String(p.nombres).trim() : '';
                const codigo = (p.codigo && String(p.codigo).trim() !== '') ? String(p.codigo).trim() : '';
                
                let textoOpcion = '';
                if (apellidos !== '' && nombres !== '') {
                    textoOpcion = apellidos + ', ' + nombres;
                } else if (apellidos !== '') {
                    textoOpcion = apellidos;
                } else if (nombres !== '') {
                    textoOpcion = nombres;
                } else {
                    textoOpcion = 'Persona ID: ' + p.personaId;
                }
                
                if (codigo !== '') {
                    textoOpcion += ' [' + codigo + ']';
                }
                
                option.textContent = textoOpcion;
                option.dataset.persona = JSON.stringify(p);
                select.appendChild(option);
            });
            
            select.disabled = false;
        }

        if (!esEdicion) {
            document.getElementById('persona_id_select').addEventListener('change', function() {
                const selectedOption = this.options[this.selectedIndex];
                const personaId = this.value;
                
                document.getElementById('persona_id_hidden').value = personaId;
                
                if (personaId && selectedOption.dataset.persona) {
                    const persona = JSON.parse(selectedOption.dataset.persona);
                    mostrarInfoPersona(persona);
                    
                    if (persona.correo && persona.correo.trim() !== '') {
                        const usernamesugerido = persona.correo.split('@')[0];
                        document.getElementById('username').value = usernamesugerido;
                    }
                } else {
                    ocultarInfoPersona();
                }
            });
        }

        function mostrarInfoPersona(persona) {
            const nombreCompleto = (persona.nombres || '') + ' ' + (persona.apellidos || '');
            document.getElementById('infoNombre').textContent = nombreCompleto.trim() || '-';
            document.getElementById('infoCorreo').textContent = persona.correo || '-';
            document.getElementById('infoDni').textContent = persona.dni || '-';
            document.getElementById('infoCodigo').textContent = persona.codigo || '-';
            document.getElementById('infoAdicional').textContent = persona.infoAdicional || '-';
            
            document.getElementById('personaInfo').classList.add('active');
        }

        function ocultarInfoPersona() {
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
                requisitos.style.display = 'block';
            } else {
                if (esEdicion) {
                    indicador.innerHTML = '<span class="text-success"><i class="fas fa-check-circle"></i> Se mantendrá la contraseña actual</span>';
                    submitBtn.disabled = false;
                } else {
                    indicador.innerHTML = '<span class="text-warning"><i class="fas fa-exclamation-triangle"></i> Ingrese una contraseña</span>';
                    submitBtn.disabled = true;
                }
                requisitos.style.display = 'none';
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
                indicador.innerHTML = '<span class="text-success"><i class="fas fa-check-circle"></i> Contraseña segura</span>';
                submitBtn.disabled = false;
            } else {
                let mensajesError = [];
                if (!longitudValida) mensajesError.push('mínimo 8 caracteres');
                if (!criteriosValidos) mensajesError.push('cumplir 3 de 4 criterios');
                
                indicador.innerHTML = '<span class="text-danger"><i class="fas fa-times-circle"></i> Faltan: ' + mensajesError.join(', ') + '</span>';
                submitBtn.disabled = true;
            }
        }
        
        function actualizarRequisito(elementId, cumple) {
            const elemento = document.getElementById(elementId);
            const textoBase = textosOriginales[elementId];
            
            if (cumple) {
                elemento.className = 'criterio-item requisito-cumplido';
                elemento.innerHTML = '<i class="fas fa-check-circle"></i> ' + textoBase;
            } else {
                elemento.className = 'criterio-item requisito-incumplido';
                elemento.innerHTML = '<i class="fas fa-times-circle"></i> ' + textoBase;
            }
        }
        
        function resetearRequisitos() {
            Object.keys(textosOriginales).forEach(elementId => {
                const elemento = document.getElementById(elementId);
                if (elemento) {
                    elemento.className = 'criterio-item requisito-pendiente';
                    elemento.innerHTML = '<i class="fas fa-circle"></i> ' + textosOriginales[elementId];
                }
            });
            document.getElementById('criteriosCumplidos').textContent = '0';
        }
        
        // ===================================================================
        // ENVÍO DEL FORMULARIO
        // ===================================================================
        document.getElementById('usuarioForm').addEventListener('submit', async function(e) {
            e.preventDefault();
            
            if (!esEdicion) {
                const personaId = document.getElementById('persona_id_hidden').value;
                if (!personaId || personaId === '0' || personaId === '') {
                    alert('❌ Debe seleccionar una persona para asociar el usuario');
                    return false;
                }
                
                const rol = document.getElementById('rol_hidden').value;
                if (!rol || rol === '') {
                    alert('❌ Debe seleccionar un tipo de persona (esto establece el rol automáticamente)');
                    return false;
                }
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

        document.getElementById('passwordInput').addEventListener('focus', function() {
            if (this.value.length > 0) {
                document.getElementById('requisitosPassword').style.display = 'block';
            }
        });
    </script>
</body>
</html>
