<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Padre, modelo.Tarea" %>
<%
    // --- LÓGICA DE SESIÓN ---
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    Padre padre = (Padre) session.getAttribute("padre");
    Tarea tarea = (Tarea) request.getAttribute("tarea");
    
    if (padre == null || tarea == null) {
        response.sendRedirect("TareasPadreServlet");
        return;
    }

    String error = (String) session.getAttribute("error");
    if (error != null) session.removeAttribute("error");
%>
<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Entregar Tarea - <%= tarea.getNombre() %></title>
    
    <jsp:include page="includes/head.jsp" />
</head>
<body class="bg-background-light dark:bg-background-dark text-slate-800 dark:text-slate-200 min-h-screen flex transition-colors duration-200">

    <jsp:include page="includes/sidebarPadre.jsp" />
    
    <main class="flex-1 md:ml-64 flex flex-col min-h-screen">
        
        <jsp:include page="includes/header.jsp" />

        <div class="p-6 md:p-8 max-w-4xl mx-auto w-full">
            
            <a href="TareasPadreServlet" class="inline-flex items-center gap-2 text-slate-500 hover:text-primary dark:text-slate-400 dark:hover:text-blue-400 transition-colors mb-6 font-medium">
                <i class="fas fa-arrow-left"></i> Volver a la lista
            </a>

            <% if (error != null) { %>
            <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative mb-6 flex items-center gap-2" role="alert">
                <i class="fas fa-exclamation-circle"></i>
                <span class="block sm:inline font-medium"><%= error %></span>
            </div>
            <% } %>

            <div class="bg-white dark:bg-card-dark rounded-xl shadow-sm border border-gray-200 dark:border-border-dark overflow-hidden mb-8">
                
                <div class="bg-gradient-to-r from-primary to-blue-600 p-6 text-white">
                    <div class="flex justify-between items-start">
                        <div>
                            <span class="inline-block px-2 py-1 bg-white/20 rounded text-xs font-semibold uppercase tracking-wider mb-2">
                                <%= tarea.getTipo() %>
                            </span>
                            <h2 class="text-2xl font-bold"><%= tarea.getNombre() %></h2>
                            <p class="text-blue-100 mt-1 opacity-90"><i class="fas fa-book mr-1"></i> Curso: <%= tarea.getCursoNombre() %></p>
                        </div>
                        <div class="text-right">
                            <div class="text-sm text-blue-100 opacity-90 mb-1">Fecha límite</div>
                            <div class="font-bold text-lg bg-white/10 px-3 py-1.5 rounded-lg border border-white/20">
                                <i class="far fa-calendar-alt mr-1"></i> <%= tarea.getFechaEntrega() %> 
                                <span class="mx-1">|</span> 
                                <i class="far fa-clock mr-1"></i> <%= (tarea.getHoraEntrega() != null) ? tarea.getHoraEntrega() : "23:59:00" %>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="p-6">
                    <div class="mb-6">
                        <h3 class="text-lg font-bold text-slate-800 dark:text-slate-200 border-b border-gray-100 dark:border-border-dark pb-2 mb-4">Instrucciones</h3>
                        <div class="text-slate-600 dark:text-slate-400 whitespace-pre-wrap leading-relaxed">
                            <%= tarea.getInstrucciones() != null && !tarea.getInstrucciones().isEmpty() ? tarea.getInstrucciones() : "No hay instrucciones adicionales." %>
                        </div>
                    </div>

                    <% 
                    if (tarea.getArchivoAdjunto() != null && !tarea.getArchivoAdjunto().isEmpty() && !tarea.getArchivoAdjunto().equals("null")) { 
                        // Preparar el nombre del archivo para la URL (maneja los espacios y caracteres especiales)
                        String archivoCodificado = "";
                        try {
                            archivoCodificado = java.net.URLEncoder.encode(tarea.getArchivoAdjunto(), "UTF-8");
                            // Reemplazar el signo '+' que pone URLEncoder por '%20' para que funcione perfecto
                            archivoCodificado = archivoCodificado.replace("+", "%20");
                        } catch (Exception e) {
                            archivoCodificado = tarea.getArchivoAdjunto();
                        }
                    %>
                    <div class="mb-8">
                        <h3 class="text-sm font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider mb-3">Actividad</h3>
                        
                        <a href="DescargarServlet?archivo=<%= archivoCodificado %>&tipo=tarea" target="_blank" class="inline-flex items-center gap-4 p-4 border border-blue-200 dark:border-blue-800 bg-blue-50/50 dark:bg-blue-900/10 rounded-xl hover:bg-blue-50 dark:hover:bg-blue-900/30 hover:border-blue-300 dark:hover:border-blue-700 transition-all duration-200 group w-full md:w-auto shadow-sm">
                            <div class="w-12 h-12 rounded-lg bg-blue-500 text-white flex items-center justify-center text-2xl shadow-inner group-hover:scale-105 transition-transform">
                                <i class="fas fa-file-download"></i>
                            </div>
                            <div class="flex-1">
                                <div class="font-bold text-blue-700 dark:text-blue-400 group-hover:text-blue-800 dark:group-hover:text-blue-300 transition-colors">
                                    Descargar archivo guía
                                </div>
                                <div class="text-xs text-slate-500 dark:text-slate-400 mt-0.5 truncate max-wxs">
                                    <%= tarea.getArchivoAdjunto() %>
                                </div>
                            </div>
                        </a>
                    </div>
                    <% } %>

                    <div class="mt-8 bg-gray-50 dark:bg-gray-800/50 rounded-xl border border-gray-200 dark:border-border-dark p-6">
                        <h3 class="text-lg font-bold text-slate-800 dark:text-slate-200 mb-4 flex items-center gap-2">
                            <i class="fas fa-cloud-upload-alt text-primary"></i> Tu Entrega
                        </h3>
                        
                        <form action="EntregaServlet" method="POST" enctype="multipart/form-data" id="formEntrega">
                            <input type="hidden" name="accion" value="subir">
                            <input type="hidden" name="id_tarea" value="<%= tarea.getId() %>">
                            
                            <div class="w-full relative">
                                <input type="file" id="archivo" name="archivo" class="hidden" accept=".pdf,.doc,.docx,.jpg,.jpeg,.png" required onchange="mostrarArchivo(this)">
                                
                                <label for="archivo" id="dropzone" class="flex flex-col items-center justify-center w-full h-40 border-2 border-dashed border-gray-300 dark:border-gray-600 rounded-lg cursor-pointer bg-white dark:bg-card-dark hover:bg-gray-50 dark:hover:bg-gray-800 hover:border-primary dark:hover:border-blue-500 transition-all">
                                    <div class="flex flex-col items-center justify-center pt-5 pb-6">
                                        <i class="fas fa-file-upload text-4xl text-gray-400 dark:text-gray-500 mb-3"></i>
                                        <p class="mb-2 text-sm text-gray-500 dark:text-gray-400"><span class="font-semibold text-primary dark:text-blue-400">Haz clic para buscar</span> o arrastra un archivo aquí</p>
                                        <p class="text-xs text-gray-500 dark:text-gray-500">PDF, Word o Imágenes (Max. 10MB)</p>
                                    </div>
                                </label>
                            </div>

                            <div id="vistaPrevia" class="hidden mt-4 p-4 bg-white dark:bg-card-dark border border-blue-200 dark:border-blue-900 rounded-lg shadow-sm flex items-center justify-between">
                                <div class="flex items-center gap-3 overflow-hidden">
                                    <div class="text-2xl text-blue-500">
                                        <i id="iconoArchivo" class="fas fa-file-alt"></i>
                                    </div>
                                    <div class="truncate">
                                        <p id="nombreArchivo" class="text-sm font-medium text-slate-700 dark:text-slate-300 truncate">nombre.pdf</p>
                                        <p id="pesoArchivo" class="text-xs text-slate-500">0 KB</p>
                                    </div>
                                </div>
                                <button type="button" onclick="eliminarArchivo()" class="text-red-500 hover:bg-red-50 dark:hover:bg-red-900/30 p-2 rounded transition-colors" title="Eliminar archivo seleccionado">
                                    <i class="fas fa-trash-alt"></i>
                                </button>
                            </div>

                            <div class="mt-6 flex justify-end">
                                <button type="submit" id="btnEnviar" disabled class="bg-gray-400 cursor-not-allowed text-white px-6 py-2.5 rounded-lg font-bold flex items-center gap-2 transition-all">
                                    <i class="fas fa-paper-plane"></i> Enviar Tarea
                                </button>
                            </div>
                        </form>
                    </div>

                </div>
            </div>
        </div>
        
        <footer class="mt-auto py-6 text-center text-xs text-slate-400 dark:text-slate-500 border-t border-slate-100 dark:border-border-dark bg-white dark:bg-card-dark">
            &copy; 2025 Colegio San Antonio - Todos los derechos reservados.
        </footer>
    </main>

    <script>
        // Lógica para mostrar el archivo seleccionado y habilitar el botón
        function mostrarArchivo(input) {
            const dropzone = document.getElementById('dropzone');
            const vistaPrevia = document.getElementById('vistaPrevia');
            const nombreArchivo = document.getElementById('nombreArchivo');
            const pesoArchivo = document.getElementById('pesoArchivo');
            const btnEnviar = document.getElementById('btnEnviar');
            
            if (input.files && input.files[0]) {
                const file = input.files[0];
                
                // Validar tamaño en cliente (10MB)
                if(file.size > 10 * 1024 * 1024) {
                    alert("El archivo pesa más de 10MB. Por favor, selecciona uno más ligero.");
                    eliminarArchivo();
                    return;
                }

                nombreArchivo.textContent = file.name;
                pesoArchivo.textContent = (file.size / 1024 / 1024).toFixed(2) + ' MB';
                
                dropzone.classList.add('hidden');
                vistaPrevia.classList.remove('hidden');
                
                // Habilitar botón
                btnEnviar.disabled = false;
                btnEnviar.className = "bg-green-600 hover:bg-green-700 text-white px-6 py-2.5 rounded-lg font-bold flex items-center gap-2 shadow-md transition-all transform hover:-translate-y-0.5";
            }
        }

        // Lógica para quitar el archivo antes de enviar (HU-14 EP-14.5)
        function eliminarArchivo() {
            const input = document.getElementById('archivo');
            const dropzone = document.getElementById('dropzone');
            const vistaPrevia = document.getElementById('vistaPrevia');
            const btnEnviar = document.getElementById('btnEnviar');
            
            input.value = ''; // Limpiar el input
            
            vistaPrevia.classList.add('hidden');
            dropzone.classList.remove('hidden');
            
            // Deshabilitar botón
            btnEnviar.disabled = true;
            btnEnviar.className = "bg-gray-400 cursor-not-allowed text-white px-6 py-2.5 rounded-lg font-bold flex items-center gap-2 transition-all";
        }
    </script>
</body>
</html>