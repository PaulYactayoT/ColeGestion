<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, modelo.Curso, modelo.Profesor" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    Profesor docente = (Profesor) session.getAttribute("docente");
    if (docente == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    List<Curso> cursos = (List<Curso>) request.getAttribute("cursos");
    
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
    <title>Selección de Curso - Material de Apoyo</title>
    
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
                    },
                    fontFamily: { "display": ["Lexend"] },
                },
            },
        }
    </script>
    
    <style>
        body { font-family: 'Lexend', sans-serif; }
        .material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24; }
        
        .course-card {
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }
        .course-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 30px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.05);
            border-color: #bfdbfe;
        }
        
        .icon-container { transition: all 0.3s ease; }
        .course-card:hover .icon-container {
            transform: scale(1.1) rotate(-3deg);
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
        }
    </style>
</head>
<body class="bg-background-light text-slate-800 min-h-screen flex overflow-hidden">

    <aside class="w-64 bg-white border-r border-gray-200 hidden md:flex flex-col justify-between z-20 flex-shrink-0">
        <div class="p-6">
            <div class="flex items-center gap-3 mb-8">
                <div class="bg-primary size-10 rounded-lg flex items-center justify-center text-white shadow-md">
                    <span class="material-symbols-outlined">school</span>
                </div>
                <div>
                    <h1 class="text-lg font-bold leading-tight text-slate-900">San Antonio</h1>
                    <p class="text-xs text-slate-500 font-medium">Panel Docente</p>
                </div>
            </div>
            
            <nav class="flex flex-col gap-2" aria-label="Navegación principal">
            <a class="flex items-center gap-3 px-3 py-2 rounded-lg text-slate-600 hover:bg-slate-50 transition-colors" 
               href="DocenteDashboardServlet">
                <span class="material-symbols-outlined">dashboard</span>
                <span class="text-sm">Dashboard</span>
            </a>
            <a class="flex items-center gap-3 px-3 py-2 rounded-lg text-slate-600 hover:bg-slate-50 transition-colors" 
               href="AsistenciaServlet?accion=registrar">
                <i class="fas fa-clipboard-check"></i>
                <span class="text-sm">Asistencias</span>
            </a>
            <a class="flex items-center gap-3 px-3 py-2 rounded-lg text-slate-600 hover:bg-slate-50 transition-colors" 
               href="revisarJustificaciones.jsp">
                <i class="fas fa-clock"></i>
                <span class="text-sm">Justificaciones</span>
            </a>
            <a class="flex items-center gap-3 px-3 py-2 rounded-lg bg-primary/10 text-primary font-medium" 
               href="MaterialServlet?accion=seleccionarCurso"
               aria-current="page">
                <i class="fas fa-folder"></i>
                <span class="text-sm">Material de Apoyo</span>
            </a>
            <a class="flex items-center gap-3 px-3 py-2 rounded-lg text-slate-600 hover:bg-slate-50 transition-colors" 
               href="DisponibilidadServlet">
                <span class="material-symbols-outlined text-[20px]">event_available</span>
                <span class="text-sm">Mi Disponibilidad</span>
            </a>
        </nav>
        </div>
        
        <div class="p-4 border-t border-gray-100">
            <a href="LogoutServlet" class="flex items-center justify-center gap-2 w-full py-2.5 border border-slate-200 rounded-lg text-sm font-medium text-slate-600 hover:bg-red-50 hover:text-red-600 hover:border-red-200 transition-all">
                <span class="material-symbols-outlined text-[18px]">logout</span>
                Cerrar Sesión
            </a>
        </div>
    </aside>

    <main class="flex-1 flex flex-col h-screen overflow-y-auto relative w-full">
        
        <header class="bg-white border-b border-gray-200 sticky top-0 z-10 px-8 py-3 flex justify-between items-center">
            <div class="flex items-center gap-2">
                <span class="material-symbols-outlined text-primary text-2xl">folder_managed</span>
                <h2 class="text-xl font-bold text-slate-800">Gestión de Materiales</h2>
            </div>
            
            <div class="flex items-center gap-4">
                <button class="p-2 text-slate-400 hover:bg-slate-50 rounded-full relative transition-colors">
                    <span class="material-symbols-outlined">notifications</span>
                    <span class="absolute top-2 right-2 size-2 bg-red-500 rounded-full border-2 border-white"></span>
                </button>
                <div class="h-8 w-[1px] bg-slate-200 mx-2 hidden md:block"></div>
                <div class="flex items-center gap-4">
                <div class="hidden md:flex flex-col items-end">
                    <span class="text-sm font-semibold text-slate-700"><%= docente.getNombres() %> <%= docente.getApellidos() %></span>
                    <span class="text-xs text-slate-500 flex items-center gap-1">
                    </span>
                </div>

                <% if (docente.getFoto() != null && !docente.getFoto().isEmpty()) { %>
                    <div class="size-10 rounded-full bg-cover bg-center border-2 border-primary/20 shadow-sm" 
                         style="background-image: url('uploads/<%= docente.getFoto() %>');"></div>
                <% } else { %>
                    <div class="size-10 rounded-full bg-primary/10 border-2 border-primary/20 flex items-center justify-center text-primary font-bold shadow-sm">
                        <%= docente.getNombres().substring(0,1) %><%= docente.getApellidos().substring(0,1) %>
                    </div>
                <% } %>
            </div>
            </div>
        </header>

        <div class="p-6 md:p-8 max-w-7xl mx-auto w-full">
            
            <% if (mensaje != null) { %>
            <div class="mb-6 bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-lg flex items-start gap-3 shadow-sm animate-bounce-short">
                <i class="fas fa-check-circle mt-1"></i>
                <div><p class="font-bold text-sm">Operación exitosa</p><p class="text-sm"><%= mensaje %></p></div>
            </div>
            <% } %>
            <% if (error != null) { %>
            <div class="mb-6 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg flex items-start gap-3 shadow-sm">
                <i class="fas fa-exclamation-circle mt-1"></i>
                <div><p class="font-bold text-sm">Error</p><p class="text-sm"><%= error %></p></div>
            </div>
            <% } %>

            <div class="bg-gradient-to-r from-primary to-blue-600 rounded-2xl p-8 text-white shadow-lg mb-10 relative overflow-hidden">
                <div class="absolute top-0 right-0 -mt-10 -mr-10 w-64 h-64 bg-white/10 rounded-full blur-3xl"></div>
                <div class="absolute bottom-0 left-10 w-32 h-32 bg-white/10 rounded-full blur-2xl"></div>

                <div class="relative z-10">
                    <div class="flex items-center gap-3 mb-3 opacity-90">
                        <span class="material-symbols-outlined icon-filled">library_books</span>
                        <span class="text-sm font-medium uppercase tracking-wider">Repositorio Académico</span>
                    </div>
                    <h1 class="text-3xl md:text-4xl font-bold mb-3 flex items-center gap-3">
                        Material de Apoyo
                        <i class="fas fa-book-reader text-blue-200 opacity-50 text-2xl"></i>
                    </h1>
                    <p class="text-blue-100 max-w-2xl text-lg font-light leading-relaxed flex items-center gap-2">
                        <span class="material-symbols-outlined text-xl">info</span>
                        Selecciona un curso para gestionar recursos, subir documentos y compartir material educativo.
                    </p>
                </div>
            </div>

            <% if (cursos != null && !cursos.isEmpty()) { %>
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    <% for (Curso c : cursos) { 
                        
                        String nombreCurso = c.getNombre().toLowerCase();
                        String iconClass = "fa-book-open"; 
                        
                        // Configuración de Colores de los Iconos
                        String colorBg = "bg-blue-50";     
                        String colorTxt = "text-blue-600"; 
                        String hoverBg = "group-hover:bg-blue-600"; 
                        String badgeColor = "bg-blue-50 text-blue-700 border-blue-100";

                        // Lógica de asignación de iconos (igual que antes)
                        if (nombreCurso.contains("mate") || nombreCurso.contains("álgebra") || nombreCurso.contains("geom") || nombreCurso.contains("aritm")) {
                            iconClass = "fa-calculator";
                            colorBg = "bg-indigo-50"; colorTxt = "text-indigo-600"; hoverBg = "group-hover:bg-indigo-600"; badgeColor = "bg-indigo-50 text-indigo-700 border-indigo-100";
                        } else if (nombreCurso.contains("cien") || nombreCurso.contains("biolo") || nombreCurso.contains("quím") || nombreCurso.contains("físic") || nombreCurso.contains("cta")) {
                            iconClass = "fa-flask";
                            colorBg = "bg-emerald-50"; colorTxt = "text-emerald-600"; hoverBg = "group-hover:bg-emerald-600"; badgeColor = "bg-emerald-50 text-emerald-700 border-emerald-100";
                        } else if (nombreCurso.contains("len") || nombreCurso.contains("comu") || nombreCurso.contains("lit") || nombreCurso.contains("verb")) {
                            iconClass = "fa-feather-pointed";
                            colorBg = "bg-rose-50"; colorTxt = "text-rose-600"; hoverBg = "group-hover:bg-rose-600"; badgeColor = "bg-rose-50 text-rose-700 border-rose-100";
                        } else if (nombreCurso.contains("hist") || nombreCurso.contains("soci") || nombreCurso.contains("perso") || nombreCurso.contains("cívic")) {
                            iconClass = "fa-globe-americas";
                            colorBg = "bg-amber-50"; colorTxt = "text-amber-600"; hoverBg = "group-hover:bg-amber-600"; badgeColor = "bg-amber-50 text-amber-700 border-amber-100";
                        } else if (nombreCurso.contains("ingl") || nombreCurso.contains("english")) {
                            iconClass = "fa-language";
                            colorBg = "bg-sky-50"; colorTxt = "text-sky-600"; hoverBg = "group-hover:bg-sky-600"; badgeColor = "bg-sky-50 text-sky-700 border-sky-100";
                        } else if (nombreCurso.contains("arte") || nombreCurso.contains("música") || nombreCurso.contains("pint")) {
                            iconClass = "fa-palette";
                            colorBg = "bg-pink-50"; colorTxt = "text-pink-600"; hoverBg = "group-hover:bg-pink-600"; badgeColor = "bg-pink-50 text-pink-700 border-pink-100";
                        } else if (nombreCurso.contains("compu") || nombreCurso.contains("inform") || nombreCurso.contains("tecno")) {
                            iconClass = "fa-laptop-code";
                            colorBg = "bg-slate-100"; colorTxt = "text-slate-700"; hoverBg = "group-hover:bg-slate-700"; badgeColor = "bg-slate-100 text-slate-700 border-slate-200";
                        } else if (nombreCurso.contains("física") || nombreCurso.contains("depor")) {
                            iconClass = "fa-futbol"; 
                            colorBg = "bg-green-50"; colorTxt = "text-green-600"; hoverBg = "group-hover:bg-green-600"; badgeColor = "bg-green-50 text-green-700 border-green-100";
                        } else if (nombreCurso.contains("relig") || nombreCurso.contains("dios")) {
                            iconClass = "fa-hands-praying";
                            colorBg = "bg-purple-50"; colorTxt = "text-purple-600"; hoverBg = "group-hover:bg-purple-600"; badgeColor = "bg-purple-50 text-purple-700 border-purple-100";
                        }
                    %>
                    
                    <div class="course-card bg-white rounded-2xl p-0 shadow-sm border border-gray-100 flex flex-col h-full overflow-hidden cursor-pointer group relative z-0"
                         onclick="location.href='MaterialServlet?accion=verMateriales&curso_id=<%= c.getId() %>'">
                        
                        <div class="p-6 flex items-start gap-5 relative">
                            <div class="icon-container <%= colorBg %> <%= colorTxt %> <%= hoverBg %> group-hover:text-white size-16 rounded-2xl flex items-center justify-center flex-shrink-0 shadow-sm">
                                <i class="fas <%= iconClass %> text-3xl"></i>
                            </div>
                            
                            <div class="flex-1 min-w-0 pt-1">
                                <h3 class="text-lg font-bold text-slate-800 mb-2 group-hover:text-primary transition-colors truncate">
                                    <%= c.getNombre() %>
                                </h3>
                                <p class="text-sm text-slate-500 mb-3 flex items-center gap-2">
                                    <i class="fas fa-user-tie text-slate-400 text-xs"></i>
                                    <span>Prof. <%= docente.getNombres() %></span>
                                </p>
                                <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold border <%= badgeColor %>">
                                    <i class="fas fa-graduation-cap opacity-70"></i>
                                    <%= c.getGradoNombre() %>
                                </span>
                            </div>
                        </div>

                        <div class="px-6 pb-4 relative z-10">
                            <div class="flex items-center gap-3 pl-1">
                                <div class="flex -space-x-2">
                                    <span class="size-8 rounded-full bg-red-50 border-2 border-white flex items-center justify-center text-red-500 shadow-sm relative z-30"><i class="fas fa-file-pdf text-xs"></i></span>
                                    <span class="size-8 rounded-full bg-blue-50 border-2 border-white flex items-center justify-center text-blue-500 shadow-sm relative z-20"><i class="fas fa-file-word text-xs"></i></span>
                                    <span class="size-8 rounded-full bg-orange-50 border-2 border-white flex items-center justify-center text-orange-500 shadow-sm relative z-10"><i class="fas fa-file-powerpoint text-xs"></i></span>
                                </div>
                                <span class="text-xs text-slate-400 font-medium flex items-center gap-1">
                                    <i class="fas fa-plus-circle text-[10px]"></i> Recursos
                                </span>
                            </div>
                        </div>

                        <div class="mt-auto bg-gray-50 border-t border-gray-100 p-4 flex items-center justify-between transition-colors duration-300 relative z-10 group-hover:bg-primary group-hover:border-primary">
                            
                            <span class="text-xs font-bold text-slate-500 group-hover:text-white uppercase tracking-wide flex items-center gap-2">
                                <i class="fas fa-cog opacity-70 group-hover:text-white"></i> Gestionar Recursos
                            </span>
                            
                            <div class="size-9 rounded-full bg-white border border-gray-200 flex items-center justify-center text-slate-400 group-hover:bg-white group-hover:text-primary group-hover:border-white transition-all shadow-sm">
                                <i class="fas fa-arrow-right-long text-sm"></i>
                            </div>
                        </div>
                    </div>
                    <% } %>
                </div>
            <% } else { %>
                <div class="bg-white rounded-2xl border-2 border-dashed border-gray-200 p-16 text-center max-w-lg mx-auto mt-8">
                    <div class="bg-gray-50 size-24 rounded-full flex items-center justify-center mx-auto mb-6 shadow-sm">
                        <i class="fas fa-folder-open text-5xl text-gray-300"></i>
                    </div>
                    <h3 class="text-xl font-bold text-slate-800 mb-2 flex items-center justify-center gap-2">
                        <i class="fas fa-exclamation-circle text-yellow-500"></i> Sin cursos asignados
                    </h3>
                    <p class="text-slate-500 mb-8">
                        No se encontraron cursos activos para tu usuario en este momento.
                    </p>
                    <a href="docenteDashboard.jsp" class="inline-flex items-center gap-2 bg-slate-800 hover:bg-slate-700 text-white px-6 py-3 rounded-xl font-medium transition-all shadow hover:shadow-md">
                        <i class="fas fa-arrow-left"></i>
                        Volver al Inicio
                    </a>
                </div>
            <% } %>

        </div>
    </main>

</body>
</html>