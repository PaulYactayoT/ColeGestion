<%-- 
    Document   : index
    Created on : 1 may. 2025, 1:23:30 p.m.
    Author     : Juan Pablo Amaya
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>

<%
    // Obtener parámetros de error e intentos
    String error = request.getParameter("error");
    String intentosParam = request.getParameter("intentos");
    int intentosRestantes = intentosParam != null ? Integer.parseInt(intentosParam) : 3;
    int intentoActual = 4 - intentosRestantes;
    boolean estaBloqueado = "bloqueado".equals(error);
    
    // Manejar tiempo de bloqueo
    Long tiempoRestanteMs = (Long) request.getAttribute("tiempoRestante");
    if (tiempoRestanteMs == null && estaBloqueado) {
        tiempoRestanteMs = 60000L;
    }
    
    // Recordar último usuario ingresado
    String lastUsername = request.getParameter("username");
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Iniciar Sesión - Sistema Académico</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
        <link rel="stylesheet" href="assets/css/estilos.css">
        <!-- CryptoJS Local para encriptación -->
        <script src="assets/js/crypto-js.min.js"></script>
        <style>
            :root {
                --primary-color: #2c5aa0;
                --primary-dark: #1e3d72;
                --primary-light: #4a7bc8;
                --accent-color: #28a745;
                --warning-color: #ffc107;
                --danger-color: #dc3545;
                --success-color: #20c997;
                --dark-color: #2d3748;
                --light-color: #f8f9fa;
                --gray-color: #6c757d;
                --gray-light-color: #c7d4e0;
                --white-color: #ffffff;
            }
            
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }
            
            body {
                background: url('assets/img/fondo_login.jpg') no-repeat center center fixed;
                background-size: cover;
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
                padding: 20px;
                margin: 0;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                position: relative;
            }
            
            /* Overlay sutil para mejorar legibilidad */
            body::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background: rgba(255, 255, 255, 0.1);
                backdrop-filter: blur(2px);
                pointer-events: none;
            }
            
            .login-container {
                position: relative;
                z-index: 10;
                width: 100%;
                max-width: 440px;
                animation: fadeInUp 0.8s ease-out;
            }
            
            .login-card {
                background: rgba(255, 255, 255, 0.98);
                padding: 2.5rem;
                border-radius: 16px;
                box-shadow: 0 15px 50px rgba(0, 0, 0, 0.15);
                border: 1px solid rgba(255, 255, 255, 0.8);
                position: relative;
                overflow: hidden;
                transition: transform 0.3s ease, box-shadow 0.3s ease;
            }
            
            .login-card:hover {
                transform: translateY(-3px);
                box-shadow: 0 20px 60px rgba(0, 0, 0, 0.2);
            }
            
            .login-card::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                height: 4px;
                background: linear-gradient(90deg, var(--primary-color), var(--primary-dark));
            }
            
            .login-header {
                text-align: center;
                margin-bottom: 2rem;
            }
            
            .login-icon {
                width: 70px;
                height: 70px;
                background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                margin: 0 auto 1rem;
                box-shadow: 0 8px 25px rgba(44, 90, 160, 0.3);
            }
            
            .login-icon i {
                font-size: 1.8rem;
                color: white;
            }
            
            .login-title {
                color: var(--dark-color);
                font-weight: 700;
                font-size: 1.6rem;
                margin-bottom: 0.5rem;
            }
            
            .login-subtitle {
                color: var(--gray-color);
                font-size: 0.9rem;
            }
            
            .form-group {
                margin-bottom: 1.5rem;
                position: relative;
            }
            
            .form-label {
                font-weight: 600;
                color: var(--dark-color);
                margin-bottom: 0.5rem;
                display: flex;
                align-items: center;
                gap: 0.5rem;
                font-size: 0.95rem;
            }
            
            .form-label i {
                color: var(--primary-color);
                width: 16px;
            }
            
            .form-control {
                padding: 0.75rem 1rem 0.75rem 2.5rem;
                border: 2px solid #e9ecef;
                border-radius: 10px;
                font-size: 1rem;
                transition: all 0.3s ease;
                background: white;
            }
            
            .form-control:focus {
                border-color: var(--primary-color);
                box-shadow: 0 0 0 3px rgba(44, 90, 160, 0.1);
                background: white;
            }
            
            .input-icon {
                position: absolute;
                left: 1rem;
                top: 50%;
                transform: translateY(-50%);
                color: var(--gray-color);
                transition: color 0.3s ease;
            }
            
            .form-control:focus + .input-icon {
                color: var(--primary-color);
            }
            
            .btn-login {
                background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
                border: none;
                padding: 0.75rem 2rem;
                border-radius: 10px;
                font-weight: 600;
                font-size: 1rem;
                transition: all 0.3s ease;
                box-shadow: 0 8px 25px rgba(44, 90, 160, 0.3);
                color: var(--gray-light-color);
                position: relative;
                overflow: hidden;
            }
            
            .btn-login:hover {
                color: var(--white-color);
                transform: translateY(-2px);
                box-shadow: 0 12px 35px rgba(44, 90, 160, 0.4);
                background: linear-gradient(135deg, var(--primary-dark), var(--primary-color));
            }
            
            .btn-login:active {
                transform: translateY(0);
            }
            
            .captcha-modal {
                display: none;
                position: fixed;
                z-index: 1000;
                left: 0;
                top: 0;
                width: 100%;
                height: 100%;
                background-color: rgba(0,0,0,0.6);
            }
            
            .captcha-content {
                background: white;
                margin: 10% auto;
                padding: 2rem;
                border-radius: 16px;
                width: 90%;
                max-width: 450px;
                box-shadow: 0 20px 60px rgba(0,0,0,0.3);
                animation: modalSlideIn 0.4s ease-out;
                position: relative;
            }
            
            .captcha-content::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                height: 4px;
                background: linear-gradient(90deg, var(--warning-color), var(--danger-color));
                border-radius: 16px 16px 0 0;
            }
            
            .captcha-header {
                text-align: center;
                margin-bottom: 1.5rem;
            }
            
            .captcha-header i {
                font-size: 2.2rem;
                color: var(--warning-color);
                margin-bottom: 1rem;
            }
            
            .captcha-text {
                font-family: 'Courier New', monospace;
                font-size: 26px;
                font-weight: bold;
                letter-spacing: 3px;
                background: linear-gradient(45deg, var(--primary-color), var(--primary-dark));
                -webkit-background-clip: text;
                -webkit-text-fill-color: transparent;
                padding: 18px;
                border: 2px dashed #dee2e6;
                border-radius: 10px;
                text-align: center;
                user-select: none;
                margin: 15px 0;
                background-color: #f8f9fa;
            }
            
            .captcha-refresh {
                cursor: pointer;
                color: var(--primary-color);
                background: none;
                border: none;
                font-size: 15px;
                transition: color 0.3s ease;
            }
            
            .captcha-refresh:hover {
                color: var(--primary-dark);
            }
            
            .alert-captcha {
                display: none;
                margin-top: 10px;
                border-radius: 10px;
                border-left: 4px solid var(--danger-color);
            }
            
            .loading {
                display: none;
                text-align: center;
                padding: 20px;
            }
            
            .spinner-border {
                width: 2.5rem;
                height: 2.5rem;
                border-width: 0.25em;
            }
            
            .intento-indicator {
                display: flex;
                justify-content: center;
                margin: 20px 0;
                gap: 8px;
            }
            
            .intento-punto {
                width: 14px;
                height: 14px;
                border-radius: 50%;
                background-color: #e9ecef;
                transition: all 0.3s ease;
                position: relative;
            }
            
            .intento-punto.activo {
                background-color: var(--warning-color);
                transform: scale(1.1);
                box-shadow: 0 0 10px rgba(255, 193, 7, 0.4);
            }
            
            .intento-punto.completado {
                background-color: var(--danger-color);
            }
            
            .progress {
                height: 6px;
                margin: 15px 0;
                border-radius: 8px;
                background-color: #e9ecef;
                overflow: hidden;
            }
            
            .progress-bar {
                border-radius: 8px;
                transition: width 0.5s ease;
            }
            
            .tiempo-restante {
                font-size: 0.85em;
                color: var(--gray-color);
                margin-top: 5px;
            }
            
            .attempt-warning {
                border-left: 4px solid var(--warning-color);
                background: linear-gradient(135deg, rgba(255, 193, 7, 0.08), rgba(255, 193, 7, 0.03));
                border-radius: 10px;
            }
            
            .attempt-danger {
                border-left: 4px solid var(--danger-color);
                background: linear-gradient(135deg, rgba(220, 53, 69, 0.08), rgba(220, 53, 69, 0.03));
                border-radius: 10px;
            }
            
            .alert {
                border-radius: 10px;
                border: none;
                padding: 1rem 1.25rem;
            }
            
            @keyframes fadeInUp {
                from {
                    opacity: 0;
                    transform: translateY(20px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }
            
            @keyframes modalSlideIn {
                from {
                    opacity: 0;
                    transform: translateY(-30px) scale(0.95);
                }
                to {
                    opacity: 1;
                    transform: translateY(0) scale(1);
                }
            }
            
            @media (max-width: 576px) {
                .login-card {
                    padding: 2rem 1.5rem;
                    margin: 1rem;
                }
                
                .captcha-content {
                    margin: 20% auto;
                    width: 95%;
                    padding: 1.5rem;
                }
                
                .login-title {
                    font-size: 1.4rem;
                }
            }
        </style>
    </head>

    <body>
        <div class="login-container">
            <div class="login-card">
                <div class="login-header">
                    <div class="login-icon">
                        <i class="fas fa-graduation-cap"></i>
                    </div>
                    <h1 class="login-title">Sistema Académico</h1>
                    <p class="login-subtitle">Ingresa a tu cuenta para continuar</p>
                </div>

                <%-- Indicador visual de intentos fallidos --%>
                <% if (!estaBloqueado && "1".equals(error)) { %>
                <div class="intento-indicator">
                    <% for (int i = 1; i <= 3; i++) { %>
                        <div class="intento-punto <%= i <= intentoActual ? "activo" : "" %> <%= i < intentoActual ? "completado" : "" %>"></div>
                    <% } %>
                </div>
                <div class="progress">
                    <div class="progress-bar bg-warning" style="width: <%= (intentoActual / 3.0) * 100 %>%">
                        <%= intentoActual %> de 3
                    </div>
                </div>
                <% } %>

                <%-- Mensajes de estado del login --%>
                <div id="loginMessages">
                    <% if (estaBloqueado) { %>
                    <div class="alert alert-danger mt-3">
                        <div class="d-flex align-items-center">
                            <i class="fas fa-lock fa-lg me-3"></i>
                            <div>
                                <strong>Cuenta temporalmente bloqueada</strong><br>
                                Has excedido el número máximo de intentos. 
                                <span id="mensajeTiempo">
                                    <% if (tiempoRestanteMs != null && tiempoRestanteMs > 0) {%>
                                    Podrás intentarlo nuevamente en <span id="tiempoTexto"><%= (int) Math.ceil(tiempoRestanteMs / 1000.0)%></span> segundos.
                                    <% } else { %>
                                    Podrás intentarlo nuevamente en breve.
                                    <% } %>
                                </span>
                                <div class="tiempo-restante" id="tiempoDetalle">
                                    <i class="fas fa-clock me-1"></i>
                                    Tiempo restante: <span id="minutos">0</span>:<span id="segundos">00</span>
                                </div>
                            </div>
                        </div>
                    </div>
                    <% } else if ("1".equals(error)) { %>
                    <div class="alert alert-warning mt-3 attempt-warning">
                        <div class="d-flex align-items-center">
                            <i class="fas fa-exclamation-triangle fa-lg me-3"></i>
                            <div>
                                <strong>Intento <%= intentoActual %> de 3 fallido</strong><br>
                                <strong>Te quedan <%= intentosRestantes %> intento(s) restantes.</strong>
                                <% if (intentoActual == 2) { %>
                                <div class="tiempo-restante mt-1">
                                    En el próximo intento fallido, la cuenta se bloqueará por 1 minuto.
                                </div>
                                <% } %>
                            </div>
                        </div>
                    </div>
                    <% } else if ("2".equals(error)) { %>
                    <div class="alert alert-danger mt-3">
                        <i class="fas fa-server me-2"></i>
                        Error del sistema. Por favor, contacta al administrador.
                    </div>
                    <% } else if ("3".equals(error)) { %>
                    <div class="alert alert-danger mt-3">
                        <i class="fas fa-user-shield me-2"></i>
                        Rol no reconocido. Contacta al administrador.
                    </div>
                    <% } else if ("sin_docente".equals(error)) { %>
                    <div class="alert alert-danger mt-3">
                        <i class="fas fa-chalkboard-teacher me-2"></i>
                        No se encontró información del docente.
                    </div>
                    <% } else if ("padre_invalido".equals(error)) { %>
                    <div class="alert alert-danger mt-3">
                        <i class="fas fa-user-friends me-2"></i>
                        No se encontró información del padre.
                    </div>
                    <% } %>
                </div>

                <%-- Formulario de login --%>
                <form id="loginForm" method="post" class="needs-validation" novalidate>
                    <div class="form-group">
                        <label class="form-label">
                            <i class="fas fa-user"></i>
                            Usuario
                        </label>
                        <div class="position-relative">
                            <input type="text" name="username" class="form-control" required 
                                   id="usernameInput" value="<%= lastUsername != null ? lastUsername : ""%>" 
                                   <%= estaBloqueado ? "disabled" : ""%>
                                   placeholder="Ingresa tu usuario">
                            <i class="fas fa-user input-icon"></i>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">
                            <i class="fas fa-lock"></i>
                            Contraseña
                        </label>
                        <div class="position-relative">
                            <input type="password" name="password" class="form-control" required
                                   id="passwordInput" <%= estaBloqueado ? "disabled" : ""%>
                                   placeholder="Ingresa tu contraseña">
                            <i class="fas fa-key input-icon"></i>
                        </div>
                    </div>

                    <button type="submit" class="btn btn-login w-100" 
                            id="submitBtn" <%= estaBloqueado ? "disabled" : ""%>>
                        <i class="fas fa-sign-in-alt me-2"></i>
                        <%= estaBloqueado ? "Cuenta Bloqueada" : "Ingresar al Sistema"%>
                    </button>
                </form>
            </div>
        </div>

        <%-- Modal para CAPTCHA --%>
        <div id="captchaModal" class="captcha-modal">
            <div class="captcha-content">
                <div class="captcha-header">
                    <i class="fas fa-shield-alt"></i>
                    <h5>Verificación de Seguridad</h5>
                    <p class="text-muted">Credenciales correctas. Complete el CAPTCHA para finalizar:</p>
                </div>

                <div class="text-center mb-3">
                    <div id="captchaText" class="captcha-text"></div>
                    <button type="button" class="captcha-refresh" onclick="generarCaptcha()">
                        <i class="fas fa-sync-alt me-1"></i>
                        Generar nuevo código
                    </button>
                </div>

                <div class="mb-3">
                    <label class="form-label">
                        <i class="fas fa-keyboard me-1"></i>
                        Ingresa el código de arriba:
                    </label>
                    <input type="text" id="captchaInput" class="form-control" 
                           placeholder="Escribe el código aquí" required>
                    <input type="hidden" id="captchaHidden" name="captchaHidden">
                </div>

                <div id="captchaError" class="alert alert-danger alert-captcha" role="alert">
                    <i class="fas fa-exclamation-circle me-2"></i>
                    Código incorrecto. Intenta de nuevo.
                </div>

                <div class="d-flex gap-2">
                    <button type="button" class="btn btn-secondary w-50" onclick="cancelarLogin()">
                        <i class="fas fa-times me-1"></i>
                        Cancelar
                    </button>
                    <button type="button" class="btn btn-primary w-50" onclick="validarYEnviarCaptcha()">
                        <i class="fas fa-check me-1"></i>
                        Verificar y Continuar
                    </button>
                </div>
            </div>
        </div>

        <%-- Indicador de carga --%>
        <div id="loading" class="loading">
            <div class="spinner-border text-primary" role="status">
                <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-3">Verificando credenciales...</p>
        </div>

        <script>
            // Verificar que CryptoJS está cargado
            console.log("CryptoJS cargado:", typeof CryptoJS !== "undefined");
            console.log("SHA256 disponible:", typeof CryptoJS.SHA256 !== "undefined");

            let captchaCode = '';
            let loginData = null;

            // Función para encriptar contraseña con SHA256
            function encriptarPasswordSHA256(password) {
                return new Promise((resolve, reject) => {
                    try {
                        if (typeof CryptoJS === 'undefined') {
                            throw new Error("CryptoJS no está cargado");
                        }
                        
                        const hashedPassword = CryptoJS.SHA256(password).toString();
                        console.log("Contraseña encriptada con SHA256 local:", hashedPassword);
                        resolve(hashedPassword);
                    } catch (error) {
                        console.error("Error encriptando con SHA256 local:", error);
                        reject(error);
                    }
                });
            }

            // Generar código CAPTCHA
            function generarCaptcha() {
                const caracteres = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789';
                let captcha = '';
                for (let i = 0; i < 6; i++) {
                    captcha += caracteres.charAt(Math.floor(Math.random() * caracteres.length));
                }

                document.getElementById('captchaText').textContent = captcha;
                captchaCode = captcha;
                document.getElementById('captchaInput').value = '';
                document.getElementById('captchaHidden').value = captcha;
                document.getElementById('captchaError').style.display = 'none';
            }

            function mostrarCaptcha() {
                generarCaptcha();
                document.getElementById('captchaModal').style.display = 'block';
                document.getElementById('captchaInput').focus();
            }

            function ocultarCaptcha() {
                document.getElementById('captchaModal').style.display = 'none';
            }

            function mostrarMensaje(tipo, mensaje, intentosRestantes = null, maxIntentos = 3) {
                const messagesDiv = document.getElementById('loginMessages');
                messagesDiv.innerHTML = '';

                let alertClass = 'alert-danger';
                let icon = '';
                let contenido = '';
                let indicadorIntentos = '';
                let progreso = '';

                if (tipo === 'credenciales' && intentosRestantes !== null) {
                    const intentoActual = maxIntentos - intentosRestantes + 1;
                    
                    let puntosHTML = '';
                    for (let i = 1; i <= maxIntentos; i++) {
                        let clases = 'intento-punto';
                        if (i <= intentoActual) {
                            clases += ' activo';
                        }
                        if (i < intentoActual) {
                            clases += ' completado';
                        }
                        puntosHTML += '<div class="' + clases + '"></div>';
                    }
                    
                    indicadorIntentos = '<div class="intento-indicator">' + puntosHTML + '</div>' +
                        '<div class="progress">' +
                        '<div class="progress-bar bg-warning" style="width: ' + ((intentoActual / maxIntentos) * 100) + '%">' +
                        intentoActual + ' de ' + maxIntentos +
                        '</div>' +
                        '</div>';
                }

                switch(tipo) {
                    case 'bloqueado':
                        alertClass = 'alert-danger';
                        contenido = '<strong>Cuenta temporalmente bloqueada</strong><br>Has excedido el número máximo de intentos. <span id="mensajeTiempo">' + mensaje + '</span>';
                        break;
                    case 'credenciales':
                        alertClass = 'alert-warning attempt-warning';
                        const intentoActual = maxIntentos - intentosRestantes + 1;
                        let advertencia = '';
                        if (intentoActual === 2) {
                            advertencia = '<div class="tiempo-restante mt-1">En el próximo intento fallido, la cuenta se bloqueará por 1 minuto.</div>';
                        }
                        contenido = '<strong>Intento ' + intentoActual + ' de ' + maxIntentos + ' fallido</strong><br><strong>Te quedan ' + intentosRestantes + ' intento(s) restantes.</strong>' + advertencia;
                        break;
                    case 'requiere_captcha':
                        alertClass = 'alert-info';
                        contenido = '<strong>' + mensaje + '</strong>';
                        break;
                    case 'captcha_incorrecto':
                        alertClass = 'alert-warning';
                        contenido = '<strong>' + mensaje + '</strong>';
                        break;
                    case 'sistema':
                        alertClass = 'alert-danger';
                        contenido = '<strong>' + mensaje + '</strong>';
                        break;
                    default:
                        alertClass = 'alert-danger';
                        contenido = '<strong>' + mensaje + '</strong>';
                }

                messagesDiv.innerHTML = 
                    indicadorIntentos +
                    '<div class="alert ' + alertClass + ' alert-dismissible fade show mt-3" role="alert">' +
                        contenido +
                        '<button type="button" class="btn-close" data-bs-dismiss="alert"></button>' +
                    '</div>' +
                    progreso;
            }

            // Función principal para enviar credenciales
            async function enviarCredenciales() {
                console.log("Enviando credenciales con SHA256 desde frontend...");

                const password = loginData.password;
                
                try {
                    // Encriptar contraseña con SHA256 antes de enviar
                    const hashedPassword = await encriptarPasswordSHA256(password);
                    
                    const params = new URLSearchParams();
                    params.append('username', loginData.username);
                    params.append('password', hashedPassword);

                    const response = await fetch('LoginServlet', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
                        },
                        body: params
                    });
                    
                    if (!response.ok) {
                        throw new Error('Error HTTP: ' + response.status);
                    }
                    
                    const data = await response.json();
                    console.log("Respuesta del servidor:", data);
                    
                    if (data.success) {
                        if (data.redirect) {
                            console.log("Login exitoso - Redirigiendo a:", data.redirect);
                            window.location.href = data.redirect;
                        } else {
                            window.location.reload();
                        }
                    } else {
                        manejarErrorLogin(data);
                    }
                } catch (error) {
                    console.error('Error de conexión:', error);
                    mostrarMensaje('sistema', 'Error de conexión. Intenta nuevamente.');
                } finally {
                    document.getElementById('loading').style.display = 'none';
                    document.getElementById('submitBtn').disabled = false;
                }
            }

            function manejarErrorLogin(data) {
                const tipoError = data.tipoError || 'desconocido';
                const intentos = data.intentosRestantes || 0;
                
                console.log("Tipo error: " + tipoError + ", Intentos: " + intentos);
                
                switch(tipoError) {
                    case 'bloqueado':
                        console.log("Usuario bloqueado");
                        mostrarMensaje('bloqueado', 'Tu cuenta ha sido bloqueada temporalmente. Intenta nuevamente en unos minutos.');
                        document.getElementById('usernameInput').disabled = true;
                        document.getElementById('passwordInput').disabled = true;
                        document.getElementById('submitBtn').disabled = true;
                        document.getElementById('submitBtn').textContent = 'Cuenta Bloqueada';
                        break;
                        
                    case 'credenciales':
                        console.log("Credenciales incorrectas. Intentos restantes: " + intentos);
                        mostrarMensaje('credenciales', '', intentos);
                        break;
                        
                    case 'requiere_captcha':
                        console.log("Credenciales correctas, requiere CAPTCHA");
                        mostrarMensaje('requiere_captcha', 'Credenciales correctas. Complete el CAPTCHA para finalizar.');
                        mostrarCaptcha();
                        break;
                        
                    case 'captcha_incorrecto':
                        console.log("CAPTCHA incorrecto");
                        mostrarMensaje('captcha_incorrecto', 'Código de verificación incorrecto. Intenta nuevamente.');
                        break;
                        
                    default:
                        console.log("Error general:", data.error);
                        mostrarMensaje('sistema', data.error || 'Error desconocido');
                        break;
                }
            }

            // Función para enviar credenciales con CAPTCHA
            async function enviarCredencialesConCaptcha() {
                console.log("Enviando credenciales con CAPTCHA...");

                const password = loginData.password;
                const captchaInputValue = document.getElementById('captchaInput').value.trim();

                try {
                    // Encriptar contraseña con SHA256
                    const hashedPassword = await encriptarPasswordSHA256(password);
                    
                    const params = new URLSearchParams();
                    params.append('username', loginData.username);
                    params.append('password', hashedPassword);
                    params.append('captchaInput', captchaInputValue);
                    params.append('captchaHidden', captchaCode);

                    const response = await fetch('LoginServlet', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
                        },
                        body: params
                    });
                    
                    if (!response.ok) {
                        throw new Error('Error HTTP: ' + response.status);
                    }
                    
                    const data = await response.json();
                    console.log("Respuesta del servidor con CAPTCHA:", data);
                    
                    if (data.success) {
                        if (data.redirect) {
                            console.log("Login exitoso - Redirigiendo a:", data.redirect);
                            window.location.href = data.redirect;
                        } else {
                            window.location.reload();
                        }
                    } else {
                        manejarErrorLogin(data);
                    }
                } catch (error) {
                    console.error('Error de conexión:', error);
                    mostrarMensaje('sistema', 'Error de conexión. Intenta nuevamente.');
                } finally {
                    document.getElementById('loading').style.display = 'none';
                    document.getElementById('submitBtn').disabled = false;
                }
            }

            function validarYEnviarCaptcha() {
                const input = document.getElementById('captchaInput').value.trim();

                if (input === '' || input !== captchaCode) {
                    document.getElementById('captchaError').style.display = 'block';
                    document.getElementById('captchaInput').focus();
                    generarCaptcha();
                    return;
                }

                console.log("CAPTCHA correcto - Enviando credenciales con CAPTCHA");
                ocultarCaptcha();
                document.getElementById('loading').style.display = 'block';
                document.getElementById('submitBtn').disabled = true;
                enviarCredencialesConCaptcha();
            }

            function cancelarLogin() {
                ocultarCaptcha();
                document.getElementById('loading').style.display = 'none';
                document.getElementById('submitBtn').disabled = false;
            }

            // Manejar envío del formulario
            document.getElementById('loginForm').addEventListener('submit', function (e) {
                e.preventDefault();

                <% if (estaBloqueado) { %>
                    return;
                <% } %>

                const username = document.getElementById('usernameInput').value.trim();
                const password = document.getElementById('passwordInput').value.trim();

                if (!username || !password) {
                    mostrarMensaje('sistema', 'Por favor, completa todos los campos.');
                    return;
                }

                loginData = {username, password};
                document.getElementById('submitBtn').disabled = true;
                document.getElementById('loading').style.display = 'block';

                // Validar credenciales sin CAPTCHA primero
                enviarCredenciales();
            });

            // Cerrar modal haciendo click fuera
            window.onclick = function (event) {
                const modal = document.getElementById('captchaModal');
                if (event.target === modal) {
                    cancelarLogin();
                }
            }

            // Generar CAPTCHA inicial
            window.onload = function () {
                generarCaptcha();
                <% if (!estaBloqueado) { %>
                    document.getElementById('submitBtn').disabled = false;
                <% } %>
                
                // Verificar que CryptoJS está disponible
                if (typeof CryptoJS === 'undefined') {
                    console.error("CRÍTICO: CryptoJS no está cargado");
                    mostrarMensaje('sistema', 'Error crítico: No se pudo cargar el sistema de seguridad. Recarga la página.');
                } else {
                    console.log("CryptoJS cargado correctamente");
                }
            };
        </script>

        <%-- Script para manejar el desbloqueo de cuenta --%>
        <% if (estaBloqueado) {%>
        <script>
            let tiempoRestante = <%= tiempoRestanteMs != null ? (int) Math.ceil(tiempoRestanteMs / 1000.0) : 60%>;
            const username = document.getElementById('usernameInput').value;

            console.log("Tiempo restante inicial:", tiempoRestante, "segundos");

            function actualizarTiempoDetalle() {
                const minutos = Math.floor(tiempoRestante / 60);
                const segundos = tiempoRestante % 60;
                
                const minutosElem = document.getElementById('minutos');
                const segundosElem = document.getElementById('segundos');
                
                if (minutosElem && segundosElem) {
                    minutosElem.textContent = minutos;
                    segundosElem.textContent = segundos.toString().padStart(2, '0');
                }
            }

            function verificarEstadoBloqueo() {
                if (!username) return;

                fetch('LoginServlet?accion=verificarBloqueo&username=' + encodeURIComponent(username))
                        .then(response => response.json())
                        .then(data => {
                            console.log("Estado de bloqueo:", data.bloqueado);
                            if (!data.bloqueado) {
                                console.log("Usuario desbloqueado, recargando página...");
                                location.reload();
                            }
                        })
                        .catch(error => {
                            console.error("Error al verificar bloqueo:", error);
                        });
            }

            if (tiempoRestante > 0) {
                function actualizarTiempo() {
                    if (tiempoRestante <= 0) {
                        console.log("Tiempo completado, verificando estado...");
                        document.getElementById('tiempoTexto').textContent = '0';
                        actualizarTiempoDetalle();
                        setInterval(verificarEstadoBloqueo, 5000);
                        return;
                    }

                    const tiempoTexto = document.getElementById('tiempoTexto');
                    if (tiempoTexto) {
                        tiempoTexto.textContent = tiempoRestante;
                    }

                    actualizarTiempoDetalle();
                    tiempoRestante--;
                    setTimeout(actualizarTiempo, 1000);
                }

                console.log("Iniciando contador de desbloqueo...");
                actualizarTiempo();
                actualizarTiempoDetalle();
            } else {
                setInterval(verificarEstadoBloqueo, 5000);
            }

            setInterval(verificarEstadoBloqueo, 10000);

        </script>
        <% }%>
    </body>
</html>