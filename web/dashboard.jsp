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
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Panel de Control - Administración</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@700;800&family=Poppins:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-color: #2c5aa0;
            --primary-dark: #1e3d72;
            --success-color: #20c997;
            --warning-color: #ffc107;
            --danger-color: #dc3545;
            --gray-color: #6c757d;
        }
        
        body {
            font-family: 'Poppins', sans-serif;
            background: linear-gradient(135deg, #f5f7fa 0%, #e8edf2 100%);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        .reduce-motion * { animation-duration: 0.01ms !important; animation-iteration-count: 1 !important; transition-duration: 0.01ms !important; }
        .high-contrast-invert { filter: invert(1) hue-rotate(180deg); }
        .high-contrast-yellow { background-color: #000000 !important; color: #ffff00 !important; }
        .beige-background { background-color: #f5f5dc !important; }
        .large-text { font-size: 20px !important; }
        .larger-text { font-size: 24px !important; }
        .largest-text { font-size: 28px !important; }
        .dyslexia-font { font-family: Arial !important; font-size: 1.1em !important; line-height: 1.6 !important; letter-spacing: 0.5px !important; }

        .main-content {
            flex: 1;
            padding: 50px 20px;
        }

        .panel-container {
            max-width: 1100px;
            margin: 0 auto;
            background: white;
            border-radius: 30px;
            padding: 50px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.08);
        }

        /* Header mejorado */
        .panel-header {
            text-align: center;
            margin-bottom: 45px;
            animation: fadeInDown 0.6s ease;
        }

        .panel-title {
            font-size: 2.5rem;
            font-weight: 800;
            color: #2c3e50;
            margin-bottom: 12px;
            font-family: 'Montserrat', sans-serif;
            letter-spacing: -1px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 15px;
        }

        .title-icon {
            width: 50px;
            height: 50px;
            background: linear-gradient(135deg, #2c5aa0, #1e3d72);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 8px 20px rgba(44, 90, 160, 0.3);
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.05); }
        }

        .divider {
            width: 80px;
            height: 4px;
            background: linear-gradient(90deg, #2c5aa0, #1e3d72);
            margin: 0 auto;
            border-radius: 10px;
        }

        /* Resumen mejorado */
        .resumen-sistema {
            background: linear-gradient(135deg, #2c5aa0 0%, #1e3d72 100%);
            border-radius: 25px;
            padding: 35px;
            margin-bottom: 45px;
            box-shadow: 0 15px 40px rgba(44, 90, 160, 0.25);
            position: relative;
            overflow: hidden;
            animation: fadeIn 0.8s ease;
        }

        .resumen-sistema::before {
            content: '';
            position: absolute;
            top: -50%;
            right: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 70%);
            animation: rotate 20s linear infinite;
        }

        @keyframes rotate {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
        }

        .resumen-header {
            color: white;
            font-size: 1.3rem;
            font-weight: 700;
            margin-bottom: 25px;
            display: flex;
            align-items: center;
            gap: 12px;
            position: relative;
            z-index: 1;
        }

        .resumen-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 20px;
            position: relative;
            z-index: 1;
        }

        .stat-item {
            background: rgba(255, 255, 255, 0.15);
            backdrop-filter: blur(10px);
            border: 2px solid rgba(255, 255, 255, 0.25);
            border-radius: 18px;
            padding: 25px;
            text-align: center;
            transition: all 0.3s;
        }

        .stat-item:hover {
            transform: translateY(-8px) scale(1.03);
            background: rgba(255, 255, 255, 0.25);
            box-shadow: 0 12px 30px rgba(0, 0, 0, 0.15);
        }

        .stat-icon {
            font-size: 2.5rem;
            margin-bottom: 10px;
            filter: drop-shadow(0 4px 8px rgba(0,0,0,0.2));
        }

        .stat-number {
            font-size: 3rem;
            font-weight: 800;
            color: white;
            margin-bottom: 5px;
            text-shadow: 0 2px 10px rgba(0,0,0,0.2);
        }

        .stat-label {
            color: rgba(255, 255, 255, 0.95);
            font-size: 1rem;
            font-weight: 600;
        }

        /* Grid mejorado */
        .gestion-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(340px, 1fr));
            gap: 30px;
        }

        /* Cards mejoradas */
        .gestion-card {
            background: white;
            border-radius: 22px;
            padding: 35px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.06);
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
            overflow: hidden;
            border: 2px solid #f8f9fa;
            animation: fadeInUp 0.6s ease;
            animation-fill-mode: both;
        }

        .gestion-card:nth-child(1) { animation-delay: 0.1s; }
        .gestion-card:nth-child(2) { animation-delay: 0.2s; }
        .gestion-card:nth-child(3) { animation-delay: 0.3s; }
        .gestion-card:nth-child(4) { animation-delay: 0.4s; }
        .gestion-card:nth-child(5) { animation-delay: 0.5s; }

        .gestion-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 5px;
        }

        .card-alumnos::before { background: linear-gradient(90deg, #2c5aa0, #1e3d72); }
        .card-profesores::before { background: linear-gradient(90deg, #20c997, #17a882); }
        .card-cursos::before { background: linear-gradient(90deg, #ffc107, #ffb300); }
        .card-grados::before { background: linear-gradient(90deg, #dc3545, #c82333); }
        .card-usuarios::before { background: linear-gradient(90deg, #6c757d, #545b62); }

        .gestion-card:hover {
            transform: translateY(-12px);
            box-shadow: 0 20px 50px rgba(0, 0, 0, 0.15);
            border-color: #e9ecef;
        }

        /* Iconos grandes mejorados */
        .card-icon-wrapper {
            width: 85px;
            height: 85px;
            border-radius: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 25px;
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
            position: relative;
        }

        .card-icon-wrapper::after {
            content: '';
            position: absolute;
            top: -3px;
            left: -3px;
            right: -3px;
            bottom: -3px;
            background: inherit;
            border-radius: 20px;
            filter: blur(15px);
            opacity: 0.6;
            z-index: -1;
        }

        .card-alumnos .card-icon-wrapper { background: linear-gradient(135deg, #2c5aa0, #1e3d72); }
        .card-profesores .card-icon-wrapper { background: linear-gradient(135deg, #20c997, #17a882); }
        .card-cursos .card-icon-wrapper { background: linear-gradient(135deg, #ffc107, #ffb300); }
        .card-grados .card-icon-wrapper { background: linear-gradient(135deg, #dc3545, #c82333); }
        .card-usuarios .card-icon-wrapper { background: linear-gradient(135deg, #6c757d, #545b62); }

        .card-icon-wrapper i {
            font-size: 2.5rem;
            color: white;
        }

        .card-title {
            font-size: 1.6rem;
            font-weight: 700;
            color: #2c3e50;
            margin-bottom: 15px;
            font-family: 'Montserrat', sans-serif;
        }

        .card-description {
            color: #6c757d;
            font-size: 0.95rem;
            line-height: 1.7;
            margin-bottom: 28px;
        }

        /* Botones mejorados */
        .btn-gestionar {
            width: 100%;
            padding: 15px 25px;
            border: none;
            border-radius: 12px;
            font-size: 1.05rem;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s ease;
            color: white;
            font-family: 'Montserrat', sans-serif;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            text-decoration: none;
            position: relative;
            overflow: hidden;
        }

        .btn-gestionar::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 0;
            height: 0;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.3);
            transform: translate(-50%, -50%);
            transition: width 0.6s, height 0.6s;
        }

        .btn-gestionar:hover::before {
            width: 350px;
            height: 350px;
        }

        .btn-content {
            position: relative;
            z-index: 1;
        }

        .card-alumnos .btn-gestionar {
            background: #2c5aa0;
            box-shadow: 0 6px 20px rgba(44, 90, 160, 0.35);
        }

        .card-alumnos .btn-gestionar:hover {
            background: #1e3d72;
            box-shadow: 0 8px 25px rgba(44, 90, 160, 0.45);
            transform: translateY(-3px);
            color: white;
        }

        .card-profesores .btn-gestionar {
            background: #20c997;
            box-shadow: 0 6px 20px rgba(32, 201, 151, 0.35);
        }

        .card-profesores .btn-gestionar:hover {
            background: #17a882;
            box-shadow: 0 8px 25px rgba(32, 201, 151, 0.45);
            transform: translateY(-3px);
            color: white;
        }

        .card-cursos .btn-gestionar {
            background: #ffc107;
            box-shadow: 0 6px 20px rgba(255, 193, 7, 0.35);
        }

        .card-cursos .btn-gestionar:hover {
            background: #ffb300;
            box-shadow: 0 8px 25px rgba(255, 193, 7, 0.45);
            transform: translateY(-3px);
            color: white;
        }

        .card-grados .btn-gestionar {
            background: #dc3545;
            box-shadow: 0 6px 20px rgba(220, 53, 69, 0.35);
        }

        .card-grados .btn-gestionar:hover {
            background: #c82333;
            box-shadow: 0 8px 25px rgba(220, 53, 69, 0.45);
            transform: translateY(-3px);
            color: white;
        }

        .card-usuarios .btn-gestionar {
            background: #6c757d;
            box-shadow: 0 6px 20px rgba(108, 117, 125, 0.35);
        }

        .card-usuarios .btn-gestionar:hover {
            background: #545b62;
            box-shadow: 0 8px 25px rgba(108, 117, 125, 0.45);
            transform: translateY(-3px);
            color: white;
        }

        /* Animaciones */
        @keyframes fadeInDown {
            from {
                opacity: 0;
                transform: translateY(-30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(40px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* Responsive */
        @media (max-width: 768px) {
            .panel-container {
                padding: 30px 25px;
                border-radius: 20px;
            }

            .panel-title {
                font-size: 2rem;
            }

            .gestion-grid {
                grid-template-columns: 1fr;
                gap: 20px;
            }

            .resumen-stats {
                grid-template-columns: 1fr 1fr;
            }
        }
    </style>
</head>
<body>
    <jsp:include page="header.jsp" />

    <div class="main-content">
        <div class="panel-container">
            
            <div class="panel-header">
                <h1 class="panel-title">
                    <span class="title-icon">
                        <i class="bi bi-speedometer2" style="color: white; font-size: 1.5rem;"></i>
                    </span>
                    Panel de Administración
                </h1>
                <div class="divider"></div>
            </div>

            <div class="resumen-sistema">
                <div class="resumen-header">
                    <i class="bi bi-graph-up"></i> Resumen del Sistema
                </div>
                <div class="resumen-stats">
                    <div class="stat-item">
                        <div class="stat-icon">👥</div>
                        <div class="stat-number">250</div>
                        <div class="stat-label">Alumnos</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-icon">👨‍🏫</div>
                        <div class="stat-number">25</div>
                        <div class="stat-label">Profesores</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-icon">📚</div>
                        <div class="stat-number">15</div>
                        <div class="stat-label">Cursos</div>
                    </div>
                    <div class="stat-item">
                        <div class="stat-icon">🎓</div>
                        <div class="stat-number">8</div>
                        <div class="stat-label">Grados</div>
                    </div>
                </div>
            </div>

            <div class="gestion-grid">
                
                <div class="gestion-card card-alumnos">
                    <div class="card-icon-wrapper">
                        <i class="fas fa-user-graduate"></i>
                    </div>
                    <h3 class="card-title">Gestión de Alumnos</h3>
                    <p class="card-description">
                        Administra la información académica y personal de todos los alumnos del colegio.
                    </p>
                    <a href="AlumnoServlet" class="btn-gestionar">
                        <span class="btn-content">
                            Gestionar Alumnos <i class="bi bi-arrow-right"></i>
                        </span>
                    </a>
                </div>

                <div class="gestion-card card-profesores">
                    <div class="card-icon-wrapper">
                        <i class="fas fa-chalkboard-teacher"></i>
                    </div>
                    <h3 class="card-title">Gestión de Profesores</h3>
                    <p class="card-description">
                        Administra el personal docente, asignación de cursos y información profesional.
                    </p>
                    <a href="ProfesorServlet" class="btn-gestionar">
                        <span class="btn-content">
                            Gestionar Profesores <i class="bi bi-arrow-right"></i>
                        </span>
                    </a>
                </div>

                <div class="gestion-card card-cursos">
                    <div class="card-icon-wrapper">
                        <i class="fas fa-book"></i>
                    </div>
                    <h3 class="card-title">Gestión de Cursos</h3>
                    <p class="card-description">
                        Configura y administra los cursos académicos, materias y asignaciones.
                    </p>
                    <a href="CursoServlet" class="btn-gestionar">
                        <span class="btn-content">
                            Gestionar Cursos <i class="bi bi-arrow-right"></i>
                        </span>
                    </a>
                </div>

                <div class="gestion-card card-grados">
                    <div class="card-icon-wrapper">
                        <i class="fas fa-layer-group"></i>
                    </div>
                    <h3 class="card-title">Gestión de Grados</h3>
                    <p class="card-description">
                        Administra los grados académicos, secciones y niveles del sistema educativo.
                    </p>
                    <a href="GradoServlet" class="btn-gestionar">
                        <span class="btn-content">
                            Gestionar Grados <i class="bi bi-arrow-right"></i>
                        </span>
                    </a>
                </div>

                <div class="gestion-card card-usuarios">
                    <div class="card-icon-wrapper">
                        <i class="fas fa-users-cog"></i>
                    </div>
                    <h3 class="card-title">Gestión de Usuarios</h3>
                    <p class="card-description">
                        Administra los usuarios del sistema, permisos y roles de acceso.
                    </p>
                    <a href="UsuarioServlet" class="btn-gestionar">
                        <span class="btn-content">
                            Gestionar Usuarios <i class="bi bi-arrow-right"></i>
                        </span>
                    </a>
                </div>

            </div>

        </div>
    </div>

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
                        <a href="https://www.facebook.com/" class="text-white fs-6 mb-1 text-decoration-none"><i class="fab fa-facebook me-2"></i>Facebook</a>
                        <a href="https://www.instagram.com/" class="text-white fs-6 mb-1 text-decoration-none"><i class="fab fa-instagram me-2"></i>Instagram</a>
                        <a href="https://twitter.com/" class="text-white fs-6 mb-1 text-decoration-none"><i class="fab fa-twitter me-2"></i>Twitter</a>
                        <a href="https://www.youtube.com/" class="text-white fs-6 mb-0 text-decoration-none"><i class="fab fa-youtube me-2"></i>YouTube</a>
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