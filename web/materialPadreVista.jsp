<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Padre, modelo.PadreDAO, modelo.Curso, modelo.Material, java.util.List, java.text.SimpleDateFormat" %>

<%
    // --- 1. LÓGICA DE SESIÓN ---
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    Padre padre = (Padre) session.getAttribute("padre");
    if (padre == null) {
        String username = (String) session.getAttribute("usuario");
        if (username != null) {
            PadreDAO padreDAO = new PadreDAO();
            padre = padreDAO.obtenerPorUsername(username);
            if (padre != null) {
                session.setAttribute("padre", padre);
                session.setAttribute("personaId", padre.getId());
            }
        }
        if (padre == null) {
            response.sendRedirect("index.jsp?error=padre_no_encontrado");
            return;
        }
    }

    boolean tieneAlumno = padre.getAlumnoId() > 0;
    int alumnoId = padre.getAlumnoId();

    // --- 2. RECUPERAR DATOS DEL SERVLET ---
    Curso curso = (Curso) request.getAttribute("curso");
    List<Material> materiales = (List<Material>) request.getAttribute("materiales");
    String alumnoNombre = (String) request.getAttribute("alumnoNombre");
    if (alumnoNombre == null) alumnoNombre = padre.getAlumnoNombre();

    if (curso == null) {
        response.sendRedirect("MaterialPadreServlet?accion=seleccionarCurso");
        return;
    }

    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
%>

<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Materiales - <%= curso.getNombre() %></title>

    <jsp:include page="includes/head.jsp" />

    <style>
        .file-card {
            transition: all 0.2s ease;
            border: 1px solid #e5e7eb;
        }
        .dark .file-card {
            border-color: #374151;
        }
        .file-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1), 0 2px 4px -1px rgba(0,0,0,0.06);
            border-color: #bfdbfe;
        }
        .dark .file-card:hover {
            border-color: #3b82f6;
            box-shadow: 0 4px 6px -1px rgba(0,0,0,0.3);
        }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark text-slate-800 dark:text-slate-200 min-h-screen flex transition-colors duration-200">

    <!-- SIDEBAR igual al padreDashboard -->
    <jsp:include page="includes/sidebarPadre.jsp" />

    <main class="flex-1 md:ml-64 flex flex-col min-h-screen">

        <!-- HEADER igual al padreDashboard -->
        <jsp:include page="includes/header.jsp" />

        <div class="p-6 md:p-8 max-w-6xl mx-auto w-full">

            <!-- Banner del curso -->
            <div class="bg-gradient-to-r from-primary to-blue-600 rounded-2xl p-8 text-white shadow-lg mb-8 relative overflow-hidden">
                <div class="absolute top-0 right-0 -mt-10 -mr-10 w-64 h-64 bg-white/10 rounded-full blur-3xl"></div>

                <div class="relative z-10 flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
                    <div>
                        <div class="flex items-center gap-2 mb-2 opacity-90">
                            <span class="material-symbols-outlined">book_2</span>
                            <span class="text-sm font-medium uppercase tracking-wider">Material de Apoyo</span>
                        </div>
                        <h1 class="text-3xl font-bold mb-1"><%= curso.getNombre() %></h1>
                        <div class="flex flex-wrap items-center gap-3 text-blue-100 text-sm">
                            <span class="bg-white/20 px-3 py-1 rounded-full backdrop-blur-sm border border-white/10 flex items-center gap-1">
                                <i class="fas fa-layer-group text-xs"></i> <%= curso.getGradoNombre() %>
                            </span>
                            <span class="flex items-center gap-1">
                                <i class="fas fa-chalkboard-teacher"></i>
                                Prof. <%= curso.getProfesorNombre() != null ? curso.getProfesorNombre() : "No asignado" %>
                            </span>
                        </div>
                    </div>

                    <div class="bg-white/10 backdrop-blur-md border border-white/20 rounded-xl p-4 min-w-[140px] text-center">
                        <span class="block text-3xl font-bold"><%= materiales != null ? materiales.size() : 0 %></span>
                        <span class="text-xs uppercase tracking-wide opacity-80">Archivos Disponibles</span>
                    </div>
                </div>
            </div>

            <!-- Lista de materiales -->
            <div class="flex flex-col gap-4">
                <div class="flex items-center justify-between mb-2">
                    <h3 class="text-lg font-bold text-slate-800 dark:text-white">Recursos Descargables</h3>
                    <a href="MaterialPadreServlet?accion=seleccionarCurso"
                       class="flex items-center gap-1.5 text-sm text-slate-500 dark:text-slate-400 hover:text-primary dark:hover:text-blue-400 transition-colors">
                        <span class="material-symbols-outlined" style="font-size:18px">arrow_back</span>
                        Volver a Cursos
                    </a>
                </div>

                <% if (materiales != null && !materiales.isEmpty()) {
                    for (Material mat : materiales) {
                        String nombre = mat.getNombreArchivo();
                        String ext = "";
                        int i = nombre.lastIndexOf('.');
                        if (i > 0) ext = nombre.substring(i + 1).toUpperCase();

                        String iconClass = "fa-file";
                        String iconColor = "text-gray-500";
                        String iconBg    = "bg-gray-100";
                        String iconBgDark = "dark:bg-gray-700";

                        if (ext.equals("PDF")) {
                            iconClass = "fa-file-pdf";   iconColor = "text-red-500";    iconBg = "bg-red-50";    iconBgDark = "dark:bg-red-900/30";
                        } else if (ext.contains("DOC")) {
                            iconClass = "fa-file-word";  iconColor = "text-blue-500";   iconBg = "bg-blue-50";   iconBgDark = "dark:bg-blue-900/30";
                        } else if (ext.contains("XLS")) {
                            iconClass = "fa-file-excel"; iconColor = "text-green-500";  iconBg = "bg-green-50";  iconBgDark = "dark:bg-green-900/30";
                        } else if (ext.contains("PPT")) {
                            iconClass = "fa-file-powerpoint"; iconColor = "text-orange-500"; iconBg = "bg-orange-50"; iconBgDark = "dark:bg-orange-900/30";
                        } else if (ext.contains("ZIP") || ext.contains("RAR")) {
                            iconClass = "fa-file-zipper"; iconColor = "text-purple-500"; iconBg = "bg-purple-50"; iconBgDark = "dark:bg-purple-900/30";
                        }

                        long size = mat.getTamanioArchivo();
                        String sizeStr = (size < 1024) ? size + " B"
                                       : (size < 1048576) ? String.format("%.1f KB", size / 1024.0)
                                       : String.format("%.1f MB", size / 1048576.0);
                %>
                <div class="file-card bg-white dark:bg-card-dark rounded-xl p-5 flex items-center justify-between gap-4 group hover:bg-blue-50/30 dark:hover:bg-blue-900/10">
                    <div class="flex items-center gap-4 overflow-hidden w-full">
                        <div class="flex-shrink-0 <%= iconBg %> <%= iconBgDark %> <%= iconColor %> size-12 rounded-lg flex items-center justify-center text-xl shadow-sm">
                            <i class="fas <%= iconClass %>"></i>
                        </div>

                        <div class="min-w-0 flex-1">
                            <h4 class="font-bold text-slate-800 dark:text-white truncate text-[15px] mb-1 group-hover:text-primary transition-colors">
                                <%= mat.getNombreArchivo() %>
                            </h4>
                            <div class="flex items-center gap-3 text-xs text-slate-500 dark:text-slate-400">
                                <span class="bg-slate-100 dark:bg-slate-700 px-2 py-0.5 rounded border border-slate-200 dark:border-slate-600 uppercase font-semibold tracking-wide text-[10px]">
                                    <%= ext %>
                                </span>
                                <span class="flex items-center gap-1">
                                    <i class="fas fa-database text-[10px]"></i> <%= sizeStr %>
                                </span>
                                <span class="flex items-center gap-1">
                                    <i class="far fa-calendar-alt text-[10px]"></i> <%= sdf.format(mat.getFechaSubida()) %>
                                </span>
                            </div>
                            <% if (mat.getDescripcion() != null && !mat.getDescripcion().isEmpty()) { %>
                                <p class="text-sm text-slate-500 dark:text-slate-400 mt-2 line-clamp-1 flex items-center gap-1">
                                    <i class="fas fa-info-circle text-xs opacity-70"></i> <%= mat.getDescripcion() %>
                                </p>
                            <% } %>
                        </div>

                        <a href="DescargarMaterialServlet?id=<%= mat.getId() %>"
                           class="hidden sm:flex flex-shrink-0 bg-white dark:bg-gray-700 border border-slate-200 dark:border-slate-600 hover:bg-primary hover:text-white hover:border-primary text-slate-600 dark:text-slate-300 px-4 py-2 rounded-lg font-medium text-sm items-center gap-2 transition-all shadow-sm">
                            <i class="fas fa-download"></i> Descargar
                        </a>
                    </div>

                    <a href="DescargarMaterialServlet?id=<%= mat.getId() %>"
                       class="sm:hidden flex-shrink-0 bg-gray-50 dark:bg-gray-700 p-3 rounded-lg text-primary border border-gray-200 dark:border-gray-600 shadow-sm">
                        <i class="fas fa-download"></i>
                    </a>
                </div>
                <%
                    }
                } else {
                %>
                <div class="bg-white dark:bg-card-dark rounded-xl border-2 border-dashed border-gray-200 dark:border-gray-700 p-12 text-center">
                    <div class="bg-blue-50 dark:bg-blue-900/20 size-20 rounded-full flex items-center justify-center mx-auto mb-4">
                        <span class="material-symbols-outlined text-4xl text-blue-300 dark:text-blue-500">folder_off</span>
                    </div>
                    <h3 class="text-lg font-bold text-slate-700 dark:text-slate-300">Aún no hay materiales</h3>
                    <p class="text-slate-500 dark:text-slate-400 text-sm mt-1 max-w-md mx-auto">
                        El profesor aún no ha compartido documentos o recursos para este curso. Vuelve a consultar más tarde.
                    </p>
                </div>
                <% } %>
            </div>

        </div>

        <footer class="mt-auto py-6 text-center text-xs text-slate-400 dark:text-slate-500 border-t border-slate-100 dark:border-border-dark bg-white dark:bg-card-dark">
            &copy; 2025 Colegio San Antonio - Todos los derechos reservados.
        </footer>
    </main>

</body>
</html>
