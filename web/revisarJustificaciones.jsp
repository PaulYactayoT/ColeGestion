<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="modelo.*, java.util.*, java.time.*" %>
<%
    // ========================================
    // VALIDACIÓN CRÍTICA DE SESIÓN
    // ========================================
    
    // Validar sesión y rol
    String rol = (String) session.getAttribute("rol");
    Integer personaId = (Integer) session.getAttribute("personaId");
    
    System.out.println("🔍 DEBUG - revisarJustificaciones.jsp");
    System.out.println("   - Rol: " + rol);
    System.out.println("   - PersonaId: " + personaId);
    
    if (rol == null || personaId == null) {
        System.out.println("❌ ERROR: Sesión inválida - redirigiendo a login");
        response.sendRedirect("index.jsp");
        return;
    }
    
    if (!rol.equals("admin") && !rol.equals("docente")) {
        System.out.println("❌ ERROR: Acceso denegado - rol: " + rol);
        response.sendRedirect("index.jsp");
        return;
    }
    
    // ========================================
    // OBTENER PARÁMETROS
    // ========================================
    
    String cursoIdStr = request.getParameter("cursoId");
    String turnoIdStr = request.getParameter("turnoId");
    
    int cursoId = 0;
    int turnoId = 0;
    
    try {
        cursoId = cursoIdStr != null ? Integer.parseInt(cursoIdStr) : 0;
        turnoId = turnoIdStr != null ? Integer.parseInt(turnoIdStr) : 0;
    } catch (NumberFormatException e) {
        System.out.println("⚠️ Error al parsear parámetros: " + e.getMessage());
    }
    
    // ========================================
    // DAOs Y DATOS
    // ========================================
    
    JustificacionDAO justificacionDAO = new JustificacionDAO();
    CursoDAO cursoDAO = new CursoDAO();
    TurnoDAO turnoDAO = new TurnoDAO();
    
    // Obtener datos
    List<Justificacion> justificacionesPendientes = new ArrayList<>();
    if (cursoId > 0 && turnoId > 0) {
        try {
            justificacionesPendientes = justificacionDAO.obtenerJustificacionesPendientes(cursoId, turnoId);
            System.out.println("✅ Justificaciones pendientes encontradas: " + justificacionesPendientes.size());
        } catch (Exception e) {
            System.out.println("❌ Error al obtener justificaciones: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    // Obtener listas para filtros
    List<Curso> cursos = new ArrayList<>();
    try {
        cursos = cursoDAO.obtenerCursosPorDocente(personaId);
        System.out.println("✅ Cursos encontrados: " + cursos.size());
    } catch (Exception e) {
        System.out.println("❌ Error al obtener cursos: " + e.getMessage());
        e.printStackTrace();
    }
    
    List<Turno> turnos = new ArrayList<>();
    try {
        turnos = turnoDAO.listarTurnos();
        System.out.println("✅ Turnos encontrados: " + turnos.size());
    } catch (Exception e) {
        System.out.println("❌ Error al obtener turnos: " + e.getMessage());
        e.printStackTrace();
    }
    
    // Mensajes
    String mensaje = request.getParameter("mensaje");
    String tipoMensaje = request.getParameter("tipo");
    
    // Obtener el objeto docente completo
    Profesor docente = (Profesor) session.getAttribute("docente");
    String nombreUsuario = "Usuario";

    if (docente != null) {
        nombreUsuario = docente.getNombres() + " " + docente.getApellidos();
    }
%>
<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Revisar Justificaciones - San Antonio</title>
    
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
        
        /* Tamaños de texto */
        .large-text { font-size: 18px !important; }
        .larger-text { font-size: 20px !important; }
        .largest-text { font-size: 22px !important; }
        
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
        
        /* Skip to content */
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
        
        /* Badge con tamaño base más grande */
        .status-badge {
            padding: 0.35rem 0.85rem;
            border-radius: 9999px;
            font-size: 0.85rem;
            font-weight: 600;
        }
        
        /* Botón de accesibilidad */
        .accessibility-toggle {
            transition: all 0.3s ease;
        }
        
        .accessibility-toggle:hover {
            transform: scale(1.1);
        }
        
        /* Alertas */
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
            border-color: #14532d;
            color: #86efac;
        }
        
        /* Animaciones suaves */
        .transition-smooth {
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }
        
        /* Hover effects */
        .card-hover:hover {
            transform: translateY(-2px);
            box-shadow: 0 12px 24px -10px rgba(19, 91, 236, 0.3);
        }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark transition-colors duration-300">
    <a href="#main-content" class="skip-to-content">Saltar al contenido principal</a>
    
    <!-- Accessibility Panel -->
    <div class="accessibility-panel fixed top-0 right-0 h-full w-80 bg-white dark:bg-gray-800 shadow-2xl z-50 overflow-y-auto p-6">
        <div class="flex justify-between items-center mb-6">
            <h2 class="text-xl font-bold text-gray-900 dark:text-white">Accesibilidad</h2>
            <button onclick="toggleAccessibilityPanel()" class="text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200">
                <span class="material-symbols-outlined">close</span>
            </button>
        </div>
        
        <div class="space-y-6">
            <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Tamaño de texto</label>
                <div class="flex gap-2">
                    <button onclick="setTextSize('normal')" class="flex-1 px-3 py-2 bg-gray-100 dark:bg-gray-700 rounded hover:bg-gray-200 dark:hover:bg-gray-600 text-sm">Normal</button>
                    <button onclick="setTextSize('large')" class="flex-1 px-3 py-2 bg-gray-100 dark:bg-gray-700 rounded hover:bg-gray-200 dark:hover:bg-gray-600 text-sm">Grande</button>
                    <button onclick="setTextSize('larger')" class="flex-1 px-3 py-2 bg-gray-100 dark:bg-gray-700 rounded hover:bg-gray-200 dark:hover:bg-gray-600 text-sm">Más grande</button>
                </div>
            </div>
            
            <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Contraste</label>
                <div class="space-y-2">
                    <button onclick="setContrast('normal')" class="w-full px-3 py-2 bg-gray-100 dark:bg-gray-700 rounded hover:bg-gray-200 dark:hover:bg-gray-600 text-sm text-left">Normal</button>
                    <button onclick="setContrast('high')" class="w-full px-3 py-2 bg-gray-100 dark:bg-gray-700 rounded hover:bg-gray-200 dark:hover:bg-gray-600 text-sm text-left">Alto contraste</button>
                    <button onclick="setContrast('yellow')" class="w-full px-3 py-2 bg-gray-100 dark:bg-gray-700 rounded hover:bg-gray-200 dark:hover:bg-gray-600 text-sm text-left">Amarillo sobre negro</button>
                </div>
            </div>
            
            <div>
                <label class="flex items-center gap-2 cursor-pointer">
                    <input type="checkbox" id="reduceMotion" onchange="toggleMotion()" class="rounded">
                    <span class="text-sm text-gray-700 dark:text-gray-300">Reducir animaciones</span>
                </label>
            </div>
            
            <div>
                <label class="flex items-center gap-2 cursor-pointer">
                    <input type="checkbox" id="dyslexiaFont" onchange="toggleDyslexiaFont()" class="rounded">
                    <span class="text-sm text-gray-700 dark:text-gray-300">Fuente para dislexia</span>
                </label>
            </div>
            
            <div>
                <label class="flex items-center gap-2 cursor-pointer">
                    <input type="checkbox" id="beigeBackground" onchange="toggleBeigeBackground()" class="rounded">
                    <span class="text-sm text-gray-700 dark:text-gray-300">Fondo beige</span>
                </label>
            </div>
            
            <button onclick="resetAccessibility()" class="w-full px-4 py-2 bg-primary text-white rounded-lg hover:bg-blue-700">
                Restablecer todo
            </button>
        </div>
    </div>
    
    <!-- Main Container con Sidebar -->
<div class="flex h-screen overflow-hidden">
    <!-- Sidebar -->
    <aside class="w-64 flex-shrink-0 bg-white dark:bg-[#1a2233] border-r border-gray-200 dark:border-gray-700 flex flex-col justify-between">
        <div class="flex flex-col gap-6 p-6">
            <!-- Logo -->
            <div class="flex items-center gap-3">
                <div class="bg-primary size-10 rounded-lg flex items-center justify-center text-white">
                    <span class="material-symbols-outlined">school</span>
                </div>
                <div class="flex flex-col">
                    <h1 class="text-gray-900 dark:text-white text-lg font-bold leading-tight">San Antonio</h1>
                    <p class="text-gray-500 dark:text-gray-400 text-xs font-normal">Panel del Docente</p>
                </div>
            </div>
            
            <!-- Navegación -->
            <nav class="flex flex-col gap-2">
                <a class="flex items-center gap-3 px-3 py-2 rounded-lg text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors" 
                   href="DocenteDashboardServlet">
                    <span class="material-symbols-outlined">dashboard</span>
                    <span class="text-sm">Dashboard</span>
                </a>
                <a class="flex items-center gap-3 px-3 py-2 rounded-lg text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors" 
                   href="AsistenciaServlet?accion=registrar">
                    <i class="fas fa-clipboard-check"></i>
                    <span class="text-sm">Asistencias</span>
                </a>
                <a class="flex items-center gap-3 px-3 py-2 rounded-lg bg-primary/10 text-primary font-medium" 
                   href="revisarJustificaciones.jsp"
                   aria-current="page">
                    <i class="fas fa-clock"></i>
                    <span class="text-sm">Justificaciones</span>
                </a>
                <a class="flex items-center gap-3 px-3 py-2 rounded-lg text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors" 
                   href="MaterialServlet?accion=seleccionarCurso">
                    <i class="fas fa-folder"></i>
                    <span class="text-sm">Material de Apoyo</span>
                </a>
                <a class="flex items-center gap-3 px-3 py-2 rounded-lg text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors" 
                   href="DisponibilidadServlet">
                    <span class="material-symbols-outlined text-[20px]">event_available</span>
                    <span class="text-sm">Mi Disponibilidad</span>
                </a>
            </nav>
        </div>
        
        <!-- Botón Cerrar Sesión -->
        <div class="p-6 border-t border-gray-200 dark:border-gray-700">
            <a href="LogoutServlet" 
               class="flex w-full items-center justify-center gap-2 rounded-lg h-10 px-4 bg-primary text-white text-sm font-bold tracking-wide hover:bg-blue-700 transition-colors">
                <span class="material-symbols-outlined text-[18px]">logout</span>
                <span>Cerrar Sesión</span>
            </a>
        </div>
    </aside>
    
    <!-- Main Content Wrapper -->
    <main class="flex-1 flex flex-col overflow-y-auto">
        <!-- Header -->
            <header class="bg-white dark:bg-gray-900 shadow-md sticky top-0 z-10 transition-colors duration-300">
    <div class="px-8 py-3">
        <div class="flex justify-between items-center">
            <div class="flex items-center gap-3">
                <h1 class="text-xl font-bold text-gray-900 dark:text-white">Revisar Justificaciones</h1>
            </div>

            <div class="flex items-center gap-3">
                <!-- Botón Dark Mode -->
                <button onclick="toggleDarkMode()" 
                        class="p-2 rounded-lg text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
                        aria-label="Cambiar tema">
                    <span class="material-symbols-outlined dark:hidden">dark_mode</span>
                    <span class="material-symbols-outlined hidden dark:inline">light_mode</span>
                </button>
                
                <!-- Botón Accesibilidad -->
                <button onclick="toggleAccessibilityPanel()" 
                        class="p-2 rounded-lg text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors accessibility-toggle"
                        aria-label="Abrir panel de accesibilidad">
                    <span class="material-symbols-outlined">accessibility</span>
                </button>
                
                <!-- User Info con Foto -->
                <div class="flex items-center gap-3">
                    <div class="hidden md:block">
                        <span class="text-sm font-medium text-gray-900 dark:text-white text-right block"><%= nombreUsuario %></span>
                        <span class="text-xs text-gray-500 dark:text-gray-400 block text-right">(<%= rol %>)</span>
                    </div>
                    <% if (docente != null && docente.getFoto() != null && !docente.getFoto().isEmpty()) { %>
                        <div class="size-10 rounded-full bg-cover bg-center border-2 border-primary/20" 
                             style="background-image: url('uploads/<%= docente.getFoto() %>');"></div>
                    <% } else { %>
                        <div class="size-10 rounded-full border-2 border-primary/20 bg-primary flex items-center justify-center text-white font-bold">
                            <% if (docente != null) { %>
                                <%= docente.getNombres().substring(0, 1) %><%= docente.getApellidos().substring(0, 1) %>
                            <% } else { %>
                                U
                            <% } %>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
</header>
        
        <!-- Main Content -->
        <div id="main-content" class="flex-1 px-8 py-8">
        
        <!-- Main Content -->
        <main id="main-content" class="flex-1 max-w-7xl w-full mx-auto px-4 sm:px-6 lg:px-8 py-8">
            <!-- Page Header -->
            <div class="bg-gradient-to-r from-blue-500 to-blue-600 dark:from-blue-600 dark:to-blue-700 rounded-2xl p-8 mb-8 shadow-lg">
                <div class="flex items-center gap-4">
                    <div class="w-16 h-16 bg-white/20 backdrop-blur-sm rounded-xl flex items-center justify-center">
                        <span class="material-symbols-outlined text-white text-4xl">fact_check</span>
                    </div>
                    <div>
                        <h1 class="text-3xl font-bold text-white mb-2">Revisar Justificaciones</h1>
                        <p class="text-blue-100">Gestiona las justificaciones de ausencias de tus estudiantes</p>
                    </div>
                </div>
            </div>
            
            <!-- Alerts -->
            <% if (mensaje != null && !mensaje.isEmpty()) { %>
                <% if ("success".equals(tipoMensaje)) { %>
                    <div class="alert alert-success flex items-center gap-3 mb-6">
                        <span class="material-symbols-outlined">check_circle</span>
                        <span><%= mensaje %></span>
                    </div>
                <% } else { %>
                    <div class="alert alert-danger flex items-center gap-3 mb-6">
                        <span class="material-symbols-outlined">error</span>
                        <span><%= mensaje %></span>
                    </div>
                <% } %>
            <% } %>
            
            <!-- Filter Form -->
            <div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6 mb-8 transition-colors duration-300">
                <h2 class="text-xl font-bold text-gray-900 dark:text-white mb-6 flex items-center gap-2">
                    <span class="material-symbols-outlined text-primary">filter_list</span>
                    Filtrar Justificaciones
                </h2>
                
                <form method="GET" action="revisarJustificaciones.jsp">
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                        <div>
                            <label for="cursoId" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                <i class="fas fa-book text-primary"></i> Curso
                            </label>
                            <select name="cursoId" id="cursoId" required
                                    class="w-full px-4 py-2.5 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent bg-white dark:bg-gray-700 text-gray-900 dark:text-white transition-colors">
                                <option value="">-- Seleccione un curso --</option>
                                <% if (cursos != null) {
                                    for (Curso c : cursos) { %>
                                    <option value="<%= c.getId() %>" <%= c.getId() == cursoId ? "selected" : "" %>>
                                        <%= c.getNombre() %> - <%= c.getGradoNombre() %>
                                    </option>
                                <% } 
                                } %>
                            </select>
                        </div>
                        
                        <div>
                            <label for="turnoId" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                <i class="fas fa-clock text-primary"></i> Turno
                            </label>
                            <select name="turnoId" id="turnoId" required
                                    class="w-full px-4 py-2.5 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent bg-white dark:bg-gray-700 text-gray-900 dark:text-white transition-colors">
                                <option value="">-- Seleccione un turno --</option>
                                <% if (turnos != null) {
                                    for (Turno t : turnos) { %>
                                    <option value="<%= t.getId() %>" <%= t.getId() == turnoId ? "selected" : "" %>>
                                        <%= t.getNombre() %> (<%= t.getHoraInicio() %> - <%= t.getHoraFin() %>)
                                    </option>
                                <% } 
                                } %>
                            </select>
                        </div>
                    </div>
                    
                    <button type="submit" class="w-full md:w-auto px-6 py-3 bg-gradient-to-r from-primary to-blue-600 hover:from-blue-600 hover:to-blue-700 text-white font-medium rounded-lg transition-all duration-300 transform hover:scale-[1.02] focus:outline focus:outline-3 focus:outline-primary flex items-center justify-center gap-2">
                        <span class="material-symbols-outlined">search</span>
                        <span>Buscar Justificaciones</span>
                    </button>
                </form>
            </div>
            
            <!-- Justifications List -->
            <% if (cursoId > 0 && turnoId > 0) { %>
                <% if (justificacionesPendientes.isEmpty()) { %>
                    <div class="bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-xl p-12 text-center">
                        <div class="flex flex-col items-center justify-center">
                            <span class="material-symbols-outlined text-green-600 dark:text-green-400 text-6xl mb-4">
                                check_circle
                            </span>
                            <h3 class="text-2xl font-bold text-green-800 dark:text-green-300 mb-2">No hay justificaciones pendientes</h3>
                            <p class="text-green-700 dark:text-green-400">Todas las justificaciones han sido revisadas</p>
                        </div>
                    </div>
                <% } else { %>
                    <div class="mb-6">
                        <h2 class="text-2xl font-bold text-gray-900 dark:text-white flex items-center gap-2">
                            <span class="material-symbols-outlined text-primary">assignment</span>
                            Justificaciones Pendientes
                            <span class="ml-2 px-3 py-1 bg-yellow-100 dark:bg-yellow-900 text-yellow-800 dark:text-yellow-200 rounded-full text-sm font-semibold">
                                <%= justificacionesPendientes.size() %>
                            </span>
                        </h2>
                    </div>
                    
                    <div class="space-y-6">
                        <% for (Justificacion justif : justificacionesPendientes) { %>
                            <div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg overflow-hidden transition-smooth card-hover">
                                <!-- Card Header -->
                                <div class="bg-gradient-to-r from-yellow-50 to-orange-50 dark:from-yellow-900/20 dark:to-orange-900/20 p-6 border-b border-gray-200 dark:border-gray-700">
                                    <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                                        <div class="flex-1">
                                            <div class="flex items-center gap-3 mb-3">
                                                <div class="w-12 h-12 bg-blue-500 rounded-full flex items-center justify-center">
                                                    <span class="material-symbols-outlined text-white">person</span>
                                                </div>
                                                <div>
                                                    <h3 class="text-xl font-bold text-gray-900 dark:text-white"><%= justif.getAlumnoNombre() %></h3>
                                                    <p class="text-sm text-gray-600 dark:text-gray-400"><%= justif.getCursoNombre() %></p>
                                                </div>
                                            </div>
                                            
                                            <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
                                                <div class="flex items-center gap-2 text-sm">
                                                    <span class="material-symbols-outlined text-gray-500 dark:text-gray-400 text-base">calendar_today</span>
                                                    <span class="text-gray-700 dark:text-gray-300">
                                                        <strong>Fecha de Ausencia:</strong> <%= justif.getFechaAsistencia() %>
                                                    </span>
                                                </div>
                                                <div class="flex items-center gap-2 text-sm">
                                                    <span class="material-symbols-outlined text-gray-500 dark:text-gray-400 text-base">event</span>
                                                    <span class="text-gray-700 dark:text-gray-300">
                                                        <strong>Fecha de Justificación:</strong> <%= justif.getFechaJustificacionFormateada() %>
                                                    </span>
                                                </div>
                                                <div class="flex items-center gap-2 text-sm md:col-span-2">
                                                    <span class="material-symbols-outlined text-gray-500 dark:text-gray-400 text-base">account_circle</span>
                                                    <span class="text-gray-700 dark:text-gray-300">
                                                        <strong>Justificado por:</strong> <%= justif.getJustificadorNombre() %>
                                                    </span>
                                                </div>
                                            </div>
                                        </div>
                                        
                                        <div>
                                            <span class="status-badge bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200 flex items-center gap-1">
                                                <span class="material-symbols-outlined text-sm">pending</span>
                                                PENDIENTE
                                            </span>
                                        </div>
                                    </div>
                                </div>
                                
                                <!-- Card Body -->
                                <div class="p-6 space-y-4">
                                    <div>
                                        <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">
                                            <i class="fas fa-tag text-primary"></i> Tipo de Justificación
                                        </label>
                                        <div class="bg-gray-50 dark:bg-gray-700 rounded-lg p-3 text-gray-900 dark:text-white">
                                            <%= justif.getTipoJustificacion() != null ? justif.getTipoJustificacion().getDescripcion() : "No especificado" %>
                                        </div>
                                    </div>
                                    
                                    <div>
                                        <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">
                                            <i class="fas fa-file-alt text-primary"></i> Descripción
                                        </label>
                                        <div class="bg-gray-50 dark:bg-gray-700 rounded-lg p-4 text-gray-900 dark:text-white">
                                            <%= justif.getDescripcion() %>
                                        </div>
                                    </div>
                                    
                                    <% if (justif.tieneDocumento()) { %>
                                        <div>
                                            <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">
                                                <i class="fas fa-paperclip text-primary"></i> Documento Adjunto
                                            </label>
                                            <div class="bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg p-4">
                                                <a href="<%= justif.getDocumentoAdjunto() %>" target="_blank" 
                                                   class="flex items-center gap-2 text-blue-600 dark:text-blue-400 hover:text-blue-700 dark:hover:text-blue-300 font-medium transition-colors">
                                                    <span class="material-symbols-outlined">description</span>
                                                    <span><%= justif.getNombreArchivo() %> (<%= justif.getTipoArchivo() %>)</span>
                                                    <span class="material-symbols-outlined text-sm ml-auto">open_in_new</span>
                                                </a>
                                            </div>
                                        </div>
                                    <% } %>
                                </div>
                                
                                <!-- Card Actions -->
                                <div class="bg-gray-50 dark:bg-gray-900 p-6 border-t border-gray-200 dark:border-gray-700">
                                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                                        <!-- Aprobar Form -->
                                        <div class="bg-white dark:bg-gray-800 rounded-lg p-4 border-2 border-green-200 dark:border-green-800">
                                            <form method="POST" action="JustificacionServlet">
                                                <input type="hidden" name="accion" value="aprobar">
                                                <input type="hidden" name="justificacionId" value="<%= justif.getId() %>">
                                                <input type="hidden" name="cursoId" value="<%= cursoId %>">
                                                <input type="hidden" name="turnoId" value="<%= turnoId %>">
                                                
                                                <label for="obs_aprobar_<%= justif.getId() %>" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                                    Observaciones (opcional)
                                                </label>
                                                <textarea name="observaciones" id="obs_aprobar_<%= justif.getId() %>" rows="3"
                                                          class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent bg-white dark:bg-gray-700 text-gray-900 dark:text-white mb-4 transition-colors"
                                                          placeholder="Añade comentarios adicionales..."></textarea>
                                                
                                                <button type="submit" 
                                                        class="w-full px-4 py-3 bg-gradient-to-r from-green-500 to-green-600 hover:from-green-600 hover:to-green-700 text-white font-medium rounded-lg transition-all duration-300 transform hover:scale-[1.02] flex items-center justify-center gap-2">
                                                    <span class="material-symbols-outlined">check_circle</span>
                                                    <span>Aprobar Justificación</span>
                                                </button>
                                            </form>
                                        </div>
                                        
                                        <!-- Rechazar Form -->
                                        <div class="bg-white dark:bg-gray-800 rounded-lg p-4 border-2 border-red-200 dark:border-red-800">
                                            <form method="POST" action="JustificacionServlet" 
                                                  onsubmit="return validarRechazo(<%= justif.getId() %>)">
                                                <input type="hidden" name="accion" value="rechazar">
                                                <input type="hidden" name="justificacionId" value="<%= justif.getId() %>">
                                                <input type="hidden" name="cursoId" value="<%= cursoId %>">
                                                <input type="hidden" name="turnoId" value="<%= turnoId %>">
                                                
                                                <label for="obs_rechazar_<%= justif.getId() %>" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                                    Motivo del Rechazo <span class="text-red-500">*</span>
                                                </label>
                                                <textarea name="observaciones" id="obs_rechazar_<%= justif.getId() %>" rows="3" required
                                                          class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-red-500 focus:border-transparent bg-white dark:bg-gray-700 text-gray-900 dark:text-white mb-4 transition-colors"
                                                          placeholder="Explique por qué rechaza esta justificación..."></textarea>
                                                
                                                <button type="submit" 
                                                        class="w-full px-4 py-3 bg-gradient-to-r from-red-500 to-red-600 hover:from-red-600 hover:to-red-700 text-white font-medium rounded-lg transition-all duration-300 transform hover:scale-[1.02] flex items-center justify-center gap-2">
                                                    <span class="material-symbols-outlined">cancel</span>
                                                    <span>Rechazar Justificación</span>
                                                </button>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        <% } %>
                    </div>
                <% } %>
            <% } %>
            
            <!-- Info Box -->
            <div class="mt-8 bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-xl p-6">
                <div class="flex items-start gap-4">
                    <span class="material-symbols-outlined text-blue-600 dark:text-blue-400 text-3xl mt-1">
                        info
                    </span>
                    <div>
                        <h4 class="font-semibold text-blue-800 dark:text-blue-300 mb-3">Información importante:</h4>
                        <ul class="space-y-2 text-sm text-blue-700 dark:text-blue-400">
                            <li class="flex items-start gap-2">
                                <span class="material-symbols-outlined text-sm mt-0.5">check</span>
                                <span>Las justificaciones pendientes aparecerán en esta sección después de aplicar los filtros</span>
                            </li>
                            <li class="flex items-start gap-2">
                                <span class="material-symbols-outlined text-sm mt-0.5">check</span>
                                <span>Puedes aprobar o rechazar justificaciones con comentarios</span>
                            </li>
                            <li class="flex items-start gap-2">
                                <span class="material-symbols-outlined text-sm mt-0.5">check</span>
                                <span>Al rechazar una justificación, el motivo será notificado al padre de familia</span>
                            </li>
                            <li class="flex items-start gap-2">
                                <span class="material-symbols-outlined text-sm mt-0.5">check</span>
                                <span>Revisa cuidadosamente los documentos adjuntos antes de tomar una decisión</span>
                            </li>
                        </ul>
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
        });
        
        // Toggle dark mode
        function toggleDarkMode() {
            document.documentElement.classList.toggle('dark');
        }
        
        // Validation function
        function validarRechazo(justificacionId) {
            const observaciones = document.getElementById('obs_rechazar_' + justificacionId).value;
            if (!observaciones || observaciones.trim() === '') {
                alert('Debe especificar el motivo del rechazo');
                return false;
            }
            
            return confirm('¿Está seguro de rechazar esta justificación?\n\nEl padre de familia será notificado del rechazo.');
        }
    </script>
    
  </div>
</body>
</html>
