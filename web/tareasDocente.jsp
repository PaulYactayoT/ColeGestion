<%-- 
    Document   : tareasDocente
    Created on : 31 may. 2025, 3:18:19 a. m.
    Author     : Juan Pablo Amaya
--%>

<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="modelo.Tarea, modelo.Curso, modelo.Profesor, java.util.List" %>

<%
    Profesor docente = (Profesor) session.getAttribute("docente");
    Curso curso = (Curso) request.getAttribute("curso");
    List<Tarea> lista = (List<Tarea>) request.getAttribute("lista");
    String accion = (String) request.getAttribute("accion");
    if (accion == null) {
        accion = request.getParameter("accion");
    }

    if (docente == null || curso == null) {
        response.sendRedirect("docenteDashboard.jsp");
        return;
    }
%>


<head>
    <meta charset="UTF-8">
    <title>Gestionar Tareas</title>
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

        <div class="d-flex justify-content-between align-items-center mb-3">
            <h4 class="fw-bold">Tareas del Curso</h4>
            <a href="TareaServlet?accion=registrar&curso_id=<%= curso.getId()%>" class="btn btn-primary">Registrar Nueva Tarea</a>
        </div>

        <div class="mb-3">
            <a href="LoginServlet?accion=dashboard" class="btn btn-outline-dark">&larr; Regresar al Inicio</a>
        </div>

        <% if ("registrar".equals(accion)) {%>
        <!-- FORMULARIO DE REGISTRO -->
        <div class="card mb-4 shadow-sm">
            <div class="card-header bg-primary text-white">Registrar Nueva Tarea</div>
            <div class="card-body">
                <form action="TareaServlet" method="post">
                    <input type="hidden" name="accion" value="registrar">
                    <input type="hidden" name="curso_id" value="<%= curso.getId()%>">

                    <div class="mb-3">
                        <label class="form-label">Nombre:</label>
                        <input type="text" name="nombre" class="form-control" required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Descripción:</label>
                        <textarea name="descripcion" class="form-control" rows="3" required></textarea>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Fecha de Entrega:</label>
                        <input type="date" name="fecha_entrega" class="form-control" required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">¿Activo?</label>
                        <select name="activo" class="form-select">
                            <option value="true">Sí</option>
                            <option value="false">No</option>
                        </select>
                    </div>

                    <div class="text-end">
                        <a href="TareaServlet?accion=ver&curso_id=<%= curso.getId()%>" class="btn btn-secondary">Cancelar</a>
                        <button type="submit" class="btn btn-primary">Registrar</button>
                    </div>
                </form>
            </div>
        </div>
        <% } %>

        <% if ("editar".equals(accion)) {
                Tarea tarea = (Tarea) request.getAttribute("tarea");
        %>
        <!-- FORMULARIO DE EDICIÓN -->
        <div class="card mb-4 shadow-sm">
            <div class="card-header bg-warning text-dark">Editar Tarea</div>
            <div class="card-body">
                <form action="TareaServlet" method="post">
                    <input type="hidden" name="id" value="<%= tarea.getId()%>">
                    <input type="hidden" name="curso_id" value="<%= curso.getId()%>">

                    <div class="mb-3">
                        <label class="form-label">Nombre:</label>
                        <input type="text" name="nombre" class="form-control" value="<%= tarea.getNombre()%>" required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Descripción:</label>
                        <textarea name="descripcion" class="form-control" rows="3" required><%= tarea.getDescripcion()%></textarea>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Fecha de Entrega:</label>
                        <input type="date" name="fecha_entrega" class="form-control" value="<%= tarea.getFechaEntrega()%>" required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">¿Activo?</label>
                        <select name="activo" class="form-select">
                            <option value="true" <%= tarea.isActivo() ? "selected" : ""%>>Sí</option>
                            <option value="false" <%= !tarea.isActivo() ? "selected" : ""%>>No</option>
                        </select>
                    </div>

                    <div class="text-end">
                        <a href="TareaServlet?accion=ver&curso_id=<%= curso.getId()%>" class="btn btn-secondary">Cancelar</a>
                        <button type="submit" class="btn btn-warning">Actualizar</button>
                    </div>
                </form>
            </div>
        </div>
        <% } %>

        <!-- LISTADO DE TAREAS -->
        <div class="card shadow-sm">
            <div class="card-header bg-dark text-white">Tareas Registradas</div>
            <div class="card-body p-0">
                <table class="table table-striped mb-0">
                    <thead class="table-dark text-center">
                        <tr>
                            <th>Nombre</th>
                            <th>Descripción</th>
                            <th>Entrega</th>
                            <th>Activo</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody class="text-center">
                        <% if (lista != null && !lista.isEmpty()) {
                                for (Tarea t : lista) {%>
                        <tr>
                            <td><%= t.getNombre()%></td>
                            <td><%= t.getDescripcion()%></td>
                            <td><%= t.getFechaEntrega()%></td>
                            <td><%= t.isActivo() ? "Sí" : "No"%></td>
                            <td>
                                <a href="TareaServlet?accion=editar&id=<%= t.getId()%>&curso_id=<%= curso.getId()%>" class="btn btn-sm btn-primary">Editar</a>
                                <a href="TareaServlet?accion=eliminar&id=<%= t.getId()%>&curso_id=<%= curso.getId()%>"
                                   class="btn btn-sm btn-danger"
                                   onclick="return confirm('¿Eliminar esta tarea?')">Eliminar</a>
                            </td>
                        </tr>
                        <% }
                        } else { %>
                        <tr><td colspan="5">No hay tareas registradas.</td></tr>
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




