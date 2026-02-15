<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page import="java.util.*" %>
<%@ page import="modelo.Disponibilidad" %>

<%
    // Seguridad y recuperación de datos
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    List<Disponibilidad> lista = (List<Disponibilidad>) request.getAttribute("listaPendientes");
    String mensaje = (String) request.getAttribute("mensaje");
    String tipoMensaje = (String) request.getAttribute("tipoMensaje");
    
    // Título para el header dinámico
    request.setAttribute("pageTitle", "Evaluación de Horarios");
%>

<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <title>Evaluación de Horarios | San Antonio</title>
    
    <%-- ✅ Incluir HEAD común --%>
    <%@ include file="includes/head.jsp" %>
    
    <script>
        // Script para rechazar con motivo
        function rechazar(id) {
            const motivo = prompt("Ingrese el motivo del rechazo:");
            if (motivo) {
                window.location.href = "AdminDisponibilidadServlet?accion=rechazar&id=" + id + 
                                       "&observacion=" + encodeURIComponent(motivo);
            }
        }
    </script>
</head>
<body class="bg-background-light dark:bg-background-dark text-[#111318] dark:text-white min-h-screen">

    <div class="flex h-screen overflow-hidden">

        <%-- ✅ SIDEBAR --%>
        <%@ include file="includes/sidebar.jsp" %>

        <main class="flex-1 flex flex-col overflow-y-auto">

            <%-- ✅ HEADER con foto dinámica --%>
            <%@ include file="includes/header.jsp" %>

            <div class="p-8 max-w-[1200px] mx-auto w-full">
                
                <% if (mensaje != null) { %>
                    <div class="mb-6 p-4 rounded-lg <%= tipoMensaje.equals("success") ? "bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300" : "bg-red-100 text-red-800 dark:bg-red-900/30 dark:text-red-300" %> flex items-center gap-3">
                        <span class="material-symbols-outlined"><%= tipoMensaje.equals("success") ? "check_circle" : "error" %></span>
                        <%= mensaje %>
                    </div>
                <% } %>

                <div class="bg-white dark:bg-[#1a2233] rounded-xl border border-[#dbdfe6] dark:border-gray-700 shadow-sm overflow-hidden">
                    <div class="p-6 border-b border-[#dbdfe6] dark:border-gray-700 flex justify-between items-center bg-gray-50 dark:bg-gray-800/50">
                        <h3 class="font-bold text-lg text-[#111318] dark:text-white">Solicitudes Pendientes</h3>
                        <span class="px-3 py-1 bg-yellow-100 dark:bg-yellow-900/30 text-yellow-800 dark:text-yellow-300 rounded-full text-xs font-bold"><%= (lista != null) ? lista.size() : 0 %> Pendientes</span>
                    </div>

                    <div class="overflow-x-auto">
                        <table class="w-full text-left text-sm">
                            <thead class="bg-gray-50 dark:bg-gray-800/50 text-gray-600 dark:text-gray-300 font-medium border-b dark:border-gray-700">
                                <tr>
                                    <th class="px-6 py-4">Docente</th>
                                    <th class="px-6 py-4">Día</th>
                                    <th class="px-6 py-4">Horario</th>
                                    <th class="px-6 py-4">Turno</th>
                                    <th class="px-6 py-4">Estado</th>
                                    <th class="px-6 py-4 text-center">Acciones</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-gray-100 dark:divide-gray-700">
                                <% if (lista != null && !lista.isEmpty()) { 
                                    for (Disponibilidad d : lista) { %>
                                    <tr class="hover:bg-gray-50 dark:hover:bg-gray-800/50 text-gray-700 dark:text-gray-300">
                                        <td class="px-6 py-4 font-bold text-primary dark:text-blue-400"><%= d.getNombreProfesor() %></td>
                                        <td class="px-6 py-4"><%= d.getDiaSemana() %></td>
                                        <td class="px-6 py-4"><%= d.getHoraInicio() %> - <%= d.getHoraFin() %></td>
                                        <td class="px-6 py-4">
                                            <span class="px-2 py-1 rounded bg-blue-100 dark:bg-blue-900/30 text-blue-800 dark:text-blue-300 text-xs font-bold"><%= d.getTurnoNombre() %></span>
                                        </td>
                                        
                                        <td class="px-6 py-4">
                                            <span class="px-2 py-1 rounded bg-yellow-100 dark:bg-yellow-900/30 text-yellow-800 dark:text-yellow-300 text-xs font-bold border border-yellow-300 dark:border-yellow-700">
                                                PENDIENTE
                                            </span>
                                        </td>

                                        <td class="px-6 py-4 text-center">
                                            <div class="flex justify-center gap-2">
                                                <a href="AdminDisponibilidadServlet?accion=aprobar&id=<%= d.getId() %>" 
                                                   onclick="return confirm('¿Aprobar solicitud?')"
                                                   class="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors shadow-sm flex items-center gap-2 text-xs font-bold uppercase tracking-wide"
                                                   style="text-decoration: none;">
                                                    <i class="fas fa-check"></i> APROBAR
                                                </a>
                                                
                                                <button onclick="rechazar(<%= d.getId() %>)"
                                                        class="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors shadow-sm flex items-center gap-2 text-xs font-bold uppercase tracking-wide">
                                                    <i class="fas fa-times"></i> RECHAZAR
                                                </button>
                                            </div>
                                        </td>
                                    </tr>
                                <% } } else { %>
                                    <tr><td colspan="6" class="px-6 py-12 text-center text-gray-500 dark:text-gray-400">No hay solicitudes pendientes.</td></tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </main>
    </div>
</body>
</html>