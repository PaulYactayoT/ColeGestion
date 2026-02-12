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
        
        .table-row-hover:hover td {
            background-color: #f8fafc;
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
                <a href="padreDashboard.jsp" class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-slate-600 hover:bg-slate-50 transition-colors group">
                    <span class="material-symbols-outlined group-hover:text-primary transition-colors">dashboard</span>
                    <span class="text-sm font-medium">Dashboard</span>
                </a>
                
                <a href="notasPadre.jsp?alumno_id=<%= alumnoId %>" class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-slate-600 hover:bg-slate-50 transition-colors group">
                    <span class="material-symbols-outlined group-hover:text-primary transition-colors">grade</span>
                    <span class="text-sm font-medium">Notas del Alumno</span>
                </a>
                
                <a href="observacionesPadre.jsp?alumno_id=<%= alumnoId %>" class="flex items-center gap-3 px-3 py-2.5 rounded-lg bg-primary/10 text-primary font-medium transition-colors">
                    <span class="material-symbols-outlined fill-1">chat_bubble</span>
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
            <div class="flex items-center gap-3">
                <a href="padreDashboard.jsp" class="md:hidden p-2 text-slate-400 hover:bg-slate-50 rounded-lg">
                    <span class="material-symbols-outlined">menu</span>
                </a>
                <div class="flex items-center gap-2 text-slate-800">
                    <span class="material-symbols-outlined text-primary text-2xl">chat_bubble</span>
                    <h1 class="text-xl font-bold">Observaciones</h1>
                </div>
            </div>
            
            <div class="flex items-center gap-4">
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
                       class="bg-white text-primary hover:bg-blue-50 px-4 py-2 rounded-lg font-semibold text-sm flex items-center gap-2 shadow-sm transition-all">
                        <i class="fas fa-file-pdf"></i> Imprimir Reporte
                    </a>
                </div>
            </div>

            <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
                
                <div class="p-4 border-b border-gray-100 flex justify-between items-center bg-gray-50/50">
                    <h3 class="font-bold text-slate-700">Historial de Registros</h3>
                    <div class="flex gap-2">
                        <span class="text-xs text-slate-500 bg-white border px-2 py-1 rounded">Orden cronológico</span>
                    </div>
                </div>

                <div class="overflow-x-auto">
                    <table class="w-full text-left border-collapse">
                        <thead>
                            <tr class="bg-gray-50 border-b border-gray-200 text-xs uppercase text-slate-500 font-bold tracking-wider">
                                <th class="px-6 py-4 w-1/4">Curso</th>
                                <th class="px-6 py-4 w-3/4">Detalle de la Observación</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100 text-sm text-slate-700">
                            
                            <% if (observaciones != null && !observaciones.isEmpty()) { 
                                for (Observacion obs : observaciones) {
                            %>
                            <tr class="table-row-hover transition-colors group">
                                <td class="px-6 py-4 align-top">
                                    <div class="flex flex-col">
                                        <span class="font-bold text-slate-800 text-base mb-1"><%= obs.getCursoNombre() %></span>
                                        </div>
                                </td>
                                <td class="px-6 py-4 align-top">
                                    <div class="relative pl-4 border-l-2 border-gray-200 group-hover:border-primary transition-colors">
                                        <p class="text-slate-600 leading-relaxed">
                                            <%= obs.getTexto() %>
                                        </p>
                                    </div>
                                </td>
                            </tr>
                            <%  } 
                               } else { %>
                            
                            <tr>
                                <td colspan="2" class="px-6 py-16 text-center text-slate-500">
                                    <div class="flex flex-col items-center justify-center">
                                        <div class="bg-blue-50 p-4 rounded-full mb-3">
                                            <span class="material-symbols-outlined text-4xl text-blue-300">thumb_up</span>
                                        </div>
                                        <h3 class="text-lg font-bold text-slate-700">¡Todo va bien!</h3>
                                        <p class="text-sm mt-1 max-w-sm">
                                            No se han registrado observaciones para este alumno hasta el momento.
                                        </p>
                                    </div>
                                </td>
                            </tr>
                            
                            <% } %>
                        </tbody>
                    </table>
                </div>
                
                <div class="px-6 py-4 border-t border-gray-200 bg-gray-50 flex justify-between items-center text-xs text-slate-500">
                    <span>Mostrando registros del año escolar actual</span>
                </div>
            </div>

        </div>
        
        <footer class="mt-auto py-6 text-center text-xs text-slate-400 border-t border-slate-100 bg-white">
            &copy; 2025 Colegio San Antonio - Todos los derechos reservados.
        </footer>
    </main>

</body>
</html>