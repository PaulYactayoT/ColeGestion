<%-- 
    Document   : usuarioForm
    Created on : 2 may. 2025, 1:45:40 a. m.
    Author     : Juan Pablo Amaya
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Usuario" %>
<%@ page import="javax.servlet.http.HttpSession" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    Usuario u = (Usuario) request.getAttribute("usuario");
    boolean esEditar = u != null;
    
    String username = "";
    String rol = "";
    int id = 0;
    
    if (esEditar && u != null) {
        username = u.getUsername() != null ? u.getUsername() : "";
        rol = u.getRol() != null ? u.getRol() : "";
        id = u.getId();
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title><%= esEditar ? "Editar Usuario" : "Registrar Usuario"%></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="assets/css/estilos.css">
    <!-- ✅ INCLUIR CRYPTO-JS PARA SHA256 -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/crypto-js/4.1.1/crypto-js.min.js"></script>
    <style>
        .requisito-cumplido { color: #28a745; font-weight: 500; }
        .requisito-incumplido { color: #dc3545; }
        .requisito-pendiente { color: #6c757d; }
        .criterio-item { 
            transition: all 0.3s ease; 
            margin-bottom: 5px;
            padding: 2px 5px;
            border-radius: 3px;
            list-style: none;
        }
        .requisitos-password {
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            border: 1px solid #dee2e6;
        }
        .criteria-counter {
            font-weight: bold;
            padding: 3px 8px;
            border-radius: 15px;
            background-color: #e9ecef;
        }
        .password-feedback {
            min-height: 20px;
            font-size: 0.9em;
            margin-top: 5px;
        }
        .debug-info {
            background-color: #fff3cd;
            border: 1px solid #ffeaa7;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 15px;
            font-size: 0.9em;
        }
    </style>
</head>
<body class="dashboard-page">

    <jsp:include page="header.jsp" />

    <div class="container mt-4">
        <h2><%= esEditar ? "Editar Usuario" : "Registrar Usuario"%></h2>
        
        <div class="debug-info">
            <strong>Modo:</strong> <%= esEditar ? "EDICIÓN" : "REGISTRO" %> | 
            <strong>Usuario ID:</strong> <%= id %> | 
            <strong>Username:</strong> <%= username %>
        </div>
        
        <% if (session.getAttribute("mensaje") != null) { %>
            <div class="alert alert-success alert-dismissible fade show">
                <%= session.getAttribute("mensaje") %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <% session.removeAttribute("mensaje"); %>
        <% } %>
        
        <% if (session.getAttribute("error") != null) { %>
            <div class="alert alert-danger alert-dismissible fade show">
                <%= session.getAttribute("error") %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <% session.removeAttribute("error"); %>
        <% } %>
        
        <form action="UsuarioServlet" method="post" id="usuarioForm">
            <input type="hidden" name="id" value="<%= id %>">

            <div class="mb-3">
                <label class="form-label">Nombre de Usuario:</label>
                <input type="text" class="form-control" name="username" 
                       value="<%= username %>" 
                       required
                       <%= esEditar ? "readonly" : "" %>>
                <% if (esEditar) { %>
                    <div class="form-text">El nombre de usuario no se puede modificar</div>
                <% } %>
            </div>

            <div class="mb-3">
                <label class="form-label">Contraseña:</label>
                <input type="password" class="form-control" name="password" 
                       id="passwordInput" 
                       value=""
                       <%= esEditar ? "" : "required" %>
                       oninput="validarPasswordEnTiempoReal(this.value)"
                       placeholder="<%= esEditar ? "Dejar vacío para mantener contraseña actual" : "Ingrese una contraseña segura"%>">
                
                <div id="indicadorPassword" class="password-feedback"></div>
                
                <div class="requisitos-password mt-2 p-3 border rounded" style="background-color: #f8f9fa; font-size: 0.8em; display: none;" id="requisitosPassword">
                    <strong>Requisitos de contraseña segura:</strong>
                    <ul class="mb-0 mt-2" style="padding-left: 1.2em;">
                        <li id="reqLongitud" class="criterio-item requisito-pendiente">Mínimo 8 caracteres</li>
                        <li id="reqMayuscula" class="criterio-item requisito-pendiente">Al menos una letra mayúscula</li>
                        <li id="reqMinuscula" class="criterio-item requisito-pendiente">Al menos una letra minúscula</li>
                        <li id="reqNumero" class="criterio-item requisito-pendiente">Al menos un número</li>
                        <li id="reqEspecial" class="criterio-item requisito-pendiente">Al menos un carácter especial (!@#$%^&* etc.)</li>
                        <li id="reqCriterios" class="criterio-item requisito-pendiente">Cumplir al menos 3 de los 4 criterios anteriores</li>
                    </ul>
                    <div class="mt-2" id="contadorCriterios">
                        <small>Criterios cumplidos: <span id="criteriosCumplidos">0</span>/4</small>
                    </div>
                </div>
                
                <% if (esEditar) { %>
                    <div class="form-text">Dejar en blanco para mantener la contraseña actual</div>
                <% } %>
            </div>

            <div class="mb-3">
                <label class="form-label">Rol:</label>
                <select class="form-select" name="rol" required>
                    <option value="">-- Selecciona un rol --</option>
                    <option value="admin" <%= "admin".equals(rol) ? "selected" : "" %>>admin</option>
                    <option value="docente" <%= "docente".equals(rol) ? "selected" : "" %>>docente</option>
                    <option value="padre" <%= "padre".equals(rol) ? "selected" : "" %>>padre</option>
                </select>
            </div>

            <button type="submit" class="btn btn-primary" id="submitBtn">
                <%= esEditar ? "Actualizar" : "Registrar"%>
            </button>
            <a href="UsuarioServlet" class="btn btn-secondary">Cancelar</a>
        </form>
    </div>

    <!-- ✅ SCRIPT PARA ENCRIPTACIÓN SHA256 -->
    <script>
        // ✅ FUNCIÓN PARA ENCRIPTAR CON SHA256
        function encriptarPasswordSHA256(password) {
            return new Promise((resolve, reject) => {
                try {
                    const hashedPassword = CryptoJS.SHA256(password).toString();
                    console.log("🔐 Contraseña encriptada con SHA256 para formulario usuario:", hashedPassword);
                    resolve(hashedPassword);
                } catch (error) {
                    console.error("❌ Error encriptando con SHA256:", error);
                    reject(error);
                }
            });
        }

        const textosOriginales = {
            reqLongitud: "Mínimo 8 caracteres",
            reqMayuscula: "Al menos una letra mayúscula",
            reqMinuscula: "Al menos una letra minúscula", 
            reqNumero: "Al menos un número",
            reqEspecial: "Al menos un carácter especial (!@#$%^&* etc.)",
            reqCriterios: "Cumplir al menos 3 de los 4 criterios anteriores"
        };

        function validarPasswordEnTiempoReal(password) {
            const indicador = document.getElementById('indicadorPassword');
            const requisitos = document.getElementById('requisitosPassword');
            const submitBtn = document.getElementById('submitBtn');
            const esEdicion = <%= esEditar %>;
            
            if (password.length > 0) {
                requisitos.style.display = 'block';
            } else {
                if (esEdicion) {
                    indicador.innerHTML = '<span class="text-success">✅ Se mantendrá la contraseña actual</span>';
                    submitBtn.disabled = false;
                } else {
                    indicador.innerHTML = '<span class="text-warning">⚠️ Ingrese una contraseña</span>';
                    submitBtn.disabled = true;
                }
                requisitos.style.display = 'none';
                resetearRequisitos();
                return;
            }
            
            const longitudValida = password.length >= 8;
            const tieneMayuscula = /[A-Z]/.test(password);
            const tieneMinuscula = /[a-z]/.test(password);
            const tieneNumero = /[0-9]/.test(password);
            const tieneEspecial = /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(password);
            
            actualizarRequisito('reqLongitud', longitudValida);
            actualizarRequisito('reqMayuscula', tieneMayuscula);
            actualizarRequisito('reqMinuscula', tieneMinuscula);
            actualizarRequisito('reqNumero', tieneNumero);
            actualizarRequisito('reqEspecial', tieneEspecial);
            
            let criteriosCumplidos = 0;
            if (tieneMayuscula) criteriosCumplidos++;
            if (tieneMinuscula) criteriosCumplidos++;
            if (tieneNumero) criteriosCumplidos++;
            if (tieneEspecial) criteriosCumplidos++;
            
            const criteriosValidos = criteriosCumplidos >= 3;
            actualizarRequisito('reqCriterios', criteriosValidos);
            
            document.getElementById('criteriosCumplidos').textContent = criteriosCumplidos;
            
            const esFuerte = longitudValida && criteriosValidos;
            
            if (esFuerte) {
                indicador.innerHTML = '<span class="text-success">✅ Contraseña segura - Cumple todos los requisitos</span>';
                submitBtn.disabled = false;
            } else {
                let mensajesError = [];
                if (!longitudValida) mensajesError.push('mínimo 8 caracteres');
                if (!criteriosValidos) mensajesError.push('cumplir 3 de 4 criterios');
                
                indicador.innerHTML = '<span class="text-danger">❌ Faltan: ' + mensajesError.join(', ') + '</span>';
                submitBtn.disabled = true;
            }
        }
        
        function actualizarRequisito(elementId, cumple) {
            const elemento = document.getElementById(elementId);
            const textoBase = textosOriginales[elementId];
            
            if (cumple) {
                elemento.className = 'criterio-item requisito-cumplido';
                elemento.innerHTML = '✅ ' + textoBase;
            } else {
                elemento.className = 'criterio-item requisito-incumplido';
                elemento.innerHTML = '❌ ' + textoBase;
            }
        }
        
        function resetearRequisitos() {
            Object.keys(textosOriginales).forEach(elementId => {
                const elemento = document.getElementById(elementId);
                if (elemento) {
                    elemento.className = 'criterio-item requisito-pendiente';
                    elemento.innerHTML = '❌ ' + textosOriginales[elementId];
                }
            });
            document.getElementById('criteriosCumplidos').textContent = '0';
        }
        
        // ✅ MODIFICAR EL ENVÍO DEL FORMULARIO PARA ENCRIPTAR CON SHA256
        document.getElementById('usuarioForm').addEventListener('submit', async function(e) {
            e.preventDefault();
            
            const password = document.getElementById('passwordInput').value;
            const esEdicion = <%= esEditar %>;
            
            if (!esEdicion && password.length === 0) {
                alert('La contraseña es obligatoria para nuevos usuarios');
                return false;
            }
            
            if (password.length > 0) {
                const longitudValida = password.length >= 8;
                const tieneMayuscula = /[A-Z]/.test(password);
                const tieneMinuscula = /[a-z]/.test(password);
                const tieneNumero = /[0-9]/.test(password);
                const tieneEspecial = /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(password);
                
                let criteriosCumplidos = 0;
                if (tieneMayuscula) criteriosCumplidos++;
                if (tieneMinuscula) criteriosCumplidos++;
                if (tieneNumero) criteriosCumplidos++;
                if (tieneEspecial) criteriosCumplidos++;
                
                const criteriosValidos = criteriosCumplidos >= 3;
                const esFuerte = longitudValida && criteriosValidos;
                
                if (!esFuerte) {
                    alert('La contraseña no cumple con los requisitos de seguridad. Revise los criterios indicados.');
                    return false;
                }

                // ✅ ENCRIPTAR CONTRASEÑA CON SHA256 ANTES DE ENVIAR
                try {
                    const hashedPassword = await encriptarPasswordSHA256(password);
                    document.getElementById('passwordInput').value = hashedPassword;
                } catch (error) {
                    alert('Error encriptando la contraseña. Intente nuevamente.');
                    return false;
                }
            }
            
            this.submit();
        });

        document.getElementById('passwordInput').addEventListener('focus', function() {
            if (this.value.length > 0) {
                document.getElementById('requisitosPassword').style.display = 'block';
            }
        });
        
        document.getElementById('passwordInput').addEventListener('blur', function() {
            if (this.value.length === 0) {
                setTimeout(() => {
                    document.getElementById('requisitosPassword').style.display = 'none';
                }, 500);
            }
        });
    </script>
    
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
</body>
</html>