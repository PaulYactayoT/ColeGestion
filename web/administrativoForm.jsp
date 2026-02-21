<%-- 
    Document   : Administrativoform
    Created on : 16 feb. 2026, 6:44:53 p. m.
    Author     : Ocelot
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="modelo.Administrativo" %>
<%@ page import="modelo.MasterTableDAO.CatalogoItem" %>
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

    Administrativo admin = (Administrativo) request.getAttribute("administrativo");
    boolean editar = (admin != null);
    
    // Obtener catálogos
    @SuppressWarnings("unchecked")
    List<CatalogoItem> tiposDocumento = (List<CatalogoItem>) request.getAttribute("tiposDocumento");
    @SuppressWarnings("unchecked")
    List<CatalogoItem> sexos = (List<CatalogoItem>) request.getAttribute("sexos");
    
    String fechaNacimientoStr = "";
    String fechaIngresoStr = "";
    if (editar) {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        if (admin.getFechaNacimiento() != null) {
            fechaNacimientoStr = sdf.format(java.sql.Date.valueOf(admin.getFechaNacimiento()));
        }
        if (admin.getFechaIngreso() != null) {
            fechaIngresoStr = sdf.format(java.sql.Date.valueOf(admin.getFechaIngreso()));
        }
    }
    
    request.setAttribute("pageTitle", editar ? "Editar Administrativo" : "Nuevo Administrativo");
%>

<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <title><%= editar ? "Editar Administrativo" : "Registrar Administrativo" %> - San Antonio</title>
    
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
        
        /* Estilos para inputs de fecha */
        input[type="date"] {
            position: relative;
            padding-right: 2.5rem;
        }
        
        input[type="date"]::-webkit-calendar-picker-indicator {
            cursor: pointer;
            opacity: 0.6;
            transition: opacity 0.2s;
        }
        
        input[type="date"]::-webkit-calendar-picker-indicator:hover {
            opacity: 1;
        }
        
        /* Prevenir que se muestren años con más de 4 dígitos */
        input[type="date"]::-webkit-datetime-edit-year-field {
            max-width: 4ch;
        }
        .status-active-bg   { background: linear-gradient(135deg, #d1fae5, #a7f3d0); color: #065f46; }
        .status-inactive-bg { background: linear-gradient(135deg, #fee2e2, #fecaca); color: #991b1b; }
        .status-licencia-bg { background: linear-gradient(135deg, #fef3c7, #fde68a); color: #92400e; }
        .status-jubilado-bg{ background: linear-gradient(135deg, #dbeafe, #bfdbfe); color: #1e40af; }
    </style>
</head>
<body class="bg-gray-100 min-h-screen">

    <div class="flex h-screen overflow-hidden">
        
        <%-- SIDEBAR: barra lateral de navegación --%>
        <%
            String rolSidebarU = (String) session.getAttribute("rol");
            String sidebarFileU = "administrativo".equals(rolSidebarU) 
                                 ? "includes/sidebarAdministrativo.jsp" 
                                 : "includes/sidebar.jsp";
        %>
        <jsp:include page="<%= sidebarFileU %>" />

        <!-- CONTENIDO PRINCIPAL -->
        <main class="flex-1 flex flex-col overflow-y-auto">
            
            <%-- HEADER: barra superior con usuario y foto --%>
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

                <form action="AdministrativoServlet" method="post" id="administrativoForm" novalidate enctype="multipart/form-data">
                    <input type="hidden" name="id" value="<%= editar ? admin.getId() : "" %>">
                    <input type="hidden" name="codigo_administrativo" value="<%= (editar && admin.getCodigoAdministrativo() != null) ? admin.getCodigoAdministrativo() : "" %>">
                    
                    <div id="step1" class="step-section active">
                        <div class="bg-white rounded-2xl shadow-xl overflow-hidden border border-gray-200">
                            
                            <%-- Cabecera del formulario con foto --%>
                            <div class="bg-primary text-white p-6 flex items-center gap-6">
                                
                                <div class="relative group cursor-pointer" onclick="document.getElementById('inputFoto').click()">
                                    <input type="file" name="foto" id="inputFoto" class="hidden" accept="image/*" onchange="previsualizarImagen(this)">
                                    
                                    <div class="w-24 h-24 bg-white/20 rounded-full flex items-center justify-center backdrop-blur-sm border-4 border-white/30 overflow-hidden hover:bg-white/30 transition shadow-lg relative">
                                        
                                        <img id="imgPreview" 
                                             src="<%= (editar && admin.getFoto() != null && !admin.getFoto().isEmpty()) ? "uploads/" + admin.getFoto() : "" %>" 
                                             class="w-full h-full object-cover <%= (editar && admin.getFoto() != null && !admin.getFoto().isEmpty()) ? "" : "hidden" %>">
                                        
                                        <div id="placeholderIcon" class="<%= (editar && admin.getFoto() != null && !admin.getFoto().isEmpty()) ? "hidden" : "flex" %> flex-col items-center justify-center text-white">
                                            <% if (editar) { %>
                                                <span class="text-3xl font-bold">
                                                    <%= admin.getNombres().substring(0,1) %><%= admin.getApellidos().substring(0,1) %>
                                                </span>
                                            <% } else { %>
                                                <i class="fas fa-camera text-4xl mb-1"></i>
                                                <span class="text-xs">Subir foto</span>
                                            <% } %>
                                        </div>

                                        <div class="absolute inset-0 bg-black/40 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
                                            <i class="fas fa-camera text-white text-2xl"></i>
                                        </div>
                                    </div>
                                </div>

                                <div class="flex-1">
                                    <h1 class="text-3xl font-bold mb-2">
                                        <i class="fas fa-user-tie mr-2"></i>
                                        <%= editar ? "Editar Administrativo" : "Registrar Administrativo" %>
                                    </h1>
                                    <p class="text-blue-100 text-sm">Complete los datos del personal administrativo</p>
                                </div>
                            </div>

                            <%-- Cuerpo del formulario --%>
                            <div class="p-8 space-y-8">

                                <!-- SECCIÓN: INFORMACIÓN PERSONAL -->
                                <div>
                                    <h3 class="text-lg font-bold text-gray-800 mb-4 flex items-center gap-2">
                                        <i class="fas fa-user text-primary"></i>
                                        Información Personal
                                    </h3>
                                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                                        
                                        <div>
                                            <label class="block text-sm font-medium text-gray-700 mb-2 required-field">Nombres</label>
                                            <input type="text" name="nombres" 
                                                   value="<%= editar ? admin.getNombres() : "" %>"
                                                   class="input-figma w-full p-3" required>
                                        </div>

                                        <div>
                                            <label class="block text-sm font-medium text-gray-700 mb-2 required-field">Apellidos</label>
                                            <input type="text" name="apellidos" 
                                                   value="<%= editar ? admin.getApellidos() : "" %>"
                                                   class="input-figma w-full p-3" required>
                                        </div>

                                        <div>
                                            <label class="block text-sm font-medium text-gray-700 mb-2 required-field">Tipo de Documento</label>
                                            <select name="tipo_documento" class="input-figma w-full p-3" required>
                                                <option value="">-- Seleccione --</option>
                                                <% if (tiposDocumento != null) {
                                                    for (CatalogoItem item : tiposDocumento) { %>
                                                        <option value="<%= item.getValue() %>" 
                                                                <%= (editar && item.getValue().equals(admin.getTipoDocumento())) ? "selected" : "" %>>
                                                            <%= item.getName() %>
                                                        </option>
                                                    <% }
                                                } else { %>
                                                    <option value="DNI">DNI</option>
                                                    <option value="CE">Carné de Extranjería</option>
                                                    <option value="PASAPORTE">Pasaporte</option>
                                                <% } %>
                                            </select>
                                        </div>

                                        <div>
                                            <label class="block text-sm font-medium text-gray-700 mb-2 required-field">Número de Documento</label>
                                            <input type="text" name="numero_documento" id="dniInput"
                                                   value="<%= editar ? admin.getNumeroDocumento() : "" %>"
                                                   class="input-figma w-full p-3" maxlength="8" required>
                                        </div>

                                        <div>
                                            <label class="block text-sm font-medium text-gray-700 mb-2 required-field">Fecha de Nacimiento</label>
                                            <input type="date" name="fecha_nacimiento" id="fechaNacimiento"
                                                   value="<%= fechaNacimientoStr %>"
                                                   min="1900-01-01" max="2100-12-31"
                                                   class="input-figma w-full p-3" required>
                                        </div>

                                        <div>
                                            <label class="block text-sm font-medium text-gray-700 mb-2 required-field">Sexo</label>
                                            <select name="sexo" class="input-figma w-full p-3" required>
                                                <option value="">-- Seleccione --</option>
                                                <% if (sexos != null) {
                                                    for (CatalogoItem item : sexos) { %>
                                                        <option value="<%= item.getValue() %>" 
                                                                <%= (editar && item.getValue().equals(admin.getSexo())) ? "selected" : "" %>>
                                                            <%= item.getName() %>
                                                        </option>
                                                    <% }
                                                } else { %>
                                                    <option value="M">Masculino</option>
                                                    <option value="F">Femenino</option>
                                                <% } %>
                                            </select>
                                        </div>

                                    </div>
                                </div>

                                <!-- SECCIÓN: INFORMACIÓN DE CONTACTO -->
                                <div>
                                    <h3 class="text-lg font-bold text-gray-800 mb-4 flex items-center gap-2">
                                        <i class="fas fa-address-book text-primary"></i>
                                        Información de Contacto
                                    </h3>
                                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                                        
                                        <div>
                                            <label class="block text-sm font-medium text-gray-700 mb-2 required-field">Correo Electrónico</label>
                                            <input type="email" name="correo" 
                                                   value="<%= editar ? (admin.getCorreo() != null ? admin.getCorreo() : "") : "" %>"
                                                   class="input-figma w-full p-3" required>
                                        </div>

                                        <div>
                                            <label class="block text-sm font-medium text-gray-700 mb-2">Teléfono</label>
                                            <input type="tel" name="telefono" id="telefonoInput"
                                                   value="<%= editar ? (admin.getTelefono() != null ? admin.getTelefono() : "") : "" %>"
                                                   class="input-figma w-full p-3" maxlength="9">
                                        </div>

                                        <div class="md:col-span-2">
                                            <label class="block text-sm font-medium text-gray-700 mb-2">Dirección</label>
                                            <textarea name="direccion" rows="2" class="input-figma w-full p-3"><%= editar ? (admin.getDireccion() != null ? admin.getDireccion() : "") : "" %></textarea>
                                        </div>

                                    </div>
                                </div>

                                <!-- SECCIÓN: INFORMACIÓN LABORAL -->
                                <div>
                                    <h3 class="text-lg font-bold text-gray-800 mb-4 flex items-center gap-2">
                                        <i class="fas fa-briefcase text-primary"></i>
                                        Información Laboral
                                    </h3>
                                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                                        
                                        <div>
                                            <label class="block text-sm font-medium text-gray-700 mb-2 required-field">Cargo</label>
                                            <input type="text" name="cargo" 
                                                   value="<%= editar ? admin.getCargo() : "" %>"
                                                   placeholder="Ej: Secretaria, Contador, etc."
                                                   class="input-figma w-full p-3" required>
                                        </div>

                                        <div>
                                            <label class="block text-sm font-medium text-gray-700 mb-2">Departamento</label>
                                            <input type="text" name="departamento" 
                                                   value="<%= editar ? (admin.getDepartamento() != null ? admin.getDepartamento() : "") : "" %>"
                                                   placeholder="Ej: Administración, Contabilidad, etc."
                                                   class="input-figma w-full p-3">
                                        </div>

                                        <div>
                                            <label class="block text-sm font-medium text-gray-700 mb-2">Fecha de Ingreso</label>
                                            <input type="date" name="fecha_ingreso" id="fechaIngreso"
                                                   value="<%= fechaIngresoStr %>"
                                                   min="1900-01-01" max="2100-12-31"
                                                   class="input-figma w-full p-3">
                                        </div>

                                    </div>
                                </div>

                                <!-- SECCIÓN: ESTADO -->
                                <div>
                                    <h3 class="text-lg font-bold text-gray-800 mb-4 flex items-center gap-2">
                                        <i class="fas fa-toggle-on text-primary"></i>
                                        Estado del Administrativo
                                    </h3>
                                    
                                    <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
                                        
                                        <label class="radio-option">
                                            <input type="radio" name="estado" value="ACTIVO" 
                                                   <%= (!editar || "ACTIVO".equals(admin.getEstado())) ? "checked" : "" %>
                                                   class="hidden">
                                            <div class="check-icon"><i class="fas fa-check"></i></div>
                                            <div class="status-icon status-active-bg">
                                                <i class="fas fa-check-circle"></i>
                                            </div>
                                            <p class="font-semibold text-gray-800">Activo</p>
                                            <p class="text-xs text-gray-500">Laborando</p>
                                        </label>

                                        <label class="radio-option">
                                            <input type="radio" name="estado" value="INACTIVO" 
                                                   <%= (editar && "INACTIVO".equals(admin.getEstado())) ? "checked" : "" %>
                                                   class="hidden">
                                            <div class="check-icon"><i class="fas fa-check"></i></div>
                                            <div class="status-icon status-inactive-bg">
                                                <i class="fas fa-times-circle"></i>
                                            </div>
                                            <p class="font-semibold text-gray-800">Inactivo</p>
                                            <p class="text-xs text-gray-500">Sin actividad</p>
                                        </label>

                                        <label class="radio-option">
                                            <input type="radio" name="estado" value="LICENCIA" 
                                                   <%= (editar && "LICENCIA".equals(admin.getEstado())) ? "checked" : "" %>
                                                   class="hidden">
                                            <div class="check-icon"><i class="fas fa-check"></i></div>
                                            <div class="status-icon status-licencia-bg">
                                                <i class="fas fa-pause-circle"></i>
                                            </div>
                                            <p class="font-semibold text-gray-800">Licencia</p>
                                            <p class="text-xs text-gray-500">Permiso temporal</p>
                                        </label>

                                        <label class="radio-option">
                                            <input type="radio" name="estado" value="JUBILADO" 
                                                   <%= (editar && "JUBILADO".equals(admin.getEstado())) ? "checked" : "" %>
                                                   class="hidden">
                                            <div class="check-icon"><i class="fas fa-check"></i></div>
                                            <div class="status-icon status-jubilado-bg">
                                                <i class="fas fa-home"></i>
                                            </div>
                                            <p class="font-semibold text-gray-800">Jubilado</p>
                                            <p class="text-xs text-gray-500">Retirado</p>
                                        </label>

                                    </div>
                                </div>

                                <!-- CÓDIGO ADMINISTRATIVO (solo en edición) -->
                                <% if (editar && admin.getCodigoAdministrativo() != null) { %>
                                <div class="bg-blue-50 border border-blue-200 rounded-lg p-4">
                                    <div class="flex items-center gap-3">
                                        <i class="fas fa-id-card text-blue-600 text-xl"></i>
                                        <div>
                                            <p class="text-sm font-medium text-gray-700">Código de Administrativo</p>
                                            <p class="text-lg font-bold text-blue-600"><%= admin.getCodigoAdministrativo() %></p>
                                        </div>
                                    </div>
                                </div>
                                <% } %>

                            </div>

                            <%-- Botones de acción --%>
                            <div class="bg-gray-50 px-8 py-6 flex justify-between items-center border-t border-gray-200">
                                <a href="AdministrativoServlet" class="btn-modern btn-secondary-modern">
                                    <i class="fas fa-arrow-left"></i> Cancelar
                                </a>
                                <button type="submit" onclick="return validarFormulario()" class="btn-modern btn-primary-modern shadow-lg">
                                    <i class="fas fa-save"></i>
                                    <%= editar ? "Actualizar Administrativo" : "Guardar Administrativo" %>
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
        
        // Solo números en teléfono
        const telefonoInput = document.getElementById('telefonoInput');
        if (telefonoInput) {
            telefonoInput.addEventListener('input', function() {
                this.value = this.value.replace(/[^0-9]/g, '');
                if (this.value.length > 9) this.value = this.value.slice(0, 9);
            });
        }

        // ✅ VALIDAR FECHAS - Controlar que el año solo tenga 4 dígitos
        function validarFecha(inputId) {
            const input = document.getElementById(inputId);
            if (!input) return;

            input.addEventListener('input', function(e) {
                let valor = this.value;
                
                // Si el usuario está escribiendo manualmente
                if (valor.length > 10) {
                    this.value = valor.slice(0, 10);
                }
                
                // Validar formato de año (solo 4 dígitos)
                const partes = valor.split('-');
                if (partes[0] && partes[0].length > 4) {
                    partes[0] = partes[0].slice(0, 4);
                    this.value = partes.join('-');
                }
            });

            input.addEventListener('change', function(e) {
                let valor = this.value;
                if (!valor) return;

                try {
                    const fecha = new Date(valor);
                    const anio = fecha.getFullYear();

                    // Validar rango de años (1900-2100)
                    if (anio < 1900 || anio > 2100) {
                        alert('El año debe estar entre 1900 y 2100');
                        this.value = '';
                        return;
                    }

                    // Validar que el año tenga exactamente 4 dígitos
                    const partes = valor.split('-');
                    if (partes[0].length !== 4) {
                        alert('El año debe tener exactamente 4 dígitos');
                        this.value = '';
                        return;
                    }

                    // Validación específica para fecha de nacimiento
                    if (inputId === 'fechaNacimiento') {
                        const hoy = new Date();
                        const edad = hoy.getFullYear() - anio;
                        
                        if (fecha > hoy) {
                            alert('La fecha de nacimiento no puede ser futura');
                            this.value = '';
                            return;
                        }
                        
                        if (edad > 120) {
                            alert('La fecha de nacimiento no es válida (edad mayor a 120 años)');
                            this.value = '';
                            return;
                        }
                    }

                } catch (error) {
                    console.error('Error al validar fecha:', error);
                }
            });

            // Prevenir copiar/pegar de fechas con años de más de 4 dígitos
            input.addEventListener('paste', function(e) {
                e.preventDefault();
                const pastedData = e.clipboardData.getData('text');
                const partes = pastedData.split('-');
                if (partes[0] && partes[0].length > 4) {
                    partes[0] = partes[0].slice(0, 4);
                }
                this.value = partes.join('-');
            });
        }

        // Aplicar validación a ambos campos de fecha
        validarFecha('fechaNacimiento');
        validarFecha('fechaIngreso');

        function validarFormulario() {
            const nombres = document.querySelector('input[name="nombres"]').value.trim();
            const apellidos = document.querySelector('input[name="apellidos"]').value.trim();
            const correo = document.querySelector('input[name="correo"]').value.trim();
            const cargo = document.querySelector('input[name="cargo"]').value.trim();
            const fechaNacimiento = document.getElementById('fechaNacimiento').value;
            const estado = document.querySelector('input[name="estado"]:checked');
            
            if (!nombres || !apellidos || !correo || !correo.includes('@') || 
                !fechaNacimiento || !cargo || !estado) {
                alert('Por favor complete todos los campos obligatorios');
                return false;
            }

            // ✅ Validación adicional de fechas
            const partesFechaNac = fechaNacimiento.split('-');
            if (partesFechaNac[0] && partesFechaNac[0].length !== 4) {
                alert('El año de la fecha de nacimiento debe tener exactamente 4 dígitos');
                return false;
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
            <% if (!editar) { %>
                // En nuevo: poner fecha de ingreso como hoy
                const fechaIngresoInput = document.getElementById('fechaIngreso');
                if (!fechaIngresoInput.value) {
                    const hoy = new Date();
                    fechaIngresoInput.value = hoy.toISOString().split('T')[0];
                }
            <% } %>
        });
    </script>
</body>
</html>
