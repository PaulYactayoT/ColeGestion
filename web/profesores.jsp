<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, modelo.Profesor" %>
<%@ page import="javax.servlet.http.HttpSession" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setHeader("Expires", "0");

    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    List<Profesor> lista = (List<Profesor>) request.getAttribute("lista");
    
    // Título para el header dinámico
    request.setAttribute("pageTitle", "Listado de Profesores");
%>

<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profesores - San Antonio</title>

    <%-- ✅ Incluir HEAD común --%>
    <%@ include file="includes/head.jsp" %>

    <style>
        /* Accesibilidad */
        .reduce-motion * { animation-duration: 0.01ms !important; animation-iteration-count: 1 !important; transition-duration: 0.01ms !important; }
        .high-contrast-invert { filter: invert(1) hue-rotate(180deg); }
        .high-contrast-yellow { background-color: #000000 !important; color: #ffff00 !important; }
        .beige-background { background-color: #f5f5dc !important; }
        .large-text  { font-size: 18px !important; }
        .larger-text { font-size: 20px !important; }
        .largest-text{ font-size: 22px !important; }
        .large-text  .custom-table th, .large-text  .custom-table td, .large-text  .text-sm, .large-text  .text-xs { font-size: 16px !important; }
        .larger-text .custom-table th, .larger-text .custom-table td, .larger-text .text-sm, .larger-text .text-xs { font-size: 18px !important; }
        .largest-text .custom-table th,.largest-text .custom-table td,.largest-text .text-sm,.largest-text .text-xs { font-size: 20px !important; }
        .dyslexia-font { font-family: Arial !important; font-size: 1.1em !important; line-height: 1.6 !important; letter-spacing: 0.5px !important; }
        .dyslexia-font .custom-table th, .dyslexia-font .custom-table td { font-family: Arial !important; line-height: 1.6 !important; }

        .accessibility-panel { transform: translateX(100%); transition: transform 0.3s ease; }
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
        .accessibility-toggle { transition: all 0.3s ease; }
        .accessibility-toggle:hover { transform: scale(1.1); }
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

    <button onclick="toggleAccessibilityPanel()"
            class="fixed top-20 right-0 z-40 bg-primary text-white p-3 rounded-l-lg shadow-lg hover:bg-blue-700 transition-colors accessibility-toggle"
            aria-label="Abrir panel de accesibilidad">
        <span class="material-symbols-outlined">accessibility_new</span>
    </button>

    <div class="flex h-screen overflow-hidden">

        <%-- ✅ SIDEBAR --%>
        <%@ include file="includes/sidebar.jsp" %>

        <main class="flex-1 flex flex-col overflow-y-auto">

            <%-- ✅ HEADER con foto dinámica --%>
            <%@ include file="includes/header.jsp" %>

            <div class="p-8">

                <%-- Alertas --%>
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

                <%-- Título y botón registrar --%>
                <div class="flex justify-between items-center mb-6">
                    <div>
                        <h2 class="text-2xl font-bold text-[#111318] dark:text-white">Gestión de Profesores</h2>
                        <p class="text-[#616f89] dark:text-gray-400 mt-1">Administra los profesores del sistema educativo</p>
                    </div>
                    <a href="ProfesorServlet?accion=nuevo"
                       class="flex items-center gap-2 px-4 py-2.5 bg-gradient-to-r from-primary to-blue-600 hover:from-blue-600 hover:to-blue-700 text-white font-medium rounded-lg transition-all duration-300 transform hover:scale-[1.02]">
                        <span class="material-symbols-outlined">person_add</span>
                        <span>Registrar Profesor</span>
                    </a>
                </div>

                <%-- Buscador en vivo --%>
                <div class="mb-8 max-w-md">
                    <form action="ProfesorServlet" method="GET">
                        <input type="hidden" name="accion" value="listar">
                        <div class="relative group">
                            <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                <span class="material-symbols-outlined text-gray-500">person_search</span>
                            </div>
                            <input type="text" name="txtBuscar" id="txtBuscar"
                                   class="block w-full pl-10 pr-3 py-3 border-none rounded-lg bg-gray-100 dark:bg-gray-800 text-gray-900 dark:text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-primary/50 focus:bg-white dark:focus:bg-[#1a2233] transition-all duration-200 sm:text-sm shadow-inner"
                                   placeholder="Filtrar resultados..."
                                   autocomplete="off"
                                   value="<%= request.getParameter("txtBuscar") != null ? request.getParameter("txtBuscar") : "" %>">
                            <div class="absolute bottom-0 left-0 h-[2px] w-0 bg-primary transition-all duration-300 group-focus-within:w-full"></div>
                        </div>
                    </form>
                </div>

                <%-- Tabla de profesores --%>
                <div class="bg-white dark:bg-[#1a2233] rounded-xl border border-[#dbdfe6] dark:border-gray-700 shadow-sm overflow-hidden">
                    <div class="overflow-x-auto">
                        <table class="custom-table">
                            <thead>
                                <tr>
                                    <th>Profesor</th>
                                    <th>Apellidos</th>
                                    <th>Correo</th>
                                    <th>Área Principal</th>
                                    <th>Nivel</th>
                                    <th>Estado</th>
                                    <th>Acciones</th>
                                </tr>
                            </thead>
                            <tbody id="tablaResultados">
                                <%
                                    if (lista != null && !lista.isEmpty()) {
                                        for (Profesor p : lista) {
                                            String nivel = p.getNivel();
                                            String nivelBadgeClass = "bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300";
                                            if      ("INICIAL".equals(nivel))    nivelBadgeClass = "bg-sky-100 text-sky-800 dark:bg-sky-900 dark:text-sky-200";
                                            else if ("PRIMARIA".equals(nivel))   nivelBadgeClass = "bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200";
                                            else if ("SECUNDARIA".equals(nivel)) nivelBadgeClass = "bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200";
                                            else if ("TODOS".equals(nivel))      nivelBadgeClass = "bg-purple-100 text-purple-800 dark:bg-purple-900 dark:text-purple-200";

                                            String estado = p.getEstado();
                                            String estadoBadgeClass = "bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300";
                                            if      ("ACTIVO".equals(estado))   estadoBadgeClass = "bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200";
                                            else if ("INACTIVO".equals(estado)) estadoBadgeClass = "bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200";
                                            else if ("LICENCIA".equals(estado)) estadoBadgeClass = "bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200";
                                            else if ("JUBILADO".equals(estado)) estadoBadgeClass = "bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300";
                                %>
                                <tr>
                                    <td class="font-medium">
                                        <div class="flex items-center gap-3">
                                            <%-- Avatar: foto o iniciales --%>
                                            <% if (p.getFoto() != null && !p.getFoto().isEmpty()) { %>
                                                <div class="size-9 rounded-full overflow-hidden border-2 border-purple-200 flex-shrink-0">
                                                    <img src="uploads/<%= p.getFoto() %>"
                                                         alt="<%= p.getNombres() %>"
                                                         style="width:100%;height:100%;object-fit:cover;"
                                                         onerror="this.parentElement.innerHTML='<span style=\'display:flex;align-items:center;justify-content:center;width:100%;height:100%;background:#f3e8ff;color:#7e22ce;font-weight:700;font-size:0.85rem;\'><%= p.getNombres().substring(0,1) %></span>'">
                                                </div>
                                            <% } else { %>
                                                <div class="size-9 rounded-full bg-purple-100 dark:bg-purple-900 flex items-center justify-center flex-shrink-0">
                                                    <span class="text-purple-600 dark:text-purple-300 font-bold text-sm">
                                                        <%= p.getNombres().substring(0,1) %><%= p.getApellidos().substring(0,1) %>
                                                    </span>
                                                </div>
                                            <% } %>
                                            <span><%= p.getNombres() %></span>
                                        </div>
                                    </td>
                                    <td><%= p.getApellidos() %></td>
                                    <td>
                                        <div class="flex items-center gap-2">
                                            <span class="material-symbols-outlined text-gray-400 text-sm">mail</span>
                                            <span class="text-blue-600 dark:text-blue-400"><%= p.getCorreo() %></span>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="status-badge bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200">
                                            <%= p.getAreaNombre() != null ? p.getAreaNombre() : "Sin área" %>
                                        </span>
                                    </td>
                                    <td>
                                        <span class="status-badge <%= nivelBadgeClass %>">
                                            <%= nivel != null ? nivel : "Sin nivel" %>
                                        </span>
                                    </td>
                                    <td>
                                        <span class="status-badge <%= estadoBadgeClass %>">
                                            <%= estado != null ? estado : "ACTIVO" %>
                                        </span>
                                    </td>
                                    <td>
                                        <div class="flex gap-2">
                                            <a href="ProfesorServlet?accion=editar&id=<%= p.getId() %>"
                                               class="btn-icon bg-blue-100 text-blue-600 hover:bg-blue-200 dark:bg-blue-900 dark:text-blue-300"
                                               title="Editar" aria-label="Editar <%= p.getNombres() %>">
                                                <span class="material-symbols-outlined text-sm">edit</span>
                                            </a>
                                            <a href="ProfesorServlet?accion=ver&id=<%= p.getId() %>"
                                               class="btn-icon bg-green-100 text-green-600 hover:bg-green-200 dark:bg-green-900 dark:text-green-300"
                                               title="Ver detalles" aria-label="Ver detalles de <%= p.getNombres() %>">
                                                <span class="material-symbols-outlined text-sm">visibility</span>
                                            </a>
                                            <a href="ProfesorServlet?accion=eliminar&id=<%= p.getId() %>"
                                               class="btn-icon bg-red-100 text-red-600 hover:bg-red-200 dark:bg-red-900 dark:text-red-300"
                                               title="Eliminar" aria-label="Eliminar <%= p.getNombres() %>"
                                               onclick="return confirm('¿Estás seguro de eliminar este profesor?')">
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
                                    <td colspan="7" class="text-center py-8">
                                        <div class="flex flex-col items-center justify-center text-gray-400">
                                            <span class="material-symbols-outlined text-4xl mb-2">school</span>
                                            <p class="text-lg font-medium">No hay profesores registrados</p>
                                            <p class="text-sm">Comienza registrando un nuevo profesor</p>
                                        </div>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>

                <%-- Info --%>
                <div class="mt-6 p-4 bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg">
                    <div class="flex items-start gap-3">
                        <span class="material-symbols-outlined text-blue-600 dark:text-blue-400 mt-0.5">info</span>
                        <div>
                            <h4 class="font-medium text-blue-800 dark:text-blue-300">Información importante:</h4>
                            <ul class="mt-2 text-sm text-blue-700 dark:text-blue-400 space-y-1">
                                <li>• Para registrar un nuevo profesor, haz clic en "Registrar Profesor"</li>
                                <li>• Los colores de los badges indican el nivel y estado del profesor</li>
                                <li>• Para editar la información de un profesor, utiliza el botón de editar</li>
                                <li>• Ten cuidado al eliminar profesores, esta acción no se puede deshacer</li>
                                <li>• Puedes ver los detalles completos usando el botón "Ver detalles"</li>
                            </ul>
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
            document.body.offsetHeight;
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

        document.addEventListener('DOMContentLoaded', function() {
            // Navegación por teclado en tabla
            document.querySelectorAll('.custom-table tbody tr').forEach(row => {
                row.setAttribute('tabindex', '0');
                row.addEventListener('keydown', function(e) {
                    if (e.key === 'Enter' || e.key === ' ') {
                        e.preventDefault();
                        const firstLink = row.querySelector('a');
                        if (firstLink) firstLink.click();
                    }
                });
            });

            // Búsqueda en vivo letra por letra
            const inputBuscar = document.getElementById('txtBuscar');
            const tablaResultados = document.getElementById('tablaResultados');
            let timeout = null;

            if (inputBuscar && tablaResultados) {
                inputBuscar.addEventListener('input', function() {
                    clearTimeout(timeout);
                    timeout = setTimeout(() => realizarBusqueda(this.value), 300);
                });
            }

            function realizarBusqueda(texto) {
                fetch('ProfesorServlet?accion=listar&txtBuscar=' + encodeURIComponent(texto))
                    .then(r => r.text())
                    .then(html => {
                        const doc = new DOMParser().parseFromString(html, 'text/html');
                        const nuevaTabla = doc.getElementById('tablaResultados');
                        if (nuevaTabla) {
                            tablaResultados.innerHTML = nuevaTabla.innerHTML;
                            tablaResultados.querySelectorAll('tr').forEach(r => r.setAttribute('tabindex', '0'));
                        }
                    })
                    .catch(err => console.error('Error en búsqueda:', err));
            }
        });
    </script>
</body>
</html>
