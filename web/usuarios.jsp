<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, modelo.Usuario" %>
<%@ page import="javax.servlet.http.HttpSession" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    List<Usuario> lista = (List<Usuario>) request.getAttribute("lista");
    request.setAttribute("pageTitle", "Listado de Usuarios");
%>
<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Usuarios - San Antonio</title>
    <%@ include file="includes/head.jsp" %>
    <style>
        .custom-table { border-collapse: separate; border-spacing: 0; width: 100%; background: white; border-radius: 0.5rem; overflow: hidden; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
        .dark .custom-table { background: #1a2233; }
        .custom-table thead { background: linear-gradient(135deg, #135bec 0%, #0d47a1 100%); }
        .custom-table th { padding: 1rem; text-align: left; font-weight: 600; color: white; font-size: 0.875rem; text-transform: uppercase; letter-spacing: 0.05em; }
        .custom-table tbody tr { border-bottom: 1px solid #e5e7eb; transition: background-color 0.2s; }
        .dark .custom-table tbody tr { border-bottom: 1px solid #374151; }
        .custom-table tbody tr:hover { background-color: #f9fafb; }
        .dark .custom-table tbody tr:hover { background-color: #2d3748; }
        .custom-table td { padding: 1rem; color: #374151; font-size: 0.875rem; }
        .dark .custom-table td { color: #d1d5db; }
        .status-badge { padding: 0.25rem 0.75rem; border-radius: 9999px; font-size: 0.75rem; font-weight: 600; }
        .btn-icon { padding: 0.5rem; border-radius: 0.375rem; display: inline-flex; align-items: center; justify-content: center; transition: all 0.2s; }
        .btn-icon:hover { transform: translateY(-1px); }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark text-[#111318] dark:text-white min-h-screen">
    <div class="flex h-screen overflow-hidden">
        <%
            String rolSbU = (String) session.getAttribute("rol");
            String sbFileU = "administrativo".equals(rolSbU)
                           ? "includes/sidebarAdministrativo.jsp"
                           : "includes/sidebar.jsp";
        %>
        <jsp:include page="<%= sbFileU %>" />
        <main class="flex-1 flex flex-col overflow-y-auto">
            <%@ include file="includes/header.jsp" %>
            <div class="p-8">
                <% if (session.getAttribute("mensaje") != null) { %>
                    <div class="alert-modern alert-success mb-6" role="alert">
                        <i class="fas fa-check-circle text-xl"></i>
                        <div><%= session.getAttribute("mensaje") %></div>
                    </div>
                    <% session.removeAttribute("mensaje"); %>
                <% } %>
                <% if (session.getAttribute("error") != null) { %>
                    <div class="alert-modern alert-danger mb-6" role="alert">
                        <i class="fas fa-exclamation-circle text-xl"></i>
                        <div><%= session.getAttribute("error") %></div>
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
                                        for (Usuario usr : lista) {
                                            String uNmb = usr.getNombreCompleto();
                                            String uTip = usr.getTipoPersona();
                                            if (uNmb == null || uNmb.trim().isEmpty()) uNmb = "(Sin nombre)";
                                            String uEst = usr.getEstado();
                                            String uBdg;
                                            if (uEst != null && "Activo".equalsIgnoreCase(uEst)) {
                                                uBdg = "bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200";
                                            } else {
                                                uBdg = "bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200";
                                                if (uEst == null) uEst = "Inactivo";
                                            }
                                %>
                                <tr>
                                    <td class="font-medium">
                                        <div class="flex items-center gap-3">
                                            <div class="size-8 rounded-full bg-indigo-100 dark:bg-indigo-900 flex items-center justify-center text-indigo-600 dark:text-indigo-300">
                                                <i class="fas fa-user"></i>
                                            </div>
                                            <div class="flex flex-col">
                                                <span class="font-semibold"><%= usr.getUsuario() %></span>
                                                <% if (uNmb != null && !uNmb.equals("(Sin nombre)")) { %>
                                                <span class="text-xs text-gray-400"><%= uNmb %></span>
                                                <% } %>
                                            </div>
                                        </div>
                                    </td>
                                    </td>
                                    <td>
                                        <span class="status-badge bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200">
                                            <%= usr.getRol() %>
                                        </span>
                                    </td>
                                    <td>
                                        <span class="status-badge <%= uBdg %>"><%= uEst %></span>
                                    </td>
                                    <td>
                                        <div class="flex gap-2">
                                            <a href="UsuarioServlet?accion=editar&id=<%= usr.getId() %>"
                                               class="btn-icon bg-blue-100 text-blue-600 hover:bg-blue-200" title="Editar">
                                                <span class="material-symbols-outlined text-sm">edit</span>
                                            </a>
                                            <% if (usr.isActivo()) { %>
                                            <a href="UsuarioServlet?accion=bloquear&id=<%= usr.getId() %>"
                                               class="btn-icon bg-yellow-100 text-yellow-600 hover:bg-yellow-200" title="Bloquear"
                                               onclick="return confirm('¿Bloquear este usuario?')">
                                                <span class="material-symbols-outlined text-sm">lock</span>
                                            </a>
                                            <% } else { %>
                                            <a href="UsuarioServlet?accion=desbloquear&id=<%= usr.getId() %>"
                                               class="btn-icon bg-green-100 text-green-600 hover:bg-green-200" title="Desbloquear">
                                                <span class="material-symbols-outlined text-sm">lock_open</span>
                                            </a>
                                            <% } %>
                                            <a href="UsuarioServlet?accion=eliminar&id=<%= usr.getId() %>"
                                               class="btn-icon bg-red-100 text-red-600 hover:bg-red-200" title="Eliminar"
                                               onclick="return confirm('¿Eliminar este usuario?')">
                                                <span class="material-symbols-outlined text-sm">delete</span>
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                                <%  }
                                    } else { %>
                                <tr>
                                    <td colspan="5" class="text-center py-12">
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
