<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Asistencia, java.util.List, java.time.format.DateTimeFormatter" %>
<%@ page import="modelo.Padre" %>
<%
    // DEBUG: Mostrar todos los atributos de sesión
    System.out.println("=== DEBUG justificarAusencia.jsp ===");
    System.out.println(" URI solicitada: " + request.getRequestURI());
    
    java.util.Enumeration<String> sessionAttrs = session.getAttributeNames();
    while (sessionAttrs.hasMoreElements()) {
        String attrName = sessionAttrs.nextElement();
        Object attrValue = session.getAttribute(attrName);
        System.out.println("SESSION: " + attrName + " = " + attrValue);
    }
    
    // Verificar si hay padre en sesión
    Padre padre = (Padre) session.getAttribute("padre");
    if (padre != null) {
        System.out.println(" PADRE EN SESIÓN: " + padre.getNombreCompleto());
        System.out.println(" PADRE PersonaId: " + padre.getPersonaId());
        System.out.println(" PADRE AlumnoId: " + padre.getAlumnoId());
        System.out.println(" PADRE Username: " + padre.getUsername());
    } else {
        System.out.println(" NO HAY PADRE EN SESIÓN");
    }
    
    // Intentar obtener personaId de diferentes maneras
    Integer personaId = (Integer) session.getAttribute("personaId");
    if (personaId == null && padre != null) {
        personaId = padre.getPersonaId();
        session.setAttribute("personaId", personaId);
        System.out.println(" PersonaId obtenido del objeto Padre: " + personaId);
    }
    
    System.out.println("==================================");
    
    // Resto del código original...
    List<Asistencia> ausencias = (List<Asistencia>) request.getAttribute("ausencias");
    Integer alumnoId = (Integer) request.getAttribute("alumnoId");
    String alumnoNombre = (String) request.getAttribute("alumnoNombre");
    String error = (String) request.getAttribute("error");
    String mensaje = (String) request.getAttribute("mensaje");
    
    // Si no hay datos, mostrar mensaje y botón para ir al dashboard
    if (alumnoId == null) {
%>
<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Justificar Ausencia - Sistema Escolar</title>
    <jsp:include page="includes/head.jsp" />
</head>
<body class="bg-background-light dark:bg-background-dark text-slate-800 dark:text-slate-200 min-h-screen flex transition-colors duration-200">
    <jsp:include page="includes/sidebarPadre.jsp" />
    <main class="flex-1 md:ml-64 flex flex-col min-h-screen">
        <jsp:include page="includes/header.jsp" />
        <div class="container mx-auto mt-20 px-4">
            <div class="max-w-md mx-auto bg-gradient-to-br from-yellow-50 to-yellow-100 dark:from-yellow-900/30 dark:to-yellow-800/30 border-l-4 border-yellow-500 rounded-lg p-6 shadow-lg">
                <h4 class="text-xl font-bold text-yellow-800 dark:text-yellow-300 mb-3">Información no disponible</h4>
                <p class="text-yellow-700 dark:text-yellow-400 mb-4">No se encontraron datos del estudiante. Por favor, regrese al dashboard e intente nuevamente.</p>
                <hr class="my-4 border-yellow-300 dark:border-yellow-700">
                <a href="PadreDashboardServlet" class="inline-block bg-gradient-to-r from-blue-500 to-blue-600 text-white px-6 py-3 rounded-lg font-semibold hover:from-blue-600 hover:to-blue-700 transition-all">
                    Volver al Dashboard
                </a>
            </div>
        </div>
    </main>
</body>
</html>
<%
        return;
    }
    
    // Manejar mensajes de sesión
    if (error == null) {
        error = (String) session.getAttribute("error");
        if (error != null) session.removeAttribute("error");
    }
    
    if (mensaje == null) {
        mensaje = (String) session.getAttribute("mensaje");
        if (mensaje != null) session.removeAttribute("mensaje");
    }
    
    // Asegurar que ausencias no sea null
    if (ausencias == null) {
        ausencias = new java.util.ArrayList<>();
    }
    
    String alumnoIdStr = (alumnoId != null) ? String.valueOf(alumnoId) : "";
    
    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
%>
<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Justificar Ausencia - Sistema Escolar</title>
    
    <!-- INCLUIR HEAD.JSP CON TODAS LAS CONFIGURACIONES -->
    <jsp:include page="includes/head.jsp" />
    
    <!-- SweetAlert2 -->
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    
    <style>
        body { font-family: 'Lexend', sans-serif; }
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
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
        
        .alert-warning {
            background: linear-gradient(135deg, #fef3c7, #fde68a);
            color: #92400e;
            border-left-color: #f59e0b;
        }
        
        /* Versiones oscuras de alertas */
        .dark .alert-danger {
            background: linear-gradient(135deg, #7f1d1d, #991b1b);
            color: #fecaca;
        }
        
        .dark .alert-success {
            background: linear-gradient(135deg, #064e3b, #065f46);
            color: #d1fae5;
        }
        
        .dark .alert-warning {
            background: linear-gradient(135deg, #78350f, #92400e);
            color: #fde68a;
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
        
        .dark .section-title {
            color: #60a5fa;
        }
        
        .file-upload-area {
            border: 2px dashed #93c5fd;
            border-radius: 0.75rem;
            padding: 2rem;
            text-align: center;
            background: linear-gradient(135deg, #dbeafe, #bfdbfe);
            transition: all 0.3s ease;
            cursor: pointer;
        }
        
        .file-upload-area:hover {
            border-color: #135bec;
            background: linear-gradient(135deg, #bfdbfe, #93c5fd);
        }
        
        .dark .file-upload-area {
            border: 2px dashed #1e3a8a;
            background: linear-gradient(135deg, #1e293b, #0f172a);
        }
        
        .dark .file-upload-area:hover {
            border-color: #3b82f6;
            background: linear-gradient(135deg, #334155, #1e293b);
        }
        
        .ausencia-card {
            background: white;
            border-radius: 0.75rem;
            padding: 1.5rem;
            margin-bottom: 1rem;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
            border-left: 4px solid #ef4444;
            transition: all 0.3s ease;
        }
        
        .ausencia-card:hover {
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            transform: translateY(-2px);
        }
        
        .dark .ausencia-card {
            background: #1a2233;
            border-left: 4px solid #ef4444;
        }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark text-slate-800 dark:text-slate-200 min-h-screen flex transition-colors duration-200">

    <!-- INCLUIR SIDEBAR PARA PADRE -->
    <jsp:include page="includes/sidebarPadre.jsp" />
    
    <main class="flex-1 md:ml-64 flex flex-col min-h-screen">
        
        <!-- INCLUIR HEADER -->
        <jsp:include page="includes/header.jsp" />

        <!-- Content Area -->
        <div class="p-8">
            
            <!-- Top Bar dentro del contenido - CON DARK MODE -->
            <div class="mb-8">
                <h2 class="text-2xl font-bold text-slate-800 dark:text-white">
                    <i class="fas fa-file-medical text-primary mr-2"></i>
                    Justificar Ausencia
                </h2>
                <p class="text-sm text-slate-500 dark:text-slate-400 mt-1">
                    Complete el formulario para justificar las ausencias de 
                    <% if (alumnoNombre != null) { %>
                        <strong class="text-primary dark:text-blue-400"><%= alumnoNombre %></strong>
                    <% } else { %>
                        su hijo(a)
                    <% } %>
                </p>
            </div>

            <!-- Mensajes de alerta (ya tienen soporte dark por CSS) -->
            <% if (error != null && !error.isEmpty()) { %>
            <div class="alert-modern alert-danger">
                <i class="fas fa-exclamation-circle text-2xl"></i>
                <div>
                    <strong class="block font-semibold">Error</strong>
                    <span><%= error %></span>
                </div>
            </div>
            <% } %>
            
            <% if (mensaje != null && !mensaje.isEmpty()) { %>
            <div class="alert-modern alert-success">
                <i class="fas fa-check-circle text-2xl"></i>
                <div>
                    <strong class="block font-semibold">Éxito</strong>
                    <span><%= mensaje %></span>
                </div>
            </div>
            <% } %>

            <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <!-- Formulario Principal - CON DARK MODE -->
                <div class="lg:col-span-2">
                    <div class="bg-white dark:bg-card-dark rounded-xl shadow-sm border border-gray-200 dark:border-border-dark p-6">
                        <% if (ausencias == null || ausencias.isEmpty()) { %>
                        <div class="alert-modern alert-warning">
                            <i class="fas fa-info-circle text-2xl"></i>
                            <div>
                                <strong class="block font-semibold">No hay ausencias pendientes</strong>
                                <span>El estudiante <strong class="dark:text-yellow-300"><%= alumnoNombre %></strong> no tiene ausencias pendientes de justificación en este momento.</span>
                            </div>
                        </div>
                        <div class="text-center py-8">
                            <i class="fas fa-check-circle text-6xl text-success dark:text-green-500 mb-4"></i>
                            <p class="text-lg text-gray-600 dark:text-slate-400">¡Todo al día!</p>
                        </div>
                        <% } else { %>
                        <form id="formJustificacion" action="JustificacionServlet" method="post" enctype="multipart/form-data">
                            <input type="hidden" name="accion" value="crear">
                            <input type="hidden" name="alumnoId" value="<%= alumnoIdStr %>">
                            
                            <!-- Selección de Ausencia -->
                            <div class="mb-6">
                                <h3 class="section-title">
                                    <i class="fas fa-calendar-times"></i>
                                    Seleccionar Ausencia
                                </h3>
                                <label class="block text-sm font-medium text-gray-700 dark:text-slate-300 mb-2">
                                    Ausencia a justificar <span class="text-red-500">*</span>
                                </label>
                                <select name="asistenciaId" id="asistenciaId" 
                                        class="w-full px-4 py-3 border-2 border-gray-200 dark:border-border-dark bg-white dark:bg-card-dark text-slate-800 dark:text-slate-200 rounded-lg focus:border-primary focus:ring-2 focus:ring-primary/20 transition-all"
                                        required>
                                    <option value="">-- Seleccione una ausencia --</option>
                                    <% for (Asistencia a : ausencias) { %>
                                    <option value="<%= a.getId() %>" 
                                            data-fecha="<%= a.getFecha().format(dateFormatter) %>">
                                        <%= a.getFecha().format(dateFormatter) %> - 
                                        <%= a.getCursoNombre() %> - 
                                        <%= a.getEstadoString() %>
                                    </option>
                                    <% } %>
                                </select>
                                <p class="text-xs text-gray-500 dark:text-slate-500 mt-2">
                                    <i class="fas fa-info-circle"></i>
                                    Total de ausencias sin justificar: <strong class="dark:text-slate-300"><%= ausencias.size() %></strong>
                                </p>
                            </div>

                            <!-- Tipo de Justificación -->
                            <div class="mb-6">
                                <h3 class="section-title">
                                    <i class="fas fa-list-alt"></i>
                                    Tipo de Justificación
                                </h3>
                                <label class="block text-sm font-medium text-gray-700 dark:text-slate-300 mb-2">
                                    Motivo <span class="text-red-500">*</span>
                                </label>
                                <select name="tipoJustificacion" id="tipoJustificacion" 
                                        class="w-full px-4 py-3 border-2 border-gray-200 dark:border-border-dark bg-white dark:bg-card-dark text-slate-800 dark:text-slate-200 rounded-lg focus:border-primary focus:ring-2 focus:ring-primary/20 transition-all"
                                        required>
                                    <option value="">-- Seleccione el motivo --</option>
                                    <option value="ENFERMEDAD">Enfermedad</option>
                                    <option value="EMERGENCIA_FAMILIAR">Emergencia Familiar</option>
                                    <option value="CITA_MEDICA">Cita Médica</option>
                                    <option value="OTRO">Otro</option>
                                </select>
                            </div>

                            <!-- Descripción -->
                            <div class="mb-6">
                                <h3 class="section-title">
                                    <i class="fas fa-align-left"></i>
                                    Descripción Detallada
                                </h3>
                                <label class="block text-sm font-medium text-gray-700 dark:text-slate-300 mb-2">
                                    Detalles <span class="text-red-500">*</span>
                                </label>
                                <textarea name="descripcion" id="descripcion" rows="5" 
                                          class="w-full px-4 py-3 border-2 border-gray-200 dark:border-border-dark bg-white dark:bg-card-dark text-slate-800 dark:text-slate-200 rounded-lg focus:border-primary focus:ring-2 focus:ring-primary/20 transition-all resize-none"
                                          placeholder="Describa detalladamente el motivo de la ausencia (mínimo 20 caracteres)..."
                                          required></textarea>
                                <div class="flex justify-between items-center mt-2">
                                    <p class="text-xs text-gray-500 dark:text-slate-500">
                                        <i class="fas fa-info-circle"></i>
                                        Mínimo 20 caracteres
                                    </p>
                                    <p class="text-xs text-gray-500 dark:text-slate-500" id="charCount">(0 caracteres)</p>
                                </div>
                            </div>

                            <!-- Documento Adjunto -->
                            <div class="mb-6">
                                <h3 class="section-title">
                                    <i class="fas fa-paperclip"></i>
                                    Documento de Respaldo
                                </h3>
                                <label class="block text-sm font-medium text-gray-700 dark:text-slate-300 mb-2">
                                    Archivo adjunto (opcional)
                                </label>
                                <div class="file-upload-area dark:file-upload-area" onclick="document.getElementById('archivo').click()">
                                    <i class="fas fa-cloud-upload-alt text-4xl text-primary dark:text-blue-400 mb-3"></i>
                                    <p class="text-sm font-semibold text-gray-700 dark:text-slate-300 mb-1">Click para seleccionar archivo</p>
                                    <p class="text-xs text-gray-500 dark:text-slate-400">Formatos permitidos: PDF, Word (.doc, .docx), Imágenes (JPG, PNG)</p>
                                    <p class="text-xs text-gray-500 dark:text-slate-400 mt-1">Tamaño máximo: 5MB</p>
                                </div>
                                <input type="file" name="archivo" id="archivo" 
                                       accept=".pdf,.doc,.docx,.jpg,.jpeg,.png"
                                       class="hidden" 
                                       onchange="previewFileName(this)">
                                
                                <!-- Preview del archivo - CON DARK MODE -->
                                <div id="filePreview" class="mt-3 p-4 bg-blue-50 dark:bg-blue-900/30 rounded-lg border border-blue-200 dark:border-blue-800 hidden">
                                    <div class="flex items-center justify-between">
                                        <div class="flex items-center gap-3">
                                            <i class="fas fa-file-alt text-2xl text-primary dark:text-blue-400"></i>
                                            <div>
                                                <p class="text-sm font-semibold text-gray-700 dark:text-slate-300" id="fileName"></p>
                                                <p class="text-xs text-gray-500 dark:text-slate-400">Archivo seleccionado</p>
                                            </div>
                                        </div>
                                        <button type="button" onclick="clearFile()" 
                                                class="px-3 py-1 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors text-sm">
                                            <i class="fas fa-times"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>

                            <!-- Botón de envío - CON DARK MODE -->
                            <div class="flex items-center gap-4 pt-6 border-t border-gray-200 dark:border-border-dark">
                                <button type="submit" id="btn-enviar"
                                        class="flex-1 bg-gradient-to-r from-primary to-primary-dark text-white px-6 py-4 rounded-lg font-semibold hover:shadow-lg transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2 dark:from-blue-600 dark:to-blue-800"
                                        disabled>
                                    <i class="fas fa-paper-plane"></i>
                                    <span id="btn-text">Enviar Justificación</span>
                                    <span id="btn-loading" class="hidden">
                                        <i class="fas fa-spinner fa-spin"></i> Enviando...
                                    </span>
                                </button>
                                <button type="reset" 
                                        class="px-6 py-4 bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-slate-300 rounded-lg font-semibold hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors">
                                    <i class="fas fa-redo"></i> Limpiar
                                </button>
                            </div>
                        </form>
                        <% } %>
                    </div>
                </div>

                <!-- Panel Lateral - CON DARK MODE -->
                <div class="lg:col-span-1">
                    <!-- Ausencias Pendientes -->
                    <% if (ausencias != null && !ausencias.isEmpty()) { %>
                    <div class="bg-white dark:bg-card-dark rounded-xl shadow-sm border border-gray-200 dark:border-border-dark p-6 mb-6">
                        <h3 class="section-title">
                            <i class="fas fa-exclamation-triangle"></i>
                            Ausencias Pendientes
                        </h3>
                        <div class="space-y-3 max-h-96 overflow-y-auto">
                            <% for (Asistencia a : ausencias) { %>
                            <div class="ausencia-card dark:ausencia-card">
                                <div class="flex items-start justify-between mb-2">
                                    <div class="flex-1">
                                        <p class="font-semibold text-gray-800 dark:text-slate-200 text-sm">
                                            <%= a.getCursoNombre() %>
                                        </p>
                                        <p class="text-xs text-gray-500 dark:text-slate-400 mt-1">
                                            <i class="fas fa-calendar"></i>
                                            <%= a.getFecha().format(dateFormatter) %>
                                        </p>
                                    </div>
                                    <span class="px-2 py-1 bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-400 text-xs font-semibold rounded">
                                        <%= a.getEstadoString() %>
                                    </span>
                                </div>
                            </div>
                            <% } %>
                        </div>
                        <div class="mt-4 p-3 bg-gray-50 dark:bg-gray-800 rounded-lg">
                            <p class="text-sm text-gray-600 dark:text-slate-400">
                                <strong class="text-primary dark:text-blue-400"><%= ausencias.size() %></strong> 
                                <%= ausencias.size() == 1 ? "ausencia" : "ausencias" %> 
                                pendiente<%= ausencias.size() == 1 ? "" : "s" %>
                            </p>
                        </div>
                    </div>
                    <% } %>

                    <!-- Información Importante - CON DARK MODE -->
                    <div class="bg-gradient-to-br from-blue-50 to-blue-100 dark:from-blue-900/30 dark:to-blue-800/30 rounded-xl border-2 border-blue-200 dark:border-blue-800 p-6">
                        <h3 class="font-bold text-blue-900 dark:text-blue-300 mb-4 flex items-center gap-2">
                            <i class="fas fa-info-circle text-xl"></i>
                            Información Importante
                        </h3>
                        <ul class="space-y-3 text-sm text-blue-800 dark:text-blue-300">
                            <li class="flex gap-2">
                                <i class="fas fa-check-circle text-blue-600 dark:text-blue-400 mt-1 flex-shrink-0"></i>
                                <span>Complete todos los campos obligatorios (*) del formulario.</span>
                            </li>
                            <li class="flex gap-2">
                                <i class="fas fa-file-alt text-blue-600 dark:text-blue-400 mt-1 flex-shrink-0"></i>
                                <span>Adjunte documentos de respaldo cuando sea posible (certificado médico, constancia, etc.).</span>
                            </li>
                            <li class="flex gap-2">
                                <i class="fas fa-clock text-blue-600 dark:text-blue-400 mt-1 flex-shrink-0"></i>
                                <span>Las justificaciones deben presentarse dentro de los 30 días posteriores a la ausencia.</span>
                            </li>
                            <li class="flex gap-2">
                                <i class="fas fa-user-check text-blue-600 dark:text-blue-400 mt-1 flex-shrink-0"></i>
                                <span>El docente revisará y aprobará/rechazará su justificación.</span>
                            </li>
                            <li class="flex gap-2">
                                <i class="fas fa-bell text-blue-600 dark:text-blue-400 mt-1 flex-shrink-0"></i>
                                <span>Recibirá notificación del resultado de la revisión.</span>
                            </li>
                        </ul>
                    </div>

                    <!-- Formatos Aceptados - CON DARK MODE -->
                    <div class="bg-white dark:bg-card-dark rounded-xl shadow-sm border border-gray-200 dark:border-border-dark p-6 mt-6">
                        <h3 class="font-bold text-gray-800 dark:text-white mb-3 flex items-center gap-2">
                            <i class="fas fa-file-upload"></i>
                            Formatos Aceptados
                        </h3>
                        <div class="space-y-2 text-sm">
                            <div class="flex items-center gap-2 text-gray-700 dark:text-slate-300">
                                <i class="fas fa-file-pdf text-red-500"></i>
                                <span>PDF (.pdf)</span>
                            </div>
                            <div class="flex items-center gap-2 text-gray-700 dark:text-slate-300">
                                <i class="fas fa-file-word text-blue-500"></i>
                                <span>Word (.doc, .docx)</span>
                            </div>
                            <div class="flex items-center gap-2 text-gray-700 dark:text-slate-300">
                                <i class="fas fa-file-image text-green-500"></i>
                                <span>Imágenes (.jpg, .jpeg, .png)</span>
                            </div>
                        </div>
                        <p class="text-xs text-gray-500 dark:text-slate-500 mt-3 pt-3 border-t border-gray-200 dark:border-border-dark">
                            <i class="fas fa-exclamation-triangle text-warning"></i>
                            Tamaño máximo por archivo: 5MB
                        </p>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Footer - CON DARK MODE -->
        <footer class="mt-auto py-6 text-center text-xs text-slate-400 dark:text-slate-500 border-t border-slate-100 dark:border-border-dark bg-white dark:bg-card-dark">
            &copy; 2025 Colegio San Antonio - Todos los derechos reservados.
        </footer>
    </main>

    <script>
        // ── Validación en tiempo real y habilitación del botón ──
        const campos = ['asistenciaId', 'tipoJustificacion', 'descripcion'];

        function validarFormulario() {
            const ausencia    = document.getElementById('asistenciaId')?.value;
            const tipo        = document.getElementById('tipoJustificacion')?.value;
            const descripcion = document.getElementById('descripcion')?.value?.trim();
            const btn         = document.getElementById('btn-enviar');

            const valido = ausencia && tipo && descripcion && descripcion.length >= 20;
            if (btn) {
                btn.disabled = !valido;
                btn.classList.toggle('opacity-50', !valido);
                btn.classList.toggle('cursor-not-allowed', !valido);
            }
        }

        // Contador de caracteres en textarea
        const textarea = document.getElementById('descripcion');
        if (textarea) {
            textarea.addEventListener('input', function () {
                const count = this.value.length;
                const charCount = document.getElementById('charCount');
                if (charCount) {
                    charCount.textContent = '(' + count + ' caracteres)';
                    charCount.style.color = count >= 20 ? '#16a34a' : '#ef4444';
                }
                validarFormulario();
            });
        }

        // Escuchar cambios en los select
        campos.forEach(id => {
            const el = document.getElementById(id);
            if (el) el.addEventListener('change', validarFormulario);
        });

        // Ejecutar al cargar por si hay valores previos
        validarFormulario();

        // ── Manejo del archivo adjunto ──
        function previewFileName(input) {
            const preview  = document.getElementById('filePreview');
            const fileName = document.getElementById('fileName');

            if (input.files && input.files[0]) {
                const file     = input.files[0];
                const maxSize  = 5 * 1024 * 1024; // 5 MB
                const allowed  = ['.pdf', '.doc', '.docx', '.jpg', '.jpeg', '.png'];
                const ext      = '.' + file.name.split('.').pop().toLowerCase();

                // Validar formato
                if (!allowed.includes(ext)) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Formato no permitido',
                        text: 'Solo se aceptan: PDF, Word (.doc, .docx) e imágenes (JPG, PNG)',
                        confirmButtonColor: '#135bec'
                    });
                    input.value = '';
                    if (preview) preview.classList.add('hidden');
                    return;
                }

                // Validar tamaño
                if (file.size > maxSize) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Archivo demasiado grande',
                        text: 'El tamaño máximo permitido es 5 MB. El archivo seleccionado pesa ' +
                              (file.size / 1024 / 1024).toFixed(2) + ' MB.',
                        confirmButtonColor: '#135bec'
                    });
                    input.value = '';
                    if (preview) preview.classList.add('hidden');
                    return;
                }

                // Mostrar preview
                if (fileName) fileName.textContent = file.name + ' (' + (file.size / 1024).toFixed(1) + ' KB)';
                if (preview)  preview.classList.remove('hidden');
            } else {
                if (preview) preview.classList.add('hidden');
            }
        }

        function clearFile() {
            const input   = document.getElementById('archivo');
            const preview = document.getElementById('filePreview');
            if (input)   input.value = '';
            if (preview) preview.classList.add('hidden');
        }

        // ── Drag & drop sobre el área de subida ──
        const dropArea = document.querySelector('.file-upload-area');
        if (dropArea) {
            ['dragenter', 'dragover'].forEach(evt =>
                dropArea.addEventListener(evt, e => { e.preventDefault(); dropArea.style.borderColor = '#135bec'; })
            );
            ['dragleave', 'drop'].forEach(evt =>
                dropArea.addEventListener(evt, e => { e.preventDefault(); dropArea.style.borderColor = ''; })
            );
            dropArea.addEventListener('drop', function (e) {
                const dt    = e.dataTransfer;
                const input = document.getElementById('archivo');
                if (dt.files.length && input) {
                    input.files = dt.files;
                    previewFileName(input);
                }
            });
        }

        // ── Envío del formulario con indicador de carga ──
        const form = document.getElementById('formJustificacion');
        if (form) {
            form.addEventListener('submit', function (e) {
                const btnText    = document.getElementById('btn-text');
                const btnLoading = document.getElementById('btn-loading');
                const btn        = document.getElementById('btn-enviar');

                if (btnText)    btnText.classList.add('hidden');
                if (btnLoading) btnLoading.classList.remove('hidden');
                if (btn)        btn.disabled = true;
            });
        }

        // ── Reset: limpiar preview al usar el botón Limpiar ──
        const resetBtn = document.querySelector('[type="reset"]');
        if (resetBtn) {
            resetBtn.addEventListener('click', function () {
                clearFile();
                setTimeout(() => {
                    validarFormulario();
                    const charCount = document.getElementById('charCount');
                    if (charCount) {
                        charCount.textContent = '(0 caracteres)';
                        charCount.style.color = '';
                    }
                }, 10);
            });
        }
    </script>
</body>
</html>