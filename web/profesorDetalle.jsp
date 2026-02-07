<%@ page import="modelo.Profesor" %>
<%@ page import="modelo.Turno" %>
<%@ page import="modelo.Area" %>
<%@ page import="java.util.List" %>
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
    String estadoClass = "";
    String estadoTexto = "";
    String estadoIcon = "";
    
    switch(estado) {
        case "ACTIVO":
            estadoClass = "status-active";
            estadoTexto = "Activo";
            estadoIcon = "fa-circle-check";
            break;
        case "INACTIVO":
            estadoClass = "status-inactive";
            estadoTexto = "Inactivo";
            estadoIcon = "fa-circle-xmark";
            break;
        case "LICENCIA":
            estadoClass = "status-license";
            estadoTexto = "En Licencia";
            estadoIcon = "fa-clock";
            break;
        case "JUBILADO":
            estadoClass = "status-retired";
            estadoTexto = "Jubilado";
            estadoIcon = "fa-umbrella-beach";
            break;
        default:
            estadoClass = "status-active";
            estadoTexto = estado;
            estadoIcon = "fa-circle";
    }
    
    String nivel = p.getNivel();
    String nivelClass = "";
    String nivelTexto = "";
    
    if (nivel != null) {
        switch(nivel) {
            case "INICIAL":
                nivelClass = "nivel-inicial";
                nivelTexto = "Inicial";
                break;
            case "PRIMARIA":
                nivelClass = "nivel-primaria";
                nivelTexto = "Primaria";
                break;
            case "SECUNDARIA":
                nivelClass = "nivel-secundaria";
                nivelTexto = "Secundaria";
                break;
            case "TODOS":
                nivelClass = "nivel-todos";
                nivelTexto = "Todos los Niveles";
                break;
            default:
                nivelClass = "nivel-todos";
                nivelTexto = nivel;
        }
    } else {
        nivelClass = "nivel-todos";
        nivelTexto = "No asignado";
    }
%>

<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Perfil Profesional - <%= p.getNombres() %> <%= p.getApellidos() %> - San Antonio</title>
    
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
                        "baby-blue": "#89CFF0",
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
        
        /* Accessibility Toggle Button */
        .accessibility-toggle {
            transition: all 0.3s ease;
        }
        
        .accessibility-toggle:hover {
            transform: scale(1.1);
        }
        
        /* Perfil específico */
        .profile-header-card {
            background: white;
            border-radius: 20px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.15);
            overflow: hidden;
            margin-bottom: 2rem;
            position: relative;
        }
        
        .dark .profile-header-card {
            background: #1a2233;
        }
        
        .profile-cover {
            height: 250px;
            background: linear-gradient(135deg, #135bec 0%, #0d47a1 100%);
            position: relative;
            overflow: hidden;
        }
        
        .profile-cover::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1440 320"><path fill="%23ffffff" fill-opacity="0.1" d="M0,96L48,112C96,128,192,160,288,160C384,160,480,128,576,122.7C672,117,768,139,864,154.7C960,171,1056,181,1152,165.3C1248,149,1344,107,1392,85.3L1440,64L1440,320L1392,320C1344,320,1248,320,1152,320C1056,320,960,320,864,320C768,320,672,320,576,320C480,320,384,320,288,320C192,320,96,320,48,320L0,320Z"></path></svg>') no-repeat bottom;
            background-size: cover;
        }
        
        .profile-info-section {
            padding: 0 3rem 2.5rem 3rem;
            position: relative;
            margin-top: -100px;
        }
        
        .profile-avatar-container {
            display: flex;
            align-items: flex-end;
            gap: 2.5rem;
            margin-bottom: 2rem;
        }
        
        .profile-avatar {
            width: 200px;
            height: 200px;
            border-radius: 20px;
            background: linear-gradient(135deg, #3b82f6, #135bec);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 5rem;
            color: white;
            font-weight: 700;
            box-shadow: 0 15px 50px rgba(0, 0, 0, 0.3);
            border: 6px solid white;
            text-transform: uppercase;
            position: relative;
            z-index: 10;
        }
        
        .dark .profile-avatar {
            border: 6px solid #1a2233;
        }
        
        .profile-title-section {
            flex: 1;
            padding-bottom: 1.5rem;
        }
        
        .profile-name {
            font-size: 3rem;
            font-weight: 700;
            color: #89CFF0;
            margin: 0;
            line-height: 1.2;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.1);
        }
        
        .profile-role {
            font-size: 1.3rem;
            color: #6b7280;
            margin-top: 0.75rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }
        
        .dark .profile-role {
            color: #d1d5db;
        }
        
        .profile-code {
            display: inline-flex;
            align-items: center;
            gap: 0.75rem;
            background: #f3f4f6;
            padding: 0.75rem 1.5rem;
            border-radius: 12px;
            font-weight: 600;
            color: #374151;
            margin-top: 1rem;
            font-size: 1.05rem;
        }
        
        .dark .profile-code {
            background: #374151;
            color: #d1d5db;
        }
        
        /* Status Badge */
        .status-badge-large {
            position: absolute;
            top: 2.5rem;
            right: 3rem;
            padding: 1rem 2rem;
            border-radius: 50px;
            font-weight: 700;
            font-size: 1.1rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            display: flex;
            align-items: center;
            gap: 0.75rem;
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.2);
        }
        
        .status-active {
            background: linear-gradient(135deg, #d1fae5, #a7f3d0);
            color: #065f46;
        }
        
        .status-inactive {
            background: linear-gradient(135deg, #fee2e2, #fecaca);
            color: #991b1b;
        }
        
        .status-license {
            background: linear-gradient(135deg, #fef3c7, #fde68a);
            color: #92400e;
        }
        
        .status-retired {
            background: linear-gradient(135deg, #e0e7ff, #c7d2fe);
            color: #3730a3;
        }
        
        .status-badge-large i {
            font-size: 1.2rem;
            animation: pulse 2s infinite;
        }
        
        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }
        
        /* Information Cards */
        .info-cards-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 2rem;
            margin-top: 2rem;
        }
        
        .info-card {
            background: white;
            border-radius: 20px;
            padding: 3rem;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.12);
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
            min-height: 500px;
        }
        
        .dark .info-card {
            background: #1a2233;
        }
        
        .info-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 6px;
            height: 100%;
            background: linear-gradient(180deg, #135bec, #0d47a1);
        }
        
        .info-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 50px rgba(0, 0, 0, 0.18);
        }
        
        .card-header-section {
            display: flex;
            align-items: center;
            gap: 1.5rem;
            margin-bottom: 2rem;
            padding-bottom: 1.5rem;
            border-bottom: 3px solid #f3f4f6;
        }
        
        .dark .card-header-section {
            border-bottom-color: #374151;
        }
        
        .card-icon {
            width: 70px;
            height: 70px;
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2rem;
            color: white;
        }
        
        .card-icon-personal {
            background: linear-gradient(135deg, #667eea, #764ba2);
        }
        
        .card-icon-professional {
            background: linear-gradient(135deg, #f093fb, #f5576c);
        }
        
        .card-title {
            font-size: 1.8rem;
            font-weight: 700;
            color: #1f2937;
            margin: 0;
        }
        
        .dark .card-title {
            color: #f3f4f6;
        }
        
        .info-item {
            display: flex;
            align-items: flex-start;
            gap: 1.5rem;
            padding: 1.25rem 0;
            border-bottom: 1px solid #f3f4f6;
        }
        
        .dark .info-item {
            border-bottom-color: #374151;
        }
        
        .info-item:last-child {
            border-bottom: none;
        }
        
        .info-icon {
            width: 50px;
            height: 50px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            font-size: 1.3rem;
        }
        
        .icon-primary { background: #e0e7ff; color: #135bec; }
        .dark .icon-primary { background: #1e3a8a; color: #93c5fd; }
        
        .icon-success { background: #d1fae5; color: #10b981; }
        .dark .icon-success { background: #064e3b; color: #a7f3d0; }
        
        .icon-warning { background: #fef3c7; color: #f59e0b; }
        .dark .icon-warning { background: #78350f; color: #fde68a; }
        
        .icon-danger { background: #fee2e2; color: #ef4444; }
        .dark .icon-danger { background: #7f1d1d; color: #fca5a5; }
        
        .icon-info { background: #dbeafe; color: #3b82f6; }
        .dark .icon-info { background: #1e3a8a; color: #93c5fd; }
        
        .info-content {
            flex: 1;
        }
        
        .info-label {
            font-size: 0.95rem;
            font-weight: 600;
            color: #6b7280;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 0.5rem;
        }
        
        .dark .info-label {
            color: #9ca3af;
        }
        
        .info-value {
            font-size: 1.2rem;
            font-weight: 600;
            color: #1f2937;
            word-break: break-word;
        }
        
        .dark .info-value {
            color: #f3f4f6;
        }
        
        .info-value.large {
            font-size: 1.4rem;
        }
        
        /* Nivel Badge */
        .nivel-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.75rem;
            padding: 0.75rem 1.5rem;
            border-radius: 12px;
            font-weight: 700;
            font-size: 1.1rem;
            text-transform: uppercase;
        }
        
        .nivel-inicial {
            background: linear-gradient(135deg, #dbeafe, #bfdbfe);
            color: #1e40af;
        }
        
        .nivel-primaria {
            background: linear-gradient(135deg, #d1fae5, #a7f3d0);
            color: #065f46;
        }
        
        .nivel-secundaria {
            background: linear-gradient(135deg, #fef3c7, #fde68a);
            color: #92400e;
        }
        
        .nivel-todos {
            background: linear-gradient(135deg, #e0e7ff, #c7d2fe);
            color: #3730a3;
        }
        
        /* Availability Table */
        .availability-table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0 10px;
        }
        
        .availability-table thead tr {
            background: #f9fafb;
        }
        
        .dark .availability-table thead tr {
            background: #374151;
        }
        
        .availability-table th {
            padding: 1rem;
            color: #135bec;
            font-weight: 600;
            border: none;
        }
        
        .dark .availability-table th {
            color: #60a5fa;
        }
        
        .availability-table tbody tr {
            background: white;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            border-radius: 10px;
        }
        
        .dark .availability-table tbody tr {
            background: #1a2233;
        }
        
        .availability-table td {
            padding: 1rem;
            vertical-align: middle;
            border: none;
        }
        
        .availability-table td:first-child {
            border-radius: 10px 0 0 10px;
        }
        
        .availability-table td:last-child {
            border-radius: 0 10px 10px 0;
        }
        
        /* Responsive */
        @media (max-width: 1200px) {
            .info-cards-grid {
                grid-template-columns: 1fr;
            }
        }
        
        @media (max-width: 768px) {
            .profile-cover {
                height: 180px;
            }
            
            .profile-avatar {
                width: 140px;
                height: 140px;
                font-size: 3.5rem;
            }
            
            .profile-info-section {
                padding: 0 1.5rem 1.5rem 1.5rem;
                margin-top: -70px;
            }
            
            .profile-avatar-container {
                flex-direction: column;
                align-items: center;
                text-align: center;
            }
            
            .profile-name {
                font-size: 2rem;
            }
            
            .status-badge-large {
                position: static;
                margin-top: 1rem;
            }
            
            .info-cards-grid {
                grid-template-columns: 1fr;
            }
            
            .info-card {
                padding: 2rem;
                min-height: auto;
            }
            
            .card-title {
                font-size: 1.4rem;
            }
        }
        
        /* Animations */
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        .profile-header-card,
        .info-card,
        .action-buttons-container {
            animation: fadeInUp 0.6s ease;
        }
        
        .info-card:nth-child(1) { animation-delay: 0.1s; }
        .info-card:nth-child(2) { animation-delay: 0.2s; }
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
                    <a class="flex items-center gap-3 px-3 py-2 rounded-lg bg-primary/10 text-primary font-medium" 
                       href="ProfesorServlet"
                       aria-current="page">
                        <i class="fas fa-chalkboard-teacher" aria-hidden="true"></i>
                        <span class="text-sm">Profesores</span>
                    </a>
                    <a class="flex items-center gap-3 px-3 py-2 rounded-lg text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors" 
                       href="CursoServlet">
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
                            Perfil Profesional
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
                    <h2 class="text-2xl font-bold text-[#111318] dark:text-white">Detalles del Profesor</h2>
                    <p class="text-[#616f89] dark:text-gray-400 mt-1">Información completa del perfil profesional</p>
                </div>
                
                <!-- Alertas -->
                <% 
                    String error = (String) session.getAttribute("error");
                    String mensaje = (String) session.getAttribute("mensaje");
                    
                    if (error != null) { 
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
                
                <!-- Header Card con Avatar -->
                <div class="profile-header-card">
                    <div class="profile-cover"></div>
                    
                    <div class="profile-info-section">
                        <div class="profile-avatar-container">
                            <div class="profile-avatar">
                                <%= p.getNombres().substring(0, 1) + p.getApellidos().substring(0, 1) %>
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
                        
                        <!-- Estado Badge -->
                        <div class="status-badge-large <%= estadoClass %>">
                            <i class="fas <%= estadoIcon %>"></i>
                            <%= estadoTexto %>
                        </div>
                    </div>
                </div>

                <!-- Information Cards Grid -->
                <div class="info-cards-grid">
                    
                    <!-- Card 1: Información Personal -->
                    <div class="info-card">
                        <div class="card-header-section">
                            <div class="card-icon card-icon-personal">
                                <i class="fas fa-user"></i>
                            </div>
                            <h2 class="card-title">Información Personal</h2>
                        </div>
                        
                        <div class="info-item">
                            <div class="info-icon icon-primary">
                                <i class="fas fa-id-card"></i>
                            </div>
                            <div class="info-content">
                                <div class="info-label">DNI</div>
                                <div class="info-value"><%= p.getDni() != null ? p.getDni() : "No registrado" %></div>
                            </div>
                        </div>
                        
                        <div class="info-item">
                            <div class="info-icon icon-success">
                                <i class="fas fa-envelope"></i>
                            </div>
                            <div class="info-content">
                                <div class="info-label">Correo Electrónico</div>
                                <div class="info-value"><%= p.getCorreo() != null ? p.getCorreo() : "No registrado" %></div>
                            </div>
                        </div>
                        
                        <div class="info-item">
                            <div class="info-icon icon-info">
                                <i class="fas fa-phone"></i>
                            </div>
                            <div class="info-content">
                                <div class="info-label">Teléfono</div>
                                <div class="info-value"><%= p.getTelefono() != null ? p.getTelefono() : "No registrado" %></div>
                            </div>
                        </div>
                        
                        <div class="info-item">
                            <div class="info-icon icon-warning">
                                <i class="fas fa-birthday-cake"></i>
                            </div>
                            <div class="info-content">
                                <div class="info-label">Fecha de Nacimiento</div>
                                <div class="info-value">
                                    <%= p.getFechaNacimiento() != null ? sdf.format(p.getFechaNacimiento()) : "No registrada" %>
                                </div>
                            </div>
                        </div>
                        
                        <div class="info-item">
                            <div class="info-icon icon-danger">
                                <i class="fas fa-map-marker-alt"></i>
                            </div>
                            <div class="info-content">
                                <div class="info-label">Dirección</div>
                                <div class="info-value"><%= p.getDireccion() != null ? p.getDireccion() : "No registrada" %></div>
                            </div>
                        </div>
                    </div>

                    <!-- Card 2: Información Profesional -->
                    <div class="info-card">
                        <div class="card-header-section">
                            <div class="card-icon card-icon-professional">
                                <i class="fas fa-briefcase"></i>
                            </div>
                            <h2 class="card-title">Información Profesional</h2>
                        </div>
                        
                        <div class="info-item">
                            <div class="info-icon icon-primary">
                                <i class="fas fa-book"></i>
                            </div>
                            <div class="info-content">
                                <div class="info-label">Especialidad / Área</div>
                                <div class="info-value large">
                                    <%= p.getAreaNombre() != null ? p.getAreaNombre() : "No asignada" %>
                                </div>
                            </div>
                        </div>
                        
                        <div class="info-item">
                            <div class="info-icon icon-success">
                                <i class="fas fa-layer-group"></i>
                            </div>
                            <div class="info-content">
                                <div class="info-label">Nivel que Enseña</div>
                                <div class="info-value">
                                    <span class="nivel-badge <%= nivelClass %>">
                                        <i class="fas fa-graduation-cap"></i>
                                        <%= nivelTexto %>
                                    </span>
                                </div>
                            </div>
                        </div>
                        
                        <div class="info-item">
                            <div class="info-icon icon-warning">
                                <i class="fas fa-clock"></i>
                            </div>
                            <div class="info-content">
                                <div class="info-label">Turno</div>
                                <div class="info-value"><%= p.getTurnoNombre() != null ? p.getTurnoNombre() : "Sin turno" %></div>
                            </div>
                        </div>
                        
                        <div class="info-item">
                            <div class="info-icon icon-info">
                                <i class="fas fa-calendar-check"></i>
                            </div>
                            <div class="info-content">
                                <div class="info-label">Fecha de Contratación</div>
                                <div class="info-value">
                                    <%= p.getFechaContratacion() != null ? sdf.format(p.getFechaContratacion()) : "No registrada" %>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
      
                <!-- BOTONES -->
                <div class="flex justify-between items-center mt-8 pt-6 border-t border-[#e5e7eb] dark:border-gray-700">
                    <div class="flex gap-3">
                        <a href="ProfesorServlet?accion=listar" 
                           class="btn-modern btn-secondary-modern">
                            <i class="fas fa-arrow-left"></i>
                            Volver al Listado
                        </a>
                    </div> 
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
            console.log('? Perfil del profesor cargado');
            
            // Navegación por teclado
            document.addEventListener('keydown', function(e) {
                if (e.key === 'Escape') {
                    const panel = document.querySelector('.accessibility-panel');
                    if (panel && panel.classList.contains('open')) {
                        panel.classList.remove('open');
                    }
                }
            });
        });
    </script>
</body>
</html>