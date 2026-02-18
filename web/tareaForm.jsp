<%@ page contentType="text/html; charset=UTF-8" %>
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
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= editar ? "Editar Tarea" : "Registrar Tarea"%> - Colegio SA</title>
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600&display=swap" rel="stylesheet">
    
    <style>
        :root { --primary-blue: #0d6efd; --dark-blue: #0b4eb8; --bg-light: #f4f7fc; --text-dark: #333; --sidebar-width: 260px; }
        body { font-family: 'Poppins', sans-serif; background-color: var(--bg-light); margin: 0; display: flex; min-height: 100vh; }

        /* SIDEBAR */
        .sidebar { width: var(--sidebar-width); background-color: #fff; box-shadow: 2px 0 10px rgba(0,0,0,0.05); position: fixed; height: 100vh; z-index: 100; display: flex; flex-direction: column; }
        .brand { padding: 20px; display: flex; align-items: center; gap: 10px; border-bottom: 1px solid #eee; }
        .brand-logo { width: 40px; height: 40px; background-color: var(--primary-blue); border-radius: 8px; display: flex; align-items: center; justify-content: center; color: white; font-size: 20px; }
        .brand-text h4 { margin: 0; font-size: 16px; font-weight: 700; color: #1a1a1a; }
        .brand-text span { font-size: 12px; color: #777; }
        .sidebar-menu { padding: 20px 10px; flex-grow: 1; }
        .menu-item { display: flex; align-items: center; padding: 12px 15px; color: #666; text-decoration: none; border-radius: 8px; margin-bottom: 5px; transition: all 0.3s; font-size: 14px; font-weight: 500; }
        .menu-item i { margin-right: 12px; width: 20px; text-align: center; }
        .menu-item:hover { background-color: #eef2ff; color: var(--primary-blue); }
        .menu-item.active { background-color: #e0eaff; color: var(--primary-blue); font-weight: 600; }
        .sidebar-footer { padding: 20px; border-top: 1px solid #eee; }

        /* CONTENT */
        .main-content { margin-left: var(--sidebar-width); flex-grow: 1; padding: 0; display: flex; flex-direction: column; }
        .top-header { background-color: #fff; padding: 15px 30px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #eee; }
        .page-title { font-size: 18px; font-weight: 600; color: #333; margin: 0; }
        .user-profile { display: flex; align-items: center; gap: 15px; }
        .user-info { text-align: right; line-height: 1.2; }
        .user-name { font-size: 14px; font-weight: 600; display: block; }
        .user-role { font-size: 12px; color: #777; }
        .user-avatar { width: 40px; height: 40px; background-color: var(--primary-blue); color: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 600; }
        .content-wrapper { padding: 30px; max-width: 1000px; margin: 0 auto; width: 100%; }

        /* FORM */
        .form-card { background: white; border-radius: 12px; box-shadow: 0 5px 20px rgba(0,0,0,0.03); border: 1px solid #eee; overflow: hidden; }
        .form-header { background-color: #fff; padding: 20px 30px; border-bottom: 1px solid #eee; display: flex; justify-content: space-between; align-items: center; }
        .form-header h5 { margin: 0; font-weight: 600; color: var(--primary-blue); font-size: 16px; }
        .form-body { padding: 30px; }
        .form-label { font-weight: 500; font-size: 13px; color: #555; margin-bottom: 8px; }
        .form-label i { margin-right: 5px; color: var(--primary-blue); }
        .required { color: #dc3545; margin-left: 3px; font-weight: bold; }
        .form-control, .form-select { border: 1px solid #e0e0e0; border-radius: 8px; padding: 10px 15px; font-size: 14px; color: #333; transition: all 0.2s; background-color: #fcfcfc; }
        .form-control:focus, .form-select:focus { border-color: var(--primary-blue); box-shadow: 0 0 0 3px rgba(13, 110, 253, 0.1); background-color: #fff; }
        .form-control:disabled { background-color: #f0f2f5; color: #666; cursor: not-allowed; }
        textarea.form-control { resize: vertical; min-height: 120px; }

        /* ARCHIVOS */
        .file-upload-box { border: 2px dashed #dde2e5; border-radius: 8px; padding: 20px; text-align: center; background-color: #fafbfc; cursor: pointer; transition: all 0.2s; position: relative; margin-top: 10px; }
        .file-upload-box:hover { border-color: var(--primary-blue); background-color: #f0f7ff; }
        .file-upload-box input[type="file"] { position: absolute; width: 100%; height: 100%; top: 0; left: 0; opacity: 0; cursor: pointer; }
        .upload-icon { font-size: 24px; color: var(--primary-blue); margin-bottom: 10px; }
        .upload-text { font-size: 13px; color: #555; font-weight: 500; }
        .upload-hint { font-size: 11px; color: #888; display: block; margin-top: 5px; }

        /* LISTAS DE ARCHIVOS */
        #fileName, #existingFilesList { margin-top: 10px; display: flex; flex-direction: column; gap: 8px; }
        
        .file-item { padding: 10px 15px; background-color: #e7f1ff; border-radius: 6px; align-items: center; justify-content: space-between; display: flex; font-size: 13px; color: var(--primary-blue); border: 1px solid #cce5ff; animation: fadeIn 0.3s ease; }
        /* Estilo para archivos ya guardados (Verde) */
        .existing-file-item { background-color: #d1e7dd; border: 1px solid #badbcc; color: #0f5132; }
        
        @keyframes fadeIn { from { opacity: 0; transform: translateY(-5px); } to { opacity: 1; transform: translateY(0); } }
        .file-info-content { display: flex; align-items: center; gap: 10px; }
        
        .btn-remove-file { background: none; border: none; color: #dc3545; font-size: 16px; cursor: pointer; padding: 5px; line-height: 1; transition: all 0.2s; border-radius: 4px; }
        .btn-remove-file:hover { background-color: rgba(220, 53, 69, 0.1); color: #a71d2a; transform: scale(1.1); }

        .form-actions { margin-top: 30px; display: flex; gap: 15px; justify-content: flex-end; padding-top: 20px; border-top: 1px solid #eee; }
        .btn-cancel { background-color: white; color: #666; border: 1px solid #ddd; padding: 10px 20px; border-radius: 6px; font-weight: 500; text-decoration: none; font-size: 14px; transition: all 0.2s; }
        .btn-cancel:hover { background-color: #f8f9fa; color: #333; border-color: #ccc; }
        .btn-save { background-color: var(--primary-blue); color: white; border: none; padding: 10px 25px; border-radius: 6px; font-weight: 500; font-size: 14px; display: flex; align-items: center; gap: 8px; box-shadow: 0 4px 10px rgba(13, 110, 253, 0.2); transition: all 0.2s; }
        .btn-save:hover { background-color: var(--dark-blue); transform: translateY(-1px); }
        .main-footer { text-align: center; padding: 20px; color: #888; font-size: 12px; margin-top: auto; }
    </style>
</head>
<body>

    <div class="sidebar">
        <div class="brand">
            <div class="brand-logo"><i class="fas fa-graduation-cap"></i></div>
            <div class="brand-text"><h4>San Antonio</h4><span>Gestión Académica</span></div>
        </div>
        <div class="sidebar-menu">
            <a href="docenteDashboard.jsp" class="menu-item"><i class="fas fa-home"></i> Dashboard</a>
            <a href="#" class="menu-item active"><i class="fas fa-book"></i> Mis Cursos</a>
            <a href="#" class="menu-item"><i class="fas fa-chalkboard-teacher"></i> Asistencias</a>
            <a href="#" class="menu-item"><i class="fas fa-star"></i> Calificaciones</a>
        </div>
        <div class="sidebar-footer">
            <a href="LogoutServlet" class="btn btn-danger w-100 btn-sm"><i class="fas fa-sign-out-alt"></i> Cerrar Sesión</a>
        </div>
    </div>

    <div class="main-content">
        <header class="top-header">
            <h2 class="page-title"><%= editar ? "Editar Tarea" : "Registrar Nueva Tarea"%></h2>
            <div class="user-profile">
                <div class="user-info"><span class="user-name"><%= docente.getNombres() %> <%= docente.getApellidos() %></span><span class="user-role">Docente</span></div>
                <div class="user-avatar"><%= docente.getNombres().substring(0,1) %><%= docente.getApellidos().substring(0,1) %></div>
            </div>
        </header>

        <div class="content-wrapper">
            <div class="form-card">
                <div class="form-header">
                    <h5><i class="fas fa-pen-fancy me-2"></i> Detalles de la Tarea</h5>
                    <a href="TareaServlet?accion=ver&curso_id=<%= curso.getId()%>" class="btn btn-sm btn-outline-secondary"><i class="fas fa-arrow-left"></i> Volver al listado</a>
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

                        <div class="mb-4">
                            <label class="form-label"><i class="fas fa-book"></i> Curso Asignado</label>
                            <input type="text" class="form-control" value="<%= curso.getNombre()%> - <%= curso.getGradoNombre()%>" disabled>
                        </div>

                        <div class="mb-4">
                            <label class="form-label"><i class="fas fa-heading"></i> Nombre de la Tarea <span class="required">*</span></label>
                            <input type="text" name="nombre" class="form-control" placeholder="Ej: Trabajo de investigación sobre células" value="<%= editar ? tarea.getNombre() : ""%>" required maxlength="100">
                        </div>

                        <div class="mb-4">
                            <label class="form-label"><i class="fas fa-align-left"></i> Descripción <span class="required">*</span></label>
                            <textarea name="descripcion" class="form-control" placeholder="Describa detalladamente en qué consiste la tarea..." required><%= editar ? tarea.getDescripcion() : ""%></textarea>
                        </div>

                        <div class="row mb-4">
                            <div class="col-md-4">
                                <label class="form-label"><i class="fas fa-calendar-alt"></i> Fecha de Entrega <span class="required">*</span></label>
                                <input type="date" name="fecha_entrega" id="fecha_entrega" class="form-control" value="<%= editar ? tarea.getFechaEntrega() : ""%>" required max="9999-12-31" onblur="validarAnio(this)">
                            </div>
                            
                            <div class="col-md-4">
                                <label class="form-label"><i class="fas fa-clock"></i> Hora Vencimiento <span class="required">*</span></label>
                                <input type="time" name="hora_entrega" class="form-control" value="<%= (editar && tarea.getHoraEntrega() != null) ? tarea.getHoraEntrega() : "00:00" %>" required>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label"><i class="fas fa-tasks"></i> Tipo de Tarea <span class="required">*</span></label>
                                <select name="tipo" class="form-select" required>
                                    <option value="TAREA" <%= (editar && "TAREA".equals(tarea.getTipo())) ? "selected" : "" %>>Tarea</option>
                                    <option value="EXAMEN" <%= (editar && "EXAMEN".equals(tarea.getTipo())) ? "selected" : "" %>>Examen</option>
                                    <option value="PROYECTO" <%= (editar && "PROYECTO".equals(tarea.getTipo())) ? "selected" : "" %>>Proyecto</option>
                                    <option value="TRABAJO" <%= (editar && "TRABAJO".equals(tarea.getTipo())) ? "selected" : "" %>>Trabajo</option>
                                </select>
                            </div>
                        </div>

                        <div class="mb-4">
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

                        <div class="mb-4">
                            <label class="form-label"><i class="fas fa-list-ul"></i> Instrucciones <span class="required">*</span></label>
                            <textarea name="instrucciones" class="form-control" placeholder="Instrucciones específicas para completar la tarea..." rows="3" required><%= editar && tarea.getInstrucciones() != null ? tarea.getInstrucciones() : ""%></textarea>
                        </div>

                        <div class="mb-4">
                            <label class="form-label"><i class="fas fa-paperclip"></i> Archivos Adjuntos <span class="required">*</span></label>
                            
                            <div id="existingFilesList">
                                <% 
                                if (editar && tarea.getArchivoAdjunto() != null && !tarea.getArchivoAdjunto().isEmpty()) { 
                                    // Java: Separar por comas
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
                            
                            <div id="fileName"></div>
                        </div>

                        <div class="form-actions">
                            <a href="TareaServlet?accion=ver&curso_id=<%= curso.getId()%>" class="btn-cancel">Cancelar</a>
                            <button type="submit" class="btn-save" id="submitBtn">
                                <i class="fas fa-<%= editar ? "save" : "check" %>"></i>
                                <%= editar ? "Guardar Cambios" : "Registrar Tarea"%>
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <footer class="main-footer">© 2026 Colegio San Antonio - Todos los derechos reservados</footer>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // --- FUNCIÓN NUEVA PARA VALIDAR AÑO DE 4 DÍGITOS ---
        function validarAnio(input) {
            if (input.value) {
                const partes = input.value.split('-'); // Divide YYYY-MM-DD
                const anio = partes[0];
                if (anio.length > 4) {
                    // Si el año tiene más de 4 dígitos, corta a los primeros 4
                    input.value = anio.substring(0, 4) + '-' + partes[1] + '-' + partes[2];
                }
            }
        }

        // Lógica para MÚLTIPLES ARCHIVOS
        const archivoInput = document.getElementById('archivoInput');
        const fileNameContainer = document.getElementById('fileName');
        const filesToDeleteInput = document.getElementById('archivos_a_eliminar');
        
        let fileStore = new DataTransfer();

        // 1. Verificar si hay archivos (para el 'required')
        function verificarEstadoArchivos() {
            const archivosNuevos = fileStore.files.length;
            let archivosExistentesVisibles = 0;
            document.querySelectorAll('.existing-file-item').forEach(el => {
                if (el.style.display !== 'none') archivosExistentesVisibles++;
            });
            const total = archivosNuevos + archivosExistentesVisibles;
            if (total === 0) {
                archivoInput.required = true;
            } else {
                archivoInput.required = false;
            }
        }

        // 2. Manejo de Nuevos Archivos
        archivoInput.addEventListener('change', function(e) {
            const newFiles = Array.from(e.target.files);
            newFiles.forEach(file => {
                if (file.size > 10 * 1024 * 1024) { alert('El archivo "' + file.name + '" es demasiado grande.'); return; }
                const validExtensions = ['.pdf', '.doc', '.docx', '.jpg', '.jpeg', '.png'];
                const fileExtension = file.name.substring(file.name.lastIndexOf('.')).toLowerCase();
                if (!validExtensions.includes(fileExtension)) { alert('Formato no permitido para "' + file.name + '".'); return; }
                fileStore.items.add(file);
            });
            archivoInput.files = fileStore.files;
            renderNewFileList();
            verificarEstadoArchivos(); 
        });

        function renderNewFileList() {
            fileNameContainer.innerHTML = '';
            if (fileStore.files.length > 0) {
                fileNameContainer.style.display = 'flex';
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
            } else {
                fileNameContainer.style.display = 'none';
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

        // 3. Manejo de Archivos Existentes
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

        // 4. VALIDACIÓN DE FECHA Y HORA
        document.getElementById('tareaForm').addEventListener('submit', function(e) {
            // Aseguramos que el año esté corregido antes de validar
            const fechaField = document.getElementById('fecha_entrega');
            validarAnio(fechaField);

            const fechaInput = fechaField.value;
            // ✅ ACTUALIZADO: Buscamos por name="hora_entrega"
            const horaInput = document.querySelector('input[name="hora_entrega"]').value;

            const now = new Date();
            const year = now.getFullYear();
            const month = String(now.getMonth() + 1).padStart(2, '0');
            const day = String(now.getDate()).padStart(2, '0');
            const hoy = year + '-' + month + '-' + day; // YYYY-MM-DD

            const horaActual = String(now.getHours()).padStart(2, '0') + ':' + 
                               String(now.getMinutes()).padStart(2, '0'); // HH:MM

            // REGLA 1: No fechas pasadas
            if (fechaInput < hoy) {
                e.preventDefault();
                alert('La fecha de entrega no puede ser anterior a hoy.');
                return false;
            }

            // REGLA 2: Si es HOY, la hora debe ser ESTRICTAMENTE MAYOR
            if (fechaInput === hoy) {
                if (horaInput <= horaActual) { 
                    e.preventDefault();
                    alert('Si la entrega es hoy, la hora debe ser posterior a la actual (' + horaActual + ').');
                    return false;
                }
            }
            
            // Validación archivos
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