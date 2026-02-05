<%@page import="java.util.List"%>
<%@page import="modelo.Disponibilidad"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    List<Disponibilidad> lista = (List<Disponibilidad>) request.getAttribute("listaHorarios");
    // Recuperamos el objeto si estamos en modo edición
    Disponibilidad edit = (Disponibilidad) request.getAttribute("disponibilidadEditar");
    
    String mensaje = (String) request.getAttribute("mensaje");
    String tipoMensaje = (String) request.getAttribute("tipoMensaje");
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Disponibilidad Docente | Colegio SA</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css">
        <style>
            :root { --primary-color: #0d6efd; --secondary-bg: #f8f9fa; }
            body { background-color: var(--secondary-bg); font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
            .card { border: none; border-radius: 15px; box-shadow: 0 5px 15px rgba(0,0,0,0.05); }
            .card-header { border-radius: 15px 15px 0 0 !important; background-color: #fff; border-bottom: 1px solid #edf2f9; font-weight: 600; }
            .form-select, .form-control { border-radius: 8px; padding: 10px; }
        </style>
    </head>
    <body>

        <nav class="navbar navbar-expand-lg navbar-dark bg-primary shadow-sm mb-4">
            <div class="container">
                <a class="navbar-brand fw-bold" href="DocenteDashboardServlet">
                    <i class="bi bi-mortarboard-fill me-2"></i>Colegio SA
                </a>
                <div class="navbar-nav ms-auto">
                    <a class="nav-link text-white" href="DocenteDashboardServlet">
                        <i class="bi bi-house-door-fill me-1"></i> Inicio
                    </a>
                </div>
            </div>
        </nav>
        
        <div class="container pb-5">
            <div class="row mb-4 align-items-center">
                <div class="col-12">
                    <div class="d-flex align-items-center">
                        <div class="bg-white p-3 rounded-circle shadow-sm me-3 text-primary">
                            <i class="bi bi-calendar2-week fs-3"></i>
                        </div>
                        <div>
                            <h2 class="fw-bold mb-0">Mi Disponibilidad Horaria</h2>
                            <p class="text-muted mb-0">Gestiona tus tiempos de enseñanza</p>
                        </div>
                    </div>
                </div>
            </div>

            <% if (mensaje != null) { %>
                <div class="alert alert-<%= tipoMensaje %> alert-dismissible fade show border-0 shadow-sm mb-4" role="alert">
                    <i class="bi <%= tipoMensaje.equals("success") ? "bi-check-circle-fill" : "bi-exclamation-triangle-fill" %> me-2"></i>
                    <%= mensaje %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            <% } %>

            <div class="row g-4">
                <div class="col-lg-4">
                    <div class="card h-100">
                        <div class="card-header py-3">
                            <i class="bi <%= (edit != null) ? "bi-pencil-square" : "bi-plus-lg" %> me-2 text-primary"></i>
                            <%= (edit != null) ? "Editar Horario" : "Registrar Horario" %>
                        </div>
                        <div class="card-body">
                            <form action="DisponibilidadServlet" method="POST">
                                <input type="hidden" name="accion" value="<%= (edit != null) ? "actualizar" : "guardar" %>">
                                <input type="hidden" name="id" value="<%= (edit != null) ? edit.getId() : "0" %>">
                                
                                <div class="mb-3">
                                    <label class="form-label small fw-bold text-uppercase">Día</label>
                                    <select name="cboDia" class="form-select" required>
                                        <option value="">Seleccione...</option>
                                        <% String dSel = (edit != null) ? edit.getDiaSemana() : ""; %>
                                        <option value="LUNES" <%= dSel.equals("LUNES") ? "selected" : "" %>>Lunes</option>
                                        <option value="MARTES" <%= dSel.equals("MARTES") ? "selected" : "" %>>Martes</option>
                                        <option value="MIERCOLES" <%= dSel.equals("MIERCOLES") ? "selected" : "" %>>Miércoles</option>
                                        <option value="JUEVES" <%= dSel.equals("JUEVES") ? "selected" : "" %>>Jueves</option>
                                        <option value="VIERNES" <%= dSel.equals("VIERNES") ? "selected" : "" %>>Viernes</option>
                                    </select>
                                </div>
                                
                                <div class="mb-3">
                                    <label class="form-label small fw-bold text-uppercase">Turno Sugerido</label>
                                    <select name="cboTurno" class="form-select" required>
                                        <option value="">Seleccione...</option>
                                        <% int tId = (edit != null) ? edit.getTurnoId() : 0; %>
                                        <option value="1" <%= (tId == 1) ? "selected" : "" %>>Mañana (08:00 - 13:00)</option>
                                        <option value="2" <%= (tId == 2) ? "selected" : "" %>>Tarde (13:00 - 18:00)</option>
                                    </select>
                                </div>

                                <div class="row">
                                    <div class="col-6 mb-3">
                                        <label class="form-label small fw-bold text-uppercase">Inicio</label>
                                        <input type="time" name="txtInicio" class="form-control" required
                                               value="<%= (edit != null) ? edit.getHoraInicio() : "" %>">
                                    </div>
                                    <div class="col-6 mb-3">
                                        <label class="form-label small fw-bold text-uppercase">Fin</label>
                                        <input type="time" name="txtFin" class="form-control" required
                                               value="<%= (edit != null) ? edit.getHoraFin() : "" %>">
                                    </div>
                                </div>

                                <div class="d-grid gap-2 mt-2">
                                    <button type="submit" class="btn <%= (edit != null) ? "btn-warning" : "btn-primary" %> py-2 shadow-sm">
                                        <i class="bi <%= (edit != null) ? "bi-arrow-repeat" : "bi-check-lg" %> me-2"></i>
                                        <%= (edit != null) ? "Actualizar" : "Confirmar" %>
                                    </button>
                                    <% if(edit != null) { %>
                                        <a href="DisponibilidadServlet" class="btn btn-outline-secondary py-1">Cancelar</a>
                                    <% } %>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>

                <div class="col-lg-8">
                    <div class="card h-100">
                        <div class="card-header py-3 d-flex justify-content-between align-items-center">
                            <span><i class="bi bi-list-stars me-2 text-primary"></i>Lista de Horarios</span>
                        </div>
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table table-hover align-middle mb-0">
                                    <thead class="table-light">
                                        <tr class="small text-uppercase text-muted">
                                            <th class="ps-4">Día</th>
                                            <th>Turno</th>
                                            <th>Horario</th>
                                            <th>Estado</th>
                                            <th class="text-center">Acción</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% if (lista != null && !lista.isEmpty()) {
                                            for (Disponibilidad d : lista) { 
                                                String badgeClass = "bg-warning"; 
                                                if ("APROBADO".equals(d.getEstado())) badgeClass = "bg-success";
                                                if ("RECHAZADO".equals(d.getEstado())) badgeClass = "bg-danger";
                                        %>
                                            <tr>
                                                <td class="ps-4 fw-bold"><%= d.getDiaSemana() %></td>
                                                <td class="text-muted"><%= d.getTurnoNombre() %></td>
                                                <td>
                                                    <span class="badge bg-light text-dark border">
                                                        <%= d.getHoraInicio() %> - <%= d.getHoraFin() %>
                                                    </span>
                                                </td>
                                                <td><span class="badge <%= badgeClass %>"><%= d.getEstado() %></span></td>
                                                <td class="text-center">
                                                    <% if (!"APROBADO".equals(d.getEstado())) { %>
                                                        <a href="DisponibilidadServlet?accion=editar&id=<%= d.getId() %>" class="btn btn-link text-primary p-0 me-2" title="Editar">
                                                            <i class="bi bi-pencil-square fs-5"></i>
                                                        </a>
                                                        <a href="DisponibilidadServlet?accion=eliminar&id=<%= d.getId() %>" class="btn btn-link text-danger p-0" onclick="return confirm('¿Eliminar?');">
                                                            <i class="bi bi-trash-fill fs-5"></i>
                                                        </a>
                                                    <% } else { %>
                                                        <i class="bi bi-lock-fill text-muted"></i>
                                                    <% } %>
                                                </td>
                                            </tr>
                                        <% } } else { %>
                                            <tr><td colspan="5" class="text-center py-5">No hay registros.</td></tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>