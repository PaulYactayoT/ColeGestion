<%-- 
    Document   : administrativoDetalle
    Created on : 16 feb. 2026, 7:39:16?p. m.
    Author     : Ocelot
--%>
<%@ page import="modelo.Administrativo" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Administrativo adminDetalle = (Administrativo) request.getAttribute("administrativo");
    if (adminDetalle == null) {
        response.sendRedirect("AdministrativoServlet");
        return;
    }
    
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
    
    String estadoAdmin = adminDetalle.getEstado() != null ? adminDetalle.getEstado() : "ACTIVO";
    String estadoClass = "";
    String estadoTexto = "";
    String estadoIcon = "";
    switch(estadoAdmin) {
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
            estadoClass = "status-licensed";
            estadoTexto = "Licencia";
            estadoIcon = "fa-pause-circle";
            break;
        case "JUBILADO":
            estadoClass = "status-retired";
            estadoTexto = "Jubilado";
            estadoIcon = "fa-home";
            break;
        default:
            estadoClass = "status-active";
            estadoTexto = estadoAdmin;
            estadoIcon = "fa-circle";
    }
    
    request.setAttribute("pageTitle", "Perfil del Administrativo");
%>

<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <title>Perfil del Administrativo - <%= adminDetalle.getNombres() %> <%= adminDetalle.getApellidos() %> - San Antonio</title>
    
    <%@ include file="includes/head.jsp" %>
    
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
            background: #f0f4ff;
            padding: 0.75rem 1.25rem;
            border-radius: 12px;
            font-size: 1rem;
            color: #1e40af;
            font-weight: 600;
            margin-top: 1rem;
            border: 2px solid #dbeafe;
        }
        
        .status-badge-large {
            position: absolute;
            top: 2rem;
            right: 2rem;
            padding: 1rem 2rem;
            border-radius: 50px;
            font-weight: 700;
            font-size: 1.2rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.2);
            z-index: 10;
        }
        
        .status-active {
            background: linear-gradient(135deg, #10b981, #059669);
            color: white;
        }
        
        .status-inactive {
            background: linear-gradient(135deg, #6b7280, #4b5563);
            color: white;
        }
        
        .status-licensed {
            background: linear-gradient(135deg, #f59e0b, #d97706);
            color: white;
        }
        
        .status-retired {
            background: linear-gradient(135deg, #3b82f6, #2563eb);
            color: white;
        }
        
        /* Info Cards Grid */
        .info-cards-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
            gap: 2rem;
            margin-top: 2rem;
        }
        
        .info-card {
            background: white;
            border-radius: 16px;
            padding: 2rem;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
            transition: all 0.3s ease;
        }
        
        .info-card:hover {
            box-shadow: 0 8px 30px rgba(0, 0, 0, 0.15);
            transform: translateY(-5px);
        }
        
        .card-header-section {
            display: flex;
            align-items: center;
            gap: 1rem;
            margin-bottom: 2rem;
            padding-bottom: 1.5rem;
            border-bottom: 3px solid #e5e7eb;
        }
        
        .card-icon {
            width: 60px;
            height: 60px;
            border-radius: 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.75rem;
            color: white;
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15);
        }
        
        .card-icon-personal {
            background: linear-gradient(135deg, #3b82f6, #2563eb);
        }
        
        .card-icon-work {
            background: linear-gradient(135deg, #8b5cf6, #7c3aed);
        }
        
        .card-title {
            font-size: 1.75rem;
            font-weight: 700;
            color: #111318;
            margin: 0;
        }
        
        .info-item {
            display: flex;
            align-items: flex-start;
            gap: 1.25rem;
            padding: 1.25rem;
            margin-bottom: 1rem;
            background: #f8fafc;
            border-radius: 12px;
            border-left: 4px solid transparent;
            transition: all 0.3s ease;
        }
        
        .info-item:hover {
            background: #f0f7ff;
            border-left-color: #3b82f6;
        }
        
        .info-icon {
            width: 48px;
            height: 48px;
            min-width: 48px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.25rem;
            color: white;
        }
        
        .icon-primary {
            background: linear-gradient(135deg, #3b82f6, #2563eb);
        }
        
        .icon-success {
            background: linear-gradient(135deg, #10b981, #059669);
        }
        
        .icon-warning {
            background: linear-gradient(135deg, #f59e0b, #d97706);
        }
        
        .icon-danger {
            background: linear-gradient(135deg, #ef4444, #dc2626);
        }
        
        .icon-info {
            background: linear-gradient(135deg, #8b5cf6, #7c3aed);
        }
        
        .info-content {
            flex: 1;
        }
        
        .info-label {
            font-size: 0.9rem;
            color: #6b7280;
            font-weight: 600;
            margin-bottom: 0.4rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .info-value {
            font-size: 1.15rem;
            color: #111318;
            font-weight: 600;
        }
        
        .info-value.large {
            font-size: 1.5rem;
            font-weight: 700;
            color: #2563eb;
        }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark text-[#111318] dark:text-white min-h-screen">

    <div class="flex h-screen overflow-hidden">

        <%@ include file="includes/sidebar.jsp" %>

        <main class="flex-1 flex flex-col overflow-y-auto">

            <%@ include file="includes/header.jsp" %>

            <div class="p-8">

                <!-- Profile Header Card -->
                <div class="profile-header-card">
                    <div class="profile-cover"></div>
                    
                    <div class="profile-info-section">
                        <div class="profile-avatar-container">
                            <div class="profile-avatar">
                                <% if (adminDetalle.getFoto() != null && !adminDetalle.getFoto().isEmpty()) { %>
                                    <img src="uploads/<%= adminDetalle.getFoto() %>" alt="Foto de perfil" style="width: 100%; height: 100%; object-fit: cover;">
                                <% } else { %>
                                    <%= adminDetalle.getNombres().substring(0, 1) %><%= adminDetalle.getApellidos().substring(0, 1) %>
                                <% } %>
                            </div>
                            
                            <div class="profile-title-section">
                                <h1 class="profile-name"><%= adminDetalle.getNombres() %> <%= adminDetalle.getApellidos() %></h1>
                                <div class="profile-role">
                                    <i class="fas fa-briefcase"></i>
                                    <%= adminDetalle.getCargo() != null ? adminDetalle.getCargo() : "Sin cargo asignado" %>
                                </div>
                                <div class="profile-code">
                                    <i class="fas fa-id-badge"></i>
                                    <%= adminDetalle.getCodigoAdministrativo() != null ? adminDetalle.getCodigoAdministrativo() : "Sin código" %>
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
                                <div class="info-value"><%= adminDetalle.getCorreo() != null ? adminDetalle.getCorreo() : "No registrado" %></div>
                            </div>
                        </div>
                        
                        <div class="info-item">
                            <div class="info-icon icon-info">
                                <i class="fas fa-id-card-alt"></i>
                            </div>
                            <div class="info-content">
                                <div class="info-label">Tipo de Documento</div>
                                <div class="info-value"><%= adminDetalle.getTipoDocumento() != null ? adminDetalle.getTipoDocumento() : "DNI" %></div>
                            </div>
                        </div>
                        
                        <div class="info-item">
                            <div class="info-icon icon-warning">
                                <i class="fas fa-fingerprint"></i>
                            </div>
                            <div class="info-content">
                                <div class="info-label">Número de Documento</div>
                                <div class="info-value"><%= adminDetalle.getNumeroDocumento() != null && !adminDetalle.getNumeroDocumento().isEmpty() ? adminDetalle.getNumeroDocumento() : "No registrado" %></div>
                            </div>
                        </div>
                        
                        <div class="info-item">
                            <div class="info-icon icon-success">
                                <i class="fas fa-phone"></i>
                            </div>
                            <div class="info-content">
                                <div class="info-label">Teléfono</div>
                                <div class="info-value"><%= adminDetalle.getTelefono() != null && !adminDetalle.getTelefono().isEmpty() ? adminDetalle.getTelefono() : "No registrado" %></div>
                            </div>
                        </div>
                        
                        <div class="info-item">
                            <div class="info-icon icon-success">
                                <i class="fas fa-calendar-alt"></i>
                            </div>
                            <div class="info-content">
                                <div class="info-label">Fecha de Nacimiento</div>
                                <div class="info-value">
                                    <% if (adminDetalle.getFechaNacimiento() != null) { %>
                                        <%= sdf.format(java.sql.Date.valueOf(adminDetalle.getFechaNacimiento())) %>
                                        <% 
                                            LocalDate fechaNac = adminDetalle.getFechaNacimiento();
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
                                <div class="info-value"><%= adminDetalle.getDireccion() != null && !adminDetalle.getDireccion().isEmpty() ? adminDetalle.getDireccion() : "No registrado" %></div>
                            </div>
                        </div>
                        
                        <div class="info-item">
                            <div class="info-icon icon-info">
                                <i class="fas fa-venus-mars"></i>
                            </div>
                            <div class="info-content">
                                <div class="info-label">Sexo</div>
                                <div class="info-value"><%= adminDetalle.getSexo() != null ? adminDetalle.getSexo() : "No especificado" %></div>
                            </div>
                        </div>
                    </div>

                    <!-- Información Laboral -->
                    <div class="info-card">
                        <div class="card-header-section">
                            <div class="card-icon card-icon-work">
                                <i class="fas fa-briefcase"></i>
                            </div>
                            <h2 class="card-title">Información Laboral</h2>
                        </div>
                        
                        <div class="info-item">
                            <div class="info-icon icon-success">
                                <i class="fas fa-user-tie"></i>
                            </div>
                            <div class="info-content">
                                <div class="info-label">Cargo</div>
                                <div class="info-value large">
                                    <%= adminDetalle.getCargo() != null ? adminDetalle.getCargo() : "No asignado" %>
                                </div>
                            </div>
                        </div>
                        
                        <div class="info-item">
                            <div class="info-icon icon-info">
                                <i class="fas fa-building"></i>
                            </div>
                            <div class="info-content">
                                <div class="info-label">Departamento</div>
                                <div class="info-value">
                                    <%= adminDetalle.getDepartamento() != null ? adminDetalle.getDepartamento() : "No asignado" %>
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
                                    <% if (adminDetalle.getFechaIngreso() != null) { %>
                                        <%= sdf.format(java.sql.Date.valueOf(adminDetalle.getFechaIngreso())) %>
                                    <% } else { %>
                                        No registrado
                                    <% } %>
                                </div>
                            </div>
                        </div>
  
                        </div>
                    </div>
                </div>
      
                <!-- Botones de acción -->
                <div class="flex justify-between items-center mt-8 pt-6 border-t border-[#e5e7eb]">
                    <div class="flex gap-3">
                        <a href="AdministrativoServlet" 
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

