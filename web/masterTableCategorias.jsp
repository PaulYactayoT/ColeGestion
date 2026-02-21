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

    List<MasterTable> categorias = (List<MasterTable>) request.getAttribute("categorias");

    String successMsg = (String) session.getAttribute("success");
    String errorMsg   = (String) session.getAttribute("error");
    session.removeAttribute("success");
    session.removeAttribute("error");

    // Calcular total de valores para estadísticas
    int totalValores = 0;
    if (categorias != null) {
        for (MasterTable c : categorias) {
            totalValores += c.getTotalValues();
        }
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Categorías - Master Table</title>
    <%@ include file="includes/head.jsp" %>
    <style>
        .cat-card {
            transition: all 0.25s ease;
            cursor: pointer;
        }
        .cat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 12px 28px rgba(79, 70, 229, 0.18);
            border-color: #6366f1;
        }
        .cat-icon {
            width: 50px; height: 50px;
            border-radius: 14px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.3rem;
            flex-shrink: 0;
        }
        /* 17 paletas de color */
        .ci-0  { background:#eef2ff; color:#4f46e5; }
        .ci-1  { background:#fdf4ff; color:#9333ea; }
        .ci-2  { background:#ecfdf5; color:#059669; }
        .ci-3  { background:#fff7ed; color:#ea580c; }
        .ci-4  { background:#eff6ff; color:#2563eb; }
        .ci-5  { background:#fef2f2; color:#dc2626; }
        .ci-6  { background:#f0fdfa; color:#0d9488; }
        .ci-7  { background:#fefce8; color:#ca8a04; }
        .ci-8  { background:#f0f9ff; color:#0284c7; }
        .ci-9  { background:#fff1f2; color:#e11d48; }
        .ci-10 { background:#f7fee7; color:#65a30d; }
        .ci-11 { background:#fdf2f8; color:#c026d3; }
        .ci-12 { background:#f8fafc; color:#475569; }
        .ci-13 { background:#fff8f1; color:#d97706; }
        .ci-14 { background:#f0fdf4; color:#16a34a; }
        .ci-15 { background:#faf5ff; color:#7c3aed; }
        .ci-16 { background:#ecfeff; color:#0891b2; }
    </style>
</head>
<body class="bg-gray-50 dark:bg-gray-900">
<div class="flex h-screen overflow-hidden">
    <%@ include file="includes/sidebar.jsp" %>
    <main class="flex-1 flex flex-col overflow-y-auto">
        <%@ include file="includes/header.jsp" %>

        <div class="p-8 space-y-6 max-w-7xl mx-auto w-full">

            <%-- Mensajes --%>
            <% if (successMsg != null) { %>
            <div class="bg-green-100 border-l-4 border-green-500 text-green-700 p-4 rounded-xl flex items-center gap-3">
                <i class="fas fa-check-circle text-xl"></i>
                <p class="font-medium"><%= successMsg %></p>
            </div>
            <% } %>
            <% if (errorMsg != null) { %>
            <div class="bg-red-100 border-l-4 border-red-500 text-red-700 p-4 rounded-xl flex items-center gap-3">
                <i class="fas fa-exclamation-circle text-xl"></i>
                <p class="font-medium"><%= errorMsg %></p>
            </div>
            <% } %>

            <%-- Header --%>
            <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                <div class="flex items-center gap-4">
                    <a href="MasterTableServlet?action=listar"
                       class="p-2 rounded-lg bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 text-gray-600 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors">
                        <i class="fas fa-arrow-left"></i>
                    </a>
                    <div>
                        <h1 class="text-3xl font-bold text-gray-900 dark:text-white flex items-center gap-3">
                            <i class="fas fa-folder-open text-indigo-600"></i>
                            Categorías del Sistema
                        </h1>
                        <p class="text-gray-500 dark:text-gray-400 mt-1 text-sm">
                            <%= categorias != null ? categorias.size() : 0 %> categorías encontradas
                        </p>
                    </div>
                </div>
                <div class="flex gap-3">
                    <a href="MasterTableServlet?action=listar"
                       class="px-5 py-2.5 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-xl font-semibold transition-colors flex items-center gap-2 hover:bg-gray-200 dark:hover:bg-gray-600">
                        <i class="fas fa-table"></i>
                        Ver Todos
                    </a>
                    <a href="MasterTableServlet?action=nuevo"
                       class="px-5 py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl font-semibold transition-colors flex items-center gap-2 shadow-sm">
                        <i class="fas fa-plus"></i>
                        Nuevo Registro
                    </a>
                </div>
            </div>

            <%-- Estadísticas rápidas --%>
            <div class="grid grid-cols-2 md:grid-cols-3 gap-4">
                <div class="bg-white dark:bg-gray-800 rounded-xl p-5 border border-gray-200 dark:border-gray-700 shadow-sm flex items-center gap-4">
                    <div class="w-12 h-12 rounded-xl bg-indigo-100 dark:bg-indigo-900/30 flex items-center justify-center text-indigo-600 text-xl">
                        <i class="fas fa-folder"></i>
                    </div>
                    <div>
                        <p class="text-xs text-gray-500 dark:text-gray-400 uppercase tracking-wide">Categorías</p>
                        <p class="text-2xl font-bold text-gray-900 dark:text-white">
                            <%= categorias != null ? categorias.size() : 0 %>
                        </p>
                    </div>
                </div>
                <div class="bg-white dark:bg-gray-800 rounded-xl p-5 border border-gray-200 dark:border-gray-700 shadow-sm flex items-center gap-4">
                    <div class="w-12 h-12 rounded-xl bg-purple-100 dark:bg-purple-900/30 flex items-center justify-center text-purple-600 text-xl">
                        <i class="fas fa-list"></i>
                    </div>
                    <div>
                        <p class="text-xs text-gray-500 dark:text-gray-400 uppercase tracking-wide">Total valores</p>
                        <p class="text-2xl font-bold text-gray-900 dark:text-white"><%= totalValores %></p>
                    </div>
                </div>
                <div class="bg-white dark:bg-gray-800 rounded-xl p-5 border border-gray-200 dark:border-gray-700 shadow-sm flex items-center gap-4 col-span-2 md:col-span-1">
                    <div class="w-12 h-12 rounded-xl bg-green-100 dark:bg-green-900/30 flex items-center justify-center text-green-600 text-xl">
                        <i class="fas fa-calculator"></i>
                    </div>
                    <div>
                        <p class="text-xs text-gray-500 dark:text-gray-400 uppercase tracking-wide">Promedio</p>
                        <p class="text-2xl font-bold text-gray-900 dark:text-white">
                            <%= (categorias != null && categorias.size() > 0) ? (totalValores / categorias.size()) : 0 %>
                        </p>
                    </div>
                </div>
            </div>

            <%-- Buscador en tiempo real --%>
            <div class="bg-white dark:bg-gray-800 rounded-xl border border-gray-200 dark:border-gray-700 shadow-sm p-4">
                <div class="relative">
                    <i class="fas fa-search absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 pointer-events-none"></i>
                    <input type="text" id="searchCat"
                           placeholder="Buscar categoría por nombre o código..."
                           oninput="filtrarCategorias(this.value)"
                           class="w-full pl-11 pr-4 py-2.5 rounded-lg border border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white focus:ring-2 focus:ring-indigo-500 focus:outline-none transition text-sm">
                </div>
            </div>

            <%-- Grid de categorías --%>
            <% if (categorias != null && !categorias.isEmpty()) { %>

            <div id="gridCategorias" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-5">
                <%
                String[] iconos = {
                    "fa-venus-mars","fa-id-card","fa-calendar-check","fa-tasks",
                    "fa-file-alt","fa-chalkboard-teacher","fa-user-graduate","fa-layer-group",
                    "fa-calendar-week","fa-comment-alt","fa-door-open","fa-users",
                    "fa-stamp","fa-user-tag","fa-graduation-cap","fa-user-circle","fa-cog"
                };
                int idx = 0;
                for (MasterTable cat : categorias) {
                    String icono   = (idx < iconos.length) ? iconos[idx] : "fa-tag";
                    int colorIdx   = idx % 17;
                    String catNombre = cat.getName()     != null ? cat.getName()     : cat.getCategory();
                    String catDesc   = cat.getDescription() != null ? cat.getDescription() : "";
                    int barWidth = Math.min(cat.getTotalValues() * 8, 100);
                %>
                <div class="cat-card bg-white dark:bg-gray-800 rounded-2xl border border-gray-200 dark:border-gray-700 p-5 shadow-sm"
                     data-nombre="<%= catNombre.toLowerCase() %>"
                     data-codigo="<%= cat.getCategory().toLowerCase() %>"
                     onclick="window.location='MasterTableServlet?action=valores&category=<%= cat.getCategory() %>'">

                    <%-- Encabezado card --%>
                    <div class="flex items-start justify-between mb-4">
                        <div class="cat-icon ci-<%= colorIdx %>">
                            <i class="fas <%= icono %>"></i>
                        </div>
                        <span class="text-xs font-bold px-2.5 py-1 rounded-full bg-indigo-100 dark:bg-indigo-900/40 text-indigo-700 dark:text-indigo-300">
                            <%= cat.getTotalValues() %> valores
                        </span>
                    </div>

                    <%-- Info principal --%>
                    <h3 class="font-bold text-gray-900 dark:text-white text-base leading-tight truncate mb-1">
                        <%= catNombre %>
                    </h3>
                    <p class="text-xs font-mono text-gray-400 dark:text-gray-500 mb-2 truncate">
                        <%= cat.getCategory() %>
                    </p>
                    <% if (!catDesc.isEmpty()) { %>
                    <p class="text-xs text-gray-500 dark:text-gray-400 mb-3 line-clamp-2" style="display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden;">
                        <%= catDesc %>
                    </p>
                    <% } else { %>
                    <div class="mb-3"></div>
                    <% } %>

                    <%-- Barra proporcional --%>
                    <div class="w-full bg-gray-100 dark:bg-gray-700 rounded-full h-1.5 mb-4">
                        <div class="h-1.5 rounded-full bg-indigo-500 opacity-70 transition-all"
                             style="width:<%= barWidth %>%"></div>
                    </div>

                    <%-- Botones --%>
                    <div class="flex gap-2">
                        <a href="MasterTableServlet?action=valores&category=<%= cat.getCategory() %>"
                           onclick="event.stopPropagation()"
                           class="flex-1 text-center px-3 py-1.5 bg-indigo-50 dark:bg-indigo-900/30 text-indigo-600 dark:text-indigo-400 rounded-lg text-xs font-semibold hover:bg-indigo-100 transition-colors">
                            <i class="fas fa-list mr-1"></i> Ver valores
                        </a>
                        <a href="MasterTableServlet?action=nuevo"
                           onclick="event.stopPropagation()"
                           title="Nuevo registro en esta categoría"
                           class="px-3 py-1.5 bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-300 rounded-lg text-xs font-semibold hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors">
                            <i class="fas fa-plus"></i>
                        </a>
                    </div>
                </div>
                <%
                    idx++;
                }
                %>
            </div>

            <%-- Sin resultados de búsqueda --%>
            <div id="sinResultados" class="hidden text-center py-16">
                <div class="text-gray-300 dark:text-gray-600 text-6xl mb-4">
                    <i class="fas fa-search"></i>
                </div>
                <p class="text-gray-500 dark:text-gray-400 text-lg font-medium">Sin coincidencias</p>
                <p class="text-gray-400 dark:text-gray-500 text-sm mt-1">Prueba con otro término</p>
            </div>

            <% } else { %>
            <%-- Sin categorías en BD --%>
            <div class="text-center py-20">
                <div class="text-gray-300 dark:text-gray-600 text-7xl mb-6">
                    <i class="fas fa-inbox"></i>
                </div>
                <p class="text-gray-500 dark:text-gray-400 text-xl font-semibold">No hay categorías disponibles</p>
                <p class="text-gray-400 dark:text-gray-500 text-sm mt-2">La master_table no tiene datos cargados</p>
                <a href="MasterTableServlet?action=nuevo"
                   class="inline-flex items-center gap-2 mt-6 px-6 py-3 bg-indigo-600 text-white rounded-xl font-semibold hover:bg-indigo-700 transition-colors">
                    <i class="fas fa-plus"></i> Crear primer registro
                </a>
            </div>
            <% } %>

        </div>
    </main>
</div>

<script>
    function filtrarCategorias(texto) {
        texto = texto.toLowerCase().trim();
        const cards     = document.querySelectorAll('#gridCategorias .cat-card');
        const noResults = document.getElementById('sinResultados');
        let visibles = 0;

        cards.forEach(card => {
            const nombre = card.dataset.nombre || '';
            const codigo = card.dataset.codigo || '';
            const ok = !texto || nombre.includes(texto) || codigo.includes(texto);
            card.style.display = ok ? '' : 'none';
            if (ok) visibles++;
        });

        if (noResults) {
            noResults.classList.toggle('hidden', visibles > 0);
        }
    }
</script>
</body>
</html>