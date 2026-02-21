<%-- 
    Document   : administrativoList
    Created on : 16 feb. 2026
    Author     : Ocelot
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, modelo.Administrativo, java.time.format.DateTimeFormatter" %>
<%
    // Variables específicas de esta página solamente
    List<Administrativo> listaAdministrativos = (List<Administrativo>) request.getAttribute("administrativos");
    String terminoBusquedaAdmin = (String) request.getAttribute("terminoBusqueda");
    request.setAttribute("pageTitle", "Gestión de Personal Administrativo");
%>

<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Personal Administrativo - San Antonio</title>

    <%@ include file="includes/head.jsp" %>

    <style>
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
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark text-[#111318] dark:text-white min-h-screen">

    <div class="flex h-screen overflow-hidden">

        <%
            String rolSidebarU = (String) session.getAttribute("rol");
            String sidebarFileU = "administrativo".equals(rolSidebarU) 
                                 ? "includes/sidebarAdministrativo.jsp" 
                                 : "includes/sidebar.jsp";
        %>
        <jsp:include page="<%= sidebarFileU %>" />

        <main class="flex-1 flex flex-col overflow-y-auto">

            <%@ include file="includes/header.jsp" %>

            <div class="p-8">

                <%-- Alertas --%>
                <% 
                    String alertError = (String) session.getAttribute("error");
                    String alertMensaje = (String) session.getAttribute("mensaje");
                    if (alertError != null) { 
                        session.removeAttribute("error"); 
                %>
                    <div class="alert-modern alert-danger mb-4" role="alert">
                        <i class="fas fa-exclamation-circle"></i>
                        <div><strong>Error:</strong> <%= alertError %></div>
                    </div>
                <% } 
                   if (alertMensaje != null) { 
                       session.removeAttribute("mensaje"); 
                %>
                    <div class="alert-modern alert-success mb-4" role="alert">
                        <i class="fas fa-check-circle"></i>
                        <div><strong>Éxito:</strong> <%= alertMensaje %></div>
                    </div>
                <% } %>

                <%-- Header --%>
                <div class="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6 mb-6">
                    <div class="flex flex-col md:flex-row justify-between items-center gap-4">
                        <div class="flex items-center gap-4">
                            <div class="p-3 bg-primary/10 rounded-lg">
                                <span class="material-symbols-outlined text-primary text-3xl">badge</span>
                            </div>
                            <div>
                                <h1 class="text-2xl font-bold text-gray-800 dark:text-white">Personal Administrativo</h1>
                                <p class="text-sm text-gray-600 dark:text-gray-400">
                                    <%= listaAdministrativos != null ? listaAdministrativos.size() : 0 %> administrativo(s) registrado(s)
                                </p>
                            </div>
                        </div>

                        <div class="flex flex-col md:flex-row gap-3 w-full md:w-auto">
                            <form action="AdministrativoServlet" method="get" class="flex gap-2">
                                <input type="hidden" name="action" value="buscar">
                                <input type="text" name="q" id="txtBuscar"
                                       value="<%= terminoBusquedaAdmin != null ? terminoBusquedaAdmin : "" %>"
                                       placeholder="Buscar por nombre, DNI, cargo..."
                                       class="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent dark:bg-gray-700 dark:border-gray-600 dark:text-white">
                                <button type="submit" class="px-4 py-2 bg-gray-200 hover:bg-gray-300 dark:bg-gray-700 dark:hover:bg-gray-600 text-gray-800 dark:text-white rounded-lg transition-colors">
                                    <span class="material-symbols-outlined">search</span>
                                </button>
                            </form>

                            <a href="AdministrativoServlet?action=nuevo" 
                               class="px-4 py-2 bg-primary hover:bg-blue-700 text-white rounded-lg font-medium transition-colors flex items-center justify-center gap-2 whitespace-nowrap">
                                <span class="material-symbols-outlined">add</span>
                                <span>Registrar Administrativo</span>
                            </a>
                        </div>
                    </div>
                </div>

                <%-- Tabla --%>
                <div class="bg-white dark:bg-gray-800 rounded-lg shadow-lg overflow-hidden">
                    <div class="overflow-x-auto">
                        <table class="custom-table" id="tablaResultados">
                            <thead>
                                <tr>
                                    <th>Administrativo</th>
                                    <th>Apellidos</th>
                                    <th>Correo</th>
                                    <th>Cargo</th>
                                    <th>Departamento</th>
                                    <th>Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    if (listaAdministrativos != null && !listaAdministrativos.isEmpty()) {
                                        for (Administrativo admItem : listaAdministrativos) {
                                            // Obtener iniciales para el avatar
                                            String inicialesAdmin = "";
                                            if (admItem.getNombres() != null && !admItem.getNombres().isEmpty()) {
                                                inicialesAdmin += admItem.getNombres().substring(0, 1);
                                            }
                                            if (admItem.getApellidos() != null && !admItem.getApellidos().isEmpty()) {
                                                inicialesAdmin += admItem.getApellidos().substring(0, 1);
                                            }
                                %>
                                <tr>
                                    <td>
                                        <div class="flex items-center gap-3">
                                            <% if (admItem.getFoto() != null && !admItem.getFoto().isEmpty()) { %>
                                                <img src="uploads/<%= admItem.getFoto() %>" 
                                                     alt="<%= admItem.getNombres() %>" 
                                                     class="w-10 h-10 rounded-full object-cover border-2 border-primary/20">
                                            <% } else { %>
                                                <div class="w-10 h-10 rounded-full bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center text-white font-bold text-sm border-2 border-primary/20">
                                                    <%= inicialesAdmin %>
                                                </div>
                                            <% } %>
                                            <span class="font-medium"><%= admItem.getNombres() != null ? admItem.getNombres() : "-" %></span>
                                        </div>
                                    </td>
                                    <td><%= admItem.getApellidos() != null ? admItem.getApellidos() : "-" %></td>
                                    <td>
                                        <div class="flex items-center gap-2">
                                            <span class="material-symbols-outlined text-sm text-gray-400">mail</span>
                                            <span><%= admItem.getCorreo() != null ? admItem.getCorreo() : "-" %></span>
                                        </div>
                                    </td>
                                    <td><%= admItem.getCargo() != null ? admItem.getCargo() : "-" %></td>
                                    <td><%= admItem.getDepartamento() != null ? admItem.getDepartamento() : "-" %></td>
                                    <td>
                                        <div class="flex gap-2">
                                            <a href="AdministrativoServlet?action=ver&id=<%= admItem.getId() %>"
                                               class="btn-icon bg-green-100 text-green-600 hover:bg-green-200 dark:bg-green-900 dark:text-green-300"
                                               title="Ver detalles" aria-label="Ver detalles de <%= admItem.getNombres() %>">
                                                <span class="material-symbols-outlined text-sm">visibility</span>
                                            </a>
                                            <a href="AdministrativoServlet?action=editar&id=<%= admItem.getId() %>"
                                               class="btn-icon bg-blue-100 text-blue-600 hover:bg-blue-200 dark:bg-blue-900 dark:text-blue-300"
                                               title="Editar" aria-label="Editar <%= admItem.getNombres() %>">
                                                <span class="material-symbols-outlined text-sm">edit</span>
                                            </a>
                                            <a href="AdministrativoServlet?action=eliminar&id=<%= admItem.getId() %>"
                                               class="btn-icon bg-red-100 text-red-600 hover:bg-red-200 dark:bg-red-900 dark:text-red-300"
                                               title="Eliminar" aria-label="Eliminar <%= admItem.getNombres() %>"
                                               onclick="return confirm('¿Estás seguro de eliminar a <%= admItem.getNombreCompleto() %>?\n\nEsta acción solo marcará el registro como eliminado.')">
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
                                    <td colspan="6" class="text-center py-8">
                                        <div class="flex flex-col items-center justify-center text-gray-400">
                                            <span class="material-symbols-outlined text-4xl mb-2">badge</span>
                                            <p class="text-lg font-medium">No hay administrativos registrados</p>
                                            <p class="text-sm">Comienza registrando un nuevo administrativo</p>
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
                                <li>• Para registrar un nuevo administrativo, haz clic en "Registrar Administrativo"</li>
                                <li>• Los colores de los badges indican el estado del administrativo</li>
                                <li>• Para editar la información de un administrativo, utiliza el botón de editar</li>
                                <li>• La eliminación es lógica: el registro se marca como eliminado pero no se borra físicamente</li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <script>
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
                fetch('AdministrativoServlet?action=buscar&q=' + encodeURIComponent(texto))
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



