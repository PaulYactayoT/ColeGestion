<%-- 
    Document   : notasForm
    Created on : 31 may. 2025, 5:19:26 a. m.
    Author     : Juan Pablo Amaya
--%>

<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="modelo.Nota, modelo.Curso, modelo.Tarea, modelo.Alumno, modelo.Profesor, java.util.List" %>

<%
    Nota nota = (Nota) request.getAttribute("nota"); // puede ser null si es nuevo
    Curso curso = (Curso) request.getAttribute("curso");
    Profesor docente = (Profesor) session.getAttribute("docente");
    List<Tarea> tareas = (List<Tarea>) request.getAttribute("tareas");
    List<Alumno> alumnos = (List<Alumno>) request.getAttribute("alumnos");
    boolean editar = (nota != null);
%>

<head>
    <meta charset="UTF-8">
    <title><%= editar ? "Editar Nota" : "Registrar Nota"%></title>
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
        .container {
            max-width: 600px;
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
        <h4 class="fw-bold text-center mb-4"><%= editar ? "Editar Nota" : "Registrar Nota"%></h4>

        <div class="card shadow-sm">
            <div class="card-body">
                <form action="NotaServlet" method="post">
                    <input type="hidden" name="id" value="<%= editar ? nota.getId() : ""%>">
                    <input type="hidden" name="curso_id" value="<%= curso.getId()%>">

                    <div class="mb-3">
                        <label class="form-label">Curso:</label>
                        <input type="text" class="form-control" value="<%= curso.getNombre()%> - <%= curso.getGradoNombre()%>" disabled>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Tarea:</label>
                        <select name="tarea_id" class="form-select" required>
                            <option value="">-- Selecciona una tarea --</option>
                            <% for (Tarea t : tareas) {%>
                            <option value="<%= t.getId()%>" <%= editar && t.getId() == nota.getTareaId() ? "selected" : ""%>>
                                <%= t.getNombre()%>
                            </option>
                            <% } %>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Alumno:</label>
                        <select name="alumno_id" class="form-select" required>
                            <option value="">-- Selecciona un alumno --</option>
                            <% for (Alumno a : alumnos) {%>
                            <option value="<%= a.getId()%>" <%= editar && a.getId() == nota.getAlumnoId() ? "selected" : ""%>>
                                <%= a.getNombres()%> <%= a.getApellidos()%>
                            </option>
                            <% }%>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Nota (0 a 20):</label>
                        <input type="number" name="nota" class="form-control" min="0" max="20" step="0.1"
                               value="<%= editar ? nota.getNota() : ""%>" required>
                    </div>

                    <div class="text-end">
                        <a href="NotaServlet?accion=listar&curso_id=<%= curso.getId()%>" class="btn btn-secondary">Cancelar</a>
                        <button type="submit" class="btn btn-primary"><%= editar ? "Actualizar" : "Registrar"%></button>
                    </div>
                </form>
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

