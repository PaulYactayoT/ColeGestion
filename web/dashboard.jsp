<%-- 
    Document   : dashboard
    Created on : 1 may. 2025, 1:24:01 p. m.
    Author     : Juan Pablo Amaya
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="javax.servlet.http.HttpSession" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect("index.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Panel de Control - Administración</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-color: #2c5aa0;
            --primary-dark: #1e3d72;
            --primary-light: #4a7bc8;
            --accent-color: #28a745;
            --warning-color: #ffc107;
            --danger-color: #dc3545;
            --success-color: #20c997;
            --dark-color: #2d3748;
            --light-color: #f8f9fa;
            --gray-color: #6c757d;
        }
        
        body {
            background: linear-gradient(135deg, #f5f7fa 0%, #e4e8f0 100%);
            background-size: cover;
            background-position: center;
            background-attachment: fixed;
            min-height: 100vh;
            font-family: 'Poppins', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        .dashboard-card {
            background-color: rgba(255, 255, 255, 0.95);
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.08);
            transition: all 0.3s ease;
            height: 100%;
            border-left: 4px solid var(--primary-color);
            backdrop-filter: blur(10px);
        }
        
        .dashboard-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 35px rgba(0,0,0,0.15);
        }
        
        .dashboard-card h5 {
            color: var(--dark-color);
            font-weight: 700;
            margin-bottom: 15px;
        }
        
        .dashboard-card p {
            color: var(--gray-color);
            margin-bottom: 20px;
            line-height: 1.5;
        }
        
        /* Botones armonizados - Mismo patrón que Padre/Profesor */
        .btn-dashboard {
            padding: 0.6rem 1.2rem;
            border: none;
            border-radius: 10px;
            font-weight: 600;
            font-size: 0.9rem;
            transition: all 0.3s ease;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            min-width: 140px;
            color: white; /* Texto blanco por defecto para buen contraste */
        }
        
        .btn-dashboard:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(0,0,0,0.15);
            color: white; /* Mantener texto blanco en hover */
        }
        
        .btn-primary-dashboard {
            background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
        }
        
        .btn-primary-dashboard:hover {
            background: linear-gradient(135deg, var(--primary-dark), var(--primary-color));
        }
        
        .btn-success-dashboard {
            background: linear-gradient(135deg, var(--success-color), #1ba87e);
        }
        
        .btn-success-dashboard:hover {
            background: linear-gradient(135deg, #1ba87e, var(--success-color));
        }
        
        .btn-warning-dashboard {
            background: linear-gradient(135deg, var(--warning-color), #e0a800);
            color: #212529; /* Texto oscuro para contraste con fondo amarillo */
        }
        
        .btn-warning-dashboard:hover {
            background: linear-gradient(135deg, #e0a800, var(--warning-color));
            color: #212529; /* Mantener texto oscuro en hover */
        }

        .btn-danger-dashboard {
            background: linear-gradient(135deg, var(--danger-color), #c82333);
        }
        
        .btn-danger-dashboard:hover {
            background: linear-gradient(135deg, #c82333, var(--danger-color));
        }
        
        .btn-info-dashboard {
            background: linear-gradient(135deg, #17a2b8, #138496);
        }
        
        .btn-info-dashboard:hover {
            background: linear-gradient(135deg, #138496, #17a2b8);
        }
        
        .btn-secondary-dashboard {
            background: linear-gradient(135deg, #6c757d, #5a6268);
        }
        
        .btn-secondary-dashboard:hover {
            background: linear-gradient(135deg, #5a6268, #6c757d);
        }
        
        /* Stats Card - Similar a las tarjetas de estadísticas */
        .stats-card {
            background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
            color: white;
            border: none;
            border-radius: 15px;
            box-shadow: 0 8px 25px rgba(44, 90, 160, 0.3);
        }
        
        .stats-card .btn {
            border-radius: 10px;
            font-weight: 600;
            transition: all 0.3s ease;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        
        .stats-card .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 15px rgba(0,0,0,0.2);
        }
        
        .page-title {
            color: var(--dark-color);
            font-weight: 800;
            text-align: center;
            margin-bottom: 40px;
            position: relative;
            padding-bottom: 15px;
        }
        
        .page-title::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 50%;
            transform: translateX(-50%);
            width: 100px;
            height: 4px;
            background: linear-gradient(90deg, var(--primary-color), var(--primary-dark));
            border-radius: 2px;
        }
        
        footer {
            margin-top: 50px;
        }
        
        /* Icon colors matching the pattern */
        .icon-primary { color: var(--primary-color); }
        .icon-success { color: var(--success-color); }
        .icon-warning { color: var(--warning-color); }
        .icon-danger { color: var(--danger-color); }
        .icon-secondary { color: var(--secondary-color); }
        .icon-info { color: #17a2b8; }
        
        /* Estilos de accesibilidad - Compatibles con el sistema del header */
        .reduce-motion * {
            animation-duration: 0.01ms !important;
            animation-iteration-count: 1 !important;
            transition-duration: 0.01ms !important;
        }
        
        .high-contrast-invert {
            filter: invert(1) hue-rotate(180deg);
        }
        
        .high-contrast-yellow {
            background-color: #000000 !important;
            color: #ffff00 !important;
        }
        
        .beige-background {
            background-color: #f5f5dc !important;
        }
        
        .large-text {
            font-size: 20px !important;
        }
        
        .larger-text {
            font-size: 24px !important;
        }
        
        .largest-text {
            font-size: 28px !important;
        }
        
        .dyslexia-font {
            font-family: Arial, Helvetica, sans-serif !important;
            font-size: 1.1em !important;
            line-height: 1.6 !important;
            letter-spacing: 0.5px !important;
        }
    </style>
</head>
<body class="dashboard-page">

    <!-- Header con Sistema de Accesibilidad -->
    <jsp:include page="header.jsp" />

    <div class="container mt-5">
        <h2 class="page-title">
            <i class="bi bi-speedometer2 me-2"></i>Panel de Administración
        </h2>

        <!-- Tarjeta de Estadísticas Rápidas - CORREGIDA -->
        <div class="card stats-card mb-5">
            <div class="card-body">
                <div class="row align-items-center">
                    <div class="col-md-8">
                        <h5 class="card-title mb-3 text-white">
                            <i class="bi bi-graph-up me-2"></i>Resumen del Sistema
                        </h5>
                        <div class="row mt-3">
                            <div class="col-6 col-md-3 mb-2">
                                <small class="text-light"><i class="bi bi-people-fill text-success me-1"></i> <strong>250</strong> Alumnos</small>
                            </div>
                            <div class="col-6 col-md-3 mb-2">
                                <small class="text-light"><i class="bi bi-person-badge text-warning me-1"></i> <strong>25</strong> Profesores</small>
                            </div>
                            <div class="col-6 col-md-3 mb-2">
                                <small class="text-light"><i class="bi bi-book text-danger me-1"></i> <strong>15</strong> Cursos</small>
                            </div>
                            <div class="col-6 col-md-3 mb-2">
                                <small class="text-light"><i class="bi bi-layers text-info me-1"></i> <strong>8</strong> Grados</small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row g-4 justify-content-center">

            <!-- Gestión de Alumnos -->
            <div class="col-md-4">
                <div class="dashboard-card">
                    <h5 class="fw-bold mb-3">
                        <i class="fas fa-user-graduate icon-primary me-2"></i>Gestión de Alumnos
                    </h5>
                    <p>Administra la información académica y personal de todos los alumnos del colegio.</p>
                    <a href="AlumnoServlet" class="btn btn-primary-dashboard">
                        <i class="bi bi-arrow-right me-1"></i>Gestionar Alumnos
                    </a>
                </div>
            </div>

            <!-- Gestión de Profesores -->
            <div class="col-md-4">
                <div class="dashboard-card">
                    <h5 class="fw-bold mb-3">
                        <i class="fas fa-chalkboard-teacher icon-success me-2"></i>Gestión de Profesores
                    </h5>
                    <p>Administra el personal docente, asignación de cursos y información profesional.</p>
                    <a href="ProfesorServlet" class="btn btn-success-dashboard">
                        <i class="bi bi-arrow-right me-1"></i>Gestionar Profesores
                    </a>
                </div>
            </div>

            <!-- Gestión de Cursos -->
            <div class="col-md-4">
                <div class="dashboard-card">
                    <h5 class="fw-bold mb-3">
                        <i class="fas fa-book icon-warning me-2"></i>Gestión de Cursos
                    </h5>
                    <p>Configura y administra los cursos académicos, materias y asignaciones.</p>
                    <a href="CursoServlet" class="btn btn-warning-dashboard">
                        <i class="bi bi-arrow-right me-1"></i>Gestionar Cursos
                    </a>
                </div>
            </div>

            <!-- Gestión de Grados - CORREGIDA -->
            <div class="col-md-4">
                <div class="dashboard-card">
                    <h5 class="fw-bold mb-3">
                        <i class="fas fa-layer-group icon-danger me-2"></i>Gestión de Grados
                    </h5>
                    <p>Administra los grados académicos, secciones y niveles del sistema educativo.</p>
                    <a href="GradoServlet" class="btn btn-danger-dashboard">
                        <i class="bi bi-arrow-right me-1"></i>Gestionar Grados
                    </a>
                </div>
            </div>

            <!-- Gestión de Usuarios -->
            <div class="col-md-4">
                <div class="dashboard-card">
                    <h5 class="fw-bold mb-3">
                        <i class="fas fa-users-cog icon-secondary me-2"></i>Gestión de Usuarios
                    </h5>
                    <p>Administra los usuarios del sistema, permisos y roles de acceso.</p>
                    <a href="UsuarioServlet" class="btn btn-secondary-dashboard">
                        <i class="bi bi-arrow-right me-1"></i>Gestionar Usuarios
                    </a>
                </div>
            </div>


        </div>
    </div>

    <!-- Footer Unificado -->
    <footer class="bg-dark text-white py-4 mt-5">
        <div class="container text-center text-md-start">
            <div class="row">
                <div class="col-md-4 mb-3">
                    <div class="logo-container text-center">
                        <img src="assets/img/logosa.png" alt="Logo" class="img-fluid mb-2" width="80" height="auto">
                        <p class="fs-6 mb-0">"Líderes en educación de calidad al más alto nivel"</p>
                    </div>
                </div>
                <div class="col-md-4 mb-3">
                    <h5 class="fs-6 fw-bold">Contacto:</h5>
                    <p class="fs-6 mb-1">Dirección: Av. El Sol 461, San Juan de Lurigancho 15434</p>
                    <p class="fs-6 mb-1">Teléfono: 987654321</p>
                    <p class="fs-6 mb-0">Correo: colegiosanantonio@gmail.com</p>
                </div>
                <div class="col-md-4 mb-3">
                    <h5 class="fs-6 fw-bold">Síguenos:</h5>
                    <div class="d-flex flex-column">
                        <a href="https://www.facebook.com/" class="text-white fs-6 mb-1 text-decoration-none">
                            <i class="fab fa-facebook me-2"></i>Facebook
                        </a>
                        <a href="https://www.instagram.com/" class="text-white fs-6 mb-1 text-decoration-none">
                            <i class="fab fa-instagram me-2"></i>Instagram
                        </a>
                        <a href="https://twitter.com/" class="text-white fs-6 mb-1 text-decoration-none">
                            <i class="fab fa-twitter me-2"></i>Twitter
                        </a>
                        <a href="https://www.youtube.com/" class="text-white fs-6 mb-0 text-decoration-none">
                            <i class="fab fa-youtube me-2"></i>YouTube
                        </a>
                    </div>
                </div>
            </div>
            <div class="text-center mt-3 pt-3 border-top border-secondary">
                <p class="fs-6 mb-0">&copy; 2025 Colegio SA - Todos los derechos reservados</p>
            </div>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>