<%@ page import="modelo.Profesor" %>
<%@ page import="modelo.Turno" %>
<%@ page import="modelo.Area" %>
<%@ page import="java.util.List" %>
<%@ page import="modelo.ProfesorNivelArea" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.time.LocalTime" %>
<%@ page import="modelo.Disponibilidad" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    Profesor p = (Profesor) request.getAttribute("profesor");
    if (p == null) {
        response.sendRedirect("ProfesorServlet?accion=listar");
        return;
    }
    
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
    
    String estado = p.getEstado() != null ? p.getEstado() : "ACTIVO";
    String estadoClass = "", estadoTexto = "", estadoIcon = "";
    switch(estado) {
        case "ACTIVO":   estadoClass = "status-active";   estadoTexto = "Activo";      estadoIcon = "fa-circle-check";   break;
        case "INACTIVO": estadoClass = "status-inactive"; estadoTexto = "Inactivo";    estadoIcon = "fa-circle-xmark";   break;
        case "LICENCIA": estadoClass = "status-license";  estadoTexto = "En Licencia"; estadoIcon = "fa-clock";          break;
        case "JUBILADO": estadoClass = "status-retired";  estadoTexto = "Jubilado";    estadoIcon = "fa-umbrella-beach"; break;
        default:         estadoClass = "status-active";   estadoTexto = estado;         estadoIcon = "fa-circle";
    }
    
    String nivel = p.getNivel();
    String nivelClass = "nivel-todos", nivelTexto = "No asignado";
    if (nivel != null) {
        switch(nivel) {
            case "INICIAL":    nivelClass = "nivel-inicial";    nivelTexto = "Inicial";           break;
            case "PRIMARIA":   nivelClass = "nivel-primaria";   nivelTexto = "Primaria";          break;
            case "SECUNDARIA": nivelClass = "nivel-secundaria"; nivelTexto = "Secundaria";        break;
            case "TODOS":      nivelClass = "nivel-todos";      nivelTexto = "Todos los Niveles"; break;
            default:           nivelClass = "nivel-todos";      nivelTexto = nivel;
        }
    }

    request.setAttribute("pageTitle", "Perfil Profesional");
%>

<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Perfil - <%= p.getNombres() %> <%= p.getApellidos() %> - San Antonio</title>

    <%-- ? HEAD común --%>
    <%@ include file="includes/head.jsp" %>

    <style>
        .reduce-motion * { animation-duration: 0.01ms !important; animation-iteration-count: 1 !important; transition-duration: 0.01ms !important; }
        .high-contrast-invert { filter: invert(1) hue-rotate(180deg); }
        .high-contrast-yellow { background-color: #000000 !important; color: #ffff00 !important; }
        .beige-background { background-color: #f5f5dc !important; }
        .large-text  { font-size: 18px !important; }
        .larger-text { font-size: 20px !important; }
        .largest-text{ font-size: 22px !important; }
        .dyslexia-font { font-family: Arial !important; font-size: 1.1em !important; line-height: 1.6 !important; letter-spacing: 0.5px !important; }
        .accessibility-panel { transform: translateX(100%); transition: transform 0.3s ease; }
        .accessibility-panel.open { transform: translateX(0); }
        .skip-to-content { position: absolute; top: -40px; left: 0; background: #135bec; color: white; padding: 8px; z-index: 100; }
        .skip-to-content:focus { top: 0; }
        :focus { outline: 3px solid #135bec !important; outline-offset: 2px; }

        .profile-header-card { background: white; border-radius: 20px; box-shadow: 0 10px 40px rgba(0,0,0,0.15); overflow: hidden; margin-bottom: 2rem; position: relative; }
        .dark .profile-header-card { background: #1a2233; }
        .profile-cover { height: 250px; background: linear-gradient(135deg, #135bec 0%, #0d47a1 100%); position: relative; overflow: hidden; }
        .profile-cover::before { content: ''; position: absolute; inset: 0; background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1440 320"><path fill="%23ffffff" fill-opacity="0.1" d="M0,96L48,112C96,128,192,160,288,160C384,160,480,128,576,122.7C672,117,768,139,864,154.7C960,171,1056,181,1152,165.3C1248,149,1344,107,1392,85.3L1440,64L1440,320L1392,320C1344,320,1248,320,1152,320C1056,320,960,320,864,320C768,320,672,320,576,320C480,320,384,320,288,320C192,320,96,320,48,320L0,320Z"></path></svg>') no-repeat bottom; background-size: cover; }
        .profile-info-section { padding: 0 3rem 2.5rem 3rem; position: relative; margin-top: -100px; }
        .profile-avatar-container { display: flex; align-items: flex-end; gap: 2.5rem; margin-bottom: 2rem; }
        .profile-avatar { width: 200px; height: 200px; border-radius: 20px; background: linear-gradient(135deg, #3b82f6, #135bec); display: flex; align-items: center; justify-content: center; font-size: 5rem; color: white; font-weight: 700; box-shadow: 0 15px 50px rgba(0,0,0,0.3); border: 6px solid white; text-transform: uppercase; position: relative; z-index: 10; overflow: hidden; padding: 0; }
        .dark .profile-avatar { border-color: #1a2233; }
        .profile-title-section { flex: 1; padding-bottom: 1.5rem; }
        .profile-name { font-size: 3rem; font-weight: 700; color: #89CFF0; margin: 0; line-height: 1.2; }
        .profile-role { font-size: 1.3rem; color: #2d2d2d; font-weight: 700; margin-top: 0.75rem; display: flex; align-items: center; gap: 0.75rem; }
        .dark .profile-role { color: #d1d5db; }
        .profile-code { display: inline-flex; align-items: center; gap: 0.75rem; background: #f3f4f6; padding: 0.75rem 1.5rem; border-radius: 12px; font-weight: 600; color: #374151; margin-top: 1rem; font-size: 1.05rem; }
        .dark .profile-code { background: #374151; color: #d1d5db; }
        .status-badge-large { position: absolute; top: 2.5rem; right: 3rem; padding: 1rem 2rem; border-radius: 50px; font-weight: 700; font-size: 1.1rem; text-transform: uppercase; letter-spacing: 1px; display: flex; align-items: center; gap: 0.75rem; box-shadow: 0 8px 20px rgba(0,0,0,0.2); }
        .status-active   { background: linear-gradient(135deg, #d1fae5, #a7f3d0); color: #065f46; }
        .status-inactive { background: linear-gradient(135deg, #fee2e2, #fecaca); color: #991b1b; }
        .status-license  { background: linear-gradient(135deg, #fef3c7, #fde68a); color: #92400e; }
        .status-retired  { background: linear-gradient(135deg, #e0e7ff, #c7d2fe); color: #3730a3; }
        .status-badge-large i { font-size: 1.2rem; animation: pulse 2s infinite; }
        @keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.5; } }

        .info-cards-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 2rem; margin-top: 2rem; }
        .info-card { background: white; border-radius: 20px; padding: 3rem; box-shadow: 0 10px 30px rgba(0,0,0,0.12); transition: all 0.3s ease; position: relative; overflow: hidden; min-height: 500px; }
        .dark .info-card { background: #1a2233; }
        .info-card::before { content: ''; position: absolute; top: 0; left: 0; width: 6px; height: 100%; background: linear-gradient(180deg, #135bec, #0d47a1); }
        .info-card:hover { transform: translateY(-5px); box-shadow: 0 20px 50px rgba(0,0,0,0.18); }
        .card-header-section { display: flex; align-items: center; gap: 1.5rem; margin-bottom: 2rem; padding-bottom: 1.5rem; border-bottom: 3px solid #f3f4f6; }
        .dark .card-header-section { border-bottom-color: #374151; }
        .card-icon { width: 70px; height: 70px; border-radius: 16px; display: flex; align-items: center; justify-content: center; font-size: 2rem; color: white; }
        .card-icon-personal     { background: linear-gradient(135deg, #667eea, #764ba2); }
        .card-icon-professional { background: linear-gradient(135deg, #f093fb, #f5576c); }
        .card-title { font-size: 1.8rem; font-weight: 700; color: #1f2937; margin: 0; }
        .dark .card-title { color: #f3f4f6; }
        .info-item { display: flex; align-items: flex-start; gap: 1.5rem; padding: 1.25rem 0; border-bottom: 1px solid #f3f4f6; }
        .dark .info-item { border-bottom-color: #374151; }
        .info-item:last-child { border-bottom: none; }
        .info-icon { width: 50px; height: 50px; border-radius: 12px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; font-size: 1.3rem; }
        .icon-primary { background: #e0e7ff; color: #135bec; }
        .icon-success { background: #d1fae5; color: #10b981; }
        .icon-warning { background: #fef3c7; color: #f59e0b; }
        .icon-danger  { background: #fee2e2; color: #ef4444; }
        .icon-info    { background: #dbeafe; color: #3b82f6; }
        .info-content { flex: 1; }
        .info-label { font-size: 0.95rem; font-weight: 600; color: #6b7280; text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 0.5rem; }
        .dark .info-label { color: #9ca3af; }
        .info-value { font-size: 1.2rem; font-weight: 600; color: #1f2937; word-break: break-word; }
        .dark .info-value { color: #f3f4f6; }

        @media (max-width: 1200px) { .info-cards-grid { grid-template-columns: 1fr; } }
        @media (max-width: 768px) {
            .profile-cover { height: 180px; }
            .profile-avatar { width: 140px; height: 140px; font-size: 3.5rem; }
            .profile-info-section { padding: 0 1.5rem 1.5rem; margin-top: -70px; }
            .profile-avatar-container { flex-direction: column; align-items: center; text-align: center; }
            .profile-name { font-size: 2rem; }
            .status-badge-large { position: static; margin-top: 1rem; }
            .info-card { padding: 2rem; min-height: auto; }
            .card-title { font-size: 1.4rem; }
        }

        @keyframes fadeInUp { from { opacity: 0; transform: translateY(30px); } to { opacity: 1; transform: translateY(0); } }
        .profile-header-card { animation: fadeInUp 0.6s ease; }
        .info-card:nth-child(1) { animation: fadeInUp 0.6s ease 0.1s both; }
        .info-card:nth-child(2) { animation: fadeInUp 0.6s ease 0.2s both; }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark text-[#111318] dark:text-white min-h-screen" id="main-content">

    <a href="#main-content" class="skip-to-content">Saltar al contenido principal</a>

    <div class="fixed top-20 right-0 z-50 accessibility-panel bg-white dark:bg-gray-800 shadow-xl rounded-l-lg p-4 w-80">
        <div class="flex justify-between items-center mb-4">
            <h3 class="font-bold text-lg">Opciones de Accesibilidad</h3>
            <button onclick="toggleAccessibilityPanel()" class="text-gray-500 hover:text-gray-700">
                <span class="material-symbols-outlined">close</span>
            </button>
        </div>
        <div class="space-y-4">
            <div class="space-y-2">
                <h4 class="font-medium">Tamaño de texto</h4>
                <div class="flex gap-2">
                    <button onclick="setTextSize('normal')" class="px-3 py-2 bg-gray-100 rounded hover:bg-gray-200 text-sm">Normal</button>
                    <button onclick="setTextSize('large')"  class="px-3 py-2 bg-gray-100 rounded hover:bg-gray-200 text-sm">Grande</button>
                    <button onclick="setTextSize('larger')" class="px-3 py-2 bg-gray-100 rounded hover:bg-gray-200 text-sm">Más Grande</button>
                </div>
            </div>
            <div class="space-y-2">
                <h4 class="font-medium">Contraste</h4>
                <div class="flex gap-2">
                    <button onclick="setContrast('normal')" class="px-3 py-2 bg-gray-100 rounded hover:bg-gray-200 text-sm">Normal</button>
                    <button onclick="setContrast('high')"   class="px-3 py-2 bg-gray-100 rounded hover:bg-gray-200 text-sm">Alto</button>
                    <button onclick="setContrast('yellow')" class="px-3 py-2 bg-gray-100 rounded hover:bg-gray-200 text-sm">Amarillo</button>
                </div>
            </div>
            <div class="space-y-2">
                <h4 class="font-medium">Otros ajustes</h4>
                <div class="flex flex-col gap-2">
                    <label class="flex items-center gap-2"><input type="checkbox" id="reduceMotion"    onchange="toggleMotion()"><span>Reducir movimiento</span></label>
                    <label class="flex items-center gap-2"><input type="checkbox" id="dyslexiaFont"    onchange="toggleDyslexiaFont()"><span>Fuente para dislexia</span></label>
                    <label class="flex items-center gap-2"><input type="checkbox" id="beigeBackground" onchange="toggleBeigeBackground()"><span>Fondo beige</span></label>
                </div>
            </div>
            <button onclick="resetAccessibility()" class="w-full py-2 bg-gray-800 text-white rounded hover:bg-gray-900">Restablecer ajustes</button>
        </div>
    </div>

    <button onclick="toggleAccessibilityPanel()"
            class="fixed top-20 right-0 z-40 bg-primary text-white p-3 rounded-l-lg shadow-lg hover:bg-blue-700 transition-colors"
            aria-label="Abrir panel de accesibilidad">
        <span class="material-symbols-outlined">accessibility_new</span>
    </button>

    <div class="flex h-screen overflow-hidden">

        <%-- ? SIDEBAR --%>
        <%
            String rolSidebarU = (String) session.getAttribute("rol");
            String sidebarFileU = "administrativo".equals(rolSidebarU) 
                                 ? "includes/sidebarAdministrativo.jsp" 
                                 : "includes/sidebar.jsp";
        %>
        <jsp:include page="<%= sidebarFileU %>" />

        <main class="flex-1 flex flex-col overflow-y-auto">

            <%-- ? HEADER con foto dinámica --%>
            <%@ include file="includes/header.jsp" %>

            <div class="p-8">
                <div class="mb-6">
                    <h2 class="text-2xl font-bold text-[#111318] dark:text-white">Detalles del Profesor</h2>
                    <p class="text-[#616f89] dark:text-gray-400 mt-1">Información completa del perfil profesional</p>
                </div>

                <%
                    String error = (String) session.getAttribute("error");
                    String mensaje = (String) session.getAttribute("mensaje");
                    if (error != null) { session.removeAttribute("error"); %>
                <div class="alert-modern alert-danger mb-6" role="alert">
                    <i class="fas fa-exclamation-circle"></i>
                    <div><strong>Error:</strong> <%= error %></div>
                </div>
                <% } if (mensaje != null) { session.removeAttribute("mensaje"); %>
                <div class="alert-modern alert-success mb-6" role="alert">
                    <i class="fas fa-check-circle"></i>
                    <div><strong>Éxito:</strong> <%= mensaje %></div>
                </div>
                <% } %>

                <div class="profile-header-card">
                    <div class="profile-cover"></div>
                    <div class="profile-info-section">
                        <div class="profile-avatar-container">
                            <div class="profile-avatar">
                                <% if (p.getFoto() != null && !p.getFoto().isEmpty()) { %>
                                    <img src="uploads/<%= p.getFoto() %>" alt="Foto de perfil" style="width:100%;height:100%;object-fit:cover;">
                                <% } else { %>
                                    <%= p.getNombres().substring(0,1) %><%= p.getApellidos().substring(0,1) %>
                                <% } %>
                            </div>
                            <div class="profile-title-section">
                                <h1 class="profile-name"><%= p.getNombres() %> <%= p.getApellidos() %></h1>
                                <div class="profile-role">
                                    <i class="fas fa-chalkboard-teacher"></i>
                                    Docente de <%= p.getAreaNombre() != null ? p.getAreaNombre() : "Área no asignada" %>
                                </div>
                                <div class="profile-code">
                                    <i class="fas fa-id-badge"></i>
                                    <%= p.getCodigoProfesor() != null ? p.getCodigoProfesor() : "Sin código" %>
                                </div>
                            </div>
                        </div>
                        <div class="status-badge-large <%= estadoClass %>">
                            <i class="fas <%= estadoIcon %>"></i>
                            <%= estadoTexto %>
                        </div>
                    </div>
                </div>

                <div class="info-cards-grid">
                    <div class="info-card">
                        <div class="card-header-section">
                            <div class="card-icon card-icon-personal"><i class="fas fa-user"></i></div>
                            <h2 class="card-title">Información Personal</h2>
                        </div>
                        <div class="info-item">
                            <div class="info-icon icon-primary"><i class="fas fa-id-card"></i></div>
                            <div class="info-content">
                                <div class="info-label">DNI</div>
                                <div class="info-value"><%= p.getDni() != null ? p.getDni() : "No registrado" %></div>
                            </div>
                        </div>
                        <div class="info-item">
                            <div class="info-icon icon-success"><i class="fas fa-envelope"></i></div>
                            <div class="info-content">
                                <div class="info-label">Correo Electrónico</div>
                                <div class="info-value"><%= p.getCorreo() != null ? p.getCorreo() : "No registrado" %></div>
                            </div>
                        </div>
                        <div class="info-item">
                            <div class="info-icon icon-info"><i class="fas fa-phone"></i></div>
                            <div class="info-content">
                                <div class="info-label">Teléfono</div>
                                <div class="info-value"><%= p.getTelefono() != null ? p.getTelefono() : "No registrado" %></div>
                            </div>
                        </div>
                        <div class="info-item">
                            <div class="info-icon icon-warning"><i class="fas fa-birthday-cake"></i></div>
                            <div class="info-content">
                                <div class="info-label">Fecha de Nacimiento</div>
                                <div class="info-value"><%= p.getFechaNacimiento() != null ? sdf.format(p.getFechaNacimiento()) : "No registrada" %></div>
                            </div>
                        </div>
                        <div class="info-item">
                            <div class="info-icon icon-danger"><i class="fas fa-map-marker-alt"></i></div>
                            <div class="info-content">
                                <div class="info-label">Dirección</div>
                                <div class="info-value"><%= p.getDireccion() != null ? p.getDireccion() : "No registrada" %></div>
                            </div>
                        </div>
                    </div>

                    <div class="info-card">
                        <div class="card-header-section">
                            <div class="card-icon card-icon-professional"><i class="fas fa-briefcase"></i></div>
                            <h2 class="card-title">Información Profesional</h2>
                        </div>
                        <div class="info-item">
                            <div class="info-icon icon-primary"><i class="fas fa-chalkboard-teacher"></i></div>
                            <div class="info-content">
                                <div class="info-label">Niveles y Áreas que dicta</div>
                                <div class="info-value">
                                    <% if (p.getAsignaciones() != null && !p.getAsignaciones().isEmpty()) { %>
                                        <div class="grid grid-cols-1 gap-3 mt-2">
                                            <% for (int i = 0; i < p.getAsignaciones().size(); i++) {
                                                ProfesorNivelArea asig = p.getAsignaciones().get(i);
                                                String asigClass = "bg-gray-100 text-gray-800 border-gray-300";
                                                switch(asig.getNivel()) {
                                                    case "INICIAL":    asigClass = "bg-pink-100 text-pink-800 border-pink-300";       break;
                                                    case "PRIMARIA":   asigClass = "bg-blue-100 text-blue-800 border-blue-300";       break;
                                                    case "SECUNDARIA": asigClass = "bg-purple-100 text-purple-800 border-purple-300"; break;
                                                }
                                            %>
                                            <div class="flex items-center justify-between p-3 rounded-lg border-2 <%= asigClass %> hover:shadow-md transition-all">
                                                <div class="flex items-center gap-3">
                                                    <div>
                                                        <div class="font-semibold text-sm"><%= asig.getNivel() %></div>
                                                        <div class="text-lg font-bold"><%= asig.getAreaNombre() != null ? asig.getAreaNombre() : "Área #" + asig.getAreaId() %></div>
                                                    </div>
                                                </div>
                                                <% if (asig.isEsPrincipal()) { %>
                                                    <span class="inline-flex items-center gap-1 px-3 py-1 rounded-full bg-yellow-100 text-yellow-800 border border-yellow-300 text-xs font-semibold">
                                                        <i class="fas fa-star"></i> Principal
                                                    </span>
                                                <% } else { %>
                                                    <span class="inline-flex items-center gap-1 px-3 py-1 rounded-full bg-white text-gray-600 border border-gray-300 text-xs">
                                                        Asignación <%= i + 1 %>
                                                    </span>
                                                <% } %>
                                            </div>
                                            <% } %>
                                        </div>
                                        <div class="mt-3 pt-3 border-t border-gray-200 dark:border-gray-700 text-sm text-gray-600 dark:text-gray-400">
                                            <i class="fas fa-info-circle mr-1"></i>
                                            <strong>Total:</strong> <%= p.getAsignaciones().size() %> asignación<%= p.getAsignaciones().size() > 1 ? "es" : "" %>
                                            <% List<String> nivelesUnicos = p.getNivelesDistintos();
                                               if (nivelesUnicos != null && !nivelesUnicos.isEmpty()) { %>
                                                <span class="ml-2">| <i class="fas fa-layer-group mr-1"></i>Niveles: <%= String.join(", ", nivelesUnicos) %></span>
                                            <% } %>
                                        </div>
                                    <% } else { %>
                                        <div class="text-gray-500 italic p-3 bg-gray-50 dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700">
                                            <i class="fas fa-exclamation-triangle mr-2 text-yellow-500"></i>
                                            No hay asignaciones registradas.
                                            <% if (p.getAreaNombre() != null) { %>
                                                <br><span class="text-sm mt-2 block">Área registrada: <strong><%= p.getAreaNombre() %></strong></span>
                                            <% } %>
                                        </div>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                        <div class="info-item">
                            <div class="info-icon icon-info"><i class="fas fa-calendar-check"></i></div>
                            <div class="info-content">
                                <div class="info-label">Fecha de Contratación</div>
                                <div class="info-value"><%= p.getFechaContratacion() != null ? sdf.format(p.getFechaContratacion()) : "No registrada" %></div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="flex justify-between items-center mt-8 pt-6 border-t border-[#e5e7eb] dark:border-gray-700">
                    <a href="ProfesorServlet?accion=listar" class="btn-modern btn-secondary-modern">
                        <i class="fas fa-arrow-left"></i> Volver al Listado
                    </a>
                </div>
            </div>
        </main>
    </div>

    <script>
        function toggleAccessibilityPanel() { document.querySelector('.accessibility-panel').classList.toggle('open'); }
        function setTextSize(size) {
            document.body.classList.remove('large-text','larger-text','largest-text');
            if (size !== 'normal') document.body.classList.add(size + '-text');
            document.body.offsetHeight;
        }
        function setContrast(mode) {
            document.body.classList.remove('high-contrast-invert','high-contrast-yellow');
            if (mode === 'high')   document.body.classList.add('high-contrast-invert');
            if (mode === 'yellow') document.body.classList.add('high-contrast-yellow');
        }
        function toggleMotion()          { document.body.classList.toggle('reduce-motion',    document.getElementById('reduceMotion').checked); }
        function toggleDyslexiaFont()    { document.body.classList.toggle('dyslexia-font',    document.getElementById('dyslexiaFont').checked); }
        function toggleBeigeBackground() { document.body.classList.toggle('beige-background', document.getElementById('beigeBackground').checked); }
        function resetAccessibility() {
            document.body.classList.remove('large-text','larger-text','largest-text','high-contrast-invert','high-contrast-yellow','reduce-motion','dyslexia-font','beige-background');
            ['reduceMotion','dyslexiaFont','beigeBackground'].forEach(id => document.getElementById(id).checked = false);
        }
        document.addEventListener('keydown', e => { if (e.key === 'Escape') document.querySelector('.accessibility-panel').classList.remove('open'); });
    </script>
</body>
</html>
