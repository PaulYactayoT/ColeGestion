<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Padre, modelo.PadreDAO, modelo.TareaDAO, modelo.Tarea, java.util.List" %>

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
    
    // --- 2. OBTENCIÓN DE DATOS ---
    List<Tarea> tareas = null;
    
    if (tieneAlumno) {
        TareaDAO tareaDAO = new TareaDAO();
        tareas = tareaDAO.listarPorAlumno(alumnoId);
    }
    
    String mensaje = (String) session.getAttribute("mensaje");
    String error = (String) session.getAttribute("error");
    if (mensaje != null) session.removeAttribute("mensaje");
    if (error != null) session.removeAttribute("error");
%>

<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tareas Pendientes - San Antonio</title>
    
    <jsp:include page="includes/head.jsp" />
    
    <style>
        .table-row-hover:hover td {
            background-color: #f8fafc;
        }
        .dark .table-row-hover:hover td {
            background-color: #1e293b;
        }
        
        /* Badges de Estado HU-14 */
        .status-badge { padding: 4px 10px; border-radius: 20px; font-size: 11px; font-weight: 600; display: inline-flex; align-items: center; gap: 4px; border: 1px solid transparent; }
        .status-active { background-color: #e6f7ee; color: #0d8a46; border-color: #bbf7d0; }
        .dark .status-active { background-color: rgba(13, 138, 70, 0.2); color: #4ade80; border-color: rgba(74, 222, 128, 0.3); }
        .status-inactive { background-color: #fce8e6; color: #c53030; border-color: #fecaca; }
        .dark .status-inactive { background-color: rgba(197, 48, 48, 0.2); color: #f87171; border-color: rgba(248, 113, 113, 0.3); }
        .status-delivered { background-color: #e0eaff; color: #0d6efd; border-color: #bfdbfe; }
        .dark .status-delivered { background-color: rgba(13, 110, 253, 0.2); color: #60a5fa; border-color: rgba(96, 165, 250, 0.3); }
        
        /* Botones de acción HU-14 */
        .btn-icon-action { width: 34px; height: 34px; border-radius: 6px; display: flex; align-items: center; justify-content: center; border: none; cursor: pointer; transition: all 0.2s; text-decoration: none; }
        .btn-view { background-color: #0d6efd; color: white; box-shadow: 0 2px 4px rgba(13, 110, 253, 0.2); }
        .btn-view:hover { background-color: #0b4eb8; transform: translateY(-2px); }
        .btn-locked { background-color: #e5e7eb; color: #6b7280; cursor: not-allowed; }
        .dark .btn-locked { background-color: #374151; color: #9ca3af; }
        
        .countdown-timer { min-width: 120px; font-weight: 600; font-size: 12px; padding: 4px 10px; border-radius: 20px; display: inline-flex; align-items: center; gap: 4px;}
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark text-slate-800 dark:text-slate-200 min-h-screen flex transition-colors duration-200">

    <jsp:include page="includes/sidebarPadre.jsp" />
    
    <main class="flex-1 md:ml-64 flex flex-col min-h-screen">
        
        <jsp:include page="includes/header.jsp" />

        <div class="p-6 md:p-8 max-w-7xl mx-auto w-full">
            
            <% if (mensaje != null) { %>
            <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative mb-6 flex items-center gap-2" role="alert">
                <i class="fas fa-check-circle"></i>
                <span class="block sm:inline font-medium"><%= mensaje %></span>
            </div>
            <% } %>
            <% if (error != null) { %>
            <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative mb-6 flex items-center gap-2" role="alert">
                <i class="fas fa-exclamation-circle"></i>
                <span class="block sm:inline font-medium"><%= error %></span>
            </div>
            <% } %>

            <div class="bg-gradient-to-r from-primary to-blue-600 rounded-2xl p-6 text-white shadow-lg mb-8 flex flex-col md:flex-row justify-between items-center gap-4 relative overflow-hidden">
                <div class="absolute top-0 right-0 -mt-8 -mr-8 w-40 h-40 bg-white/10 rounded-full blur-2xl"></div>
                
                <div class="relative z-10">
                    <h2 class="text-2xl font-bold flex items-center gap-2">
                        <i class="fas fa-tasks opacity-70"></i>
                        Agenda de Tareas
                    </h2>
                    <p class="text-blue-100 text-sm font-medium mt-1">
                        Revisa las asignaciones y fechas de entrega para <%= padre.getAlumnoNombre() %>.
                    </p>
                </div>

                <div class="relative z-10 flex gap-2">
                    <a href="ExportServlet?report=tareas&type=pdf&alumno_id=<%= alumnoId%>" 
                       class="bg-white text-primary hover:bg-blue-50 px-4 py-2 rounded-lg font-semibold text-sm flex items-center gap-2 shadow-sm transition-all dark:bg-card-dark dark:text-white dark:hover:bg-gray-800">
                        <i class="fas fa-file-pdf"></i> Exportar PDF
                    </a>
                    
                    <a href="ExportServlet?report=tareas&type=xlsx&alumno_id=<%= alumnoId%>"
                       class="bg-green-500 hover:bg-green-600 text-white px-4 py-2 rounded-lg font-semibold text-sm flex items-center gap-2 shadow-sm transition-all dark:bg-green-600 dark:hover:bg-green-700">
                        <i class="fas fa-file-excel"></i> Exportar Excel
                    </a>
                </div>
            </div>

            <div class="bg-white dark:bg-card-dark rounded-xl shadow-sm border border-gray-200 dark:border-border-dark overflow-hidden">
                
                <div class="p-4 border-b border-gray-100 dark:border-border-dark flex justify-between items-center bg-gray-50/50 dark:bg-gray-800/50">
                    <h3 class="font-bold text-slate-700 dark:text-slate-300">Listado de Actividades</h3>
                    <div class="flex gap-2">
                        <span class="text-xs text-slate-500 dark:text-slate-400 bg-white dark:bg-card-dark border px-2 py-1 rounded flex items-center gap-1 dark:border-border-dark">
                            <span class="size-2 rounded-full bg-green-500"></span> Activas
                        </span>
                    </div>
                </div>

                <div class="overflow-x-auto">
                    <table class="w-full text-left border-collapse">
                        <thead>
                            <tr class="bg-gray-50 dark:bg-gray-800 border-b border-gray-200 dark:border-border-dark text-xs uppercase text-slate-500 dark:text-slate-400 font-bold tracking-wider">
                                <th class="px-6 py-4">Curso / Tarea</th>
                                <th class="px-6 py-4 w-1/4">Descripción</th>
                                <th class="px-6 py-4">Fecha Límite</th>
                                <th class="px-6 py-4 text-center">Tiempo Restante</th>
                                <th class="px-6 py-4 text-center">Estado / Acción</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100 dark:divide-border-dark text-sm text-slate-700 dark:text-slate-300">
                            
                            <% if (tareas != null && !tareas.isEmpty()) { 
                                for (Tarea tarea : tareas) {
                                    String estado = tarea.getEstadoCalculado() != null ? tarea.getEstadoCalculado() : "ACTIVO";
                            %>
                            <tr class="table-row-hover transition-colors">
                                <td class="px-6 py-4">
                                    <div class="font-bold text-primary dark:text-blue-400 mb-1"><%= tarea.getCursoNombre() %></div>
                                    <div class="font-medium text-slate-800 dark:text-slate-200"><%= tarea.getNombre() %></div>
                                    <span class="inline-block mt-1 px-2 py-0.5 bg-gray-100 text-gray-600 dark:bg-gray-800 dark:text-gray-400 rounded text-[10px] uppercase tracking-wider font-semibold border border-gray-200 dark:border-gray-700">
                                        <%= tarea.getTipo() %>
                                    </span>
                                </td>
                                
                                <td class="px-6 py-4 text-slate-600 dark:text-slate-400">
                                    <p class="line-clamp-2 text-xs" title="<%= tarea.getDescripcion() %>">
                                        <%= tarea.getDescripcion() %>
                                    </p>
                                </td>
                                
                                <td class="px-6 py-4 text-slate-500 dark:text-slate-400 whitespace-nowrap">
                                    <div class="flex items-center gap-2 font-medium">
                                        <i class="far fa-calendar-alt text-primary dark:text-blue-400"></i>
                                        <div>
                                            <%= (tarea.getFechaEntrega() != null) ? tarea.getFechaEntrega() : "Sin fecha" %>
                                            <div class="text-xs font-normal mt-0.5 opacity-75">
                                                <i class="far fa-clock"></i> <%= (tarea.getHoraEntrega() != null) ? tarea.getHoraEntrega() : "23:59:59" %>
                                            </div>
                                        </div>
                                    </div>
                                </td>

                                <td class="px-6 py-4 text-center whitespace-nowrap">
                                    <% if ("INACTIVO".equals(estado) || "ELIMINADO".equals(estado) || "FINALIZADO".equals(estado) || "CERRADO_MANUAL".equals(estado)) { %>
                                        <span class="inline-flex items-center gap-1 px-3 py-1 bg-red-100 text-red-700 border border-red-200 dark:bg-red-900/30 dark:text-red-400 dark:border-red-800 rounded-full text-xs font-semibold">
                                            <i class="fas fa-exclamation-triangle"></i> Tiempo Finalizado
                                        </span>
                                    <% } else if ("ENTREGADO".equals(estado)) { %>
                                        <span class="inline-flex items-center gap-1 px-3 py-1 bg-green-100 text-green-700 border border-green-200 dark:bg-green-900/30 dark:text-green-400 dark:border-green-800 rounded-full text-xs font-semibold">
                                            <i class="fas fa-check-circle"></i> Subido correctamente
                                        </span>
                                    <% } else { %>
                                        <div class="countdown-timer inline-flex items-center gap-1.5 px-3 py-1 bg-gray-100 text-gray-700 border border-gray-200 dark:bg-gray-800 dark:text-gray-300 dark:border-gray-700 rounded-full text-xs font-semibold shadow-sm"
                                             data-fecha="<%= tarea.getFechaEntrega() %>" 
                                             data-hora="<%= tarea.getHoraEntrega() != null ? tarea.getHoraEntrega() : "23:59:59" %>">
                                             <i class="fas fa-spinner fa-spin text-[10px]"></i> Calculando...
                                        </div>
                                    <% } %>
                                </td>

                                <td class="px-6 py-4">
                                    <div class="flex flex-col items-center gap-2">
                                        <% if ("ENTREGADO".equals(estado)) { %>
                                            <span class="status-badge status-delivered"><i class="fas fa-check"></i> Entregado</span>
                                        <% } else if (tarea.isActivo() && "ACTIVO".equals(estado)) { %>
                                            <span class="status-badge status-active"><i class="fas fa-circle text-[8px]"></i> Activo</span>
                                        <% } else { %>
                                            <span class="status-badge status-inactive"><i class="fas fa-times"></i> Inactivo</span>
                                        <% } %>
                                        
                                        <% if (tarea.isActivo() && "ACTIVO".equals(estado)) { %>
                                            <a href="EntregaServlet?accion=ver&id=<%= tarea.getId() %>" class="btn-icon-action btn-view w-full max-w-[100px] gap-2 text-xs" title="Subir Tarea">
                                                <i class="fas fa-upload"></i> Ver Tarea
                                            </a>
                                        <% } else { %>
                                            <button class="btn-icon-action btn-locked w-full max-w-[100px] gap-2 text-xs" disabled title="Acceso bloqueado">
                                                <i class="fas fa-lock"></i> Bloqueado
                                            </button>
                                        <% } %>
                                    </div>
                                </td>
                            </tr>
                            <%  } 
                               } else { %>
                            
                            <tr>
                                <td colspan="5" class="px-6 py-16 text-center text-slate-500 dark:text-slate-400">
                                    <div class="flex flex-col items-center justify-center">
                                        <div class="bg-green-50 dark:bg-green-900/20 p-4 rounded-full mb-3">
                                            <span class="material-symbols-outlined text-4xl text-green-300 dark:text-green-600">task_alt</span>
                                        </div>
                                        <h3 class="text-lg font-bold text-slate-700 dark:text-slate-300">¡Todo al día!</h3>
                                        <p class="text-sm mt-1 max-w-sm text-slate-500 dark:text-slate-400">
                                            No hay tareas pendientes registradas para este alumno en este momento.
                                        </p>
                                    </div>
                                </td>
                            </tr>
                            
                            <% } %>
                        </tbody>
                    </table>
                </div>
                
                <div class="px-6 py-4 border-t border-gray-200 dark:border-border-dark bg-gray-50 dark:bg-gray-800/50 flex justify-between items-center text-xs text-slate-500 dark:text-slate-400">
                    <span>Ordenado por fecha de entrega más próxima</span>
                </div>
            </div>

        </div>
        
        <footer class="mt-auto py-6 text-center text-xs text-slate-400 dark:text-slate-500 border-t border-slate-100 dark:border-border-dark bg-white dark:bg-card-dark">
            &copy; 2025 Colegio San Antonio - Todos los derechos reservados.
        </footer>
    </main>

    <script>
        // Script de contador de tiempo idéntico al del profesor
        function actualizarRelojes() {
            const ahora = new Date().getTime();
            const relojes = document.querySelectorAll('.countdown-timer');

            relojes.forEach(reloj => {
                const fecha = reloj.getAttribute('data-fecha');
                const hora = reloj.getAttribute('data-hora');
                
                if (!fecha || fecha === 'null') return;

                const horaFull = (hora && hora.length === 5) ? hora + ":00" : (hora ? hora : "23:59:00");
                const fechaISO = fecha + "T" + horaFull;
                const vencimiento = new Date(fechaISO).getTime();
                
                if (isNaN(vencimiento)) return;

                const distancia = vencimiento - ahora;

                if (distancia < 0) {
                    reloj.className = 'inline-flex items-center gap-1 px-3 py-1 bg-red-100 text-red-700 border border-red-200 dark:bg-red-900/30 dark:text-red-400 dark:border-red-800 rounded-full text-xs font-semibold';
                    reloj.innerHTML = '<i class="fas fa-exclamation-triangle"></i> Tiempo Finalizado';
                    
                    // Bloquear visualmente en vivo
                    const fila = reloj.closest('tr');
                    if (fila) {
                        const badgeContainer = fila.querySelector('td:last-child > div');
                        if (badgeContainer) {
                            // Cambiar a Inactivo (si no está entregado)
                            const badge = badgeContainer.querySelector('.status-badge');
                            if (badge && !badge.classList.contains('status-delivered')) {
                                badge.className = 'status-badge status-inactive';
                                badge.innerHTML = '<i class="fas fa-times"></i> Inactivo';
                            }
                            
                            // Cambiar botón a Candado
                            const btn = badgeContainer.querySelector('.btn-icon-action');
                            if (btn && btn.tagName === 'A') {
                                const newBtn = document.createElement('button');
                                newBtn.className = 'btn-icon-action btn-locked w-full max-w-[100px] gap-2 text-xs';
                                newBtn.disabled = true;
                                newBtn.title = 'Acceso bloqueado';
                                newBtn.innerHTML = '<i class="fas fa-lock"></i> Bloqueado';
                                badgeContainer.replaceChild(newBtn, btn);
                            }
                        }
                    }
                } else {
                    const dias = Math.floor(distancia / (1000 * 60 * 60 * 24));
                    const horas = Math.floor((distancia % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                    const minutos = Math.floor((distancia % (1000 * 60 * 60)) / (1000 * 60));
                    const segundos = Math.floor((distancia % (1000 * 60)) / 1000);

                    let texto = dias > 0 ? dias + "d " + horas + "h " + minutos + "m" : 
                                (horas < 10 ? "0"+horas : horas) + ":" + (minutos < 10 ? "0"+minutos : minutos) + ":" + (segundos < 10 ? "0"+segundos : segundos);
                    
                    let claseColor = dias > 0 ? "bg-green-100 text-green-700 border-green-200 dark:bg-green-900/30 dark:text-green-400 dark:border-green-800" : 
                                    (horas < 1 ? "bg-orange-100 text-orange-700 border-orange-200 dark:bg-orange-900/30 dark:text-orange-400 dark:border-orange-800" : 
                                                 "bg-blue-100 text-blue-700 border-blue-200 dark:bg-blue-900/30 dark:text-blue-400 dark:border-blue-800");
                    
                    reloj.className = `countdown-timer inline-flex items-center gap-1.5 px-3 py-1 border rounded-full text-xs font-semibold shadow-sm transition-colors ${claseColor}`;
                    reloj.innerHTML = '<i class="far fa-clock"></i> ' + texto;
                }
            });
        }
        setInterval(actualizarRelojes, 1000);
        actualizarRelojes();
    </script>
</body>
</html>