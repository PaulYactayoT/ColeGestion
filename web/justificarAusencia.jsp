<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="modelo.*, java.util.*, java.time.*" %>
<%
    // Verificar sesión de padre
    Integer personaId = (Integer) session.getAttribute("personaId");
    String rol = (String) session.getAttribute("rol");
    
    if (personaId == null || !"padre".equals(rol)) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Obtener asistencias con ausencias del alumno hijo
    int alumnoId = request.getParameter("alumnoId") != null ? 
                   Integer.parseInt(request.getParameter("alumnoId")) : 0;
    
    AsistenciaDAO asistenciaDAO = new AsistenciaDAO();
    JustificacionDAO justificacionDAO = new JustificacionDAO();
    AlumnoDAO alumnoDAO = new AlumnoDAO();
    
    List<Asistencia> ausencias = new ArrayList<>();
    Alumno alumno = null;
    
    if (alumnoId > 0) {
        alumno = alumnoDAO.obtenerAlumnoPorId(alumnoId);
        // Obtener ausencias de los últimos 30 días
        ausencias = asistenciaDAO.obtenerAsistenciasPorAlumno(alumnoId);
        
        // Filtrar solo ausencias sin justificar
        ausencias.removeIf(a -> !a.getEstado().equals(Asistencia.EstadoAsistencia.AUSENTE) ||
                               justificacionDAO.tieneJustificacionPendiente(a.getId()));
    }
    
    // Obtener lista de hijos del padre
    List<Alumno> hijos = alumnoDAO.obtenerHijosPorPadre(personaId);
    
    // Mensajes
    String mensaje = request.getParameter("mensaje");
    String tipoMensaje = request.getParameter("tipo");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Justificar Ausencias - Sistema Escolar</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #ffffff;
            color: #000000;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }
        
        /* Header */
        .main-header {
            background-color: #000000;
            color: #ffffff;
            padding: 20px 0;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .header-content {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .header-title {
            font-size: 24px;
            font-weight: 600;
        }
        
        .header-user {
            font-size: 14px;
            opacity: 0.9;
        }
        
        /* Container */
        .container {
            flex: 1;
            max-width: 1200px;
            margin: 0 auto;
            padding: 30px 20px;
            width: 100%;
        }
        
        /* Page Header */
        .page-header {
            background: linear-gradient(135deg, #A8D8EA 0%, #7FB3D5 100%);
            color: #000000;
            padding: 30px;
            border-radius: 12px;
            margin-bottom: 30px;
            box-shadow: 0 4px 15px rgba(168, 216, 234, 0.3);
        }
        
        .page-header h1 {
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 8px;
        }
        
        .page-header p {
            font-size: 15px;
            opacity: 0.85;
        }
        
        /* Alertas */
        .alert {
            padding: 16px 20px;
            border-radius: 8px;
            margin-bottom: 25px;
            display: flex;
            align-items: center;
            gap: 12px;
            font-weight: 500;
            animation: slideDown 0.3s ease;
        }
        
        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border-left: 4px solid #28a745;
        }
        
        .alert-error {
            background-color: #f8d7da;
            color: #721c24;
            border-left: 4px solid #dc3545;
        }
        
        .alert-info {
            background-color: #d1ecf1;
            color: #0c5460;
            border-left: 4px solid #17a2b8;
        }
        
        /* Selector de Alumno */
        .alumno-selector {
            background-color: #ffffff;
            border: 2px solid #e0e0e0;
            padding: 25px;
            border-radius: 10px;
            margin-bottom: 25px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }
        
        .form-group {
            margin-bottom: 0;
        }
        
        .form-group label {
            display: block;
            font-weight: 600;
            margin-bottom: 8px;
            color: #000000;
            font-size: 15px;
        }
        
        .form-control {
            width: 100%;
            padding: 12px 16px;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            font-size: 15px;
            font-family: inherit;
            background-color: #ffffff;
            color: #000000;
            transition: all 0.3s ease;
        }
        
        .form-control:focus {
            outline: none;
            border-color: #A8D8EA;
            box-shadow: 0 0 0 3px rgba(168, 216, 234, 0.2);
        }
        
        textarea.form-control {
            resize: vertical;
            min-height: 120px;
        }
        
        /* Ausencias List */
        .ausencias-list {
            margin-bottom: 30px;
        }
        
        .ausencia-card {
            background-color: #ffffff;
            border: 2px solid #e0e0e0;
            border-left: 4px solid #dc3545;
            padding: 20px;
            margin-bottom: 20px;
            border-radius: 10px;
            transition: all 0.3s ease;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }
        
        .ausencia-card:hover {
            transform: translateX(5px);
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        
        .ausencia-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
            padding-bottom: 15px;
            border-bottom: 1px solid #e0e0e0;
        }
        
        .ausencia-info {
            flex: 1;
        }
        
        .ausencia-info h3 {
            font-size: 18px;
            font-weight: 700;
            margin-bottom: 8px;
            color: #000000;
        }
        
        .ausencia-info p {
            font-size: 14px;
            color: #666;
            margin: 4px 0;
        }
        
        .ausencia-badge {
            background-color: #f8d7da;
            color: #721c24;
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: 600;
        }
        
        /* Formulario de Justificación */
        .justificacion-form {
            background-color: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            margin-top: 15px;
        }
        
        .form-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }
        
        /* Botones */
        .btn {
            padding: 12px 24px;
            border: none;
            border-radius: 8px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
        }
        
        .btn-primary {
            background-color: #A8D8EA;
            color: #000000;
        }
        
        .btn-primary:hover {
            background-color: #7FB3D5;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(168, 216, 234, 0.4);
        }
        
        .btn-success {
            background-color: #28a745;
            color: #ffffff;
        }
        
        .btn-success:hover {
            background-color: #218838;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(40, 167, 69, 0.4);
        }
        
        .btn-secondary {
            background-color: #6c757d;
            color: #ffffff;
        }
        
        .btn-secondary:hover {
            background-color: #5a6268;
        }
        
        .btn-block {
            width: 100%;
            justify-content: center;
        }
        
        /* File Upload */
        .file-upload {
            position: relative;
            display: inline-block;
            width: 100%;
        }
        
        .file-upload input[type="file"] {
            position: absolute;
            opacity: 0;
            width: 100%;
            height: 100%;
            cursor: pointer;
        }
        
        .file-upload-label {
            display: block;
            padding: 12px 16px;
            border: 2px dashed #A8D8EA;
            border-radius: 8px;
            text-align: center;
            background-color: #f8f9fa;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .file-upload-label:hover {
            background-color: #A8D8EA;
            border-color: #7FB3D5;
        }
        
        .file-name {
            margin-top: 8px;
            font-size: 14px;
            color: #666;
        }
        
        /* Empty State */
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #6c757d;
        }
        
        .empty-state-icon {
            font-size: 64px;
            margin-bottom: 20px;
            opacity: 0.5;
        }
        
        .empty-state h3 {
            font-size: 22px;
            margin-bottom: 10px;
            color: #000000;
        }
        
        .empty-state p {
            font-size: 15px;
            color: #6c757d;
        }
        
        /* Footer */
        .main-footer {
            background-color: #000000;
            color: #ffffff;
            padding: 20px 0;
            text-align: center;
            margin-top: auto;
        }
        
        .footer-content {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
            font-size: 14px;
        }
        
        /* Animaciones */
        @keyframes slideDown {
            from {
                transform: translateY(-20px);
                opacity: 0;
            }
            to {
                transform: translateY(0);
                opacity: 1;
            }
        }
        
        /* Responsivo */
        @media (max-width: 768px) {
            .header-content {
                flex-direction: column;
                gap: 10px;
                text-align: center;
            }
            
            .ausencia-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 10px;
            }
            
            .form-row {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <!-- Header -->
    <header class="main-header">
        <div class="header-content">
            <div class="header-title">🏫 Sistema de Asistencia Escolar</div>
            <div class="header-user">👤 <%= session.getAttribute("nombres") %> (<%= rol.toUpperCase() %>)</div>
        </div>
    </header>
    
    <!-- Container -->
    <div class="container">
        <!-- Page Header -->
        <div class="page-header">
            <h1>📝 Justificar Ausencias</h1>
            <p>Justifica las ausencias de tus hijos con documentos de respaldo</p>
        </div>
        
        <!-- Mensajes -->
        <% if (mensaje != null) { %>
            <div class="alert alert-<%= tipoMensaje %>">
                <span><%= mensaje %></span>
            </div>
        <% } %>
        
        <!-- Selector de Alumno -->
        <div class="alumno-selector">
            <form method="GET" action="justificarAusencia.jsp">
                <div class="form-group">
                    <label for="alumnoId">👨‍🎓 Seleccionar Hijo</label>
                    <select name="alumnoId" id="alumnoId" class="form-control" onchange="this.form.submit()" required>
                        <option value="">-- Seleccione un hijo --</option>
                        <% for (Alumno hijo : hijos) { %>
                            <option value="<%= hijo.getId() %>" <%= hijo.getId() == alumnoId ? "selected" : "" %>>
                                <%= hijo.getNombreCompleto() %>
                            </option>
                        <% } %>
                    </select>
                </div>
            </form>
        </div>
        
        <!-- Lista de Ausencias -->
        <% if (alumnoId > 0) { %>
            <% if (ausencias.isEmpty()) { %>
                <div class="empty-state">
                    <div class="empty-state-icon">🎉</div>
                    <h3>¡Excelente!</h3>
                    <p>No hay ausencias sin justificar para <%= alumno != null ? alumno.getNombreCompleto() : "este alumno" %></p>
                </div>
            <% } else { %>
                <div class="ausencias-list">
                    <h2 style="margin-bottom: 20px; font-size: 22px; color: #000000;">
                        📋 Ausencias de <%= alumno != null ? alumno.getNombreCompleto() : "" %>
                    </h2>
                    
                    <% for (Asistencia ausencia : ausencias) { %>
                        <div class="ausencia-card">
                            <div class="ausencia-header">
                                <div class="ausencia-info">
                                    <h3>📅 <%= ausencia.getFechaFormateada() %></h3>
                                    <p><strong>Curso:</strong> <%= ausencia.getCursoNombre() %></p>
                                    <p><strong>Turno:</strong> <%= ausencia.getTurnoNombre() %></p>
                                    <% if (ausencia.getObservaciones() != null && !ausencia.getObservaciones().isEmpty()) { %>
                                        <p><strong>Observación:</strong> <%= ausencia.getObservaciones() %></p>
                                    <% } %>
                                </div>
                                <div>
                                    <span class="ausencia-badge">❌ AUSENTE</span>
                                </div>
                            </div>
                            
                            <!-- Formulario de Justificación -->
                            <div class="justificacion-form">
                                <h4 style="margin-bottom: 15px; color: #000000;">Justificar esta ausencia</h4>
                                
                                <form method="POST" action="JustificacionServlet" enctype="multipart/form-data">
                                    <input type="hidden" name="accion" value="crear">
                                    <input type="hidden" name="asistenciaId" value="<%= ausencia.getId() %>">
                                    <input type="hidden" name="alumnoId" value="<%= alumnoId %>">
                                    
                                    <div class="form-row">
                                        <div class="form-group">
                                            <label for="tipoJustificacion_<%= ausencia.getId() %>">Tipo de Justificación *</label>
                                            <select name="tipoJustificacion" id="tipoJustificacion_<%= ausencia.getId() %>" 
                                                    class="form-control" required>
                                                <option value="">-- Seleccione --</option>
                                                <option value="ENFERMEDAD">🏥 Enfermedad</option>
                                                <option value="CITA_MEDICA">👨‍⚕️ Cita Médica</option>
                                                <option value="EMERGENCIA_FAMILIAR">🏠 Emergencia Familiar</option>
                                                <option value="OTRO">📌 Otro</option>
                                            </select>
                                        </div>
                                    </div>
                                    
                                    <div class="form-group" style="margin-bottom: 20px;">
                                        <label for="descripcion_<%= ausencia.getId() %>">Descripción *</label>
                                        <textarea name="descripcion" id="descripcion_<%= ausencia.getId() %>" 
                                                  class="form-control" required
                                                  placeholder="Explique el motivo de la ausencia..."></textarea>
                                    </div>
                                    
                                    <div class="form-group" style="margin-bottom: 20px;">
                                        <label for="archivo_<%= ausencia.getId() %>">
                                            Documento de Respaldo (Imagen o PDF)
                                        </label>
                                        <div class="file-upload">
                                            <input type="file" name="archivo" id="archivo_<%= ausencia.getId() %>" 
                                                   accept=".pdf,.jpg,.jpeg,.png"
                                                   onchange="mostrarNombreArchivo(this, <%= ausencia.getId() %>)">
                                            <label for="archivo_<%= ausencia.getId() %>" class="file-upload-label">
                                                📎 Seleccionar archivo (PDF, JPG, PNG)
                                            </label>
                                            <div id="fileName_<%= ausencia.getId() %>" class="file-name"></div>
                                        </div>
                                    </div>
                                    
                                    <button type="submit" class="btn btn-success btn-block">
                                        ✉️ Enviar Justificación
                                    </button>
                                </form>
                            </div>
                        </div>
                    <% } %>
                </div>
            <% } %>
        <% } %>
    </div>
    
    <!-- Footer -->
    <footer class="main-footer">
        <div class="footer-content">
            © 2025 Sistema de Asistencia Escolar. Todos los derechos reservados.
        </div>
    </footer>
    
    <script>
        function mostrarNombreArchivo(input, asistenciaId) {
            const fileName = input.files[0]?.name;
            const fileNameDiv = document.getElementById('fileName_' + asistenciaId);
            if (fileName) {
                fileNameDiv.textContent = '📄 ' + fileName;
                fileNameDiv.style.color = '#28a745';
                fileNameDiv.style.fontWeight = '600';
            } else {
                fileNameDiv.textContent = '';
            }
        }
    </script>
</body>
</html>
