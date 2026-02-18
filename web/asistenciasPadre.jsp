<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Asistencia, java.util.List, java.util.Map, modelo.Padre, modelo.PadreDAO" %>

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

    List<Asistencia> asistencias = (List<Asistencia>) request.getAttribute("asistencias");
    Map<String, Object> resumen = (Map<String, Object>) request.getAttribute("resumen");
    Integer mes = (Integer) request.getAttribute("mes");
    Integer anio = (Integer) request.getAttribute("anio");
    
    // Manejar mensajes desde sesión
    String mensaje = (String) session.getAttribute("mensaje");
    String error = (String) session.getAttribute("error");
    
    if (mensaje != null) session.removeAttribute("mensaje");
    if (error != null) session.removeAttribute("error");

    if (mes == null) mes = java.time.LocalDate.now().getMonthValue();
    if (anio == null) anio = java.time.LocalDate.now().getYear();

    // Valores por defecto para el resumen
    int totalClases = 0, presentes = 0, tardanzas = 0, ausentes = 0, justificados = 0;
    double porcentajeAsistencia = 0.0;

    if (resumen != null && !resumen.isEmpty()) {
        totalClases = resumen.get("totalClases") != null ? (Integer) resumen.get("totalClases") : 0;
        presentes = resumen.get("presentes") != null ? (Integer) resumen.get("presentes") : 0;
        tardanzas = resumen.get("tardanzas") != null ? (Integer) resumen.get("tardanzas") : 0;
        ausentes = resumen.get("ausentes") != null ? (Integer) resumen.get("ausentes") : 0;
        justificados = resumen.get("justificados") != null ? (Integer) resumen.get("justificados") : 0;
        porcentajeAsistencia = resumen.get("porcentajeAsistencia") != null ? (Double) resumen.get("porcentajeAsistencia") : 0.0;
    }
%>
<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Asistencias - San Antonio</title>
    
    <!-- INCLUIR HEAD.JSP CON TODAS LAS CONFIGURACIONES -->
    <jsp:include page="includes/head.jsp" />
</head>
<body class="bg-background-light dark:bg-background-dark text-slate-800 dark:text-slate-200 min-h-screen flex transition-colors duration-200">

    <!-- SIDEBAR (con logo) -->
    <jsp:include page="includes/sidebarPadre.jsp" />
    
    <!-- CONTENIDO PRINCIPAL -->
    <main class="flex-1 md:ml-64 flex flex-col min-h-screen">
        
        <!-- HEADER SUPERIOR (con foto del alumno) -->
        <jsp:include page="includes/header.jsp" />

        <div class="p-6 md:p-8 max-w-7xl mx-auto w-full">
            
            <!-- Título y botón volver -->
            <div class="flex justify-between items-center mb-6">
                <h1 class="text-2xl font-bold text-slate-800 dark:text-white flex items-center gap-2">
                    <i class="fas fa-calendar-check text-primary"></i>
                    Asistencias de mi Hijo
                </h1>
                <a href="padreDashboard.jsp" class="px-4 py-2 bg-slate-100 dark:bg-gray-800 text-slate-600 dark:text-slate-400 rounded-lg hover:bg-slate-200 dark:hover:bg-gray-700 transition-colors flex items-center gap-2">
                    <i class="fas fa-arrow-left"></i>
                    Volver
                </a>
            </div>

            <!-- Mensajes de alerta -->
            <% if (mensaje != null && !mensaje.isEmpty()) { %>
            <div class="mb-4 p-4 bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-400 rounded-lg flex items-center gap-3">
                <i class="fas fa-check-circle"></i>
                <span><%= mensaje %></span>
            </div>
            <% } %>

            <% if (error != null && !error.isEmpty()) { %>
            <div class="mb-4 p-4 bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400 rounded-lg flex items-center gap-3">
                <i class="fas fa-exclamation-circle"></i>
                <span><%= error %></span>
            </div>
            <% } %>

            <!-- Resumen de asistencias -->
            <div class="grid grid-cols-1 md:grid-cols-5 gap-4 mb-6">
                <div class="bg-white dark:bg-card-dark rounded-xl p-4 shadow-sm border border-gray-200 dark:border-border-dark">
                    <p class="text-sm text-slate-500 dark:text-slate-400">Total Clases</p>
                    <p class="text-2xl font-bold text-slate-800 dark:text-white"><%= totalClases %></p>
                </div>
                <div class="bg-white dark:bg-card-dark rounded-xl p-4 shadow-sm border border-gray-200 dark:border-border-dark">
                    <p class="text-sm text-slate-500 dark:text-slate-400">Presentes</p>
                    <p class="text-2xl font-bold text-green-600 dark:text-green-400"><%= presentes %></p>
                </div>
                <div class="bg-white dark:bg-card-dark rounded-xl p-4 shadow-sm border border-gray-200 dark:border-border-dark">
                    <p class="text-sm text-slate-500 dark:text-slate-400">Tardanzas</p>
                    <p class="text-2xl font-bold text-yellow-600 dark:text-yellow-400"><%= tardanzas %></p>
                </div>
                <div class="bg-white dark:bg-card-dark rounded-xl p-4 shadow-sm border border-gray-200 dark:border-border-dark">
                    <p class="text-sm text-slate-500 dark:text-slate-400">Ausentes</p>
                    <p class="text-2xl font-bold text-red-600 dark:text-red-400"><%= ausentes %></p>
                </div>
                <div class="bg-white dark:bg-card-dark rounded-xl p-4 shadow-sm border border-gray-200 dark:border-border-dark">
                    <p class="text-sm text-slate-500 dark:text-slate-400">Justificados</p>
                    <p class="text-2xl font-bold text-blue-600 dark:text-blue-400"><%= justificados %></p>
                </div>
            </div>

            <!-- Barra de progreso -->
            <div class="bg-white dark:bg-card-dark rounded-xl p-5 shadow-sm border border-gray-200 dark:border-border-dark mb-6">
                <div class="flex justify-between items-center mb-2">
                    <span class="text-sm font-medium text-slate-600 dark:text-slate-400">Porcentaje de Asistencia</span>
                    <span class="text-lg font-bold <%= porcentajeAsistencia >= 90 ? "text-green-600" : (porcentajeAsistencia >= 75 ? "text-yellow-600" : "text-red-600") %>">
                        <%= String.format("%.1f", porcentajeAsistencia) %>%
                    </span>
                </div>
                <div class="w-full h-3 bg-gray-200 dark:bg-gray-700 rounded-full overflow-hidden">
                    <div class="h-full rounded-full transition-all duration-300 <%= porcentajeAsistencia >= 90 ? "bg-green-500" : (porcentajeAsistencia >= 75 ? "bg-yellow-500" : "bg-red-500") %>" 
                         style="width: <%= porcentajeAsistencia %>%"></div>
                </div>
                <p class="text-xs text-slate-400 dark:text-slate-500 mt-2">Total de clases: <%= totalClases %></p>
            </div>

            <!-- Filtros -->
            <div class="bg-white dark:bg-card-dark rounded-xl p-5 shadow-sm border border-gray-200 dark:border-border-dark mb-6">
                <form method="get" action="AsistenciaServlet" class="grid grid-cols-1 md:grid-cols-4 gap-4">
                    <input type="hidden" name="accion" value="verPadre">
                    
                    <div>
                        <label class="block text-sm font-medium text-slate-600 dark:text-slate-400 mb-2">Mes</label>
                        <select name="mes" class="w-full px-4 py-2.5 rounded-lg border border-gray-200 dark:border-border-dark bg-white dark:bg-card-dark text-slate-800 dark:text-slate-200 focus:border-primary focus:ring-2 focus:ring-primary/20 outline-none transition">
                            <% 
                                String[] meses = {"Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
                                    "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"};
                                for (int i = 1; i <= 12; i++) {
                            %>
                            <option value="<%= i %>" <%= i == mes ? "selected" : "" %>><%= meses[i-1] %></option>
                            <% } %>
                        </select>
                    </div>
                    
                    <div>
                        <label class="block text-sm font-medium text-slate-600 dark:text-slate-400 mb-2">Año</label>
                        <select name="anio" class="w-full px-4 py-2.5 rounded-lg border border-gray-200 dark:border-border-dark bg-white dark:bg-card-dark text-slate-800 dark:text-slate-200 focus:border-primary focus:ring-2 focus:ring-primary/20 outline-none transition">
                            <% for (int i = anio - 1; i <= anio + 1; i++) { %>
                            <option value="<%= i %>" <%= i == anio ? "selected" : "" %>><%= i %></option>
                            <% } %>
                        </select>
                    </div>
                    
                    <div class="flex items-end">
                        <button type="submit" class="w-full px-4 py-2.5 bg-primary hover:bg-blue-700 text-white rounded-lg font-medium transition-colors flex items-center justify-center gap-2">
                            <i class="fas fa-filter"></i>
                            Filtrar
                        </button>
                    </div>
                    
                    <div class="flex items-end">
                        <a href="JustificacionServlet?accion=form" class="w-full px-4 py-2.5 bg-yellow-500 hover:bg-yellow-600 text-white rounded-lg font-medium transition-colors flex items-center justify-center gap-2">
                            <i class="fas fa-pencil-alt"></i>
                            Justificar
                        </a>
                    </div>
                </form>
            </div>

            <!-- Tabla de asistencias -->
            <div class="bg-white dark:bg-card-dark rounded-xl shadow-sm border border-gray-200 dark:border-border-dark overflow-hidden">
                <div class="px-6 py-4 border-b border-gray-200 dark:border-border-dark bg-gray-50 dark:bg-gray-800/50 flex justify-between items-center">
                    <h3 class="font-semibold text-slate-700 dark:text-slate-300">Detalle de Asistencias</h3>
                    <span class="px-3 py-1 bg-slate-100 dark:bg-gray-800 text-slate-600 dark:text-slate-400 rounded-full text-xs">
                        <%= asistencias != null ? asistencias.size() : 0 %> registros
                    </span>
                </div>

                <div class="overflow-x-auto">
                    <table class="w-full">
                        <thead class="bg-gray-50 dark:bg-gray-800 border-b border-gray-200 dark:border-border-dark">
                            <tr>
                                <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 dark:text-slate-400 uppercase tracking-wider">Fecha</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 dark:text-slate-400 uppercase tracking-wider">Curso</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 dark:text-slate-400 uppercase tracking-wider">Grado</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 dark:text-slate-400 uppercase tracking-wider">Estado</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 dark:text-slate-400 uppercase tracking-wider">Hora</th>
                                <th class="px-6 py-3 text-left text-xs font-medium text-slate-500 dark:text-slate-400 uppercase tracking-wider">Observaciones</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100 dark:divide-border-dark">
                            <% if (asistencias != null && !asistencias.isEmpty()) { 
                                for (Asistencia a : asistencias) {
                                    String estadoColor = "";
                                    String estadoIcon = "";
                                    
                                    switch (a.getEstadoString()) {
                                        case "PRESENTE":
                                            estadoColor = "bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400";
                                            estadoIcon = "fa-check-circle";
                                            break;
                                        case "TARDANZA":
                                            estadoColor = "bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-400";
                                            estadoIcon = "fa-clock";
                                            break;
                                        case "AUSENTE":
                                            estadoColor = "bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-400";
                                            estadoIcon = "fa-times-circle";
                                            break;
                                        case "JUSTIFICADO":
                                            estadoColor = "bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400";
                                            estadoIcon = "fa-file-alt";
                                            break;
                                    }
                            %>
                            <tr class="hover:bg-gray-50 dark:hover:bg-gray-800/50 transition-colors">
                                <td class="px-6 py-4 text-sm text-slate-600 dark:text-slate-400"><%= a.getFecha() %></td>
                                <td class="px-6 py-4 text-sm text-slate-600 dark:text-slate-400"><%= a.getCursoNombre() != null ? a.getCursoNombre() : "N/A" %></td>
                                <td class="px-6 py-4 text-sm text-slate-600 dark:text-slate-400"><%= a.getGradoNombre() != null ? a.getGradoNombre() : "N/A" %></td>
                                <td class="px-6 py-4">
                                    <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-medium <%= estadoColor %>">
                                        <i class="fas <%= estadoIcon %>"></i>
                                        <%= a.getEstadoString() %>
                                    </span>
                                </td>
                                <td class="px-6 py-4 text-sm text-slate-600 dark:text-slate-400"><%= a.getHoraClase() != null ? a.getHoraClase() : "N/A" %></td>
                                <td class="px-6 py-4 text-sm text-slate-600 dark:text-slate-400">
                                    <% if (a.getObservaciones() != null && !a.getObservaciones().isEmpty()) { %>
                                        <span class="relative group">
                                            <i class="fas fa-info-circle text-slate-400 hover:text-primary cursor-help"></i>
                                            <span class="absolute bottom-full left-1/2 -translate-x-1/2 mb-2 px-3 py-2 bg-slate-800 text-white text-xs rounded-lg opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap z-10 pointer-events-none">
                                                <%= a.getObservaciones() %>
                                            </span>
                                        </span>
                                    <% } else { %>
                                        <span class="text-slate-300 dark:text-slate-600">—</span>
                                    <% } %>
                                </td>
                            </tr>
                            <% } } else { %>
                            <tr>
                                <td colspan="6" class="px-6 py-12 text-center text-slate-500 dark:text-slate-400">
                                    <div class="flex flex-col items-center">
                                        <i class="fas fa-calendar-times text-5xl text-slate-300 dark:text-slate-600 mb-4"></i>
                                        <p class="text-lg font-medium">No hay asistencias registradas</p>
                                        <p class="text-sm">No se encontraron registros para el período seleccionado.</p>
                                    </div>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        
        <!-- Footer -->
        <footer class="mt-auto py-6 text-center text-xs text-slate-400 dark:text-slate-500 border-t border-slate-100 dark:border-border-dark bg-white dark:bg-card-dark">
            &copy; 2025 Colegio San Antonio - Todos los derechos reservados.
        </footer>
    </main>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>