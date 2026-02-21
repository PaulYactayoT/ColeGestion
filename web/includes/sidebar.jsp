<%-- 
    Document   : sidebar
    Created on : 15 feb. 2026, 9:01:33 a. m.
    Author     : Ocelot
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="modelo.ModuloDAO, modelo.Modulo, java.util.List" %>
<%
    String currentPage = request.getServletPath();
    String rolSidebar  = (String) session.getAttribute("rol");

    // Cargar módulos dinámicos para roles NO admin
    List<Modulo> modulosMenu = new java.util.ArrayList<>();
    if (!"admin".equals(rolSidebar)) {
        Object idObj = session.getAttribute("usuarioId");
        if (idObj != null) {
            try {
                int uid = Integer.parseInt(idObj.toString());
                modulosMenu = new ModuloDAO().listarPorUsuario(uid);
            } catch (Exception e) {
                System.err.println("Error cargando módulos sidebar: " + e.getMessage());
            }
        }
    }
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

            <% if ("admin".equals(rolSidebar)) { %>
            <%-- ================================================= --%>
            <%--  MENÚ FIJO PARA ADMIN                             --%>
            <%-- ================================================= --%>

            <!-- Dashboard -->
            <a class="flex items-center gap-3 px-3 py-2 rounded-lg <%= currentPage.contains("dashboard") ? "bg-primary/10 text-primary font-medium" : "text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800" %> transition-colors" 
               href="<%= request.getContextPath() %>/dashboard.jsp"
               <%= currentPage.contains("dashboard") ? "aria-current=\"page\"" : "" %>>
                <span class="material-symbols-outlined">dashboard</span>
                <span class="text-sm">Dashboard</span>
            </a>

            <!-- Estudiantes -->
            <a class="flex items-center gap-3 px-3 py-2 rounded-lg <%= currentPage.contains("alumno") || currentPage.contains("Alumno") ? "bg-primary/10 text-primary font-medium" : "text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800" %> transition-colors" 
               href="<%= request.getContextPath() %>/AlumnoServlet"
               <%= currentPage.contains("alumno") || currentPage.contains("Alumno") ? "aria-current=\"page\"" : "" %>>
                <i class="fas fa-user-graduate" aria-hidden="true"></i>
                <span class="text-sm">Estudiantes</span>
            </a>

            <!-- Profesores -->
            <a class="flex items-center gap-3 px-3 py-2 rounded-lg <%= currentPage.contains("profesor") || currentPage.contains("Profesor") ? "bg-primary/10 text-primary font-medium" : "text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800" %> transition-colors" 
               href="<%= request.getContextPath() %>/ProfesorServlet"
               <%= currentPage.contains("profesor") || currentPage.contains("Profesor") ? "aria-current=\"page\"" : "" %>>
                <i class="fas fa-chalkboard-teacher" aria-hidden="true"></i>
                <span class="text-sm">Profesores</span>
            </a>

            <!-- Administrativos -->
            <a class="flex items-center gap-3 px-3 py-2 rounded-lg <%= currentPage.contains("administrativo") || currentPage.contains("Administrativo") ? "bg-primary/10 text-primary font-medium" : "text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800" %> transition-colors" 
               href="<%= request.getContextPath() %>/AdministrativoServlet"
               <%= currentPage.contains("Administrativo") || currentPage.contains("administrativo") ? "aria-current=\"page\"" : "" %>>
                <i class="fas fa-user-tie" aria-hidden="true"></i>
                <span class="text-sm">Administrativo</span>
            </a>

            <!-- Cursos -->
            <a class="flex items-center gap-3 px-3 py-2 rounded-lg <%= currentPage.contains("curso") || currentPage.contains("Curso") ? "bg-primary/10 text-primary font-medium" : "text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800" %> transition-colors" 
               href="<%= request.getContextPath() %>/CursoServlet"
               <%= currentPage.contains("curso") || currentPage.contains("Curso") ? "aria-current=\"page\"" : "" %>>
                <i class="fas fa-book" aria-hidden="true"></i>
                <span class="text-sm">Cursos</span>
            </a>

            <!-- Grados -->
            <a class="flex items-center gap-3 px-3 py-2 rounded-lg <%= currentPage.contains("grado") || currentPage.contains("Grado") ? "bg-primary/10 text-primary font-medium" : "text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800" %> transition-colors" 
               href="<%= request.getContextPath() %>/GradoServlet"
               <%= currentPage.contains("grado") || currentPage.contains("Grado") ? "aria-current=\"page\"" : "" %>>
                <i class="fas fa-layer-group" aria-hidden="true"></i>
                <span class="text-sm">Grados</span>
            </a>

            <!-- Usuarios -->
            <a class="flex items-center gap-3 px-3 py-2 rounded-lg <%= currentPage.contains("usuario") || currentPage.contains("Usuario") ? "bg-primary/10 text-primary font-medium" : "text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800" %> transition-colors" 
               href="<%= request.getContextPath() %>/UsuarioServlet"
               <%= currentPage.contains("usuario") || currentPage.contains("Usuario") ? "aria-current=\"page\"" : "" %>>
                <i class="fas fa-users-cog" aria-hidden="true"></i>
                <span class="text-sm">Usuarios</span>
            </a>

            <!-- Disponibilidad -->
            <a class="flex items-center gap-3 px-3 py-2 rounded-lg <%= currentPage.contains("disponibilidad") || currentPage.contains("Disponibilidad") ? "bg-primary/10 text-primary font-medium" : "text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800" %> transition-colors" 
               href="<%= request.getContextPath() %>/AdminDisponibilidadServlet"
               <%= currentPage.contains("disponibilidad") || currentPage.contains("Disponibilidad") ? "aria-current=\"page\"" : "" %>>
                <i class="fas fa-calendar-check" aria-hidden="true"></i>
                <span class="text-sm">Disponibilidad</span>
            </a>

            <!-- Master Table CRUD -->
            <a class="flex items-center gap-3 px-3 py-2 rounded-lg <%= currentPage.contains("MasterTable") || currentPage.contains("masterTable") ? "bg-primary/10 text-primary font-medium" : "text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800" %> transition-colors" 
               href="<%= request.getContextPath() %>/MasterTableServlet"
               <%= currentPage.contains("MasterTable") || currentPage.contains("masterTable") ? "aria-current=\"page\"" : "" %>>
                <i class="fas fa-table" aria-hidden="true"></i>
                <span class="text-sm">Master Table CRUD</span>
            </a>

            <!-- Módulos -->
            <a class="flex items-center gap-3 px-3 py-2 rounded-lg <%= currentPage.contains("Modulo") || currentPage.contains("modulo") ? "bg-primary/10 text-primary font-medium" : "text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800" %> transition-colors"
               href="<%= request.getContextPath() %>/ModuloServlet?accion=listar"
               <%= currentPage.contains("Modulo") || currentPage.contains("modulo") ? "aria-current=\"page\"" : "" %>>
                <i class="fas fa-shield-alt" aria-hidden="true"></i>
                <span class="text-sm">Módulos</span>
            </a>

            <% } else if (modulosMenu.isEmpty()) { %>
            <%-- ================================================= --%>
            <%--  SIN MÓDULOS ASIGNADOS                           --%>
            <%-- ================================================= --%>
            <div class="flex flex-col items-center gap-2 py-8 text-center text-[#616f89]">
                <i class="fas fa-lock text-3xl opacity-30"></i>
                <p class="text-xs">Sin módulos asignados.<br>Contacta al administrador.</p>
            </div>

            <% } else { %>
            <%-- ================================================= --%>
            <%--  MENÚ DINÁMICO: docente / padre / administrativo  --%>
            <%-- ================================================= --%>
            <%
                for (Modulo mod : modulosMenu) {
                    String urlMod  = mod.getUrl() != null ? mod.getUrl() : "#";
                    String icono   = mod.getIcono() != null ? mod.getIcono() : "fas fa-circle";
                    String urlBase = urlMod.split("\\?")[0];
                    boolean activo = currentPage.contains(urlBase);
                    String clsLink = activo
                        ? "bg-primary/10 text-primary font-medium"
                        : "text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800";
            %>
            <a class="flex items-center gap-3 px-3 py-2 rounded-lg <%= clsLink %> transition-colors"
               href="<%= request.getContextPath() %>/<%= urlMod %>"
               <%= activo ? "aria-current=\"page\"" : "" %>>
                <i class="<%= icono %>" aria-hidden="true"></i>
                <span class="text-sm"><%= mod.getNombre() %></span>
            </a>
            <% } %>

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
