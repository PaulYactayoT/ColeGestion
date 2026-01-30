

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.sql.*, modelo.Curso, modelo.Grado, conexion.Conexion" %>
<%@ page import="javax.servlet.http.HttpSession" %>

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

<head>
    <meta charset="UTF-8">
    <title>Listado de Cursos</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="assets/css/estilos.css">
    <style>
        .card-curso {
            transition: transform 0.2s, box-shadow 0.2s;
            background-color: #003366; /* Azul oscuro personalizado */
            color: white; /* Texto blanco */
        }
        .card-curso:hover {
            transform: translateY(-5px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.3);
        }
        .badge-horario {
            display: inline-block;
            margin: 2px;
            font-size: 0.75rem;
        }
        .nivel-badge {
            font-size: 0.8rem;
        }
        .card-curso .card-footer {
            background-color: #003366; /* Mismo azul oscuro para el footer */
            border-top: 1px solid #0056b3; /* Borde sutil */
        }
    </style>
</head>
<body class="dashboard-page">

    <jsp:include page="header.jsp" />
    
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
    <div class="container mt-5">
        <h2 class="mb-4 text-center fw-bold"><i class="fas fa-book"></i> Listado de Cursos</h2>

        <!-- FILTRO POR GRADO -->
        <form action="CursoServlet" method="get" class="row g-3 align-items-center mb-4">
            <input type="hidden" name="accion" value="filtrar">
            <div class="col-auto">
                <label for="grado_id" class="col-form-label"><i class="fas fa-filter"></i> Filtrar por Grado:</label>
            </div>
            <div class="col-auto">
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
            <div class="col-auto">
                <button type="submit" class="btn btn-primary"><i class="fas fa-search"></i> Filtrar</button>
            </div>
        </form>

        <div class="text-end mb-4">
            <a href="RegistroCursoServlet?accion=cargarFormulario" class="btn btn-success">
                <i class="fas fa-plus"></i> Registrar Curso
            </a>
        </div>

        <!-- CAMBIO PRINCIPAL: Grid de cards en lugar de tabla -->
        <div class="row">
            <%
                List<Curso> lista = (List<Curso>) request.getAttribute("lista");

                if (lista != null && !lista.isEmpty()) {
                    for (Curso c : lista) {
                        // Obtener datos adicionales
                        int gradoId = obtenerGradoId(c.getId());
                        String nivel = obtenerNivel(gradoId);
                        String horarios = obtenerHorarios(c.getId());
                        
                        // Colores para badges (mantengo colores para contraste)
                        String badgeColor = "secondary";
                        if ("INICIAL".equals(nivel)) badgeColor = "info";
                        else if ("PRIMARIA".equals(nivel)) badgeColor = "primary";
                        else if ("SECUNDARIA".equals(nivel)) badgeColor = "success";
            %>
            <div class="col-md-6 col-lg-4 mb-4">
                <div class="card card-curso h-100">
                    <div class="card-header">
                        <h5 class="card-title mb-0"><i class="fas fa-graduation-cap"></i> <%= c.getNombre()%></h5>
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
    
    <footer class="bg-dark text-white py-2">
        <div class="container text-center text-md-start">
            <div class="row">
                <div class="col-md-4 mb-0">
                    <div class="logo-container text-center">
                        <img src="assets/img/logosa.png" alt="Logo" class="img-fluid mb-1" width="80" height="auto">
                        <p class="fs-6">"Líderes en educación de calidad al más alto nivel"</p>
                    </div>
                </div>

                <div class="col-md-4 mb-0">
                    <h5 class="fs-8">Contacto:</h5>
                    <p class="fs-6">Dirección: Av. El Sol 461, San Juan de Lurigancho 15434</p>
                    <p class="fs-6">Teléfono: 987654321</p>
                    <p class="fs-6">Correo: colegiosanantonio@gmail.com</p>
                </div>

                <div class="col-md-4 mb-0">
                    <h5 class="fs-8">Síguenos:</h5>
                    <a href="https://www.facebook.com/" class="text-white d-block fs-6">Facebook</a>
                    <a href="https://www.instagram.com/" class="text-white d-block fs-6">Instagram</a>
                    <a href="https://twitter.com/" class="text-white d-block fs-6">Twitter</a>
                    <a href="https://www.youtube.com/" class="text-white d-block fs-6">YouTube</a>
                </div>
            </div>

            <div class="text-center mt-0">
                <p class="fs-6">&copy; 2025 Colegio SA - Todos los derechos reservados</p>
            </div>
        </div>
    </footer>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>