<%-- 
    Document   : notasDocente
    Created on : 31 may. 2025, 5:34:02 a. m.
    Author     : Juan Pablo Amaya
--%>

<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="modelo.Profesor, modelo.Curso, modelo.Nota, java.util.List" %>

<%
    Profesor docente = (Profesor) session.getAttribute("docente");
    Curso curso = (Curso) request.getAttribute("curso");
    List<Nota> lista = (List<Nota>) request.getAttribute("lista");

    if (docente == null || curso == null) {
        response.sendRedirect("docenteDashboard.jsp");
        return;
    }
%>


<head>
    <meta charset="UTF-8">
    <title>Notas del Curso</title>
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
        .section-header {
            background-color: #111;
            color: white;
            padding: 15px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .section-header a {
            color: white;
            text-decoration: none;
            margin-left: 20px;
        }
        .section-header a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>

    <!-- CABECERA -->
    <div class="section-header">
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
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h4 class="fw-bold">Notas del Curso</h4>
            <a href="NotaServlet?accion=nuevo&curso_id=<%= curso.getId()%>" class="btn btn-primary">Registrar Nota</a>

        </div>

        <div class="mb-3">
            <a href="LoginServlet?accion=dashboard" class="btn btn-outline-dark">&larr; Regresar al Inicio</a>
        </div>

        <div class="card shadow-sm">
            <div class="card-header bg-dark text-white">Listado de Notas</div>
            <div class="card-body p-0">
                <table class="table table-striped mb-0">
                    <thead class="table-dark text-center">
                        <tr>
                            <th>Alumno</th>
                            <th>Tarea</th>
                            <th>Nota</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody class="text-center">
                        <%
                            if (lista != null && !lista.isEmpty()) {
                                for (Nota n : lista) {
                        %>
                        <tr>
                            <td><%= n.getAlumnoNombre()%></td>
                            <td><%= n.getTareaNombre()%></td>
                            <td><%= n.getNota()%></td>
                            <td>
                                <a href="NotaServlet?accion=editar&id=<%= n.getId()%>&curso_id=<%= curso.getId()%>" class="btn btn-sm btn-primary">Editar</a>
                                <a href="NotaServlet?accion=eliminar&id=<%= n.getId()%>&curso_id=<%= curso.getId()%>" 
                                   class="btn btn-sm btn-danger" 
                                   onclick="return confirm('¿Eliminar esta nota?')">Eliminar</a>
                            </td>
                        </tr>
                        <%
                            }
                        } else {
                        %>
                        <tr><td colspan="4">No hay notas registradas.</td></tr>
                        <% }%>
                    </tbody>
                </table>
            </div>
        </div>
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
