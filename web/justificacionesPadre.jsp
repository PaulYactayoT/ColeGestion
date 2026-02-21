<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Justificacion, modelo.Padre, java.util.List" %>
<%
    Padre padre = (Padre) session.getAttribute("padre");
    if (padre == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    List<Justificacion> justificaciones = (List<Justificacion>) request.getAttribute("justificaciones");
    if (justificaciones == null) justificaciones = new java.util.ArrayList<>();

    String mensaje = (String) session.getAttribute("mensaje");
    String error   = (String) session.getAttribute("error");
    session.removeAttribute("mensaje");
    session.removeAttribute("error");

    int alumnoId = padre.getAlumnoId();
%>
<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mis Justificaciones - Sistema Escolar</title>

    <jsp:include page="includes/head.jsp" />

    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <style>
        body { font-family: 'Lexend', sans-serif; }
        .material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24; }

        .alert-modern {
            border-radius: 0.75rem;
            padding: 1rem 1.25rem;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 1rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            border-left: 4px solid;
        }
        .alert-danger  { background: linear-gradient(135deg,#fee2e2,#fecaca); color:#991b1b; border-left-color:#ef4444; }
        .alert-success { background: linear-gradient(135deg,#d1fae5,#a7f3d0); color:#065f46; border-left-color:#10b981; }
        .dark .alert-danger  { background: linear-gradient(135deg,#7f1d1d,#991b1b); color:#fecaca; }
        .dark .alert-success { background: linear-gradient(135deg,#064e3b,#065f46); color:#d1fae5; }

        .section-title {
            color: #135bec;
            font-weight: 600;
            font-size: 1.1rem;
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        .dark .section-title { color: #60a5fa; }

        .justif-card {
            background: white;
            border-radius: 0.75rem;
            padding: 1.25rem 1.5rem;
            margin-bottom: 0.75rem;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            border-left: 4px solid #135bec;
            transition: all 0.25s ease;
        }
        .justif-card:hover { box-shadow: 0 4px 14px rgba(0,0,0,0.1); transform: translateY(-2px); }
        .dark .justif-card { background: #1a2233; border-left-color: #3b82f6; }

        .justif-card.estado-PENDIENTE  { border-left-color: #f59e0b; }
        .justif-card.estado-APROBADO   { border-left-color: #10b981; }
        .justif-card.estado-RECHAZADO  { border-left-color: #ef4444; }

        .badge-estado {
            display: inline-flex;
            align-items: center;
            gap: 0.25rem;
            padding: 0.25rem 0.75rem;
            border-radius: 9999px;
            font-size: 0.75rem;
            font-weight: 600;
        }
        .badge-PENDIENTE  { background:#fef3c7; color:#92400e; }
        .badge-APROBADO   { background:#d1fae5; color:#065f46; }
        .badge-RECHAZADO  { background:#fee2e2; color:#991b1b; }
        .dark .badge-PENDIENTE  { background:#78350f40; color:#fde68a; }
        .dark .badge-APROBADO   { background:#06403040; color:#6ee7b7; }
        .dark .badge-RECHAZADO  { background:#7f1d1d40; color:#fca5a5; }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark text-slate-800 dark:text-slate-200 min-h-screen flex transition-colors duration-200">

    <jsp:include page="includes/sidebarPadre.jsp" />

    <main class="flex-1 md:ml-64 flex flex-col min-h-screen">

        <jsp:include page="includes/header.jsp" />

        <div class="p-8">

            <!-- Título de página -->
            <div class="mb-8">
                <h2 class="text-2xl font-bold text-slate-800 dark:text-white flex items-center gap-2">
                    <i class="fas fa-file-medical text-primary"></i>
                    Mis Justificaciones
                </h2>
                <p class="text-sm text-slate-500 dark:text-slate-400 mt-1">
                    Historial de justificaciones enviadas para
                    <strong class="text-primary dark:text-blue-400"><%= padre.getAlumnoNombre() != null ? padre.getAlumnoNombre() : "su hijo(a)" %></strong>
                </p>
            </div>

            <!-- Alertas -->
            <% if (error != null && !error.isEmpty()) { %>
            <div class="alert-modern alert-danger">
                <i class="fas fa-exclamation-circle text-2xl"></i>
                <div><strong class="block">Error</strong><span><%= error %></span></div>
            </div>
            <% } %>
            <% if (mensaje != null && !mensaje.isEmpty()) { %>
            <div class="alert-modern alert-success">
                <i class="fas fa-check-circle text-2xl"></i>
                <div><strong class="block">Éxito</strong><span><%= mensaje %></span></div>
            </div>
            <% } %>

            <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">

                <!-- Lista de justificaciones -->
                <div class="lg:col-span-2">
                    <div class="bg-white dark:bg-card-dark rounded-xl shadow-sm border border-gray-200 dark:border-border-dark p-6">

                        <div class="flex items-center justify-between mb-6">
                            <h3 class="section-title mb-0">
                                <i class="fas fa-list-alt"></i> Justificaciones enviadas
                            </h3>
                            <span class="text-xs px-3 py-1 rounded-full font-semibold
                                <%= justificaciones.size() > 0 ? "bg-blue-100 dark:bg-blue-900/30 text-blue-800 dark:text-blue-300" : "bg-gray-100 dark:bg-gray-700 text-gray-500 dark:text-gray-400" %>">
                                <%= justificaciones.size() %> registro<%= justificaciones.size() != 1 ? "s" : "" %>
                            </span>
                        </div>

                        <% if (!justificaciones.isEmpty()) {
                            for (Justificacion j : justificaciones) {
                                String estadoStr = j.getEstado() != null ? j.getEstado().name() : "PENDIENTE";
                                String iconoEstado = estadoStr.equals("APROBADO") ? "check_circle"
                                                  : estadoStr.equals("RECHAZADO") ? "cancel" : "schedule";
                        %>
                        <div class="justif-card estado-<%= estadoStr %>">
                            <div class="flex flex-wrap items-start justify-between gap-3">
                                <!-- Info principal -->
                                <div class="flex-1 min-w-0">
                                    <div class="flex items-center gap-2 mb-1">
                                        <span class="font-bold text-slate-800 dark:text-white text-sm">
                                            <%= j.getCursoNombre() != null ? j.getCursoNombre() : "Sin curso" %>
                                        </span>
                                        <span class="badge-estado badge-<%= estadoStr %>">
                                            <span class="material-symbols-outlined" style="font-size:13px"><%= iconoEstado %></span>
                                            <%= estadoStr %>
                                        </span>
                                    </div>

                                    <div class="flex flex-wrap gap-4 text-xs text-slate-500 dark:text-slate-400 mt-1">
                                        <span class="flex items-center gap-1">
                                            <i class="fas fa-calendar text-primary dark:text-blue-400"></i>
                                            Ausencia: <strong class="text-slate-700 dark:text-slate-200 ml-1"><%= j.getFechaAsistencia() != null ? j.getFechaAsistencia() : "—" %></strong>
                                        </span>
                                        <span class="flex items-center gap-1">
                                            <i class="fas fa-tag text-primary dark:text-blue-400"></i>
                                            <%= j.getTipoJustificacion() != null ? j.getTipoJustificacion().getDescripcion() : "—" %>
                                        </span>
                                    </div>

                                    <% if (j.getDescripcion() != null && !j.getDescripcion().isEmpty()) { %>
                                    <p class="text-xs text-slate-500 dark:text-slate-400 mt-2 line-clamp-2">
                                        <i class="fas fa-align-left mr-1 opacity-60"></i><%= j.getDescripcion() %>
                                    </p>
                                    <% } %>

                                    <% if (estadoStr.equals("RECHAZADO") && j.getObservacionesAprobacion() != null && !j.getObservacionesAprobacion().isEmpty()) { %>
                                    <div class="mt-2 p-2 bg-red-50 dark:bg-red-900/20 rounded-lg border border-red-200 dark:border-red-800">
                                        <p class="text-xs text-red-700 dark:text-red-300 flex items-start gap-1">
                                            <i class="fas fa-exclamation-circle mt-0.5 flex-shrink-0"></i>
                                            <span><strong>Motivo del rechazo:</strong> <%= j.getObservacionesAprobacion() %></span>
                                        </p>
                                    </div>
                                    <% } %>

                                    <% if (estadoStr.equals("APROBADO") && j.getObservacionesAprobacion() != null && !j.getObservacionesAprobacion().isEmpty()) { %>
                                    <div class="mt-2 p-2 bg-green-50 dark:bg-green-900/20 rounded-lg border border-green-200 dark:border-green-800">
                                        <p class="text-xs text-green-700 dark:text-green-300 flex items-start gap-1">
                                            <i class="fas fa-comment-dots mt-0.5 flex-shrink-0"></i>
                                            <span><strong>Observación:</strong> <%= j.getObservacionesAprobacion() %></span>
                                        </p>
                                    </div>
                                    <% } %>
                                </div>

                                <!-- Acciones -->
                                <div class="flex flex-col items-end gap-2 flex-shrink-0">
                                    <% if (j.tieneDocumento()) { %>
                                    <a href="<%= j.getDocumentoAdjunto() %>" target="_blank"
                                       class="flex items-center gap-1.5 px-3 py-1.5 bg-blue-50 dark:bg-blue-900/20 text-blue-700 dark:text-blue-300 border border-blue-200 dark:border-blue-800 rounded-lg text-xs font-medium hover:bg-blue-100 dark:hover:bg-blue-900/40 transition-colors">
                                        <i class="fas fa-download"></i> Ver doc.
                                    </a>
                                    <% } %>
                                    <span class="text-xs text-slate-400 dark:text-slate-500 flex items-center gap-1">
                                        <i class="fas fa-clock text-[10px]"></i>
                                        <%= j.getFechaJustificacion() != null ? j.getFechaJustificacion().toLocalDate().toString() : "—" %>
                                    </span>
                                </div>
                            </div>
                        </div>
                        <%
                            }
                        } else { %>
                        <div class="text-center py-14">
                            <span class="material-symbols-outlined text-gray-300 dark:text-gray-600 block mb-3" style="font-size:64px">task_alt</span>
                            <h3 class="text-lg font-bold text-slate-500 dark:text-slate-400">No hay justificaciones</h3>
                            <p class="text-sm text-slate-400 dark:text-slate-500 mt-1 mb-5">Aún no has enviado ninguna justificación.</p>
                            <a href="JustificacionServlet?accion=form"
                               class="inline-flex items-center gap-2 px-5 py-2.5 bg-primary hover:bg-blue-700 text-white font-semibold rounded-lg transition-colors text-sm">
                                <i class="fas fa-plus"></i> Justificar una ausencia
                            </a>
                        </div>
                        <% } %>
                    </div>
                </div>

                <!-- Panel lateral -->
                <div class="lg:col-span-1 space-y-6">

                    <!-- Resumen de estados -->
                    <%
                        int totalJ = justificaciones.size();
                        int pendientes = 0, aprobadas = 0, rechazadas = 0;
                        for (Justificacion jj : justificaciones) {
                            if (jj.getEstado() == null) { pendientes++; continue; }
                            switch (jj.getEstado().name()) {
                                case "APROBADO":  aprobadas++;  break;
                                case "RECHAZADO": rechazadas++; break;
                                default:          pendientes++; break;
                            }
                        }
                    %>
                    <div class="bg-white dark:bg-card-dark rounded-xl shadow-sm border border-gray-200 dark:border-border-dark p-6">
                        <h3 class="section-title">
                            <i class="fas fa-chart-pie"></i> Resumen
                        </h3>
                        <div class="space-y-3">
                            <div class="flex items-center justify-between">
                                <span class="flex items-center gap-2 text-sm text-slate-600 dark:text-slate-300">
                                    <span class="w-3 h-3 rounded-full bg-amber-400 inline-block"></span> Pendientes
                                </span>
                                <span class="font-bold text-amber-600 dark:text-amber-400"><%= pendientes %></span>
                            </div>
                            <div class="flex items-center justify-between">
                                <span class="flex items-center gap-2 text-sm text-slate-600 dark:text-slate-300">
                                    <span class="w-3 h-3 rounded-full bg-green-500 inline-block"></span> Aprobadas
                                </span>
                                <span class="font-bold text-green-600 dark:text-green-400"><%= aprobadas %></span>
                            </div>
                            <div class="flex items-center justify-between">
                                <span class="flex items-center gap-2 text-sm text-slate-600 dark:text-slate-300">
                                    <span class="w-3 h-3 rounded-full bg-red-500 inline-block"></span> Rechazadas
                                </span>
                                <span class="font-bold text-red-600 dark:text-red-400"><%= rechazadas %></span>
                            </div>
                            <div class="pt-3 border-t border-gray-100 dark:border-border-dark flex items-center justify-between">
                                <span class="text-sm font-semibold text-slate-600 dark:text-slate-300">Total enviadas</span>
                                <span class="font-bold text-primary dark:text-blue-400"><%= totalJ %></span>
                            </div>
                        </div>
                    </div>

                    <!-- Acciones rápidas -->
                    <div class="bg-gradient-to-br from-blue-50 to-blue-100 dark:from-blue-900/30 dark:to-blue-800/30 rounded-xl border-2 border-blue-200 dark:border-blue-800 p-6">
                        <h3 class="font-bold text-blue-900 dark:text-blue-300 mb-4 flex items-center gap-2">
                            <i class="fas fa-bolt text-xl"></i> Acciones rápidas
                        </h3>
                        <div class="space-y-3">
                            <a href="JustificacionServlet?accion=form"
                               class="flex items-center gap-3 w-full px-4 py-3 bg-primary hover:bg-blue-700 text-white font-semibold rounded-lg transition-colors text-sm">
                                <i class="fas fa-plus-circle"></i> Nueva Justificación
                            </a>
                            <a href="asistenciasPadre.jsp?alumno_id=<%= alumnoId %>"
                               class="flex items-center gap-3 w-full px-4 py-3 bg-white dark:bg-gray-800 border border-blue-200 dark:border-blue-800 text-blue-700 dark:text-blue-300 font-medium rounded-lg hover:bg-blue-50 dark:hover:bg-blue-900/20 transition-colors text-sm">
                                <i class="fas fa-calendar-check"></i> Ver Asistencias
                            </a>
                            <a href="PadreDashboardServlet"
                               class="flex items-center gap-3 w-full px-4 py-3 bg-white dark:bg-gray-800 border border-blue-200 dark:border-blue-800 text-blue-700 dark:text-blue-300 font-medium rounded-lg hover:bg-blue-50 dark:hover:bg-blue-900/20 transition-colors text-sm">
                                <i class="fas fa-home"></i> Ir al Dashboard
                            </a>
                        </div>
                    </div>

                    <!-- Info estados -->
                    <div class="bg-white dark:bg-card-dark rounded-xl shadow-sm border border-gray-200 dark:border-border-dark p-6">
                        <h3 class="font-bold text-gray-800 dark:text-white mb-4 flex items-center gap-2 text-sm">
                            <i class="fas fa-info-circle text-primary"></i> ¿Qué significa cada estado?
                        </h3>
                        <ul class="space-y-3 text-xs text-slate-600 dark:text-slate-400">
                            <li class="flex items-start gap-2">
                                <span class="w-2.5 h-2.5 rounded-full bg-amber-400 mt-1 flex-shrink-0"></span>
                                <span><strong class="text-slate-700 dark:text-slate-200">Pendiente:</strong> El docente aún no ha revisado tu solicitud.</span>
                            </li>
                            <li class="flex items-start gap-2">
                                <span class="w-2.5 h-2.5 rounded-full bg-green-500 mt-1 flex-shrink-0"></span>
                                <span><strong class="text-slate-700 dark:text-slate-200">Aprobada:</strong> La ausencia fue justificada correctamente.</span>
                            </li>
                            <li class="flex items-start gap-2">
                                <span class="w-2.5 h-2.5 rounded-full bg-red-500 mt-1 flex-shrink-0"></span>
                                <span><strong class="text-slate-700 dark:text-slate-200">Rechazada:</strong> El docente no aceptó la justificación. Revisa el motivo.</span>
                            </li>
                        </ul>
                    </div>

                </div>
            </div>
        </div>

        <footer class="mt-auto py-6 text-center text-xs text-slate-400 dark:text-slate-500 border-t border-slate-100 dark:border-border-dark bg-white dark:bg-card-dark">
            &copy; 2026 Colegio San Antonio - Todos los derechos reservados.
        </footer>
    </main>

</body>
</html>
