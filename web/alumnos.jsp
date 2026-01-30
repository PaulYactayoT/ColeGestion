<%-- 
    Document   : alumnos
    Created on : 1 may. 2025, 8:09:32 p. m.
    Author     : Juan Pablo Amaya
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, modelo.Alumno, modelo.Grado" %>
<%@ page import="javax.servlet.http.HttpSession" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    List<Grado> grados = (List<Grado>) request.getAttribute("grados");
    Integer gradoSeleccionado = (Integer) request.getAttribute("gradoSeleccionado");
%>

<head>
    <meta charset="UTF-8">
    <title>Listado de Alumnos</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="assets/css/estilos.css">
</head>
<body class="dashboard-page">

    <jsp:include page="header.jsp" />

    <div class="container mt-4">
        <h2>Listado de Alumnos</h2>

        <!-- FORMULARIO PARA FILTRAR POR GRADO -->
        <form action="AlumnoServlet" method="get" class="row g-3 align-items-center mb-3">
            <input type="hidden" name="accion" value="filtrar">
            <div class="col-auto">
                <label for="grado_id" class="col-form-label">Filtrar por Grado:</label>
            </div>
            <div class="col-auto">
                <select name="grado_id" id="grado_id" class="form-select">
                    <option value="">-- Todos los grados --</option>
                    <% for (Grado g : grados) {%>
                    <option value="<%= g.getId()%>" <%= (gradoSeleccionado != null && gradoSeleccionado == g.getId()) ? "selected" : ""%>>
                        <%= g.getNombre()%> - <%= g.getNivel()%>
                    </option>
                    <% } %>
                </select>
            </div>
            <div class="col-auto">
                <button type="submit" class="btn btn-primary">Filtrar</button>
            </div>
        </form>

        <!-- BOTÓN CORREGIDO PARA USAR EL SERVLET -->
        <a href="AlumnoServlet?accion=nuevo" class="btn btn-success mb-3">Registrar Alumno</a>

        <table class="table table-bordered table-striped">
            <thead class="table-dark">
                <tr>
                    
                    <th>Nombres</th>
                    <th>Apellidos</th>
                    <th>Correo</th>
                    <th>Fecha Nac.</th>
                    <th>Acciones</th>
                </tr>
            </thead>
            <tbody>
                <%
                    List<Alumno> lista = (List<Alumno>) request.getAttribute("lista");
                    for (Alumno a : lista) {
                %>
                <tr>
                    
                    <td><%= a.getNombres()%></td>
                    <td><%= a.getApellidos()%></td>
                    <td><%= a.getCorreo()%></td>
                    <td><%= a.getFechaNacimiento()%></td>
                    <td>
                        <a href="AlumnoServlet?accion=editar&id=<%= a.getId()%>" class="btn btn-primary btn-sm">Editar</a>
                        <a href="AlumnoServlet?accion=eliminar&id=<%= a.getId()%>" class="btn btn-danger btn-sm"
                           onclick="return confirm('¿Estás seguro de eliminar este alumno?')">Eliminar</a>
                    </td>
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


