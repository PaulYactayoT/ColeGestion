<%@ page import="modelo.Profesor" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    Profesor p = (Profesor) request.getAttribute("profesor");
    if (p == null) {
        response.sendRedirect("ProfesorServlet?accion=listar");
        return;
    }
    
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Perfil Profesional - <%= p.getNombres() %> <%= p.getApellidos() %></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="assets/css/estilos.css">
    <style>
        :root {
            --primary-color: #4f46e5;
            --primary-dark: #4338ca;
            --primary-light: #818cf8;
            --baby-blue: #89CFF0;
            --success-color: #10b981;
            --danger-color: #ef4444;
            --warning-color: #f59e0b;
            --info-color: #3b82f6;
            --dark-color: #1f2937;
            --gray-50: #f9fafb;
            --gray-100: #f3f4f6;
            --gray-200: #e5e7eb;
            --gray-600: #4b5563;
            --gray-700: #374151;
            --gray-800: #1f2937;
            --light-gray-bg: #e8e9eb;
        }

        body {
            background: var(--light-gray-bg);
            min-height: 100vh;
            padding-bottom: 2rem;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        .profile-container {
            max-width: 1400px;
            margin: 2rem auto;
            padding: 0 2rem;
        }

        /* Header Card con Avatar */
        .profile-header-card {
            background: white;
            border-radius: 20px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.15);
            overflow: hidden;
            margin-bottom: 2rem;
            position: relative;
        }

        .profile-cover {
            height: 250px;
            background: linear-gradient(135deg, var(--primary-color) 0%, var(--primary-dark) 100%);
            position: relative;
            overflow: hidden;
        }

        .profile-cover::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1440 320"><path fill="%23ffffff" fill-opacity="0.1" d="M0,96L48,112C96,128,192,160,288,160C384,160,480,128,576,122.7C672,117,768,139,864,154.7C960,171,1056,181,1152,165.3C1248,149,1344,107,1392,85.3L1440,64L1440,320L1392,320C1344,320,1248,320,1152,320C1056,320,960,320,864,320C768,320,672,320,576,320C480,320,384,320,288,320C192,320,96,320,48,320L0,320Z"></path></svg>') no-repeat bottom;
            background-size: cover;
        }

        .profile-info-section {
            padding: 0 3rem 2.5rem 3rem;
            position: relative;
            margin-top: -100px;
        }

        .profile-avatar-container {
            display: flex;
            align-items: flex-end;
            gap: 2.5rem;
            margin-bottom: 2rem;
        }

        .profile-avatar {
            width: 200px;
            height: 200px;
            border-radius: 20px;
            background: linear-gradient(135deg, var(--primary-light), var(--primary-color));
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 5rem;
            color: white;
            font-weight: 700;
            box-shadow: 0 15px 50px rgba(0, 0, 0, 0.3);
            border: 6px solid white;
            text-transform: uppercase;
            position: relative;
            z-index: 10;
        }

        .profile-title-section {
            flex: 1;
            padding-bottom: 1.5rem;
        }

        .profile-name {
            font-size: 3rem;
            font-weight: 700;
            color: var(--baby-blue);
            margin: 0;
            line-height: 1.2;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.1);
        }

        .profile-role {
            font-size: 1.3rem;
            color: var(--gray-600);
            margin-top: 0.75rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }

        .profile-code {
            display: inline-flex;
            align-items: center;
            gap: 0.75rem;
            background: var(--gray-100);
            padding: 0.75rem 1.5rem;
            border-radius: 12px;
            font-weight: 600;
            color: var(--gray-700);
            margin-top: 1rem;
            font-size: 1.05rem;
        }

        /* Status Badge */
        .status-badge-large {
            position: absolute;
            top: 2.5rem;
            right: 3rem;
            padding: 1rem 2rem;
            border-radius: 50px;
            font-weight: 700;
            font-size: 1.1rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            display: flex;
            align-items: center;
            gap: 0.75rem;
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.2);
        }

        .status-active {
            background: linear-gradient(135deg, #d1fae5, #a7f3d0);
            color: #065f46;
        }

        .status-inactive {
            background: linear-gradient(135deg, #fee2e2, #fecaca);
            color: #991b1b;
        }

        .status-license {
            background: linear-gradient(135deg, #fef3c7, #fde68a);
            color: #92400e;
        }

        .status-retired {
            background: linear-gradient(135deg, #e0e7ff, #c7d2fe);
            color: #3730a3;
        }

        .status-badge-large i {
            font-size: 1.2rem;
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }

        /* Information Cards - MÁS GRANDES */
        .info-cards-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 2rem;
            margin-top: 2rem;
        }

        .info-card {
            background: white;
            border-radius: 20px;
            padding: 3rem;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.12);
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
            min-height: 500px;
        }

        .info-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 6px;
            height: 100%;
            background: linear-gradient(180deg, var(--primary-color), var(--primary-dark));
        }

        .info-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 50px rgba(0, 0, 0, 0.18);
        }

        .card-header-section {
            display: flex;
            align-items: center;
            gap: 1.5rem;
            margin-bottom: 2rem;
            padding-bottom: 1.5rem;
            border-bottom: 3px solid var(--gray-100);
        }

        .card-icon {
            width: 70px;
            height: 70px;
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2rem;
            color: white;
        }

        .card-icon-personal {
            background: linear-gradient(135deg, #667eea, #764ba2);
        }

        .card-icon-professional {
            background: linear-gradient(135deg, #f093fb, #f5576c);
        }

        .card-title {
            font-size: 1.8rem;
            font-weight: 700;
            color: var(--gray-800);
            margin: 0;
        }

        .info-item {
            display: flex;
            align-items: flex-start;
            gap: 1.5rem;
            padding: 1.25rem 0;
            border-bottom: 1px solid var(--gray-100);
        }

        .info-item:last-child {
            border-bottom: none;
        }

        .info-icon {
            width: 50px;
            height: 50px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            font-size: 1.3rem;
        }

        .icon-primary { background: #e0e7ff; color: var(--primary-color); }
        .icon-success { background: #d1fae5; color: var(--success-color); }
        .icon-warning { background: #fef3c7; color: var(--warning-color); }
        .icon-danger { background: #fee2e2; color: var(--danger-color); }
        .icon-info { background: #dbeafe; color: var(--info-color); }

        .info-content {
            flex: 1;
        }

        .info-label {
            font-size: 0.95rem;
            font-weight: 600;
            color: var(--gray-600);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 0.5rem;
        }

        .info-value {
            font-size: 1.2rem;
            font-weight: 600;
            color: var(--gray-800);
            word-break: break-word;
        }

        .info-value.large {
            font-size: 1.4rem;
        }

        /* Nivel Badge */
        .nivel-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.75rem;
            padding: 0.75rem 1.5rem;
            border-radius: 12px;
            font-weight: 700;
            font-size: 1.1rem;
            text-transform: uppercase;
        }

        .nivel-inicial {
            background: linear-gradient(135deg, #dbeafe, #bfdbfe);
            color: #1e40af;
        }

        .nivel-primaria {
            background: linear-gradient(135deg, #d1fae5, #a7f3d0);
            color: #065f46;
        }

        .nivel-secundaria {
            background: linear-gradient(135deg, #fef3c7, #fde68a);
            color: #92400e;
        }

        .nivel-todos {
            background: linear-gradient(135deg, #e0e7ff, #c7d2fe);
            color: #3730a3;
        }

        /* Action Buttons */
        .action-buttons-container {
            background: white;
            border-radius: 20px;
            padding: 2.5rem;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.12);
            margin-top: 2rem;
            display: flex;
            justify-content: center;
        }

        .btn-modern {
            padding: 1.25rem 3rem;
            border-radius: 15px;
            font-weight: 700;
            font-size: 1.1rem;
            border: none;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 1rem;
            text-decoration: none;
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15);
        }

        .btn-modern i {
            font-size: 1.3rem;
        }

        .btn-secondary-modern {
            background: linear-gradient(135deg, #6b7280, #4b5563);
            color: white;
        }

        .btn-secondary-modern:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 30px rgba(107, 114, 128, 0.4);
            color: white;
        }

        /* Responsive */
        @media (max-width: 1200px) {
            .info-cards-grid {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 768px) {
            .profile-container {
                padding: 0 1rem;
            }

            .profile-cover {
                height: 180px;
            }

            .profile-avatar {
                width: 140px;
                height: 140px;
                font-size: 3.5rem;
            }

            .profile-info-section {
                padding: 0 1.5rem 1.5rem 1.5rem;
                margin-top: -70px;
            }

            .profile-avatar-container {
                flex-direction: column;
                align-items: center;
                text-align: center;
            }

            .profile-name {
                font-size: 2rem;
            }

            .status-badge-large {
                position: static;
                margin-top: 1rem;
            }

            .info-cards-grid {
                grid-template-columns: 1fr;
            }

            .info-card {
                padding: 2rem;
                min-height: auto;
            }

            .card-title {
                font-size: 1.4rem;
            }
        }

        /* Animations */
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .profile-header-card,
        .info-card,
        .action-buttons-container {
            animation: fadeInUp 0.6s ease;
        }

        .info-card:nth-child(1) { animation-delay: 0.1s; }
        .info-card:nth-child(2) { animation-delay: 0.2s; }
    </style>
</head>
<body>
    <jsp:include page="header.jsp" />

    <div class="profile-container">
        
        <!-- Header Card con Avatar y Nombre -->
        <div class="profile-header-card">
            <div class="profile-cover"></div>
            
            <div class="profile-info-section">
                <div class="profile-avatar-container">
                    <div class="profile-avatar">
                        <%= p.getNombres().substring(0, 1) + p.getApellidos().substring(0, 1) %>
                    </div>
                    
                    <div class="profile-title-section">
                        <h1 class="profile-name"><%= p.getNombres() %> <%= p.getApellidos() %></h1>
                        <div class="profile-role">
                            <i class="fas fa-chalkboard-teacher"></i>
                            Docente de <%= p.getAreaNombre() != null ? p.getAreaNombre() : "Área no asignada" %>
                        </div>
                        <div class="profile-code">
                            <i class="fas fa-id-badge"></i>
                            <%= p.getCodigoProfesor() != null ? p.getCodigoProfesor() : "Sin código" %>
                        </div>
                    </div>
                </div>
                
                <!-- Estado Badge -->
                <% 
                    String estado = p.getEstado() != null ? p.getEstado() : "ACTIVO";
                    String estadoClass = "";
                    String estadoTexto = "";
                    String estadoIcon = "";
                    
                    switch(estado) {
                        case "ACTIVO":
                            estadoClass = "status-active";
                            estadoTexto = "Activo";
                            estadoIcon = "fa-circle-check";
                            break;
                        case "INACTIVO":
                            estadoClass = "status-inactive";
                            estadoTexto = "Inactivo";
                            estadoIcon = "fa-circle-xmark";
                            break;
                        case "LICENCIA":
                            estadoClass = "status-license";
                            estadoTexto = "En Licencia";
                            estadoIcon = "fa-clock";
                            break;
                        case "JUBILADO":
                            estadoClass = "status-retired";
                            estadoTexto = "Jubilado";
                            estadoIcon = "fa-umbrella-beach";
                            break;
                        default:
                            estadoClass = "status-active";
                            estadoTexto = estado;
                            estadoIcon = "fa-circle";
                    }
                %>
                <div class="status-badge-large <%= estadoClass %>">
                    <i class="fas <%= estadoIcon %>"></i>
                    <%= estadoTexto %>
                </div>
            </div>
        </div>

        <!-- Information Cards Grid -->
        <div class="info-cards-grid">
            
            <!-- Card 1: Información Personal -->
            <div class="info-card">
                <div class="card-header-section">
                    <div class="card-icon card-icon-personal">
                        <i class="fas fa-user"></i>
                    </div>
                    <h2 class="card-title">Información Personal</h2>
                </div>
                
                <div class="info-item">
                    <div class="info-icon icon-primary">
                        <i class="fas fa-id-card"></i>
                    </div>
                    <div class="info-content">
                        <div class="info-label">DNI</div>
                        <div class="info-value"><%= p.getDni() != null ? p.getDni() : "No registrado" %></div>
                    </div>
                </div>
                
                <div class="info-item">
                    <div class="info-icon icon-success">
                        <i class="fas fa-envelope"></i>
                    </div>
                    <div class="info-content">
                        <div class="info-label">Correo Electrónico</div>
                        <div class="info-value"><%= p.getCorreo() != null ? p.getCorreo() : "No registrado" %></div>
                    </div>
                </div>
                
                <div class="info-item">
                    <div class="info-icon icon-info">
                        <i class="fas fa-phone"></i>
                    </div>
                    <div class="info-content">
                        <div class="info-label">Teléfono</div>
                        <div class="info-value"><%= p.getTelefono() != null ? p.getTelefono() : "No registrado" %></div>
                    </div>
                </div>
                
                <div class="info-item">
                    <div class="info-icon icon-warning">
                        <i class="fas fa-birthday-cake"></i>
                    </div>
                    <div class="info-content">
                        <div class="info-label">Fecha de Nacimiento</div>
                        <div class="info-value">
                            <%= p.getFechaNacimiento() != null ? sdf.format(p.getFechaNacimiento()) : "No registrada" %>
                        </div>
                    </div>
                </div>
                
                <div class="info-item">
                    <div class="info-icon icon-danger">
                        <i class="fas fa-map-marker-alt"></i>
                    </div>
                    <div class="info-content">
                        <div class="info-label">Dirección</div>
                        <div class="info-value"><%= p.getDireccion() != null ? p.getDireccion() : "No registrada" %></div>
                    </div>
                </div>
            </div>

            <!-- Card 2: Información Profesional -->
            <div class="info-card">
                <div class="card-header-section">
                    <div class="card-icon card-icon-professional">
                        <i class="fas fa-briefcase"></i>
                    </div>
                    <h2 class="card-title">Información Profesional</h2>
                </div>
                
                <div class="info-item">
                    <div class="info-icon icon-primary">
                        <i class="fas fa-book"></i>
                    </div>
                    <div class="info-content">
                        <div class="info-label">Especialidad / Área</div>
                        <div class="info-value large">
                            <%= p.getAreaNombre() != null ? p.getAreaNombre() : "No asignada" %>
                        </div>
                    </div>
                </div>
                
                <div class="info-item">
                    <div class="info-icon icon-success">
                        <i class="fas fa-layer-group"></i>
                    </div>
                    <div class="info-content">
                        <div class="info-label">Nivel que Enseña</div>
                        <div class="info-value">
                            <% 
                                String nivel = p.getNivel();
                                String nivelClass = "";
                                String nivelTexto = "";
                                
                                if (nivel != null) {
                                    switch(nivel) {
                                        case "INICIAL":
                                            nivelClass = "nivel-inicial";
                                            nivelTexto = "Inicial";
                                            break;
                                        case "PRIMARIA":
                                            nivelClass = "nivel-primaria";
                                            nivelTexto = "Primaria";
                                            break;
                                        case "SECUNDARIA":
                                            nivelClass = "nivel-secundaria";
                                            nivelTexto = "Secundaria";
                                            break;
                                        case "TODOS":
                                            nivelClass = "nivel-todos";
                                            nivelTexto = "Todos los Niveles";
                                            break;
                                        default:
                                            nivelClass = "nivel-todos";
                                            nivelTexto = nivel;
                                    }
                                } else {
                                    nivelClass = "nivel-todos";
                                    nivelTexto = "No asignado";
                                }
                            %>
                            <span class="nivel-badge <%= nivelClass %>">
                                <i class="fas fa-graduation-cap"></i>
                                <%= nivelTexto %>
                            </span>
                        </div>
                    </div>
                </div>
                
                <div class="info-item">
                    <div class="info-icon icon-warning">
                        <i class="fas fa-clock"></i>
                    </div>
                    <div class="info-content">
                        <div class="info-label">Turno</div>
                        <div class="info-value"><%= p.getTurnoNombre() != null ? p.getTurnoNombre() : "Sin turno" %></div>
                    </div>
                </div>
                
                <div class="info-item">
                    <div class="info-icon icon-info">
                        <i class="fas fa-calendar-check"></i>
                    </div>
                    <div class="info-content">
                        <div class="info-label">Fecha de Contratación</div>
                        <div class="info-value">
                            <%= p.getFechaContratacion() != null ? sdf.format(p.getFechaContratacion()) : "No registrada" %>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Action Buttons - SOLO VOLVER -->
        <div class="action-buttons-container">
            <a href="ProfesorServlet?accion=listar" 
               class="btn-modern btn-secondary-modern">
                <i class="fas fa-arrow-left"></i>
                Volver al Listado
            </a>
        </div>
    </div>

    <footer class="bg-dark text-white py-4 mt-5">
        <div class="container text-center">
            <div class="row">
                <div class="col-12">
                    <p class="mb-2">&copy; 2025 Colegio San Antonio - Sistema de Gestión Educativa</p>
                    <p class="mb-0 text-white-50 small">
                        <i class="fas fa-shield-alt"></i> Datos protegidos y confidenciales
                    </p>
                </div>
            </div>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
