<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Padre" %>
<%@ page import="modelo.ImageDAO, modelo.Imagen" %>
<%@ page import="modelo.AsistenciaDAO, java.util.Map" %>
<%@ page import="java.util.List" %>

<%
    Padre padre = (Padre) session.getAttribute("padre");
    if (padre == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    int alumnoId = padre.getAlumnoId();

    // Obtener resumen de asistencias del mes actual
    AsistenciaDAO asistenciaDAO = new AsistenciaDAO();
    int mesActual = java.time.LocalDate.now().getMonthValue();
    int anioActual = java.time.LocalDate.now().getYear();

    // Obtener resumen de asistencias (usaremos turno 1 por defecto)
    Map<String, Object> resumenAsistencia = asistenciaDAO.obtenerResumenAsistenciaAlumnoTurno(alumnoId, 1, mesActual, anioActual);

    // Cargar imágenes ya subidas de este alumno
    List<Imagen> imgs = new ImageDAO().listarPorAlumno(alumnoId);

    // Calcular porcentaje de asistencia
    double porcentajeAsistencia = 0.0;
    if (resumenAsistencia != null && !resumenAsistencia.isEmpty()) {
        Object porcentajeObj = resumenAsistencia.get("porcentajeAsistencia");
        if (porcentajeObj != null) {
            porcentajeAsistencia = (Double) porcentajeObj;
        }
    }

    // Determinar color del badge según el porcentaje
    String badgeClass = "bg-success";
    if (porcentajeAsistencia < 75) {
        badgeClass = "bg-danger";
    } else if (porcentajeAsistencia < 90) {
        badgeClass = "bg-warning";
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
        </style>
    </head>
    <body>

        <div class="header-bar">
            <div>
                <img src="assets/img/logosa.png" alt="Logo" style="width: 30px; height: auto; margin-right: 10px;" />
                <strong>Colegio SA</strong>
            </div>
            <div>
                <span class="me-3">Padre de: <strong><%= padre.getAlumnoNombre()%></strong> | Grado: <strong><%= padre.getGradoNombre()%></strong></span>
                <a href="LogoutServlet" class="btn btn-outline-light btn-sm">
                    <i class="bi bi-box-arrow-right me-1"></i>Cerrar sesión
                </a>
            </div>
        </div>

        <div class="container mt-5">
            <h2 class="page-title">
                <i class="bi bi-house-heart me-2"></i>Panel del Padre de Familia
            </h2>

            <!-- Tarjeta de Resumen de Asistencia -->
            <div class="card asistencia-card mb-5">
                <div class="card-body">
                    <div class="row align-items-center">
                        <div class="col-md-8">
                            <h5 class="card-title mb-3">
                                <i class="bi bi-journal-check me-2"></i>Asistencia Escolar
                            </h5>
                            <p class="card-text mb-3">
                                <strong>Asistencia Mensual:</strong> 
                                <span class="badge <%= badgeClass%> badge-lg ms-2"><%= String.format("%.1f", porcentajeAsistencia)%>%</span>
                            </p>
                            <% if (resumenAsistencia != null && !resumenAsistencia.isEmpty()) {%>
                            <div class="row mt-3">
                                <div class="col-6 col-md-3 mb-2">
                                    <small><i class="bi bi-check-circle-fill text-success me-1"></i> <strong><%= resumenAsistencia.get("presentes")%></strong> Presentes</small>
                                </div>
                                <div class="col-6 col-md-3 mb-2">
                                    <small><i class="bi bi-clock-fill text-warning me-1"></i> <strong><%= resumenAsistencia.get("tardanzas")%></strong> Tardanzas</small>
                                </div>
                                <div class="col-6 col-md-3 mb-2">
                                    <small><i class="bi bi-x-circle-fill text-danger me-1"></i> <strong><%= resumenAsistencia.get("ausentes")%></strong> Ausentes</small>
                                </div>
                                <div class="col-6 col-md-3 mb-2">
                                    <small><i class="bi bi-file-text-fill text-info me-1"></i> <strong><%= resumenAsistencia.get("justificados")%></strong> Justificados</small>
                                </div>
                            </div>
                            <% }%>
                        </div>
                        <div class="col-md-4 text-center text-md-end">
                            <a href="AsistenciaServlet?accion=verPadre&alumno_id=<%= alumnoId%>" class="btn btn-light btn-dashboard me-2 mb-2">
                                <i class="bi bi-graph-up me-1"></i>Ver Detalles
                            </a>
                            <a href="JustificacionServlet?accion=form" class="btn btn-warning-dashboard mb-2">
                                <i class="bi bi-pencil-square me-1"></i>Justificar
                            </a>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row g-4 justify-content-center">

                <!-- Notas del Alumno -->
                <div class="col-md-4">
                    <div class="card-box">
                        <h5 class="fw-bold mb-3">
                            <i class="bi bi-journal-text text-primary me-2"></i>Notas del Alumno
                        </h5>
                        <p>Revisa las calificaciones y evaluaciones por curso y tarea.</p>
                        <a href="notasPadre.jsp?alumno_id=<%= alumnoId%>" class="btn btn-primary-dashboard">
                            <i class="bi bi-arrow-right me-1"></i>Ver Notas
                        </a>
                    </div>
                </div>

                <!-- Observaciones -->
                <div class="col-md-4">
                    <div class="card-box">
                        <h5 class="fw-bold mb-3">
                            <i class="bi bi-chat-left-text text-warning me-2"></i>Observaciones
                        </h5>
                        <p>Consulta las observaciones y comentarios del docente sobre tu hijo.</p>
                        <a href="observacionesPadre.jsp?alumno_id=<%= alumnoId%>" class="btn btn-warning-dashboard">
                            <i class="bi bi-arrow-right me-1"></i>Ver Observaciones
                        </a>
                    </div>
                </div>

                <!-- Tareas Asignadas -->
                <div class="col-md-4">
                    <div class="card-box">
                        <h5 class="fw-bold mb-3">
                            <i class="bi bi-list-check text-success me-2"></i>Tareas Pendientes
                        </h5>
                        <p>Consulta las tareas asignadas por curso y sus fechas de entrega.</p>
                        <a href="tareasPadre.jsp?alumno_id=<%= alumnoId%>" class="btn btn-success-dashboard">
                            <i class="bi bi-arrow-right me-1"></i>Ver Tareas
                        </a>
                    </div>
                </div>

                <!-- Álbum de Fotos -->
                <div class="col-md-4">
                    <div class="card-box">
                        <h5 class="fw-bold mb-3">
                            <i class="bi bi-images text-info me-2"></i>Álbum de Fotos
                        </h5>
                        <p>Álbum de recuerdos y actividades escolares de tu hijo/a.</p>
                        <a href="albumPadre.jsp?alumno_id=<%= alumnoId%>" class="btn btn-info-dashboard">
                            <i class="bi bi-arrow-right me-1"></i>Ver Álbum
                        </a>
                    </div>
                </div>

                <!-- Asistencias Detalladas -->
                <div class="col-md-4">
                    <div class="card-box">
                        <h5 class="fw-bold mb-3">
                            <i class="bi bi-calendar-check text-secondary me-2"></i>Asistencias
                        </h5>
                        <p>Consulta el historial completo y detallado de asistencias.</p>
                        <a href="asistenciasPadre.jsp?alumno_id=<%= alumnoId%>" class="btn btn-secondary-dashboard">
                            <i class="bi bi-arrow-right me-1"></i>Ver Asistencias
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
        </script>
    </body>
</html>