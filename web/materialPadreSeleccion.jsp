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
    
    <!-- INCLUIR HEAD.JSP CON TODAS LAS CONFIGURACIONES -->
    <jsp:include page="includes/head.jsp" />
    
    <style>
        .course-card {
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }
        .course-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 30px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.05);
            border-color: #bfdbfe;
        }
        .dark .course-card:hover {
            border-color: #1e3a8a;
            box-shadow: 0 15px 30px -5px rgba(0, 0, 0, 0.3), 0 8px 10px -6px rgba(0, 0, 0, 0.2);
        }
        
        .icon-container { transition: all 0.3s ease; }
        .course-card:hover .icon-container {
            transform: scale(1.1) rotate(-3deg);
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
                        
                        // Variables de color (Colores suaves para diferenciar materias)
                        String colorBg = "bg-blue-50";     
                        String colorTxt = "text-blue-600"; 
                        
                        // Versiones dark de los colores
                        String darkColorBg = "dark:bg-blue-900/30";
                        String darkColorTxt = "dark:text-blue-400";
                        
                        // Asignación de iconos y colores según materia
                        if (nombreCurso.contains("mate") || nombreCurso.contains("álgebra") || nombreCurso.contains("geom") || nombreCurso.contains("aritm")) {
                            iconClass = "fa-calculator"; 
                            colorBg = "bg-indigo-50"; colorTxt = "text-indigo-600";
                            darkColorBg = "dark:bg-indigo-900/30"; darkColorTxt = "dark:text-indigo-400";
                        } else if (nombreCurso.contains("cien") || nombreCurso.contains("biolo") || nombreCurso.contains("quím") || nombreCurso.contains("físic") || nombreCurso.contains("cta")) {
                            iconClass = "fa-flask"; 
                            colorBg = "bg-emerald-50"; colorTxt = "text-emerald-600";
                            darkColorBg = "dark:bg-emerald-900/30"; darkColorTxt = "dark:text-emerald-400";
                        } else if (nombreCurso.contains("len") || nombreCurso.contains("comu") || nombreCurso.contains("lit")) {
                            iconClass = "fa-feather-pointed"; 
                            colorBg = "bg-rose-50"; colorTxt = "text-rose-600";
                            darkColorBg = "dark:bg-rose-900/30"; darkColorTxt = "dark:text-rose-400";
                        } else if (nombreCurso.contains("hist") || nombreCurso.contains("soci") || nombreCurso.contains("perso")) {
                            iconClass = "fa-globe-americas"; 
                            colorBg = "bg-amber-50"; colorTxt = "text-amber-600";
                            darkColorBg = "dark:bg-amber-900/30"; darkColorTxt = "dark:text-amber-400";
                        } else if (nombreCurso.contains("ingl") || nombreCurso.contains("english")) {
                            iconClass = "fa-language"; 
                            colorBg = "bg-sky-50"; colorTxt = "text-sky-600";
                            darkColorBg = "dark:bg-sky-900/30"; darkColorTxt = "dark:text-sky-400";
                        } else if (nombreCurso.contains("arte") || nombreCurso.contains("música")) {
                            iconClass = "fa-palette"; 
                            colorBg = "bg-pink-50"; colorTxt = "text-pink-600";
                            darkColorBg = "dark:bg-pink-900/30"; darkColorTxt = "dark:text-pink-400";
                        } else if (nombreCurso.contains("compu") || nombreCurso.contains("inform")) {
                            iconClass = "fa-laptop-code"; 
                            colorBg = "bg-slate-100"; colorTxt = "text-slate-700";
                            darkColorBg = "dark:bg-slate-800"; darkColorTxt = "dark:text-slate-300";
                        } else if (nombreCurso.contains("física") || nombreCurso.contains("depor")) {
                            iconClass = "fa-futbol"; 
                            colorBg = "bg-green-50"; colorTxt = "text-green-600";
                            darkColorBg = "dark:bg-green-900/30"; darkColorTxt = "dark:text-green-400";
                        } else if (nombreCurso.contains("relig") || nombreCurso.contains("dios")) {
                            iconClass = "fa-hands-praying"; 
                            colorBg = "bg-purple-50"; colorTxt = "text-purple-600";
                            darkColorBg = "dark:bg-purple-900/30"; darkColorTxt = "dark:text-purple-400";
                        }
                    %>
                    
                    <!-- Tarjeta de curso - CON DARK MODE -->
                    <div class="course-card bg-white dark:bg-card-dark rounded-2xl p-0 shadow-sm border border-gray-200 dark:border-border-dark flex flex-col h-full overflow-hidden cursor-pointer group relative z-0"
                         onclick="location.href='MaterialPadreServlet?accion=verMateriales&curso_id=<%= c.getId() %>'">
                        
                        <div class="p-6 flex items-start gap-5 relative">
                            <div class="icon-container <%= colorBg %> <%= colorTxt %> <%= darkColorBg %> <%= darkColorTxt %> group-hover:text-white dark:group-hover:text-white size-16 rounded-2xl flex items-center justify-center flex-shrink-0 shadow-sm transition-all duration-300">
                                <i class="fas <%= iconClass %> text-3xl"></i>
                            </div>
                            
                            <div class="flex-1 min-w-0 pt-1">
                                <h3 class="text-lg font-bold text-slate-800 dark:text-white mb-2 group-hover:text-primary dark:group-hover:text-blue-400 transition-colors truncate">
                                    <%= c.getNombre() %>
                                </h3>
                                <p class="text-sm text-slate-500 dark:text-slate-400 mb-3 flex items-center gap-2">
                                    <i class="fas fa-chalkboard-teacher text-slate-400 dark:text-slate-500 text-xs"></i>
                                    <span>Prof. <%= c.getProfesorNombre() != null ? c.getProfesorNombre() : "Asignado" %></span>
                                </p>
                                
                                <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold bg-slate-50 dark:bg-slate-800 text-slate-600 dark:text-slate-300 border border-slate-200 dark:border-border-dark">
                                    <i class="fas fa-layer-group opacity-70"></i>
                                    <%= c.getGradoNombre() %>
                                </span>
                            </div>
                        </div>

                        <!-- Iconos de formato - CON DARK MODE -->
                        <div class="px-6 pb-4 relative z-10">
                            <div class="flex items-center gap-3 pl-1">
                                <div class="flex -space-x-2">
                                    <span class="size-8 rounded-full bg-white dark:bg-card-dark border-2 border-slate-100 dark:border-border-dark flex items-center justify-center text-red-500 shadow-sm relative z-30"><i class="fas fa-file-pdf text-xs"></i></span>
                                    <span class="size-8 rounded-full bg-white dark:bg-card-dark border-2 border-slate-100 dark:border-border-dark flex items-center justify-center text-blue-500 shadow-sm relative z-20"><i class="fas fa-file-word text-xs"></i></span>
                                    <span class="size-8 rounded-full bg-white dark:bg-card-dark border-2 border-slate-100 dark:border-border-dark flex items-center justify-center text-orange-500 shadow-sm relative z-10"><i class="fas fa-file-powerpoint text-xs"></i></span>
                                </div>
                                <span class="text-xs text-slate-400 dark:text-slate-500 font-medium flex items-center gap-1">
                                    <i class="fas fa-download text-[10px]"></i> Recursos disponibles
                                </span>
                            </div>
                        </div>

                        <!-- Footer de la tarjeta - CON DARK MODE -->
                        <div class="mt-auto bg-gray-50 dark:bg-gray-800/50 border-t border-gray-200 dark:border-border-dark p-4 flex items-center justify-between transition-colors duration-300 relative z-10 group-hover:bg-primary dark:group-hover:bg-primary group-hover:border-primary dark:group-hover:border-primary">
                            
                            <span class="text-xs font-bold text-slate-500 dark:text-slate-400 group-hover:text-white dark:group-hover:text-white uppercase tracking-wide flex items-center gap-2">
                                <i class="fas fa-eye opacity-70 group-hover:text-white dark:group-hover:text-white"></i> Ver Materiales
                            </span>
                            
                            <div class="size-9 rounded-full bg-white dark:bg-card-dark border border-gray-200 dark:border-border-dark flex items-center justify-center text-slate-400 dark:text-slate-500 group-hover:bg-white dark:group-hover:bg-card-dark group-hover:text-primary dark:group-hover:text-primary group-hover:border-white dark:group-hover:border-primary transition-all shadow-sm">
                                <i class="fas fa-arrow-right text-sm"></i>
                            </div>
                        </div>
                    </div>
                    <% } %>
                </div>
            <% } else { %>
                <!-- Mensaje sin cursos - CON DARK MODE -->
                <div class="bg-white dark:bg-card-dark rounded-2xl border-2 border-dashed border-gray-200 dark:border-border-dark p-16 text-center max-w-lg mx-auto mt-8">
                    <div class="bg-gray-50 dark:bg-gray-800 size-24 rounded-full flex items-center justify-center mx-auto mb-6 shadow-sm">
                        <i class="fas fa-folder-open text-5xl text-gray-300 dark:text-gray-600"></i>
                    </div>
                    <h3 class="text-xl font-bold text-slate-800 dark:text-white mb-2">No se encontraron cursos</h3>
                    <p class="text-slate-500 dark:text-slate-400 mb-6">
                        Parece que no hay cursos asignados o materiales disponibles en este momento.
                    </p>
                    <a href="padreDashboard.jsp" class="inline-flex items-center gap-2 bg-slate-800 dark:bg-slate-700 hover:bg-slate-700 dark:hover:bg-slate-600 text-white px-6 py-3 rounded-xl font-medium transition-all shadow hover:shadow-md">
                        <i class="fas fa-arrow-left"></i>
                        Volver al Inicio
                    </a>
                </div>
            <% } %>

        </div>
        
        <!-- Footer - CON DARK MODE -->
        <footer class="mt-auto py-6 text-center text-xs text-slate-400 dark:text-slate-500 border-t border-slate-100 dark:border-border-dark bg-white dark:bg-card-dark">
            &copy; 2025 Colegio San Antonio - Todos los derechos reservados.
        </footer>
    </main>

</body>
</html>