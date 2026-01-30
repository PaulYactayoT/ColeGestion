<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Padre, modelo.Material, modelo.Curso, java.util.List" %>
<%
    Padre padre = (Padre) session.getAttribute("padre");
    Curso curso = (Curso) request.getAttribute("curso");
    List<Material> materiales = (List<Material>) request.getAttribute("materiales");
    String alumnoNombre = (String) request.getAttribute("alumnoNombre");

    if (padre == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    if (curso == null) {
        response.sendRedirect("MaterialPadreServlet?accion=seleccionarCurso");
        return;
    }

    String mensaje = (String) session.getAttribute("mensaje");
    String error = (String) session.getAttribute("error");

    if (mensaje != null) {
        session.removeAttribute("mensaje");
    }
    if (error != null) {
        session.removeAttribute("error");
    }
%>

<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <title>Materiales - <%= curso.getNombre()%></title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
        <link rel="stylesheet" href="assets/css/estilos.css">

        <style>
            :root {
                --primary-color: #2c5aa0;
                --primary-dark: #1e3d72;
                --purple-color: #6f42c1;
                --purple-dark: #563d7c;
            }
            
            body {
                background-image: url('assets/img/fondo_dashboard_padre.jpg');
                background-size: cover;
                background-position: center;
                background-attachment: fixed;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            }
            
            .header-bar {
                background-color: rgba(17, 17, 17, 0.95);
                color: white;
                padding: 15px 30px;
                display: flex;
                justify-content: space-between;
                align-items: center;
                backdrop-filter: blur(10px);
                box-shadow: 0 2px 15px rgba(0,0,0,0.1);
            }
            
            .main-container {
                background: rgba(255, 255, 255, 0.95);
                border-radius: 15px;
                padding: 30px;
                box-shadow: 0 8px 20px rgba(0,0,0,0.15);
                margin-top: 30px;
            }
            
            .curso-header {
                background: linear-gradient(135deg, var(--purple-color), var(--purple-dark));
                color: white;
                padding: 20px;
                border-radius: 10px;
                margin-bottom: 30px;
            }
            
            .curso-header h3 {
                margin: 0;
                font-weight: 700;
            }
            
            .curso-header p {
                margin: 5px 0 0 0;
                opacity: 0.9;
            }
            
            .material-card {
                background: white;
                border-radius: 10px;
                padding: 20px;
                margin-bottom: 20px;
                box-shadow: 0 4px 8px rgba(0,0,0,0.1);
                transition: transform 0.2s;
                border-left: 4px solid var(--purple-color);
            }
            
            .material-card:hover {
                transform: translateY(-3px);
                box-shadow: 0 6px 12px rgba(0,0,0,0.15);
            }
            
            .file-icon {
                font-size: 2.5rem;
                color: var(--purple-color);
            }
            
            .badge-custom {
                padding: 8px 15px;
                border-radius: 20px;
                font-size: 0.85rem;
            }
            
            .back-button {
                background: linear-gradient(135deg, #6c757d, #5a6268);
                border: none;
                color: white;
                padding: 8px 20px;
                border-radius: 8px;
                transition: all 0.3s;
                text-decoration: none;
                display: inline-block;
            }
            
            .back-button:hover {
                transform: translateY(-2px);
                box-shadow: 0 4px 8px rgba(0,0,0,0.2);
                color: white;
            }
            
            .alumno-info-banner {
                background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
                color: white;
                padding: 10px 15px;
                border-radius: 8px;
                margin-bottom: 20px;
                text-align: center;
                font-size: 0.95rem;
            }
            
            .download-info {
                background: #f8f9fa;
                border-left: 4px solid #17a2b8;
                padding: 15px;
                border-radius: 8px;
                margin-bottom: 20px;
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
                <span class="me-3">Padre de: <strong><%= alumnoNombre%></strong></span>
                <a href="LogoutServlet" class="btn btn-outline-light btn-sm">
                    <i class="bi bi-box-arrow-right"></i> Cerrar sesión
                </a>
            </div>
        </div>

        <div class="container">
            <div class="main-container">

                <!-- Mensajes -->
                <% if (mensaje != null) {%>
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="bi bi-check-circle"></i> <%= mensaje%>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <% } %>

                <% if (error != null) {%>
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="bi bi-exclamation-triangle"></i> <%= error%>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
                <% } %>

                <!-- Botón de regreso -->
                <div class="mb-3">
                    <a href="MaterialPadreServlet?accion=seleccionarCurso" class="back-button">
                        <i class="bi bi-arrow-left"></i> Volver a Cursos
                    </a>
                </div>

                <!-- Banner con info del alumno -->
                <div class="alumno-info-banner">
                    <i class="bi bi-person-circle"></i> <strong>Materiales para:</strong> <%= alumnoNombre%>
                </div>

                <!-- Header del Curso -->
                <div class="curso-header">
                    <div class="row align-items-center">
                        <div class="col-md-8">
                            <h3><i class="bi bi-book-half"></i> <%= curso.getNombre()%></h3>
                            <p><i class="bi bi-mortarboard"></i> Grado: <%= curso.getGradoNombre()%></p>
                            <p><i class="bi bi-person"></i> Profesor: <%= curso.getProfesorNombre()%></p>
                        </div>
                        <div class="col-md-4 text-end">
                            <span class="badge bg-light text-dark" style="font-size: 1rem;">
                                <i class="bi bi-folder-fill"></i> <%= materiales != null ? materiales.size() : 0%> materiales
                            </span>
                        </div>
                    </div>
                </div>

                <!-- Información sobre descarga -->
                <div class="download-info">
                    <i class="bi bi-info-circle text-info"></i>
                    <strong>Nota:</strong> Estos son los materiales de apoyo proporcionados por el profesor. 
                    Puedes visualizarlos y descargarlos para apoyar el aprendizaje de tu hijo/a.
                </div>

                <!-- Lista de Materiales -->
                <h4 class="mb-3">
                    <i class="bi bi-folder2-open"></i> Materiales Disponibles
                </h4>

                <%
                    if (materiales != null && !materiales.isEmpty()) {
                        for (Material mat : materiales) {
                %>
                <div class="material-card">
                    <div class="row align-items-center">
                        <div class="col-md-1 text-center">
                            <% 
                                String extension = mat.getExtension().toLowerCase();
                                String iconClass = "bi-file-earmark";
                                String iconColor = "text-secondary";
                                
                                if (extension.equals("PDF")) {
                                    iconClass = "bi-file-earmark-pdf";
                                    iconColor = "text-danger";
                                } else if (extension.equals("DOC") || extension.equals("DOCX")) {
                                    iconClass = "bi-file-earmark-word";
                                    iconColor = "text-primary";
                                } else if (extension.equals("XLS") || extension.equals("XLSX")) {
                                    iconClass = "bi-file-earmark-excel";
                                    iconColor = "text-success";
                                } else if (extension.equals("PPT") || extension.equals("PPTX")) {
                                    iconClass = "bi-file-earmark-ppt";
                                    iconColor = "text-warning";
                                } else if (extension.equals("ZIP") || extension.equals("RAR")) {
                                    iconClass = "bi-file-earmark-zip";
                                    iconColor = "text-info";
                                }
                            %>
                            <i class="bi <%= iconClass%> file-icon <%= iconColor%>"></i>
                        </div>
                        <div class="col-md-8">
                            <h5 class="mb-1"><%= mat.getNombreArchivo()%></h5>
                            <% if (mat.getDescripcion() != null && !mat.getDescripcion().isEmpty()) {%>
                            <p class="text-muted mb-1">
                                <i class="bi bi-chat-left-text"></i> <%= mat.getDescripcion()%>
                            </p>
                            <% }%>
                            <small class="text-muted">
                                <i class="bi bi-calendar"></i> Subido el: 
                                <%= new java.text.SimpleDateFormat("dd/MM/yyyy").format(mat.getFechaSubida())%>
                            </small>
                        </div>
                        <div class="col-md-3 text-center">
                            <span class="badge badge-custom" style="background-color: var(--purple-color);">
                                <i class="bi bi-file-earmark"></i> <%= mat.getExtension()%>
                            </span>
                            <br>
                            <small class="text-muted d-block mt-1"><%= mat.getTamanioFormateado()%></small>
                            <a href="<%= request.getContextPath()%>/<%= mat.getRutaArchivo()%>" 
                               class="btn btn-sm btn-outline-primary mt-2" 
                               download="<%= mat.getNombreArchivo()%>"
                               target="_blank">
                                <i class="bi bi-download"></i> Descargar
                            </a>
                        </div>
                    </div>
                </div>
                <%
                        }
                    } else {
                %>
                <div class="alert alert-info text-center">
                    <i class="bi bi-info-circle"></i> No hay materiales disponibles para este curso aún.
                    <br>El profesor aún no ha subido materiales de apoyo.
                </div>
                <%
                    }
                %>

            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>