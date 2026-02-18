<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Padre, modelo.PadreDAO, modelo.ImageDAO, modelo.Imagen, java.util.List, java.util.ArrayList" %>

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
    
    // --- 2. OBTENCIÓN DE IMÁGENES ---
    List<Imagen> imagenes = new ArrayList<>();
    if (tieneAlumno) {
        ImageDAO imageDAO = new ImageDAO();
        List<Imagen> resultados = imageDAO.listarPorAlumno(alumnoId);
        if (resultados != null) {
            imagenes = resultados;
        }
    }
%>

<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Álbum de Fotos - San Antonio</title>
    
    <!-- INCLUIR HEAD.JSP CON TODAS LAS CONFIGURACIONES -->
    <jsp:include page="includes/head.jsp" />
    
    <style>
        .dark .group:hover .dark\:bg-card-dark {
            background-color: #1a2233;
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
                <div class="absolute top-0 right-0 -mt-8 -mr-8 w-40 h-40 bg-white/10 rounded-full blur-3xl"></div>
                
                <div class="relative z-10">
                    <h2 class="text-2xl font-bold flex items-center gap-2">
                        <i class="fas fa-images opacity-70"></i>
                        Galería de Recuerdos
                    </h2>
                    <p class="text-blue-100 text-sm font-medium mt-1">
                        Momentos especiales y actividades de <%= padre.getAlumnoNombre() %> en el colegio.
                    </p>
                </div>

                <div class="relative z-10 flex gap-2">
                    <a href="uploadImage.jsp" class="bg-white text-primary hover:bg-blue-50 px-5 py-2.5 rounded-lg font-bold text-sm flex items-center gap-2 shadow-sm transition-all dark:bg-card-dark dark:text-white dark:hover:bg-gray-800">
                        <i class="fas fa-cloud-upload-alt"></i> Subir Foto
                    </a>
                </div>
            </div>

            <% if (!imagenes.isEmpty()) { %>
                <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
                    <% for (Imagen img : imagenes) { %>
                    
                    <div class="relative group bg-white dark:bg-card-dark rounded-xl shadow-sm hover:shadow-lg transition-all duration-300 overflow-hidden border border-gray-200 dark:border-border-dark h-64">
                        
                        <img src="<%= img.getRuta() %>" alt="Foto escolar" class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-110">
                        
                        <div class="absolute inset-0 bg-gradient-to-t from-black/70 via-black/20 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex flex-col justify-end p-4">
                            
                            <div class="flex justify-between items-center">
                                <a href="<%= img.getRuta() %>" target="_blank" class="text-white hover:text-blue-300 transition-colors dark:hover:text-blue-400" title="Ver tamaño completo">
                                    <i class="fas fa-expand-alt"></i>
                                </a>
                                
                                <form action="DeleteImageServlet" method="post" onsubmit="return confirm('¿Estás seguro de eliminar esta foto?');" class="m-0">
                                    <input type="hidden" name="id" value="<%= img.getId() %>"/>
                                    <button type="submit" class="bg-red-600 hover:bg-red-700 text-white size-8 rounded-lg flex items-center justify-center transition-colors shadow-md dark:bg-red-700 dark:hover:bg-red-800" title="Eliminar foto">
                                        <i class="fas fa-trash-alt text-xs"></i>
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                    <% } %>
                </div>
            <% } else { %>
                
                <div class="bg-white dark:bg-card-dark rounded-xl border-2 border-dashed border-gray-200 dark:border-border-dark p-16 text-center max-w-lg mx-auto mt-10">
                    <div class="bg-blue-50 dark:bg-blue-900/20 size-24 rounded-full flex items-center justify-center mx-auto mb-6">
                        <span class="material-symbols-outlined text-5xl text-blue-300 dark:text-blue-600">add_a_photo</span>
                    </div>
                    <h3 class="text-xl font-bold text-slate-800 dark:text-slate-200 mb-2">Álbum Vacío</h3>
                    <p class="text-slate-500 dark:text-slate-400 mb-6">
                        Aún no hay fotos en el álbum de este alumno. ¡Sube la primera!
                    </p>
                    <a href="uploadImage.jsp" class="inline-flex items-center gap-2 bg-primary hover:bg-blue-700 text-white px-6 py-2.5 rounded-lg font-medium transition-all shadow hover:shadow-md dark:bg-primary-dark dark:hover:bg-blue-800">
                        <i class="fas fa-upload"></i>
                        Subir Imagen
                    </a>
                </div>
                
            <% } %>

        </div>
        
        <footer class="mt-auto py-6 text-center text-xs text-slate-400 dark:text-slate-500 border-t border-slate-100 dark:border-border-dark bg-white dark:bg-card-dark">
            &copy; 2025 Colegio San Antonio - Todos los derechos reservados.
        </footer>
    </main>

</body>
</html>