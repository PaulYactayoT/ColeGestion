<%@ page import="modelo.Alumno" %>
<%@ page import="java.util.List" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    Alumno a = (Alumno) request.getAttribute("alumno");
    if (a == null) {
        response.sendRedirect("AlumnoServlet");
        return;
    }
    
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
    
    String estado = a.getEstado() != null ? a.getEstado() : "ACTIVO";
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
        case "EGRESADO":
            estadoClass = "status-graduated";
            estadoTexto = "Egresado";
            estadoIcon = "fa-graduation-cap";
            break;
        case "RETIRADO":
            estadoClass = "status-retired";
            estadoTexto = "Retirado";
            estadoIcon = "fa-door-open";
            break;
        default:
            estadoClass = "status-active";
            estadoTexto = estado;
            estadoIcon = "fa-circle";
    }
    
    String gradoNivel = a.getGradoNivel();
    String nivelClass = "";
    String nivelTexto = "";
    
    if (gradoNivel != null) {
        switch(gradoNivel) {
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
            default:
                nivelClass = "nivel-primaria";
                nivelTexto = gradoNivel;
        }
    } else {
        nivelClass = "nivel-primaria";
        nivelTexto = "No asignado";
    }
    
    // Configurar título de la página
    request.setAttribute("pageTitle", "Perfil del Estudiante");
%>

<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <title>Perfil del Estudiante - <%= a.getNombres() %> <%= a.getApellidos() %> - San Antonio</title>
    
    <!-- Incluir HEAD común -->
    <%@ include file="includes/head.jsp" %>
    
    <!-- Estilos específicos de esta página -->
    <style>
        /* Perfil especifico */
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
            background: linear-gradient(135deg, #2563eb 0%, #1e40af 100%);
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
            background: linear-gradient(135deg, #3b82f6, #135bec);
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
            color: #89CFF0;
            margin: 0;
            line-height: 1.2;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.1);
        }
        
        .profile-role {
            font-size: 1.3rem;
            color: #2d2d2d; 
            font-weight: 700;
            margin-top: 0.75rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }
        
        .profile-code {
            display: inline-flex;
            align-items: center;
            gap: 0.75rem;
            background: #f3f4f6;
            padding: 0.75rem 1.5rem;
            border-radius: 12px;
            font-weight: 600;
            color: #374151;
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
        
        .status-graduated {
            background: linear-gradient(135deg, #dbeafe, #bfdbfe);
            color: #1e40af;
        }
        
        .status-retired {
            background: linear-gradient(135deg, #fef3c7, #fde68a);
            color: #92400e;
        }
        
        .status-badge-large i {
            font-size: 1.2rem;
            animation: pulse 2s infinite;
        }
        
        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }
        
        /* Information Cards */
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
            background: linear-gradient(180deg, #135bec, #0d47a1);
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
            border-bottom: 3px solid #f3f4f6;
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
        
        .card-icon-academic {
            background: linear-gradient(135deg, #f093fb, #f5576c);
        }
        
        .card-title {
            font-size: 1.8rem;
            font-weight: 700;
            color: #1f2937;
            margin: 0;
        }
        
        .info-item {
            display: flex;
            align-items: flex-start;
            gap: 1.5rem;
            padding: 1.25rem 0;
            border-bottom: 1px solid #f3f4f6;
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
        
        .icon-primary { background: #e0e7ff; color: #135bec; }
        .icon-success { background: #d1fae5; color: #10b981; }
        .icon-warning { background: #fef3c7; color: #f59e0b; }
        .icon-danger { background: #fee2e2; color: #ef4444; }
        .icon-info { background: #dbeafe; color: #3b82f6; }
        
        .info-content {
            flex: 1;
        }
        
        .info-label {
            font-size: 0.95rem;
            font-weight: 600;
            color: #6b7280;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 0.5rem;
        }
        
        .info-value {
            font-size: 1.2rem;
            font-weight: 600;
            color: #1f2937;
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
        
        /* Responsive */
        @media (max-width: 1200px) {
            .info-cards-grid {
                grid-template-columns: 1fr;
            }
        }
        
        @media (max-width: 768px) {
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
        }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark text-[#111318] dark:text-white min-h-screen">
    
    <div class="flex h-screen overflow-hidden">
        
        <!-- SIDEBAR - Incluir barra lateral -->
        <%@ include file="includes/sidebar.jsp" %>
        
        <!-- CONTENIDO PRINCIPAL -->
        <main class="flex-1 flex flex-col overflow-y-auto">
            
            <!-- HEADER - Incluir barra superior -->
            <%@ include file="includes/header.jsp" %>
            
            <!-- CONTENIDO DE LA PÁGINA -->
            <div class="p-8">
                <div class="mb-6">
                    <h2 class="text-2xl font-bold text-[#111318] dark:text-white">Detalles del Estudiante</h2>
                    <p class="text-[#616f89] dark:text-gray-400 mt-1">Información completa del perfil académico</p>
                </div>
                
                <!-- Alertas -->
                <% 
                    String error = (String) session.getAttribute("error");
                    String mensaje = (String) session.getAttribute("mensaje");
                    
                    if (error != null) { 
                        session.removeAttribute("error");
                %>
                <div class="alert-modern alert-danger mb-6" role="alert">
                    <i class="fas fa-exclamation-circle"></i>
                    <div>
                        <strong>Error:</strong> <%= error %>
                    </div>
                </div>
                <% } %>
                
                <% if (mensaje != null) { 
                    session.removeAttribute("mensaje");
                %>
                <div class="alert-modern alert-success mb-6" role="alert">
                    <i class="fas fa-check-circle"></i>
                    <div>
                        <strong>Éxito:</strong> <%= mensaje %>
                    </div>
                </div>
                <% } %>
                
                <!-- Profile Card -->
                <div class="profile-header-card">
                    <div class="profile-cover"></div>
                    
                    <div class="profile-info-section">
                        <div class="profile-avatar-container">
                            <div class="profile-avatar relative" style="overflow: hidden; padding: 0;">
                                <% if (a.getFoto() != null && !a.getFoto().isEmpty()) { %>
                                    <img src="uploads/<%= a.getFoto() %>" alt="Foto de perfil" style="width: 100%; height: 100%; object-fit: cover;">
                                <% } else { %>
                                    <%= a.getNombres().substring(0, 1) %><%= a.getApellidos().substring(0, 1) %>
                                <% } %>
                            </div>
                            
                            <div class="profile-title-section">
                                <h1 class="profile-name"><%= a.getNombres() %> <%= a.getApellidos() %></h1>
                                <div class="profile-role">
                                    <i class="fas fa-user-graduate"></i>
                                    Estudiante de <%= a.getGradoNombre() != null ? a.getGradoNombre() : "Grado no asignado" %>
                                </div>
                                <div class="profile-code">
                                    <i class="fas fa-id-badge"></i>
                                    <%= a.getCodigoAlumno() != null ? a.getCodigoAlumno() : "Sin código" %>
                                </div>
                            </div>
                        </div>
                        
                        <div class="status-badge-large <%= estadoClass %>">
                            <i class="fas <%= estadoIcon %>"></i>
                            <%= estadoTexto %>
                        </div>
                    </div>
                </div>

                <!-- Info Cards Grid -->
                <div class="info-cards-grid">
                    
                    <!-- Información Personal -->
                    <div class="info-card">
                        <div class="card-header-section">
                            <div class="card-icon card-icon-personal">
                                <i class="fas fa-user"></i>
                            </div>
                            <h2 class="card-title">Información Personal</h2>
                        </div>
                        
                        <div class="info-item">
                            <div class="info-icon icon-primary">
                                <i class="fas fa-envelope"></i>
                            </div>
                            <div class="info-content">
                                <div class="info-label">Correo Electrónico</div>
                                <div class="info-value"><%= a.getCorreo() != null ? a.getCorreo() : "No registrado" %></div>
                            </div>
                        </div>
                        
                        <div class="info-item">
                            <div class="info-icon icon-info">
                                <i class="fas fa-id-card-alt"></i>
                            </div>
                            <div class="info-content">
                                <div class="info-label">DNI</div>
                                <div class="info-value"><%= a.getDni() != null && !a.getDni().isEmpty() ? a.getDni() : "No registrado" %></div>
                            </div>
                        </div>
                        
                        <div class="info-item">
                            <div class="info-icon icon-warning">
                                <i class="fas fa-phone"></i>
                            </div>
                            <div class="info-content">
                                <div class="info-label">Teléfono</div>
                                <div class="info-value"><%= a.getTelefono() != null && !a.getTelefono().isEmpty() ? a.getTelefono() : "No registrado" %></div>
                            </div>
                        </div>
                        
                        <div class="info-item">
                            <div class="info-icon icon-success">
                                <i class="fas fa-calendar-alt"></i>
                            </div>
                            <div class="info-content">
                                <div class="info-label">Fecha de Nacimiento</div>
                                <div class="info-value">
                                    <% if (a.getFechaNacimiento() != null) { %>
                                        <%= sdf.format(java.sql.Date.valueOf(a.getFechaNacimiento())) %>
                                        <% 
                                            LocalDate fechaNac = a.getFechaNacimiento();
                                            int edad = LocalDate.now().getYear() - fechaNac.getYear();
                                        %>
                                        <span class="text-sm text-gray-500">(<%= edad %> años)</span>
                                    <% } else { %>
                                        No registrado
                                    <% } %>
                                </div>
                            </div>
                        </div>
                        
                        <div class="info-item">
                            <div class="info-icon icon-danger">
                                <i class="fas fa-map-marker-alt"></i>
                            </div>
                            <div class="info-content">
                                <div class="info-label">Dirección</div>
                                <div class="info-value"><%= a.getDireccion() != null && !a.getDireccion().isEmpty() ? a.getDireccion() : "No registrado" %></div>
                            </div>
                        </div>
                    </div>

                    <!-- Información Académica -->
                    <div class="info-card">
                        <div class="card-header-section">
                            <div class="card-icon card-icon-academic">
                                <i class="fas fa-graduation-cap"></i>
                            </div>
                            <h2 class="card-title">Información Académica</h2>
                        </div>
                        
                        <div class="info-item">
                            <div class="info-icon icon-success">
                                <i class="fas fa-school"></i>
                            </div>
                            <div class="info-content">
                                <div class="info-label">Grado/Salón</div>
                                <div class="info-value large">
                                    <%= a.getGradoNombre() != null ? a.getGradoNombre() : "No asignado" %>
                                </div>
                            </div>
                        </div>
                        
                        <div class="info-item">
                            <div class="info-icon icon-info">
                                <i class="fas fa-layer-group"></i>
                            </div>
                            <div class="info-content">
                                <div class="info-label">Nivel Educativo</div>
                                <div class="info-value">
                                    <span class="nivel-badge <%= nivelClass %>">
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
                                <div class="info-value">
                                    <%= a.getTurnoNombre() != null ? a.getTurnoNombre() : "No asignado" %>
                                </div>
                            </div>
                        </div>
                        
                        <div class="info-item">
                            <div class="info-icon icon-primary">
                                <i class="fas fa-calendar-check"></i>
                            </div>
                            <div class="info-content">
                                <div class="info-label">Fecha de Ingreso</div>
                                <div class="info-value">
                                    <% if (a.getFechaIngreso() != null) { %>
                                        <%= sdf.format(java.sql.Date.valueOf(a.getFechaIngreso())) %>
                                    <% } else { %>
                                        No registrado
                                    <% } %>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
      
                <!-- Botones de acción -->
                <div class="flex justify-between items-center mt-8 pt-6 border-t border-[#e5e7eb]">
                    <div class="flex gap-3">
                        <a href="AlumnoServlet?accion=listar" 
                           class="btn-modern btn-secondary-modern">
                            <i class="fas fa-arrow-left"></i>
                            Volver al Listado
                        </a>
                    </div> 
                </div>
            </div>
        </main>
    </div>
    
</body>
</html>
