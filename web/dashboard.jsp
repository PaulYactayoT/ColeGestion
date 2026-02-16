<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page import="java.util.*" %>
<%@ page import="modelo.EstadisticasDAO" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    // Obtener estadísticas reales
    EstadisticasDAO estadisticasDAO = new EstadisticasDAO();
    Map<String, Integer> estadisticas = estadisticasDAO.obtenerEstadisticasGenerales();
    
    int totalEstudiantes = estadisticas.get("totalEstudiantes");
    int totalProfesores  = estadisticas.get("totalProfesores");
    int totalCursos      = estadisticas.get("totalCursos");
    int totalGrados      = estadisticas.get("totalGrados");
    
    // Nombre del usuario para el saludo
    String usuarioDash = (String) session.getAttribute("usuario");
    
    // Título para el header dinámico
    request.setAttribute("pageTitle", "Dashboard");
%>

<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - San Antonio</title>
    
    <%-- ✅ Incluir HEAD común --%>
    <%@ include file="includes/head.jsp" %>
    
    <style>
        /* Accesibilidad */
        .reduce-motion * { animation-duration: 0.01ms !important; animation-iteration-count: 1 !important; transition-duration: 0.01ms !important; }
        .high-contrast-invert { filter: invert(1) hue-rotate(180deg); }
        .high-contrast-yellow { background-color: #000000 !important; color: #ffff00 !important; }
        .beige-background { background-color: #f5f5dc !important; }
        .large-text  { font-size: 20px !important; }
        .larger-text { font-size: 24px !important; }
        .largest-text{ font-size: 28px !important; }
        .dyslexia-font { font-family: Arial !important; font-size: 1.1em !important; line-height: 1.6 !important; letter-spacing: 0.5px !important; }

        .accessibility-panel { transform: translateX(100%); transition: transform 0.3s ease; }
        .accessibility-panel.open { transform: translateX(0); }
        .skip-to-content { position: absolute; top: -40px; left: 0; background: #135bec; color: white; padding: 8px; z-index: 100; }
        .skip-to-content:focus { top: 0; }
        :focus { outline: 3px solid #135bec !important; outline-offset: 2px; }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark text-[#111318] dark:text-white min-h-screen" id="main-content">

    <a href="#main-content" class="skip-to-content">Saltar al contenido principal</a>

    <%-- Panel de Accesibilidad --%>
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
                    <button onclick="setTextSize('large')"  class="px-3 py-2 bg-gray-100 rounded hover:bg-gray-200 text-sm">Grande</button>
                    <button onclick="setTextSize('larger')" class="px-3 py-2 bg-gray-100 rounded hover:bg-gray-200 text-sm">Más Grande</button>
                </div>
            </div>
            <div class="space-y-2">
                <h4 class="font-medium">Contraste</h4>
                <div class="flex gap-2">
                    <button onclick="setContrast('normal')" class="px-3 py-2 bg-gray-100 rounded hover:bg-gray-200 text-sm">Normal</button>
                    <button onclick="setContrast('high')"   class="px-3 py-2 bg-gray-100 rounded hover:bg-gray-200 text-sm">Alto</button>
                    <button onclick="setContrast('yellow')" class="px-3 py-2 bg-gray-100 rounded hover:bg-gray-200 text-sm">Amarillo</button>
                </div>
            </div>
            <div class="space-y-2">
                <h4 class="font-medium">Otros ajustes</h4>
                <div class="flex flex-col gap-2">
                    <label class="flex items-center gap-2"><input type="checkbox" id="reduceMotion"    onchange="toggleMotion()"><span>Reducir movimiento</span></label>
                    <label class="flex items-center gap-2"><input type="checkbox" id="dyslexiaFont"    onchange="toggleDyslexiaFont()"><span>Fuente para dislexia</span></label>
                    <label class="flex items-center gap-2"><input type="checkbox" id="beigeBackground" onchange="toggleBeigeBackground()"><span>Fondo beige</span></label>
                </div>
            </div>
            <button onclick="resetAccessibility()" class="w-full py-2 bg-gray-800 text-white rounded hover:bg-gray-900">
                Restablecer ajustes
            </button>
        </div>
    </div>

    <%-- Botón flotante de accesibilidad --%>
    <button onclick="toggleAccessibilityPanel()" 
            class="fixed top-20 right-0 z-40 bg-primary text-white p-3 rounded-l-lg shadow-lg hover:bg-blue-700 transition-colors"
            aria-label="Abrir panel de accesibilidad">
        <span class="material-symbols-outlined">accessibility_new</span>
    </button>

    <div class="flex h-screen overflow-hidden">

        <%-- ✅ SIDEBAR --%>
        <%@ include file="includes/sidebar.jsp" %>

        <main class="flex-1 flex flex-col overflow-y-auto">

            <%-- ✅ HEADER con foto dinámica --%>
            <%@ include file="includes/header.jsp" %>

            <div class="p-8 space-y-8 max-w-[1200px] mx-auto w-full">

                <%-- Banner de bienvenida (Estilo Azul Profundo Degradado) --%>
                <div class="bg-gradient-to-r from-blue-600 to-blue-800 rounded-xl p-6 mb-8 text-white shadow-lg relative overflow-hidden">
                    <div class="absolute right-0 top-0 h-full w-1/3 bg-white/10 skew-x-12 transform origin-bottom-left"></div>
                    <div class="relative z-10">
                        <h2 class="text-3xl font-bold tracking-tight">
                            Bienvenido, <%= usuarioDash != null ? usuarioDash : "Administrador" %>
                        </h2>
                        <p class="text-blue-100 mt-2 max-w-md">Aquí tienes el resumen de lo que está sucediendo hoy en el Instituto San Antonio.</p>
                    </div>
                </div>

                <%-- Tarjetas de estadísticas (Estilo Azul Uniforme del Profesor) --%>
                <div class="grid grid-cols-1 md:grid-cols-4 gap-6">

                    <div class="bg-gradient-to-r from-blue-500 to-blue-700 rounded-xl p-6 shadow-lg shadow-blue-500/30 text-white hover:-translate-y-1 transition-transform duration-300 relative overflow-hidden group">
                        <div class="absolute -right-6 -top-6 h-24 w-24 rounded-full bg-white/10 group-hover:bg-white/20 transition-colors blur-xl"></div>
                        <div class="relative flex items-center justify-between z-10">
                            <div>
                                <p class="text-blue-100 text-sm font-medium">Total Estudiantes</p>
                                <h3 class="text-3xl font-bold mt-1"><%= totalEstudiantes %></h3>
                                <span class="inline-flex mt-2 items-center rounded-lg bg-white/20 px-2 py-1 text-xs backdrop-blur-sm font-semibold border border-white/10">
                                    Activos
                                </span>
                            </div>
                            <div class="rounded-xl bg-white/20 p-3 backdrop-blur-sm shadow-inner">
                                <span class="material-symbols-outlined text-3xl">groups</span>
                            </div>
                        </div>
                    </div>

                    <div class="bg-gradient-to-r from-blue-500 to-blue-700 rounded-xl p-6 shadow-lg shadow-blue-500/30 text-white hover:-translate-y-1 transition-transform duration-300 relative overflow-hidden group">
                        <div class="absolute -right-6 -top-6 h-24 w-24 rounded-full bg-white/10 group-hover:bg-white/20 transition-colors blur-xl"></div>
                        <div class="relative flex items-center justify-between z-10">
                            <div>
                                <p class="text-blue-100 text-sm font-medium">Profesores</p>
                                <h3 class="text-3xl font-bold mt-1"><%= totalProfesores %></h3>
                                <span class="inline-flex mt-2 items-center rounded-lg bg-white/20 px-2 py-1 text-xs backdrop-blur-sm font-semibold border border-white/10">
                                    Activos
                                </span>
                            </div>
                            <div class="rounded-xl bg-white/20 p-3 backdrop-blur-sm shadow-inner">
                                <span class="material-symbols-outlined text-3xl">school</span>
                            </div>
                        </div>
                    </div>

                    <div class="bg-gradient-to-r from-blue-500 to-blue-700 rounded-xl p-6 shadow-lg shadow-blue-500/30 text-white hover:-translate-y-1 transition-transform duration-300 relative overflow-hidden group">
                        <div class="absolute -right-6 -top-6 h-24 w-24 rounded-full bg-white/10 group-hover:bg-white/20 transition-colors blur-xl"></div>
                        <div class="relative flex items-center justify-between z-10">
                            <div>
                                <p class="text-blue-100 text-sm font-medium">Total Cursos</p>
                                <h3 class="text-3xl font-bold mt-1"><%= totalCursos %></h3>
                                <span class="inline-flex mt-2 items-center rounded-lg bg-white/20 px-2 py-1 text-xs backdrop-blur-sm font-semibold border border-white/10">
                                    Registrados
                                </span>
                            </div>
                            <div class="rounded-xl bg-white/20 p-3 backdrop-blur-sm shadow-inner">
                                <span class="material-symbols-outlined text-3xl">book</span>
                            </div>
                        </div>
                    </div>

                    <div class="bg-gradient-to-r from-blue-500 to-blue-700 rounded-xl p-6 shadow-lg shadow-blue-500/30 text-white hover:-translate-y-1 transition-transform duration-300 relative overflow-hidden group">
                        <div class="absolute -right-6 -top-6 h-24 w-24 rounded-full bg-white/10 group-hover:bg-white/20 transition-colors blur-xl"></div>
                        <div class="relative flex items-center justify-between z-10">
                            <div>
                                <p class="text-blue-100 text-sm font-medium">Grados</p>
                                <h3 class="text-3xl font-bold mt-1"><%= totalGrados %></h3>
                                <span class="inline-flex mt-2 items-center rounded-lg bg-white/20 px-2 py-1 text-xs backdrop-blur-sm font-semibold border border-white/10">
                                    Niveles
                                </span>
                            </div>
                            <div class="rounded-xl bg-white/20 p-3 backdrop-blur-sm shadow-inner">
                                <span class="material-symbols-outlined text-3xl">layers</span>
                            </div>
                        </div>
                    </div>
                </div>

                <%-- Accesos directos --%>
                <div>
                    <h3 class="font-bold text-xl text-[#111318] dark:text-white mb-4">Accesos Directos</h3>
                    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">

                        <div class="bg-white dark:bg-[#1a2233] p-6 rounded-xl border-2 border-yellow-500 shadow-sm hover:shadow-md transition-shadow">
                            <div class="flex items-center gap-4 mb-4">
                                <div class="size-12 rounded-lg bg-yellow-100 dark:bg-yellow-900/30 flex items-center justify-center">
                                    <i class="fas fa-calendar-check text-yellow-600 text-xl"></i>
                                </div>
                                <div>
                                    <h3 class="font-bold text-lg text-[#111318] dark:text-white">Evaluación de Disponibilidad</h3>
                                    <p class="text-sm text-[#616f89] dark:text-gray-400">Revisar solicitudes pendientes</p>
                                </div>
                            </div>
                            <a href="AdminDisponibilidadServlet" class="block w-full py-3 bg-yellow-500 hover:bg-yellow-600 text-white text-center rounded-lg font-bold transition-colors">
                                <i class="fas fa-eye me-2"></i> Ver Solicitudes
                            </a>
                        </div>

                        <div class="bg-white dark:bg-[#1a2233] p-6 rounded-xl border-2 border-blue-600 shadow-sm hover:shadow-md transition-shadow">
                            <div class="flex items-center gap-4 mb-4">
                                <div class="size-12 rounded-lg bg-blue-100 dark:bg-blue-900/30 flex items-center justify-center">
                                    <i class="fas fa-user-graduate text-blue-600 text-xl"></i>
                                </div>
                                <div>
                                    <h3 class="font-bold text-lg text-[#111318] dark:text-white">Gestión de Alumnos</h3>
                                    <p class="text-sm text-[#616f89] dark:text-gray-400">Administrar información académica</p>
                                </div>
                            </div>
                            <a href="AlumnoServlet" class="block w-full py-3 bg-blue-600 hover:bg-blue-700 text-white text-center rounded-lg font-medium transition-colors">
                                Gestionar Alumnos
                            </a>
                        </div>

                        <div class="bg-white dark:bg-[#1a2233] p-6 rounded-xl border-2 border-green-600 shadow-sm hover:shadow-md transition-shadow">
                            <div class="flex items-center gap-4 mb-4">
                                <div class="size-12 rounded-lg bg-green-100 dark:bg-green-900/30 flex items-center justify-center">
                                    <i class="fas fa-chalkboard-teacher text-green-600 text-xl"></i>
                                </div>
                                <div>
                                    <h3 class="font-bold text-lg text-[#111318] dark:text-white">Gestión de Profesores</h3>
                                    <p class="text-sm text-[#616f89] dark:text-gray-400">Personal docente y asignaciones</p>
                                </div>
                            </div>
                            <a href="ProfesorServlet" class="block w-full py-3 bg-green-600 hover:bg-green-700 text-white text-center rounded-lg font-medium transition-colors">
                                Gestionar Profesores
                            </a>
                        </div>

                        <div class="bg-white dark:bg-[#1a2233] p-6 rounded-xl border-2 border-purple-600 shadow-sm hover:shadow-md transition-shadow">
                            <div class="flex items-center gap-4 mb-4">
                                <div class="size-12 rounded-lg bg-purple-100 dark:bg-purple-900/30 flex items-center justify-center">
                                    <i class="fas fa-book text-purple-600 text-xl"></i>
                                </div>
                                <div>
                                    <h3 class="font-bold text-lg text-[#111318] dark:text-white">Gestión de Cursos</h3>
                                    <p class="text-sm text-[#616f89] dark:text-gray-400">Configurar cursos académicos</p>
                                </div>
                            </div>
                            <a href="CursoServlet" class="block w-full py-3 bg-purple-600 hover:bg-purple-700 text-white text-center rounded-lg font-medium transition-colors">
                                Gestionar Cursos
                            </a>
                        </div>

                        <div class="bg-white dark:bg-[#1a2233] p-6 rounded-xl border-2 border-red-600 shadow-sm hover:shadow-md transition-shadow">
                            <div class="flex items-center gap-4 mb-4">
                                <div class="size-12 rounded-lg bg-red-100 dark:bg-red-900/30 flex items-center justify-center">
                                    <i class="fas fa-layer-group text-red-600 text-xl"></i>
                                </div>
                                <div>
                                    <h3 class="font-bold text-lg text-[#111318] dark:text-white">Gestión de Grados</h3>
                                    <p class="text-sm text-[#616f89] dark:text-gray-400">Administrar grados académicos</p>
                                </div>
                            </div>
                            <a href="GradoServlet" class="block w-full py-3 bg-red-600 hover:bg-red-700 text-white text-center rounded-lg font-medium transition-colors">
                                Gestionar Grados
                            </a>
                        </div>

                        <div class="bg-white dark:bg-[#1a2233] p-6 rounded-xl border-2 border-gray-600 shadow-sm hover:shadow-md transition-shadow">
                            <div class="flex items-center gap-4 mb-4">
                                <div class="size-12 rounded-lg bg-gray-100 dark:bg-gray-800 flex items-center justify-center">
                                    <i class="fas fa-users-cog text-gray-600 text-xl"></i>
                                </div>
                                <div>
                                    <h3 class="font-bold text-lg text-[#111318] dark:text-white">Gestión de Usuarios</h3>
                                    <p class="text-sm text-[#616f89] dark:text-gray-400">Permisos y roles de acceso</p>
                                </div>
                            </div>
                            <a href="UsuarioServlet" class="block w-full py-3 bg-gray-600 hover:bg-gray-700 text-white text-center rounded-lg font-medium transition-colors">
                                Gestionar Usuarios
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <script>
        function toggleAccessibilityPanel() { document.querySelector('.accessibility-panel').classList.toggle('open'); }
        function setTextSize(size) {
            document.body.classList.remove('large-text','larger-text','largest-text');
            if (size !== 'normal') document.body.classList.add(size + '-text');
        }
        function setContrast(mode) {
            document.body.classList.remove('high-contrast-invert','high-contrast-yellow');
            if (mode === 'high')   document.body.classList.add('high-contrast-invert');
            if (mode === 'yellow') document.body.classList.add('high-contrast-yellow');
        }
        function toggleMotion()          { document.body.classList.toggle('reduce-motion',    document.getElementById('reduceMotion').checked); }
        function toggleDyslexiaFont()    { document.body.classList.toggle('dyslexia-font',    document.getElementById('dyslexiaFont').checked); }
        function toggleBeigeBackground() { document.body.classList.toggle('beige-background', document.getElementById('beigeBackground').checked); }
        function resetAccessibility() {
            document.body.classList.remove('large-text','larger-text','largest-text','high-contrast-invert','high-contrast-yellow','reduce-motion','dyslexia-font','beige-background');
            ['reduceMotion','dyslexiaFont','beigeBackground'].forEach(id => document.getElementById(id).checked = false);
        }
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') document.querySelector('.accessibility-panel').classList.remove('open');
        });
    </script>
</body>
</html>