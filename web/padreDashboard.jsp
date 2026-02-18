<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Padre, modelo.PadreDAO, modelo.AsistenciaDAO" %>
<%@ page import="java.util.Map" %>

<%
    // --- 1. LÓGICA DE SESIÓN Y DATOS ---
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
    } else {
        if (session.getAttribute("personaId") == null) {
            session.setAttribute("personaId", padre.getId());
        }
    }
    
    boolean tieneAlumno = padre.getAlumnoId() > 0;
    int alumnoId = padre.getAlumnoId();
    
    Map<String, Object> resumenAsistencia = null;
    double porcentajeAsistencia = 0.0;
    
    // Variables para contadores
    int cPresentes = 0, cTardanzas = 0, cAusentes = 0, cJustificados = 0;
    
    if (tieneAlumno) {
        AsistenciaDAO asistenciaDAO = new AsistenciaDAO();
        int mesActual = java.time.LocalDate.now().getMonthValue();
        int anioActual = java.time.LocalDate.now().getYear();
        
        resumenAsistencia = asistenciaDAO.obtenerResumenAsistenciaAlumnoTurno(alumnoId, 1, mesActual, anioActual);
        
        if (resumenAsistencia != null && !resumenAsistencia.isEmpty()) {
            Object porcentajeObj = resumenAsistencia.get("porcentajeAsistencia");
            if (porcentajeObj != null) porcentajeAsistencia = (Double) porcentajeObj;
            
            // Extraer contadores de forma segura
            if(resumenAsistencia.get("presentes") != null) cPresentes = Integer.parseInt(resumenAsistencia.get("presentes").toString());
            if(resumenAsistencia.get("tardanzas") != null) cTardanzas = Integer.parseInt(resumenAsistencia.get("tardanzas").toString());
            if(resumenAsistencia.get("ausentes") != null) cAusentes = Integer.parseInt(resumenAsistencia.get("ausentes").toString());
            if(resumenAsistencia.get("justificados") != null) cJustificados = Integer.parseInt(resumenAsistencia.get("justificados").toString());
        }
    }
%>

<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panel del Padre - San Antonio</title>
    
    <!-- INCLUIR HEAD.JSP CON TODAS LAS CONFIGURACIONES -->
    <jsp:include page="includes/head.jsp" />
    
    <style>
        .dashboard-card {
            transition: all 0.3s ease;
            border: 1px solid transparent;
        }
        .dashboard-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.05);
        }
        .dark .dashboard-card:hover {
            border-color: #374151;
            box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.3);
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
            
            <% if (!tieneAlumno) { %>
            <!-- Alerta sin alumno - CON DARK MODE -->
            <div class="bg-yellow-50 dark:bg-yellow-900/30 border border-yellow-200 dark:border-yellow-800 rounded-xl p-6 mb-8 flex items-start gap-4">
                <div class="bg-yellow-100 dark:bg-yellow-800 text-yellow-600 dark:text-yellow-400 p-2 rounded-lg">
                    <span class="material-symbols-outlined text-2xl">warning</span>
                </div>
                <div>
                    <h3 class="font-bold text-yellow-800 dark:text-yellow-300 text-lg">No tienes un alumno asociado</h3>
                    <p class="text-yellow-700 dark:text-yellow-400 mt-1">Para ver la información académica, asistencia y tareas, tu cuenta debe estar vinculada a un estudiante matriculado. Por favor, contacta a la administración.</p>
                </div>
            </div>
            <% } else { %>

            <!-- Banner de Asistencia - CON DARK MODE (mantiene gradiente) -->
            <div class="bg-gradient-to-r from-primary to-blue-600 rounded-2xl p-6 md:p-8 text-white shadow-lg mb-8 relative overflow-hidden flex flex-col md:flex-row justify-between items-center gap-6">
                <div class="absolute top-0 right-0 -mt-10 -mr-10 w-64 h-64 bg-white/10 rounded-full blur-3xl"></div>
                
                <div class="relative z-10 w-full md:w-auto">
                    <h2 class="text-2xl md:text-3xl font-bold mb-2">Asistencia de <%= padre.getAlumnoNombre() %></h2>
                    <div class="flex items-center gap-3">
                        <span class="opacity-90 text-sm">Asistencia Mensual:</span>
                        <div class="w-32 h-2 bg-blue-900/30 rounded-full overflow-hidden">
                            <div class="h-full bg-white rounded-full" style="width: <%= porcentajeAsistencia %>%"></div>
                        </div>
                        <span class="font-bold"><%= String.format("%.1f", porcentajeAsistencia) %>%</span>
                    </div>
                </div>

                <div class="relative z-10 flex gap-3 w-full md:w-auto">
                    <a href="asistenciasPadre.jsp?alumno_id=<%= alumnoId %>" class="flex-1 md:flex-none text-center bg-white text-primary hover:bg-blue-50 px-5 py-2.5 rounded-lg font-semibold transition-colors flex items-center justify-center gap-2 dark:bg-card-dark dark:text-white dark:hover:bg-gray-800">
                        <span class="material-symbols-outlined text-[20px]">visibility</span>
                        Ver Detalles
                    </a>
                </div>
            </div>

            <!-- Tarjetas de resumen - CON DARK MODE -->
            <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-10">
                <div class="bg-white dark:bg-card-dark p-4 rounded-xl shadow-sm border border-slate-100 dark:border-border-dark flex items-center justify-between transition-colors">
                    <div>
                        <p class="text-xs text-slate-500 dark:text-slate-400 uppercase font-bold tracking-wider mb-1">Total Presentes</p>
                        <p class="text-2xl font-bold text-slate-800 dark:text-white"><%= cPresentes %></p>
                    </div>
                    <div class="size-10 rounded-full bg-green-50 dark:bg-green-900/30 text-green-600 dark:text-green-400 flex items-center justify-center">
                        <span class="material-symbols-outlined">check_circle</span>
                    </div>
                </div>
                
                <div class="bg-white dark:bg-card-dark p-4 rounded-xl shadow-sm border border-slate-100 dark:border-border-dark flex items-center justify-between transition-colors">
                    <div>
                        <p class="text-xs text-slate-500 dark:text-slate-400 uppercase font-bold tracking-wider mb-1">Tardanzas</p>
                        <p class="text-2xl font-bold text-slate-800 dark:text-white"><%= cTardanzas %></p>
                    </div>
                    <div class="size-10 rounded-full bg-orange-50 dark:bg-orange-900/30 text-orange-600 dark:text-orange-400 flex items-center justify-center">
                        <span class="material-symbols-outlined">schedule</span>
                    </div>
                </div>
                
                <div class="bg-white dark:bg-card-dark p-4 rounded-xl shadow-sm border border-slate-100 dark:border-border-dark flex items-center justify-between transition-colors">
                    <div>
                        <p class="text-xs text-slate-500 dark:text-slate-400 uppercase font-bold tracking-wider mb-1">Ausentes</p>
                        <p class="text-2xl font-bold text-slate-800 dark:text-white"><%= cAusentes %></p>
                    </div>
                    <div class="size-10 rounded-full bg-red-50 dark:bg-red-900/30 text-red-600 dark:text-red-400 flex items-center justify-center">
                        <span class="material-symbols-outlined">cancel</span>
                    </div>
                </div>
                
                <div class="bg-white dark:bg-card-dark p-4 rounded-xl shadow-sm border border-slate-100 dark:border-border-dark flex items-center justify-between transition-colors">
                    <div>
                        <p class="text-xs text-slate-500 dark:text-slate-400 uppercase font-bold tracking-wider mb-1">Justificados</p>
                        <p class="text-2xl font-bold text-slate-800 dark:text-white"><%= cJustificados %></p>
                    </div>
                    <div class="size-10 rounded-full bg-blue-50 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400 flex items-center justify-center">
                        <span class="material-symbols-outlined">assignment_turned_in</span>
                    </div>
                </div>
            </div>

            <!-- Sección de Bienvenida o Información Adicional (opcional) -->
            <div class="bg-white dark:bg-card-dark rounded-xl p-6 shadow-sm border border-slate-100 dark:border-border-dark mb-6">
<h3 class="text-lg font-bold text-slate-800 dark:text-white mb-2">Bienvenido, <%= padre.getNombres() %> <%= padre.getApellidos() %></h3>                <p class="text-slate-600 dark:text-slate-400">
                    Aquí puedes monitorear el progreso académico y la asistencia de tu hijo. 
                    Utiliza el menú lateral para acceder a las diferentes secciones.
                </p>
            </div>

            <% } %>
            
            <!-- Footer - CON DARK MODE -->
            <footer class="mt-12 text-center text-sm text-slate-400 dark:text-slate-500 py-6 border-t border-slate-100 dark:border-border-dark">
                &copy; 2025 Colegio San Antonio - Todos los derechos reservados.
            </footer>

        </div>
    </main>

</body>
</html>