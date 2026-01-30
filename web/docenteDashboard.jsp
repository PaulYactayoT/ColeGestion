<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Profesor, modelo.Curso, java.util.List" %>
<%@ page import="modelo.AsistenciaDAO, java.util.Map, java.util.HashMap" %>
<%
    Profesor docente = (Profesor) session.getAttribute("docente");
    List<Curso> cursos = (List<Curso>) request.getAttribute("misCursos");

    if (docente == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    if (cursos == null) {
        response.sendRedirect("DocenteDashboardServlet");
        return;
    }

    AsistenciaDAO asistenciaDAO = new AsistenciaDAO();
    Map<Integer, Map<String, Object>> estadisticasCursos = new HashMap<>();

    if (cursos != null && !cursos.isEmpty()) {
        for (Curso curso : cursos) {
            Map<String, Object> stats = new HashMap<>();
            stats.put("totalAlumnos", 25);
            stats.put("presentesHoy", 22);
            stats.put("ausentesHoy", 3);
            stats.put("porcentajeAsistencia", 88.0);
            estadisticasCursos.put(curso.getId(), stats);
        }
    }

    String mensaje = (String) session.getAttribute("mensaje");
    String error = (String) session.getAttribute("error");

    if (mensaje != null) {
        session.removeAttribute("mensaje");
    }
    if (error != null) {
        session.removeAttribute("error");
    }
%>

<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <title>Panel del Docente</title>
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
                background-image: url('assets/img/fondo_dashboard_docente.jpg');
                background-size: 100% 100%;
                background-position: center;
                background-attachment: fixed;
                height: 100vh;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            }
            .header-bar {
                background-color: #111;
                color: white;
                padding: 15px 30px;
                display: flex;
                justify-content: space-between;
                align-items: center;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            }
            .nav-links a {
                color: white;
                margin-right: 25px;
                text-decoration: none;
            }
            .nav-links a:hover {
                text-decoration: underline;
            }
            .card-box {
                background-color: #fff8ed;
                border-radius: 15px;
                padding: 20px;
                text-align: center;
                box-shadow: 0 4px 8px rgba(0,0,0,0.1);
                transition: transform 0.2s;
                border: 1px solid #e9ecef;
                height: 100%;
            }
            .card-box:hover {
                transform: translateY(-5px);
                box-shadow: 0 6px 12px rgba(0,0,0,0.15);
            }
            .asistencia-badge {
                font-size: 0.8rem;
                padding: 4px 8px;
                border-radius: 10px;
            }
            
            .btn-dashboard {
                padding: 0.6rem 1rem;
                border: none;
                border-radius: 10px;
                font-weight: 600;
                font-size: 0.9rem;
                transition: all 0.3s ease;
                box-shadow: 0 4px 8px rgba(0,0,0,0.1);
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 8px;
                width: 100%;
                margin-bottom: 10px;
            }
            
            .btn-dashboard:hover {
                transform: translateY(-2px);
                box-shadow: 0 6px 12px rgba(0,0,0,0.15);
            }
            
            .btn-primary-dashboard {
                background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
                color: white;
            }
            
            .btn-primary-dashboard:hover {
                background: linear-gradient(135deg, var(--primary-dark), var(--primary-color));
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
            
            .btn-success-dashboard {
                background: linear-gradient(135deg, var(--success-color), #1ba87e);
                color: white;
            }
            
            .btn-success-dashboard:hover {
                background: linear-gradient(135deg, #1ba87e, var(--success-color));
                color: white;
            }
            
            .btn-info-dashboard {
                background: linear-gradient(135deg, #17a2b8, #138496);
                color: white;
            }
            
            .btn-info-dashboard:hover {
                background: linear-gradient(135deg, #138496, #17a2b8);
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
            
            .btn-light-dashboard {
                background: linear-gradient(135deg, #f8f9fa, #e9ecef);
                color: #212529;
                border: 1px solid #dee2e6;
            }
            
            .btn-light-dashboard:hover {
                background: linear-gradient(135deg, #e9ecef, #f8f9fa);
                color: #212529;
            }
            
            /* Nuevo estilo para botón de Material de Apoyo */
            .btn-purple-dashboard {
                background: linear-gradient(135deg, #6f42c1, #563d7c);
                color: white;
            }
            
            .btn-purple-dashboard:hover {
                background: linear-gradient(135deg, #563d7c, #6f42c1);
                color: white;
            }
            
            .stats-card {
                background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
                color: white;
                border: none;
                border-radius: 15px;
                box-shadow: 0 6px 15px rgba(44, 90, 160, 0.3);
            }
            
            .stats-card .btn {
                border-radius: 10px;
                font-weight: 600;
                transition: all 0.3s ease;
                box-shadow: 0 4px 8px rgba(0,0,0,0.1);
            }
            
            .stats-card .btn:hover {
                transform: translateY(-2px);
                box-shadow: 0 6px 12px rgba(0,0,0,0.15);
            }
            
            .curso-title {
                color: var(--primary-dark);
                font-weight: 700;
                border-bottom: 2px solid var(--primary-light);
                padding-bottom: 10px;
                margin-bottom: 15px;
            }
            
            .stats-container {
                background: rgba(255, 255, 255, 0.9);
                border-radius: 10px;
                padding: 15px;
                margin-bottom: 15px;
                box-shadow: 0 2px 5px rgba(0,0,0,0.05);
            }
            
            footer {
                margin-top: 50px;
            }
        </style>
    </head>
    <body>

        <div class="header-bar">
            <div class="nav-links">
                <img src="assets/img/logosa.png" alt="Logo" style="width: 30px; height: auto; margin-right: 10px;" />
                <span class="fw-bold fs-6">Colegio SA</span>
            </div>
            <div>
                <span><i class="bi bi-person-circle"></i> <%= docente.getNombres()%> <%= docente.getApellidos()%></span>
                <a href="LogoutServlet" class="btn btn-outline-light btn-sm ms-3">
                    <i class="bi bi-box-arrow-right"></i> Cerrar sesión
                </a>
            </div>
        </div>

        <div class="container mt-5">

            <!-- Mostrar mensajes -->
            <% if (mensaje != null) {%>
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle"></i> <%= mensaje%>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <% } %>

            <% if (error != null) {%>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="bi bi-exclamation-triangle"></i> <%= error%>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <% } %>

            <h2 class="text-center fw-bold mb-5">
                <i class="bi bi-speedometer2"></i> Panel del Docente
            </h2>

            <div class="card mb-4 stats-card">
                <div class="card-body">
                    <h5 class="card-title mb-3">
                        <i class="bi bi-clipboard-check"></i> Módulo de Asistencias
                    </h5>
                    <div class="row">
                        <div class="col-md-4">
                            <a href="AsistenciaServlet?accion=registrar" class="btn btn-light-dashboard">
                                <i class="bi bi-plus-circle"></i> Tomar Asistencia
                            </a>
                        </div>
                        <div class="col-md-4">
                            <a href="JustificacionServlet?accion=pending" class="btn btn-warning-dashboard">
                                <i class="bi bi-clock-history"></i> Justificaciones Pendientes
                            </a>
                        </div>
                        <div class="col-md-4">
                            <a href="MaterialServlet?accion=seleccionarCurso" class="btn btn-purple-dashboard">
                                <i class="bi bi-folder-fill"></i> Material de Apoyo
                            </a>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row g-4">
                <%
                    if (cursos != null && !cursos.isEmpty()) {
                        for (Curso c : cursos) {
                            Map<String, Object> stats = estadisticasCursos.get(c.getId());
                %>
                <div class="col-md-4">
                    <div class="card-box">
                        <h5 class="curso-title">
                            <i class="bi bi-book"></i> <%= c.getNombre()%>
                        </h5>
                        <p class="mb-2">
                            <strong>Grado:</strong> <%= c.getGradoNombre()%>
                        </p>
                        <p class="mb-3 text-muted small">
                            <strong>Profesor:</strong> <%= c.getProfesorNombre() != null ? c.getProfesorNombre() : "No asignado"%>
                        </p>

                        <!-- Información de Asistencia -->
                        <% if (stats != null) {%>
                        <div class="stats-container">
                            <small class="text-muted d-block mb-2">
                                <i class="bi bi-calendar-check"></i> Asistencia Hoy
                            </small>
                            <div class="d-flex justify-content-center gap-2 mb-2">
                                <span class="badge bg-success">
                                    <i class="bi bi-check-circle"></i> <%= stats.get("presentesHoy")%> Presentes
                                </span>
                                <span class="badge bg-danger">
                                    <i class="bi bi-x-circle"></i> <%= stats.get("ausentesHoy")%> Ausentes
                                </span>
                            </div>
                            <div class="mt-2">
                                <small class="fw-bold text-primary">
                                    <i class="bi bi-percent"></i> <%= stats.get("porcentajeAsistencia")%>% de asistencia
                                </small>
                            </div>
                        </div>
                        <% }%>

                        <div class="d-grid gap-2 mt-3">
                            <a href="TareaServlet?accion=ver&curso_id=<%= c.getId()%>" class="btn btn-secondary-dashboard">
                                <i class="bi bi-journal-check"></i> Gestionar Tareas
                            </a>
                            <a href="NotaServlet?curso_id=<%= c.getId()%>" class="btn btn-primary-dashboard">
                                <i class="bi bi-pencil-square"></i> Gestionar Notas
                            </a>
                            <a href="ObservacionServlet?accion=listar&curso_id=<%= c.getId()%>" class="btn btn-success-dashboard">
                                <i class="bi bi-chat-left-text"></i> Gestionar Observaciones
                            </a>
                            <a href="AsistenciaServlet?accion=registrar&curso_id=<%= c.getId()%>" class="btn btn-info-dashboard">
                                <i class="bi bi-clipboard-data"></i> Gestionar Asistencias
                            </a>
                        </div>
                    </div>
                </div>
                <%
                    }
                } else {
                %>
                <div class="col-12">
                    <div class="alert alert-info text-center">
                        <h5><i class="bi bi-info-circle"></i> No tienes cursos asignados</h5>
                        <p class="mb-0">Contacta con administración para asignarte cursos.</p>
                        <a href="DocenteDashboardServlet" class="btn btn-primary mt-2">
                            <i class="bi bi-arrow-clockwise"></i> Recargar
                        </a>
                    </div>
                </div>
                <%
                    }
                %>
            </div>
        </div>

        <footer class="bg-dark text-white py-2 mt-5">
            <div class="container text-center text-md-start">
                <div class="row">
                    <div class="col-md-4 mb-0">
                        <div class="logo-container text-center">
                            <img src="assets/img/logosa.png" alt="Logo" class="img-fluid mb-1" width="80" height="auto">
                            <p class="fs-6">"Líderes en educación de calidad al más alto nivel"</p>
                        </div>
                    </div>

                    <div class="col-md-4 mb-0">
                        <h5 class="fs-8">Contacto:</h5>
                        <p class="fs-6">Dirección: Av. El Sol 461, San Juan de Lurigancho 15434</p>
                        <p class="fs-6">Teléfono: 987654321</p>
                        <p class="fs-6">Correo: colegiosanantonio@gmail.com</p>
                    </div>

                    <div class="col-md-4 mb-0">
                        <h5 class="fs-8">Síguenos:</h5>
                        <a href="https://www.facebook.com/" class="text-white d-block fs-6">Facebook</a>
                        <a href="https://www.instagram.com/" class="text-white d-block fs-6">Instagram</a>
                        <a href="https://twitter.com/" class="text-white d-block fs-6">Twitter</a>
                        <a href="https://www.youtube.com/" class="text-white d-block fs-6">YouTube</a>
                    </div>
                </div>

                <div class="text-center mt-0">
                    <p class="fs-6">&copy; 2025 Colegio SA - Todos los derechos reservados</p>
                </div>
            </div>
        </footer>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>