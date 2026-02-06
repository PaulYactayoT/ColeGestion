<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Asistencia, java.util.List, java.time.format.DateTimeFormatter" %>
<%
    // Eliminar toda la lógica de redirección inicial
    // Cargar directamente los datos del request
    List<Asistencia> ausencias = (List<Asistencia>) request.getAttribute("ausencias");
    Integer alumnoId = (Integer) request.getAttribute("alumnoId");
    String alumnoNombre = (String) request.getAttribute("alumnoNombre");
    String error = (String) request.getAttribute("error");
    String mensaje = (String) request.getAttribute("mensaje");
    
    // Si no hay datos, mostrar mensaje y botón para ir al dashboard
    if (alumnoId == null) {
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Justificar Ausencia - Sistema Escolar</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <div class="alert alert-warning text-center">
            <h4 class="alert-heading">Información no disponible</h4>
            <p>No se encontraron datos del estudiante. Por favor, regrese al dashboard e intente nuevamente.</p>
            <hr>
            <a href="PadreDashboardServlet" class="btn btn-primary">Volver al Dashboard</a>
        </div>
    </div>
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
    DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("HH:mm");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Justificar Ausencia - Sistema Escolar</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8f9fa;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .card {
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            border: none;
            border-radius: 12px;
            margin-bottom: 20px;
        }
        .card-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 12px 12px 0 0 !important;
            padding: 20px;
        }
        .info-card {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            color: white;
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 20px;
        }
        .warning-card {
            background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);
            color: #212529;
            border-radius: 12px;
            padding: 20px;
        }
        .form-control, .form-select {
            border-radius: 8px;
            border: 2px solid #e0e0e0;
            padding: 12px 16px;
            transition: all 0.3s ease;
        }
        .form-control:focus, .form-select:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border: none;
            padding: 14px 28px;
            border-radius: 8px;
            font-weight: 600;
            transition: all 0.3s ease;
        }
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.3);
        }
        .btn-primary:disabled {
            background: #6c757d;
            cursor: not-allowed;
            transform: none;
            box-shadow: none;
        }
        .badge-ausencia {
            font-size: 0.85em;
            padding: 6px 12px;
            border-radius: 20px;
        }
        .badge-ausencia.presente { background-color: #d4edda; color: #155724; }
        .badge-ausencia.ausente { background-color: #f8d7da; color: #721c24; }
        .badge-ausencia.tardanza { background-color: #fff3cd; color: #856404; }
        .badge-ausencia.justificado { background-color: #d1ecf1; color: #0c5460; }
    </style>
</head>
<body>
    <jsp:include page="header.jsp"/>

    <div class="container mt-4 mb-5">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="mb-1"><i class="bi bi-pencil-square me-2"></i> Justificar Ausencia</h2>
                <p class="text-muted mb-0">
                    Complete el formulario para justificar una ausencia del estudiante
                    <% if (alumnoNombre != null) { %>
                        <br><strong class="text-primary"><%= alumnoNombre %></strong>
                    <% } %>
                </p>
            </div>
            <a href="AsistenciaServlet?accion=verPadre" class="btn btn-outline-secondary">
                <i class="bi bi-arrow-left me-2"></i> Volver a Asistencias
            </a>
        </div>

        <!-- Mensajes de éxito/error -->
        <% if (mensaje != null && !mensaje.isEmpty()) { %>
            <div class="alert alert-success alert-dismissible fade show d-flex align-items-center" role="alert">
                <i class="bi bi-check-circle-fill me-3 fs-4"></i>
                <div class="flex-grow-1">
                    <strong class="fs-6">Éxito:</strong>
                    <div class="mt-1"><%= mensaje %></div>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } %>
        
        <% if (error != null && !error.isEmpty()) { %>
            <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-3 fs-4"></i>
                <div class="flex-grow-1">
                    <strong class="fs-6">Error:</strong>
                    <div class="mt-1"><%= error %></div>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } %>

        <!-- Advertencia si no hay ausencias -->
        <% if (ausencias.isEmpty() && alumnoId != null) { %>
            <div class="alert alert-info alert-dismissible fade show d-flex align-items-center" role="alert">
                <i class="bi bi-info-circle-fill me-3 fs-4"></i>
                <div class="flex-grow-1">
                    <strong class="fs-6">Información:</strong>
                    <div class="mt-1">No se encontraron ausencias pendientes de justificación en los últimos 30 días.</div>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } %>

        <div class="row">
            <!-- Formulario Principal -->
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header d-flex align-items-center">
                        <i class="bi bi-file-earmark-text me-3 fs-3"></i>
                        <div>
                            <h5 class="mb-0 fw-bold">Formulario de Justificación</h5>
                            <small class="opacity-75">Complete todos los campos obligatorios (*)</small>
                        </div>
                    </div>
                    <div class="card-body p-4">
                        <form method="post" action="JustificacionServlet" enctype="multipart/form-data" id="formJustificacion">
                            <input type="hidden" name="accion" value="crear">
                            <input type="hidden" name="alumnoId" value="<%= alumnoIdStr %>">
                            
                            <!-- Selección de Ausencia -->
                            <div class="mb-4">
                                <label for="asistenciaId" class="form-label fw-semibold">
                                    <i class="bi bi-calendar-x me-2"></i> Seleccione la ausencia a justificar *
                                </label>
                                <select class="form-select form-select-lg" id="asistenciaId" name="asistenciaId" required>
                                    <option value="">-- Seleccione una fecha de ausencia --</option>
                                    <% 
                                    if (ausencias != null && !ausencias.isEmpty()) {
                                        System.out.println("DEBUG JSP: Mostrando " + ausencias.size() + " ausencias");
                                        for (Asistencia a : ausencias) { 
                                            String fechaFormateada = a.getFecha() != null ? 
                                                a.getFecha().format(dateFormatter) : "Sin fecha";
                                            String horaFormateada = a.getHoraClase() != null ? 
                                                a.getHoraClase().format(timeFormatter) : "";
                                            String estado = a.getEstadoString() != null ? a.getEstadoString() : "";
                                            String cursoNombre = a.getCursoNombre() != null ? a.getCursoNombre() : "Curso";
                                            
                                            String estadoEmoji = "";
                                            String estadoClase = "";
                                            if ("AUSENTE".equals(estado)) {
                                                estadoEmoji = "❌"; 
                                                estadoClase = "ausente";
                                            } else if ("TARDANZA".equals(estado)) {
                                                estadoEmoji = "⏰"; 
                                                estadoClase = "tardanza";
                                            } else {
                                                estadoEmoji = "📋";
                                                estadoClase = "presente";
                                            }
                                    %>
                                            <option value="<%= a.getId() %>" 
                                                    data-curso="<%= cursoNombre %>"
                                                    data-fecha="<%= fechaFormateada %>"
                                                    data-hora="<%= horaFormateada %>"
                                                    data-estado="<%= estado %>">
                                                <%= estadoEmoji %> <%= fechaFormateada %> | 
                                                🕐 <%= horaFormateada %> | 
                                                📚 <%= cursoNombre %> | 
                                                <span class="badge badge-ausencia <%= estadoClase %>"><%= estado %></span>
                                            </option>
                                        <% 
                                        }
                                    } else { 
                                    %>
                                        <option value="" disabled>No hay ausencias pendientes de justificación</option>
                                    <% } %>
                                </select>
                                <div class="form-text mt-2">
                                    <% if (!ausencias.isEmpty()) { %>
                                        <i class="bi bi-info-circle me-1"></i> 
                                        Se encontraron <span class="fw-semibold"><%= ausencias.size() %></span> 
                                        ausencia<%= ausencias.size() != 1 ? "s" : "" %> pendiente<%= ausencias.size() != 1 ? "s" : "" %> de justificación
                                    <% } else { %>
                                        <i class="bi bi-check-circle me-1"></i> 
                                        No se encontraron ausencias recientes para justificar
                                    <% } %>
                                </div>
                            </div>
                            
                            <!-- Tipo de Justificación -->
                            <div class="mb-4">
                                <label for="tipoJustificacion" class="form-label fw-semibold">
                                    <i class="bi bi-tag me-2"></i> Tipo de Justificación *
                                </label>
                                <select class="form-select" id="tipoJustificacion" name="tipoJustificacion" required>
                                    <option value="">-- Seleccione un tipo de justificación --</option>
                                    <option value="ENFERMEDAD">🏥 Enfermedad (con o sin certificado médico)</option>
                                    <option value="EMERGENCIA_FAMILIAR">👨‍👩‍👧 Emergencia Familiar (situación urgente)</option>
                                    <option value="CITA_MEDICA">📋 Cita Médica (programada o de control)</option>
                                    <option value="OTRO">📝 Otro (especifique en la descripción)</option>
                                </select>
                                <div class="form-text">Seleccione el motivo principal de la ausencia</div>
                            </div>
                            
                            <!-- Descripción Detallada -->
                            <div class="mb-4">
                                <label for="descripcion" class="form-label fw-semibold">
                                    <i class="bi bi-chat-left-text me-2"></i> Descripción Detallada *
                                </label>
                                <textarea class="form-control" id="descripcion" name="descripcion" 
                                          rows="6" placeholder="Describa el motivo de la ausencia de manera detallada... 

Ejemplo: 'El estudiante presentó fiebre alta de 39°C desde la noche anterior, por lo que no pudo asistir a clases. Se le administró medicación y reposo indicado por médico.'"
                                          required></textarea>
                                <div class="form-text mt-2">
                                    <i class="bi bi-lightbulb me-1"></i> 
                                    Proporcione todos los detalles necesarios: síntomas, fechas, acciones tomadas, etc.
                                    <span id="charCount" class="ms-2 text-muted">(0 caracteres)</span>
                                </div>
                            </div>
                            
                            <!-- Documento Adjunto -->
                            <div class="mb-4">
                                <label for="archivo" class="form-label fw-semibold">
                                    <i class="bi bi-paperclip me-2"></i> Documento Adjunto (Opcional pero recomendado)
                                </label>
                                <div class="input-group">
                                    <input type="file" class="form-control" id="archivo" name="archivo" 
                                           accept=".pdf,.jpg,.jpeg,.png,.doc,.docx"
                                           onchange="previewFileName(this)">
                                    <button type="button" class="btn btn-outline-secondary" onclick="clearFile()">
                                        <i class="bi bi-x-circle"></i>
                                    </button>
                                </div>
                                <div class="form-text mt-2">
                                    <i class="bi bi-file-earmark-pdf me-1"></i> 
                                    Formatos permitidos: PDF, JPG, PNG, DOC, DOCX (máximo 5MB)
                                </div>
                                <div id="filePreview" class="mt-2 d-none">
                                    <div class="alert alert-info d-flex align-items-center p-2">
                                        <i class="bi bi-file-earmark me-2"></i>
                                        <span id="fileName"></span>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Información Importante -->
                            <div class="alert alert-info border-start border-info border-4">
                                <div class="d-flex">
                                    <i class="bi bi-info-circle-fill me-3 fs-4 text-info"></i>
                                    <div>
                                        <h6 class="alert-heading fw-bold mb-2">Importante sobre el proceso de justificación</h6>
                                        <ul class="mb-0 ps-3">
                                            <li>Las justificaciones serán revisadas por el personal docente correspondiente</li>
                                            <li>Recibirá una notificación una vez que sea aprobada o rechazada</li>
                                            <li>El plazo máximo para justificar una ausencia es de 30 días</li>
                                            <li>Puede consultar el estado en el historial de asistencias</li>
                                        </ul>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Botones de acción -->
                            <div class="d-grid gap-3">
                                <button type="submit" class="btn btn-primary btn-lg" id="btn-enviar" 
                                        <%= ausencias.isEmpty() ? "disabled" : "" %>>
                                    <i class="bi bi-send-fill me-2"></i> 
                                    <span id="btn-text">Enviar Justificación</span>
                                    <span id="btn-loading" class="d-none">
                                        <span class="spinner-border spinner-border-sm me-2" role="status"></span>
                                        Procesando...
                                    </span>
                                </button>
                                
                                <div class="d-flex gap-2">
                                    <a href="AsistenciaServlet?accion=verPadre" class="btn btn-outline-secondary flex-grow-1">
                                        <i class="bi bi-x-circle me-2"></i> Cancelar
                                    </a>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
            
            <!-- Panel de Información -->
            <div class="col-md-4">
                <!-- Tipos de Justificación -->
                <div class="info-card">
                    <h6 class="card-title fw-bold mb-3">
                        <i class="bi bi-question-circle-fill me-2"></i> Tipos de Justificación
                    </h6>
                    <hr style="border-color: rgba(255,255,255,0.3); margin: 1rem 0;">
                    <div class="mb-3">
                        <div class="d-flex align-items-start mb-2">
                            <span class="me-2">🏥</span>
                            <div>
                                <h6 class="mb-1 fw-semibold">Enfermedad</h6>
                                <small class="opacity-75">Incluye certificados médicos o justificativos de salud. 
                                Se recomienda adjuntar documento médico cuando sea posible.</small>
                            </div>
                        </div>
                    </div>
                    <div class="mb-3">
                        <div class="d-flex align-items-start mb-2">
                            <span class="me-2">👨‍👩‍👧</span>
                            <div>
                                <h6 class="mb-1 fw-semibold">Emergencia Familiar</h6>
                                <small class="opacity-75">Situaciones familiares urgentes que requieren la presencia del estudiante. 
                                Puede incluir problemas de salud familiar, trámites urgentes, etc.</small>
                            </div>
                        </div>
                    </div>
                    <div class="mb-3">
                        <div class="d-flex align-items-start mb-2">
                            <span class="me-2">📋</span>
                            <div>
                                <h6 class="mb-1 fw-semibold">Cita Médica</h6>
                                <small class="opacity-75">Consultas médicas programadas, controles, exámenes de laboratorio, 
                                vacunación, etc. Adjunte comprobante si está disponible.</small>
                            </div>
                        </div>
                    </div>
                    <div class="mb-0">
                        <div class="d-flex align-items-start">
                            <span class="me-2">📝</span>
                            <div>
                                <h6 class="mb-1 fw-semibold">Otro</h6>
                                <small class="opacity-75">Otras situaciones justificadas que no encajan en las categorías anteriores. 
                                Describa detalladamente en el campo correspondiente.</small>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Información Importante -->
                <div class="warning-card">
                    <h6 class="card-title fw-bold mb-3">
                        <i class="bi bi-exclamation-triangle-fill me-2"></i> Información Importante
                    </h6>
                    <hr style="border-color: rgba(0,0,0,0.1); margin: 1rem 0;">
                    <ul class="list-unstyled mb-0">
                        <li class="mb-3 d-flex">
                            <i class="bi bi-clock-fill me-3 text-warning fs-5"></i>
                            <div>
                                <strong class="d-block">Plazo de justificación</strong>
                                <small>Las justificaciones deben enviarse dentro de los 30 días siguientes a la ausencia.</small>
                            </div>
                        </li>
                        <li class="mb-3 d-flex">
                            <i class="bi bi-x-circle-fill me-3 text-danger fs-5"></i>
                            <div>
                                <strong class="d-block">Sin justificación</strong>
                                <small>Si no se justifica, la ausencia se mantendrá como "AUSENTE" en el registro.</small>
                            </div>
                        </li>
                        <li class="mb-3 d-flex">
                            <i class="bi bi-person-fill-check me-3 text-primary fs-5"></i>
                            <div>
                                <strong class="d-block">Revisión docente</strong>
                                <small>El docente puede solicitar información adicional si es necesario.</small>
                            </div>
                        </li>
                        <li class="d-flex">
                            <i class="bi bi-list-check me-3 text-success fs-5"></i>
                            <div>
                                <strong class="d-block">Seguimiento</strong>
                                <small>Puede ver el estado de sus justificaciones en el historial en cualquier momento.</small>
                            </div>
                        </li>
                    </ul>
                </div>
                
                <!-- Estadísticas -->
                <% if (ausencias != null && !ausencias.isEmpty()) { %>
                <div class="card mt-3">
                    <div class="card-body">
                        <h6 class="card-title fw-bold mb-3">
                            <i class="bi bi-bar-chart-fill me-2"></i> Estadísticas
                        </h6>
                        <div class="row text-center">
                            <div class="col-6 mb-3">
                                <div class="p-3 bg-light rounded">
                                    <h3 class="fw-bold text-primary mb-0"><%= ausencias.size() %></h3>
                                    <small class="text-muted">Ausencias pendientes</small>
                                </div>
                            </div>
                            <div class="col-6 mb-3">
                                <div class="p-3 bg-light rounded">
                                    <h3 class="fw-bold text-success mb-0">30</h3>
                                    <small class="text-muted">Días plazo máximo</small>
                                </div>
                            </div>
                        </div>
                        <div class="progress mt-2" style="height: 8px;">
                            <div class="progress-bar bg-success" role="progressbar" 
                                 style="width: <%= Math.min(100, (ausencias.size() * 10)) %>%" 
                                 aria-valuenow="<%= ausencias.size() %>" 
                                 aria-valuemin="0" 
                                 aria-valuemax="10">
                            </div>
                        </div>
                        <small class="text-muted mt-2 d-block">
                            <% if (ausencias.size() > 5) { %>
                                <i class="bi bi-exclamation-triangle text-warning me-1"></i>
                                Tiene varias ausencias pendientes de justificación
                            <% } else if (ausencias.size() > 0) { %>
                                <i class="bi bi-check-circle text-success me-1"></i>
                                Gestione sus ausencias pendientes oportunamente
                            <% } else { %>
                                <i class="bi bi-check-circle text-success me-1"></i>
                                No tiene ausencias pendientes
                            <% } %>
                        </small>
                    </div>
                </div>
                <% } %>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Contador de caracteres
        document.getElementById('descripcion').addEventListener('input', function() {
            const charCount = document.getElementById('charCount');
            charCount.textContent = '(' + this.value.length + ' caracteres)';
        });
        
        // Control de habilitación del botón
        document.getElementById('asistenciaId').addEventListener('change', function() {
            const btnEnviar = document.getElementById('btn-enviar');
            const btnText = document.getElementById('btn-text');
            const option = this.options[this.selectedIndex];
            
            if (this.value === '') {
                btnEnviar.disabled = true;
                btnText.textContent = 'Enviar Justificación';
            } else {
                btnEnviar.disabled = false;
                const fecha = option.getAttribute('data-fecha') || '';
                const hora = option.getAttribute('data-hora') || '';
                btnText.textContent = 'Justificar: ' + fecha + ' ' + hora;
            }
        });
        
        // Vista previa de nombre de archivo
        function previewFileName(input) {
            const filePreview = document.getElementById('filePreview');
            const fileName = document.getElementById('fileName');
            
            if (input.files && input.files[0]) {
                const file = input.files[0];
                const fileSize = (file.size / 1024 / 1024).toFixed(2); // MB
                
                if (fileSize > 5) {
                    alert('⚠️ El archivo es demasiado grande. El tamaño máximo es 5MB.');
                    input.value = '';
                    filePreview.classList.add('d-none');
                    return;
                }
                
                fileName.textContent = file.name + ' (' + fileSize + ' MB)';
                filePreview.classList.remove('d-none');
            }
        }
        
        // Limpiar archivo
        function clearFile() {
            document.getElementById('archivo').value = '';
            document.getElementById('filePreview').classList.add('d-none');
        }
        
        // Envío del formulario
        document.getElementById('formJustificacion').addEventListener('submit', function(e) {
            const btnEnviar = document.getElementById('btn-enviar');
            const btnLoading = document.getElementById('btn-loading');
            const btnText = document.getElementById('btn-text');
            
            // Validación adicional
            const asistenciaId = document.getElementById('asistenciaId').value;
            const tipo = document.getElementById('tipoJustificacion').value;
            const descripcion = document.getElementById('descripcion').value.trim();
            
            if (!asistenciaId || !tipo || !descripcion) {
                e.preventDefault();
                alert('⚠️ Complete todos los campos obligatorios antes de enviar.');
                return;
            }
            
            if (descripcion.length < 20) {
                e.preventDefault();
                alert('⚠️ La descripción debe tener al menos 20 caracteres.');
                return;
            }
            
            // Mostrar loading
            btnEnviar.disabled = true;
            btnText.classList.add('d-none');
            btnLoading.classList.remove('d-none');
            
            // Permitir el envío
            return true;
        });
        
        // Inicialización
        document.addEventListener('DOMContentLoaded', function() {
            const asistenciaSelect = document.getElementById('asistenciaId');
            if (asistenciaSelect.value === '') {
                document.getElementById('btn-enviar').disabled = true;
            }
            
            console.log('✅ Formulario de justificación cargado');
            console.log('📋 Opciones en select: ' + asistenciaSelect.options.length);
            
            // Contar solo las opciones que no son la opción por defecto
            const opcionesAusencias = Array.from(asistenciaSelect.options).filter(opt => opt.value !== "");
            console.log('📋 Ausencias disponibles para seleccionar: ' + opcionesAusencias.length);
            
            // Mostrar información de cada ausencia
            opcionesAusencias.forEach((opt, index) => {
                console.log('   Ausencia ' + (index + 1) + ': ' + opt.textContent);
            });
        });
    </script>
</body>
</html>