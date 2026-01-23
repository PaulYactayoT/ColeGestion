<%-- 
    Document   : cursoForm
    Created on : 1 may. 2025, 9:28:17 p. m.
    Author     : Juan Pablo Amaya
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Curso" %>
<%@ page import="modelo.Grado" %>
<%@ page import="modelo.Profesor" %>
<%@ page import="java.util.List" %>
<%@ page import="javax.servlet.http.HttpSession" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    Curso c = (Curso) request.getAttribute("curso");
    List<Grado> grados = (List<Grado>) request.getAttribute("grados");
    List<Profesor> profesores = (List<Profesor>) request.getAttribute("profesores");
    boolean editar = (c != null);
%>


<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title><%= editar ? "Editar Curso" : "Registrar Curso"%></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="assets/css/estilos.css">
</head>
<body class="dashboard-page">

    <jsp:include page="header.jsp" />

    <div class="container mt-5">
        <h2 class="mb-4 text-center fw-bold"><%= editar ? "Editar Curso" : "Registrar Curso"%></h2>

        <form action="CursoServlet" method="post" class="bg-white p-4 rounded shadow-sm">

            <input type="hidden" name="id" value="<%= editar ? c.getId() : ""%>">

            <div class="mb-3">
                <label class="form-label">Nombre:</label>
                <input type="text" name="nombre" class="form-control" 
                       value="<%= editar ? c.getNombre() : ""%>" required>
            </div>

            <div class="mb-3">
                <label class="form-label">Grado:</label>
                <select name="grado_id" class="form-select" required>
                    <option value="">-- Seleccione un grado --</option>
                    <% for (Grado g : grados) {%>
                    <option value="<%= g.getId()%>" <%= (editar && c.getGradoId() == g.getId()) ? "selected" : ""%>>
                        <%= g.getNombre()%> - <%= g.getNivel()%>
                    </option>
                    <% } %>
                </select>
            </div>

            <div class="mb-3">
                <label class="form-label">Profesor:</label>
                <select name="profesor_id" class="form-select" required>
                    <option value="">-- Seleccione un profesor --</option>
                    <% for (Profesor p : profesores) {%>
                    <option value="<%= p.getId()%>" <%= (editar && c.getProfesorId() == p.getId()) ? "selected" : ""%>>
                        <%= p.getNombres()%> <%= p.getApellidos()%>
                    </option>
                    <% }%>
                </select>
            </div>

            <div class="mb-3">
                <label class="form-label">Créditos:</label>
                <input type="number" name="creditos" class="form-control" min="1"
                       value="<%= editar ? c.getCreditos() : ""%>" required>
            </div>

            <!-- NUEVO: Campo de descripción -->
            <div class="mb-3">
                <label class="form-label">Descripción:</label>
                <textarea name="descripcion" class="form-control" rows="3" 
                          placeholder="Ingrese una descripción del curso (opcional)"><%= editar && c.getDescripcion() != null ? c.getDescripcion() : ""%></textarea>
            </div>

            <div class="text-end">
                <a href="CursoServlet" class="btn btn-secondary">Cancelar</a>
                <button type="submit" class="btn btn-primary">
                    <%= editar ? "Actualizar" : "Registrar"%>
                </button>
            </div>
        </form>
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
                <p class="fs-6">&copy; 2025 Colegio SA - Todos los derechos reservados</p>
            </div>
        </div>
    </footer>
</body>
</html>