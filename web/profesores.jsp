<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, modelo.Profesor" %>
<%@ page import="javax.servlet.http.HttpSession" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setHeader("Expires", "0");

    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    List<Profesor> lista = (List<Profesor>) request.getAttribute("lista");
%>

<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profesores - San Antonio</title>
    
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    
    <link href="https://fonts.googleapis.com/css2?family=Lexend:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
    
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    
    <script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        "primary": "#135bec",
                        "background-light": "#f6f6f8",
                        "background-dark": "#101622",
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
        
        /* Tamaños de texto - Afectar a toda la página incluyendo tablas */
        .large-text { 
            font-size: 18px !important; 
        }
        .large-text .custom-table th,
        .large-text .custom-table td,
        .large-text .status-badge,
        .large-text .text-sm,
        .large-text .text-xs {
            font-size: 16px !important;
        }
        
        .larger-text { 
            font-size: 20px !important; 
        }
        .larger-text .custom-table th,
        .larger-text .custom-table td,
        .larger-text .status-badge,
        .larger-text .text-sm,
        .larger-text .text-xs {
            font-size: 18px !important;
        }
        
        .largest-text { 
            font-size: 22px !important; 
        }
        .largest-text .custom-table th,
        .largest-text .custom-table td,
        .largest-text .status-badge,
        .largest-text .text-sm,
        .largest-text .text-xs {
            font-size: 20px !important;
        }
        
        .dyslexia-font { 
            font-family: Arial !important; 
            font-size: 1.1em !important; 
            line-height: 1.6 !important; 
            letter-spacing: 0.5px !important; 
        }
        .dyslexia-font .custom-table th,
        .dyslexia-font .custom-table td {
            font-family: Arial !important;
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
        
        /* Estilos para la tabla - CON tamaños base más grandes */
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
        
        /* Tamaños base para la tabla - ya más grandes */
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
        
        .custom-table tbody tr:hover {
            background-color: #f9fafb;
        }
        
        .dark .custom-table tbody tr:hover {
            background-color: #2d3748;
        }
        
        .custom-table td {
            padding: 1rem;
            color: #374151;
            font-size: 0.95rem; 
        }
        
        .dark .custom-table td {
            color: #d1d5db;
        }
        
        /* Badge con tamaño base más grande */
        .status-badge {
            padding: 0.35rem 0.85rem; 
            border-radius: 9999px;
            font-size: 0.85rem; 
            font-weight: 600;
        }
        
        .btn-icon {
            padding: 0.5rem;
            border-radius: 0.375rem;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            transition: all 0.2s;
        }
        
        .btn-icon:hover {
            transform: translateY(-1px);
        }
        
        /* Textos generales más grandes por defecto */
        .text-sm {
            font-size: 0.95rem !important; 
        }
        
        .text-xs {
            font-size: 0.85rem !important; 
        }
        
        /* Asegurar que los iconos también se agranden */
        .large-text .material-symbols-outlined {
            font-size: 1.2em !important;
        }
        
        .larger-text .material-symbols-outlined {
            font-size: 1.3em !important;
        }
        
        .largest-text .material-symbols-outlined {
            font-size: 1.4em !important;
        }
        
        /* Botón de accesibilidad */
        .accessibility-toggle {
            transition: all 0.3s ease;
        }
        
        .accessibility-toggle:hover {
            transform: scale(1.1);
        }
        
        /* Estilos para alertas */
        .alert {
            border-radius: 0.5rem;
            padding: 1rem;
            margin-bottom: 1rem;
            border: 1px solid transparent;
        }
        
        .alert-danger {
            background-color: #fef2f2;
            border-color: #fecaca;
            color: #dc2626;
        }
        
        .dark .alert-danger {
            background-color: #450a0a;
            border-color: #7f1d1d;
            color: #fca5a5;
        }
        
        .alert-success {
            background-color: #f0fdf4;
            border-color: #bbf7d0;
            color: #16a34a;
        }
        
        .dark .alert-success {
            background-color: #052e16;
            border-color: #166534;
            color: #86efac;
        }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark text-[#111318] dark:text-white min-h-screen" id="main-content">
    <a href="#main-content" class="skip-to-content focus:top-0">Saltar al contenido principal</a>
    
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
    
    <button onclick="toggleAccessibilityPanel()" 
            class="fixed top-20 right-0 z-40 bg-primary text-white p-3 rounded-l-lg shadow-lg hover:bg-blue-700 transition-colors accessibility-toggle"
            aria-label="Abrir panel de accesibilidad">
        <span class="material-symbols-outlined">accessibility_new</span>
    </button>
    
    <div class="flex h-screen overflow-hidden">
        <aside class="w-64 flex-shrink-0 bg-white dark:bg-[#1a2233] border-r border-[#dbdfe6] dark:border-gray-700 flex flex-col justify-between">
            <div class="flex flex-col gap-8 p-6">
                <div class="flex items-center gap-3">
                    <div class="bg-primary size-10 rounded-lg flex items-center justify-center text-white" aria-hidden="true">
                        <span class="material-symbols-outlined">school</span>
                    </div>
                    <div class="flex flex-col">
                        <h1 class="text-[#111318] dark:text-white text-lg font-bold leading-tight">San Antonio</h1>
                        <p class="text-[#616f89] dark:text-gray-400 text-xs font-normal">Gestión Académica</p>
                    </div>
                </div>
                
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
            
            <div class="p-6 border-t border-[#dbdfe6] dark:border-gray-700">
                <a href="LogoutServlet" 
                   class="flex w-full items-center justify-center gap-2 rounded-lg h-10 px-4 bg-primary text-white text-sm font-bold tracking-wide hover:bg-blue-700 transition-colors">
                    <span class="material-symbols-outlined text-[18px]" aria-hidden="true">logout</span>
                    <span>Cerrar Sesión</span>
                </a>
            </div>
        </aside>
        
        <main class="flex-1 flex flex-col overflow-y-auto">
            <header class="flex items-center justify-between bg-white dark:bg-[#1a2233] border-b border-[#f0f2f4] dark:border-gray-700 px-8 py-3 sticky top-0 z-10">
                <div class="flex items-center gap-4 flex-1">
                    <div class="flex items-center gap-3">
                        <h1 class="text-xl font-bold text-[#111318] dark:text-white">
                            Listado de Profesores
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
            
            <div class="p-8">
                <% 
                    String error = (String) session.getAttribute("error");
                    String mensaje = (String) session.getAttribute("mensaje");
                    
                    if (error != null) { 
                        session.removeAttribute("error");
                %>
                <div class="alert alert-danger mb-6" role="alert">
                    <div class="flex items-center gap-2">
                        <i class="fas fa-exclamation-circle"></i>
                        <strong>Error:</strong> <%= error %>
                    </div>
                </div>
                <% } %>
                
                <% if (mensaje != null) { 
                    session.removeAttribute("mensaje");
                %>
                <div class="alert alert-success mb-6" role="alert">
                    <div class="flex items-center gap-2">
                        <i class="fas fa-check-circle"></i>
                        <strong>Éxito:</strong> <%= mensaje %>
                    </div>
                </div>
                <% } %>
                
                <div class="flex justify-between items-center mb-6">
                    <div>
                        <h2 class="text-2xl font-bold text-[#111318] dark:text-white">Gestión de Profesores</h2>
                        <p class="text-[#616f89] dark:text-gray-400 mt-1">Administra los profesores del sistema educativo</p>
                    </div>
                    <a href="ProfesorServlet?accion=nuevo" 
                       class="flex items-center gap-2 px-4 py-2.5 bg-gradient-to-r from-primary to-blue-600 hover:from-blue-600 hover:to-blue-700 text-white font-medium rounded-lg transition-all duration-300 transform hover:scale-[1.02] focus:outline focus:outline-3 focus:outline-primary">
                        <span class="material-symbols-outlined">person_add</span>
                        <span>Registrar Profesor</span>
                    </a>
                </div>

                <div class="mb-8 max-w-md">
                    <form action="ProfesorServlet" method="GET">
                        <input type="hidden" name="accion" value="listar">
                        
                        <div class="relative group"> 
                            <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                <span class="material-symbols-outlined text-gray-500">person_search</span>
                            </div>
                            
                            <input type="text" name="txtBuscar" id="txtBuscar" 
                                   class="block w-full pl-10 pr-3 py-3 border-none rounded-lg bg-gray-100 dark:bg-gray-800 text-gray-900 dark:text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-primary/50 focus:bg-white dark:focus:bg-[#1a2233] transition-all duration-200 ease-in-out sm:text-sm shadow-inner"
                                   placeholder="Filtrar resultados..."
                                   autocomplete="off"
                                   value="<%= request.getParameter("txtBuscar") != null ? request.getParameter("txtBuscar") : "" %>">
                                   
                            <div class="absolute bottom-0 left-0 h-[2px] w-0 bg-primary transition-all duration-300 group-focus-within:w-full"></div>
                        </div>
                    </form>
                </div>
                
                <div class="bg-white dark:bg-[#1a2233] rounded-xl border border-[#dbdfe6] dark:border-gray-700 shadow-sm overflow-hidden">
                    <div class="overflow-x-auto">
                        <table class="custom-table">
                            <thead>
                                <tr>
                                    <th>Nombres</th>
                                    <th>Apellidos</th>
                                    <th>Correo</th>
                                    <th>Área Principal</th>
                                    <th>Nivel</th>
                                    <th>Estado</th>
                                    <th>Acciones</th>
                                </tr>
                            </thead>
                            <tbody id="tablaResultados">
                                <%
                                    if (lista != null && !lista.isEmpty()) {
                                        for (Profesor p : lista) {
                                %>
                                <tr>
                                    <td class="font-medium">
                                        <div class="flex items-center gap-3">
                                            <div class="size-8 rounded-full bg-purple-100 dark:bg-purple-900 flex items-center justify-center">
                                                <span class="material-symbols-outlined text-purple-600 dark:text-purple-300 text-sm">school</span>
                                            </div>
                                            <span><%= p.getNombres()%></span>
                                        </div>
                                    </td>
                                    <td><%= p.getApellidos()%></td>
                                    <td>
                                        <div class="flex items-center gap-2">
                                            <span class="material-symbols-outlined text-gray-400 text-sm">mail</span>
                                            <span class="text-blue-600 dark:text-blue-400"><%= p.getCorreo()%></span>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="status-badge bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200">
                                            <%= p.getAreaNombre() != null ? p.getAreaNombre() : "Sin área" %>
                                        </span>
                                    </td>
                                    <td>
                                        <% 
                                            String nivel = p.getNivel();
                                            String nivelBadgeClass = "bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300";
                                            
                                            if ("INICIAL".equals(nivel)) {
                                                nivelBadgeClass = "bg-sky-100 text-sky-800 dark:bg-green-900 dark:text-sky-200"; 
                                            } else if ("PRIMARIA".equals(nivel)) {
                                                nivelBadgeClass = "bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200";
                                            } else if ("SECUNDARIA".equals(nivel)) {
                                                nivelBadgeClass = "bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200";
                                            } else if ("TODOS".equals(nivel)) {
                                                nivelBadgeClass = "bg-purple-100 text-purple-800 dark:bg-purple-900 dark:text-purple-200";
                                            }
                                        %>
                                        <span class="status-badge <%= nivelBadgeClass %>">
                                            <%= nivel != null ? nivel : "Sin nivel" %>
                                        </span>
                                    </td> 
                                    <td>
                                        <% 
                                            String estado = p.getEstado();
                                            String estadoBadgeClass = "bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300";
                                            
                                            if ("ACTIVO".equals(estado)) {
                                                estadoBadgeClass = "bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200";
                                            } else if ("INACTIVO".equals(estado)) {
                                                estadoBadgeClass = "bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200";
                                            } else if ("LICENCIA".equals(estado)) {
                                                estadoBadgeClass = "bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200";
                                            } else if ("JUBILADO".equals(estado)) {
                                                estadoBadgeClass = "bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300";
                                            }
                                        %>
                                        <span class="status-badge <%= estadoBadgeClass %>">
                                            <%= estado != null ? estado : "ACTIVO" %>
                                        </span>
                                    </td>
                                    <td>
                                        <div class="flex gap-2">
                                            <a href="ProfesorServlet?accion=editar&id=<%= p.getId()%>" 
                                               class="btn-icon bg-blue-100 text-blue-600 hover:bg-blue-200 dark:bg-blue-900 dark:text-blue-300 dark:hover:bg-blue-800 focus:outline focus:outline-2 focus:outline-blue-500"
                                               title="Editar profesor"
                                               aria-label="Editar profesor <%= p.getNombres()%>">
                                                 <span class="material-symbols-outlined text-sm">edit</span>
                                            </a>
                                            <a href="ProfesorServlet?accion=ver&id=<%= p.getId()%>" 
                                               class="btn-icon bg-green-100 text-green-600 hover:bg-green-200 dark:bg-green-900 dark:text-green-300 dark:hover:bg-green-800 focus:outline focus:outline-2 focus:outline-green-500"
                                               title="Ver detalles"
                                               aria-label="Ver detalles del profesor <%= p.getNombres()%>">
                                                 <span class="material-symbols-outlined text-sm">visibility</span>
                                            </a>
                                            <a href="ProfesorServlet?accion=eliminar&id=<%= p.getId()%>" 
                                               class="btn-icon bg-red-100 text-red-600 hover:bg-red-200 dark:bg-red-900 dark:text-red-300 dark:hover:bg-red-800 focus:outline focus:outline-2 focus:outline-red-500"
                                               title="Eliminar profesor"
                                               aria-label="Eliminar profesor <%= p.getNombres()%>"
                                               onclick="return confirm('¿Estás seguro de eliminar este profesor?')">
                                                 <span class="material-symbols-outlined text-sm">delete</span>
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                                <%
                                        }
                                    } else {
                                %>
                                <tr>
                                    <td colspan="8" class="text-center py-8">
                                        <div class="flex flex-col items-center justify-center text-gray-400">
                                            <span class="material-symbols-outlined text-4xl mb-2">school</span>
                                            <p class="text-lg font-medium">No hay profesores registrados</p>
                                            <p class="text-sm">Comienza registrando un nuevo profesor</p>
                                        </div>
                                    </td>
                                </tr>
                                <% }%>
                            </tbody>
                        </table>
                    </div>
                </div>
                
                <div class="mt-6 p-4 bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg">
                    <div class="flex items-start gap-3">
                        <span class="material-symbols-outlined text-blue-600 dark:text-blue-400 mt-0.5">
                            info
                        </span>
                        <div>
                            <h4 class="font-medium text-blue-800 dark:text-blue-300">Información importante:</h4>
                            <ul class="mt-2 text-sm text-blue-700 dark:text-blue-400 space-y-1">
                                <li>• Para registrar un nuevo profesor, haz clic en "Registrar Profesor"</li>
                                <li>• Los colores de los badges indican el nivel y estado del profesor</li>
                                <li>• Para editar la información de un profesor, utiliza el botón de editar</li>
                                <li>• Ten cuidado al eliminar profesores, esta acción no se puede deshacer</li>
                                <li>• Puedes ver los detalles completos de un profesor usando el botón de "Ver detalles"</li>
                            </ul>
                        </div>
                    </div>
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
            if (size === 'large') {
                document.body.classList.add('large-text');
            } else if (size === 'larger') {
                document.body.classList.add('larger-text');
            } else if (size === 'largest') {
                document.body.classList.add('largest-text');
            }
            
            // Forzar reflow para que los cambios se apliquen inmediatamente
            document.body.offsetHeight;
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
        
        // Focus management for accessibility
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                const panel = document.querySelector('.accessibility-panel');
                if (panel.classList.contains('open')) {
                    panel.classList.remove('open');
                }
            }
            
            // Navegación por teclado en la tabla
            if (e.key === 'Tab') {
                // Asegurar que los elementos sean enfocables
                const focusableElements = document.querySelectorAll('a, button, input, select, textarea, [tabindex]:not([tabindex="-1"])');
                focusableElements.forEach(el => {
                    el.setAttribute('tabindex', '0');
                });
            }
        });
        
        // Mejorar navegación por teclado en la tabla
        document.addEventListener('DOMContentLoaded', function() {
            const tableRows = document.querySelectorAll('.custom-table tbody tr');
            tableRows.forEach((row, index) => {
                row.setAttribute('tabindex', '0');
                row.addEventListener('keydown', function(e) {
                    if (e.key === 'Enter' || e.key === ' ') {
                        e.preventDefault();
                        const firstLink = row.querySelector('a');
                        if (firstLink) {
                            firstLink.click();
                        }
                    }
                });
            });
            
            // Auto-focus en el botón de registrar si existe
            const registrarBtn = document.querySelector('a[href*="ProfesorServlet?accion=nuevo"]');
            if (registrarBtn) {
                registrarBtn.focus();
            }

            // SCRIPT PARA BÚSQUEDA EN VIVO (LETRA POR LETRA)
            const inputBuscar = document.getElementById('txtBuscar');
            const tablaResultados = document.getElementById('tablaResultados');
            let timeout = null;

            if(inputBuscar && tablaResultados) {
                inputBuscar.addEventListener('input', function() {
                    const texto = this.value;

                    // Limpiamos el reloj anterior para no saturar al servidor
                    clearTimeout(timeout);

                    // Esperamos 300ms después de que dejes de escribir para buscar
                    timeout = setTimeout(function() {
                        realizarBusqueda(texto);
                    }, 300);
                });
            }

            function realizarBusqueda(texto) {
                // Usamos fetch para llamar al Servlet sin recargar
                fetch('ProfesorServlet?accion=listar&txtBuscar=' + encodeURIComponent(texto))
                    .then(response => response.text())
                    .then(html => {
                        const parser = new DOMParser();
                        const doc = parser.parseFromString(html, 'text/html');
                        
                        // Extraemos solo el nuevo tbody de la respuesta
                        const nuevaTabla = doc.getElementById('tablaResultados');
                        
                        // Reemplazamos el tbody actual con el nuevo
                        if (nuevaTabla) {
                            tablaResultados.innerHTML = nuevaTabla.innerHTML;
                            
                            // Reaplicar navegación por teclado en las nuevas filas si es necesario
                            const rows = tablaResultados.querySelectorAll('tr');
                            rows.forEach(row => row.setAttribute('tabindex', '0'));
                        }
                    })
                    .catch(error => console.error('Error en búsqueda en vivo:', error));
            }
        });
        
        // Auto-focus en la página de carga
        window.addEventListener('load', function() {
            // Enfocar el botón de registrar si existe
            const registrarBtn = document.querySelector('a[href*="ProfesorServlet?accion=nuevo"]');
            if (registrarBtn) {
                registrarBtn.focus();
            }
        });
        
        // Toggle dark mode
        function toggleDarkMode() {
            document.documentElement.classList.toggle('dark');
        }
    </script>
</body>
</html>