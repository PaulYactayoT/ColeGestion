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
        <title>Mis Justificaciones</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    </head>
    <body>
        <jsp:include page="header.jsp"/>

        <div class="container mt-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2><i class="bi bi-list-check"></i> Mis Justificaciones</h2>
                <div>
                    <a href="JustificacionServlet?accion=form" class="btn btn-primary me-2">
                        <i class="bi bi-plus-circle"></i> Nueva Justificación
                    </a>
                    <a href="asistenciasPadre.jsp" class="btn btn-secondary">
                        <i class="bi bi-arrow-left"></i> Volver a Asistencias
                    </a>
                </div>
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

            <div class="card">
                <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center">
                    <h5 class="mb-0">
                        <i class="bi bi-list-check"></i> Historial de Justificaciones
                    </h5>
                    <span class="badge bg-light text-dark"><%= justificaciones.size()%> justificaciones</span>
                </div>
                <div class="card-body">
                    <% if (!justificaciones.isEmpty()) { %>
                    <div class="table-responsive">
                        <table class="table table-striped table-hover">
                            <thead class="table-dark">
                                <tr>
                                    <th>Fecha Envío</th>
                                    <th>Curso</th>
                                    <th>Fecha Ausencia</th>
                                    <th>Tipo</th>
                                    <th>Estado</th>
                                    <th>Respuesta</th>
                                    <th>Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Justificacion j : justificaciones) {
                                        String estadoBadge = "";
                                        String estadoIcon = "";
                                        switch (j.getEstado() != null ? j.getEstado() : "PENDIENTE") {
                                            case "PENDIENTE":
                                                estadoBadge = "bg-warning";
                                                estadoIcon = "bi-clock";
                                                break;
                                            case "APROBADO":
                                                estadoBadge = "bg-success";
                                                estadoIcon = "bi-check-circle";
                                                break;
                                            case "RECHAZADO":
                                                estadoBadge = "bg-danger";
                                                estadoIcon = "bi-x-circle";
                                                break;
                                            default:
                                                estadoBadge = "bg-secondary";
                                                estadoIcon = "bi-question-circle";
                                        }
                                %>
                                <tr>
                                    <td>
                                        <small>
                                            <% if (j.getFechaJustificacion() != null) {%>
                                            <%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(j.getFechaJustificacion())%><br>
                                            <span class="text-muted"><%= new java.text.SimpleDateFormat("HH:mm").format(j.getFechaJustificacion())%></span>
                                            <% } else { %>
                                            N/A
                                            <% }%>
                                        </small>
                                    </td>
                                    <td><%= j.getCursoNombre() != null ? j.getCursoNombre() : "N/A"%></td>
                                    <td>
                                        <small>
                                            <strong><%= j.getFecha() != null ? j.getFecha() : "N/A"%></strong><br>
                                            <%= j.getHoraClase() != null ? j.getHoraClase() : ""%>
                                        </small>
                                    </td>
                                    <td>
                                        <span class="badge bg-info"><%= j.getTipoJustificacion() != null ? j.getTipoJustificacion() : "N/A"%></span>
                                    </td>
                                    <td>
                                        <span class="badge <%= estadoBadge%>">
                                            <i class="bi <%= estadoIcon%>"></i> <%= j.getEstado() != null ? j.getEstado() : "PENDIENTE"%>
                                        </span>
                                    </td>
                                    <td>
                                        <% if (j.getObservacionesAprobacion() != null && !j.getObservacionesAprobacion().isEmpty()) {%>
                                        <button type="button" class="btn btn-sm btn-outline-secondary" 
                                                data-bs-toggle="modal" 
                                                data-bs-target="#respuestaModal<%= j.getId()%>">
                                            <i class="bi bi-eye"></i> Ver
                                        </button>
                                        <% } else { %>
                                        <span class="text-muted">-</span>
                                        <% }%>
                                    </td>
                                    <td>
                                        <button type="button" class="btn btn-sm btn-outline-primary" 
                                                data-bs-toggle="modal" 
                                                data-bs-target="#detalleModal<%= j.getId()%>">
                                            <i class="bi bi-eye"></i> Detalles
                                        </button>

                                        <!-- Modal de detalles -->
                                        <div class="modal fade" id="detalleModal<%= j.getId()%>" tabindex="-1">
                                            <div class="modal-dialog modal-lg">
                                                <div class="modal-content">
                                                    <div class="modal-header">
                                                        <h5 class="modal-title">Detalles de Justificación</h5>
                                                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                    </div>
                                                    <div class="modal-body">
                                                        <div class="row">
                                                            <div class="col-md-6">
                                                                <strong>Alumno:</strong> <%= j.getAlumnoNombre() != null ? j.getAlumnoNombre() : "N/A"%><br>
                                                                <strong>Curso:</strong> <%= j.getCursoNombre() != null ? j.getCursoNombre() : "N/A"%><br>
                                                                <strong>Fecha de Ausencia:</strong> <%= j.getFecha() != null ? j.getFecha() : "N/A"%> 
                                                                <%= j.getHoraClase() != null ? j.getHoraClase() : ""%>
                                                            </div>
                                                            <div class="col-md-6">
                                                                <strong>Tipo:</strong> <%= j.getTipoJustificacion() != null ? j.getTipoJustificacion() : "N/A"%><br>
                                                                <strong>Estado:</strong> 
                                                                <span class="badge <%= estadoBadge%>"><%= j.getEstado() != null ? j.getEstado() : "PENDIENTE"%></span><br>
                                                                <strong>Fecha Envío:</strong> 
                                                                <% if (j.getFechaJustificacion() != null) {%>
                                                                <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(j.getFechaJustificacion())%>
                                                                <% } else { %>
                                                                N/A
                                                                <% }%>
                                                            </div>
                                                        </div>
                                                        <hr>
                                                        <div class="mb-3">
                                                            <strong>Descripción:</strong>
                                                            <p class="mt-2 p-3 bg-light rounded"><%= j.getDescripcion() != null ? j.getDescripcion() : "Sin descripción"%></p>
                                                        </div>
                                                        <% if (j.getDocumentoAdjunto() != null && !j.getDocumentoAdjunto().isEmpty()) {%>
                                                        <div class="mb-3">
                                                            <strong>Documento Adjunto:</strong>
                                                            <a href="<%= j.getDocumentoAdjunto()%>" target="_blank" class="btn btn-sm btn-outline-primary">
                                                                <i class="bi bi-download"></i> Descargar Documento
                                                            </a>
                                                        </div>
                                                        <% } %>
                                                    </div>
                                                    <div class="modal-footer">
                                                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Modal de respuesta -->
                                        <% if (j.getObservacionesAprobacion() != null && !j.getObservacionesAprobacion().isEmpty()) {%>
                                        <div class="modal fade" id="respuestaModal<%= j.getId()%>" tabindex="-1">
                                            <div class="modal-dialog">
                                                <div class="modal-content">
                                                    <div class="modal-header">
                                                        <h5 class="modal-title">Respuesta del Docente</h5>
                                                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                    </div>
                                                    <div class="modal-body">
                                                        <p><%= j.getObservacionesAprobacion()%></p>
                                                        <% if (j.getFechaAprobacion() != null) {%>
                                                        <small class="text-muted">
                                                            Fecha de respuesta: <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(j.getFechaAprobacion())%>
                                                        </small>
                                                        <% } %>
                                                    </div>
                                                    <div class="modal-footer">
                                                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cerrar</button>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
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
                            <i class="bi bi-inbox" style="font-size: 3rem;"></i>
                            <h5 class="mt-3">No hay justificaciones enviadas</h5>
                            <p>No has enviado ninguna justificación hasta el momento.</p>
                            <a href="JustificacionServlet?accion=form" class="btn btn-primary me-2">
                                <i class="bi bi-plus-circle"></i> Nueva Justificación
                            </a>
                        </div>
                    </div>
                    <% }%>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>