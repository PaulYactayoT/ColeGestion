<%-- 
    Document   : verAlumnos
    Created on : 3 may. 2025, 5:39:17 a. m.
    Author     : Juan Pablo Amaya
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Alumno" %>
<%@ page import="modelo.Grado" %>
<%@ page import="java.util.List" %>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Ver Alumnos por Grado</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="assets/css/estilos.css">
    </head>
    <body class="dashboard-page" style="background-color: #f0f4ff;">

        <jsp:include page="header.jsp" />

        <div class="container mt-5">
            <h2 class="mb-4">Ver Alumnos por Grado</h2>

            <!-- Formulario para seleccionar el grado -->
            <form method="get" action="VerAlumnosServlet">
                <label for="grado_id">Seleccionar Grado:</label>
                <select name="grado" id="grado_id" class="form-select" required>
                    <option value="">-- Selecciona un grado --</option>
                    <%
                        List<Grado> grados = (List<Grado>) request.getAttribute("grados");
                        for (Grado g : grados) {
                    %>
                    <option value="<%= g.getId()%>" 
                            <%= (request.getAttribute("gradoSeleccionado") != null && g.getId() == (int) request.getAttribute("gradoSeleccionado")) ? "selected" : ""%> >
                        <%= g.getNombre()%> - <%= g.getNivel()%>
                    </option>
                    <% } %>
                </select>
                <button type="submit" class="btn btn-primary mt-3">Ver Alumnos</button>
            </form>

            <h3 class="mt-5">Alumnos Registrados</h3>
            <table class="table table-bordered table-striped">
                <thead class="table-dark">
                    <tr>
                        <th>Nombre</th>
                        <th>Apellido</th>
                        <th>Correo</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        List<Alumno> alumnos = (List<Alumno>) request.getAttribute("alumnos");
                        if (alumnos != null && !alumnos.isEmpty()) {
                            for (Alumno a : alumnos) {
                    %>
                    <tr>
                        <td><%= a.getNombres()%></td>
                        <td><%= a.getApellidos()%></td>
                        <td><%= a.getCorreo()%></td>
                    </tr>
                    <% }
                    } else { %>
                    <tr>
                        <td colspan="3" class="text-center">No hay alumnos registrados para este grado.</td>
                    </tr>
                    <% }%>
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
                    <p class="fs-6">&copy; 2025 Colegio SA - Todos los derechos reservados</p>
                </div>
            </div>
        </footer>
    </body>
</html>
