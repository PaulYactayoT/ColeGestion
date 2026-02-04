<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, modelo.Alumno, modelo.Grado" %>
<%@ page import="javax.servlet.http.HttpSession" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    List<Grado> grados = (List<Grado>) request.getAttribute("grados");
    Integer gradoSeleccionado = (Integer) request.getAttribute("gradoSeleccionado");
%>

<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Alumnos - San Antonio</title>
    
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
            font-size: 0.95rem; /* Aumentado de 0.875rem */
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
            font-size: 0.95rem; /* Aumentado de 0.875rem */
        }
        
        .dark .custom-table td {
            color: #d1d5db;
        }
        
        /* Badge con tamaño base más grande */
        .status-badge {
            padding: 0.35rem 0.85rem; /* Aumentado */
            border-radius: 9999px;
            font-size: 0.85rem; /* Aumentado de 0.75rem */
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
            font-size: 0.95rem !important; /* Aumentado */
        }
        
        .text-xs {
            font-size: 0.85rem !important; /* Aumentado */
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
        
        /* Estilos para el filtro */
        .filter-card {
            background: white;
            border-radius: 0.5rem;
            padding: 1.5rem;
            border: 1px solid #e5e7eb;
            margin-bottom: 1.5rem;
        }
        
        .dark .filter-card {
            background: #1a2233;
            border-color: #374151;
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
                    <a class="flex items-center gap-3 px-3 py-2 rounded-lg bg-primary/10 text-primary font-medium" 
                       href="AlumnoServlet"
                       aria-current="page">
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
                            Listado de Alumnos
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
                <!-- Header con título y botón -->
                <div class="flex justify-between items-center mb-6">
                    <div>
                        <h2 class="text-2xl font-bold text-[#111318] dark:text-white">Gestión de Alumnos</h2>
                        <p class="text-[#616f89] dark:text-gray-400 mt-1">Administra los estudiantes del sistema educativo</p>
                    </div>
                    <a href="AlumnoServlet?accion=nuevo" 
                       class="flex items-center gap-2 px-4 py-2.5 bg-gradient-to-r from-red-600 to-red-700 hover:from-red-700 hover:to-red-800 text-white font-medium rounded-lg transition-all duration-300 transform hover:scale-[1.02] focus:outline focus:outline-3 focus:outline-red-500">
                        <span class="material-symbols-outlined">person_add</span>
                        <span>Registrar Alumno</span>
                    </a>
                </div>
                
                <!-- Filtro por Grado -->
                <div class="filter-card mb-6">
                    <h3 class="font-medium text-lg text-[#111318] dark:text-white mb-3">Filtrar Alumnos</h3>
                    <form action="AlumnoServlet" method="get" class="flex flex-col md:flex-row gap-4 items-start md:items-center">
                        <input type="hidden" name="accion" value="filtrar">
                        <div class="flex-1">
                            <label for="grado_id" class="block text-sm font-medium text-[#111318] dark:text-white mb-2">
                                Grado Académico
                            </label>
                            <div class="relative">
                                <span class="absolute left-3 top-3 material-symbols-outlined text-gray-400">
                                    filter_alt
                                </span>
                                <select name="grado_id" id="grado_id" 
                                        class="pl-10 w-full p-3 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-gray-800 focus:ring-2 focus:ring-red-500 focus:border-transparent">
                                    <option value="">-- Todos los grados --</option>
                                    <% for (Grado g : grados) {%>
                                    <option value="<%= g.getId()%>" <%= (gradoSeleccionado != null && gradoSeleccionado == g.getId()) ? "selected" : ""%>>
                                        <%= g.getNombre()%> - <%= g.getNivel()%>
                                    </option>
                                    <% } %>
                                </select>
                            </div>
                        </div>
                        <div class="mt-2 md:mt-0">
                            <button type="submit" 
                                    class="flex items-center gap-2 px-4 py-3 bg-gradient-to-r from-primary to-blue-600 hover:from-blue-600 hover:to-blue-700 text-white font-medium rounded-lg transition-all duration-300 transform hover:scale-[1.02] focus:outline focus:outline-3 focus:outline-primary">
                                <span class="material-symbols-outlined">search</span>
                                <span>Filtrar</span>
                            </button>
                        </div>
                    </form>
                </div>
                
                <!-- Tabla de alumnos -->
                <div class="bg-white dark:bg-[#1a2233] rounded-xl border border-[#dbdfe6] dark:border-gray-700 shadow-sm overflow-hidden">
                    <div class="overflow-x-auto">
                        <table class="custom-table">
                            <thead>
                                <tr>
                                    <th>Nombres</th>
                                    <th>Apellidos</th>
                                    <th>Correo</th>
                                    <th>Fecha Nac.</th>
                                    <th>Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    List<Alumno> lista = (List<Alumno>) request.getAttribute("lista");
                                    if (lista != null && !lista.isEmpty()) {
                                        for (Alumno a : lista) {
                                %>
                                <tr>
                                    <td class="font-medium">
                                        <div class="flex items-center gap-3">
                                            <div class="size-8 rounded-full bg-blue-100 dark:bg-blue-900 flex items-center justify-center">
                                                <span class="material-symbols-outlined text-blue-600 dark:text-blue-300 text-sm">person</span>
                                            </div>
                                            <span><%= a.getNombres()%></span>
                                        </div>
                                    </td>
                                    <td><%= a.getApellidos()%></td>
                                    <td>
                                        <div class="flex items-center gap-2">
                                            <span class="material-symbols-outlined text-gray-400 text-sm">mail</span>
                                            <span class="text-blue-600 dark:text-blue-400"><%= a.getCorreo()%></span>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="status-badge bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200">
                                            <%= a.getFechaNacimiento()%>
                                        </span>
                                    </td>
      
                                    <td>
                                        <div class="flex gap-2">
                                            <a href="AlumnoServlet?accion=editar&id=<%= a.getId()%>" 
                                               class="btn-icon bg-blue-100 text-blue-600 hover:bg-blue-200 dark:bg-blue-900 dark:text-blue-300 dark:hover:bg-blue-800 focus:outline focus:outline-2 focus:outline-blue-500"
                                               title="Editar alumno"
                                               aria-label="Editar alumno <%= a.getNombres()%>">
                                                <span class="material-symbols-outlined text-sm">edit</span>
                                            </a>
                                            <a href="AlumnoServlet?accion=eliminar&id=<%= a.getId()%>" 
                                               class="btn-icon bg-red-100 text-red-600 hover:bg-red-200 dark:bg-red-900 dark:text-red-300 dark:hover:bg-red-800 focus:outline focus:outline-2 focus:outline-red-500"
                                               title="Eliminar alumno"
                                               aria-label="Eliminar alumno <%= a.getNombres()%>"
                                               onclick="return confirm('¿Estás seguro de eliminar este alumno?')">
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
                                    <td colspan="5" class="text-center py-8">
                                        <div class="flex flex-col items-center justify-center text-gray-400">
                                            <span class="material-symbols-outlined text-4xl mb-2">school</span>
                                            <p class="text-lg font-medium">No hay alumnos registrados</p>
                                            <p class="text-sm">Comienza registrando un nuevo alumno</p>
                                        </div>
                                    </td>
                                </tr>
                                <% }%>
                            </tbody>
                        </table>
                    </div>
                </div>
                
                <!-- Información adicional -->
                <div class="mt-6 p-4 bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg">
                    <div class="flex items-start gap-3">
                        <span class="material-symbols-outlined text-blue-600 dark:text-blue-400 mt-0.5">
                            info
                        </span>
                        <div>
                            <h4 class="font-medium text-blue-800 dark:text-blue-300">Información importante:</h4>
                            <ul class="mt-2 text-sm text-blue-700 dark:text-blue-400 space-y-1">
                                <li>• Para registrar un nuevo alumno, haz clic en "Registrar Alumno"</li>
                                <li>• Puedes filtrar los alumnos por grado académico usando el filtro superior</li>
                                <li>• Para editar la información de un alumno, utiliza el botón de editar</li>
                                <li>• Ten cuidado al eliminar alumnos, esta acción no se puede deshacer</li>
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
            
            // Auto-focus en el filtro si hay datos
            const gradoSelect = document.getElementById('grado_id');
            if (gradoSelect) {
                gradoSelect.focus();
            }
        });
        
        // Auto-focus en la página de carga
        window.addEventListener('load', function() {
            // Enfocar el botón de registrar si existe
            const registrarBtn = document.querySelector('a[href*="AlumnoServlet?accion=nuevo"]');
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