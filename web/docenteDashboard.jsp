<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Profesor, modelo.Curso, java.util.List" %>
<%@ page import="modelo.AsistenciaDAO, java.util.Map, java.util.HashMap" %>
<%
    Profesor docente = (Profesor) session.getAttribute("docente");
    List<Curso> cursos = (List<Curso>) request.getAttribute("misCursos");

    if (docente == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    if (cursos == null) {
        response.sendRedirect("DocenteDashboardServlet");
        return;
    }

    AsistenciaDAO asistenciaDAO = new AsistenciaDAO();
    Map<Integer, Map<String, Object>> estadisticasCursos = new HashMap<>();
    
    // Obtener fecha de hoy en formato yyyy-MM-dd
    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
    String fechaHoy = sdf.format(new java.util.Date());

    if (cursos != null && !cursos.isEmpty()) {
        for (Curso curso : cursos) {
            // Obtener estadísticas reales desde la base de datos
            Map<String, Object> stats = asistenciaDAO.obtenerEstadisticasHoy(curso.getId(), fechaHoy);
            estadisticasCursos.put(curso.getId(), stats);
        }
    }

    String mensaje = (String) session.getAttribute("mensaje");
    String error = (String) session.getAttribute("error");

    if (mensaje != null) {
        session.removeAttribute("mensaje");
    }
    if (error != null) {
        session.removeAttribute("error");
    }
%>

<!DOCTYPE html>
<html class="light" lang="es">

<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panel de Profesor - San Antonio</title>
    
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
            border-color: #166534;
            color: #86efac;
        }
        
        /* Cards de cursos */
        .curso-card {
            background: white;
            border-radius: 1rem;
            padding: 1.5rem;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            transition: all 0.3s ease;
            border: 1px solid #e5e7eb;
        }
        
        .curso-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.15);
        }
        
        .dark .curso-card {
            background: #1a2233;
            border-color: #374151;
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
                        <p class="text-[#616f89] dark:text-gray-400 text-xs font-normal">Panel de Profesor</p>
                    </div>
                </div>
                
                 <nav class="flex flex-col gap-2" aria-label="Navegación principal">
                    <a class="flex items-center gap-3 px-3 py-2 rounded-lg bg-primary/10 text-primary font-medium" 
                       href="DocenteDashboardServlet"
                       aria-current="page">
                        <span class="material-symbols-outlined">dashboard</span>
                        <span class="text-sm">Dashboard</span>
                    </a>
                    <a class="flex items-center gap-3 px-3 py-2 rounded-lg text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors" 
                       href="AsistenciaServlet?accion=registrar">
                        <i class="fas fa-clipboard-check" aria-hidden="true"></i>
                        <span class="text-sm">Asistencias</span>
                    </a>
                    <a class="flex items-center gap-3 px-3 py-2 rounded-lg text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors" 
                       href="revisarJustificaciones.jsp">
                        <i class="fas fa-clock" aria-hidden="true"></i>
                        <span class="text-sm">Justificaciones</span>
                    </a>
                    <a class="flex items-center gap-3 px-3 py-2 rounded-lg text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors" 
                       href="MaterialServlet?accion=seleccionarCurso">
                        <i class="fas fa-folder" aria-hidden="true"></i>
                        <span class="text-sm">Material de Apoyo</span>
                    </a>
                    
                    <a class="flex items-center gap-3 px-3 py-2 rounded-lg text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors" 
                       href="DisponibilidadServlet">
                        <span class="material-symbols-outlined text-[20px]">event_available</span>
                        <span class="text-sm">Mi Disponibilidad</span>
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
                            <span class="material-symbols-outlined align-middle mr-2">speed</span>
                            Panel de Profesor
                        </h1>
                    </div>
                </div>
                
                <div class="flex items-center gap-4 ml-8">
                    <!-- Botón Dark Mode -->
                    <button onclick="toggleDarkMode()" 
                            class="p-2 text-[#616f89] dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg transition-colors"
                            aria-label="Cambiar tema">
                        <span class="material-symbols-outlined dark:hidden">dark_mode</span>
                        <span class="material-symbols-outlined hidden dark:inline">light_mode</span>
                    </button>
                    
                    <button class="p-2 text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg relative"
                            aria-label="Notificaciones">
                        <span class="material-symbols-outlined">notifications</span>
                        <span class="absolute top-2 right-2 size-2 bg-red-500 rounded-full border-2 border-white"></span>
                    </button>
                    
                    <div class="h-8 w-[1px] bg-gray-200 dark:bg-gray-700 mx-2" aria-hidden="true"></div>
                    
                    <div class="flex items-center gap-3">
                        <div class="hidden md:block text-right">
                            <p class="text-sm font-medium text-[#111318] dark:text-white">
                                <%= docente.getNombres()%> <%= docente.getApellidos()%>
                            </p>
                            <p class="text-xs text-[#616f89] dark:text-gray-400">Profesor</p>
                        </div>
                        <% if (docente.getFoto() != null && !docente.getFoto().isEmpty()) { %>
                            <div class="size-10 rounded-full bg-cover bg-center border-2 border-primary/20" 
                                 style="background-image: url('uploads/<%= docente.getFoto() %>');"
                                 aria-label="Foto de perfil del docente">
                            </div>
                        <% } else { %>
                            <div class="size-10 rounded-full border-2 border-primary/20 bg-primary flex items-center justify-center text-white font-bold" 
                                 aria-label="Foto de perfil del docente">
                                <%= docente.getNombres().substring(0, 1) %><%= docente.getApellidos().substring(0, 1) %>
                            </div>
                        <% } %>
                    </div>
                </div>
            </header>
            
            <div class="p-8">
                <% if (error != null) { %>
                <div class="alert alert-danger mb-6" role="alert">
                    <div class="flex items-center gap-2">
                        <i class="fas fa-exclamation-circle"></i>
                        <strong>Error:</strong> <%= error %>
                    </div>
                </div>
                <% } %>
                
                <% if (mensaje != null) { %>
                <div class="alert alert-success mb-6" role="alert">
                    <div class="flex items-center gap-2">
                        <i class="fas fa-check-circle"></i>
                        <strong>Éxito:</strong> <%= mensaje %>
                    </div>
                </div>
                <% } %>
                
                <div class="bg-gradient-to-r from-primary to-blue-600 rounded-xl p-6 mb-6 shadow-lg">
                    <h3 class="text-white text-xl font-bold mb-4 flex items-center gap-2">
                        <span class="material-symbols-outlined">fact_check</span>
                        Módulo de Gestión Académica
                    </h3>
                    
                    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                        
                        <a href="AsistenciaServlet?accion=registrar" 
                           class="flex items-center justify-center gap-2 px-4 py-3 bg-white text-primary font-medium rounded-lg hover:bg-gray-50 transition-all duration-300 transform hover:scale-[1.02] focus:outline focus:outline-3 focus:outline-white">
                            <span class="material-symbols-outlined">add_circle</span>
                            <span>Tomar Asistencia</span>
                        </a>
                        
                        <a href="revisarJustificaciones.jsp" 
                           class="flex items-center justify-center gap-2 px-4 py-3 bg-yellow-400 text-gray-900 font-medium rounded-lg hover:bg-yellow-300 transition-all duration-300 transform hover:scale-[1.02] focus:outline focus:outline-3 focus:outline-white">
                            <span class="material-symbols-outlined">schedule</span>
                            <span>Justificaciones</span>
                        </a>
                        
                        <a href="MaterialServlet?accion=seleccionarCurso" 
                           class="flex items-center justify-center gap-2 px-4 py-3 bg-purple-600 text-white font-medium rounded-lg hover:bg-purple-700 transition-all duration-300 transform hover:scale-[1.02] focus:outline focus:outline-3 focus:outline-white">
                            <span class="material-symbols-outlined">folder</span>
                            <span>Material Apoyo</span>
                        </a>

                        <a href="DisponibilidadServlet" 
                           class="flex items-center justify-center gap-2 px-4 py-3 bg-teal-500 text-white font-medium rounded-lg hover:bg-teal-600 transition-all duration-300 transform hover:scale-[1.02] focus:outline focus:outline-3 focus:outline-white">
                            <span class="material-symbols-outlined">event_available</span>
                            <span>Mi Disponibilidad</span>
                        </a>

                    </div>
                </div>
                
                <%
                    if (cursos != null && !cursos.isEmpty()) {
                %>
                <div class="mb-6">
                    <h2 class="text-2xl font-bold text-[#111318] dark:text-white mb-4">Mis Cursos Asignados</h2>
                    <p class="text-[#616f89] dark:text-gray-400 mb-6">Gestiona tus cursos y realiza seguimiento de tus estudiantes</p>
                </div>
                
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    <%
                        for (Curso c : cursos) {
                            Map<String, Object> stats = estadisticasCursos.get(c.getId());
                    %>
                    <div class="curso-card">
                        <div class="flex items-center gap-3 mb-4 pb-3 border-b border-gray-200 dark:border-gray-700">
                            <div class="size-12 rounded-lg bg-blue-100 dark:bg-blue-900 flex items-center justify-center">
                                <span class="material-symbols-outlined text-blue-600 dark:text-blue-300 text-2xl">book</span>
                            </div>
                            <div class="flex-1">
                                <h3 class="font-bold text-lg text-[#111318] dark:text-white"><%= c.getNombre()%></h3>
                                <p class="text-sm text-[#616f89] dark:text-gray-400"><%= c.getGradoNombre()%></p>
                            </div>
                        </div>
                        
                        <% if (stats != null) { %>
                        <div class="bg-gray-50 dark:bg-gray-800 rounded-lg p-3 mb-4">
                            <p class="text-xs text-gray-600 dark:text-gray-400 mb-2 flex items-center gap-1">
                                <span class="material-symbols-outlined text-sm">calendar_today</span>
                                Asistencia Hoy
                            </p>
                            <div class="flex gap-2 mb-2">
                                <span class="status-badge bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200">
                                    <i class="fas fa-check-circle"></i> <%= stats.get("presentesHoy")%> Presentes
                                </span>
                                <span class="status-badge bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200">
                                    <i class="fas fa-times-circle"></i> <%= stats.get("ausentesHoy")%> Ausentes
                                </span>
                            </div>
                            <div class="flex items-center gap-2">
                                <div class="flex-1 bg-gray-200 dark:bg-gray-700 rounded-full h-2">
                                    <div class="bg-blue-600 h-2 rounded-full" style="width: <%= stats.get("porcentajeAsistencia")%>%"></div>
                                </div>
                                <span class="text-xs font-bold text-blue-600 dark:text-blue-400"><%= stats.get("porcentajeAsistencia")%>%</span>
                            </div>
                        </div>
                        <% } %>
                        
                        <div class="space-y-2">
                            <a href="TareaServlet?accion=ver&curso_id=<%= c.getId()%>" 
                               class="flex items-center justify-center gap-2 px-4 py-2 bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-200 font-medium rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 transition-all w-full">
                                <i class="fas fa-tasks"></i>
                                <span class="text-sm">Gestionar Tareas</span>
                            </a>
                            <a href="NotaServlet?curso_id=<%= c.getId()%>" 
                               class="flex items-center justify-center gap-2 px-4 py-2 bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200 font-medium rounded-lg hover:bg-blue-200 dark:hover:bg-blue-800 transition-all w-full">
                                <i class="fas fa-pen"></i>
                                <span class="text-sm">Gestionar Notas</span>
                            </a>
                            <a href="ObservacionServlet?accion=listar&curso_id=<%= c.getId()%>" 
                               class="flex items-center justify-center gap-2 px-4 py-2 bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200 font-medium rounded-lg hover:bg-green-200 dark:hover:bg-green-800 transition-all w-full">
                                <i class="fas fa-comment"></i>
                                <span class="text-sm">Gestionar Observaciones</span>
                            </a>
                            <a href="AsistenciaServlet?accion=registrar&curso_id=<%= c.getId()%>" 
                               class="flex items-center justify-center gap-2 px-4 py-2 bg-cyan-100 text-cyan-800 dark:bg-cyan-900 dark:text-cyan-200 font-medium rounded-lg hover:bg-cyan-200 dark:hover:bg-cyan-800 transition-all w-full">
                                <i class="fas fa-clipboard-list"></i>
                                <span class="text-sm">Gestionar Asistencias</span>
                            </a>
                        </div>
                    </div>
                    <%
                        }
                    %>
                </div>
                <%
                    } else {
                %>
                <div class="bg-cyan-50 dark:bg-cyan-900/20 border border-cyan-200 dark:border-cyan-800 rounded-xl p-8 text-center">
                    <div class="flex flex-col items-center justify-center">
                        <span class="material-symbols-outlined text-cyan-600 dark:text-cyan-400 text-6xl mb-4">
                            info
                        </span>
                        <h3 class="text-xl font-bold text-cyan-800 dark:text-cyan-300 mb-2">No tienes cursos asignados</h3>
                        <p class="text-cyan-700 dark:text-cyan-400 mb-4">Contacta con administración para asignarte cursos.</p>
                        <a href="DocenteDashboardServlet" 
                           class="flex items-center gap-2 px-6 py-3 bg-gradient-to-r from-primary to-blue-600 hover:from-blue-600 hover:to-blue-700 text-white font-medium rounded-lg transition-all duration-300 transform hover:scale-[1.02] focus:outline focus:outline-3 focus:outline-primary">
                            <span class="material-symbols-outlined">refresh</span>
                            <span>Recargar</span>
                        </a>
                    </div>
                </div>
                <%
                    }
                %>
                
                <div class="mt-6 p-4 bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg">
                    <div class="flex items-start gap-3">
                        <span class="material-symbols-outlined text-blue-600 dark:text-blue-400 mt-0.5">
                            info
                        </span>
                        <div>
                            <h4 class="font-medium text-blue-800 dark:text-blue-300">Información importante:</h4>
                            <ul class="mt-2 text-sm text-blue-700 dark:text-blue-400 space-y-1">
                                <li>• Las justificaciones pendientes aparecerán en la sección correspondiente</li>
                                <li>• Puedes aprobar o rechazar justificaciones con comentarios</li>
                                <li>• Revisa las asistencias regularmente para mantener el control</li>
                                <li>• Los materiales de apoyo están disponibles para todos tus cursos</li>
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
    </script>
</body>
</html>
