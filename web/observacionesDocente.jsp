<%-- 
    Document   : observacionesDocente
    Created on : 31 may. 2025, 6:34:03 a. m.
    Author     : Juan Pablo Amaya
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Profesor, modelo.Curso, modelo.Observacion, java.util.List" %>

<%
    Profesor docente = (Profesor) session.getAttribute("docente");
    Curso curso = (Curso) request.getAttribute("curso");
    List<Observacion> lista = (List<Observacion>) request.getAttribute("lista");

    if (docente == null || curso == null) {
        response.sendRedirect("docenteDashboard.jsp");
        return;
    }
    
    String mensaje = (String) session.getAttribute("mensaje");
    String error = (String) session.getAttribute("error");
    
    // Leer mensaje de exito desde parametro URL
    String successParam = request.getParameter("success");
    if ("true".equals(successParam) && mensaje == null) {
        mensaje = "Observacion registrada con exito.";
    }
    
    if (mensaje != null) session.removeAttribute("mensaje");
    if (error != null) session.removeAttribute("error");
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <%@ include file="includes/head.jsp" %>
    <title>Observaciones - <%= curso.getNombre() %></title>
    <style>
        /* Estilos para la tabla */
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
            background-color: #f8fafc;
            color: #4b5563;
            font-weight: 600;
            padding: 1rem 1.5rem;
            text-align: left;
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            border-bottom: 1px solid #e5e7eb;
        }
        
        .dark .custom-table th {
            background-color: #283044;
            color: #9ca3af;
            border-bottom-color: #374151;
        }
        
        .custom-table td {
            padding: 1rem 1.5rem;
            border-bottom: 1px solid #e5e7eb;
            color: #1f2937;
            vertical-align: middle;
            font-size: 0.875rem;
        }
        
        .dark .custom-table td {
            border-bottom-color: #374151;
            color: #f3f4f6;
        }
        
        .custom-table tbody tr:hover {
            background-color: #f9faff;
        }
        
        .dark .custom-table tbody tr:hover {
            background-color: #283044;
        }
        
        /* Badges para tipo de observación */
        .badge-positiva {
            background-color: #d1fae5;
            color: #065f46;
            padding: 0.25rem 0.75rem;
            border-radius: 9999px;
            font-size: 0.75rem;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 0.25rem;
        }
        
        .dark .badge-positiva {
            background-color: #064e3b;
            color: #a7f3d0;
        }
        
        .badge-negativa {
            background-color: #fee2e2;
            color: #991b1b;
            padding: 0.25rem 0.75rem;
            border-radius: 9999px;
            font-size: 0.75rem;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 0.25rem;
        }
        
        .dark .badge-negativa {
            background-color: #7f1d1d;
            color: #fecaca;
        }
        
        .badge-neutral {
            background-color: #dbeafe;
            color: #1e40af;
            padding: 0.25rem 0.75rem;
            border-radius: 9999px;
            font-size: 0.75rem;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 0.25rem;
        }
        
        .dark .badge-neutral {
            background-color: #1e3a8a;
            color: #bfdbfe;
        }
        
        /* Botones de acción */
        .btn-edit {
            background-color: #e0eaff;
            color: #0d6efd;
            padding: 0.5rem 1rem;
            border-radius: 0.5rem;
            text-decoration: none;
            font-size: 0.75rem;
            font-weight: 500;
            transition: all 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 0.375rem;
            border: none;
            cursor: pointer;
        }
        
        .btn-edit:hover {
            background-color: #0d6efd;
            color: white;
        }
        
        .btn-delete {
            background-color: #ffe5e7;
            color: #dc2626;
            padding: 0.5rem 1rem;
            border-radius: 0.5rem;
            text-decoration: none;
            font-size: 0.75rem;
            font-weight: 500;
            transition: all 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 0.375rem;
            border: none;
            cursor: pointer;
        }
        
        .btn-delete:hover {
            background-color: #dc2626;
            color: white;
        }
        
        .btn-add {
            background-color: #0d6efd;
            color: white;
            padding: 0.625rem 1.25rem;
            border-radius: 0.5rem;
            font-weight: 500;
            font-size: 0.875rem;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            box-shadow: 0 4px 10px rgba(13, 110, 253, 0.2);
            transition: all 0.2s;
        }
        
        .btn-add:hover {
            background-color: #0b4eb8;
            transform: translateY(-1px);
        }
        
        .btn-back {
            background-color: white;
            color: #6b7280;
            border: 1px solid #e5e7eb;
            padding: 0.625rem 1.25rem;
            border-radius: 0.5rem;
            font-weight: 500;
            font-size: 0.875rem;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
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
        
        /* Curso badge */
        .course-badge {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 0.5rem 1rem;
            border-radius: 2rem;
            color: white;
            font-size: 0.875rem;
            font-weight: 500;
        }
        
        /* Info box */
        .info-box {
            background-color: #eff6ff;
            border: 1px solid #bfdbfe;
            border-radius: 0.75rem;
            padding: 1.25rem;
        }
        
        .dark .info-box {
            background-color: rgba(30, 58, 138, 0.2);
            border-color: #1e3a8a;
        }
        
        /* Evidencia icon */
        .evidencia-link {
            color: #0d6efd;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 0.25rem;
            font-size: 0.75rem;
        }
        
        .evidencia-link:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark text-[#111318] dark:text-white min-h-screen flex flex-col">

    <div class="flex flex-1 h-screen overflow-hidden">
        <!-- Sidebar -->
        <%@ include file="includes/sidebarDocente.jsp" %>
        
        <main class="flex-1 flex flex-col overflow-y-auto">
            <!-- Header -->
            <% request.setAttribute("pageTitle", "Observaciones - " + curso.getNombre()); %>
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
                
                <!-- Encabezado del curso con gradiente (igual que notaForm) -->
                <div class="bg-gradient-to-r from-primary to-blue-600 rounded-xl p-6 mb-8 text-white shadow-lg">
                    <div class="relative z-10 flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
                        <div>
                            <h2 class="text-2xl font-bold">Observaciones del Curso</h2>
                            <p class="text-blue-100 mt-1">
                                <strong><%= curso.getNombre() %></strong> - <%= curso.getGradoNombre() %>
                            </p>
                        </div>
                        <span class="course-badge">
                            <i class="fas fa-comment mr-2"></i>
                            <%= lista != null ? lista.size() : 0 %> observaciones
                        </span>
                    </div>
                </div>
                
                <!-- Acciones -->
                <div class="flex justify-between items-center mb-6">
                    <a href="ObservacionServlet?accion=registrar&curso_id=<%= curso.getId() %>" class="btn-add">
                        <i class="fas fa-plus"></i> Registrar Observación
                    </a>
                </div>
                
                <!-- Tabla de observaciones (SIN EL HEADER INTERMEDIO) -->
                <div class="table-container">
                    <div class="overflow-x-auto">
                        <table class="custom-table">
                            <thead>
                                <tr>
                                    <th>Alumno</th>
                                    <th>Tipo</th>
                                    <th>Observación</th>
                                    <th>Evidencia</th>
                                    <th class="text-center">Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    if (lista != null && !lista.isEmpty()) {
                                        for (Observacion o : lista) {
                                            String tipoClass = "";
                                            String tipoIcon = "";
                                            String tipoText = "";
                                            
                                            if ("POSITIVA".equals(o.getTipo())) {
                                                tipoClass = "badge-positiva";
                                                tipoIcon = "fa-smile";
                                                tipoText = "Positiva";
                                            } else if ("NEGATIVA".equals(o.getTipo())) {
                                                tipoClass = "badge-negativa";
                                                tipoIcon = "fa-frown";
                                                tipoText = "Negativa";
                                            } else {
                                                tipoClass = "badge-neutral";
                                                tipoIcon = "fa-meh";
                                                tipoText = "Neutral";
                                            }
                                %>
                                <tr>
                                    <td class="font-medium">
                                        <div class="flex items-center gap-2">
                                            <div class="w-8 h-8 rounded-full bg-blue-100 dark:bg-blue-900 flex items-center justify-center text-blue-600 dark:text-blue-300">
                                                <i class="fas fa-user-graduate text-xs"></i>
                                            </div>
                                            <%= o.getAlumnoNombre() %>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="<%= tipoClass %>">
                                            <i class="fas <%= tipoIcon %>"></i>
                                            <%= tipoText %>
                                        </span>
                                    </td>
                                    <td>
                                        <div class="max-w-xs truncate" title="<%= o.getTexto() %>">
                                            <%= o.getTexto() %>
                                        </div>
                                    </td>
                                    <td>
                                        <% if (o.getRutaEvidencia() != null && !o.getRutaEvidencia().isEmpty()) { %>
                                            <a href="#" class="evidencia-link" onclick="verEvidencia('<%= o.getRutaEvidencia() %>')">
                                                <i class="fas fa-paperclip"></i> Ver archivo
                                            </a>
                                        <% } else { %>
                                            <span class="text-gray-400 text-xs">Sin evidencia</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <div class="flex items-center justify-center gap-2">
                                            <a href="ObservacionServlet?accion=editar&id=<%= o.getId() %>&curso_id=<%= curso.getId() %>" 
                                               class="btn-edit" title="Editar observación">
                                                <i class="fas fa-pencil-alt"></i> Editar
                                            </a>
                                            <a href="ObservacionServlet?accion=eliminar&id=<%= o.getId() %>&curso_id=<%= curso.getId() %>" 
                                               class="btn-delete" 
                                               onclick="return confirm('¿Estás seguro de eliminar esta observación? Esta acción no se puede deshacer.')"
                                               title="Eliminar observación">
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
                                    <td colspan="5" class="text-center py-12">
                                        <div class="text-gray-500 dark:text-gray-400">
                                            <i class="fas fa-comment-slash fa-4x mb-4 opacity-50"></i>
                                            <p class="text-lg font-medium mb-2">No hay observaciones registradas</p>
                                        </div>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
                
                <!-- Info box (igual que notaForm) -->
                <div class="mt-6 p-4 bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg">
                    <div class="flex items-start gap-3">
                        <span class="material-symbols-outlined text-blue-600 dark:text-blue-400 mt-0.5">
                            info
                        </span>
                        <div>
                            <h4 class="font-medium text-blue-800 dark:text-blue-300">Información importante:</h4>
                            <ul class="mt-2 text-sm text-blue-700 dark:text-blue-400 space-y-1">
                                <li>• Las observaciones son visibles para los padres de familia</li>
                                <li>• Puedes editar o eliminar observaciones existentes</li>
                                <li>• Registra observaciones positivas o áreas de mejora para los estudiantes</li>
                                <li>• Las observaciones con evidencia adjunta tienen un icono de papel clip</li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <script>
        // Función para ver evidencia (puedes personalizarla según tu necesidad)
        function verEvidencia(ruta) {
            // Aquí puedes abrir un modal o redirigir al archivo
            window.open(ruta, '_blank');
        }
        
        // Confirmación para eliminar
        document.querySelectorAll('.btn-delete').forEach(btn => {
            btn.addEventListener('click', function(e) {
                if (!confirm('¿Estás seguro de eliminar esta observación? Esta acción no se puede deshacer.')) {
                    e.preventDefault();
                }
            });
        });
        
        // Auto-ocultar mensajes después de 5 segundos
        setTimeout(function() {
            document.querySelectorAll('.alert').forEach(alert => {
                alert.style.transition = 'opacity 0.5s';
                alert.style.opacity = '0';
                setTimeout(() => alert.remove(), 500);
            });
        }, 5000);
    </script>
</body>
</html>