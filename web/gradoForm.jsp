<%-- 
    Document   : gradoForm
    Created on : 1 may. 2025, 10:57:00 p. m.
    Author     : Juan Pablo Amaya
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Grado" %>
<%@ page import="javax.servlet.http.HttpSession" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    Grado g = (Grado) request.getAttribute("grado");
    boolean esEditar = g != null;
%>

<head>
    <meta charset="UTF-8">
    <title>Registrar Alumno</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="assets/css/estilos.css">
</head>
<body class="dashboard-page">

    <jsp:include page="header.jsp" />

    <div class="container mt-4">
        <h2><%= esEditar ? "Editar Grado" : "Registrar Grado"%></h2>
        <form action="GradoServlet" method="post">
            <input type="hidden" name="id" value="<%= esEditar ? g.getId() : ""%>">

            <div class="mb-3">
                <label class="form-label">Nombre:</label>
                <input type="text" class="form-control" name="nombre" value="<%= esEditar ? g.getNombre() : ""%>" required>
            </div>

            <div class="mb-3">
                <label class="form-label">Nivel:</label>
                <select class="form-select" name="nivel" required>
                    <option value="">-- Selecciona un nivel --</option>
                    <option value="Inicial" <%= esEditar && g.getNivel().equals("Inicial") ? "selected" : ""%>>Inicial</option>
                    <option value="Primaria" <%= esEditar && g.getNivel().equals("Primaria") ? "selected" : ""%>>Primaria</option>
                    <option value="Secundaria" <%= esEditar && g.getNivel().equals("Secundaria") ? "selected" : ""%>>Secundaria</option>
                </select>
            </div>

            <button type="submit" class="btn btn-primary"><%= esEditar ? "Actualizar" : "Registrar"%></button>
            <a href="GradoServlet" class="btn btn-secondary">Cancelar</a>
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