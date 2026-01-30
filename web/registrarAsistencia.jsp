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
    String fechaStr = request.getParameter("fecha");
    String horaClaseStr = request.getParameter("horaClase");
    
    int cursoId = cursoIdStr != null ? Integer.parseInt(cursoIdStr) : 0;
    int turnoId = turnoIdStr != null ? Integer.parseInt(turnoIdStr) : 0;
    LocalDate fecha = fechaStr != null ? LocalDate.parse(fechaStr) : LocalDate.now();
    LocalTime horaClase = horaClaseStr != null ? LocalTime.parse(horaClaseStr) : LocalTime.of(8, 0);
    
    // DAOs
    AsistenciaDAO asistenciaDAO = new AsistenciaDAO();
    AlumnoDAO alumnoDAO = new AlumnoDAO();
    CursoDAO cursoDAO = new CursoDAO();
    TurnoDAO turnoDAO = new TurnoDAO();
    ConfiguracionLimiteDAO configuracionDAO = new ConfiguracionLimiteDAO();
    
    // Obtener datos
    Curso curso = null;
    List<Alumno> alumnos = new ArrayList<>();
    List<Asistencia> asistenciasExistentes = new ArrayList<>();
    boolean puedeEditar = true;
    String mensajeLimite = "";
    
    if (cursoId > 0 && turnoId > 0) {
        curso = cursoDAO.obtenerCursoPorId(cursoId);
        alumnos = alumnoDAO.obtenerAlumnosPorCurso(cursoId, turnoId);
        asistenciasExistentes = asistenciaDAO.obtenerAsistenciasPorCursoYFecha(cursoId, turnoId, fecha);
        
        // Verificar si puede editar
        puedeEditar = configuracionDAO.puedeEditarAsistencia(cursoId, turnoId, fecha, horaClase);
        mensajeLimite = configuracionDAO.obtenerMensajeTiempoLimite(cursoId, turnoId, fecha, horaClase);
    }
    
    // Crear mapa de asistencias existentes
    Map<Integer, Asistencia> mapaAsistencias = new HashMap<>();
    for (Asistencia asist : asistenciasExistentes) {
        mapaAsistencias.put(asist.getAlumnoId(), asist);
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
    <title>Registrar Asistencia - Sistema Escolar</title>
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
        
        /* Container Principal */
        .container {
            flex: 1;
            max-width: 1400px;
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
        
        .alert-warning {
            background-color: #fff3cd;
            color: #856404;
            border-left: 4px solid #ffc107;
        }
        
        .alert-info {
            background-color: #d1ecf1;
            color: #0c5460;
            border-left: 4px solid #17a2b8;
        }
        
        /* Mensaje de Bloqueo */
        .locked-message {
            background-color: #f8d7da;
            border: 3px solid #dc3545;
            border-radius: 12px;
            padding: 30px;
            text-align: center;
            margin-bottom: 25px;
        }
        
        .locked-message .icon {
            font-size: 64px;
            color: #dc3545;
            margin-bottom: 15px;
        }
        
        .locked-message h3 {
            font-size: 24px;
            color: #721c24;
            margin-bottom: 10px;
        }
        
        .locked-message p {
            font-size: 16px;
            color: #721c24;
        }
        
        /* Formulario de Filtros */
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
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
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
        
        .form-control:disabled {
            background-color: #f5f5f5;
            cursor: not-allowed;
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
        
        .btn-primary:hover:not(:disabled) {
            background-color: #7FB3D5;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(168, 216, 234, 0.4);
        }
        
        .btn-primary:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }
        
        .btn-success {
            background-color: #28a745;
            color: #ffffff;
        }
        
        .btn-success:hover:not(:disabled) {
            background-color: #218838;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(40, 167, 69, 0.4);
        }
        
        /* Tabla */
        .table-container {
            background-color: #ffffff;
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            margin-bottom: 25px;
        }
        
        .table-header {
            background-color: #f8f9fa;
            padding: 20px;
            border-bottom: 2px solid #e0e0e0;
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
        
        /* Radio Buttons */
        .radio-group {
            display: flex;
            gap: 15px;
            flex-wrap: wrap;
        }
        
        .radio-option {
            display: flex;
            align-items: center;
            gap: 6px;
            cursor: pointer;
        }
        
        .radio-option input[type="radio"] {
            cursor: pointer;
            width: 18px;
            height: 18px;
            accent-color: #A8D8EA;
        }
        
        .radio-option input[type="radio"]:disabled {
            cursor: not-allowed;
        }
        
        /* Badges */
        .badge {
            display: inline-block;
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
        }
        
        .badge-presente {
            background-color: #d4edda;
            color: #155724;
        }
        
        .badge-tardanza {
            background-color: #fff3cd;
            color: #856404;
        }
        
        .badge-ausente {
            background-color: #f8d7da;
            color: #721c24;
        }
        
        .badge-justificado {
            background-color: #d1ecf1;
            color: #0c5460;
        }
        
        /* Footer de Tabla */
        .table-footer {
            padding: 20px;
            text-align: right;
            background-color: #f8f9fa;
            border-top: 2px solid #e0e0e0;
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
        
        /* Info Box */
        .info-box {
            background-color: #A8D8EA;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 25px;
        }
        
        .info-box p {
            margin: 8px 0;
            line-height: 1.6;
            color: #000000;
        }
        
        .info-box strong {
            color: #000000;
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
            
            .form-row {
                grid-template-columns: 1fr;
            }
            
            table {
                font-size: 13px;
            }
            
            th, td {
                padding: 10px;
            }
            
            .radio-group {
                flex-direction: column;
                gap: 8px;
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
            <h1>✅ Registrar Asistencia</h1>
            <p>Gestiona la asistencia de los alumnos de forma rápida y eficiente</p>
        </div>
        
        <!-- Mensajes -->
        <% if (mensaje != null) { %>
            <div class="alert alert-<%= tipoMensaje %>">
                <span><%= mensaje %></span>
            </div>
        <% } %>
        
        <!-- Información de Límite de Tiempo -->
        <% if (cursoId > 0 && turnoId > 0) { %>
            <div class="info-box">
                <p><strong>⏰ Estado de Edición:</strong> <%= mensajeLimite %></p>
                <% if (!puedeEditar) { %>
                    <p><strong>⚠️ IMPORTANTE:</strong> Ya no puedes modificar esta asistencia porque el tiempo límite ha vencido.</p>
                <% } %>
            </div>
        <% } %>
        
        <!-- Mensaje de Bloqueo -->
        <% if (cursoId > 0 && turnoId > 0 && !puedeEditar) { %>
            <div class="locked-message">
                <div class="icon">🔒</div>
                <h3>Edición Bloqueada</h3>
                <p><%= mensajeLimite %></p>
                <p>Para modificar esta asistencia, contacta al administrador del sistema.</p>
            </div>
        <% } %>
        
        <!-- Formulario de Filtros -->
        <div class="filter-section">
            <form method="GET" action="registrarAsistencia.jsp">
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
                    
                    <div class="form-group">
                        <label for="fecha">📅 Fecha</label>
                        <input type="date" name="fecha" id="fecha" class="form-control" 
                               value="<%= fecha %>" 
                               max="<%= LocalDate.now() %>" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="horaClase">⏰ Hora de Clase</label>
                        <input type="time" name="horaClase" id="horaClase" class="form-control" 
                               value="<%= horaClase %>" required>
                    </div>
                </div>
                
                <button type="submit" class="btn btn-primary">
                    🔄 Cargar Asistencia
                </button>
            </form>
        </div>
        
        <!-- Tabla de Asistencias -->
        <% if (cursoId > 0 && turnoId > 0 && alumnos.size() > 0) { %>
            <div class="table-container">
                <div class="table-header">
                    <h2>👥 Lista de Alumnos - <%= curso != null ? curso.getNombre() : "" %></h2>
                </div>
                
                <form method="POST" action="AsistenciaServlet">
                    <input type="hidden" name="accion" value="registrar">
                    <input type="hidden" name="cursoId" value="<%= cursoId %>">
                    <input type="hidden" name="turnoId" value="<%= turnoId %>">
                    <input type="hidden" name="fecha" value="<%= fecha %>">
                    <input type="hidden" name="horaClase" value="<%= horaClase %>">
                    
                    <table>
                        <thead>
                            <tr>
                                <th>N°</th>
                                <th>Alumno</th>
                                <th>Estado Actual</th>
                                <th>Marcar Asistencia</th>
                                <th>Observaciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                            int contador = 1;
                            for (Alumno alumno : alumnos) { 
                                Asistencia asistExistente = mapaAsistencias.get(alumno.getId());
                                String estadoActual = asistExistente != null ? asistExistente.getEstadoString() : "Sin registro";
                                String observaciones = asistExistente != null && asistExistente.getObservaciones() != null ? asistExistente.getObservaciones() : "";
                            %>
                                <tr>
                                    <td><%= contador++ %></td>
                                    <td>
                                        <strong><%= alumno.getNombreCompleto() %></strong>
                                    </td>
                                    <td>
                                        <% if (asistExistente != null) { %>
                                            <span class="badge badge-<%= estadoActual.toLowerCase() %>">
                                                <%= estadoActual %>
                                            </span>
                                        <% } else { %>
                                            <span style="color: #999;">Sin registro</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <div class="radio-group">
                                            <label class="radio-option">
                                                <input type="radio" name="estado_<%= alumno.getId() %>" 
                                                       value="PRESENTE"
                                                       <%= "PRESENTE".equals(estadoActual) ? "checked" : "" %>
                                                       <%= !puedeEditar ? "disabled" : "" %>>
                                                ✓ Presente
                                            </label>
                                            <label class="radio-option">
                                                <input type="radio" name="estado_<%= alumno.getId() %>" 
                                                       value="TARDANZA"
                                                       <%= "TARDANZA".equals(estadoActual) ? "checked" : "" %>
                                                       <%= !puedeEditar ? "disabled" : "" %>>
                                                ⏱ Tardanza
                                            </label>
                                            <label class="radio-option">
                                                <input type="radio" name="estado_<%= alumno.getId() %>" 
                                                       value="AUSENTE"
                                                       <%= ("AUSENTE".equals(estadoActual) || asistExistente == null) ? "checked" : "" %>
                                                       <%= !puedeEditar ? "disabled" : "" %>>
                                                ✗ Ausente
                                            </label>
                                        </div>
                                    </td>
                                    <td>
                                        <input type="text" name="observaciones_<%= alumno.getId() %>" 
                                               class="form-control" 
                                               value="<%= observaciones %>"
                                               placeholder="Opcional"
                                               <%= !puedeEditar ? "disabled" : "" %>>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                    
                    <div class="table-footer">
                        <button type="submit" class="btn btn-success" <%= !puedeEditar ? "disabled" : "" %>>
                            💾 Guardar Asistencias
                        </button>
                    </div>
                </form>
            </div>
        <% } else if (cursoId > 0 && turnoId > 0 && alumnos.size() == 0) { %>
            <div class="alert alert-warning">
                <span>⚠️ No hay alumnos registrados en este curso y turno.</span>
            </div>
        <% } %>
    </div>
    
    <!-- Footer -->
    <footer class="main-footer">
        <div class="footer-content">
            © 2025 Sistema de Asistencia Escolar. Todos los derechos reservados.
        </div>
    </footer>
</body>
</html>
