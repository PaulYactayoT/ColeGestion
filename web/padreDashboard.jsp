<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Padre, modelo.PadreDAO, modelo.AsistenciaDAO, modelo.ImageDAO, modelo.Imagen" %>
<%@ page import="java.util.Map, java.util.List" %>

<%
    // --- 1. LÓGICA DE SESIÓN Y DATOS (Igual que tu código original) ---
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
    
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    
    <link href="https://fonts.googleapis.com/css2?family=Lexend:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
    
    <script>
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        "primary": "#135bec",
                        "primary-dark": "#0d47a1",
                        "background-light": "#f6f6f8",
                        "background-dark": "#101622",
                    },
                    fontFamily: { "display": ["Lexend"] },
                },
            },
        }
    </script>
    
    <style>
        body { font-family: 'Lexend', sans-serif; }
        .material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24; }
        
        /* Efectos de Hover para las tarjetas */
        .dashboard-card {
            transition: all 0.3s ease;
            border: 1px solid transparent;
        }
        .dashboard-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.05);
            border-color: #e5e7eb;
        }
    </style>
</head>
<body class="bg-background-light text-slate-800 min-h-screen flex">

    <aside class="w-64 bg-white border-r border-gray-200 hidden md:flex flex-col justify-between fixed h-full z-20">
        <div class="p-6">
            <div class="flex items-center gap-3 mb-8">
                <div class="bg-primary size-10 rounded-lg flex items-center justify-center text-white shadow-md">
                    <span class="material-symbols-outlined">school</span>
                </div>
                <div>
                    <h1 class="text-lg font-bold leading-tight text-slate-900">San Antonio</h1>
                    <p class="text-xs text-slate-500 font-medium">Panel de Padre</p>
                </div>
            </div>
            
            <nav class="space-y-1">
                <a href="#" class="flex items-center gap-3 px-3 py-2.5 rounded-lg bg-primary/10 text-primary font-medium transition-colors">
                    <span class="material-symbols-outlined fill-1">dashboard</span>
                    <span class="text-sm">Dashboard</span>
                </a>
                
                <% if (tieneAlumno) { %>
                <a href="notasPadre.jsp?alumno_id=<%= alumnoId %>" class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-slate-600 hover:bg-slate-50 transition-colors group">
                    <span class="material-symbols-outlined group-hover:text-primary transition-colors">grade</span>
                    <span class="text-sm font-medium">Notas del Alumno</span>
                </a>
                <a href="observacionesPadre.jsp?alumno_id=<%= alumnoId %>" class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-slate-600 hover:bg-slate-50 transition-colors group">
                    <span class="material-symbols-outlined group-hover:text-primary transition-colors">chat_bubble</span>
                    <span class="text-sm font-medium">Observaciones</span>
                </a>
                <a href="tareasPadre.jsp?alumno_id=<%= alumnoId %>" class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-slate-600 hover:bg-slate-50 transition-colors group">
                    <span class="material-symbols-outlined group-hover:text-primary transition-colors">assignment</span>
                    <span class="text-sm font-medium">Tareas</span>
                </a>
                <a href="MaterialPadreServlet?accion=seleccionarCurso" class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-slate-600 hover:bg-slate-50 transition-colors group">
                    <span class="material-symbols-outlined group-hover:text-primary transition-colors">folder_open</span>
                    <span class="text-sm font-medium">Material de Apoyo</span>
                </a>
                <a href="albumPadre.jsp?alumno_id=<%= alumnoId %>" class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-slate-600 hover:bg-slate-50 transition-colors group">
                    <span class="material-symbols-outlined group-hover:text-primary transition-colors">photo_library</span>
                    <span class="text-sm font-medium">Álbums</span>
                </a>
                <a href="asistenciasPadre.jsp?alumno_id=<%= alumnoId %>" class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-slate-600 hover:bg-slate-50 transition-colors group">
                    <span class="material-symbols-outlined group-hover:text-primary transition-colors">calendar_month</span>
                    <span class="text-sm font-medium">Asistencias</span>
                </a>
                <% } %>
            </nav>
        </div>
        
        <div class="p-4 border-t border-gray-100">
            <a href="LogoutServlet" class="flex items-center justify-center gap-2 w-full py-2.5 border border-slate-200 rounded-lg text-sm font-medium text-slate-600 hover:bg-slate-50 hover:text-red-600 transition-colors">
                <span class="material-symbols-outlined text-[18px]">logout</span>
                Cerrar Sesión
            </a>
        </div>
    </aside>

    <main class="flex-1 md:ml-64 flex flex-col min-h-screen">
        
        <header class="bg-white border-b border-gray-200 sticky top-0 z-10 px-8 py-3 flex justify-between items-center">
            <div class="flex items-center gap-4">
                <h1 class="text-xl font-bold text-slate-800 hidden md:block">Panel del Padre de Familia</h1>
                <h1 class="text-xl font-bold text-slate-800 md:hidden">San Antonio</h1>
            </div>
            
            <div class="flex items-center gap-4">
                <button class="p-2 text-slate-400 hover:bg-slate-50 rounded-full relative">
                    <span class="material-symbols-outlined">notifications</span>
                    <span class="absolute top-2 right-2 size-2 bg-red-500 rounded-full border-2 border-white"></span>
                </button>
                <div class="h-8 w-[1px] bg-slate-200 mx-2 hidden md:block"></div>
                <div class="flex items-center gap-3">
                    <div class="text-right hidden md:block">
                        <p class="text-sm font-semibold text-slate-800"><%= tieneAlumno ? padre.getAlumnoNombre() : "Sin alumno" %></p>
                        <p class="text-xs text-slate-500"><%= tieneAlumno ? padre.getGradoNombre() : "Pendiente" %></p>
                    </div>
                    <div class="size-10 rounded-full bg-slate-100 border-2 border-slate-200 flex items-center justify-center text-slate-500">
                        <span class="material-symbols-outlined">person</span>
                    </div>
                </div>
            </div>
        </header>

        <div class="p-6 md:p-8 max-w-7xl mx-auto w-full">
            
            <% if (!tieneAlumno) { %>
            <div class="bg-yellow-50 border border-yellow-200 rounded-xl p-6 mb-8 flex items-start gap-4">
                <div class="bg-yellow-100 text-yellow-600 p-2 rounded-lg">
                    <span class="material-symbols-outlined text-2xl">warning</span>
                </div>
                <div>
                    <h3 class="font-bold text-yellow-800 text-lg">No tienes un alumno asociado</h3>
                    <p class="text-yellow-700 mt-1">Para ver la información académica, asistencia y tareas, tu cuenta debe estar vinculada a un estudiante matriculado. Por favor, contacta a la administración.</p>
                </div>
            </div>
            <% } else { %>

            <div class="bg-primary rounded-2xl p-6 md:p-8 text-white shadow-lg mb-8 relative overflow-hidden flex flex-col md:flex-row justify-between items-center gap-6">
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
                    <a href="asistenciasPadre.jsp?alumno_id=<%= alumnoId %>" class="flex-1 md:flex-none text-center bg-white text-primary hover:bg-blue-50 px-5 py-2.5 rounded-lg font-semibold transition-colors flex items-center justify-center gap-2">
                        <span class="material-symbols-outlined text-[20px]">visibility</span>
                        Ver Detalles
                    </a>
                    <a href="JustificacionServlet?accion=form&alumno_id=<%= alumnoId %>&persona_id=<%= padre.getId() %>" class="flex-1 md:flex-none text-center bg-yellow-400 hover:bg-yellow-500 text-slate-900 px-5 py-2.5 rounded-lg font-bold transition-colors flex items-center justify-center gap-2">
                        <span class="material-symbols-outlined text-[20px]">edit_note</span>
                        Justificar
                    </a>
                </div>
            </div>

            <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-10">
                <div class="bg-white p-4 rounded-xl shadow-sm border border-slate-100 flex items-center justify-between">
                    <div>
                        <p class="text-xs text-slate-500 uppercase font-bold tracking-wider mb-1">Total Presentes</p>
                        <p class="text-2xl font-bold text-slate-800"><%= cPresentes %></p>
                    </div>
                    <div class="size-10 rounded-full bg-green-50 text-green-600 flex items-center justify-center">
                        <span class="material-symbols-outlined">check_circle</span>
                    </div>
                </div>
                <div class="bg-white p-4 rounded-xl shadow-sm border border-slate-100 flex items-center justify-between">
                    <div>
                        <p class="text-xs text-slate-500 uppercase font-bold tracking-wider mb-1">Tardanzas</p>
                        <p class="text-2xl font-bold text-slate-800"><%= cTardanzas %></p>
                    </div>
                    <div class="size-10 rounded-full bg-orange-50 text-orange-600 flex items-center justify-center">
                        <span class="material-symbols-outlined">schedule</span>
                    </div>
                </div>
                <div class="bg-white p-4 rounded-xl shadow-sm border border-slate-100 flex items-center justify-between">
                    <div>
                        <p class="text-xs text-slate-500 uppercase font-bold tracking-wider mb-1">Ausentes</p>
                        <p class="text-2xl font-bold text-slate-800"><%= cAusentes %></p>
                    </div>
                    <div class="size-10 rounded-full bg-red-50 text-red-600 flex items-center justify-center">
                        <span class="material-symbols-outlined">cancel</span>
                    </div>
                </div>
                <div class="bg-white p-4 rounded-xl shadow-sm border border-slate-100 flex items-center justify-between">
                    <div>
                        <p class="text-xs text-slate-500 uppercase font-bold tracking-wider mb-1">Justificados</p>
                        <p class="text-2xl font-bold text-slate-800"><%= cJustificados %></p>
                    </div>
                    <div class="size-10 rounded-full bg-blue-50 text-blue-600 flex items-center justify-center">
                        <span class="material-symbols-outlined">assignment_turned_in</span>
                    </div>
                </div>
            </div>

            <h3 class="text-lg font-bold text-slate-800 mb-5">Accesos Directos</h3>
            
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                
                <div class="dashboard-card bg-white rounded-2xl p-6 shadow-sm border border-gray-100 flex flex-col items-center text-center h-full">
                    <div class="bg-yellow-50 text-yellow-600 p-4 rounded-2xl mb-4">
                        <i class="fas fa-clipboard-list text-3xl"></i>
                    </div>
                    <h4 class="font-bold text-lg text-slate-800 mb-2">Notas del Alumno</h4>
                    <p class="text-sm text-slate-500 mb-6 flex-grow">Revisa las calificaciones y evaluaciones por curso y tarea.</p>
                    <a href="notasPadre.jsp?alumno_id=<%= alumnoId %>" class="w-full py-3 rounded-xl bg-yellow-400 hover:bg-yellow-500 text-slate-900 font-bold transition-colors shadow-sm">
                        Ver Notas
                    </a>
                </div>

                <div class="dashboard-card bg-white rounded-2xl p-6 shadow-sm border border-gray-100 flex flex-col items-center text-center h-full">
                    <div class="bg-blue-50 text-blue-600 p-4 rounded-2xl mb-4">
                        <i class="fas fa-chalkboard-user text-3xl"></i>
                    </div>
                    <h4 class="font-bold text-lg text-slate-800 mb-2">Observaciones</h4>
                    <p class="text-sm text-slate-500 mb-6 flex-grow">Consulta las observaciones y comentarios del docente sobre tu hijo.</p>
                    <a href="observacionesPadre.jsp?alumno_id=<%= alumnoId %>" class="w-full py-3 rounded-xl bg-primary hover:bg-blue-700 text-white font-bold transition-colors shadow-sm">
                        Ver Observaciones
                    </a>
                </div>

                <div class="dashboard-card bg-white rounded-2xl p-6 shadow-sm border border-gray-100 flex flex-col items-center text-center h-full">
                    <div class="bg-green-50 text-green-600 p-4 rounded-2xl mb-4">
                        <i class="fas fa-list-check text-3xl"></i>
                    </div>
                    <h4 class="font-bold text-lg text-slate-800 mb-2">Tareas Pendientes</h4>
                    <p class="text-sm text-slate-500 mb-6 flex-grow">Consulta las tareas asignadas por curso y sus fechas de entrega.</p>
                    <a href="tareasPadre.jsp?alumno_id=<%= alumnoId %>" class="w-full py-3 rounded-xl bg-green-600 hover:bg-green-700 text-white font-bold transition-colors shadow-sm">
                        Ver Tareas
                    </a>
                </div>

                <div class="dashboard-card bg-white rounded-2xl p-6 shadow-sm border border-gray-100 flex flex-col items-center text-center h-full">
                    <div class="bg-rose-50 text-rose-500 p-4 rounded-2xl mb-4">
                        <i class="fas fa-folder-open text-3xl"></i>
                    </div>
                    <h4 class="font-bold text-lg text-slate-800 mb-2">Material de Apoyo</h4>
                    <p class="text-sm text-slate-500 mb-6 flex-grow">Accede a los materiales educativos subidos por los profesores.</p>
                    <a href="MaterialPadreServlet?accion=seleccionarCurso" class="w-full py-3 rounded-xl bg-rose-400 hover:bg-rose-500 text-white font-bold transition-colors shadow-sm">
                        Ver Materiales
                    </a>
                </div>

                <div class="dashboard-card bg-white rounded-2xl p-6 shadow-sm border border-gray-100 flex flex-col items-center text-center h-full">
                    <div class="bg-red-50 text-red-600 p-4 rounded-2xl mb-4">
                        <i class="fas fa-images text-3xl"></i>
                    </div>
                    <h4 class="font-bold text-lg text-slate-800 mb-2">Álbum de Fotos</h4>
                    <p class="text-sm text-slate-500 mb-6 flex-grow">Álbum de recuerdos y actividades escolares de tu hijo/a.</p>
                    <a href="albumPadre.jsp?alumno_id=<%= alumnoId %>" class="w-full py-3 rounded-xl bg-red-600 hover:bg-red-700 text-white font-bold transition-colors shadow-sm">
                        Ver Álbum
                    </a>
                </div>

                <div class="dashboard-card bg-white rounded-2xl p-6 shadow-sm border border-gray-100 flex flex-col items-center text-center h-full">
                    <div class="bg-gray-100 text-gray-600 p-4 rounded-2xl mb-4">
                        <i class="fas fa-calendar-check text-3xl"></i>
                    </div>
                    <h4 class="font-bold text-lg text-slate-800 mb-2">Asistencias</h4>
                    <p class="text-sm text-slate-500 mb-6 flex-grow">Consulta el historial completo y detallado de asistencia.</p>
                    <a href="JustificacionServlet?accion=form&alumno_id=<%= alumnoId %>&persona_id=<%= padre.getId() %>" class="w-full py-3 rounded-xl bg-gray-500 hover:bg-gray-600 text-white font-bold transition-colors shadow-sm">
                        Justificar
                    </a>
                </div>

            </div>
            <% } %>
            
            <footer class="mt-12 text-center text-sm text-slate-400 py-6 border-t border-slate-100">
                &copy; 2025 Colegio San Antonio - Todos los derechos reservados.
            </footer>

        </div>
    </main>

</body>
</html>