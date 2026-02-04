<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Grado" %>
<%@ page import="javax.servlet.http.HttpSession" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    Grado g = (Grado) request.getAttribute("grado");
    boolean esEditar = g != null;
%>

<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= esEditar ? "Editar Grado" : "Registrar Grado" %> - San Antonio</title>
    
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
        .large-text { 
            font-size: 20px !important; 
        }
        .larger-text { 
            font-size: 24px !important; 
        }
        .largest-text { 
            font-size: 28px !important; 
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
            class="fixed top-20 right-0 z-40 bg-primary text-white p-3 rounded-l-lg shadow-lg hover:bg-blue-700 transition-colors"
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
                    <a class="flex items-center gap-3 px-3 py-2 rounded-lg text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors" 
                       href="ProfesorServlet">
                        <i class="fas fa-chalkboard-teacher" aria-hidden="true"></i>
                        <span class="text-sm">Profesores</span>
                    </a>
                    <a class="flex items-center gap-3 px-3 py-2 rounded-lg text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors" 
                       href="CursoServlet">
                        <i class="fas fa-book" aria-hidden="true"></i>
                        <span class="text-sm">Cursos</span>
                    </a>
                    <a class="flex items-center gap-3 px-3 py-2 rounded-lg bg-primary/10 text-primary font-medium" 
                       href="GradoServlet"
                       aria-current="page">
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
                <form action="LogoutServlet" method="post" class="w-full">
                    <button type="submit" 
                            class="flex w-full items-center justify-center gap-2 rounded-lg h-10 px-4 bg-primary text-white text-sm font-bold tracking-wide hover:bg-blue-700 transition-colors">
                        <span class="material-symbols-outlined text-[18px]" aria-hidden="true">logout</span>
                        <span>Cerrar Sesión</span>
                    </button>
                </form>
            </div>
        </aside>
        
        <!-- Main Content -->
        <main class="flex-1 flex flex-col overflow-y-auto">
            <!-- TopNavBar -->
            <header class="flex items-center justify-between bg-white dark:bg-[#1a2233] border-b border-[#f0f2f4] dark:border-gray-700 px-8 py-3 sticky top-0 z-10">
                <div class="flex items-center gap-4 flex-1">
                    <div class="flex items-center gap-3">
                        <a href="GradoServlet" class="text-primary hover:underline">
                            <span class="material-symbols-outlined">arrow_back</span>
                        </a>
                        <h1 class="text-xl font-bold text-[#111318] dark:text-white">
                            <%= esEditar ? "Editar Grado" : "Registrar Nuevo Grado" %>
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
            
            <!-- Form Content -->
            <div class="p-8 max-w-4xl mx-auto w-full">
                <!-- Form Card -->
                <div class="bg-white dark:bg-[#1a2233] rounded-xl border border-[#dbdfe6] dark:border-gray-700 shadow-sm p-8">
                    <div class="flex items-center gap-4 mb-8">
                        <div class="size-16 rounded-xl bg-gradient-to-r from-red-500 to-red-600 flex items-center justify-center">
                            <i class="fas fa-layer-group text-white text-2xl"></i>
                        </div>
                        <div>
                            <h2 class="text-2xl font-bold text-[#111318] dark:text-white">
                                <%= esEditar ? "Editar Información del Grado" : "Registrar Nuevo Grado" %>
                            </h2>
                            <p class="text-[#616f89] dark:text-gray-400 mt-1">
                                <%= esEditar ? "Actualiza la información del grado académico" : "Completa los datos para registrar un nuevo grado" %>
                            </p>
                        </div>
                    </div>
                    
                    <form action="GradoServlet" method="post">
                        <input type="hidden" name="id" value="<%= esEditar ? g.getId() : ""%>">
                        
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <!-- Nombre del Grado -->
                            <div class="space-y-2">
                                <label for="nombre" class="block text-sm font-medium text-[#111318] dark:text-white">
                                    Nombre del Grado *
                                </label>
                                <div class="relative">
                                    <span class="absolute left-3 top-3 material-symbols-outlined text-gray-400">
                                        bookmark
                                    </span>
                                    <input type="text" 
                                           id="nombre"
                                           name="nombre" 
                                           value="<%= esEditar ? g.getNombre() : ""%>"
                                           class="pl-10 w-full p-3 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-gray-800 focus:ring-2 focus:ring-red-500 focus:border-transparent"
                                           placeholder="Ej: Primer Grado de Primaria"
                                           required
                                           aria-required="true">
                                </div>
                                <p class="text-xs text-gray-500 dark:text-gray-400">
                                    Ej: "Primer Grado", "Segundo Grado de Secundaria"
                                </p>
                            </div>
                            
                            <!-- Nivel Educativo -->
                            <div class="space-y-2">
                                <label for="nivel" class="block text-sm font-medium text-[#111318] dark:text-white">
                                    Nivel Educativo *
                                </label>
                                <div class="relative">
                                    <span class="absolute left-3 top-3 material-symbols-outlined text-gray-400">
                                        school
                                    </span>
                                    <select id="nivel"
                                            name="nivel" 
                                            class="pl-10 w-full p-3 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-gray-800 focus:ring-2 focus:ring-red-500 focus:border-transparent appearance-none"
                                            required
                                            aria-required="true">
                                        <option value="" disabled selected>-- Selecciona un nivel --</option>
                                        <option value="Inicial" <%= esEditar && g.getNivel().equals("Inicial") ? "selected" : ""%>>
                                            Educación Inicial
                                        </option>
                                        <option value="Primaria" <%= esEditar && g.getNivel().equals("Primaria") ? "selected" : ""%>>
                                            Educación Primaria
                                        </option>
                                        <option value="Secundaria" <%= esEditar && g.getNivel().equals("Secundaria") ? "selected" : ""%>>
                                            Educación Secundaria
                                        </option>
                                    </select>
                                    <span class="absolute right-3 top-3 material-symbols-outlined text-gray-400">
                                        arrow_drop_down
                                    </span>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Botones de acción -->
                        <div class="flex flex-col md:flex-row gap-4 mt-8 pt-8 border-t border-gray-200 dark:border-gray-700">
                            <button type="submit" 
                                    class="flex-1 py-3 px-6 bg-gradient-to-r from-red-600 to-red-700 hover:from-red-700 hover:to-red-800 text-white font-bold rounded-lg transition-all duration-300 transform hover:scale-[1.02] focus:outline focus:outline-3 focus:outline-red-500">
                                <div class="flex items-center justify-center gap-2">
                                    <span class="material-symbols-outlined">
                                        <%= esEditar ? "save" : "add" %>
                                    </span>
                                    <span><%= esEditar ? "Actualizar Grado" : "Registrar Grado" %></span>
                                </div>
                            </button>
                            
                            <a href="GradoServlet" 
                               class="flex-1 py-3 px-6 bg-gray-100 dark:bg-gray-800 hover:bg-gray-200 dark:hover:bg-gray-700 text-gray-800 dark:text-gray-300 font-bold rounded-lg text-center transition-colors focus:outline focus:outline-3 focus:outline-gray-500">
                                <div class="flex items-center justify-center gap-2">
                                    <span class="material-symbols-outlined">close</span>
                                    <span>Cancelar</span>
                                </div>
                            </a>
                        </div>
                    </form>
                    
                    <!-- Información adicional -->
                    <div class="mt-8 p-4 bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg">
                        <div class="flex items-start gap-3">
                            <span class="material-symbols-outlined text-blue-600 dark:text-blue-400 mt-0.5">
                                info
                            </span>
                            <div>
                                <h4 class="font-medium text-blue-800 dark:text-blue-300">Información importante:</h4>
                                <ul class="mt-2 text-sm text-blue-700 dark:text-blue-400 space-y-1">
                                    <li>• Los campos marcados con * son obligatorios</li>
                                    <li>• Verifique que el nombre del grado no exista previamente</li>
                                    <li>• Cada nivel puede tener múltiples grados</li>
                                    <li>• Los grados no pueden eliminarse si tienen estudiantes asignados</li>
                                </ul>
                            </div>
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
        
        // Auto-focus on first input when page loads
        window.addEventListener('load', function() {
            document.getElementById('nombre').focus();
        });
    </script>
</body>
</html>