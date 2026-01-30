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
    String turnoIdStr = request.getParameter("turnoId");
    int turnoId = turnoIdStr != null ? Integer.parseInt(turnoIdStr) : 0;
    
    // DAOs
    ConfiguracionLimiteDAO configuracionDAO = new ConfiguracionLimiteDAO();
    CursoDAO cursoDAO = new CursoDAO();
    TurnoDAO turnoDAO = new TurnoDAO();
    
    // Obtener datos
    List<ConfiguracionLimiteEdicion> configuraciones = new ArrayList<>();
    if (turnoId > 0) {
        configuraciones = configuracionDAO.obtenerConfiguracionesPorTurno(turnoId);
    }
    
    List<Turno> turnos = turnoDAO.listarTurnos();
    List<Curso> cursos = cursoDAO.listarCursosActivos();
    
    // Mensajes
    String mensaje = request.getParameter("mensaje");
    String tipoMensaje = request.getParameter("tipo");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Configuración de Límites de Edición - Sistema Escolar</title>
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
        
        /* Container Principal */
        .container {
            flex: 1;
            max-width: 1200px;
            margin: 0 auto;
            padding: 30px 20px;
            width: 100%;
        }
        
        /* Título de Página */
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
        
        /* Info Box */
        .info-box {
            background-color: #f8f9fa;
            border: 2px solid #A8D8EA;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 25px;
        }
        
        .info-box p {
            margin: 8px 0;
            line-height: 1.6;
        }
        
        .info-box strong {
            color: #000000;
        }
        
        /* Sección de Filtros */
        .filter-section {
            background-color: #ffffff;
            border: 2px solid #e0e0e0;
            padding: 25px;
            border-radius: 10px;
            margin-bottom: 25px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }
        
        /* Formularios */
        .form-group {
            margin-bottom: 20px;
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
            background-color: #A8D8EA;
            color: #000000;
        }
        
        .btn-success:hover {
            background-color: #7FB3D5;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(168, 216, 234, 0.4);
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
        
        /* Tabla */
        .table-container {
            background-color: #ffffff;
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
        }
        
        .table-header {
            background-color: #f8f9fa;
            padding: 20px;
            border-bottom: 2px solid #e0e0e0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .table-header h2 {
            margin: 0;
            font-size: 20px;
            font-weight: 700;
            color: #000000;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
        }
        
        thead {
            background-color: #000000;
            color: #ffffff;
        }
        
        th {
            padding: 16px;
            text-align: left;
            font-weight: 600;
            font-size: 14px;
            letter-spacing: 0.5px;
        }
        
        td {
            padding: 16px;
            border-bottom: 1px solid #f0f0f0;
            color: #000000;
        }
        
        tbody tr {
            transition: background-color 0.2s ease;
        }
        
        tbody tr:hover {
            background-color: #f8f9fa;
        }
        
        tbody tr:last-child td {
            border-bottom: none;
        }
        
        /* Badges */
        .badge {
            display: inline-block;
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
        }
        
        .badge-info {
            background-color: #A8D8EA;
            color: #000000;
        }
        
        .badge-success {
            background-color: #28a745;
            color: #ffffff;
        }
        
        /* Estado Vacío */
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
            
            .table-header {
                flex-direction: column;
                gap: 15px;
                align-items: stretch;
            }
            
            table {
                font-size: 13px;
            }
            
            th, td {
                padding: 10px;
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
    
    <!-- Container Principal -->
    <div class="container">
        <!-- Título de Página -->
        <div class="page-header">
            <h1>⏱️ Configuración de Límites de Edición</h1>
            <p>Gestiona los tiempos límite para editar asistencias según horarios de clase</p>
        </div>
        
        <!-- Mensajes -->
        <% if (mensaje != null) { %>
            <div class="alert alert-<%= tipoMensaje %>">
                <span><%= mensaje %></span>
            </div>
        <% } %>
        
        <!-- Información -->
        <div class="info-box">
            <p><strong>ℹ️ ¿Cómo funciona?</strong></p>
            <p>• Define cuánto tiempo después del inicio de la clase los docentes pueden editar la asistencia</p>
            <p>• Configura límites específicos por día, hora y turno</p>
            <p>• Puedes aplicar una configuración a todos los cursos o solo a uno específico</p>
            <p>• <strong>Una vez vencido el tiempo límite, los docentes NO podrán modificar la asistencia</strong></p>
        </div>
        
        <!-- Filtro por Turno -->
        <div class="filter-section">
            <form method="GET" action="configurarLimitesEdicion.jsp">
                <div class="form-group">
                    <label for="turnoId">🔍 Seleccionar Turno</label>
                    <select name="turnoId" id="turnoId" class="form-control" onchange="this.form.submit()">
                        <option value="">-- Seleccione un turno --</option>
                        <% for (Turno turno : turnos) { %>
                            <option value="<%= turno.getId() %>" 
                                    <%= turno.getId() == turnoId ? "selected" : "" %>>
                                <%= turno.getNombre() %> (<%= turno.getHoraInicio() %> - <%= turno.getHoraFin() %>)
                            </option>
                        <% } %>
                    </select>
                </div>
            </form>
        </div>
        
        <% if (turnoId > 0) { %>
            <!-- Tabla de Configuraciones -->
            <div class="table-container">
                <div class="table-header">
                    <h2>📋 Configuraciones Actuales</h2>
                    <button class="btn btn-success" onclick="abrirModal()">
                        ➕ Nueva Configuración
                    </button>
                </div>
                
                <% if (configuraciones.isEmpty()) { %>
                    <div class="empty-state">
                        <div class="empty-state-icon">📭</div>
                        <h3>No hay configuraciones</h3>
                        <p>Crea tu primera configuración de límite de edición</p>
                    </div>
                <% } else { %>
                    <table>
                        <thead>
                            <tr>
                                <th>Día</th>
                                <th>Hora Inicio</th>
                                <th>Curso</th>
                                <th>Límite</th>
                                <th>Descripción</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (ConfiguracionLimiteEdicion config : configuraciones) { %>
                                <tr>
                                    <td><strong><%= config.getDiaSemana() %></strong></td>
                                    <td><%= config.getHoraInicioClaseFormateada() %></td>
                                    <td>
                                        <% if (config.isAplicaTodosCursos()) { %>
                                            <span class="badge badge-info">Todos los cursos</span>
                                        <% } else { %>
                                            <%= config.getCursoNombre() %>
                                        <% } %>
                                    </td>
                                    <td>
                                        <span class="badge badge-success">
                                            <%= config.getDescripcionLimite() %>
                                        </span>
                                    </td>
                                    <td><%= config.getDescripcion() != null ? config.getDescripcion() : "-" %></td>
                                    <td>
                                        <button class="btn btn-danger" 
                                                onclick="eliminarConfig(<%= config.getId() %>)"
                                                style="padding: 8px 16px; font-size: 13px;">
                                            🗑️ Eliminar
                                        </button>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                <% } %>
            </div>
        <% } %>
    </div>
    
    <!-- Modal Nueva Configuración -->
    <div id="modalConfig" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h3>➕ Nueva Configuración de Límite</h3>
            </div>
            
            <form method="POST" action="ConfiguracionLimiteServlet">
                <div class="modal-body">
                    <input type="hidden" name="accion" value="crear">
                    <input type="hidden" name="turnoId" value="<%= turnoId %>">
                    
                    <div class="form-group">
                        <label for="diaSemana">Día de la Semana *</label>
                        <select name="diaSemana" id="diaSemana" class="form-control" required>
                            <option value="">-- Seleccione --</option>
                            <option value="LUNES">Lunes</option>
                            <option value="MARTES">Martes</option>
                            <option value="MIERCOLES">Miércoles</option>
                            <option value="JUEVES">Jueves</option>
                            <option value="VIERNES">Viernes</option>
                            <option value="SABADO">Sábado</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="horaInicioClase">Hora de Inicio de Clase *</label>
                        <input type="time" name="horaInicioClase" id="horaInicioClase" 
                               class="form-control" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="limiteEdicionMinutos">Límite de Edición (en minutos) *</label>
                        <input type="number" name="limiteEdicionMinutos" id="limiteEdicionMinutos" 
                               class="form-control" min="30" max="720" value="60" required>
                        <small style="color: #666; margin-top: 5px; display: block;">
                            📌 Ejemplo: 60 minutos = El docente puede editar hasta 1 hora después de iniciada la clase
                        </small>
                    </div>
                    
                    <div class="form-group">
                        <label for="cursoId">Curso</label>
                        <select name="cursoId" id="cursoId" class="form-control">
                            <option value="0">-- Aplicar a todos los cursos --</option>
                            <% for (Curso curso : cursos) { %>
                                <option value="<%= curso.getId() %>">
                                    <%= curso.getNombre() %> - <%= curso.getGradoNombre() %> <%= curso.getSeccion() %>
                                </option>
                            <% } %>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="descripcion">Descripción (opcional)</label>
                        <textarea name="descripcion" id="descripcion" class="form-control" 
                                  rows="3" placeholder="Ej: Límite para clases de la mañana"></textarea>
                    </div>
                </div>
                
                <div class="modal-footer">
                    <button type="button" class="btn btn-danger" onclick="cerrarModal()">
                        ❌ Cancelar
                    </button>
                    <button type="submit" class="btn btn-success">
                        💾 Guardar Configuración
                    </button>
                </div>
            </form>
        </div>
    </div>
    
    <!-- Footer -->
    <footer class="main-footer">
        <div class="footer-content">
            © 2025 Sistema de Asistencia Escolar. Todos los derechos reservados.
        </div>
    </footer>
    
    <script>
        function abrirModal() {
            document.getElementById('modalConfig').classList.add('active');
        }
        
        function cerrarModal() {
            document.getElementById('modalConfig').classList.remove('active');
        }
        
        function eliminarConfig(id) {
            if (confirm('¿Está seguro de eliminar esta configuración?\n\nEsta acción no se puede deshacer.')) {
                window.location.href = 'ConfiguracionLimiteServlet?accion=eliminar&id=' + id + 
                                      '&turnoId=<%= turnoId %>';
            }
        }
        
        // Cerrar modal al hacer click fuera
        document.getElementById('modalConfig').addEventListener('click', function(e) {
            if (e.target === this) {
                cerrarModal();
            }
        });
        
        // Cerrar modal con tecla Escape
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                cerrarModal();
            }
        });
    </script>
</body>
</html>
