<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="modelo.*, java.util.*, java.time.*" %>
<%
    // Validar sesión
    String rol = (String) session.getAttribute("rol");
    if (rol == null || (!rol.equals("admin") && !rol.equals("docente"))) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Obtener datos que el Servlet pasa por request.setAttribute
    List<Curso> cursos = (List<Curso>) request.getAttribute("cursos");
    List<Alumno> alumnos = (List<Alumno>) request.getAttribute("alumnos");
    Curso cursoSeleccionado = (Curso) request.getAttribute("cursoSeleccionado");
    List<Asistencia> asistenciasExistentes = (List<Asistencia>) request.getAttribute("asistenciasExistentes");
    Boolean puedeEditar = (Boolean) request.getAttribute("puedeEditar");
    String mensajeLimite = (String) request.getAttribute("mensajeLimite");
    
    // Parámetros
    String cursoIdParam = (String) request.getAttribute("cursoIdParam");
    String fechaParam = (String) request.getAttribute("fechaParam");
    String turnoIdParam = (String) request.getAttribute("turnoIdParam");
    String horaClaseParam = (String) request.getAttribute("horaClaseParam");
    
    // Valores por defecto
    if (cursos == null) cursos = new ArrayList<>();
    if (alumnos == null) alumnos = new ArrayList<>();
    if (asistenciasExistentes == null) asistenciasExistentes = new ArrayList<>();
    if (puedeEditar == null) puedeEditar = true;
    if (mensajeLimite == null) mensajeLimite = "";
    if (fechaParam == null) fechaParam = LocalDate.now().toString();
    if (horaClaseParam == null) horaClaseParam = "08:00";
    if (turnoIdParam == null) turnoIdParam = "1";
    
    // Crear mapa de asistencias existentes
    Map<Integer, Asistencia> mapaAsistencias = new HashMap<>();
    for (Asistencia asist : asistenciasExistentes) {
        mapaAsistencias.put(asist.getAlumnoId(), asist);
    }
    
    // Mensajes
    String mensaje = (String) session.getAttribute("mensaje");
    String error = (String) session.getAttribute("error");
    String advertencia = (String) session.getAttribute("advertencia");
    
    // Limpiar mensajes de sesión después de mostrarlos
    session.removeAttribute("mensaje");
    session.removeAttribute("error");
    session.removeAttribute("advertencia");
    
    // Obtener nombre del usuario para mostrar
    String nombreUsuario = (String) session.getAttribute("nombres");
    if (nombreUsuario == null) {
        nombreUsuario = "Usuario";
    }
%>
<!DOCTYPE html>
<html lang="es">
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
    <title>Registrar Asistencia - San Antonio</title>
    
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    
    <link href="https://fonts.googleapis.com/css2?family=Lexend:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
    
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    
    <script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        "primary": "#135bec",
                        "background-light": "#f6f6f8",
                        "background-dark": "#101622",
                    },
                    fontFamily: {
                        "display": ["Lexend"]
                    },
                    borderRadius: {"DEFAULT": "0.25rem", "lg": "0.5rem", "xl": "0.75rem", "full": "9999px"},
                },
            },
        }
    </script>
    
    <style>
        body {
            font-family: 'Lexend', sans-serif;
        }
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
        
        /* Mejoras de accesibilidad */
        .reduce-motion * { 
            animation-duration: 0.01ms !important; 
            animation-iteration-count: 1 !important; 
            transition-duration: 0.01ms !important; 
        }
        .high-contrast-invert { 
            filter: invert(1) hue-rotate(180deg); 
        }
        .high-contrast-yellow { 
            background-color: #000000 !important; 
            color: #ffff00 !important; 
        }
        .beige-background { 
            background-color: #f5f5dc !important; 
        }
        
        /* Tamaños de texto */
        .large-text { font-size: 18px !important; }
        .larger-text { font-size: 20px !important; }
        .largest-text { font-size: 22px !important; }
        
        .dyslexia-font { 
            font-family: Arial !important; 
            font-size: 1.1em !important; 
            line-height: 1.6 !important; 
            letter-spacing: 0.5px !important; 
        }
        
        /* Panel de accesibilidad */
        .accessibility-panel {
            transform: translateX(100%);
            transition: transform 0.3s ease;
        }
        .accessibility-panel.open {
            transform: translateX(0);
        }
        
        /* Skip to content */
        .skip-to-content {
            position: absolute;
            top: -40px;
            left: 0;
            background: #135bec;
            color: white;
            padding: 8px;
            z-index: 100;
        }
        .skip-to-content:focus {
            top: 0;
        }
        
        /* Focus styles */
        :focus {
            outline: 3px solid #135bec !important;
            outline-offset: 2px;
        }
        
        /* Badge con tamaño base más grande */
        .status-badge {
            padding: 0.35rem 0.85rem;
            border-radius: 9999px;
            font-size: 0.85rem;
            font-weight: 600;
        }
        
        /* Botón de accesibilidad */
        .accessibility-toggle {
            transition: all 0.3s ease;
        }
        
        .accessibility-toggle:hover {
            transform: scale(1.1);
        }
        
        /* Alertas */
        .alert {
            border-radius: 0.5rem;
            padding: 1rem;
            margin-bottom: 1rem;
            border: 1px solid transparent;
        }
        
        .alert-danger {
            background-color: #fef2f2;
            border-color: #fecaca;
            color: #dc2626;
        }
        
        .dark .alert-danger {
            background-color: #450a0a;
            border-color: #7f1d1d;
            color: #fca5a5;
        }
        
        .alert-success {
            background-color: #f0fdf4;
            border-color: #bbf7d0;
            color: #16a34a;
        }
        
        .dark .alert-success {
            background-color: #052e16;
            border-color: #14532d;
            color: #86efac;
        }
        
        .alert-warning {
            background-color: #fffbeb;
            border-color: #fde68a;
            color: #92400e;
        }
        
        .dark .alert-warning {
            background-color: #451a03;
            border-color: #78350f;
            color: #fde68a;
        }
        
        /* Animaciones suaves */
        .transition-smooth {
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }
        
        /* Radio buttons custom */
        .radio-option {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.5rem 0.75rem;
            border-radius: 0.5rem;
            transition: all 0.2s;
            cursor: pointer;
        }
        
        .radio-option:hover {
            background-color: rgba(19, 91, 236, 0.1);
        }
        
        .radio-option input[type="radio"] {
            width: 1.125rem;
            height: 1.125rem;
            cursor: pointer;
        }
        
        .radio-option input[type="radio"]:disabled {
            cursor: not-allowed;
        }
        
        /* Table responsive */
        .table-scroll {
            overflow-x: auto;
        }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark transition-colors duration-300">
    <a href="#main-content" class="skip-to-content">Saltar al contenido principal</a>
    
    <!-- Accessibility Panel -->
    <div class="accessibility-panel fixed top-0 right-0 h-full w-80 bg-white dark:bg-gray-800 shadow-2xl z-50 overflow-y-auto p-6">
        <div class="flex justify-between items-center mb-6">
            <h2 class="text-xl font-bold text-gray-900 dark:text-white">Accesibilidad</h2>
            <button onclick="toggleAccessibilityPanel()" class="text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200">
                <span class="material-symbols-outlined">close</span>
            </button>
        </div>
        
        <div class="space-y-6">
            <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Tamaño de texto</label>
                <div class="flex gap-2">
                    <button onclick="setTextSize('normal')" class="flex-1 px-3 py-2 bg-gray-100 dark:bg-gray-700 rounded hover:bg-gray-200 dark:hover:bg-gray-600 text-sm">Normal</button>
                    <button onclick="setTextSize('large')" class="flex-1 px-3 py-2 bg-gray-100 dark:bg-gray-700 rounded hover:bg-gray-200 dark:hover:bg-gray-600 text-sm">Grande</button>
                    <button onclick="setTextSize('larger')" class="flex-1 px-3 py-2 bg-gray-100 dark:bg-gray-700 rounded hover:bg-gray-200 dark:hover:bg-gray-600 text-sm">Más grande</button>
                </div>
            </div>
            
            <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Contraste</label>
                <div class="space-y-2">
                    <button onclick="setContrast('normal')" class="w-full px-3 py-2 bg-gray-100 dark:bg-gray-700 rounded hover:bg-gray-200 dark:hover:bg-gray-600 text-sm text-left">Normal</button>
                    <button onclick="setContrast('high')" class="w-full px-3 py-2 bg-gray-100 dark:bg-gray-700 rounded hover:bg-gray-200 dark:hover:bg-gray-600 text-sm text-left">Alto contraste</button>
                    <button onclick="setContrast('yellow')" class="w-full px-3 py-2 bg-gray-100 dark:bg-gray-700 rounded hover:bg-gray-200 dark:hover:bg-gray-600 text-sm text-left">Amarillo sobre negro</button>
                </div>
            </div>
            
            <div>
                <label class="flex items-center gap-2 cursor-pointer">
                    <input type="checkbox" id="reduceMotion" onchange="toggleMotion()" class="rounded">
                    <span class="text-sm text-gray-700 dark:text-gray-300">Reducir animaciones</span>
                </label>
            </div>
            
            <div>
                <label class="flex items-center gap-2 cursor-pointer">
                    <input type="checkbox" id="dyslexiaFont" onchange="toggleDyslexiaFont()" class="rounded">
                    <span class="text-sm text-gray-700 dark:text-gray-300">Fuente para dislexia</span>
                </label>
            </div>
            
            <div>
                <label class="flex items-center gap-2 cursor-pointer">
                    <input type="checkbox" id="beigeBackground" onchange="toggleBeigeBackground()" class="rounded">
                    <span class="text-sm text-gray-700 dark:text-gray-300">Fondo beige</span>
                </label>
            </div>
            
            <button onclick="resetAccessibility()" class="w-full px-4 py-2 bg-primary text-white rounded-lg hover:bg-blue-700">
                Restablecer todo
            </button>
        </div>
    </div>
    
    <!-- Main Container con Sidebar -->
    <div class="flex h-screen overflow-hidden">
        <!-- Sidebar - INCLUIDO -->
        <jsp:include page="includes/sidebarDocente.jsp" />
        
        <!-- Main Content Wrapper -->
        <main class="flex-1 flex flex-col overflow-y-auto">
            <!-- Header - INCLUIDO -->
            <% request.setAttribute("pageTitle", "Registrar Asistencia"); %>
            <jsp:include page="includes/header.jsp" />
            
            <!-- Main Content -->
            <div id="main-content" class="flex-1 px-8 py-8">
                <!-- Alerts -->
                <% if (mensaje != null) { %>
                    <div class="alert alert-success flex items-center gap-3 mb-6">
                        <span class="material-symbols-outlined">check_circle</span>
                        <span><%= mensaje %></span>
                    </div>
                <% } %>
                
                <% if (error != null) { %>
                    <div class="alert alert-danger flex items-center gap-3 mb-6">
                        <span class="material-symbols-outlined">error</span>
                        <span><%= error %></span>
                    </div>
                <% } %>
                
                <% if (advertencia != null) { %>
                    <div class="alert alert-warning flex items-center gap-3 mb-6">
                        <span class="material-symbols-outlined">warning</span>
                        <span><%= advertencia %></span>
                    </div>
                <% } %>
                
                <!-- Mensaje de límite de tiempo -->
                <% if (!puedeEditar && mensajeLimite != null && !mensajeLimite.isEmpty()) { %>
                    <div class="alert alert-warning flex items-center gap-3 mb-6">
                        <span class="material-symbols-outlined">schedule</span>
                        <div>
                            <div><%= mensajeLimite %></div>
                            <small class="text-xs">El formulario está en modo solo lectura.</small>
                        </div>
                    </div>
                <% } %>
                
                <!-- Mensaje de Bloqueo Completo -->
                <% if (cursoSeleccionado != null && !puedeEditar && mensajeLimite != null && mensajeLimite.contains("vencido")) { %>
                    <div class="bg-red-50 dark:bg-red-900/20 border-2 border-red-500 dark:border-red-800 rounded-xl p-8 mb-8 text-center">
                        <div class="flex flex-col items-center justify-center">
                            <span class="material-symbols-outlined text-red-600 dark:text-red-400 text-6xl mb-4">
                                lock
                            </span>
                            <h3 class="text-2xl font-bold text-red-800 dark:text-red-300 mb-2">Edición Bloqueada</h3>
                            <p class="text-red-700 dark:text-red-400 mb-2"><%= mensajeLimite %></p>
                            <p class="text-sm text-red-600 dark:text-red-500">Para modificar esta asistencia, contacta al administrador del sistema.</p>
                        </div>
                    </div>
                <% } %>
                
                <!-- Filtros: ESTÁTICO si ya hay curso cargado, EDITABLE si no -->
                <% if (cursoSeleccionado != null) { %>
                    <%-- ✅ MODO ESTÁTICO: datos de la BD, solo lectura --%>
                    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6 mb-8 transition-colors duration-300">
                        <div class="flex items-center mb-5">
                            <h2 class="text-xl font-bold text-gray-900 dark:text-white flex items-center gap-2">
                                <span class="material-symbols-outlined text-primary">info</span>
                                Datos del Curso
                            </h2>
                        </div>

                        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                            <%-- Curso --%>
                            <div class="bg-gray-50 dark:bg-gray-700 rounded-lg px-4 py-3 border border-gray-200 dark:border-gray-600">
                                <p class="text-xs font-medium text-gray-500 dark:text-gray-400 mb-1 flex items-center gap-1">
                                    <i class="fas fa-book text-primary"></i> Curso
                                </p>
                                <p class="font-semibold text-gray-900 dark:text-white">
                                    <%= cursoSeleccionado.getNombre() %>
                                    <% if (cursoSeleccionado.getGradoNombre() != null) { %>
                                        <span class="text-xs font-normal text-gray-500 dark:text-gray-400">- <%= cursoSeleccionado.getGradoNombre() %></span>
                                    <% } %>
                                </p>
                            </div>
                            <%-- Turno --%>
                            <div class="bg-gray-50 dark:bg-gray-700 rounded-lg px-4 py-3 border border-gray-200 dark:border-gray-600">
                                <p class="text-xs font-medium text-gray-500 dark:text-gray-400 mb-1 flex items-center gap-1">
                                    <i class="fas fa-clock text-primary"></i> Turno
                                </p>
                                <p class="font-semibold text-gray-900 dark:text-white">
                                    <%= "1".equals(turnoIdParam) ? "Mañana" : ("2".equals(turnoIdParam) ? "Tarde" : "Turno " + turnoIdParam) %>
                                </p>
                            </div>
                            <%-- Fecha --%>
                            <div class="bg-gray-50 dark:bg-gray-700 rounded-lg px-4 py-3 border border-gray-200 dark:border-gray-600">
                                <p class="text-xs font-medium text-gray-500 dark:text-gray-400 mb-1 flex items-center gap-1">
                                    <i class="fas fa-calendar text-primary"></i> Fecha
                                </p>
                                <p class="font-semibold text-gray-900 dark:text-white">
                                    <%
                                        // Formatear fecha de yyyy-MM-dd a dd/MM/yyyy
                                        String fechaMostrar = fechaParam;
                                        try {
                                            java.time.LocalDate fd = java.time.LocalDate.parse(fechaParam);
                                            fechaMostrar = fd.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"));
                                        } catch(Exception ex) {}
                                    %>
                                    <%= fechaMostrar %>
                                </p>
                            </div>
                            <%-- Hora --%>
                            <div class="bg-gray-50 dark:bg-gray-700 rounded-lg px-4 py-3 border border-gray-200 dark:border-gray-600">
                                <p class="text-xs font-medium text-gray-500 dark:text-gray-400 mb-1 flex items-center gap-1">
                                    <i class="fas fa-clock text-primary"></i> Hora de Clase
                                </p>
                                <p class="font-semibold text-gray-900 dark:text-white">
                                    <%= horaClaseParam != null ? horaClaseParam : "08:00" %>
                                </p>
                            </div>
                        </div>
                    </div>

                <% } else { %>
                    <%-- ✅ MODO EDITABLE: el docente aún no ha cargado un curso --%>
                    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6 mb-8 transition-colors duration-300">
                        <h2 class="text-xl font-bold text-gray-900 dark:text-white mb-6 flex items-center gap-2">
                            <span class="material-symbols-outlined text-primary">filter_list</span>
                            Seleccionar Curso y Fecha
                        </h2>

                        <form method="GET" action="AsistenciaServlet">
                            <input type="hidden" name="accion" value="registrar">

                            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-6">
                                <div>
                                    <label for="curso_id" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                        <i class="fas fa-book text-primary"></i> Curso
                                    </label>
                                    <select name="curso_id" id="curso_id" required
                                            class="w-full px-4 py-2.5 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent bg-white dark:bg-gray-700 text-gray-900 dark:text-white transition-colors">
                                        <option value="">-- Seleccione un curso --</option>
                                        <% for (Curso c : cursos) { %>
                                            <option value="<%= c.getId() %>"><%= c.getNombre() %><%= c.getGradoNombre() != null ? " - " + c.getGradoNombre() : "" %></option>
                                        <% } %>
                                    </select>
                                </div>

                                <div>
                                    <label for="turno_id" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                        <i class="fas fa-clock text-primary"></i> Turno
                                    </label>
                                    <select name="turno_id" id="turno_id" required
                                            class="w-full px-4 py-2.5 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent bg-white dark:bg-gray-700 text-gray-900 dark:text-white transition-colors">
                                        <option value="1">Mañana</option>
                                        <option value="2">Tarde</option>
                                    </select>
                                </div>

                                <div>
                                    <label for="fecha" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                        <i class="fas fa-calendar text-primary"></i> Fecha
                                    </label>
                                    <input type="date" name="fecha" id="fecha" required
                                           value="<%= fechaParam %>"
                                           max="<%= LocalDate.now() %>"
                                           class="w-full px-4 py-2.5 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent bg-white dark:bg-gray-700 text-gray-900 dark:text-white transition-colors">
                                </div>

                                <div>
                                    <label for="hora_clase" class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                                        <i class="fas fa-clock text-primary"></i> Hora de Clase
                                    </label>
                                    <input type="time" name="hora_clase" id="hora_clase" required
                                           value="<%= horaClaseParam %>"
                                           class="w-full px-4 py-2.5 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent bg-white dark:bg-gray-700 text-gray-900 dark:text-white transition-colors">
                                </div>
                            </div>

                            <button type="submit" class="w-full md:w-auto px-6 py-3 bg-gradient-to-r from-primary to-blue-600 hover:from-blue-600 hover:to-blue-700 text-white font-medium rounded-lg transition-all duration-300 transform hover:scale-[1.02] focus:outline focus:outline-3 focus:outline-primary flex items-center justify-center gap-2">
                                <span class="material-symbols-outlined">refresh</span>
                                <span>Cargar Asistencia</span>
                            </button>
                        </form>
                    </div>
                <% } %>
                
                <!-- Tabla de Asistencias -->
                <% if (cursoSeleccionado != null && alumnos != null && alumnos.size() > 0) { %>
                    <div class="bg-white dark:bg-gray-800 rounded-xl shadow-lg overflow-hidden transition-colors duration-300">
                        <!-- Header de la tabla -->
                        <div class="bg-gradient-to-r from-blue-50 to-cyan-50 dark:from-blue-900/20 dark:to-cyan-900/20 p-6 border-b border-gray-200 dark:border-gray-700">
                            <h2 class="text-xl font-bold text-gray-900 dark:text-white flex items-center gap-2">
                                <span class="material-symbols-outlined text-primary">group</span>
                                Lista de Alumnos - <%= cursoSeleccionado.getNombre() %>
                            </h2>
                        </div>
                        
                        <form method="POST" action="AsistenciaServlet">
                            <input type="hidden" name="accion" value="registrarGrupal">
                            <input type="hidden" name="cursoId" value="<%= cursoSeleccionado.getId() %>">
                            <input type="hidden" name="turnoId" value="<%= turnoIdParam %>">
                            <input type="hidden" name="fecha" value="<%= fechaParam %>">
                            <input type="hidden" name="horaClase" value="<%= horaClaseParam %>">
                            
                            <div class="table-scroll overflow-x-auto">
                                <table class="w-full">
                                    <thead class="bg-gray-900 dark:bg-gray-950">
                                        <tr>
                                            <th class="px-6 py-4 text-left text-sm font-semibold text-white">N°</th>
                                            <th class="px-6 py-4 text-left text-sm font-semibold text-white">Alumno</th>
                                            <th class="px-6 py-4 text-left text-sm font-semibold text-white">Estado Actual</th>
                                            <th class="px-6 py-4 text-left text-sm font-semibold text-white">Marcar Asistencia</th>
                                            <th class="px-6 py-4 text-left text-sm font-semibold text-white">Observaciones</th>
                                        </tr>
                                    </thead>
                                    <tbody class="divide-y divide-gray-200 dark:divide-gray-700">
                                        <% 
                                        int contador = 1;
                                        for (Alumno alumno : alumnos) { 
                                            Asistencia asistExistente = mapaAsistencias.get(alumno.getId());
                                            String estadoActual = asistExistente != null ? asistExistente.getEstadoString() : "Sin registro";
                                            String observaciones = asistExistente != null && asistExistente.getObservaciones() != null ? asistExistente.getObservaciones() : "";
                                        %>
                                            <tr class="hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors">
                                                <td class="px-6 py-4 text-gray-900 dark:text-white font-medium"><%= contador++ %></td>
                                                <td class="px-6 py-4">
                                                    <div class="flex items-center gap-3">
                                                        <div class="w-10 h-10 bg-gradient-to-br from-primary to-blue-600 rounded-full flex items-center justify-center">
                                                            <span class="material-symbols-outlined text-white text-xl">person</span>
                                                        </div>
                                                        <span class="font-semibold text-gray-900 dark:text-white"><%= alumno.getNombreCompleto() %></span>
                                                    </div>
                                                </td>
                                                <td class="px-6 py-4">
                                                    <% if (asistExistente != null) { %>
                                                        <% if ("PRESENTE".equals(estadoActual)) { %>
                                                            <span class="status-badge bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200">
                                                                <i class="fas fa-check-circle"></i> <%= estadoActual %>
                                                            </span>
                                                        <% } else if ("TARDANZA".equals(estadoActual)) { %>
                                                            <span class="status-badge bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200">
                                                                <i class="fas fa-clock"></i> <%= estadoActual %>
                                                            </span>
                                                        <% } else if ("AUSENTE".equals(estadoActual)) { %>
                                                            <span class="status-badge bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200">
                                                                <i class="fas fa-times-circle"></i> <%= estadoActual %>
                                                            </span>
                                                        <% } else { %>
                                                            <span class="status-badge bg-gray-100 text-gray-800 dark:bg-gray-900 dark:text-gray-200">
                                                                <%= estadoActual %>
                                                            </span>
                                                        <% } %>
                                                    <% } else { %>
                                                        <span class="text-sm text-gray-500 dark:text-gray-400">Sin registro</span>
                                                    <% } %>
                                                </td>
                                                <td class="px-6 py-4">
                                                    <div class="flex flex-wrap gap-2">
                                                        <label class="radio-option bg-green-50 dark:bg-green-900/20 text-green-800 dark:text-green-300">
                                                            <input type="radio" name="estado_<%= alumno.getId() %>" 
                                                                   value="PRESENTE"
                                                                   <%= "PRESENTE".equals(estadoActual) ? "checked" : "" %>
                                                                   <%= !puedeEditar ? "disabled" : "" %>
                                                                   class="text-green-600 focus:ring-green-500">
                                                            <i class="fas fa-check-circle"></i> Presente
                                                        </label>
                                                        <label class="radio-option bg-yellow-50 dark:bg-yellow-900/20 text-yellow-800 dark:text-yellow-300">
                                                            <input type="radio" name="estado_<%= alumno.getId() %>" 
                                                                   value="TARDANZA"
                                                                   <%= "TARDANZA".equals(estadoActual) ? "checked" : "" %>
                                                                   <%= !puedeEditar ? "disabled" : "" %>
                                                                   class="text-yellow-600 focus:ring-yellow-500">
                                                            <i class="fas fa-clock"></i> Tardanza
                                                        </label>
                                                        <label class="radio-option bg-red-50 dark:bg-red-900/20 text-red-800 dark:text-red-300">
                                                            <input type="radio" name="estado_<%= alumno.getId() %>" 
                                                                   value="AUSENTE"
                                                                   <%= ("AUSENTE".equals(estadoActual) || asistExistente == null) ? "checked" : "" %>
                                                                   <%= !puedeEditar ? "disabled" : "" %>
                                                                   class="text-red-600 focus:ring-red-500">
                                                            <i class="fas fa-times-circle"></i> Ausente
                                                        </label>
                                                    </div>
                                                </td>
                                                <td class="px-6 py-4">
                                                    <input type="text" name="observaciones_<%= alumno.getId() %>" 
                                                           value="<%= observaciones %>"
                                                           placeholder="Opcional"
                                                           <%= !puedeEditar ? "disabled" : "" %>
                                                           class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent bg-white dark:bg-gray-700 text-gray-900 dark:text-white transition-colors disabled:bg-gray-100 dark:disabled:bg-gray-800 disabled:cursor-not-allowed">
                                                </td>
                                            </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                            
                            <!-- Footer de la tabla -->
                            <div class="bg-gray-50 dark:bg-gray-900 p-6 border-t border-gray-200 dark:border-gray-700 flex justify-end">
                                <button type="submit" 
                                        <%= !puedeEditar ? "disabled" : "" %>
                                        class="px-6 py-3 bg-gradient-to-r from-green-500 to-green-600 hover:from-green-600 hover:to-green-700 text-white font-medium rounded-lg transition-all duration-300 transform hover:scale-[1.02] flex items-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:scale-100">
                                    <span class="material-symbols-outlined">save</span>
                                    <span>Guardar Asistencias</span>
                                </button>
                            </div>
                        </form>
                    </div>
                <% } else if (cursoSeleccionado != null && (alumnos == null || alumnos.size() == 0)) { %>
                    <div class="alert alert-warning flex items-center gap-3">
                        <span class="material-symbols-outlined">warning</span>
                        <span>No hay alumnos registrados en este curso y turno.</span>
                    </div>
                <% } %>
                
                <!-- Info Box -->
                <div class="mt-8 bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-xl p-6">
                    <div class="flex items-start gap-4">
                        <span class="material-symbols-outlined text-blue-600 dark:text-blue-400 text-3xl mt-1">
                            info
                        </span>
                        <div>
                            <h4 class="font-semibold text-blue-800 dark:text-blue-300 mb-3">Información importante:</h4>
                            <ul class="space-y-2 text-sm text-blue-700 dark:text-blue-400">
                                <li class="flex items-start gap-2">
                                    <span class="material-symbols-outlined text-sm mt-0.5">check</span>
                                    <span>Selecciona el curso, turno, fecha y hora antes de cargar la lista de asistencia</span>
                                </li>
                                <li class="flex items-start gap-2">
                                    <span class="material-symbols-outlined text-sm mt-0.5">check</span>
                                    <span>Marca el estado de asistencia de cada alumno (Presente, Tardanza o Ausente)</span>
                                </li>
                                <li class="flex items-start gap-2">
                                    <span class="material-symbols-outlined text-sm mt-0.5">check</span>
                                    <span>Puedes agregar observaciones opcionales para cada alumno</span>
                                </li>
                                <li class="flex items-start gap-2">
                                    <span class="material-symbols-outlined text-sm mt-0.5">check</span>
                                    <span>El sistema puede bloquear la edición si ha pasado el tiempo límite establecido</span>
                                </li>
                                <li class="flex items-start gap-2">
                                    <span class="material-symbols-outlined text-sm mt-0.5">check</span>
                                    <span>Revisa cuidadosamente antes de guardar, ya que las modificaciones pueden tener restricciones de tiempo</span>
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Footer -->
            <footer class="bg-white dark:bg-gray-900 border-t border-gray-200 dark:border-gray-700 mt-12 transition-colors duration-300">
                <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
                    <p class="text-center text-sm text-gray-600 dark:text-gray-400">
                        © 2025 Sistema de Asistencia Escolar - San Antonio. Todos los derechos reservados.
                    </p>
                </div>
            </footer>
        </main>
    </div>

    <script>
        // Accessibility Functions
        function toggleAccessibilityPanel() {
            const panel = document.querySelector('.accessibility-panel');
            panel.classList.toggle('open');
        }
        
        function setTextSize(size) {
            document.body.classList.remove('large-text', 'larger-text', 'largest-text');
            if (size === 'large') {
                document.body.classList.add('large-text');
            } else if (size === 'larger') {
                document.body.classList.add('larger-text');
            } else if (size === 'largest') {
                document.body.classList.add('largest-text');
            }
            document.body.offsetHeight;
        }
        
        function setContrast(mode) {
            document.body.classList.remove('high-contrast-invert', 'high-contrast-yellow');
            if (mode === 'high') {
                document.body.classList.add('high-contrast-invert');
            } else if (mode === 'yellow') {
                document.body.classList.add('high-contrast-yellow');
            }
        }
        
        function toggleMotion() {
            const checkbox = document.getElementById('reduceMotion');
            if (checkbox.checked) {
                document.body.classList.add('reduce-motion');
            } else {
                document.body.classList.remove('reduce-motion');
            }
        }
        
        function toggleDyslexiaFont() {
            const checkbox = document.getElementById('dyslexiaFont');
            if (checkbox.checked) {
                document.body.classList.add('dyslexia-font');
            } else {
                document.body.classList.remove('dyslexia-font');
            }
        }
        
        function toggleBeigeBackground() {
            const checkbox = document.getElementById('beigeBackground');
            if (checkbox.checked) {
                document.body.classList.add('beige-background');
            } else {
                document.body.classList.remove('beige-background');
            }
        }
        
        function resetAccessibility() {
            document.body.classList.remove(
                'large-text', 'larger-text', 'largest-text',
                'high-contrast-invert', 'high-contrast-yellow',
                'reduce-motion', 'dyslexia-font', 'beige-background'
            );
            
            document.getElementById('reduceMotion').checked = false;
            document.getElementById('dyslexiaFont').checked = false;
            document.getElementById('beigeBackground').checked = false;
        }
        
        // Focus management for accessibility
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                const panel = document.querySelector('.accessibility-panel');
                if (panel.classList.contains('open')) {
                    panel.classList.remove('open');
                }
            }
        });
    </script>
</body>
</html>