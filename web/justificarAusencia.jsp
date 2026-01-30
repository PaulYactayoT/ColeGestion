<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Asistencia, java.util.List" %>
<%
    List<Asistencia> ausencias = (List<Asistencia>) request.getAttribute("ausencias");
    // CORRECCIÓN: Cambiar String por Integer
    Integer alumnoId = (Integer) request.getAttribute("alumnoId");
    String error = (String) request.getAttribute("error");
    String mensaje = (String) request.getAttribute("mensaje");
    
    // Manejar errores de sesión también
    if (error == null) {
        error = (String) session.getAttribute("error");
        if (error != null) {
            session.removeAttribute("error");
        }
    }
    
    if (mensaje == null) {
        mensaje = (String) session.getAttribute("mensaje");
        if (mensaje != null) {
            session.removeAttribute("mensaje");
        }
    }
    
    if (ausencias == null) {
        ausencias = new java.util.ArrayList<>();
    }
    
    // CORRECCIÓN: Convertir alumnoId a String para el hidden input
    String alumnoIdStr = (alumnoId != null) ? String.valueOf(alumnoId) : "";
%>
<!DOCTYPE html>
<html>
<head>
    <title>Justificar Ausencia</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
</head>
<body>
    <jsp:include page="header.jsp"/>

    <div class="container mt-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2><i class="bi bi-pencil-square"></i> Justificar Ausencia</h2>
            <a href="asistenciasPadre.jsp" class="btn btn-secondary">
                <i class="bi bi-arrow-left"></i> Volver a Asistencias
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

        <div class="row">
            <div class="col-md-8">
                <div class="card">
                    <div class="card-body">
                        <form method="post" action="JustificacionServlet">
                            <input type="hidden" name="accion" value="crear">
                            <%-- CORRECCIÓN: Usar alumnoIdStr --%>
                            <input type="hidden" name="alumno_id" value="<%= alumnoIdStr %>">
                            
                            <div class="mb-3">
                                <label for="asistencia_id" class="form-label">Seleccione la ausencia a justificar *</label>
                                <select class="form-select" id="asistencia_id" name="asistencia_id" required>
                                    <option value="">Seleccione una fecha de ausencia</option>
                                    <% if (!ausencias.isEmpty()) {
                                        for (Asistencia a : ausencias) { 
                                            if ("AUSENTE".equals(a.getEstado())) { %>
                                            <option value="<%= a.getId() %>">
                                                <%= a.getFecha() %> - <%= a.getCursoNombre() != null ? a.getCursoNombre() : "Curso" %> 
                                                (<%= a.getHoraClase() != null ? a.getHoraClase() : "Hora" %>)
                                            </option>
                                        <% }
                                        }
                                    } else { %>
                                        <option value="">No hay ausencias pendientes de justificación</option>
                                    <% } %>
                                </select>
                                <div class="form-text">
                                    <% if (!ausencias.isEmpty()) { %>
                                        Se encontraron <%= ausencias.size() %> ausencias pendientes de justificación
                                    <% } else { %>
                                        No se encontraron ausencias recientes para justificar
                                    <% } %>
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <label for="tipo_justificacion" class="form-label">Tipo de Justificación *</label>
                                <select class="form-select" id="tipo_justificacion" name="tipo_justificacion" required>
                                    <option value="">Seleccione un tipo</option>
                                    <option value="ENFERMEDAD">Enfermedad</option>
                                    <option value="EMERGENCIA_FAMILIAR">Emergencia Familiar</option>
                                    <option value="CITA_MEDICA">Cita Médica</option>
                                    <option value="OTRO">Otro</option>
                                </select>
                            </div>
                            
                            <div class="mb-3">
                                <label for="descripcion" class="form-label">Descripción Detallada *</label>
                                <textarea class="form-control" id="descripcion" name="descripcion" 
                                          rows="4" placeholder="Describa el motivo de la ausencia de manera detallada..." 
                                          required></textarea>
                                <div class="form-text">Proporcione todos los detalles necesarios para la justificación.</div>
                            </div>
                            
                            <div class="alert alert-info">
                                <i class="bi bi-info-circle"></i>
                                <strong>Importante:</strong> Las justificaciones serán revisadas por el personal docente. 
                                Recibirá una notificación una vez que sea aprobada o rechazada.
                            </div>
                            
                            <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                                <button type="submit" class="btn btn-primary" id="btn-enviar" 
                                        <%= ausencias.isEmpty() ? "disabled" : "" %>>
                                    <i class="bi bi-send"></i> Enviar Justificación
                                </button>
                                <a href="asistenciasPadre.jsp" class="btn btn-secondary">Cancelar</a>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
            
            <div class="col-md-4">
                <div class="card">
                    <div class="card-header bg-info text-white">
                        <h6 class="mb-0"><i class="bi bi-question-circle"></i> Tipos de Justificación</h6>
                    </div>
                    <div class="card-body">
                        <div class="mb-3">
                            <h6 class="text-primary"><i class="bi bi-heart-pulse"></i> Enfermedad</h6>
                            <small class="text-muted">Incluye certificados médicos o justificativos de salud.</small>
                        </div>
                        <div class="mb-3">
                            <h6 class="text-primary"><i class="bi bi-people"></i> Emergencia Familiar</h6>
                            <small class="text-muted">Situaciones familiares urgentes que requieren la presencia del estudiante.</small>
                        </div>
                        <div class="mb-3">
                            <h6 class="text-primary"><i class="bi bi-calendar-check"></i> Cita Médica</h6>
                            <small class="text-muted">Consultas médicas programadas.</small>
                        </div>
                        <div class="mb-3">
                            <h6 class="text-primary"><i class="bi bi-three-dots"></i> Otro</h6>
                            <small class="text-muted">Otras situaciones justificadas.</small>
                        </div>
                    </div>
                </div>

                <div class="card mt-3">
                    <div class="card-header bg-warning text-dark">
                        <h6 class="mb-0"><i class="bi bi-exclamation-triangle"></i> Información Importante</h6>
                    </div>
                    <div class="card-body">
                        <ul class="small">
                            <li>Las justificaciones deben enviarse dentro de los 3 días hábiles siguientes a la ausencia.</li>
                            <li>Sin una justificación aprobada, la ausencia se mantendrá como "AUSENTE".</li>
                            <li>El docente puede solicitar información adicional si es necesario.</li>
                            <li>Puede ver el estado de sus justificaciones en el historial.</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        document.getElementById('asistencia_id').addEventListener('change', function() {
            const btnEnviar = document.getElementById('btn-enviar');
            btnEnviar.disabled = this.value === '';
        });

        // Validación inicial
        document.getElementById('btn-enviar').disabled = <%= ausencias.isEmpty() %>;
    </script>
</body>
</html>