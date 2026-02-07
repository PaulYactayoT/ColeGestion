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
%>

<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <title>Evaluación de Horarios | San Antonio</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Lexend:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    
    <script>
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: { colors: { "primary": "#135bec", "background-light": "#f6f6f8" }, fontFamily: { "display": ["Lexend"] } }
            }
        }
        
        // Script para rechazar con motivo
        function rechazar(id) {
            let motivo = prompt("Ingrese el motivo del rechazo:", "Cruce de horarios");
            if (motivo !== null && motivo.trim() !== "") {
                window.location.href = "AdminDisponibilidadServlet?accion=rechazar&id=" + id + "&observacion=" + encodeURIComponent(motivo);
            }
        }
    </script>
    <style>body { font-family: 'Lexend', sans-serif; }</style>
</head>
<body class="bg-background-light text-[#111318] min-h-screen">

    <div class="flex h-screen overflow-hidden">
        <aside class="w-64 flex-shrink-0 bg-white border-r border-[#dbdfe6] flex flex-col p-6">
            <div class="flex items-center gap-3 mb-8">
                <div class="bg-primary size-10 rounded-lg flex items-center justify-center text-white"><span class="material-symbols-outlined">school</span></div>
                <div><h1 class="text-lg font-bold">San Antonio</h1><p class="text-xs text-gray-500">Admin</p></div>
            </div>
            <nav class="flex flex-col gap-2">
                <a href="dashboard.jsp" class="flex items-center gap-3 px-3 py-2 rounded-lg text-gray-500 hover:bg-gray-100"><span class="material-symbols-outlined">dashboard</span> Dashboard</a>
                <a href="#" class="flex items-center gap-3 px-3 py-2 rounded-lg bg-yellow-50 text-yellow-700 font-medium border border-yellow-200"><i class="fas fa-calendar-check"></i> Aprobar Horarios</a>
            </nav>
        </aside>

        <main class="flex-1 flex flex-col overflow-y-auto">
            <div class="p-8 max-w-[1200px] mx-auto w-full">
                
                <% if (mensaje != null) { %>
                    <div class="mb-6 p-4 rounded-lg <%= tipoMensaje.equals("success") ? "bg-green-100 text-green-800" : "bg-red-100 text-red-800" %> flex items-center gap-3">
                        <span class="material-symbols-outlined"><%= tipoMensaje.equals("success") ? "check_circle" : "error" %></span>
                        <%= mensaje %>
                    </div>
                <% } %>

                <div class="bg-white rounded-xl border border-[#dbdfe6] shadow-sm overflow-hidden">
                    <div class="p-6 border-b border-[#dbdfe6] flex justify-between items-center bg-gray-50">
                        <h3 class="font-bold text-lg">Solicitudes Pendientes</h3>
                        <span class="px-3 py-1 bg-yellow-100 text-yellow-800 rounded-full text-xs font-bold"><%= (lista != null) ? lista.size() : 0 %> Pendientes</span>
                    </div>

                    <div class="overflow-x-auto">
                        <table class="w-full text-left text-sm">
                            <thead class="bg-gray-50 text-gray-600 font-medium border-b">
                                <tr>
                                    <th class="px-6 py-4">Docente</th>
                                    <th class="px-6 py-4">Día</th>
                                    <th class="px-6 py-4">Horario</th>
                                    <th class="px-6 py-4">Turno</th>
                                    <th class="px-6 py-4">Estado</th> <th class="px-6 py-4 text-center">Acciones</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-gray-100">
                                <% if (lista != null && !lista.isEmpty()) { 
                                    for (Disponibilidad d : lista) { %>
                                    <tr class="hover:bg-gray-50">
                                        <td class="px-6 py-4 font-bold text-primary"><%= d.getNombreProfesor() %></td>
                                        <td class="px-6 py-4"><%= d.getDiaSemana() %></td>
                                        <td class="px-6 py-4 text-gray-600"><%= d.getHoraInicio() %> - <%= d.getHoraFin() %></td>
                                        <td class="px-6 py-4">
                                            <span class="px-2 py-1 rounded bg-blue-100 text-blue-800 text-xs font-bold"><%= d.getTurnoNombre() %></span>
                                        </td>
                                        
                                        <td class="px-6 py-4">
                                            <span class="px-2 py-1 rounded bg-yellow-100 text-yellow-800 text-xs font-bold border border-yellow-300">
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
                                    <tr><td colspan="6" class="px-6 py-12 text-center text-gray-500">No hay solicitudes pendientes.</td></tr>
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