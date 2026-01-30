<%-- 
    Document   : gradoForm
    Created on : 1 may. 2025, 10:57:00 p. m.
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
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= esEditar ? "Editar Grado" : "Registrar Grado"%> - Colegio SA</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="assets/css/estilos.css">
    <style>
        :root {
            --primary-color: #2563eb;
            --primary-dark: #1e40af;
            --secondary-color: #64748b;
            --success-color: #10b981;
            --background-light: #f8fafc;
            --card-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            --card-shadow-hover: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
        }

        body.dashboard-page {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        .form-container {
            flex: 1;
        }

        .form-container {
            max-width: 650px;
            margin: 2rem auto;
            padding: 0 1rem;
        }

        .form-card {
            background: white;
            border-radius: 20px;
            box-shadow: var(--card-shadow-hover);
            overflow: hidden;
            animation: slideUp 0.5s ease-out;
        }

        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .form-header {
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-dark) 100%);
            color: white;
            padding: 2rem;
            text-align: center;
        }

        .form-header h2 {
            margin: 0;
            font-size: 1.75rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.75rem;
        }

        .form-header .icon {
            font-size: 2rem;
        }

        .form-body {
            padding: 2.5rem;
        }

        .form-label {
            font-weight: 600;
            color: #334155;
            margin-bottom: 0.5rem;
            font-size: 0.95rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .form-label i {
            color: var(--primary-color);
        }

        .form-control, .form-select {
            border: 2px solid #e2e8f0;
            border-radius: 10px;
            padding: 0.75rem 1rem;
            font-size: 1rem;
            transition: all 0.3s ease;
        }

        .form-control:focus, .form-select:focus {
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
        }

        .form-select {
            cursor: pointer;
            background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3e%3cpath fill='none' stroke='%232563eb' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M2 5l6 6 6-6'/%3e%3c/svg%3e");
        }

        .mb-3 {
            margin-bottom: 1.5rem !important;
        }

        .btn-group-custom {
            display: flex;
            gap: 1rem;
            margin-top: 2rem;
        }

        .btn {
            border-radius: 10px;
            padding: 0.75rem 2rem;
            font-weight: 600;
            font-size: 1rem;
            transition: all 0.3s ease;
            border: none;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            justify-content: center;
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-dark) 100%);
            flex: 1;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(37, 99, 235, 0.3);
        }

        .btn-secondary {
            background: var(--secondary-color);
            flex: 1;
        }

        .btn-secondary:hover {
            background: #475569;
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(100, 116, 139, 0.3);
        }

        .input-icon {
            position: relative;
        }

        .input-icon i {
            position: absolute;
            left: 1rem;
            top: 50%;
            transform: translateY(-50%);
            color: var(--secondary-color);
        }

        .input-icon .form-control,
        .input-icon .form-select {
            padding-left: 2.75rem;
        }

        footer {
            margin-top: auto;
            background-color: #1a1a1a !important;
        }

        footer .logo-container img {
            border-radius: 15px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.3);
            background-color: white;
            padding: 5px;
        }

        footer h5 {
            font-weight: 700;
            margin-bottom: 1rem;
            color: #fff;
            font-size: 1.1rem;
        }

        footer p {
            color: #d1d5db;
            line-height: 1.8;
        }

        footer a {
            text-decoration: none;
            transition: all 0.3s ease;
            display: inline-block;
            color: #d1d5db;
        }

        footer a:hover {
            transform: translateX(5px);
            color: #60a5fa !important;
        }

        footer .border-top {
            border-color: #374151 !important;
        }

        footer i {
            color: #60a5fa;
        }

        @media (max-width: 768px) {
            .form-body {
                padding: 1.5rem;
            }

            .form-header h2 {
                font-size: 1.5rem;
            }

            .btn-group-custom {
                flex-direction: column;
            }

            .btn {
                width: 100%;
            }
        }

        /* Animación para los campos del formulario */
        .mb-3 {
            animation: fadeIn 0.5s ease-out backwards;
        }

        .mb-3:nth-child(1) {
            animation-delay: 0.1s;
        }

        .mb-3:nth-child(2) {
            animation-delay: 0.2s;
        }

        .btn-group-custom {
            animation: fadeIn 0.5s ease-out 0.3s backwards;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
    </style>
</head>
<body class="dashboard-page">
    <jsp:include page="header.jsp" />
    
    <div class="form-container">
        <div class="form-card">
            <div class="form-header">
                <h2>
                    <i class="bi <%= esEditar ? "bi-pencil-square" : "bi-plus-circle"%> icon"></i>
                    <%= esEditar ? "Editar Grado" : "Registrar Nuevo Grado"%>
                </h2>
            </div>
            
            <div class="form-body">
                <form action="GradoServlet" method="post">
                    <input type="hidden" name="id" value="<%= esEditar ? g.getId() : ""%>">
                    
                    <div class="mb-3">
                        <label class="form-label">
                            <i class="bi bi-tag-fill"></i>
                            Nombre del Grado
                        </label>
                        <div class="input-icon">
                            <i class="bi bi-pencil"></i>
                            <input type="text" 
                                   class="form-control" 
                                   name="nombre" 
                                   value="<%= esEditar ? g.getNombre() : ""%>" 
                                   placeholder="Ej: Primer Grado, Segundo Grado..."
                                   required>
                        </div>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label">
                            <i class="bi bi-diagram-3-fill"></i>
                            Nivel Educativo
                        </label>
                        <div class="input-icon">
                            <i class="bi bi-list-ul"></i>
                            <select class="form-select" name="nivel" required>
                                <option value="">-- Selecciona un nivel --</option>
                                <option value="Inicial" <%= esEditar && g.getNivel().equals("Inicial") ? "selected" : ""%>>
                                    🎨 Inicial
                                </option>
                                <option value="Primaria" <%= esEditar && g.getNivel().equals("Primaria") ? "selected" : ""%>>
                                    📚 Primaria
                                </option>
                                <option value="Secundaria" <%= esEditar && g.getNivel().equals("Secundaria") ? "selected" : ""%>>
                                    🎓 Secundaria
                                </option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="btn-group-custom">
                        <button type="submit" class="btn btn-primary">
                            <i class="bi <%= esEditar ? "bi-check-circle" : "bi-save"%>"></i>
                            <%= esEditar ? "Actualizar Grado" : "Registrar Grado"%>
                        </button>
                        <a href="GradoServlet" class="btn btn-secondary">
                            <i class="bi bi-x-circle"></i>
                            Cancelar
                        </a>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <footer class="text-white py-4 mt-5" style="background-color: #1a1a1a;">
        <div class="container text-center text-md-start">
            <div class="row">
                <div class="col-md-4 mb-3">
                    <div class="logo-container text-center">
                        <img src="assets/img/logosa.png" alt="Logo Colegio SA" class="img-fluid mb-2" width="90" height="auto">
                        <p class="fs-6 fw-light fst-italic">"Líderes en educación de calidad al más alto nivel"</p>
                    </div>
                </div>
                <div class="col-md-4 mb-3">
                    <h5 class="fs-6"><i class="bi bi-envelope-fill me-2"></i>Contacto</h5>
                    <p class="fs-6 mb-2"><i class="bi bi-geo-alt-fill me-2"></i>Av. El Sol 461, San Juan de Lurigancho 15434</p>
                    <p class="fs-6 mb-2"><i class="bi bi-telephone-fill me-2"></i>987 654 321</p>
                    <p class="fs-6 mb-0"><i class="bi bi-envelope-at-fill me-2"></i>colegiosanantonio@gmail.com</p>
                </div>
                <div class="col-md-4 mb-3">
                    <h5 class="fs-6"><i class="bi bi-share-fill me-2"></i>Síguenos</h5>
                    <a href="https://www.facebook.com/" class="text-white d-block fs-6 mb-2">
                        <i class="bi bi-facebook me-2"></i>Facebook
                    </a>
                    <a href="https://www.instagram.com/" class="text-white d-block fs-6 mb-2">
                        <i class="bi bi-instagram me-2"></i>Instagram
                    </a>
                    <a href="https://twitter.com/" class="text-white d-block fs-6 mb-2">
                        <i class="bi bi-twitter-x me-2"></i>Twitter
                    </a>
                    <a href="https://www.youtube.com/" class="text-white d-block fs-6 mb-2">
                        <i class="bi bi-youtube me-2"></i>YouTube
                    </a>
                </div>
            </div>
            <div class="text-center mt-3 pt-3 border-top">
                <p class="fs-6 mb-0">
                    <i class="bi bi-c-circle me-1"></i>2025 Colegio SA - Todos los derechos reservados
                </p>
            </div>
        </div>
    </footer>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
