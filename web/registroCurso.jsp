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
    
    // Declarar variables para JavaScript (FUERA del if)
    String nivelCurso = "";
    Integer gradoIdCurso = null;
    Integer profesorIdCurso = null;
    String nombreCurso = "";
    String areaCurso = "";
    Integer creditosCurso = 1;
    Integer turnoId = null;
    
    // Obtener valores solo si está en modo edición
    if (modoEdicion && cursoEditar != null) {
        System.out.println("   JSP - Modo edición activado");
        System.out.println("   Curso: " + cursoEditar.getNombre());
        System.out.println("   ID: " + cursoEditar.getId());
        
        nivelCurso = cursoEditar.getNivel();
        gradoIdCurso = cursoEditar.getGradoId();
        profesorIdCurso = cursoEditar.getProfesorId();
        nombreCurso = cursoEditar.getNombre();
        areaCurso = cursoEditar.getArea();
        creditosCurso = cursoEditar.getCreditos();
        
        // Obtener el turno del primer horario
        if (horariosEditar != null && !horariosEditar.isEmpty()) {
            turnoId = (Integer) horariosEditar.get(0).get("turno_id");
        }
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registro de Curso - Sistema Escolar</title>
    
    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- CSS Personalizado -->
    <link rel="stylesheet" href="assets/css/estilos.css">
    
    <style>
        :root {
            /* 🎨 NUEVA PALETA DE COLORES */
            --color-fondo-principal: #E8E9EB;        /* Plomo muy claro */
            --color-fondo-secundario: #F5F5F6;       /* Plomo casi blanco */
            --color-celeste-bebe: #D4E9F7;           /* Celeste bebé */
            --color-celeste-claro: #B8DAF0;          /* Celeste claro */
            --color-celeste-medio: #A0CEE8;          /* Celeste medio */
            --color-celeste-acento: #7FC3E3;         /* Celeste acento suave */
            --color-texto-principal: #2B2D30;        /* Negro suave */
            --color-texto-secundario: #5A5C5F;       /* Gris oscuro */
            --color-borde: #D1D3D5;                  /* Borde gris claro */
            --color-sombra: rgba(0, 0, 0, 0.06);     /* Sombra muy suave */
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, var(--color-fondo-principal) 0%, #E0E2E4 100%);
            color: var(--color-texto-principal);
            min-height: 100vh;
            padding-bottom: 60px;
        }

        /* ========== CONTENEDOR PRINCIPAL ========== */
        .container {
            max-width: 1400px;
        }

        /* ========== ENCABEZADO DE PÁGINA ========== */
        .page-header {
            background: var(--color-fondo-secundario);
            border-radius: 20px;
            padding: 30px 40px;
            margin-bottom: 30px;
            box-shadow: 0 4px 20px var(--color-sombra);
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-left: 5px solid var(--color-celeste-acento);
        }

        .page-header h2 {
            font-size: 2rem;
            font-weight: 700;
            color: var(--color-texto-principal);
            display: flex;
            align-items: center;
            gap: 15px;
            margin: 0;
        }

        .page-header h2 i {
            color: var(--color-celeste-acento);
            font-size: 2.2rem;
        }

        /* ========== SECCIONES DEL FORMULARIO ========== */
        .form-section {
            background: var(--color-fondo-secundario);
            border-radius: 20px;
            padding: 35px;
            margin-bottom: 25px;
            box-shadow: 0 2px 15px var(--color-sombra);
            border: 1px solid var(--color-borde);
            transition: all 0.3s ease;
            animation: fadeIn 0.5s ease;
        }

        .form-section:hover {
            box-shadow: 0 5px 25px rgba(0, 0, 0, 0.1);
            transform: translateY(-2px);
        }

        .section-title {
            font-size: 1.4rem;
            font-weight: 700;
            color: var(--color-texto-principal);
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 3px solid var(--color-celeste-bebe);
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .section-title i {
            color: var(--color-celeste-acento);
            font-size: 1.5rem;
        }

        /* ========== FORMULARIOS ========== */
        .form-label {
            font-weight: 600;
            color: var(--color-texto-principal);
            margin-bottom: 10px;
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 0.95rem;
        }

        .form-label i {
            color: var(--color-celeste-acento);
        }

        .form-select,
        .form-control {
            border: 2px solid var(--color-borde);
            border-radius: 12px;
            padding: 12px 16px;
            font-size: 0.95rem;
            transition: all 0.3s ease;
            background: white;
            color: var(--color-texto-principal);
        }

        .form-select:focus,
        .form-control:focus {
            border-color: var(--color-celeste-medio);
            box-shadow: 0 0 0 0.2rem rgba(160, 206, 232, 0.25);
            background: white;
            outline: none;
        }

        .form-select:disabled,
        .form-control:disabled {
            background: #E9ECEF;
            cursor: not-allowed;
            opacity: 0.7;
        }

        /* ========== TEXTO DE AYUDA ========== */
        .text-muted {
            font-size: 0.85rem;
            color: var(--color-texto-secundario);
            display: flex;
            align-items: center;
            gap: 5px;
            margin-top: 5px;
        }

        /* ========== DÍAS DE LA SEMANA ========== */
        .dias-semana {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
            gap: 15px;
            margin-top: 15px;
        }

        .dia-checkbox {
            position: relative;
        }

        .dia-checkbox input[type="checkbox"] {
            display: none;
        }

        .dia-checkbox label {
            display: block;
            padding: 18px 15px;
            background: var(--color-celeste-bebe);
            border: 3px solid var(--color-celeste-claro);
            border-radius: 15px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s ease;
            font-weight: 600;
            color: var(--color-texto-principal);
        }

        .dia-checkbox label:hover {
            background: var(--color-celeste-claro);
            transform: translateY(-3px);
            box-shadow: 0 6px 15px rgba(127, 195, 227, 0.3);
        }

        .dia-checkbox input[type="checkbox"]:checked + label {
            background: linear-gradient(135deg, var(--color-celeste-medio), var(--color-celeste-acento));
            color: var(--color-texto-principal);
            border-color: var(--color-celeste-acento);
            transform: scale(1.05);
            box-shadow: 0 8px 20px rgba(127, 195, 227, 0.4);
        }

        .dia-checkbox label i {
            font-size: 1.5rem;
            display: block;
            margin-bottom: 8px;
        }

        /* ========== HORARIOS AGREGADOS ========== */
        .horario-item {
            background: linear-gradient(135deg, var(--color-celeste-bebe), #E8F4FA);
            border: 2px solid var(--color-celeste-claro);
            border-radius: 15px;
            padding: 20px 25px;
            margin-bottom: 15px;
            position: relative;
            display: flex;
            align-items: center;
            gap: 20px;
            transition: all 0.3s ease;
            color: var(--color-texto-principal);
        }

        .horario-item:hover {
            box-shadow: 0 5px 20px rgba(127, 195, 227, 0.2);
            transform: translateX(5px);
        }

        .btn-remove-horario {
            background: #FFE5E5;
            color: #D32F2F;
            border: 2px solid #FFCDD2;
            padding: 10px 16px;
            border-radius: 10px;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .btn-remove-horario:hover {
            background: #FFCDD2;
            transform: scale(1.1);
        }

        /* ========== BOTONES ========== */
        .btn {
            border-radius: 12px;
            padding: 12px 25px;
            font-weight: 600;
            transition: all 0.3s ease;
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--color-celeste-medio), var(--color-celeste-acento));
            border: none;
            color: var(--color-texto-principal);
            box-shadow: 0 4px 15px rgba(127, 195, 227, 0.3);
        }

        .btn-primary:hover:not(:disabled) {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(127, 195, 227, 0.4);
            background: linear-gradient(135deg, var(--color-celeste-acento), #6BB8D9);
        }

        .btn-secondary {
            background: var(--color-fondo-principal);
            border: 2px solid var(--color-borde);
            color: var(--color-texto-secundario);
        }

        .btn-secondary:hover {
            background: var(--color-celeste-bebe);
            border-color: var(--color-celeste-claro);
            color: var(--color-texto-principal);
        }

        .btn-success {
            background: linear-gradient(135deg, #A8D5BA, #88C9A1);
            border: none;
            color: var(--color-texto-principal);
        }

        .btn-success:hover:not(:disabled) {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(136, 201, 161, 0.4);
        }

        .btn:disabled {
            opacity: 0.5;
            cursor: not-allowed;
            transform: none !important;
        }

        .btn-outline-primary {
            background: transparent;
            border: 2px solid var(--color-celeste-acento);
            color: var(--color-celeste-acento);
        }

        .btn-outline-primary:hover:not(:disabled) {
            background: var(--color-celeste-bebe);
            border-color: var(--color-celeste-medio);
            color: var(--color-texto-principal);
        }

        /* ========== BOTÓN VOLVER ========== */
        .btn-volver {
            background: var(--color-fondo-principal);
            border: 2px solid var(--color-celeste-claro);
            color: var(--color-texto-principal);
            padding: 10px 20px;
            border-radius: 12px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .btn-volver:hover {
            background: var(--color-celeste-bebe);
            border-color: var(--color-celeste-medio);
            color: var(--color-texto-principal);
            transform: translateX(-3px);
        }

        /* ========== ALERTAS ========== */
        .alert {
            border-radius: 15px;
            padding: 18px 25px;
            border: none;
            box-shadow: 0 2px 10px var(--color-sombra);
            font-weight: 500;
        }

        .alert-success {
            background: linear-gradient(135deg, #E8F5E9, #C8E6C9);
            color: #2E7D32;
        }

        .alert-danger {
            background: linear-gradient(135deg, #FFEBEE, #FFCDD2);
            color: #C62828;
        }

        .alert-warning {
            background: linear-gradient(135deg, #FFF3E0, #FFE0B2);
            color: #E65100;
        }

        /* ========== ENTRADA DE HORARIO ========== */
        #horarioEntry {
            background: var(--color-fondo-secundario);
            border: 2px solid var(--color-celeste-claro);
        }

        /* ========== ANIMACIONES ========== */
        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(-20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* ========== RESPONSIVE ========== */
        @media (max-width: 768px) {
            .page-header {
                flex-direction: column;
                gap: 20px;
                text-align: center;
                padding: 25px 20px;
            }

            .page-header h2 {
                font-size: 1.5rem;
            }

            .form-section {
                padding: 25px 20px;
            }

            .dias-semana {
                grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
            }
        }
        
    </style>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">

<!-- SweetAlert2 (para alertas bonitas) -->
<link href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>
<body class="dashboard-page">

    <!-- Header -->
    <jsp:include page="header.jsp" />

    <div class="container mt-4 mb-5">
        
        <!-- ========== TÍTULO ========== -->
        <div class="page-header">
            <h2>
                <i class="fas fa-<%= modoEdicion ? "edit" : "book-open" %>"></i>
                <%= modoEdicion ? "Editar Curso" : "Registro de Curso" %>
            </h2>
            <a href="CursoServlet" class="btn-volver">
                <i class="fas fa-arrow-left"></i>
                Volver a Cursos
            </a>
        </div>

        <!-- ========== MENSAJES ========== -->
        <% if (mensaje != null) { %>
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="fas fa-check-circle"></i> <%= mensaje %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>
        
        <% if (error != null) { %>
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="fas fa-exclamation-circle"></i> <%= error %>
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
                <i class="fas fa-layer-group"></i>
                <span>Paso 1: Seleccionar Nivel y Grado</span>
            </div>

                <div class="row">
                    <!-- Nivel Educativo -->
                    <div class="col-md-6 mb-3">
                        <label class="form-label">
                            <i class="fas fa-school"></i> Nivel Educativo <span class="text-danger">*</span>
                        </label>
                        <select name="nivel_select" id="selectNivel" class="form-select" required>
                            <option value="">-- Seleccione un nivel --</option>
                            <option value="INICIAL">INICIAL (3-5 años)</option>
                            <option value="PRIMARIA">PRIMARIA (1° - 6°)</option>
                            <option value="SECUNDARIA">SECUNDARIA (1° - 5°)</option>
                        </select>
                        <small class="text-muted">
                            <i class="fas fa-info-circle"></i> Primero seleccione el nivel educativo
                        </small>
                    </div>

                    <!-- Grado -->
                    <div class="col-md-6 mb-3">
                        <label class="form-label">
                            <i class="fas fa-graduation-cap"></i> Grado <span class="text-danger">*</span>
                        </label>
                        <select name="grado" id="selectGrado" class="form-select" required disabled>
                            <option value="">Seleccione primero un nivel</option>
                        </select>
                        <small class="text-muted" id="infoGrado">
                            <i class="fas fa-lock"></i> Se habilitará al seleccionar nivel
                        </small>
                    </div>
                </div>
            </div>

            <!-- ========== SECCIÓN 2: TURNO ========== -->
            <div class="form-section">
                <div class="section-title">
                    <i class="fas fa-clock"></i> Paso 2: Seleccionar Turno
                </div>

                <div class="row">
                    <div class="col-md-12 mb-3">
                        <label class="form-label">
                            <i class="fas fa-clock"></i> Turno <span class="text-danger">*</span>
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
                            <i class="fas fa-info-circle"></i> El turno determina el horario disponible
                        </small>
                    </div>
                </div>
            </div>

            <!-- ========== SECCIÓN 3: ÁREA Y CURSO ========== -->
            <div class="form-section">
                <div class="section-title">
                    <i class="fas fa-book"></i> Paso 3: Seleccionar Área y Curso
                </div>

                <div class="row">
                    <!-- Área -->
                    <div class="col-md-6 mb-3">
                        <label class="form-label">
                            <i class="fas fa-layer-group"></i> Área Académica <span class="text-danger">*</span>
                        </label>
                        <select id="selectArea" class="form-select" required disabled>
                            <option value="">Seleccione primero un turno</option>
                        </select>
                        <small class="text-muted">
                            <i class="fas fa-lock"></i> Se habilitará al seleccionar turno
                        </small>
                    </div>

                    <!-- Curso -->
                    <div class="col-md-6 mb-3">
                        <label class="form-label">
                            <i class="fas fa-book-open"></i> Nombre del Curso <span class="text-danger">*</span>
                        </label>
                        <select name="curso" id="selectCurso" class="form-select" required disabled>
                            <option value="">Seleccione primero un área</option>
                        </select>
                        <small class="text-muted">
                            <i class="fas fa-lock"></i> Se habilitará al seleccionar área
                        </small>
                    </div>
                </div>
            </div>

            <!-- ========== SECCIÓN 4: PROFESOR Y DETALLES ========== -->
            <div class="form-section">
                <div class="section-title">
                    <i class="fas fa-chalkboard-teacher"></i> Paso 4: Profesor y Detalles del Curso
                </div>

                <div class="row">
                    <!-- Profesor -->
                    <div class="col-md-6 mb-3">
                        <label class="form-label">
                            <i class="fas fa-user-tie"></i> Profesor <span class="text-danger">*</span>
                        </label>
                        <select name="profesor" id="selectProfesor" class="form-select" required disabled>
                            <option value="">Seleccione primero un curso</option>
                        </select>
                        <small class="text-muted">
                            <i class="fas fa-filter"></i> Filtrado por área, turno y nivel
                        </small>
                    </div>

                    <!-- Créditos -->
                    <div class="col-md-6 mb-3">
                        <label class="form-label">
                            <i class="fas fa-star"></i> Créditos <span class="text-danger">*</span>
                        </label>
                        <input type="number" name="creditos" id="inputCreditos" 
                               class="form-control" min="1" max="10" value="1" required>
                        <small class="text-muted">
                            <i class="fas fa-info-circle"></i> Valor entre 1 y 10
                        </small>
                    </div>

                    <!-- Descripción -->
                    <div class="col-md-12 mb-3">
                        <label class="form-label">
                            <i class="fas fa-align-left"></i> Descripción del Curso
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
                    <i class="fas fa-calendar-alt"></i> Paso 5: Configurar Horarios de Clase
                </div>

                <!-- Días de la semana -->
                <div class="mb-4">
                    <label class="form-label mb-3">
                        <i class="fas fa-calendar-week"></i> Días de clase <span class="text-danger">*</span>
                    </label>
                    <div class="dias-semana" id="diasSemana">
                        <div class="dia-checkbox">
                            <input type="checkbox" id="diaLunes" value="LUNES">
                            <label for="diaLunes">
                                <i class="fas fa-calendar-day"></i><br>
                                <strong>Lunes</strong>
                            </label>
                        </div>
                        <div class="dia-checkbox">
                            <input type="checkbox" id="diaMartes" value="MARTES">
                            <label for="diaMartes">
                                <i class="fas fa-calendar-day"></i><br>
                                <strong>Martes</strong>
                            </label>
                        </div>
                        <div class="dia-checkbox">
                            <input type="checkbox" id="diaMiercoles" value="MIERCOLES">
                            <label for="diaMiercoles">
                                <i class="fas fa-calendar-day"></i><br>
                                <strong>Miércoles</strong>
                            </label>
                        </div>
                        <div class="dia-checkbox">
                            <input type="checkbox" id="diaJueves" value="JUEVES">
                            <label for="diaJueves">
                                <i class="fas fa-calendar-day"></i><br>
                                <strong>Jueves</strong>
                            </label>
                        </div>
                        <div class="dia-checkbox">
                            <input type="checkbox" id="diaViernes" value="VIERNES">
                            <label for="diaViernes">
                                <i class="fas fa-calendar-day"></i><br>
                                <strong>Viernes</strong>
                            </label>
                        </div>
                    </div>
                    <small class="text-muted d-block mt-2">
                        <i class="fas fa-info-circle"></i> Seleccione los días en los que se dictará el curso
                    </small>
                </div>

                <!-- Contenedor de horarios agregados -->
                <div id="horariosContainer" class="mb-3">
                    <p class="text-muted">
                        <i class="fas fa-info-circle"></i> No hay horarios agregados aún
                    </p>
                </div>

                <!-- Mensaje de validación -->
                <div id="validation-message"></div>

                <!-- Botón agregar horario -->
                <button type="button" id="btnAgregarHorario" class="btn btn-outline-primary" disabled>
                    <i class="fas fa-plus"></i> Agregar Horario
                </button>
                <small class="text-muted d-block mt-2">
                    <i class="fas fa-lock"></i> Seleccione días, turno y profesor para habilitar
                </small>
            </div>

            <!-- ========== BOTONES DE ACCIÓN ========== -->
            <div class="text-end">
                <a href="CursoServlet" class="btn btn-secondary btn-lg">
                    <i class="fas fa-times"></i> Cancelar
                </a>
                <button type="submit" id="btnSubmit" class="btn btn-primary btn-lg" disabled>
                    <i class="fas fa-save"></i> 
                    <%= modoEdicion ? "Guardar Cambios" : "Registrar Curso" %>
                </button>
            </div>
        </form>

    </div>

    <!-- Footer -->
    <footer class="bg-dark text-white py-3 mt-5">
        <div class="container text-center">
            <p class="mb-0">&copy; 2026 Sistema Escolar - Todos los derechos reservados</p>
        </div>
    </footer>
    
    <script>
        const CONTEXTPATH = '<%= request.getContextPath() %>';
    </script>

 <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- ========== JAVASCRIPT COMPLETO (SIN CAMBIOS EN LA LÓGICA) ========== -->
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
                                '<i class="fas fa-check-circle text-success"></i> Grados cargados correctamente';
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
                    infoGrado.innerHTML = '<i class="fas fa-check-circle text-success"></i> Grado seleccionado. Ahora seleccione un turno';
                }
                
                resetearCamposSiguientes(selectTurno);
            } else {
                selectTurno.disabled = true;
                selectTurno.selectedIndex = 0;
                resetearCamposSiguientes(selectTurno);
                
                const infoGrado = document.getElementById('infoGrado');
                if (infoGrado) {
                    infoGrado.innerHTML = '<i class="fas fa-lock"></i> Se habilitará al seleccionar nivel';
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
                         console.log('Áreas recibidas del servidor:', data);

                         selectArea.innerHTML = '<option value="">-- Seleccione un área --</option>';

                         if (data && data.length > 0) {
                             data.forEach(area => {
                                 console.log('  Procesando área:', area);
                                 const option = document.createElement('option');

                                 option.value = area.nombre;
                                 option.textContent = area.nombre;

                                 if (area.descripcion) option.title = area.descripcion;
                                 selectArea.appendChild(option);
                             });
                             console.log('✅ ' + data.length + ' áreas cargadas correctamente');
                         } else {
                             selectArea.innerHTML = '<option value="">No hay áreas disponibles</option>';
                             console.warn('⚠️ No se recibieron áreas del servidor');
                         }
                     })
                     .catch(error => {
                         console.error('❌ Error al cargar áreas:', error);
                         selectArea.innerHTML = '<option value="">Error al cargar áreas</option>';
                         mostrarMensaje('Error al cargar áreas: ' + error.message, 'danger');
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
            const selectGrado = document.getElementById('selectGrado');

            const areaValue = selectArea.value;
            const areaText = selectArea.options[selectArea.selectedIndex].text;
            const gradoId = selectGrado.value;

            console.log('📚 CAMBIO DE ÁREA DETECTADO:');
            console.log('  Valor (value):', areaValue);
            console.log('  Texto (nombre):', areaText);
            console.log('  Grado ID:', gradoId);
            console.log('  ¿Es undefined?:', areaValue === 'undefined');
            console.log('  ¿Está vacío?:', areaValue === '');

            const areaNombre = areaText.trim();
            inputArea.value = areaNombre;

            console.log('✅ Área seleccionada:', areaNombre);
            console.log('✅ Grado ID:', gradoId);

            if (!gradoId || gradoId === '' || gradoId === 'undefined' || gradoId === '0') {
                console.warn('⚠️ Grado no seleccionado');
                selectCurso.disabled = true;
                selectCurso.innerHTML = '<option value="">Seleccione un grado primero</option>';

                if (typeof Swal !== 'undefined') {
                    Swal.fire({
                        icon: 'warning',
                        title: 'Grado no seleccionado',
                        text: 'Por favor, seleccione un grado antes de elegir un área',
                        confirmButtonColor: '#64B5F6'
                    });
                }
                return;
            }

            if (areaValue && areaValue !== '' && areaValue !== 'undefined' && areaNombre !== '-- Seleccione un área --') {
                selectCurso.disabled = false;
                selectCurso.innerHTML = '<option value="">Cargando cursos...</option>';

                console.log('🔄 Enviando petición para obtener cursos');
                console.log('   Área:', areaNombre);
                console.log('   Grado:', gradoId);

                const url = CONTEXTPATH + '/RegistroCursoServlet?accion=obtenerCursos' +
                            '&area=' + encodeURIComponent(areaNombre) +
                            '&grado=' + encodeURIComponent(gradoId) +
                            '&nivel=' + encodeURIComponent(nivelSeleccionado);

                console.log('🌐 URL:', url);

                fetch(url)
                    .then(response => {
                        console.log('📡 Respuesta recibida, status:', response.status);
                        if (!response.ok) {
                            throw new Error('Error en la respuesta del servidor: ' + response.status);
                        }
                        return response.json();
                    })
                    .then(data => {
                        console.log('📦 Datos recibidos:', data);
                        console.log('📊 Total de cursos:', data.length);

                        selectCurso.innerHTML = '<option value="">-- Seleccione un curso --</option>';

                        if (data && data.length > 0) {
                            data.forEach(curso => {
                                const option = document.createElement('option');
                                option.value = curso.nombre;
                                option.textContent = curso.nombre;
                                if (curso.descripcion) option.title = curso.descripcion;
                                if (curso.creditos) option.textContent += ` (${curso.creditos} créditos)`;
                                selectCurso.appendChild(option);
                            });
                            console.log('✅ ' + data.length + ' cursos cargados correctamente');
                        } else {
                            selectCurso.innerHTML = '<option value="">No hay cursos disponibles para esta área y grado</option>';
                            console.warn('⚠️ No se encontraron cursos para el área:', areaNombre, 'y grado:', gradoId);

                            if (typeof mostrarMensaje === 'function') {
                                mostrarMensaje('No se encontraron cursos para el área ' + areaNombre + ' en este grado', 'warning');
                            }
                        }

                        resetearCamposSiguientes(selectCurso);
                    })
                    .catch(error => {
                        console.error('❌ Error al cargar cursos:', error);
                        selectCurso.innerHTML = '<option value="">Error al cargar cursos</option>';

                        if (typeof mostrarMensaje === 'function') {
                            mostrarMensaje('Error al cargar cursos: ' + error.message, 'danger');
                        }
                    });
            } else {
                selectCurso.disabled = true;
                selectCurso.innerHTML = '<option value="">Seleccione primero un área válida</option>';
                resetearCamposSiguientes(selectCurso);
                console.warn('⚠️ Área no seleccionada o inválida');
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
            container.className = 'mt-3 p-3 border rounded bg-light';

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
            btnValidar.className = 'btn btn-success me-2';
            btnValidar.innerHTML = '<i class="fas fa-check"></i> Validar y Agregar';

            const btnCancelar = document.createElement('button');
            btnCancelar.type = 'button';
            btnCancelar.className = 'btn btn-secondary';
            btnCancelar.innerHTML = '<i class="fas fa-times"></i> Cancelar';

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
                container.innerHTML = '<p class="text-muted"><i class="fas fa-info-circle"></i> No hay horarios agregados aún</p>';
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
                btnRemove.className = 'btn btn-sm btn-danger btn-remove-horario';
                btnRemove.innerHTML = '<i class="fas fa-trash"></i>';
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
            div.innerHTML = '<i class="fas fa-' + (tipo === 'success' ? 'check' : tipo === 'danger' ? 'exclamation' : 'info') + '-circle"></i> ' + texto;

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
        
        const datosEdicion = {
            nivel: "<%= nivelCurso != null ? nivelCurso : "" %>",
            gradoId: <%= gradoIdCurso != null ? gradoIdCurso : "null" %>,
            turnoId: <%= turnoId != null ? turnoId : "null" %>,
            area: "<%= areaCurso != null ? areaCurso : "" %>",
            nombreCurso: "<%= nombreCurso != null ? nombreCurso.replace("\"", "\\\"") : "" %>",
            profesorId: <%= profesorIdCurso != null ? profesorIdCurso : "null" %>,
            creditos: <%= creditosCurso != null ? creditosCurso : 1 %>,
            horarios: [
                <% if (horariosEditar != null && !horariosEditar.isEmpty()) {
                    for (int i = 0; i < horariosEditar.size(); i++) {
                        Map<String, Object> h = horariosEditar.get(i);
                %>
                {
                    dia: "<%= h.get("dia_semana") %>",
                    hora_inicio: "<%= h.get("hora_inicio") %>",
                    hora_fin: "<%= h.get("hora_fin") %>"
                }<%= i < horariosEditar.size() - 1 ? "," : "" %>
                <% }} %>
            ]
        };

        console.log(" MODO EDICIÓN - Datos a cargar:", datosEdicion);

        // FUNCIÓN DE INICIALIZACIÓN
        function inicializarModoEdicion() {
            console.log(" Iniciando carga de datos...");

            // 1. NIVEL
            const selectNivel = document.getElementById('selectNivel');
            if (datosEdicion.nivel) {
                selectNivel.value = datosEdicion.nivel;
                nivelSeleccionado = datosEdicion.nivel;
                document.getElementById('inputNivel').value = datosEdicion.nivel;

                // 2. GRADOS
                const selectGrado = document.getElementById('selectGrado');
                selectGrado.disabled = false;

                fetch(CONTEXTPATH + '/RegistroCursoServlet?accion=obtenerGrados&nivel=' + datosEdicion.nivel)
                    .then(r => r.json())
                    .then(grados => {
                        selectGrado.innerHTML = '<option value="">-- Seleccione un grado --</option>';
                        grados.forEach(g => {
                            const opt = document.createElement('option');
                            opt.value = g.id;
                            opt.textContent = g.nombre + ' - ' + g.nivel;
                            selectGrado.appendChild(opt);
                        });

                        selectGrado.value = datosEdicion.gradoId;

                        // 3. TURNO
                        const selectTurno = document.getElementById('selectTurno');
                        selectTurno.disabled = false;
                        if (datosEdicion.turnoId) {
                            selectTurno.value = datosEdicion.turnoId;
                            turnoSeleccionado = datosEdicion.turnoId;
                        }

                        // 4. ÁREAS
                        return fetch(CONTEXTPATH + '/RegistroCursoServlet?accion=obtenerAreas&nivel=' + datosEdicion.nivel);
                    })
                    .then(r => r.json())
                    .then(areas => {
                        const selectArea = document.getElementById('selectArea');
                        selectArea.disabled = false;
                        selectArea.innerHTML = '<option value="">-- Seleccione un área --</option>';
                        areas.forEach(a => {
                            const opt = document.createElement('option');
                            opt.value = a.nombre;
                            opt.textContent = a.nombre;
                            selectArea.appendChild(opt);
                        });

                        selectArea.value = datosEdicion.area;
                        document.getElementById('inputArea').value = datosEdicion.area;

                        // 5. CURSOS
                        const params = new URLSearchParams({
                            accion: 'obtenerCursos',
                            area: datosEdicion.area,
                            grado_id: datosEdicion.gradoId
                        });
                        return fetch(CONTEXTPATH + '/RegistroCursoServlet?' + params);
                    })
                    .then(r => r.json())
                    .then(cursos => {
                        const selectCurso = document.getElementById('selectCurso');
                        selectCurso.disabled = false;
                        selectCurso.innerHTML = '<option value="">-- Seleccione un curso --</option>';
                        cursos.forEach(c => {
                            const opt = document.createElement('option');
                            opt.value = c.nombre;
                            opt.textContent = c.nombre;
                            selectCurso.appendChild(opt);
                        });

                        selectCurso.value = datosEdicion.nombreCurso;

                        // 6. PROFESORES
                        const paramsPro = new URLSearchParams({
                            accion: 'obtenerProfesores',
                            area: datosEdicion.area,
                            nivel: datosEdicion.nivel,
                            turno_id: datosEdicion.turnoId
                        });
                        return fetch(CONTEXTPATH + '/RegistroCursoServlet?' + paramsPro);
                    })
                    .then(r => r.json())
                    .then(profesores => {
                        const selectProfesor = document.getElementById('selectProfesor');
                        selectProfesor.disabled = false;
                        selectProfesor.innerHTML = '<option value="">-- Seleccione un profesor --</option>';
                        profesores.forEach(p => {
                            const opt = document.createElement('option');
                            opt.value = p.id;
                            opt.textContent = p.nombres + ' ' + p.apellidos;
                            selectProfesor.appendChild(opt);
                        });

                        selectProfesor.value = datosEdicion.profesorId;

                        // 7. CRÉDITOS
                        document.getElementById('inputCreditos').value = datosEdicion.creditos;

                        // 8. HORARIOS
                        if (datosEdicion.horarios.length > 0) {
                            horariosAgregados = [];
                            datosEdicion.horarios.forEach(h => {
                                horariosAgregados.push({
                                    dia: h.dia,
                                    hora_inicio: h.hora_inicio,
                                    hora_fin: h.hora_fin
                                });
                            });
                            renderHorarios();
                        }

                        validarFormulario();
                        mostrarMensaje(' Datos cargados correctamente', 'success');
                        console.log(" Inicialización completada");
                    })
                    .catch(error => {
                        console.error(" Error:", error);
                        mostrarMensaje('Error al cargar datos: ' + error.message, 'danger');
                    });
            }
        }
        <% if (modoEdicion && cursoEditar != null) { %>
            setTimeout(inicializarModoEdicion, 600);
        <% } %>
     </script>
</body>
</html>
