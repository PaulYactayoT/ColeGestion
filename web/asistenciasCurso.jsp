<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Asistencia, java.util.List" %>
<%
    List<Asistencia> asistencias = (List<Asistencia>) request.getAttribute("asistencias");
    Integer cursoId = (Integer) request.getAttribute("cursoId");
    String fecha = (String) request.getAttribute("fecha");
    String mensaje = (String) request.getParameter("mensaje");
    String error = (String) request.getParameter("error");

    if (fecha == null) {
        fecha = java.time.LocalDate.now().toString();
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <title>Asistencias del Curso</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    </head>
    <body>
        <jsp:include page="header.jsp"/>

        <div class="container mt-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2><i class="bi bi-clipboard-data"></i> Asistencias del Curso</h2>
                <a href="AsistenciaServlet?accion=ver" class="btn btn-secondary">
                    <i class="bi bi-arrow-left"></i> Volver a Cursos
                </a>
            </div>

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
            <% }%>

            <!-- Filtros -->
            <div class="card mb-4">
                <div class="card-body">
                    <form method="get" class="row g-3">
                        <input type="hidden" name="accion" value="verCurso">
                        <input type="hidden" name="curso_id" value="<%= cursoId%>">

                        <div class="col-md-4">
                            <label for="fecha" class="form-label">Fecha</label>
                            <input type="date" class="form-control" id="fecha" name="fecha" 
                                   value="<%= fecha%>" required>
                        </div>

                        <div class="col-md-3">
                            <label for="turno_id" class="form-label">Turno</label>
                            <select class="form-select" id="turno_id" name="turno_id">
                                <option value="1">MAÑANA</option>
                                <option value="2">TARDE</option>
                            </select>
                        </div>

                        <div class="col-md-2">
                            <label class="form-label">&nbsp;</label>
                            <button type="submit" class="btn btn-primary w-100">
                                <i class="bi bi-funnel"></i> Filtrar
                            </button>
                        </div>

                        <div class="col-md-3">
                            <label class="form-label">&nbsp;</label>
                            <a href="AsistenciaServlet?accion=registrar&curso_id=${cursoId}&fecha=${fecha}" class="btn btn-primary">
                                <i class="bi bi-plus-circle"></i> Nueva Asistencia
                            </a>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Lista de asistencias -->
            <div class="card">
                <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center">
                    <h5 class="mb-0"><i class="bi bi-list-check"></i> Registros de Asistencia</h5>
                    <span class="badge bg-light text-dark"><%= asistencias != null ? asistencias.size() : 0%> registros</span>
                </div>
                <div class="card-body">
                    <% if (asistencias != null && !asistencias.isEmpty()) { %>
                    <div class="table-responsive">
                        <table class="table table-striped table-hover">
                            <thead class="table-dark">
                                <tr>
                                    <th>Alumno</th>
                                    <th>Fecha</th>
                                    <th>Hora</th>
                                    <th>Estado</th>
                                    <th>Observaciones</th>
                                    <th>Registrado por</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Asistencia a : asistencias) {
                                        String estadoBadge = "";
                                        String estadoIcon = "";
                                        switch (a.getEstado()) {
                                            case "PRESENTE":
                                                estadoBadge = "bg-success";
                                                estadoIcon = "bi-check-circle";
                                                break;
                                            case "TARDANZA":
                                                estadoBadge = "bg-warning";
                                                estadoIcon = "bi-clock";
                                                break;
                                            case "AUSENTE":
                                                estadoBadge = "bg-danger";
                                                estadoIcon = "bi-x-circle";
                                                break;
                                            case "JUSTIFICADO":
                                                estadoBadge = "bg-info";
                                                estadoIcon = "bi-file-text";
                                                break;
                                        }
                                %>
                                <tr>
                                    <td><%= a.getAlumnoNombre() != null ? a.getAlumnoNombre() : "N/A"%></td>
                                    <td><%= a.getFecha()%></td>
                                    <td><%= a.getHoraClase() != null ? a.getHoraClase() : "N/A"%></td>
                                    <td>
                                        <span class="badge <%= estadoBadge%>">
                                            <i class="bi <%= estadoIcon%>"></i> <%= a.getEstado()%>
                                        </span>
                                    </td>
                                    <td>
                                        <% if (a.getObservaciones() != null && !a.getObservaciones().isEmpty()) {%>
                                        <button type="button" class="btn btn-sm btn-outline-secondary" 
                                                data-bs-toggle="tooltip" 
                                                title="<%= a.getObservaciones()%>">
                                            <i class="bi bi-eye"></i>
                                        </button>
                                        <% } else { %>
                                        <span class="text-muted">-</span>
                                        <% }%>
                                    </td>
                                    <td><%= a.getProfesorNombre() != null ? a.getProfesorNombre() : "Sistema"%></td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                    <% } else {%>
                    <div class="text-center py-4">
                        <div class="text-muted">
                            <i class="bi bi-calendar-x" style="font-size: 3rem;"></i>
                            <h5 class="mt-3">No hay asistencias registradas</h5>
                            <p>No se encontraron registros de asistencia para los criterios seleccionados.</p>
                            <a href="registrarAsistencia.jsp?curso_id=<%= cursoId%>" class="btn btn-primary">
                                <i class="bi bi-plus-circle"></i> Registrar Primera Asistencia
                            </a>
                        </div>
                    </div>
                    <% }%>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            // Inicializar tooltips
            var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
            var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
                return new bootstrap.Tooltip(tooltipTriggerEl);
            });
        </script>
    </body>
</html>