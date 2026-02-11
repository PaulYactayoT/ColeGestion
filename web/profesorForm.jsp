<%@ page import="modelo.Profesor" %>
<%@ page import="modelo.Area" %>
<%@ page import="modelo.ProfesorNivelArea" %>
<%@ page import="java.util.List" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.time.LocalTime" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    Profesor p = (Profesor) request.getAttribute("profesor");
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
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= editar ? "Editar Profesor" : "Registrar Profesor" %> - San Antonio</title>
    
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Lexend:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
    <!-- Material Symbols -->
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
    
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    
    <script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        "primary": "#135bec",
                        "primary-dark": "#0d47a1",
                        "success": "#10b981",
                        "danger": "#ef4444",
                        "warning": "#f59e0b",
                        "info": "#3b82f6",
                        "background-light": "#f6f6f8",
                        "background-dark": "#101622",
                        "card-light": "#ffffff",
                        "card-dark": "#1a2233",
                        "border-light": "#e5e7eb",
                        "border-dark": "#374151",
                    },
                    fontFamily: {
                        "display": ["Lexend"]
                    },
                    borderRadius: {"DEFAULT": "0.25rem", "lg": "0.5rem", "xl": "0.75rem", "full": "9999px"},
                },
            },
        }
    </script>
    
    <style>
        body {
            font-family: 'Lexend', sans-serif;
        }
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
        
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
        
        /* Tamaños de texto */
        .large-text { font-size: 18px !important; }
        .large-text .form-label,
        .large-text .form-control,
        .large-text .form-select,
        .large-text .text-sm {
            font-size: 16px !important;
        }
        
        .larger-text { font-size: 20px !important; }
        .larger-text .form-label,
        .larger-text .form-control,
        .larger-text .form-select,
        .larger-text .text-sm {
            font-size: 18px !important;
        }
        
        .largest-text { font-size: 22px !important; }
        .largest-text .form-label,
        .largest-text .form-control,
        .largest-text .form-select,
        .largest-text .text-sm {
            font-size: 20px !important;
        }
        
        .dyslexia-font { 
            font-family: Arial !important; 
            font-size: 1.1em !important; 
            line-height: 1.6 !important; 
            letter-spacing: 0.5px !important; 
        }
        
        /* Accessibility panel */
        .accessibility-panel {
            transform: translateX(100%);
            transition: transform 0.3s ease;
        }
        .accessibility-panel.open {
            transform: translateX(0);
        }
        
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
        
        :focus {
            outline: 3px solid #135bec !important;
            outline-offset: 2px;
        }
        
        .input-group-icon {
            position: relative;
        }
        
        .input-group-icon i,
        .input-group-icon .material-symbols-outlined {
            position: absolute;
            left: 12px;
            top: 50%;
            transform: translateY(-50%);
            color: #6b7280;
            z-index: 10;
        }
        
        .input-group-icon .form-control,
        .input-group-icon .form-select {
            padding-left: 16px;
        }
        
        .required-field::after {
            content: " *";
            color: #ef4444;
            font-weight: bold;
        }
        
        /* Alertas */
        .alert-modern {
            border-radius: 0.5rem;
            padding: 1rem 1.25rem;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 1rem;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
            border-left: 4px solid;
        }
        
        .alert-danger {
            background: linear-gradient(135deg, #fee2e2, #fecaca);
            color: #991b1b;
            border-left-color: #ef4444;
        }
        
        .alert-success {
            background: linear-gradient(135deg, #d1fae5, #a7f3d0);
            color: #065f46;
            border-left-color: #10b981;
        }
        
        /* Sección de título */
        .section-title {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            font-size: 1.125rem;
            font-weight: 600;
            color: #135bec;
            margin-bottom: 1.5rem;
            padding-bottom: 0.75rem;
            border-bottom: 2px solid #e5e7eb;
        }
        
        .section-title i {
            font-size: 1.25rem;
        }
        
        .section-divider {
            border: 0;
            border-top: 2px solid #e5e7eb;
            margin: 2rem 0;
        }
        
        /* Botones modernos */
        .btn-modern {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.625rem 1.25rem;
            border-radius: 0.5rem;
            font-weight: 500;
            transition: all 0.2s;
            border: none;
            cursor: pointer;
            text-decoration: none;
        }
        
        .btn-primary-modern {
            background: linear-gradient(135deg, #135bec, #0d47a1);
            color: white;
        }
        
        .btn-primary-modern:hover {
            background: linear-gradient(135deg, #0d47a1, #135bec);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(19, 91, 236, 0.4);
        }
        
        .btn-success-modern {
            background: linear-gradient(135deg, #10b981, #059669);
            color: white;
        }
        
        .btn-success-modern:hover {
            background: linear-gradient(135deg, #059669, #10b981);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(16, 185, 129, 0.4);
        }
        
        .btn-secondary-modern {
            background: #6b7280;
            color: white;
        }
        
        .btn-secondary-modern:hover {
            background: #4b5563;
            transform: translateY(-2px);
        }
        
        .btn-danger-modern {
            background: linear-gradient(135deg, #ef4444, #dc2626);
            color: white;
        }
        
        .btn-danger-modern:hover {
            background: linear-gradient(135deg, #dc2626, #ef4444);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(239, 68, 68, 0.4);
        }
        
        /* Estilos para asignaciones múltiples */
        .asignacion-item {
            transition: all 0.3s ease;
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            border: 2px solid #dee2e6;
            border-radius: 0.75rem;
            padding: 1.25rem;
            margin-bottom: 1rem;
        }

        .asignacion-item:hover {
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            transform: translateY(-2px);
            border-color: #135bec;
        }

        .asignacion-principal {
            background: linear-gradient(135deg, #dbeafe 0%, #bfdbfe 100%);
            border-color: #3b82f6;
        }

        .asignacion-numero {
            font-size: 0.875rem;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        #asignaciones-container:empty::before {
            content: "? Haga clic en 'Agregar Nivel/Área' para comenzar";
            display: block;
            padding: 2rem;
            text-align: center;
            color: #6c757d;
            font-style: italic;
            border: 2px dashed #dee2e6;
            border-radius: 0.5rem;
            background: #f8f9fa;
        }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark transition-colors duration-200">
    <!-- Skip to content (Accesibilidad) -->
    <a href="#main-content" class="skip-to-content">Saltar al contenido principal</a>

    <div class="flex min-h-screen">
        <!-- Sidebar -->
        <aside class="w-64 bg-white dark:bg-card-dark border-r border-[#dbdfe6] dark:border-gray-700 shadow-lg">
            <div class="p-6">
                <div class="flex items-center gap-3 mb-8">
                    <div class="w-10 h-10 bg-primary rounded-lg flex items-center justify-center">
                        <i class="fas fa-school text-white text-xl"></i>
                    </div>
                    <span class="text-xl font-bold text-[#111318] dark:text-white">San Antonio</span>
                </div>
                
                <nav class="space-y-2">
                    <a href="dashboard.jsp" class="flex items-center gap-3 px-4 py-3 text-gray-600 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg transition-colors">
                        <i class="fas fa-home w-5"></i>
                        <span>Dashboard</span>
                    </a>
                    <a href="ProfesorServlet" class="flex items-center gap-3 px-4 py-3 bg-primary text-white rounded-lg">
                        <i class="fas fa-chalkboard-teacher w-5"></i>
                        <span>Profesores</span>
                    </a>
                    <a href="EstudianteServlet" class="flex items-center gap-3 px-4 py-3 text-gray-600 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg transition-colors">
                        <i class="fas fa-user-graduate w-5"></i>
                        <span>Estudiantes</span>
                    </a>
                </nav>
            </div>
        </aside>

        <!-- Main Content -->
        <main id="main-content" class="flex-1">
            <!-- Header -->
            <header class="bg-white dark:bg-card-dark border-b border-[#dbdfe6] dark:border-gray-700 p-4 shadow-sm">
                <div class="flex items-center justify-between">
                    <h1 class="text-2xl font-bold text-[#111318] dark:text-white">
                        <i class="fas <%= editar ? "fa-edit" : "fa-user-plus" %> text-primary mr-2"></i>
                        <%= editar ? "Editar Profesor" : "Registrar Nuevo Profesor" %>
                    </h1>
                    
                    <div class="flex items-center gap-4">
                        <!-- Botón de accesibilidad -->
                        <button onclick="toggleAccessibilityPanel()" 
                                class="p-2 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
                                aria-label="Opciones de accesibilidad">
                            <i class="fas fa-universal-access text-gray-600 dark:text-gray-300 text-xl"></i>
                        </button>
                        
                        <!-- Usuario -->
                        <div class="flex items-center gap-2">
                            <div class="w-8 h-8 bg-primary rounded-full flex items-center justify-center">
                                <i class="fas fa-user text-white text-sm"></i>
                            </div>
                            <span class="text-sm font-medium text-[#111318] dark:text-white">
                                <%= session.getAttribute("usuario") %>
                            </span>
                        </div>
                    </div>
                </div>
            </header>

            <!-- Panel de Accesibilidad -->
            <div class="accessibility-panel fixed right-0 top-0 h-full w-80 bg-white dark:bg-card-dark shadow-2xl z-50 overflow-y-auto">
                <div class="p-6">
                    <div class="flex items-center justify-between mb-6">
                        <h3 class="text-lg font-bold text-[#111318] dark:text-white">Accesibilidad</h3>
                        <button onclick="toggleAccessibilityPanel()" class="text-gray-500 hover:text-gray-700">
                            <i class="fas fa-times text-xl"></i>
                        </button>
                    </div>
                    
                    <div class="space-y-6">
                        <!-- Tamaño de texto -->
                        <div>
                            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                Tamaño de texto
                            </label>
                            <div class="flex gap-2">
                                <button onclick="setTextSize('normal')" class="flex-1 px-3 py-2 text-sm border rounded hover:bg-gray-50">Normal</button>
                                <button onclick="setTextSize('large')" class="flex-1 px-3 py-2 text-sm border rounded hover:bg-gray-50">Grande</button>
                                <button onclick="setTextSize('larger')" class="flex-1 px-3 py-2 text-sm border rounded hover:bg-gray-50">Más grande</button>
                            </div>
                        </div>
                        
                        <!-- Contraste -->
                        <div>
                            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                Contraste
                            </label>
                            <div class="flex gap-2">
                                <button onclick="setContrast('normal')" class="flex-1 px-3 py-2 text-sm border rounded hover:bg-gray-50">Normal</button>
                                <button onclick="setContrast('high')" class="flex-1 px-3 py-2 text-sm border rounded hover:bg-gray-50">Alto</button>
                                <button onclick="setContrast('yellow')" class="flex-1 px-3 py-2 text-sm border rounded hover:bg-gray-50">Amarillo</button>
                            </div>
                        </div>
                        
                        <!-- Opciones adicionales -->
                        <div class="space-y-3">
                            <label class="flex items-center gap-2">
                                <input type="checkbox" id="reduceMotion" onchange="toggleMotion()" class="rounded">
                                <span class="text-sm text-gray-700 dark:text-gray-300">Reducir movimiento</span>
                            </label>
                            
                            <label class="flex items-center gap-2">
                                <input type="checkbox" id="dyslexiaFont" onchange="toggleDyslexiaFont()" class="rounded">
                                <span class="text-sm text-gray-700 dark:text-gray-300">Fuente para dislexia</span>
                            </label>
                            
                            <label class="flex items-center gap-2">
                                <input type="checkbox" id="beigeBackground" onchange="toggleBeigeBackground()" class="rounded">
                                <span class="text-sm text-gray-700 dark:text-gray-300">Fondo beige</span>
                            </label>
                        </div>
                        
                        <!-- Resetear -->
                        <button onclick="resetAccessibility()" class="w-full px-4 py-2 bg-gray-600 text-white rounded hover:bg-gray-700">
                            Restablecer configuración
                        </button>
                    </div>
                </div>
            </div>

            <!-- Contenido del formulario -->
            <div class="p-6">
                <!-- Mensajes de error/éxito -->
                <% 
                    String error = (String) session.getAttribute("error");
                    String mensaje = (String) session.getAttribute("mensaje");
                %>
                
                <% if (error != null) { 
                    session.removeAttribute("error");
                %>
                <div class="alert-modern alert-danger mb-6" role="alert">
                    <i class="fas fa-exclamation-circle"></i>
                    <div>
                        <strong>Error:</strong> <%= error %>
                    </div>
                </div>
                <% } %>
                
                <% if (mensaje != null) { 
                    session.removeAttribute("mensaje");
                %>
                <div class="alert-modern alert-success mb-6" role="alert">
                    <i class="fas fa-check-circle"></i>
                    <div>
                        <strong>Éxito:</strong> <%= mensaje %>
                    </div>
                </div>
                <% } %>
                
                <!-- Formulario -->
                <div class="bg-white dark:bg-card-dark rounded-xl border border-[#dbdfe6] dark:border-gray-700 shadow-sm overflow-hidden">
                    <div class="p-6">
                        <form action="ProfesorServlet" method="post" id="profesorForm" novalidate>
                            <input type="hidden" name="id" value="<%= editar ? p.getId() : "" %>">
                            <input type="hidden" name="accion" value="<%= editar ? "actualizar" : "guardar" %>">
                            
                            <!-- SECCIÓN: INFORMACIÓN PERSONAL -->
                            <div class="section-title">
                                <i class="fas fa-user"></i>
                                Información Personal
                            </div>
                            
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
                                <div>
                                    <label for="nombres" class="block text-sm font-medium text-[#111318] dark:text-white mb-2 required-field">
                                        Nombres
                                    </label>
                                    <div class="input-group-icon">
                                        <input type="text" class="w-full p-3 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-gray-800 focus:ring-2 focus:ring-primary focus:border-transparent" 
                                               name="nombres" id="nombres"
                                               value="<%= editar && p.getNombres() != null ? p.getNombres() : "" %>" 
                                               required maxlength="100" placeholder="Ingrese los nombres">
                                    </div>
                                    <div class="text-sm text-red-600 mt-1" id="nombres-error"></div>
                                </div>

                                <div>
                                    <label for="apellidos" class="block text-sm font-medium text-[#111318] dark:text-white mb-2 required-field">
                                        Apellidos
                                    </label>
                                    <div class="input-group-icon">
                                        <input type="text" class="w-full p-3 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-gray-800 focus:ring-2 focus:ring-primary focus:border-transparent" 
                                               name="apellidos" id="apellidos"
                                               value="<%= editar && p.getApellidos() != null ? p.getApellidos() : "" %>" 
                                               required maxlength="100" placeholder="Ingrese los apellidos">
                                    </div>
                                    <div class="text-sm text-red-600 mt-1" id="apellidos-error"></div>
                                </div>
                            </div>

                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
                                <div>
                                    <label for="correo" class="block text-sm font-medium text-[#111318] dark:text-white mb-2 required-field">
                                        Correo Electrónico
                                    </label>
                                    <div class="input-group-icon">
                                        <input type="email" class="w-full p-3 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-gray-800 focus:ring-2 focus:ring-primary focus:border-transparent" 
                                               name="correo" id="correo"
                                               value="<%= editar && p.getCorreo() != null ? p.getCorreo() : "" %>" 
                                               required maxlength="100" placeholder="ejemplo@email.com">
                                    </div>
                                    <div class="text-sm text-red-600 mt-1" id="correo-error"></div>
                                </div>

                                <div>
                                    <label for="dni" class="block text-sm font-medium text-[#111318] dark:text-white mb-2">
                                        DNI
                                        <i class="fas fa-info-circle tooltip-info" title="Opcional - 8 dígitos numéricos"></i>
                                    </label>
                                    <div class="input-group-icon">
                                        <input type="text" class="w-full p-3 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-gray-800 focus:ring-2 focus:ring-primary focus:border-transparent" 
                                               name="dni" id="dni"
                                               value="<%= editar && p.getDni() != null ? p.getDni() : "" %>" 
                                               maxlength="8" placeholder="12345678">
                                    </div>
                                    <div class="text-sm text-gray-500 mt-1">Opcional, 8 dígitos numéricos</div>
                                    <div class="text-sm text-red-600 mt-1" id="dni-error"></div>
                                </div>
                            </div>

                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
                                <div>
                                    <label for="fecha_nacimiento" class="block text-sm font-medium text-[#111318] dark:text-white mb-2">
                                        Fecha de Nacimiento
                                    </label>
                                    <div class="input-group-icon">
                                        <input type="date" class="w-full p-3 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-gray-800 focus:ring-2 focus:ring-primary focus:border-transparent" 
                                               name="fecha_nacimiento" id="fecha_nacimiento"
                                               value="<%= fechaNacimientoStr %>">
                                    </div>
                                </div>

                                <div>
                                    <label for="telefono" class="block text-sm font-medium text-[#111318] dark:text-white mb-2">
                                        Teléfono
                                    </label>
                                    <div class="input-group-icon">
                                        <input type="tel" class="w-full p-3 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-gray-800 focus:ring-2 focus:ring-primary focus:border-transparent" 
                                               name="telefono" id="telefono"
                                               value="<%= editar && p.getTelefono() != null ? p.getTelefono() : "" %>" 
                                               maxlength="20" placeholder="987654321">
                                    </div>
                                </div>
                            </div>

                            <div class="mb-6">
                                <label for="direccion" class="block text-sm font-medium text-[#111318] dark:text-white mb-2">
                                    Dirección
                                </label>
                                <div class="input-group-icon">
                                    <textarea class="w-full p-3 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-gray-800 focus:ring-2 focus:ring-primary focus:border-transparent" 
                                              name="direccion" id="direccion" rows="2" maxlength="255" 
                                              placeholder="Av. Principal 123, Distrito, Ciudad"><%= editar && p.getDireccion() != null ? p.getDireccion() : "" %></textarea>
                                </div>
                            </div>

                            <hr class="section-divider">

                            <!-- SECCIÓN: ASIGNACIONES DE NIVEL Y ÁREA -->
                            <div class="section-title">
                                <i class="fas fa-chalkboard-teacher"></i>
                                Niveles y Áreas que dicta el Profesor
                            </div>
                            
                            <div class="bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg p-4 mb-6">
                                <div class="flex items-start gap-3">
                                    <i class="fas fa-info-circle text-blue-600 dark:text-blue-400 mt-1"></i>
                                    <div class="text-sm text-blue-800 dark:text-blue-200">
                                        <strong>Importante:</strong> Un profesor puede dictar en múltiples niveles y áreas. 
                                        Por ejemplo: Matemática en Primaria y Secundaria, o Comunicación y Personal Social en Inicial.
                                        La primera asignación será considerada como la principal.
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Container de asignaciones -->
                            <div id="asignaciones-container" class="mb-4">
                                <!-- Las asignaciones se cargarán dinámicamente aquí -->
                            </div>
                            
                            <!-- Botón para agregar más asignaciones -->
                            <div class="mb-6">
                                <button type="button" 
                                        class="inline-flex items-center gap-2 px-4 py-2 bg-primary text-white rounded-lg hover:bg-primary-dark transition-colors"
                                        onclick="agregarAsignacion()">
                                    <i class="fas fa-plus-circle"></i>
                                    Agregar otro Nivel/Área
                                </button>
                            </div>

                            <hr class="section-divider">

                            <!-- SECCIÓN: INFORMACIÓN ADMINISTRATIVA -->
                            <div class="section-title">
                                <i class="fas fa-briefcase"></i>
                                Información Administrativa
                            </div>
                            
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
                                <div>
                                    <label for="fecha_contratacion" class="block text-sm font-medium text-[#111318] dark:text-white mb-2">
                                        Fecha de Contratación
                                    </label>
                                    <div class="input-group-icon">
                                        <input type="date" class="w-full p-3 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-gray-800 focus:ring-2 focus:ring-primary focus:border-transparent" 
                                               name="fecha_contratacion" id="fecha_contratacion"
                                               value="<%= fechaContratacionStr %>">
                                    </div>
                                </div>

                                <div>
                                    <label for="estado" class="block text-sm font-medium text-[#111318] dark:text-white mb-2">
                                        Estado
                                    </label>
                                    <select name="estado" class="w-full p-3 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-gray-800 focus:ring-2 focus:ring-primary focus:border-transparent">
                                        <option value="ACTIVO" <%= (editar && "ACTIVO".equals(p.getEstado())) ? "selected" : "" %>>ACTIVO</option>
                                        <option value="INACTIVO" <%= (editar && "INACTIVO".equals(p.getEstado())) ? "selected" : "" %>>INACTIVO</option>
                                        <option value="LICENCIA" <%= (editar && "LICENCIA".equals(p.getEstado())) ? "selected" : "" %>>LICENCIA</option>
                                        <option value="JUBILADO" <%= (editar && "JUBILADO".equals(p.getEstado())) ? "selected" : "" %>>JUBILADO</option>
                                    </select>
                                </div>
                            </div>
                            
                            <!-- BOTONES -->
                            <div class="flex justify-between items-center mt-8 pt-6 border-t border-[#e5e7eb] dark:border-gray-700">
                                <div class="flex gap-3">
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
                                   onclick="return confirm('¿Está seguro de eliminar este profesor?')">
                                    <i class="fas fa-trash"></i>
                                    Eliminar
                                </a>
                                <% } %>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <!-- Template para asignaciones (oculto) -->
    <template id="asignacion-template">
        <div class="asignacion-item">
            <div class="grid grid-cols-1 md:grid-cols-12 gap-4 items-center">
                <!-- Selector de Nivel -->
                <div class="md:col-span-5">
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                        <i class="fas fa-layer-group mr-1"></i> Nivel Educativo
                    </label>
                    <select name="asignacion_nivel[]" class="nivel-select w-full p-3 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-gray-800 focus:ring-2 focus:ring-primary" required onchange="filtrarAreasPorNivelAsignacion(this)">
                        <option value="">-- Seleccione nivel --</option>
                        <option value="INICIAL"> Inicial</option>
                        <option value="PRIMARIA"> Primaria</option>
                        <option value="SECUNDARIA"> Secundaria</option>
                    </select>
                </div>
                
                <!-- Selector de Área -->
                <div class="md:col-span-5">
                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                        <i class="fas fa-book mr-1"></i> Área o Materia
                    </label>
                    <select name="asignacion_area[]" class="area-select w-full p-3 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-gray-800 focus:ring-2 focus:ring-primary" required disabled>
                        <option value="">Primero seleccione un nivel</option>
                        <% 
                            if (areas != null && !areas.isEmpty()) {
                                for (Area area : areas) {
                        %>
                            <option value="<%= area.getId() %>" data-nivel="<%= area.getNivel() %>"><%= area.getNombre() %></option>
                        <% 
                                }
                            }
                        %>
                    </select>
                </div>
                
                <!-- Botón eliminar -->
                <div class="md:col-span-2 text-center">
                    <label class="block text-sm font-medium text-transparent mb-2">&nbsp;</label>
                    <button type="button" 
                            class="w-full px-4 py-3 bg-red-100 text-red-700 rounded-lg hover:bg-red-200 transition-colors"
                            onclick="eliminarAsignacion(this)"
                            title="Eliminar esta asignación">
                        <i class="fas fa-trash-alt"></i>
                    </button>
                </div>
            </div>
            
            <!-- Indicador -->
            <div class="mt-3 pt-3 border-t border-gray-300">
                <span class="asignacion-numero text-gray-600 dark:text-gray-400">
                    <!-- Se actualizará dinámicamente -->
                </span>
            </div>
        </div>
    </template>

    <!-- JAVASCRIPT -->
    <script>
        // ==================== FUNCIONES DE ACCESIBILIDAD ====================
        function toggleAccessibilityPanel() {
            const panel = document.querySelector('.accessibility-panel');
            panel.classList.toggle('open');
        }
        
        function setTextSize(size) {
            document.body.classList.remove('large-text', 'larger-text', 'largest-text');
            if (size === 'large') document.body.classList.add('large-text');
            else if (size === 'larger') document.body.classList.add('larger-text');
            else if (size === 'largest') document.body.classList.add('largest-text');
            document.body.offsetHeight;
        }
        
        function setContrast(mode) {
            document.body.classList.remove('high-contrast-invert', 'high-contrast-yellow');
            if (mode === 'high') document.body.classList.add('high-contrast-invert');
            else if (mode === 'yellow') document.body.classList.add('high-contrast-yellow');
        }
        
        function toggleMotion() {
            const checkbox = document.getElementById('reduceMotion');
            document.body.classList.toggle('reduce-motion', checkbox.checked);
        }
        
        function toggleDyslexiaFont() {
            const checkbox = document.getElementById('dyslexiaFont');
            document.body.classList.toggle('dyslexia-font', checkbox.checked);
        }
        
        function toggleBeigeBackground() {
            const checkbox = document.getElementById('beigeBackground');
            document.body.classList.toggle('beige-background', checkbox.checked);
        }
        
        function resetAccessibility() {
            document.body.classList.remove('large-text', 'larger-text', 'largest-text', 'high-contrast-invert', 'high-contrast-yellow', 'reduce-motion', 'dyslexia-font', 'beige-background');
            document.getElementById('reduceMotion').checked = false;
            document.getElementById('dyslexiaFont').checked = false;
            document.getElementById('beigeBackground').checked = false;
        }
        
        function showToast(message, type = 'info') {
            const toast = document.createElement('div');
            let bgClass = 'bg-blue-600';
            let iconClass = 'fa-info-circle';

            if (type === 'success') {
                bgClass = 'bg-green-600';
                iconClass = 'fa-check-circle';
            } else if (type === 'error') {
                bgClass = 'bg-red-600';
                iconClass = 'fa-exclamation-circle';
            }

            toast.className = `fixed top-4 right-4 z-50 p-4 rounded-lg shadow-lg text-white ${bgClass}`;
            toast.innerHTML = `<div class="flex items-center gap-2"><i class="fas ${iconClass}"></i><span>${message}</span></div>`;

            document.body.appendChild(toast);
            setTimeout(() => toast.remove(), 5000);
        }

        // ==================== GESTIÓN DE ASIGNACIONES MÚLTIPLES ====================
        let contadorAsignaciones = 0;

        /**
         * Agregar una nueva asignación
         */
        function agregarAsignacion(nivel = '', areaId = '') {
            const container = document.getElementById('asignaciones-container');
            const template = document.getElementById('asignacion-template');
            
            // Clonar el template
            const clone = template.content.cloneNode(true);
            
            // Establecer valores si vienen como parámetro
            if (nivel) {
                const selectNivel = clone.querySelector('select[name="asignacion_nivel[]"]');
                selectNivel.value = nivel;
                
                // Si hay nivel, filtrar áreas inmediatamente después de agregar
                setTimeout(() => {
                    const asignaciones = container.querySelectorAll('.asignacion-item');
                    const ultimaAsignacion = asignaciones[asignaciones.length - 1];
                    const nivelSelect = ultimaAsignacion.querySelector('.nivel-select');
                    filtrarAreasPorNivelAsignacion(nivelSelect);
                }, 10);
            }
            
            if (areaId) {
                const selectArea = clone.querySelector('select[name="asignacion_area[]"]');
                // El área se seleccionará después del filtrado
                setTimeout(() => {
                    const asignaciones = container.querySelectorAll('.asignacion-item');
                    const ultimaAsignacion = asignaciones[asignaciones.length - 1];
                    const areaSelect = ultimaAsignacion.querySelector('.area-select');
                    areaSelect.value = areaId;
                }, 20);
            }
            
            // Agregar al container
            container.appendChild(clone);
            contadorAsignaciones++;
            
            // Actualizar números
            actualizarNumerosAsignacion();
            
            console.log('? Asignación agregada. Total:', contadorAsignaciones);
        }

        /**
         * Filtrar áreas según el nivel seleccionado en una asignación
         */
        function filtrarAreasPorNivelAsignacion(selectNivel) {
            // Encontrar el select de área correspondiente
            const asignacionItem = selectNivel.closest('.asignacion-item');
            const selectArea = asignacionItem.querySelector('.area-select');
            
            const nivelSeleccionado = selectNivel.value;
            const opciones = selectArea.querySelectorAll('option');
            
            // Resetear el valor del área
            selectArea.value = '';
            
            if (!nivelSeleccionado) {
                // Si no hay nivel seleccionado, deshabilitar área
                selectArea.disabled = true;
                opciones.forEach((opcion, index) => {
                    if (index === 0) {
                        opcion.style.display = 'block';
                        opcion.textContent = 'Primero seleccione un nivel';
                    } else {
                        opcion.style.display = 'none';
                    }
                });
                return;
            }
            
            // Habilitar el select de área
            selectArea.disabled = false;
            
            // Actualizar texto de la primera opción
            opciones[0].textContent = '-- Seleccione área --';
            opciones[0].style.display = 'block';
            
            let areasVisibles = 0;
            
            // Filtrar opciones según el nivel
            opciones.forEach((opcion, index) => {
                if (index === 0) return; // Saltar la primera opción
                
                const nivelArea = opcion.getAttribute('data-nivel');
                
                // Mostrar si coincide con el nivel o si el área es para TODOS los niveles
                if (nivelArea === nivelSeleccionado || nivelArea === 'TODOS') {
                    opcion.style.display = 'block';
                    areasVisibles++;
                } else {
                    opcion.style.display = 'none';
                }
            });
            
            // Si no hay áreas disponibles
            if (areasVisibles === 0) {
                opciones[0].textContent = 'No hay áreas disponibles para este nivel';
                selectArea.disabled = true;
            }
            
            console.log(`? Áreas filtradas para nivel ${nivelSeleccionado}: ${areasVisibles} disponibles`);
        }

        /**
         * Eliminar una asignación
         */
        function eliminarAsignacion(btn) {
            const item = btn.closest('.asignacion-item');
            const container = document.getElementById('asignaciones-container');
            
            // Validar que no sea la única
            if (container.children.length <= 1) {
                showToast('Debe haber al menos una asignación de nivel y área', 'error');
                return;
            }
            
            if (confirm('¿Está seguro de eliminar esta asignación?')) {
                item.remove();
                contadorAsignaciones--;
                actualizarNumerosAsignacion();
                showToast('Asignación eliminada correctamente', 'success');
            }
        }

        /**
         * Actualizar números de asignaciones
         */
        function actualizarNumerosAsignacion() {
            const asignaciones = document.querySelectorAll('.asignacion-item');
            
            asignaciones.forEach((asig, index) => {
                const numeroLabel = asig.querySelector('.asignacion-numero');
                
                // Quitar y agregar clase principal
                asig.classList.remove('asignacion-principal');
                
                if (index === 0) {
                    asig.classList.add('asignacion-principal');
                    numeroLabel.innerHTML = '<i class="fas fa-star text-yellow-500"></i> <strong>Asignación Principal</strong> - Esta será la asignación por defecto del profesor';
                } else {
                    numeroLabel.innerHTML = `<i class="fas fa-circle text-primary"></i> Asignación ${index + 1}`;
                }
            });
        }

        /**
         * Validar formulario antes de enviar
         */
        function validarFormularioAsignaciones() {
            const container = document.getElementById('asignaciones-container');
            
            // Verificar que haya al menos una asignación
            if (container.children.length === 0) {
                showToast('Debe agregar al menos una asignación de nivel y área', 'error');
                return false;
            }
            
            // Verificar que todas estén completas
            const asignaciones = container.querySelectorAll('.asignacion-item');
            let validas = true;
            
            asignaciones.forEach((asig, index) => {
                const nivel = asig.querySelector('select[name="asignacion_nivel[]"]').value;
                const area = asig.querySelector('select[name="asignacion_area[]"]').value;
                
                if (!nivel || !area) {
                    showToast(`La asignación ${index + 1} está incompleta`, 'error');
                    validas = false;
                }
            });
            
            return validas;
        }

        // ==================== INICIALIZACIÓN ====================
        document.addEventListener('DOMContentLoaded', function() {
            console.log('? Inicializando formulario de profesor...');
            
            // Cargar asignaciones existentes o crear una nueva
            <% if (editar && p != null && p.getAsignaciones() != null && !p.getAsignaciones().isEmpty()) { %>
                // MODO EDICIÓN: Cargar asignaciones existentes
                console.log('Modo edición: Cargando <%= p.getAsignaciones().size() %> asignaciones');
                <% for (ProfesorNivelArea asig : p.getAsignaciones()) { %>
                    agregarAsignacion('<%= asig.getNivel() %>', '<%= asig.getAreaId() %>');
                <% } %>
            <% } else { %>
                // MODO NUEVO: Agregar una asignación vacía
                console.log('Modo nuevo: Agregando asignación vacía');
                agregarAsignacion();
            <% } %>
            
            // Agregar validación al submit
            const formulario = document.getElementById('profesorForm');
            if (formulario) {
                formulario.addEventListener('submit', function(e) {
                    if (!validarFormularioAsignaciones()) {
                        e.preventDefault();
                        return false;
                    }
                    return true;
                });
            }
            
            console.log(' Formulario inicializado correctamente');
        });
    </script>
</body>
</html>
