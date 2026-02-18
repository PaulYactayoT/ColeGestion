<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="modelo.Tarea, modelo.Curso, modelo.Profesor, java.util.List" %>

<%
    // Lógica de Sesión y Datos
    Profesor docente = (Profesor) session.getAttribute("docente");
    Curso curso = (Curso) request.getAttribute("curso");
    List<Tarea> lista = (List<Tarea>) request.getAttribute("lista");
    
    // Validar sesión
    if (docente == null || curso == null) {
        response.sendRedirect("docenteDashboard.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Tareas - Colegio SA</title>
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600&display=swap" rel="stylesheet">
    
    <style>
        :root {
            --primary-blue: #0d6efd;
            --dark-blue: #0b4eb8;
            --bg-light: #f4f7fc;
            --text-dark: #333;
            --sidebar-width: 260px;
        }

        body {
            font-family: 'Poppins', sans-serif;
            background-color: var(--bg-light);
            margin: 0;
            display: flex;
            min-height: 100vh;
        }

        /* ================= SIDEBAR ================= */
        .sidebar {
            width: var(--sidebar-width);
            background-color: #fff;
            box-shadow: 2px 0 10px rgba(0,0,0,0.05);
            position: fixed;
            height: 100vh;
            z-index: 100;
            display: flex;
            flex-direction: column;
        }

        .brand {
            padding: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
            border-bottom: 1px solid #eee;
        }

        .brand-logo {
            width: 40px;
            height: 40px;
            background-color: var(--primary-blue);
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 20px;
        }

        .brand-text h4 { margin: 0; font-size: 16px; font-weight: 700; color: #1a1a1a; }
        .brand-text span { font-size: 12px; color: #777; }

        .sidebar-menu { padding: 20px 10px; flex-grow: 1; }
        
        .menu-item {
            display: flex;
            align-items: center;
            padding: 12px 15px;
            color: #666;
            text-decoration: none;
            border-radius: 8px;
            margin-bottom: 5px;
            transition: all 0.3s;
            font-size: 14px;
            font-weight: 500;
        }

        .menu-item i { margin-right: 12px; width: 20px; text-align: center; }
        .menu-item:hover { background-color: #eef2ff; color: var(--primary-blue); }
        .menu-item.active { background-color: #e0eaff; color: var(--primary-blue); font-weight: 600; }

        .sidebar-footer { padding: 20px; border-top: 1px solid #eee; }

        /* ================= MAIN CONTENT ================= */
        .main-content {
            margin-left: var(--sidebar-width);
            flex-grow: 1;
            padding: 0;
            display: flex;
            flex-direction: column;
        }

        /* HEADER SUPERIOR */
        .top-header {
            background-color: #fff;
            padding: 15px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid #eee;
        }

        .page-title { font-size: 18px; font-weight: 600; color: #333; margin: 0; }

        .user-profile { display: flex; align-items: center; gap: 15px; }
        .user-info { text-align: right; line-height: 1.2; }
        .user-name { font-size: 14px; font-weight: 600; display: block; }
        .user-role { font-size: 12px; color: #777; }
        .user-avatar {
            width: 40px; height: 40px;
            background-color: var(--primary-blue);
            color: white;
            border-radius: 50%;
            display: flex; 
            align-items: center; 
            justify-content: center;
            font-weight: 600;
        }

        /* CONTENIDO INTERNO */
        .content-wrapper { padding: 30px; }

        .section-header-card {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
        }

        .course-info h2 { font-size: 22px; font-weight: 700; margin-bottom: 5px; }
        .course-info p { color: #666; margin: 0; }

        .btn-add {
            background-color: var(--primary-blue);
            color: white;
            padding: 10px 20px;
            border-radius: 6px;
            border: none;
            font-weight: 500;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            box-shadow: 0 4px 10px rgba(13, 110, 253, 0.2);
            transition: all 0.2s;
        }
        .btn-add:hover { background-color: var(--dark-blue); color: white; transform: translateY(-2px); }

        /* TABLA ESTILO DASHBOARD */
        .table-card {
            background: white;
            border-radius: 10px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.02);
            border: 1px solid #eee;
            overflow: hidden;
        }

        .table-responsive { width: 100%; }
        
        .custom-table { width: 100%; border-collapse: collapse; }
        
        .custom-table thead tr { background-color: var(--dark-blue); color: white; }
        .custom-table thead th { 
            background-color: var(--dark-blue); 
            color: white; 
            font-weight: 600;
            padding: 15px 20px;
            text-align: left;
            border: none;
            font-size: 13px;
            text-transform: uppercase;
        }

        .custom-table td {
            padding: 15px 20px;
            border-bottom: 1px solid #eee;
            color: #444;
            vertical-align: middle;
            font-size: 14px;
        }

        .custom-table tbody tr:hover { background-color: #f9faff; }

        /* BADGES */
        .badge-status {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 600;
        }
        .status-active { background-color: #e6f7ee; color: #0d8a46; }
        /* Badge para inactivo unificado (vencido o manual) */
        .status-finalized, .status-inactive { background-color: #fce8e6; color: #c53030; }

        /* ACCIONES */
        .actions-cell { display: flex; gap: 8px; }
        
        .btn-icon {
            width: 32px; height: 32px;
            border-radius: 6px;
            display: flex;
            align-items: center;
            justify-content: center;
            border: none;
            cursor: pointer;
            transition: all 0.2s;
            text-decoration: none;
        }

        .btn-edit { background-color: #e0eaff; color: var(--primary-blue); }
        .btn-edit:hover { background-color: var(--primary-blue); color: white; }

        .btn-delete { background-color: #ffe5e7; color: #d63345; }
        .btn-delete:hover { background-color: #d63345; color: white; }

        /* FOOTER */
        .main-footer {
            text-align: center;
            padding: 20px;
            color: #888;
            font-size: 12px;
            margin-top: auto;
        }
    </style>
</head>
<body>

    <div class="sidebar">
        <div class="brand">
            <div class="brand-logo"><i class="fas fa-graduation-cap"></i></div>
            <div class="brand-text">
                <h4>San Antonio</h4>
                <span>Gestión Académica</span>
            </div>
        </div>
        
        <div class="sidebar-menu">
            <a href="docenteDashboard.jsp" class="menu-item">
                <i class="fas fa-home"></i> Dashboard
            </a>
            <a href="#" class="menu-item active">
                <i class="fas fa-book"></i> Mis Cursos
            </a>
            <a href="#" class="menu-item">
                <i class="fas fa-chalkboard-teacher"></i> Asistencias
            </a>
            <a href="#" class="menu-item">
                <i class="fas fa-star"></i> Calificaciones
            </a>
        </div>

        <div class="sidebar-footer">
            <a href="LogoutServlet" class="btn btn-danger w-100 btn-sm">
                <i class="fas fa-sign-out-alt"></i> Cerrar Sesión
            </a>
        </div>
    </div>

    <div class="main-content">
        
        <header class="top-header">
            <h2 class="page-title">Listado de Tareas</h2>
            
            <div class="user-profile">
                <div class="user-info">
                    <span class="user-name"><%= docente.getNombres() %> <%= docente.getApellidos() %></span>
                    <span class="user-role">Docente</span>
                </div>
                <div class="user-avatar">
                    <%= docente.getNombres().substring(0,1) %><%= docente.getApellidos().substring(0,1) %>
                </div>
            </div>
        </header>

        <div class="content-wrapper">
            
            <% 
                String mensaje = (String) session.getAttribute("mensaje");
                String error = (String) session.getAttribute("error");
                
                if (mensaje != null) { 
                    session.removeAttribute("mensaje");
            %>
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="fas fa-check-circle me-2"></i> <%= mensaje %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>
            <% if (error != null) { 
                    session.removeAttribute("error");
            %>
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="fas fa-exclamation-circle me-2"></i> <%= error %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>

            <div class="section-header-card">
                <div class="course-info">
                    <h2>Gestión de Tareas</h2>
                    <p>Administra las actividades del curso: <strong><%= curso.getNombre() %> - <%= curso.getGradoNombre() %></strong></p>
                </div>
                <div>
                    <a href="docenteDashboard.jsp" class="btn btn-outline-secondary me-2">
                        <i class="fas fa-arrow-left"></i> Volver
                    </a>
                    <a href="TareaServlet?accion=registrar&curso_id=<%= curso.getId() %>" class="btn-add">
                        <i class="fas fa-plus"></i> Registrar Tarea
                    </a>
                </div>
            </div>

            <div class="table-card">
                <div class="table-responsive">
                    <table class="custom-table">
                        <thead>
                            <tr>
                                <th>NOMBRE</th>
                                <th>DESCRIPCIÓN</th>
                                <th>FECHA DE ENTREGA</th>
                                <th class="text-center">TIEMPO RESTANTE</th>
                                <th>ESTADO</th>
                                <th>ACCIONES</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (lista != null && !lista.isEmpty()) { 
                                for (Tarea t : lista) { 
                                    boolean esFinalizado = "FINALIZADO".equals(t.getEstadoCalculado());
                            %>
                            <tr>
                                <td>
                                    <div class="d-flex align-items-center">
                                        <div class="bg-light rounded p-2 me-3 text-primary">
                                            <i class="fas fa-book-open"></i>
                                        </div>
                                        <div>
                                            <div class="fw-bold"><%= t.getNombre() %></div>
                                            <small class="text-muted"><%= t.getTipo() %></small>
                                        </div>
                                    </div>
                                </td>
                                <td><%= t.getDescripcion() %></td>
                                
                                <td>
                                    <div class="d-flex align-items-center text-primary">
                                        <i class="far fa-calendar-alt me-2"></i>
                                        <span class="fw-medium">
                                            <%= (t.getFechaEntrega() != null && !t.getFechaEntrega().equals("null")) ? t.getFechaEntrega() : "Sin fecha" %>
                                            <br>
                                            <small style="color:#666">
                                                <i class="far fa-clock"></i> <%= (t.getHoraEntrega() != null) ? t.getHoraEntrega() : "23:59:59" %>
                                            </small>
                                        </span>
                                    </div>
                                </td>

                                <td class="text-center align-middle">
                                    <% if (esFinalizado) { %>
                                        <span class="badge bg-danger text-white">
                                            <i class="fas fa-exclamation-triangle"></i> Tiempo Finalizado
                                        </span>
                                    <% } else { %>
                                        <div class="countdown-timer badge bg-secondary" 
                                             style="min-width: 130px; font-weight: normal; font-size: 13px;"
                                             data-fecha="<%= t.getFechaEntrega() %>" 
                                             data-hora="<%= t.getHoraEntrega() != null ? t.getHoraEntrega() : "23:59:59" %>">
                                             <i class="fas fa-spinner fa-spin"></i>
                                        </div>
                                    <% } %>
                                </td>

                                <td>
                                    <% if (esFinalizado || !t.isActivo()) { %>
                                        <span class="badge-status status-inactive state-badge">Inactivo</span>
                                    <% } else { %>
                                        <span class="badge-status status-active state-badge">Activo</span>
                                    <% } %>
                                </td>
                                <td>
                                    <div class="actions-cell">
                                        <a href="TareaServlet?accion=editar&id=<%= t.getId() %>" class="btn-icon btn-edit" title="Editar">
                                            <i class="fas fa-pencil-alt"></i>
                                        </a>

                                        <form action="TareaServlet" method="GET" style="display:inline;" onsubmit="return confirm('¿Estás seguro de eliminar esta tarea?');">
                                            <input type="hidden" name="accion" value="eliminar">
                                            <input type="hidden" name="id" value="<%= t.getId() %>">
                                            <button type="submit" class="btn-icon btn-delete" title="Eliminar">
                                                <i class="fas fa-trash-alt"></i>
                                            </button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                            <% } 
                               } else { %>
                            <tr>
                                <td colspan="6" class="text-center py-5">
                                    <div class="text-muted">
                                        <i class="fas fa-folder-open fa-3x mb-3"></i>
                                        <p>No hay tareas registradas para este curso.</p>
                                    </div>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>

        <footer class="main-footer">
            © 2026 Colegio San Antonio - Todos los derechos reservados
        </footer>

    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function actualizarRelojes() {
            const ahora = new Date().getTime();
            const relojes = document.querySelectorAll('.countdown-timer');

            relojes.forEach(reloj => {
                const fecha = reloj.getAttribute('data-fecha');
                const hora = reloj.getAttribute('data-hora');
                
                const fila = reloj.closest('tr');
                const badgeEstado = fila.querySelector('.state-badge');

                if (!fecha || fecha === 'null') {
                    reloj.innerHTML = '-';
                    return;
                }

                const horaFull = (hora && hora.length === 5) ? hora + ":00" : (hora ? hora : "23:59:00");
                const fechaISO = fecha + "T" + horaFull;
                const vencimiento = new Date(fechaISO).getTime();
                
                if (isNaN(vencimiento)) {
                    reloj.innerHTML = "Fecha Inválida";
                    return;
                }

                const distancia = vencimiento - ahora;

                if (distancia < 0) {
                    reloj.className = 'countdown-timer badge bg-danger';
                    reloj.innerHTML = '<i class="fas fa-exclamation-triangle"></i> Tiempo Finalizado';
                    
                    if (badgeEstado) {
                        badgeEstado.className = 'badge-status status-inactive state-badge';
                        badgeEstado.innerText = 'Inactivo';
                    }

                } else {
                    const dias = Math.floor(distancia / (1000 * 60 * 60 * 24));
                    const horas = Math.floor((distancia % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                    const minutos = Math.floor((distancia % (1000 * 60 * 60)) / (1000 * 60));
                    const segundos = Math.floor((distancia % (1000 * 60)) / 1000);

                    let texto = "";
                    
                    if (dias > 0) {
                        texto = dias + "d " + horas + "h " + minutos + "m";
                        reloj.className = 'countdown-timer badge bg-success'; 
                    } else {
                        texto = (horas < 10 ? "0"+horas : horas) + ":" + 
                                (minutos < 10 ? "0"+minutos : minutos) + ":" + 
                                (segundos < 10 ? "0"+segundos : segundos);
                        
                        if (horas < 1) {
                            reloj.className = 'countdown-timer badge bg-warning text-dark'; 
                        } else {
                            reloj.className = 'countdown-timer badge bg-info text-dark'; 
                        }
                    }
                    
                    reloj.innerHTML = '<i class="far fa-clock"></i> ' + texto;
                }
            });
        }

        setInterval(actualizarRelojes, 1000);
        actualizarRelojes();
    </script>
</body>
</html>