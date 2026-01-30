<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Justificacion, java.util.List" %>
<%
    List<Justificacion> justificaciones = (List<Justificacion>) request.getAttribute("justificaciones");
    String mensaje = (String) request.getParameter("mensaje");
    String error = (String) request.getParameter("error");
    
    if (justificaciones == null) {
        justificaciones = new java.util.ArrayList<>();
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Justificaciones Pendientes</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
</head>
<body>
    <jsp:include page="header.jsp"/>

    <div class="container mt-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2><i class="bi bi-clock-history"></i> Justificaciones Pendientes</h2>
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

        <div class="card">
            <div class="card-header bg-warning text-dark d-flex justify-content-between align-items-center">
                <h5 class="mb-0">
                    <i class="bi bi-clock-history"></i> Justificaciones por Revisar
                </h5>
                <span class="badge bg-danger"><%= justificaciones.size() %> pendientes</span>
            </div>
            <div class="card-body">
                <% if (!justificaciones.isEmpty()) { %>
                    <div class="table-responsive">
                        <table class="table table-striped table-hover">
                            <thead class="table-dark">
                                <tr>
                                    <th>Alumno</th>
                                    <th>Curso</th>
                                    <th>Fecha Ausencia</th>
                                    <th>Tipo</th>
                                    <th>Descripción</th>
                                    <th>Enviado por</th>
                                    <th>Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Justificacion j : justificaciones) { %>
                                <tr>
                                    <td><%= j.getAlumnoNombre() != null ? j.getAlumnoNombre() : "N/A" %></td>
                                    <td><%= j.getCursoNombre() != null ? j.getCursoNombre() : "N/A" %></td>
                                    <td>
                                        <small>
                                            <strong><%= j.getFecha() != null ? j.getFecha() : "N/A" %></strong><br>
                                            <%= j.getHoraClase() != null ? j.getHoraClase() : "" %>
                                        </small>
                                    </td>
                                    <td>
                                        <span class="badge bg-info"><%= j.getTipoJustificacion() %></span>
                                    </td>
                                    <td>
                                        <% if (j.getDescripcion() != null && !j.getDescripcion().isEmpty()) { %>
                                            <button type="button" class="btn btn-sm btn-outline-primary" 
                                                    data-bs-toggle="modal" 
                                                    data-bs-target="#descModal<%= j.getId() %>">
                                                <i class="bi bi-eye"></i> Ver
                                            </button>
                                            
                                            <!-- Modal para descripción -->
                                            <div class="modal fade" id="descModal<%= j.getId() %>" tabindex="-1">
                                                <div class="modal-dialog">
                                                    <div class="modal-content">
                                                        <div class="modal-header">
                                                            <h5 class="modal-title">Descripción de la Justificación</h5>
                                                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                        </div>
                                                        <div class="modal-body">
                                                            <p><%= j.getDescripcion() %></p>
                                                            <% if (j.getDocumentoAdjunto() != null && !j.getDocumentoAdjunto().isEmpty()) { %>
                                                                <div class="mt-3">
                                                                    <strong>Documento adjunto:</strong> 
                                                                    <a href="<%= j.getDocumentoAdjunto() %>" target="_blank" class="btn btn-sm btn-outline-secondary">
                                                                        <i class="bi bi-download"></i> Descargar
                                                                    </a>
                                                                </div>
                                                            <% } %>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        <% } else { %>
                                            <span class="text-muted">Sin descripción</span>
                                        <% } %>
                                    </td>
                                    <td><%= j.getPadreNombre() != null ? j.getPadreNombre() : "N/A" %></td>
                                    <td>
                                        <div class="btn-group btn-group-sm" role="group">
                                            <form method="post" action="JustificacionServlet" class="d-inline">
                                                <input type="hidden" name="accion" value="aprobar">
                                                <input type="hidden" name="id" value="<%= j.getId() %>">
                                                <button type="submit" class="btn btn-success" 
                                                        onclick="return confirm('¿Está seguro de aprobar esta justificación?')">
                                                    <i class="bi bi-check-lg"></i> Aprobar
                                                </button>
                                            </form>
                                            <button type="button" class="btn btn-danger" 
                                                    data-bs-toggle="modal" 
                                                    data-bs-target="#rechazarModal<%= j.getId() %>">
                                                <i class="bi bi-x-lg"></i> Rechazar
                                            </button>
                                        </div>

                                        <!-- Modal para rechazar -->
                                        <div class="modal fade" id="rechazarModal<%= j.getId() %>" tabindex="-1">
                                            <div class="modal-dialog">
                                                <div class="modal-content">
                                                    <div class="modal-header">
                                                        <h5 class="modal-title">Rechazar Justificación</h5>
                                                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                    </div>
                                                    <form method="post" action="JustificacionServlet">
                                                        <input type="hidden" name="accion" value="rechazar">
                                                        <input type="hidden" name="id" value="<%= j.getId() %>">
                                                        <div class="modal-body">
                                                            <div class="mb-3">
                                                                <label for="observaciones<%= j.getId() %>" class="form-label">
                                                                    Motivo del rechazo *
                                                                </label>
                                                                <textarea class="form-control" id="observaciones<%= j.getId() %>" 
                                                                          name="observaciones" rows="3" required
                                                                          placeholder="Explique por qué rechaza esta justificación..."></textarea>
                                                                <div class="form-text">Esta observación será visible para el padre de familia.</div>
                                                            </div>
                                                        </div>
                                                        <div class="modal-footer">
                                                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                                                            <button type="submit" class="btn btn-danger">Confirmar Rechazo</button>
                                                        </div>
                                                    </form>
                                                </div>
                                            </div>
                                        </div>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                <% } else { %>
                    <div class="text-center py-4">
                        <div class="text-muted">
                            <i class="bi bi-check-circle" style="font-size: 3rem;"></i>
                            <h5 class="mt-3">No hay justificaciones pendientes</h5>
                            <p>Todas las justificaciones han sido revisadas.</p>
                        </div>
                    </div>
                <% } %>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>