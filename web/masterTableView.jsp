<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.MasterTable" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    MasterTable mt = (MasterTable) request.getAttribute("masterTable");
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Detalles - Master Table</title>
    <%@ include file="includes/head.jsp" %>
</head>
<body class="bg-gray-50 dark:bg-gray-900">

    <div class="flex h-screen overflow-hidden">
        <%@ include file="includes/sidebar.jsp" %>

        <main class="flex-1 flex flex-col overflow-y-auto">
            <%@ include file="includes/header.jsp" %>

            <div class="p-8">
                <div class="max-w-4xl mx-auto">
                    
                    <%-- Header --%>
                    <div class="mb-6">
                        <div class="flex items-center justify-between">
                            <div class="flex items-center gap-3">
                                <a href="MasterTableServlet?action=listar" class="text-gray-600 hover:text-gray-900 dark:text-gray-400 dark:hover:text-gray-200">
                                    <i class="fas fa-arrow-left"></i>
                                </a>
                                <h1 class="text-3xl font-bold text-gray-900 dark:text-white">
                                    <i class="fas fa-info-circle text-indigo-600 mr-2"></i>
                                    Detalles del Registro
                                </h1>
                            </div>
                            
                            <% if (mt != null && mt.getIdMasterTableParent() != null) { %>
                            <a href="MasterTableServlet?action=editar&id=<%= mt.getIdMasterTable() %>" 
                               class="px-4 py-2 bg-yellow-600 text-white rounded-lg hover:bg-yellow-700 transition-colors flex items-center gap-2">
                                <i class="fas fa-edit"></i>
                                <span>Editar</span>
                            </a>
                            <% } %>
                        </div>
                    </div>

                    <% if (mt != null) { %>
                    
                    <%-- Información Principal --%>
                    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-8 mb-6">
                        <h2 class="text-xl font-semibold text-gray-900 dark:text-white mb-6 flex items-center gap-2">
                            <i class="fas fa-database text-indigo-600"></i>
                            Información Principal
                        </h2>
                        
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div>
                                <label class="block text-sm font-medium text-gray-500 dark:text-gray-400 mb-1">ID</label>
                                <p class="text-lg font-semibold text-gray-900 dark:text-white">#<%= mt.getIdMasterTable() %></p>
                            </div>
                            
                            <div>
                                <label class="block text-sm font-medium text-gray-500 dark:text-gray-400 mb-1">Estado</label>
                                <% if ("A".equals(mt.getStatus())) { %>
                                <span class="inline-flex items-center gap-2 px-4 py-2 bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-400 rounded-lg font-semibold">
                                    <i class="fas fa-check-circle"></i> Activo
                                </span>
                                <% } else { %>
                                <span class="inline-flex items-center gap-2 px-4 py-2 bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-400 rounded-lg font-semibold">
                                    <i class="fas fa-times-circle"></i> Inactivo
                                </span>
                                <% } %>
                            </div>
                            
                            <div>
                                <label class="block text-sm font-medium text-gray-500 dark:text-gray-400 mb-1">Categoría</label>
                                <p class="text-lg text-gray-900 dark:text-white">
                                    <span class="px-3 py-1 bg-blue-100 dark:bg-blue-900/30 text-blue-800 dark:text-blue-400 rounded-full font-mono">
                                        <%= mt.getCategory() %>
                                    </span>
                                </p>
                            </div>
                            
                            <div>
                                <label class="block text-sm font-medium text-gray-500 dark:text-gray-400 mb-1">Valor (Code)</label>
                                <p class="text-lg text-gray-900 dark:text-white font-mono font-semibold"><%= mt.getValue() %></p>
                            </div>
                            
                            <div class="md:col-span-2">
                                <label class="block text-sm font-medium text-gray-500 dark:text-gray-400 mb-1">Nombre (Display)</label>
                                <p class="text-lg text-gray-900 dark:text-white font-semibold"><%= mt.getName() %></p>
                            </div>
                            
                            <div class="md:col-span-2">
                                <label class="block text-sm font-medium text-gray-500 dark:text-gray-400 mb-1">Descripción</label>
                                <p class="text-gray-700 dark:text-gray-300"><%= mt.getDescription() != null ? mt.getDescription() : "-" %></p>
                            </div>
                            
                            <div>
                                <label class="block text-sm font-medium text-gray-500 dark:text-gray-400 mb-1">Orden de visualización</label>
                                <p class="text-lg text-gray-900 dark:text-white font-semibold"><%= mt.getOrderIndex() %></p>
                            </div>
                        </div>
                    </div>

                    <%-- Campos Adicionales --%>
                    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-8 mb-6">
                        <h2 class="text-xl font-semibold text-gray-900 dark:text-white mb-6 flex items-center gap-2">
                            <i class="fas fa-plus-circle text-indigo-600"></i>
                            Campos Adicionales
                        </h2>
                        
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div>
                                <label class="block text-sm font-medium text-gray-500 dark:text-gray-400 mb-1">Additional One</label>
                                <p class="text-gray-900 dark:text-white"><%= mt.getAdditionalOne() != null ? mt.getAdditionalOne() : "-" %></p>
                            </div>
                            
                            <div>
                                <label class="block text-sm font-medium text-gray-500 dark:text-gray-400 mb-1">Additional Two</label>
                                <p class="text-gray-900 dark:text-white"><%= mt.getAdditionalTwo() != null ? mt.getAdditionalTwo() : "-" %></p>
                            </div>
                            
                            <div>
                                <label class="block text-sm font-medium text-gray-500 dark:text-gray-400 mb-1">Additional Three</label>
                                <p class="text-gray-900 dark:text-white"><%= mt.getAdditionalThree() != null ? mt.getAdditionalThree() : "-" %></p>
                            </div>
                            
                            <div>
                                <label class="block text-sm font-medium text-gray-500 dark:text-gray-400 mb-1">Additional Four</label>
                                <p class="text-gray-900 dark:text-white"><%= mt.getAdditionalFour() != null ? mt.getAdditionalFour() : "-" %></p>
                            </div>
                        </div>
                    </div>

                    <%-- Metadatos del Sistema --%>
                    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-8">
                        <h2 class="text-xl font-semibold text-gray-900 dark:text-white mb-6 flex items-center gap-2">
                            <i class="fas fa-cog text-indigo-600"></i>
                            Metadatos del Sistema
                        </h2>
                        
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div>
                                <label class="block text-sm font-medium text-gray-500 dark:text-gray-400 mb-1">Database Web ID</label>
                                <p class="text-gray-900 dark:text-white"><%= mt.getDatabaseWebId() != null ? mt.getDatabaseWebId() : "-" %></p>
                            </div>
                            
                            <div>
                                <label class="block text-sm font-medium text-gray-500 dark:text-gray-400 mb-1">Host ID</label>
                                <p class="text-gray-900 dark:text-white"><%= mt.getHostId() != null ? mt.getHostId() : "-" %></p>
                            </div>
                            
                            <div>
                                <label class="block text-sm font-medium text-gray-500 dark:text-gray-400 mb-1">Fecha de creación</label>
                                <p class="text-gray-900 dark:text-white">
                                    <i class="fas fa-calendar-plus text-gray-400 mr-2"></i>
                                    <%= mt.getCreatedAt() != null ? sdf.format(mt.getCreatedAt()) : "-" %>
                                </p>
                            </div>
                            
                            <div>
                                <label class="block text-sm font-medium text-gray-500 dark:text-gray-400 mb-1">Última actualización</label>
                                <p class="text-gray-900 dark:text-white">
                                    <i class="fas fa-clock text-gray-400 mr-2"></i>
                                    <%= mt.getUpdatedAt() != null ? sdf.format(mt.getUpdatedAt()) : "-" %>
                                </p>
                            </div>
                        </div>
                    </div>

                    <% } else { %>
                    <div class="bg-red-100 border-l-4 border-red-500 text-red-700 p-4 rounded-lg" role="alert">
                        <p class="font-medium">Registro no encontrado</p>
                    </div>
                    <% } %>

                </div>
            </div>
        </main>
    </div>

</body>
</html>