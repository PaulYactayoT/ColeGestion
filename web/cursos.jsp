<%@ page import="java.util.*, java.sql.*, modelo.Curso, modelo.Grado, conexion.Conexion" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%
    String nivelSeleccionado = (String) request.getAttribute("nivelSeleccionado");
    String turnoSeleccionado = (String) request.getAttribute("turnoSeleccionado");
%>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    List<Grado> grados = (List<Grado>) request.getAttribute("grados");
    Integer gradoSeleccionado = (Integer) request.getAttribute("gradoSeleccionado");
    
    String mensaje = (String) session.getAttribute("mensaje");
    String error = (String) session.getAttribute("error");
%>

<%!
    // Método para obtener horarios de un curso
    private String obtenerHorarios(int cursoId) {
        StringBuilder resultado = new StringBuilder();
        try (Connection conn = conexion.Conexion.getConnection()) {
            String sql = "SELECT dia_semana, TIME_FORMAT(hora_inicio, '%H:%i') as inicio, " +
                        "TIME_FORMAT(hora_fin, '%H:%i') as fin " +
                        "FROM horario_clase WHERE curso_id = ? AND eliminado = 0 " +
                        "ORDER BY FIELD(dia_semana, 'LUNES','MARTES','MIERCOLES','JUEVES','VIERNES','SABADO'), hora_inicio";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, cursoId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                if (resultado.length() > 0) resultado.append("; ");
                resultado.append(rs.getString("dia_semana")).append(" ")
                        .append(rs.getString("inicio")).append("-").append(rs.getString("fin"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return resultado.toString();
    }
    
    // Método para obtener nivel de un grado
    private String obtenerNivel(int gradoId) {
        try (Connection conn = conexion.Conexion.getConnection()) {
            String sql = "SELECT nivel FROM grado WHERE id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, gradoId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getString("nivel");
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "-";
    }
    
    // Método para obtener grado_id de un curso
    private int obtenerGradoId(int cursoId) {
        try (Connection conn = conexion.Conexion.getConnection()) {
            String sql = "SELECT grado_id FROM curso WHERE id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, cursoId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt("grado_id");
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
%>

<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Listado de Cursos - San Antonio</title>
    
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Lexend:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
    <!-- Material Symbols -->
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
    
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    
    <script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        "primary": "#135bec",
                        "primary-dark": "#0d47a1",
                        "success": "#10b981",
                        "danger": "#ef4444",
                        "warning": "#f59e0b",
                        "info": "#3b82f6",
                        "background-light": "#f6f6f8",
                        "background-dark": "#101622",
                        "card-light": "#ffffff",
                        "card-dark": "#1a2233",
                        "border-light": "#e5e7eb",
                        "border-dark": "#374151",
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
        
        /* Tamaños de texto - Afectar a toda la página */
        .large-text { 
            font-size: 18px !important; 
        }
        .large-text .form-label,
        .large-text .form-control,
        .large-text .form-select,
        .large-text .text-sm {
            font-size: 16px !important;
        }
        
        .larger-text { 
            font-size: 20px !important; 
        }
        .larger-text .form-label,
        .larger-text .form-control,
        .larger-text .form-select,
        .larger-text .text-sm {
            font-size: 18px !important;
        }
        
        .largest-text { 
            font-size: 22px !important; 
        }
        .largest-text .form-label,
        .largest-text .form-control,
        .largest-text .form-select,
        .largest-text .text-sm {
            font-size: 20px !important;
        }
        
        .dyslexia-font { 
            font-family: Arial !important; 
            font-size: 1.1em !important; 
            line-height: 1.6 !important; 
            letter-spacing: 0.5px !important; 
        }
        
        /* Ocultar elementos de accesibilidad inicialmente */
        .accessibility-panel {
            transform: translateX(100%);
            transition: transform 0.3s ease;
        }
        .accessibility-panel.open {
            transform: translateX(0);
        }
        
        /* Skip to content link */
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
        
        /* Input groups */
        .input-group-icon {
            position: relative;
        }
        
        .input-group-icon i,
        .input-group-icon .material-symbols-outlined {
            position: absolute;
            left: 12px;
            top: 50%;
            transform: translateY(-50%);
            color: #6b7280;
            z-index: 10;
        }
        
        .input-group-icon .form-control,
        .input-group-icon .form-select {
            padding-left: 40px;
        }
        
        /* Alertas */
        .alert-modern {
            border-radius: 0.5rem;
            padding: 1rem 1.25rem;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 1rem;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
            border-left: 4px solid;
        }
        
        .alert-danger {
            background: linear-gradient(135deg, #fee2e2, #fecaca);
            color: #991b1b;
            border-left-color: #ef4444;
        }
        
        .alert-success {
            background: linear-gradient(135deg, #d1fae5, #a7f3d0);
            color: #065f46;
            border-left-color: #10b981;
        }
        
        .alert-info {
            background: linear-gradient(135deg, #dbeafe, #bfdbfe);
            color: #1e40af;
            border-left-color: #3b82f6;
        }
        
        /* Badge */
        .badge {
            padding: 0.35rem 0.85rem;
            border-radius: 9999px;
            font-size: 0.85rem;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 0.25rem;
        }
        
        /* Botones */
        .btn-modern {
            padding: 0.75rem 1.5rem;
            border-radius: 0.5rem;
            font-weight: 600;
            font-size: 0.95rem;
            border: none;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            cursor: pointer;
            text-decoration: none;
        }
        
        .btn-primary-modern {
            background: linear-gradient(135deg, #135bec, #0d47a1);
            color: white;
        }
        
        .btn-primary-modern:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 15px rgba(19, 91, 236, 0.3);
        }
        
        .btn-success-modern {
            background: linear-gradient(135deg, #10b981, #059669);
            color: white;
        }
        
        .btn-success-modern:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 15px rgba(16, 185, 129, 0.3);
        }
        
        .btn-secondary-modern {
            background: #6b7280;
            color: white;
        }
        
        .btn-secondary-modern:hover {
            background: #4b5563;
            transform: translateY(-2px);
        }
        
        .btn-danger-modern {
            background: linear-gradient(135deg, #ef4444, #dc2626);
            color: white;
        }
        
        .btn-danger-modern:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 15px rgba(239, 68, 68, 0.3);
        }
        
        /* Table styles */
        .custom-table {
            border-collapse: separate;
            border-spacing: 0;
            width: 100%;
            background: white;
            border-radius: 0.5rem;
            overflow: hidden;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }
        
        .dark .custom-table {
            background: #1a2233;
        }
        
        .custom-table thead {
            background: linear-gradient(135deg, #135bec 0%, #0d47a1 100%);
        }
        
        .custom-table th {
            padding: 1rem;
            text-align: left;
            font-weight: 600;
            color: white;
            font-size: 0.95rem;
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }
        
        .custom-table tbody tr {
            border-bottom: 1px solid #e5e7eb;
            transition: background-color 0.2s;
        }
        
        .dark .custom-table tbody tr {
            border-bottom: 1px solid #374151;
        }
        
        .custom-table td {
            padding: 1rem;
            color: #374151;
            font-size: 0.95rem;
        }
        
        .dark .custom-table td {
            color: #d1d5db;
        }
        
        /* Section styles */
        .section-divider {
            border: none;
            height: 2px;
            background: linear-gradient(90deg, #135bec, transparent);
            margin: 2rem 0 1.5rem 0;
        }
        
        .section-title {
            color: #135bec;
            font-weight: 600;
            font-size: 1.2rem;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .dark .section-title {
            color: #60a5fa;
        }
        
        /* Tooltip */
        .tooltip-info {
            cursor: help;
            color: #3b82f6;
            margin-left: 0.25rem;
        }
        
        /* Accessibility Toggle Button */
        .accessibility-toggle {
            transition: all 0.3s ease;
        }
        
        .accessibility-toggle:hover {
            transform: scale(1.1);
        }
        
        /* Cards de cursos */
        .card-curso-modern {
            background: white;
            border: 2px solid #e5e7eb;
            border-radius: 1rem;
            overflow: hidden;
            transition: all 0.3s ease;
            box-shadow: 0 2px 15px rgba(0, 0, 0, 0.08);
            height: 100%;
        }
        
        .dark .card-curso-modern {
            background: #1a2233;
            border-color: #374151;
        }
        
        .card-curso-modern:hover {
            transform: translateY(-8px);
            box-shadow: 0 8px 30px rgba(19, 91, 236, 0.15);
            border-color: #135bec;
        }
        
        .card-curso-modern .card-header-modern {
            background: linear-gradient(135deg, #dbeafe, #bfdbfe);
            border-bottom: 2px solid #d1d5db;
            padding: 1.25rem 1.5rem;
        }
        
        .dark .card-curso-modern .card-header-modern {
            background: linear-gradient(135deg, #1e3a8a, #1e40af);
            border-bottom-color: #374151;
        }
        
        .card-curso-modern .card-header-modern h5 {
            color: #1e40af;
            font-weight: 700;
            font-size: 1.1rem;
            margin: 0;
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }
        
        .dark .card-curso-modern .card-header-modern h5 {
            color: #93c5fd;
        }
        
        .card-curso-modern .card-body-modern {
            padding: 1.5rem;
            background: white;
        }
        
        .dark .card-curso-modern .card-body-modern {
            background: #1a2233;
        }
        
        .card-curso-modern .card-text {
            color: #374151;
            font-size: 0.9rem;
            margin-bottom: 1rem;
            line-height: 1.6;
        }
        
        .dark .card-curso-modern .card-text {
            color: #d1d5db;
        }
        
        .card-curso-modern .card-text strong {
            color: #111827;
            font-weight: 600;
        }
        
        .dark .card-curso-modern .card-text strong {
            color: #f9fafb;
        }
        
        .card-curso-modern .card-footer-modern {
            background: #f9fafb;
            border-top: 2px solid #e5e7eb;
            padding: 1rem 1.5rem;
            text-align: center;
        }
        
        .dark .card-curso-modern .card-footer-modern {
            background: #111827;
            border-top-color: #374151;
        }
        
        /* Badges personalizados */
        .badge-horario {
            display: inline-block;
            margin: 0.25rem;
            font-size: 0.75rem;
            padding: 0.4rem 0.8rem;
            border-radius: 0.5rem;
        }
        
        .nivel-badge-modern {
            font-size: 0.85rem;
            padding: 0.5rem 1rem;
            border-radius: 0.75rem;
            font-weight: 600;
        }
        
        /* Animaciones */
        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(-20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        .card-curso-modern {
            animation: fadeIn 0.5s ease;
        }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark text-[#111318] dark:text-white min-h-screen" id="main-content">
    <!-- Skip to content link -->
    <a href="#main-content" class="skip-to-content focus:top-0">Saltar al contenido principal</a>
    
    <!-- Accessibility Panel -->
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
                    <button onclick="setTextSize('large')" class="px-3 py-2 bg-gray-100 rounded hover:bg-gray-200 text-sm">Grande</button>
                    <button onclick="setTextSize('larger')" class="px-3 py-2 bg-gray-100 rounded hover:bg-gray-200 text-sm">Más Grande</button>
                </div>
            </div>
            
            <div class="space-y-2">
                <h4 class="font-medium">Contraste</h4>
                <div class="flex gap-2">
                    <button onclick="setContrast('normal')" class="px-3 py-2 bg-gray-100 rounded hover:bg-gray-200 text-sm">Normal</button>
                    <button onclick="setContrast('high')" class="px-3 py-2 bg-gray-100 rounded hover:bg-gray-200 text-sm">Alto Contraste</button>
                    <button onclick="setContrast('yellow')" class="px-3 py-2 bg-gray-100 rounded hover:bg-gray-200 text-sm">Amarillo/Negro</button>
                </div>
            </div>
            
            <div class="space-y-2">
                <h4 class="font-medium">Otros ajustes</h4>
                <div class="flex flex-col gap-2">
                    <label class="flex items-center gap-2">
                        <input type="checkbox" id="reduceMotion" onchange="toggleMotion()">
                        <span>Reducir movimiento</span>
                    </label>
                    <label class="flex items-center gap-2">
                        <input type="checkbox" id="dyslexiaFont" onchange="toggleDyslexiaFont()">
                        <span>Fuente para dislexia</span>
                    </label>
                    <label class="flex items-center gap-2">
                        <input type="checkbox" id="beigeBackground" onchange="toggleBeigeBackground()">
                        <span>Fondo beige</span>
                    </label>
                </div>
            </div>
            
            <button onclick="resetAccessibility()" class="w-full py-2 bg-gray-800 text-white rounded hover:bg-gray-900">
                Restablecer ajustes
            </button>
        </div>
    </div>
    
    <!-- Accessibility Toggle Button -->
    <button onclick="toggleAccessibilityPanel()" 
            class="fixed top-20 right-0 z-40 bg-primary text-white p-3 rounded-l-lg shadow-lg hover:bg-blue-700 transition-colors accessibility-toggle"
            aria-label="Abrir panel de accesibilidad">
        <span class="material-symbols-outlined">accessibility_new</span>
    </button>
    
    <div class="flex h-screen overflow-hidden">
        <!-- Left SideNavBar -->
        <aside class="w-64 flex-shrink-0 bg-white dark:bg-[#1a2233] border-r border-[#dbdfe6] dark:border-gray-700 flex flex-col justify-between">
            <div class="flex flex-col gap-8 p-6">
                <!-- Brand -->
                <div class="flex items-center gap-3">
                    <div class="bg-primary size-10 rounded-lg flex items-center justify-center text-white" aria-hidden="true">
                        <span class="material-symbols-outlined">school</span>
                    </div>
                    <div class="flex flex-col">
                        <h1 class="text-[#111318] dark:text-white text-lg font-bold leading-tight">San Antonio</h1>
                        <p class="text-[#616f89] dark:text-gray-400 text-xs font-normal">Gestión Académica</p>
                    </div>
                </div>
                
                <!-- Navigation -->
                <nav class="flex flex-col gap-2" aria-label="Navegación principal">
                    <a class="flex items-center gap-3 px-3 py-2 rounded-lg text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors" 
                       href="dashboard.jsp">
                        <span class="material-symbols-outlined">dashboard</span>
                        <span class="text-sm">Dashboard</span>
                    </a>
                    <a class="flex items-center gap-3 px-3 py-2 rounded-lg text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors" 
                       href="AlumnoServlet">
                        <i class="fas fa-user-graduate" aria-hidden="true"></i>
                        <span class="text-sm">Estudiantes</span>
                    </a>
                    <a class="flex items-center gap-3 px-3 py-2 rounded-lg text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors" 
                       href="ProfesorServlet">
                        <i class="fas fa-chalkboard-teacher" aria-hidden="true"></i>
                        <span class="text-sm">Profesores</span>
                    </a>
                    <a class="flex items-center gap-3 px-3 py-2 rounded-lg bg-primary/10 text-primary font-medium" 
                       href="CursoServlet"
                       aria-current="page">
                        <i class="fas fa-book" aria-hidden="true"></i>
                        <span class="text-sm">Cursos</span>
                    </a>
                    <a class="flex items-center gap-3 px-3 py-2 rounded-lg text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors" 
                       href="GradoServlet">
                        <i class="fas fa-layer-group" aria-hidden="true"></i>
                        <span class="text-sm">Grados</span>
                    </a>
                    <a class="flex items-center gap-3 px-3 py-2 rounded-lg text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors" 
                       href="UsuarioServlet">
                        <i class="fas fa-users-cog" aria-hidden="true"></i>
                        <span class="text-sm">Usuarios</span>
                    </a>
                </nav>
            </div>
            
            <!-- Footer Sidebar -->
            <div class="p-6 border-t border-[#dbdfe6] dark:border-gray-700">
                <a href="LogoutServlet" 
                   class="flex w-full items-center justify-center gap-2 rounded-lg h-10 px-4 bg-primary text-white text-sm font-bold tracking-wide hover:bg-blue-700 transition-colors">
                    <span class="material-symbols-outlined text-[18px]" aria-hidden="true">logout</span>
                    <span>Cerrar Sesión</span>
                </a>
            </div>
        </aside>
        
        <!-- Main Content -->
        <main class="flex-1 flex flex-col overflow-y-auto">
            <!-- TopNavBar -->
            <header class="flex items-center justify-between bg-white dark:bg-[#1a2233] border-b border-[#f0f2f4] dark:border-gray-700 px-8 py-3 sticky top-0 z-10">
                <div class="flex items-center gap-4 flex-1">
                    <div class="flex items-center gap-3">
                        <h1 class="text-xl font-bold text-[#111318] dark:text-white">
                            Gestión de Cursos
                        </h1>
                    </div>
                </div>
                
                <div class="flex items-center gap-4 ml-8">
                    <button class="p-2 text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg relative"
                            aria-label="Notificaciones">
                        <span class="material-symbols-outlined">notifications</span>
                        <span class="absolute top-2 right-2 size-2 bg-red-500 rounded-full border-2 border-white"></span>
                    </button>
                    
                    <button class="p-2 text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg"
                            aria-label="Configuración">
                        <span class="material-symbols-outlined">settings</span>
                    </button>
                    
                    <div class="h-8 w-[1px] bg-gray-200 dark:bg-gray-700 mx-2" aria-hidden="true"></div>
                    
                    <div class="flex items-center gap-3">
                        <p class="text-sm font-medium hidden md:block">
                            <%= session.getAttribute("usuario") != null ? session.getAttribute("usuario") : "Administrador" %>
                        </p>
                        <div class="size-10 rounded-full bg-cover bg-center border-2 border-primary/20" 
                             style="background-image: url('https://lh3.googleusercontent.com/aida-public/AB6AXuCO64ytW7WFj5YJ0XxtUSKDLHtMumvYdpNUpuyZfiJ1u2v-o-ZSRqiNGLyx6pmhB7nZDuPBYTD_VLKKCEUg0atLHJC4hTrMG5QjAfNlLQdzKId6L3tl2-QhmWJUVQVRr4hk7ODNpJ2OomnFQx_u6WT5QgxJRWLtvZ2I5ecv8WfcR1-MoMfF485fYSxo5s9ErvyApFtN9ro0oew7DMrNHFDQJp1zE9Dtyls43R9C7cnQa5HNlhDoiFBsEBf8CYKzebhaA6Yfuad3vcM');"
                             aria-label="Foto de perfil del administrador">
                        </div>
                    </div>
                </div>
            </header>
            
            <!-- Main Content -->
            <div class="p-8">
                <!-- Header con título -->
                <div class="mb-6">
                    <h2 class="text-2xl font-bold text-[#111318] dark:text-white">Listado de Cursos</h2>
                    <p class="text-[#616f89] dark:text-gray-400 mt-1">Consulta y gestiona los cursos académicos</p>
                </div>
                
                <!-- Alertas -->
                <% if (error != null) { 
                    session.removeAttribute("error");
                %>
                <div class="alert-modern alert-danger mb-6" role="alert">
                    <i class="fas fa-exclamation-circle"></i>
                    <div>
                        <strong>Error:</strong> <%= error %>
                    </div>
                </div>
                <% } %>
                
                <% if (mensaje != null) { 
                    session.removeAttribute("mensaje");
                %>
                <div class="alert-modern alert-success mb-6" role="alert">
                    <i class="fas fa-check-circle"></i>
                    <div>
                        <strong>Éxito:</strong> <%= mensaje %>
                    </div>
                </div>
                <% } %>
                
                <!-- SECCIÓN: FILTROS -->
                <div class="bg-white dark:bg-card-dark rounded-xl border border-[#dbdfe6] dark:border-gray-700 shadow-sm overflow-hidden mb-8">
                    <div class="border-b border-[#f0f2f4] dark:border-gray-700 p-6" style="background: linear-gradient(135deg, #135bec, #0d47a1);">
                        <h3 class="text-xl font-bold text-white flex items-center gap-2">
                            <i class="fas fa-filter"></i>
                            Filtros de Búsqueda
                        </h3>
                    </div>
                    
                    <div class="p-6">
                        <form action="CursoServlet" method="get">
                            <input type="hidden" name="accion" value="filtrar">
                            
                            <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
                                <!-- Filtro Nivel -->
                                <div>
                                    <label for="nivel" class="block text-sm font-medium text-[#111318] dark:text-white mb-2">
                                        <i class="fas fa-layer-group mr-2"></i>Nivel
                                    </label>
                                    <div class="input-group-icon">
    
                                        <select name="nivel" id="nivel" class="w-full p-3 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-gray-800 focus:ring-2 focus:ring-primary focus:border-transparent">
                                            <option value="">Todos los niveles</option>
                                            <option value="INICIAL" <%= "INICIAL".equals(nivelSeleccionado) ? "selected" : "" %>>INICIAL</option>
                                            <option value="PRIMARIA" <%= "PRIMARIA".equals(nivelSeleccionado) ? "selected" : "" %>>PRIMARIA</option>
                                            <option value="SECUNDARIA" <%= "SECUNDARIA".equals(nivelSeleccionado) ? "selected" : "" %>>SECUNDARIA</option>
                                        </select>
                                    </div>
                                </div>

                                <!-- Filtro Turno -->
                                <div>
                                    <label for="turno" class="block text-sm font-medium text-[#111318] dark:text-white mb-2">
                                        <i class="fas fa-clock mr-2"></i>Turno
                                    </label>
                                    <div class="input-group-icon">
     
                                        <select name="turno" id="turno" class="w-full p-3 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-gray-800 focus:ring-2 focus:ring-primary focus:border-transparent">
                                            <option value="">Todos los turnos</option>
                                            <option value="MAÑANA" <%= "MAÑANA".equals(turnoSeleccionado) ? "selected" : "" %>>MAÑANA</option>
                                            <option value="TARDE" <%= "TARDE".equals(turnoSeleccionado) ? "selected" : "" %>>TARDE</option>
                                        </select>
                                    </div>
                                </div>

                                <!-- Filtro Grado -->
                                <div>
                                    <label for="grado_id" class="block text-sm font-medium text-[#111318] dark:text-white mb-2">
                                        <i class="fas fa-graduation-cap mr-2"></i>Grado
                                    </label>
                                    <div class="input-group-icon">
                                        <select name="grado_id" id="grado_id" class="w-full p-3 border border-gray-300 dark:border-gray-700 rounded-lg bg-white dark:bg-gray-800 focus:ring-2 focus:ring-primary focus:border-transparent">
                                            <option value="">Todos los grados</option>
                                            <% if (grados != null) {
                                                for (Grado g : grados) { %>
                                            <option value="<%= g.getId()%>" <%= (gradoSeleccionado != null && gradoSeleccionado == g.getId()) ? "selected" : ""%>>
                                                <%= g.getNombre()%> - <%= g.getNivel()%>
                                            </option>
                                            <% }
                                            } %>
                                        </select>
                                    </div>
                                </div>

                                <!-- Botón Filtrar -->
                                <div class="flex items-end">
                                    <button type="submit" class="btn-modern btn-primary-modern w-full">
                                        <i class="fas fa-search"></i> Filtrar Cursos
                                    </button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
                
                <!-- BOTÓN REGISTRAR -->
                <div class="flex justify-between items-center mb-8">
                    <div></div>
                    <a href="RegistroCursoServlet?accion=cargarFormulario" class="btn-modern btn-success-modern">
                        <i class="fas fa-plus"></i> Registrar Nuevo Curso
                    </a>
                </div>
                
                <!-- GRID DE CARDS -->
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    <%
                        List<Curso> lista = (List<Curso>) request.getAttribute("lista");

                        if (lista != null && !lista.isEmpty()) {
                            for (Curso c : lista) {
                                // Obtener datos adicionales
                                int gradoId = obtenerGradoId(c.getId());
                                String nivel = obtenerNivel(gradoId);
                                String horarios = obtenerHorarios(c.getId());
                                
                                // Colores para badges de nivel
                                String badgeColor = "bg-gray-200 text-gray-800";
                                if ("INICIAL".equals(nivel)) badgeColor = "bg-blue-100 text-blue-800";
                                else if ("PRIMARIA".equals(nivel)) badgeColor = "bg-primary text-white";
                                else if ("SECUNDARIA".equals(nivel)) badgeColor = "bg-green-100 text-green-800";
                    %>
                    <div class="card-curso-modern">
                        <div class="card-header-modern">
                            <h5>
                                <i class="fas fa-graduation-cap"></i>
                                <%= c.getNombre()%>
                            </h5>
                        </div>
                        <div class="card-body-modern">
                            <!-- NIVEL -->
                            <p class="card-text">
                                <strong>Nivel:</strong><br>
                                <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium <%= badgeColor %> nivel-badge-modern">
                                    <i class="fas fa-layer-group mr-1"></i>
                                    <%= nivel%>
                                </span>
                            </p>
                            
                            <!-- GRADO -->
                            <p class="card-text">
                                <strong>Grado:</strong><br>
                                <span class="text-[#111318] dark:text-white"><%= c.getGradoNombre() != null ? c.getGradoNombre() : "-" %></span>
                            </p>
                            
                            <!-- PROFESOR -->
                            <p class="card-text">
                                <strong>Profesor:</strong><br>
                                <span class="text-[#111318] dark:text-white"><%= c.getProfesorNombre() != null ? c.getProfesorNombre() : "-" %></span>
                            </p>
                            
                            <!-- HORARIOS -->
                            <p class="card-text">
                                <strong>Horarios:</strong><br>
                                <div class="mt-2">
                                    <% if (horarios != null && !horarios.isEmpty()) {
                                        String[] horariosArray = horarios.split("; ");
                                        for (String h : horariosArray) {
                                            String[] partes = h.split(" ");
                                            if (partes.length >= 2) {
                                                String dia = partes[0];
                                                String hora = partes[1];
                                                String colorDia = "bg-gray-100 text-gray-800";
                                                switch(dia) {
                                                    case "LUNES": colorDia = "bg-blue-100 text-blue-800"; break;
                                                    case "MARTES": colorDia = "bg-green-100 text-green-800"; break;
                                                    case "MIERCOLES": colorDia = "bg-purple-100 text-purple-800"; break;
                                                    case "JUEVES": colorDia = "bg-yellow-100 text-yellow-800"; break;
                                                    case "VIERNES": colorDia = "bg-red-100 text-red-800"; break;
                                                    case "SABADO": colorDia = "bg-indigo-100 text-indigo-800"; break;
                                                }
                                    %>
                                    <span class="inline-flex items-center px-2 py-1 rounded text-xs font-medium <%= colorDia %> badge-horario mr-1 mb-1">
                                        <i class="fas fa-clock mr-1 text-xs"></i>
                                        <%= dia%> <%= hora%>
                                    </span>
                                    <% 
                                            }
                                        }
                                    } else { 
                                    %>
                                    <span class="text-gray-500 dark:text-gray-400 text-sm">Sin horarios asignados</span>
                                    <% } %>
                                </div>
                            </p>
                        </div>
                        <div class="card-footer-modern">
                            <!-- ACCIONES -->
                            <div class="flex justify-center gap-2">
                                <a href="CursoServlet?accion=editar&id=<%= c.getId()%>" class="btn-modern btn-primary-modern btn-sm">
                                    <i class="fas fa-edit"></i> Editar
                                </a>
                                <a href="CursoServlet?accion=eliminar&id=<%= c.getId()%>" 
                                   class="btn-modern btn-danger-modern btn-sm"
                                   onclick="return confirm('¿Está seguro de eliminar este curso?')">
                                    <i class="fas fa-trash"></i> Eliminar
                                </a>
                            </div>
                        </div>
                    </div>
                    <%
                        }
                    } else {
                    %>
                    <div class="col-span-full">
                        <div class="alert-modern alert-info text-center">
                            <i class="fas fa-info-circle"></i>
                            <div>
                                <strong>No hay cursos registrados</strong><br>
                                <span class="text-sm">Comienza registrando un nuevo curso</span>
                            </div>
                        </div>
                    </div>
                    <%
                        }
                    %>
                </div>
            </div>
        </main>
    </div>

    <script>
        // ==================== FUNCIONES DE ACCESIBILIDAD ====================
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
            document.body.offsetHeight; // Forzar reflow
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
        
        // Toast notifications
        function showToast(message, type = 'info') {
            const toast = document.createElement('div');

            // Determinar estilo según tipo
            let bgClass = 'bg-blue-600';
            let iconClass = 'fa-info-circle';

            if (type === 'success') {
                bgClass = 'bg-green-600';
                iconClass = 'fa-check-circle';
            } else if (type === 'error') {
                bgClass = 'bg-red-600';
                iconClass = 'fa-exclamation-circle';
            }

            toast.className = 'fixed top-4 right-4 z-50 p-4 rounded-lg shadow-lg text-white ' + bgClass;
            toast.innerHTML = `
                <div class="flex items-center gap-2">
                    <i class="fas ${iconClass}"></i>
                    <span>${message}</span>
                </div>
            `;

            document.body.appendChild(toast);

            setTimeout(() => {
                toast.remove();
            }, 5000);
        }
        
        // Event listeners
        document.addEventListener('DOMContentLoaded', function() {
            console.log('? Listado de cursos cargado');
            
            // Navegación por teclado
            document.addEventListener('keydown', function(e) {
                if (e.key === 'Escape') {
                    const panel = document.querySelector('.accessibility-panel');
                    if (panel && panel.classList.contains('open')) {
                        panel.classList.remove('open');
                    }
                }
            });
            
            // Auto-focus en primer campo de filtro
            setTimeout(() => {
                const nivelField = document.getElementById('nivel');
                if (nivelField) {
                    nivelField.focus();
                }
            }, 100);
        });
    </script>
</body>
</html>