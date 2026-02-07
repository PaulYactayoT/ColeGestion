<%@page import="java.util.List"%>
<%@page import="modelo.Disponibilidad"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    List<Disponibilidad> lista = (List<Disponibilidad>) request.getAttribute("listaHorarios");
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
            .card { border: none; border-radius: 12px; }
            .card-header { border-radius: 12px 12px 0 0 !important; font-weight: 600; }
            .btn { border-radius: 8px; transition: all 0.3s; }
            .btn:hover { transform: translateY(-1px); box-shadow: 0 4px 8px rgba(0,0,0,0.1); }
            .table thead { background-color: #f8f9fa; }
            .badge { padding: 0.6em 1em; border-radius: 50px; }
            .navbar-brand img { max-height: 40px; }
            .link-motivo { font-size: 0.85em; cursor: pointer; text-decoration: underline; }
        </style>
        
        <script>
            function verMotivo(motivo) {
                if(!motivo || motivo === 'null' || motivo.trim() === '') {
                    alert("No se especificó un motivo detallado.");
                } else {
                    alert("🛑 MOTIVO DEL RECHAZO:\n\n" + motivo);
                }
            }

            function editar(id, dia, turnoId, inicio, fin) {
                document.getElementById("idDisponibilidad").value = id;
                document.getElementById("cboDia").value = dia;
                document.getElementById("cboTurno").value = turnoId;
                document.getElementById("txtInicio").value = inicio;
                document.getElementById("txtFin").value = fin;
                document.getElementById("accion").value = "actualizar"; 

                let btn = document.getElementById("btnGuardar");
                btn.innerHTML = "<i class='bi bi-pencil-square me-2'></i>Corregir y Guardar";
                btn.classList.remove("btn-primary");
                btn.classList.add("btn-warning");
                
                window.scrollTo({ top: 0, behavior: 'smooth' });
                alert("MODO EDICIÓN ACTIVADO:\nCorrige los datos en el formulario superior y guarda para re-enviar la solicitud.");
            }
        </script>
    </head>
    <body class="bg-light">

        <nav class="navbar navbar-light bg-white shadow-sm mb-4">
            <div class="container">
                <a class="navbar-brand fw-bold text-primary" href="docenteDashboard.jsp">
                    <i class="bi bi-mortarboard-fill me-2"></i>COLEGIO SA
                </a>
                <div class="ms-auto">
                    <a href="docenteDashboard.jsp" class="btn btn-outline-primary border-2">
                        <i class="bi bi-house-door-fill"></i>
                    </a>
                </div>
            </div>
        </nav>
        
        <div class="container py-3">
            <div class="row mb-4">
                <div class="col-12">
                    <div class="d-flex align-items-center">
                        <div class="bg-primary text-white p-3 rounded-3 me-3">
                            <i class="bi bi-calendar-check fs-3"></i>
                        </div>
                        <div>
                            <h2 class="fw-bold mb-0 text-dark">Mi Disponibilidad</h2>
                            <p class="text-muted mb-0">Organiza tus horarios para el presente ciclo académico</p>
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
                    <div class="card shadow-sm h-100">
                        <div class="card-header bg-white py-3">
                            <i class="bi bi-plus-circle me-2 text-primary"></i>Registrar / Editar Horario
                        </div>
                        <div class="card-body">
                            <form action="DisponibilidadServlet" method="POST">
                                <input type="hidden" name="accion" id="accion" value="guardar">
                                <input type="hidden" name="id" id="idDisponibilidad"> 
                                
                                <div class="mb-3">
                                    <label class="form-label fw-bold text-secondary small text-uppercase">Día de la Semana</label>
                                    <select name="cboDia" id="cboDia" class="form-select border-2" required>
                                        <option value="">Seleccione...</option>
                                        <option value="LUNES">Lunes</option>
                                        <option value="MARTES">Martes</option>
                                        <option value="MIERCOLES">Miércoles</option>
                                        <option value="JUEVES">Jueves</option>
                                        <option value="VIERNES">Viernes</option>
                                    </select>
                                </div>
                                
                                <div class="mb-3">
                                    <label class="form-label fw-bold text-secondary small text-uppercase">Turno</label>
                                    <select name="cboTurno" id="cboTurno" class="form-select border-2" required>
                                        <option value="">Seleccione...</option>
                                        <option value="1"> Mañana </option>
                                        <option value="2"> Tarde </option>
                                    </select>
                                </div>

                                <div class="row">
                                    <div class="col-6 mb-3">
                                        <label class="form-label fw-bold text-secondary small text-uppercase">Hora Inicio</label>
                                        <input type="time" name="txtInicio" id="txtInicio" class="form-control border-2" required>
                                    </div>
                                    <div class="col-6 mb-3">
                                        <label class="form-label fw-bold text-secondary small text-uppercase">Hora Fin</label>
                                        <input type="time" name="txtFin" id="txtFin" class="form-control border-2" required>
                                    </div>
                                </div>

                                <div class="d-grid mt-2">
                                    <button type="submit" id="btnGuardar" class="btn btn-primary py-2">
                                        <i class="bi bi-save me-2"></i>Guardar Disponibilidad
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>

                <div class="col-lg-8">
                    <div class="card shadow-sm h-100">
                        <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
                            <span><i class="bi bi-table me-2 text-primary"></i>Mis Horarios Registrados</span>
                            <span class="badge bg-light text-dark border"><%= (lista != null) ? lista.size() : 0 %> Registros</span>
                        </div>
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table table-hover align-middle mb-0">
                                    <thead class="text-secondary small text-uppercase">
                                        <tr>
                                            <th class="ps-4">Día</th>
                                            <th>Turno</th>
                                            <th>Horario</th>
                                            <th>Estado</th>
                                            <th class="text-center">Acciones</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% 
                                        if (lista != null && !lista.isEmpty()) {
                                            for (Disponibilidad d : lista) { 
                                                boolean esRechazado = "RECHAZADO".equals(d.getEstado());
                                                boolean esAprobado = "APROBADO".equals(d.getEstado());
                                                boolean esPendiente = "PENDIENTE".equals(d.getEstado());
                                        %>
                                            <tr>
                                                <td class="ps-4 fw-bold text-dark"><%= d.getDiaSemana() %></td>
                                                <td><span class="text-muted"><%= d.getTurnoNombre() %></span></td>
                                                <td>
                                                    <div class="d-flex align-items-center">
                                                        <i class="bi bi-alarm me-2 text-primary"></i>
                                                        <%= d.getHoraInicio() %> - <%= d.getHoraFin() %>
                                                    </div>
                                                </td>
                                                <td>
                                                    <% if (esAprobado) { %>
                                                        <span class="badge bg-success d-inline-flex align-items-center">
                                                            <i class="bi bi-check-circle me-1"></i>APROBADO
                                                        </span>
                                                    <% } else if (esRechazado) { %>
                                                        <div class="d-flex flex-column align-items-start">
                                                            <span class="badge bg-danger mb-1">
                                                                <i class="bi bi-x-circle me-1"></i>RECHAZADO
                                                            </span>
                                                            <span class="link-motivo text-danger" onclick="verMotivo('<%= d.getObservaciones() %>')">
                                                                <i class="bi bi-info-circle-fill"></i> Ver motivo
                                                            </span>
                                                        </div>
                                                    <% } else { %>
                                                        <span class="badge bg-warning text-dark d-inline-flex align-items-center">
                                                            <i class="bi bi-clock-history me-1"></i>PENDIENTE
                                                        </span>
                                                    <% } %>
                                                </td>
                                                
                                                <td class="text-center">
                                                    <% if (esAprobado) { %>
                                                        <span class="badge bg-light text-muted border">
                                                            <i class="bi bi-lock-fill me-1"></i>Finalizado
                                                        </span>
                                                    <% } else { %>
                                                        <div class="btn-group">
                                                            
                                                            <button type="button" 
                                                                    class="btn btn-sm <%= esRechazado ? "btn-outline-primary" : "btn-secondary" %>" 
                                                                    title="<%= esRechazado ? "Corregir" : "En revisión (No editable)" %>"
                                                                    <%= !esRechazado ? "disabled" : "" %>
                                                                    onclick="editar(<%= d.getId() %>, '<%= d.getDiaSemana() %>', <%= d.getTurnoId() %>, '<%= d.getHoraInicio() %>', '<%= d.getHoraFin() %>')">
                                                                <i class="bi bi-pencil"></i>
                                                            </button>
                                                            
                                                            <a href="DisponibilidadServlet?accion=eliminar&id=<%= d.getId() %>" 
                                                               class="btn btn-sm btn-outline-danger" 
                                                               onclick="return confirm('¿Estás seguro de cancelar esta solicitud?');"
                                                               title="Eliminar / Cancelar">
                                                                <i class="bi bi-trash"></i>
                                                            </a>
                                                        </div>
                                                        
                                                        <% if(esPendiente) { %>
                                                            <small class="d-block text-muted mt-1" style="font-size: 0.7em;">Solo cancelar</small>
                                                        <% } %>
                                                    <% } %>
                                                </td>
                                            </tr>
                                        <% 
                                            } 
                                        } else { 
                                        %>
                                            <tr>
                                                <td colspan="5" class="text-center py-5 text-muted">
                                                    <i class="bi bi-info-circle fs-2 d-block mb-2"></i>
                                                    No tienes horarios registrados aún.
                                                </td>
                                            </tr>
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