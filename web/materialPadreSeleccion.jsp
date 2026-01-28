<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Padre, modelo.Curso, java.util.List, java.util.Map" %>
<%
    Padre padre = (Padre) session.getAttribute("padre");
    List<Curso> cursos = (List<Curso>) request.getAttribute("cursos");
    Map<Integer, Integer> contadorMateriales = (Map<Integer, Integer>) request.getAttribute("contadorMateriales");
    String alumnoNombre = (String) request.getAttribute("alumnoNombre");

    if (padre == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    String mensaje = (String) session.getAttribute("mensaje");
    String error = (String) request.getAttribute("error");
    if (error == null) error = (String) session.getAttribute("error");

    if (mensaje != null) session.removeAttribute("mensaje");
    if (error != null) session.removeAttribute("error");
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Material de Apoyo - Padre</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    
    <style>
        :root {
            --primary-color: #2c5aa0;
            --purple-color: #6f42c1;
        }
        
        body {
            background-image: url('assets/img/fondo_dashboard_docente.jpg');
            background-size: cover;
            background-attachment: fixed;
            min-height: 100vh;
        }
        
        .header-bar {
            background-color: #111;
            color: white;
            padding: 15px 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .main-container {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 15px;
            padding: 40px;
            box-shadow: 0 8px 20px rgba(0,0,0,0.15);
            margin-top: 50px;
            max-width: 1200px;
        }
        
        .alumno-info {
            background: linear-gradient(135deg, var(--primary-color), var(--purple-color));
            color: white;
            padding: 20px;
            border-radius: 12px;
            margin-bottom: 30px;
            text-align: center;
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
        }
        
        .badge-materiales {
            background: var(--purple-color);
            color: white;
            padding: 8px 15px;
            border-radius: 20px;
            font-size: 0.9rem;
        }
        
        .btn-ver-materiales {
            background: linear-gradient(135deg, var(--purple-color), #563d7c);
            border: none;
            color: white;
            padding: 10px 25px;
            border-radius: 10px;
            width: 100%;
            font-weight: 600;
            transition: all 0.3s;
        }
        
        .btn-ver-materiales:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 12px rgba(111, 66, 193, 0.4);
            color: white;
        }
    </style>
</head>
<body>

    <!-- Header -->
    <div class="header-bar d-flex justify-content-between align-items-center">
        <div class="d-flex align-items-center">
            <img src="assets/img/logosa.png" alt="Logo" style="width: 30px; height: auto; margin-right: 10px;" />
            <span class="fw-bold fs-6">Colegio SA</span>
        </div>
        <div>
            <span><i class="bi bi-person-circle"></i> Padre de: <%= alumnoNombre != null ? alumnoNombre : "null" %></span>
            <a href="PadreDashboardServlet" class="btn btn-outline-light btn-sm ms-3">
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
            <% if (mensaje != null) { %>
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle"></i> <%= mensaje %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <% } %>

            <% if (error != null) { %>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="bi bi-exclamation-triangle"></i> <%= error %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <% } %>

            <!-- Información del Alumno -->
            <div class="alumno-info">
                <h3><i class="bi bi-person-circle"></i> Materiales de estudio para: <%= alumnoNombre != null ? alumnoNombre : "null" %></h3>
                <p class="mb-0">Selecciona el curso para ver los materiales de apoyo subidos por el profesor</p>
            </div>

            <!-- Lista de Cursos -->
            <h2 class="text-center mb-4">
                <i class="bi bi-folder-fill text-purple"></i> Material de Apoyo
            </h2>

            <div class="row">
                <%
                    if (cursos != null && !cursos.isEmpty()) {
                        for (Curso curso : cursos) {
                            int cantidadMateriales = contadorMateriales != null ? 
                                contadorMateriales.getOrDefault(curso.getId(), 0) : 0;
                %>
                <div class="col-md-6">
                    <div class="curso-card" onclick="location.href='MaterialPadreServlet?accion=verMateriales&curso_id=<%= curso.getId() %>'">
                        <div class="row align-items-center">
                            <div class="col-3 text-center">
                                <i class="bi bi-book-half" style="font-size: 3rem; color: var(--purple-color);"></i>
                            </div>
                            <div class="col-9">
                                <h5 style="color: var(--primary-color); font-weight: 700;">
                                    <%= curso.getNombre() %>
                                </h5>
                                <p class="text-muted mb-2">
                                    <i class="bi bi-mortarboard"></i> 
                                    <strong>Grado:</strong> <%= curso.getGradoNombre() %>
                                </p>
                                <p class="text-muted mb-3">
                                    <i class="bi bi-person"></i> 
                                    <strong>Profesor:</strong> <%= curso.getProfesorNombre() != null ? curso.getProfesorNombre() : "No asignado" %>
                                </p>
                                <div class="d-flex justify-content-between align-items-center">
                                    <span class="badge-materiales">
                                        <i class="bi bi-file-earmark-text"></i> <%= cantidadMateriales %> materiales
                                    </span>
                                    <a href="MaterialPadreServlet?accion=verMateriales&curso_id=<%= curso.getId() %>" 
                                       class="btn btn-ver-materiales"
                                       style="width: auto; padding: 8px 20px;"
                                       onclick="event.stopPropagation()">
                                        <i class="bi bi-eye"></i> Ver Materiales
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <%
                        }
                    } else {
                %>
                <div class="col-12">
                    <div class="text-center py-5">
                        <i class="bi bi-inbox" style="font-size: 4rem; color: #dee2e6;"></i>
                        <h4 class="mt-3">No se encontraron cursos</h4>
                        <p class="text-muted">El alumno aún no tiene cursos asignados para este ciclo escolar</p>
                        <a href="PadreDashboardServlet" class="btn btn-primary mt-3">
                            <i class="bi bi-arrow-clockwise"></i> Volver al Panel
                        </a>
                    </div>
                </div>
                <%
                    }
                %>
            </div>

        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>