<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Profesor, modelo.Material, modelo.Curso, java.util.List, java.text.SimpleDateFormat" %>

<%
    // 1. Configuración de no-caché y sesión
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    Profesor docente = (Profesor) session.getAttribute("docente");
    if (docente == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    // 2. Obtener datos del curso y materiales
    Curso curso = (Curso) request.getAttribute("curso");
    List<Material> materiales = (List<Material>) request.getAttribute("materiales");

    // Si no hay curso seleccionado, volver a la lista
    if (curso == null) {
        response.sendRedirect("MaterialServlet?accion=seleccionarCurso");
        return;
    }

    String mensaje = (String) session.getAttribute("mensaje");
    String error = (String) session.getAttribute("error");
    if (mensaje != null) session.removeAttribute("mensaje");
    if (error != null) session.removeAttribute("error");
    
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
%>

<!DOCTYPE html>
<html lang="es">
<head>
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
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestionar Recursos - <%= curso.getNombre() %></title>
    
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
        .dark .file-card {
            background-color: #1a2233;
            border-color: #374151;
        }
        .dark .file-card:hover {
            border-color: #3b82f6;
        }
        
        /* Estilos para modo oscuro */
        .dark .bg-white {
            background-color: #1a2233 !important;
        }
        .dark .bg-slate-50 {
            background-color: #283044 !important;
        }
        .dark .border-gray-200, .dark .border-gray-100, .dark .border-slate-200 {
            border-color: #374151 !important;
        }
        .dark .text-slate-800, .dark .text-slate-700, .dark .text-gray-900 {
            color: #f3f4f6 !important;
        }
        .dark .text-slate-500, .dark .text-slate-400, .dark .text-gray-600 {
            color: #9ca3af !important;
        }
        .dark .bg-gray-100 {
            background-color: #283044 !important;
        }
        .dark .bg-primary\/10 {
            background-color: rgba(19, 91, 236, 0.2) !important;
        }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark text-slate-800 dark:text-gray-200 min-h-screen flex overflow-hidden">

    <div class="flex h-screen overflow-hidden w-full">
        <!-- Sidebar - INCLUIDO -->
        <jsp:include page="includes/sidebarDocente.jsp" />

        <main class="flex-1 flex flex-col overflow-y-auto relative w-full">
            
            <!-- Header - INCLUIDO -->
            <% request.setAttribute("pageTitle", "Gestión de Recursos - " + curso.getNombre()); %>
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

                <div class="bg-gradient-to-r from-primary to-blue-600 rounded-2xl p-8 text-white shadow-lg mb-8 relative overflow-hidden">
                    <div class="absolute top-0 right-0 -mt-10 -mr-10 w-64 h-64 bg-white/10 rounded-full blur-3xl"></div>
                    <div class="absolute bottom-0 left-10 w-32 h-32 bg-white/10 rounded-full blur-2xl"></div>

                    <div class="relative z-10 flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
                        <div>
                            <div class="flex items-center gap-2 mb-2 opacity-90">
                                <span class="material-symbols-outlined icon-filled">folder_open</span>
                                <span class="text-sm font-medium uppercase tracking-wider">Detalle del Curso</span>
                            </div>
                            <h1 class="text-3xl font-bold mb-1"><%= curso.getNombre() %></h1>
                            <div class="flex items-center gap-3">
                                <span class="bg-white/20 px-3 py-1 rounded-full text-sm font-medium backdrop-blur-sm border border-white/10">
                                    <i class="fas fa-graduation-cap text-xs mr-1"></i> <%= curso.getGradoNombre() %>
                                </span>
                            </div>
                        </div>
                        
                        <div class="bg-white/10 backdrop-blur-md border border-white/20 rounded-xl p-4 min-w-[140px] text-center">
                            <span class="block text-3xl font-bold"><%= materiales != null ? materiales.size() : 0 %></span>
                            <span class="text-xs uppercase tracking-wide opacity-80">Archivos Subidos</span>
                        </div>
                    </div>
                </div>

                <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                    
                    <div class="lg:col-span-1">
                        <div class="bg-white dark:bg-gray-800 rounded-xl border border-gray-200 dark:border-gray-700 shadow-sm p-6 sticky top-24">
                            <h3 class="text-lg font-bold text-gray-900 dark:text-white mb-6 flex items-center gap-2 pb-4 border-b border-gray-100 dark:border-gray-700">
                                <div class="bg-blue-50 dark:bg-blue-900/30 p-2 rounded-lg text-primary dark:text-blue-400">
                                    <span class="material-symbols-outlined">cloud_upload</span>
                                </div>
                                Subir Nuevo Material
                            </h3>
                            
                            <form action="MaterialServlet" method="post" enctype="multipart/form-data" class="space-y-5">
                                <input type="hidden" name="accion" value="subir">
                                <input type="hidden" name="curso_id" value="<%= curso.getId()%>">
                                
                                <div>
                                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Seleccionar Archivo <span class="text-red-500">*</span></label>
                                    <div class="relative group">
                                        <input type="file" name="archivo" required 
                                               class="block w-full text-sm text-gray-500 dark:text-gray-400
                                               file:mr-4 file:py-2.5 file:px-4
                                               file:rounded-lg file:border-0
                                               file:text-sm file:font-semibold
                                               file:bg-blue-50 dark:file:bg-blue-900/30 file:text-primary dark:file:text-blue-400
                                               hover:file:bg-blue-100 dark:hover:file:bg-blue-800/50 transition-all cursor-pointer border border-gray-300 dark:border-gray-600 rounded-lg p-1 bg-white dark:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-primary/20">
                                    </div>
                                    <p class="text-xs text-gray-500 dark:text-gray-400 mt-2 flex items-center gap-1">
                                        <span class="material-symbols-outlined text-[14px]">info</span>
                                        Máx 10MB (PDF, Word, Excel, PPT)
                                    </p>
                                </div>
                                
                                <div>
                                    <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Descripción (Opcional)</label>
                                    <textarea name="descripcion" rows="3" 
                                              class="w-full rounded-lg border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white shadow-sm focus:border-primary focus:ring focus:ring-primary/20 text-sm placeholder-gray-400" 
                                              placeholder="Ej: Diapositivas de la clase sobre fracciones..."></textarea>
                                </div>
                                
                                <button type="submit" class="w-full bg-gray-800 dark:bg-primary hover:bg-primary dark:hover:bg-blue-700 text-white font-medium py-3 px-4 rounded-xl shadow-md hover:shadow-lg transition-all duration-300 flex items-center justify-center gap-2 group">
                                    <span class="material-symbols-outlined text-[20px] group-hover:-translate-y-0.5 transition-transform">publish</span>
                                    Subir Archivo
                                </button>
                            </form>
                        </div>
                    </div>

                    <div class="lg:col-span-2 space-y-4">
                        <div class="flex items-center justify-between mb-2">
                            <h3 class="text-lg font-bold text-gray-900 dark:text-white">Archivos Disponibles</h3>
                            <div class="text-sm text-gray-500 dark:text-gray-400 bg-white dark:bg-gray-800 px-3 py-1.5 rounded-lg border border-gray-200 dark:border-gray-700 shadow-sm">
                                Ordenado por fecha
                            </div>
                        </div>

                        <% if (materiales != null && !materiales.isEmpty()) { 
                            for (Material mat : materiales) {
                                String nombre = mat.getNombreArchivo();
                                String ext = "";
                                int i = nombre.lastIndexOf('.');
                                if (i > 0) ext = nombre.substring(i+1).toLowerCase();
                                
                                // Configuración visual por tipo de archivo
                                String iconClass = "fa-file";
                                String iconColor = "text-gray-500 dark:text-gray-400";
                                String iconBg = "bg-gray-100 dark:bg-gray-700";
                                
                                if (ext.equals("pdf")) { 
                                    iconClass = "fa-file-pdf"; iconColor = "text-red-500 dark:text-red-400"; iconBg = "bg-red-50 dark:bg-red-900/30"; 
                                } else if (ext.contains("doc")) { 
                                    iconClass = "fa-file-word"; iconColor = "text-blue-500 dark:text-blue-400"; iconBg = "bg-blue-50 dark:bg-blue-900/30"; 
                                } else if (ext.contains("xls")) { 
                                    iconClass = "fa-file-excel"; iconColor = "text-green-500 dark:text-green-400"; iconBg = "bg-green-50 dark:bg-green-900/30"; 
                                } else if (ext.contains("ppt")) { 
                                    iconClass = "fa-file-powerpoint"; iconColor = "text-orange-500 dark:text-orange-400"; iconBg = "bg-orange-50 dark:bg-orange-900/30"; 
                                } else if (ext.contains("zip") || ext.contains("rar")) { 
                                    iconClass = "fa-file-zipper"; iconColor = "text-purple-500 dark:text-purple-400"; iconBg = "bg-purple-50 dark:bg-purple-900/30"; 
                                }
                                
                                // Tamaño formateado
                                long size = mat.getTamanioArchivo();
                                String sizeStr = (size < 1024) ? size + " B" : (size < 1048576) ? String.format("%.1f KB", size/1024.0) : String.format("%.1f MB", size/1048576.0);
                        %>
                        
                        <div class="file-card bg-white dark:bg-gray-800 rounded-xl p-4 flex items-start gap-4 group">
                            <div class="flex-shrink-0 <%= iconBg %> <%= iconColor %> w-12 h-12 rounded-lg flex items-center justify-center text-xl shadow-sm">
                                <i class="fas <%= iconClass %>"></i>
                            </div>
                            
                            <div class="flex-grow min-w-0 pt-0.5">
                                <div class="flex justify-between items-start gap-4">
                                    <div>
                                        <h4 class="font-semibold text-gray-900 dark:text-white truncate pr-4 text-[15px] group-hover:text-primary transition-colors">
                                            <%= mat.getNombreArchivo() %>
                                        </h4>
                                        <p class="text-sm text-gray-500 dark:text-gray-400 mt-0.5 line-clamp-1">
                                            <%= (mat.getDescripcion() != null && !mat.getDescripcion().isEmpty()) ? mat.getDescripcion() : "Sin descripción adicional" %>
                                        </p>
                                    </div>
                                    
                                    <a href="MaterialServlet?accion=eliminar&id=<%= mat.getId()%>&curso_id=<%= curso.getId()%>" 
                                       onclick="return confirm('¿Seguro que deseas eliminar este archivo de forma permanente?')"
                                       class="text-gray-400 dark:text-gray-500 hover:text-red-500 dark:hover:text-red-400 hover:bg-red-50 dark:hover:bg-red-900/30 p-2 rounded-lg transition-all"
                                       title="Eliminar archivo">
                                        <i class="fas fa-trash-alt"></i>
                                    </a>
                                </div>
                                
                                <div class="flex items-center gap-4 mt-3 text-xs font-medium text-gray-500 dark:text-gray-400">
                                    <span class="flex items-center gap-1.5 bg-gray-50 dark:bg-gray-700 px-2 py-1 rounded border border-gray-100 dark:border-gray-600 uppercase tracking-wide">
                                        <%= ext.isEmpty() ? "FILE" : ext %>
                                    </span>
                                    <span class="flex items-center gap-1">
                                        <i class="fas fa-database text-[10px]"></i> <%= sizeStr %>
                                    </span>
                                    <span class="flex items-center gap-1">
                                        <i class="far fa-calendar-alt text-[10px]"></i> <%= sdf.format(mat.getFechaSubida()) %>
                                    </span>
                                </div>
                            </div>
                        </div>
                        <% 
                            } 
                        } else { 
                        %>
                        
                        <div class="bg-white dark:bg-gray-800 rounded-xl border-2 border-dashed border-gray-200 dark:border-gray-700 p-12 text-center h-full flex flex-col justify-center items-center">
                            <div class="bg-gray-50 dark:bg-gray-700 w-16 h-16 rounded-full flex items-center justify-center mb-4">
                                <span class="material-symbols-outlined text-3xl text-gray-400 dark:text-gray-500">folder_off</span>
                            </div>
                            <h3 class="text-lg font-bold text-gray-800 dark:text-gray-200">Aún no hay materiales</h3>
                            <p class="text-gray-500 dark:text-gray-400 text-sm mt-1 max-w-xs mx-auto">
                                Usa el formulario de la izquierda para subir documentos y compartirlos con tus alumnos.
                            </p>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>
            
        </main>
    </div>
</body>
</html>