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

    // --- VARIABLES AGREGADAS PARA EL NUEVO DASHBOARD ---
    int dashTotalCursos = (cursos != null) ? cursos.size() : 0;
    int dashTotalAlumnos = (request.getAttribute("totalAlumnos") != null) ? (Integer)request.getAttribute("totalAlumnos") : 0;
    int dashJustificaciones = (request.getAttribute("totalJustificaciones") != null) ? (Integer)request.getAttribute("totalJustificaciones") : 0;
    int dashMateriales = (request.getAttribute("totalMateriales") != null) ? (Integer)request.getAttribute("totalMateriales") : 0;
%>

<!DOCTYPE html>
<html lang="es">
<script>
    // Aplicar tema guardado en cookie ANTES de renderizar
    (function() {
        function getCookie(name) {
            const match = document.cookie.match(new RegExp('(^| )' + name + '=([^;]+)'));
            return match ? match[2] : null;
        }
        if (getCookie('theme') === 'dark') {
            document.documentElement.classList.add('dark');
            document.documentElement.classList.remove('light');
        }
    })();
</script>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script>
        (function() {
            function getCookie(n) { var m = document.cookie.match('(^|;) ?' + n + '=([^;]*)(;|$)'); return m ? m[2] : null; }
            if (getCookie('theme') === 'dark') document.documentElement.classList.add('dark');
        })();
    </script>
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
        <%@ include file="includes/sidebarDocente.jsp" %>
        
        <main class="flex-1 flex flex-col overflow-y-auto">
            <% request.setAttribute("pageTitle", "Panel de Profesor"); %>
            <jsp:include page="includes/header.jsp" />
            
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
                
                <div class="bg-gradient-to-r from-blue-600 to-blue-800 rounded-xl p-6 mb-8 text-white shadow-lg relative overflow-hidden">
                    <div class="absolute right-0 top-0 h-full w-1/3 bg-white/10 skew-x-12 transform origin-bottom-left"></div>
                    <div class="relative z-10">
                        <h2 class="text-2xl font-bold">Bienvenido de nuevo, <%= docente.getNombres() %></h2>
                        <p class="text-blue-100 mt-1 max-w-xl">Aquí tienes el resumen de tu actividad académica y tus cursos asignados para el periodo actual.</p>
                    </div>
                </div>
                
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
                    
                    <div class="bg-gradient-to-r from-blue-500 to-blue-700 rounded-xl p-6 shadow-lg shadow-blue-500/30 text-white hover:-translate-y-1 transition-transform duration-300 relative overflow-hidden group">
                        <div class="absolute -right-6 -top-6 h-24 w-24 rounded-full bg-white/10 group-hover:bg-white/20 transition-colors blur-xl"></div>
                        
                        <div class="relative z-10 flex justify-between items-start">
                            <div>
                                <p class="text-blue-100 text-sm font-medium opacity-90">Cursos Asignados</p>
                                <h3 class="text-4xl font-bold mt-2"><%= dashTotalCursos %></h3>
                                <span class="inline-flex mt-3 px-2 py-1 bg-white/20 rounded-lg text-xs font-semibold backdrop-blur-sm border border-white/10">
                                    Activos
                                </span>
                            </div>
                            <div class="p-3 bg-white/20 rounded-xl backdrop-blur-sm shadow-inner">
                                <span class="material-symbols-outlined text-2xl">book</span>
                            </div>
                        </div>
                    </div>
                    
                    <div class="bg-gradient-to-r from-blue-500 to-blue-700 rounded-xl p-6 shadow-lg shadow-blue-500/30 text-white hover:-translate-y-1 transition-transform duration-300 relative overflow-hidden group">
                        <div class="absolute -right-6 -top-6 h-24 w-24 rounded-full bg-white/10 group-hover:bg-white/20 transition-colors blur-xl"></div>
                        
                        <div class="relative z-10 flex justify-between items-start">
                            <div>
                                <p class="text-blue-100 text-sm font-medium opacity-90">Total Estudiantes</p>
                                <h3 class="text-4xl font-bold mt-2"><%= dashTotalAlumnos %></h3>
                                <span class="inline-flex mt-3 px-2 py-1 bg-white/20 rounded-lg text-xs font-semibold backdrop-blur-sm border border-white/10">
                                    En tus aulas
                                </span>
                            </div>
                            <div class="p-3 bg-white/20 rounded-xl backdrop-blur-sm shadow-inner">
                                <span class="material-symbols-outlined text-2xl">groups</span>
                            </div>
                        </div>
                    </div>
                    
                    <div class="bg-gradient-to-r from-blue-500 to-blue-700 rounded-xl p-6 shadow-lg shadow-blue-500/30 text-white hover:-translate-y-1 transition-transform duration-300 relative overflow-hidden group">
                        <div class="absolute -right-6 -top-6 h-24 w-24 rounded-full bg-white/10 group-hover:bg-white/20 transition-colors blur-xl"></div>
                        
                        <div class="relative z-10 flex justify-between items-start">
                            <div>
                                <p class="text-blue-100 text-sm font-medium opacity-90">Justificaciones</p>
                                <h3 class="text-4xl font-bold mt-2"><%= dashJustificaciones %></h3>
                                <span class="inline-flex mt-3 px-2 py-1 bg-white/20 rounded-lg text-xs font-semibold backdrop-blur-sm border border-white/10">
                                    Pendientes
                                </span>
                            </div>
                            <div class="p-3 bg-white/20 rounded-xl backdrop-blur-sm shadow-inner">
                                <span class="material-symbols-outlined text-2xl">warning</span>
                            </div>
                        </div>
                    </div>
                    
                    <div class="bg-gradient-to-r from-blue-500 to-blue-700 rounded-xl p-6 shadow-lg shadow-blue-500/30 text-white hover:-translate-y-1 transition-transform duration-300 relative overflow-hidden group">
                        <div class="absolute -right-6 -top-6 h-24 w-24 rounded-full bg-white/10 group-hover:bg-white/20 transition-colors blur-xl"></div>
                        
                        <div class="relative z-10 flex justify-between items-start">
                            <div>
                                <p class="text-blue-100 text-sm font-medium opacity-90">Material Didáctico</p>
                                <h3 class="text-4xl font-bold mt-2"><%= dashMateriales %></h3>
                                <span class="inline-flex mt-3 px-2 py-1 bg-white/20 rounded-lg text-xs font-semibold backdrop-blur-sm border border-white/10">
                                    Subidos
                                </span>
                            </div>
                            <div class="p-3 bg-white/20 rounded-xl backdrop-blur-sm shadow-inner">
                                <span class="material-symbols-outlined text-2xl">folder_open</span>
                            </div>
                        </div>
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
            const html = document.documentElement;
            const isDark = html.classList.contains('dark');
            if (isDark) {
                html.classList.remove('dark');
                html.classList.add('light');
                setCookie('theme', 'light', 365);
            } else {
                html.classList.add('dark');
                html.classList.remove('light');
                setCookie('theme', 'dark', 365);
            }
        }
        function setCookie(name, value, days) {
            const date = new Date();
            date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
            document.cookie = name + "=" + value + ";expires=" + date.toUTCString() + ";path=/";
        }
    </script>
</body>
</html>