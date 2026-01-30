<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Profesor, modelo.Curso, java.util.List" %>
<%
    Profesor docente = (Profesor) session.getAttribute("docente");
    List<Curso> cursos = (List<Curso>) request.getAttribute("cursos");

    if (docente == null) {
        response.sendRedirect("index.jsp");
        return;
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
        <title>Seleccionar Curso - Material de Apoyo</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
        <link rel="stylesheet" href="assets/css/estilos.css">

        <style>
            :root {
                --primary-color: #2c5aa0;
                --primary-dark: #1e3d72;
                --success-color: #20c997;
                --purple-color: #6f42c1;
                --purple-dark: #563d7c;
            }
            
            body {
                background-image: url('assets/img/fondo_dashboard_docente.jpg');
                background-size: cover;
                background-position: center;
                background-attachment: fixed;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                min-height: 100vh;
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
            
            .main-container {
                background: rgba(255, 255, 255, 0.95);
                border-radius: 15px;
                padding: 40px;
                box-shadow: 0 8px 20px rgba(0,0,0,0.15);
                margin-top: 50px;
                max-width: 1000px;
                margin-left: auto;
                margin-right: auto;
            }
            
            .curso-card {
                background: white;
                border-radius: 12px;
                padding: 25px;
                margin-bottom: 20px;
                box-shadow: 0 4px 8px rgba(0,0,0,0.1);
                transition: all 0.3s ease;
                border-left: 5px solid var(--purple-color);
                cursor: pointer;
            }
            
            .curso-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 8px 16px rgba(111, 66, 193, 0.3);
                border-left-color: var(--purple-dark);
            }
            
            .curso-icon {
                font-size: 3rem;
                color: var(--purple-color);
                margin-bottom: 10px;
            }
            
            .curso-title {
                font-size: 1.5rem;
                font-weight: 700;
                color: var(--primary-dark);
                margin-bottom: 10px;
            }
            
            .curso-info {
                color: #6c757d;
                font-size: 0.95rem;
                margin-bottom: 5px;
            }
            
            .btn-seleccionar {
                background: linear-gradient(135deg, var(--purple-color), var(--purple-dark));
                border: none;
                color: white;
                padding: 10px 25px;
                border-radius: 10px;
                transition: all 0.3s;
                font-weight: 600;
                width: 100%;
            }
            
            .btn-seleccionar:hover {
                transform: translateY(-2px);
                box-shadow: 0 6px 12px rgba(111, 66, 193, 0.4);
                color: white;
            }
            
            .page-title {
                text-align: center;
                color: var(--primary-dark);
                margin-bottom: 40px;
                font-weight: 700;
            }
            
            .page-title i {
                color: var(--purple-color);
            }
            
            .empty-state {
                text-align: center;
                padding: 60px 20px;
                color: #6c757d;
            }
            
            .empty-state i {
                font-size: 4rem;
                color: #dee2e6;
                margin-bottom: 20px;
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
                <a href="DocenteDashboardServlet" class="btn btn-outline-light btn-sm ms-3">
                    <i class="bi bi-arrow-left"></i> Volver al Panel
                </a>
                <a href="LogoutServlet" class="btn btn-outline-light btn-sm ms-2">
                    <i class="bi bi-box-arrow-right"></i> Cerrar sesión
                </a>
            </div>
        </div>

        <div class="container">
            <div class="main-container">

                <!-- Mensajes -->
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

                <!-- Título -->
                <h2 class="page-title">
                    <i class="bi bi-folder-fill"></i> Material de Apoyo
                </h2>
                
                <p class="text-center text-muted mb-4">
                    Selecciona el curso para el cual deseas gestionar materiales de apoyo
                </p>

                <!-- Lista de Cursos -->
                <div class="row">
                    <%
                        if (cursos != null && !cursos.isEmpty()) {
                            for (Curso curso : cursos) {
                    %>
                    <div class="col-md-6">
                        <div class="curso-card" onclick="location.href='MaterialServlet?accion=verMateriales&curso_id=<%= curso.getId()%>'">
                            <div class="row align-items-center">
                                <div class="col-3 text-center">
                                    <i class="bi bi-book-half curso-icon"></i>
                                </div>
                                <div class="col-9">
                                    <h5 class="curso-title"><%= curso.getNombre()%></h5>
                                    <p class="curso-info mb-1">
                                        <i class="bi bi-mortarboard"></i> 
                                        <strong>Grado:</strong> <%= curso.getGradoNombre()%>
                                    </p>
                                    <p class="curso-info mb-3">
                                        <i class="bi bi-person"></i> 
                                        <strong>Profesor:</strong> <%= curso.getProfesorNombre() != null ? curso.getProfesorNombre() : "No asignado"%>
                                    </p>
                                    <a href="MaterialServlet?accion=verMateriales&curso_id=<%= curso.getId()%>" 
                                       class="btn btn-seleccionar"
                                       onclick="event.stopPropagation()">
                                        <i class="bi bi-folder-open"></i> Gestionar Materiales
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                    <%
                            }
                        } else {
                    %>
                    <div class="col-12">
                        <div class="empty-state">
                            <i class="bi bi-inbox"></i>
                            <h4>No tienes cursos asignados</h4>
                            <p class="text-muted">
                                Contacta con el administrador para que te asigne cursos
                            </p>
                            <a href="DocenteDashboardServlet" class="btn btn-primary mt-3">
                                <i class="bi bi-arrow-clockwise"></i> Recargar
                            </a>
                        </div>
                    </div>seleccioncurso
                    <%
                        }
                    %>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>