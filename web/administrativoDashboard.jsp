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

    String rolSesion = (String) session.getAttribute("rol");
    if (!"administrativo".equals(rolSesion)) {
        response.sendRedirect("acceso_denegado.jsp");
        return;
    }

    // Obtener estadísticas reales
    EstadisticasDAO estadisticasDAO = new EstadisticasDAO();
    Map<String, Integer> estadisticas = estadisticasDAO.obtenerEstadisticasGenerales();

    int totalEstudiantes = estadisticas.getOrDefault("totalEstudiantes", 0);
    int totalProfesores  = estadisticas.getOrDefault("totalProfesores",  0);
    int totalCursos      = estadisticas.getOrDefault("totalCursos",      0);
    int totalGrados      = estadisticas.getOrDefault("totalGrados",      0);

   String usuarioDash = (String) session.getAttribute("usuario");
String nombreCompletoAdm = usuarioDash; // por defecto

// Obtener nombre completo desde BD
try (java.sql.Connection connD = conexion.Conexion.getConnection()) {
    String sqlD = "SELECT p.nombres, p.apellidos FROM persona p " +
                  "JOIN usuario u ON u.persona_id = p.id " +
                  "WHERE u.username = ?";
    try (java.sql.PreparedStatement psD = connD.prepareStatement(sqlD)) {
        psD.setString(1, usuarioDash);
        java.sql.ResultSet rsD = psD.executeQuery();
        if (rsD.next()) {
            String nom = rsD.getString("nombres")   != null ? rsD.getString("nombres")   : "";
            String ape = rsD.getString("apellidos") != null ? rsD.getString("apellidos") : "";
            nombreCompletoAdm = (nom + " " + ape).trim();
        }
    }
} catch (Exception eD) {
    System.err.println("Error obteniendo nombre administrativo: " + eD.getMessage());
}
    request.setAttribute("pageTitle", "Dashboard Administrativo");
%>

<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panel Administrativo - San Antonio</title>

    <%@ include file="includes/head.jsp" %>

    <style>
        .reduce-motion * { animation-duration: 0.01ms !important; animation-iteration-count: 1 !important; transition-duration: 0.01ms !important; }
        .high-contrast-invert { filter: invert(1) hue-rotate(180deg); }
        .high-contrast-yellow { background-color: #000000 !important; color: #ffff00 !important; }
        .beige-background { background-color: #f5f5dc !important; }
        .large-text  { font-size: 20px !important; }
        .larger-text { font-size: 24px !important; }
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

        <%-- SIDEBAR ADMINISTRATIVO --%>
        <%@ include file="includes/sidebarAdministrativo.jsp" %>

        <main class="flex-1 flex flex-col overflow-y-auto">

            <%-- HEADER --%>
            <%@ include file="includes/header.jsp" %>

            <div class="p-8 space-y-8 max-w-[1200px] mx-auto w-full">

                <%-- Banner de bienvenida --%>
                <div class="relative rounded-xl overflow-hidden min-h-[180px] bg-primary flex flex-col justify-center px-8 shadow-lg shadow-primary/20"
                     style="background-image: linear-gradient(90deg, rgba(19,91,236,0.95) 0%, rgba(19,91,236,0.6) 100%), url('https://lh3.googleusercontent.com/aida-public/AB6AXuB_3LXerE1vpUAm_1-q-D4EMXN-i8c-idTTZtPpQ58USnatUubEWaEA7NNTJhGtxA9glVNSU_OMWawnGSq4XX5HQvmUwfenKc6i66zaj2YSDXBn3IKNZQ4rkpfpv8Dvq_7FB1vCbkRfa3B33h-wF109oSVddHtKvBQS_mmEBKEorF9YbpZ5S1_tjrrkkRqaIgmrorMQiVIBf6m59RTKJhwF44UqJ3IBTkBBl-ch6fp8z52Qm823GZAMO-ZKdgXwLhe_q9AMTD-k4rs'); background-size: cover; background-position: center;">
                    <div class="relative z-10 text-white">
                        <p class="text-sm font-medium opacity-80 mb-1">Bienvenido de vuelta</p>
                        <h2 class="text-3xl font-bold mb-2"><%= nombreCompletoAdm %></h2>
                        <p class="text-sm opacity-80">
                            <i class="fas fa-calendar me-1"></i>
                            <%= new java.text.SimpleDateFormat("EEEE, dd 'de' MMMM 'de' yyyy", new java.util.Locale("es","PE")).format(new java.util.Date()) %>
                        </p>
                    </div>
                    <!-- Decoración -->
                    <div class="absolute right-8 top-1/2 -translate-y-1/2 opacity-10">
                        <span class="material-symbols-outlined" style="font-size: 120px;">manage_accounts</span>
                    </div>
                </div>

                <%-- Tarjetas de estadísticas --%>
                <div>
                    <h3 class="font-bold text-xl text-[#111318] dark:text-white mb-4">Resumen General</h3>
                    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">

                        <div class="bg-white dark:bg-[#1a2233] rounded-xl p-5 border border-[#dbdfe6] dark:border-gray-700 shadow-sm hover:shadow-md transition-shadow">
                            <div class="flex items-center justify-between mb-3">
                                <div class="size-11 rounded-lg bg-blue-100 dark:bg-blue-900/30 flex items-center justify-center">
                                    <i class="fas fa-user-graduate text-blue-600 text-lg"></i>
                                </div>
                                <span class="text-xs text-[#616f89] dark:text-gray-400 font-medium uppercase tracking-wide">Alumnos</span>
                            </div>
                            <p class="text-3xl font-bold text-[#111318] dark:text-white"><%= totalEstudiantes %></p>
                            <p class="text-xs text-[#616f89] dark:text-gray-400 mt-1">Total matriculados</p>
                        </div>

                        <div class="bg-white dark:bg-[#1a2233] rounded-xl p-5 border border-[#dbdfe6] dark:border-gray-700 shadow-sm hover:shadow-md transition-shadow">
                            <div class="flex items-center justify-between mb-3">
                                <div class="size-11 rounded-lg bg-green-100 dark:bg-green-900/30 flex items-center justify-center">
                                    <i class="fas fa-chalkboard-teacher text-green-600 text-lg"></i>
                                </div>
                                <span class="text-xs text-[#616f89] dark:text-gray-400 font-medium uppercase tracking-wide">Docentes</span>
                            </div>
                            <p class="text-3xl font-bold text-[#111318] dark:text-white"><%= totalProfesores %></p>
                            <p class="text-xs text-[#616f89] dark:text-gray-400 mt-1">Personal docente</p>
                        </div>

                        <div class="bg-white dark:bg-[#1a2233] rounded-xl p-5 border border-[#dbdfe6] dark:border-gray-700 shadow-sm hover:shadow-md transition-shadow">
                            <div class="flex items-center justify-between mb-3">
                                <div class="size-11 rounded-lg bg-purple-100 dark:bg-purple-900/30 flex items-center justify-center">
                                    <i class="fas fa-book text-purple-600 text-lg"></i>
                                </div>
                                <span class="text-xs text-[#616f89] dark:text-gray-400 font-medium uppercase tracking-wide">Cursos</span>
                            </div>
                            <p class="text-3xl font-bold text-[#111318] dark:text-white"><%= totalCursos %></p>
                            <p class="text-xs text-[#616f89] dark:text-gray-400 mt-1">Cursos activos</p>
                        </div>

                        <div class="bg-white dark:bg-[#1a2233] rounded-xl p-5 border border-[#dbdfe6] dark:border-gray-700 shadow-sm hover:shadow-md transition-shadow">
                            <div class="flex items-center justify-between mb-3">
                                <div class="size-11 rounded-lg bg-orange-100 dark:bg-orange-900/30 flex items-center justify-center">
                                    <i class="fas fa-layer-group text-orange-600 text-lg"></i>
                                </div>
                                <span class="text-xs text-[#616f89] dark:text-gray-400 font-medium uppercase tracking-wide">Grados</span>
                            </div>
                            <p class="text-3xl font-bold text-[#111318] dark:text-white"><%= totalGrados %></p>
                            <p class="text-xs text-[#616f89] dark:text-gray-400 mt-1">Grados académicos</p>
                        </div>

                    </div>
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