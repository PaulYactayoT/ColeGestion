<%-- 
    Document   : grados
    Created on : 1 may. 2025, 10:56:05 p. m.
    Author     : Juan Pablo Amaya
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, modelo.Grado" %>
<%@ page import="javax.servlet.http.HttpSession" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    // Título para el header dinámico
    request.setAttribute("pageTitle", "Listado de Grados");
%>

<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Grados - San Antonio</title>
    
    <%-- ✅ Incluir HEAD común (Tailwind, fuentes, estilos globales) --%>
    <%@ include file="includes/head.jsp" %>
    
    <style>
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

        /* Estilos para la tabla */
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

        .custom-table th {
            padding: 1rem;
            text-align: left;
            font-weight: 600;
            color: white;
            font-size: 0.875rem;
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
            font-size: 0.875rem;
        }

        .dark .custom-table td {
            color: #d1d5db;
        }

        .status-badge {
            padding: 0.25rem 0.75rem;
            border-radius: 9999px;
            font-size: 0.75rem;
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

        /* Botón de accesibilidad */
        .accessibility-toggle {
            transition: all 0.3s ease;
        }

        .accessibility-toggle:hover {
            transform: scale(1.1);
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
        
        <%-- ✅ SIDEBAR: barra lateral con navegación y roles --%>
        <%
            String rolSidebarU = (String) session.getAttribute("rol");
            String sidebarFileU = "administrativo".equals(rolSidebarU) 
                                 ? "includes/sidebarAdministrativo.jsp" 
                                 : "includes/sidebar.jsp";
        %>
        <jsp:include page="<%= sidebarFileU %>" />
        
        <!-- Main Content -->
        <main class="flex-1 flex flex-col overflow-y-auto">
            
            <%-- ✅ HEADER: barra superior con foto dinámica del usuario --%>
            <%@ include file="includes/header.jsp" %>
            
            <!-- Main Content -->
            <div class="p-8">
                <!-- Header con título y botón -->
                <div class="flex justify-between items-center mb-6">
                    <div>
                        <h2 class="text-2xl font-bold text-[#111318] dark:text-white">Grados Académicos</h2>
                        <p class="text-[#616f89] dark:text-gray-400 mt-1">Gestiona los grados académicos del sistema</p>
                    </div>
                    <a href="gradoForm.jsp" 
                       class="flex items-center gap-2 px-4 py-2.5 bg-gradient-to-r from-red-600 to-red-700 hover:from-red-700 hover:to-red-800 text-white font-medium rounded-lg transition-all duration-300 transform hover:scale-[1.02] focus:outline focus:outline-3 focus:outline-red-500">
                        <span class="material-symbols-outlined">add</span>
                        <span>Registrar Grado</span>
                    </a>
                </div>
                
                <!-- Tabla de grados -->
                <div class="bg-white dark:bg-[#1a2233] rounded-xl border border-[#dbdfe6] dark:border-gray-700 shadow-sm overflow-hidden">
                    <div class="overflow-x-auto">
                        <table class="custom-table">
                            <thead>
                                <tr>
                                    <th>Nombre del Grado</th>
                                    <th>Nivel Educativo</th>
                                    <th>Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    List<Grado> lista = (List<Grado>) request.getAttribute("lista");
                                    if (lista != null && !lista.isEmpty()) {
                                        for (Grado g : lista) {
                                %>
                                <tr>
                                    <td class="font-medium">
                                        <div class="flex items-center gap-3">
                                            <div class="size-8 rounded-lg bg-primary/10 flex items-center justify-center">
                                                <span class="material-symbols-outlined text-primary text-sm">school</span>
                                            </div>
                                            <span><%= g.getNombre()%></span>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="status-badge bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200">
                                            <%= g.getNivel()%>
                                        </span>
                                    </td>
                                    <td>
                                        <div class="flex gap-2">
                                            <a href="GradoServlet?accion=editar&id=<%= g.getId()%>" 
                                               class="btn-icon bg-blue-100 text-blue-600 hover:bg-blue-200 dark:bg-blue-900 dark:text-blue-300 dark:hover:bg-blue-800 focus:outline focus:outline-2 focus:outline-blue-500"
                                               title="Editar grado"
                                               aria-label="Editar grado <%= g.getNombre()%>">
                                                <span class="material-symbols-outlined text-sm">edit</span>
                                            </a>
                                            <a href="GradoServlet?accion=eliminar&id=<%= g.getId()%>" 
                                               class="btn-icon bg-red-100 text-red-600 hover:bg-red-200 dark:bg-red-900 dark:text-red-300 dark:hover:bg-red-800 focus:outline focus:outline-2 focus:outline-red-500"
                                               title="Eliminar grado"
                                               aria-label="Eliminar grado <%= g.getNombre()%>"
                                               onclick="return confirm('¿Deseas eliminar este grado?')">
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
                                    <td colspan="3" class="text-center py-8">
                                        <div class="flex flex-col items-center justify-center text-gray-400">
                                            <span class="material-symbols-outlined text-4xl mb-2">school</span>
                                            <p class="text-lg font-medium">No hay grados registrados</p>
                                            <p class="text-sm">Comienza registrando un nuevo grado</p>
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
                                <li>• Los grados no pueden eliminarse si tienen estudiantes asignados</li>
                                <li>• Cada nivel puede tener múltiples grados</li>
                                <li>• Verifique que el nombre del grado no exista previamente al registrar uno nuevo</li>
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
        });
        
        // Auto-focus en la página de carga
        window.addEventListener('load', function() {
            // Enfocar el botón de registrar si existe
            const registrarBtn = document.querySelector('a[href="gradoForm.jsp"]');
            if (registrarBtn) {
                registrarBtn.focus();
            }
        });
    </script>
</body>
</html>
