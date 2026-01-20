<%-- 
    Document   : alumnoForm
    Created on : 1 may. 2025, 8:09:43 p. m.
    Author     : Juan Pablo Amaya
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Alumno" %>
<%@ page import="modelo.Grado" %>
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

    Alumno a = (Alumno) request.getAttribute("alumno");
    List<Grado> grados = (List<Grado>) request.getAttribute("grados");
    boolean editar = (a != null);
%>

<head>
    <meta charset="UTF-8">
    <title><%= editar ? "Editar Alumno" : "Registrar Alumno"%></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="assets/css/estilos.css?v=1.4">
</head>
<body class="dashboard-page">
    <jsp:include page="header.jsp" />

    <div class="container mt-5">
        <h2 class="mb-4 text-center fw-bold"><%= editar ? "Editar Alumno" : "Registrar Alumno"%></h2>

        <form action="AlumnoServlet" method="post" class="p-4 rounded shadow bg-white">
            <input type="hidden" name="id" value="<%= editar ? a.getId() : ""%>">

            <div class="mb-3">
                <label class="form-label">Nombres:</label>
                <input type="text" class="form-control" name="nombres" value="<%= editar ? a.getNombres() : ""%>" required>
            </div>

            <div class="mb-3">
                <label class="form-label">Apellidos:</label>
                <input type="text" class="form-control" name="apellidos" value="<%= editar ? a.getApellidos() : ""%>" required>
            </div>

            <div class="mb-3">
                <label class="form-label">Correo:</label>
                <input type="email" class="form-control" name="correo" value="<%= editar ? a.getCorreo() : ""%>" required>
            </div>

            <div class="mb-3">
                <label class="form-label">Fecha de Nacimiento:</label>
                <input type="date" class="form-control" name="fecha_nacimiento" value="<%= editar ? a.getFechaNacimiento() : ""%>" required>
            </div>

            <div class="mb-3">
                <label class="form-label">Grado/Salón:</label>
                <select name="grado_id" class="form-select" required>
                    <option value="">-- Selecciona un grado --</option>
                    <% for (Grado g : grados) {%>
                    <option value="<%= g.getId()%>" <%= (editar && a.getGradoId() == g.getId()) ? "selected" : ""%>>
                        <%= g.getNombre()%> - <%= g.getNivel()%>
                    </option>
                    <% }%>
                </select>
            </div>

            <button type="submit" class="btn btn-primary"><%= editar ? "Actualizar" : "Registrar"%></button>
            <a href="AlumnoServlet" class="btn btn-secondary">Cancelar</a>
        </form>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
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



