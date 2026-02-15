<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="modelo.Profesor" %>
<%@ page import="modelo.Area" %>
<%@ page import="modelo.ProfesorNivelArea" %>
<%@ page import="java.util.List" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.time.LocalTime" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    Profesor p = (Profesor) request.getAttribute("profesor");
    List<Area> areas = (List<Area>) request.getAttribute("areas");
    boolean editar = (p != null);
    
    String fechaNacimientoStr = "";
    String fechaContratacionStr = "";
    
    if (editar) {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        if (p.getFechaNacimiento() != null) {
            fechaNacimientoStr = sdf.format(p.getFechaNacimiento());
        }
        if (p.getFechaContratacion() != null) {
            fechaContratacionStr = sdf.format(p.getFechaContratacion());
        }
    }
    
    // Título para el header dinámico
    request.setAttribute("pageTitle", editar ? "Editar Profesor" : "Registrar Profesor");
%>

<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= editar ? "Editar Profesor" : "Registrar Profesor" %> - San Antonio</title>

    <%-- ✅ Incluir HEAD común --%>
    <%@ include file="includes/head.jsp" %>

    <style>
        .step-section { display: none; animation: fadeIn 0.4s ease-in-out; }
        .step-section.active { display: block; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
        .input-figma { background-color: #ffffff; border: 1px solid #d1d5db; border-radius: 0.5rem; transition: all 0.2s; }
        .input-figma:focus { border-color: #135bec; box-shadow: 0 0 0 3px rgba(19, 91, 236, 0.1); }
        .required-field::after { content: " *"; color: #ef4444; font-weight: bold; }
        .asignacion-item { background: #ffffff; border: 1px solid #e5e7eb; border-radius: 0.75rem; padding: 1.25rem; margin-bottom: 1rem; box-shadow: 0 1px 2px rgba(0,0,0,0.05); }
        .asignacion-principal { background: #eff6ff; border-color: #bfdbfe; }
    </style>
</head>
<body class="bg-gray-100 min-h-screen">

    <div class="flex h-screen overflow-hidden">

        <%-- ✅ SIDEBAR --%>
        <%@ include file="includes/sidebar.jsp" %>

        <main class="flex-1 flex flex-col overflow-y-auto">

            <%-- ✅ HEADER con foto dinámica --%>
            <%@ include file="includes/header.jsp" %>

            <div class="p-4 md:p-8 max-w-5xl mx-auto w-full">

                <%-- Alertas --%>
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

                <form action="ProfesorServlet" method="post" id="profesorForm" novalidate enctype="multipart/form-data">
                    <input type="hidden" name="id" value="<%= editar ? p.getId() : "" %>">
                    <input type="hidden" name="accion" value="<%= editar ? "actualizar" : "guardar" %>">
                    <input type="hidden" name="codigo_profesor" value="<%= (editar && p.getCodigoProfesor() != null) ? p.getCodigoProfesor() : "" %>">

                    <%-- ══════════════ PASO 1: INFORMACIÓN PERSONAL ══════════════ --%>
                    <div id="step1" class="step-section active">
                        <div class="bg-white rounded-2xl shadow-xl overflow-hidden border border-gray-200">

                            <%-- Cabecera con foto --%>
                            <div class="bg-primary text-white p-6 flex items-center gap-6">
                                <div class="relative group cursor-pointer" onclick="document.getElementById('inputFoto').click()">
                                    <input type="file" name="foto" id="inputFoto" class="hidden" accept="image/*" onchange="previsualizarImagen(this)">
                                    <div class="w-24 h-24 bg-white/20 rounded-full flex items-center justify-center backdrop-blur-sm border-4 border-white/30 overflow-hidden hover:bg-white/30 transition shadow-lg relative">
                                        <img id="imgPreview"
                                             src="<%= (editar && p.getFoto() != null && !p.getFoto().isEmpty()) ? "uploads/" + p.getFoto() : "" %>"
                                             class="w-full h-full object-cover <%= (editar && p.getFoto() != null && !p.getFoto().isEmpty()) ? "" : "hidden" %>">
                                        <div id="placeholderIcon" class="<%= (editar && p.getFoto() != null && !p.getFoto().isEmpty()) ? "hidden" : "flex" %> flex-col items-center justify-center text-white">
                                            <% if (editar) { %>
                                                <span class="text-2xl font-bold">
                                                    <%= p.getNombres().substring(0,1) %><%= p.getApellidos().substring(0,1) %>
                                                </span>
                                            <% } else { %>
                                                <i class="fas fa-camera text-3xl mb-1"></i>
                                                <span class="text-xs">Subir foto</span>
                                            <% } %>
                                        </div>
                                        <div class="absolute inset-0 bg-black/40 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
                                            <i class="fas fa-pen text-white"></i>
                                        </div>
                                    </div>
                                    <div class="absolute bottom-0 right-0 bg-white text-primary rounded-full p-1.5 shadow-md border border-gray-200">
                                        <i class="fas fa-camera text-xs"></i>
                                    </div>
                                </div>
                                <div>
                                    <h1 class="text-2xl font-bold tracking-wide">
                                        <%= editar ? "Editar Profesor" : "Registrar Nuevo Profesor" %>
                                    </h1>
                                    <p class="text-blue-100 text-sm opacity-90">Paso 1: Información Personal</p>
                                </div>
                            </div>

                            <div class="p-8">
                                <h3 class="text-primary font-bold text-lg mb-4 border-b pb-2 flex items-center gap-2">
                                    <i class="fas fa-address-card"></i> Información Personal
                                </h3>

                                <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                                    <div>
                                        <label class="block text-sm font-bold text-gray-700 mb-1 required-field">Nombres</label>
                                        <input type="text" class="input-figma w-full p-3" name="nombres" id="nombres"
                                               value="<%= editar && p.getNombres() != null ? p.getNombres() : "" %>" required placeholder="Ej: Ricardo Juan">
                                        <div class="text-xs text-red-500 mt-1 hidden" id="error-nombres">Este campo es obligatorio</div>
                                    </div>
                                    <div>
                                        <label class="block text-sm font-bold text-gray-700 mb-1 required-field">Apellidos</label>
                                        <input type="text" class="input-figma w-full p-3" name="apellidos" id="apellidos"
                                               value="<%= editar && p.getApellidos() != null ? p.getApellidos() : "" %>" required placeholder="Ej: Tapia Carbajal">
                                        <div class="text-xs text-red-500 mt-1 hidden" id="error-apellidos">Este campo es obligatorio</div>
                                    </div>
                                </div>

                                <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                                    <div>
                                        <label class="block text-sm font-bold text-gray-700 mb-1 required-field">Correo electrónico</label>
                                        <input type="email" class="input-figma w-full p-3" name="correo" id="correo"
                                               value="<%= editar && p.getCorreo() != null ? p.getCorreo() : "" %>" required placeholder="Ej: Juan23@gmail.com">
                                        <div class="text-xs text-red-500 mt-1 hidden" id="error-correo">Este campo es obligatorio</div>
                                    </div>
                                    <div>
                                        <label class="block text-sm font-bold text-gray-700 mb-1 required-field">DNI</label>
                                        <input type="text" class="input-figma w-full p-3" name="dni" id="dni"
                                               value="<%= editar && p.getDni() != null ? p.getDni() : "" %>" maxlength="8" placeholder="Solo se admiten 8 números">
                                        <div class="text-xs text-red-500 mt-1 hidden" id="error-dni">Este campo es obligatorio</div>
                                    </div>
                                </div>

                                <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                                    <div>
                                        <label class="block text-sm font-bold text-gray-700 mb-1 required-field">Fecha de Nacimiento</label>
                                        <input type="date" class="input-figma w-full p-3" name="fecha_nacimiento" id="fecha_nacimiento"
                                               value="<%= fechaNacimientoStr %>" max="9999-12-31" onblur="validarAnio(this)">
                                        <div class="text-xs text-red-500 mt-1 hidden" id="error-fecha">Seleccione una fecha válida</div>
                                    </div>
                                    <div>
                                        <label class="block text-sm font-bold text-gray-700 mb-1 required-field">Teléfono</label>
                                        <input type="tel" class="input-figma w-full p-3" name="telefono" id="telefono"
                                               value="<%= editar && p.getTelefono() != null ? p.getTelefono() : "" %>" maxlength="9" placeholder="9 dígitos, empieza con 9">
                                        <div class="text-xs text-red-500 mt-1 hidden" id="error-telefono">Este campo es obligatorio</div>
                                    </div>
                                </div>

                                <div class="mb-6">
                                    <label class="block text-sm font-bold text-gray-700 mb-1 required-field">Dirección</label>
                                    <input type="text" class="input-figma w-full p-3" name="direccion" id="direccion"
                                           value="<%= editar && p.getDireccion() != null ? p.getDireccion() : "" %>" placeholder="Ej: Av. la Marina 137">
                                    <div class="text-xs text-red-500 mt-1 hidden" id="error-direccion">Este campo es obligatorio</div>
                                </div>

                                <div class="flex justify-between items-center mt-8 pt-4 border-t border-gray-300">
                                    <a href="ProfesorServlet" class="btn-modern btn-secondary-modern">
                                        <i class="fas fa-arrow-left"></i> Cancelar
                                    </a>
                                    <button type="button" onclick="validarYPasarSiguiente()" class="btn-modern btn-primary-modern">
                                        SIGUIENTE <i class="fas fa-arrow-right"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <%-- ══════════════ PASO 2: INFORMACIÓN PROFESIONAL ══════════════ --%>
                    <div id="step2" class="step-section">
                        <div class="bg-white rounded-2xl shadow-xl overflow-hidden border border-gray-200">

                            <div class="bg-primary text-white p-6 flex items-center gap-4">
                                <div class="w-12 h-12 bg-white/20 rounded-full flex items-center justify-center backdrop-blur-sm">
                                    <i class="fas fa-briefcase text-2xl"></i>
                                </div>
                                <div>
                                    <h1 class="text-2xl font-bold tracking-wide">
                                        <%= editar ? "Editar Profesor" : "Registrar Nuevo Profesor" %>
                                    </h1>
                                    <p class="text-blue-100 text-sm opacity-90">Paso 2: Información Profesional</p>
                                </div>
                            </div>

                            <div class="p-8">
                                <h3 class="text-primary font-bold text-lg mb-4 border-b pb-2 flex items-center gap-2">
                                    <i class="fas fa-layer-group"></i> Niveles y Áreas
                                </h3>

                                <div id="asignaciones-container" class="mb-4 space-y-4"></div>

                                <div class="mb-8">
                                    <button type="button" onclick="agregarAsignacion()" class="text-primary font-bold hover:underline flex items-center gap-2 text-sm">
                                        <i class="fas fa-plus-circle"></i> Agregar otro Nivel/Área
                                    </button>
                                </div>

                                <h3 class="text-primary font-bold text-lg mb-4 border-b pb-2 flex items-center gap-2">
                                    <i class="fas fa-file-contract"></i> Datos Administrativos
                                </h3>

                                <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                                    <div>
                                        <label class="block text-sm font-bold text-gray-700 mb-1 required-field">Fecha de Contratación</label>
                                        <input type="date" class="input-figma w-full p-3" name="fecha_contratacion" id="fecha_contratacion"
                                               value="<%= fechaContratacionStr %>" max="9999-12-31" onblur="validarAnio(this)">
                                        <div class="text-xs text-red-500 mt-1 hidden" id="error-fecha-contratacion">Seleccione una fecha válida</div>
                                    </div>
                                    <div>
                                        <label class="block text-sm font-bold text-gray-700 mb-1">Estado</label>
                                        <select name="estado" class="input-figma w-full p-3">
                                            <option value="ACTIVO"   <%= (editar && "ACTIVO".equals(p.getEstado()))   ? "selected" : "" %>>ACTIVO</option>
                                            <option value="INACTIVO" <%= (editar && "INACTIVO".equals(p.getEstado())) ? "selected" : "" %>>INACTIVO</option>
                                            <option value="LICENCIA" <%= (editar && "LICENCIA".equals(p.getEstado())) ? "selected" : "" %>>LICENCIA</option>
                                            <option value="JUBILADO" <%= (editar && "JUBILADO".equals(p.getEstado())) ? "selected" : "" %>>JUBILADO</option>
                                        </select>
                                    </div>
                                </div>

                                <div class="flex justify-between items-center mt-8 pt-4 border-t border-gray-300">
                                    <button type="button" onclick="volverPasoAnterior()" class="btn-modern btn-secondary-modern">
                                        <i class="fas fa-arrow-left"></i> ATRÁS
                                    </button>
                                    <button type="button" onclick="validarYEnviar()" class="btn-modern bg-green-500 hover:bg-green-600 text-white px-8 py-3 rounded-lg font-bold transition shadow-lg flex items-center gap-2">
                                        <i class="fas fa-check"></i> <%= editar ? "ACTUALIZAR" : "REGISTRAR PROFESOR" %>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
        </main>
    </div>

    <%-- Template para asignaciones --%>
    <template id="asignacion-template">
        <div class="asignacion-item bg-white p-4 rounded-lg border border-gray-200 shadow-sm">
            <div class="flex flex-col md:flex-row gap-4 items-end">
                <div class="flex-1 w-full">
                    <label class="block text-xs font-bold text-gray-500 mb-1">Nivel de educación</label>
                    <select name="asignacion_nivel[]" class="nivel-select w-full p-2 border rounded bg-gray-50" required>
                        <option value="">-- Seleccione --</option>
                        <option value="INICIAL">Inicial</option>
                        <option value="PRIMARIA">Primaria</option>
                        <option value="SECUNDARIA">Secundaria</option>
                    </select>
                </div>
                <div class="flex-1 w-full">
                    <label class="block text-xs font-bold text-gray-500 mb-1">Área</label>
                    <select name="asignacion_area[]" class="area-select w-full p-2 border rounded bg-gray-50" required disabled>
                        <option value="">Primero seleccione nivel</option>
                        <% if (areas != null) { for (Area area : areas) { %>
                            <option value="<%= area.getId() %>" data-nivel="<%= area.getNivel() %>"><%= area.getNombre() %></option>
                        <% } } %>
                    </select>
                </div>
                <div>
                    <button type="button" onclick="eliminarAsignacion(this)" class="text-red-500 hover:text-red-700 p-2">
                        <i class="fas fa-trash-alt"></i>
                    </button>
                </div>
            </div>
            <div class="mt-2 text-xs font-bold text-gray-400 asignacion-numero"></div>
        </div>
    </template>

    <script>
        // Previsualizar imagen
        function previsualizarImagen(input) {
            if (input.files && input.files[0]) {
                var reader = new FileReader();
                reader.onload = function(e) {
                    var icon = document.getElementById('placeholderIcon');
                    if (icon) { icon.classList.add('hidden'); icon.classList.remove('flex'); }
                    var img = document.getElementById('imgPreview');
                    img.src = e.target.result;
                    img.classList.remove('hidden');
                };
                reader.readAsDataURL(input.files[0]);
            }
        }

        // Validar año en inputs de fecha
        function validarAnio(input) {
            if (input.value) {
                const partes = input.value.split('-');
                const anio = partes[0];
                if (anio.length > 4) {
                    input.value = anio.substring(0, 4) + '-' + partes[1] + '-' + partes[2];
                }
            }
        }

        // Validar paso 1 y avanzar
        function validarYPasarSiguiente() {
            const campos = [
                { el: document.getElementById('nombres'),          err: 'error-nombres' },
                { el: document.getElementById('apellidos'),        err: 'error-apellidos' },
                { el: document.getElementById('correo'),           err: 'error-correo' },
                { el: document.getElementById('dni'),              err: 'error-dni' },
                { el: document.getElementById('fecha_nacimiento'), err: 'error-fecha' },
                { el: document.getElementById('telefono'),         err: 'error-telefono' },
                { el: document.getElementById('direccion'),        err: 'error-direccion' },
            ];

            document.querySelectorAll('[id^="error-"]').forEach(el => el.classList.add('hidden'));
            document.querySelectorAll('.input-figma').forEach(el => el.classList.remove('border-red-500', 'ring-2', 'ring-red-200'));

            let valido = true;
            campos.forEach(({ el, err }) => {
                if (!el.value.trim()) {
                    document.getElementById(err).classList.remove('hidden');
                    el.classList.add('border-red-500', 'ring-2', 'ring-red-200');
                    if (valido) el.focus();
                    valido = false;
                }
            });

            // Validar año de fecha nacimiento
            const fechaNac = document.getElementById('fecha_nacimiento');
            if (fechaNac.value) {
                const anio = parseInt(fechaNac.value.split('-')[0]);
                if (anio > 9999 || anio < 1900) {
                    document.getElementById('error-fecha').classList.remove('hidden');
                    fechaNac.classList.add('border-red-500');
                    valido = false;
                }
            }

            if (valido) {
                document.getElementById('step1').classList.remove('active');
                setTimeout(() => {
                    document.getElementById('step2').classList.add('active');
                    window.scrollTo({ top: 0, behavior: 'smooth' });
                }, 100);
            }
        }

        function volverPasoAnterior() {
            document.getElementById('step2').classList.remove('active');
            document.getElementById('step1').classList.add('active');
            window.scrollTo(0, 0);
        }

        function validarYEnviar() {
            const fechaContratacion = document.getElementById('fecha_contratacion');
            let valido = true;

            document.getElementById('error-fecha-contratacion').classList.add('hidden');
            fechaContratacion.classList.remove('border-red-500', 'ring-2', 'ring-red-200');

            if (!fechaContratacion.value) {
                document.getElementById('error-fecha-contratacion').classList.remove('hidden');
                fechaContratacion.classList.add('border-red-500', 'ring-2', 'ring-red-200');
                valido = false;
            }

            const asignaciones = document.querySelectorAll('#asignaciones-container .asignacion-item');
            if (asignaciones.length === 0) {
                alert("Debe asignar al menos un Nivel y Área al profesor.");
                valido = false;
            } else {
                let completas = true;
                asignaciones.forEach(item => {
                    if (!item.querySelector('.nivel-select').value || !item.querySelector('.area-select').value) {
                        completas = false;
                    }
                });
                if (!completas) { alert("Por favor seleccione Nivel y Área en todas las asignaciones."); valido = false; }
            }

            if (valido) document.getElementById('profesorForm').submit();
        }

        // Lógica de asignaciones
        let contadorAsignaciones = 0;

        function agregarAsignacion(nivel = '', areaId = '') {
            const container = document.getElementById('asignaciones-container');
            const template = document.getElementById('asignacion-template');
            const clone = template.content.cloneNode(true);

            const selectNivel = clone.querySelector('.nivel-select');
            const selectArea  = clone.querySelector('.area-select');

            if (nivel) {
                selectNivel.value = nivel;
                filtrarAreasLogica(selectNivel, selectArea, areaId);
            }

            selectNivel.onchange = function() {
                filtrarAreasLogica(this, this.closest('.asignacion-item').querySelector('.area-select'), null);
            };

            container.appendChild(clone);
            contadorAsignaciones++;
            actualizarNumerosAsignacion();
        }

        function filtrarAreasLogica(selectNivel, selectArea, areaIdPreseleccionado) {
            const nivel = selectNivel.value;
            const opciones = selectArea.querySelectorAll('option');
            selectArea.disabled = false;
            let encontrado = false;

            opciones.forEach((op, i) => {
                if (i === 0) { op.textContent = '-- Seleccione área --'; return; }
                const nivelArea = op.getAttribute('data-nivel');
                if (nivel && (nivelArea === nivel || nivelArea === 'TODOS')) {
                    op.style.display = 'block';
                    if (areaIdPreseleccionado && op.value === areaIdPreseleccionado) encontrado = true;
                } else {
                    op.style.display = 'none';
                }
            });

            if (areaIdPreseleccionado && encontrado) {
                selectArea.value = areaIdPreseleccionado;
            } else if (!areaIdPreseleccionado) {
                selectArea.value = "";
            }

            if (!nivel) {
                selectArea.value = "";
                selectArea.disabled = true;
                opciones[0].textContent = 'Primero seleccione nivel';
            }
        }

        function eliminarAsignacion(btn) {
            const container = document.getElementById('asignaciones-container');
            if (container.children.length <= 1) { alert('Debe haber al menos una asignación.'); return; }
            btn.closest('.asignacion-item').remove();
            contadorAsignaciones--;
            actualizarNumerosAsignacion();
        }

        function actualizarNumerosAsignacion() {
            document.querySelectorAll('.asignacion-item').forEach((item, i) => {
                const label = item.querySelector('.asignacion-numero');
                item.classList.remove('asignacion-principal');
                if (i === 0) {
                    item.classList.add('asignacion-principal');
                    label.innerHTML = '<i class="fas fa-star text-yellow-500"></i> Asignación Principal';
                } else {
                    label.innerHTML = `Asignación ${i + 1}`;
                }
            });
        }

        // Inicialización: cargar asignaciones existentes en edición
        document.addEventListener('DOMContentLoaded', function() {
            <% if (editar && p != null && p.getAsignaciones() != null && !p.getAsignaciones().isEmpty()) { %>
                <% for (ProfesorNivelArea asig : p.getAsignaciones()) { %>
                    agregarAsignacion('<%= asig.getNivel() %>', '<%= asig.getAreaId() %>');
                <% } %>
            <% } else { %>
                agregarAsignacion();
            <% } %>
        });
    </script>
</body>
</html>
