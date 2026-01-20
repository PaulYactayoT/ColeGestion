<%-- 
    Document   : uploadImage
    Created on : 11 jul. 2025, 1:48:48 a. m.
    Author     : Juan Pablo Amaya
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Padre" %>
<%
    Padre padre = (Padre) session.getAttribute("padre");
    if (padre == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    int alumnoId = padre.getAlumnoId();
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Subir Foto de <%= padre.getAlumnoNombre() %></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="assets/css/estilos.css">
    <style>
        body {
            background-image: url('assets/img/fondo_dashboard_padre.jpg');
            background-size: cover;
            background-position: center;
            background-attachment: fixed;
            min-height: 100vh;
        }
        .container {
            max-width: 600px;
        }
        .header-bar {
            background-color: #111;
            color: white;
            padding: 15px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .header-bar a {
            color: white;
            text-decoration: none;
            margin-left: 15px;
        }
        .header-bar a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <!-- Header -->
    <div class="header-bar">
        <div class="d-flex align-items-center">
            <img src="assets/img/logosa.png" alt="Logo" style="width: 30px; margin-right: 10px;">
            <strong>Colegio SA</strong>
        </div>
        <div>
            Padre de: <%= padre.getAlumnoNombre() %> | Grado: <%= padre.getGradoNombre() %>
            <a href="LogoutServlet" class="btn btn-sm btn-outline-light ms-3">Cerrar sesión</a>
        </div>
    </div>

    <!-- Formulario -->
    <div class="container mt-5">
        <h4 class="fw-bold text-center mb-4">Subir un Recuerdo de <%= padre.getAlumnoNombre() %></h4>
        <div class="card shadow-sm">
            <div class="card-body">
                <form action="UploadImageServlet" method="post" enctype="multipart/form-data">
                    <input type="hidden" name="alumno_id" value="<%= alumnoId %>"/>
                    <div class="mb-3">
                        <label for="imagen" class="form-label">Selecciona imagen</label>
                        <input type="file"
                               id="imagen"
                               name="imagen"
                               accept="image/*"
                               class="form-control"
                               required>
                    </div>
                    <div class="text-end">
                        <a href="albumPadre.jsp" class="btn btn-secondary">Cancelar</a>
                        <button type="submit" class="btn btn-primary">Subir Imagen</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Footer -->
    <footer class="bg-dark text-white py-2">
        <div class="container text-center text-md-start">
            <div class="row">
                <div class="col-md-4 mb-3 text-center">
                    <img src="assets/img/logosa.png" alt="Logo" class="img-fluid mb-1" width="80">
                    <p class="fs-6">"Líderes en educación de calidad al más alto nivel"</p>
                </div>
                <div class="col-md-4 mb-3">
                    <h5>Contacto:</h5>
                    <p class="fs-6 mb-1">Dirección: Av. El Sol 461, San Juan de Lurigancho 15434</p>
                    <p class="fs-6 mb-1">Teléfono: 987654321</p>
                    <p class="fs-6 mb-0">Correo: colegiosanantonio@gmail.com</p>
                </div>
                <div class="col-md-4 mb-3">
                    <h5>Síguenos:</h5>
                    <a href="https://www.facebook.com/" class="text-white d-block fs-6">Facebook</a>
                    <a href="https://www.instagram.com/" class="text-white d-block fs-6">Instagram</a>
                    <a href="https://twitter.com/" class="text-white d-block fs-6">Twitter</a>
                    <a href="https://www.youtube.com/" class="text-white d-block fs-6">YouTube</a>
                </div>
            </div>
            <div class="text-center mt-0">
                <p class="fs-6 mb-0">&copy; 2025 Colegio SA - Todos los derechos reservados</p>
            </div>
        </div>
    </footer>
</body>
</html>

