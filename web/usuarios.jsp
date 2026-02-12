<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, modelo.Usuario" %>
<%@ page import="javax.servlet.http.HttpSession" %>

<%
    // Configuración para evitar caché (Seguridad)
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    // Validación de sesión
    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    // Recuperar lista del Servlet
    List<Usuario> lista = (List<Usuario>) request.getAttribute("lista");
%>

<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Usuarios - San Antonio</title>
    
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    
    <link href="https://fonts.googleapis.com/css2?family=Lexend:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    
    <script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        "primary": "#135bec",
                        "background-light": "#f6f6f8",
                        "background-dark": "#101622",
                    },
                    fontFamily: {
                        "display": ["Lexend"]
                    },
                },
            },
        }
    </script>
    
    <style>
        body { font-family: 'Lexend', sans-serif; }
        .material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24; }
        
        /* Estilos de Tabla */
        .custom-table {
            border-collapse: separate; border-spacing: 0; width: 100%;
            background: white; border-radius: 0.5rem; overflow: hidden;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }
        .dark .custom-table { background: #1a2233; }
        .custom-table thead { background: linear-gradient(135deg, #135bec 0%, #0d47a1 100%); }
        .custom-table th { padding: 1rem; text-align: left; font-weight: 600; color: white; font-size: 0.95rem; text-transform: uppercase; }
        .custom-table tbody tr { border-bottom: 1px solid #e5e7eb; }
        .dark .custom-table tbody tr { border-bottom: 1px solid #374151; }
        .custom-table tbody tr:hover { background-color: #f9fafb; }
        .dark .custom-table tbody tr:hover { background-color: #2d3748; }
        .custom-table td { padding: 1rem; color: #374151; font-size: 0.95rem; }
        .dark .custom-table td { color: #d1d5db; }
        
        /* Badges y Botones */
        .status-badge { padding: 0.35rem 0.85rem; border-radius: 9999px; font-size: 0.85rem; font-weight: 600; }
        .btn-icon { padding: 0.5rem; border-radius: 0.375rem; display: inline-flex; align-items: center; justify-content: center; transition: all 0.2s; }
        .btn-icon:hover { transform: translateY(-1px); }
        
        /* Accesibilidad */
        .accessibility-panel { transform: translateX(100%); transition: transform 0.3s ease; }
        .accessibility-panel.open { transform: translateX(0); }
        .large-text * { font-size: 1.1em !important; }
        .high-contrast-invert { filter: invert(1) hue-rotate(180deg); }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark text-[#111318] dark:text-white min-h-screen">

    <button onclick="document.querySelector('.accessibility-panel').classList.toggle('open')" 
            class="fixed top-20 right-0 z-40 bg-primary text-white p-3 rounded-l-lg shadow-lg hover:bg-blue-700 transition-colors">
        <span class="material-symbols-outlined">accessibility_new</span>
    </button>

    <div class="fixed top-20 right-0 z-50 accessibility-panel bg-white dark:bg-gray-800 shadow-xl rounded-l-lg p-4 w-80">
        <div class="flex justify-between items-center mb-4">
            <h3 class="font-bold text-lg">Accesibilidad</h3>
            <button onclick="document.querySelector('.accessibility-panel').classList.remove('open')" class="text-gray-500">
                <span class="material-symbols-outlined">close</span>
            </button>
        </div>
        <div class="space-y-3">
            <button onclick="document.body.classList.toggle('large-text')" class="w-full py-2 bg-gray-100 rounded hover:bg-gray-200">Aumentar Texto</button>
            <button onclick="document.body.classList.toggle('high-contrast-invert')" class="w-full py-2 bg-gray-100 rounded hover:bg-gray-200">Alto Contraste</button>
        </div>
    </div>

    <div class="flex h-screen overflow-hidden">
        <aside class="w-64 flex-shrink-0 bg-white dark:bg-[#1a2233] border-r border-[#dbdfe6] dark:border-gray-700 flex flex-col justify-between">
            <div class="flex flex-col gap-8 p-6">
                <div class="flex items-center gap-3">
                    <div class="bg-primary size-10 rounded-lg flex items-center justify-center text-white">
                        <span class="material-symbols-outlined">school</span>
                    </div>
                    <div class="flex flex-col">
                        <h1 class="text-[#111318] dark:text-white text-lg font-bold leading-tight">San Antonio</h1>
                        <p class="text-[#616f89] dark:text-gray-400 text-xs font-normal">Gestión Académica</p>
                    </div>
                </div>
                
                <nav class="flex flex-col gap-2">
                    <a href="dashboard.jsp" class="flex items-center gap-3 px-3 py-2 rounded-lg text-[#616f89] hover:bg-gray-100 transition-colors">
                        <span class="material-symbols-outlined">dashboard</span>
                        <span class="text-sm">Dashboard</span>
                    </a>
                    <a href="AlumnoServlet" class="flex items-center gap-3 px-3 py-2 rounded-lg text-[#616f89] hover:bg-gray-100 transition-colors">
                        <i class="fas fa-user-graduate"></i>
                        <span class="text-sm">Estudiantes</span>
                    </a>
                    <a href="ProfesorServlet" class="flex items-center gap-3 px-3 py-2 rounded-lg text-[#616f89] hover:bg-gray-100 transition-colors">
                        <i class="fas fa-chalkboard-teacher"></i>
                        <span class="text-sm">Profesores</span>
                    </a>
                    <a href="CursoServlet" class="flex items-center gap-3 px-3 py-2 rounded-lg text-[#616f89] hover:bg-gray-100 transition-colors">
                        <i class="fas fa-book"></i>
                        <span class="text-sm">Cursos</span>
                    </a>
                    <a href="GradoServlet" class="flex items-center gap-3 px-3 py-2 rounded-lg text-[#616f89] hover:bg-gray-100 transition-colors">
                        <i class="fas fa-layer-group"></i>
                        <span class="text-sm">Grados</span>
                    </a>
                    <a href="UsuarioServlet" class="flex items-center gap-3 px-3 py-2 rounded-lg bg-primary/10 text-primary font-medium" aria-current="page">
                        <i class="fas fa-users-cog"></i>
                        <span class="text-sm">Usuarios</span>
                    </a>
                </nav>
            </div>
            
            <div class="p-6 border-t border-[#dbdfe6] dark:border-gray-700">
                <a href="LogoutServlet" class="flex w-full items-center justify-center gap-2 rounded-lg h-10 px-4 bg-primary text-white text-sm font-bold tracking-wide hover:bg-blue-700 transition-colors">
                    <span class="material-symbols-outlined text-[18px]">logout</span>
                    <span>Cerrar Sesión</span>
                </a>
            </div>
        </aside>
        
        <main class="flex-1 flex flex-col overflow-y-auto">
            <header class="flex items-center justify-between bg-white dark:bg-[#1a2233] border-b border-[#f0f2f4] dark:border-gray-700 px-8 py-3 sticky top-0 z-10">
                <h1 class="text-xl font-bold text-[#111318] dark:text-white">Listado de Usuarios</h1>
                
                <div class="flex items-center gap-4">
                    <button class="p-2 text-[#616f89] hover:bg-gray-100 rounded-lg relative">
                        <span class="material-symbols-outlined">notifications</span>
                        <span class="absolute top-2 right-2 size-2 bg-red-500 rounded-full border-2 border-white"></span>
                    </button>
                    <div class="h-8 w-[1px] bg-gray-200 mx-2"></div>
                    <div class="flex items-center gap-3">
                        <p class="text-sm font-medium hidden md:block">
                            <%= session.getAttribute("usuario") != null ? session.getAttribute("usuario") : "Admin" %>
                        </p>
                        <div class="size-10 rounded-full bg-cover bg-center border-2 border-primary/20" 
                             style="background-image: url('https://ui-avatars.com/api/?name=Admin&background=random');">
                        </div>
                    </div>
                </div>
            </header>
            
            <div class="p-8">
                <% if (session.getAttribute("mensaje") != null) { %>
                    <div class="bg-green-100 border border-green-200 text-green-800 rounded-lg p-4 mb-6 flex items-center gap-3">
                        <i class="fas fa-check-circle"></i>
                        <span><%= session.getAttribute("mensaje") %></span>
                    </div>
                    <% session.removeAttribute("mensaje"); %>
                <% } %>
                
                <% if (session.getAttribute("error") != null) { %>
                    <div class="bg-red-100 border border-red-200 text-red-800 rounded-lg p-4 mb-6 flex items-center gap-3">
                        <i class="fas fa-exclamation-circle"></i>
                        <span><%= session.getAttribute("error") %></span>
                    </div>
                    <% session.removeAttribute("error"); %>
                <% } %>
                
                <div class="flex justify-between items-center mb-6">
                    <div>
                        <h2 class="text-2xl font-bold text-[#111318] dark:text-white">Gestión de Usuarios</h2>
                        <p class="text-[#616f89] dark:text-gray-400 mt-1">Administra el acceso al sistema</p>
                    </div>
                    <a href="UsuarioServlet?accion=nuevo" 
                       class="flex items-center gap-2 px-4 py-2.5 bg-gradient-to-r from-primary to-blue-600 hover:from-blue-600 hover:to-blue-700 text-white font-medium rounded-lg transition-all shadow-md hover:shadow-lg">
                        <span class="material-symbols-outlined">person_add</span>
                        <span>Registrar Usuario</span>
                    </a>
                </div>
                
                <div class="bg-white dark:bg-[#1a2233] rounded-xl border border-[#dbdfe6] dark:border-gray-700 shadow-sm overflow-hidden">
                    <div class="overflow-x-auto">
                        <table class="custom-table">
                            <thead>
                                <tr>
                                    <th>Usuario</th>
                                    <th>Rol</th>
                                    <th>Estado</th>
                                    <th>Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    if (lista != null && !lista.isEmpty()) {
                                        for (Usuario u : lista) {
                                %>
                                <tr>
                                    <td class="font-medium">
                                        <div class="flex items-center gap-3">
                                            <div class="size-8 rounded-full bg-indigo-100 dark:bg-indigo-900 flex items-center justify-center text-indigo-600 dark:text-indigo-300">
                                                <i class="fas fa-user"></i>
                                            </div>
                                            <span><%= u.getUsuario() %></span>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="status-badge bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200">
                                            <%= u.getRol() %>
                                        </span>
                                    </td>
                                    <td>
                                        <% 
                                            // Lógica para determinar el color del estado
                                            String estado = u.getEstado(); 
                                            String badgeClass = "bg-gray-100 text-gray-800";
                                            // Aceptamos "Activo" o "true" o "1" para flexibilidad
                                            if (estado != null && ("Activo".equalsIgnoreCase(estado) || "true".equalsIgnoreCase(estado) || "1".equals(estado))) {
                                                badgeClass = "bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200";
                                                estado = "Activo"; // Asegurar visualización
                                            } else {
                                                badgeClass = "bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200";
                                                if(estado == null) estado = "Inactivo";
                                            }
                                        %>
                                        <span class="status-badge <%= badgeClass %>">
                                            <%= estado %>
                                        </span>
                                    </td>
                                    <td>
                                        <div class="flex gap-2">
                                            <a href="UsuarioServlet?accion=editar&id=<%= u.getId() %>" 
                                               class="btn-icon bg-blue-100 text-blue-600 hover:bg-blue-200 dark:bg-blue-900 dark:text-blue-300"
                                               title="Editar">
                                                <span class="material-symbols-outlined text-sm">edit</span>
                                            </a>
                                            <a href="UsuarioServlet?accion=eliminar&id=<%= u.getId() %>" 
                                               class="btn-icon bg-red-100 text-red-600 hover:bg-red-200 dark:bg-red-900 dark:text-red-300"
                                               title="Eliminar"
                                               onclick="return confirm('¿Estás seguro de eliminar este usuario?')">
                                                <span class="material-symbols-outlined text-sm">delete</span>
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                                <%
                                        }
                                    } else {
                                %>
                                <tr>
                                    <td colspan="4" class="text-center py-12">
                                        <div class="flex flex-col items-center justify-center text-gray-400">
                                            <span class="material-symbols-outlined text-5xl mb-3">person_off</span>
                                            <p class="text-lg font-medium">No hay usuarios registrados</p>
                                        </div>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
                
                <div class="mt-8 text-center text-sm text-gray-500 dark:text-gray-400">
                    <p>&copy; 2025 Colegio San Antonio - Todos los derechos reservados</p>
                </div>
            </div>
        </main>
    </div>
</body>
</html>