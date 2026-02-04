<%@ page import="modelo.Profesor" %>
<%@ page import="modelo.Turno" %>
<%@ page import="modelo.Area" %>
<%@ page import="java.util.List" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.time.LocalTime" %>
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
        
        /* Tamaños de texto - Afectar a toda la página */
        .large-text { 
            font-size: 18px !important; 
        }
        .large-text .form-label,
        .large-text .form-control,
        .large-text .form-select,
        .large-text .text-sm {
            font-size: 16px !important;
        }
        
        .larger-text { 
            font-size: 20px !important; 
        }
        .larger-text .form-label,
        .larger-text .form-control,
        .larger-text .form-select,
        .larger-text .text-sm {
            font-size: 18px !important;
        }
        
        .largest-text { 
            font-size: 22px !important; 
        }
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
        
        /* Ocultar elementos de accesibilidad inicialmente */
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
        
        /* Estilos específicos para formularios */
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
        
        .alert-info {
            background: linear-gradient(135deg, #dbeafe, #bfdbfe);
            color: #1e40af;
            border-left-color: #3b82f6;
        }
        
        /* Badge */
        .badge {
            padding: 0.35rem 0.85rem;
            border-radius: 9999px;
            font-size: 0.85rem;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 0.25rem;
        }
        
        /* Botones */
        .btn-modern {
            padding: 0.75rem 1.5rem;
            border-radius: 0.5rem;
            font-weight: 600;
            font-size: 0.95rem;
            border: none;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            cursor: pointer;
            text-decoration: none;
        }
        
        .btn-primary-modern {
            background: linear-gradient(135deg, #135bec, #0d47a1);
            color: white;
        }
        
        .btn-primary-modern:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 15px rgba(19, 91, 236, 0.3);
        }
        
        .btn-success-modern {
            background: linear-gradient(135deg, #10b981, #059669);
            color: white;
        }
        
        .btn-success-modern:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 15px rgba(16, 185, 129, 0.3);
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
            transform: translateY(-2px);
            box-shadow: 0 8px 15px rgba(239, 68, 68, 0.3);
        }
        
        /* Table styles */
        .custom-table {
            border-collapse: separate;
            border-spacing: 0;
            width: 100%;
            background: white;
            border-radius: 0.5rem;
            overflow: hidden;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }
        
        .dark .custom-table {
            background: #1a2233;
        }
        
        .custom-table thead {
            background: linear-gradient(135deg, #135bec 0%, #0d47a1 100%);
        }
        
        .custom-table th {
            padding: 1rem;
            text-align: left;
            font-weight: 600;
            color: white;
            font-size: 0.95rem;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }
        
        .custom-table tbody tr {
            border-bottom: 1px solid #e5e7eb;
            transition: background-color 0.2s;
        }
        
        .dark .custom-table tbody tr {
            border-bottom: 1px solid #374151;
        }
        
        .custom-table td {
            padding: 1rem;
            color: #374151;
            font-size: 0.95rem;
        }
        
        .dark .custom-table td {
            color: #d1d5db;
        }
        
        /* Section styles */
        .section-divider {
            border: none;
            height: 2px;
            background: linear-gradient(90deg, #135bec, transparent);
            margin: 2rem 0 1.5rem 0;
        }
        
        .section-title {
            color: #135bec;
            font-weight: 600;
            font-size: 1.2rem;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .dark .section-title {
            color: #60a5fa;
        }
        
        /* Tooltip */
        .tooltip-info {
            cursor: help;
            color: #3b82f6;
            margin-left: 0.25rem;
        }
        
        /* Accessibility Toggle Button */
        .accessibility-toggle {
            transition: all 0.3s ease;
        }
        
        .accessibility-toggle:hover {
            transform: scale(1.1);
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
        <!-- Left SideNavBar -->
        <aside class="w-64 flex-shrink-0 bg-white dark:bg-[#1a2233] border-r border-[#dbdfe6] dark:border-gray-700 flex flex-col justify-between">
            <div class="flex flex-col gap-8 p-6">
                <!-- Brand -->
                <div class="flex items-center gap-3">
                    <div class="bg-primary size-10 rounded-lg flex items-center justify-center text-white" aria-hidden="true">
                        <span class="material-symbols-outlined">school</span>
                    </div>
                    <div class="flex flex-col">
                        <h1 class="text-[#111318] dark:text-white text-lg font-bold leading-tight">San Antonio</h1>
                        <p class="text-[#616f89] dark:text-gray-400 text-xs font-normal">Gestión Académica</p>
                    </div>
                </div>
                
                <!-- Navigation -->
                <nav class="flex flex-col gap-2" aria-label="Navegación principal">
                    <a class="flex items-center gap-3 px-3 py-2 rounded-lg text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors" 
                       href="dashboard.jsp">
                        <span class="material-symbols-outlined">dashboard</span>
                        <span class="text-sm">Dashboard</span>
                    </a>
                    <a class="flex items-center gap-3 px-3 py-2 rounded-lg text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors" 
                       href="AlumnoServlet">
                        <i class="fas fa-user-graduate" aria-hidden="true"></i>
                        <span class="text-sm">Estudiantes</span>
                    </a>
                    <a class="flex items-center gap-3 px-3 py-2 rounded-lg bg-primary/10 text-primary font-medium" 
                       href="ProfesorServlet"
                       aria-current="page">
                        <i class="fas fa-chalkboard-teacher" aria-hidden="true"></i>
                        <span class="text-sm">Profesores</span>
                    </a>
                    <a class="flex items-center gap-3 px-3 py-2 rounded-lg text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors" 
                       href="CursoServlet">
                        <i class="fas fa-book" aria-hidden="true"></i>
                        <span class="text-sm">Cursos</span>
                    </a>
                    <a class="flex items-center gap-3 px-3 py-2 rounded-lg text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors" 
                       href="GradoServlet">
                        <i class="fas fa-layer-group" aria-hidden="true"></i>
                        <span class="text-sm">Grados</span>
                    </a>
                    <a class="flex items-center gap-3 px-3 py-2 rounded-lg text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors" 
                       href="UsuarioServlet">
                        <i class="fas fa-users-cog" aria-hidden="true"></i>
                        <span class="text-sm">Usuarios</span>
                    </a>
                </nav>
            </div>
            
                     <!-- Footer Sidebar -->
            <div class="p-6 border-t border-[#dbdfe6] dark:border-gray-700">
                <a href="LogoutServlet" 
                   class="flex w-full items-center justify-center gap-2 rounded-lg h-10 px-4 bg-primary text-white text-sm font-bold tracking-wide hover:bg-blue-700 transition-colors">
                    <span class="material-symbols-outlined text-[18px]" aria-hidden="true">logout</span>
                    <span>Cerrar Sesión</span>
                </a>
            </div>
        </aside>
        
        <!-- Main Content -->
        <main class="flex-1 flex flex-col overflow-y-auto">
            <!-- TopNavBar -->
            <header class="flex items-center justify-between bg-white dark:bg-[#1a2233] border-b border-[#f0f2f4] dark:border-gray-700 px-8 py-3 sticky top-0 z-10">
                <div class="flex items-center gap-4 flex-1">
                    <div class="flex items-center gap-3">
                        <h1 class="text-xl font-bold text-[#111318] dark:text-white">
                            <%= editar ? "Editar Profesor" : "Registrar Nuevo Profesor" %>
                        </h1>
                    </div>
                </div>
                
                <div class="flex items-center gap-4 ml-8">
                    <button class="p-2 text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg relative"
                            aria-label="Notificaciones">
                        <span class="material-symbols-outlined">notifications</span>
                        <span class="absolute top-2 right-2 size-2 bg-red-500 rounded-full border-2 border-white"></span>
                    </button>
                    
                    <button class="p-2 text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg"
                            aria-label="Configuración">
                        <span class="material-symbols-outlined">settings</span>
                    </button>
                    
                    <div class="h-8 w-[1px] bg-gray-200 dark:bg-gray-700 mx-2" aria-hidden="true"></div>
                    
                    <div class="flex items-center gap-3">
                        <p class="text-sm font-medium hidden md:block">
                            <%= session.getAttribute("usuario") != null ? session.getAttribute("usuario") : "Administrador" %>
                        </p>
                        <div class="size-10 rounded-full bg-cover bg-center border-2 border-primary/20" 
                             style="background-image: url('https://lh3.googleusercontent.com/aida-public/AB6AXuCO64ytW7WFj5YJ0XxtUSKDLHtMumvYdpNUpuyZfiJ1u2v-o-ZSRqiNGLyx6pmhB7nZDuPBYTD_VLKKCEUg0atLHJC4hTrMG5QjAfNlLQdzKId6L3tl2-QhmWJUVQVRr4hk7ODNpJ2OomnFQx_u6WT5QgxJRWLtvZ2I5ecv8WfcR1-MoMfF485fYSxo5s9ErvyApFtN9ro0oew7DMrNHFDQJp1zE9Dtyls43R9C7cnQa5HNlhDoiFBsEBf8CYKzebhaA6Yfuad3vcM');"
                             aria-label="Foto de perfil del administrador">
                        </div>
                    </div>
                </div>
            </header>
            
            <!-- Main Content -->
            <div class="p-8">
                <!-- Header con título -->
                <div class="mb-6">
                    <h2 class="text-2xl font-bold text-[#111318] dark:text-white">Gestión de Profesores</h2>
                    <p class="text-[#616f89] dark:text-gray-400 mt-1"><%= editar ? "Edita la información del profesor" : "Completa el formulario para registrar un nuevo profesor" %></p>
                </div>
                
                <!-- Alertas -->
                <% 
                    String error = (String) session.getAttribute("error");
                    String mensaje = (String) session.getAttribute("mensaje");
                    
                    if (error != null) { 
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

                            <!-- SECCIÓN: INFORMACIÓN PROFESIONAL -->
                            <div class="section-title">
                                <i class="fas fa-briefcase"></i>
                                Información Profesional
                            </div>
                            
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
                                <div>
                                    <label for="nivel" class="block text-sm font-medium text-[#111318] dark:text-white mb-2 required-field">
                                        Nivel que Enseña
                                    </label>
                                    <select class="w-full p-3 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-gray-800 focus:ring-2 focus:ring-primary focus:border-transparent" 
                                            name="nivel" id="nivel" required>
                                        <option value="">Seleccione un nivel</option>
                                        <option value="INICIAL" <%= (editar && "INICIAL".equals(p.getNivel())) ? "selected" : "" %>>Inicial</option>
                                        <option value="PRIMARIA" <%= (editar && "PRIMARIA".equals(p.getNivel())) ? "selected" : "" %>>Primaria</option>
                                        <option value="SECUNDARIA" <%= (editar && "SECUNDARIA".equals(p.getNivel())) ? "selected" : "" %>>Secundaria</option>
                                        <option value="TODOS" <%= (editar && "TODOS".equals(p.getNivel())) ? "selected" : "" %>>Todos los Niveles</option>
                                    </select>
                                    <div class="text-sm text-red-600 mt-1" id="nivel-error"></div>
                                </div>
                                
                                <div>
                                    <label for="area_id" class="block text-sm font-medium text-[#111318] dark:text-white mb-2 required-field">
                                        Área
                                    </label>
                                    <select class="w-full p-3 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-gray-800 focus:ring-2 focus:ring-primary focus:border-transparent" 
                                            name="area_id" id="area_id" required>
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
                                            <option value="" disabled>No hay áreas disponibles</option>
                                        <% 
                                            }
                                        %>
                                    </select>
                                    <div class="text-sm text-gray-500 mt-1">Las áreas se filtran según el nivel seleccionado</div>
                                    <div class="text-sm text-red-600 mt-1" id="area-error"></div>
                                </div>
                            </div>

                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
                                <div>
                                    <label for="turno_id" class="block text-sm font-medium text-[#111318] dark:text-white mb-2 required-field">
                                        Turno
                                    </label>
                                    <select class="w-full p-3 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-gray-800 focus:ring-2 focus:ring-primary focus:border-transparent" 
                                            name="turno_id" id="turno_id" required>
                                        <option value="">Seleccione un turno</option>
                                        <% 
                                            if (turnos != null && !turnos.isEmpty()) {
                                                for (Turno turno : turnos) {
                                                    boolean selected = editar && p.getTurnoId() == turno.getId();
                                                    
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
                                    <div class="text-sm text-red-600 mt-1" id="turno-error"></div>
                                </div>
                                
                                <div>
                                    <input type="hidden" name="codigo_profesor" value="">
                                </div>
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
                            
                            <!-- ========================================
                                    SECCIÓN: DISPONIBILIDAD HORARIA
                                    ======================================== -->
                            <hr class="section-divider">
                            <div class="section-title">
                                <i class="fas fa-calendar-alt"></i>
                                Disponibilidad Horaria
                            </div>

                            <div class="alert-modern alert-info mb-6">
                                <i class="fas fa-info-circle"></i>
                                <div>
                                    Selecciona los días y horarios en los que el profesor está disponible para dictar clases.
                                </div>
                            </div>

                            <div id="disponibilidad-container" class="mb-6">
                                <!-- Tabla para mostrar disponibilidades existentes -->
                                <div class="overflow-x-auto">
                                    <table class="custom-table">
                                        <thead>
                                            <tr>
                                                <th>Día</th>
                                                <th>Hora Inicio</th>
                                                <th>Hora Fin</th>
                                            </tr>
                                        </thead>
                                        <tbody id="disponibilidades-body">
                                            <!-- Se llenarán dinámicamente -->
                                            <tr id="sin-disponibilidades">
                                                <td colspan="4" class="text-center py-4 text-gray-400">
                                                    <i class="fas fa-info-circle"></i> No hay disponibilidades registradas
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>

                                <button type="button" class="btn-modern btn-success-modern mt-4" id="btn-agregar-disponibilidad">
                                    <i class="fas fa-plus"></i> Agregar Horario Disponible
                                </button>
                            </div>

                            <!-- Modal para agregar disponibilidad -->
                            <div class="modal fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50 hidden" id="modalDisponibilidad">
                                <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white dark:bg-gray-800">
                                    <div class="flex justify-between items-center mb-4">
                                        <h3 class="text-lg font-bold">Agregar Horario Disponible</h3>
                                        <button type="button" onclick="closeModal()" class="text-gray-500 hover:text-gray-700">
                                            <i class="fas fa-times"></i>
                                        </button>
                                    </div>
                                    <div class="mb-4">
                                        <label class="block text-sm font-medium text-[#111318] dark:text-white mb-2 required-field">
                                            Día de la Semana
                                        </label>
                                        <select class="w-full p-3 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-gray-800 focus:ring-2 focus:ring-primary focus:border-transparent" 
                                                id="modal-dia" required>
                                            <option value="">Seleccione un día</option>
                                            <option value="LUNES">Lunes</option>
                                            <option value="MARTES">Martes</option>
                                            <option value="MIERCOLES">Miércoles</option>      
                                            <option value="JUEVES">Jueves</option>
                                            <option value="VIERNES">Viernes</option>
                                            <option value="SABADO">Sábado</option>
                                        </select>
                                    </div>
                                    <div class="mb-4">
                                        <label class="block text-sm font-medium text-[#111318] dark:text-white mb-2 required-field">
                                            Hora de Inicio
                                        </label>
                                        <input type="time" class="w-full p-3 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-gray-800 focus:ring-2 focus:ring-primary focus:border-transparent" 
                                               id="modal-hora-inicio" required>
                                    </div>
                                    <div class="mb-4">
                                        <label class="block text-sm font-medium text-[#111318] dark:text-white mb-2 required-field">
                                            Hora de Fin
                                        </label>
                                        <input type="time" class="w-full p-3 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-gray-800 focus:ring-2 focus:ring-primary focus:border-transparent" 
                                               id="modal-hora-fin" required>
                                    </div>
                                    <div class="flex justify-end gap-3">
                                        <button type="button" onclick="closeModal()" 
                                                class="btn-modern btn-secondary-modern">
                                            <i class="fas fa-times"></i> Cancelar
                                        </button>
                                        <button type="button" onclick="guardarDisponibilidad()" 
                                                class="btn-modern btn-primary-modern">
                                            <i class="fas fa-save"></i> Guardar Horario
                                        </button>
                                    </div>
                                </div>
                            </div>

                            <!-- Campos ocultos para disponibilidades -->
                            <div id="disponibilidades-hidden"></div>
                            
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

    <script>
        // ==================== FUNCIONES DE ACCESIBILIDAD ====================
        function toggleAccessibilityPanel() {
            const panel = document.querySelector('.accessibility-panel');
            panel.classList.toggle('open');
        }
        
        function setTextSize(size) {
            document.body.classList.remove('large-text', 'larger-text', 'largest-text');
            if (size === 'large') {
                document.body.classList.add('large-text');
            } else if (size === 'larger') {
                document.body.classList.add('larger-text');
            } else if (size === 'largest') {
                document.body.classList.add('largest-text');
            }
            document.body.offsetHeight; // Forzar reflow
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
            const checkbox = document.getElementById('reduceMotion');
            if (checkbox.checked) {
                document.body.classList.add('reduce-motion');
            } else {
                document.body.classList.remove('reduce-motion');
            }
        }
        
        function toggleDyslexiaFont() {
            const checkbox = document.getElementById('dyslexiaFont');
            if (checkbox.checked) {
                document.body.classList.add('dyslexia-font');
            } else {
                document.body.classList.remove('dyslexia-font');
            }
        }
        
        function toggleBeigeBackground() {
            const checkbox = document.getElementById('beigeBackground');
            if (checkbox.checked) {
                document.body.classList.add('beige-background');
            } else {
                document.body.classList.remove('beige-background');
            }
        }
        
        function resetAccessibility() {
            document.body.classList.remove(
                'large-text', 'larger-text', 'largest-text',
                'high-contrast-invert', 'high-contrast-yellow',
                'reduce-motion', 'dyslexia-font', 'beige-background'
            );
            
            document.getElementById('reduceMotion').checked = false;
            document.getElementById('dyslexiaFont').checked = false;
            document.getElementById('beigeBackground').checked = false;
        }
        
        // ==================== FUNCIONES DEL FORMULARIO ====================
        
        let disponibilidadesArray = [];
        
        // Filtrar áreas según nivel seleccionado
        const nivelSelect = document.getElementById('nivel');
        const areaSelect = document.getElementById('area_id');
        
        function filtrarAreas() {
            const nivelSeleccionado = nivelSelect.value;
            const opciones = areaSelect.querySelectorAll('option');
            
            areaSelect.value = '';
            
            opciones.forEach(function(opcion) {
                if (opcion.value === '') {
                    opcion.style.display = '';
                    if (nivelSeleccionado === '') {
                        opcion.textContent = 'Primero seleccione un nivel';
                    } else {
                        opcion.textContent = 'Seleccione el área';
                    }
                    return;
                }
                
                const nivelArea = opcion.getAttribute('data-nivel');
                
                if (nivelSeleccionado === 'TODOS') {
                    if (nivelArea === 'TODOS') {
                        opcion.style.display = '';
                    } else {
                        opcion.style.display = 'none';
                    }
                } else {
                    if (nivelArea === 'TODOS' || nivelArea === nivelSeleccionado) {
                        opcion.style.display = '';
                    } else {
                        opcion.style.display = 'none';
                    }
                }
            });
        }
        
        if (nivelSelect && areaSelect) {
            nivelSelect.addEventListener('change', filtrarAreas);
            filtrarAreas();
        }
        
        // Modal functions
        function openModal() {
            // Verificar que se haya seleccionado un turno primero
            const turnoId = document.getElementById('turno_id').value;
            if (!turnoId || turnoId === '') {
                alert(' IMPORTANTE: Primero debe seleccionar un TURNO en el formulario principal antes de agregar disponibilidades.\n\n' +
                      'Por favor:\n' +
                      '1. Seleccione un Turno en la sección "Información Profesional"\n' +
                      '2. Luego haga clic en "Agregar Horario Disponible"');
                return;
            }

            document.getElementById('modalDisponibilidad').classList.remove('hidden');
            document.getElementById('modal-dia').focus();
        }
        function closeModal() {
        document.getElementById('modalDisponibilidad').classList.add('hidden');
        document.getElementById('modal-dia').value = '';
        document.getElementById('modal-hora-inicio').value = '';
        document.getElementById('modal-hora-fin').value = '';
    }

        function guardarDisponibilidad() {
        console.log('=== INICIANDO guardarDisponibilidad() ===');

        // Obtener valores del modal
        const dia = document.getElementById('modal-dia').value;
        const horaInicio = document.getElementById('modal-hora-inicio').value;
        const horaFin = document.getElementById('modal-hora-fin').value;
        const turnoId = document.getElementById('turno_id').value;

        console.log('Valores obtenidos:', { dia, horaInicio, horaFin, turnoId });

        // ? VALIDACIÓN 1: Campos completos
        if (!dia || !horaInicio || !horaFin) {
            alert('?? Por favor complete todos los campos obligatorios:\n- Día de la semana\n- Hora de inicio\n- Hora de fin');
            return;
        }

        // ? VALIDACIÓN 2: Hora de inicio menor que hora de fin
        if (horaInicio >= horaFin) {
            alert('?? La hora de inicio debe ser ANTERIOR a la hora de fin');
            return;
        }

        // ? VALIDACIÓN 3: Turno seleccionado (CRÍTICA)
        if (!turnoId || turnoId === '' || turnoId === null) {
            alert('?? ERROR CRÍTICO: Debe seleccionar un TURNO en el formulario principal ANTES de agregar disponibilidades.\n\n' +
                  'Pasos a seguir:\n' +
                  '1. Cierre este modal\n' +
                  '2. Seleccione un Turno en la sección "Información Profesional"\n' +
                  '3. Vuelva a hacer clic en "Agregar Horario Disponible"');
            return;
        }

        console.log('? Validaciones pasadas correctamente');
        console.log('? Creando disponibilidad con turnoId:', turnoId);

        // ? Crear objeto disponibilidad
        const disponibilidad = {
            dia: dia,
            turnoId: turnoId.toString(), // ? Asegurar que sea string
            horaInicio: horaInicio,
            horaFin: horaFin,
            disponible: true
        };

        console.log('Objeto disponibilidad creado:', disponibilidad);

        disponibilidadesArray.push(disponibilidad);
        console.log('Disponibilidad agregada al array. Total:', disponibilidadesArray.length);

        // ? IMPORTANTE: Actualizar tabla Y campos ocultos inmediatamente
        actualizarTablaDisponibilidades();
        actualizarCamposOcultos(); 

        closeModal();

        // Feedback visual
        showToast('? Disponibilidad agregada correctamente', 'success');
        console.log('=== FIN guardarDisponibilidad() ===');
    }
        
        function actualizarTablaDisponibilidades() {
        const tbody = document.getElementById('disponibilidades-body');
        const filaSinDatos = document.getElementById('sin-disponibilidades');

        // Limpiar tabla (excepto la fila de "sin datos")
        Array.from(tbody.children).forEach(row => {
            if (row.id !== 'sin-disponibilidades') {
                row.remove();
            }
        });

        if (disponibilidadesArray.length === 0) {
            if (filaSinDatos) {
                filaSinDatos.style.display = '';
            }
            return;
        }

        if (filaSinDatos) {
            filaSinDatos.style.display = 'none';
        }

        // Agregar cada disponibilidad a la tabla
        disponibilidadesArray.forEach((disp, index) => {
            const fila = document.createElement('tr');

            let horaInicioMostrar = disp.horaInicio || '';
            let horaFinMostrar = disp.horaFin || '';

            // Formatear horas para mostrar (solo HH:mm)
            if (horaInicioMostrar.includes(':')) {
                horaInicioMostrar = horaInicioMostrar.substring(0, 5);
            }
            if (horaFinMostrar.includes(':')) {
                horaFinMostrar = horaFinMostrar.substring(0, 5);
            }

            fila.innerHTML = `
                <td>${disp.dia || ''}</td>
                <td>${horaInicioMostrar}</td>
                <td>${horaFinMostrar}</td>
                <td>
                    <button type="button" class="p-2 text-red-600 hover:bg-red-100 rounded" 
                            onclick="eliminarDisponibilidad(${index})" title="Eliminar">
                        <i class="fas fa-trash"></i>
                    </button>
                </td>
            `;
            tbody.appendChild(fila);
        });
    }
        
        function eliminarDisponibilidad(index) {
        if (confirm('¿Está seguro de eliminar esta disponibilidad?')) {
            disponibilidadesArray.splice(index, 1);
            actualizarTablaDisponibilidades();
            actualizarCamposOcultos();
            showToast('? Disponibilidad eliminada', 'info');
        }
    }
        
        function actualizarCamposOcultos() {
        console.log('\n? === INICIANDO actualizarCamposOcultos() ===');

        const container = document.getElementById('disponibilidades-hidden');
        if (!container) {
            console.error('? ERROR CRÍTICO: No se encontró el contenedor disponibilidades-hidden');
            console.error('? Verifique que existe: <div id="disponibilidades-hidden"></div>');
            console.error('? Y que está DENTRO del <form>');
            return;
        }

        console.log('? Contenedor encontrado:', container);

        // ? Limpiar completamente el contenedor
        container.innerHTML = '';
        console.log('? Contenedor limpiado');

        console.log('? Total de disponibilidades a procesar:', disponibilidadesArray.length);

        // ? SIEMPRE enviar el total, incluso si es 0
        const totalInput = document.createElement('input');
        totalInput.type = 'hidden';
        totalInput.name = 'total_disponibilidades';
        totalInput.value = disponibilidadesArray.length.toString();
        container.appendChild(totalInput);
        console.log('? Campo total_disponibilidades creado:', totalInput.value);

        if (disponibilidadesArray.length === 0) {
            console.log('?? No hay disponibilidades para enviar (total = 0)');
            console.log('? === FIN actualizarCamposOcultos() ===\n');
            return;
        }

        // ? Procesar cada disponibilidad
        let camposCreados = 0;
        disponibilidadesArray.forEach((disp, index) => {
            console.log(`\n--- Procesando disponibilidad ${index} ---`);
            console.log('Datos:', disp);

            // ? VALIDACIÓN ESTRICTA: Verificar campos obligatorios
            if (!disp.dia || disp.dia === '') {
                console.warn(`?? Disponibilidad ${index}: campo 'dia' vacío`);
                return;
            }
            if (!disp.horaInicio || disp.horaInicio === '') {
                console.warn(`?? Disponibilidad ${index}: campo 'horaInicio' vacío`);
                return;
            }
            if (!disp.horaFin || disp.horaFin === '') {
                console.warn(`?? Disponibilidad ${index}: campo 'horaFin' vacío`);
                return;
            }

            // ? VALIDACIÓN CRÍTICA: Verificar turnoId
            if (!disp.turnoId || disp.turnoId === '' || disp.turnoId === null || disp.turnoId === undefined) {
                console.error(`? ERROR CRÍTICO en disponibilidad ${index}: turnoId inválido:`, disp.turnoId);
                console.error(`? Esta disponibilidad NO se enviará al servidor`);
                return;
            }

            console.log(`? Todos los campos validados para disponibilidad ${index}`);

            // ? CREAR LOS 5 CAMPOS OCULTOS
            const campos = [
                { name: `disp_dia_${index}`, value: disp.dia },
                { name: `disp_turno_${index}`, value: disp.turnoId },
                { name: `disp_hora_inicio_${index}`, value: disp.horaInicio },
                { name: `disp_hora_fin_${index}`, value: disp.horaFin },
                { name: `disp_disponible_${index}`, value: 'true' }
            ];

            campos.forEach(campo => {
                const input = document.createElement('input');
                input.type = 'hidden';
                input.name = campo.name;
                input.value = campo.value;
                container.appendChild(input);
                console.log(`  ? Campo creado: ${campo.name} = ${campo.value}`);
                camposCreados++;
            });

            console.log(`? Disponibilidad ${index} procesada correctamente`);
        });

        console.log(`\n? RESUMEN:`);
        console.log(`  - Disponibilidades en array: ${disponibilidadesArray.length}`);
        console.log(`  - Campos ocultos creados: ${camposCreados}`);
        console.log(`  - Total de inputs en contenedor: ${container.querySelectorAll('input').length}`);
        console.log('? Campos ocultos actualizados correctamente');
        console.log('? === FIN actualizarCamposOcultos() ===\n');
    }
      
    function validarFormulario() {
        let errores = [];

        if (!document.getElementById('nombres').value.trim()) {
            errores.push("El campo Nombres es obligatorio");
        }

        if (!document.getElementById('apellidos').value.trim()) {
            errores.push("El campo Apellidos es obligatorio");
        }

        if (!document.getElementById('correo').value.trim()) {
            errores.push("El campo Correo es obligatorio");
        }

        if (!document.getElementById('nivel').value) {
            errores.push("Debe seleccionar un Nivel");
        }

        if (!document.getElementById('area_id').value) {
            errores.push("Debe seleccionar un Área");
        }

        if (!document.getElementById('turno_id').value) {
            errores.push("Debe seleccionar un Turno");
        }

        // Validar DNI si está presente
        const dni = document.getElementById('dni').value.trim();
        if (dni && (!/^\d{8}$/.test(dni))) {
            errores.push("El DNI debe tener 8 dígitos numéricos");
        }

        return errores;
    }
        // Toast notifications
       function showToast(message, type = 'info') {
        const toast = document.createElement('div');

        // Determinar estilo según tipo
        let bgClass = 'bg-blue-600';
        let iconClass = 'fa-info-circle';

        if (type === 'success') {
            bgClass = 'bg-green-600';
            iconClass = 'fa-check-circle';
        } else if (type === 'error') {
            bgClass = 'bg-red-600';
            iconClass = 'fa-exclamation-circle';
        }

        toast.className = 'fixed top-4 right-4 z-50 p-4 rounded-lg shadow-lg text-white ' + bgClass;
        toast.innerHTML = `
            <div class="flex items-center gap-2">
                <i class="fas ${iconClass}"></i>
                <span>${message}</span>
            </div>
        `;

        document.body.appendChild(toast);

        setTimeout(() => {
            toast.remove();
        }, 5000);
    }
        
        // Cargar disponibilidades existentes si estamos editando
        <% if (editar && p.getDisponibilidades() != null && !p.getDisponibilidades().isEmpty()) { %>
            const disponibilidadesExistentes = [
                <% 
                java.util.List<modelo.Disponibilidad> disponibilidades = p.getDisponibilidades();
                for (int i = 0; i < disponibilidades.size(); i++) {
                    modelo.Disponibilidad disp = disponibilidades.get(i);

                    String horaInicio = disp.getHoraInicio() != null ? disp.getHoraInicio().toString() : "";
                    String horaFin = disp.getHoraFin() != null ? disp.getHoraFin().toString() : "";
                    if (horaInicio.length() > 8) horaInicio = horaInicio.substring(0, 5);
                    if (horaFin.length() > 8) horaFin = horaFin.substring(0, 5);
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

            console.log('? Cargando disponibilidades existentes:', disponibilidadesExistentes.length);
            disponibilidadesArray = disponibilidadesExistentes;
            actualizarTablaDisponibilidades();
            actualizarCamposOcultos();  // ? AGREGAR ESTA LÍNEA
            console.log('? Disponibilidades cargadas y campos ocultos generados');
        <% } %>
        
        // Validación del formulario
        function validarFormulario() {
            let errores = [];
            
            if (!document.getElementById('nombres').value.trim()) {
                errores.push("El campo Nombres es obligatorio");
            }
            
            if (!document.getElementById('apellidos').value.trim()) {
                errores.push("El campo Apellidos es obligatorio");
            }
            
            if (!document.getElementById('correo').value.trim()) {
                errores.push("El campo Correo es obligatorio");
            }
            
            if (!document.getElementById('nivel').value) {
                errores.push("Debe seleccionar un Nivel");
            }
            
            if (!document.getElementById('area_id').value) {
                errores.push("Debe seleccionar un Área");
            }
            
            if (!document.getElementById('turno_id').value) {
                errores.push("Debe seleccionar un Turno");
            }
            
            // Validar DNI si está presente
            const dni = document.getElementById('dni').value.trim();
            if (dni && (!/^\d{8}$/.test(dni))) {
                errores.push("El DNI debe tener 8 dígitos numéricos");
            }
            
            return errores;
        }
        
       // Event listeners
        document.addEventListener('DOMContentLoaded', function() {
            console.log('? Inicializando formulario de profesor...');

            // Botón agregar disponibilidad
            const btnAgregar = document.getElementById('btn-agregar-disponibilidad');
            if (btnAgregar) {
                btnAgregar.addEventListener('click', openModal);
                console.log('? Event listener agregado a btn-agregar-disponibilidad');
            }

            // ? CRÍTICO: Submit del formulario
            const form = document.getElementById('profesorForm');
            if (form) {
                form.addEventListener('submit', function(e) {
                    console.log('\n? === INICIANDO ENVÍO DEL FORMULARIO ===');
                    console.log('Timestamp:', new Date().toISOString());

                    // Validación básica del formulario
                    const errores = validarFormulario();

                    if (errores.length > 0) {
                        e.preventDefault();
                        console.error('? Errores de validación:', errores);
                        alert('? Errores en el formulario:\n\n' + errores.join('\n'));
                        return false;
                    }

                    console.log('? Validación básica pasada');

                    // ? PASO CRÍTICO: Actualizar campos ocultos JUSTO ANTES de enviar
                    console.log('? Actualizando campos ocultos antes del envío...');
                    actualizarCamposOcultos();

                    // ? VERIFICACIÓN: Confirmar que los campos se crearon
                    const container = document.getElementById('disponibilidades-hidden');
                    const totalInputs = container ? container.querySelectorAll('input').length : 0;

                    console.log('? Estado antes del envío:');
                    console.log('  - Disponibilidades en array:', disponibilidadesArray.length);
                    console.log('  - Campos ocultos creados:', totalInputs);

                    // ? Si hay disponibilidades pero no hay campos, ERROR CRÍTICO
                    if (disponibilidadesArray.length > 0 && totalInputs === 0) {
                        e.preventDefault();
                        console.error('? ERROR CRÍTICO: Hay disponibilidades pero no se crearon los campos ocultos');
                        alert('? ERROR CRÍTICO:\n\n' +
                              'Las disponibilidades no se generaron correctamente.\n' +
                              'Por favor, contacte al administrador del sistema.\n\n' +
                              'Detalles técnicos:\n' +
                              `- Disponibilidades en memoria: ${disponibilidadesArray.length}\n` +
                              `- Campos ocultos creados: ${totalInputs}`);
                        return false;
                    }

                    // ? Si llegamos aquí, todo está correcto
                    console.log('? Todos los checks pasados');
                    console.log('? Formulario validado correctamente');
                    console.log('? Enviando formulario al servidor...');
                    console.log('? === FIN VALIDACIÓN - PERMITIENDO ENVÍO ===\n');

                    showToast('? Enviando formulario...', 'info');

                    return true;
                }); 

                console.log('? Event listener agregado al submit del formulario');
            } 
            // Navegación por teclado (DEBE ESTAR AQUÍ, DENTRO DEL DOMContentLoaded)
            document.addEventListener('keydown', function(e) {
                if (e.key === 'Escape') {
                    const panel = document.querySelector('.accessibility-panel');
                    if (panel && panel.classList.contains('open')) {
                        panel.classList.remove('open');
                    }
                    closeModal();
                }
            });

            // Auto-focus en primer campo
            setTimeout(() => {
                const nombresField = document.getElementById('nombres');
                if (nombresField) {
                    nombresField.focus();
                }
            }, 100);

            console.log('? Formulario inicializado correctamente');
        }); 
    </script>
</body>
</html>