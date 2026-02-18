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
    
    // Obtener mensajes de error si existen
    String error = request.getParameter("error");
%>

<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Subir Foto - San Antonio</title>
    
    <!-- INCLUIR HEAD.JSP CON TODAS LAS CONFIGURACIONES -->
    <jsp:include page="includes/head.jsp" />
    
    <style>
        .upload-area {
            transition: all 0.3s ease;
        }
        .upload-area:hover {
            border-color: #135bec;
            background-color: #f0f9ff;
        }
        .dark .upload-area:hover {
            background-color: #1e293b;
        }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark text-slate-800 dark:text-slate-200 min-h-screen flex transition-colors duration-200">

    <!-- INCLUIR SIDEBAR PARA PADRE -->
    <jsp:include page="includes/sidebarPadre.jsp" />
    
    <main class="flex-1 md:ml-64 flex flex-col min-h-screen">
        
        <!-- INCLUIR HEADER -->
        <jsp:include page="includes/header.jsp" />

        <div class="flex-1 flex flex-col items-center justify-center p-6">
            
            <!-- Mostrar error si existe -->
            <% if (error != null && !error.isEmpty()) { %>
            <div class="mb-4 w-full max-w-lg p-4 bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400 rounded-lg flex items-center gap-3">
                <i class="fas fa-exclamation-circle"></i>
                <span><%= error %></span>
            </div>
            <% } %>
            
            <!-- Tarjeta principal -->
            <div class="bg-white dark:bg-card-dark w-full max-w-lg rounded-2xl shadow-lg border border-gray-200 dark:border-border-dark overflow-hidden transition-colors duration-200">
                
                <!-- Encabezado de la tarjeta -->
                <div class="bg-primary/5 dark:bg-primary/10 p-6 border-b border-primary/10 dark:border-primary/20 text-center">
                    <div class="bg-white dark:bg-card-dark size-16 rounded-full flex items-center justify-center mx-auto mb-4 shadow-sm border border-primary/10 dark:border-primary/20 text-primary">
                        <span class="material-symbols-outlined text-3xl">add_a_photo</span>
                    </div>
                    <h2 class="text-xl font-bold text-slate-800 dark:text-white">Añadir Recuerdo</h2>
                    <p class="text-sm text-slate-500 dark:text-slate-400 mt-1">Sube una nueva foto al álbum de <span class="font-semibold"><%= padre.getAlumnoNombre() %></span></p>
                </div>

                <!-- Cuerpo de la tarjeta -->
                <div class="p-8">
                    <form action="UploadImageServlet" method="post" enctype="multipart/form-data" class="space-y-6">
                        <!-- ✅ CAMPO OCULTO CON alumno_id - ESTO ES CRÍTICO -->
                        <input type="hidden" name="alumno_id" value="<%= alumnoId %>">
                        
                        <div class="space-y-2">
                            <label class="block text-sm font-medium text-slate-700 dark:text-slate-300">Seleccionar Imagen</label>
                            <div class="upload-area relative border-2 border-dashed border-gray-300 dark:border-border-dark rounded-xl p-6 hover:bg-slate-50 dark:hover:bg-gray-800 hover:border-primary dark:hover:border-primary transition-colors text-center cursor-pointer group">
                                <!-- ✅ CAMPO CON NOMBRE "file" - DEBE COINCIDIR CON EL SERVLET -->
                                <input type="file" name="file" accept="image/*" required 
                                       class="absolute inset-0 w-full h-full opacity-0 cursor-pointer z-10">
                                
                                <div class="text-slate-400 dark:text-slate-500 group-hover:text-primary dark:group-hover:text-primary transition-colors">
                                    <span class="material-symbols-outlined text-4xl mb-2">cloud_upload</span>
                                    <p class="text-sm font-medium">Haz clic o arrastra una imagen aquí</p>
                                    <p class="text-xs mt-1 text-slate-400 dark:text-slate-500">(JPG, PNG, GIF - Máx 5MB)</p>
                                </div>
                            </div>
                        </div>

                        <!-- Botones de acción -->
                        <div class="flex gap-3 pt-2">
                            <a href="albumPadre.jsp?alumno_id=<%= alumnoId %>" 
                               class="flex-1 py-3 px-4 rounded-xl border border-gray-300 dark:border-border-dark text-slate-600 dark:text-slate-400 font-medium hover:bg-gray-50 dark:hover:bg-gray-800 text-center transition-colors">
                                Cancelar
                            </a>
                            <button type="submit" 
                                    class="flex-1 py-3 px-4 rounded-xl bg-primary text-white font-bold hover:bg-blue-700 dark:bg-primary-dark dark:hover:bg-blue-800 shadow-md transition-all flex items-center justify-center gap-2">
                                <span class="material-symbols-outlined">upload</span>
                                Subir Foto
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Información adicional -->
            <div class="mt-6 text-center text-xs text-slate-400 dark:text-slate-500">
                <i class="fas fa-info-circle mr-1"></i>
                Formatos permitidos: JPG, PNG, GIF. Tamaño máximo: 5MB
            </div>

        </div>
        
        <!-- Footer -->
        <footer class="py-6 text-center text-xs text-slate-400 dark:text-slate-500 border-t border-slate-100 dark:border-border-dark bg-white dark:bg-card-dark w-full">
            &copy; 2025 Colegio San Antonio - Todos los derechos reservados.
        </footer>
    </main>

    <!-- Script para previsualización de imagen -->
    <script>
        document.querySelector('input[type="file"]').addEventListener('change', function(e) {
            const file = e.target.files[0];
            if (file) {
                // Validar tipo de archivo
                const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/jpg'];
                if (!allowedTypes.includes(file.type)) {
                    alert('Solo se permiten archivos JPG, PNG y GIF');
                    this.value = '';
                    return;
                }
                
                // Validar tamaño (5MB = 5 * 1024 * 1024 bytes)
                if (file.size > 5 * 1024 * 1024) {
                    alert('El archivo no debe superar los 5MB');
                    this.value = '';
                    return;
                }
                
                const uploadArea = document.querySelector('.upload-area div');
                const fileName = file.name;
                const fileSize = (file.size / 1024).toFixed(2);
                
                uploadArea.innerHTML = `
                    <span class="material-symbols-outlined text-4xl mb-2 text-primary">check_circle</span>
                    <p class="text-sm font-medium text-primary">Archivo seleccionado:</p>
                    <p class="text-xs mt-1 text-slate-600 dark:text-slate-400">${fileName} (${fileSize} KB)</p>
                `;
            }
        });
    </script>

</body>
</html>