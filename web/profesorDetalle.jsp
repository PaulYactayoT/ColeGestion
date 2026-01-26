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
    <title>Detalles del Profesor</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="assets/css/estilos.css">
    <style>
        .detail-card {
            background: white;
            border-radius: 15px;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
            margin-bottom: 2rem;
        }
        
        .detail-header {
            background: linear-gradient(135deg, #4f46e5, #4338ca);
            color: white;
            padding: 1.5rem;
            border-radius: 15px 15px 0 0;
            display: flex;
            align-items: center;
            gap: 1rem;
        }
        
        .detail-header i {
            font-size: 2rem;
        }
        
        .section-title {
            color: #4f46e5;
            font-weight: 600;
            font-size: 1.2rem;
            margin: 1.5rem 0 1rem 0;
            padding-bottom: 0.5rem;
            border-bottom: 2px solid #e5e7eb;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .info-row {
            padding: 0.75rem 0;
            border-bottom: 1px solid #f3f4f6;
        }
        
        .info-label {
            font-weight: 600;
            color: #374151;
            margin-bottom: 0.25rem;
        }
        
        .info-value {
            color: #6b7280;
            font-size: 0.95rem;
        }
        
        .badge-nivel {
            font-size: 1rem;
            padding: 0.5rem 1rem;
        }
        
        .btn-back {
            background: #6b7280;
            color: white;
            padding: 0.75rem 2rem;
            border-radius: 10px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            transition: all 0.3s ease;
        }
        
        .btn-back:hover {
            background: #4b5563;
            color: white;
            transform: translateY(-2px);
        }
        
        .btn-edit {
            background: linear-gradient(135deg, #4f46e5, #4338ca);
            color: white;
            padding: 0.75rem 2rem;
            border-radius: 10px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            transition: all 0.3s ease;
        }
        
        .btn-edit:hover {
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 8px 15px rgba(79, 70, 229, 0.3);
        }
    </style>
</head>
<body>
    <jsp:include page="header.jsp" />

    <div class="container mt-5 mb-5">
        <div class="detail-card">
            <!-- Header -->
            <div class="detail-header">
                <i class="fas fa-user-circle"></i>
                <div>
                    <h3 class="mb-0">Detalles del Profesor</h3>
                    <p class="mb-0" style="opacity: 0.9;">Información completa del registro</p>
                </div>
            </div>
            
            <!-- Body -->
            <div class="p-4">
                <div class="row">
                    <!-- Columna Izquierda: Información Personal -->
                    <div class="col-md-6">
                        <div class="section-title">
                            <i class="fas fa-user"></i>
                            Información Personal
                        </div>
                        
                        <div class="info-row">
                            <div class="info-label">Nombres Completos</div>
                            <div class="info-value"><%= p.getNombres() %> <%= p.getApellidos() %></div>
                        </div>
                        
                        <div class="info-row">
                            <div class="info-label">DNI</div>
                            <div class="info-value"><%= p.getDni() != null ? p.getDni() : "No registrado" %></div>
                        </div>
                        
                        <div class="info-row">
                            <div class="info-label">Correo Electrónico</div>
                            <div class="info-value">
                                <i class="fas fa-envelope text-primary"></i> <%= p.getCorreo() %>
                            </div>
                        </div>
                        
                        <div class="info-row">
                            <div class="info-label">Teléfono</div>
                            <div class="info-value">
                                <i class="fas fa-phone text-success"></i> 
                                <%= p.getTelefono() != null ? p.getTelefono() : "No registrado" %>
                            </div>
                        </div>
                        
                        <div class="info-row">
                            <div class="info-label">Fecha de Nacimiento</div>
                            <div class="info-value">
                                <i class="fas fa-calendar text-info"></i>
                                <%= p.getFechaNacimiento() != null ? sdf.format(p.getFechaNacimiento()) : "No registrada" %>
                            </div>
                        </div>
                        
                        <div class="info-row">
                            <div class="info-label">Dirección</div>
                            <div class="info-value">
                                <i class="fas fa-map-marker-alt text-danger"></i>
                                <%= p.getDireccion() != null ? p.getDireccion() : "No registrada" %>
                            </div>
                        </div>
                    </div>

                    <!-- Columna Derecha: Información Profesional -->
                    <div class="col-md-6">
                        <div class="section-title">
                            <i class="fas fa-briefcase"></i>
                            Información Profesional
                        </div>
                        
                        <div class="info-row">
                            <div class="info-label">Código de Profesor</div>
                            <div class="info-value">
                                <span class="badge bg-secondary"><%= p.getCodigoProfesor() != null ? p.getCodigoProfesor() : "No asignado" %></span>
                            </div>
                        </div>
                        
                        <div class="info-row">
                            <div class="info-label">Especialidad / Área</div>
                            <div class="info-value"><%= p.getEspecialidad() %></div>
                        </div>
                        
                        <div class="info-row">
                            <div class="info-label">Nivel que Enseña</div>
                            <div class="info-value">
                                <% 
                                    String nivel = p.getNivel();
                                    String badge = "";
                                    if ("INICIAL".equals(nivel)) {
                                        badge = "badge bg-info badge-nivel";
                                    } else if ("PRIMARIA".equals(nivel)) {
                                        badge = "badge bg-success badge-nivel";
                                    } else if ("SECUNDARIA".equals(nivel)) {
                                        badge = "badge bg-warning badge-nivel";
                                    } else if ("TODOS".equals(nivel)) {
                                        badge = "badge bg-primary badge-nivel";
                                    } else {
                                        badge = "badge bg-secondary badge-nivel";
                                    }
                                %>
                                <span class="<%= badge %>"><%= nivel != null ? nivel : "Sin nivel" %></span>
                            </div>
                        </div>
                        
                        <div class="info-row">
                            <div class="info-label">Turno</div>
                            <div class="info-value">
                                <i class="fas fa-clock text-warning"></i>
                                <%= p.getTurnoNombre() != null ? p.getTurnoNombre() : "Sin turno" %>
                            </div>
                        </div>
                        
                        <div class="info-row">
                            <div class="info-label">Fecha de Contratación</div>
                            <div class="info-value">
                                <i class="fas fa-calendar-check text-success"></i>
                                <%= p.getFechaContratacion() != null ? sdf.format(p.getFechaContratacion()) : "No registrada" %>
                            </div>
                        </div>
                        
                        <div class="info-row">
                            <div class="info-label">Estado</div>
                            <div class="info-value">
                                <% 
                                    String estado = p.getEstado();
                                    String badgeEstado = "";
                                    if ("ACTIVO".equals(estado)) {
                                        badgeEstado = "badge bg-success badge-nivel";
                                    } else if ("INACTIVO".equals(estado)) {
                                        badgeEstado = "badge bg-danger badge-nivel";
                                    } else if ("LICENCIA".equals(estado)) {
                                        badgeEstado = "badge bg-warning badge-nivel";
                                    } else if ("JUBILADO".equals(estado)) {
                                        badgeEstado = "badge bg-secondary badge-nivel";
                                    }
                                %>
                                <span class="<%= badgeEstado %>"><%= estado != null ? estado : "ACTIVO" %></span>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Botones de Acción -->
                <div class="d-flex justify-content-between align-items-center mt-4 pt-4" style="border-top: 2px solid #e5e7eb;">
                    <a href="ProfesorServlet?accion=listar" class="btn-back">
                        <i class="fas fa-arrow-left"></i>
                        Volver al Listado
                    </a>
                </div>
            </div>
        </div>
    </div>

    <footer class="bg-dark text-white py-4 mt-5">
        <div class="container text-center">
            <p class="mb-0">&copy; 2025 Colegio SA - Todos los derechos reservados</p>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>