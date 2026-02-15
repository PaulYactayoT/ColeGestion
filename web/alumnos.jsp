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
    
    // Título para el header dinámico
    request.setAttribute("pageTitle", "Listado de Alumnos");
%>

<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Alumnos - San Antonio</title>
    
    <%-- ✅ Incluir HEAD común (Tailwind, fuentes, estilos globales) --%>
    <%@ include file="includes/head.jsp" %>
    
    <style>
        /* Mejoras de accesibilidad */
        .reduce-motion * { 
            animation-duration: 0.01ms !important; 
            animation-iteration-count: 1 !important; 
            transition-duration: 0.01ms !important; 
        }
        .high-contrast-invert { filter: invert(1) hue-rotate(180deg); }
        .high-contrast-yellow { background-color: #000000 !important; color: #ffff00 !important; }
        .beige-background { background-color: #f5f5dc !important; }
        
        .large-text  { font-size: 18px !important; }
        .larger-text { font-size: 20px !important; }
        .largest-text{ font-size: 22px !important; }
        .large-text  .custom-table th, .large-text  .custom-table td { font-size: 16px !important; }
        .larger-text .custom-table th, .larger-text .custom-table td { font-size: 18px !important; }
        .largest-text .custom-table th,.largest-text .custom-table td { font-size: 20px !important; }
        
        .dyslexia-font { font-family: Arial !important; font-size: 1.1em !important; line-height: 1.6 !important; letter-spacing: 0.5px !important; }
        .dyslexia-font .custom-table th, .dyslexia-font .custom-table td { font-family: Arial !important; line-height: 1.6 !important; }
        
        /* Panel de accesibilidad */
        .accessibility-panel {
            transform: translateX(100%);
            transition: transform 0.3s ease;
        }
        .accessibility-panel.open { transform: translateX(0); }
        
        .skip-to-content { position: absolute; top: -40px; left: 0; background: #135bec; color: white; padding: 8px; z-index: 100; }
        .skip-to-content:focus { top: 0; }
        :focus { outline: 3px solid #135bec !important; outline-offset: 2px; }

        /* Tabla */
        .custom-table { border-collapse: separate; border-spacing: 0; width: 100%; background: white; border-radius: 0.5rem; overflow: hidden; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
        .dark .custom-table { background: #1a2233; }
        .custom-table thead { background: linear-gradient(135deg, #135bec 0%, #0d47a1 100%); }
        .custom-table th { padding: 1rem; text-align: left; font-weight: 600; color: white; font-size: 0.95rem; text-transform: uppercase; letter-spacing: 0.05em; }
        .custom-table tbody tr { border-bottom: 1px solid #e5e7eb; transition: background-color 0.2s; }
        .dark .custom-table tbody tr { border-bottom: 1px solid #374151; }
        .custom-table tbody tr:hover { background-color: #f9fafb; }
        .dark .custom-table tbody tr:hover { background-color: #2d3748; }
        .custom-table td { padding: 1rem; color: #374151; font-size: 0.95rem; }
        .dark .custom-table td { color: #d1d5db; }
        
        .status-badge { padding: 0.35rem 0.85rem; border-radius: 9999px; font-size: 0.85rem; font-weight: 600; }
        .btn-icon { padding: 0.5rem; border-radius: 0.375rem; display: inline-flex; align-items: center; justify-content: center; transition: all 0.2s; }
        .btn-icon:hover { transform: translateY(-1px); }
        
        .filter-card { background: white; border-radius: 0.5rem; padding: 1.5rem; border: 1px solid #e5e7eb; margin-bottom: 1.5rem; }
        .dark .filter-card { background: #1a2233; border-color: #374151; }
        
        .accessibility-toggle { transition: all 0.3s ease; }
        .accessibility-toggle:hover { transform: scale(1.1); }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark text-[#111318] dark:text-white min-h-screen" id="main-content">
    
    <!-- Skip to content -->
    <a href="#main-content" class="skip-to-content focus:top-0">Saltar al contenido principal</a>
    
    <!-- Panel de Accesibilidad -->
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
                    <button onclick="setContrast('normal')"  class="px-3 py-2 bg-gray-100 rounded hover:bg-gray-200 text-sm">Normal</button>
                    <button onclick="setContrast('high')"    class="px-3 py-2 bg-gray-100 rounded hover:bg-gray-200 text-sm">Alto</button>
                    <button onclick="setContrast('yellow')"  class="px-3 py-2 bg-gray-100 rounded hover:bg-gray-200 text-sm">Amarillo</button>
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
    
    <!-- Botón de accesibilidad -->
    <button onclick="toggleAccessibilityPanel()" 
            class="fixed top-20 right-0 z-40 bg-primary text-white p-3 rounded-l-lg shadow-lg hover:bg-blue-700 transition-colors accessibility-toggle"
            aria-label="Abrir panel de accesibilidad">
        <span class="material-symbols-outlined">accessibility_new</span>
    </button>

    <div class="flex h-screen overflow-hidden">
        
        <%-- ✅ SIDEBAR: barra lateral con navegación y roles --%>
        <%@ include file="includes/sidebar.jsp" %>
        
        <!-- CONTENIDO PRINCIPAL -->
        <main class="flex-1 flex flex-col overflow-y-auto">
            
            <%-- ✅ HEADER: barra superior con foto dinámica del usuario --%>
            <%@ include file="includes/header.jsp" %>
            
            <!-- CONTENIDO DE LA PÁGINA -->
            <div class="p-8">
                
                <!-- Título y botón registrar -->
                <div class="flex justify-between items-center mb-6">
                    <div>
                        <h2 class="text-2xl font-bold text-[#111318] dark:text-white">Gestión de Alumnos</h2>
                        <p class="text-[#616f89] dark:text-gray-400 mt-1">Administra los estudiantes del sistema educativo</p>
                    </div>
                    <a href="AlumnoServlet?accion=nuevo" 
                       class="flex items-center gap-2 px-4 py-2.5 bg-gradient-to-r from-primary to-blue-700 hover:from-blue-700 hover:to-blue-800 text-white font-medium rounded-lg transition-all duration-300 transform hover:scale-[1.02]">
                        <span class="material-symbols-outlined">person_add</span>
                        <span>Registrar Alumno</span>
                    </a>
                </div>
                
                <!-- Alertas de sesión -->
                <%
                    String error = (String) session.getAttribute("error");
                    String mensaje = (String) session.getAttribute("mensaje");
                    if (error != null) { session.removeAttribute("error"); %>
                    <div class="alert-modern alert-danger mb-4" role="alert">
                        <i class="fas fa-exclamation-circle"></i>
                        <div><strong>Error:</strong> <%= error %></div>
                    </div>
                <% } if (mensaje != null) { session.removeAttribute("mensaje"); %>
                    <div class="alert-modern alert-success mb-4" role="alert">
                        <i class="fas fa-check-circle"></i>
                        <div><strong>Éxito:</strong> <%= mensaje %></div>
                    </div>
                <% } %>
                
                <!-- Filtro por Grado -->
                <div class="filter-card">
                    <h3 class="font-medium text-lg text-[#111318] dark:text-white mb-3">Filtrar Alumnos</h3>
                    <form action="AlumnoServlet" method="get" class="flex flex-col md:flex-row gap-4 items-start md:items-end">
                        <input type="hidden" name="accion" value="filtrar">
                        <div class="flex-1">
                            <label for="grado_id" class="block text-sm font-medium text-[#111318] dark:text-white mb-2">
                                Grado Académico
                            </label>
                            <div class="relative">
                                <span class="absolute left-3 top-3 material-symbols-outlined text-gray-400">filter_alt</span>
                                <select name="grado_id" id="grado_id" 
                                        class="pl-10 w-full p-3 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-gray-800 focus:ring-2 focus:ring-primary focus:border-transparent">
                                    <option value="">-- Todos los grados --</option>
                                    <% if (grados != null) { for (Grado g : grados) { %>
                                    <option value="<%= g.getId() %>" <%= (gradoSeleccionado != null && gradoSeleccionado == g.getId()) ? "selected" : "" %>>
                                        <%= g.getNombre() %> - <%= g.getNivel() %>
                                    </option>
                                    <% } } %>
                                </select>
                            </div>
                        </div>
                        <div>
                            <button type="submit" 
                                    class="flex items-center gap-2 px-4 py-3 bg-primary hover:bg-blue-700 text-white font-medium rounded-lg transition-all duration-300">
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
                                    <th>Alumno</th>
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
                                        for (Alumno al : lista) {
                                %>
                                <tr>
                                    <td class="font-medium">
                                        <div class="flex items-center gap-3">
                                            <%-- Avatar: foto o iniciales --%>
                                            <% if (al.getFoto() != null && !al.getFoto().isEmpty()) { %>
                                                <div class="size-9 rounded-full overflow-hidden border-2 border-blue-200 flex-shrink-0">
                                                    <img src="uploads/<%= al.getFoto() %>" 
                                                         alt="<%= al.getNombres() %>"
                                                         style="width:100%;height:100%;object-fit:cover;"
                                                         onerror="this.parentElement.innerHTML='<span style=\'display:flex;align-items:center;justify-content:center;width:100%;height:100%;background:#dbeafe;color:#1d4ed8;font-weight:700;font-size:0.85rem;\'><%= al.getNombres().substring(0,1) %></span>'">
                                                </div>
                                            <% } else { %>
                                                <div class="size-9 rounded-full bg-blue-100 dark:bg-blue-900 flex items-center justify-center flex-shrink-0">
                                                    <span class="text-blue-600 dark:text-blue-300 font-bold text-sm">
                                                        <%= al.getNombres().substring(0,1) %><%= al.getApellidos().substring(0,1) %>
                                                    </span>
                                                </div>
                                            <% } %>
                                            <span><%= al.getNombres() %></span>
                                        </div>
                                    </td>
                                    <td><%= al.getApellidos() %></td>
                                    <td>
                                        <div class="flex items-center gap-2">
                                            <span class="material-symbols-outlined text-gray-400 text-sm">mail</span>
                                            <span class="text-blue-600 dark:text-blue-400"><%= al.getCorreo() %></span>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="status-badge bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200">
                                            <%= al.getFechaNacimiento() %>
                                        </span>
                                    </td>
                                    <td>
                                        <div class="flex gap-2">
                                            <!-- VER DETALLE -->
                                            <a href="AlumnoServlet?accion=ver&id=<%= al.getId() %>" 
                                               class="btn-icon bg-green-100 text-green-600 hover:bg-green-200 dark:bg-green-900 dark:text-green-300"
                                               title="Ver detalle" aria-label="Ver detalle de <%= al.getNombres() %>">
                                                <span class="material-symbols-outlined text-sm">visibility</span>
                                            </a>
                                            <!-- EDITAR -->
                                            <a href="AlumnoServlet?accion=editar&id=<%= al.getId() %>" 
                                               class="btn-icon bg-blue-100 text-blue-600 hover:bg-blue-200 dark:bg-blue-900 dark:text-blue-300"
                                               title="Editar" aria-label="Editar <%= al.getNombres() %>">
                                                <span class="material-symbols-outlined text-sm">edit</span>
                                            </a>
                                            <!-- ELIMINAR -->
                                            <a href="AlumnoServlet?accion=eliminar&id=<%= al.getId() %>" 
                                               class="btn-icon bg-red-100 text-red-600 hover:bg-red-200 dark:bg-red-900 dark:text-red-300"
                                               title="Eliminar" aria-label="Eliminar <%= al.getNombres() %>"
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
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
                
                <!-- Info adicional -->
                <div class="mt-6 p-4 bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg">
                    <div class="flex items-start gap-3">
                        <span class="material-symbols-outlined text-blue-600 dark:text-blue-400 mt-0.5">info</span>
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
        function toggleAccessibilityPanel() {
            document.querySelector('.accessibility-panel').classList.toggle('open');
        }
        function setTextSize(size) {
            document.body.classList.remove('large-text', 'larger-text', 'largest-text');
            if (size !== 'normal') document.body.classList.add(size + '-text');
        }
        function setContrast(mode) {
            document.body.classList.remove('high-contrast-invert', 'high-contrast-yellow');
            if (mode === 'high')    document.body.classList.add('high-contrast-invert');
            if (mode === 'yellow')  document.body.classList.add('high-contrast-yellow');
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
