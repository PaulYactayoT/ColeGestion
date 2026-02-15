<%-- 
    Document   : sidebar
    Created on : 15 feb. 2026, 9:01:33 a. m.
    Author     : Ocelot
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String currentPage = request.getServletPath();
    String rolSidebar = (String) session.getAttribute("rol");
%>

<!-- Sidebar Lateral -->
<aside class="w-64 flex-shrink-0 bg-white dark:bg-[#1a2233] border-r border-[#dbdfe6] dark:border-gray-700 flex flex-col justify-between">
    <div class="flex flex-col gap-8 p-6">
        <!-- Logo -->
        <div class="flex items-center gap-3">
            <div class="bg-primary size-10 rounded-lg flex items-center justify-center text-white" aria-hidden="true">
                <span class="material-symbols-outlined">school</span>
            </div>
            <div class="flex flex-col">
                <h1 class="text-[#111318] dark:text-white text-lg font-bold leading-tight">San Antonio</h1>
                <p class="text-[#616f89] dark:text-gray-400 text-xs font-normal">Gestión Académica</p>
            </div>
        </div>
        
        <!-- Navegación -->
        <nav class="flex flex-col gap-2" aria-label="Navegación principal">
            <!-- Dashboard - Todos -->
            <a class="flex items-center gap-3 px-3 py-2 rounded-lg <%= currentPage.contains("dashboard") ? "bg-primary/10 text-primary font-medium" : "text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800" %> transition-colors" 
               href="<%= request.getContextPath() %>/dashboard.jsp"
               <%= currentPage.contains("dashboard") ? "aria-current=\"page\"" : "" %>>
                <span class="material-symbols-outlined">dashboard</span>
                <span class="text-sm">Dashboard</span>
            </a>
            
            <!-- Estudiantes - Solo Admin -->
            <% if ("admin".equals(rolSidebar)) { %>
            <a class="flex items-center gap-3 px-3 py-2 rounded-lg <%= currentPage.contains("alumno") || currentPage.contains("Alumno") ? "bg-primary/10 text-primary font-medium" : "text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800" %> transition-colors" 
               href="<%= request.getContextPath() %>/AlumnoServlet"
               <%= currentPage.contains("alumno") || currentPage.contains("Alumno") ? "aria-current=\"page\"" : "" %>>
                <i class="fas fa-user-graduate" aria-hidden="true"></i>
                <span class="text-sm">Estudiantes</span>
            </a>
            <% } %>
            
            <!-- Profesores - Solo Admin -->
            <% if ("admin".equals(rolSidebar)) { %>
            <a class="flex items-center gap-3 px-3 py-2 rounded-lg <%= currentPage.contains("profesor") || currentPage.contains("Profesor") ? "bg-primary/10 text-primary font-medium" : "text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800" %> transition-colors" 
               href="<%= request.getContextPath() %>/ProfesorServlet"
               <%= currentPage.contains("profesor") || currentPage.contains("Profesor") ? "aria-current=\"page\"" : "" %>>
                <i class="fas fa-chalkboard-teacher" aria-hidden="true"></i>
                <span class="text-sm">Profesores</span>
            </a>
            <% } %>
            
            <!-- Cursos - Admin y Docente -->
            <% if ("admin".equals(rolSidebar) || "docente".equals(rolSidebar)) { %>
            <a class="flex items-center gap-3 px-3 py-2 rounded-lg <%= currentPage.contains("curso") || currentPage.contains("Curso") ? "bg-primary/10 text-primary font-medium" : "text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800" %> transition-colors" 
               href="<%= request.getContextPath() %>/CursoServlet"
               <%= currentPage.contains("curso") || currentPage.contains("Curso") ? "aria-current=\"page\"" : "" %>>
                <i class="fas fa-book" aria-hidden="true"></i>
                <span class="text-sm">Cursos</span>
            </a>
            <% } %>
            
            <!-- Grados - Solo Admin -->
            <% if ("admin".equals(rolSidebar)) { %>
            <a class="flex items-center gap-3 px-3 py-2 rounded-lg <%= currentPage.contains("grado") || currentPage.contains("Grado") ? "bg-primary/10 text-primary font-medium" : "text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800" %> transition-colors" 
               href="<%= request.getContextPath() %>/GradoServlet"
               <%= currentPage.contains("grado") || currentPage.contains("Grado") ? "aria-current=\"page\"" : "" %>>
                <i class="fas fa-layer-group" aria-hidden="true"></i>
                <span class="text-sm">Grados</span>
            </a>
            <% } %>
            
            <!-- Usuarios - Solo Admin -->
            <% if ("admin".equals(rolSidebar)) { %>
            <a class="flex items-center gap-3 px-3 py-2 rounded-lg <%= currentPage.contains("usuario") || currentPage.contains("Usuario") ? "bg-primary/10 text-primary font-medium" : "text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800" %> transition-colors" 
               href="<%= request.getContextPath() %>/UsuarioServlet"
               <%= currentPage.contains("usuario") || currentPage.contains("Usuario") ? "aria-current=\"page\"" : "" %>>
                <i class="fas fa-users-cog" aria-hidden="true"></i>
                <span class="text-sm">Usuarios</span>
            </a>
            <% } %>
            
            <!-- Disponibilidad del Profesor - Solo Admin -->
            <% if ("admin".equals(rolSidebar)) { %>
            <a class="flex items-center gap-3 px-3 py-2 rounded-lg <%= currentPage.contains("disponibilidad") || currentPage.contains("Disponibilidad") ? "bg-primary/10 text-primary font-medium" : "text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800" %> transition-colors" 
               href="<%= request.getContextPath() %>/AdminDisponibilidadServlet"
               <%= currentPage.contains("disponibilidad") || currentPage.contains("Disponibilidad") ? "aria-current=\"page\"" : "" %>>
                <i class="fas fa-calendar-check" aria-hidden="true"></i>
                <span class="text-sm">Disponibilidad</span>
            </a>
            <% } %>
        </nav>
    </div>
    
    <!-- Botón de Cerrar Sesión -->
    <div class="p-6 border-t border-[#dbdfe6] dark:border-gray-700">
        <a href="<%= request.getContextPath() %>/LogoutServlet" 
           class="flex w-full items-center justify-center gap-2 rounded-lg h-10 px-4 bg-primary text-white text-sm font-bold tracking-wide hover:bg-blue-700 transition-colors">
            <span class="material-symbols-outlined text-[18px]" aria-hidden="true">logout</span>
            <span>Cerrar Sesión</span>
        </a>
    </div>
</aside>
