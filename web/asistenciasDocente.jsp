<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Curso, java.util.List" %>
<%@ page import="modelo.Profesor" %>
<%
    List<Curso> cursos = (List<Curso>) request.getAttribute("misCursos");
    String mensaje = (String) request.getParameter("mensaje");
    String error = (String) request.getParameter("error");
    
    // Obtener el objeto docente completo
    Profesor docente = (Profesor) session.getAttribute("docente");
    String nombreUsuario = "Usuario";
    String rol = "docente";
    
    if (docente != null) {
        nombreUsuario = docente.getNombres() + " " + docente.getApellidos();
    }
%>
<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Asistencias - San Antonio</title>
    
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
    
    <!-- Main Container -->
    <div class="flex flex-col min-h-screen">
        <!-- Header -->
        <header class="bg-white dark:bg-gray-900 shadow-md sticky top-0 z-40 transition-colors duration-300">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                <div class="flex justify-between items-center py-4">
                    <div class="flex items-center gap-4">
                        <!-- Botón de regreso -->
                        <a href="DocenteDashboardServlet" 
                           class="p-2 rounded-lg bg-gray-100 dark:bg-gray-800 hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors flex items-center justify-center"
                           title="Volver al Panel">
                            <span class="material-symbols-outlined text-gray-700 dark:text-gray-300">arrow_back</span>
                        </a>
                        
                        <div class="w-12 h-12 bg-gradient-to-br from-primary to-blue-600 rounded-xl flex items-center justify-center">
                            <span class="material-symbols-outlined text-white text-2xl">school</span>
                        </div>
                        <div>
                            <h1 class="text-2xl font-bold text-gray-900 dark:text-white">San Antonio</h1>
                            <p class="text-sm text-gray-600 dark:text-gray-400">Sistema de Gestión Escolar</p>
                        </div>
                    </div>
                    
                    <div class="flex items-center gap-3">
                    <!-- User Info con Foto -->
                    <div class="flex items-center gap-3 bg-gray-100 dark:bg-gray-800 px-4 py-2 rounded-lg">
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
                        <div class="hidden md:block">
                            <span class="text-sm font-medium text-gray-900 dark:text-white"><%= nombreUsuario %></span>
                            <span class="text-xs text-gray-500 dark:text-gray-400 block">(<%= rol %>)</span>
                        </div>
                    </div>
                        
                        <!-- Dark Mode Toggle -->
                        <button onclick="toggleDarkMode()" class="p-2 rounded-lg bg-gray-100 dark:bg-gray-800 hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors" aria-label="Toggle dark mode">
                            <span class="material-symbols-outlined text-gray-700 dark:text-gray-300">dark_mode</span>
                        </button>
                        
                        <!-- Accessibility Toggle -->
                        <button onclick="toggleAccessibilityPanel()" class="accessibility-toggle p-2 rounded-lg bg-gray-100 dark:bg-gray-800 hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors" aria-label="Abrir panel de accesibilidad">
                            <span class="material-symbols-outlined text-gray-700 dark:text-gray-300">accessibility</span>
                        </button>
                        
                        <!-- Logout -->
                        <a href="LogoutServlet" class="flex items-center gap-2 px-4 py-2 bg-red-500 hover:bg-red-600 text-white rounded-lg transition-colors">
                            <span class="material-symbols-outlined text-sm">logout</span>
                            <span class="hidden sm:inline text-sm">Salir</span>
                        </a>
                    </div>
                </div>
            </div>
        </header>
        
        <!-- Main Content -->
        <main id="main-content" class="flex-1 max-w-7xl w-full mx-auto px-4 sm:px-6 lg:px-8 py-8">
            <!-- Page Header -->
            <div class="bg-gradient-to-r from-cyan-500 to-blue-600 dark:from-cyan-600 dark:to-blue-700 rounded-2xl p-8 mb-8 shadow-lg">
                <div class="flex items-center gap-4">
                    <div class="w-16 h-16 bg-white/20 backdrop-blur-sm rounded-xl flex items-center justify-center">
                        <span class="material-symbols-outlined text-white text-4xl">fact_check</span>
                    </div>
                    <div>
                        <h1 class="text-3xl font-bold text-white mb-2">Gestión de Asistencias</h1>
                        <p class="text-cyan-100">Administra las asistencias de tus cursos</p>
                    </div>
                </div>
            </div>
            
            <!-- Alerts -->
            <% if (mensaje != null && !mensaje.isEmpty()) { %>
                <div class="alert alert-success flex items-center gap-3 mb-6">
                    <span class="material-symbols-outlined">check_circle</span>
                    <span><%= mensaje %></span>
                </div>
            <% } %>
            
            <% if (error != null && !error.isEmpty()) { %>
                <div class="alert alert-danger flex items-center gap-3 mb-6">
                    <span class="material-symbols-outlined">error</span>
                    <span><%= error %></span>
                </div>
            <% } %>
            
            <!-- Cursos Grid -->
            <div class="mb-8">
                <h2 class="text-2xl font-bold text-gray-900 dark:text-white mb-6 flex items-center gap-2">
                    <span class="material-symbols-outlined text-primary">menu_book</span>
                    Mis Cursos
                </h2>
                
                <% if (cursos != null && !cursos.isEmpty()) { %>
                    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                        <% for (Curso curso : cursos) { %>
                            <div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg overflow-hidden transition-smooth card-hover">
                                <!-- Card Header -->
                                <div class="bg-gradient-to-r from-blue-50 to-cyan-50 dark:from-blue-900/20 dark:to-cyan-900/20 p-6 border-b border-gray-200 dark:border-gray-700">
                                    <div class="flex items-center gap-3 mb-3">
                                        <div class="w-12 h-12 bg-gradient-to-br from-primary to-blue-600 rounded-lg flex items-center justify-center">
                                            <span class="material-symbols-outlined text-white text-2xl">book</span>
                                        </div>
                                        <div class="flex-1">
                                            <h3 class="font-bold text-lg text-gray-900 dark:text-white"><%= curso.getNombre() %></h3>
                                            <p class="text-sm text-gray-600 dark:text-gray-400"><%= curso.getGradoNombre() %></p>
                                        </div>
                                    </div>
                                    
                                    <div class="flex items-center gap-2 text-sm text-gray-700 dark:text-gray-300">
                                        <span class="material-symbols-outlined text-primary text-base">star</span>
                                        <span><strong>Créditos:</strong> <%= curso.getCreditos() %></span>
                                    </div>
                                </div>
                                
                                <!-- Card Actions -->
                                <div class="p-4 space-y-2">
                                    <a href="AsistenciaServlet?accion=verCurso&curso_id=<%= curso.getId() %>" 
                                       class="flex items-center justify-center gap-2 px-4 py-2.5 bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200 font-medium rounded-lg hover:bg-blue-200 dark:hover:bg-blue-800 transition-all w-full">
                                        <span class="material-symbols-outlined text-sm">list</span>
                                        <span class="text-sm">Ver Asistencias</span>
                                    </a>
                                    <a href="registrarAsistencia.jsp?curso_id=<%= curso.getId() %>" 
                                       class="flex items-center justify-center gap-2 px-4 py-2.5 bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200 font-medium rounded-lg hover:bg-green-200 dark:hover:bg-green-800 transition-all w-full">
                                        <span class="material-symbols-outlined text-sm">add_circle</span>
                                        <span class="text-sm">Registrar Asistencia</span>
                                    </a>
                                </div>
                            </div>
                        <% } %>
                    </div>
                <% } else { %>
                    <div class="bg-cyan-50 dark:bg-cyan-900/20 border border-cyan-200 dark:border-cyan-800 rounded-xl p-12 text-center">
                        <div class="flex flex-col items-center justify-center">
                            <span class="material-symbols-outlined text-cyan-600 dark:text-cyan-400 text-6xl mb-4">
                                info
                            </span>
                            <h3 class="text-2xl font-bold text-cyan-800 dark:text-cyan-300 mb-2">No tienes cursos asignados</h3>
                            <p class="text-cyan-700 dark:text-cyan-400">Contacta con administración para asignarte cursos.</p>
                        </div>
                    </div>
                <% } %>
            </div>
            
            <!-- Acciones Adicionales -->
            <div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6 transition-colors duration-300">
                <h2 class="text-xl font-bold text-gray-900 dark:text-white mb-6 flex items-center gap-2">
                    <span class="material-symbols-outlined text-primary">settings</span>
                    Otras Acciones
                </h2>
                
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <a href="reportesAsistencia.jsp" 
                       class="flex items-center gap-3 px-6 py-4 bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 text-white font-medium rounded-lg transition-all duration-300 transform hover:scale-[1.02] shadow-md">
                        <span class="material-symbols-outlined text-2xl">bar_chart</span>
                        <div>
                            <div class="font-semibold">Ver Reportes</div>
                            <div class="text-xs text-blue-100">Estadísticas y análisis</div>
                        </div>
                    </a>
                    
                    <a href="JustificacionServlet?accion=pending" 
                       class="flex items-center gap-3 px-6 py-4 bg-gradient-to-r from-yellow-500 to-orange-500 hover:from-yellow-600 hover:to-orange-600 text-white font-medium rounded-lg transition-all duration-300 transform hover:scale-[1.02] shadow-md">
                        <span class="material-symbols-outlined text-2xl">schedule</span>
                        <div>
                            <div class="font-semibold">Justificaciones Pendientes</div>
                            <div class="text-xs text-yellow-100">Revisar solicitudes</div>
                        </div>
                    </a>
                </div>
            </div>
            
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
                                <span>Selecciona un curso para ver o registrar asistencias</span>
                            </li>
                            <li class="flex items-start gap-2">
                                <span class="material-symbols-outlined text-sm mt-0.5">check</span>
                                <span>Puedes consultar reportes detallados de asistencia por curso</span>
                            </li>
                            <li class="flex items-start gap-2">
                                <span class="material-symbols-outlined text-sm mt-0.5">check</span>
                                <span>Revisa las justificaciones pendientes regularmente</span>
                            </li>
                            <li class="flex items-start gap-2">
                                <span class="material-symbols-outlined text-sm mt-0.5">check</span>
                                <span>Mantén actualizado el registro de asistencias diariamente</span>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>
        </main>
        
        <!-- Footer -->
        <footer class="bg-white dark:bg-gray-900 border-t border-gray-200 dark:border-gray-700 mt-12 transition-colors duration-300">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
                <p class="text-center text-sm text-gray-600 dark:text-gray-400">
                    © 2025 Sistema de Asistencia Escolar - San Antonio. Todos los derechos reservados.
                </p>
            </div>
        </footer>
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

