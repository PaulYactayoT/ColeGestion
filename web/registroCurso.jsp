<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, modelo.Curso" %>

<%
    // ========== VALIDACIÓN DE SESIÓN ==========
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    String rol = (String) session.getAttribute("rol");
    if (!"admin".equals(rol)) {
        response.sendRedirect("acceso_denegado.jsp");
        return;
    }

    // ========== OBTENER DATOS ==========
    List<Map<String, Object>> turnos = (List<Map<String, Object>>) request.getAttribute("turnos");
    
    if (turnos == null) {
        turnos = new ArrayList<>();
    }
    
    String mensaje = (String) session.getAttribute("mensaje");
    String error = (String) session.getAttribute("error");
    session.removeAttribute("mensaje");
    session.removeAttribute("error");
%>
<%
    // ========== DATOS PARA MODO EDICIÓN ==========
    Curso cursoEditar = (Curso) request.getAttribute("cursoEditar");
    List<Map<String, Object>> horariosEditar = (List<Map<String, Object>>) request.getAttribute("horariosEditar");
    Boolean modoEdicion = (Boolean) request.getAttribute("modoEdicion");
    
    if (modoEdicion == null) modoEdicion = false;
    
    // Debug
    if (modoEdicion && cursoEditar != null) {
        System.out.println("  JSP - Modo edición activado");
        System.out.println("   Curso: " + cursoEditar.getNombre());
        System.out.println("   ID: " + cursoEditar.getId());
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= modoEdicion ? "Editar Curso" : "Registrar Curso"%> - Colegio SA</title>
    
    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <!-- CSS Personalizado -->
    <link rel="stylesheet" href="assets/css/estilos.css">
    
    <style>
        :root {
            --primary-color: #2563eb;
            --primary-dark: #1e40af;
            --secondary-color: #64748b;
            --success-color: #10b981;
            --danger-color: #ef4444;
            --warning-color: #f59e0b;
            --info-color: #3b82f6;
            --background-light: #f8fafc;
            --card-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            --card-shadow-hover: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
        }

        body.dashboard-page {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        .form-container {
            max-width: 1100px;
            margin: 2rem auto;
            padding: 0 1rem;
            flex: 1;
        }

        .form-card {
            background: white;
            border-radius: 20px;
            box-shadow: var(--card-shadow-hover);
            overflow: hidden;
            animation: slideUp 0.5s ease-out;
        }

        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .form-header {
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-dark) 100%);
            color: white;
            padding: 2rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .form-header h2 {
            margin: 0;
            font-size: 1.75rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        .form-header .icon {
            font-size: 2rem;
        }

        .form-body {
            padding: 2.5rem;
        }

        .form-section {
            background: #f8fafc;
            border-radius: 15px;
            padding: 2rem;
            margin-bottom: 2rem;
            border: 2px solid #e2e8f0;
            transition: all 0.3s ease;
        }

        .form-section:hover {
            border-color: var(--primary-color);
            box-shadow: 0 4px 12px rgba(37, 99, 235, 0.1);
        }

        .section-title {
            color: #1e293b;
            font-size: 1.25rem;
            font-weight: 700;
            margin-bottom: 1.5rem;
            padding-bottom: 0.75rem;
            border-bottom: 3px solid var(--primary-color);
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        .section-title i {
            font-size: 1.5rem;
            color: var(--primary-color);
        }

        .section-title .step-number {
            background: var(--primary-color);
            color: white;
            width: 35px;
            height: 35px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 1.1rem;
        }

        .form-label {
            font-weight: 600;
            color: #334155;
            margin-bottom: 0.5rem;
            font-size: 0.95rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .form-label i {
            color: var(--primary-color);
        }

        .text-danger {
            color: var(--danger-color) !important;
        }

        .form-control, .form-select, textarea.form-control {
            border: 2px solid #e2e8f0;
            border-radius: 10px;
            padding: 0.75rem 1rem;
            font-size: 1rem;
            transition: all 0.3s ease;
        }

        .form-control:focus, .form-select:focus, textarea.form-control:focus {
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
        }

        .form-control:disabled, .form-select:disabled {
            background-color: #f1f5f9;
            cursor: not-allowed;
            opacity: 0.6;
        }

        .form-select {
            cursor: pointer;
            background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3e%3cpath fill='none' stroke='%232563eb' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M2 5l6 6 6-6'/%3e%3c/svg%3e");
        }

        small.text-muted {
            color: #64748b !important;
            font-size: 0.85rem;
            display: block;
            margin-top: 0.25rem;
        }

        /* Días de la semana */
        .dias-semana {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
            gap: 1rem;
        }

        .dia-checkbox {
            position: relative;
        }

        .dia-checkbox input[type="checkbox"] {
            display: none;
        }

        .dia-checkbox label {
            display: block;
            padding: 1.25rem;
            border: 3px solid #e2e8f0;
            border-radius: 12px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s ease;
            background: white;
            font-weight: 600;
        }

        .dia-checkbox input[type="checkbox"]:checked + label {
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-dark) 100%);
            color: white;
            border-color: var(--primary-color);
            transform: translateY(-3px);
            box-shadow: 0 8px 16px rgba(37, 99, 235, 0.3);
        }

        .dia-checkbox label:hover {
            border-color: var(--primary-color);
            box-shadow: 0 4px 12px rgba(37, 99, 235, 0.2);
            transform: translateY(-2px);
        }

        .dia-checkbox label i {
            font-size: 1.5rem;
            display: block;
            margin-bottom: 0.5rem;
        }

        /* Horarios agregados */
        .horario-item {
            background: white;
            border: 2px solid #e2e8f0;
            border-radius: 12px;
            padding: 1.25rem;
            margin-bottom: 1rem;
            position: relative;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .horario-item:hover {
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            border-color: var(--primary-color);
        }

        .horario-item strong {
            color: var(--primary-color);
            font-size: 1.1rem;
        }

        .btn-remove-horario {
            background: var(--danger-color);
            color: white;
            border: none;
            padding: 0.5rem 1rem;
            border-radius: 8px;
            transition: all 0.3s ease;
        }

        .btn-remove-horario:hover {
            background: #dc2626;
            transform: scale(1.05);
        }

        /* Alertas */
        .alert {
            border-radius: 12px;
            border: none;
            padding: 1rem 1.25rem;
            margin-bottom: 1.5rem;
            animation: slideDown 0.4s ease-out;
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        @keyframes slideDown {
            from {
                opacity: 0;
                transform: translateY(-20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .alert i {
            font-size: 1.5rem;
        }

        .alert-success {
            background: #d1fae5;
            color: #065f46;
            border-left: 4px solid var(--success-color);
        }

        .alert-danger {
            background: #fee2e2;
            color: #991b1b;
            border-left: 4px solid var(--danger-color);
        }

        .alert-warning {
            background: #fef3c7;
            color: #92400e;
            border-left: 4px solid var(--warning-color);
        }

        #validation-message {
            display: none;
        }

        /* Botones */
        .btn {
            border-radius: 10px;
            padding: 0.75rem 1.75rem;
            font-weight: 600;
            font-size: 1rem;
            transition: all 0.3s ease;
            border: none;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            justify-content: center;
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-dark) 100%);
            color: white;
        }

        .btn-primary:hover:not(:disabled) {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(37, 99, 235, 0.3);
            color: white;
        }

        .btn-secondary {
            background: var(--secondary-color);
            color: white;
        }

        .btn-secondary:hover {
            background: #475569;
            transform: translateY(-2px);
            color: white;
        }

        .btn-outline-primary {
            border: 2px solid var(--primary-color);
            color: var(--primary-color);
            background: white;
        }

        .btn-outline-primary:hover:not(:disabled) {
            background: var(--primary-color);
            color: white;
            transform: translateY(-2px);
        }

        .btn:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }

        .btn-lg {
            padding: 1rem 2.5rem;
            font-size: 1.1rem;
        }

        footer {
            margin-top: auto;
            background-color: #1a1a1a !important;
        }

        footer .logo-container img {
            border-radius: 15px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.3);
            background-color: white;
            padding: 5px;
        }

        footer h5 {
            font-weight: 700;
            margin-bottom: 1rem;
            color: #fff;
            font-size: 1.1rem;
        }

        footer p {
            color: #d1d5db;
            line-height: 1.8;
        }

        footer a {
            text-decoration: none;
            transition: all 0.3s ease;
            display: inline-block;
            color: #d1d5db;
        }

        footer a:hover {
            transform: translateX(5px);
            color: #60a5fa !important;
        }

        footer .border-top {
            border-color: #374151 !important;
        }

        footer i {
            color: #60a5fa;
        }

        @media (max-width: 768px) {
            .form-body {
                padding: 1.5rem;
            }

            .form-header {
                flex-direction: column;
                gap: 1rem;
                text-align: center;
            }

            .form-header h2 {
                font-size: 1.5rem;
            }

            .section-title {
                font-size: 1.1rem;
            }

            .dias-semana {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        /* Entrada de horario temporal */
        #horarioEntry {
            background: linear-gradient(135deg, #f0f9ff 0%, #e0f2fe 100%);
            border: 2px dashed var(--primary-color);
        }

        #horarioEntry label {
            color: var(--primary-color);
            font-weight: 600;
            margin-top: 0.75rem;
            margin-bottom: 0.25rem;
        }
    </style>
</head>
<body class="dashboard-page">

    <!-- Header -->
    <jsp:include page="header.jsp" />

    <div class="form-container">
        <div class="form-card">
            <!-- Header del Formulario -->
            <div class="form-header">
                <h2>
                    <i class="bi <%= modoEdicion ? "bi-pencil-square" : "bi-book"%> icon"></i>
                    <%= modoEdicion ? "Editar Curso" : "Registrar Nuevo Curso"%>
                </h2>
                <a href="CursoServlet" class="btn btn-secondary">
                    <i class="bi bi-arrow-left"></i> Volver
                </a>
            </div>

            <div class="form-body">
                <!-- ========== MENSAJES ========== -->
                <% if (mensaje != null) { %>
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="bi bi-check-circle-fill"></i>
                    <div><%= mensaje %></div>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <% } %>
                
                <% if (error != null) { %>
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="bi bi-exclamation-triangle-fill"></i>
                    <div><%= error %></div>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <% } %>

                <!-- ========== FORMULARIO ========== -->
                <form id="formRegistroCurso" action="RegistroCursoServlet" method="post">
                    <% if (modoEdicion && cursoEditar != null) { %>
                        <input type="hidden" name="curso_id" value="<%= cursoEditar.getId() %>">
                        <input type="hidden" name="accion" value="actualizar">
                    <% } else { %>
                        <input type="hidden" name="accion" value="registrar">
                    <% } %>
                
                    <!-- ✅ CAMPOS HIDDEN NECESARIOS PARA EL JAVASCRIPT ✅ -->
                    <input type="hidden" id="inputNivel" name="nivel" value="">
                    <input type="hidden" id="inputArea" name="area" value="">
                    <!-- ============================================== -->
                
                    <!-- ========== SECCIÓN 1: NIVEL Y GRADO ========== -->
                    <div class="form-section">
                        <div class="section-title">
                            <span class="step-number">1</span>
                            <i class="bi bi-diagram-3-fill"></i>
                            Seleccionar Nivel y Grado
                        </div>

                        <div class="row">
                            <!-- Nivel Educativo -->
                            <div class="col-md-6 mb-3">
                                <label class="form-label">
                                    <i class="bi bi-mortarboard-fill"></i>
                                    Nivel Educativo <span class="text-danger">*</span>
                                </label>
                                <select name="nivel_select" id="selectNivel" class="form-select" required>
                                    <option value="">-- Seleccione un nivel --</option>
                                    <option value="INICIAL">🎨 INICIAL (3-5 años)</option>
                                    <option value="PRIMARIA">📚 PRIMARIA (1° - 6°)</option>
                                    <option value="SECUNDARIA">🎓 SECUNDARIA (1° - 5°)</option>
                                </select>
                                <small class="text-muted">
                                    <i class="bi bi-info-circle"></i> Primero seleccione el nivel educativo
                                </small>
                            </div>

                            <!-- Grado -->
                            <div class="col-md-6 mb-3">
                                <label class="form-label">
                                    <i class="bi bi-bookmark-fill"></i>
                                    Grado <span class="text-danger">*</span>
                                </label>
                                <select name="grado" id="selectGrado" class="form-select" required disabled>
                                    <option value="">Seleccione primero un nivel</option>
                                </select>
                                <small class="text-muted" id="infoGrado">
                                    <i class="bi bi-lock-fill"></i> Se habilitará al seleccionar nivel
                                </small>
                            </div>
                        </div>
                    </div>

                    <!-- ========== SECCIÓN 2: TURNO ========== -->
                    <div class="form-section">
                        <div class="section-title">
                            <span class="step-number">2</span>
                            <i class="bi bi-clock-fill"></i>
                            Seleccionar Turno
                        </div>

                        <div class="row">
                            <div class="col-md-12 mb-3">
                                <label class="form-label">
                                    <i class="bi bi-clock-history"></i>
                                    Turno <span class="text-danger">*</span>
                                </label>
                                <select name="turno" id="selectTurno" class="form-select" required disabled>
                                    <option value="">Seleccione primero un grado</option>
                                    <% if (turnos != null && !turnos.isEmpty()) {
                                        for (Map<String, Object> turno : turnos) { %>
                                            <option value="<%= turno.get("id") %>" 
                                                    data-inicio="<%= turno.get("hora_inicio") %>"
                                                    data-fin="<%= turno.get("hora_fin") %>">
                                                <%= turno.get("nombre") %> 
                                                (<%= turno.get("hora_inicio") %> - <%= turno.get("hora_fin") %>)
                                            </option>
                                    <% }} %>
                                </select>
                                <small class="text-muted">
                                    <i class="bi bi-info-circle"></i> El turno determina el horario disponible
                                </small>
                            </div>
                        </div>
                    </div>

                    <!-- ========== SECCIÓN 3: ÁREA Y CURSO ========== -->
                    <div class="form-section">
                        <div class="section-title">
                            <span class="step-number">3</span>
                            <i class="bi bi-journal-bookmark-fill"></i>
                            Seleccionar Área y Curso
                        </div>

                        <div class="row">
                            <!-- Área -->
                            <div class="col-md-6 mb-3">
                                <label class="form-label">
                                    <i class="bi bi-folder-fill"></i>
                                    Área Académica <span class="text-danger">*</span>
                                </label>
                                <select id="selectArea" class="form-select" required disabled>
                                    <option value="">Seleccione primero un turno</option>
                                </select>
                                <small class="text-muted">
                                    <i class="bi bi-lock-fill"></i> Se habilitará al seleccionar turno
                                </small>
                            </div>

                            <!-- Curso -->
                            <div class="col-md-6 mb-3">
                                <label class="form-label">
                                    <i class="bi bi-book-fill"></i>
                                    Nombre del Curso <span class="text-danger">*</span>
                                </label>
                                <select name="curso" id="selectCurso" class="form-select" required disabled>
                                    <option value="">Seleccione primero un área</option>
                                </select>
                                <small class="text-muted">
                                    <i class="bi bi-lock-fill"></i> Se habilitará al seleccionar área
                                </small>
                            </div>
                        </div>
                    </div>

                    <!-- ========== SECCIÓN 4: PROFESOR Y DETALLES ========== -->
                    <div class="form-section">
                        <div class="section-title">
                            <span class="step-number">4</span>
                            <i class="bi bi-person-workspace"></i>
                            Profesor y Detalles del Curso
                        </div>

                        <div class="row">
                            <!-- Profesor -->
                            <div class="col-md-6 mb-3">
                                <label class="form-label">
                                    <i class="bi bi-person-badge-fill"></i>
                                    Profesor <span class="text-danger">*</span>
                                </label>
                                <select name="profesor" id="selectProfesor" class="form-select" required disabled>
                                    <option value="">Seleccione primero un curso</option>
                                </select>
                                <small class="text-muted">
                                    <i class="bi bi-funnel-fill"></i> Filtrado por área, turno y nivel
                                </small>
                            </div>

                            <!-- Créditos -->
                            <div class="col-md-6 mb-3">
                                <label class="form-label">
                                    <i class="bi bi-star-fill"></i>
                                    Créditos <span class="text-danger">*</span>
                                </label>
                                <input type="number" name="creditos" id="inputCreditos" 
                                       class="form-control" min="1" max="10" value="1" required>
                                <small class="text-muted">
                                    <i class="bi bi-info-circle"></i> Valor entre 1 y 10
                                </small>
                            </div>

                            <!-- Descripción -->
                            <div class="col-md-12 mb-3">
                                <label class="form-label">
                                    <i class="bi bi-text-paragraph"></i>
                                    Descripción del Curso
                                </label>
                                <textarea name="descripcion" id="inputDescripcion" 
                                          class="form-control" rows="3" 
                                          placeholder="Breve descripción del contenido del curso..."><%= (modoEdicion && cursoEditar != null && cursoEditar.getDescripcion() != null) ? cursoEditar.getDescripcion() : "" %></textarea>
                            </div>
                        </div>
                    </div>

                    <!-- ========== SECCIÓN 5: HORARIOS ========== -->
                    <div class="form-section">
                        <div class="section-title">
                            <span class="step-number">5</span>
                            <i class="bi bi-calendar-week-fill"></i>
                            Configurar Horarios de Clase
                        </div>

                        <!-- Días de la semana -->
                        <div class="mb-4">
                            <label class="form-label mb-3">
                                <i class="bi bi-calendar-range-fill"></i>
                                Días de clase <span class="text-danger">*</span>
                            </label>
                            <div class="dias-semana" id="diasSemana">
                                <div class="dia-checkbox">
                                    <input type="checkbox" id="diaLunes" value="LUNES">
                                    <label for="diaLunes">
                                        <i class="bi bi-calendar-day"></i>
                                        <strong>Lunes</strong>
                                    </label>
                                </div>
                                <div class="dia-checkbox">
                                    <input type="checkbox" id="diaMartes" value="MARTES">
                                    <label for="diaMartes">
                                        <i class="bi bi-calendar-day"></i>
                                        <strong>Martes</strong>
                                    </label>
                                </div>
                                <div class="dia-checkbox">
                                    <input type="checkbox" id="diaMiercoles" value="MIERCOLES">
                                    <label for="diaMiercoles">
                                        <i class="bi bi-calendar-day"></i>
                                        <strong>Miércoles</strong>
                                    </label>
                                </div>
                                <div class="dia-checkbox">
                                    <input type="checkbox" id="diaJueves" value="JUEVES">
                                    <label for="diaJueves">
                                        <i class="bi bi-calendar-day"></i>
                                        <strong>Jueves</strong>
                                    </label>
                                </div>
                                <div class="dia-checkbox">
                                    <input type="checkbox" id="diaViernes" value="VIERNES">
                                    <label for="diaViernes">
                                        <i class="bi bi-calendar-day"></i>
                                        <strong>Viernes</strong>
                                    </label>
                                </div>
                            </div>
                            <small class="text-muted d-block mt-2">
                                <i class="bi bi-info-circle"></i> Seleccione los días en los que se dictará el curso
                            </small>
                        </div>

                        <!-- Contenedor de horarios agregados -->
                        <div id="horariosContainer" class="mb-3">
                            <p class="text-muted">
                                <i class="bi bi-info-circle"></i> No hay horarios agregados aún
                            </p>
                        </div>

                        <!-- Mensaje de validación -->
                        <div id="validation-message"></div>

                        <!-- Botón agregar horario -->
                        <button type="button" id="btnAgregarHorario" class="btn btn-outline-primary" disabled>
                            <i class="bi bi-plus-circle"></i> Agregar Horario
                        </button>
                        <small class="text-muted d-block mt-2">
                            <i class="bi bi-lock-fill"></i> Seleccione días, turno y profesor para habilitar
                        </small>
                    </div>

                    <!-- ========== BOTONES DE ACCIÓN ========== -->
                    <div class="d-flex justify-content-end gap-2 mt-4 pt-3" style="border-top: 2px solid #e5e7eb;">
                        <a href="CursoServlet" class="btn btn-secondary btn-lg">
                            <i class="bi bi-x-circle"></i> Cancelar
                        </a>
                        <button type="submit" id="btnSubmit" class="btn btn-primary btn-lg" disabled>
                            <i class="bi bi-<%= modoEdicion ? "check-circle" : "save"%>"></i>
                            <%= modoEdicion ? "Guardar Cambios" : "Registrar Curso" %>
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Footer -->
    <footer class="text-white py-4 mt-5" style="background-color: #1a1a1a;">
        <div class="container text-center text-md-start">
            <div class="row">
                <div class="col-md-4 mb-3">
                    <div class="logo-container text-center">
                        <img src="assets/img/logosa.png" alt="Logo Colegio SA" class="img-fluid mb-2" width="90" height="auto">
                        <p class="fs-6 fw-light fst-italic">"Líderes en educación de calidad al más alto nivel"</p>
                    </div>
                </div>
                <div class="col-md-4 mb-3">
                    <h5 class="fs-6"><i class="bi bi-envelope-fill me-2"></i>Contacto</h5>
                    <p class="fs-6 mb-2"><i class="bi bi-geo-alt-fill me-2"></i>Av. El Sol 461, San Juan de Lurigancho 15434</p>
                    <p class="fs-6 mb-2"><i class="bi bi-telephone-fill me-2"></i>987 654 321</p>
                    <p class="fs-6 mb-0"><i class="bi bi-envelope-at-fill me-2"></i>colegiosanantonio@gmail.com</p>
                </div>
                <div class="col-md-4 mb-3">
                    <h5 class="fs-6"><i class="bi bi-share-fill me-2"></i>Síguenos</h5>
                    <a href="https://www.facebook.com/" class="text-white d-block fs-6 mb-2">
                        <i class="bi bi-facebook me-2"></i>Facebook
                    </a>
                    <a href="https://www.instagram.com/" class="text-white d-block fs-6 mb-2">
                        <i class="bi bi-instagram me-2"></i>Instagram
                    </a>
                    <a href="https://twitter.com/" class="text-white d-block fs-6 mb-2">
                        <i class="bi bi-twitter-x me-2"></i>Twitter
                    </a>
                    <a href="https://www.youtube.com/" class="text-white d-block fs-6 mb-2">
                        <i class="bi bi-youtube me-2"></i>YouTube
                    </a>
                </div>
            </div>
            <div class="text-center mt-3 pt-3 border-top">
                <p class="fs-6 mb-0">
                    <i class="bi bi-c-circle me-1"></i>2025 Colegio SA - Todos los derechos reservados
                </p>
            </div>
        </div>
    </footer>
    
    <script>
        const CONTEXTPATH = '<%= request.getContextPath() %>';
    </script>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- ========== JAVASCRIPT COMPLETO ========== -->
    <script>
        // ========== VARIABLES GLOBALES ==========
        let horariosAgregados = [];
        let contadorHorarios = 0;
        let nivelSeleccionado = '';
        let turnoSeleccionado = null;

        // ========== INICIALIZAR AL CARGAR ==========
        document.addEventListener('DOMContentLoaded', function() {
            console.log('🚀 Inicializando formulario de registro');
            inicializarEventos();
        });

        // ========== FUNCIÓN PRINCIPAL DE INICIALIZACIÓN ==========
        function inicializarEventos() {
            document.getElementById('selectNivel').addEventListener('change', cambioNivel);
            document.getElementById('selectGrado').addEventListener('change', cambioGrado);
            document.getElementById('selectTurno').addEventListener('change', cambioTurno);
            document.getElementById('selectArea').addEventListener('change', cambioArea);
            document.getElementById('selectCurso').addEventListener('change', cambioCurso);
            document.getElementById('selectProfesor').addEventListener('change', cambioProfesor);
            
            document.querySelectorAll('#diasSemana input[type="checkbox"]').forEach(checkbox => {
                checkbox.addEventListener('change', verificarHabilitarAgregar);
            });
            
            document.getElementById('btnAgregarHorario').addEventListener('click', agregarHorario);
            document.getElementById('formRegistroCurso').addEventListener('input', validarFormulario);
        }

        // ========== 1. CAMBIO DE NIVEL ==========
        function cambioNivel() {
            const selectNivel = document.getElementById('selectNivel');
            const selectGrado = document.getElementById('selectGrado');
            
            nivelSeleccionado = selectNivel.value;
            document.getElementById('inputNivel').value = nivelSeleccionado;
            
            console.log('📚 Nivel seleccionado:', nivelSeleccionado);
            
            if (nivelSeleccionado) {
                selectGrado.disabled = false;
                selectGrado.innerHTML = '<option value="">Cargando grados...</option>';
                
                fetch(CONTEXTPATH + '/RegistroCursoServlet?accion=obtenerGrados&nivel=' + encodeURIComponent(nivelSeleccionado))
                    .then(response => {
                        if (!response.ok) {
                            throw new Error('HTTP error! status: ' + response.status);
                        }
                        return response.json();
                    })
                    .then(data => {
                        selectGrado.innerHTML = '<option value="">-- Seleccione un grado --</option>';
                        
                        if (data && data.length > 0) {
                            data.forEach(grado => {
                                const option = document.createElement('option');
                                option.value = grado.id;
                                option.textContent = grado.nombre + ' - ' + grado.nivel;
                                selectGrado.appendChild(option);
                            });
                            
                            document.getElementById('infoGrado').innerHTML = 
                                '<i class="bi bi-check-circle-fill text-success"></i> Grados cargados correctamente';
                        } else {
                            selectGrado.innerHTML = '<option value="">No hay grados disponibles</option>';
                            mostrarMensaje('No hay grados disponibles para este nivel', 'warning');
                        }
                    })
                    .catch(error => {
                        console.error('❌ Error al cargar grados:', error);
                        selectGrado.innerHTML = '<option value="">Error al cargar grados</option>';
                        selectGrado.disabled = true;
                        mostrarMensaje('Error al cargar grados: ' + error.message, 'danger');
                    });
                
                resetearCamposSiguientes(selectGrado);
            } else {
                selectGrado.disabled = true;
                selectGrado.innerHTML = '<option value="">Seleccione primero un nivel</option>';
                resetearCamposSiguientes(selectGrado);
            }
        }

        // ========== 2. CAMBIO DE GRADO ==========
        function cambioGrado() {
            const selectGrado = document.getElementById('selectGrado');
            const selectTurno = document.getElementById('selectTurno');
            const gradoId = selectGrado.value;
            
            console.log('🎓 Grado seleccionado:', gradoId);
            
            if (gradoId) {
                selectTurno.disabled = false;
                
                const infoGrado = document.getElementById('infoGrado');
                if (infoGrado) {
                    infoGrado.innerHTML = '<i class="bi bi-check-circle-fill text-success"></i> Grado seleccionado. Ahora seleccione un turno';
                }
                
                resetearCamposSiguientes(selectTurno);
            } else {
                selectTurno.disabled = true;
                selectTurno.selectedIndex = 0;
                resetearCamposSiguientes(selectTurno);
                
                const infoGrado = document.getElementById('infoGrado');
                if (infoGrado) {
                    infoGrado.innerHTML = '<i class="bi bi-lock-fill"></i> Se habilitará al seleccionar nivel';
                }
            }
        }

        // ========== 3. CAMBIO DE TURNO ==========
        function cambioTurno() {
            const selectTurno = document.getElementById('selectTurno');
            const selectArea = document.getElementById('selectArea');
            
            turnoSeleccionado = selectTurno.value;
            console.log('⏰ Turno seleccionado:', turnoSeleccionado);
            
            if (turnoSeleccionado && nivelSeleccionado) {
                selectArea.disabled = false;
                selectArea.innerHTML = '<option value="">Cargando áreas...</option>';
                
                fetch(CONTEXTPATH + '/RegistroCursoServlet?accion=obtenerAreas&nivel=' + encodeURIComponent(nivelSeleccionado))
                    .then(response => response.json())
                    .then(data => {
                        selectArea.innerHTML = '<option value="">-- Seleccione un área --</option>';
                        
                        if (data && data.length > 0) {
                            data.forEach(area => {
                                const option = document.createElement('option');
                                option.value = area.area;
                                option.textContent = area.area;
                                selectArea.appendChild(option);
                            });
                        } else {
                            selectArea.innerHTML = '<option value="">No hay áreas disponibles</option>';
                        }
                    })
                    .catch(error => {
                        console.error('❌ Error al cargar áreas:', error);
                        selectArea.innerHTML = '<option value="">Error al cargar áreas</option>';
                        mostrarMensaje('Error al cargar áreas', 'danger');
                    });
                
                resetearCamposSiguientes(selectArea);
            } else {
                selectArea.disabled = true;
                selectArea.innerHTML = '<option value="">Seleccione primero un turno</option>';
                resetearCamposSiguientes(selectArea);
            }
        }

        // ========== 4. CAMBIO DE ÁREA ==========
        function cambioArea() {
            const selectArea = document.getElementById('selectArea');
            const selectCurso = document.getElementById('selectCurso');
            const inputArea = document.getElementById('inputArea');
            const area = selectArea.value;
            
            inputArea.value = area;
            console.log('📖 Área seleccionada:', area);
            
            if (area) {
                selectCurso.disabled = false;
                selectCurso.innerHTML = '<option value="">Cargando cursos...</option>';
                
                fetch(CONTEXTPATH + '/RegistroCursoServlet?accion=obtenerCursos&area=' + encodeURIComponent(area))
                    .then(response => response.json())
                    .then(data => {
                        selectCurso.innerHTML = '<option value="">-- Seleccione un curso --</option>';
                        
                        if (data && data.length > 0) {
                            data.forEach(curso => {
                                const option = document.createElement('option');
                                option.value = curso.nombre;
                                option.textContent = curso.nombre;
                                if (curso.descripcion) option.title = curso.descripcion;
                                selectCurso.appendChild(option);
                            });
                        } else {
                            selectCurso.innerHTML = '<option value="">No hay cursos disponibles</option>';
                        }
                    })
                    .catch(error => {
                        console.error('❌ Error al cargar cursos:', error);
                        selectCurso.innerHTML = '<option value="">Error al cargar cursos</option>';
                        mostrarMensaje('Error al cargar cursos', 'danger');
                    });
                
                resetearCamposSiguientes(selectCurso);
            } else {
                selectCurso.disabled = true;
                selectCurso.innerHTML = '<option value="">Seleccione primero un área</option>';
                resetearCamposSiguientes(selectCurso);
            }
        }

        // ========== 5. CAMBIO DE CURSO ==========
        function cambioCurso() {
            const selectCurso = document.getElementById('selectCurso');
            const selectProfesor = document.getElementById('selectProfesor');
            const area = document.getElementById('inputArea').value;
            const curso = selectCurso.value;
            
            console.log('📘 Curso seleccionado:', curso);
            
            if (curso && area && turnoSeleccionado && nivelSeleccionado) {
                selectProfesor.disabled = false;
                selectProfesor.innerHTML = '<option value="">Cargando profesores...</option>';
                
                const url = CONTEXTPATH + '/RegistroCursoServlet?accion=obtenerProfesores'
                    + '&curso=' + encodeURIComponent(curso)
                    + '&turno=' + encodeURIComponent(turnoSeleccionado)
                    + '&nivel=' + encodeURIComponent(nivelSeleccionado);
                
                fetch(url)
                    .then(response => response.json())
                    .then(data => {
                        selectProfesor.innerHTML = '<option value="">-- Seleccione un profesor --</option>';
                        
                        if (data && data.length > 0) {
                            data.forEach(profesor => {
                                const option = document.createElement('option');
                                option.value = profesor.id;
                                option.textContent = profesor.nombre_completo + ' - ' + profesor.especialidad;
                                selectProfesor.appendChild(option);
                            });
                        } else {
                            selectProfesor.innerHTML = '<option value="">No hay profesores disponibles</option>';
                            mostrarMensaje('No hay profesores disponibles para este curso y turno', 'warning');
                        }
                    })
                    .catch(error => {
                        console.error('❌ Error al cargar profesores:', error);
                        selectProfesor.innerHTML = '<option value="">Error al cargar profesores</option>';
                        mostrarMensaje('Error al cargar profesores', 'danger');
                    });
            } else {
                selectProfesor.disabled = true;
                selectProfesor.innerHTML = '<option value="">Seleccione primero un curso</option>';
            }
        }

        // ========== 6. CAMBIO DE PROFESOR ==========
        function cambioProfesor() {
            console.log('👨‍🏫 Profesor seleccionado:', document.getElementById('selectProfesor').value);
            verificarHabilitarAgregar();
        }

        // ========== VERIFICAR SI HABILITAR BOTÓN AGREGAR ==========
        function verificarHabilitarAgregar() {
            const anyDiaChecked = Array.from(document.querySelectorAll('#diasSemana input[type="checkbox"]'))
                .some(cb => cb.checked);
            const turno = document.getElementById('selectTurno').value;
            const profesor = document.getElementById('selectProfesor').value;
            const btnAgregar = document.getElementById('btnAgregarHorario');

            if (anyDiaChecked && turno && profesor) {
                btnAgregar.disabled = false;
            } else {
                btnAgregar.disabled = true;
            }
            
            validarFormulario();
        }

        // ========== AGREGAR HORARIO ==========
        function agregarHorario() {
            if (document.getElementById('horarioEntry')) {
                return;
            }

            const container = document.createElement('div');
            container.id = 'horarioEntry';
            container.className = 'mt-3 p-3 border rounded';

            const diasSeleccionados = Array.from(document.querySelectorAll('#diasSemana input[type="checkbox"]'))
                .filter(cb => cb.checked)
                .map(cb => cb.value);

            const diaSelect = document.createElement('select');
            diaSelect.className = 'form-select mb-2';
            diaSelect.id = 'horarioDia';
            diasSeleccionados.forEach(d => {
                const o = document.createElement('option');
                o.value = d;
                o.textContent = d.charAt(0) + d.slice(1).toLowerCase();
                diaSelect.appendChild(o);
            });

            const horaInicio = document.createElement('input');
            horaInicio.type = 'time';
            horaInicio.className = 'form-control mb-2';
            horaInicio.id = 'horarioHoraInicio';

            const horaFin = document.createElement('input');
            horaFin.type = 'time';
            horaFin.className = 'form-control mb-2';
            horaFin.id = 'horarioHoraFin';

            const btnValidar = document.createElement('button');
            btnValidar.type = 'button';
            btnValidar.className = 'btn btn-primary me-2';
            btnValidar.innerHTML = '<i class="bi bi-check-circle"></i> Validar y Agregar';

            const btnCancelar = document.createElement('button');
            btnCancelar.type = 'button';
            btnCancelar.className = 'btn btn-secondary';
            btnCancelar.innerHTML = '<i class="bi bi-x-circle"></i> Cancelar';

            container.appendChild(createLabel('Día'));
            container.appendChild(diaSelect);
            container.appendChild(createLabel('Hora inicio'));
            container.appendChild(horaInicio);
            container.appendChild(createLabel('Hora fin'));
            container.appendChild(horaFin);
            container.appendChild(btnValidar);
            container.appendChild(btnCancelar);

            document.getElementById('horariosContainer').prepend(container);

            btnCancelar.addEventListener('click', () => container.remove());

            btnValidar.addEventListener('click', async () => {
                const dia = diaSelect.value;
                const hInicio = horaInicio.value;
                const hFin = horaFin.value;
                const turnoId = document.getElementById('selectTurno').value;
                const profesorId = document.getElementById('selectProfesor').value;

                if (!dia || !hInicio || !hFin) {
                    mostrarMensaje('Complete día, hora inicio y hora fin', 'warning');
                    return;
                }

                if (hInicio >= hFin) {
                    mostrarMensaje('La hora de inicio debe ser anterior a la hora fin', 'warning');
                    return;
                }

                try {
                    const respTurno = await fetch(CONTEXTPATH + '/RegistroCursoServlet?accion=validarHorario'
                        + '&turnoId=' + encodeURIComponent(turnoId)
                        + '&horaInicio=' + encodeURIComponent(hInicio)
                        + '&horaFin=' + encodeURIComponent(hFin));
                    const dataTurno = await respTurno.json();
                    
                    if (!dataTurno.dentro_rango) {
                        mostrarMensaje(dataTurno.mensaje || 'Horario fuera del rango del turno', 'danger');
                        return;
                    }
                } catch (err) {
                    console.error('Error validando turno', err);
                    mostrarMensaje('Error al validar horario en el turno', 'danger');
                    return;
                }

                try {
                    const url = CONTEXTPATH + '/RegistroCursoServlet?accion=validarDisponibilidad'
                        + '&profesorId=' + encodeURIComponent(profesorId)
                        + '&turnoId=' + encodeURIComponent(turnoId)
                        + '&diaSemana=' + encodeURIComponent(dia)
                        + '&horaInicio=' + encodeURIComponent(hInicio)
                        + '&horaFin=' + encodeURIComponent(hFin);
                    const respDispon = await fetch(url);
                    const dataDisp = await respDispon.json();

                    if (!dataDisp.disponible) {
                        mostrarMensaje(dataDisp.mensaje || 'Profesor no disponible para ese horario', 'warning');
                        return;
                    }
                } catch (err) {
                    console.error('Error validando disponibilidad', err);
                    mostrarMensaje('Error al validar disponibilidad del profesor', 'danger');
                    return;
                }

                horariosAgregados.push({
                    id: ++contadorHorarios,
                    dia: dia,
                    hora_inicio: hInicio,
                    hora_fin: hFin
                });

                container.remove();
                renderHorarios();
                mostrarMensaje('Horario agregado correctamente', 'success');
                validarFormulario();
            });
        }

        function createLabel(text) {
            const lbl = document.createElement('label');
            lbl.className = 'form-label mt-2 fw-bold';
            lbl.textContent = text;
            return lbl;
        }

        // ========== RENDERIZAR HORARIOS ==========
        function renderHorarios() {
            const container = document.getElementById('horariosContainer');
            container.innerHTML = '';

            if (horariosAgregados.length === 0) {
                container.innerHTML = '<p class="text-muted"><i class="bi bi-info-circle"></i> No hay horarios agregados aún</p>';
                removeHiddenHorarioInputs();
                return;
            }

            removeHiddenHorarioInputs();
            horariosAgregados.forEach((h, idx) => {
                const item = document.createElement('div');
                item.className = 'horario-item';

                const texto = document.createElement('div');
                texto.innerHTML = '<strong>' + h.dia + '</strong> — ' + h.hora_inicio + ' a ' + h.hora_fin;

                const btnRemove = document.createElement('button');
                btnRemove.type = 'button';
                btnRemove.className = 'btn btn-sm btn-remove-horario';
                btnRemove.innerHTML = '<i class="bi bi-trash"></i> Eliminar';
                btnRemove.addEventListener('click', () => {
                    horariosAgregados.splice(idx, 1);
                    renderHorarios();
                    validarFormulario();
                });

                item.appendChild(texto);
                item.appendChild(btnRemove);
                container.appendChild(item);

                appendHiddenInput('dias[]', h.dia);
                appendHiddenInput('horasInicio[]', h.hora_inicio);
                appendHiddenInput('horasFin[]', h.hora_fin);
            });
        }

        function appendHiddenInput(name, value) {
            const input = document.createElement('input');
            input.type = 'hidden';
            input.name = name;
            input.value = value;
            input.dataset.autocreated = 'true';
            document.getElementById('formRegistroCurso').appendChild(input);
        }

        function removeHiddenHorarioInputs() {
            const form = document.getElementById('formRegistroCurso');
            Array.from(form.querySelectorAll('input[data-autocreated="true"]')).forEach(i => i.remove());
        }

        // ========== VALIDACIÓN GLOBAL ==========
        function validarFormulario() {
            const nivel = document.getElementById('inputNivel').value;
            const grado = document.getElementById('selectGrado').value;
            const turno = document.getElementById('selectTurno').value;
            const curso = document.getElementById('selectCurso').value;
            const profesor = document.getElementById('selectProfesor').value;
            const creditos = document.getElementById('inputCreditos').value;
            const btnSubmit = document.getElementById('btnSubmit');

            const valido = nivel && grado && turno && curso && profesor && creditos && horariosAgregados.length > 0;
            btnSubmit.disabled = !valido;
        }

        // ========== MENSAJES ==========
        function mostrarMensaje(texto, tipo) {
            const div = document.getElementById('validation-message');
            div.style.display = 'block';
            div.className = 'alert alert-' + tipo;
            div.innerHTML = '<i class="bi bi-' + (tipo === 'success' ? 'check-circle-fill' : tipo === 'danger' ? 'exclamation-triangle-fill' : 'info-circle-fill') + '"></i> ' + texto;

            setTimeout(() => {
                div.style.display = 'none';
            }, 6000);
        }

        // ========== RESETEAR CAMPOS ==========
        function resetearCamposSiguientes(elemento) {
            const selectGrado = document.getElementById('selectGrado');
            const selectTurno = document.getElementById('selectTurno');
            const selectArea = document.getElementById('selectArea');
            const selectCurso = document.getElementById('selectCurso');
            const selectProfesor = document.getElementById('selectProfesor');

            if (elemento === selectGrado) {
                selectTurno.disabled = true;
                selectTurno.selectedIndex = 0;
                selectArea.disabled = true;
                selectArea.innerHTML = '<option value="">Seleccione primero un turno</option>';
                selectCurso.disabled = true;
                selectCurso.innerHTML = '<option value="">Seleccione primero un área</option>';
                selectProfesor.disabled = true;
                selectProfesor.innerHTML = '<option value="">Seleccione primero un curso</option>';
            }

            if (elemento === selectTurno) {
                selectArea.disabled = true;
                selectArea.innerHTML = '<option value="">Seleccione primero un turno</option>';
                selectCurso.disabled = true;
                selectCurso.innerHTML = '<option value="">Seleccione primero un área</option>';
                selectProfesor.disabled = true;
                selectProfesor.innerHTML = '<option value="">Seleccione primero un curso</option>';
            }

            if (elemento === selectArea) {
                selectCurso.disabled = true;
                selectCurso.innerHTML = '<option value="">Seleccione primero un área</option>';
                selectProfesor.disabled = true;
                selectProfesor.innerHTML = '<option value="">Seleccione primero un curso</option>';
            }

            if (elemento === selectCurso) {
                selectProfesor.disabled = true;
                selectProfesor.innerHTML = '<option value="">Seleccione primero un curso</option>';
            }

            document.querySelectorAll('#diasSemana input[type="checkbox"]').forEach(cb => cb.checked = false);
            horariosAgregados = [];
            contadorHorarios = 0;
            renderHorarios();
            document.getElementById('btnAgregarHorario').disabled = true;
            validarFormulario();
        }

        // ========== EVENTO SUBMIT ==========
        document.getElementById('formRegistroCurso').addEventListener('submit', function(e) {
            if (horariosAgregados.length === 0) {
                e.preventDefault();
                mostrarMensaje('Debe agregar al menos un horario antes de registrar el curso', 'warning');
                return false;
            }
            return true;
        });
        
        // Función para inicializar el formulario en modo edición
        function inicializarFormularioEdicion() {
            // Detectar si estamos en modo edición
            const selectCurso = document.getElementById('selectCurso');
            const selectProfesor = document.getElementById('selectProfesor');
            const selectTurno = document.getElementById('selectTurno');

            // Si hay un curso ya seleccionado (modo edición)
            if (selectCurso && selectCurso.value) {
                console.log('🔧 Detectado modo EDICIÓN - Cargando profesores filtrados');

                // Guardar el profesor que estaba seleccionado
                const profesorSeleccionado = selectProfesor ? selectProfesor.value : null;

                // Esperar un momento para que las variables globales se inicialicen
                setTimeout(() => {
                    // Simular el cambio de curso para cargar profesores filtrados
                    cambioCurso();

                    // Después de cargar los profesores, reseleccionar el profesor original
                    if (profesorSeleccionado) {
                        setTimeout(() => {
                            if (selectProfesor) {
                                selectProfesor.value = profesorSeleccionado;
                                console.log('✅ Profesor reseleccionado:', profesorSeleccionado);
                            }
                        }, 500);
                    }
                }, 300);
            }
        }

        // Ejecutar cuando el DOM esté completamente cargado
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', inicializarFormularioEdicion);
        } else {
            // DOM ya está listo
            inicializarFormularioEdicion();
        }
    </script>
</body>
</html>
