<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, modelo.Curso, modelo.Grado, modelo.Profesor" %>

<%
    Curso curso = (Curso) request.getAttribute("curso");
    List<Grado> grados = (List<Grado>) request.getAttribute("grados");
    List<Profesor> profesores = (List<Profesor>) request.getAttribute("profesores");
    
    if (curso == null) {
        response.sendRedirect("CursoServlet?accion=listar");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Editar Curso</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
    <jsp:include page="header.jsp" />
    
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header bg-primary text-white">
                        <h4><i class="fas fa-edit"></i> Editar Curso</h4>
                    </div>
                    <div class="card-body">
                        
                        <!-- Mostrar mensajes -->
                        <% String error = (String) session.getAttribute("error");
                           if (error != null) { %>
                            <div class="alert alert-danger">
                                <%= error %>
                            </div>
                        <% session.removeAttribute("error");
                           } %>
                        
                        <!-- FORMULARIO DE EDICIÓN -->
                        <form action="CursoServlet" method="POST">
                            <!-- ID del curso (hidden) -->
                            <input type="hidden" name="id" value="<%= curso.getId() %>">
                            
                            <!-- Nombre del Curso -->
                            <div class="mb-3">
                                <label for="nombre" class="form-label">
                                    <i class="fas fa-book"></i> Nombre del Curso *
                                </label>
                                <input type="text" 
                                       class="form-control" 
                                       id="nombre" 
                                       name="nombre" 
                                       value="<%= curso.getNombre() %>" 
                                       required>
                            </div>
                            
                            <!-- Grado -->
                            <div class="mb-3">
                                <label for="grado_id" class="form-label">
                                    <i class="fas fa-graduation-cap"></i> Grado *
                                </label>
                                <select class="form-select" id="grado_id" name="grado_id" required>
                                    <option value="">-- Seleccione un grado --</option>
                                    <% if (grados != null) {
                                        for (Grado g : grados) { %>
                                        <option value="<%= g.getId() %>" 
                                                <%= (curso.getGradoId() == g.getId()) ? "selected" : "" %>>
                                            <%= g.getNombre() %> - <%= g.getNivel() %>
                                        </option>
                                    <% }
                                    } %>
                                </select>
                            </div>
                            
                            <!-- Profesor -->
                            <div class="mb-3">
                                <label for="profesor_id" class="form-label">
                                    <i class="fas fa-chalkboard-teacher"></i> Profesor *
                                </label>
                                <select class="form-select" id="profesor_id" name="profesor_id" required>
                                    <option value="">-- Seleccione un profesor --</option>
                                    <% if (profesores != null) {
                                        for (Profesor p : profesores) { %>
                                        <option value="<%= p.getId() %>" 
                                                <%= (curso.getProfesorId() == p.getId()) ? "selected" : "" %>>
                                            <%= p.getNombres() %> <%= p.getApellidos() %>
                                        </option>
                                    <% }
                                    } %>
                                </select>
                            </div>
                            
                            <!-- Área -->
                            <div class="mb-3">
                                <label for="area" class="form-label">
                                    <i class="fas fa-tag"></i> Área Académica
                                </label>
                                <input type="text" 
                                       class="form-control" 
                                       id="area" 
                                       name="area" 
                                       value="<%= curso.getArea() != null ? curso.getArea() : "" %>">
                            </div>
                            
                            <!-- Créditos -->
                            <div class="mb-3">
                                <label for="creditos" class="form-label">
                                    <i class="fas fa-star"></i> Créditos
                                </label>
                                <input type="number" 
                                       class="form-control" 
                                       id="creditos" 
                                       name="creditos" 
                                       value="<%= curso.getCreditos() %>" 
                                       min="1">
                            </div>
                            
                            <!-- Descripción -->
                            <div class="mb-3">
                                <label for="descripcion" class="form-label">
                                    <i class="fas fa-align-left"></i> Descripción
                                </label>
                                <textarea class="form-control" 
                                          id="descripcion" 
                                          name="descripcion" 
                                          rows="3"><%= curso.getDescripcion() != null ? curso.getDescripcion() : "" %></textarea>
                            </div>
                            
                            <!-- Información de Horarios -->
                            <div class="alert alert-info">
                                <i class="fas fa-info-circle"></i> 
                                <strong>Nota:</strong> Los horarios del curso se gestionan desde el módulo de Registro de Cursos.
                                Este formulario solo actualiza la información básica del curso.
                            </div>
                            
                            <!-- Botones -->
                            <div class="d-flex justify-content-between">
                                <a href="CursoServlet?accion=listar" class="btn btn-secondary">
                                    <i class="fas fa-arrow-left"></i> Cancelar
                                </a>
                                <button type="submit" class="btn btn-primary">
                                    <i class="fas fa-save"></i> Guardar Cambios
                                </button>
                            </div>
                        </form>
                        
                    </div>
                </div>
                
                <!-- Card de Horarios Actuales -->
                <div class="card mt-3">
                    <div class="card-header bg-info text-white">
                        <h5><i class="fas fa-clock"></i> Horarios Actuales</h5>
                    </div>
                    <div class="card-body">
                        <%
                            List<Map<String, Object>> horarios = 
                                (List<Map<String, Object>>) request.getAttribute("horarios");
                            
                            if (horarios == null) {
                                // Obtener horarios si no están en el request
                                horarios = new modelo.CursoDAO().obtenerHorariosPorCurso(curso.getId());
                            }
                            
                            if (horarios != null && !horarios.isEmpty()) {
                        %>
                            <table class="table table-sm">
                                <thead>
                                    <tr>
                                        <th>Día</th>
                                        <th>Horario</th>
                                        <th>Turno</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (Map<String, Object> h : horarios) { %>
                                    <tr>
                                        <td><%= h.get("dia_semana") %></td>
                                        <td><%= h.get("hora_inicio") %> - <%= h.get("hora_fin") %></td>
                                        <td><%= h.get("turno_nombre") %></td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        <% } else { %>
                            <p class="text-muted">No hay horarios registrados para este curso.</p>
                        <% } %>
                        
                        <a href="RegistroCursoServlet?accion=cargarFormulario" class="btn btn-sm btn-outline-primary mt-2">
                            <i class="fas fa-calendar-alt"></i> Gestionar Horarios
                        </a>
                    </div>
                </div>
                
            </div>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
