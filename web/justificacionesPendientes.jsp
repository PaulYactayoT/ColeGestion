<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Justificacion, java.util.List" %>

<%
    // ========== VALIDACIÓN DE SESIÓN ==========
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    String rol = (String) session.getAttribute("rol");
    if (!"docente".equals(rol)) {
        response.sendRedirect("acceso_denegado.jsp");
        return;
    }

    // ========== OBTENER DATOS ==========
    List<Justificacion> justificaciones = (List<Justificacion>) request.getAttribute("justificaciones");

    if (justificaciones == null) {
        justificaciones = new java.util.ArrayList<>();
    }
    
    String mensaje = (String) session.getAttribute("mensaje");
    String error = (String) session.getAttribute("error");
    session.removeAttribute("mensaje");
    session.removeAttribute("error");
%>
<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Justificaciones Pendientes - Sistema Escolar</title>
    
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Lexend:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
    <!-- Material Symbols -->
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
    
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    
    <!-- SweetAlert2 -->
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" rel="stylesheet">
    
    <script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        "primary": "#135bec",
                        "primary-dark": "#0d47a1",
                        "success": "#10b981",
                        "danger": "#ef4444",
                        "warning": "#f59e0b",
                        "info": "#3b82f6",
                    },
                    fontFamily: {
                        "display": ["Lexend"]
                    },
                },
            },
        }
    </script>
    
    <style>
        body { font-family: 'Lexend', sans-serif; }
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
        
        .horario-item {
            background: linear-gradient(135deg, #dbeafe, #bfdbfe);
            border: 2px solid #93c5fd;
            border-radius: 0.75rem;
            padding: 1.25rem;
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        
        .alert-modern {
            border-radius: 0.75rem;
            padding: 1rem 1.25rem;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 1rem;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
            border-left: 4px solid;
        }
        
        .alert-danger {
            background: linear-gradient(135deg, #fee2e2, #fecaca);
            color: #991b1b;
            border-left-color: #ef4444;
        }
        
        .alert-success {
            background: linear-gradient(135deg, #d1fae5, #a7f3d0);
            color: #065f46;
            border-left-color: #10b981;
        }
        
        .section-title {
            color: #135bec;
            font-weight: 600;
            font-size: 1.2rem;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
    </style>
</head>
<body class="bg-[#f6f6f8] text-[#111318] min-h-screen">
    
    <div class="flex h-screen overflow-hidden">
        <!-- Left SideNavBar -->
        <aside class="w-64 flex-shrink-0 bg-white border-r border-[#dbdfe6] flex flex-col justify-between">
            <div class="flex flex-col gap-8 p-6">
                <!-- Brand -->
                <div class="flex items-center gap-3">
                    <div class="bg-primary size-10 rounded-lg flex items-center justify-center text-white">
                        <span class="material-symbols-outlined">school</span>
                    </div>
                    <div class="flex flex-col">
                        <h1 class="text-[#111318] text-lg font-bold">San Antonio</h1>
                        <p class="text-[#616f89] text-xs">Gestión Académica</p>
                    </div>
                </div>
                
                <!-- Navigation -->
                <nav class="flex flex-col gap-2">
                    <a class="flex items-center gap-3 px-3 py-2 rounded-lg text-[#616f89] hover:bg-gray-100" 
                       href="docenteDashboard.jsp">
                        <span class="material-symbols-outlined">dashboard</span>
                        <span class="text-sm">Dashboard</span>
                    </a>
                    <a class="flex items-center gap-3 px-3 py-2 rounded-lg bg-primary/10 text-primary font-medium" 
                       href="justificacionesPendientes.jsp">
                        <i class="fas fa-clock"></i>
                        <span class="text-sm">Justificaciones</span>
                    </a>
                    <a class="flex items-center gap-3 px-3 py-2 rounded-lg text-[#616f89] hover:bg-gray-100" 
                       href="AsistenciaServlet?accion=listar">
                        <i class="fas fa-calendar-check"></i>
                        <span class="text-sm">Asistencias</span>
                    </a>
                </nav>
            </div>
            
            <!-- Footer Sidebar -->
            <div class="p-6 border-t border-[#dbdfe6]">
                <a href="LogoutServlet" 
                   class="flex w-full items-center justify-center gap-2 rounded-lg h-10 px-4 bg-primary text-white text-sm font-bold hover:bg-blue-700">
                    <span class="material-symbols-outlined text-[18px]">logout</span>
                    <span>Cerrar Sesión</span>
                </a>
            </div>
        </aside>
        
        <!-- Main Content -->
        <main class="flex-1 flex flex-col overflow-y-auto">
            <!-- TopNavBar -->
            <header class="flex items-center justify-between bg-white border-b border-[#f0f2f4] px-8 py-3 sticky top-0 z-10">
                <div class="flex items-center gap-4 flex-1">
                    <h1 class="text-xl font-bold text-[#111318]">Justificaciones Pendientes</h1>
                </div>
                
                <div class="flex items-center gap-4">
                    <button class="p-2 text-[#616f89] hover:bg-gray-100 rounded-lg" aria-label="Notificaciones">
                        <span class="material-symbols-outlined">notifications</span>
                    </button>
                    <div class="flex items-center gap-3">
                        <p class="text-sm font-medium"><%= session.getAttribute("usuario") %></p>
                        <div class="size-10 rounded-full bg-primary flex items-center justify-center text-white">
                            <%= session.getAttribute("usuario").toString().substring(0,1).toUpperCase() %>
                        </div>
                    </div>
                </div>
            </header>
            
            <!-- Main Content -->
            <div class="p-8">
                <!-- Alertas -->
                <% if (error != null) { %>
                <div class="alert-modern alert-danger" role="alert">
                    <i class="fas fa-exclamation-circle text-xl"></i>
                    <div><strong>Error:</strong> <%= error %></div>
                </div>
                <% } %>
                
                <% if (mensaje != null) { %>
                <div class="alert-modern alert-success" role="alert">
                    <i class="fas fa-check-circle text-xl"></i>
                    <div><strong>Éxito:</strong> <%= mensaje %></div>
                </div>
                <% } %>
                
                <!-- Contenedor Principal -->
                <div class="bg-white rounded-xl border border-[#dbdfe6] shadow-sm p-6">
                    <!-- Título -->
                    <div class="section-title">
                        <i class="fas fa-clipboard-list"></i>
                        Justificaciones por Revisar
                    </div>
                    
                    <p class="text-[#616f89] text-sm mb-6">
                        Total de justificaciones pendientes: <strong class="text-primary"><%= justificaciones.size() %></strong>
                    </p>

                    <% if (!justificaciones.isEmpty()) { %>
                        <!-- Lista de Justificaciones -->
                        <div id="justificacionesContainer">
                            <% for (Justificacion j : justificaciones) { %>
                            <div class="horario-item">
                                <div class="flex-1">
                                    <div class="flex items-center gap-3 mb-2">
                                        <div class="size-10 rounded-full bg-primary flex items-center justify-center text-white font-semibold">
                                            <%= j.getAlumnoNombre() != null && j.getAlumnoNombre().length() > 0 ? j.getAlumnoNombre().substring(0, 1).toUpperCase() : "A" %>
                                        </div>
                                        <div>
                                            <div class="font-bold text-[#111318]">
                                                <i class="fas fa-user-graduate"></i> 
                                                <strong><%= j.getAlumnoNombre() != null ? j.getAlumnoNombre() : "N/A" %></strong>
                                            </div>
                                            <div class="text-sm text-[#616f89]">
                                                <i class="fas fa-book"></i> <%= j.getCursoNombre() != null ? j.getCursoNombre() : "N/A" %> - 
                                                <i class="fas fa-calendar"></i> <%= j.getFechaAsistencia() != null ? j.getFechaAsistencia() : "N/A" %>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="text-sm text-[#616f89] mt-2">
                                        <i class="fas fa-tag"></i> <strong>Tipo:</strong> <%= j.getTipoJustificacion() != null ? j.getTipoJustificacion().getDescripcion() : "N/A" %> - 
                                        <i class="fas fa-user"></i> <strong>Enviado por:</strong> <%= j.getJustificadorNombre() != null ? j.getJustificadorNombre() : "N/A" %>
                                        <% if (j.getDescripcion() != null && !j.getDescripcion().isEmpty()) { %>
                                        - <button type="button" 
                                                onclick="verDescripcion(<%= j.getId() %>)"
                                                class="text-primary hover:text-primary-dark font-semibold"
                                                aria-label="Ver descripción de la justificación">
                                            <i class="fas fa-eye"></i> Ver descripción
                                        </button>
                                        <% } %>
                                    </div>
                                </div>
                                <div class="flex gap-2">
                                    <form method="post" action="JustificacionServlet" class="inline" onsubmit="return confirmarAprobacion()">
                                        <input type="hidden" name="accion" value="aprobar">
                                        <input type="hidden" name="id" value="<%= j.getId() %>">
                                        <button type="submit" 
                                                class="px-4 py-2 bg-success text-white rounded-lg hover:bg-green-600 transition-all font-semibold text-sm"
                                                aria-label="Aprobar justificación">
                                            <i class="fas fa-check"></i> Aprobar
                                        </button>
                                    </form>
                                    <button type="button" 
                                            onclick="verRechazo(<%= j.getId() %>)"
                                            class="px-4 py-2 bg-danger text-white rounded-lg hover:bg-red-600 transition-all font-semibold text-sm"
                                            aria-label="Rechazar justificación">
                                        <i class="fas fa-times"></i> Rechazar
                                    </button>
                                </div>
                            </div>
                            <% } %>
                        </div>
                    <% } else { %>
                        <!-- Sin justificaciones -->
                        <div class="text-center py-12">
                            <i class="fas fa-check-circle text-6xl text-success mb-4"></i>
                            <h3 class="text-xl font-bold text-gray-800 mb-2">No hay justificaciones pendientes</h3>
                            <p class="text-gray-600 mb-6">Todas las justificaciones han sido revisadas.</p>
                            <a href="docenteDashboard.jsp" 
                               class="inline-flex items-center gap-2 px-6 py-3 bg-primary text-white rounded-lg hover:bg-primary-dark transition-all font-semibold">
                                <i class="fas fa-arrow-left"></i>
                                <span>Volver al Dashboard</span>
                            </a>
                        </div>
                    <% } %>
                </div>
            </div>
        </main>
    </div>

    <!-- Modales (fuera del contenedor principal) -->
    <% for (Justificacion j : justificaciones) { %>
    <!-- Modal Ver Descripción -->
    <div id="modal-desc-<%= j.getId() %>" 
         style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 1000; align-items: center; justify-content: center;"
         role="dialog" 
         aria-modal="true" 
         aria-labelledby="modal-title-<%= j.getId() %>">
        <div style="background: white; border-radius: 1rem; max-width: 600px; width: 90%; max-height: 90vh; overflow-y: auto;">
            <div class="p-6 border-b border-gray-200">
                <div class="flex items-center justify-between">
                    <h3 id="modal-title-<%= j.getId() %>" class="text-xl font-bold text-[#111318]">
                        <i class="fas fa-file-alt text-primary mr-2"></i>
                        Detalle de Justificación
                    </h3>
                    <button onclick="cerrarModal('modal-desc-<%= j.getId() %>')" 
                            class="text-gray-400 hover:text-gray-600"
                            aria-label="Cerrar modal">
                        <i class="fas fa-times text-2xl"></i>
                    </button>
                </div>
            </div>
            <div class="p-6">
                <div class="mb-4">
                    <h4 class="font-semibold text-gray-700 mb-2">Descripción:</h4>
                    <p class="text-gray-600 bg-gray-50 rounded-lg p-4"><%= j.getDescripcion() %></p>
                </div>
                
                <% if (j.tieneDocumento()) { %>
                <div class="mt-4 p-4 bg-blue-50 rounded-lg border border-blue-200">
                    <h4 class="font-semibold text-gray-700 mb-2">Documento Adjunto:</h4>
                    <div class="flex items-center justify-between">
                        <div class="flex items-center gap-3">
                            <i class="fas fa-file-alt text-2xl text-primary"></i>
                            <span class="text-sm text-gray-700"><%= j.getNombreArchivo() %></span>
                        </div>
                        <a href="<%= j.getDocumentoAdjunto() %>" 
                           target="_blank" 
                           class="px-4 py-2 bg-primary text-white rounded-lg hover:bg-primary-dark transition-all flex items-center gap-2"
                           aria-label="Descargar documento adjunto">
                            <i class="fas fa-download"></i>
                            <span>Descargar</span>
                        </a>
                    </div>
                </div>
                <% } %>
            </div>
        </div>
    </div>

    <!-- Modal Rechazar -->
    <div id="modal-rechazar-<%= j.getId() %>" 
         style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 1000; align-items: center; justify-content: center;"
         role="dialog" 
         aria-modal="true" 
         aria-labelledby="modal-rechazo-title-<%= j.getId() %>">
        <div style="background: white; border-radius: 1rem; max-width: 600px; width: 90%; max-height: 90vh; overflow-y: auto;">
            <div class="p-6 border-b border-gray-200">
                <div class="flex items-center justify-between">
                    <h3 id="modal-rechazo-title-<%= j.getId() %>" class="text-xl font-bold text-[#111318]">
                        <i class="fas fa-times-circle text-danger mr-2"></i>
                        Rechazar Justificación
                    </h3>
                    <button onclick="cerrarModal('modal-rechazar-<%= j.getId() %>')" 
                            class="text-gray-400 hover:text-gray-600"
                            aria-label="Cerrar modal">
                        <i class="fas fa-times text-2xl"></i>
                    </button>
                </div>
            </div>
            <form method="post" action="JustificacionServlet">
                <input type="hidden" name="accion" value="rechazar">
                <input type="hidden" name="id" value="<%= j.getId() %>">
                <div class="p-6">
                    <label for="observaciones-<%= j.getId() %>" class="block text-sm font-semibold text-gray-700 mb-2">
                        Motivo del rechazo <span class="text-danger">*</span>
                    </label>
                    <textarea id="observaciones-<%= j.getId() %>" 
                              name="observaciones" 
                              rows="4" 
                              required
                              class="w-full px-4 py-3 border-2 border-gray-200 rounded-lg focus:border-primary focus:ring-2 focus:ring-primary/20 transition-all resize-none"
                              placeholder="Explique detalladamente por qué rechaza esta justificación..."
                              aria-required="true"></textarea>
                    <p class="text-xs text-gray-500 mt-2">
                        <i class="fas fa-info-circle"></i>
                        Esta observación será visible para el padre de familia.
                    </p>
                </div>
                <div class="px-6 py-4 bg-gray-50 flex items-center justify-end gap-3">
                    <button type="button" 
                            onclick="cerrarModal('modal-rechazar-<%= j.getId() %>')"
                            class="px-4 py-2 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition-all">
                        Cancelar
                    </button>
                    <button type="submit" 
                            class="px-4 py-2 bg-danger text-white rounded-lg hover:bg-red-600 transition-all font-semibold flex items-center gap-2">
                        <i class="fas fa-times"></i>
                        <span>Confirmar Rechazo</span>
                    </button>
                </div>
            </form>
        </div>
    </div>
    <% } %>

    <!-- SweetAlert2 -->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    
    <script>
        function verDescripcion(id) {
            const modal = document.getElementById('modal-desc-' + id);
            modal.style.display = 'flex';
            document.body.style.overflow = 'hidden';
        }

        function verRechazo(id) {
            const modal = document.getElementById('modal-rechazar-' + id);
            modal.style.display = 'flex';
            document.body.style.overflow = 'hidden';
        }

        function cerrarModal(id) {
            const modal = document.getElementById(id);
            modal.style.display = 'none';
            document.body.style.overflow = 'auto';
        }

        function confirmarAprobacion() {
            return confirm('¿Está seguro de aprobar esta justificación?');
        }

        // Cerrar modales con ESC
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                document.querySelectorAll('[id^="modal-"]').forEach(modal => {
                    modal.style.display = 'none';
                });
                document.body.style.overflow = 'auto';
            }
        });

        // Cerrar modal al hacer click fuera
        document.querySelectorAll('[id^="modal-"]').forEach(modal => {
            modal.addEventListener('click', function(e) {
                if (e.target === this) {
                    this.style.display = 'none';
                    document.body.style.overflow = 'auto';
                }
            });
        });

        // SweetAlert para mensajes
        <% if (mensaje != null) { %>
        Swal.fire({
            icon: 'success',
            title: '¡Éxito!',
            text: '<%= mensaje %>',
            toast: true,
            position: 'top-end',
            showConfirmButton: false,
            timer: 3000,
            timerProgressBar: true
        });
        <% } %>

        <% if (error != null) { %>
        Swal.fire({
            icon: 'error',
            title: 'Error',
            text: '<%= error %>',
            toast: true,
            position: 'top-end',
            showConfirmButton: false,
            timer: 3000,
            timerProgressBar: true
        });
        <% } %>
    </script>
</body>
</html>
