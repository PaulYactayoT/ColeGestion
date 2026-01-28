<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Padre" %>
<%@ page import="modelo.ImageDAO, modelo.Imagen" %>
<%@ page import="modelo.AsistenciaDAO, java.util.Map" %>
<%@ page import="java.util.List" %>
<%@ page import="modelo.PadreDAO" %>

<%
    Padre padre = (Padre) session.getAttribute("padre");
    if (padre == null) {
        // Intentar obtener el padre desde la sesión de usuario
        String username = (String) session.getAttribute("usuario");
        if (username != null) {
            PadreDAO padreDAO = new PadreDAO();
            padre = padreDAO.obtenerPorUsername(username);
            if (padre != null) {
                session.setAttribute("padre", padre);
            }
        }
        
        if (padre == null) {
            response.sendRedirect("index.jsp?error=padre_no_encontrado");
            return;
        }
    }
    
    // Verificar si tiene alumno asociado
    boolean tieneAlumno = padre.getAlumnoId() > 0;
    int alumnoId = padre.getAlumnoId();
    
    // Obtener resumen de asistencias solo si tiene alumno
    Map<String, Object> resumenAsistencia = null;
    double porcentajeAsistencia = 0.0;
    String badgeClass = "bg-secondary";
    
    if (tieneAlumno) {
        AsistenciaDAO asistenciaDAO = new AsistenciaDAO();
        int mesActual = java.time.LocalDate.now().getMonthValue();
        int anioActual = java.time.LocalDate.now().getYear();
        
        // Obtener resumen de asistencias (usaremos turno 1 por defecto)
        resumenAsistencia = asistenciaDAO.obtenerResumenAsistenciaAlumnoTurno(alumnoId, 1, mesActual, anioActual);
        
        // Calcular porcentaje de asistencia
        if (resumenAsistencia != null && !resumenAsistencia.isEmpty()) {
            Object porcentajeObj = resumenAsistencia.get("porcentajeAsistencia");
            if (porcentajeObj != null) {
                porcentajeAsistencia = (Double) porcentajeObj;
            }
        }
        
        // Determinar color del badge según el porcentaje
        if (porcentajeAsistencia < 75) {
            badgeClass = "bg-danger";
        } else if (porcentajeAsistencia < 90) {
            badgeClass = "bg-warning";
        } else {
            badgeClass = "bg-success";
        }
    }
    
    // Cargar imágenes si tiene alumno
    List<Imagen> imgs = null;
    if (tieneAlumno) {
        imgs = new ImageDAO().listarPorAlumno(alumnoId);
    }
%>

<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <title>Panel del Padre de Familia</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
        <link rel="stylesheet" href="assets/css/estilos.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <style>
            :root {
                --primary-color: #2c5aa0;
                --primary-dark: #1e3d72;
                --primary-light: #4a7bc8;
                --accent-color: #28a745;
                --warning-color: #ffc107;
                --danger-color: #dc3545;
                --success-color: #20c997;
                --dark-color: #2d3748;
                --light-color: #f8f9fa;
                --gray-color: #6c757d;
                --material-color: #6f42c1;
                --material-dark: #563d7c;
            }
            
            body {
                background-image: url('assets/img/fondo_dashboard_padre.jpg');
                background-size: cover;
                background-position: center;
                background-attachment: fixed;
                min-height: 100vh;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            }
            
            .header-bar {
                background-color: rgba(17, 17, 17, 0.95);
                color: white;
                padding: 15px 30px;
                display: flex;
                justify-content: space-between;
                align-items: center;
                backdrop-filter: blur(10px);
                box-shadow: 0 2px 15px rgba(0,0,0,0.1);
            }
            
            .card-box {
                background-color: rgba(255, 255, 255, 0.95);
                border-radius: 15px;
                padding: 25px;
                text-align: center;
                box-shadow: 0 8px 25px rgba(0,0,0,0.1);
                transition: all 0.3s ease;
                height: 100%;
                border-left: 4px solid var(--primary-color);
            }
            
            .card-box:hover {
                transform: translateY(-8px);
                box-shadow: 0 15px 35px rgba(0,0,0,0.15);
            }
            
            .card-box h5 {
                color: var(--dark-color);
                font-weight: 700;
                margin-bottom: 15px;
            }
            
            .card-box p {
                color: var(--gray-color);
                margin-bottom: 20px;
                line-height: 1.5;
            }
            
            /* Botones armonizados */
            .btn-dashboard {
                padding: 0.6rem 1.2rem;
                border: none;
                border-radius: 10px;
                font-weight: 600;
                font-size: 0.9rem;
                transition: all 0.3s ease;
                box-shadow: 0 4px 12px rgba(0,0,0,0.1);
                display: inline-flex;
                align-items: center;
                justify-content: center;
                gap: 8px;
                min-width: 140px;
            }
            
            .btn-dashboard:hover {
                transform: translateY(-3px);
                box-shadow: 0 8px 20px rgba(0,0,0,0.15);
            }
            
            .btn-primary-dashboard {
                background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
                color: white;
            }
            
            .btn-primary-dashboard:hover {
                background: linear-gradient(135deg, var(--primary-dark), var(--primary-color));
                color: white;
            }
            
            .btn-success-dashboard {
                background: linear-gradient(135deg, var(--success-color), #1ba87e);
                color: white;
            }
            
            .btn-success-dashboard:hover {
                background: linear-gradient(135deg, #1ba87e, var(--success-color));
                color: white;
            }
            
            .btn-warning-dashboard {
                background: linear-gradient(135deg, var(--warning-color), #e0a800);
                color: #212529;
            }
            
            .btn-warning-dashboard:hover {
                background: linear-gradient(135deg, #e0a800, var(--warning-color));
                color: #212529;
            }
            
            .btn-info-dashboard {
                background: linear-gradient(135deg, #17a2b8, #138496);
                color: white;
            }
            
            .btn-info-dashboard:hover {
                background: linear-gradient(135deg, #138496, #17a2b8);
                color: white;
            }
            
            .btn-secondary-dashboard {
                background: linear-gradient(135deg, #6c757d, #5a6268);
                color: white;
            }
            
            .btn-secondary-dashboard:hover {
                background: linear-gradient(135deg, #5a6268, #6c757d);
                color: white;
            }
            
            .btn-material-dashboard {
                background: linear-gradient(135deg, var(--material-color), var(--material-dark));
                color: white;
            }
            
            .btn-material-dashboard:hover {
                background: linear-gradient(135deg, var(--material-dark), var(--material-color));
                color: white;
            }
            
            .asistencia-card {
                background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
                color: white;
                border: none;
                border-radius: 15px;
                box-shadow: 0 8px 25px rgba(44, 90, 160, 0.3);
            }
            
            .asistencia-card .btn {
                border-radius: 10px;
                font-weight: 600;
                transition: all 0.3s ease;
                box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            }
            
            .asistencia-card .btn:hover {
                transform: translateY(-2px);
                box-shadow: 0 6px 15px rgba(0,0,0,0.2);
            }
            
            .page-title {
                color: var(--dark-color);
                font-weight: 800;
                text-align: center;
                margin-bottom: 40px;
                position: relative;
                padding-bottom: 15px;
            }
            
            .page-title::after {
                content: '';
                position: absolute;
                bottom: 0;
                left: 50%;
                transform: translateX(-50%);
                width: 100px;
                height: 4px;
                background: linear-gradient(90deg, var(--primary-color), var(--primary-dark));
                border-radius: 2px;
            }
            
            .progress {
                height: 10px;
                margin: 10px 0;
                border-radius: 5px;
            }
            
            .badge-lg {
                font-size: 0.9rem;
                padding: 0.5rem 0.8rem;
                border-radius: 10px;
            }
            
            .no-alumno-alert {
                background-color: rgba(255, 193, 7, 0.2);
                border-left: 4px solid #ffc107;
                border-radius: 8px;
                padding: 15px;
                margin-bottom: 20px;
            }
            
            /* Estilos de accesibilidad */
            .reduce-motion * {
                animation-duration: 0.01ms !important;
                animation-iteration-count: 1 !important;
                transition-duration: 0.01ms !important;
            }
            
            .high-contrast-invert {
                filter: invert(1) hue-rotate(180deg);
            }
            
            .high-contrast-yellow {
                background-color: #000000 !important;
                color: #ffff00 !important;
            }
            
            .beige-background {
                background-color: #f5f5dc !important;
            }
            
            .large-text {
                font-size: 20px !important;
            }
            
            .larger-text {
                font-size: 24px !important;
            }
            
            .largest-text {
                font-size: 28px !important;
            }
            
            .dyslexia-font {
                font-family: Arial, Helvetica, sans-serif !important;
                font-size: 1.1em !important;
                line-height: 1.6 !important;
                letter-spacing: 0.5px !important;
            }
            
            /* Estilo específico para la tarjeta de material */
            .material-card {
                border-left-color: var(--material-color) !important;
            }
            
            .material-icon {
                color: var(--material-color);
            }
            
            .disabled-card {
                opacity: 0.7;
                filter: grayscale(30%);
            }
            
            .disabled-card:hover {
                transform: none !important;
                box-shadow: 0 8px 25px rgba(0,0,0,0.1) !important;
            }
            
            .btn-disabled {
                opacity: 0.6;
                cursor: not-allowed;
            }
            
            .btn-disabled:hover {
                transform: none !important;
                box-shadow: 0 4px 12px rgba(0,0,0,0.1) !important;
            }
        </style>
    </head>
    <body>

        <div class="header-bar">
            <div>
                <img src="assets/img/logosa.png" alt="Logo" style="width: 30px; height: auto; margin-right: 10px;" />
                <strong>Colegio SA</strong>
            </div>
            <div>
                <% if (tieneAlumno) { %>
                    <span class="me-3">Padre de: <strong><%= padre.getAlumnoNombre() != null ? padre.getAlumnoNombre() : "Sin alumno asociado" %></strong> 
                    <% if (padre.getGradoNombre() != null) { %>| Grado: <strong><%= padre.getGradoNombre() %></strong><% } %></span>
                <% } else { %>
                    <span class="me-3">Bienvenido: <strong><%= padre.getNombreCompleto() %></strong></span>
                <% } %>
                <a href="LogoutServlet" class="btn btn-outline-light btn-sm">
                    <i class="bi bi-box-arrow-right me-1"></i>Cerrar sesión
                </a>
            </div>
        </div>

        <div class="container mt-5">
            <h2 class="page-title">
                <i class="bi bi-house-heart me-2"></i>Panel del Padre de Familia
            </h2>

            <% if (!tieneAlumno) { %>
            <div class="no-alumno-alert mb-5">
                <div class="d-flex align-items-center">
                    <div class="me-3">
                        <i class="bi bi-exclamation-triangle-fill text-warning fs-3"></i>
                    </div>
                    <div>
                        <h5 class="mb-2"><strong>No tiene alumno asociado</strong></h5>
                        <p class="mb-2">Actualmente no tienes ningún alumno vinculado a tu cuenta. Para acceder a las funcionalidades del sistema (asistencia, notas, observaciones, etc.), necesitas estar asociado a un alumno.</p>
                        <div class="mt-3">
                            <a href="LoginServlet?accion=debugPadre&username=<%= padre.getUsername() %>" class="btn btn-warning btn-sm me-2" target="_blank">
                                <i class="bi bi-bug me-1"></i>Verificar Datos
                            </a>
                            <a href="#" class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#solicitarAsociacionModal">
                                <i class="bi bi-headset me-1"></i>Solicitar Asociación
                            </a>
                        </div>
                    </div>
                </div>
            </div>
            <% } %>

            <!-- Tarjeta de Resumen de Asistencia -->
            <div class="card asistencia-card mb-5">
                <div class="card-body">
                    <div class="row align-items-center">
                        <div class="col-md-8">
                            <h5 class="card-title mb-3">
                                <i class="bi bi-journal-check me-2"></i>
                                <% if (tieneAlumno) { %>
                                    Asistencia de <%= padre.getAlumnoNombre() %>
                                <% } else { %>
                                    Asistencia Escolar
                                <% } %>
                            </h5>
                            
                            <% if (tieneAlumno) { %>
                                <p class="card-text mb-3">
                                    <strong>Asistencia Mensual:</strong> 
                                    <span class="badge <%= badgeClass%> badge-lg ms-2"><%= String.format("%.1f", porcentajeAsistencia)%>%</span>
                                </p>
                                <% if (resumenAsistencia != null && !resumenAsistencia.isEmpty()) { %>
                                <div class="row mt-3">
                                    <div class="col-6 col-md-3 mb-2">
                                        <small><i class="bi bi-check-circle-fill text-success me-1"></i> <strong><%= resumenAsistencia.get("presentes") != null ? resumenAsistencia.get("presentes") : "0" %></strong> Presentes</small>
                                    </div>
                                    <div class="col-6 col-md-3 mb-2">
                                        <small><i class="bi bi-clock-fill text-warning me-1"></i> <strong><%= resumenAsistencia.get("tardanzas") != null ? resumenAsistencia.get("tardanzas") : "0" %></strong> Tardanzas</small>
                                    </div>
                                    <div class="col-6 col-md-3 mb-2">
                                        <small><i class="bi bi-x-circle-fill text-danger me-1"></i> <strong><%= resumenAsistencia.get("ausentes") != null ? resumenAsistencia.get("ausentes") : "0" %></strong> Ausentes</small>
                                    </div>
                                    <div class="col-6 col-md-3 mb-2">
                                        <small><i class="bi bi-file-text-fill text-info me-1"></i> <strong><%= resumenAsistencia.get("justificados") != null ? resumenAsistencia.get("justificados") : "0" %></strong> Justificados</small>
                                    </div>
                                </div>
                                <% } else { %>
                                <p class="mb-0"><i>No hay datos de asistencia disponibles para este mes.</i></p>
                                <% } %>
                            <% } else { %>
                                <p class="card-text mb-3">
                                    <strong>Estado:</strong> 
                                    <span class="badge bg-secondary badge-lg ms-2">No disponible</span>
                                </p>
                                <p class="mb-0"><i>Para ver la asistencia escolar, necesitas tener un alumno asociado.</i></p>
                            <% } %>
                        </div>
                        <div class="col-md-4 text-center text-md-end">
                            <% if (tieneAlumno) { %>
                                <a href="AsistenciaServlet?accion=verPadre&alumno_id=<%= alumnoId%>" class="btn btn-light btn-dashboard me-2 mb-2">
                                    <i class="bi bi-graph-up me-1"></i>Ver Detalles
                                </a>
                                <a href="JustificacionServlet?accion=form" class="btn btn-warning-dashboard mb-2">
                                    <i class="bi bi-pencil-square me-1"></i>Justificar
                                </a>
                            <% } else { %>
                                <a href="#" class="btn btn-light btn-dashboard me-2 mb-2 btn-disabled" disabled>
                                    <i class="bi bi-graph-up me-1"></i>Ver Detalles
                                </a>
                                <a href="#" class="btn btn-warning-dashboard mb-2 btn-disabled" disabled>
                                    <i class="bi bi-pencil-square me-1"></i>Justificar
                                </a>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row g-4 justify-content-center">

                <!-- Notas del Alumno -->
                <div class="col-md-4">
                    <div class="card-box <%= !tieneAlumno ? "disabled-card" : "" %>">
                        <h5 class="fw-bold mb-3">
                            <i class="bi bi-journal-text text-primary me-2"></i>Notas del Alumno
                        </h5>
                        <p>Revisa las calificaciones y evaluaciones por curso y tarea.</p>
                        <% if (tieneAlumno) { %>
                            <a href="notasPadre.jsp?alumno_id=<%= alumnoId%>" class="btn btn-primary-dashboard">
                                <i class="bi bi-arrow-right me-1"></i>Ver Notas
                            </a>
                        <% } else { %>
                            <a href="#" class="btn btn-primary-dashboard btn-disabled" disabled>
                                <i class="bi bi-lock me-1"></i>No disponible
                            </a>
                        <% } %>
                    </div>
                </div>

                <!-- Observaciones -->
                <div class="col-md-4">
                    <div class="card-box <%= !tieneAlumno ? "disabled-card" : "" %>">
                        <h5 class="fw-bold mb-3">
                            <i class="bi bi-chat-left-text text-warning me-2"></i>Observaciones
                        </h5>
                        <p>Consulta las observaciones y comentarios del docente sobre tu hijo.</p>
                        <% if (tieneAlumno) { %>
                            <a href="observacionesPadre.jsp?alumno_id=<%= alumnoId%>" class="btn btn-warning-dashboard">
                                <i class="bi bi-arrow-right me-1"></i>Ver Observaciones
                            </a>
                        <% } else { %>
                            <a href="#" class="btn btn-warning-dashboard btn-disabled" disabled>
                                <i class="bi bi-lock me-1"></i>No disponible
                            </a>
                        <% } %>
                    </div>
                </div>

                <!-- Tareas Asignadas -->
                <div class="col-md-4">
                    <div class="card-box <%= !tieneAlumno ? "disabled-card" : "" %>">
                        <h5 class="fw-bold mb-3">
                            <i class="bi bi-list-check text-success me-2"></i>Tareas Pendientes
                        </h5>
                        <p>Consulta las tareas asignadas por curso y sus fechas de entrega.</p>
                        <% if (tieneAlumno) { %>
                            <a href="tareasPadre.jsp?alumno_id=<%= alumnoId%>" class="btn btn-success-dashboard">
                                <i class="bi bi-arrow-right me-1"></i>Ver Tareas
                            </a>
                        <% } else { %>
                            <a href="#" class="btn btn-success-dashboard btn-disabled" disabled>
                                <i class="bi bi-lock me-1"></i>No disponible
                            </a>
                        <% } %>
                    </div>
                </div>

                <!-- Material de Apoyo -->
                <div class="col-md-4">
                    <div class="card-box material-card <%= !tieneAlumno ? "disabled-card" : "" %>">
                        <h5 class="fw-bold mb-3">
                            <i class="bi bi-folder-fill material-icon me-2"></i>Material de Apoyo
                        </h5>
                        <p>Accede a los materiales educativos subidos por los profesores.</p>
                        <% if (tieneAlumno) { %>
                            <a href="MaterialPadreServlet?accion=seleccionarCurso" class="btn btn-material-dashboard">
                                <i class="bi bi-arrow-right me-1"></i>Ver Materiales
                            </a>
                        <% } else { %>
                            <a href="#" class="btn btn-material-dashboard btn-disabled" disabled>
                                <i class="bi bi-lock me-1"></i>No disponible
                            </a>
                        <% } %>
                    </div>
                </div>

                <!-- Álbum de Fotos -->
                <div class="col-md-4">
                    <div class="card-box <%= !tieneAlumno ? "disabled-card" : "" %>">
                        <h5 class="fw-bold mb-3">
                            <i class="bi bi-images text-info me-2"></i>Álbum de Fotos
                        </h5>
                        <p>Álbum de recuerdos y actividades escolares de tu hijo/a.</p>
                        <% if (tieneAlumno) { %>
                            <a href="albumPadre.jsp?alumno_id=<%= alumnoId%>" class="btn btn-info-dashboard">
                                <i class="bi bi-arrow-right me-1"></i>Ver Álbum
                            </a>
                        <% } else { %>
                            <a href="#" class="btn btn-info-dashboard btn-disabled" disabled>
                                <i class="bi bi-lock me-1"></i>No disponible
                            </a>
                        <% } %>
                    </div>
                </div>

                <!-- Asistencias Detalladas -->
                <div class="col-md-4">
                    <div class="card-box <%= !tieneAlumno ? "disabled-card" : "" %>">
                        <h5 class="fw-bold mb-3">
                            <i class="bi bi-calendar-check text-secondary me-2"></i>Asistencias
                        </h5>
                        <p>Consulta el historial completo y detallado de asistencias.</p>
                        <% if (tieneAlumno) { %>
                            <a href="asistenciasPadre.jsp?alumno_id=<%= alumnoId%>" class="btn btn-secondary-dashboard">
                                <i class="bi bi-arrow-right me-1"></i>Ver Asistencias
                            </a>
                        <% } else { %>
                            <a href="#" class="btn btn-secondary-dashboard btn-disabled" disabled>
                                <i class="bi bi-lock me-1"></i>No disponible
                            </a>
                        <% } %>
                    </div>
                </div>

            </div>
        </div>

        <!-- Modal para solicitar asociación -->
        <div class="modal fade" id="solicitarAsociacionModal" tabindex="-1" aria-labelledby="solicitarAsociacionModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header bg-primary text-white">
                        <h5 class="modal-title" id="solicitarAsociacionModalLabel">
                            <i class="bi bi-headset me-2"></i>Solicitar Asociación con Alumno
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <p>Para asociar tu cuenta con un alumno, necesitas contactar con la administración del colegio.</p>
                        <div class="alert alert-info">
                            <h6><i class="bi bi-info-circle me-2"></i>Información requerida:</h6>
                            <ul class="mb-0">
                                <li>Nombre completo del padre/madre: <strong><%= padre.getNombreCompleto() %></strong></li>
                                <li>DNI: <strong><%= padre.getDni() != null ? padre.getDni() : "No registrado" %></strong></li>
                                <li>Nombre completo del alumno</li>
                                <li>Código del alumno (si lo conoces)</li>
                                <li>Grado y sección del alumno</li>
                            </ul>
                        </div>
                        <div class="mt-3">
                            <h6><i class="bi bi-telephone me-2"></i>Contacto:</h6>
                            <p class="mb-1">📞 Teléfono: <strong>987654321</strong></p>
                            <p class="mb-1">✉️ Correo: <strong>colegiosanantonio@gmail.com</strong></p>
                            <p class="mb-0">📍 Dirección: <strong>Av. El Sol 461, San Juan de Lurigancho 15434</strong></p>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
                        <a href="mailto:colegiosanantonio@gmail.com?subject=Solicitud%20de%20Asociación%20con%20Alumno&body=Nombre:%20<%= padre.getNombreCompleto() %>%0ADNI:%20<%= padre.getDni() != null ? padre.getDni() : "No registrado" %>%0ASolicito%20asociar%20mi%20cuenta%20con%20un%20alumno." class="btn btn-primary">
                            <i class="bi bi-envelope me-1"></i>Enviar Correo
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <footer class="bg-dark text-white py-4 mt-5">
            <div class="container text-center text-md-start">
                <div class="row">
                    <div class="col-md-4 mb-3">
                        <div class="logo-container text-center">
                            <img src="assets/img/logosa.png" alt="Logo" class="img-fluid mb-2" width="80" height="auto">
                            <p class="fs-6 mb-0">"Líderes en educación de calidad al más alto nivel"</p>
                        </div>
                    </div>
                    <div class="col-md-4 mb-3">
                        <h5 class="fs-6 fw-bold">Contacto:</h5>
                        <p class="fs-6 mb-1">Dirección: Av. El Sol 461, San Juan de Lurigancho 15434</p>
                        <p class="fs-6 mb-1">Teléfono: 987654321</p>
                        <p class="fs-6 mb-0">Correo: colegiosanantonio@gmail.com</p>
                    </div>
                    <div class="col-md-4 mb-3">
                        <h5 class="fs-6 fw-bold">Síguenos:</h5>
                        <div class="d-flex flex-column">
                            <a href="https://www.facebook.com/" class="text-white fs-6 mb-1 text-decoration-none">
                                <i class="fab fa-facebook me-2"></i>Facebook
                            </a>
                            <a href="https://www.instagram.com/" class="text-white fs-6 mb-1 text-decoration-none">
                                <i class="fab fa-instagram me-2"></i>Instagram
                            </a>
                            <a href="https://twitter.com/" class="text-white fs-6 mb-1 text-decoration-none">
                                <i class="fab fa-twitter me-2"></i>Twitter
                            </a>
                            <a href="https://www.youtube.com/" class="text-white fs-6 mb-0 text-decoration-none">
                                <i class="fab fa-youtube me-2"></i>YouTube
                            </a>
                        </div>
                    </div>
                </div>
                <div class="text-center mt-3 pt-3 border-top border-secondary">
                    <p class="fs-6 mb-0">&copy; 2025 Colegio SA - Todos los derechos reservados</p>
                </div>
            </div>
        </footer>
        
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        
        <script>
            // Sistema de accesibilidad para padres
            document.addEventListener('DOMContentLoaded', function() {
                // Cargar configuración de accesibilidad si existe
                const savedSettings = localStorage.getItem('accessibilitySettings');
                if (savedSettings) {
                    applyAccessibilitySettings(JSON.parse(savedSettings));
                }
                
                // Marcar contenido principal para modo enfoque
                const mainContent = document.querySelector('.container');
                if (mainContent) {
                    mainContent.classList.add('focus-content');
                }
                
                // Prevenir clics en botones deshabilitados
                document.querySelectorAll('.btn-disabled').forEach(btn => {
                    btn.addEventListener('click', function(e) {
                        e.preventDefault();
                        if (this.hasAttribute('disabled')) {
                            showNoAlumnoAlert();
                        }
                    });
                });
            });
            
            // Función para aplicar configuración de accesibilidad
            function applyAccessibilitySettings(settings) {
                // Remover todas las clases de accesibilidad
                const classesToRemove = [
                    'large-text', 'larger-text', 'largest-text',
                    'high-contrast-invert', 'high-contrast-yellow',
                    'beige-background', 'reduce-motion', 'dyslexia-font'
                ];
                
                classesToRemove.forEach(className => {
                    document.body.classList.remove(className);
                });
                
                // Aplicar configuración
                if (settings.fontSize) {
                    const fontSize = parseInt(settings.fontSize);
                    if (fontSize >= 20 && fontSize < 24) {
                        document.body.classList.add('large-text');
                    } else if (fontSize >= 24 && fontSize < 28) {
                        document.body.classList.add('larger-text');
                    } else if (fontSize >= 28) {
                        document.body.classList.add('largest-text');
                    }
                }
                
                if (settings.fontType === 'opendyslexic') {
                    document.body.classList.add('dyslexia-font');
                }
                
                if (settings.contrastScheme === 'invert') {
                    document.body.classList.add('high-contrast-invert');
                } else if (settings.contrastScheme === 'yellow') {
                    document.body.classList.add('high-contrast-yellow');
                }
                
                if (settings.beigeBackground) {
                    document.body.classList.add('beige-background');
                }
                
                if (settings.reduceAnimations) {
                    document.body.classList.add('reduce-motion');
                }
                
                if (settings.focusMode) {
                    document.body.classList.add('focus-mode', 'active');
                }
            }
            
            // Función para mostrar alerta cuando no hay alumno
            function showNoAlumnoAlert() {
                const modal = new bootstrap.Modal(document.getElementById('solicitarAsociacionModal'));
                modal.show();
            }
            
            // Mostrar modal automáticamente si hay parámetro en URL
            const urlParams = new URLSearchParams(window.location.search);
            if (urlParams.has('showAsociacionModal')) {
                setTimeout(() => {
                    showNoAlumnoAlert();
                }, 500);
            }
        </script>
    </body>
</html>