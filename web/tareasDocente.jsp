<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Tarea, modelo.Curso, modelo.Profesor, java.util.List" %>

<%
    // Lógica de Sesión y Datos
    Profesor docente = (Profesor) session.getAttribute("docente");
    Curso curso = (Curso) request.getAttribute("curso");
    List<Tarea> lista = (List<Tarea>) request.getAttribute("lista");
    
    // Validar sesión
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
    <title>Gestión de Tareas - <%= curso.getNombre() %></title>
    <style>
        /* Estilos adicionales para la tabla de tareas */
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
        
        .status-badge-custom {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 600;
        }
        
        .status-active {
            background-color: #e6f7ee;
            color: #0d8a46;
        }
        
        .dark .status-active {
            background-color: #0d8a46;
            color: white;
        }
        
        .status-inactive {
            background-color: #fce8e6;
            color: #c53030;
        }
        
        .dark .status-inactive {
            background-color: #c53030;
            color: white;
        }
        
        .btn-icon {
            width: 32px;
            height: 32px;
            border-radius: 6px;
            display: flex;
            align-items: center;
            justify-content: center;
            border: none;
            cursor: pointer;
            transition: all 0.2s;
            text-decoration: none;
        }
        
        .btn-edit {
            background-color: #e0eaff;
            color: #0d6efd;
        }
        
        .btn-edit:hover {
            background-color: #0d6efd;
            color: white;
        }
        
        .btn-delete {
            background-color: #ffe5e7;
            color: #d63345;
        }
        
        .btn-delete:hover {
            background-color: #d63345;
            color: white;
        }
        
        .btn-add {
            background-color: #0d6efd;
            color: white;
            padding: 10px 20px;
            border-radius: 6px;
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
        
        .actions-cell {
            display: flex;
            gap: 8px;
        }
        
        .countdown-timer {
            min-width: 130px;
            font-weight: normal;
            font-size: 13px;
            padding: 6px 12px;
            border-radius: 20px;
        }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark text-[#111318] dark:text-white min-h-screen">
    
    <div class="flex h-screen overflow-hidden">
        <!-- Sidebar -->
        <%@ include file="includes/sidebarDocente.jsp" %>
        
        <main class="flex-1 flex flex-col overflow-y-auto">
            <!-- Header -->
            <% request.setAttribute("pageTitle", "Gestión de Tareas - " + curso.getNombre()); %>
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
                
                <!-- Encabezado -->
                <div class="bg-gradient-to-r from-primary to-blue-600 rounded-xl p-6 mb-8 text-white shadow-lg">
                    <div class="relative z-10">
                        <h2 class="text-2xl font-bold">Gestión de Tareas</h2>
                        <p class="text-blue-100 mt-1">Curso: <strong><%= curso.getNombre() %> - <%= curso.getGradoNombre() %></strong></p>
                    </div>
                </div>
                
                <!-- Acciones -->
                <div class="flex justify-between items-center mb-6">
                    <h3 class="text-xl font-bold text-[#111318] dark:text-white">Listado de Tareas</h3>
                    <div class="flex gap-3">
                        <a href="docenteDashboard.jsp" class="px-4 py-2 bg-gray-500 hover:bg-gray-600 text-white rounded-lg transition-colors flex items-center gap-2">
                            <i class="fas fa-arrow-left"></i> Volver
                        </a>
                        <a href="TareaServlet?accion=registrar&curso_id=<%= curso.getId() %>" class="px-4 py-2 bg-primary hover:bg-blue-700 text-white rounded-lg transition-colors flex items-center gap-2">
                            <i class="fas fa-plus"></i> Registrar Tarea
                        </a>
                    </div>
                </div>
                
                <!-- Tabla -->
                <div class="table-container">
                    <div class="overflow-x-auto">
                        <table class="custom-table">
                            <thead>
                                <tr>
                                    <th>NOMBRE</th>
                                    <th>DESCRIPCIÓN</th>
                                    <th>FECHA DE ENTREGA</th>
                                    <th class="text-center">TIEMPO RESTANTE</th>
                                    <th>ESTADO</th>
                                    <th>ACCIONES</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (lista != null && !lista.isEmpty()) { 
                                    for (Tarea t : lista) { 
                                        boolean esFinalizado = "FINALIZADO".equals(t.getEstadoCalculado());
                                %>
                                <tr>
                                    <td>
                                        <div class="flex items-center gap-3">
                                            <div class="bg-blue-100 dark:bg-blue-900 rounded-lg p-2 text-primary dark:text-blue-300">
                                                <i class="fas fa-book-open"></i>
                                            </div>
                                            <div>
                                                <div class="font-bold"><%= t.getNombre() %></div>
                                                <small class="text-gray-500 dark:text-gray-400"><%= t.getTipo() != null ? t.getTipo() : "" %></small>
                                            </div>
                                        </div>
                                    </td>
                                    <td><%= t.getDescripcion() %></td>
                                    
                                    <td>
                                        <div class="flex items-center gap-2 text-primary">
                                            <i class="far fa-calendar-alt"></i>
                                            <span>
                                                <%= (t.getFechaEntrega() != null && !t.getFechaEntrega().equals("null")) ? t.getFechaEntrega() : "Sin fecha" %>
                                                <br>
                                                <small class="text-gray-500 dark:text-gray-400">
                                                    <i class="far fa-clock"></i> <%= (t.getHoraEntrega() != null) ? t.getHoraEntrega() : "23:59:59" %>
                                                </small>
                                            </span>
                                        </div>
                                    </td>

                                    <td class="text-center">
                                        <% if (esFinalizado) { %>
                                            <span class="inline-flex items-center gap-1 px-3 py-1 bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200 rounded-full text-xs font-semibold">
                                                <i class="fas fa-exclamation-triangle"></i> Finalizado
                                            </span>
                                        <% } else { %>
                                            <div class="countdown-timer inline-flex items-center gap-1 px-3 py-1 bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-200 rounded-full text-xs font-semibold"
                                                 data-fecha="<%= t.getFechaEntrega() %>" 
                                                 data-hora="<%= t.getHoraEntrega() != null ? t.getHoraEntrega() : "23:59:59" %>">
                                                 <i class="fas fa-spinner fa-spin"></i>
                                            </div>
                                        <% } %>
                                    </td>

                                    <td>
                                        <% if (esFinalizado || !t.isActivo()) { %>
                                            <span class="status-badge-custom status-inactive">Inactivo</span>
                                        <% } else { %>
                                            <span class="status-badge-custom status-active">Activo</span>
                                        <% } %>
                                    </td>
                                    <td>
                                        <div class="actions-cell">
                                            <a href="TareaServlet?accion=editar&id=<%= t.getId() %>" class="btn-icon btn-edit" title="Editar">
                                                <i class="fas fa-pencil-alt"></i>
                                            </a>

                                            <form action="TareaServlet" method="GET" style="display:inline;" onsubmit="return confirm('¿Estás seguro de eliminar esta tarea?');">
                                                <input type="hidden" name="accion" value="eliminar">
                                                <input type="hidden" name="id" value="<%= t.getId() %>">
                                                <button type="submit" class="btn-icon btn-delete" title="Eliminar">
                                                    <i class="fas fa-trash-alt"></i>
                                                </button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                                <% } 
                                   } else { %>
                                <tr>
                                    <td colspan="6" class="text-center py-12">
                                        <div class="text-gray-500 dark:text-gray-400">
                                            <i class="fas fa-folder-open fa-3x mb-3"></i>
                                            <p class="text-lg">No hay tareas registradas para este curso.</p>
                                        </div>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function actualizarRelojes() {
            const ahora = new Date().getTime();
            const relojes = document.querySelectorAll('.countdown-timer');

            relojes.forEach(reloj => {
                const fecha = reloj.getAttribute('data-fecha');
                const hora = reloj.getAttribute('data-hora');
                
                const fila = reloj.closest('tr');
                const badgeEstado = fila ? fila.querySelector('.status-badge-custom') : null;

                if (!fecha || fecha === 'null') {
                    reloj.innerHTML = '-';
                    return;
                }

                const horaFull = (hora && hora.length === 5) ? hora + ":00" : (hora ? hora : "23:59:00");
                const fechaISO = fecha + "T" + horaFull;
                const vencimiento = new Date(fechaISO).getTime();
                
                if (isNaN(vencimiento)) {
                    reloj.innerHTML = "Fecha Inválida";
                    return;
                }

                const distancia = vencimiento - ahora;

                if (distancia < 0) {
                    reloj.className = 'countdown-timer inline-flex items-center gap-1 px-3 py-1 bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200 rounded-full text-xs font-semibold';
                    reloj.innerHTML = '<i class="fas fa-exclamation-triangle"></i> Tiempo Finalizado';
                    
                    if (badgeEstado) {
                        badgeEstado.className = 'status-badge-custom status-inactive';
                        badgeEstado.innerText = 'Inactivo';
                    }

                } else {
                    const dias = Math.floor(distancia / (1000 * 60 * 60 * 24));
                    const horas = Math.floor((distancia % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                    const minutos = Math.floor((distancia % (1000 * 60 * 60)) / (1000 * 60));
                    const segundos = Math.floor((distancia % (1000 * 60)) / 1000);

                    let texto = "";
                    let claseColor = "bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-200";
                    
                    if (dias > 0) {
                        texto = dias + "d " + horas + "h " + minutos + "m";
                        claseColor = "bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200";
                    } else {
                        texto = (horas < 10 ? "0"+horas : horas) + ":" + 
                                (minutos < 10 ? "0"+minutos : minutos) + ":" + 
                                (segundos < 10 ? "0"+segundos : segundos);
                        
                        if (horas < 1) {
                            claseColor = "bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200";
                        } else {
                            claseColor = "bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200";
                        }
                    }
                    
                    reloj.className = `countdown-timer inline-flex items-center gap-1 px-3 py-1 rounded-full text-xs font-semibold ${claseColor}`;
                    reloj.innerHTML = '<i class="far fa-clock"></i> ' + texto;
                }
            });
        }

        setInterval(actualizarRelojes, 1000);
        actualizarRelojes();
    </script>
</body>
</html>