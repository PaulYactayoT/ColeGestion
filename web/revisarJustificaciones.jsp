<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="modelo.*, java.util.*, java.time.*" %>
<%
    // Validar sesión
    String rol = (String) session.getAttribute("rol");
    if (rol == null || (!rol.equals("admin") && !rol.equals("docente"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    Integer personaId = (Integer) session.getAttribute("personaId");
    
    // Obtener parámetros
    String cursoIdStr = request.getParameter("cursoId");
    String turnoIdStr = request.getParameter("turnoId");
    
    int cursoId = cursoIdStr != null ? Integer.parseInt(cursoIdStr) : 0;
    int turnoId = turnoIdStr != null ? Integer.parseInt(turnoIdStr) : 0;
    
    // DAOs
    JustificacionDAO justificacionDAO = new JustificacionDAO();
    CursoDAO cursoDAO = new CursoDAO();
    TurnoDAO turnoDAO = new TurnoDAO();
    
    // Obtener datos
    List<Justificacion> justificacionesPendientes = new ArrayList<>();
    if (cursoId > 0 && turnoId > 0) {
        justificacionesPendientes = justificacionDAO.obtenerJustificacionesPendientes(cursoId, turnoId);
    }
    
    // Obtener listas para filtros
    List<Curso> cursos = cursoDAO.obtenerCursosPorDocente(personaId);
    List<Turno> turnos = turnoDAO.listarTurnos();
    
    // Mensajes
    String mensaje = request.getParameter("mensaje");
    String tipoMensaje = request.getParameter("tipo");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Revisar Justificaciones - Sistema Escolar</title>
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
            max-width: 1400px;
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
            max-width: 1400px;
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
        
        /* Filtros */
        .filter-section {
            background-color: #ffffff;
            border: 2px solid #e0e0e0;
            padding: 25px;
            border-radius: 10px;
            margin-bottom: 25px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }
        
        .form-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
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
            min-height: 100px;
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
        
        .btn-danger {
            background-color: #dc3545;
            color: #ffffff;
        }
        
        .btn-danger:hover {
            background-color: #c82333;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(220, 53, 69, 0.4);
        }
        
        .btn-sm {
            padding: 8px 16px;
            font-size: 13px;
        }
        
        /* Justificaciones List */
        .justificaciones-list {
            margin-bottom: 30px;
        }
        
        .justificacion-card {
            background-color: #ffffff;
            border: 2px solid #e0e0e0;
            border-left: 4px solid #ffc107;
            padding: 25px;
            margin-bottom: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            transition: all 0.3s ease;
        }
        
        .justificacion-card:hover {
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        
        .justificacion-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 20px;
            padding-bottom: 20px;
            border-bottom: 2px solid #e0e0e0;
        }
        
        .justificacion-info {
            flex: 1;
        }
        
        .justificacion-info h3 {
            font-size: 20px;
            font-weight: 700;
            margin-bottom: 10px;
            color: #000000;
        }
        
        .info-row {
            display: flex;
            gap: 30px;
            flex-wrap: wrap;
            margin-bottom: 8px;
        }
        
        .info-item {
            font-size: 14px;
            color: #666;
        }
        
        .info-item strong {
            color: #000000;
            font-weight: 600;
        }
        
        .badge {
            display: inline-block;
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: 600;
        }
        
        .badge-warning {
            background-color: #fff3cd;
            color: #856404;
        }
        
        .justificacion-body {
            margin-bottom: 20px;
        }
        
        .justificacion-section {
            margin-bottom: 15px;
        }
        
        .justificacion-section label {
            display: block;
            font-weight: 600;
            color: #000000;
            margin-bottom: 8px;
            font-size: 15px;
        }
        
        .justificacion-text {
            background-color: #f8f9fa;
            padding: 15px;
            border-radius: 8px;
            border-left: 3px solid #A8D8EA;
            line-height: 1.6;
        }
        
        .documento-adjunto {
            background-color: #f8f9fa;
            padding: 15px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        
        .documento-adjunto a {
            color: #007bff;
            text-decoration: none;
            font-weight: 600;
        }
        
        .documento-adjunto a:hover {
            text-decoration: underline;
        }
        
        .justificacion-actions {
            display: flex;
            gap: 15px;
            flex-wrap: wrap;
        }
        
        .action-form {
            flex: 1;
            min-width: 300px;
        }
        
        /* Modal */
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.6);
            z-index: 1000;
            align-items: center;
            justify-content: center;
        }
        
        .modal.active {
            display: flex;
        }
        
        .modal-content {
            background-color: #ffffff;
            border-radius: 12px;
            max-width: 600px;
            width: 90%;
            max-height: 90vh;
            overflow-y: auto;
            box-shadow: 0 10px 40px rgba(0,0,0,0.3);
            animation: modalSlideIn 0.3s ease;
        }
        
        .modal-header {
            background-color: #000000;
            color: #ffffff;
            padding: 20px 25px;
            border-radius: 12px 12px 0 0;
        }
        
        .modal-header h3 {
            margin: 0;
            font-size: 22px;
            font-weight: 600;
        }
        
        .modal-body {
            padding: 25px;
        }
        
        .modal-footer {
            padding: 20px 25px;
            border-top: 1px solid #e0e0e0;
            display: flex;
            gap: 12px;
            justify-content: flex-end;
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
            max-width: 1400px;
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
        
        @keyframes modalSlideIn {
            from {
                transform: translateY(-50px);
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
            
            .justificacion-header {
                flex-direction: column;
                gap: 15px;
            }
            
            .info-row {
                flex-direction: column;
                gap: 8px;
            }
            
            .justificacion-actions {
                flex-direction: column;
            }
            
            .action-form {
                min-width: 100%;
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
            <h1>🔍 Revisar Justificaciones</h1>
            <p>Aprueba o rechaza las justificaciones de ausencias enviadas por los padres</p>
        </div>
        
        <!-- Mensajes -->
        <% if (mensaje != null) { %>
            <div class="alert alert-<%= tipoMensaje %>">
                <span><%= mensaje %></span>
            </div>
        <% } %>
        
        <!-- Filtros -->
        <div class="filter-section">
            <form method="GET" action="revisarJustificaciones.jsp">
                <div class="form-row">
                    <div class="form-group">
                        <label for="cursoId">📚 Curso</label>
                        <select name="cursoId" id="cursoId" class="form-control" required>
                            <option value="">-- Seleccione un curso --</option>
                            <% for (Curso c : cursos) { %>
                                <option value="<%= c.getId() %>" <%= c.getId() == cursoId ? "selected" : "" %>>
                                    <%= c.getNombre() %> - <%= c.getGradoNombre() %> <%= c.getSeccion() %>
                                </option>
                            <% } %>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="turnoId">🕐 Turno</label>
                        <select name="turnoId" id="turnoId" class="form-control" required>
                            <option value="">-- Seleccione un turno --</option>
                            <% for (Turno t : turnos) { %>
                                <option value="<%= t.getId() %>" <%= t.getId() == turnoId ? "selected" : "" %>>
                                    <%= t.getNombre() %> (<%= t.getHoraInicio() %> - <%= t.getHoraFin() %>)
                                </option>
                            <% } %>
                        </select>
                    </div>
                </div>
                
                <button type="submit" class="btn btn-primary">
                    🔍 Buscar Justificaciones
                </button>
            </form>
        </div>
        
        <!-- Lista de Justificaciones -->
        <% if (cursoId > 0 && turnoId > 0) { %>
            <% if (justificacionesPendientes.isEmpty()) { %>
                <div class="empty-state">
                    <div class="empty-state-icon">✅</div>
                    <h3>No hay justificaciones pendientes</h3>
                    <p>Todas las justificaciones han sido revisadas</p>
                </div>
            <% } else { %>
                <div class="justificaciones-list">
                    <h2 style="margin-bottom: 25px; font-size: 22px; color: #000000;">
                        📋 Justificaciones Pendientes (<%= justificacionesPendientes.size() %>)
                    </h2>
                    
                    <% for (Justificacion justif : justificacionesPendientes) { %>
                        <div class="justificacion-card">
                            <div class="justificacion-header">
                                <div class="justificacion-info">
                                    <h3>👨‍🎓 <%= justif.getAlumnoNombre() %></h3>
                                    <div class="info-row">
                                        <div class="info-item">
                                            <strong>Fecha de Ausencia:</strong> <%= justif.getFechaAsistencia() %>
                                        </div>
                                        <div class="info-item">
                                            <strong>Curso:</strong> <%= justif.getCursoNombre() %>
                                        </div>
                                    </div>
                                    <div class="info-row">
                                        <div class="info-item">
                                            <strong>Justificado por:</strong> <%= justif.getJustificadorNombre() %>
                                        </div>
                                        <div class="info-item">
                                            <strong>Fecha de Justificación:</strong> <%= justif.getFechaJustificacionFormateada() %>
                                        </div>
                                    </div>
                                </div>
                                <div>
                                    <span class="badge badge-warning">⏳ PENDIENTE</span>
                                </div>
                            </div>
                            
                            <div class="justificacion-body">
                                <div class="justificacion-section">
                                    <label>Tipo de Justificación</label>
                                    <div class="justificacion-text">
                                        <%= justif.getTipoJustificacion().getDescripcion() %>
                                    </div>
                                </div>
                                
                                <div class="justificacion-section">
                                    <label>Descripción</label>
                                    <div class="justificacion-text">
                                        <%= justif.getDescripcion() %>
                                    </div>
                                </div>
                                
                                <% if (justif.tieneDocumento()) { %>
                                    <div class="justificacion-section">
                                        <label>Documento Adjunto</label>
                                        <div class="documento-adjunto">
                                            <span>📎</span>
                                            <a href="<%= justif.getDocumentoAdjunto() %>" target="_blank">
                                                <%= justif.getNombreArchivo() %> 
                                                (<%= justif.getTipoArchivo() %>)
                                            </a>
                                        </div>
                                    </div>
                                <% } %>
                            </div>
                            
                            <div class="justificacion-actions">
                                <!-- Formulario Aprobar -->
                                <div class="action-form">
                                    <form method="POST" action="JustificacionServlet">
                                        <input type="hidden" name="accion" value="aprobar">
                                        <input type="hidden" name="justificacionId" value="<%= justif.getId() %>">
                                        <input type="hidden" name="cursoId" value="<%= cursoId %>">
                                        <input type="hidden" name="turnoId" value="<%= turnoId %>">
                                        
                                        <div class="form-group" style="margin-bottom: 15px;">
                                            <label for="obs_aprobar_<%= justif.getId() %>">
                                                Observaciones (opcional)
                                            </label>
                                            <textarea name="observaciones" id="obs_aprobar_<%= justif.getId() %>" 
                                                      class="form-control" rows="2"
                                                      placeholder="Añade comentarios adicionales..."></textarea>
                                        </div>
                                        
                                        <button type="submit" class="btn btn-success" style="width: 100%;">
                                            ✅ Aprobar Justificación
                                        </button>
                                    </form>
                                </div>
                                
                                <!-- Formulario Rechazar -->
                                <div class="action-form">
                                    <form method="POST" action="JustificacionServlet" 
                                          onsubmit="return validarRechazo(<%= justif.getId() %>)">
                                        <input type="hidden" name="accion" value="rechazar">
                                        <input type="hidden" name="justificacionId" value="<%= justif.getId() %>">
                                        <input type="hidden" name="cursoId" value="<%= cursoId %>">
                                        <input type="hidden" name="turnoId" value="<%= turnoId %>">
                                        
                                        <div class="form-group" style="margin-bottom: 15px;">
                                            <label for="obs_rechazar_<%= justif.getId() %>">
                                                Motivo del Rechazo *
                                            </label>
                                            <textarea name="observaciones" id="obs_rechazar_<%= justif.getId() %>" 
                                                      class="form-control" rows="2" required
                                                      placeholder="Explique por qué rechaza esta justificación..."></textarea>
                                        </div>
                                        
                                        <button type="submit" class="btn btn-danger" style="width: 100%;">
                                            ❌ Rechazar Justificación
                                        </button>
                                    </form>
                                </div>
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
        function validarRechazo(justificacionId) {
            const observaciones = document.getElementById('obs_rechazar_' + justificacionId).value;
            if (!observaciones || observaciones.trim() === '') {
                alert('⚠️ Debe especificar el motivo del rechazo');
                return false;
            }
            
            return confirm('¿Está seguro de rechazar esta justificación?\n\nEl padre de familia será notificado del rechazo.');
        }
    </script>
</body>
</html>
