<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Profesor, modelo.Material, modelo.Curso, java.util.List, java.text.SimpleDateFormat" %>
<%
    Profesor docente = (Profesor) session.getAttribute("docente");
    Curso curso = (Curso) request.getAttribute("curso");
    List<Material> materiales = (List<Material>) request.getAttribute("materiales");

    if (docente == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    if (curso == null) {
        response.sendRedirect("MaterialServlet?accion=seleccionarCurso");
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
    
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
%>

<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <title>Material de Apoyo - <%= curso.getNombre()%></title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
        <link rel="stylesheet" href="assets/css/estilos.css">

        <style>
            :root {
                --primary-color: #2c5aa0;
                --primary-dark: #1e3d72;
                --success-color: #20c997;
                --purple-color: #6f42c1;
                --purple-dark: #563d7c;
            }
            
            body {
                background-image: url('assets/img/fondo_dashboard_docente.jpg');
                background-size: cover;
                background-position: center;
                background-attachment: fixed;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            }
            
            .header-bar {
                background-color: #111;
                color: white;
                padding: 15px 30px;
                display: flex;
                justify-content: space-between;
                align-items: center;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
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
            
            .btn-primary-custom {
                background: linear-gradient(135deg, var(--purple-color), var(--purple-dark));
                border: none;
                color: white;
                padding: 10px 20px;
                border-radius: 10px;
                transition: all 0.3s;
                font-weight: 600;
            }
            
            .btn-primary-custom:hover {
                transform: translateY(-2px);
                box-shadow: 0 6px 12px rgba(111, 66, 193, 0.3);
                color: white;
            }
            
            .upload-area {
                background: #f8f9fa;
                border: 2px dashed var(--purple-color);
                border-radius: 10px;
                padding: 30px;
                margin-bottom: 30px;
            }
            
            .material-info {
                display: flex;
                align-items: center;
                gap: 15px;
            }
            
            .badge-custom {
                padding: 8px 15px;
                border-radius: 20px;
                font-size: 0.85rem;
                background-color: var(--purple-color);
                color: white;
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
        </style>
    </head>
    <body>

        <div class="header-bar">
            <div class="nav-links">
                <img src="assets/img/logosa.png" alt="Logo" style="width: 30px; height: auto; margin-right: 10px;" />
                <span class="fw-bold fs-6">Colegio SA</span>
            </div>
            <div>
                <span><i class="bi bi-person-circle"></i> <%= docente.getNombres()%> <%= docente.getApellidos()%></span>
                <a href="LogoutServlet" class="btn btn-outline-light btn-sm ms-2">
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
                    <a href="MaterialServlet?accion=seleccionarCurso" class="back-button">
                        <i class="bi bi-arrow-left"></i> Volver a Mis Cursos
                    </a>
                </div>

                <!-- Header del Curso -->
                <div class="curso-header">
                    <div class="row align-items-center">
                        <div class="col-md-8">
                            <h3><i class="bi bi-book-half"></i> <%= curso.getNombre()%></h3>
                            <p><i class="bi bi-mortarboard"></i> Grado: <%= curso.getGradoNombre()%></p>
                        </div>
                        <div class="col-md-4 text-end">
                            <span class="badge bg-light text-dark" style="font-size: 1rem;">
                                <i class="bi bi-folder-fill"></i> <%= materiales != null ? materiales.size() : 0%> materiales
                            </span>
                        </div>
                    </div>
                </div>

                <!-- Formulario de Subida -->
                <div class="upload-area">
                    <h5 class="mb-3">
                        <i class="bi bi-cloud-upload"></i> Subir Nuevo Material
                    </h5>
                    <form action="MaterialServlet" method="post" enctype="multipart/form-data">
                        <input type="hidden" name="accion" value="subir">
                        <input type="hidden" name="curso_id" value="<%= curso.getId()%>">
                        
                        <div class="row g-3">
                            <div class="col-md-12">
                                <label class="form-label fw-bold">
                                    <i class="bi bi-file-earmark-arrow-up"></i> Archivo *
                                </label>
                                <input type="file" name="archivo" class="form-control" required>
                                <small class="text-muted">Tamaño máximo: 10MB | Formatos: PDF, DOC, DOCX, PPT, PPTX, XLS, XLSX, ZIP</small>
                            </div>
                            
                            <div class="col-12">
                                <label class="form-label fw-bold">
                                    <i class="bi bi-chat-left-text"></i> Descripción (opcional)
                                </label>
                                <textarea name="descripcion" class="form-control" rows="2" 
                                          placeholder="Ej: Material de apoyo para el tema de fracciones..."></textarea>
                            </div>
                            
                            <div class="col-12 text-center">
                                <button type="submit" class="btn btn-primary-custom">
                                    <i class="bi bi-cloud-upload"></i> Subir Material
                                </button>
                            </div>
                        </div>
                    </form>
                </div>

                <!-- Lista de Materiales -->
                <h4 class="mb-3">
                    <i class="bi bi-list-ul"></i> Materiales Subidos
                    <span class="badge bg-purple" style="background-color: var(--purple-color);">
                        <%= materiales != null ? materiales.size() : 0%>
                    </span>
                </h4>

                <%
                    if (materiales != null && !materiales.isEmpty()) {
                        for (Material mat : materiales) {
                            // Determinar icono según extensión
                            String nombreArchivo = mat.getNombreArchivo();
                            String extension = "";
                            int dotIndex = nombreArchivo.lastIndexOf('.');
                            if (dotIndex > 0) {
                                extension = nombreArchivo.substring(dotIndex + 1).toLowerCase();
                            }
                            
                            String iconClass = "bi-file-earmark";
                            if (extension.equals("pdf")) {
                                iconClass = "bi-file-earmark-pdf";
                            } else if (extension.equals("doc") || extension.equals("docx")) {
                                iconClass = "bi-file-earmark-word";
                            } else if (extension.equals("xls") || extension.equals("xlsx")) {
                                iconClass = "bi-file-earmark-excel";
                            } else if (extension.equals("ppt") || extension.equals("pptx")) {
                                iconClass = "bi-file-earmark-ppt";
                            } else if (extension.equals("zip") || extension.equals("rar")) {
                                iconClass = "bi-file-earmark-zip";
                            }
                            
                            // Formatear tamaño
                            String tamanioFormateado = "";
                            long tamanio = mat.getTamanioArchivo();
                            if (tamanio < 1024) {
                                tamanioFormateado = tamanio + " B";
                            } else if (tamanio < 1024 * 1024) {
                                tamanioFormateado = String.format("%.1f KB", tamanio / 1024.0);
                            } else {
                                tamanioFormateado = String.format("%.1f MB", tamanio / (1024.0 * 1024.0));
                            }
                %>
                <div class="material-card">
                    <div class="row align-items-center">
                        <div class="col-md-1 text-center">
                            <i class="bi <%= iconClass%> file-icon"></i>
                        </div>
                        <div class="col-md-7">
                            <div class="material-info">
                                <div>
                                    <h5 class="mb-1"><%= mat.getNombreArchivo()%></h5>
                                    <% if (mat.getDescripcion() != null && !mat.getDescripcion().isEmpty()) {%>
                                    <p class="text-muted mb-0">
                                        <i class="bi bi-chat-left-text"></i> <%= mat.getDescripcion()%>
                                    </p>
                                    <% }%>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-2 text-center">
                            <span class="badge badge-custom">
                                <i class="bi bi-file-earmark"></i> <%= extension.toUpperCase()%>
                            </span>
                            <br>
                            <small class="text-muted"><%= tamanioFormateado%></small>
                            <br>
                            <small class="text-muted">
                                <%= sdf.format(mat.getFechaSubida())%>
                            </small>
                        </div>
                        <div class="col-md-2 text-center">
                            <a href="MaterialServlet?accion=eliminar&id=<%= mat.getId()%>&curso_id=<%= curso.getId()%>" 
                               class="btn btn-danger btn-sm"
                               onclick="return confirm('¿Está seguro de eliminar este material?')">
                                <i class="bi bi-trash"></i> Eliminar
                            </a>
                        </div>
                    </div>
                </div>
                <%
                        }
                    } else {
                %>
                <div class="alert alert-info text-center">
                    <i class="bi bi-info-circle"></i> No hay materiales subidos para este curso aún.
                    <br>Usa el formulario de arriba para subir tu primer material.
                </div>
                <%
                    }
                %>

            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>