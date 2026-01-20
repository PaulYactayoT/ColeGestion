<%-- 
    Document   : notasPadre
    Created on : 31 may. 2025, 1:01:37 p. m.
    Author     : Juan Pablo Amaya
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Nota" %>
<%@ page import="modelo.NotaDAO" %>
<%@ page import="modelo.Padre" %>
<%@ page import="modelo.Nota" %>
<%@ page import="java.util.List" %>


<%
    // Obtener el ID del alumno desde la URL
    int alumnoId = Integer.parseInt(request.getParameter("alumno_id"));

    // Crear un objeto NotaDAO para acceder a las notas
    NotaDAO notaDAO = new NotaDAO();

    // Obtener la lista de notas para este alumno
    List<Nota> notas = notaDAO.listarPorAlumno(alumnoId);

    // Obtener el objeto padre desde la sesión
    Padre padre = (Padre) session.getAttribute("padre");

    // Si el padre es nulo, redirigir a la página de login
    if (padre == null) {
        response.sendRedirect("index.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <title>Notas del Alumno</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
        <link rel="stylesheet" href="assets/css/estilos.css">
        <style>
            body {
                background-image: url('assets/img/fondo_dashboard_padre.jpg');
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
        </style>
    </head>
    <body>
        <div class="header-bar">
            <div>
                <img src="assets/img/logosa.png" alt="Logo" style="width: 30px; height: auto; margin-right: 10px;" />
                <strong>Colegio SA</strong>
            </div>
            <div>
                Padre de: <%= padre.getAlumnoNombre()%> | Grado: <%= padre.getGradoNombre()%>
                <a href="LogoutServlet" class="btn btn-outline-light btn-sm ms-3">Cerrar sesión</a>
            </div>
        </div>

        <div class="container mt-5">
            <div class="mb-3">
                <a href="padreDashboard.jsp" class="btn btn-outline-dark">&larr; Regresar al Inicio</a>
            </div>
            <!-- Botones PDF/Excel -->
            <div class="d-flex justify-content-end mb-3">
                <!-- PDF -->
                <a href="ExportServlet?report=notas&type=pdf&alumno_id=<%= alumnoId%>"
                   class="btn btn-danger btn-sm btn-report me-2">
                    <i class="bi bi-file-earmark-pdf-fill me-1"></i> Exportar PDF
                </a>

                <!-- XLSX -->
                <a href="ExportServlet?report=notas&type=xlsx&alumno_id=<%= alumnoId%>"
                   class="btn btn-success btn-sm btn-report">
                    <i class="bi bi-file-earmark-excel-fill me-1"></i> Exportar Excel
                </a>
            </div>


            <div class="card shadow-sm">
                <div class="card-header bg-primary text-white">Notas del Alumno</div>
                <div class="card-body p-0">
                    <table class="table table-bordered mb-0 text-center">
                        <thead class="table-dark">
                            <tr>
                                <th>Curso</th>
                                <th>Tarea</th>
                                <th>Nota</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                // Verificar si la lista de notas está vacía
                                if (notas != null && !notas.isEmpty()) {
                                    // Mostrar las notas si existen
                                    for (Nota nota : notas) {
                            %>
                            <tr>
                                <td><%= nota.getCursoNombre()%></td>
                                <td><%= nota.getTareaNombre()%></td>
                                <td><%= nota.getNota()%></td>
                            </tr>
                            <%
                                }
                            } else {
                            %>
                            <tr><td colspan="3" class="text-center">No hay notas registradas.</td></tr>
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
</html>

