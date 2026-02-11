<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Asistencia, java.util.List, java.time.format.DateTimeFormatter" %>
<%@ page import="modelo.Padre" %>
<%
    // DEBUG: Mostrar todos los atributos de sesión
    System.out.println("=== DEBUG justificarAusencia.jsp ===");
    System.out.println("📝 URI solicitada: " + request.getRequestURI());
    
    java.util.Enumeration<String> sessionAttrs = session.getAttributeNames();
    while (sessionAttrs.hasMoreElements()) {
        String attrName = sessionAttrs.nextElement();
        Object attrValue = session.getAttribute(attrName);
        System.out.println("SESSION: " + attrName + " = " + attrValue);
    }
    
    // Verificar si hay padre en sesión
    Padre padre = (Padre) session.getAttribute("padre");
    if (padre != null) {
        System.out.println("✅ PADRE EN SESIÓN: " + padre.getNombreCompleto());
        System.out.println("📋 PADRE PersonaId: " + padre.getPersonaId());
        System.out.println("👤 PADRE AlumnoId: " + padre.getAlumnoId());
        System.out.println("🔑 PADRE Username: " + padre.getUsername());
    } else {
        System.out.println("❌ NO HAY PADRE EN SESIÓN");
    }
    
    // Intentar obtener personaId de diferentes maneras
    Integer personaId = (Integer) session.getAttribute("personaId");
    if (personaId == null && padre != null) {
        personaId = padre.getPersonaId();
        session.setAttribute("personaId", personaId);
        System.out.println("✅ PersonaId obtenido del objeto Padre: " + personaId);
    }
    
    System.out.println("==================================");
    
    // Resto del código original...
    List<Asistencia> ausencias = (List<Asistencia>) request.getAttribute("ausencias");
    Integer alumnoId = (Integer) request.getAttribute("alumnoId");
    String alumnoNombre = (String) request.getAttribute("alumnoNombre");
    String error = (String) request.getAttribute("error");
    String mensaje = (String) request.getAttribute("mensaje");
    
    // Si no hay datos, mostrar mensaje y botón para ir al dashboard
    if (alumnoId == null) {
%>
<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Justificar Ausencia - Sistema Escolar</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Lexend:wght@300;400;500;600;700&display=swap" rel="stylesheet">
</head>
<body class="bg-[#f6f6f8] font-['Lexend']">
    <div class="container mx-auto mt-20 px-4">
        <div class="max-w-md mx-auto bg-gradient-to-br from-yellow-50 to-yellow-100 border-l-4 border-yellow-500 rounded-lg p-6 shadow-lg">
            <h4 class="text-xl font-bold text-yellow-800 mb-3">Información no disponible</h4>
            <p class="text-yellow-700 mb-4">No se encontraron datos del estudiante. Por favor, regrese al dashboard e intente nuevamente.</p>
            <hr class="my-4 border-yellow-300">
            <a href="PadreDashboardServlet" class="inline-block bg-gradient-to-r from-blue-500 to-blue-600 text-white px-6 py-3 rounded-lg font-semibold hover:from-blue-600 hover:to-blue-700 transition-all">
                Volver al Dashboard
            </a>
        </div>
    </div>
</body>
</html>
<%
        return;
    }
    
    // Manejar mensajes de sesión
    if (error == null) {
        error = (String) session.getAttribute("error");
        if (error != null) session.removeAttribute("error");
    }
    
    if (mensaje == null) {
        mensaje = (String) session.getAttribute("mensaje");
        if (mensaje != null) session.removeAttribute("mensaje");
    }
    
    // Asegurar que ausencias no sea null
    if (ausencias == null) {
        ausencias = new java.util.ArrayList<>();
    }
    
    String alumnoIdStr = (alumnoId != null) ? String.valueOf(alumnoId) : "";
    
    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
%>
<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Justificar Ausencia - Sistema Escolar</title>
    
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Lexend:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
    <!-- Material Symbols -->
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
    
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    
    <!-- SweetAlert2 -->
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    
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
                    },
                    fontFamily: {
                        "display": ["Lexend"]
                    },
                },
            },
        }
    </script>
    
    <style>
        body { font-family: 'Lexend', sans-serif; }
        .material-symbols-outlined {
            font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
        }
        
        .alert-modern {
            border-radius: 0.75rem;
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
        
        .alert-warning {
            background: linear-gradient(135deg, #fef3c7, #fde68a);
            color: #92400e;
            border-left-color: #f59e0b;
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
        
        .file-upload-area {
            border: 2px dashed #93c5fd;
            border-radius: 0.75rem;
            padding: 2rem;
            text-align: center;
            background: linear-gradient(135deg, #dbeafe, #bfdbfe);
            transition: all 0.3s ease;
            cursor: pointer;
        }
        
        .file-upload-area:hover {
            border-color: #135bec;
            background: linear-gradient(135deg, #bfdbfe, #93c5fd);
        }
        
        .ausencia-card {
            background: white;
            border-radius: 0.75rem;
            padding: 1.5rem;
            margin-bottom: 1rem;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
            border-left: 4px solid #ef4444;
            transition: all 0.3s ease;
        }
        
        .ausencia-card:hover {
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            transform: translateY(-2px);
        }
    </style>
</head>
<body class="bg-[#f6f6f8] text-[#111318] min-h-screen">
    
    <div class="flex h-screen overflow-hidden">
        <!-- Left SideNavBar -->
        <aside class="w-64 flex-shrink-0 bg-white border-r border-[#dbdfe6] flex flex-col justify-between">
            <div class="flex flex-col gap-8 p-6">
                <!-- Brand -->
                <div class="flex items-center gap-3">
                    <div class="bg-primary size-10 rounded-lg flex items-center justify-center text-white">
                        <span class="material-symbols-outlined">school</span>
                    </div>
                    <div class="flex flex-col">
                        <h1 class="text-[#111318] text-lg font-bold">San Antonio</h1>
                        <p class="text-[#616f89] text-xs">Gestión Académica</p>
                    </div>
                </div>
                
                <!-- Navigation -->
                <nav class="flex flex-col gap-2">
                    <a class="flex items-center gap-3 px-3 py-2 rounded-lg text-[#616f89] hover:bg-gray-100" 
                       href="PadreDashboardServlet">
                        <span class="material-symbols-outlined">dashboard</span>
                        <span class="text-sm">Dashboard</span>
                    </a>
                    <a class="flex items-center gap-3 px-3 py-2 rounded-lg text-[#616f89] hover:bg-gray-100" 
                       href="AsistenciaServlet?accion=verPadre">
                        <i class="fas fa-calendar-check"></i>
                        <span class="text-sm">Asistencias</span>
                    </a>
                    <a class="flex items-center gap-3 px-3 py-2 rounded-lg bg-primary text-white" 
                       href="JustificacionServlet?accion=form">
                        <i class="fas fa-file-medical"></i>
                        <span class="text-sm">Justificar Ausencia</span>
                    </a>
                </nav>
            </div>
            
            <!-- User Info -->
            <div class="p-6 border-t border-[#dbdfe6]">
                <div class="flex items-center gap-3">
                    <div class="bg-primary size-10 rounded-full flex items-center justify-center text-white font-semibold">
                        <% if (padre != null) { %>
                            <%= padre.getNombreCompleto().substring(0, 1).toUpperCase() %>
                        <% } else { %>
                            P
                        <% } %>
                    </div>
                    <div class="flex-1 overflow-hidden">
                        <p class="text-sm font-semibold text-[#111318] truncate">
                            <% if (padre != null) { %>
                                <%= padre.getNombreCompleto() %>
                            <% } else { %>
                                Padre de Familia
                            <% } %>
                        </p>
                        <p class="text-xs text-[#616f89]">Apoderado</p>
                    </div>
                </div>
                <a href="logout.jsp" class="mt-4 flex items-center gap-2 px-3 py-2 rounded-lg text-sm text-danger hover:bg-red-50 transition-colors">
                    <span class="material-symbols-outlined">logout</span>
                    <span>Cerrar Sesión</span>
                </a>
            </div>
        </aside>

        <!-- Main Content -->
        <main class="flex-1 overflow-y-auto">
            <!-- Top Bar -->
            <div class="bg-white border-b border-[#dbdfe6] px-8 py-4 sticky top-0 z-10">
                <div class="flex items-center justify-between">
                    <div>
                        <h2 class="text-2xl font-bold text-[#111318]">
                            <i class="fas fa-file-medical text-primary mr-2"></i>
                            Justificar Ausencia
                        </h2>
                        <p class="text-sm text-[#616f89] mt-1">
                            Complete el formulario para justificar las ausencias de 
                            <% if (alumnoNombre != null) { %>
                                <strong class="text-primary"><%= alumnoNombre %></strong>
                            <% } else { %>
                                su hijo(a)
                            <% } %>
                        </p>
                    </div>
                    <a href="AsistenciaServlet?accion=verPadre" class="px-4 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors flex items-center gap-2">
                        <i class="fas fa-arrow-left"></i>
                        <span>Volver</span>
                    </a>
                </div>
            </div>

            <!-- Content Area -->
            <div class="p-8">
                <!-- Mensajes de alerta -->
                <% if (error != null && !error.isEmpty()) { %>
                <div class="alert-modern alert-danger">
                    <i class="fas fa-exclamation-circle text-2xl"></i>
                    <div>
                        <strong class="block font-semibold">Error</strong>
                        <span><%= error %></span>
                    </div>
                </div>
                <% } %>
                
                <% if (mensaje != null && !mensaje.isEmpty()) { %>
                <div class="alert-modern alert-success">
                    <i class="fas fa-check-circle text-2xl"></i>
                    <div>
                        <strong class="block font-semibold">Éxito</strong>
                        <span><%= mensaje %></span>
                    </div>
                </div>
                <% } %>

                <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                    <!-- Formulario Principal -->
                    <div class="lg:col-span-2">
                        <div class="bg-white rounded-xl shadow-sm border border-[#dbdfe6] p-6">
                            <% if (ausencias == null || ausencias.isEmpty()) { %>
                            <div class="alert-modern alert-warning">
                                <i class="fas fa-info-circle text-2xl"></i>
                                <div>
                                    <strong class="block font-semibold">No hay ausencias pendientes</strong>
                                    <span>El estudiante <strong><%= alumnoNombre %></strong> no tiene ausencias pendientes de justificación en este momento.</span>
                                </div>
                            </div>
                            <div class="text-center py-8">
                                <i class="fas fa-check-circle text-6xl text-success mb-4"></i>
                                <p class="text-lg text-gray-600">¡Todo al día!</p>
                            </div>
                            <% } else { %>
                            <form id="formJustificacion" action="JustificacionServlet" method="post" enctype="multipart/form-data">
                                <input type="hidden" name="accion" value="crear">
                                <input type="hidden" name="alumnoId" value="<%= alumnoIdStr %>">
                                
                                <!-- Selección de Ausencia -->
                                <div class="mb-6">
                                    <h3 class="section-title">
                                        <i class="fas fa-calendar-times"></i>
                                        Seleccionar Ausencia
                                    </h3>
                                    <label class="block text-sm font-medium text-gray-700 mb-2">
                                        Ausencia a justificar <span class="text-red-500">*</span>
                                    </label>
                                    <select name="asistenciaId" id="asistenciaId" 
                                            class="w-full px-4 py-3 border-2 border-gray-200 rounded-lg focus:border-primary focus:ring-2 focus:ring-primary/20 transition-all"
                                            required>
                                        <option value="">-- Seleccione una ausencia --</option>
                                        <% for (Asistencia a : ausencias) { %>
                                        <option value="<%= a.getId() %>" 
                                                data-fecha="<%= a.getFecha().format(dateFormatter) %>">
                                            <%= a.getFecha().format(dateFormatter) %> - 
                                            <%= a.getCursoNombre() %> - 
                                            <%= a.getEstadoString() %>
                                        </option>
                                        <% } %>
                                    </select>
                                    <p class="text-xs text-gray-500 mt-2">
                                        <i class="fas fa-info-circle"></i>
                                        Total de ausencias sin justificar: <strong><%= ausencias.size() %></strong>
                                    </p>
                                </div>

                                <!-- Tipo de Justificación -->
                                <div class="mb-6">
                                    <h3 class="section-title">
                                        <i class="fas fa-list-alt"></i>
                                        Tipo de Justificación
                                    </h3>
                                    <label class="block text-sm font-medium text-gray-700 mb-2">
                                        Motivo <span class="text-red-500">*</span>
                                    </label>
                                    <select name="tipoJustificacion" id="tipoJustificacion" 
                                            class="w-full px-4 py-3 border-2 border-gray-200 rounded-lg focus:border-primary focus:ring-2 focus:ring-primary/20 transition-all"
                                            required>
                                        <option value="">-- Seleccione el motivo --</option>
                                        <option value="ENFERMEDAD">Enfermedad</option>
                                        <option value="EMERGENCIA_FAMILIAR">Emergencia Familiar</option>
                                        <option value="CITA_MEDICA">Cita Médica</option>
                                        <option value="OTRO">Otro</option>
                                    </select>
                                </div>

                                <!-- Descripción -->
                                <div class="mb-6">
                                    <h3 class="section-title">
                                        <i class="fas fa-align-left"></i>
                                        Descripción Detallada
                                    </h3>
                                    <label class="block text-sm font-medium text-gray-700 mb-2">
                                        Detalles <span class="text-red-500">*</span>
                                    </label>
                                    <textarea name="descripcion" id="descripcion" rows="5" 
                                              class="w-full px-4 py-3 border-2 border-gray-200 rounded-lg focus:border-primary focus:ring-2 focus:ring-primary/20 transition-all resize-none"
                                              placeholder="Describa detalladamente el motivo de la ausencia (mínimo 20 caracteres)..."
                                              required></textarea>
                                    <div class="flex justify-between items-center mt-2">
                                        <p class="text-xs text-gray-500">
                                            <i class="fas fa-info-circle"></i>
                                            Mínimo 20 caracteres
                                        </p>
                                        <p class="text-xs text-gray-500" id="charCount">(0 caracteres)</p>
                                    </div>
                                </div>

                                <!-- Documento Adjunto -->
                                <div class="mb-6">
                                    <h3 class="section-title">
                                        <i class="fas fa-paperclip"></i>
                                        Documento de Respaldo
                                    </h3>
                                    <label class="block text-sm font-medium text-gray-700 mb-2">
                                        Archivo adjunto (opcional)
                                    </label>
                                    <div class="file-upload-area" onclick="document.getElementById('archivo').click()">
                                        <i class="fas fa-cloud-upload-alt text-4xl text-primary mb-3"></i>
                                        <p class="text-sm font-semibold text-gray-700 mb-1">Click para seleccionar archivo</p>
                                        <p class="text-xs text-gray-500">Formatos permitidos: PDF, Word (.doc, .docx), Imágenes (JPG, PNG)</p>
                                        <p class="text-xs text-gray-500 mt-1">Tamaño máximo: 5MB</p>
                                    </div>
                                    <input type="file" name="archivo" id="archivo" 
                                           accept=".pdf,.doc,.docx,.jpg,.jpeg,.png"
                                           class="hidden" 
                                           onchange="previewFileName(this)">
                                    
                                    <!-- Preview del archivo -->
                                    <div id="filePreview" class="mt-3 p-4 bg-blue-50 rounded-lg border border-blue-200 hidden">
                                        <div class="flex items-center justify-between">
                                            <div class="flex items-center gap-3">
                                                <i class="fas fa-file-alt text-2xl text-primary"></i>
                                                <div>
                                                    <p class="text-sm font-semibold text-gray-700" id="fileName"></p>
                                                    <p class="text-xs text-gray-500">Archivo seleccionado</p>
                                                </div>
                                            </div>
                                            <button type="button" onclick="clearFile()" 
                                                    class="px-3 py-1 bg-red-500 text-white rounded-lg hover:bg-red-600 transition-colors text-sm">
                                                <i class="fas fa-times"></i>
                                            </button>
                                        </div>
                                    </div>
                                </div>

                                <!-- Botón de envío -->
                                <div class="flex items-center gap-4 pt-6 border-t border-gray-200">
                                    <button type="submit" id="btn-enviar"
                                            class="flex-1 bg-gradient-to-r from-primary to-primary-dark text-white px-6 py-4 rounded-lg font-semibold hover:shadow-lg transition-all disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
                                            disabled>
                                        <i class="fas fa-paper-plane"></i>
                                        <span id="btn-text">Enviar Justificación</span>
                                        <span id="btn-loading" class="hidden">
                                            <i class="fas fa-spinner fa-spin"></i> Enviando...
                                        </span>
                                    </button>
                                    <button type="reset" 
                                            class="px-6 py-4 bg-gray-100 text-gray-700 rounded-lg font-semibold hover:bg-gray-200 transition-colors">
                                        <i class="fas fa-redo"></i> Limpiar
                                    </button>
                                </div>
                            </form>
                            <% } %>
                        </div>
                    </div>

                    <!-- Panel Lateral -->
                    <div class="lg:col-span-1">
                        <!-- Ausencias Pendientes -->
                        <% if (ausencias != null && !ausencias.isEmpty()) { %>
                        <div class="bg-white rounded-xl shadow-sm border border-[#dbdfe6] p-6 mb-6">
                            <h3 class="section-title">
                                <i class="fas fa-exclamation-triangle"></i>
                                Ausencias Pendientes
                            </h3>
                            <div class="space-y-3 max-h-96 overflow-y-auto">
                                <% for (Asistencia a : ausencias) { %>
                                <div class="ausencia-card">
                                    <div class="flex items-start justify-between mb-2">
                                        <div class="flex-1">
                                            <p class="font-semibold text-gray-800 text-sm">
                                                <%= a.getCursoNombre() %>
                                            </p>
                                            <p class="text-xs text-gray-500 mt-1">
                                                <i class="fas fa-calendar"></i>
                                                <%= a.getFecha().format(dateFormatter) %>
                                            </p>
                                        </div>
                                        <span class="px-2 py-1 bg-red-100 text-red-700 text-xs font-semibold rounded">
                                            <%= a.getEstadoString() %>
                                        </span>
                                    </div>
                                </div>
                                <% } %>
                            </div>
                            <div class="mt-4 p-3 bg-gray-50 rounded-lg">
                                <p class="text-sm text-gray-600">
                                    <strong class="text-primary"><%= ausencias.size() %></strong> 
                                    <%= ausencias.size() == 1 ? "ausencia" : "ausencias" %> 
                                    pendiente<%= ausencias.size() == 1 ? "" : "s" %>
                                </p>
                            </div>
                        </div>
                        <% } %>

                        <!-- Información Importante -->
                        <div class="bg-gradient-to-br from-blue-50 to-blue-100 rounded-xl border-2 border-blue-200 p-6">
                            <h3 class="font-bold text-blue-900 mb-4 flex items-center gap-2">
                                <i class="fas fa-info-circle text-xl"></i>
                                Información Importante
                            </h3>
                            <ul class="space-y-3 text-sm text-blue-800">
                                <li class="flex gap-2">
                                    <i class="fas fa-check-circle text-blue-600 mt-1 flex-shrink-0"></i>
                                    <span>Complete todos los campos obligatorios (*) del formulario.</span>
                                </li>
                                <li class="flex gap-2">
                                    <i class="fas fa-file-alt text-blue-600 mt-1 flex-shrink-0"></i>
                                    <span>Adjunte documentos de respaldo cuando sea posible (certificado médico, constancia, etc.).</span>
                                </li>
                                <li class="flex gap-2">
                                    <i class="fas fa-clock text-blue-600 mt-1 flex-shrink-0"></i>
                                    <span>Las justificaciones deben presentarse dentro de los 30 días posteriores a la ausencia.</span>
                                </li>
                                <li class="flex gap-2">
                                    <i class="fas fa-user-check text-blue-600 mt-1 flex-shrink-0"></i>
                                    <span>El docente revisará y aprobará/rechazará su justificación.</span>
                                </li>
                                <li class="flex gap-2">
                                    <i class="fas fa-bell text-blue-600 mt-1 flex-shrink-0"></i>
                                    <span>Recibirá notificación del resultado de la revisión.</span>
                                </li>
                            </ul>
                        </div>

                        <!-- Formatos Aceptados -->
                        <div class="bg-white rounded-xl shadow-sm border border-[#dbdfe6] p-6 mt-6">
                            <h3 class="font-bold text-gray-800 mb-3 flex items-center gap-2">
                                <i class="fas fa-file-upload"></i>
                                Formatos Aceptados
                            </h3>
                            <div class="space-y-2 text-sm">
                                <div class="flex items-center gap-2 text-gray-700">
                                    <i class="fas fa-file-pdf text-red-500"></i>
                                    <span>PDF (.pdf)</span>
                                </div>
                                <div class="flex items-center gap-2 text-gray-700">
                                    <i class="fas fa-file-word text-blue-500"></i>
                                    <span>Word (.doc, .docx)</span>
                                </div>
                                <div class="flex items-center gap-2 text-gray-700">
                                    <i class="fas fa-file-image text-green-500"></i>
                                    <span>Imágenes (.jpg, .jpeg, .png)</span>
                                </div>
                            </div>
                            <p class="text-xs text-gray-500 mt-3 pt-3 border-t border-gray-200">
                                <i class="fas fa-exclamation-triangle text-warning"></i>
                                Tamaño máximo por archivo: 5MB
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <script>
        // Contador de caracteres
        document.getElementById('descripcion').addEventListener('input', function() {
            const charCount = document.getElementById('charCount');
            charCount.textContent = '(' + this.value.length + ' caracteres)';
        });
        
        // Control de habilitación del botón
        document.getElementById('asistenciaId').addEventListener('change', function() {
            const btnEnviar = document.getElementById('btn-enviar');
            const btnText = document.getElementById('btn-text');
            const option = this.options[this.selectedIndex];
            
            if (this.value === '') {
                btnEnviar.disabled = true;
                btnText.textContent = 'Enviar Justificación';
            } else {
                btnEnviar.disabled = false;
                const fecha = option.getAttribute('data-fecha') || '';
                btnText.textContent = 'Justificar: ' + fecha;
            }
        });
        
        // Vista previa de nombre de archivo
        function previewFileName(input) {
            const filePreview = document.getElementById('filePreview');
            const fileName = document.getElementById('fileName');
            
            if (input.files && input.files[0]) {
                const file = input.files[0];
                const fileSize = (file.size / 1024 / 1024).toFixed(2); // MB
                const fileExt = file.name.split('.').pop().toLowerCase();
                
                // Validar formato
                const allowedFormats = ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'];
                if (!allowedFormats.includes(fileExt)) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Formato no permitido',
                        text: 'Solo se permiten archivos PDF, Word e imágenes (JPG, PNG)',
                        confirmButtonColor: '#135bec'
                    });
                    input.value = '';
                    filePreview.classList.add('hidden');
                    return;
                }
                
                // Validar tamaño
                if (fileSize > 5) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Archivo demasiado grande',
                        text: 'El tamaño máximo permitido es 5MB',
                        confirmButtonColor: '#135bec'
                    });
                    input.value = '';
                    filePreview.classList.add('hidden');
                    return;
                }
                
                fileName.textContent = file.name + ' (' + fileSize + ' MB)';
                filePreview.classList.remove('hidden');
            }
        }
        
        // Limpiar archivo
        function clearFile() {
            document.getElementById('archivo').value = '';
            document.getElementById('filePreview').classList.add('hidden');
        }
        
        // Envío del formulario
        document.getElementById('formJustificacion').addEventListener('submit', function(e) {
            const btnEnviar = document.getElementById('btn-enviar');
            const btnLoading = document.getElementById('btn-loading');
            const btnText = document.getElementById('btn-text');
            
            // Validación adicional
            const asistenciaId = document.getElementById('asistenciaId').value;
            const tipo = document.getElementById('tipoJustificacion').value;
            const descripcion = document.getElementById('descripcion').value.trim();
            
            if (!asistenciaId || !tipo || !descripcion) {
                e.preventDefault();
                Swal.fire({
                    icon: 'warning',
                    title: 'Campos incompletos',
                    text: 'Complete todos los campos obligatorios antes de enviar',
                    confirmButtonColor: '#135bec'
                });
                return;
            }
            
            if (descripcion.length < 20) {
                e.preventDefault();
                Swal.fire({
                    icon: 'warning',
                    title: 'Descripción muy corta',
                    text: 'La descripción debe tener al menos 20 caracteres',
                    confirmButtonColor: '#135bec'
                });
                return;
            }
            
            // Mostrar loading
            btnEnviar.disabled = true;
            btnText.classList.add('hidden');
            btnLoading.classList.remove('hidden');
            
            // Permitir el envío
            return true;
        });
        
        // Inicialización
        document.addEventListener('DOMContentLoaded', function() {
            const asistenciaSelect = document.getElementById('asistenciaId');
            if (asistenciaSelect && asistenciaSelect.value === '') {
                document.getElementById('btn-enviar').disabled = true;
            }
            
            console.log('✅ Formulario de justificación cargado');
            
            <% if (mensaje != null && !mensaje.isEmpty()) { %>
            Swal.fire({
                icon: 'success',
                title: '¡Éxito!',
                text: '<%= mensaje %>',
                confirmButtonColor: '#135bec'
            });
            <% } %>
            
            <% if (error != null && !error.isEmpty()) { %>
            Swal.fire({
                icon: 'error',
                title: 'Error',
                text: '<%= error %>',
                confirmButtonColor: '#135bec'
            });
            <% } %>
        });
    </script>
</body>
</html>
