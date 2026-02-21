<%@page import="modelo.Observacion"%>
<%@page import="modelo.Alumno"%>
<%@page import="java.util.List"%>
<%@page import="modelo.Curso"%>
<%
    Curso curso = (Curso) request.getAttribute("curso");
    List<Alumno> alumnos = (List<Alumno>) request.getAttribute("alumnos");
    Observacion obs = (Observacion) request.getAttribute("observacion");
    
    // Persistencia de filtros
    String nivelSel = (request.getAttribute("nivel_sel") != null) ? (String) request.getAttribute("nivel_sel") : "";
    int gradoSel = (request.getAttribute("grado_sel") != null) ? (int) request.getAttribute("grado_sel") : 0;
    int turnoSel = 0;
    Object turnoAttr = request.getAttribute("turno_sel");
    if (turnoAttr != null) {
        turnoSel = Integer.parseInt(turnoAttr.toString());
    }

    String titulo = (obs != null) ? "Editar Observacion" : "Nueva Observacion";
    boolean editar = (obs != null);
    
    String mensaje = (String) session.getAttribute("mensaje");
    String error = (String) session.getAttribute("error");
    
    if (mensaje != null) session.removeAttribute("mensaje");
    if (error != null) session.removeAttribute("error");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <%@ include file="includes/head.jsp" %>
    <title><%= titulo %> - <%= curso != null ? curso.getNombre() : "" %></title>
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
            display: inline-flex;
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
        
        .footer-custom {
            background-color: #111827;
            color: white;
            padding: 2rem 0;
            margin-top: 2rem;
        }
        
        .dark .footer-custom {
            background-color: #0f172a;
        }
        
        .course-badge {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 0.5rem 1rem;
            border-radius: 2rem;
            color: white;
            font-size: 0.875rem;
            font-weight: 500;
        }
        
        /* Estilo para las opciones de tipo de conducta */
        .tipo-option {
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 0.75rem;
            border: 2px solid #e5e7eb;
            border-radius: 0.75rem;
            cursor: pointer;
            transition: all 0.2s;
        }
        
        .dark .tipo-option {
            border-color: #4b5563;
        }
        
        .tipo-option.selected {
            border-color: #0d6efd;
            background-color: rgba(13, 110, 253, 0.05);
        }
        
        .dark .tipo-option.selected {
            background-color: rgba(59, 130, 246, 0.1);
        }
        
        .tipo-option i {
            font-size: 1.5rem;
            margin-bottom: 0.25rem;
        }
        
        .tipo-option span {
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
        }
        
        /* Filtros */
        .filtros-container {
            background-color: #f8fafc;
            border-radius: 0.75rem;
            padding: 1.5rem;
            margin-bottom: 2rem;
            border: 1px solid #e5e7eb;
        }
        
        .dark .filtros-container {
            background-color: #1e293b;
            border-color: #374151;
        }
        
        .step-indicator {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin-bottom: 1rem;
        }
        
        .step-number {
            background-color: #0d6efd;
            color: white;
            width: 1.75rem;
            height: 1.75rem;
            border-radius: 9999px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.875rem;
            font-weight: 600;
        }
        
        .step-text {
            font-weight: 600;
            color: #1f2937;
            text-transform: uppercase;
            font-size: 0.75rem;
            letter-spacing: 0.05em;
        }
        
        .dark .step-text {
            color: #e5e7eb;
        }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark text-[#111318] dark:text-white min-h-screen flex flex-col">

    <div class="flex flex-1 h-screen overflow-hidden">
        <!-- Sidebar (Docente) -->
        <%@ include file="includes/sidebarDocente.jsp" %>
        
        <main class="flex-1 flex flex-col overflow-y-auto">
            <!-- Header -->
            <% request.setAttribute("pageTitle", titulo + " - " + (curso != null ? curso.getNombre() : "")); %>
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
                
                <!-- Encabezado del curso -->
                <div class="bg-gradient-to-r from-primary to-blue-600 rounded-xl p-6 mb-8 text-white shadow-lg">
                    <div class="relative z-10 flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
                        <div>
                            <h2 class="text-2xl font-bold"><%= titulo %></h2>
                            <p class="text-blue-100 mt-1">
                                Curso: <strong><%= curso != null ? curso.getNombre() : "" %></strong>
                                <% if (curso != null) { %> - <%= curso.getGradoNombre() %><% } %>
                            </p>
                        </div>
                        <span class="course-badge">
                            <i class="fas fa-users mr-2"></i>
                            <%= alumnos != null ? alumnos.size() : 0 %> alumnos en el aula
                        </span>
                    </div>
                </div>
                
                <!-- Formulario principal -->
                <div class="form-card max-w-3xl mx-auto">
                    <div class="form-header">
                        <h5><i class="fas fa-<%= editar ? "edit" : "plus-circle" %> me-2"></i> 
                            <%= titulo %>
                        </h5>
                    </div>

                    <div class="form-body">
                        <!-- FILTROS (PASO 1) -->
                        <div class="filtros-container">
                            <div class="step-indicator">
                                <span class="step-number">1</span>
                                <span class="step-text">Filtrar Alumnos por Salon</span>
                            </div>
                            
                            <form action="ObservacionServlet" method="GET" class="grid grid-cols-1 md:grid-cols-3 gap-4">
                                <input type="hidden" name="accion" value="registrar">
                                <input type="hidden" name="curso_id" value="<%= curso != null ? curso.getId() : 0 %>">
                                
                                
                                <div>
                                <label class="form-label">Nivel</label>
                                <select name="nivel" class="form-select" disabled>
                                    <option value="SECUNDARIA" <%= "SECUNDARIA".equals(nivelSel) ? "selected" : "" %>>Secundaria</option>
                                </select>
                            </div>
                            <div>
                                <label class="form-label">Grado</label>
                                <select name="grado_id" class="form-select" disabled>
                                    <option value="">-- Seleccionar --</option>
                                    <option value="21" <%= gradoSel == 21 ? "selected" : "" %>>1° Año</option>
                                    <option value="22" <%= gradoSel == 22 ? "selected" : "" %>>2° Año</option>
                                    <option value="23" <%= gradoSel == 23 ? "selected" : "" %>>3° Año</option>
                                    <option value="24" <%= gradoSel == 24 ? "selected" : "" %>>4° Año</option>
                                    <option value="25" <%= gradoSel == 25 ? "selected" : "" %>>5° Año</option>
                                </select>
                            </div>
                            <div>
                                <label class="form-label">Turno</label>
                                <select name="turno_id" class="form-select" disabled>
                                    <option value="">-- Seleccionar --</option>
                                    <option value="1" <%= turnoSel == 1 ? "selected" : "" %>>Mañana</option>
                                    <option value="2" <%= turnoSel == 2 ? "selected" : "" %>>Tarde</option>
                                </select>
                            </div>
                            </form>
                        </div>

                        <!-- FORMULARIO DE OBSERVACIoN (PASO 2) -->
                        <form action="ObservacionServlet" method="POST" enctype="multipart/form-data" id="obsForm">
                            <input type="hidden" name="id" value="<%= (obs != null) ? obs.getId() : "0" %>">
                            <input type="hidden" name="curso_id" value="<%= curso != null ? curso.getId() : 0 %>">
                            
                            <div class="step-indicator mb-4">
                                <span class="step-number">2</span>
                                <span class="step-text">Detalles de la Observacion</span>
                            </div>
                            
                            <div class="mb-6">
                                <label class="form-label">
                                    <i class="fas fa-user-graduate"></i> Alumno <span class="text-red-500">*</span>
                                </label>
                                <select name="alumno_id" class="form-select" required>
                                    <% if (alumnos != null && !alumnos.isEmpty()) { %>
                                        <option value="">-- Seleccione al alumno --</option>
                                        <% for (Alumno a : alumnos) { %>
                                        <option value="<%= a.getId() %>" <%= (obs != null && obs.getAlumnoId() == a.getId()) ? "selected" : "" %>>
                                            <%= a.getApellidos().toUpperCase() %>, <%= a.getNombres() %>
                                        </option>
                                        <% } %>
                                    <% } else { %>
                                        <option value="">No hay alumnos (Use el filtro arriba)</option>
                                    <% } %>
                                </select>
                            </div>
                            
                            <div class="mb-6">
                                <label class="form-label">
                                    <i class="fas fa-tag"></i> Tipo de Conducta <span class="text-red-500">*</span>
                                </label>
                                <div class="grid grid-cols-3 gap-3">
                                    <% 
                                        String tipoPositivaChecked = (obs != null && "POSITIVA".equals(obs.getTipo())) ? "selected" : "";
                                        String tipoNegativaChecked = (obs != null && "NEGATIVA".equals(obs.getTipo())) ? "selected" : (obs == null ? "selected" : "");
                                        String tipoNeutralChecked = (obs != null && "NEUTRAL".equals(obs.getTipo())) ? "selected" : "";
                                    %>
                                    <label class="tipo-option <%= tipoPositivaChecked %>" data-value="POSITIVA">
                                        <input type="radio" name="tipo" value="POSITIVA" <%= "selected".equals(tipoPositivaChecked) ? "checked" : "" %> required class="hidden">
                                        <i class="fas fa-smile text-green-500"></i>
                                        <span class="text-green-700 dark:text-green-400">Positiva</span>
                                    </label>
                                    <label class="tipo-option <%= tipoNegativaChecked %>" data-value="NEGATIVA">
                                        <input type="radio" name="tipo" value="NEGATIVA" <%= "selected".equals(tipoNegativaChecked) ? "checked" : "" %> class="hidden">
                                        <i class="fas fa-frown text-red-500"></i>
                                        <span class="text-red-700 dark:text-red-400">Negativa</span>
                                    </label>
                                    <label class="tipo-option <%= tipoNeutralChecked %>" data-value="NEUTRAL">
                                        <input type="radio" name="tipo" value="NEUTRAL" <%= "selected".equals(tipoNeutralChecked) ? "checked" : "" %> class="hidden">
                                        <i class="fas fa-meh text-blue-500"></i>
                                        <span class="text-blue-700 dark:text-blue-400">Neutral</span>
                                    </label>
                                </div>
                            </div>
                            
                            <div class="mb-6">
                                <label class="form-label">
                                    <i class="fas fa-align-left"></i> Descripcion <span class="text-red-500">*</span>
                                </label>
                                <textarea name="texto" rows="4" class="form-control" placeholder="Escriba aqui los detalles..." required><%= (obs != null) ? obs.getTexto() : "" %></textarea>
                            </div>
                            
                            <div class="mb-6">
                                <label class="form-label">
                                    <i class="fas fa-paperclip"></i> Evidencia (Opcional)
                                </label>
                                <div class="border-2 border-dashed border-gray-300 dark:border-gray-600 rounded-lg p-4" id="dropZone">
                                    <input type="file" name="evidencia" id="evidenciaInput" accept=".jpg,.jpeg,.png,.pdf,.docx" class="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100 dark:file:bg-gray-700 dark:file:text-blue-400">
                                    <p class="mt-2 text-xs text-gray-400"><i class="fas fa-info-circle mr-1"></i> Formatos permitidos: JPG, JPEG, PNG, PDF, DOCX &mdash; Maximo 5MB</p>
                                    <div id="fileError" style="display:none;" class="mt-2 flex items-center gap-2 bg-red-50 border border-red-300 text-red-700 rounded-lg px-3 py-2 text-sm font-medium">
                                        <i class="fas fa-exclamation-triangle text-red-500"></i>
                                        <span id="fileErrorMsg"></span>
                                    </div>
                                    <div id="fileOk" style="display:none;" class="mt-2 flex items-center gap-2 bg-green-50 border border-green-300 text-green-700 rounded-lg px-3 py-2 text-sm font-medium">
                                        <i class="fas fa-check-circle text-green-500"></i>
                                        <span id="fileOkMsg"></span>
                                    </div>
                                    <% if (obs != null && obs.getRutaEvidencia() != null && !obs.getRutaEvidencia().isEmpty()) { %>
                                        <div class="mt-2 text-xs text-blue-600 dark:text-blue-400 bg-blue-50 dark:bg-gray-800 p-2 rounded border border-blue-100 dark:border-blue-900">
                                            <i class="fas fa-file mr-1"></i> Archivo actual: <%= obs.getRutaEvidencia() %>
                                        </div>
                                    <% } %>
                                </div>
                            </div>
                            
                            <div class="flex justify-end gap-3">
                                <a href="ObservacionServlet?accion=listar&curso_id=<%= curso != null ? curso.getId() : 0 %>" class="btn-cancel">
                                    <i class="fas fa-times mr-2"></i> Cancelar
                                </a>
                                <button type="submit" class="btn-save" id="submitBtn">
                                    <i class="fas fa-save"></i>
                                    Guardar Observacion
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
                
                <!-- Info box -->
                <div class="mt-6 p-4 bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg max-w-3xl mx-auto">
                    <div class="flex items-start gap-3">
                        <span class="material-symbols-outlined text-blue-600 dark:text-blue-400 mt-0.5">
                            info
                        </span>
                        <div>
                            <h4 class="font-medium text-blue-800 dark:text-blue-300">Informacion importante:</h4>
                            <ul class="mt-2 text-sm text-blue-700 dark:text-blue-400 space-y-1">
                                <li>? Las observaciones son visibles para los padres de familia</li>
                                <li>? Puedes adjuntar una imagen o PDF como evidencia (opcional)</li>
                                <li>? La conducta positiva refuerza el buen comportamiento</li>
                                <li>? La conducta negativa debe incluir una descripcion clara del incidente</li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <script>
        // Resaltar la opcion de tipo seleccionada
        document.querySelectorAll('.tipo-option').forEach(option => {
            option.addEventListener('click', function() {
                document.querySelectorAll('.tipo-option').forEach(opt => {
                    opt.classList.remove('selected');
                });
                this.classList.add('selected');
                const radio = this.querySelector('input[type="radio"]');
                if (radio) radio.checked = true;
            });
        });

        // --- VALIDACION DE ARCHIVO EN TIEMPO REAL ---
        const fileInput   = document.getElementById('evidenciaInput');
        const fileError   = document.getElementById('fileError');
        const fileErrorMsg= document.getElementById('fileErrorMsg');
        const fileOk      = document.getElementById('fileOk');
        const fileOkMsg   = document.getElementById('fileOkMsg');
        const submitBtn   = document.getElementById('submitBtn');
        const allowed     = ['.jpg', '.jpeg', '.png', '.pdf', '.docx'];
        const maxSize     = 5 * 1024 * 1024; // 5MB
        let fileValido    = true;

        function mostrarError(msg) {
            fileError.style.display = 'flex';
            fileErrorMsg.textContent = msg;
            fileOk.style.display = 'none';
            submitBtn.disabled = true;
            submitBtn.style.opacity = '0.5';
            submitBtn.style.cursor = 'not-allowed';
            fileValido = false;
        }

        function mostrarOk(msg) {
            fileOk.style.display = 'flex';
            fileOkMsg.textContent = msg;
            fileError.style.display = 'none';
            submitBtn.disabled = false;
            submitBtn.style.opacity = '1';
            submitBtn.style.cursor = 'pointer';
            fileValido = true;
        }

        function limpiarEstado() {
            fileError.style.display = 'none';
            fileOk.style.display = 'none';
            submitBtn.disabled = false;
            submitBtn.style.opacity = '1';
            submitBtn.style.cursor = 'pointer';
            fileValido = true;
        }

        fileInput.addEventListener('change', function() {
            if (!this.files || this.files.length === 0) {
                limpiarEstado();
                return;
            }
            const file = this.files[0];
            const fileName = file.name.toLowerCase();
            const ext = '.' + fileName.split('.').pop();
            const esValido = allowed.includes(ext);

            if (!esValido) {
                this.value = '';
                mostrarError('Formato "' + ext + '" no permitido. Solo se aceptan: JPG, JPEG, PNG, PDF, DOCX.');
                return;
            }
            if (file.size > maxSize) {
                this.value = '';
                mostrarError('El archivo supera el limite de 5MB. Peso actual: ' + (file.size / 1024 / 1024).toFixed(2) + 'MB.');
                return;
            }
            mostrarOk('Archivo valido: ' + file.name + ' (' + (file.size / 1024).toFixed(0) + ' KB)');
        });

        // Validacion final al enviar (doble seguridad)
        document.getElementById('obsForm').addEventListener('submit', function(e) {
            e.preventDefault();
            if (!fileValido) return;

            submitBtn.disabled = true;
            submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Procesando...';
            this.submit();
        });
    </script>
</body>
</html>