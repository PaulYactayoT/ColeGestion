<%-- 
    Document   : profesorForm
    Created on : 1 may. 2025, 8:57:32 p. m.
    Author     : Juan Pablo Amaya
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Profesor" %>
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

    Profesor p = (Profesor) request.getAttribute("profesor");
    boolean editar = (p != null);
    
    // Formatear fechas para input date (yyyy-MM-dd)
    String fechaNacimientoStr = "";
    String fechaContratacionStr = "";
    
    if (editar) {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        if (p.getFechaNacimiento() != null) {
            fechaNacimientoStr = sdf.format(p.getFechaNacimiento());
        }
        if (p.getFechaContratacion() != null) {
            fechaContratacionStr = sdf.format(p.getFechaContratacion());
        }
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= editar ? "Editar Profesor" : "Registrar Profesor"%></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="assets/css/estilos.css?v=1.5">
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
                <%= editar ? "📝 Editar Profesor" : "➕ Registrar Profesor"%>
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

            <form action="ProfesorServlet" method="post" class="p-4 form-card bg-white">
                <input type="hidden" name="id" value="<%= editar ? p.getId() : "" %>">
                
                <!-- SECCIÓN: INFORMACIÓN PERSONAL -->
                <h4 class="section-title">📋 Información Personal</h4>
                
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label required-field">Nombres:</label>
                        <input type="text" class="form-control" name="nombres" 
                               value="<%= editar && p.getNombres() != null ? p.getNombres() : "" %>" 
                               required maxlength="100" placeholder="Ingrese los nombres">
                    </div>

                    <div class="col-md-6 mb-3">
                        <label class="form-label required-field">Apellidos:</label>
                        <input type="text" class="form-control" name="apellidos" 
                               value="<%= editar && p.getApellidos() != null ? p.getApellidos() : "" %>" 
                               required maxlength="100" placeholder="Ingrese los apellidos">
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label required-field">Correo Electrónico:</label>
                        <input type="email" class="form-control" name="correo" 
                               value="<%= editar && p.getCorreo() != null ? p.getCorreo() : "" %>" 
                               required maxlength="100" placeholder="ejemplo@email.com">
                    </div>

                    <div class="col-md-6 mb-3">
                        <label class="form-label">DNI:</label>
                        <input type="text" class="form-control" name="dni" 
                               value="<%= editar && p.getDni() != null ? p.getDni() : "" %>" 
                               maxlength="8" pattern="[0-9]{8}" 
                               placeholder="8 dígitos (ej: 12345678)">
                        <small class="form-text text-muted">Opcional, 8 dígitos numéricos</small>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Fecha de Nacimiento:</label>
                        <input type="date" class="form-control" name="fecha_nacimiento" 
                               value="<%= fechaNacimientoStr %>">
                    </div>

                    <div class="col-md-6 mb-3">
                        <label class="form-label">Teléfono:</label>
                        <input type="tel" class="form-control" name="telefono" 
                               value="<%= editar && p.getTelefono() != null ? p.getTelefono() : "" %>" 
                               maxlength="20" placeholder="987654321">
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label">Dirección:</label>
                    <textarea class="form-control" name="direccion" rows="3" maxlength="255" 
                              placeholder="Av. Principal 123, Distrito, Ciudad"><%= editar && p.getDireccion() != null ? p.getDireccion() : "" %></textarea>
                </div>

                <!-- SECCIÓN: INFORMACIÓN PROFESIONAL -->
                <h4 class="section-title mt-4">👨‍🏫 Información Profesional</h4>
                
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label required-field">Especialidad:</label>
                        <select class="form-select" name="especialidad" required>
                            <option value="">Seleccione una especialidad</option>
                            <option value="Biología" <%= (editar && "Biología".equals(p.getEspecialidad())) ? "selected" : "" %>>Biología</option>
                            <option value="Historia" <%= (editar && "Historia".equals(p.getEspecialidad())) ? "selected" : "" %>>Historia</option>
                            <option value="Matemática" <%= (editar && "Matemática".equals(p.getEspecialidad())) ? "selected" : "" %>>Matemática</option>
                            <option value="Comunicación" <%= (editar && "Comunicación".equals(p.getEspecialidad())) ? "selected" : "" %>>Comunicación</option>
                            <option value="Geografía" <%= (editar && "Geografía".equals(p.getEspecialidad())) ? "selected" : "" %>>Geografía</option>
                            <option value="Educación Física" <%= (editar && "Educación Física".equals(p.getEspecialidad())) ? "selected" : "" %>>Educación Física</option>
                            <option value="Arte y Cultura" <%= (editar && "Arte y Cultura".equals(p.getEspecialidad())) ? "selected" : "" %>>Arte y Cultura</option>
                            <option value="Química" <%= (editar && "Química".equals(p.getEspecialidad())) ? "selected" : "" %>>Química</option>
                        </select>
                    </div>

                    <div class="col-md-6 mb-3">
                        <label class="form-label">Código de Profesor:</label>
                        <input type="text" class="form-control" name="codigo_profesor" 
                               value="<%= editar && p.getCodigoProfesor() != null ? p.getCodigoProfesor() : "" %>" 
                               maxlength="20" placeholder="Ej: PROF-001">
                        <small class="form-text text-muted">Opcional, se generará automáticamente</small>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Fecha de Contratación:</label>
                        <input type="date" class="form-control" name="fecha_contratacion" 
                               value="<%= fechaContratacionStr %>">
                    </div>

                    <div class="col-md-6 mb-3">
                        <label class="form-label">Estado:</label>
                        <select name="estado" class="form-select">
                            <option value="ACTIVO" <%= (editar && "ACTIVO".equals(p.getEstado())) ? "selected" : "" %>>ACTIVO</option>
                            <option value="INACTIVO" <%= (editar && "INACTIVO".equals(p.getEstado())) ? "selected" : "" %>>INACTIVO</option>
                            <option value="LICENCIA" <%= (editar && "LICENCIA".equals(p.getEstado())) ? "selected" : "" %>>LICENCIA</option>
                            <option value="JUBILADO" <%= (editar && "JUBILADO".equals(p.getEstado())) ? "selected" : "" %>>JUBILADO</option>
                        </select>
                    </div>
                </div>

                <!-- SECCIÓN: USUARIO DEL SISTEMA -->
                <h4 class="section-title mt-4">🔐 Acceso al Sistema</h4>
                
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Nombre de Usuario:</label>
                        <input type="text" class="form-control" name="username" 
                               value="<%= editar && p.getUsername() != null ? p.getUsername() : "" %>" 
                               maxlength="50" placeholder="Nombre de usuario para login">
                        <small class="form-text text-muted">Opcional, se generará automáticamente</small>
                    </div>
                    
                    <div class="col-md-6 mb-3">
                        <label class="form-label">Contraseña:</label>
                        <input type="password" class="form-control" name="password" 
                               placeholder="<%= editar ? "Dejar en blanco para no cambiar" : "Ingrese contraseña" %>"
                               <%= editar ? "" : "required" %>>
                        <small class="form-text text-muted">
                            <%= editar ? "Solo llene si desea cambiar la contraseña" : "La contraseña se hasheará con SHA-256" %>
                        </small>
                    </div>
                </div>

                <!-- BOTONES -->
                <div class="d-flex justify-content-between mt-4">
                    <div>
                        <button type="submit" class="btn btn-submit text-white me-2">
                            <%= editar ? "💾 Actualizar Profesor" : "✅ Registrar Profesor" %>
                        </button>
                        <a href="ProfesorServlet" class="btn btn-cancel text-white">❌ Cancelar</a>
                    </div>
                    
                    <% if (editar) { %>
                    <div>
                        <a href="ProfesorServlet?accion=eliminar&id=<%= p.getId() %>" 
                           class="btn btn-outline-danger"
                           onclick="return confirm('¿Está seguro de eliminar este profesor?')">
                            🗑️ Eliminar Profesor
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
        // Establecer fechas por defecto si no estamos editando
        document.addEventListener('DOMContentLoaded', function() {
            const fechaNacInput = document.querySelector('input[name="fecha_nacimiento"]');
            const fechaContInput = document.querySelector('input[name="fecha_contratacion"]');
            
            // Fecha de nacimiento por defecto (hace 30 años)
            if (!<%= editar %> && (!fechaNacInput.value || fechaNacInput.value === '')) {
                const hoy = new Date();
                const hace30Anios = new Date(hoy.getFullYear() - 30, hoy.getMonth(), hoy.getDate());
                fechaNacInput.valueAsDate = hace30Anios;
            }
            
            // Fecha de contratación por defecto (hoy)
            if (!<%= editar %> && (!fechaContInput.value || fechaContInput.value === '')) {
                const hoy = new Date();
                fechaContInput.valueAsDate = hoy;
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
                const especialidad = document.querySelector('select[name="especialidad"]').value.trim();
                
                let errores = [];
                
                if (nombres === '') errores.push('Nombres es obligatorio');
                if (apellidos === '') errores.push('Apellidos es obligatorio');
                if (correo === '' || !correo.includes('@')) errores.push('Correo electrónico válido es obligatorio');
                if (especialidad === '') errores.push('Especialidad es obligatoria');
                
                if (errores.length > 0) {
                    event.preventDefault();
                    alert('Por favor corrija los siguientes errores:\n\n• ' + errores.join('\n• '));
                }
            });
        });
    </script>
</body>
</html>