<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="modelo.Alumno" %>
<%@ page import="modelo.Grado" %>
<%@ page import="java.util.List" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    Alumno a = (Alumno) request.getAttribute("alumno");
    List<Grado> grados = (List<Grado>) request.getAttribute("grados");
    boolean editar = (a != null);
    
    String fechaNacimientoStr = "";
    if (editar) {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        if (a.getFechaNacimiento() != null) {
            fechaNacimientoStr = sdf.format(java.sql.Date.valueOf(a.getFechaNacimiento()));
        }
    }
    
    // Configurar título de la página
    request.setAttribute("pageTitle", editar ? "Editar Estudiante" : "Nuevo Estudiante");
%>

<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <title><%= editar ? "Editar Alumno" : "Registrar Alumno" %> - San Antonio</title>
    
    <%@ include file="includes/head.jsp" %>
    
    <style>
        .step-section { display: none; animation: fadeIn 0.4s ease-in-out; }
        .step-section.active { display: block; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
        .input-figma { background-color: #ffffff; border: 1px solid #d1d5db; border-radius: 0.5rem; transition: all 0.2s; }
        .input-figma:focus { border-color: #135bec; box-shadow: 0 0 0 3px rgba(19, 91, 236, 0.1); }
        .required-field::after { content: " *"; color: #ef4444; font-weight: bold; }
        
        .radio-option {
            position: relative;
            cursor: pointer;
            border: 2px solid #d1d5db;
            border-radius: 0.75rem;
            padding: 1rem;
            transition: all 0.2s;
            background: white;
        }
        .radio-option:hover {
            border-color: #135bec;
            background: #f0f7ff;
        }
        .radio-option input[type="radio"]:checked ~ .check-icon {
            display: flex;
        }
        .check-icon {
            display: none;
            position: absolute;
            top: 0.5rem;
            right: 0.5rem;
            width: 1.5rem;
            height: 1.5rem;
            background: #135bec;
            border-radius: 50%;
            color: white;
            align-items: center;
            justify-content: center;
            font-size: 0.75rem;
        }
        .status-icon {
            width: 3rem;
            height: 3rem;
            border-radius: 0.75rem;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            margin-bottom: 0.5rem;
        }
        .status-active-bg   { background: linear-gradient(135deg, #d1fae5, #a7f3d0); color: #065f46; }
        .status-inactive-bg { background: linear-gradient(135deg, #fee2e2, #fecaca); color: #991b1b; }
        .status-graduated-bg{ background: linear-gradient(135deg, #dbeafe, #bfdbfe); color: #1e40af; }
        .status-retired-bg  { background: linear-gradient(135deg, #fef3c7, #fde68a); color: #92400e; }
    </style>
</head>
<body class="bg-gray-100 min-h-screen">

    <div class="flex h-screen overflow-hidden">
        
        <%-- ✅ SIDEBAR: barra lateral de navegación --%>
        <%
            String rolSidebarU = (String) session.getAttribute("rol");
            String sidebarFileU = "administrativo".equals(rolSidebarU) 
                                 ? "includes/sidebarAdministrativo.jsp" 
                                 : "includes/sidebar.jsp";
        %>
        <jsp:include page="<%= sidebarFileU %>" />

        <!-- CONTENIDO PRINCIPAL -->
        <main class="flex-1 flex flex-col overflow-y-auto">
            
            <%-- ✅ HEADER: barra superior con usuario y foto --%>
            <%@ include file="includes/header.jsp" %>

            <!-- CONTENIDO DEL FORMULARIO -->
            <div class="p-4 md:p-8 max-w-5xl mx-auto w-full">
                
                <!-- Alertas -->
                <% 
                    String error = (String) session.getAttribute("error");
                    String mensaje = (String) session.getAttribute("mensaje");
                    if (error != null) { session.removeAttribute("error"); %>
                    <div class="alert-modern alert-danger mb-4" role="alert">
                        <i class="fas fa-exclamation-circle"></i>
                        <div><strong>Error:</strong> <%= error %></div>
                    </div>
                <% } if (mensaje != null) { session.removeAttribute("mensaje"); %>
                    <div class="alert-modern alert-success mb-4" role="alert">
                        <i class="fas fa-check-circle"></i>
                        <div><strong>Éxito:</strong> <%= mensaje %></div>
                    </div>
                <% } %>

                <form action="AlumnoServlet" method="post" id="alumnoForm" novalidate enctype="multipart/form-data">
                    <input type="hidden" name="id" value="<%= editar ? a.getId() : "" %>">
                    <input type="hidden" name="codigo_alumno" value="<%= (editar && a.getCodigoAlumno() != null) ? a.getCodigoAlumno() : "" %>">
                    
                    <div id="step1" class="step-section active">
                        <div class="bg-white rounded-2xl shadow-xl overflow-hidden border border-gray-200">
                            
                            <%-- Cabecera del formulario con foto --%>
                            <div class="bg-primary text-white p-6 flex items-center gap-6">
                                
                                <div class="relative group cursor-pointer" onclick="document.getElementById('inputFoto').click()">
                                    <input type="file" name="foto" id="inputFoto" class="hidden" accept="image/*" onchange="previsualizarImagen(this)">
                                    
                                    <div class="w-24 h-24 bg-white/20 rounded-full flex items-center justify-center backdrop-blur-sm border-4 border-white/30 overflow-hidden hover:bg-white/30 transition shadow-lg relative">
                                        
                                        <img id="imgPreview" 
                                             src="<%= (editar && a.getFoto() != null && !a.getFoto().isEmpty()) ? "uploads/" + a.getFoto() : "" %>" 
                                             class="w-full h-full object-cover <%= (editar && a.getFoto() != null && !a.getFoto().isEmpty()) ? "" : "hidden" %>">
                                        
                                        <div id="placeholderIcon" class="<%= (editar && a.getFoto() != null && !a.getFoto().isEmpty()) ? "hidden" : "flex" %> flex-col items-center justify-center text-white">
                                            <% if (editar) { %>
                                                <span class="text-3xl font-bold">
                                                    <%= a.getNombres().substring(0,1) %><%= a.getApellidos().substring(0,1) %>
                                                </span>
                                            <% } else { %>
                                                <i class="fas fa-camera text-4xl mb-1"></i>
                                                <span class="text-xs">Subir foto</span>
                                            <% } %>
                                        </div>

                                        <div class="absolute inset-0 bg-black/40 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
                                            <i class="fas fa-pen text-white"></i>
                                        </div>
                                    </div>
                                </div>
                                
                                <div class="flex-1">
                                    <h2 class="text-3xl font-bold mb-2">
                                        <%= editar ? "Editar Alumno" : "Nuevo Alumno" %>
                                    </h2>
                                    <p class="text-white/80 text-sm">
                                        <%= editar ? "Actualiza la información del estudiante" : "Complete los datos del nuevo estudiante" %>
                                    </p>
                                </div>
                            </div>

                            <div class="p-8 space-y-6">
                                
                                <%-- INFORMACIÓN PERSONAL --%>
                                <div>
                                    <h3 class="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
                                        <i class="fas fa-user text-primary"></i> Información Personal
                                    </h3>
                                    
                                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                                        <div>
                                            <label class="block text-sm font-medium text-gray-700 mb-2 required-field">Nombres</label>
                                            <input type="text" name="nombres" 
                                                   value="<%= editar && a.getNombres() != null ? a.getNombres() : "" %>"
                                                   class="input-figma w-full px-4 py-3 text-gray-900 focus:outline-none" 
                                                   placeholder="Ej: Juan Carlos" 
                                                   required maxlength="100">
                                        </div>

                                        <div>
                                            <label class="block text-sm font-medium text-gray-700 mb-2 required-field">Apellidos</label>
                                            <input type="text" name="apellidos" 
                                                   value="<%= editar && a.getApellidos() != null ? a.getApellidos() : "" %>"
                                                   class="input-figma w-full px-4 py-3 text-gray-900 focus:outline-none" 
                                                   placeholder="Ej: Pérez García" 
                                                   required maxlength="100">
                                        </div>

                                        <div>
                                            <label class="block text-sm font-medium text-gray-700 mb-2 required-field">Correo Electrónico</label>
                                            <input type="email" name="correo" 
                                                   value="<%= editar && a.getCorreo() != null ? a.getCorreo() : "" %>"
                                                   class="input-figma w-full px-4 py-3 text-gray-900 focus:outline-none" 
                                                   placeholder="estudiante@ejemplo.com" 
                                                   required maxlength="100">
                                        </div>

                                        <div>
                                            <label class="block text-sm font-medium text-gray-700 mb-2">DNI</label>
                                            <input type="text" name="dni" id="dniInput"
                                                   value="<%= editar && a.getDni() != null ? a.getDni() : "" %>"
                                                   class="input-figma w-full px-4 py-3 text-gray-900 focus:outline-none" 
                                                   placeholder="8 dígitos" 
                                                   maxlength="8" pattern="[0-9]{8}">
                                            <p class="text-xs text-gray-500 mt-1">Opcional, 8 dígitos numéricos</p>
                                        </div>

                                        <div>
                                            <label class="block text-sm font-medium text-gray-700 mb-2 required-field">Fecha de Nacimiento</label>
                                            <input type="date" name="fecha_nacimiento" id="fechaNacimiento"
                                                   value="<%= fechaNacimientoStr %>"
                                                   class="input-figma w-full px-4 py-3 text-gray-900 focus:outline-none" 
                                                   required max="9999-12-31">
                                        </div>

                                        <div class="md:col-span-2">
                                            <label class="block text-sm font-medium text-gray-700 mb-2">Dirección</label>
                                            <textarea name="direccion" rows="3" 
                                                      class="input-figma w-full px-4 py-3 text-gray-900 focus:outline-none resize-none" 
                                                      placeholder="Av. Principal 123, Distrito, Ciudad" 
                                                      maxlength="255"><%= editar && a.getDireccion() != null ? a.getDireccion() : "" %></textarea>
                                        </div>
                                    </div>
                                </div>

                                <hr class="border-gray-300">

                                <%-- INFORMACIÓN ACADÉMICA --%>
                                <div>
                                    <h3 class="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
                                        <i class="fas fa-graduation-cap text-primary"></i> Información Académica
                                    </h3>
                                    
                                    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                                        <div>
                                            <label class="block text-sm font-medium text-gray-700 mb-2 required-field">Turno</label>
                                            <select name="turno_id" id="turnoSelect" 
                                                    class="input-figma w-full px-4 py-3 text-gray-900 focus:outline-none" 
                                                    required onchange="filtrarNiveles()">
                                                <option value="">-- Seleccione turno --</option>
                                                <option value="1" <%= editar && a.getTurnoId() == 1 ? "selected" : "" %>>Mañana</option>
                                                <option value="2" <%= editar && a.getTurnoId() == 2 ? "selected" : "" %>>Tarde</option>
                                            </select>
                                        </div>

                                        <div>
                                            <label class="block text-sm font-medium text-gray-700 mb-2 required-field">Nivel</label>
                                            <select name="nivel" id="nivelSelect" 
                                                    class="input-figma w-full px-4 py-3 text-gray-900 focus:outline-none" 
                                                    required disabled onchange="filtrarGrados()">
                                                <option value="">Primero seleccione turno</option>
                                                <option value="INICIAL">Inicial</option>
                                                <option value="PRIMARIA">Primaria</option>
                                                <option value="SECUNDARIA">Secundaria</option>
                                            </select>
                                        </div>

                                        <div>
                                            <label class="block text-sm font-medium text-gray-700 mb-2 required-field">Grado/Salón</label>
                                            <select name="grado_id" id="gradoSelect" 
                                                    class="input-figma w-full px-4 py-3 text-gray-900 focus:outline-none" 
                                                    required disabled>
                                                <option value="">Primero seleccione nivel</option>
                                                <% if (grados != null) { for (Grado g : grados) { 
                                                    boolean selected = editar && a.getGradoId() == g.getId();
                                                %>
                                                <option value="<%= g.getId() %>" 
                                                        data-nivel="<%= g.getNivel() %>" 
                                                        <%= selected ? "selected" : "" %>>
                                                    <%= g.getNombre() %>
                                                </option>
                                                <% } } %>
                                            </select>
                                        </div>
                                    </div>
                                </div>

                                <hr class="border-gray-300">

                                <%-- ESTADO DEL ALUMNO --%>
                                <div>
                                    <h3 class="text-lg font-semibold text-gray-900 mb-4 flex items-center gap-2">
                                        <i class="fas fa-info-circle text-primary"></i> Estado del Estudiante
                                    </h3>
                                    
                                    <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
                                        <label class="radio-option">
                                            <input type="radio" name="estado" value="ACTIVO" class="hidden"
                                                   <%= (!editar || a.getEstado() == null || a.getEstado().equals("ACTIVO")) ? "checked" : "" %>>
                                            <div class="radio-content flex flex-col items-center text-center p-4">
                                                <div class="status-icon status-active-bg">
                                                    <i class="fas fa-circle-check"></i>
                                                </div>
                                                <span class="font-semibold text-gray-900">Activo</span>
                                                <span class="text-xs text-gray-500 mt-1">Estudiante regular</span>
                                            </div>
                                            <div class="check-icon"><i class="fas fa-check"></i></div>
                                        </label>

                                        <label class="radio-option">
                                            <input type="radio" name="estado" value="INACTIVO" class="hidden"
                                                   <%= editar && "INACTIVO".equals(a.getEstado()) ? "checked" : "" %>>
                                            <div class="radio-content flex flex-col items-center text-center p-4">
                                                <div class="status-icon status-inactive-bg">
                                                    <i class="fas fa-circle-xmark"></i>
                                                </div>
                                                <span class="font-semibold text-gray-900">Inactivo</span>
                                                <span class="text-xs text-gray-500 mt-1">Temporalmente fuera</span>
                                            </div>
                                            <div class="check-icon"><i class="fas fa-check"></i></div>
                                        </label>

                                        <label class="radio-option">
                                            <input type="radio" name="estado" value="EGRESADO" class="hidden"
                                                   <%= editar && "EGRESADO".equals(a.getEstado()) ? "checked" : "" %>>
                                            <div class="radio-content flex flex-col items-center text-center p-4">
                                                <div class="status-icon status-graduated-bg">
                                                    <i class="fas fa-graduation-cap"></i>
                                                </div>
                                                <span class="font-semibold text-gray-900">Egresado</span>
                                                <span class="text-xs text-gray-500 mt-1">Completó estudios</span>
                                            </div>
                                            <div class="check-icon"><i class="fas fa-check"></i></div>
                                        </label>

                                        <label class="radio-option">
                                            <input type="radio" name="estado" value="RETIRADO" class="hidden"
                                                   <%= editar && "RETIRADO".equals(a.getEstado()) ? "checked" : "" %>>
                                            <div class="radio-content flex flex-col items-center text-center p-4">
                                                <div class="status-icon status-retired-bg">
                                                    <i class="fas fa-door-open"></i>
                                                </div>
                                                <span class="font-semibold text-gray-900">Retirado</span>
                                                <span class="text-xs text-gray-500 mt-1">Abandonó colegio</span>
                                            </div>
                                            <div class="check-icon"><i class="fas fa-check"></i></div>
                                        </label>
                                    </div>
                                </div>

                                <%-- Código de alumno (solo en edición) --%>
                                <% if (editar && a.getCodigoAlumno() != null) { %>
                                <div class="bg-blue-50 border border-blue-200 rounded-lg p-4">
                                    <div class="flex items-center gap-3">
                                        <i class="fas fa-id-card text-blue-600 text-xl"></i>
                                        <div>
                                            <p class="text-sm font-medium text-gray-700">Código de Alumno</p>
                                            <p class="text-lg font-bold text-blue-600"><%= a.getCodigoAlumno() %></p>
                                        </div>
                                    </div>
                                </div>
                                <% } %>

                            </div>

                            <%-- SECCIÓN: Datos del Padre/Apoderado (solo en registro nuevo) --%>
                            <% if (!editar) { %>
                            <div class="px-8 py-6 border-t border-gray-200">
                                <div class="flex items-center gap-3 mb-6">
                                    <div class="w-8 h-8 bg-green-100 rounded-full flex items-center justify-center">
                                        <i class="fas fa-user-tie text-green-600 text-sm"></i>
                                    </div>
                                    <div>
                                        <h3 class="font-bold text-gray-900">Datos del Padre / Apoderado</h3>
                                        <p class="text-xs text-gray-500">Se creará automáticamente un usuario para el padre con acceso al sistema</p>
                                    </div>
                                </div>

                                <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                                    <div>
                                        <label class="block text-sm font-medium text-gray-700 mb-1 required-field">Nombres del padre</label>
                                        <input type="text" name="padre_nombres" id="padreNombres"
                                               class="input-figma w-full px-4 py-3 text-sm focus:outline-none"
                                               placeholder="Ej: Juan Carlos" required>
                                    </div>
                                    <div>
                                        <label class="block text-sm font-medium text-gray-700 mb-1 required-field">Apellidos del padre</label>
                                        <input type="text" name="padre_apellidos" id="padreApellidos"
                                               class="input-figma w-full px-4 py-3 text-sm focus:outline-none"
                                               placeholder="Ej: García López" required>
                                    </div>
                                    <div>
                                        <label class="block text-sm font-medium text-gray-700 mb-1 required-field">Correo del padre</label>
                                        <input type="email" name="padre_correo" id="padreCorreo"
                                               class="input-figma w-full px-4 py-3 text-sm focus:outline-none"
                                               placeholder="padre@correo.com" required>
                                    </div>
                                    <div>
                                        <label class="block text-sm font-medium text-gray-700 mb-1">Teléfono del padre</label>
                                        <input type="tel" name="padre_telefono" id="padreTelefono"
                                               class="input-figma w-full px-4 py-3 text-sm focus:outline-none"
                                               placeholder="999999999" maxlength="9">
                                    </div>
                                    <div>
                                        <label class="block text-sm font-medium text-gray-700 mb-1">DNI del padre</label>
                                        <input type="text" name="padre_dni" id="padreDni"
                                               class="input-figma w-full px-4 py-3 text-sm focus:outline-none"
                                               placeholder="12345678" maxlength="8">
                                    </div>
                                    <div>
                                        <label class="block text-sm font-medium text-gray-700 mb-1 required-field">Parentesco</label>
                                        <select name="padre_parentesco" class="input-figma w-full px-4 py-3 text-sm focus:outline-none" required>
                                            <option value="PADRE">Padre</option>
                                            <option value="MADRE">Madre</option>
                                            <option value="TUTOR">Tutor</option>
                                            <option value="APODERADO">Apoderado</option>
                                        </select>
                                    </div>
                                </div>

                                <!-- Info usuario generado -->
                                <div class="mt-4 p-4 bg-blue-50 border border-blue-200 rounded-lg">
                                    <p class="text-sm text-blue-800 flex items-start gap-2">
                                        <i class="fas fa-info-circle mt-0.5 flex-shrink-0"></i>
                                        <span>El <strong>usuario y contraseña</strong> del padre se generarán automáticamente usando su DNI. Si no tiene DNI, se usará su correo. Podrá cambiarlo después.</span>
                                    </p>
                                </div>
                            </div>
                            <% } %>

                            <%-- Botones de acción --%>
                            <div class="bg-gray-50 px-8 py-6 flex justify-between items-center border-t border-gray-200">
                                <a href="AlumnoServlet" class="btn-modern btn-secondary-modern">
                                    <i class="fas fa-arrow-left"></i> Cancelar
                                </a>
                                <button type="submit" onclick="return validarFormulario()" class="btn-modern btn-primary-modern shadow-lg">
                                    <i class="fas fa-save"></i>
                                    <%= editar ? "Actualizar Alumno" : "Guardar Alumno" %>
                                </button>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
        </main>
    </div>

    <script>
        // Solo números en DNI
        const dniInput = document.getElementById('dniInput');
        if (dniInput) {
            dniInput.addEventListener('input', function() {
                this.value = this.value.replace(/[^0-9]/g, '');
                if (this.value.length > 8) this.value = this.value.slice(0, 8);
            });
        }
        
        function filtrarNiveles() {
            const turnoSelect = document.getElementById('turnoSelect');
            const nivelSelect = document.getElementById('nivelSelect');
            const gradoSelect = document.getElementById('gradoSelect');
            
            if (turnoSelect.value) {
                nivelSelect.disabled = false;
                nivelSelect.innerHTML = '<option value="">-- Seleccione nivel --</option>' +
                                       '<option value="INICIAL">Inicial</option>' +
                                       '<option value="PRIMARIA">Primaria</option>' +
                                       '<option value="SECUNDARIA">Secundaria</option>';
            } else {
                nivelSelect.disabled = true;
                nivelSelect.innerHTML = '<option value="">Primero seleccione turno</option>';
                gradoSelect.disabled = true;
                gradoSelect.value = '';
            }
        }

        function filtrarGrados() {
            const nivelSelect = document.getElementById('nivelSelect');
            const gradoSelect = document.getElementById('gradoSelect');
            const nivelSeleccionado = nivelSelect.value;
            const opciones = gradoSelect.querySelectorAll('option');
            
            if (nivelSeleccionado) {
                gradoSelect.disabled = false;
                opciones.forEach((opcion, index) => {
                    if (index === 0) {
                        opcion.textContent = '-- Seleccione grado --';
                        return;
                    }
                    const nivelOpcion = opcion.getAttribute('data-nivel');
                    opcion.style.display = nivelOpcion === nivelSeleccionado ? 'block' : 'none';
                });
                gradoSelect.value = '';
            } else {
                gradoSelect.disabled = true;
                gradoSelect.value = '';
                if (opciones[0]) opciones[0].textContent = 'Primero seleccione nivel';
            }
        }

        function validarFormulario() {
            const nombres = document.querySelector('input[name="nombres"]').value.trim();
            const apellidos = document.querySelector('input[name="apellidos"]').value.trim();
            const correo = document.querySelector('input[name="correo"]').value.trim();
            const fechaNacimiento = document.getElementById('fechaNacimiento').value;
            const turno = document.getElementById('turnoSelect').value;
            const nivel = document.getElementById('nivelSelect').value;
            const grado = document.getElementById('gradoSelect').value;
            const estado = document.querySelector('input[name="estado"]:checked');
            
            if (!nombres || !apellidos || !correo || !correo.includes('@') || 
                !fechaNacimiento || !turno || !nivel || !grado || !estado) {
                alert('Por favor complete todos los campos obligatorios del alumno');
                return false;
            }

            // Validar campos del padre solo en registro nuevo
            const padreNombres = document.getElementById('padreNombres');
            if (padreNombres) {
                const pNombres = padreNombres.value.trim();
                const pApellidos = document.getElementById('padreApellidos').value.trim();
                const pCorreo = document.getElementById('padreCorreo').value.trim();
                if (!pNombres || !pApellidos || !pCorreo || !pCorreo.includes('@')) {
                    alert('Por favor complete los datos obligatorios del padre/apoderado (Nombres, Apellidos y Correo)');
                    return false;
                }
            }

            return true;
        }

        // Previsualizar imagen seleccionada
        function previsualizarImagen(input) {
            const imgPreview = document.getElementById('imgPreview');
            const placeholderIcon = document.getElementById('placeholderIcon');
            if (input.files && input.files[0]) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    imgPreview.src = e.target.result;
                    imgPreview.classList.remove('hidden');
                    placeholderIcon.classList.add('hidden');
                };
                reader.readAsDataURL(input.files[0]);
            }
        }

        document.addEventListener('DOMContentLoaded', function() {
            <% if (editar) { %>
                // En edición: restaurar selects de turno, nivel y grado
                const turnoSelect = document.getElementById('turnoSelect');
                if (turnoSelect.value) {
                    filtrarNiveles();
                    setTimeout(function() {
                        const gradoSeleccionado = document.getElementById('gradoSelect')
                                                          .querySelector('option[selected]');
                        if (gradoSeleccionado) {
                            const nivelDelGrado = gradoSeleccionado.getAttribute('data-nivel');
                            document.getElementById('nivelSelect').value = nivelDelGrado;
                            filtrarGrados();
                            setTimeout(function() {
                                document.getElementById('gradoSelect').value = '<%= a.getGradoId() %>';
                            }, 100);
                        }
                    }, 100);
                }
            <% } else { %>
                // En nuevo: poner fecha por defecto hace 10 años
                const fechaInput = document.getElementById('fechaNacimiento');
                if (!fechaInput.value) {
                    const hoy = new Date();
                    const hace10Anios = new Date(hoy.getFullYear() - 10, hoy.getMonth(), hoy.getDate());
                    fechaInput.value = hace10Anios.toISOString().split('T')[0];
                }
            <% } %>
        });
    </script>
</body>
</html>
