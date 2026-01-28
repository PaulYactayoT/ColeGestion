<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, java.util.Map" %>

<%
    List<Map<String, Object>> hijos = (List<Map<String, Object>>) request.getAttribute("hijos");
    if (hijos == null || hijos.isEmpty()) {
        response.sendRedirect("padreDashboard.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Seleccionar Alumno</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-6">
                <div class="card shadow">
                    <div class="card-header bg-primary text-white">
                        <h4 class="mb-0"><i class="bi bi-people-fill me-2"></i>Seleccionar Alumno</h4>
                    </div>
                    <div class="card-body">
                        <p class="text-muted">Tienes <%= hijos.size() %> alumno(s) asociado(s). Selecciona uno para continuar:</p>
                        
                        <form action="SeleccionarAlumnoServlet" method="post">
                            <div class="list-group">
                                <% for (Map<String, Object> hijo : hijos) { %>
                                <label class="list-group-item d-flex gap-3">
                                    <input class="form-check-input flex-shrink-0" 
                                           type="radio" 
                                           name="alumno_id" 
                                           value="<%= hijo.get("alumno_id") %>"
                                           <%= hijos.indexOf(hijo) == 0 ? "checked" : "" %>>
                                    <div>
                                        <h6 class="mb-1"><%= hijo.get("alumno_nombre") %></h6>
                                        <small class="text-muted d-block">
                                            Código: <%= hijo.get("codigo_alumno") %> | 
                                            Grado: <%= hijo.get("grado_nombre") %> | 
                                            Parentesco: <%= hijo.get("parentesco") %>
                                        </small>
                                    </div>
                                </label>
                                <% } %>
                            </div>
                            
                            <div class="mt-4 text-center">
                                <button type="submit" class="btn btn-primary px-4">
                                    <i class="bi bi-check-circle me-2"></i>Continuar con este alumno
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
                
                <div class="text-center mt-3">
                    <a href="LogoutServlet" class="text-decoration-none">
                        <i class="bi bi-box-arrow-left me-1"></i>Cerrar sesión
                    </a>
                </div>
            </div>
        </div>
    </div>
</body>
</html>