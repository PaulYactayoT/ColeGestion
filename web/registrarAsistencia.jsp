<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="modelo.*, java.util.*, java.time.*" %>
<%
    // Validar sesión
    String rol = (String) session.getAttribute("rol");
    if (rol == null || (!rol.equals("admin") && !rol.equals("docente"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Obtener datos que el Servlet pasa por request.setAttribute
    List<Curso> cursos = (List<Curso>) request.getAttribute("cursos");
    List<Alumno> alumnos = (List<Alumno>) request.getAttribute("alumnos");
    Curso cursoSeleccionado = (Curso) request.getAttribute("cursoSeleccionado");
    List<Asistencia> asistenciasExistentes = (List<Asistencia>) request.getAttribute("asistenciasExistentes");
    Boolean puedeEditar = (Boolean) request.getAttribute("puedeEditar");
    String mensajeLimite = (String) request.getAttribute("mensajeLimite");
    
    // Parámetros
    String cursoIdParam = (String) request.getAttribute("cursoIdParam");
    String fechaParam = (String) request.getAttribute("fechaParam");
    String turnoIdParam = (String) request.getAttribute("turnoIdParam");
    String horaClaseParam = (String) request.getAttribute("horaClaseParam");
    
    // Valores por defecto
    if (cursos == null) cursos = new ArrayList<>();
    if (alumnos == null) alumnos = new ArrayList<>();
    if (asistenciasExistentes == null) asistenciasExistentes = new ArrayList<>();
    if (puedeEditar == null) puedeEditar = true;
    if (mensajeLimite == null) mensajeLimite = "";
    if (fechaParam == null) fechaParam = LocalDate.now().toString();
    if (horaClaseParam == null) horaClaseParam = "08:00";
    if (turnoIdParam == null) turnoIdParam = "1";
    
    // Crear mapa de asistencias existentes
    Map<Integer, Asistencia> mapaAsistencias = new HashMap<>();
    for (Asistencia asist : asistenciasExistentes) {
        mapaAsistencias.put(asist.getAlumnoId(), asist);
    }
    
    // Mensajes
    String mensaje = (String) session.getAttribute("mensaje");
    String error = (String) session.getAttribute("error");
    String advertencia = (String) session.getAttribute("advertencia");
    
    // Limpiar mensajes de sesión después de mostrarlos
    session.removeAttribute("mensaje");
    session.removeAttribute("error");
    session.removeAttribute("advertencia");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registrar Asistencia - Sistema Escolar</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
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
            opacity: 0.85;
        }
        
        .btn-back {
            display: flex;
            align-items: center;
            gap: 8px;
            background-color: #000000;
            color: #ffffff;
            padding: 12px 24px;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 600;
            font-size: 15px;
            transition: all 0.3s ease;
        }
        
        .btn-back:hover {
            background-color: #333333;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
            color: #ffffff;
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
            
            .page-header {
                flex-direction: column;
                gap: 15px;
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
            <div class="header-left">
                <img src="assets/img/logosa.png" alt="Logo" class="logo-img">
                <span class="header-title">Colegio SA</span>
            </div>
            <div class="header-right">
                <div class="header-user">
                    <i class="bi bi-person-circle"></i>
                    <span><%= session.getAttribute("nombres") %></span>
                </div>
                <a href="LogoutServlet" class="btn-logout">
                    <i class="bi bi-box-arrow-right"></i>
                    <span>Cerrar sesión</span>
                </a>
            </div>
        </div>
    </header>
    
    <!-- Container Principal -->
    <div class="container">
        <!-- Titulo de Pagina -->
        <div class="page-header">
            <div class="page-header-left">
                <h1><i class="bi bi-clipboard-check"></i> Registrar Asistencia</h1>
                <p>Gestiona la asistencia de los alumnos de forma rapida y eficiente</p>
            </div>
            <a href="DocenteDashboardServlet" class="btn-back">
                <i class="bi bi-arrow-left-circle"></i>
                <span>Volver al Panel</span>
            </a>
        </div>
        
        <!-- Mensajes -->
        <% if (mensaje != null) { %>
            <div class="alert alert-success">
                <span><i class="bi bi-check-circle"></i> <%= mensaje %></span>
            </div>
        <% } %>
        
        <% if (error != null) { %>
            <div class="alert alert-error">
                <span><i class="bi bi-x-circle"></i> <%= error %></span>
            </div>
        <% } %>
        
        <% if (advertencia != null) { %>
            <div class="alert alert-warning">
                <span><i class="bi bi-exclamation-triangle"></i> <%= advertencia %></span>
            </div>
        <% } %>
        
        <!-- Informacion de Limite de Tiempo -->
        <% if (cursoSeleccionado != null && mensajeLimite != null && !mensajeLimite.isEmpty()) { %>
            <div class="info-box">
                <p><strong><i class="bi bi-clock"></i> Estado de Edicion:</strong> <%= mensajeLimite %></p>
                <% if (!puedeEditar) { %>
                    <p><strong><i class="bi bi-exclamation-triangle"></i> IMPORTANTE:</strong> Ya no puedes modificar esta asistencia porque el tiempo limite ha vencido.</p>
                <% } %>
            </div>
        <% } %>
        
        <!-- Mensaje de Bloqueo -->
        <% if (cursoSeleccionado != null && !puedeEditar) { %>
            <div class="locked-message">
                <div class="icon"><i class="bi bi-lock" style="font-size: 64px;"></i></div>
                <h3>Edicion Bloqueada</h3>
                <p><%= mensajeLimite %></p>
                <p>Para modificar esta asistencia, contacta al administrador del sistema.</p>
            </div>
        <% } %>
        
        <!-- Formulario de Filtros -->
        <div class="filter-section">
            <form method="GET" action="AsistenciaServlet">
                <input type="hidden" name="accion" value="registrar">
                <div class="form-row">
                    <div class="form-group">
                        <label for="curso_id"><i class="bi bi-book"></i> Curso</label>
                        <select name="curso_id" id="curso_id" class="form-control" required>
                            <option value="">-- Seleccione un curso --</option>
                            <% for (Curso c : cursos) { %>
                                <option value="<%= c.getId() %>" <%= c.getId() == (cursoSeleccionado != null ? cursoSeleccionado.getId() : 0) ? "selected" : "" %>>
                                    <%= c.getNombre() %><%= c.getGradoNombre() != null ? " - " + c.getGradoNombre() : "" %>
                                </option>
                            <% } %>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="turno_id"><i class="bi bi-clock"></i> Turno</label>
                        <select name="turno_id" id="turno_id" class="form-control" required>
                            <option value="1" <%= "1".equals(turnoIdParam) ? "selected" : "" %>>Manana</option>
                            <option value="2" <%= "2".equals(turnoIdParam) ? "selected" : "" %>>Tarde</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="fecha"><i class="bi bi-calendar"></i> Fecha</label>
                        <input type="date" name="fecha" id="fecha" class="form-control" 
                               value="<%= fechaParam %>" 
                               max="<%= LocalDate.now() %>" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="hora_clase"><i class="bi bi-alarm"></i> Hora de Clase</label>
                        <input type="time" name="hora_clase" id="hora_clase" class="form-control" 
                               value="<%= horaClaseParam %>" required>
                    </div>
                </div>
                
                <button type="submit" class="btn btn-primary">
                    <i class="bi bi-arrow-repeat"></i> Cargar Asistencia
                </button>
            </form>
        </div>
        
        <!-- Tabla de Asistencias -->
        <% if (cursoSeleccionado != null && alumnos != null && alumnos.size() > 0) { %>
            <div class="table-container">
                <div class="table-header">
                    <h2><i class="bi bi-people"></i> Lista de Alumnos - <%= cursoSeleccionado.getNombre() %></h2>
                </div>
                
                <form method="POST" action="AsistenciaServlet">
                    <input type="hidden" name="accion" value="registrarGrupal">
                    <input type="hidden" name="cursoId" value="<%= cursoSeleccionado.getId() %>">
                    <input type="hidden" name="turnoId" value="<%= turnoIdParam %>">
                    <input type="hidden" name="fecha" value="<%= fechaParam %>">
                    <input type="hidden" name="horaClase" value="<%= horaClaseParam %>">
                    
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
                                                <i class="bi bi-check-circle"></i> Presente
                                            </label>
                                            <label class="radio-option">
                                                <input type="radio" name="estado_<%= alumno.getId() %>" 
                                                       value="TARDANZA"
                                                       <%= "TARDANZA".equals(estadoActual) ? "checked" : "" %>
                                                       <%= !puedeEditar ? "disabled" : "" %>>
                                                <i class="bi bi-clock-history"></i> Tardanza
                                            </label>
                                            <label class="radio-option">
                                                <input type="radio" name="estado_<%= alumno.getId() %>" 
                                                       value="AUSENTE"
                                                       <%= ("AUSENTE".equals(estadoActual) || asistExistente == null) ? "checked" : "" %>
                                                       <%= !puedeEditar ? "disabled" : "" %>>
                                                <i class="bi bi-x-circle"></i> Ausente
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
                            <i class="bi bi-save"></i> Guardar Asistencias
                        </button>
                    </div>
                </form>
            </div>
        <% } else if (cursoSeleccionado != null && (alumnos == null || alumnos.size() == 0)) { %>
            <div class="alert alert-warning">
                <span><i class="bi bi-exclamation-triangle"></i> No hay alumnos registrados en este curso y turno.</span>
            </div>
        <% } %>
    </div>
    
    <!-- Footer -->
    <footer class="main-footer">
        <div class="footer-content">
            &copy; 2025 Sistema de Asistencia Escolar. Todos los derechos reservados.
        </div>
    </footer>
</body>
</html>
