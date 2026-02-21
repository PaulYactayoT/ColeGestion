<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="modelo.MasterTable" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    request.setAttribute("pageTitle", "Master Table CRUD");
    
    List<MasterTable> listaMasterTable = (List<MasterTable>) request.getAttribute("listaMasterTable");
    List<MasterTable> categorias = (List<MasterTable>) request.getAttribute("categorias");
    List<String[]> estadisticas = (List<String[]>) request.getAttribute("estadisticas");
    String statusFilter = (String) request.getAttribute("statusFilter");
    String categoryFilter = (String) request.getAttribute("categoryFilter");
    String searchTerm = (String) request.getAttribute("searchTerm");
    Boolean vistaCategoria = (Boolean) request.getAttribute("vistaCategoria");
    
    String successMsg = (String) session.getAttribute("success");
    String errorMsg = (String) session.getAttribute("error");
    session.removeAttribute("success");
    session.removeAttribute("error");
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Master Table CRUD - San Antonio</title>
    <%@ include file="includes/head.jsp" %>
    
    <style>
        .badge-active { background-color: #10b981; color: white; }
        .badge-inactive { background-color: #ef4444; color: white; }
        .badge-category { background-color: #3b82f6; color: white; }
        .stat-card { transition: transform 0.2s; }
        .stat-card:hover { transform: translateY(-4px); }
    </style>
</head>
<body class="bg-gray-50 dark:bg-gray-900">

    <div class="flex h-screen overflow-hidden">
        <%@ include file="includes/sidebar.jsp" %>

        <main class="flex-1 flex flex-col overflow-y-auto">
            <%@ include file="includes/header.jsp" %>

            <div class="p-8 space-y-6">
                
                <%-- Mensajes de éxito/error --%>
                <% if (successMsg != null) { %>
                <div class="bg-green-100 border-l-4 border-green-500 text-green-700 p-4 rounded-lg shadow-sm" role="alert">
                    <div class="flex items-center">
                        <i class="fas fa-check-circle mr-3 text-xl"></i>
                        <p class="font-medium"><%= successMsg %></p>
                    </div>
                </div>
                <% } %>
                
                <% if (errorMsg != null) { %>
                <div class="bg-red-100 border-l-4 border-red-500 text-red-700 p-4 rounded-lg shadow-sm" role="alert">
                    <div class="flex items-center">
                        <i class="fas fa-exclamation-circle mr-3 text-xl"></i>
                        <p class="font-medium"><%= errorMsg %></p>
                    </div>
                </div>
                <% } %>

                <%-- Header con título y botones --%>
                <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                    <div>
                        <h1 class="text-3xl font-bold text-gray-900 dark:text-white">
                            <i class="fas fa-table text-indigo-600 mr-2"></i>
                            Master Table CRUD
                        </h1>
                        <p class="text-gray-600 dark:text-gray-400 mt-1">Gestión centralizada de catálogos del sistema</p>
                    </div>
                    
                    <div class="flex gap-3">
                        <a href="MasterTableServlet?action=categorias" 
                           class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors flex items-center gap-2">
                            <i class="fas fa-folder-open"></i>
                            <span>Ver Categorías</span>
                        </a>
                        <a href="MasterTableServlet?action=nuevo" 
                           class="px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition-colors flex items-center gap-2">
                            <i class="fas fa-plus"></i>
                            <span>Nuevo Registro</span>
                        </a>
                         <%-- NUEVO BOTÓN --%>
    <a href="ejecutarSP.jsp" 
       class="px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors flex items-center gap-2">
        <i class="fas fa-terminal"></i>
        <span>Ejecutar SP</span>
    </a> 
                    </div>
                </div>

                <%-- Estadísticas --%>
                <% if (estadisticas != null && !estadisticas.isEmpty()) { %>
                <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
                    <% for (String[] stat : estadisticas) { %>
                    <div class="stat-card bg-white dark:bg-gray-800 rounded-xl p-6 shadow-sm border border-gray-200 dark:border-gray-700">
                        <div class="flex items-center justify-between">
                            <div>
                                <p class="text-sm text-gray-600 dark:text-gray-400"><%= stat[0] %></p>
                                <p class="text-2xl font-bold text-gray-900 dark:text-white mt-1"><%= stat[1] %></p>
                            </div>
                            <div class="text-3xl text-indigo-600">
                                <i class="fas fa-database"></i>
                            </div>
                        </div>
                    </div>
                    <% } %>
                </div>
                <% } %>

                <%-- Filtros y búsqueda --%>
                <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6">
                    <form method="GET" action="MasterTableServlet" class="grid grid-cols-1 md:grid-cols-4 gap-4">
                        <input type="hidden" name="action" value="listar">
                        
                        <%-- Búsqueda --%>
                        <div class="md:col-span-2">
                            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                <i class="fas fa-search mr-1"></i> Buscar
                            </label>
                            <input type="text" name="q" value="<%= searchTerm != null ? searchTerm : "" %>" 
                                   placeholder="Buscar por nombre, valor o descripción..."
                                   class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-indigo-500 dark:bg-gray-700 dark:text-white">
                        </div>
                        
                        <%-- Filtro por categoría --%>
                        <div>
                            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                <i class="fas fa-filter mr-1"></i> Categoría
                            </label>
                            <select name="category" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-indigo-500 dark:bg-gray-700 dark:text-white">
                                <option value="">Todas</option>
                                <% if (categorias != null) {
                                    for (MasterTable cat : categorias) { %>
                                <option value="<%= cat.getCategory() %>" <%= cat.getCategory().equals(categoryFilter) ? "selected" : "" %>>
                                    <%= cat.getName() %> (<%= cat.getTotalValues() %>)
                                </option>
                                <% } } %>
                            </select>
                        </div>
                        
                        <%-- Filtro por estado --%>
                        <div>
                            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                <i class="fas fa-toggle-on mr-1"></i> Estado
                            </label>
                            <select name="status" class="w-full px-4 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-indigo-500 dark:bg-gray-700 dark:text-white">
                                <option value="">Todos</option>
                                <option value="A" <%= "A".equals(statusFilter) ? "selected" : "" %>>Activos</option>
                                <option value="I" <%= "I".equals(statusFilter) ? "selected" : "" %>>Inactivos</option>
                            </select>
                        </div>
                        
                        <div class="md:col-span-4 flex gap-2">
                            <button type="submit" class="px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition-colors">
                                <i class="fas fa-search mr-2"></i> Buscar
                            </button>
                            <a href="MasterTableServlet?action=listar" class="px-4 py-2 bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-300 dark:hover:bg-gray-600 transition-colors">
                                <i class="fas fa-redo mr-2"></i> Limpiar
                            </a>
                        </div>
                    </form>
                </div>

                <%-- Tabla de datos --%>
                <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 overflow-hidden">
                    <div class="overflow-x-auto">
                        <table class="w-full">
                            <thead class="bg-gray-50 dark:bg-gray-700 border-b border-gray-200 dark:border-gray-600">
                                <tr>
                                    <th class="px-6 py-4 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">ID</th>
                                    <th class="px-6 py-4 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Categoría</th>
                                    <th class="px-6 py-4 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Valor</th>
                                    <th class="px-6 py-4 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Nombre</th>
                                    <th class="px-6 py-4 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Descripción</th>
                                    <th class="px-6 py-4 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Orden</th>
                                    <th class="px-6 py-4 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Estado</th>
                                    <th class="px-6 py-4 text-center text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">Acciones</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-gray-200 dark:divide-gray-600">
                                <% if (listaMasterTable != null && !listaMasterTable.isEmpty()) {
                                    for (MasterTable mt : listaMasterTable) { %>
                                <tr class="hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors">
                                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900 dark:text-white font-medium">
                                        #<%= mt.getIdMasterTable() %>
                                    </td>
                                    <td class="px-6 py-4 whitespace-nowrap">
                                        <span class="badge-category px-3 py-1 rounded-full text-xs font-medium">
                                            <%= mt.getCategory() %>
                                        </span>
                                    </td>
                                    <td class="px-6 py-4 whitespace-nowrap text-sm font-mono text-gray-700 dark:text-gray-300">
                                        <%= mt.getValue() %>
                                    </td>
                                    <td class="px-6 py-4 text-sm text-gray-900 dark:text-white font-medium">
                                        <%= mt.getName() %>
                                    </td>
                                    <td class="px-6 py-4 text-sm text-gray-600 dark:text-gray-400 max-w-xs truncate">
                                        <%= mt.getDescription() != null ? mt.getDescription() : "-" %>
                                    </td>
                                    <td class="px-6 py-4 whitespace-nowrap text-sm text-center text-gray-700 dark:text-gray-300">
                                        <%= mt.getOrderIndex() %>
                                    </td>
                                    <td class="px-6 py-4 whitespace-nowrap">
                                        <% if ("A".equals(mt.getStatus())) { %>
                                        <span class="badge-active px-3 py-1 rounded-full text-xs font-medium">
                                            <i class="fas fa-check-circle mr-1"></i> Activo
                                        </span>
                                        <% } else { %>
                                        <span class="badge-inactive px-3 py-1 rounded-full text-xs font-medium">
                                            <i class="fas fa-times-circle mr-1"></i> Inactivo
                                        </span>
                                        <% } %>
                                    </td>
                                    <td class="px-6 py-4 whitespace-nowrap text-center">
                                        <div class="flex justify-center gap-2">
                                            <%-- Ver detalles --%>
                                            <a href="MasterTableServlet?action=ver&id=<%= mt.getIdMasterTable() %>" 
                                               class="text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300"
                                               title="Ver detalles">
                                                <i class="fas fa-eye"></i>
                                            </a>
                                            
                                            <%-- Editar --%>
                                            <% if (mt.getIdMasterTableParent() != null) { %>
                                            <a href="MasterTableServlet?action=editar&id=<%= mt.getIdMasterTable() %>" 
                                               class="text-yellow-600 hover:text-yellow-800 dark:text-yellow-400 dark:hover:text-yellow-300"
                                               title="Editar">
                                                <i class="fas fa-edit"></i>
                                            </a>
                                              <%-- ELIMINAR LÓGICAMENTE --%>
            <a href="MasterTableServlet?action=eliminarLogico&id=<%= mt.getIdMasterTable() %>"
               class="text-red-500 hover:text-red-700 dark:text-red-400 transition-colors"
               title="Eliminar registro"
               onclick="return confirm('⚠️ ¿Eliminar este registro?\n\nEsta acción NO se puede deshacer fácilmente.')">
                <i class="fas fa-trash text-base"></i>
            </a>
                                            <%-- Activar/Desactivar --%>
                                            <% if ("A".equals(mt.getStatus())) { %>
                                            <a href="MasterTableServlet?action=eliminar&id=<%= mt.getIdMasterTable() %>" 
                                               class="text-red-600 hover:text-red-800 dark:text-red-400 dark:hover:text-red-300"
                                               title="Desactivar"
                                               onclick="return confirm('¿Desactivar este registro?')">
                                                <i class="fas fa-ban"></i>
                                            </a>
                                            <% } else { %>
                                            <a href="MasterTableServlet?action=activar&id=<%= mt.getIdMasterTable() %>" 
                                               class="text-green-600 hover:text-green-800 dark:text-green-400 dark:hover:text-green-300"
                                               title="Activar"
                                               onclick="return confirm('¿Activar este registro?')">
                                                <i class="fas fa-check"></i>
                                            </a>
                                            <% } %>
                                            <% } else { %>
                                            <span class="text-gray-400" title="Categoría padre - No editable">
                                                <i class="fas fa-lock"></i>
                                            </span>
                                            <% } %>
                                        </div>
                                    </td>
                                </tr>
                                <% } 
                                } else { %>
                                <tr>
                                    <td colspan="8" class="px-6 py-12 text-center">
                                        <div class="text-gray-400 dark:text-gray-500">
                                            <i class="fas fa-inbox text-6xl mb-4"></i>
                                            <p class="text-lg font-medium">No se encontraron registros</p>
                                            <p class="text-sm mt-2">Intenta ajustar los filtros de búsqueda</p>
                                        </div>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>

            </div>
        </main>
    </div>

</body>
</html>