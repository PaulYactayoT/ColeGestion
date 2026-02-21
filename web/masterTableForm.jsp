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
    
    MasterTable masterTable = (MasterTable) request.getAttribute("masterTable");
    List<MasterTable> categorias = (List<MasterTable>) request.getAttribute("categorias");
    String action = (String) request.getAttribute("action");
    boolean esEdicion = masterTable != null;
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= esEdicion ? "Editar" : "Nuevo" %> Registro - Master Table</title>
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
                        <div class="flex items-center gap-3 mb-2">
                            <a href="MasterTableServlet?action=listar" class="text-gray-600 hover:text-gray-900 dark:text-gray-400 dark:hover:text-gray-200">
                                <i class="fas fa-arrow-left"></i>
                            </a>
                            <h1 class="text-3xl font-bold text-gray-900 dark:text-white">
                                <i class="fas fa-<%= esEdicion ? "edit" : "plus" %> text-indigo-600 mr-2"></i>
                                <%= esEdicion ? "Editar Registro" : "Nuevo Registro" %>
                            </h1>
                        </div>
                        <p class="text-gray-600 dark:text-gray-400 ml-10">
                            <%= esEdicion ? "Modifica los datos del registro existente" : "Completa el formulario para crear un nuevo registro" %>
                        </p>
                    </div>

                    <%-- Formulario --%>
                    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-8">
                        <form method="POST" action="MasterTableServlet" class="space-y-6">
                            <input type="hidden" name="action" value="guardar">
                            <% if (esEdicion) { %>
                            <input type="hidden" name="id" value="<%= masterTable.getIdMasterTable() %>">
                            <% } %>

                            <%-- Categoría --%>
                            <div>
                                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                    <i class="fas fa-folder text-indigo-600 mr-1"></i> Categoría *
                                </label>
                                <% if (esEdicion) { %>
                                <input type="text" name="category" value="<%= masterTable.getCategory() %>" readonly
                                       class="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg bg-gray-100 dark:bg-gray-700 dark:text-white cursor-not-allowed">
                                <p class="mt-1 text-sm text-gray-500">La categoría no puede modificarse</p>
                                <% } else { %>
                                <select name="category" required
                                        class="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-indigo-500 dark:bg-gray-700 dark:text-white">
                                    <option value="">Seleccione una categoría</option>
                                    <% if (categorias != null) {
                                        for (MasterTable cat : categorias) { %>
                                    <option value="<%= cat.getCategory() %>"><%= cat.getName() %></option>
                                    <% } } %>
                                </select>
                                <% } %>
                            </div>

                            <%-- Value --%>
                            <div>
                                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                    <i class="fas fa-code text-indigo-600 mr-1"></i> Valor (Code) *
                                </label>
                                <input type="text" name="value" 
                                       value="<%= esEdicion ? masterTable.getValue() : "" %>"
                                       required maxlength="100"
                                       placeholder="Ej: DNI, PRESENTE, MASCULINO"
                                       class="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-indigo-500 dark:bg-gray-700 dark:text-white font-mono">
                                <p class="mt-1 text-sm text-gray-500">Código único identificador (sin espacios, en mayúsculas)</p>
                            </div>

                            <%-- Name --%>
                            <div>
                                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                    <i class="fas fa-tag text-indigo-600 mr-1"></i> Nombre (Display) *
                                </label>
                                <input type="text" name="name" 
                                       value="<%= esEdicion ? masterTable.getName() : "" %>"
                                       required maxlength="100"
                                       placeholder="Ej: Documento Nacional de Identidad"
                                       class="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-indigo-500 dark:bg-gray-700 dark:text-white">
                                <p class="mt-1 text-sm text-gray-500">Nombre legible para mostrar en la interfaz</p>
                            </div>

                            <%-- Description --%>
                            <div>
                                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                    <i class="fas fa-align-left text-indigo-600 mr-1"></i> Descripción
                                </label>
                                <textarea name="description" rows="3" maxlength="255"
                                          placeholder="Descripción detallada del registro (opcional)"
                                          class="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-indigo-500 dark:bg-gray-700 dark:text-white"><%= esEdicion && masterTable.getDescription() != null ? masterTable.getDescription() : "" %></textarea>
                            </div>

                            <%-- Order Index --%>
                            <div>
                                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                    <i class="fas fa-sort-numeric-up text-indigo-600 mr-1"></i> Orden de visualización
                                </label>
                                <input type="number" name="orderIndex" 
                                       value="<%= esEdicion ? masterTable.getOrderIndex() : 0 %>"
                                       min="0" max="999"
                                       class="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-indigo-500 dark:bg-gray-700 dark:text-white">
                                <p class="mt-1 text-sm text-gray-500">Número para ordenar en listas (menor = primero)</p>
                            </div>

                            <%-- Campos adicionales --%>
                            <div class="border-t border-gray-200 dark:border-gray-700 pt-6">
                                <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">
                                    <i class="fas fa-plus-circle text-indigo-600 mr-2"></i>
                                    Campos Adicionales (Opcionales)
                                </h3>
                                
                                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                    <div>
                                        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                            Additional One
                                        </label>
                                        <input type="text" name="additionalOne" 
                                               value="<%= esEdicion && masterTable.getAdditionalOne() != null ? masterTable.getAdditionalOne() : "" %>"
                                               maxlength="100"
                                               placeholder="Ej: Color, Icono, Clase CSS"
                                               class="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-indigo-500 dark:bg-gray-700 dark:text-white">
                                    </div>
                                    
                                    <div>
                                        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                            Additional Two
                                        </label>
                                        <input type="text" name="additionalTwo" 
                                               value="<%= esEdicion && masterTable.getAdditionalTwo() != null ? masterTable.getAdditionalTwo() : "" %>"
                                               maxlength="100"
                                               placeholder="Ej: Peso, Valor numérico"
                                               class="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-indigo-500 dark:bg-gray-700 dark:text-white">
                                    </div>
                                    
                                    <div>
                                        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                            Additional Three
                                        </label>
                                        <input type="text" name="additionalThree" 
                                               value="<%= esEdicion && masterTable.getAdditionalThree() != null ? masterTable.getAdditionalThree() : "" %>"
                                               maxlength="100"
                                               placeholder="Campo extra 3"
                                               class="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-indigo-500 dark:bg-gray-700 dark:text-white">
                                    </div>
                                    
                                    <div>
                                        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                            Additional Four
                                        </label>
                                        <input type="text" name="additionalFour" 
                                               value="<%= esEdicion && masterTable.getAdditionalFour() != null ? masterTable.getAdditionalFour() : "" %>"
                                               maxlength="100"
                                               placeholder="Campo extra 4"
                                               class="w-full px-4 py-3 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-indigo-500 dark:bg-gray-700 dark:text-white">
                                    </div>
                                </div>
                            </div>

                            <%-- Botones --%>
                            <div class="flex gap-3 pt-6 border-t border-gray-200 dark:border-gray-700">
                                <button type="submit" 
                                        class="px-6 py-3 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition-colors font-medium flex items-center gap-2">
                                    <i class="fas fa-save"></i>
                                    <span><%= esEdicion ? "Actualizar" : "Guardar" %> Registro</span>
                                </button>
                                
                                <a href="MasterTableServlet?action=listar" 
                                   class="px-6 py-3 bg-gray-200 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-300 dark:hover:bg-gray-600 transition-colors font-medium flex items-center gap-2">
                                    <i class="fas fa-times"></i>
                                    <span>Cancelar</span>
                                </a>
                            </div>
                        </form>
                    </div>

                </div>
            </div>
        </main>
    </div>

</body>
</html>