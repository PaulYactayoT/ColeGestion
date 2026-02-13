<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Padre, modelo.PadreDAO, modelo.Curso, java.util.List" %>

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
    
    // Obtener cursos
    List<Curso> cursos = (List<Curso>) request.getAttribute("cursos");
%>

<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Material de Estudio - San Antonio</title>
    
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
        }
        .course-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 30px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.05);
            border-color: #bfdbfe;
        }
        
        .icon-container { transition: all 0.3s ease; }
        .course-card:hover .icon-container {
            transform: scale(1.1) rotate(-3deg);
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
            <div class="flex items-center gap-3">
                <a href="padreDashboard.jsp" class="md:hidden p-2 text-slate-400 hover:bg-slate-50 rounded-lg">
                    <span class="material-symbols-outlined">menu</span>
                </a>
                <div class="flex items-center gap-2 text-slate-800">
                    <span class="material-symbols-outlined text-primary text-2xl">folder_managed</span>
                    <h1 class="text-xl font-bold">Material de Estudio</h1>
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
                <div class="absolute top-0 right-0 -mt-8 -mr-8 w-40 h-40 bg-white/20 rounded-full blur-2xl"></div>
                
                <div class="relative z-10">
                    <h2 class="text-2xl font-bold flex items-center gap-2">
                        <i class="fas fa-book-reader opacity-70"></i>
                        Repositorio de Recursos
                    </h2>
                    <p class="text-blue-100 text-sm font-medium mt-1">
                        Accede a las guías, diapositivas y documentos compartidos por los docentes para <%= padre.getAlumnoNombre() %>.
                    </p>
                </div>
            </div>

            <% if (cursos != null && !cursos.isEmpty()) { %>
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-3 gap-6">
                    <% for (Curso c : cursos) { 
                        
                        // Lógica de Iconos
                        String nombreCurso = c.getNombre().toLowerCase();
                        String iconClass = "fa-book-open"; 
                        
                        // Variables de color (Colores suaves para diferenciar materias, pero hover azul)
                        String colorBg = "bg-blue-50";     
                        String colorTxt = "text-blue-600"; 
                        
                        // NOTA: Mantenemos el hover en azul para uniformidad
                        String hoverBg = "group-hover:bg-primary";
                        
                        // Asignación de iconos
                        if (nombreCurso.contains("mate") || nombreCurso.contains("álgebra") || nombreCurso.contains("geom") || nombreCurso.contains("aritm")) {
                            iconClass = "fa-calculator"; colorBg = "bg-indigo-50"; colorTxt = "text-indigo-600";
                        } else if (nombreCurso.contains("cien") || nombreCurso.contains("biolo") || nombreCurso.contains("quím") || nombreCurso.contains("físic") || nombreCurso.contains("cta")) {
                            iconClass = "fa-flask"; colorBg = "bg-emerald-50"; colorTxt = "text-emerald-600";
                        } else if (nombreCurso.contains("len") || nombreCurso.contains("comu") || nombreCurso.contains("lit")) {
                            iconClass = "fa-feather-pointed"; colorBg = "bg-rose-50"; colorTxt = "text-rose-600";
                        } else if (nombreCurso.contains("hist") || nombreCurso.contains("soci") || nombreCurso.contains("perso")) {
                            iconClass = "fa-globe-americas"; colorBg = "bg-amber-50"; colorTxt = "text-amber-600";
                        } else if (nombreCurso.contains("ingl") || nombreCurso.contains("english")) {
                            iconClass = "fa-language"; colorBg = "bg-sky-50"; colorTxt = "text-sky-600";
                        } else if (nombreCurso.contains("arte") || nombreCurso.contains("música")) {
                            iconClass = "fa-palette"; colorBg = "bg-pink-50"; colorTxt = "text-pink-600";
                        } else if (nombreCurso.contains("compu") || nombreCurso.contains("inform")) {
                            iconClass = "fa-laptop-code"; colorBg = "bg-slate-100"; colorTxt = "text-slate-700";
                        } else if (nombreCurso.contains("física") || nombreCurso.contains("depor")) {
                            iconClass = "fa-futbol"; colorBg = "bg-green-50"; colorTxt = "text-green-600";
                        } else if (nombreCurso.contains("relig") || nombreCurso.contains("dios")) {
                            iconClass = "fa-hands-praying"; colorBg = "bg-purple-50"; colorTxt = "text-purple-600";
                        }
                    %>
                    
                    <div class="course-card bg-white rounded-2xl p-0 shadow-sm border border-gray-100 flex flex-col h-full overflow-hidden cursor-pointer group relative z-0"
                         onclick="location.href='MaterialPadreServlet?accion=verMateriales&curso_id=<%= c.getId() %>'">
                        
                        <div class="p-6 flex items-start gap-5 relative">
                            <div class="icon-container <%= colorBg %> <%= colorTxt %> <%= hoverBg %> group-hover:text-white size-16 rounded-2xl flex items-center justify-center flex-shrink-0 shadow-sm">
                                <i class="fas <%= iconClass %> text-3xl"></i>
                            </div>
                            
                            <div class="flex-1 min-w-0 pt-1">
                                <h3 class="text-lg font-bold text-slate-800 mb-2 group-hover:text-primary transition-colors truncate">
                                    <%= c.getNombre() %>
                                </h3>
                                <p class="text-sm text-slate-500 mb-3 flex items-center gap-2">
                                    <i class="fas fa-chalkboard-teacher text-slate-400 text-xs"></i>
                                    <span>Prof. <%= c.getProfesorNombre() != null ? c.getProfesorNombre() : "Asignado" %></span>
                                </p>
                                
                                <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold bg-slate-50 text-slate-600 border border-slate-200">
                                    <i class="fas fa-layer-group opacity-70"></i>
                                    <%= c.getGradoNombre() %>
                                </span>
                            </div>
                        </div>

                        <div class="px-6 pb-4 relative z-10">
                            <div class="flex items-center gap-3 pl-1">
                                <div class="flex -space-x-2">
                                    <span class="size-8 rounded-full bg-white border-2 border-slate-100 flex items-center justify-center text-red-500 shadow-sm relative z-30"><i class="fas fa-file-pdf text-xs"></i></span>
                                    <span class="size-8 rounded-full bg-white border-2 border-slate-100 flex items-center justify-center text-blue-500 shadow-sm relative z-20"><i class="fas fa-file-word text-xs"></i></span>
                                    <span class="size-8 rounded-full bg-white border-2 border-slate-100 flex items-center justify-center text-orange-500 shadow-sm relative z-10"><i class="fas fa-file-powerpoint text-xs"></i></span>
                                </div>
                                <span class="text-xs text-slate-400 font-medium flex items-center gap-1">
                                    <i class="fas fa-download text-[10px]"></i> Recursos disponibles
                                </span>
                            </div>
                        </div>

                        <div class="mt-auto bg-gray-50 border-t border-gray-100 p-4 flex items-center justify-between transition-colors duration-300 relative z-10 group-hover:bg-primary group-hover:border-primary">
                            
                            <span class="text-xs font-bold text-slate-500 group-hover:text-white uppercase tracking-wide flex items-center gap-2">
                                <i class="fas fa-eye opacity-70 group-hover:text-white"></i> Ver Materiales
                            </span>
                            
                            <div class="size-9 rounded-full bg-white border border-gray-200 flex items-center justify-center text-slate-400 group-hover:bg-white group-hover:text-primary group-hover:border-white transition-all shadow-sm">
                                <i class="fas fa-arrow-right text-sm"></i>
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
                    <h3 class="text-xl font-bold text-slate-800 mb-2">No se encontraron cursos</h3>
                    <p class="text-slate-500 mb-6">
                        Parece que no hay cursos asignados o materiales disponibles en este momento.
                    </p>
                    <a href="padreDashboard.jsp" class="inline-flex items-center gap-2 bg-slate-800 hover:bg-slate-700 text-white px-6 py-3 rounded-xl font-medium transition-all shadow hover:shadow-md">
                        <i class="fas fa-arrow-left"></i>
                        Volver al Inicio
                    </a>
                </div>
            <% } %>

        </div>
        
        <footer class="mt-auto py-6 text-center text-xs text-slate-400 border-t border-slate-100 bg-white">
            &copy; 2025 Colegio San Antonio - Todos los derechos reservados.
        </footer>
    </main>

</body>
</html>