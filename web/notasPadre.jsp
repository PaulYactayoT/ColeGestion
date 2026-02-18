<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Padre, modelo.PadreDAO, modelo.NotaDAO, modelo.Nota, java.util.List" %>

<%
    // --- 1. LÓGICA DE SESIÓN Y SEGURIDAD ---
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
    
    // --- 2. OBTENCIÓN DE NOTAS ---
    List<Nota> notas = null;
    
    if (tieneAlumno) {
        NotaDAO notaDAO = new NotaDAO();
        notas = notaDAO.listarPorAlumno(alumnoId);
    }
%>

<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Notas del Alumno - San Antonio</title>
    
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
                <div class="absolute top-0 right-0 -mt-8 -mr-8 w-40 h-40 bg-white/20 rounded-full blur-2xl"></div>
                
                <div class="relative z-10">
                    <h2 class="text-2xl font-bold flex items-center gap-2">
                        <i class="fas fa-clipboard-list opacity-70"></i>
                        Registro de Notas
                    </h2>
                    <p class="text-blue-100 text-sm font-medium mt-1">
                        Visualiza el rendimiento académico de <%= padre.getAlumnoNombre() %> en tiempo real.
                    </p>
                </div>

                <div class="relative z-10 flex gap-2">
                    <a href="ExportServlet?report=notas&type=pdf&alumno_id=<%= alumnoId%>" 
                       class="bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-lg font-semibold text-sm flex items-center gap-2 shadow-sm transition-all">
                        <i class="fas fa-file-pdf"></i> Exportar PDF
                    </a>
                    
                    <a href="ExportServlet?report=notas&type=xlsx&alumno_id=<%= alumnoId%>"
                       class="bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-lg font-semibold text-sm flex items-center gap-2 shadow-sm transition-all">
                        <i class="fas fa-file-excel"></i> Exportar Excel
                    </a>
                </div>
            </div>

            <!-- Tarjeta de notas - AHORA CON DARK MODE -->
            <div class="bg-white dark:bg-card-dark rounded-xl shadow-sm border border-gray-200 dark:border-border-dark overflow-hidden">
                
                <div class="p-4 border-b border-gray-100 dark:border-border-dark flex justify-between items-center bg-gray-50/50 dark:bg-gray-800/50">
                    <h3 class="font-bold text-slate-700 dark:text-slate-300">Detalle de Evaluaciones</h3>
                    <div class="flex gap-2">
                        <span class="text-xs text-slate-500 dark:text-slate-400 bg-white dark:bg-card-dark border px-2 py-1 rounded dark:border-border-dark">Todas las asignaturas</span>
                    </div>
                </div>

                <div class="overflow-x-auto">
                    <table class="w-full text-left border-collapse">
                        <thead>
                            <tr class="bg-gray-50 dark:bg-gray-800 border-b border-gray-200 dark:border-border-dark text-xs uppercase text-slate-500 dark:text-slate-400 font-bold tracking-wider">
                                <th class="px-6 py-4">Curso</th>
                                <th class="px-6 py-4">Evaluación / Tarea</th>
                                <th class="px-6 py-4 text-center">Nota</th>
                                <th class="px-6 py-4 text-center">Estado</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100 dark:divide-border-dark text-sm text-slate-700 dark:text-slate-300">
                            
                            <% if (notas != null && !notas.isEmpty()) { 
                                for (Nota nota : notas) {
                                    double valorNota = 0.0;
                                    try {
                                        valorNota = Double.parseDouble(String.valueOf(nota.getNota()));
                                    } catch(Exception e) {
                                        valorNota = 0.0;
                                    }
                                    
                                    String colorNota = "text-slate-700 dark:text-slate-300";
                                    String badgeEstado = "bg-green-100 text-green-700 border-green-200 dark:bg-green-900/30 dark:text-green-400 dark:border-green-800";
                                    String textoEstado = "Aprobado";
                                    String iconoEstado = "check_circle";
                                    
                                    if (valorNota < 11) {
                                        colorNota = "text-red-600 dark:text-red-400 font-bold";
                                        badgeEstado = "bg-red-100 text-red-700 border-red-200 dark:bg-red-900/30 dark:text-red-400 dark:border-red-800";
                                        textoEstado = "Desaprobado";
                                        iconoEstado = "cancel";
                                    } else if (valorNota < 14) {
                                        colorNota = "text-orange-600 dark:text-orange-400 font-bold";
                                        badgeEstado = "bg-orange-100 text-orange-700 border-orange-200 dark:bg-orange-900/30 dark:text-orange-400 dark:border-orange-800";
                                        textoEstado = "Regular";
                                        iconoEstado = "info";
                                    } else {
                                        colorNota = "text-blue-600 dark:text-blue-400 font-bold";
                                        badgeEstado = "bg-blue-100 text-blue-700 border-blue-200 dark:bg-blue-900/30 dark:text-blue-400 dark:border-blue-800";
                                        textoEstado = "Excelente";
                                    }
                            %>
                            <tr class="table-row-hover transition-colors">
                                <td class="px-6 py-4 font-medium text-slate-900 dark:text-slate-200">
                                    <div class="flex items-center gap-2">
                                        <div class="size-2 rounded-full bg-primary"></div>
                                        <%= nota.getCursoNombre() %>
                                    </div>
                                </td>
                                <td class="px-6 py-4"><%= nota.getTareaNombre() %></td>
                                <td class="px-6 py-4 text-center text-base <%= colorNota %>">
                                    <%= String.format("%.0f", valorNota) %>
                                </td>
                                <td class="px-6 py-4 text-center">
                                    <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-medium border <%= badgeEstado %>">
                                        <span class="material-symbols-outlined text-[14px]"><%= iconoEstado %></span>
                                        <%= textoEstado %>
                                    </span>
                                </td>
                            </tr>
                            <%  } 
                               } else { %>
                            
                            <tr>
                                <td colspan="4" class="px-6 py-12 text-center text-slate-500 dark:text-slate-400">
                                    <div class="flex flex-col items-center justify-center">
                                        <div class="bg-gray-50 dark:bg-gray-800 p-4 rounded-full mb-3">
                                            <span class="material-symbols-outlined text-4xl text-gray-300 dark:text-gray-600">grade_off</span>
                                        </div>
                                        <p class="font-medium">No hay notas registradas</p>
                                        <p class="text-xs mt-1">Las calificaciones aparecerán aquí cuando los profesores las publiquen.</p>
                                    </div>
                                </td>
                            </tr>
                            
                            <% } %>
                        </tbody>
                    </table>
                </div>
                
                <div class="px-6 py-4 border-t border-gray-200 dark:border-border-dark bg-gray-50 dark:bg-gray-800/50 flex justify-between items-center text-xs text-slate-500 dark:text-slate-400">
                    <span>Registro actualizado automáticamente</span>
                </div>
            </div>

        </div>
        
        <footer class="mt-auto py-6 text-center text-xs text-slate-400 dark:text-slate-500 border-t border-slate-100 dark:border-border-dark bg-white dark:bg-card-dark">
            &copy; 2025 Colegio San Antonio - Todos los derechos reservados.
        </footer>
    </main>

</body>
</html>