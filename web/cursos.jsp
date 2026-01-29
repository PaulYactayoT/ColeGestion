<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.sql.*, modelo.Curso, modelo.Grado, conexion.Conexion" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%
    String nivelSeleccionado = (String) request.getAttribute("nivelSeleccionado");
    String turnoSeleccionado = (String) request.getAttribute("turnoSeleccionado");
%>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    List<Grado> grados = (List<Grado>) request.getAttribute("grados");
    Integer gradoSeleccionado = (Integer) request.getAttribute("gradoSeleccionado");
    
    String mensaje = (String) session.getAttribute("mensaje");
    String error = (String) session.getAttribute("error");
    session.removeAttribute("mensaje");
    session.removeAttribute("error");
%>


<%!
    // Método para obtener horarios de un curso
    private String obtenerHorarios(int cursoId) {
        StringBuilder resultado = new StringBuilder();
        try (Connection conn = conexion.Conexion.getConnection()) {
            String sql = "SELECT dia_semana, TIME_FORMAT(hora_inicio, '%H:%i') as inicio, " +
                        "TIME_FORMAT(hora_fin, '%H:%i') as fin " +
                        "FROM horario_clase WHERE curso_id = ? AND eliminado = 0 " +
                        "ORDER BY FIELD(dia_semana, 'LUNES','MARTES','MIERCOLES','JUEVES','VIERNES','SABADO'), hora_inicio";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, cursoId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                if (resultado.length() > 0) resultado.append("; ");
                resultado.append(rs.getString("dia_semana")).append(" ")
                        .append(rs.getString("inicio")).append("-").append(rs.getString("fin"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return resultado.toString();
    }
    
    // Método para obtener nivel de un grado
    private String obtenerNivel(int gradoId) {
        try (Connection conn = conexion.Conexion.getConnection()) {
            String sql = "SELECT nivel FROM grado WHERE id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, gradoId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getString("nivel");
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "-";
    }
    
    // Método para obtener grado_id de un curso
    private int obtenerGradoId(int cursoId) {
        try (Connection conn = conexion.Conexion.getConnection()) {
            String sql = "SELECT grado_id FROM curso WHERE id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, cursoId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("grado_id");
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Listado de Cursos - Sistema Escolar</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="assets/css/estilos.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
    <style>
        :root {
            /* PALETA DE COLORES PROFESIONAL */
            --color-fondo-principal: #E8E9EB;
            --color-fondo-secundario: #F5F5F6;
            --color-celeste-bebe: #D4E9F7;
            --color-celeste-claro: #B8DAF0;
            --color-celeste-medio: #A0CEE8;
            --color-celeste-acento: #7FC3E3;
            --color-texto-principal: #2B2D30;
            --color-texto-secundario: #5A5C5F;
            --color-borde: #D1D3D5;
            --color-sombra: rgba(0, 0, 0, 0.06);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: linear-gradient(135deg, var(--color-fondo-principal) 0%, #E0E2E4 100%);
            color: var(--color-texto-principal);
            min-height: 100vh;
        }

        .container {
            max-width: 1400px;
        }

        /* ========== ENCABEZADO ========== */
        .page-header {
            background: #2B2D30;  
            border-radius: 20px;
            padding: 30px 40px;
            margin-bottom: 30px;
            box-shadow: 0 4px 20px var(--color-sombra);
            border-left: 5px solid var(--color-celeste-acento);
        }

        .page-header h2 {
            font-size: 2rem;
            font-weight: 700;
            color: white;
            display: flex;
            align-items: center;
            gap: 15px;
            margin: 0;
        }

        .page-header h2 i {
            color: var(--color-celeste-acento);
            font-size: 2.2rem;
        }

        /* ========== SECCIÓN DE FILTROS ========== */
        .filter-section {
            background: var(--color-fondo-secundario);
            border-radius: 20px;
            padding: 30px;
            margin-bottom: 30px;
            box-shadow: 0 2px 15px var(--color-sombra);
            border: 1px solid var(--color-borde);
        }

        .filter-section h5 {
            color: var(--color-texto-principal);
            font-weight: 600;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .filter-section h5 i {
            color: var(--color-celeste-acento);
        }

        .form-label {
            font-weight: 600;
            color: var(--color-texto-principal);
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 0.9rem;
        }

        .form-label i {
            color: var(--color-celeste-acento);
        }

        .form-select {
            border: 2px solid var(--color-borde);
            border-radius: 12px;
            padding: 10px 14px;
            font-size: 0.95rem;
            transition: all 0.3s ease;
            background: white;
            color: var(--color-texto-principal);
        }

        .form-select:focus {
            border-color: var(--color-celeste-medio);
            box-shadow: 0 0 0 0.2rem rgba(160, 206, 232, 0.25);
            outline: none;
        }

        /* ========== BOTONES ========== */
        .btn {
            border-radius: 12px;
            padding: 10px 20px;
            font-weight: 600;
            transition: all 0.3s ease;
        }

        .btn-primary {
            background: #0d6efd;
            border: none;
            color: white;
            box-shadow: 0 4px 15px rgba(13, 110, 253, 0.3);
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(13, 110, 253, 0.4);
            background: #0b5ed7;
            color: white;
        }

        .btn-success {
            background: #198754;
            border: none;
            color: white;
        }

        .btn-success:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(25, 135, 84, 0.4);
            background: #157347;
            color: white;
        }

        .btn-sm {
            padding: 6px 12px;
            font-size: 0.85rem;
        }

        .btn-danger {
            background: #dc3545;
            border: none;
            color: white;
        }

        .btn-danger:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(220, 53, 69, 0.4);
            background: #bb2d3b;
            color: white;
        }

        /* ========== CARDS DE CURSOS ========== */
        .card-curso {
            background: var(--color-fondo-secundario);
            border: 2px solid var(--color-borde);
            border-radius: 20px;
            overflow: hidden;
            transition: all 0.3s ease;
            box-shadow: 0 2px 15px var(--color-sombra);
            height: 100%;
        }

        .card-curso:hover {
            transform: translateY(-8px);
            box-shadow: 0 8px 30px rgba(0, 0, 0, 0.12);
            border-color: var(--color-celeste-medio);
        }

        .card-curso .card-header {
            background: var(--color-celeste-bebe);
            border-bottom: 2px solid var(--color-celeste-claro);
            padding: 18px 20px;
        }

        .card-curso .card-header h5 {
            color: var(--color-texto-principal);
            font-weight: 700;
            font-size: 1.1rem;
            margin: 0;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .card-curso .card-header h5 i {
            color: var(--color-celeste-acento);
        }

        .card-curso .card-body {
            padding: 20px;
            background: var(--color-fondo-secundario);
        }

        .card-curso .card-text {
            color: var(--color-texto-principal);
            font-size: 0.9rem;
            margin-bottom: 12px;
            line-height: 1.6;
        }

        .card-curso .card-text strong {
            color: var(--color-texto-secundario);
            font-weight: 600;
        }

        .card-curso .card-footer {
            background: var(--color-celeste-bebe);
            border-top: 2px solid var(--color-celeste-claro);
            padding: 15px 20px;
        }

        /* ========== BADGES ========== */
        .badge {
            padding: 6px 12px;
            border-radius: 8px;
            font-weight: 600;
            font-size: 0.8rem;
        }

        .badge-horario {
            display: inline-block;
            margin: 3px;
            font-size: 0.75rem;
            padding: 5px 10px;
        }

        .nivel-badge {
            font-size: 0.85rem;
            padding: 7px 14px;
        }

        /* Colores de badges - Bootstrap normal */
        .bg-info {
            background: #0dcaf0 !important;
            color: #000 !important;
        }

        .bg-primary {
            background: #0d6efd !important;
            color: white !important;
        }

        .bg-success {
            background: #198754 !important;
            color: white !important;
        }

        .bg-secondary {
            background: #6c757d !important;
            color: white !important;
        }

        .bg-warning {
            background: #ffc107 !important;
            color: #000 !important;
        }

        .bg-danger {
            background: #dc3545 !important;
            color: white !important;
        }

        .bg-dark {
            background: #212529 !important;
            color: white !important;
        }

        /* ========== ALERTAS ========== */
        .alert {
            border-radius: 15px;
            padding: 18px 25px;
            border: none;
            box-shadow: 0 2px 10px var(--color-sombra);
            font-weight: 500;
        }

        .alert-success {
            background: linear-gradient(135deg, #E8F5E9, #C8E6C9);
            color: #2E7D32;
        }

        .alert-danger {
            background: linear-gradient(135deg, #FFEBEE, #FFCDD2);
            color: #C62828;
        }

        .alert-info {
            background: linear-gradient(135deg, var(--color-celeste-bebe), var(--color-celeste-claro));
            color: var(--color-texto-principal);
        }

        /* ========== FOOTER ========== */
        footer {
            margin-top: 60px;
            background: #2B2D30 !important;
        }

        footer h5 {
            color: var(--color-celeste-claro);
            font-weight: 600;
        }

        footer p, footer a {
            color: #E8E9EB;
        }

        footer a:hover {
            color: var(--color-celeste-acento);
        }

        /* ========== RESPONSIVE ========== */
        @media (max-width: 768px) {
            .page-header {
                padding: 20px;
            }

            .page-header h2 {
                font-size: 1.5rem;
            }

            .filter-section {
                padding: 20px;
            }

            .card-curso .card-body {
                padding: 15px;
            }
        }

        /* ========== ANIMACIONES ========== */
        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(-20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .card-curso {
            animation: fadeIn 0.5s ease;
        }
    </style>
</head>
<body class="dashboard-page">

    <jsp:include page="header.jsp" />
    
    <!-- ========== MENSAJES ========== -->
    <div class="container mt-4">
        <% if (mensaje != null) { %>
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="fas fa-check-circle"></i> <%= mensaje %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>
        
        <% if (error != null) { %>
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="fas fa-exclamation-circle"></i> <%= error %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>
    </div>

    <div class="container mt-5 mb-5">
        <!-- ========== ENCABEZADO ========== -->
        <div class="page-header">
            <h2>
                <i class="fas fa-book"></i>
                Listado de Cursos
            </h2>
        </div>

        <!-- ========== SECCIÓN DE FILTROS ========== -->
        <div class="filter-section">
            <h5>
                <i class="fas fa-filter"></i>
                Filtrar Cursos
            </h5>
            <form action="CursoServlet" method="get">
                <input type="hidden" name="accion" value="filtrar">
                
                <div class="row g-3 align-items-end">
                    <!-- Filtro Nivel -->
                    <div class="col-md-3">
                        <label for="nivel" class="form-label">
                            <i class="fas fa-layer-group"></i>
                            Nivel
                        </label>
                        <select name="nivel" id="nivel" class="form-select">
                        <option value="">-- Todos los niveles --</option>
                        <option value="INICIAL" <%= "INICIAL".equals(nivelSeleccionado) ? "selected" : "" %>>INICIAL</option>
                        <option value="PRIMARIA" <%= "PRIMARIA".equals(nivelSeleccionado) ? "selected" : "" %>>PRIMARIA</option>
                        <option value="SECUNDARIA" <%= "SECUNDARIA".equals(nivelSeleccionado) ? "selected" : "" %>>SECUNDARIA</option>
                    </select>
                    </div>

                    <!-- Filtro Turno -->
                    <div class="col-md-3">
                        <label for="turno" class="form-label">
                            <i class="fas fa-clock"></i>
                            Turno
                        </label>
                        <select name="turno" id="turno" class="form-select">
                            <option value="">-- Todos los turnos --</option>
                            <option value="MAÑANA" <%= "MAÑANA".equals(turnoSeleccionado) ? "selected" : "" %>>MAÑANA</option>
                            <option value="TARDE" <%= "TARDE".equals(turnoSeleccionado) ? "selected" : "" %>>TARDE</option>
                        </select>
                      </div>

                    <!-- Filtro Grado -->
                    <div class="col-md-4">
                        <label for="grado_id" class="form-label">
                            <i class="fas fa-graduation-cap"></i>
                            Grado
                        </label>
                        <select name="grado_id" id="grado_id" class="form-select">
                            <option value="">-- Todos los grados --</option>
                            <% if (grados != null) {
                                for (Grado g : grados) {%>
                            <option value="<%= g.getId()%>" <%= (gradoSeleccionado != null && gradoSeleccionado == g.getId()) ? "selected" : ""%>>
                                <%= g.getNombre()%> - <%= g.getNivel()%>
                            </option>
                            <% }
                            } %>
                        </select>
                    </div>

                    <!-- Botones -->
                    <div class="col-md-2">
                        <button type="submit" class="btn btn-primary w-100">
                            <i class="fas fa-search"></i> Filtrar
                        </button>
                    </div>
                </div>
            </form>
        </div>

        <!-- ========== BOTÓN REGISTRAR ========== -->
        <div class="text-end mb-4">
            <a href="RegistroCursoServlet?accion=cargarFormulario" class="btn btn-success btn-lg">
                <i class="fas fa-plus"></i> Registrar Curso
            </a>
        </div>

        <!-- ========== GRID DE CARDS ========== -->
        <div class="row">
            <%
                List<Curso> lista = (List<Curso>) request.getAttribute("lista");

                if (lista != null && !lista.isEmpty()) {
                    for (Curso c : lista) {
                        // Obtener datos adicionales
                        int gradoId = obtenerGradoId(c.getId());
                        String nivel = obtenerNivel(gradoId);
                        String horarios = obtenerHorarios(c.getId());
                        
                        // Colores para badges de nivel
                        String badgeColor = "secondary";
                        if ("INICIAL".equals(nivel)) badgeColor = "info";
                        else if ("PRIMARIA".equals(nivel)) badgeColor = "primary";
                        else if ("SECUNDARIA".equals(nivel)) badgeColor = "success";
            %>
            <div class="col-md-6 col-lg-4 mb-4">
                <div class="card card-curso">
                    <div class="card-header">
                        <h5>
                            <i class="fas fa-graduation-cap"></i>
                            <%= c.getNombre()%>
                        </h5>
                    </div>
                    <div class="card-body">
                        <!-- NIVEL -->
                        <p class="card-text">
                            <strong>Nivel:</strong> 
                            <span class="badge bg-<%= badgeColor%> nivel-badge"><%= nivel%></span>
                        </p>
                        
                        <!-- GRADO -->
                        <p class="card-text">
                            <strong>Grado:</strong> <%= c.getGradoNombre() != null ? c.getGradoNombre() : "-" %>
                        </p>
                        
                        <!-- PROFESOR -->
                        <p class="card-text">
                            <strong>Profesor:</strong> <%= c.getProfesorNombre() != null ? c.getProfesorNombre() : "-" %>
                        </p>
                        
                        <!-- HORARIOS -->
                        <p class="card-text">
                            <strong>Horarios:</strong><br>
                            <% if (horarios != null && !horarios.isEmpty()) {
                                String[] horariosArray = horarios.split("; ");
                                for (String h : horariosArray) {
                                    String[] partes = h.split(" ");
                                    if (partes.length >= 2) {
                                        String dia = partes[0];
                                        String hora = partes[1];
                                        String colorDia = "secondary";
                                        switch(dia) {
                                            case "LUNES": colorDia = "primary"; break;
                                            case "MARTES": colorDia = "success"; break;
                                            case "MIERCOLES": colorDia = "info"; break;
                                            case "JUEVES": colorDia = "warning"; break;
                                            case "VIERNES": colorDia = "danger"; break;
                                            case "SABADO": colorDia = "dark"; break;
                                        }
                            %>
                            <span class="badge bg-<%= colorDia%> badge-horario">
                                <%= dia%> <%= hora%>
                            </span>
                            <% 
                                    }
                                }
                            } else { 
                            %>
                            <span class="text-muted">Sin horarios</span>
                            <% } %>
                        </p>
                    </div>
                    <div class="card-footer text-center">
                        <!-- ACCIONES -->
                        <a href="CursoServlet?accion=editar&id=<%= c.getId()%>" class="btn btn-primary btn-sm me-2">
                            <i class="fas fa-edit"></i> Editar
                        </a>
                        <a href="CursoServlet?accion=eliminar&id=<%= c.getId()%>" class="btn btn-danger btn-sm"
                           onclick="return confirm('¿Eliminar este curso?')">
                            <i class="fas fa-trash"></i> Eliminar
                        </a>
                    </div>
                </div>
            </div>
            <%
                }
            } else {
            %>
            <div class="col-12">
                <div class="alert alert-info text-center">
                    <i class="fas fa-info-circle"></i> No hay cursos registrados.
                </div>
            </div>
            <%
                }
            %>
        </div>
    </div>
    
    <!-- ========== FOOTER ========== -->
    <footer class="bg-dark text-white py-4">
        <div class="container text-center text-md-start">
            <div class="row">
                <div class="col-md-4 mb-3">
                    <div class="logo-container text-center">
                        <img src="assets/img/logosa.png" alt="Logo" class="img-fluid mb-2" width="80" height="auto">
                        <p class="fs-6">"Líderes en educación de calidad al más alto nivel"</p>
                    </div>
                </div>

                <div class="col-md-4 mb-3">
                    <h5 class="fs-6">Contacto:</h5>
                    <p class="fs-6 mb-1">Dirección: Av. El Sol 461, San Juan de Lurigancho 15434</p>
                    <p class="fs-6 mb-1">Teléfono: 987654321</p>
                    <p class="fs-6 mb-1">Correo: colegiosanantonio@gmail.com</p>
                </div>

                <div class="col-md-4 mb-3">
                    <h5 class="fs-6">Síguenos:</h5>
                    <a href="https://www.facebook.com/" class="text-white d-block fs-6 mb-1">Facebook</a>
                    <a href="https://www.instagram.com/" class="text-white d-block fs-6 mb-1">Instagram</a>
                    <a href="https://twitter.com/" class="text-white d-block fs-6 mb-1">Twitter</a>
                    <a href="https://www.youtube.com/" class="text-white d-block fs-6 mb-1">YouTube</a>
                </div>
            </div>

            <div class="text-center mt-3">
                <p class="fs-6 mb-0">&copy; 2025 Colegio SA - Todos los derechos reservados</p>
            </div>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
