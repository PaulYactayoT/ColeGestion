<%-- 
    Document   : sidebarDocente
    Created on : 17 feb. 2026, 9:06:27 p. m.
    Author     : Ocelot
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="modelo.ModuloDAO, modelo.Modulo, java.util.List" %>
<%
    String currentPageDoc = request.getServletPath();

    List<Modulo> modulosDocente = new java.util.ArrayList<>();
    Object uidObj = session.getAttribute("usuarioId");
    if (uidObj != null) {
        try {
            int uid = Integer.parseInt(uidObj.toString());
            modulosDocente = new ModuloDAO().listarPorUsuario(uid);
        } catch (Exception ex) {
            System.err.println("sidebarDocente: error cargando módulos: " + ex.getMessage());
        }
    }
%>

<aside class="w-64 flex-shrink-0 bg-white dark:bg-[#1a2233] border-r border-[#dbdfe6] dark:border-gray-700 flex flex-col justify-between">
    <div class="flex flex-col gap-8 p-6">

        <!-- Logo -->
        <div class="flex items-center gap-3">
            <div class="bg-primary size-10 rounded-lg flex items-center justify-center text-white" aria-hidden="true">
                <span class="material-symbols-outlined">school</span>
            </div>
            <div class="flex flex-col">
                <h1 class="text-[#111318] dark:text-white text-lg font-bold leading-tight">San Antonio</h1>
                <p class="text-[#616f89] dark:text-gray-400 text-xs font-normal">Panel de Profesor</p>
            </div>
        </div>

        <!-- Navegación dinámica -->
        <nav class="flex flex-col gap-2" aria-label="Navegación principal">

            <!-- Botón Inicio siempre visible -->
            <%
                boolean iniciActivo = currentPageDoc.contains("docenteDashboard");
                String clsInicio = iniciActivo
                    ? "bg-primary/10 text-primary font-medium"
                    : "text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800";
            %>
            <a class="flex items-center gap-3 px-3 py-2 rounded-lg <%= clsInicio %> transition-colors"
               href="<%= request.getContextPath() %>/DocenteDashboardServlet"
               <%= iniciActivo ? "aria-current=\"page\"" : "" %>>
                <span class="material-symbols-outlined text-[20px]">home</span>
                <span class="text-sm">Inicio</span>
            </a>

            <% if (modulosDocente.isEmpty()) { %>
                <div class="flex flex-col items-center gap-2 py-8 text-center text-[#616f89]">
                    <i class="fas fa-lock text-3xl opacity-30"></i>
                    <p class="text-xs">Sin módulos asignados.<br>Contacta al administrador.</p>
                </div>
            <% } else {
                // Para detectar página activa también desde JSPs que usan el servlet
                String currentURI = request.getRequestURI();
                String currentServlet = currentPageDoc; // ej: /materialSeleccionCurso.jsp
                
                for (Modulo mod : modulosDocente) {
                    String urlMod  = mod.getUrl()   != null ? mod.getUrl()   : "#";
                    String icono   = mod.getIcono() != null ? mod.getIcono() : "fas fa-circle";
                    String urlBase = urlMod.split("\\?")[0].trim(); // ej: MaterialServlet

                    // Activo si: el path actual contiene el servlet, o la URI contiene el servlet
                    boolean activo = currentServlet.contains(urlBase)
                                  || currentURI.contains(urlBase);
                    
                    // Casos especiales: JSPs que son resultado de un servlet
                    if (!activo) {
                        if (urlBase.equals("MaterialServlet") && currentServlet.contains("material")) activo = true;
                        if (urlBase.equals("AsistenciaServlet") && currentServlet.contains("asistencia")) activo = true;
                        if (urlBase.equals("NotaServlet") && currentServlet.contains("nota")) activo = true;
                        if (urlBase.equals("TareaServlet") && currentServlet.contains("tarea")) activo = true;
                        if (urlBase.equals("ObservacionServlet") && currentServlet.contains("observacion")) activo = true;
                        if (urlBase.equals("JustificacionServlet") && (currentServlet.contains("justificacion") || currentServlet.contains("revisarJustificaciones"))) activo = true;
                        if (urlBase.equals("DisponibilidadServlet") && currentServlet.contains("disponibilidad")) activo = true;
                    }
                    
                    String cls = activo
                        ? "bg-primary/10 text-primary font-medium"
                        : "text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800";
            %>
                <a class="flex items-center gap-3 px-3 py-2 rounded-lg <%= cls %> transition-colors"
                   href="<%= request.getContextPath() %>/<%= urlMod %>"
                   <%= activo ? "aria-current=\"page\"" : "" %>>
                    <i class="<%= icono %>" aria-hidden="true"></i>
                    <span class="text-sm"><%= mod.getNombre() %></span>
                </a>
            <% } } %>
        </nav>

    </div>

    <!-- Cerrar Sesión -->
    <div class="p-6 border-t border-[#dbdfe6] dark:border-gray-700">
        <a href="<%= request.getContextPath() %>/LogoutServlet"
           class="flex w-full items-center justify-center gap-2 rounded-lg h-10 px-4 bg-primary text-white text-sm font-bold tracking-wide hover:bg-blue-700 transition-colors">
            <span class="material-symbols-outlined text-[18px]" aria-hidden="true">logout</span>
            <span>Cerrar Sesión</span>
        </a>
    </div>
</aside>
