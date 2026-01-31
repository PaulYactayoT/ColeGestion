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
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #E3F2FD 0%, #BBDEFB 100%);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        /* HEADER - NUEVO DISEÑO */
        .main-header {
            background-color: #1a1a1a;
            color: #ffffff;
            padding: 12px 0;
            box-shadow: 0 2px 10px rgba(0,0,0,0.2);
        }
        
        .header-content {
            max-width: 1400px;
            margin: 0 auto;
            padding: 0 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .header-left {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        
        .logo-img {
            width: 40px;
            height: 40px;
            object-fit: contain;
        }
        
        .header-title {
            font-size: 20px;
            font-weight: 600;
            color: #ffffff;
        }
        
        .header-right {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .header-user {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 14px;
            color: #ffffff;
        }
        
        .btn-logout {
            display: flex;
            align-items: center;
            gap: 6px;
            background-color: transparent;
            border: 1px solid #ffffff;
            color: #ffffff;
            padding: 6px 16px;
            border-radius: 6px;
            font-size: 13px;
            text-decoration: none;
            transition: all 0.3s ease;
        }
        
        .btn-logout:hover {
            background-color: #ffffff;
            color: #1a1a1a;
        }

        /* MAIN CONTAINER */
        .main-container {
            flex: 1;
            max-width: 900px;
            margin: 40px auto;
            padding: 0 20px;
            width: 100%;
        }

        /* PAGE HEADER CON BOTÓN DE VOLVER */
        .page-header {
            background: linear-gradient(135deg, #2196F3 0%, #1976D2 100%);
            color: white;
            padding: 30px;
            border-radius: 12px;
            margin-bottom: 30px;
            box-shadow: 0 4px 15px rgba(33, 150, 243, 0.3);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .page-header-left h1 {
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 8px;
        }
        
        .page-header-left p {
            font-size: 15px;
            opacity: 0.95;
            margin: 0;
        }
        
        .btn-back {
            display: flex;
            align-items: center;
            gap: 8px;
            background-color: rgba(255, 255, 255, 0.2);
            color: #ffffff;
            padding: 10px 20px;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 600;
            font-size: 14px;
            transition: all 0.3s ease;
            border: 1px solid rgba(255, 255, 255, 0.3);
        }
        
        .btn-back:hover {
            background-color: rgba(255, 255, 255, 0.3);
            transform: translateY(-2px);
            color: #ffffff;
        }

        /* CARD */
        .form-card {
            background: white;
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.15);
            overflow: hidden;
        }

        .form-card-header {
            background: linear-gradient(135deg, #2196F3 0%, #1976D2 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }

        .form-card-header h2 {
            margin: 0;
            font-size: 2rem;
            font-weight: 600;
        }

        .form-card-header p {
            margin: 10px 0 0 0;
            opacity: 0.95;
            font-size: 1rem;
        }

        .form-card-body {
            padding: 40px;
        }

        /* FORM STYLES */
        .form-group {
            margin-bottom: 25px;
        }

        .form-label {
            color: #1a1a1a;
            font-weight: 600;
            font-size: 0.95rem;
            margin-bottom: 8px;
            display: block;
        }

        .form-label .required {
            color: #f44336;
            margin-left: 3px;
        }

        .form-control, .form-select {
            border: 2px solid #E0E0E0;
            border-radius: 10px;
            padding: 12px 15px;
            font-size: 1rem;
            color: #1a1a1a;
            transition: all 0.3s ease;
            background: #FAFAFA;
        }

        .form-control:focus, .form-select:focus {
            border-color: #2196F3;
            box-shadow: 0 0 0 0.2rem rgba(33, 150, 243, 0.15);
            background: white;
        }

        .form-control:disabled {
            background: #F5F5F5;
            color: #757575;
            cursor: not-allowed;
        }

        textarea.form-control {
            resize: vertical;
            min-height: 120px;
        }

        /* FILE INPUT CUSTOM */
        .file-input-wrapper {
            position: relative;
            overflow: hidden;
            display: inline-block;
            width: 100%;
        }

        .file-input-wrapper input[type=file] {
            position: absolute;
            left: -9999px;
        }

        .file-input-label {
            display: flex;
            align-items: center;
            gap: 15px;
            padding: 15px;
            background: #FAFAFA;
            border: 2px dashed #BDBDBD;
            border-radius: 10px;
            cursor: pointer;
            transition: all 0.3s ease;
            color: #1a1a1a;
        }

        .file-input-label:hover {
            background: #F5F5F5;
            border-color: #2196F3;
        }

        .file-input-label i {
            font-size: 2rem;
            color: #2196F3;
        }

        .file-input-text {
            flex: 1;
        }

        .file-input-text strong {
            display: block;
            margin-bottom: 5px;
            color: #1a1a1a;
        }

        .file-input-text small {
            color: #757575;
        }

        .file-name {
            margin-top: 10px;
            padding: 10px;
            background: #E3F2FD;
            border-radius: 8px;
            color: #1976D2;
            font-size: 0.9rem;
            display: none;
        }

        .file-name i {
            margin-right: 8px;
        }

        /* CURRENT FILE DISPLAY */
        .current-file {
            margin-top: 10px;
            padding: 12px;
            background: #E8F5E9;
            border-left: 4px solid #4CAF50;
            border-radius: 8px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .current-file i {
            color: #4CAF50;
            font-size: 1.2rem;
        }

        .current-file a {
            color: #2E7D32;
            text-decoration: none;
            font-weight: 500;
        }

        .current-file a:hover {
            text-decoration: underline;
        }

        /* ROW FOR TWO COLUMNS */
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }

        @media (max-width: 768px) {
            .form-row {
                grid-template-columns: 1fr;
            }
        }

        /* BUTTONS */
        .form-actions {
            display: flex;
            gap: 15px;
            justify-content: flex-end;
            margin-top: 35px;
            padding-top: 25px;
            border-top: 2px solid #F5F5F5;
        }

        .btn {
            padding: 12px 30px;
            border-radius: 25px;
            font-weight: 600;
            font-size: 1rem;
            border: none;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-block;
        }

        .btn-primary {
            background: linear-gradient(135deg, #2196F3 0%, #1976D2 100%);
            color: white;
            box-shadow: 0 4px 15px rgba(33, 150, 243, 0.3);
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(33, 150, 243, 0.4);
        }

        .btn-secondary {
            background: #E0E0E0;
            color: #424242;
        }

        .btn-secondary:hover {
            background: #BDBDBD;
            color: #1a1a1a;
        }

        /* FOOTER */
        .footer {
            background: linear-gradient(135deg, #1a1a1a 0%, #2d2d2d 100%);
            color: white;
            padding: 30px 0;
            margin-top: auto;
        }

        .footer-content {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 30px;
        }

        .footer-section h5 {
            font-size: 1.1rem;
            margin-bottom: 15px;
            font-weight: 600;
        }

        .footer-section p, .footer-section a {
            font-size: 0.9rem;
            margin-bottom: 8px;
            color: rgba(255,255,255,0.8);
            text-decoration: none;
            display: block;
        }

        .footer-section a:hover {
            color: white;
        }

        .footer-logo {
            width: 80px;
            height: 80px;
            margin-bottom: 15px;
        }

        .footer-bottom {
            text-align: center;
            padding-top: 20px;
            margin-top: 20px;
            border-top: 1px solid rgba(255,255,255,0.1);
            font-size: 0.85rem;
            opacity: 0.7;
        }

        /* LOADING ANIMATION */
        .btn-primary:disabled {
            opacity: 0.7;
            cursor: not-allowed;
        }

        /* RESPONSIVO */
        @media (max-width: 768px) {
            .header-content {
                flex-direction: column;
                gap: 10px;
                text-align: center;
            }
            
            .page-header {
                flex-direction: column;
                gap: 15px;
                text-align: center;
            }
        }
    </style>
</head>
<body>
    <!-- HEADER -->
    <header class="main-header">
        <div class="header-content">
            <div class="header-left">
                <img src="assets/img/logosa.png" alt="Logo" class="logo-img">
                <span class="header-title">Colegio SA</span>
            </div>
            <div class="header-right">
                <div class="header-user">
                    <i class="bi bi-person-circle"></i>
                    <span><%= docente.getNombres()%> <%= docente.getApellidos()%></span>
                </div>
                <a href="LogoutServlet" class="btn-logout">
                    <i class="bi bi-box-arrow-right"></i>
                    <span>Cerrar sesión</span>
                </a>
            </div>
        </div>
    </header>

    <!-- PAGE HEADER CON BOTÓN VOLVER -->
    <div class="main-container">
        <div class="page-header">
            <div class="page-header-left">
                <h1>
                    <i class="fas fa-<%= editar ? "edit" : "plus-circle" %>"></i>
                    <%= editar ? "Editar Tarea" : "Registrar Nueva Tarea"%>
                </h1>
                <p>
                    <i class="fas fa-book"></i> <%= curso.getNombre()%> - <%= curso.getGradoNombre()%>
                </p>
            </div>
            <a href="TareaServlet?accion=ver&curso_id=<%= curso.getId()%>" class="btn-back">
                <i class="bi bi-arrow-left-circle"></i>
                <span>Volver a Tareas</span>
            </a>
        </div>

        <!-- MAIN CONTENT -->
        <div class="form-card">
            <div class="form-card-body">
                <form action="TareaServlet" method="post" enctype="multipart/form-data" id="tareaForm">
                    <input type="hidden" name="curso_id" value="<%= curso.getId()%>">
                    
                    <%-- MODO EDICIÓN O CREACIÓN --%>
                    <% if (editar) {%>
                        <input type="hidden" name="accion" value="actualizar">
                        <input type="hidden" name="id" value="<%= tarea.getId()%>">
                    <% } else { %>
                        <input type="hidden" name="accion" value="guardar">
                    <% }%>

                    <!-- CURSO (SOLO LECTURA) -->
                    <div class="form-group">
                        <label class="form-label">
                            <i class="fas fa-book"></i> Curso Asignado
                        </label>
                        <input type="text" class="form-control" value="<%= curso.getNombre()%> - <%= curso.getGradoNombre()%>" disabled>
                    </div>

                    <!-- NOMBRE DE LA TAREA -->
                    <div class="form-group">
                        <label class="form-label">
                            <i class="fas fa-heading"></i> Nombre de la Tarea<span class="required">*</span>
                        </label>
                        <input type="text" name="nombre" class="form-control" 
                               placeholder="Ej: Trabajo de investigación sobre células"
                               value="<%= editar ? tarea.getNombre() : ""%>" 
                               required maxlength="100">
                    </div>

                    <!-- DESCRIPCIÓN -->
                    <div class="form-group">
                        <label class="form-label">
                            <i class="fas fa-align-left"></i> Descripción<span class="required">*</span>
                        </label>
                        <textarea name="descripcion" class="form-control" 
                                  placeholder="Describa detalladamente en qué consiste la tarea..."
                                  required><%= editar ? tarea.getDescripcion() : ""%></textarea>
                    </div>

                    <!-- ROW: FECHA Y TIPO -->
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-calendar-alt"></i> Fecha de Entrega<span class="required">*</span>
                            </label>
                            <input type="date" name="fecha_entrega" class="form-control" 
                                   value="<%= editar ? tarea.getFechaEntrega() : ""%>" required>
                        </div>

                        <div class="form-group">
                            <label class="form-label">
                                <i class="fas fa-tasks"></i> Tipo de Tarea<span class="required">*</span>
                            </label>
                            <select name="tipo" class="form-select" required>
                                <option value="TAREA" <%= (editar && "TAREA".equals(tarea.getTipo())) ? "selected" : "" %>>Tarea</option>
                                <option value="EXAMEN" <%= (editar && "EXAMEN".equals(tarea.getTipo())) ? "selected" : "" %>>Examen</option>
                                <option value="PROYECTO" <%= (editar && "PROYECTO".equals(tarea.getTipo())) ? "selected" : "" %>>Proyecto</option>
                                <option value="TRABAJO" <%= (editar && "TRABAJO".equals(tarea.getTipo())) ? "selected" : "" %>>Trabajo</option>
                            </select>
                        </div>
                    </div>

                    <!-- PESO -->
                    <div class="form-group">
                        <label class="form-label">
                            <i class="fas fa-percentage"></i> Peso en la Nota Final (%)
                        </label>
                        <input type="number" name="peso" class="form-control" 
                               placeholder="Ej: 10"
                               value="<%= editar && tarea.getPeso() > 0 ? tarea.getPeso() : ""%>" 
                               min="0" max="100" step="0.01">
                        <small class="text-muted">Valor entre 0 y 100</small>
                    </div>

                    <!-- INSTRUCCIONES -->
                    <div class="form-group">
                        <label class="form-label">
                            <i class="fas fa-clipboard-list"></i> Instrucciones Adicionales
                        </label>
                        <textarea name="instrucciones" class="form-control" 
                                  placeholder="Instrucciones específicas para completar la tarea..."
                                  rows="4"><%= editar && tarea.getInstrucciones() != null ? tarea.getInstrucciones() : ""%></textarea>
                    </div>

                    <!-- ARCHIVO ADJUNTO -->
                    <div class="form-group">
                        <label class="form-label">
                            <i class="fas fa-paperclip"></i> Archivo Adjunto (PDF)
                        </label>
                        
                        <% if (editar && tarea.getArchivoAdjunto() != null && !tarea.getArchivoAdjunto().isEmpty()) { %>
                            <div class="current-file">
                                <i class="fas fa-file-pdf"></i>
                                <span>Archivo actual: 
                                    <a href="uploads/<%= tarea.getArchivoAdjunto()%>" target="_blank">
                                        <%= tarea.getArchivoAdjunto()%>
                                    </a>
                                </span>
                            </div>
                        <% } %>

                        <div class="file-input-wrapper">
                            <input type="file" name="archivo" id="archivoInput" accept=".pdf">
                            <label for="archivoInput" class="file-input-label">
                                <i class="fas fa-cloud-upload-alt"></i>
                                <div class="file-input-text">
                                    <strong>Haga clic para seleccionar un archivo</strong>
                                    <small>o arrastre y suelte aquí (Solo archivos PDF, máx. 10MB)</small>
                                </div>
                            </label>
                        </div>
                        <div class="file-name" id="fileName"></div>
                    </div>

                    <!-- BOTONES -->
                    <div class="form-actions">
                        <a href="TareaServlet?accion=ver&curso_id=<%= curso.getId()%>" class="btn btn-secondary">
                            <i class="fas fa-times"></i> Cancelar
                        </a>
                        <button type="submit" class="btn btn-primary" id="submitBtn">
                            <i class="fas fa-<%= editar ? "save" : "check" %>"></i>
                            <%= editar ? "Actualizar Tarea" : "Registrar Tarea"%>
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- FOOTER -->
    <div class="footer">
        <div class="footer-content">
            <div class="footer-section">
                <img src="assets/img/logosa.png" alt="Logo" class="footer-logo">
                <p>"Líderes en educación de calidad al más alto nivel"</p>
            </div>
            
            <div class="footer-section">
                <h5><i class="fas fa-map-marker-alt"></i> Contacto</h5>
                <p>Av. El Sol 461, San Juan de Lurigancho 15434</p>
                <p><i class="fas fa-phone"></i> 987654321</p>
                <p><i class="fas fa-envelope"></i> colegiosanantonio@gmail.com</p>
            </div>
            
            <div class="footer-section">
                <h5><i class="fas fa-share-alt"></i> Síguenos</h5>
                <a href="https://www.facebook.com/"><i class="fab fa-facebook"></i> Facebook</a>
                <a href="https://www.instagram.com/"><i class="fab fa-instagram"></i> Instagram</a>
                <a href="https://twitter.com/"><i class="fab fa-twitter"></i> Twitter</a>
                <a href="https://www.youtube.com/"><i class="fab fa-youtube"></i> YouTube</a>
            </div>
        </div>
        
        <div class="footer-bottom">
            <p>&copy; 2025 Colegio SA - Todos los derechos reservados</p>
        </div>
    </div>

    <!-- SCRIPTS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Mostrar nombre del archivo seleccionado
        document.getElementById('archivoInput').addEventListener('change', function(e) {
            const fileName = e.target.files[0] ? e.target.files[0].name : '';
            const fileNameDiv = document.getElementById('fileName');
            
            if (fileName) {
                // Validar tamaño del archivo (10MB)
                const fileSize = e.target.files[0].size / 1024 / 1024; // en MB
                if (fileSize > 10) {
                    alert('El archivo es demasiado grande. El tamaño máximo es 10MB.');
                    e.target.value = '';
                    fileNameDiv.style.display = 'none';
                    return;
                }
                
                // Validar extensión
                if (!fileName.toLowerCase().endsWith('.pdf')) {
                    alert('Solo se permiten archivos PDF.');
                    e.target.value = '';
                    fileNameDiv.style.display = 'none';
                    return;
                }
                
                fileNameDiv.innerHTML = '<i class="fas fa-file-pdf"></i> ' + fileName;
                fileNameDiv.style.display = 'block';
            } else {
                fileNameDiv.style.display = 'none';
            }
        });

        // Validación del formulario antes de enviar
        document.getElementById('tareaForm').addEventListener('submit', function(e) {
            const fechaEntrega = document.querySelector('input[name="fecha_entrega"]').value;
            const hoy = new Date().toISOString().split('T')[0];
            
            if (fechaEntrega < hoy) {
                e.preventDefault();
                alert('La fecha de entrega no puede ser anterior a hoy.');
                return false;
            }

            // Deshabilitar botón para evitar doble envío
            const submitBtn = document.getElementById('submitBtn');
            submitBtn.disabled = true;
            submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Procesando...';
        });

        // Drag and drop para archivos
        const fileLabel = document.querySelector('.file-input-label');
        
        fileLabel.addEventListener('dragover', (e) => {
            e.preventDefault();
            fileLabel.style.borderColor = '#2196F3';
            fileLabel.style.background = '#E3F2FD';
        });
        
        fileLabel.addEventListener('dragleave', (e) => {
            e.preventDefault();
            fileLabel.style.borderColor = '#BDBDBD';
            fileLabel.style.background = '#FAFAFA';
        });
        
        fileLabel.addEventListener('drop', (e) => {
            e.preventDefault();
            fileLabel.style.borderColor = '#BDBDBD';
            fileLabel.style.background = '#FAFAFA';
            
            const files = e.dataTransfer.files;
            if (files.length > 0) {
                document.getElementById('archivoInput').files = files;
                document.getElementById('archivoInput').dispatchEvent(new Event('change'));
            }
        });
    </script>
</body>
</html>
