<%-- 
    Document   : observacionForm
    Created on : 31 may. 2025, 6:34:33?a. m.
    Author     : Juan Pablo Amaya
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Curso, modelo.Profesor, modelo.Observacion, modelo.Alumno, java.util.List" %>

<%
    Profesor docente = (Profesor) session.getAttribute("docente");
    Curso curso = (Curso) request.getAttribute("curso");
    List<Alumno> alumnos = (List<Alumno>) request.getAttribute("alumnos");
    Observacion observacion = (Observacion) request.getAttribute("observacion");

    if (docente == null || curso == null) {
        response.sendRedirect("docenteDashboard.jsp");
        return;
    }

    boolean editar = (observacion != null);
%>


<head>
    <meta charset="UTF-8">
    <title><%= editar ? "Editar Observación" : "Registrar Observación"%></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="assets/css/estilos.css">
    <style>
        body {
            background-image: url('assets/img/fondo_dashboard_docente.jpg');
            background-size: 100% 100%;
            background-position: center;
            background-attachment: fixed;
            height: 100vh;
        }
        .header-bar {
            background-color: #111;
            color: white;
            padding: 15px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .header-bar a {
            color: white;
            text-decoration: none;
        }
        .header-bar a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>

    <div class="header-bar">
        <div>
            <img src="assets/img/logosa.png" alt="Logo" style="width: 30px; height: auto; margin-right: 10px;" />
            <strong>Colegio SA</strong> |
            Curso: <%= curso.getNombre()%> |
            Grado: <%= curso.getGradoNombre()%>
        </div>
        <div>
            Docente: <%= docente.getNombres()%> <%= docente.getApellidos()%>
            <a href="LogoutServlet" class="btn btn-sm btn-outline-light ms-3">Cerrar sesión</a>
        </div>
    </div>

    <div class="container mt-5">
        <h3 class="mb-4 text-center fw-bold"><%= editar ? "Editar Observación" : "Registrar Nueva Observación"%></h3>

        <form action="ObservacionServlet" method="post" class="bg-white p-4 rounded shadow-sm">

            <input type="hidden" name="curso_id" value="<%= curso.getId()%>">
            <input type="hidden" name="id" value="<%= editar ? observacion.getId() : ""%>">

            <div class="mb-3">
                <label class="form-label">Alumno:</label>
                <select name="alumno_id" class="form-select" required>
                    <option value="">-- Seleccione un alumno --</option>
                    <% for (Alumno a : alumnos) {%>
                    <option value="<%= a.getId()%>" <%= (editar && a.getId() == observacion.getAlumnoId()) ? "selected" : ""%>>
                        <%= a.getNombres()%> <%= a.getApellidos()%>
                    </option>
                    <% }%>
                </select>
            </div>

            <div class="mb-3">
                <label class="form-label">Observación:</label>
                <textarea name="texto" class="form-control" rows="4" required><%= editar ? observacion.getTexto() : ""%></textarea>
            </div>

            <div class="text-end">
                <a href="ObservacionServlet?accion=listar&curso_id=<%= curso.getId()%>" class="btn btn-secondary">Cancelar</a>
                <button type="submit" class="btn btn-primary"><%= editar ? "Actualizar" : "Registrar"%></button>
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
