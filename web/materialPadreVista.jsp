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
    if(alumnoNombre == null) alumnoNombre = padre.getAlumnoNombre();

    // Validación simple por si entra directo sin curso
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
        
        .file-card {
            transition: all 0.2s ease;
            border: 1px solid #e5e7eb;
        }
        .file-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            border-color: #bfdbfe;
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
                
                <a href="observacionesPadre.jsp?alumno_id=<%= alumnoId %>" class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-slate-600 hover:bg-slate-50 transition-colors group">
                    <span class="material-symbols-outlined group-hover:text-primary transition-colors">chat_bubble</span>
                    <span class="text-sm font-medium">Observaciones</span>
                </a>
                
                <a href="tareasPadre.jsp?alumno_id=<%= alumnoId %>" class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-slate-600 hover:bg-slate-50 transition-colors group">
                    <span class="material-symbols-outlined group-hover:text-primary transition-colors">assignment</span>
                    <span class="text-sm font-medium">Tareas</span>
                </a>
                
                <a href="MaterialPadreServlet?accion=seleccionarCurso" class="flex items-center gap-3 px-3 py-2.5 rounded-lg bg-primary/10 text-primary font-medium transition-colors">
                    <span class="material-symbols-outlined fill-1">folder_open</span>
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
            <div class="flex items-center gap-2">
                <a href="MaterialPadreServlet?accion=seleccionarCurso" class="p-2 -ml-2 text-slate-400 hover:text-primary hover:bg-blue-50 rounded-full transition-colors" title="Volver a Cursos">
                    <span class="material-symbols-outlined">arrow_back</span>
                </a>
                <h2 class="text-xl font-bold text-slate-800">Detalle del Curso</h2>
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

        <div class="p-6 md:p-8 max-w-6xl mx-auto w-full">
            
            <div class="bg-gradient-to-r from-primary to-blue-600 rounded-2xl p-8 text-white shadow-lg mb-8 relative overflow-hidden">
                <div class="absolute top-0 right-0 -mt-10 -mr-10 w-64 h-64 bg-white/10 rounded-full blur-3xl"></div>
                
                <div class="relative z-10 flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
                    <div>
                        <div class="flex items-center gap-2 mb-2 opacity-90">
                            <span class="material-symbols-outlined icon-filled">book_2</span>
                            <span class="text-sm font-medium uppercase tracking-wider">Material de Apoyo</span>
                        </div>
                        <h1 class="text-3xl font-bold mb-1"><%= curso.getNombre() %></h1>
                        <div class="flex flex-wrap items-center gap-3 text-blue-100 text-sm">
                            <span class="bg-white/20 px-3 py-1 rounded-full backdrop-blur-sm border border-white/10 flex items-center gap-1">
                                <i class="fas fa-layer-group text-xs"></i> <%= curso.getGradoNombre() %>
                            </span>
                            <span class="flex items-center gap-1">
                                <i class="fas fa-chalkboard-teacher"></i> Prof. <%= curso.getProfesorNombre() != null ? curso.getProfesorNombre() : "No asignado" %>
                            </span>
                        </div>
                    </div>
                    
                    <div class="bg-white/10 backdrop-blur-md border border-white/20 rounded-xl p-4 min-w-[140px] text-center">
                        <span class="block text-3xl font-bold"><%= materiales != null ? materiales.size() : 0 %></span>
                        <span class="text-xs uppercase tracking-wide opacity-80">Archivos Disponibles</span>
                    </div>
                </div>
            </div>

            <div class="flex flex-col gap-4">
                <div class="flex items-center justify-between mb-2">
                    <h3 class="text-lg font-bold text-slate-800">Recursos Descargables</h3>
                </div>

                <% if (materiales != null && !materiales.isEmpty()) { 
                    for (Material mat : materiales) {
                        String nombre = mat.getNombreArchivo();
                        String ext = "";
                        int i = nombre.lastIndexOf('.');
                        if (i > 0) ext = nombre.substring(i+1).toUpperCase();
                        
                        // Configuración visual por tipo de archivo
                        String iconClass = "fa-file";
                        String iconColor = "text-gray-500";
                        String iconBg = "bg-gray-100";
                        
                        if (ext.equals("PDF")) { 
                            iconClass = "fa-file-pdf"; iconColor = "text-red-500"; iconBg = "bg-red-50"; 
                        } else if (ext.contains("DOC")) { 
                            iconClass = "fa-file-word"; iconColor = "text-blue-500"; iconBg = "bg-blue-50"; 
                        } else if (ext.contains("XLS")) { 
                            iconClass = "fa-file-excel"; iconColor = "text-green-500"; iconBg = "bg-green-50"; 
                        } else if (ext.contains("PPT")) { 
                            iconClass = "fa-file-powerpoint"; iconColor = "text-orange-500"; iconBg = "bg-orange-50"; 
                        } else if (ext.contains("ZIP") || ext.contains("RAR")) { 
                            iconClass = "fa-file-zipper"; iconColor = "text-purple-500"; iconBg = "bg-purple-50"; 
                        }
                        
                        // Formateo de tamaño seguro
                        long size = mat.getTamanioArchivo();
                        String sizeStr = (size < 1024) ? size + " B" : (size < 1048576) ? String.format("%.1f KB", size/1024.0) : String.format("%.1f MB", size/1048576.0);
                %>
                
                <div class="file-card bg-white rounded-xl p-5 flex items-center justify-between gap-4 group hover:bg-blue-50/30">
                    <div class="flex items-center gap-4 overflow-hidden w-full">
                        <div class="flex-shrink-0 <%= iconBg %> <%= iconColor %> size-12 rounded-lg flex items-center justify-center text-xl shadow-sm">
                            <i class="fas <%= iconClass %>"></i>
                        </div>
                        
                        <div class="min-w-0 flex-1">
                            <h4 class="font-bold text-slate-800 truncate text-[15px] mb-1 group-hover:text-primary transition-colors">
                                <%= mat.getNombreArchivo() %>
                            </h4>
                            <div class="flex items-center gap-3 text-xs text-slate-500">
                                <span class="bg-slate-100 px-2 py-0.5 rounded border border-slate-200 uppercase font-semibold tracking-wide text-[10px]">
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
                                <p class="text-sm text-slate-500 mt-2 line-clamp-1 flex items-center gap-1">
                                    <i class="fas fa-info-circle text-xs opacity-70"></i> <%= mat.getDescripcion() %>
                                </p>
                            <% } %>
                        </div>
                        
                        <a href="<%= request.getContextPath() %>/<%= mat.getRutaArchivo() %>" target="_blank" 
                           class="hidden sm:flex flex-shrink-0 bg-white border border-slate-200 hover:bg-primary hover:text-white hover:border-primary text-slate-600 px-4 py-2 rounded-lg font-medium text-sm items-center gap-2 transition-all shadow-sm">
                            <i class="fas fa-download"></i> Descargar
                        </a>
                    </div>
                    
                    <a href="<%= request.getContextPath() %>/<%= mat.getRutaArchivo() %>" target="_blank" 
                       class="sm:hidden flex-shrink-0 bg-gray-50 p-3 rounded-lg text-primary border border-gray-200 shadow-sm">
                        <i class="fas fa-download"></i>
                    </a>
                </div>
                <% 
                    } 
                } else { 
                %>
                
                <div class="bg-white rounded-xl border-2 border-dashed border-gray-200 p-12 text-center">
                    <div class="bg-blue-50 size-20 rounded-full flex items-center justify-center mx-auto mb-4">
                        <span class="material-symbols-outlined text-4xl text-blue-300">folder_off</span>
                    </div>
                    <h3 class="text-lg font-bold text-slate-700">Aún no hay materiales</h3>
                    <p class="text-slate-500 text-sm mt-1 max-w-md mx-auto">
                        El profesor aún no ha compartido documentos o recursos para este curso. Vuelve a consultar más tarde.
                    </p>
                </div>
                <% } %>
            </div>

        </div>
        
        <footer class="mt-auto py-6 text-center text-xs text-slate-400 border-t border-slate-100 bg-white">
            &copy; 2025 Colegio San Antonio - Todos los derechos reservados.
        </footer>
    </main>

</body>
</html>