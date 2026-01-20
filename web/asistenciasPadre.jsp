<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Asistencia, java.util.List, java.util.Map" %>
<%
    List<Asistencia> asistencias = (List<Asistencia>) request.getAttribute("asistencias");
    Map<String, Object> resumen = (Map<String, Object>) request.getAttribute("resumen");
    Integer mes = (Integer) request.getAttribute("mes");
    Integer anio = (Integer) request.getAttribute("anio");
    
    // Manejar mensajes desde sesión en lugar de parámetros URL
    String mensaje = (String) session.getAttribute("mensaje");
    String error = (String) session.getAttribute("error");
    
    // Limpiar mensajes de sesión después de usarlos
    if (mensaje != null) {
        session.removeAttribute("mensaje");
    }
    if (error != null) {
        session.removeAttribute("error");
    }

    if (mes == null) {
        mes = java.time.LocalDate.now().getMonthValue();
    }
    if (anio == null) {
        anio = java.time.LocalDate.now().getYear();
    }

    // Valores por defecto para el resumen
    int totalClases = 0, presentes = 0, tardanzas = 0, ausentes = 0, justificados = 0;
    double porcentajeAsistencia = 0.0;

    if (resumen != null && !resumen.isEmpty()) {
        totalClases = resumen.get("totalClases") != null ? (Integer) resumen.get("totalClases") : 0;
        presentes = resumen.get("presentes") != null ? (Integer) resumen.get("presentes") : 0;
        tardanzas = resumen.get("tardanzas") != null ? (Integer) resumen.get("tardanzas") : 0;
        ausentes = resumen.get("ausentes") != null ? (Integer) resumen.get("ausentes") : 0;
        justificados = resumen.get("justificados") != null ? (Integer) resumen.get("justificados") : 0;
        porcentajeAsistencia = resumen.get("porcentajeAsistencia") != null ? (Double) resumen.get("porcentajeAsistencia") : 0.0;
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <title>Asistencias de mi Hijo</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    </head>
    <body>
        <jsp:include page="header.jsp"/>

        <div class="container mt-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2><i class="bi bi-clipboard-check"></i> Asistencias de mi Hijo</h2>
                <a href="padreDashboard.jsp" class="btn btn-secondary">
                    <i class="bi bi-arrow-left"></i> Volver al Dashboard
                </a>
            </div>

            <% if (mensaje != null && !mensaje.isEmpty()) { %>
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="bi bi-check-circle"></i> <%= mensaje %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <% } %>

            <% if (error != null && !error.isEmpty()) { %>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="bi bi-exclamation-triangle"></i> <%= error %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <% } %>

            <!-- Resumen -->
            <div class="row mb-4">
                <div class="col-md-12">
                    <div class="card border-0 shadow-sm">
                        <div class="card-body">
                            <h5 class="card-title"><i class="bi bi-graph-up"></i> Resumen del Mes</h5>
                            <div class="row text-center">
                                <div class="col-md-3 mb-3">
                                    <div class="p-3 bg-success bg-opacity-10 rounded">
                                        <h3 class="text-success mb-0"><%= presentes %></h3>
                                        <small class="text-muted">Presentes</small>
                                    </div>
                                </div>
                                <div class="col-md-3 mb-3">
                                    <div class="p-3 bg-warning bg-opacity-10 rounded">
                                        <h3 class="text-warning mb-0"><%= tardanzas %></h3>
                                        <small class="text-muted">Tardanzas</small>
                                    </div>
                                </div>
                                <div class="col-md-3 mb-3">
                                    <div class="p-3 bg-danger bg-opacity-10 rounded">
                                        <h3 class="text-danger mb-0"><%= ausentes %></h3>
                                        <small class="text-muted">Ausentes</small>
                                    </div>
                                </div>
                                <div class="col-md-3 mb-3">
                                    <div class="p-3 bg-info bg-opacity-10 rounded">
                                        <h3 class="text-info mb-0"><%= justificados %></h3>
                                        <small class="text-muted">Justificados</small>
                                    </div>
                                </div>
                            </div>

                            <%
                                String progressClass = "bg-success";
                                if (porcentajeAsistencia < 75)
                                    progressClass = "bg-danger";
                                else if (porcentajeAsistencia < 90)
                                    progressClass = "bg-warning";
                            %>
                            <div class="mt-3">
                                <div class="d-flex justify-content-between mb-1">
                                    <span>Porcentaje de Asistencia (<%= totalClases %> clases totales)</span>
                                    <span><strong><%= String.format("%.1f", porcentajeAsistencia) %>%</strong></span>
                                </div>
                                <div class="progress" style="height: 20px;">
                                    <div class="progress-bar <%= progressClass %>" role="progressbar" 
                                         style="width: <%= porcentajeAsistencia %>%;" 
                                         aria-valuenow="<%= porcentajeAsistencia %>" aria-valuemin="0" aria-valuemax="100">
                                        <%= String.format("%.1f", porcentajeAsistencia) %>%
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Filtros -->
            <div class="card mb-4">
                <div class="card-body">
                    <form method="get" action="AsistenciaServlet" class="row g-3">
                        <input type="hidden" name="accion" value="verPadre">

                        <div class="col-md-3">
                            <label for="mes" class="form-label">Mes</label>
                            <select class="form-select" id="mes" name="mes">
                                <%
                                    String[] meses = {"Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
                                        "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"};
                                    for (int i = 1; i <= 12; i++) {
                                %>
                                <option value="<%= i %>" <%= i == mes ? "selected" : "" %>>
                                    <%= meses[i - 1] %>
                                </option>
                                <% } %>
                            </select>
                        </div>

                        <div class="col-md-3">
                            <label for="anio" class="form-label">Año</label>
                            <select class="form-select" id="anio" name="anio">
                                <% for (int i = anio - 1; i <= anio + 1; i++) { %>
                                <option value="<%= i %>" <%= i == anio ? "selected" : "" %>>
                                    <%= i %>
                                </option>
                                <% } %>
                            </select>
                        </div>

                        <div class="col-md-3">
                            <label class="form-label">&nbsp;</label>
                            <button type="submit" class="btn btn-primary w-100">
                                <i class="bi bi-funnel"></i> Filtrar
                            </button>
                        </div>

                        <div class="col-md-3">
                            <label class="form-label">&nbsp;</label>
                            <a href="JustificacionServlet?accion=form" class="btn btn-warning w-100">
                                <i class="bi bi-pencil-square"></i> Justificar Ausencia
                            </a>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Lista de asistencias -->
            <div class="card">
                <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center">
                    <h5 class="mb-0"><i class="bi bi-list-check"></i> Detalle de Asistencias</h5>
                    <span class="badge bg-light text-dark"><%= asistencias != null ? asistencias.size() : 0 %> registros</span>
                </div>
                <div class="card-body">
                    <% if (asistencias != null && !asistencias.isEmpty()) { %>
                    <div class="table-responsive">
                        <table class="table table-striped table-hover">
                            <thead class="table-dark">
                                <tr>
                                    <th>Fecha</th>
                                    <th>Curso</th>
                                    <th>Grado</th>
                                    <th>Estado</th>
                                    <th>Hora</th>
                                    <th>Observaciones</th>
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
                                    <td><%= a.getFecha() %></td>
                                    <td><%= a.getCursoNombre() != null ? a.getCursoNombre() : "N/A" %></td>
                                    <td><%= a.getGradoNombre() != null ? a.getGradoNombre() : "N/A" %></td>
                                    <td>
                                        <span class="badge <%= estadoBadge %>">
                                            <i class="bi <%= estadoIcon %>"></i> <%= a.getEstado() %>
                                        </span>
                                    </td>
                                    <td><%= a.getHoraClase() != null ? a.getHoraClase() : "N/A" %></td>
                                    <td>
                                        <% if (a.getObservaciones() != null && !a.getObservaciones().isEmpty()) { %>
                                        <button type="button" class="btn btn-sm btn-outline-secondary" 
                                                data-bs-toggle="tooltip" 
                                                title="<%= a.getObservaciones() %>">
                                            <i class="bi bi-eye"></i>
                                        </button>
                                        <% } else { %>
                                        <span class="text-muted">-</span>
                                        <% } %>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                    <% } else { %>
                    <div class="text-center py-4">
                        <div class="text-muted">
                            <i class="bi bi-calendar-x" style="font-size: 3rem;"></i>
                            <h5 class="mt-3">No hay asistencias registradas</h5>
                            <p>No se encontraron registros de asistencia para el período seleccionado.</p>
                        </div>
                    </div>
                    <% } %>
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