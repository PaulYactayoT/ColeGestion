<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Padre, modelo.PadreDAO, modelo.ObservacionDAO, modelo.Observacion, java.util.List" %>

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
    List<Observacion> observaciones = null;
    
    if (tieneAlumno) {
        ObservacionDAO observacionDAO = new ObservacionDAO();
        observaciones = observacionDAO.listarPorAlumno(alumnoId);
    }
%>

<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Observaciones - San Antonio</title>
    
    <!-- INCLUIR HEAD.JSP CON TODAS LAS CONFIGURACIONES -->
    <jsp:include page="includes/head.jsp" />
    
    <style>
        .table-row-hover:hover td {
            background-color: #f8fafc;
        }
        .dark .table-row-hover:hover td {
            background-color: #1e293b;
        }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark text-slate-800 dark:text-slate-200 min-h-screen flex transition-colors duration-200">

    <!-- INCLUIR SIDEBAR PARA PADRE -->
    <jsp:include page="includes/sidebarPadre.jsp" />
    
    <main class="flex-1 md:ml-64 flex flex-col min-h-screen">
        
        <!-- INCLUIR HEADER -->
        <jsp:include page="includes/header.jsp" />

        <div class="p-6 md:p-8 max-w-7xl mx-auto w-full">
            
            <!-- Banner principal - se mantiene igual porque es gradiente -->
            <div class="bg-gradient-to-r from-primary to-blue-600 rounded-2xl p-6 text-white shadow-lg mb-8 flex flex-col md:flex-row justify-between items-center gap-4 relative overflow-hidden">
                <div class="absolute top-0 right-0 -mt-8 -mr-8 w-40 h-40 bg-white/10 rounded-full blur-2xl"></div>
                
                <div class="relative z-10">
                    <h2 class="text-2xl font-bold flex items-center gap-2">
                        <i class="fas fa-comments opacity-70"></i>
                        Hoja de Observaciones
                    </h2>
                    <p class="text-blue-100 text-sm font-medium mt-1">
                        Comentarios y anotaciones de los docentes sobre el desempeño de <%= padre.getAlumnoNombre() %>.
                    </p>
                </div>

                <div class="relative z-10 flex gap-2">
                    <a href="ExportServlet?report=observaciones&type=pdf&alumno_id=<%= alumnoId%>" 
                       class="bg-white text-primary hover:bg-blue-50 px-4 py-2 rounded-lg font-semibold text-sm flex items-center gap-2 shadow-sm transition-all dark:bg-card-dark dark:text-white dark:hover:bg-gray-800">
                        <i class="fas fa-file-pdf"></i> Imprimir Reporte
                    </a>
                </div>
            </div>

            <!-- Tarjeta de observaciones - CON DARK MODE -->
            <div class="bg-white dark:bg-card-dark rounded-xl shadow-sm border border-gray-200 dark:border-border-dark overflow-hidden">
                
                <div class="p-4 border-b border-gray-100 dark:border-border-dark flex justify-between items-center bg-gray-50/50 dark:bg-gray-800/50">
                    <h3 class="font-bold text-slate-700 dark:text-slate-300">Historial de Registros</h3>
                    <div class="flex gap-2">
                        <span class="text-xs text-slate-500 dark:text-slate-400 bg-white dark:bg-card-dark border px-2 py-1 rounded dark:border-border-dark">Orden cronológico</span>
                    </div>
                </div>

                <div class="overflow-x-auto">
                    <table class="w-full text-left border-collapse">
                        <thead>
                            <tr class="bg-gray-50 dark:bg-gray-800 border-b border-gray-200 dark:border-border-dark text-xs uppercase text-slate-500 dark:text-slate-400 font-bold tracking-wider">
                                <th class="px-6 py-4 w-1/4">Curso</th>
                                <th class="px-6 py-4 w-3/4">Detalle de la Observación</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100 dark:divide-border-dark text-sm text-slate-700 dark:text-slate-300">
                            
                            <% if (observaciones != null && !observaciones.isEmpty()) { 
                                for (Observacion obs : observaciones) {
                            %>
                            <tr class="table-row-hover transition-colors group">
                                <td class="px-6 py-4 align-top">
                                    <div class="flex flex-col">
                                        <span class="font-bold text-slate-800 dark:text-slate-200 text-base mb-1"><%= obs.getCursoNombre() %></span>
                                    </div>
                                </td>
                                <td class="px-6 py-4 align-top">
                                    <div class="relative pl-4 border-l-2 border-gray-200 dark:border-border-dark group-hover:border-primary transition-colors">
                                        <p class="text-slate-600 dark:text-slate-400 leading-relaxed">
                                            <%= obs.getTexto() %>
                                        </p>
                                    </div>
                                </td>
                            </tr>
                            <%  } 
                               } else { %>
                            
                            <tr>
                                <td colspan="2" class="px-6 py-16 text-center text-slate-500 dark:text-slate-400">
                                    <div class="flex flex-col items-center justify-center">
                                        <div class="bg-blue-50 dark:bg-blue-900/20 p-4 rounded-full mb-3">
                                            <span class="material-symbols-outlined text-4xl text-blue-300 dark:text-blue-600">thumb_up</span>
                                        </div>
                                        <h3 class="text-lg font-bold text-slate-700 dark:text-slate-300">¡Todo va bien!</h3>
                                        <p class="text-sm mt-1 max-w-sm text-slate-500 dark:text-slate-400">
                                            No se han registrado observaciones para este alumno hasta el momento.
                                        </p>
                                    </div>
                                </td>
                            </tr>
                            
                            <% } %>
                        </tbody>
                    </table>
                </div>
                
                <div class="px-6 py-4 border-t border-gray-200 dark:border-border-dark bg-gray-50 dark:bg-gray-800/50 flex justify-between items-center text-xs text-slate-500 dark:text-slate-400">
                    <span>Mostrando registros del año escolar actual</span>
                </div>
            </div>

        </div>
        
        <footer class="mt-auto py-6 text-center text-xs text-slate-400 dark:text-slate-500 border-t border-slate-100 dark:border-border-dark bg-white dark:bg-card-dark">
            &copy; 2025 Colegio San Antonio - Todos los derechos reservados.
        </footer>
    </main>

</body>
</html>