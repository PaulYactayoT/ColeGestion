<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Tarea, modelo.Curso, modelo.Profesor" %>

<%
    Tarea tarea = (Tarea) request.getAttribute("tarea");
    Curso curso = (Curso) request.getAttribute("curso");
    Profesor docente = (Profesor) session.getAttribute("docente");

    if (docente == null || curso == null) {
        response.sendRedirect("docenteDashboard.jsp");
        return;
    }

    boolean editar = (tarea != null);
    
    String mensaje = (String) session.getAttribute("mensaje");
    String error = (String) session.getAttribute("error");
    
    if (mensaje != null) session.removeAttribute("mensaje");
    if (error != null) session.removeAttribute("error");
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <%@ include file="includes/head.jsp" %>
    <title><%= editar ? "Editar Tarea" : "Registrar Tarea"%> - <%= curso.getNombre() %></title>
    <style>
        /* Estilos adicionales para el formulario */
        .form-card {
            background: white;
            border-radius: 0.75rem;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            border: 1px solid #e5e7eb;
            overflow: hidden;
        }
        
        .dark .form-card {
            background: #1a2233;
            border-color: #374151;
        }
        
        .form-header {
            background-color: #fff;
            padding: 1.25rem 1.5rem;
            border-bottom: 1px solid #e5e7eb;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .dark .form-header {
            background-color: #1a2233;
            border-bottom-color: #374151;
        }
        
        .form-header h5 {
            margin: 0;
            font-weight: 600;
            color: #0d6efd;
            font-size: 1rem;
        }
        
        .dark .form-header h5 {
            color: #3b82f6;
        }
        
        .form-body {
            padding: 1.5rem;
        }
        
        .form-label {
            font-weight: 500;
            font-size: 0.875rem;
            color: #374151;
            margin-bottom: 0.5rem;
            display: block;
        }
        
        .dark .form-label {
            color: #e5e7eb;
        }
        
        .form-label i {
            margin-right: 0.25rem;
            color: #0d6efd;
        }
        
        .dark .form-label i {
            color: #3b82f6;
        }
        
        .required {
            color: #dc3545;
            margin-left: 0.125rem;
            font-weight: bold;
        }
        
        .form-control, .form-select {
            width: 100%;
            padding: 0.625rem 0.75rem;
            border: 1px solid #e5e7eb;
            border-radius: 0.5rem;
            font-size: 0.875rem;
            color: #1f2937;
            transition: all 0.2s;
            background-color: #fff;
        }
        
        .dark .form-control, .dark .form-select {
            background-color: #283044;
            border-color: #4b5563;
            color: #f3f4f6;
        }
        
        .form-control:focus, .form-select:focus {
            border-color: #0d6efd;
            outline: none;
            box-shadow: 0 0 0 3px rgba(13, 110, 253, 0.1);
        }
        
        .form-control:disabled {
            background-color: #f3f4f6;
            cursor: not-allowed;
        }
        
        .dark .form-control:disabled {
            background-color: #374151;
        }
        
        textarea.form-control {
            resize: vertical;
            min-height: 100px;
        }
        
        .file-upload-box {
            border: 2px dashed #e5e7eb;
            border-radius: 0.5rem;
            padding: 1.5rem;
            text-align: center;
            background-color: #f9fafb;
            cursor: pointer;
            transition: all 0.2s;
            position: relative;
            margin-top: 0.5rem;
        }
        
        .dark .file-upload-box {
            border-color: #4b5563;
            background-color: #283044;
        }
        
        .file-upload-box:hover {
            border-color: #0d6efd;
            background-color: #f0f7ff;
        }
        
        .dark .file-upload-box:hover {
            background-color: #2d3748;
        }
        
        .file-upload-box input[type="file"] {
            position: absolute;
            width: 100%;
            height: 100%;
            top: 0;
            left: 0;
            opacity: 0;
            cursor: pointer;
        }
        
        .upload-icon {
            font-size: 1.5rem;
            color: #0d6efd;
            margin-bottom: 0.5rem;
        }
        
        .upload-text {
            font-size: 0.875rem;
            color: #4b5563;
            font-weight: 500;
        }
        
        .dark .upload-text {
            color: #e5e7eb;
        }
        
        .upload-hint {
            font-size: 0.75rem;
            color: #6b7280;
            display: block;
            margin-top: 0.25rem;
        }
        
        .file-item {
            padding: 0.625rem 0.75rem;
            background-color: #e7f1ff;
            border-radius: 0.5rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: 0.875rem;
            color: #0d6efd;
            border: 1px solid #cce5ff;
            animation: fadeIn 0.3s ease;
            margin-bottom: 0.5rem;
        }
        
        .dark .file-item {
            background-color: #1e3a8a;
            border-color: #2563eb;
            color: #bfdbfe;
        }
        
        .existing-file-item {
            background-color: #d1e7dd;
            border: 1px solid #badbcc;
            color: #0f5132;
        }
        
        .dark .existing-file-item {
            background-color: #14532d;
            border-color: #166534;
            color: #86efac;
        }
        
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-0.3125rem); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .file-info-content {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .btn-remove-file {
            background: none;
            border: none;
            color: #dc3545;
            font-size: 1rem;
            cursor: pointer;
            padding: 0.25rem;
            line-height: 1;
            transition: all 0.2s;
            border-radius: 0.25rem;
        }
        
        .btn-remove-file:hover {
            background-color: rgba(220, 53, 69, 0.1);
            transform: scale(1.1);
        }
        
        .form-actions {
            margin-top: 1.5rem;
            display: flex;
            gap: 1rem;
            justify-content: flex-end;
            padding-top: 1.25rem;
            border-top: 1px solid #e5e7eb;
        }
        
        .dark .form-actions {
            border-top-color: #374151;
        }
        
        .btn-cancel {
            background-color: white;
            color: #6b7280;
            border: 1px solid #e5e7eb;
            padding: 0.625rem 1.25rem;
            border-radius: 0.5rem;
            font-weight: 500;
            text-decoration: none;
            font-size: 0.875rem;
            transition: all 0.2s;
        }
        
        .btn-cancel:hover {
            background-color: #f3f4f6;
            color: #374151;
        }
        
        .dark .btn-cancel {
            background-color: #283044;
            color: #e5e7eb;
            border-color: #4b5563;
        }
        
        .dark .btn-cancel:hover {
            background-color: #374151;
        }
        
        .btn-save {
            background-color: #0d6efd;
            color: white;
            border: none;
            padding: 0.625rem 1.5rem;
            border-radius: 0.5rem;
            font-weight: 500;
            font-size: 0.875rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            box-shadow: 0 4px 10px rgba(13, 110, 253, 0.2);
            transition: all 0.2s;
            cursor: pointer;
        }
        
        .btn-save:hover {
            background-color: #0b4eb8;
            transform: translateY(-1px);
        }
        
        .btn-save:disabled {
            opacity: 0.5;
            cursor: not-allowed;
            transform: none;
        }
        
        .btn-outline-secondary {
            background: transparent;
            border: 1px solid #e5e7eb;
            color: #6b7280;
            padding: 0.5rem 1rem;
            border-radius: 0.5rem;
            font-size: 0.875rem;
            text-decoration: none;
            transition: all 0.2s;
        }
        
        .btn-outline-secondary:hover {
            background-color: #f3f4f6;
        }
        
        .dark .btn-outline-secondary {
            border-color: #4b5563;
            color: #e5e7eb;
        }
        
        .dark .btn-outline-secondary:hover {
            background-color: #374151;
        }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark text-[#111318] dark:text-white min-h-screen">

    <div class="flex h-screen overflow-hidden">
        <!-- Sidebar -->
        <%@ include file="includes/sidebarDocente.jsp" %>
        
        <main class="flex-1 flex flex-col overflow-y-auto">
            <!-- Header -->
            <% request.setAttribute("pageTitle", (editar ? "Editar Tarea" : "Registrar Tarea") + " - " + curso.getNombre()); %>
            <jsp:include page="includes/header.jsp" />
            
            <div class="p-8">
                <!-- Mensajes -->
                <% if (mensaje != null) { %>
                <div class="alert alert-success mb-6" role="alert">
                    <div class="flex items-center gap-2">
                        <i class="fas fa-check-circle"></i>
                        <span><%= mensaje %></span>
                    </div>
                </div>
                <% } %>
                
                <% if (error != null) { %>
                <div class="alert alert-danger mb-6" role="alert">
                    <div class="flex items-center gap-2">
                        <i class="fas fa-exclamation-circle"></i>
                        <span><%= error %></span>
                    </div>
                </div>
                <% } %>
                
                <!-- Encabezado -->
                <div class="bg-gradient-to-r from-primary to-blue-600 rounded-xl p-6 mb-8 text-white shadow-lg">
                    <div class="relative z-10">
                        <h2 class="text-2xl font-bold"><%= editar ? "Editar Tarea" : "Registrar Nueva Tarea" %></h2>
                        <p class="text-blue-100 mt-1">Curso: <strong><%= curso.getNombre() %> - <%= curso.getGradoNombre() %></strong></p>
                    </div>
                </div>
                
                <!-- Formulario -->
                <div class="form-card">
                    <div class="form-header">
                        <h5><i class="fas fa-pen-fancy me-2"></i> Detalles de la Tarea</h5>
                        <a href="TareaServlet?accion=ver&curso_id=<%= curso.getId()%>" class="btn-outline-secondary">
                            <i class="fas fa-arrow-left me-2"></i> Volver
                        </a>
                    </div>

                    <div class="form-body">
                        <form action="TareaServlet" method="post" enctype="multipart/form-data" id="tareaForm">
                            <input type="hidden" name="curso_id" value="<%= curso.getId()%>">
                            <% if (editar) {%>
                                <input type="hidden" name="accion" value="actualizar">
                                <input type="hidden" name="id" value="<%= tarea.getId()%>">
                            <% } else { %>
                                <input type="hidden" name="accion" value="guardar">
                            <% }%>

                            <input type="hidden" name="archivos_a_eliminar" id="archivos_a_eliminar" value="">

                            <div class="mb-6">
                                <label class="form-label"><i class="fas fa-book"></i> Curso Asignado</label>
                                <input type="text" class="form-control" value="<%= curso.getNombre()%> - <%= curso.getGradoNombre()%>" disabled>
                            </div>

                            <div class="mb-6">
                                <label class="form-label"><i class="fas fa-heading"></i> Nombre de la Tarea <span class="required">*</span></label>
                                <input type="text" name="nombre" class="form-control" placeholder="Ej: Trabajo de investigación sobre células" value="<%= editar ? tarea.getNombre() : ""%>" required maxlength="100">
                            </div>

                            <div class="mb-6">
                                <label class="form-label"><i class="fas fa-align-left"></i> Descripción <span class="required">*</span></label>
                                <textarea name="descripcion" class="form-control" placeholder="Describa detalladamente en qué consiste la tarea..." required><%= editar ? tarea.getDescripcion() : ""%></textarea>
                            </div>

                            <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
                                <div>
                                    <label class="form-label"><i class="fas fa-calendar-alt"></i> Fecha de Entrega <span class="required">*</span></label>
                                    <input type="date" name="fecha_entrega" id="fecha_entrega" class="form-control" value="<%= editar ? tarea.getFechaEntrega() : ""%>" required max="9999-12-31" onblur="validarAnio(this)">
                                </div>
                                
                                <div>
                                    <label class="form-label"><i class="fas fa-clock"></i> Hora Vencimiento <span class="required">*</span></label>
                                    <input type="time" name="hora_entrega" class="form-control" value="<%= (editar && tarea.getHoraEntrega() != null) ? tarea.getHoraEntrega() : "23:59" %>" required>
                                </div>
                                
                                <div>
                                    <label class="form-label"><i class="fas fa-tasks"></i> Tipo de Tarea <span class="required">*</span></label>
                                    <select name="tipo" class="form-select" required>
                                        <option value="TAREA" <%= (editar && "TAREA".equals(tarea.getTipo())) ? "selected" : "" %>>Tarea</option>
                                        <option value="EXAMEN" <%= (editar && "EXAMEN".equals(tarea.getTipo())) ? "selected" : "" %>>Examen</option>
                                        <option value="PROYECTO" <%= (editar && "PROYECTO".equals(tarea.getTipo())) ? "selected" : "" %>>Proyecto</option>
                                        <option value="TRABAJO" <%= (editar && "TRABAJO".equals(tarea.getTipo())) ? "selected" : "" %>>Trabajo</option>
                                    </select>
                                </div>
                            </div>

                            <div class="mb-6">
                                <label class="form-label"><i class="fas fa-percentage"></i> Peso en la Nota Final (%) <span class="required">*</span></label>
                                <% 
                                   int[] porcentajes = {10, 20, 30, 40, 50, 60};
                                   double pesoActual = (editar && tarea.getPeso() > 0) ? tarea.getPeso() : 0;
                                %>
                                <select name="peso" class="form-select" required>
                                    <option value="" disabled <%= (pesoActual == 0) ? "selected" : "" %>>Seleccione un porcentaje...</option>
                                    <% for(int p : porcentajes) { String selected = ((int)pesoActual == p) ? "selected" : ""; %>
                                        <option value="<%= p %>" <%= selected %>><%= p %>%</option>
                                    <% } %>
                                    <% boolean esValorEstandar = false; for(int p : porcentajes) { if((int)pesoActual == p) esValorEstandar = true; } if(pesoActual > 0 && !esValorEstandar) { %>
                                        <option value="<%= pesoActual %>" selected><%= (int)pesoActual %>% (Personalizado)</option>
                                    <% } %>
                                </select>
                            </div>

                            <div class="mb-6">
                                <label class="form-label"><i class="fas fa-list-ul"></i> Instrucciones <span class="required">*</span></label>
                                <textarea name="instrucciones" class="form-control" placeholder="Instrucciones específicas para completar la tarea..." rows="3" required><%= editar && tarea.getInstrucciones() != null ? tarea.getInstrucciones() : ""%></textarea>
                            </div>

                            <div class="mb-6">
                                <label class="form-label"><i class="fas fa-paperclip"></i> Archivos Adjuntos <span class="required">*</span></label>
                                
                                <div id="existingFilesList" class="space-y-2 mb-4">
                                    <% 
                                    if (editar && tarea.getArchivoAdjunto() != null && !tarea.getArchivoAdjunto().isEmpty()) { 
                                        String[] archivosGuardados = tarea.getArchivoAdjunto().split(",");
                                        
                                        for(String archivo : archivosGuardados) {
                                            if(archivo != null && !archivo.trim().isEmpty()) {
                                                String limpio = archivo.trim();
                                                String rowId = "file-row-" + Math.abs(limpio.hashCode());
                                    %>
                                        <div class="file-item existing-file-item" id="<%= rowId %>">
                                            <div class="file-info-content">
                                                <i class="fas fa-file-download"></i>
                                                <strong><%= limpio %></strong>
                                            </div>
                                            <button type="button" class="btn-remove-file" onclick="markFileForDeletion('<%= limpio %>', '<%= rowId %>')" title="Eliminar este archivo">
                                                <i class="fas fa-times-circle"></i>
                                            </button>
                                        </div>
                                    <% 
                                            }
                                        }
                                    } 
                                    %>
                                </div>

                                <div class="file-upload-box">
                                    <input type="file" name="archivo" id="archivoInput" accept=".pdf,.doc,.docx,.jpg,.jpeg,.png" multiple
                                           <%= (editar && tarea.getArchivoAdjunto() != null && !tarea.getArchivoAdjunto().isEmpty()) ? "" : "required" %>> 
                                    <div class="upload-icon"><i class="fas fa-cloud-upload-alt"></i></div>
                                    <div class="upload-text">Haga clic o arrastre archivos aquí</div>
                                    <span class="upload-hint">Puede seleccionar varios archivos (Máx 10MB c/u)</span>
                                </div>
                                
                                <div id="fileName" class="space-y-2 mt-4"></div>
                            </div>

                            <div class="form-actions">
                                <a href="TareaServlet?accion=ver&curso_id=<%= curso.getId()%>" class="btn-cancel">
                                    <i class="fas fa-times me-2"></i> Cancelar
                                </a>
                                <button type="submit" class="btn-save" id="submitBtn">
                                    <i class="fas fa-<%= editar ? "save" : "check" %>"></i>
                                    <%= editar ? "Guardar Cambios" : "Registrar Tarea" %>
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <script>
        function validarAnio(input) {
            if (input.value) {
                const partes = input.value.split('-');
                const anio = partes[0];
                if (anio.length > 4) {
                    input.value = anio.substring(0, 4) + '-' + partes[1] + '-' + partes[2];
                }
            }
        }

        const archivoInput = document.getElementById('archivoInput');
        const fileNameContainer = document.getElementById('fileName');
        const filesToDeleteInput = document.getElementById('archivos_a_eliminar');
        
        let fileStore = new DataTransfer();

        function verificarEstadoArchivos() {
            const archivosNuevos = fileStore.files.length;
            let archivosExistentesVisibles = 0;
            document.querySelectorAll('.existing-file-item').forEach(el => {
                if (el.style.display !== 'none') archivosExistentesVisibles++;
            });
            const total = archivosNuevos + archivosExistentesVisibles;
            archivoInput.required = (total === 0);
        }

        archivoInput.addEventListener('change', function(e) {
            const newFiles = Array.from(e.target.files);
            newFiles.forEach(file => {
                if (file.size > 10 * 1024 * 1024) { 
                    alert('El archivo "' + file.name + '" es demasiado grande.'); 
                    return; 
                }
                const validExtensions = ['.pdf', '.doc', '.docx', '.jpg', '.jpeg', '.png'];
                const fileExtension = file.name.substring(file.name.lastIndexOf('.')).toLowerCase();
                if (!validExtensions.includes(fileExtension)) { 
                    alert('Formato no permitido para "' + file.name + '".'); 
                    return; 
                }
                fileStore.items.add(file);
            });
            archivoInput.files = fileStore.files;
            renderNewFileList();
            verificarEstadoArchivos(); 
        });

        function renderNewFileList() {
            fileNameContainer.innerHTML = '';
            if (fileStore.files.length > 0) {
                Array.from(fileStore.files).forEach((file, index) => {
                    let iconClass = 'fa-file';
                    const name = file.name.toLowerCase();
                    if (name.endsWith('.pdf')) iconClass = 'fa-file-pdf';
                    else if (name.endsWith('.doc') || name.endsWith('.docx')) iconClass = 'fa-file-word';
                    else if (name.endsWith('.jpg') || name.endsWith('.png')) iconClass = 'fa-file-image';

                    const itemHtml = 
                        '<div class="file-item">' +
                            '<div class="file-info-content"><i class="fas ' + iconClass + '"></i><strong>' + file.name + '</strong></div>' +
                            '<button type="button" class="btn-remove-file" onclick="removeNewFile(' + index + ')" title="Quitar"><i class="fas fa-times-circle"></i></button>' +
                        '</div>';
                    fileNameContainer.insertAdjacentHTML('beforeend', itemHtml);
                });
            }
        }

        window.removeNewFile = function(index) {
            const newStore = new DataTransfer();
            Array.from(fileStore.files).forEach((file, i) => { if (i !== index) newStore.items.add(file); });
            fileStore = newStore;
            archivoInput.files = fileStore.files;
            renderNewFileList();
            verificarEstadoArchivos(); 
        };

        window.markFileForDeletion = function(fileName, rowId) {
            if(confirm('¿Eliminar el archivo "' + fileName + '"? Este cambio se aplicará al guardar.')) {
                document.getElementById(rowId).style.display = 'none';
                let currentToDelete = filesToDeleteInput.value;
                if(currentToDelete) {
                    filesToDeleteInput.value = currentToDelete + "," + fileName;
                } else {
                    filesToDeleteInput.value = fileName;
                }
                verificarEstadoArchivos();
            }
        };

        verificarEstadoArchivos();

        document.getElementById('tareaForm').addEventListener('submit', function(e) {
            const fechaField = document.getElementById('fecha_entrega');
            validarAnio(fechaField);

            const fechaInput = fechaField.value;
            const horaInput = document.querySelector('input[name="hora_entrega"]').value;

            const now = new Date();
            const year = now.getFullYear();
            const month = String(now.getMonth() + 1).padStart(2, '0');
            const day = String(now.getDate()).padStart(2, '0');
            const hoy = year + '-' + month + '-' + day;

            const horaActual = String(now.getHours()).padStart(2, '0') + ':' + 
                               String(now.getMinutes()).padStart(2, '0');

            if (fechaInput < hoy) {
                e.preventDefault();
                alert('La fecha de entrega no puede ser anterior a hoy.');
                return false;
            }

            if (fechaInput === hoy) {
                if (horaInput <= horaActual) { 
                    e.preventDefault();
                    alert('Si la entrega es hoy, la hora debe ser posterior a la actual (' + horaActual + ').');
                    return false;
                }
            }
            
            verificarEstadoArchivos();
            if(archivoInput.required && archivoInput.files.length === 0) {
                 e.preventDefault();
                 alert('Debes adjuntar al menos un archivo.');
                 return false;
            }

            const submitBtn = document.getElementById('submitBtn');
            submitBtn.disabled = true;
            submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Procesando...';
        });
    </script>
</body>
</html>