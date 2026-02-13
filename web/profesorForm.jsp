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
%>

<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= editar ? "Editar Profesor" : "Registrar Profesor" %> - San Antonio</title>
    
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Lexend:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    
    <script id="tailwind-config">
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        "primary": "#135bec",
                        "primary-dark": "#0d47a1",
                        "card-bg": "#f3f4f6",
                    },
                    fontFamily: {
                        "display": ["Lexend"]
                    }
                },
            },
        }
    </script>
    
    <style>
        body { font-family: 'Lexend', sans-serif; }
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
<body class="bg-gray-100 min-h-screen flex text-gray-800">

    <aside class="w-64 bg-white border-r border-gray-200 hidden md:block">
        <div class="p-6">
            <div class="flex items-center gap-3 mb-8">
                <div class="w-10 h-10 bg-primary rounded-lg flex items-center justify-center">
                    <i class="fas fa-school text-white text-xl"></i>
                </div>
                <span class="text-xl font-bold">San Antonio</span>
            </div>
            <nav class="space-y-2">
                <a href="dashboard.jsp" class="flex items-center gap-3 px-4 py-3 text-gray-600 hover:bg-gray-50 rounded-lg"><i class="fas fa-home w-5"></i> Dashboard</a>
                <a href="ProfesorServlet" class="flex items-center gap-3 px-4 py-3 bg-primary text-white rounded-lg"><i class="fas fa-chalkboard-teacher w-5"></i> Profesores</a>
                <a href="EstudianteServlet" class="flex items-center gap-3 px-4 py-3 text-gray-600 hover:bg-gray-50 rounded-lg"><i class="fas fa-user-graduate w-5"></i> Estudiantes</a>
            </nav>
        </div>
    </aside>

    <main class="flex-1 flex flex-col h-screen overflow-y-auto">
        <header class="bg-white border-b border-gray-200 p-4 shadow-sm flex justify-end items-center">
             <div class="flex items-center gap-4">
                <div class="flex items-center gap-2">
                    <div class="w-8 h-8 bg-primary rounded-full flex items-center justify-center">
                        <i class="fas fa-user text-white text-sm"></i>
                    </div>
                    <span class="text-sm font-medium"><%= session.getAttribute("usuario") %></span>
                </div>
            </div>
        </header>

        <div class="p-4 md:p-8 max-w-5xl mx-auto w-full">
            
            <% 
                String error = (String) session.getAttribute("error");
                String mensaje = (String) session.getAttribute("mensaje");
                if (error != null) { session.removeAttribute("error"); %>
                <div class="bg-red-100 border-l-4 border-red-500 text-red-700 p-4 mb-4 rounded shadow-sm" role="alert">
                    <p class="font-bold">Error</p>
                    <p><%= error %></p>
                </div>
            <% } if (mensaje != null) { session.removeAttribute("mensaje"); %>
                <div class="bg-green-100 border-l-4 border-green-500 text-green-700 p-4 mb-4 rounded shadow-sm" role="alert">
                    <p class="font-bold">Éxito</p>
                    <p><%= mensaje %></p>
                </div>
            <% } %>

            <form action="ProfesorServlet" method="post" id="profesorForm" novalidate enctype="multipart/form-data">
                <input type="hidden" name="id" value="<%= editar ? p.getId() : "" %>">
                <input type="hidden" name="accion" value="<%= editar ? "actualizar" : "guardar" %>">
                <input type="hidden" name="codigo_profesor" value="<%= (editar && p.getCodigoProfesor() != null) ? p.getCodigoProfesor() : "" %>">
                
                <div id="step1" class="step-section active">
                    <div class="bg-card-bg rounded-2xl shadow-xl overflow-hidden border border-gray-200">
                        
                        <div class="bg-primary text-white p-6 flex items-center gap-6">
                            
                            <div class="relative group cursor-pointer" onclick="document.getElementById('inputFoto').click()">
                                <input type="file" name="foto" id="inputFoto" class="hidden" accept="image/*" onchange="previsualizarImagen(this)">
                                
                                <div class="w-24 h-24 bg-white/20 rounded-full flex items-center justify-center backdrop-blur-sm border-4 border-white/30 overflow-hidden hover:bg-white/30 transition shadow-lg relative">
                                    
                                    <img id="imgPreview" 
                                         src="<%= (editar && p.getFoto() != null) ? "uploads/" + p.getFoto() : "" %>" 
                                         class="w-full h-full object-cover <%= (editar && p.getFoto() != null) ? "" : "hidden" %>">
                                    
                                    <div id="placeholderIcon" class="<%= (editar && p.getFoto() != null) ? "hidden" : "flex" %> flex-col items-center justify-center text-white">
                                        <% if (editar) { %>
                                            <span class="text-2xl font-bold">
                                                <%= p.getNombres().substring(0,1) %><%= p.getApellidos().substring(0,1) %>
                                            </span>
                                        <% } else { %>
                                            <i class="fas fa-camera text-3xl mb-1"></i>
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
                                <h1 class="text-2xl font-bold italic tracking-wide">
                                    <%= editar ? "Editar Profesor" : "Registrar Nuevo Profesor" %>
                                </h1>
                                <p class="text-blue-100 text-sm opacity-90">
                                    Haga clic en la imagen para subir una foto
                                </p>
                            </div>
                        </div>
                        <div class="p-8">
                            <h3 class="text-primary font-bold text-lg mb-4 border-b pb-2 flex items-center gap-2">
                                <i class="fas fa-address-card"></i> Información Personal
                            </h3>

                            <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                                <div>
                                    <label for="nombres" class="block text-sm font-bold text-gray-700 mb-1 required-field">Nombres</label>
                                    <input type="text" class="input-figma w-full p-3" name="nombres" id="nombres" 
                                           value="<%= editar && p.getNombres() != null ? p.getNombres() : "" %>" required placeholder="Ej: Ricardo Juan">
                                    <div class="text-xs text-red-500 mt-1 hidden" id="error-nombres">Este campo es obligatorio</div>
                                </div>

                                <div>
                                    <label for="apellidos" class="block text-sm font-bold text-gray-700 mb-1 required-field">Apellidos</label>
                                    <input type="text" class="input-figma w-full p-3" name="apellidos" id="apellidos" 
                                           value="<%= editar && p.getApellidos() != null ? p.getApellidos() : "" %>" required placeholder="Ej: Tapia Carbajal">
                                    <div class="text-xs text-red-500 mt-1 hidden" id="error-apellidos">Este campo es obligatorio</div>
                                </div>
                            </div>

                            <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                                <div>
                                    <label for="correo" class="block text-sm font-bold text-gray-700 mb-1 required-field">Correo electrónico</label>
                                    <input type="email" class="input-figma w-full p-3" name="correo" id="correo" 
                                           value="<%= editar && p.getCorreo() != null ? p.getCorreo() : "" %>" required placeholder="Ej: Juan23@gmail.com">
                                    <div class="text-xs text-red-500 mt-1 hidden" id="error-correo">Este campo es obligatorio</div>
                                </div>

                                <div>
                                    <label for="dni" class="block text-sm font-bold text-gray-700 mb-1 required-field">DNI</label>
                                    <input type="text" class="input-figma w-full p-3" name="dni" id="dni" 
                                           value="<%= editar && p.getDni() != null ? p.getDni() : "" %>" maxlength="8" placeholder="Solo se admiten 8 números">
                                    <div class="text-xs text-red-500 mt-1 hidden" id="error-dni">Este campo es obligatorio</div>
                                </div>
                            </div>

                            <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                                <div>
                                    <label for="fecha_nacimiento" class="block text-sm font-bold text-gray-700 mb-1 required-field">Fecha de Nacimiento</label>
                                    <input type="date" class="input-figma w-full p-3" name="fecha_nacimiento" id="fecha_nacimiento" 
                                           value="<%= fechaNacimientoStr %>" max="9999-12-31" onblur="validarAnio(this)">
                                    <div class="text-xs text-red-500 mt-1 hidden" id="error-fecha">Seleccione una fecha válida</div>
                                </div>

                                <div>
                                    <label for="telefono" class="block text-sm font-bold text-gray-700 mb-1 required-field">Teléfono</label>
                                    <input type="tel" class="input-figma w-full p-3" name="telefono" id="telefono" 
                                           value="<%= editar && p.getTelefono() != null ? p.getTelefono() : "" %>" maxlength="9" placeholder="Solo se admiten 9 números y que empiece con 9">
                                    <div class="text-xs text-red-500 mt-1 hidden" id="error-telefono">Este campo es obligatorio</div>
                                </div>
                            </div>

                            <div class="mb-6">
                                <label for="direccion" class="block text-sm font-bold text-gray-700 mb-1 required-field">Dirección</label>
                                <input type="text" class="input-figma w-full p-3" name="direccion" id="direccion" 
                                       value="<%= editar && p.getDireccion() != null ? p.getDireccion() : "" %>" placeholder="Ej: Av. la Marina 137">
                                <div class="text-xs text-red-500 mt-1 hidden" id="error-direccion">Este campo es obligatorio</div>
                            </div>

                            <div class="flex justify-between items-center mt-8 pt-4 border-t border-gray-300">
                                <a href="ProfesorServlet" class="bg-black text-white px-6 py-3 rounded-lg font-bold hover:bg-gray-800 transition shadow-lg flex items-center gap-2">
                                    <i class="fas fa-arrow-left"></i> Volver al panel
                                </a>
                                <button type="button" onclick="validarYPasarSiguiente()" class="bg-blue-400 text-white px-8 py-3 rounded-lg font-bold hover:bg-blue-500 transition shadow-lg flex items-center gap-2">
                                    SIGUIENTE <i class="fas fa-arrow-right"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <div id="step2" class="step-section">
                    <div class="bg-card-bg rounded-2xl shadow-xl overflow-hidden border border-gray-200">
                        <div class="bg-primary text-white p-6 flex items-center gap-4">
                            <div class="w-12 h-12 bg-white/20 rounded-full flex items-center justify-center backdrop-blur-sm">
                                <i class="fas fa-briefcase text-2xl"></i>
                            </div>
                            <div>
                                <h1 class="text-2xl font-bold italic tracking-wide">
                                    <%= editar ? "Editar Profesor" : "Registrar Nuevo Profesor" %>
                                </h1>
                                <p class="text-blue-100 text-sm opacity-90">Paso 2: Información Profesional</p>
                            </div>
                        </div>

                        <div class="p-8">
                            <h3 class="text-primary font-bold text-lg mb-4 border-b pb-2 flex items-center gap-2">
                                <i class="fas fa-layer-group"></i> Niveles y Áreas
                            </h3>

                            <div id="asignaciones-container" class="mb-4 space-y-4">
                            </div>
                            
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
                                    <label class="block text-sm font-bold text-gray-700 mb-1">Fecha de Contratación</label>
                                    <input type="date" class="input-figma w-full p-3" name="fecha_contratacion" 
                                           value="<%= fechaContratacionStr %>"max="9999-12-31" onblur="validarAnio(this)">
                                </div>
                                <div>
                                    <label class="block text-sm font-bold text-gray-700 mb-1">Estado</label>
                                    <select name="estado" class="input-figma w-full p-3">
                                        <option value="ACTIVO" <%= (editar && "ACTIVO".equals(p.getEstado())) ? "selected" : "" %>>ACTIVO</option>
                                        <option value="INACTIVO" <%= (editar && "INACTIVO".equals(p.getEstado())) ? "selected" : "" %>>INACTIVO</option>
                                        <option value="LICENCIA" <%= (editar && "LICENCIA".equals(p.getEstado())) ? "selected" : "" %>>LICENCIA</option>
                                        <option value="JUBILADO" <%= (editar && "JUBILADO".equals(p.getEstado())) ? "selected" : "" %>>JUBILADO</option>
                                    </select>
                                </div>
                            </div>

                            <div class="flex justify-between items-center mt-8 pt-4 border-t border-gray-300">
                                <button type="button" onclick="volverPasoAnterior()" class="bg-black text-white px-6 py-3 rounded-lg font-bold hover:bg-gray-800 transition shadow-lg flex items-center gap-2">
                                    <i class="fas fa-arrow-left"></i> ATRÁS
                                </button>
                                
                                <button type="submit" class="bg-green-500 text-white px-8 py-3 rounded-lg font-bold hover:bg-green-600 transition shadow-lg flex items-center gap-2">
                                    <i class="fas fa-check"></i> <%= editar ? "ACTUALIZAR" : "REGISTRAR PROFESOR" %>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

            </form>
        </div>
    </main>

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
        // ✅ FUNCIÓN PARA PREVISUALIZAR LA IMAGEN
        function previsualizarImagen(input) {
            if (input.files && input.files[0]) {
                var reader = new FileReader();
                reader.onload = function(e) {
                    // Ocultar ícono/iniciales
                    var icon = document.getElementById('placeholderIcon');
                    if(icon) {
                        icon.classList.add('hidden');
                        icon.classList.remove('flex');
                    }
                    
                    // Mostrar imagen
                    var img = document.getElementById('imgPreview');
                    img.src = e.target.result;
                    img.classList.remove('hidden');
                }
                reader.readAsDataURL(input.files[0]);
            }
        }

        // ==========================================
        // 1. VALIDACIÓN DEL WIZARD (MANTENIDA)
        // ==========================================
        function validarAnio(input) {
            if (input.value) {
                const partes = input.value.split('-'); 
                const anio = partes[0];
                if (anio.length > 4) {
                    const anioCorregido = anio.substring(0, 4);
                    input.value = anioCorregido + '-' + partes[1] + '-' + partes[2];
                }
            }
        }

        function validarYPasarSiguiente() {
            const nombres = document.getElementById('nombres');
            const apellidos = document.getElementById('apellidos');
            const correo = document.getElementById('correo');
            const dni = document.getElementById('dni');
            const fechaNac = document.getElementById('fecha_nacimiento');
            const telefono = document.getElementById('telefono');
            const direccion = document.getElementById('direccion');
            
            let valido = true;

            document.querySelectorAll('[id^="error-"]').forEach(el => el.classList.add('hidden'));
            document.querySelectorAll('.input-figma').forEach(el => el.classList.remove('border-red-500', 'ring-2', 'ring-red-200'));

            const mostrarError = (input, idError) => {
                document.getElementById(idError).classList.remove('hidden');
                input.classList.add('border-red-500', 'ring-2', 'ring-red-200');
                if(valido) input.focus(); 
                valido = false;
            };

            if (!nombres.value.trim()) mostrarError(nombres, 'error-nombres');
            if (!apellidos.value.trim()) mostrarError(apellidos, 'error-apellidos');
            if (!correo.value.trim()) mostrarError(correo, 'error-correo');
            if (!dni.value.trim()) mostrarError(dni, 'error-dni');
            
            if (!fechaNac.value) {
                mostrarError(fechaNac, 'error-fecha');
            } else {
                const anio = parseInt(fechaNac.value.split('-')[0]);
                if (anio > 9999 || anio < 1900) {
                    mostrarError(fechaNac, 'error-fecha');
                    alert("Año inválido");
                }
            }

            if (!telefono.value.trim()) mostrarError(telefono, 'error-telefono');
            if (!direccion.value.trim()) mostrarError(direccion, 'error-direccion');

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

        // ==========================================
        // 2. LÓGICA DE ASIGNACIONES (CORREGIDA)
        // ==========================================
        let contadorAsignaciones = 0;

        function agregarAsignacion(nivel = '', areaId = '') {
            const container = document.getElementById('asignaciones-container');
            const template = document.getElementById('asignacion-template');
            // Clonar el nodo
            const clone = template.content.cloneNode(true);
            
            // Obtener referencias a los elementos DENTRO del clon
            const selectNivel = clone.querySelector('.nivel-select');
            const selectArea = clone.querySelector('.area-select');

            // Si estamos en modo EDICIÓN (tenemos datos)
            if (nivel) {
                selectNivel.value = nivel;
                // IMPORTANTE: Llamamos a la función de filtrado pasando el ID preseleccionado
                filtrarAreasLogica(selectNivel, selectArea, areaId);
            }

            // Agregar evento onchange manualmente
            selectNivel.onchange = function() {
                // Al cambiar manualmente, no pasamos areaId para que se resetee
                filtrarAreasLogica(this, this.closest('.asignacion-item').querySelector('.area-select'), null);
            };

            container.appendChild(clone);
            contadorAsignaciones++;
            actualizarNumerosAsignacion();
        }

        // Función que separa la lógica de filtrado para poder reusarla
        function filtrarAreasLogica(selectNivel, selectArea, areaIdPreseleccionado) {
            const nivel = selectNivel.value;
            const opciones = selectArea.querySelectorAll('option');

            // 1. Resetear estado inicial
            selectArea.disabled = false; // DESBLOQUEAR INMEDIATAMENTE
            
            // 2. Filtrar opciones
            let encontradoPreseleccionado = false;

            opciones.forEach((op, index) => {
                if (index === 0) {
                    op.textContent = '-- Seleccione área --';
                    return;
                }
                
                const nivelArea = op.getAttribute('data-nivel');
                
                // Lógica de visualización
                if (nivel && (nivelArea === nivel || nivelArea === 'TODOS')) {
                    op.style.display = 'block'; // Mostrar opción
                    
                    // Si coincide con el que queremos preseleccionar
                    if (areaIdPreseleccionado && op.value === areaIdPreseleccionado) {
                        encontradoPreseleccionado = true;
                    }
                } else {
                    op.style.display = 'none'; // Ocultar opción
                }
            });

            // 3. Asignar valor
            if (areaIdPreseleccionado && encontradoPreseleccionado) {
                selectArea.value = areaIdPreseleccionado; // Poner el valor guardado
            } else if (!areaIdPreseleccionado) {
                selectArea.value = ""; // Resetear si es cambio manual
            }

            // 4. Manejo si no hay nivel
            if (!nivel) {
                selectArea.value = "";
                selectArea.disabled = true; // Bloquear solo si no hay nivel
                opciones[0].textContent = 'Primero seleccione nivel';
            }
        }

        function eliminarAsignacion(btn) {
            const container = document.getElementById('asignaciones-container');
            if (container.children.length <= 1) {
                alert('Debe haber al menos una asignación.');
                return;
            }
            btn.closest('.asignacion-item').remove();
            contadorAsignaciones--;
            actualizarNumerosAsignacion();
        }

        function actualizarNumerosAsignacion() {
            const items = document.querySelectorAll('.asignacion-item');
            items.forEach((item, index) => {
                const label = item.querySelector('.asignacion-numero');
                item.classList.remove('asignacion-principal');
                if (index === 0) {
                    item.classList.add('asignacion-principal');
                    label.innerHTML = '<i class="fas fa-star text-yellow-500"></i> Asignación Principal';
                } else {
                    label.innerHTML = `Asignación ${index + 1}`;
                }
            });
        }

        // ==========================================
        // 3. INICIALIZACIÓN (CARGA DE DATOS)
        // ==========================================
        document.addEventListener('DOMContentLoaded', function() {
            <% if (editar && p != null && p.getAsignaciones() != null && !p.getAsignaciones().isEmpty()) { %>
                // MODO EDICIÓN: Carga los datos existentes
                <% for (ProfesorNivelArea asig : p.getAsignaciones()) { %>
                    // IMPORTANTE: Aquí pasamos los IDs como string
                    agregarAsignacion('<%= asig.getNivel() %>', '<%= asig.getAreaId() %>');
                <% } %>
            <% } else { %>
                // MODO NUEVO
                agregarAsignacion();
            <% } %>
        });
    </script>
</body>
</html>