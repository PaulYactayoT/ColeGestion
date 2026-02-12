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
                
                <a href="MaterialPadreServlet?accion=seleccionarCurso" class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-slate-600 hover:bg-slate-50 transition-colors group">
                    <span class="material-symbols-outlined group-hover:text-primary transition-colors">folder_open</span>
                    <span class="text-sm font-medium">Material de Apoyo</span>
                </a>
                
                <a href="albumPadre.jsp?alumno_id=<%= alumnoId %>" class="flex items-center gap-3 px-3 py-2.5 rounded-lg bg-primary/10 text-primary font-medium transition-colors">
                    <span class="material-symbols-outlined fill-1">photo_library</span>
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
                    <span class="material-symbols-outlined text-primary text-2xl">photo_library</span>
                    <h1 class="text-xl font-bold">Álbum Escolar</h1>
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
                    <a href="uploadImage.jsp" class="bg-white text-primary hover:bg-blue-50 px-5 py-2.5 rounded-lg font-bold text-sm flex items-center gap-2 shadow-sm transition-all">
                        <i class="fas fa-cloud-upload-alt"></i> Subir Foto
                    </a>
                </div>
            </div>

            <% if (!imagenes.isEmpty()) { %>
                <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
                    <% for (Imagen img : imagenes) { %>
                    
                    <div class="relative group bg-white rounded-xl shadow-sm hover:shadow-lg transition-all duration-300 overflow-hidden border border-gray-100 h-64">
                        
                        <img src="<%= img.getRuta() %>" alt="Foto escolar" class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-110">
                        
                        <div class="absolute inset-0 bg-gradient-to-t from-black/70 via-black/20 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex flex-col justify-end p-4">
                            
                            <div class="flex justify-between items-center">
                                <a href="<%= img.getRuta() %>" target="_blank" class="text-white hover:text-blue-300 transition-colors" title="Ver tamaño completo">
                                    <i class="fas fa-expand-alt"></i>
                                </a>
                                
                                <form action="DeleteImageServlet" method="post" onsubmit="return confirm('¿Estás seguro de eliminar esta foto?');" class="m-0">
                                    <input type="hidden" name="id" value="<%= img.getId() %>"/>
                                    <button type="submit" class="bg-red-600 hover:bg-red-700 text-white size-8 rounded-lg flex items-center justify-center transition-colors shadow-md" title="Eliminar foto">
                                        <i class="fas fa-trash-alt text-xs"></i>
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                    <% } %>
                </div>
            <% } else { %>
                
                <div class="bg-white rounded-xl border-2 border-dashed border-gray-200 p-16 text-center max-w-lg mx-auto mt-10">
                    <div class="bg-blue-50 size-24 rounded-full flex items-center justify-center mx-auto mb-6">
                        <span class="material-symbols-outlined text-5xl text-blue-300">add_a_photo</span>
                    </div>
                    <h3 class="text-xl font-bold text-slate-800 mb-2">Álbum Vacío</h3>
                    <p class="text-slate-500 mb-6">
                        Aún no hay fotos en el álbum de este alumno. ¡Sube la primera!
                    </p>
                    <a href="uploadImage.jsp" class="inline-flex items-center gap-2 bg-primary hover:bg-blue-700 text-white px-6 py-2.5 rounded-lg font-medium transition-all shadow hover:shadow-md">
                        <i class="fas fa-upload"></i>
                        Subir Imagen
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