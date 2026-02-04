<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page import="java.util.*" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    // Datos de ejemplo para grados
    List<Map<String, String>> grados = new ArrayList<>();
    Map<String, String> g1 = new HashMap<>();
    g1.put("nombre", "Primer Grado");
    g1.put("seccion", "A");
    g1.put("estudiantes", "30");
    grados.add(g1);
    
    Map<String, String> g2 = new HashMap<>();
    g2.put("nombre", "Segundo Grado");
    g2.put("seccion", "B");
    g2.put("estudiantes", "28");
    grados.add(g2);
    
    Map<String, String> g3 = new HashMap<>();
    g3.put("nombre", "Tercer Grado");
    g3.put("seccion", "C");
    g3.put("estudiantes", "32");
    grados.add(g3);
    
    Map<String, String> g4 = new HashMap<>();
    g4.put("nombre", "Cuarto Grado");
    g4.put("seccion", "A");
    g4.put("estudiantes", "25");
    grados.add(g4);
    
    Map<String, String> g5 = new HashMap<>();
    g5.put("nombre", "Quinto Grado");
    g5.put("seccion", "B");
    g5.put("estudiantes", "29");
    grados.add(g5);
    
    // Obtener parámetro de búsqueda
    String busqueda = request.getParameter("busqueda");
    List<Map<String, String>> resultados = new ArrayList<>();
    
    if (busqueda != null && !busqueda.trim().isEmpty()) {
        String busquedaLower = busqueda.toLowerCase();
        for (Map<String, String> grado : grados) {
            if (grado.get("nombre").toLowerCase().contains(busquedaLower) || 
                grado.get("seccion").toLowerCase().contains(busquedaLower)) {
                resultados.add(grado);
            }
        }
    }
%>

<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>San Antonio Admin Dashboard</title>
    
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
        
        /* Mejoras de accesibilidad del primer dashboard */
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
                        <p class="text-[#616f89] dark:text-gray-400 text-xs font-normal">Panel de Control</p>
                    </div>
                </div>
                
                <!-- Navigation -->
                <nav class="flex flex-col gap-2" aria-label="Navegación principal">
                    <a class="flex items-center gap-3 px-3 py-2 rounded-lg bg-primary/10 text-primary font-medium" 
                       href="#" 
                       aria-current="page">
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
                    <form action="dashboard.jsp" method="get" class="w-full max-w-md">
                        <label for="search-input" class="sr-only">Buscar</label>
                        <div class="flex items-center bg-[#f0f2f4] dark:bg-gray-800 rounded-lg px-3 py-1.5 w-full">
                            <span class="material-symbols-outlined text-[#616f89]" aria-hidden="true">search</span>
                            <input id="search-input"
                                   name="busqueda"
                                   class="bg-transparent border-none focus:ring-0 text-sm w-full placeholder:text-[#616f89] dark:text-white" 
                                   placeholder="Buscar grados, estudiantes, cursos..." 
                                   type="text"
                                   value="<%= busqueda != null ? busqueda : "" %>"
                                   aria-label="Campo de búsqueda"/>
                        </div>
                    </form>
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
            
            <!-- Dashboard Content -->
            <div class="p-8 space-y-8 max-w-[1200px] mx-auto w-full">
                <!-- Welcome Banner -->
                <div class="relative rounded-xl overflow-hidden min-h-[180px] bg-primary flex flex-col justify-center px-8 shadow-lg shadow-primary/20" 
                     style="background-image: linear-gradient(90deg, rgba(19, 91, 236, 0.95) 0%, rgba(19, 91, 236, 0.6) 100%), url('https://lh3.googleusercontent.com/aida-public/AB6AXuB_3LXerE1vpUAm_1-q-D4EMXN-i8c-idTTZtPpQ58USnatUubEWaEA7NNTJhGtxA9glVNSU_OMWawnGSq4XX5HQvmUwfenKc6i66zaj2YSDXBn3IKNZQ4rkpfpv8Dvq_7FB1vCbkRfa3B33h-wF109oSVddHtKvBQS_mmEBKEorF9YbpZ5S1_tjrrkkRqaIgmrorMQiVIBf6m59RTKJhwF44UqJ3IBTkBBl-ch6fp8z52Qm823GZAMO-ZKdgXwLhe_q9AMTD-k4rs'); background-size: cover; background-position: center;">
                    <h2 class="text-white text-3xl font-bold tracking-tight">Bienvenido de nuevo, Administrador</h2>
                    <p class="text-blue-100 mt-2 max-w-md">Aquí tienes el resumen de lo que está sucediendo hoy en el Instituto San Antonio.</p>
                </div>
                
                <!-- Results Section for Search -->
                <% if (busqueda != null && !busqueda.trim().isEmpty()) { %>
                    <div class="bg-white dark:bg-[#1a2233] p-6 rounded-xl border border-[#dbdfe6] dark:border-gray-700 shadow-sm">
                        <div class="flex justify-between items-center mb-4">
                            <h3 class="text-xl font-bold">Resultados de búsqueda para "<%= busqueda %>"</h3>
                            <a href="dashboard.jsp" class="text-primary hover:underline">Limpiar búsqueda</a>
                        </div>
                        
                        <% if (resultados.isEmpty()) { %>
                            <p class="text-gray-500">No se encontraron grados que coincidan con tu búsqueda.</p>
                        <% } else { %>
                            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                                <% for (Map<String, String> grado : resultados) { %>
                                    <div class="border border-gray-200 dark:border-gray-700 rounded-lg p-4">
                                        <h4 class="font-bold text-lg"><%= grado.get("nombre") %></h4>
                                        <p class="text-gray-600 dark:text-gray-400">Sección: <%= grado.get("seccion") %></p>
                                        <p class="text-gray-600 dark:text-gray-400">Estudiantes: <%= grado.get("estudiantes") %></p>
                                    </div>
                                <% } %>
                            </div>
                        <% } %>
                    </div>
                <% } %>
                
                <!-- KPI Cards (Stats) -->
                <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
                    <div class="bg-white dark:bg-[#1a2233] p-6 rounded-xl border border-[#dbdfe6] dark:border-gray-700 shadow-sm flex flex-col gap-1">
                        <div class="flex justify-between items-start">
                            <p class="text-[#616f89] text-sm font-medium">Total Estudiantes</p>
                            <span class="material-symbols-outlined text-primary" aria-hidden="true">groups</span>
                        </div>
                        <h3 class="text-2xl font-bold text-[#111318] dark:text-white">250</h3>
                        <div class="flex items-center gap-1 mt-2">
                            <span class="text-[#07883b] text-sm font-semibold">+5%</span>
                            <p class="text-[#616f89] text-xs">desde el mes pasado</p>
                        </div>
                    </div>
                    
                    <div class="bg-white dark:bg-[#1a2233] p-6 rounded-xl border border-[#dbdfe6] dark:border-gray-700 shadow-sm flex flex-col gap-1">
                        <div class="flex justify-between items-start">
                            <p class="text-[#616f89] text-sm font-medium">Profesores Activos</p>
                            <span class="material-symbols-outlined text-primary" aria-hidden="true">school</span>
                        </div>
                        <h3 class="text-2xl font-bold text-[#111318] dark:text-white">25</h3>
                        <div class="flex items-center gap-1 mt-2">
                            <span class="text-[#07883b] text-sm font-semibold">+2%</span>
                            <p class="text-[#616f89] text-xs">nuevas incorporaciones</p>
                        </div>
                    </div>
                    
                    <div class="bg-white dark:bg-[#1a2233] p-6 rounded-xl border border-[#dbdfe6] dark:border-gray-700 shadow-sm flex flex-col gap-1">
                        <div class="flex justify-between items-start">
                            <p class="text-[#616f89] text-sm font-medium">Total Cursos</p>
                            <span class="material-symbols-outlined text-orange-500" aria-hidden="true">book</span>
                        </div>
                        <h3 class="text-2xl font-bold text-[#111318] dark:text-white">15</h3>
                        <div class="flex items-center gap-1 mt-2">
                            <span class="text-[#07883b] text-sm font-semibold">+8%</span>
                            <p class="text-[#616f89] text-xs">este semestre</p>
                        </div>
                    </div>
                    
                    <div class="bg-white dark:bg-[#1a2233] p-6 rounded-xl border border-[#dbdfe6] dark:border-gray-700 shadow-sm flex flex-col gap-1">
                        <div class="flex justify-between items-start">
                            <p class="text-[#616f89] text-sm font-medium">Grados Activos</p>
                            <span class="material-symbols-outlined text-purple-500" aria-hidden="true">layers</span>
                        </div>
                        <h3 class="text-2xl font-bold text-[#111318] dark:text-white">8</h3>
                        <div class="flex items-center gap-1 mt-2">
                            <span class="text-[#07883b] text-sm font-semibold">+0%</span>
                            <p class="text-[#616f89] text-xs">estable</p>
                        </div>
                    </div>
                </div>
                
                <!-- Quick Access Cards -->
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    <!-- Alumnos Card -->
                    <div class="bg-white dark:bg-[#1a2233] p-6 rounded-xl border border-[#dbdfe6] dark:border-gray-700 shadow-sm hover:shadow-md transition-shadow">
                        <div class="flex items-center gap-4 mb-4">
                            <div class="size-12 rounded-lg bg-blue-100 dark:bg-blue-900/30 flex items-center justify-center" aria-hidden="true">
                                <i class="fas fa-user-graduate text-blue-600 dark:text-blue-400 text-xl"></i>
                            </div>
                            <div>
                                <h3 class="font-bold text-lg text-[#111318] dark:text-white">Gestión de Alumnos</h3>
                                <p class="text-sm text-[#616f89] dark:text-gray-400">Administrar información académica</p>
                            </div>
                        </div>
                        <a href="AlumnoServlet" class="block w-full py-3 bg-blue-600 hover:bg-blue-700 text-white text-center rounded-lg font-medium transition-colors focus:outline focus:outline-3 focus:outline-blue-500">
                            Gestionar Alumnos
                        </a>
                    </div>
                    
                    <!-- Profesores Card -->
                    <div class="bg-white dark:bg-[#1a2233] p-6 rounded-xl border border-[#dbdfe6] dark:border-gray-700 shadow-sm hover:shadow-md transition-shadow">
                        <div class="flex items-center gap-4 mb-4">
                            <div class="size-12 rounded-lg bg-green-100 dark:bg-green-900/30 flex items-center justify-center" aria-hidden="true">
                                <i class="fas fa-chalkboard-teacher text-green-600 dark:text-green-400 text-xl"></i>
                            </div>
                            <div>
                                <h3 class="font-bold text-lg text-[#111318] dark:text-white">Gestión de Profesores</h3>
                                <p class="text-sm text-[#616f89] dark:text-gray-400">Personal docente y asignaciones</p>
                            </div>
                        </div>
                        <a href="ProfesorServlet" class="block w-full py-3 bg-green-600 hover:bg-green-700 text-white text-center rounded-lg font-medium transition-colors focus:outline focus:outline-3 focus:outline-green-500">
                            Gestionar Profesores
                        </a>
                    </div>
                    
                    <!-- Cursos Card -->
                    <div class="bg-white dark:bg-[#1a2233] p-6 rounded-xl border border-[#dbdfe6] dark:border-gray-700 shadow-sm hover:shadow-md transition-shadow">
                        <div class="flex items-center gap-4 mb-4">
                            <div class="size-12 rounded-lg bg-orange-100 dark:bg-orange-900/30 flex items-center justify-center" aria-hidden="true">
                                <i class="fas fa-book text-orange-600 dark:text-orange-400 text-xl"></i>
                            </div>
                            <div>
                                <h3 class="font-bold text-lg text-[#111318] dark:text-white">Gestión de Cursos</h3>
                                <p class="text-sm text-[#616f89] dark:text-gray-400">Configurar cursos académicos</p>
                            </div>
                        </div>
                        <a href="CursoServlet" class="block w-full py-3 bg-orange-600 hover:bg-orange-700 text-white text-center rounded-lg font-medium transition-colors focus:outline focus:outline-3 focus:outline-orange-500">
                            Gestionar Cursos
                        </a>
                    </div>
                    
                    <!-- Grados Card -->
                    <div class="bg-white dark:bg-[#1a2233] p-6 rounded-xl border border-[#dbdfe6] dark:border-gray-700 shadow-sm hover:shadow-md transition-shadow">
                        <div class="flex items-center gap-4 mb-4">
                            <div class="size-12 rounded-lg bg-red-100 dark:bg-red-900/30 flex items-center justify-center" aria-hidden="true">
                                <i class="fas fa-layer-group text-red-600 dark:text-red-400 text-xl"></i>
                            </div>
                            <div>
                                <h3 class="font-bold text-lg text-[#111318] dark:text-white">Gestión de Grados</h3>
                                <p class="text-sm text-[#616f89] dark:text-gray-400">Administrar grados académicos</p>
                            </div>
                        </div>
                        <a href="GradoServlet" class="block w-full py-3 bg-red-600 hover:bg-red-700 text-white text-center rounded-lg font-medium transition-colors focus:outline focus:outline-3 focus:outline-red-500">
                            Gestionar Grados
                        </a>
                    </div>
                    
                    <!-- Usuarios Card -->
                    <div class="bg-white dark:bg-[#1a2233] p-6 rounded-xl border border-[#dbdfe6] dark:border-gray-700 shadow-sm hover:shadow-md transition-shadow">
                        <div class="flex items-center gap-4 mb-4">
                            <div class="size-12 rounded-lg bg-gray-100 dark:bg-gray-800 flex items-center justify-center" aria-hidden="true">
                                <i class="fas fa-users-cog text-gray-600 dark:text-gray-400 text-xl"></i>
                            </div>
                            <div>
                                <h3 class="font-bold text-lg text-[#111318] dark:text-white">Gestión de Usuarios</h3>
                                <p class="text-sm text-[#616f89] dark:text-gray-400">Permisos y roles de acceso</p>
                            </div>
                        </div>
                        <a href="UsuarioServlet" class="block w-full py-3 bg-gray-600 hover:bg-gray-700 text-white text-center rounded-lg font-medium transition-colors focus:outline focus:outline-3 focus:outline-gray-500">
                            Gestionar Usuarios
                        </a>
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
        
        // Auto-focus search input when search results are shown
        <% if (busqueda != null && !busqueda.trim().isEmpty()) { %>
            window.addEventListener('load', function() {
                document.getElementById('search-input').focus();
            });
        <% } %>
    </script>
</body>
</html>