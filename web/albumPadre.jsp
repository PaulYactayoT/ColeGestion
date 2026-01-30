<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Padre, modelo.ImageDAO, modelo.Imagen, java.util.List" %>
<%
    Padre padre = (Padre) session.getAttribute("padre");
    if (padre == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    int alumnoId = padre.getAlumnoId();
    List<Imagen> imagenes = new ImageDAO().listarPorAlumno(alumnoId);
%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <title>Álbum de Fotos</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
        <link rel="stylesheet" href="assets/css/estilos.css">
        <style>
            body {
                background-image: url('assets/img/fondo_dashboard_docente.jpg');
                background-size: 100% 100%;
                background-position: center;
                background-attachment: fixed;
                height: 100vh;
            }
            .section-header {
                background-color: #111;
                color: white;
                padding: 15px 30px;
                display: flex;
                justify-content: space-between;
                align-items: center;
            }
            .gallery {
                display: grid;
                grid-template-columns: repeat(auto-fill,minmax(150px,1fr));
                gap:1rem;
            }
            .gallery img {
                width:100%;
                border-radius:8px;
                display:block;
            }
            .gallery .position-relative {
                overflow: hidden;
                border-radius: 8px;
            }

            .gallery .position-relative .delete-btn {
                position: absolute;
                top: .5rem;
                right: .5rem;
                display: none;
                background: rgba(0,0,0,0.5);
                border-radius: 4px;
                width: 1.6rem;
                height: 1.6rem;
                align-items: center;
                justify-content: center;
                color: #fff;
                transition: background .2s, transform .2s;
                cursor: pointer;
            }

            .gallery .position-relative:hover .delete-btn {
                display: flex;
                transform: scale(1.1);
                font-size: 0.9rem;
            }

            .gallery .position-relative .delete-btn:hover {
                background: rgba(0,0,0,0.7);
            }
        </style>
    </head>
    <body class="page-wrapper">

        <!-- HEADER -->
        <div class="section-header">
            <div>
                <img src="assets/img/logosa.png" style="width:30px;…"/>
                <strong>Colegio SA</strong>
            </div>
            <div>
                Padre de: <%= padre.getAlumnoNombre()%> | Grado: <%= padre.getGradoNombre()%>
                <a href="LogoutServlet" class="btn btn-sm btn-outline-light ms-3">Cerrar sesión</a>
            </div>
        </div>

        <div class="container mt-5">
            <h4 class="fw-bold text-center mb-4">Álbum de Fotos de <%= padre.getAlumnoNombre()%></h4>

            <!-- Botón Subir -->
            <div class="text-end mb-3">
                <a href="uploadImage.jsp" class="btn btn-info">
                    <i class="bi bi-upload me-1"></i>Subir Imagen
                </a>
            </div>

            <!-- Galería -->
            <div class="card shadow-sm">
                <div class="card-body">
                    <div class="gallery">
                        <% for (Imagen img : imagenes) {%>
                        <div class="position-relative">
                            <img src="<%= img.getRuta()%>" alt="Foto" class="shadow-sm"/>
                            <form action="DeleteImageServlet" method="post"
                                  onsubmit="return confirm('¿Eliminar esta imagen?');">
                                <input type="hidden" name="id" value="<%= img.getId()%>"/>
                                <button type="submit" class="delete-btn">
                                    <i class="bi bi-trash-fill"></i>
                                </button>
                            </form>
                        </div>
                        <% } %>

                        <% if (imagenes.isEmpty()) { %>
                        <p class="text-center w-100">No hay fotos aún.</p>
                        <% }%>
                    </div>
                </div>
            </div>

            <!-- Volver al dashboard -->
            <div class="mt-3">
                <a href="padreDashboard.jsp" class="btn btn-outline-dark">&larr; Regresar</a>
            </div>
        </div>

        <!-- FOOTER -->
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

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
