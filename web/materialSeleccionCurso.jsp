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
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Selección de Curso - Material de Apoyo</title>
    
    <script>
        // Detectar tema ANTES de renderizar
        (function() {
            function getCookie(name) {
                const match = document.cookie.match(new RegExp('(^| )' + name + '=([^;]+)'));
                return match ? match[2] : null;
            }
            if (getCookie('theme') === 'dark') {
                document.documentElement.classList.add('dark');
            }
        })();
    </script>
    
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
        
        .course-card {
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            background-color: white;
        }
        .dark .course-card {
            background-color: #1a2233;
            border-color: #374151;
        }
        
        .course-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 30px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.05);
            border-color: #bfdbfe;
        }
        .dark .course-card:hover {
            border-color: #3b82f6;
            box-shadow: 0 15px 30px -5px rgba(0, 0, 0, 0.3);
        }
        
        .icon-container { transition: all 0.3s ease; }
        .course-card:hover .icon-container {
            transform: scale(1.1) rotate(-3deg);
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
        }
        
        /* Estilos para el mensaje de "sin cursos" en modo oscuro */
        .dark .bg-white.rounded-2xl {
            background-color: #1a2233 !important;
            border-color: #374151 !important;
        }
        .dark .bg-gray-50 {
            background-color: #283044 !important;
        }
        .dark .text-gray-300 {
            color: #6b7280 !important;
        }
        .dark .text-slate-800 {
            color: #e5e7eb !important;
        }
        .dark .text-slate-500 {
            color: #9ca3af !important;
        }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark text-gray-900 dark:text-gray-100 min-h-screen flex overflow-hidden">

    <div class="flex h-screen overflow-hidden w-full">
        <%@ include file="includes/sidebarDocente.jsp" %>

        <main class="flex-1 flex flex-col overflow-y-auto">
            
            <%-- AGREGAR EL HEADER AQUÍ --%>
            <% request.setAttribute("pageTitle", "Material de Apoyo"); %>
            <jsp:include page="includes/header.jsp" />

            <div class="p-6 md:p-8 max-w-7xl mx-auto w-full">
                
                <% if (mensaje != null) { %>
                <div class="mb-6 bg-green-50 dark:bg-green-900/30 border border-green-200 dark:border-green-800 text-green-700 dark:text-green-300 px-4 py-3 rounded-lg flex items-start gap-3 shadow-sm">
                    <i class="fas fa-check-circle mt-1"></i>
                    <div><p class="font-bold text-sm">Operación exitosa</p><p class="text-sm"><%= mensaje %></p></div>
                </div>
                <% } %>
                <% if (error != null) { %>
                <div class="mb-6 bg-red-50 dark:bg-red-900/30 border border-red-200 dark:border-red-800 text-red-700 dark:text-red-300 px-4 py-3 rounded-lg flex items-start gap-3 shadow-sm">
                    <i class="fas fa-exclamation-circle mt-1"></i>
                    <div><p class="font-bold text-sm">Error</p><p class="text-sm"><%= error %></p></div>
                </div>
                <% } %>

                <!-- Banner superior (se mantiene igual porque usa primary y blanco) -->
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
                            String colorBg = "bg-blue-50 dark:bg-blue-900/30";     
                            String colorTxt = "text-blue-600 dark:text-blue-400"; 
                            String hoverBg = "group-hover:bg-blue-600 dark:group-hover:bg-blue-600"; 
                            String badgeColor = "bg-blue-50 dark:bg-blue-900/30 text-blue-700 dark:text-blue-300 border-blue-100 dark:border-blue-800";

                            // Lógica de asignación de iconos
                            if (nombreCurso.contains("mate") || nombreCurso.contains("álgebra") || nombreCurso.contains("geom") || nombreCurso.contains("aritm")) {
                                iconClass = "fa-calculator";
                                colorBg = "bg-indigo-50 dark:bg-indigo-900/30"; colorTxt = "text-indigo-600 dark:text-indigo-400"; hoverBg = "group-hover:bg-indigo-600"; badgeColor = "bg-indigo-50 dark:bg-indigo-900/30 text-indigo-700 dark:text-indigo-300 border-indigo-100 dark:border-indigo-800";
                            } else if (nombreCurso.contains("cien") || nombreCurso.contains("biolo") || nombreCurso.contains("quím") || nombreCurso.contains("físic") || nombreCurso.contains("cta")) {
                                iconClass = "fa-flask";
                                colorBg = "bg-emerald-50 dark:bg-emerald-900/30"; colorTxt = "text-emerald-600 dark:text-emerald-400"; hoverBg = "group-hover:bg-emerald-600"; badgeColor = "bg-emerald-50 dark:bg-emerald-900/30 text-emerald-700 dark:text-emerald-300 border-emerald-100 dark:border-emerald-800";
                            } else if (nombreCurso.contains("len") || nombreCurso.contains("comu") || nombreCurso.contains("lit") || nombreCurso.contains("verb")) {
                                iconClass = "fa-feather-pointed";
                                colorBg = "bg-rose-50 dark:bg-rose-900/30"; colorTxt = "text-rose-600 dark:text-rose-400"; hoverBg = "group-hover:bg-rose-600"; badgeColor = "bg-rose-50 dark:bg-rose-900/30 text-rose-700 dark:text-rose-300 border-rose-100 dark:border-rose-800";
                            } else if (nombreCurso.contains("hist") || nombreCurso.contains("soci") || nombreCurso.contains("perso") || nombreCurso.contains("cívic")) {
                                iconClass = "fa-globe-americas";
                                colorBg = "bg-amber-50 dark:bg-amber-900/30"; colorTxt = "text-amber-600 dark:text-amber-400"; hoverBg = "group-hover:bg-amber-600"; badgeColor = "bg-amber-50 dark:bg-amber-900/30 text-amber-700 dark:text-amber-300 border-amber-100 dark:border-amber-800";
                            } else if (nombreCurso.contains("ingl") || nombreCurso.contains("english")) {
                                iconClass = "fa-language";
                                colorBg = "bg-sky-50 dark:bg-sky-900/30"; colorTxt = "text-sky-600 dark:text-sky-400"; hoverBg = "group-hover:bg-sky-600"; badgeColor = "bg-sky-50 dark:bg-sky-900/30 text-sky-700 dark:text-sky-300 border-sky-100 dark:border-sky-800";
                            } else if (nombreCurso.contains("arte") || nombreCurso.contains("música") || nombreCurso.contains("pint")) {
                                iconClass = "fa-palette";
                                colorBg = "bg-pink-50 dark:bg-pink-900/30"; colorTxt = "text-pink-600 dark:text-pink-400"; hoverBg = "group-hover:bg-pink-600"; badgeColor = "bg-pink-50 dark:bg-pink-900/30 text-pink-700 dark:text-pink-300 border-pink-100 dark:border-pink-800";
                            } else if (nombreCurso.contains("compu") || nombreCurso.contains("inform") || nombreCurso.contains("tecno")) {
                                iconClass = "fa-laptop-code";
                                colorBg = "bg-slate-100 dark:bg-slate-700"; colorTxt = "text-slate-700 dark:text-slate-300"; hoverBg = "group-hover:bg-slate-700"; badgeColor = "bg-slate-100 dark:bg-slate-700 text-slate-700 dark:text-slate-300 border-slate-200 dark:border-slate-600";
                            } else if (nombreCurso.contains("física") || nombreCurso.contains("depor")) {
                                iconClass = "fa-futbol"; 
                                colorBg = "bg-green-50 dark:bg-green-900/30"; colorTxt = "text-green-600 dark:text-green-400"; hoverBg = "group-hover:bg-green-600"; badgeColor = "bg-green-50 dark:bg-green-900/30 text-green-700 dark:text-green-300 border-green-100 dark:border-green-800";
                            } else if (nombreCurso.contains("relig") || nombreCurso.contains("dios")) {
                                iconClass = "fa-hands-praying";
                                colorBg = "bg-purple-50 dark:bg-purple-900/30"; colorTxt = "text-purple-600 dark:text-purple-400"; hoverBg = "group-hover:bg-purple-600"; badgeColor = "bg-purple-50 dark:bg-purple-900/30 text-purple-700 dark:text-purple-300 border-purple-100 dark:border-purple-800";
                            }
                        %>
                        
                        <div class="course-card rounded-2xl p-0 shadow-sm border border-gray-200 dark:border-gray-700 flex flex-col h-full overflow-hidden cursor-pointer group relative z-0"
                             onclick="location.href='MaterialServlet?accion=verMateriales&curso_id=<%= c.getId() %>'">
                            
                            <div class="p-6 flex items-start gap-5 relative">
                                <div class="icon-container <%= colorBg %> <%= colorTxt %> <%= hoverBg %> group-hover:text-white size-16 rounded-2xl flex items-center justify-center flex-shrink-0 shadow-sm">
                                    <i class="fas <%= iconClass %> text-3xl"></i>
                                </div>
                                
                                <div class="flex-1 min-w-0 pt-1">
                                    <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-2 group-hover:text-primary transition-colors truncate">
                                        <%= c.getNombre() %>
                                    </h3>
                                    <p class="text-sm text-gray-600 dark:text-gray-400 mb-3 flex items-center gap-2">
                                        <i class="fas fa-user-tie text-gray-400 dark:text-gray-500 text-xs"></i>
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
                                        <span class="size-8 rounded-full bg-red-50 dark:bg-red-900/30 border-2 border-white dark:border-gray-800 flex items-center justify-center text-red-500 dark:text-red-400 shadow-sm relative z-30"><i class="fas fa-file-pdf text-xs"></i></span>
                                        <span class="size-8 rounded-full bg-blue-50 dark:bg-blue-900/30 border-2 border-white dark:border-gray-800 flex items-center justify-center text-blue-500 dark:text-blue-400 shadow-sm relative z-20"><i class="fas fa-file-word text-xs"></i></span>
                                        <span class="size-8 rounded-full bg-orange-50 dark:bg-orange-900/30 border-2 border-white dark:border-gray-800 flex items-center justify-center text-orange-500 dark:text-orange-400 shadow-sm relative z-10"><i class="fas fa-file-powerpoint text-xs"></i></span>
                                    </div>
                                    <span class="text-xs text-gray-500 dark:text-gray-400 font-medium flex items-center gap-1">
                                        <i class="fas fa-plus-circle text-[10px]"></i> Recursos
                                    </span>
                                </div>
                            </div>

                            <div class="mt-auto bg-gray-50 dark:bg-gray-800 border-t border-gray-200 dark:border-gray-700 p-4 flex items-center justify-between transition-colors duration-300 relative z-10 group-hover:bg-primary group-hover:border-primary">
                                
                                <span class="text-xs font-bold text-gray-600 dark:text-gray-300 group-hover:text-white uppercase tracking-wide flex items-center gap-2">
                                    <i class="fas fa-cog opacity-70 group-hover:text-white"></i> Gestionar Recursos
                                </span>
                                
                                <div class="size-9 rounded-full bg-white dark:bg-gray-700 border border-gray-200 dark:border-gray-600 flex items-center justify-center text-gray-400 dark:text-gray-300 group-hover:bg-white group-hover:text-primary group-hover:border-white transition-all shadow-sm">
                                    <i class="fas fa-arrow-right-long text-sm"></i>
                                </div>
                            </div>
                        </div>
                        <% } %>
                    </div>
                <% } else { %>
                    <div class="bg-white dark:bg-gray-800 rounded-2xl border-2 border-dashed border-gray-200 dark:border-gray-700 p-16 text-center max-w-lg mx-auto mt-8">
                        <div class="bg-gray-50 dark:bg-gray-700 size-24 rounded-full flex items-center justify-center mx-auto mb-6 shadow-sm">
                            <i class="fas fa-folder-open text-5xl text-gray-300 dark:text-gray-500"></i>
                        </div>
                        <h3 class="text-xl font-bold text-gray-800 dark:text-gray-200 mb-2 flex items-center justify-center gap-2">
                            <i class="fas fa-exclamation-circle text-yellow-500"></i> Sin cursos asignados
                        </h3>
                        <p class="text-gray-500 dark:text-gray-400 mb-8">
                            No se encontraron cursos activos para tu usuario en este momento.
                        </p>
                        <a href="docenteDashboard.jsp" class="inline-flex items-center gap-2 bg-gray-800 dark:bg-primary hover:bg-gray-700 dark:hover:bg-primary-dark text-white px-6 py-3 rounded-xl font-medium transition-all shadow hover:shadow-md">
                            <i class="fas fa-arrow-left"></i>
                            Volver al Inicio
                        </a>
                    </div>
                <% } %>

            </div>
        </main>
    </div>

</body>
</html>