<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Curso, java.util.List" %>
<%
    List<Curso> cursos = (List<Curso>) request.getAttribute("misCursos");
    String mensaje = (String) request.getParameter("mensaje");
    String error = (String) request.getParameter("error");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Gestión de Asistencias - Docente</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
</head>
<body>
    <jsp:include page="header.jsp"/>

    <div class="container mt-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2><i class="bi bi-clipboard-check"></i> Gestión de Asistencias</h2>
            <a href="docenteDashboard.jsp" class="btn btn-secondary">
                <i class="bi bi-arrow-left"></i> Volver al Dashboard
            </a>
        </div>

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

        <div class="row">
            <% if (cursos != null && !cursos.isEmpty()) { 
                for (Curso curso : cursos) { %>
                <div class="col-md-6 col-lg-4 mb-4">
                    <div class="card h-100 shadow-sm">
                        <div class="card-body">
                            <h5 class="card-title text-primary">
                                <i class="bi bi-book"></i> <%= curso.getNombre() %>
                            </h5>
                            <p class="card-text">
                                <strong>Grado:</strong> <%= curso.getGradoNombre() %><br>
                                <strong>Créditos:</strong> <%= curso.getCreditos() %>
                            </p>
                        </div>
                        <div class="card-footer bg-transparent">
                            <div class="d-grid gap-2">
                                <a href="AsistenciaServlet?accion=verCurso&curso_id=<%= curso.getId() %>" 
                                   class="btn btn-outline-primary btn-sm">
                                    <i class="bi bi-list-check"></i> Ver Asistencias
                                </a>
                                <a href="registrarAsistencia.jsp?curso_id=<%= curso.getId() %>" 
                                   class="btn btn-outline-success btn-sm">
                                    <i class="bi bi-plus-circle"></i> Registrar Asistencia
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
                <% }
            } else { %>
                <div class="col-12">
                    <div class="alert alert-info text-center">
                        <h5><i class="bi bi-info-circle"></i> No tienes cursos asignados</h5>
                        <p class="mb-0">Contacta con administración para asignarte cursos.</p>
                    </div>
                </div>
            <% } %>
        </div>

        <!-- Acciones adicionales -->
        <div class="row mt-4">
            <div class="col-12">
                <div class="card">
                    <div class="card-body">
                        <h5 class="card-title">Otras Acciones</h5>
                        <div class="d-flex gap-2 flex-wrap">
                            <a href="reportesAsistencia.jsp" class="btn btn-info">
                                <i class="bi bi-graph-up"></i> Ver Reportes
                            </a>
                            <a href="JustificacionServlet?accion=pending" class="btn btn-warning">
                                <i class="bi bi-clock-history"></i> Justificaciones Pendientes
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>