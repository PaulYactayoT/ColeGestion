<%-- 
    Document   : profesores
    Created on : 1 may. 2025, 8:55:51 p. m.
    Author     : Juan Pablo Amaya
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, modelo.Profesor" %>
<%@ page import="javax.servlet.http.HttpSession" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    List<Profesor> lista = (List<Profesor>) request.getAttribute("lista");
%>

<head>
    <meta charset="UTF-8">
    <title>Listado de Profesores</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="assets/css/estilos.css">
</head>
<body class="dashboard-page">

    <jsp:include page="header.jsp" />

    <div class="container mt-5">
        <h2 class="mb-4">Listado de Profesores</h2>
        
            <% 
                String error = (String) session.getAttribute("error");
                String mensaje = (String) session.getAttribute("mensaje");

                if (error != null) { 
                    session.removeAttribute("error");
            %>
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="fas fa-exclamation-circle"></i>
                    <strong>Error:</strong> <%= error %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>

            <% if (mensaje != null) { 
                session.removeAttribute("mensaje");
            %>
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="fas fa-check-circle"></i>
                    <strong>Éxito:</strong> <%= mensaje %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>
        <a href="ProfesorServlet?accion=nuevo" class="btn btn-success mb-3">Registrar Profesor</a>

        <table class="table table-bordered table-striped">
            <thead class="table-dark">
                <tr>
                    <th>Nombres</th>
                    <th>Apellidos</th>
                    <th>Correo</th>
                    <th>Área</th>
                    <th>Nivel</th>
                    <th>Turno</th>
                    <th>Estado</th>
                    <th>Acciones</th>
                </tr>
            </thead>
            <tbody>
                <%
                    if (lista != null && !lista.isEmpty()) {
                        for (Profesor p : lista) {
                %>
                <tr>
                    <td><%= p.getNombres()%></td>
                    <td><%= p.getApellidos()%></td>
                    <td><%= p.getCorreo()%></td>
                    <td><%= p.getAreaNombre() != null ? p.getAreaNombre() : "Sin área" %></td>
                    <td>
                        <% 
                            String nivel = p.getNivel();
                            String badge = "";
                            if ("INICIAL".equals(nivel)) {
                                badge = "badge bg-info";
                            } else if ("PRIMARIA".equals(nivel)) {
                                badge = "badge bg-success";
                            } else if ("SECUNDARIA".equals(nivel)) {
                                badge = "badge bg-warning";
                            } else if ("TODOS".equals(nivel)) {
                                badge = "badge bg-primary";
                            } else {
                                badge = "badge bg-secondary";
                            }
                        %>
                        <span class="<%= badge %>"><%= nivel != null ? nivel : "Sin nivel" %></span>
                    </td>
                    <td><%= p.getTurnoNombre()!= null ? p.getTurnoNombre() : "Sin turno"%></td>
                    
                    <td>
                    <% 
                        String estado = p.getEstado();
                        String badgeEstado = "";
                        if ("ACTIVO".equals(estado)) {
                            badgeEstado = "badge bg-success";
                        } else if ("INACTIVO".equals(estado)) {
                            badgeEstado = "badge bg-danger";
                        } else if ("LICENCIA".equals(estado)) {
                            badgeEstado = "badge bg-warning text-dark";
                        } else if ("JUBILADO".equals(estado)) {
                            badgeEstado = "badge bg-secondary";
                        } else {
                            badgeEstado = "badge bg-secondary";
                        }
                    %>
                    <span class="<%= badgeEstado %>"><%= estado != null ? estado : "ACTIVO" %></span>
                </td>
                    <td>
                        <a href="ProfesorServlet?accion=editar&id=<%= p.getId()%>" 
                           class="btn btn-primary btn-sm" title="Editar">
                            <i class="fas fa-edit"></i>
                        </a>
                        <a href="ProfesorServlet?accion=ver&id=<%= p.getId()%>" 
                           class="btn btn-info btn-sm" title="Ver Detalles">
                            <i class="fas fa-eye"></i>
                        </a>
                        <a href="ProfesorServlet?accion=eliminar&id=<%= p.getId()%>" 
                           class="btn btn-danger btn-sm"
                           onclick="return confirm('¿Eliminar este profesor?')" title="Eliminar">
                            <i class="fas fa-trash"></i>
                        </a>
                    </td>
                </tr>
                <%
                    }
                } else {
                %>
                <tr>
                    <td colspan="8" class="text-center">No hay profesores registrados.</td>
                </tr>
                <%
                    }
                %>
            </tbody>
        </table>
    </div>
    <footer class="bg-dark text-white py-2">
        <div class="container text-center text-md-start">
            <div class="row">

                <div class="col-md-4 mb-0">
                    <div class="logo-container text-center">
                        <img src="assets/img/logosa.png" alt="Logo" class="img-fluid mb-1" width="80" height="auto">
                        <p class="fs-6">"Líderes en educación de calidad al más alto nivel"</p>
                    </div>
                </div>

                <div class="col-md-4 mb-0">
                    <h5 class="fs-8">Contacto:</h5>
                    <p class="fs-6">Dirección: Av. El Sol 461, San Juan de Lurigancho 15434</p>
                    <p class="fs-6">Teléfono: 987654321</p>
                    <p class="fs-6">Correo: colegiosanantonio@gmail.com</p>
                </div>

                <div class="col-md-4 mb-0">
                    <h5 class="fs-8">Síguenos:</h5>
                    <a href="https://www.facebook.com/" class="text-white d-block fs-6">Facebook</a>
                    <a href="https://www.instagram.com/" class="text-white d-block fs-6">Instagram</a>
                    <a href="https://twitter.com/" class="text-white d-block fs-6">Twitter</a>
                    <a href="https://www.youtube.com/" class="text-white d-block fs-6">YouTube</a>
                </div>
            </div>

            <div class="text-center mt-0">
                <p class="fs-6">&copy; 2026 Colegio SA - Todos los derechos reservados</p>
            </div>
        </div>
    </footer>
</body>
