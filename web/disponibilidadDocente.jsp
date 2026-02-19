<%@page import="modelo.Profesor"%>
<%@page import="java.util.List"%>
<%@page import="modelo.Disponibilidad"%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // ANTI-CACHÉ: Fuerza datos frescos siempre
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
    
    Profesor docente = (Profesor) session.getAttribute("docente");
    if (docente == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    
    List<Disponibilidad> lista = (List<Disponibilidad>) request.getAttribute("listaHorarios");
    String mensaje = (String) request.getAttribute("mensaje");
    String tipoMensaje = (String) request.getAttribute("tipoMensaje");
%>
<!DOCTYPE html>
<html lang="es"> <!-- QUITADO class="light" -->
<head>
    <script>
        // Detectar tema ANTES de renderizar
        (function() {
            function getCookie(name) {
                const match = document.cookie.match(new RegExp('(^| )' + name + '=([^;]+)'));
                return match ? match[2] : null;
            }
            if (getCookie('theme') === 'dark') {
                document.documentElement.classList.add('dark');
            }
        })();
    </script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mi Disponibilidad - San Antonio</title>
    
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Lexend:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    
    <script>
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        "primary": "#135bec",
                        "background-light": "#f6f6f8",
                        "background-dark": "#101622",
                    },
                    fontFamily: { "display": ["Lexend"] },
                },
            },
        }
    </script>
</head>
<body class="bg-background-light dark:bg-background-dark text-gray-800 dark:text-gray-200">
    <div class="flex h-screen overflow-hidden">
        <!-- Sidebar - INCLUIDO -->
        <jsp:include page="includes/sidebarDocente.jsp" />
    
        <main class="flex-1 flex flex-col overflow-y-auto">
            <!-- Header - INCLUIDO -->
            <% request.setAttribute("pageTitle", "Mi Disponibilidad"); %>
            <jsp:include page="includes/header.jsp" />
            
            <!-- Contenido -->
            <div class="p-8">
                <!-- Alertas -->
                <% if (mensaje != null) { %>
                    <div class="mb-6 p-4 rounded-lg border-l-4 <%= tipoMensaje.equals("success") ? "bg-green-50 dark:bg-green-900/30 border-green-500 text-green-700 dark:text-green-300" : "bg-red-50 dark:bg-red-900/30 border-red-500 text-red-700 dark:text-red-300" %>">
                        <div class="flex items-center gap-2">
                            <i class="fas <%= tipoMensaje.equals("success") ? "fa-check-circle" : "fa-exclamation-circle" %>"></i>
                            <span><%= mensaje %></span>
                        </div>
                    </div>
                <% } %>

                <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                    <!-- Formulario -->
                    <div class="lg:col-span-1">
                        <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 p-6">
                            <h2 class="text-lg font-bold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
                                <i class="fas fa-plus-circle text-primary"></i>
                                Registrar / Editar Horario
                            </h2>
                            <form action="DisponibilidadServlet" method="POST" class="space-y-4">
                                <input type="hidden" name="accion" id="accion" value="guardar">
                                <input type="hidden" name="id" id="idDisponibilidad"> 
                                
                                <div>
                                    <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">Día de la Semana</label>
                                    <select name="cboDia" id="cboDia" class="w-full rounded-lg border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white focus:border-primary focus:ring focus:ring-primary/20" required>
                                        <option value="">Seleccione...</option>
                                        <option value="LUNES">Lunes</option>
                                        <option value="MARTES">Martes</option>
                                        <option value="MIERCOLES">Miércoles</option>
                                        <option value="JUEVES">Jueves</option>
                                        <option value="VIERNES">Viernes</option>
                                    </select>
                                </div>
                                
                                <div>
                                    <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">Turno</label>
                                    <select name="cboTurno" id="cboTurno" class="w-full rounded-lg border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white focus:border-primary focus:ring focus:ring-primary/20" required>
                                        <option value="">Seleccione...</option>
                                        <option value="1">Mañana</option>
                                        <option value="2">Tarde</option>
                                    </select>
                                </div>

                                <div class="grid grid-cols-2 gap-4">
                                    <div>
                                        <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">Hora Inicio</label>
                                        <input type="time" name="txtInicio" id="txtInicio" class="w-full rounded-lg border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white focus:border-primary focus:ring focus:ring-primary/20" required>
                                    </div>
                                    <div>
                                        <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2">Hora Fin</label>
                                        <input type="time" name="txtFin" id="txtFin" class="w-full rounded-lg border-gray-300 dark:border-gray-600 dark:bg-gray-700 dark:text-white focus:border-primary focus:ring focus:ring-primary/20" required>
                                    </div>
                                </div>

                                <button type="submit" id="btnGuardar" class="w-full bg-primary hover:bg-blue-700 text-white font-semibold py-3 px-4 rounded-lg transition-colors flex items-center justify-center gap-2">
                                    <i class="fas fa-save"></i>
                                    Guardar Disponibilidad
                                </button>
                            </form>
                        </div>
                    </div>

                    <!-- Tabla de Horarios -->
                    <div class="lg:col-span-2">
                        <div class="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-200 dark:border-gray-700 overflow-hidden">
                            <div class="p-4 bg-gray-50 dark:bg-gray-700 border-b border-gray-200 dark:border-gray-600 flex items-center justify-between">
                                <h2 class="text-lg font-bold text-gray-900 dark:text-white flex items-center gap-2">
                                    <i class="fas fa-table text-primary"></i>
                                    Mis Horarios Registrados
                                </h2>
                                <span class="px-3 py-1 bg-white dark:bg-gray-600 border border-gray-300 dark:border-gray-500 rounded-full text-sm font-medium text-gray-700 dark:text-gray-200">
                                    <%= (lista != null) ? lista.size() : 0 %> Registros
                                </span>
                            </div>
                            <div class="overflow-x-auto">
                                <table class="w-full">
                                    <thead class="bg-gray-50 dark:bg-gray-700 border-b border-gray-200 dark:border-gray-600">
                                        <tr class="text-sm text-gray-600 dark:text-gray-300 uppercase tracking-wide">
                                            <th class="px-6 py-3 text-left font-semibold">Día</th>
                                            <th class="px-6 py-3 text-left font-semibold">Turno</th>
                                            <th class="px-6 py-3 text-left font-semibold">Horario</th>
                                            <th class="px-6 py-3 text-left font-semibold">Estado</th>
                                            <th class="px-6 py-3 text-center font-semibold">Acciones</th>
                                        </tr>
                                    </thead>
                                    <tbody class="divide-y divide-gray-200 dark:divide-gray-700">
                                        <% 
                                            if (lista != null && !lista.isEmpty()) {
                                                for (Disponibilidad d : lista) { 
                                                    String estadoLimpio = (d.getEstado() != null) ? d.getEstado().trim().toUpperCase() : "PENDIENTE";
                                                    boolean esRechazado = "RECHAZADO".equals(estadoLimpio);
                                                    boolean esAprobado = "APROBADO".equals(estadoLimpio);
                                        %>
                                        <tr class="hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors">
                                            <td class="px-6 py-4 font-bold text-gray-900 dark:text-white"><%= d.getDiaSemana() %></td>
                                            <td class="px-6 py-4 text-gray-600 dark:text-gray-300"><%= d.getTurnoNombre() %></td>
                                            <td class="px-6 py-4">
                                                <div class="flex items-center gap-2 text-gray-700 dark:text-gray-300">
                                                    <i class="fas fa-clock text-primary"></i>
                                                    <%= d.getHoraInicio() %> - <%= d.getHoraFin() %>
                                                </div>
                                            </td>
                                            <td class="px-6 py-4">
                                                <% if (esAprobado) { %>
                                                    <span class="inline-flex items-center gap-1 px-3 py-1 bg-green-100 dark:bg-green-900/30 text-green-800 dark:text-green-300 rounded-full text-sm font-semibold">
                                                        <i class="fas fa-check-circle"></i> APROBADO
                                                    </span>
                                                <% } else if (esRechazado) { %>
                                                    <div class="flex flex-col gap-1">
                                                        <span class="inline-flex items-center gap-1 px-3 py-1 bg-red-100 dark:bg-red-900/30 text-red-800 dark:text-red-300 rounded-full text-sm font-semibold w-fit">
                                                            <i class="fas fa-times-circle"></i> RECHAZADO
                                                        </span>
                                                        <button onclick="verMotivo('<%= d.getObservaciones() != null ? d.getObservaciones().replace("'", "\\'") : "" %>')" class="text-xs text-red-600 dark:text-red-400 hover:text-red-800 underline text-left">
                                                            <i class="fas fa-info-circle"></i> Ver motivo
                                                        </button>
                                                    </div>
                                                <% } else { %>
                                                    <span class="inline-flex items-center gap-1 px-3 py-1 bg-yellow-100 dark:bg-yellow-900/30 text-yellow-800 dark:text-yellow-300 rounded-full text-sm font-semibold">
                                                        <i class="fas fa-clock"></i> PENDIENTE
                                                    </span>
                                                <% } %>
                                            </td>
                                            <td class="px-6 py-4 text-center">
                                                <% if (esAprobado) { %>
                                                    <span class="inline-flex items-center gap-1 px-3 py-1 bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-300 rounded-lg text-sm">
                                                        <i class="fas fa-lock"></i> Finalizado
                                                    </span>
                                                <% } else { %>
                                                    <div class="flex items-center justify-center gap-2">
                                                        <button type="button" 
                                                                class="px-3 py-1.5 <%= esRechazado ? "bg-primary hover:bg-blue-700 text-white" : "bg-gray-200 dark:bg-gray-600 text-gray-400 dark:text-gray-500 cursor-not-allowed" %> rounded-lg text-sm font-medium transition-colors"
                                                                <%= !esRechazado ? "disabled" : "" %>
                                                                onclick="editar(<%= d.getId() %>, '<%= d.getDiaSemana() %>', <%= d.getTurnoId() %>, '<%= d.getHoraInicio() %>', '<%= d.getHoraFin() %>')">
                                                            <i class="fas fa-edit"></i>
                                                        </button>
                                                        <a href="DisponibilidadServlet?accion=eliminar&id=<%= d.getId() %>" 
                                                           class="px-3 py-1.5 bg-red-500 hover:bg-red-600 text-white rounded-lg text-sm font-medium transition-colors"
                                                           onclick="return confirm('¿Estás seguro de cancelar esta solicitud?');">
                                                            <i class="fas fa-trash"></i>
                                                        </a>
                                                    </div>
                                                <% } %>
                                            </td>
                                        </tr>
                                        <% 
                                            } 
                                        } else { 
                                        %>
                                        <tr>
                                            <td colspan="5" class="px-6 py-12 text-center text-gray-500 dark:text-gray-400">
                                                <i class="fas fa-info-circle text-4xl mb-3 block text-gray-300 dark:text-gray-600"></i>
                                                <p class="text-lg font-medium">No tienes horarios registrados aún</p>
                                                <p class="text-sm">Usa el formulario de la izquierda para registrar tu disponibilidad</p>
                                            </td>
                                        </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>
    
    <script>
        function verMotivo(motivo) {
            if(!motivo || motivo === 'null' || motivo.trim() === '') {
                alert("No se especificó un motivo detallado.");
            } else {
                alert("🛑 MOTIVO DEL RECHAZO:\n\n" + motivo);
            }
        }

        function editar(id, dia, turnoId, inicio, fin) {
            document.getElementById("idDisponibilidad").value = id;
            document.getElementById("cboDia").value = dia;
            document.getElementById("cboTurno").value = turnoId;
            document.getElementById("txtInicio").value = inicio;
            document.getElementById("txtFin").value = fin;
            document.getElementById("accion").value = "actualizar"; 

            let btn = document.getElementById("btnGuardar");
            btn.innerHTML = '<i class="fas fa-save mr-2"></i>Corregir y Guardar';
            btn.classList.remove("bg-primary");
            btn.classList.add("bg-yellow-500");
            
            window.scrollTo({ top: 0, behavior: 'smooth' });
            alert("MODO EDICIÓN ACTIVADO:\nCorrige los datos en el formulario superior y guarda para re-enviar la solicitud.");
        }
    </script>
</body>
</html>