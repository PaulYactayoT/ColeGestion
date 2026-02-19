<%-- 
    Document   : observacionForm
    Created on : 31 may. 2025, 6:34:33?a. m.
    Author     : Juan Pablo Amaya
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Curso, modelo.Profesor, modelo.Observacion, modelo.Alumno, java.util.List" %>

<%
    Profesor docente = (Profesor) session.getAttribute("docente");
    Curso curso = (Curso) request.getAttribute("curso");
    List<Alumno> alumnos = (List<Alumno>) request.getAttribute("alumnos");
    Observacion observacion = (Observacion) request.getAttribute("observacion");

    if (docente == null || curso == null) {
        response.sendRedirect("docenteDashboard.jsp");
        return;
    }

    boolean editar = (observacion != null);
    
    String mensaje = (String) session.getAttribute("mensaje");
    String error = (String) session.getAttribute("error");
    
    if (mensaje != null) session.removeAttribute("mensaje");
    if (error != null) session.removeAttribute("error");
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <%@ include file="includes/head.jsp" %>
    <title><%= editar ? "Editar Observación" : "Registrar Observación" %> - <%= curso.getNombre() %></title>
    <style>
        /* Estilos adicionales para el formulario */
        .form-card {
            background: white;
            border-radius: 0.75rem;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            border: 1px solid #e5e7eb;
            overflow: hidden;
        }
        
        .dark .form-card {
            background: #1a2233;
            border-color: #374151;
        }
        
        .form-header {
            background-color: #fff;
            padding: 1.25rem 1.5rem;
            border-bottom: 1px solid #e5e7eb;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .dark .form-header {
            background-color: #1a2233;
            border-bottom-color: #374151;
        }
        
        .form-header h5 {
            margin: 0;
            font-weight: 600;
            color: #0d6efd;
            font-size: 1rem;
        }
        
        .dark .form-header h5 {
            color: #3b82f6;
        }
        
        .form-body {
            padding: 1.5rem;
        }
        
        .form-label {
            font-weight: 500;
            font-size: 0.875rem;
            color: #374151;
            margin-bottom: 0.5rem;
            display: block;
        }
        
        .dark .form-label {
            color: #e5e7eb;
        }
        
        .form-label i {
            margin-right: 0.25rem;
            color: #0d6efd;
        }
        
        .dark .form-label i {
            color: #3b82f6;
        }
        
        .form-control, .form-select {
            width: 100%;
            padding: 0.625rem 0.75rem;
            border: 1px solid #e5e7eb;
            border-radius: 0.5rem;
            font-size: 0.875rem;
            color: #1f2937;
            transition: all 0.2s;
            background-color: #fff;
        }
        
        .dark .form-control, .dark .form-select {
            background-color: #283044;
            border-color: #4b5563;
            color: #f3f4f6;
        }
        
        .form-control:focus, .form-select:focus {
            border-color: #0d6efd;
            outline: none;
            box-shadow: 0 0 0 3px rgba(13, 110, 253, 0.1);
        }
        
        textarea.form-control {
            resize: vertical;
            min-height: 120px;
        }
        
        .btn-cancel {
            background-color: white;
            color: #6b7280;
            border: 1px solid #e5e7eb;
            padding: 0.625rem 1.25rem;
            border-radius: 0.5rem;
            font-weight: 500;
            text-decoration: none;
            font-size: 0.875rem;
            transition: all 0.2s;
        }
        
        .btn-cancel:hover {
            background-color: #f3f4f6;
            color: #374151;
        }
        
        .dark .btn-cancel {
            background-color: #283044;
            color: #e5e7eb;
            border-color: #4b5563;
        }
        
        .dark .btn-cancel:hover {
            background-color: #374151;
        }
        
        .btn-save {
            background-color: #0d6efd;
            color: white;
            border: none;
            padding: 0.625rem 1.5rem;
            border-radius: 0.5rem;
            font-weight: 500;
            font-size: 0.875rem;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            box-shadow: 0 4px 10px rgba(13, 110, 253, 0.2);
            transition: all 0.2s;
            cursor: pointer;
        }
        
        .btn-save:hover {
            background-color: #0b4eb8;
            transform: translateY(-1px);
        }
        
        .btn-save:disabled {
            opacity: 0.5;
            cursor: not-allowed;
            transform: none;
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
        
        .course-badge {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 0.5rem 1rem;
            border-radius: 2rem;
            color: white;
            font-size: 0.875rem;
            font-weight: 500;
        }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark text-[#111318] dark:text-white min-h-screen flex flex-col">

    <div class="flex flex-1 h-screen overflow-hidden">
        <!-- Sidebar -->
        <%@ include file="includes/sidebarDocente.jsp" %>
        
        <main class="flex-1 flex flex-col overflow-y-auto">
            <!-- Header -->
            <% request.setAttribute("pageTitle", (editar ? "Editar Observación" : "Nueva Observación") + " - " + curso.getNombre()); %>
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
                            <h2 class="text-2xl font-bold"><%= editar ? "Editar Observación" : "Registrar Nueva Observación" %></h2>
                            <p class="text-blue-100 mt-1">
                                Curso: <strong><%= curso.getNombre() %></strong> - <%= curso.getGradoNombre() %>
                            </p>
                        </div>
                        <span class="course-badge">
                            <i class="fas fa-user-graduate mr-2"></i>
                            <%= alumnos != null ? alumnos.size() : 0 %> estudiantes
                        </span>
                    </div>
                </div>
                
                <!-- Formulario -->
                <div class="form-card max-w-3xl mx-auto">
                    <div class="form-header">
                        <h5><i class="fas fa-<%= editar ? "edit" : "plus-circle" %> me-2"></i> 
                            <%= editar ? "Editar Observación" : "Registrar Nueva Observación" %>
                        </h5>
                    </div>

                    <div class="form-body">
                        <form action="ObservacionServlet" method="post">
                            <input type="hidden" name="curso_id" value="<%= curso.getId() %>">
                            <% if (editar) { %>
                                <input type="hidden" name="accion" value="actualizar">
                                <input type="hidden" name="id" value="<%= observacion.getId() %>">
                            <% } else { %>
                                <input type="hidden" name="accion" value="guardar">
                            <% } %>

                            <div class="mb-6">
                                <label class="form-label">
                                    <i class="fas fa-user"></i> Alumno <span class="text-red-500">*</span>
                                </label>
                                <select name="alumno_id" class="form-select" required>
                                    <option value="">-- Seleccione un alumno --</option>
                                    <% for (Alumno a : alumnos) { %>
                                    <option value="<%= a.getId() %>" <%= (editar && a.getId() == observacion.getAlumnoId()) ? "selected" : "" %>>
                                        <%= a.getNombres() %> <%= a.getApellidos() %>
                                    </option>
                                    <% } %>
                                </select>
                            </div>

                            <div class="mb-6">
                                <label class="form-label">
                                    <i class="fas fa-comment"></i> Observación <span class="text-red-500">*</span>
                                </label>
                                <textarea name="texto" class="form-control" rows="5" 
                                          placeholder="Escribe aquí tu observación sobre el estudiante..." 
                                          required><%= editar ? observacion.getTexto() : "" %></textarea>
                                <p class="text-xs text-gray-500 dark:text-gray-400 mt-2">
                                    <i class="fas fa-info-circle"></i> 
                                    Esta observación será visible para los padres del estudiante.
                                </p>
                            </div>

                            <div class="flex justify-end gap-3">
                                <a href="ObservacionServlet?accion=listar&curso_id=<%= curso.getId() %>" class="btn-cancel">
                                    <i class="fas fa-times mr-2"></i> Cancelar
                                </a>
                                <button type="submit" class="btn-save" id="submitBtn">
                                    <i class="fas fa-<%= editar ? "save" : "check" %>"></i>
                                    <%= editar ? "Actualizar" : "Registrar" %>
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
                
                <!-- Info box -->
                <div class="mt-6 p-4 bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg max-w-3xl mx-auto">
                    <div class="flex items-start gap-3">
                        <span class="material-symbols-outlined text-blue-600 dark:text-blue-400 mt-0.5">
                            info
                        </span>
                        <div>
                            <h4 class="font-medium text-blue-800 dark:text-blue-300">Consejos para escribir observaciones:</h4>
                            <ul class="mt-2 text-sm text-blue-700 dark:text-blue-400 space-y-1">
                                <li>• Sé específico y objetivo en tu observación</li>
                                <li>• Menciona tanto aspectos positivos como áreas de mejora</li>
                                <li>• Incluye recomendaciones concretas para el estudiante</li>
                                <li>• Mantén un tono profesional y constructivo</li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>

    <!-- Bootstrap JS (opcional, solo si necesitas funcionalidad de Bootstrap) -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Prevenir envío doble del formulario
        document.getElementById('submitBtn')?.addEventListener('click', function() {
            this.disabled = true;
            this.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Procesando...';
            this.form.submit();
        });
    </script>
</body>
</html>