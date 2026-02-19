<%-- 
    Document   : notasDocente
    Created on : 31 may. 2025, 5:34:02 a. m.
    Author     : Juan Pablo Amaya
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Profesor, modelo.Curso, modelo.Nota, java.util.List" %>

<%
    Profesor docente = (Profesor) session.getAttribute("docente");
    Curso curso = (Curso) request.getAttribute("curso");
    List<Nota> lista = (List<Nota>) request.getAttribute("lista");

    if (docente == null || curso == null) {
        response.sendRedirect("docenteDashboard.jsp");
        return;
    }
    
    String mensaje = (String) session.getAttribute("mensaje");
    String error = (String) session.getAttribute("error");
    
    if (mensaje != null) session.removeAttribute("mensaje");
    if (error != null) session.removeAttribute("error");
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <%@ include file="includes/head.jsp" %>
    <title>Notas - <%= curso.getNombre() %></title>
    <style>
        /* Estilos adicionales para la tabla */
        .table-container {
            background: white;
            border-radius: 0.75rem;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            border: 1px solid #e5e7eb;
            overflow: hidden;
        }
        
        .dark .table-container {
            background: #1a2233;
            border-color: #374151;
        }
        
        .custom-table {
            width: 100%;
            border-collapse: collapse;
        }
        
        .custom-table th {
            background-color: #0b4eb8;
            color: white;
            font-weight: 600;
            padding: 15px 20px;
            text-align: left;
            font-size: 13px;
            text-transform: uppercase;
        }
        
        .dark .custom-table th {
            background-color: #1e3a8a;
        }
        
        .custom-table td {
            padding: 15px 20px;
            border-bottom: 1px solid #e5e7eb;
            color: #444;
            vertical-align: middle;
            font-size: 14px;
        }
        
        .dark .custom-table td {
            border-bottom-color: #374151;
            color: #e5e7eb;
        }
        
        .custom-table tbody tr:hover {
            background-color: #f9faff;
        }
        
        .dark .custom-table tbody tr:hover {
            background-color: #283044;
        }
        
        /* Estilos para badges de notas */
        .nota-badge {
            display: inline-block;
            padding: 0.5rem 1rem;
            border-radius: 2rem;
            font-weight: 600;
            font-size: 0.875rem;
            min-width: 60px;
            text-align: center;
        }
        
        .nota-alta {
            background-color: #10b981;
            color: white;
        }
        
        .nota-media {
            background-color: #f59e0b;
            color: white;
        }
        
        .nota-baja {
            background-color: #ef4444;
            color: white;
        }
        
        .btn-edit {
            background-color: #e0eaff;
            color: #0d6efd;
            padding: 8px 16px;
            border-radius: 6px;
            text-decoration: none;
            font-size: 13px;
            font-weight: 500;
            transition: all 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        
        .btn-edit:hover {
            background-color: #0d6efd;
            color: white;
        }
        
        .btn-delete {
            background-color: #ffe5e7;
            color: #d63345;
            padding: 8px 16px;
            border-radius: 6px;
            text-decoration: none;
            font-size: 13px;
            font-weight: 500;
            transition: all 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        
        .btn-delete:hover {
            background-color: #d63345;
            color: white;
        }
        
        .btn-add {
            background-color: #0d6efd;
            color: white;
            padding: 10px 20px;
            border-radius: 8px;
            font-weight: 500;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            box-shadow: 0 4px 10px rgba(13, 110, 253, 0.2);
            transition: all 0.2s;
        }
        
        .btn-add:hover {
            background-color: #0b4eb8;
            transform: translateY(-2px);
        }
        
        .btn-back {
            background-color: white;
            color: #6b7280;
            border: 1px solid #e5e7eb;
            padding: 8px 16px;
            border-radius: 8px;
            font-weight: 500;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.2s;
        }
        
        .btn-back:hover {
            background-color: #f3f4f6;
            color: #374151;
        }
        
        .dark .btn-back {
            background-color: #283044;
            color: #e5e7eb;
            border-color: #4b5563;
        }
        
        .dark .btn-back:hover {
            background-color: #374151;
        }
        
        .footer-custom {
            background-color: #111827;
            color: white;
            padding: 2rem 0;
            margin-top: 2rem;
        }
        
        .dark .footer-custom {
            background-color: #0f172a;
        }
        
        .stats-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 1rem 1.5rem;
            border-radius: 1rem;
            color: white;
        }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark text-[#111318] dark:text-white min-h-screen flex flex-col">

    <div class="flex flex-1 h-screen overflow-hidden">
        <!-- Sidebar -->
        <%@ include file="includes/sidebarDocente.jsp" %>
        
        <main class="flex-1 flex flex-col overflow-y-auto">
            <!-- Header -->
            <% request.setAttribute("pageTitle", "Notas - " + curso.getNombre()); %>
            <jsp:include page="includes/header.jsp" />
            
            <div class="p-8">
                <!-- Mensajes -->
                <% if (mensaje != null) { %>
                <div class="alert alert-success mb-6" role="alert">
                    <div class="flex items-center gap-2">
                        <i class="fas fa-check-circle"></i>
                        <span><%= mensaje %></span>
                    </div>
                </div>
                <% } %>
                
                <% if (error != null) { %>
                <div class="alert alert-danger mb-6" role="alert">
                    <div class="flex items-center gap-2">
                        <i class="fas fa-exclamation-circle"></i>
                        <span><%= error %></span>
                    </div>
                </div>
                <% } %>
                
                <!-- Encabezado del curso -->
                <div class="bg-gradient-to-r from-primary to-blue-600 rounded-xl p-6 mb-8 text-white shadow-lg">
                    <div class="relative z-10 flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
                        <div>
                            <h2 class="text-2xl font-bold">Gestión de Notas</h2>
                            <p class="text-blue-100 mt-1">
                                Curso: <strong><%= curso.getNombre() %></strong> - <%= curso.getGradoNombre() %>
                            </p>
                        </div>
                        <div class="bg-white/10 backdrop-blur-md border border-white/20 rounded-xl px-6 py-3">
                            <span class="text-sm uppercase tracking-wide opacity-80">Total Notas:</span>
                            <span class="text-2xl font-bold ml-2"><%= lista != null ? lista.size() : 0 %></span>
                        </div>
                    </div>
                </div>
                
                <!-- Acciones -->
                <div class="flex justify-between items-center mb-6">
                    <a href="LoginServlet?accion=dashboard" class="btn-back">
                        <i class="fas fa-arrow-left"></i> Regresar al Inicio
                    </a>
                    <a href="NotaServlet?accion=nuevo&curso_id=<%= curso.getId() %>" class="btn-add">
                        <i class="fas fa-plus"></i> Registrar Nota
                    </a>
                </div>
                
                <!-- Tabla de notas -->
                <div class="table-container">
                    <div class="overflow-x-auto">
                        <table class="custom-table">
                            <thead>
                                <tr>
                                    <th>Alumno</th>
                                    <th>Tarea</th>
                                    <th class="text-center">Nota</th>
                                    <th class="text-center">Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    if (lista != null && !lista.isEmpty()) {
                                        for (Nota n : lista) {
                                            double notaValor = n.getNota();
                                            String notaClass = "nota-badge";
                                            if (notaValor >= 4.0) {
                                                notaClass += " nota-alta";
                                            } else if (notaValor >= 2.5) {
                                                notaClass += " nota-media";
                                            } else {
                                                notaClass += " nota-baja";
                                            }
                                %>
                                <tr>
                                    <td class="font-medium"><%= n.getAlumnoNombre() %></td>
                                    <td><%= n.getTareaNombre() %></td>
                                    <td class="text-center">
                                        <span class="<%= notaClass %>">
                                            <%= String.format("%.1f", notaValor) %>
                                        </span>
                                    </td>
                                    <td class="text-center">
                                        <div class="flex items-center justify-center gap-2">
                                            <a href="NotaServlet?accion=editar&id=<%= n.getId() %>&curso_id=<%= curso.getId() %>" 
                                               class="btn-edit" title="Editar">
                                                <i class="fas fa-pencil-alt"></i> Editar
                                            </a>
                                            <a href="NotaServlet?accion=eliminar&id=<%= n.getId() %>&curso_id=<%= curso.getId() %>" 
                                               class="btn-delete" 
                                               onclick="return confirm('¿Estás seguro de eliminar esta nota?')"
                                               title="Eliminar">
                                                <i class="fas fa-trash-alt"></i> Eliminar
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
                                        <div class="text-gray-500 dark:text-gray-400">
                                            <i class="fas fa-clipboard-list fa-3x mb-3"></i>
                                            <p class="text-lg">No hay notas registradas para este curso.</p>
                                            <p class="text-sm mt-2">Haz clic en "Registrar Nota" para agregar una nueva.</p>
                                        </div>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
                
                <!-- Info box -->
                <div class="mt-6 p-4 bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg">
                    <div class="flex items-start gap-3">
                        <span class="material-symbols-outlined text-blue-600 dark:text-blue-400 mt-0.5">
                            info
                        </span>
                        <div>
                            <h4 class="font-medium text-blue-800 dark:text-blue-300">Información importante:</h4>
                            <ul class="mt-2 text-sm text-blue-700 dark:text-blue-400 space-y-1">
                                <li>• Las notas son visibles para los padres de familia</li>
                                <li>• Puedes editar o eliminar notas existentes</li>
                                <li>• Las notas se muestran con código de colores según su rango</li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>

    <!-- Bootstrap JS (opcional, solo si necesitas funcionalidad de Bootstrap) -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>