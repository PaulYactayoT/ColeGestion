<%-- 
    Document   : historialAsistencia
    Author     : milag
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="modelo.Curso, java.util.*" %>
<%
    String rol = (String) session.getAttribute("rol");
    if (rol == null || (!rol.equals("admin") && !rol.equals("docente"))) {
        response.sendRedirect("login.jsp");
        return;
    }

    Curso curso = (Curso) request.getAttribute("curso");
    List<Map<String, Object>> fechas = (List<Map<String, Object>>) request.getAttribute("fechas");
    if (fechas == null) fechas = new ArrayList<>();

    String mensaje = (String) session.getAttribute("mensaje");
    String error   = (String) session.getAttribute("error");
    session.removeAttribute("mensaje");
    session.removeAttribute("error");

    // Calcular totales globales
    int totalSesiones  = fechas.size();
    int totalRegistros = 0, totalPresentes = 0, totalAusentes = 0, totalTardanzas = 0;
    for (Map<String, Object> f : fechas) {
        totalRegistros  += (Integer) f.get("total");
        totalPresentes  += (Integer) f.get("presentes");
        totalAusentes   += (Integer) f.get("ausentes");
        totalTardanzas  += (Integer) f.get("tardanzas");
    }
    double pctGlobal = totalRegistros > 0 ? ((totalPresentes + totalTardanzas) * 100.0 / totalRegistros) : 0;
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <script>
        (function() {
            function getCookie(n) { const m = document.cookie.match(new RegExp('(^| )' + n + '=([^;]+)')); return m ? m[2] : null; }
            if (getCookie('theme') === 'dark') document.documentElement.classList.add('dark');
        })();
    </script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Historial de Asistencias</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms"></script>
    <link href="https://fonts.googleapis.com/css2?family=Lexend:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <script>
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: { "primary": "#135bec", "background-light": "#f6f6f8", "background-dark": "#101622" },
                    fontFamily: { "display": ["Lexend"] },
                    borderRadius: { "DEFAULT": "0.25rem", "lg": "0.5rem", "xl": "0.75rem", "full": "9999px" }
                }
            }
        }
    </script>
    <style>
        body { font-family: 'Lexend', sans-serif; }
        .material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24; }
        .fila:hover { background: rgba(19,91,236,0.04); }
        .dark .fila:hover { background: rgba(19,91,236,0.1); }
        .barra { height: 8px; border-radius: 9999px; background: #e5e7eb; overflow: hidden; }
        .dark .barra { background: #374151; }
        .barra-fill { height: 100%; border-radius: 9999px; }

        /* Estilo para el input date */
        input[type="date"] {
            color-scheme: light;
        }
        .dark input[type="date"] {
            color-scheme: dark;
        }
        input[type="date"]::-webkit-calendar-picker-indicator {
            cursor: pointer;
            border-radius: 4px;
            padding: 2px;
            opacity: 0.6;
        }
        input[type="date"]::-webkit-calendar-picker-indicator:hover {
            opacity: 1;
            background-color: rgba(19,91,236,0.1);
        }

        /* Animación para filas filtradas */
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-4px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        .fila-visible { animation: fadeIn 0.2s ease; }

        /* Highlight de fila seleccionada */
        .fila-destacada {
            background: rgba(19,91,236,0.06) !important;
            border-left: 3px solid #135bec;
        }
        .dark .fila-destacada {
            background: rgba(19,91,236,0.15) !important;
        }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark transition-colors duration-300">
<div class="flex h-screen overflow-hidden">
    <jsp:include page="includes/sidebarDocente.jsp" />
    <main class="flex-1 flex flex-col overflow-y-auto">
        <% request.setAttribute("pageTitle", "Historial de Asistencias"); %>
        <jsp:include page="includes/header.jsp" />

        <div class="flex-1 px-8 py-8 max-w-7xl mx-auto w-full">

            <!-- Alertas -->
            <% if (mensaje != null) { %>
                <div class="flex items-center gap-3 bg-green-50 dark:bg-green-900/20 border border-green-200 rounded-xl p-4 mb-6">
                    <span class="material-symbols-outlined text-green-600">check_circle</span>
                    <span class="text-green-800 dark:text-green-300"><%= mensaje %></span>
                </div>
            <% } %>
            <% if (error != null) { %>
                <div class="flex items-center gap-3 bg-red-50 dark:bg-red-900/20 border border-red-200 rounded-xl p-4 mb-6">
                    <span class="material-symbols-outlined text-red-600">error</span>
                    <span class="text-red-800 dark:text-red-300"><%= error %></span>
                </div>
            <% } %>

            <!-- Header -->
            <div class="bg-gradient-to-r from-primary to-blue-600 rounded-xl p-6 mb-8 text-white shadow-lg">
                <div class="flex flex-wrap items-center justify-between gap-4">
                    <div class="flex items-center gap-4">
                        <div class="bg-white/20 rounded-lg p-3">
                            <span class="material-symbols-outlined text-3xl">history</span>
                        </div>
                        <div>
                            <h1 class="text-2xl font-bold">Historial de Asistencias</h1>
                            <p class="text-blue-100 mt-1 text-lg font-medium">
                                <%= curso != null ? curso.getNombre() : "" %>
                                <% if (curso != null && curso.getGradoNombre() != null) { %>
                                    <span class="text-blue-200 text-base font-normal">— <%= curso.getGradoNombre() %></span>
                                <% } %>
                            </p>
                        </div>
                    </div>
                    <div class="flex gap-3 flex-wrap">
                        <a href="AsistenciaServlet?accion=registrar&curso_id=<%= curso != null ? curso.getId() : "" %>"
                           class="flex items-center gap-2 px-5 py-2.5 bg-white text-primary font-semibold rounded-lg hover:bg-blue-50 transition-colors shadow">
                            <span class="material-symbols-outlined text-sm">add_circle</span>
                            Nueva Asistencia
                        </a>
                        <a href="AsistenciaServlet"
                           class="flex items-center gap-2 px-5 py-2.5 bg-white/20 hover:bg-white/30 text-white font-medium rounded-lg transition-colors">
                            <span class="material-symbols-outlined text-sm">arrow_back</span>
                            Volver
                        </a>
                    </div>
                </div>
            </div>

            <% if (!fechas.isEmpty()) { %>

            <!-- Tarjetas de resumen -->
            <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
                <div class="bg-white dark:bg-gray-800 rounded-xl p-5 shadow border border-gray-100 dark:border-gray-700 text-center">
                    <p class="text-4xl font-bold text-primary mb-1"><%= totalSesiones %></p>
                    <p class="text-sm text-gray-500 dark:text-gray-400">Sesiones</p>
                </div>
                <div class="bg-white dark:bg-gray-800 rounded-xl p-5 shadow border border-gray-100 dark:border-gray-700 text-center">
                    <p class="text-4xl font-bold text-green-600 mb-1"><%= totalPresentes %></p>
                    <p class="text-sm text-gray-500 dark:text-gray-400">Presentes</p>
                </div>
                <div class="bg-white dark:bg-gray-800 rounded-xl p-5 shadow border border-gray-100 dark:border-gray-700 text-center">
                    <p class="text-4xl font-bold text-red-500 mb-1"><%= totalAusentes %></p>
                    <p class="text-sm text-gray-500 dark:text-gray-400">Ausentes</p>
                </div>
                <div class="bg-white dark:bg-gray-800 rounded-xl p-5 shadow border border-gray-100 dark:border-gray-700 text-center">
                    <p class="text-4xl font-bold mb-1"
                       style="color: <%= pctGlobal >= 80 ? "#16a34a" : (pctGlobal >= 60 ? "#f59e0b" : "#ef4444") %>">
                        <%= String.format("%.0f", pctGlobal) %>%
                    </p>
                    <p class="text-sm text-gray-500 dark:text-gray-400">Asistencia global</p>
                </div>
            </div>

            <!-- Filtro por Calendario -->
            <div class="bg-white dark:bg-gray-800 rounded-xl shadow p-4 mb-4 border border-gray-100 dark:border-gray-700">
                <div class="flex flex-wrap items-center gap-3">
                    <span class="flex items-center gap-2 text-sm font-medium text-gray-600 dark:text-gray-300">
                        <span class="material-symbols-outlined text-primary" style="font-size:20px">calendar_month</span>
                        Filtrar por fecha:
                    </span>

                    <input type="date" id="filtroFecha"
                           onchange="filtrarPorFecha()"
                           class="px-3 py-2 border border-gray-200 dark:border-gray-600 rounded-lg text-sm text-gray-700 dark:text-gray-200 bg-gray-50 dark:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-primary/30 focus:border-primary transition-all cursor-pointer">

                    <button onclick="limpiarFiltro()" id="btnLimpiar"
                            class="hidden items-center gap-1.5 px-3 py-2 bg-red-50 dark:bg-red-900/20 text-red-600 dark:text-red-400 rounded-lg text-xs font-medium hover:bg-red-100 dark:hover:bg-red-900/40 transition-colors border border-red-100 dark:border-red-800">
                        <span class="material-symbols-outlined" style="font-size:15px">close</span>
                        Limpiar
                    </button>

                    <span id="resultadoFiltro" class="hidden text-xs px-3 py-1.5 bg-blue-50 dark:bg-blue-900/20 text-blue-600 dark:text-blue-400 rounded-full border border-blue-100 dark:border-blue-800 font-medium"></span>
                </div>
            </div>

            <!-- Tabla -->
            <div class="bg-white dark:bg-gray-800 rounded-xl shadow overflow-hidden border border-gray-100 dark:border-gray-700">
                <div class="bg-gray-900 dark:bg-gray-950 px-6 py-4 flex items-center justify-between">
                    <span class="text-white font-semibold flex items-center gap-2">
                        <span class="material-symbols-outlined text-sm">calendar_month</span>
                        Sesiones registradas
                    </span>
                    <span class="text-gray-400 text-sm" id="contadorSesiones"><%= totalSesiones %> sesión<%= totalSesiones != 1 ? "es" : "" %></span>
                </div>
                <div class="overflow-x-auto">
                    <table class="w-full" id="tabla">
                        <thead class="bg-gray-50 dark:bg-gray-700 border-b border-gray-200 dark:border-gray-600">
                            <tr>
                                <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase">Fecha</th>
                                <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase">Hora</th>
                                <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase">Turno</th>
                                <th class="px-6 py-3 text-center text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase">Total</th>
                                <th class="px-6 py-3 text-center text-xs font-semibold text-green-600 uppercase">Presentes</th>
                                <th class="px-6 py-3 text-center text-xs font-semibold text-orange-500 uppercase">Tardanzas</th>
                                <th class="px-6 py-3 text-center text-xs font-semibold text-red-500 uppercase">Ausentes</th>
                                <th class="px-6 py-3 text-left text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase">Asistencia</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100 dark:divide-gray-700">
                        <% for (Map<String, Object> f : fechas) {
                            int pct = Integer.parseInt(f.get("porcentaje").toString());
                            String color = pct >= 80 ? "#16a34a" : (pct >= 60 ? "#f59e0b" : "#ef4444");
                        %>
                            <tr class="fila transition-colors" data-fecha="<%= f.get("fechaStr") %>">
                                <td class="px-6 py-4">
                                    <div class="flex items-center gap-2">
                                        <span class="material-symbols-outlined text-primary" style="font-size:18px">calendar_today</span>
                                        <span class="font-semibold text-gray-900 dark:text-white"><%= f.get("fechaStr") %></span>
                                    </div>
                                </td>
                                <td class="px-6 py-4 text-gray-600 dark:text-gray-300 text-sm">
                                    <i class="fas fa-clock text-gray-400 mr-1"></i><%= f.get("horaStr") %>
                                </td>
                                <td class="px-6 py-4">
                                    <span class="px-2 py-1 bg-blue-100 dark:bg-blue-900/30 text-blue-800 dark:text-blue-300 rounded-full text-xs font-medium">
                                        <%= f.get("turnoNombre") != null ? f.get("turnoNombre") : "—" %>
                                    </span>
                                </td>
                                <td class="px-6 py-4 text-center font-bold text-gray-700 dark:text-gray-200"><%= f.get("total") %></td>
                                <td class="px-6 py-4 text-center">
                                    <span class="px-3 py-1 bg-green-100 dark:bg-green-900/30 text-green-800 dark:text-green-300 rounded-full text-sm font-bold">
                                        <%= f.get("presentes") %>
                                    </span>
                                </td>
                                <td class="px-6 py-4 text-center">
                                    <span class="px-3 py-1 bg-orange-100 dark:bg-orange-900/30 text-orange-700 dark:text-orange-300 rounded-full text-sm font-bold">
                                        <%= f.get("tardanzas") %>
                                    </span>
                                </td>
                                <td class="px-6 py-4 text-center">
                                    <span class="px-3 py-1 bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-300 rounded-full text-sm font-bold">
                                        <%= f.get("ausentes") %>
                                    </span>
                                </td>
                                <td class="px-6 py-4" style="min-width:150px">
                                    <div class="flex items-center gap-2">
                                        <div class="flex-1 barra">
                                            <div class="barra-fill" style="width:<%= pct %>%; background:<%= color %>"></div>
                                        </div>
                                        <span class="text-sm font-bold" style="color:<%= color %>; min-width:38px"><%= pct %>%</span>
                                    </div>
                                </td>
                            </tr>
                        <% } %>
                        </tbody>
                    </table>

                    <!-- Mensaje sin resultados tras filtrar -->
                    <div id="sinResultados" class="hidden py-14 text-center">
                        <span class="material-symbols-outlined text-gray-300 dark:text-gray-600 block mb-3" style="font-size:56px">event_busy</span>
                        <p class="text-gray-500 dark:text-gray-400 font-medium">No hay sesiones en la fecha seleccionada.</p>
                        <button onclick="limpiarFiltro()" class="mt-4 text-sm text-primary hover:underline">Ver todas las sesiones</button>
                    </div>
                </div>
            </div>

            <% } else { %>
            <!-- Sin registros -->
            <div class="bg-white dark:bg-gray-800 rounded-xl shadow p-16 text-center border border-gray-100 dark:border-gray-700">
                <span class="material-symbols-outlined text-gray-300 dark:text-gray-600 mb-4 block" style="font-size:80px">event_busy</span>
                <h3 class="text-xl font-bold text-gray-500 dark:text-gray-400 mb-2">Sin asistencias registradas</h3>
                <p class="text-gray-400 dark:text-gray-500 mb-6">Aún no hay sesiones registradas para este curso.</p>
                <a href="AsistenciaServlet?accion=registrar&curso_id=<%= curso != null ? curso.getId() : "" %>"
                   class="inline-flex items-center gap-2 px-6 py-3 bg-primary hover:bg-blue-700 text-white font-semibold rounded-lg transition-colors">
                    <span class="material-symbols-outlined">add_circle</span>
                    Registrar primera asistencia
                </a>
            </div>
            <% } %>
        </div>
    </main>
</div>

<script>
    // Construir set de fechas disponibles para validar formato
    // Las fechas vienen en formato dd/MM/yyyy desde el servidor
    // El input type="date" devuelve yyyy-MM-dd, así que convertimos para comparar

    function parseFechaFila(strFecha) {
        // Acepta "dd/MM/yyyy" o "dd-MM-yyyy"
        const partes = strFecha.split(/[\/\-]/);
        if (partes.length !== 3) return null;
        // Puede venir como dd/MM/yyyy
        const [dd, mm, yyyy] = partes;
        return `${yyyy}-${mm.padStart(2,'0')}-${dd.padStart(2,'0')}`;
    }

    function filtrarPorFecha() {
        const inputVal = document.getElementById('filtroFecha').value; // yyyy-MM-dd
        const filas    = document.querySelectorAll('#tabla tbody tr.fila');
        const btnLimpiar      = document.getElementById('btnLimpiar');
        const resultadoSpan   = document.getElementById('resultadoFiltro');
        const sinResultados   = document.getElementById('sinResultados');
        const contadorSesiones = document.getElementById('contadorSesiones');

        if (!inputVal) {
            limpiarFiltro();
            return;
        }

        let visibles = 0;
        filas.forEach(tr => {
            const fechaFila = parseFechaFila(tr.dataset.fecha);
            if (fechaFila === inputVal) {
                tr.style.display = '';
                tr.classList.add('fila-visible', 'fila-destacada');
                visibles++;
            } else {
                tr.style.display = 'none';
                tr.classList.remove('fila-visible', 'fila-destacada');
            }
        });

        // Mostrar/ocultar mensaje sin resultados
        sinResultados.classList.toggle('hidden', visibles > 0);

        // Actualizar contador
        contadorSesiones.textContent = visibles + ' sesión' + (visibles !== 1 ? 'es' : '') + ' encontrada' + (visibles !== 1 ? 's' : '');

        // Mostrar badge de resultado
        resultadoSpan.textContent = visibles > 0
            ? visibles + (visibles === 1 ? ' sesión encontrada' : ' sesiones encontradas')
            : 'Sin resultados';
        resultadoSpan.classList.remove('hidden');

        // Mostrar botón limpiar
        btnLimpiar.classList.remove('hidden');
        btnLimpiar.classList.add('flex');
    }

    function limpiarFiltro() {
        document.getElementById('filtroFecha').value = '';
        const filas = document.querySelectorAll('#tabla tbody tr.fila');
        const totalSesiones = filas.length;

        filas.forEach(tr => {
            tr.style.display = '';
            tr.classList.remove('fila-visible', 'fila-destacada');
        });

        document.getElementById('sinResultados').classList.add('hidden');
        document.getElementById('resultadoFiltro').classList.add('hidden');
        document.getElementById('contadorSesiones').textContent =
            totalSesiones + ' sesión' + (totalSesiones !== 1 ? 'es' : '');

        const btn = document.getElementById('btnLimpiar');
        btn.classList.add('hidden');
        btn.classList.remove('flex');
    }
</script>
</body>
</html>
