<%-- 
    Document   : alumnoForm
    Created on : 1 may. 2025, 8:09:43 p. m.
    Author     : Paul
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Alumno" %>
<%@ page import="modelo.Grado" %>
<%@ page import="java.util.List" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    Alumno a = (Alumno) request.getAttribute("alumno");
    List<Grado> grados = (List<Grado>) request.getAttribute("grados");
    boolean editar = (a != null);
    
    // Formatear fecha para input date (yyyy-MM-dd)
    String fechaNacimientoStr = "";
    if (editar && a.getFechaNacimiento() != null) {
        fechaNacimientoStr = a.getFechaNacimiento().toString();
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= editar ? "Editar Alumno" : "Registrar Alumno"%></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="assets/css/estilos.css?v=1.4">
    <style>
        .form-container {
            max-width: 800px;
            margin: 0 auto;
        }
        .section-title {
            color: #2c3e50;
            border-bottom: 2px solid #3498db;
            padding-bottom: 10px;
            margin-bottom: 20px;
            font-weight: 600;
        }
        .required-field::after {
            content: " *";
            color: #e74c3c;
        }
        .form-card {
            border: none;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            border-radius: 10px;
            overflow: hidden;
        }
        .btn-submit {
            background: linear-gradient(135deg, #2ecc71, #27ae60);
            border: none;
            padding: 12px 30px;
            font-weight: 600;
            transition: all 0.3s;
        }
        .btn-submit:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(46, 204, 113, 0.3);
        }
        .btn-cancel {
            background: linear-gradient(135deg, #95a5a6, #7f8c8d);
            border: none;
            padding: 12px 30px;
            font-weight: 600;
        }
    </style>
</head>
<body class="dashboard-page">
    <jsp:include page="header.jsp" />

    <div class="container mt-5 mb-5">
        <div class="form-container">
            <h2 class="mb-4 text-center fw-bold text-primary">
                <%= editar ? "📝 Editar Alumno" : "Registrar Alumno"%>
            </h2>
            
            <!-- Mensajes de éxito/error -->
            <% if (request.getAttribute("error") != null) { %>
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <%= request.getAttribute("error") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>
            
            <% if (request.getAttribute("mensaje") != null) { %>
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <%= request.getAttribute("mensaje") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            <% } %>

            <form action="AlumnoServlet" method="post" class="p-4 form-card bg-white">
                <input type="hidden" name="id" value="<%= editar ? a.getId() : "" %>">
                
                <!-- SECCIÓN: INFORMACIÓN PERSONAL -->
                <h4 class="section-title">📋 Información Personal</h4>
                
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label required-field">Nombres:</label>
                        <input type="text" class="form-control" name="nombres" 
                               value="<%= editar && a.getNombres() != null ? a.getNombres() : "" %>" 
                               required maxlength="100" placeholder="Ingrese los nombres (ej: Renato Augusto)">
                    </div>

                    <div class="col-md-6 mb-3">
                        <label class="form-label required-field">Apellidos:</label>
                        <input type="text" class="form-control" name="apellidos" 
                               value="<%= editar && a.getApellidos() != null ? a.getApellidos() : "" %>" 
                               required maxlength="100" placeholder="Ingrese los apellidos(ej: Balboa Nuñez)">
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label required-field">Correo Electrónico:</label>
                        <input type="email" class="form-control" name="correo" 
                               value="<%= editar && a.getCorreo() != null ? a.getCorreo() : "" %>" 
                               required maxlength="100" placeholder="ejemplo@email.com">
                    </div>

                    <div class="col-md-6 mb-3">
                        <label class="form-label">DNI:</label>
                        <input type="text" class="form-control" name="dni" 
                               value="<%= editar && a.getDni() != null ? a.getDni() : "" %>" 
                               maxlength="8" pattern="[0-9]{8}" 
                               placeholder="8 dígitos (ej: 12345678)">
                        <small class="form-text text-muted">Opcional, 8 dígitos numéricos</small>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label required-field">Fecha de Nacimiento:</label>
                        <input type="date" class="form-control" name="fecha_nacimiento" 
                               value="<%= fechaNacimientoStr %>" max="9999-12-31" onblur="validarAnio(this)" >
                        <div class="text-xs text-red-500 mt-1 hidden" id="error-fecha">Seleccione una fecha válida</div>
                    </div>

                    <div class="col-md-6 mb-3">
                        <label class="form-label">Teléfono:</label>
                        <input type="tel" class="form-control" name="telefono" 
                               value="<%= editar && a.getTelefono() != null ? a.getTelefono() : "" %>" 
                               maxlength="9" placeholder="Solo se aceptan 9 dígitos y que empiecen con 9 (ej:987654321)">
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label">Dirección:</label>
                    <textarea class="form-control" name="direccion" rows="3" maxlength="255" 
                              placeholder="Av. Principal 123, Distrito, Ciudad"><%= editar && a.getDireccion() != null ? a.getDireccion() : "" %></textarea>
                </div>

                <!-- SECCIÓN: INFORMACIÓN ACADÉMICA -->
                <h4 class="section-title mt-4">🎓 Información Académica</h4>
                
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label required-field">Grado/Salón:</label>
                        <select name="grado_id" class="form-select" required>
                            <option value="">-- Selecciona un grado --</option>
                            <% for (Grado g : grados) { 
                                boolean selected = editar && a.getGradoId() == g.getId();
                            %>
                            <option value="<%= g.getId() %>" <%= selected ? "selected" : "" %>>
                                <%= g.getNombre() %> - <%= g.getNivel() %>
                            </option>
                            <% } %>
                        </select>
                    </div>
                    
                    <% if (editar && a.getCodigoAlumno() != null) { %>
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Código de Alumno:</label>
                        <input type="text" class="form-control" value="<%= a.getCodigoAlumno() %>" readonly>
                        <small class="form-text text-muted">Código generado automáticamente</small>
                    </div>
                    <% } %>
                </div>

                <!-- BOTONES -->
                <div class="d-flex justify-content-between mt-4">
                    <div>
                        <button type="submit" class="btn btn-submit text-white me-2">
                            <%= editar ? "💾 Actualizar Alumno" : "✅ Registrar Alumno" %>
                        </button>
                        <a href="AlumnoServlet" class="btn btn-cancel text-white">❌ Cancelar</a>
                    </div>
                    
                    <% if (editar) { %>
                    <div>
                        <a href="AlumnoServlet?accion=eliminar&id=<%= a.getId() %>" 
                           class="btn btn-outline-danger"
                           onclick="return confirm('¿Está seguro de eliminar este alumno?')">
                            🗑️ Eliminar Alumno
                        </a>
                    </div>
                    <% } %>
                </div>
            </form>
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
    
    <script>
        // Establecer fecha por defecto (hace 10 años) si no estamos editando
        document.addEventListener('DOMContentLoaded', function() {
            const fechaInput = document.querySelector('input[name="fecha_nacimiento"]');
            
            if (!<%= editar %> && (!fechaInput.value || fechaInput.value === '')) {
                const hoy = new Date();
                const hace10Anios = new Date(hoy.getFullYear() - 10, hoy.getMonth(), hoy.getDate());
                const fechaFormateada = hace10Anios.toISOString().split('T')[0];
                fechaInput.value = fechaFormateada;
            }
            
            // Validación del DNI (solo números, 8 dígitos)
            const dniInput = document.querySelector('input[name="dni"]');
            if (dniInput) {
                dniInput.addEventListener('input', function() {
                    this.value = this.value.replace(/[^0-9]/g, '');
                    if (this.value.length > 8) {
                        this.value = this.value.slice(0, 8);
                    }
                });
            }
            
            // Validación del teléfono (solo números)
            const telefonoInput = document.querySelector('input[name="telefono"]');
            if (telefonoInput) {
                telefonoInput.addEventListener('input', function() {
                    this.value = this.value.replace(/[^0-9]/g, '');
                });
            }
            
            // Confirmación antes de enviar el formulario
            const form = document.querySelector('form');
            form.addEventListener('submit', function(event) {
                const nombres = document.querySelector('input[name="nombres"]').value.trim();
                const apellidos = document.querySelector('input[name="apellidos"]').value.trim();
                const correo = document.querySelector('input[name="correo"]').value.trim();
                const fecha = document.querySelector('input[name="fecha_nacimiento"]').value;
                const grado = document.querySelector('select[name="grado_id"]').value;
                
                let errores = [];
                
                if (nombres === '') errores.push('Nombres es obligatorio');
                if (apellidos === '') errores.push('Apellidos es obligatorio');
                if (correo === '' || !correo.includes('@')) errores.push('Correo electrónico válido es obligatorio');
                if (fecha === '') errores.push('Fecha de nacimiento es obligatoria');
                if (grado === '') errores.push('Debe seleccionar un grado');
                
                if (errores.length > 0) {
                    event.preventDefault();
                    alert('Por favor corrija los siguientes errores:\n\n• ' + errores.join('\n• '));
                }
            });
        });
    </script>
</body>
</html>