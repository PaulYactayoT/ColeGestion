<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Padre, modelo.PadreDAO" %>

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
%>

<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Subir Foto - San Antonio</title>
    
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
            <div class="flex items-center gap-2">
                <a href="albumPadre.jsp?alumno_id=<%= alumnoId %>" class="p-2 -ml-2 text-slate-400 hover:text-primary hover:bg-blue-50 rounded-full transition-colors" title="Volver al Álbum">
                    <span class="material-symbols-outlined">arrow_back</span>
                </a>
                <h2 class="text-xl font-bold text-slate-800">Subir Nueva Foto</h2>
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

        <div class="flex-1 flex flex-col items-center justify-center p-6">
            
            <div class="bg-white w-full max-w-lg rounded-2xl shadow-lg border border-gray-100 overflow-hidden">
                
                <div class="bg-primary/5 p-6 border-b border-primary/10 text-center">
                    <div class="bg-white size-16 rounded-full flex items-center justify-center mx-auto mb-4 shadow-sm border border-primary/10 text-primary">
                        <span class="material-symbols-outlined text-3xl">add_a_photo</span>
                    </div>
                    <h2 class="text-xl font-bold text-slate-800">Añadir Recuerdo</h2>
                    <p class="text-sm text-slate-500 mt-1">Sube una nueva foto al álbum de <%= padre.getAlumnoNombre() %></p>
                </div>

                <div class="p-8">
                    <form action="UploadImageServlet" method="post" enctype="multipart/form-data" class="space-y-6">
                        <input type="hidden" name="alumno_id" value="<%= alumnoId %>">
                        
                        <div class="space-y-2">
                            <label class="block text-sm font-medium text-slate-700">Seleccionar Imagen</label>
                            <div class="relative border-2 border-dashed border-gray-300 rounded-xl p-6 hover:bg-slate-50 hover:border-primary transition-colors text-center cursor-pointer group">
                                <input type="file" name="file" accept="image/*" required 
                                       class="absolute inset-0 w-full h-full opacity-0 cursor-pointer z-10">
                                
                                <div class="text-slate-400 group-hover:text-primary transition-colors">
                                    <span class="material-symbols-outlined text-4xl mb-2">cloud_upload</span>
                                    <p class="text-sm font-medium">Haz clic o arrastra una imagen aquí</p>
                                    <p class="text-xs mt-1 text-slate-400">(JPG, PNG, GIF - Máx 5MB)</p>
                                </div>
                            </div>
                        </div>

                        <div class="flex gap-3 pt-2">
                            <a href="albumPadre.jsp?alumno_id=<%= alumnoId %>" class="flex-1 py-3 px-4 rounded-xl border border-gray-300 text-slate-600 font-medium hover:bg-gray-50 text-center transition-colors">
                                Cancelar
                            </a>
                            <button type="submit" class="flex-1 py-3 px-4 rounded-xl bg-primary text-white font-bold hover:bg-blue-700 shadow-md transition-all flex items-center justify-center gap-2">
                                <span class="material-symbols-outlined">upload</span>
                                Subir Foto
                            </button>
                        </div>
                    </form>
                </div>
            </div>

        </div>
        
        <footer class="py-6 text-center text-xs text-slate-400 border-t border-slate-100 bg-white w-full">
            &copy; 2025 Colegio San Antonio - Todos los derechos reservados.
        </footer>
    </main>

</body>
</html>