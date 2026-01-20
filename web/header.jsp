<%-- 
    Document   : header
    Created on : 1 may. 2025, 8:44:30 p. m.
    Author     : Juan Pablo Amaya
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="javax.servlet.http.HttpSession" %>

<head>
    <meta charset="UTF-8">
    <title>Panel Colegio</title>

    <!-- Bootstrap 5 por CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600&display=swap" rel="stylesheet">
    <style>
        .accessibility-btn {
            background: transparent;
            border: 1px solid rgba(255,255,255,0.5);
            color: white;
            border-radius: 50%;
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        .accessibility-btn:hover {
            background: rgba(255,255,255,0.1);
            transform: scale(1.05);
        }
        .accessibility-btn.active {
            background: rgba(220, 53, 69, 0.3);
            border-color: #dc3545;
        }
        .accessibility-modal .nav-link {
            color: #495057;
            font-weight: 500;
        }
        .accessibility-modal .nav-link.active {
            background-color: #0d6efd;
            color: white;
        }
        .contrast-preview {
            width: 30px;
            height: 30px;
            border-radius: 4px;
            display: inline-block;
            margin-right: 8px;
            border: 1px solid #ddd;
            cursor: pointer;
        }
        .contrast-normal { background: #ffffff; color: #000000; }
        .contrast-invert { background: #000000; color: #ffffff; }
        .contrast-yellow { background: #ffff00; color: #000000; }
        
        /* Estilos para tooltips */
        .info-tooltip {
            color: #6c757d;
            cursor: help;
            margin-left: 5px;
        }
        .info-tooltip:hover {
            color: #0d6efd;
        }
        
        /* Estilos para las configuraciones de accesibilidad */
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
            font-size: 20px !important;
        }
        
        .larger-text {
            font-size: 24px !important;
        }
        
        .largest-text {
            font-size: 28px !important;
        }
        
        /* Estilos para fuente de dislexia */
        .dyslexia-font {
            font-family: Arial, Helvetica, sans-serif !important;
            font-size: 1.1em !important;
            line-height: 1.6 !important;
            letter-spacing: 0.5px !important;
        }
        
        /* Modo enfoque mejorado para TDAH */
        .focus-mode {
            position: relative;
        }
        
        .focus-mode.active::before {
            content: '';
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.85);
            z-index: 1040;
            display: block;
        }
        
        .focus-mode.active .focus-content {
            position: relative;
            z-index: 1041;
            background: white;
            margin: 40px auto;
            border-radius: 12px;
            padding: 25px;
            box-shadow: 0 0 40px rgba(0,0,0,0.7);
            max-width: 95%;
            max-height: 90vh;
            overflow: auto;
        }
        
        .focus-mode.active .navbar,
        .focus-mode.active footer,
        .focus-mode.active .sidebar,
        .focus-mode.active .focus-exclude {
            display: none !important;
        }
        
        /* Botón de salida del modo enfoque */
        .exit-focus-btn {
            position: fixed;
            top: 15px;
            right: 15px;
            z-index: 1060;
            background: #ffc107;
            color: #000;
            border: none;
            border-radius: 25px;
            padding: 10px 20px;
            font-weight: 600;
            box-shadow: 0 4px 15px rgba(0,0,0,0.3);
            display: none;
            align-items: center;
            gap: 8px;
            transition: all 0.3s ease;
        }
        
        .exit-focus-btn:hover {
            background: #e0a800;
            transform: scale(1.05);
        }
        
        .focus-mode.active .exit-focus-btn {
            display: flex;
        }
        
        /* Atajo de teclado */
        .exit-focus-btn kbd {
            background: rgba(0,0,0,0.2);
            padding: 2px 6px;
            border-radius: 4px;
            font-size: 0.8em;
            margin-left: 5px;
        }
        
        /* Modo reducción sensorial para TEA */
        .sensory-reduction {
            animation: none !important;
            transition: none !important;
        }
        
        .sensory-reduction * {
            animation: none !important;
            transition: none !important;
        }
        
        .sensory-reduction .btn,
        .sensory-reduction .card {
            background-color: #f8f9fa !important;
            color: #495057 !important;
            border-color: #dee2e6 !important;
        }
        
        .sensory-reduction .navbar {
            background-color: #6c757d !important;
        }
        
        /* Botón de deshacer */
        .undo-button {
            position: fixed;
            bottom: 20px;
            left: 20px;
            background: #dc3545;
            color: white;
            border: none;
            border-radius: 25px;
            padding: 10px 20px;
            z-index: 10000;
            box-shadow: 0 4px 12px rgba(0,0,0,0.3);
            display: none;
        }
        
        .undo-button.show {
            display: block;
            animation: slideInUp 0.3s ease;
        }
        
        @keyframes slideInUp {
            from { transform: translateY(100px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }
        
        /* Indicador de voz MEJORADO */
        .voice-indicator {
            position: fixed;
            bottom: 20px;
            right: 20px;
            background: #dc3545;
            color: white;
            border-radius: 50%;
            width: 80px;
            height: 80px;
            display: none;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            z-index: 10000;
            box-shadow: 0 4px 20px rgba(0,0,0,0.4);
            border: 3px solid white;
            flex-direction: column;
            gap: 5px;
        }
        
        .voice-indicator.listening {
            background: #28a745;
            animation: pulse 1s infinite;
        }
        
        .voice-indicator.processing {
            background: #ffc107;
            animation: none;
        }
        
        .voice-indicator .voice-status {
            font-size: 0.7em;
            font-weight: bold;
        }
        
        @keyframes pulse {
            0% { transform: scale(1); box-shadow: 0 4px 20px rgba(40, 167, 69, 0.6); }
            50% { transform: scale(1.05); box-shadow: 0 6px 25px rgba(40, 167, 69, 0.8); }
            100% { transform: scale(1); box-shadow: 0 4px 20px rgba(40, 167, 69, 0.6); }
        }
        
        /* Notificaciones de voz */
        .voice-notification {
            position: fixed;
            top: 20px;
            right: 20px;
            background: #333;
            color: white;
            padding: 15px 20px;
            border-radius: 10px;
            z-index: 10001;
            max-width: 300px;
            font-size: 14px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.3);
            display: none;
        }
        
        .voice-notification.show {
            display: block;
            animation: slideInRight 0.3s ease;
        }
        
        @keyframes slideInRight {
            from { transform: translateX(100%); opacity: 0; }
            to { transform: translateX(0); opacity: 1; }
        }
        
        /* ESTILOS CORREGIDOS PARA DALTONISMO */
        .colorblind-protanopia {
            filter: url('#protanopia') !important;
        }
        
        .colorblind-deuteranopia {
            filter: url('#deuteranopia') !important;
        }
        
        .colorblind-tritanopia {
            filter: url('#tritanopia') !important;
        }
        
        .colorblind-achromatopsia {
            filter: grayscale(100%) contrast(150%) !important;
        }
        
        /* Asegurar que los filtros se apliquen correctamente */
        html.colorblind-protanopia,
        html.colorblind-deuteranopia,
        html.colorblind-tritanopia,
        html.colorblind-achromatopsia {
            width: 100% !important;
            height: 100% !important;
        }
        
        body.colorblind-protanopia,
        body.colorblind-deuteranopia,
        body.colorblind-tritanopia,
        body.colorblind-achromatopsia {
            width: 100% !important;
            min-height: 100vh !important;
            margin: 0 !important;
            padding: 0 !important;
            overflow-x: hidden !important;
        }
        
        /* Simulador de vista de daltonismo para previews */
        .colorblind-preview {
            width: 25px;
            height: 25px;
            border-radius: 4px;
            display: inline-block;
            margin-right: 8px;
            border: 1px solid #ddd;
            cursor: pointer;
            position: relative;
        }
        
        .colorblind-preview.protanopia {
            background: linear-gradient(45deg, #5e5e5e 0%, #004d00 50%, #000080 100%) !important;
        }
        
        .colorblind-preview.deuteranopia {
            background: linear-gradient(45deg, #8a8a8a 0%, #006600 50%, #191974 100%) !important;
        }
        
        .colorblind-preview.tritanopia {
            background: linear-gradient(45deg, #ffff80 0%, #ff80ff 50%, #8080ff 100%) !important;
        }
        
        .colorblind-preview.achromatopsia {
            background: linear-gradient(45deg, #404040 0%, #808080 50%, #c0c0c0 100%) !important;
        }
        
        .colorblind-option {
            border: 2px solid transparent;
            border-radius: 8px;
            padding: 10px;
            margin: 5px 0;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .colorblind-option:hover {
            background-color: #f8f9fa;
            border-color: #dee2e6;
        }
        
        .colorblind-option.selected {
            background-color: #e3f2fd;
            border-color: #2196f3;
        }
        
        .colorblind-description {
            font-size: 0.85em;
            color: #6c757d;
            margin-top: 5px;
        }

        /* Perfiles de accesibilidad */
        .profile-option {
            border: 2px solid #e9ecef;
            border-radius: 8px;
            padding: 15px;
            margin: 10px 0;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .profile-option:hover {
            border-color: #0d6efd;
            background-color: #f8f9fa;
        }
        
        .profile-option.selected {
            border-color: #0d6efd;
            background-color: #e3f2fd;
        }
        
        .profile-badge {
            font-size: 0.75em;
            padding: 3px 8px;
            border-radius: 12px;
            margin-left: 8px;
        }
        
        .profile-description {
            font-size: 0.85em;
            color: #6c757d;
            margin-top: 8px;
        }

        /* Solución alternativa para navegadores que no soportan bien SVG filters */
        .colorblind-protanopia-alt {
            filter: sepia(0.3) saturate(0.5) hue-rotate(-20deg) !important;
        }
        
        .colorblind-deuteranopia-alt {
            filter: sepia(0.3) saturate(0.5) hue-rotate(25deg) !important;
        }
        
        .colorblind-tritanopia-alt {
            filter: sepia(0.2) saturate(2) hue-rotate(150deg) !important;
        }
    </style>
</head>
<body>
    <!-- Filtros SVG para daltonismo - POSICIÓN CORREGIDA -->
    <svg xmlns="http://www.w3.org/2000/svg" version="1.1" style="position: absolute; width: 0; height: 0; overflow: hidden;">
        <defs>
            <!-- Filtro para Protanopia (ceguera al rojo) -->
            <filter id="protanopia" x="0" y="0" width="100%" height="100%">
                <feColorMatrix type="matrix" values="0.567, 0.433, 0, 0, 0 
                                                     0.558, 0.442, 0, 0, 0 
                                                     0, 0.242, 0.758, 0, 0 
                                                     0, 0, 0, 1, 0" />
            </filter>
            
            <!-- Filtro para Deuteranopia (ceguera al verde) -->
            <filter id="deuteranopia" x="0" y="0" width="100%" height="100%">
                <feColorMatrix type="matrix" values="0.625, 0.375, 0, 0, 0 
                                                     0.7, 0.3, 0, 0, 0 
                                                     0, 0.3, 0.7, 0, 0 
                                                     0, 0, 0, 1, 0" />
            </filter>
            
            <!-- Filtro para Tritanopia (ceguera al azul) -->
            <filter id="tritanopia" x="0" y="0" width="100%" height="100%">
                <feColorMatrix type="matrix" values="0.95, 0.05, 0, 0, 0 
                                                     0, 0.433, 0.567, 0, 0 
                                                     0, 0.475, 0.525, 0, 0 
                                                     0, 0, 0, 1, 0" />
            </filter>
        </defs>
    </svg>

    <!-- Botón de deshacer -->
    <button class="undo-button" id="undoButton">
        <i class="fas fa-undo me-2"></i>Deshacer última acción
    </button>

    <!-- Botón para salir del modo enfoque -->
    <button class="exit-focus-btn" id="exitFocusMode" title="Salir del modo enfoque (Esc)">
        <i class="fas fa-times"></i> Salir del modo enfoque 
        <kbd>Esc</kbd>
    </button>

    <!-- Notificación de voz -->
    <div class="voice-notification" id="voiceNotification"></div>

    <nav class="navbar navbar-expand-lg navbar-dark bg-dark mb-4">
        <div class="container-fluid">
            <a class="navbar-brand" href="<%= request.getSession().getAttribute("rol") != null && "docente".equals(request.getSession().getAttribute("rol")) ? "docenteDashboard.jsp" : "dashboard.jsp"%>"><img src="assets/img/logosa.png" alt="Logo" style="width: 30px; height: auto; margin-right: 10px;">Colegio SA</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse"
                    data-bs-target="#navbarNav" aria-controls="navbarNav"
                    aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>

            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                    <% if ("docente".equals(request.getSession().getAttribute("rol"))) { %>
                    <!-- Opciones para el rol Docente -->
                    <li class="nav-item">
                        <a class="nav-link" href="TareaServlet">Tareas</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="NotaServlet">Notas</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="VerAlumnosServlet">Ver Alumnos</a>
                    </li>
                    <% } else if ("admin".equals(request.getSession().getAttribute("rol"))) { %>
                    <!-- Opciones para el rol Admin -->
                    <li class="nav-item">
                        <a class="nav-link" href="AlumnoServlet">Alumnos</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="ProfesorServlet">Profesores</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="CursoServlet">Cursos</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="GradoServlet">Grados</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="UsuarioServlet">Usuarios</a>
                    </li>
                    <% } %>
                </ul>

                <div class="d-flex align-items-center">
                    <span class="navbar-text text-light me-3">
                        <%= (request.getSession().getAttribute("usuario") != null) ? request.getSession().getAttribute("usuario") : "Invitado"%>
                    </span>
                    
                    <!-- Botón de accesibilidad -->
                    <button class="accessibility-btn me-2" id="accessibilityToggle" title="Configuración de accesibilidad">
                        <i class="fas fa-universal-access"></i>
                    </button>
                    
                    <!-- Botón de activar control por voz MEJORADO -->
                    <button class="accessibility-btn me-2" id="voiceControlToggle" title="Activar control por voz - Click para empezar a escuchar">
                        <i class="fas fa-microphone"></i>
                    </button>
                    
                    <a class="btn btn-outline-light btn-sm" href="LogoutServlet">Cerrar sesión</a>
                </div>
            </div>
        </div>
    </nav>

    <!-- Modal de Configuración de Accesibilidad -->
    <div class="modal fade accessibility-modal" id="accessibilityModal" tabindex="-1" aria-labelledby="accessibilityModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="accessibilityModalLabel">
                        <i class="fas fa-universal-access me-2"></i>Panel de Accesibilidad
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <ul class="nav nav-pills mb-3" id="accessibilityTabs" role="tablist">
                        <li class="nav-item" role="presentation">
                            <button class="nav-link active" id="profiles-tab" data-bs-toggle="pill" data-bs-target="#profiles" type="button" role="tab" aria-controls="profiles" aria-selected="true">Perfiles</button>
                        </li>
                        <li class="nav-item" role="presentation">
                            <button class="nav-link" id="visual-tab" data-bs-toggle="pill" data-bs-target="#visual" type="button" role="tab" aria-controls="visual" aria-selected="false">Visual</button>
                        </li>
                        <li class="nav-item" role="presentation">
                            <button class="nav-link" id="navigation-tab" data-bs-toggle="pill" data-bs-target="#navigation" type="button" role="tab" aria-controls="navigation" aria-selected="false">Navegación</button>
                        </li>
                        <li class="nav-item" role="presentation">
                            <button class="nav-link" id="behavior-tab" data-bs-toggle="pill" data-bs-target="#behavior" type="button" role="tab" aria-controls="behavior" aria-selected="false">Comportamiento</button>
                        </li>
                    </ul>
                    
                    <div class="tab-content" id="accessibilityTabContent">
                        <!-- Pestaña Perfiles Predefinidos -->
                        <div class="tab-pane fade show active" id="profiles" role="tabpanel" aria-labelledby="profiles-tab">
                            <div class="alert alert-info">
                                <i class="fas fa-info-circle me-2"></i>
                                Selecciona un perfil predefinido para aplicar automáticamente todas las configuraciones recomendadas.
                            </div>
                            
                            <div class="profile-option" data-profile="baja-vision">
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="accessibilityProfile" id="profileBajaVision" value="baja-vision">
                                    <label class="form-check-label fw-bold" for="profileBajaVision">
                                        👁️ Baja Visión
                                        <span class="profile-badge bg-warning text-dark">Recomendado</span>
                                    </label>
                                </div>
                                <div class="profile-description">
                                    Fuente 24px, alto contraste invertido, espaciado amplio. Ideal para personas con dificultad para ver texto pequeño.
                                </div>
                            </div>
                            
                            <div class="profile-option" data-profile="daltonismo">
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="accessibilityProfile" id="profileDaltonismo" value="daltonismo">
                                    <label class="form-check-label fw-bold" for="profileDaltonismo">
                                        🎨 Daltonismo
                                    </label>
                                </div>
                                <div class="profile-description">
                                    Modo deuteranopia, etiquetas visibles, sin dependencia de color. Para dificultad para distinguir colores.
                                </div>
                            </div>
                            
                            <div class="profile-option" data-profile="dislexia">
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="accessibilityProfile" id="profileDislexia" value="dislexia">
                                    <label class="form-check-label fw-bold" for="profileDislexia">
                                        📝 Dislexia
                                    </label>
                                </div>
                                <div class="profile-description">
                                    Fuente Arial mejorada, fondo beige, párrafos cortos. Ayuda en la lectura y comprensión.
                                </div>
                            </div>
                            
                            <div class="profile-option" data-profile="tdah">
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="accessibilityProfile" id="profileTdah" value="tdah">
                                    <label class="form-check-label fw-bold" for="profileTdah">
                                        ⚡ TDAH
                                    </label>
                                </div>
                                <div class="profile-description">
                                    Modo enfoque, reducción de distracciones, notificaciones agrupadas. Mejora la concentración.
                                </div>
                            </div>
                            
                            <div class="profile-option" data-profile="tea">
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="accessibilityProfile" id="profileTea" value="tea">
                                    <label class="form-check-label fw-bold" for="profileTea">
                                        🌈 TEA
                                    </label>
                                </div>
                                <div class="profile-description">
                                    Reducción sensorial completa, sin animaciones, colores suaves. Interfaz predecible y tranquila.
                                </div>
                            </div>
                            
                            <div class="profile-option" data-profile="movilidad">
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="accessibilityProfile" id="profileMovilidad" value="movilidad">
                                    <label class="form-check-label fw-bold" for="profileMovilidad">
                                        ♿ Movilidad Reducida
                                    </label>
                                </div>
                                <div class="profile-description">
                                    Navegación por teclado, control por voz, botones grandes. Para uso sin mouse.
                                </div>
                            </div>
                        </div>
                        
                        <!-- Pestaña Visual -->
                        <div class="tab-pane fade" id="visual" role="tabpanel" aria-labelledby="visual-tab">
                            <div class="mb-3">
                                <label class="form-label">
                                    Tamaño de texto
                                    <i class="fas fa-info-circle info-tooltip" data-bs-toggle="tooltip" title="Ajusta el tamaño del texto para mejorar la legibilidad. Recomendado para personas con baja visión."></i>
                                </label>
                                <input type="range" class="form-range" id="fontSize" min="16" max="28" value="16">
                                <div class="d-flex justify-content-between">
                                    <small>16px</small>
                                    <small id="currentFontSize">16px</small>
                                    <small>28px</small>
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label">
                                    Tipo de fuente
                                    <i class="fas fa-info-circle info-tooltip" data-bs-toggle="tooltip" title="Configura Arial con mejoras de legibilidad (tamaño, espaciado y altura de línea) para personas con dislexia."></i>
                                </label>
                                <select class="form-select" id="fontType">
                                    <option value="default">Fuente predeterminada</option>
                                    <option value="opendyslexic">Fuente para Dislexia (Arial mejorada)</option>
                                </select>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label">
                                    Esquema de contraste
                                    <i class="fas fa-info-circle info-tooltip" data-bs-toggle="tooltip" title="Mejora el contraste entre texto y fondo para personas con daltonismo o baja visión."></i>
                                </label>
                                <div>
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="radio" name="contrastScheme" id="contrastNormal" value="normal" checked>
                                        <label class="form-check-label" for="contrastNormal">
                                            <span class="contrast-preview contrast-normal">A</span> Normal
                                        </label>
                                    </div>
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="radio" name="contrastScheme" id="contrastInvert" value="invert">
                                        <label class="form-check-label" for="contrastInvert">
                                            <span class="contrast-preview contrast-invert">A</span> Invertido
                                        </label>
                                    </div>
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="radio" name="contrastScheme" id="contrastYellow" value="yellow">
                                        <label class="form-check-label" for="contrastYellow">
                                            <span class="contrast-preview contrast-yellow">A</span> Amarillo/Negro
                                        </label>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- SECCIÓN CORREGIDA: Modos de Daltonismo -->
                            <div class="mb-3">
                                <label class="form-label">
                                    Modo para Daltonismo
                                    <i class="fas fa-info-circle info-tooltip" data-bs-toggle="tooltip" title="Ajusta los colores para diferentes tipos de daltonismo. Estos filtros ayudan a distinguir colores que normalmente serían confusos."></i>
                                </label>
                                
                                <div class="colorblind-options">
                                    <div class="colorblind-option" data-type="normal">
                                        <div class="form-check">
                                            <input class="form-check-input" type="radio" name="colorblindMode" id="colorblindNormal" value="normal" checked>
                                            <label class="form-check-label" for="colorblindNormal">
                                                <span class="colorblind-preview contrast-normal">A</span> 
                                                <strong>Visión Normal</strong>
                                            </label>
                                        </div>
                                        <div class="colorblind-description">
                                            Sin ajustes para daltonismo
                                        </div>
                                    </div>
                                    
                                    <div class="colorblind-option" data-type="protanopia">
                                        <div class="form-check">
                                            <input class="form-check-input" type="radio" name="colorblindMode" id="colorblindProtanopia" value="protanopia">
                                            <label class="form-check-label" for="colorblindProtanopia">
                                                <span class="colorblind-preview protanopia">A</span> 
                                                <strong>Protanopia</strong>
                                            </label>
                                        </div>
                                        <div class="colorblind-description">
                                            Ceguera al rojo - Dificultad para distinguir rojos y verdes
                                        </div>
                                    </div>
                                    
                                    <div class="colorblind-option" data-type="deuteranopia">
                                        <div class="form-check">
                                            <input class="form-check-input" type="radio" name="colorblindMode" id="colorblindDeuteranopia" value="deuteranopia">
                                            <label class="form-check-label" for="colorblindDeuteranopia">
                                                <span class="colorblind-preview deuteranopia">A</span> 
                                                <strong>Deuteranopia</strong>
                                            </label>
                                        </div>
                                        <div class="colorblind-description">
                                            Ceguera al verde - Forma más común de daltonismo rojo-verde
                                        </div>
                                    </div>
                                    
                                    <div class="colorblind-option" data-type="tritanopia">
                                        <div class="form-check">
                                            <input class="form-check-input" type="radio" name="colorblindMode" id="colorblindTritanopia" value="tritanopia">
                                            <label class="form-check-label" for="colorblindTritanopia">
                                                <span class="colorblind-preview tritanopia">A</span> 
                                                <strong>Tritanopia</strong>
                                            </label>
                                        </div>
                                        <div class="colorblind-description">
                                            Ceguera al azul - Dificultad para distinguir azules y amarillos
                                        </div>
                                    </div>
                                    
                                    <div class="colorblind-option" data-type="achromatopsia">
                                        <div class="form-check">
                                            <input class="form-check-input" type="radio" name="colorblindMode" id="colorblindAchromatopsia" value="achromatopsia">
                                            <label class="form-check-label" for="colorblindAchromatopsia">
                                                <span class="colorblind-preview achromatopsia">A</span> 
                                                <strong>Acromatopsia</strong>
                                            </label>
                                        </div>
                                        <div class="colorblind-description">
                                            Visión en escala de grises - Incapacidad para percibir cualquier color
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="mb-3 form-check form-switch">
                                <input class="form-check-input" type="checkbox" id="reduceAnimations">
                                <label class="form-check-label" for="reduceAnimations">
                                    Reducir animaciones
                                    <i class="fas fa-info-circle info-tooltip" data-bs-toggle="tooltip" title="Elimina o reduce las animaciones y transiciones. Recomendado para personas con epilepsia fotosensible o que se distraen fácilmente."></i>
                                </label>
                            </div>
                            
                            <div class="mb-3 form-check form-switch">
                                <input class="form-check-input" type="checkbox" id="beigeBackground">
                                <label class="form-check-label" for="beigeBackground">
                                    Fondo beige para lectura
                                    <i class="fas fa-info-circle info-tooltip" data-bs-toggle="tooltip" title="Cambia el fondo a color beige suave para reducir el estrés visual durante la lectura prolongada."></i>
                                </label>
                            </div>
                        </div>
                        
                        <!-- Pestaña Navegación -->
                        <div class="tab-pane fade" id="navigation" role="tabpanel" aria-labelledby="navigation-tab">
                            <div class="mb-3 form-check form-switch">
                                <input class="form-check-input" type="checkbox" id="keyboardNavigation">
                                <label class="form-check-label" for="keyboardNavigation">
                                    Navegación exclusiva por teclado
                                    <i class="fas fa-info-circle info-tooltip" data-bs-toggle="tooltip" title="Permite navegar por todo el sistema usando solo el teclado. Ideal para personas con movilidad reducida."></i>
                                </label>
                            </div>
                            
                            <div class="mb-3 form-check form-switch">
                                <input class="form-check-input" type="checkbox" id="showShortcuts">
                                <label class="form-check-label" for="showShortcuts">
                                    Mostrar atajos de teclado en pantalla
                                    <i class="fas fa-info-circle info-tooltip" data-bs-toggle="tooltip" title="Muestra los atajos de teclado disponibles en cada pantalla para facilitar el acceso rápido."></i>
                                </label>
                            </div>
                            
                            <div class="mb-3 form-check form-switch">
                                <input class="form-check-input" type="checkbox" id="voiceControl">
                                <label class="form-check-label" for="voiceControl">
                                    Habilitar control por voz
                                    <i class="fas fa-info-circle info-tooltip" data-bs-toggle="tooltip" title="Activa el reconocimiento de voz para navegar y realizar acciones usando comandos de voz. Requiere micrófono."></i>
                                </label>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label">Comandos de voz disponibles:</label>
                                <div class="alert alert-info small">
                                    <strong>Navegación:</strong><br>
                                    • "Ir a [alumnos|profesores|cursos|grados|usuarios|dashboard]"<br>
                                    • "Abrir menú" - Mostrar menú principal<br>
                                    • "Cerrar sesión" - Salir del sistema<br><br>
                                    
                                    <strong>Accesibilidad:</strong><br>
                                    • "Activar modo [baja visión|daltonismo|dislexia|tdah|tea|movilidad]"<br>
                                    • "Aumentar texto" - Aumentar tamaño de fuente<br>
                                    • "Reducir texto" - Reducir tamaño de fuente<br>
                                    • "Activar [protanopia|deuteranopia|tritanopia|escala de grises]"<br>
                                    • "Salir modo enfoque" - Desactivar modo enfoque<br><br>
                                    
                                    <strong>General:</strong><br>
                                    • "Ayuda" - Mostrar ayuda<br>
                                    • "Leer página" - Leer contenido actual<br>
                                    • "Deshacer" - Deshacer última acción
                                </div>
                            </div>
                            
                            <div class="mb-3 form-check form-switch">
                                <input class="form-check-input" type="checkbox" id="extendedTouch">
                                <label class="form-check-label" for="extendedTouch">
                                    Áreas táctiles ampliadas
                                    <i class="fas fa-info-circle info-tooltip" data-bs-toggle="tooltip" title="Aumenta el tamaño de los botones y áreas clicables para facilitar la interacción táctil."></i>
                                </label>
                            </div>
                        </div>
                        
                        <!-- Pestaña Comportamiento -->
                        <div class="tab-pane fade" id="behavior" role="tabpanel" aria-labelledby="behavior-tab">
                            <div class="mb-3 form-check form-switch">
                                <input class="form-check-input" type="checkbox" id="focusMode">
                                <label class="form-check-label" for="focusMode">
                                    Modo enfoque (sin distracciones)
                                    <i class="fas fa-info-circle info-tooltip" data-bs-toggle="tooltip" title="Elimina elementos distractores de la interfaz para mejorar la concentración. Ideal para TDAH."></i>
                                </label>
                            </div>
                            
                            <div class="mb-3 form-check form-switch">
                                <input class="form-check-input" type="checkbox" id="sensoryReduction">
                                <label class="form-check-label" for="sensoryReduction">
                                    Reducción sensorial (sin sonidos ni popups)
                                    <i class="fas fa-info-circle info-tooltip" data-bs-toggle="tooltip" title="Desactiva sonidos, animaciones y ventanas emergentes. Recomendado para personas con TEA o sensibilidad sensorial."></i>
                                </label>
                            </div>
                            
                            <div class="mb-3 form-check form-switch">
                                <input class="form-check-input" type="checkbox" id="groupNotifications">
                                <label class="form-check-label" for="groupNotifications">
                                    Agrupar notificaciones
                                    <i class="fas fa-info-circle info-tooltip" data-bs-toggle="tooltip" title="Agrupa las notificaciones para mostrarlas en momentos específicos en lugar de interrumpir constantemente."></i>
                                </label>
                            </div>
                            
                            <div class="mb-3 form-check form-switch">
                                <input class="form-check-input" type="checkbox" id="undoFeature">
                                <label class="form-check-label" for="undoFeature">
                                    Habilitar función deshacer
                                    <i class="fas fa-info-circle info-tooltip" data-bs-toggle="tooltip" title="Muestra un botón para deshacer la última acción durante 10 segundos después de cada operación."></i>
                                </label>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label">
                                    Duración de sesión
                                    <i class="fas fa-info-circle info-tooltip" data-bs-toggle="tooltip" title="Configura el tiempo máximo de inactividad antes de cerrar sesión automáticamente."></i>
                                </label>
                                <select class="form-select" id="sessionDuration">
                                    <option value="30">30 minutos</option>
                                    <option value="60">1 hora</option>
                                    <option value="120">2 horas</option>
                                    <option value="0">Ilimitada</option>
                                </select>
                            </div>
                            
                            <div class="mb-3 form-check form-switch">
                                <input class="form-check-input" type="checkbox" id="autoSave">
                                <label class="form-check-label" for="autoSave">
                                    Guardado automático cada 30 segundos
                                    <i class="fas fa-info-circle info-tooltip" data-bs-toggle="tooltip" title="Guarda automáticamente el trabajo cada 30 segundos para prevenir pérdida de información."></i>
                                </label>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" id="resetAccessibility">Restablecer</button>
                    <button type="button" class="btn btn-primary" id="saveAccessibility">Guardar configuración</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Indicador de reconocimiento de voz MEJORADO -->
    <div class="voice-indicator" id="voiceIndicator" title="Haz clic para detener el reconocimiento de voz">
        <i class="fas fa-microphone fa-lg"></i>
        <div class="voice-status" id="voiceStatus">Listo</div>
    </div>

    <script>
        // Sistema de reconocimiento de voz SIMPLIFICADO Y MEJORADO
        class VoiceControlSystem {
            constructor() {
                this.recognition = null;
                this.isListening = false;
                this.isProcessing = false;
                this.lastAction = null;
                this.commands = {
                    // Navegación por menú
                    'ir a alumnos': () => this.navigateTo('AlumnoServlet'),
                    'ir a profesores': () => this.navigateTo('ProfesorServlet'),
                    'ir a cursos': () => this.navigateTo('CursoServlet'),
                    'ir a grados': () => this.navigateTo('GradoServlet'),
                    'ir a usuarios': () => this.navigateTo('UsuarioServlet'),
                    'ir a dashboard': () => this.navigateTo('dashboard.jsp'),
                    'ir a tareas': () => this.navigateTo('TareaServlet'),
                    'ir a notas': () => this.navigateTo('NotaServlet'),
                    'ir a ver alumnos': () => this.navigateTo('VerAlumnosServlet'),
                    
                    // Acciones de sistema
                    'abrir menú': () => this.toggleMenu(),
                    'cerrar sesión': () => this.logout(),
                    'ayuda': () => this.showHelp(),
                    'leer página': () => this.readPage(),
                    'deshacer': () => this.undoLastAction(),
                    
                    // Perfiles de accesibilidad
                    'activar baja visión': () => this.applyProfile('baja-vision'),
                    'activar daltonismo': () => this.applyProfile('daltonismo'),
                    'activar dislexia': () => this.applyProfile('dislexia'),
                    'activar tdah': () => this.applyProfile('tdah'),
                    'activar tea': () => this.applyProfile('tea'),
                    'activar movilidad': () => this.applyProfile('movilidad'),
                    
                    // Configuraciones visuales
                    'aumentar texto': () => this.increaseTextSize(),
                    'reducir texto': () => this.decreaseTextSize(),
                    'activar protanopia': () => this.setColorblindMode('protanopia'),
                    'activar deuteranopia': () => this.setColorblindMode('deuteranopia'),
                    'activar tritanopia': () => this.setColorblindMode('tritanopia'),
                    'activar escala de grises': () => this.setColorblindMode('achromatopsia'),
                    'desactivar daltonismo': () => this.setColorblindMode('normal'),
                    
                    // Modos de comportamiento
                    'activar modo enfoque': () => this.toggleFocusMode(),
                    'salir modo enfoque': () => this.disableFocusMode(),
                    'desactivar modo enfoque': () => this.disableFocusMode(),
                    'activar reducción sensorial': () => this.toggleSensoryReduction(),
                    'desactivar reducción sensorial': () => this.toggleSensoryReduction()
                };
                
                this.init();
            }
            
            init() {
                if ('webkitSpeechRecognition' in window || 'SpeechRecognition' in window) {
                    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
                    this.recognition = new SpeechRecognition();
                    
                    // CONFIGURACIÓN SIMPLIFICADA - Una sola escucha por click
                    this.recognition.continuous = false;
                    this.recognition.interimResults = false;
                    this.recognition.lang = 'es-ES';
                    this.recognition.maxAlternatives = 1;
                    
                    this.recognition.onstart = () => {
                        console.log('Reconocimiento de voz iniciado');
                        this.isListening = true;
                        this.updateVoiceIndicator('listening', 'Escuchando...');
                        this.showVoiceNotification('Escuchando... Habla ahora');
                    };
                    
                    this.recognition.onresult = (event) => {
                        this.isProcessing = true;
                        this.updateVoiceIndicator('processing', 'Procesando...');
                        
                        const transcript = event.results[0][0].transcript.toLowerCase().trim();
                        console.log('Comando detectado:', transcript);
                        
                        this.showVoiceNotification(`Comando: "${transcript}"`);
                        this.processCommand(transcript);
                        
                        // Detener automáticamente después de procesar
                        setTimeout(() => {
                            this.stopListening();
                        }, 1000);
                    };
                    
                    this.recognition.onerror = (event) => {
                        console.error('Error en reconocimiento de voz:', event.error);
                        this.showVoiceNotification('Error: ' + event.error);
                        this.stopListening();
                    };
                    
                    this.recognition.onend = () => {
                        console.log('Reconocimiento de voz finalizado');
                        if (this.isListening && !this.isProcessing) {
                            this.showVoiceNotification('No se detectó comando. Haz clic para intentar nuevamente.');
                        }
                        this.stopListening();
                    };
                } else {
                    console.warn('El reconocimiento de voz no es compatible con este navegador');
                    this.showVoiceNotification('El reconocimiento de voz no es compatible con tu navegador');
                }
            }
            
            startListening() {
                if (!this.recognition) {
                    this.showVoiceNotification('El reconocimiento de voz no está disponible');
                    return;
                }
                
                if (this.isListening) {
                    this.stopListening();
                    return;
                }
                
                try {
                    this.recognition.start();
                } catch (error) {
                    console.error('Error al iniciar reconocimiento de voz:', error);
                    this.showVoiceNotification('Error al acceder al micrófono. Verifica los permisos.');
                }
            }
            
            stopListening() {
                this.isListening = false;
                this.isProcessing = false;
                
                if (this.recognition) {
                    try {
                        this.recognition.stop();
                    } catch (error) {
                        // Ignorar errores al detener
                    }
                }
                
                this.updateVoiceIndicator('ready', 'Listo');
            }
            
            processCommand(transcript) {
                let commandExecuted = false;
                
                // Buscar comando exacto primero
                for (const [command, action] of Object.entries(this.commands)) {
                    if (transcript === command) {
                        this.showVoiceNotification(`Ejecutando: ${command}`);
                        action();
                        commandExecuted = true;
                        break;
                    }
                }
                
                // Si no se encontró comando exacto, buscar coincidencias parciales
                if (!commandExecuted) {
                    for (const [command, action] of Object.entries(this.commands)) {
                        if (transcript.includes(command)) {
                            this.showVoiceNotification(`Ejecutando: ${command}`);
                            action();
                            commandExecuted = true;
                            break;
                        }
                    }
                }
                
                if (!commandExecuted) {
                    this.showVoiceNotification('Comando no reconocido. Di "ayuda" para ver opciones.');
                }
            }
            
            navigateTo(page) {
                this.lastAction = { type: 'navigation', from: window.location.href };
                window.location.href = page;
            }
            
            toggleMenu() {
                const navbarToggler = document.querySelector('.navbar-toggler');
                if (navbarToggler) {
                    navbarToggler.click();
                    this.showVoiceNotification('Menú abierto');
                }
            }
            
            logout() {
                this.showVoiceNotification('Cerrando sesión...');
                setTimeout(() => {
                    window.location.href = 'LogoutServlet';
                }, 1000);
            }
            
            showHelp() {
                const commandsList = Object.keys(this.commands).join('\n• ');
                this.showVoiceNotification('Mostrando ayuda...');
                setTimeout(() => {
                    alert(`Comandos de voz disponibles:\n\n• ${commandsList}`);
                }, 500);
            }
            
            readPage() {
                const mainContent = document.querySelector('h1, h2, .container') || document.body;
                const text = mainContent.innerText || mainContent.textContent;
                this.speak(text.substring(0, 200) + '...');
                this.showVoiceNotification('Leyendo contenido de la página...');
            }
            
            undoLastAction() {
                if (this.lastAction && this.lastAction.type === 'navigation') {
                    this.showVoiceNotification('Deshaciendo última acción...');
                    setTimeout(() => {
                        window.location.href = this.lastAction.from;
                    }, 1000);
                } else {
                    this.showVoiceMessage('No hay acción para deshacer');
                }
            }
            
            applyProfile(profile) {
                const profiles = {
                    'baja-vision': {
                        fontSize: '24',
                        fontType: 'default',
                        contrastScheme: 'invert',
                        reduceAnimations: true,
                        beigeBackground: false
                    },
                    'daltonismo': {
                        fontSize: '18',
                        fontType: 'default', 
                        contrastScheme: 'normal',
                        colorblindMode: 'deuteranopia',
                        reduceAnimations: false
                    },
                    'dislexia': {
                        fontSize: '20',
                        fontType: 'opendyslexic',
                        contrastScheme: 'normal',
                        beigeBackground: true,
                        reduceAnimations: true
                    },
                    'tdah': {
                        fontSize: '18',
                        fontType: 'default',
                        contrastScheme: 'normal', 
                        focusMode: true,
                        groupNotifications: true,
                        reduceAnimations: true
                    },
                    'tea': {
                        fontSize: '18',
                        fontType: 'default',
                        contrastScheme: 'normal',
                        sensoryReduction: true,
                        reduceAnimations: true,
                        groupNotifications: true
                    },
                    'movilidad': {
                        fontSize: '20',
                        fontType: 'default',
                        contrastScheme: 'normal',
                        keyboardNavigation: true,
                        voiceControl: true,
                        extendedTouch: true
                    }
                };
                
                if (profiles[profile]) {
                    const settings = { ...profiles[profile] };
                    localStorage.setItem('accessibilitySettings', JSON.stringify(settings));
                    applyAccessibilitySettings(settings);
                    this.showVoiceNotification(`Perfil ${profile} aplicado correctamente`);
                }
            }
            
            increaseTextSize() {
                const currentSize = parseInt(localStorage.getItem('accessibilitySettings') ? JSON.parse(localStorage.getItem('accessibilitySettings')).fontSize : 16);
                const newSize = Math.min(currentSize + 2, 28);
                this.updateFontSize(newSize);
                this.showVoiceNotification(`Tamaño de texto aumentado a ${newSize}px`);
            }
            
            decreaseTextSize() {
                const currentSize = parseInt(localStorage.getItem('accessibilitySettings') ? JSON.parse(localStorage.getItem('accessibilitySettings')).fontSize : 16);
                const newSize = Math.max(currentSize - 2, 16);
                this.updateFontSize(newSize);
                this.showVoiceNotification(`Tamaño de texto reducido a ${newSize}px`);
            }
            
            updateFontSize(size) {
                const settings = JSON.parse(localStorage.getItem('accessibilitySettings')) || {};
                settings.fontSize = size;
                localStorage.setItem('accessibilitySettings', JSON.stringify(settings));
                applyAccessibilitySettings(settings);
            }
            
            setColorblindMode(mode) {
                const settings = JSON.parse(localStorage.getItem('accessibilitySettings')) || {};
                settings.colorblindMode = mode;
                localStorage.setItem('accessibilitySettings', JSON.stringify(settings));
                applyAccessibilitySettings(settings);
                this.showVoiceNotification(`Modo ${mode} activado`);
            }
            
            toggleFocusMode() {
                const settings = JSON.parse(localStorage.getItem('accessibilitySettings')) || {};
                settings.focusMode = !settings.focusMode;
                localStorage.setItem('accessibilitySettings', JSON.stringify(settings));
                applyAccessibilitySettings(settings);
                this.showVoiceNotification(`Modo enfoque ${settings.focusMode ? 'activado' : 'desactivado'}`);
            }
            
            disableFocusMode() {
                const settings = JSON.parse(localStorage.getItem('accessibilitySettings')) || {};
                settings.focusMode = false;
                localStorage.setItem('accessibilitySettings', JSON.stringify(settings));
                applyAccessibilitySettings(settings);
                this.showVoiceNotification('Modo enfoque desactivado');
            }
            
            toggleSensoryReduction() {
                const settings = JSON.parse(localStorage.getItem('accessibilitySettings')) || {};
                settings.sensoryReduction = !settings.sensoryReduction;
                localStorage.setItem('accessibilitySettings', JSON.stringify(settings));
                applyAccessibilitySettings(settings);
                this.showVoiceNotification(`Reducción sensorial ${settings.sensoryReduction ? 'activada' : 'desactivada'}`);
            }
            
            speak(text) {
                if ('speechSynthesis' in window) {
                    const utterance = new SpeechSynthesisUtterance(text);
                    utterance.lang = 'es-ES';
                    utterance.rate = 1.0;
                    utterance.pitch = 1.0;
                    speechSynthesis.speak(utterance);
                }
            }
            
            showVoiceNotification(message) {
                const notification = document.getElementById('voiceNotification');
                if (notification) {
                    notification.textContent = message;
                    notification.classList.add('show');
                    
                    setTimeout(() => {
                        notification.classList.remove('show');
                    }, 3000);
                }
            }
            
            updateVoiceIndicator(state, status) {
                const indicator = document.getElementById('voiceIndicator');
                const statusElement = document.getElementById('voiceStatus');
                
                if (indicator && statusElement) {
                    // Remover todas las clases de estado
                    indicator.classList.remove('listening', 'processing', 'ready');
                    
                    // Aplicar nueva clase de estado
                    if (state === 'listening') {
                        indicator.classList.add('listening');
                        indicator.style.display = 'flex';
                    } else if (state === 'processing') {
                        indicator.classList.add('processing');
                    } else {
                        indicator.classList.add('ready');
                        // Ocultar después de un tiempo si está listo
                        setTimeout(() => {
                            if (!this.isListening && !this.isProcessing) {
                                indicator.style.display = 'none';
                            }
                        }, 2000);
                    }
                    
                    statusElement.textContent = status;
                }
            }
        }

        // Inicializar sistema de voz
        let voiceSystem = null;

        // FUNCIÓN CORREGIDA PARA APLICAR CONFIGURACIÓN
        function applyAccessibilitySettings(settings) {
            try {
                console.log('Aplicando configuración:', settings);
                
                // Remover TODAS las clases de accesibilidad
                const classesToRemove = [
                    'large-text', 'larger-text', 'largest-text',
                    'high-contrast-invert', 'high-contrast-yellow',
                    'beige-background', 'reduce-motion', 'dyslexia-font',
                    'colorblind-protanopia', 'colorblind-deuteranopia',
                    'colorblind-tritanopia', 'colorblind-achromatopsia',
                    'colorblind-protanopia-alt', 'colorblind-deuteranopia-alt', 'colorblind-tritanopia-alt',
                    'focus-mode', 'sensory-reduction'
                ];
                
                classesToRemove.forEach(className => {
                    document.body.classList.remove(className);
                });
                
                // Resetear estilos inline
                document.body.style.filter = '';
                document.body.style.fontFamily = '';
                document.body.style.fontSize = '';
                document.body.style.lineHeight = '';
                document.body.style.letterSpacing = '';
                document.documentElement.style.fontSize = '';

                // 1. Aplicar tamaño de fuente
                if (settings.fontSize) {
                    const fontSize = parseInt(settings.fontSize);
                    console.log('Aplicando tamaño de fuente:', fontSize);
                    
                    if (fontSize >= 20 && fontSize < 24) {
                        document.body.classList.add('large-text');
                    } else if (fontSize >= 24 && fontSize < 28) {
                        document.body.classList.add('larger-text');
                    } else if (fontSize >= 28) {
                        document.body.classList.add('largest-text');
                    }
                }

                // 2. Aplicar tipo de fuente - CORREGIDO
                if (settings.fontType === 'opendyslexic') {
                    console.log('Aplicando fuente para dislexia');
                    document.body.classList.add('dyslexia-font');
                } else {
                    document.body.style.fontFamily = '';
                }

                // 3. Aplicar esquema de contraste
                if (settings.contrastScheme === 'invert') {
                    document.body.classList.add('high-contrast-invert');
                } else if (settings.contrastScheme === 'yellow') {
                    document.body.classList.add('high-contrast-yellow');
                }

                // 4. APLICAR MODO DALTONISMO - CORREGIDO
                if (settings.colorblindMode && settings.colorblindMode !== 'normal') {
                    console.log('Aplicando modo daltonismo:', settings.colorblindMode);
                    
                    // Aplicar la clase principal - CORREGIDO
                    document.body.classList.add('colorblind-' + settings.colorblindMode);
                    
                    // Para navegadores problemáticos, aplicar también la versión alternativa
                    if (settings.colorblindMode !== 'achromatopsia') {
                        document.body.classList.add('colorblind-' + settings.colorblindMode + '-alt');
                    }
                    
                    // Forzar reflow para asegurar la aplicación
                    void document.body.offsetHeight;
                }

                // 5. Aplicar fondo beige
                if (settings.beigeBackground) {
                    document.body.classList.add('beige-background');
                }

                // 6. Aplicar reducción de animaciones
                if (settings.reduceAnimations) {
                    document.body.classList.add('reduce-motion');
                }

                // 7. Aplicar modo enfoque - VERSIÓN MEJORADA
                if (settings.focusMode) {
                    document.body.classList.add('focus-mode', 'active');
                    
                    // Asegurar que el contenido principal esté marcado
                    setTimeout(() => {
                        const mainContent = document.querySelector('.container, main, .content') || 
                                           document.querySelector('body > *:not(.navbar):not(footer):not(.exit-focus-btn)');
                        
                        if (mainContent && !mainContent.classList.contains('focus-content')) {
                            mainContent.classList.add('focus-content');
                        }
                    }, 100);
                } else {
                    document.body.classList.remove('focus-mode', 'active');
                    
                    // Remover clases de contenido de enfoque
                    document.querySelectorAll('.focus-content').forEach(el => {
                        el.classList.remove('focus-content');
                    });
                }

                // 8. Aplicar reducción sensorial
                if (settings.sensoryReduction) {
                    document.body.classList.add('sensory-reduction');
                }

                // 9. Control por voz
                if (settings.voiceControl) {
                    if (!voiceSystem) {
                        voiceSystem = new VoiceControlSystem();
                    }
                    // No iniciar automáticamente, solo preparar el sistema
                } else if (voiceSystem) {
                    voiceSystem.stopListening();
                }

                console.log('Clases actuales del body:', document.body.className);

            } catch (error) {
                console.error('Error al aplicar configuración:', error);
            }
        }

        // Sistema mejorado para modo enfoque
        function setupEnhancedFocusMode() {
            const exitButton = document.getElementById('exitFocusMode');
            const focusModeCheckbox = document.getElementById('focusMode');
            
            // Función para desactivar modo enfoque
            function disableFocusMode() {
                if (focusModeCheckbox) {
                    focusModeCheckbox.checked = false;
                }
                
                const settings = JSON.parse(localStorage.getItem('accessibilitySettings')) || {};
                settings.focusMode = false;
                localStorage.setItem('accessibilitySettings', JSON.stringify(settings));
                applyAccessibilitySettings(settings);
            }
            
            // Evento para el botón de salida
            if (exitButton) {
                exitButton.addEventListener('click', disableFocusMode);
            }
            
            // Salir con tecla Escape
            document.addEventListener('keydown', function(e) {
                if (e.key === 'Escape' && document.body.classList.contains('focus-mode') && 
                    document.body.classList.contains('active')) {
                    disableFocusMode();
                }
            });
            
            // Comando de voz para salir
            if (voiceSystem) {
                voiceSystem.commands['salir modo enfoque'] = disableFocusMode;
                voiceSystem.commands['desactivar modo enfoque'] = disableFocusMode;
            }
            
            // Asegurar que el contenido principal tenga la clase focus-content
            function markMainContent() {
                const mainContent = document.querySelector('.container, main, .content') || 
                                   document.querySelector('body > *:not(.navbar):not(footer):not(.exit-focus-btn)');
                
                if (mainContent && !mainContent.classList.contains('focus-content')) {
                    mainContent.classList.add('focus-content');
                }
            }
            
            // Observar cambios en el DOM
            const observer = new MutationObserver(function(mutations) {
                let shouldMarkContent = false;
                
                mutations.forEach(function(mutation) {
                    if (mutation.type === 'childList') {
                        shouldMarkContent = true;
                    }
                    if (mutation.attributeName === 'class' && mutation.target === document.body) {
                        if (document.body.classList.contains('focus-mode') && 
                            document.body.classList.contains('active')) {
                            markMainContent();
                        }
                    }
                });
                
                if (shouldMarkContent) {
                    setTimeout(markMainContent, 100);
                }
            });
            
            observer.observe(document.body, { 
                childList: true, 
                subtree: true,
                attributes: true,
                attributeFilter: ['class']
            });
            
            // Marcar contenido inicial
            markMainContent();
        }

        // Función para cargar configuración desde localStorage - CORREGIDA
        function loadAccessibilitySettings() {
            try {
                const settings = JSON.parse(localStorage.getItem('accessibilitySettings')) || {};
                console.log('Cargando configuración:', settings);
                
                // Configuración Visual - Solo elementos que existen
                const fontSizeElement = document.getElementById('fontSize');
                const currentFontSizeElement = document.getElementById('currentFontSize');
                if (settings.fontSize && fontSizeElement && currentFontSizeElement) {
                    fontSizeElement.value = settings.fontSize;
                    currentFontSizeElement.textContent = settings.fontSize + 'px';
                }
                
                const fontTypeElement = document.getElementById('fontType');
                if (settings.fontType && fontTypeElement) {
                    fontTypeElement.value = settings.fontType;
                }
                
                if (settings.contrastScheme) {
                    const radio = document.querySelector('input[name="contrastScheme"][value="' + settings.contrastScheme + '"]');
                    if (radio) radio.checked = true;
                }
                
                // Configuración Daltonismo
                if (settings.colorblindMode) {
                    const radio = document.querySelector('input[name="colorblindMode"][value="' + settings.colorblindMode + '"]');
                    if (radio) {
                        radio.checked = true;
                        
                        // Actualizar UI visual
                        document.querySelectorAll('.colorblind-option').forEach(option => {
                            option.classList.remove('selected');
                        });
                        const selectedOption = document.querySelector('.colorblind-option[data-type="' + settings.colorblindMode + '"]');
                        if (selectedOption) {
                            selectedOption.classList.add('selected');
                        }
                    }
                }
                
                // Solo configurar elementos que existen
                const reduceAnimationsElement = document.getElementById('reduceAnimations');
                if (reduceAnimationsElement && settings.reduceAnimations !== undefined) {
                    reduceAnimationsElement.checked = settings.reduceAnimations;
                }
                
                const beigeBackgroundElement = document.getElementById('beigeBackground');
                if (beigeBackgroundElement && settings.beigeBackground !== undefined) {
                    beigeBackgroundElement.checked = settings.beigeBackground;
                }
                
                const keyboardNavigationElement = document.getElementById('keyboardNavigation');
                if (keyboardNavigationElement && settings.keyboardNavigation !== undefined) {
                    keyboardNavigationElement.checked = settings.keyboardNavigation;
                }
                
                const voiceControlElement = document.getElementById('voiceControl');
                if (voiceControlElement && settings.voiceControl !== undefined) {
                    voiceControlElement.checked = settings.voiceControl;
                }
                
                const focusModeElement = document.getElementById('focusMode');
                if (focusModeElement && settings.focusMode !== undefined) {
                    focusModeElement.checked = settings.focusMode;
                }
                
                const sensoryReductionElement = document.getElementById('sensoryReduction');
                if (sensoryReductionElement && settings.sensoryReduction !== undefined) {
                    sensoryReductionElement.checked = settings.sensoryReduction;
                }
                
                // Aplicar configuración cargada
                applyAccessibilitySettings(settings);
            } catch (error) {
                console.error('Error al cargar configuración:', error);
            }
        }
        
        // Función para guardar configuración en localStorage - CORREGIDA
        function saveAccessibilitySettings() {
            try {
                // Obtener valores del formulario
                const fontSize = document.getElementById('fontSize').value;
                const fontType = document.getElementById('fontType').value;
                
                const contrastSchemeElement = document.querySelector('input[name="contrastScheme"]:checked');
                const contrastScheme = contrastSchemeElement ? contrastSchemeElement.value : 'normal';
                
                const colorblindModeElement = document.querySelector('input[name="colorblindMode"]:checked');
                const colorblindMode = colorblindModeElement ? colorblindModeElement.value : 'normal';
                
                const reduceAnimations = document.getElementById('reduceAnimations').checked;
                const beigeBackground = document.getElementById('beigeBackground').checked;
                const keyboardNavigation = document.getElementById('keyboardNavigation').checked;
                const voiceControl = document.getElementById('voiceControl').checked;
                const focusMode = document.getElementById('focusMode').checked;
                const sensoryReduction = document.getElementById('sensoryReduction').checked;
                const groupNotifications = document.getElementById('groupNotifications').checked;
                const undoFeature = document.getElementById('undoFeature').checked;
                
                const settings = {
                    // Visual
                    fontSize: fontSize,
                    fontType: fontType,
                    contrastScheme: contrastScheme,
                    colorblindMode: colorblindMode,
                    reduceAnimations: reduceAnimations,
                    beigeBackground: beigeBackground,
                    
                    // Navegación
                    keyboardNavigation: keyboardNavigation,
                    voiceControl: voiceControl,
                    
                    // Comportamiento
                    focusMode: focusMode,
                    sensoryReduction: sensoryReduction,
                    groupNotifications: groupNotifications,
                    undoFeature: undoFeature
                };
                
                console.log('Guardando configuración:', settings);
                localStorage.setItem('accessibilitySettings', JSON.stringify(settings));
                
                // Aplicar configuración inmediatamente
                applyAccessibilitySettings(settings);
                
                // Cerrar modal después de guardar
                const modal = bootstrap.Modal.getInstance(document.getElementById('accessibilityModal'));
                if (modal) {
                    modal.hide();
                }
                
                // Mostrar mensaje de confirmación
                setTimeout(() => {
                    alert('Configuración de accesibilidad guardada correctamente.');
                }, 300);
                
            } catch (error) {
                console.error('Error al guardar configuración:', error);
                alert('Error al guardar la configuración. Por favor, intenta nuevamente.');
            }
        }
        
        // Función para restablecer configuración - CORREGIDA
        function resetAccessibilitySettings() {
            if (confirm('¿Estás seguro de que deseas restablecer toda la configuración de accesibilidad?')) {
                try {
                    localStorage.removeItem('accessibilitySettings');
                    
                    // Restablecer valores por defecto en el formulario
                    document.getElementById('fontSize').value = 16;
                    document.getElementById('currentFontSize').textContent = '16px';
                    document.getElementById('fontType').value = 'default';
                    
                    // Restablecer radios
                    document.getElementById('contrastNormal').checked = true;
                    document.getElementById('colorblindNormal').checked = true;
                    
                    // Restablecer checkboxes
                    const reduceAnimationsElement = document.getElementById('reduceAnimations');
                    if (reduceAnimationsElement) reduceAnimationsElement.checked = false;
                    
                    const beigeBackgroundElement = document.getElementById('beigeBackground');
                    if (beigeBackgroundElement) beigeBackgroundElement.checked = false;
                    
                    const keyboardNavigationElement = document.getElementById('keyboardNavigation');
                    if (keyboardNavigationElement) keyboardNavigationElement.checked = false;
                    
                    const voiceControlElement = document.getElementById('voiceControl');
                    if (voiceControlElement) voiceControlElement.checked = false;
                    
                    const focusModeElement = document.getElementById('focusMode');
                    if (focusModeElement) focusModeElement.checked = false;
                    
                    const sensoryReductionElement = document.getElementById('sensoryReduction');
                    if (sensoryReductionElement) sensoryReductionElement.checked = false;
                    
                    // Actualizar UI visual para daltonismo
                    document.querySelectorAll('.colorblind-option').forEach(option => {
                        option.classList.remove('selected');
                    });
                    const normalOption = document.querySelector('.colorblind-option[data-type="normal"]');
                    if (normalOption) normalOption.classList.add('selected');
                    
                    // Aplicar valores por defecto
                    applyAccessibilitySettings({});
                    
                    // Detener reconocimiento de voz si estaba activo
                    if (voiceSystem) {
                        voiceSystem.stopListening();
                    }
                    
                    alert('Configuración restablecida correctamente.');
                    
                } catch (error) {
                    console.error('Error al restablecer configuración:', error);
                    alert('Error al restablecer la configuración.');
                }
            }
        }
        
        // Inicializar cuando el DOM esté listo
        document.addEventListener('DOMContentLoaded', function() {
            console.log('Inicializando sistema de accesibilidad...');
            
            // Inicializar tooltips de Bootstrap
            const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
            const tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
                return new bootstrap.Tooltip(tooltipTriggerEl);
            });
            
            // Configurar interacción para opciones de daltonismo
            document.querySelectorAll('.colorblind-option').forEach(option => {
                option.addEventListener('click', function() {
                    const radio = this.querySelector('input[type="radio"]');
                    if (radio) {
                        radio.checked = true;
                        
                        // Actualizar UI visual
                        document.querySelectorAll('.colorblind-option').forEach(opt => {
                            opt.classList.remove('selected');
                        });
                        this.classList.add('selected');
                    }
                });
            });
            
            // Configurar interacción para perfiles predefinidos
            document.querySelectorAll('.profile-option').forEach(option => {
                option.addEventListener('click', function() {
                    const radio = this.querySelector('input[type="radio"]');
                    if (radio) {
                        radio.checked = true;
                        
                        // Aplicar perfil automáticamente
                        const profile = this.dataset.profile;
                        const profiles = {
                            'baja-vision': {
                                fontSize: '24',
                                fontType: 'default',
                                contrastScheme: 'invert',
                                reduceAnimations: true
                            },
                            'daltonismo': {
                                fontSize: '18',
                                colorblindMode: 'deuteranopia'
                            },
                            'dislexia': {
                                fontSize: '20',
                                fontType: 'opendyslexic',
                                beigeBackground: true
                            },
                            'tdah': {
                                focusMode: true,
                                groupNotifications: true
                            },
                            'tea': {
                                sensoryReduction: true,
                                reduceAnimations: true
                            },
                            'movilidad': {
                                keyboardNavigation: true,
                                voiceControl: true
                            }
                        };
                        
                        if (profiles[profile]) {
                            const currentSettings = JSON.parse(localStorage.getItem('accessibilitySettings')) || {};
                            const newSettings = { ...currentSettings, ...profiles[profile] };
                            localStorage.setItem('accessibilitySettings', JSON.stringify(newSettings));
                            applyAccessibilitySettings(newSettings);
                            
                            // Actualizar formulario
                            Object.keys(profiles[profile]).forEach(key => {
                                if (key === 'fontSize') {
                                    document.getElementById('fontSize').value = profiles[profile][key];
                                    document.getElementById('currentFontSize').textContent = profiles[profile][key] + 'px';
                                } else if (key === 'fontType') {
                                    document.getElementById('fontType').value = profiles[profile][key];
                                } else if (key === 'contrastScheme') {
                                    document.getElementById('contrast' + profiles[profile][key].charAt(0).toUpperCase() + profiles[profile][key].slice(1)).checked = true;
                                } else if (key === 'colorblindMode') {
                                    document.querySelector('input[name="colorblindMode"][value="' + profiles[profile][key] + '"]').checked = true;
                                } else {
                                    const element = document.getElementById(key);
                                    if (element) element.checked = true;
                                }
                            });
                            
                            alert('Perfil ' + profile + ' aplicado correctamente');
                        }
                    }
                });
            });
            
            // Configurar sistema de modo enfoque mejorado
            setupEnhancedFocusMode();
            
            // Cargar configuración al iniciar
            loadAccessibilitySettings();
            
            // Configurar evento para el botón de accesibilidad
            const accessibilityToggle = document.getElementById('accessibilityToggle');
            if (accessibilityToggle) {
                accessibilityToggle.addEventListener('click', function() {
                    console.log('Abriendo modal de accesibilidad...');
                    const modalElement = document.getElementById('accessibilityModal');
                    if (modalElement) {
                        const modal = new bootstrap.Modal(modalElement);
                        modal.show();
                    }
                });
            }
            
            // CONFIGURACIÓN MEJORADA DEL BOTÓN DE VOZ
            const voiceControlToggle = document.getElementById('voiceControlToggle');
            if (voiceControlToggle) {
                // Inicializar sistema de voz
                if (!voiceSystem) {
                    voiceSystem = new VoiceControlSystem();
                }
                
                voiceControlToggle.addEventListener('click', function() {
                    if (!voiceSystem) {
                        voiceSystem = new VoiceControlSystem();
                    }
                    
                    // Alternar estado de escucha
                    if (voiceSystem.isListening) {
                        // Si ya está escuchando, detener
                        voiceSystem.stopListening();
                        this.classList.remove('active');
                        this.title = "Activar control por voz - Click para empezar a escuchar";
                    } else {
                        // Si no está escuchando, iniciar
                        voiceSystem.startListening();
                        this.classList.add('active');
                        this.title = "Click para detener la escucha";
                    }
                });
            }
            
            // Configurar indicador de voz para detener escucha
            const voiceIndicator = document.getElementById('voiceIndicator');
            if (voiceIndicator) {
                voiceIndicator.addEventListener('click', function() {
                    if (voiceSystem) {
                        voiceSystem.stopListening();
                        const voiceToggle = document.getElementById('voiceControlToggle');
                        if (voiceToggle) {
                            voiceToggle.classList.remove('active');
                            voiceToggle.title = "Activar control por voz - Click para empezar a escuchar";
                        }
                    }
                });
            }
            
            // Actualizar valor de tamaño de fuente en tiempo real
            const fontSizeSlider = document.getElementById('fontSize');
            if (fontSizeSlider) {
                fontSizeSlider.addEventListener('input', function() {
                    const currentSizeElement = document.getElementById('currentFontSize');
                    if (currentSizeElement) {
                        currentSizeElement.textContent = this.value + 'px';
                    }
                });
            }
            
            // Configurar botones de guardar y restablecer
            const saveButton = document.getElementById('saveAccessibility');
            if (saveButton) {
                saveButton.addEventListener('click', saveAccessibilitySettings);
            }
            
            const resetButton = document.getElementById('resetAccessibility');
            if (resetButton) {
                resetButton.addEventListener('click', resetAccessibilitySettings);
            }
            
            // Configurar botón de deshacer
            const undoButton = document.getElementById('undoButton');
            if (undoButton) {
                undoButton.addEventListener('click', function() {
                    if (voiceSystem && voiceSystem.lastAction) {
                        voiceSystem.undoLastAction();
                    }
                    this.classList.remove('show');
                });
            }
            
            // Simular función de deshacer para demostración
            document.addEventListener('click', function(e) {
                if (e.target.matches('a.btn, button.btn') && !e.target.matches('#undoButton, .btn-close')) {
                    const undoButton = document.getElementById('undoButton');
                    if (undoButton) {
                        undoButton.classList.add('show');
                        setTimeout(() => {
                            undoButton.classList.remove('show');
                        }, 10000);
                    }
                }
            });
            
            console.log('Sistema de accesibilidad inicializado correctamente');
        });
    </script>
</body>