<%-- 
    Document   : sidebarPadre
    Created on : 18 feb. 2026, 6:58:56 a. m.
    Author     : Ocelot
--%>
<%--
    sidebarPadre.jsp
    Sidebar dinámico para el rol PADRE.
    Carga únicamente los módulos asignados al usuario desde usuario_modulo.
    Los módulos que necesiten alumno_id lo recibirán desde la sesión.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="modelo.ModuloDAO, modelo.Modulo, java.util.List, modelo.Padre" %>
<%
    String currentPagePadre = request.getServletPath();
    String currentQueryString = request.getQueryString() != null ? "?" + request.getQueryString() : "";
    String currentFullUrl = currentPagePadre + currentQueryString;

    // Obtener alumnoId del objeto padre en sesión
    String alumnoIdParam = "";
    Padre padreObj = (Padre) session.getAttribute("padre");
    if (padreObj != null && padreObj.getAlumnoId() > 0) {
        alumnoIdParam = String.valueOf(padreObj.getAlumnoId());
    }

    List<Modulo> modulosPadre = new java.util.ArrayList<>();
    Object uidObjP = session.getAttribute("usuarioId");
    if (uidObjP != null) {
        try {
            int uidP = Integer.parseInt(uidObjP.toString());
            modulosPadre = new ModuloDAO().listarPorUsuario(uidP);
        } catch (Exception exP) {
            System.err.println("sidebarPadre: error cargando módulos: " + exP.getMessage());
        }
    }
%>

<aside class="w-64 bg-white dark:bg-[#1a2233] border-r border-gray-200 dark:border-gray-700 hidden md:flex flex-col justify-between fixed h-full z-20">
    <div class="p-6">
        <!-- Logo -->
        <div class="flex items-center gap-3 mb-8">
            <div class="bg-primary size-10 rounded-lg flex items-center justify-center text-white shadow-md">
                <span class="material-symbols-outlined">school</span>
            </div>
            <div>
                <h1 class="text-lg font-bold leading-tight text-slate-900 dark:text-white whitespace-nowrap">San Antonio</h1>
                <p class="text-xs text-slate-500 dark:text-gray-400 font-medium whitespace-nowrap">Panel de Padre</p>
            </div>
        </div>

        <!-- Navegación dinámica -->
        <nav class="space-y-1">
            <%
                boolean dashboardActivo = currentPagePadre.contains("padreDashboard");
                String dashboardCls = dashboardActivo
                    ? "flex items-center gap-3 px-3 py-2.5 rounded-lg bg-primary/10 text-primary font-medium transition-colors w-full"
                    : "flex items-center gap-3 px-3 py-2.5 rounded-lg text-slate-600 dark:text-gray-300 hover:bg-slate-50 dark:hover:bg-gray-800 transition-colors group w-full";
            %>
            <a href="<%= request.getContextPath() %>/PadreDashboardServlet"
               class="<%= dashboardCls %>"
                <%= dashboardActivo ? "aria-current='page'" : "" %>>
                <span class="material-symbols-outlined w-5 text-center flex-shrink-0 text-[20px]">home</span>
                <span class="text-sm font-medium whitespace-nowrap">Inicio</span>
            </a>

            <% if (modulosPadre.isEmpty()) { %>
                <div class="flex flex-col items-center gap-2 py-8 text-center text-slate-400">
                    <i class="fas fa-lock text-3xl opacity-30"></i>
                    <p class="text-xs">Sin módulos asignados.<br>Contacta al administrador.</p>
                </div>
            <% } else {
                for (Modulo modP : modulosPadre) {
                    String urlModP  = modP.getUrl()   != null ? modP.getUrl()   : "#";
                    String iconoP   = modP.getIcono() != null ? modP.getIcono() : "fas fa-circle";
                    
                    // Extraer la URL base sin parámetros
                    String urlBaseP = urlModP.split("\\?")[0];
                    
                    // Determinar si está activo
                    boolean activoP = currentPagePadre.contains(urlBaseP) || currentFullUrl.contains(urlModP);
                    
                    String clsP = activoP
                        ? "flex items-center gap-3 px-3 py-2.5 rounded-lg bg-primary/10 text-primary font-medium transition-colors w-full"
                        : "flex items-center gap-3 px-3 py-2.5 rounded-lg text-slate-600 dark:text-gray-300 hover:bg-slate-50 dark:hover:bg-gray-800 transition-colors group w-full";

                    // Construir URL con alumno_id si es necesario
                    String urlFinal = urlModP;
                    if (!alumnoIdParam.isEmpty()) {
                        if (urlModP.contains("?")) {
                            urlFinal = urlModP + "&alumno_id=" + alumnoIdParam;
                        } else {
                            // Solo agregar alumno_id si el módulo parece necesitarlo
                            if (urlBaseP.contains("nota") || urlBaseP.contains("asistencia") ||
                                urlBaseP.contains("observacion") || urlBaseP.contains("tarea") ||
                                urlBaseP.contains("album") || urlBaseP.contains("Album") ||
                                urlBaseP.contains("justific")) {
                                urlFinal = urlModP + "?alumno_id=" + alumnoIdParam;
                            }
                        }
                    }
            %>
                <a href="<%= request.getContextPath() %>/<%= urlFinal %>"
                   class="<%= clsP %>"
                   <%= activoP ? "aria-current=\"page\"" : "" %>>
                    <%-- Icono con ancho fijo --%>
                    <i class="<%= iconoP %> w-5 text-center flex-shrink-0" aria-hidden="true"></i>
                    <%-- Texto con nowrap para evitar que se parta --%>
                    <span class="text-sm font-medium whitespace-nowrap overflow-hidden text-ellipsis"><%= modP.getNombre() %></span>
                </a>
            <% } } %>
        </nav>
    </div>

    <!-- Cerrar Sesión -->
    <div class="p-4 border-t border-gray-100 dark:border-gray-700">
        <a href="<%= request.getContextPath() %>/LogoutServlet"
           class="flex items-center justify-center gap-2 w-full py-2.5 border border-slate-200 dark:border-gray-600 rounded-lg text-sm font-medium text-slate-600 dark:text-gray-300 hover:bg-slate-50 dark:hover:bg-gray-800 hover:text-red-600 transition-colors">
            <span class="material-symbols-outlined text-[18px] flex-shrink-0">logout</span>
            <span class="whitespace-nowrap">Cerrar Sesión</span>
        </a>
    </div>
</aside>