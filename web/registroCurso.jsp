<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, modelo.Curso" %>

<%
    // ========== VALIDACIÓN DE SESIÓN ==========
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    String rol = (String) session.getAttribute("rol");
    if (!"admin".equals(rol)) {
        response.sendRedirect("acceso_denegado.jsp");
        return;
    }

    // ========== OBTENER DATOS ==========
    List<Map<String, Object>> turnos = (List<Map<String, Object>>) request.getAttribute("turnos");
    
    if (turnos == null) {
        turnos = new ArrayList<>();
    }
    
    String mensaje = (String) session.getAttribute("mensaje");
    String error = (String) session.getAttribute("error");
    session.removeAttribute("mensaje");
    session.removeAttribute("error");
%>
<%
    // ========== DATOS PARA MODO EDICIÓN ==========
    Curso cursoEditar = (Curso) request.getAttribute("cursoEditar");
    List<Map<String, Object>> horariosEditar = (List<Map<String, Object>>) request.getAttribute("horariosEditar");
    Boolean modoEdicion = (Boolean) request.getAttribute("modoEdicion");
    
    if (modoEdicion == null) modoEdicion = false;
    
    // Debug
    if (modoEdicion && cursoEditar != null) {
        System.out.println("  JSP - Modo edición activado");
        System.out.println("   Curso: " + cursoEditar.getNombre());
        System.out.println("   ID: " + cursoEditar.getId());
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registro de Curso - Sistema Escolar</title>
    
    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- CSS Personalizado -->
    <link rel="stylesheet" href="assets/css/estilos.css">
    
    <style>
        /* ========== ESTILOS PERSONALIZADOS ========== */
        .card-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        
        .form-section {
            background: white;
            border-radius: 10px;
            padding: 25px;
            margin-bottom: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        
        .section-title {
            font-size: 1.2em;
            font-weight: 600;
            color: #667eea;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 3px solid #667eea;
        }
        
        /* Estilos para días de la semana */
        .dias-semana {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }
        
        .dia-checkbox {
            flex: 1;
            min-width: 120px;
        }
        
        .dia-checkbox input[type="checkbox"] {
            display: none;
        }
        
        .dia-checkbox label {
            display: block;
            padding: 12px;
            border: 2px solid #dee2e6;
            border-radius: 8px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s;
            background: white;
        }
        
        .dia-checkbox input[type="checkbox"]:checked + label {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-color: #667eea;
            transform: scale(1.05);
        }
        
        .dia-checkbox label:hover {
            border-color: #667eea;
            box-shadow: 0 2px 8px rgba(102, 126, 234, 0.3);
        }
        
        /* Estilos para horarios agregados */
        .horario-item {
            background: #f8f9fa;
            border: 1px solid #dee2e6;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 10px;
            position: relative;
            transition: all 0.3s;
        }
        
        .horario-item:hover {
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        }
        
        .btn-remove-horario {
            position: absolute;
            top: 10px;
            right: 10px;
        }
        
        /* Mensaje de validación */
        #validation-message {
            display: none;
            margin-top: 10px;
            padding: 12px;
            border-radius: 8px;
            animation: fadeIn 0.3s;
        }
        
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        /* Select deshabilitado */
        select:disabled {
            background-color: #e9ecef;
            cursor: not-allowed;
        }
        
        /* Badges informativos */
        .info-badge {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 5px;
            font-size: 0.85em;
            margin-right: 5px;
        }
        
        .badge-turno {
            background: #e3f2fd;
            color: #1976d2;
        }
        
        .badge-nivel {
            background: #f3e5f5;
            color: #7b1fa2;
        }
    </style>
</head>
<body class="dashboard-page">

    <!-- Header -->
    <jsp:include page="header.jsp" />

    <div class="container mt-4 mb-5">
        
        <!-- ========== TÍTULO ========== -->
        <div class="row mb-4">
            <div class="col-12">
                <div class="d-flex justify-content-between align-items-center">
                    <h2>
                        <i class="fas fa-<%= modoEdicion ? "edit" : "book-open" %> text-primary"></i> 
                        <%= modoEdicion ? "Editar Curso" : "Registro de Curso" %>
                    </h2>
                    <a href="CursoServlet" class="btn btn-secondary">
                        <i class="fas fa-arrow-left"></i> Volver a Cursos
                    </a>
                </div>
            </div>
        </div>

        <!-- ========== MENSAJES ========== -->
        <% if (mensaje != null) { %>
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="fas fa-check-circle"></i> <%= mensaje %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>
        
        <% if (error != null) { %>
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="fas fa-exclamation-circle"></i> <%= error %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>

        <!-- ========== FORMULARIO ========== -->
        <form id="formRegistroCurso" action="RegistroCursoServlet" method="post">
            <% if (modoEdicion && cursoEditar != null) { %>
                <input type="hidden" name="curso_id" value="<%= cursoEditar.getId() %>">
                <input type="hidden" name="accion" value="actualizar">
            <% } else { %>
                <input type="hidden" name="accion" value="registrar">
            <% } %>
        
        <!-- ✅ CAMPOS HIDDEN NECESARIOS PARA EL JAVASCRIPT ✅ -->
        <input type="hidden" id="inputNivel" name="nivel" value="">
        <input type="hidden" id="inputArea" name="area" value="">
        <!-- ============================================== -->
        
            <!-- ========== SECCIÓN 1: NIVEL Y GRADO ========== -->
            <div class="form-section">
                <div class="section-title">
                    <i class="fas fa-layer-group"></i> Paso 1: Seleccionar Nivel y Grado
                </div>

                <div class="row">
                    <!-- Nivel Educativo -->
                    <div class="col-md-6 mb-3">
                        <label class="form-label">
                            <i class="fas fa-school"></i> Nivel Educativo <span class="text-danger">*</span>
                        </label>
                        <select name="nivel_select" id="selectNivel" class="form-select" required>
                            <option value="">-- Seleccione un nivel --</option>
                            <option value="INICIAL">INICIAL (3-5 años)</option>
                            <option value="PRIMARIA">PRIMARIA (1° - 6°)</option>
                            <option value="SECUNDARIA">SECUNDARIA (1° - 5°)</option>
                        </select>
                        <small class="text-muted">
                            <i class="fas fa-info-circle"></i> Primero seleccione el nivel educativo
                        </small>
                    </div>

                    <!-- Grado -->
                    <div class="col-md-6 mb-3">
                        <label class="form-label">
                            <i class="fas fa-graduation-cap"></i> Grado <span class="text-danger">*</span>
                        </label>
                        <select name="grado" id="selectGrado" class="form-select" required disabled>
                            <option value="">Seleccione primero un nivel</option>
                        </select>
                        <small class="text-muted" id="infoGrado">
                            <i class="fas fa-lock"></i> Se habilitará al seleccionar nivel
                        </small>
                    </div>
                </div>
            </div>

            <!-- ========== SECCIÓN 2: TURNO ========== -->
            <div class="form-section">
                <div class="section-title">
                    <i class="fas fa-clock"></i> Paso 2: Seleccionar Turno
                </div>

                <div class="row">
                    <div class="col-md-12 mb-3">
                        <label class="form-label">
                            <i class="fas fa-clock"></i> Turno <span class="text-danger">*</span>
                        </label>
                        <select name="turno" id="selectTurno" class="form-select" required disabled>
                            <option value="">Seleccione primero un grado</option>
                            <% if (turnos != null && !turnos.isEmpty()) {
                                for (Map<String, Object> turno : turnos) { %>
                                    <option value="<%= turno.get("id") %>" 
                                            data-inicio="<%= turno.get("hora_inicio") %>"
                                            data-fin="<%= turno.get("hora_fin") %>">
                                        <%= turno.get("nombre") %> 
                                        (<%= turno.get("hora_inicio") %> - <%= turno.get("hora_fin") %>)
                                    </option>
                            <% }} %>
                        </select>
                        <small class="text-muted">
                            <i class="fas fa-info-circle"></i> El turno determina el horario disponible
                        </small>
                    </div>
                </div>
            </div>

            <!-- ========== SECCIÓN 3: ÁREA Y CURSO ========== -->
            <div class="form-section">
                <div class="section-title">
                    <i class="fas fa-book"></i> Paso 3: Seleccionar Área y Curso
                </div>

                <div class="row">
                    <!-- Área -->
                    <div class="col-md-6 mb-3">
                        <label class="form-label">
                            <i class="fas fa-layer-group"></i> Área Académica <span class="text-danger">*</span>
                        </label>
                        <select id="selectArea" class="form-select" required disabled>
                            <option value="">Seleccione primero un turno</option>
                        </select>
                        <small class="text-muted">
                            <i class="fas fa-lock"></i> Se habilitará al seleccionar turno
                        </small>
                    </div>

                    <!-- Curso -->
                    <div class="col-md-6 mb-3">
                        <label class="form-label">
                            <i class="fas fa-book-open"></i> Nombre del Curso <span class="text-danger">*</span>
                        </label>
                        <select name="curso" id="selectCurso" class="form-select" required disabled>
                            <option value="">Seleccione primero un área</option>
                        </select>
                        <small class="text-muted">
                            <i class="fas fa-lock"></i> Se habilitará al seleccionar área
                        </small>
                    </div>
                </div>
            </div>

            <!-- ========== SECCIÓN 4: PROFESOR Y DETALLES ========== -->
            <div class="form-section">
                <div class="section-title">
                    <i class="fas fa-chalkboard-teacher"></i> Paso 4: Profesor y Detalles del Curso
                </div>

                <div class="row">
                    <!-- Profesor -->
                    <div class="col-md-6 mb-3">
                        <label class="form-label">
                            <i class="fas fa-user-tie"></i> Profesor <span class="text-danger">*</span>
                        </label>
                        <select name="profesor" id="selectProfesor" class="form-select" required disabled>
                            <option value="">Seleccione primero un curso</option>
                        </select>
                        <small class="text-muted">
                            <i class="fas fa-filter"></i> Filtrado por área, turno y nivel
                        </small>
                    </div>

                    <!-- Créditos -->
                    <div class="col-md-6 mb-3">
                        <label class="form-label">
                            <i class="fas fa-star"></i> Créditos <span class="text-danger">*</span>
                        </label>
                        <input type="number" name="creditos" id="inputCreditos" 
                               class="form-control" min="1" max="10" value="1" required>
                        <small class="text-muted">
                            <i class="fas fa-info-circle"></i> Valor entre 1 y 10
                        </small>
                    </div>

                    <!-- Descripción -->
                    <div class="col-md-12 mb-3">
                        <label class="form-label">
                            <i class="fas fa-align-left"></i> Descripción del Curso
                        </label>
                        <textarea name="descripcion" id="inputDescripcion" 
                                  class="form-control" rows="3" 
                                  placeholder="Breve descripción del contenido del curso..."><%= (modoEdicion && cursoEditar != null && cursoEditar.getDescripcion() != null) ? cursoEditar.getDescripcion() : "" %></textarea>
                    </div>
                </div>
            </div>

            <!-- ========== SECCIÓN 5: HORARIOS ========== -->
            <div class="form-section">
                <div class="section-title">
                    <i class="fas fa-calendar-alt"></i> Paso 5: Configurar Horarios de Clase
                </div>

                <!-- Días de la semana -->
                <div class="mb-4">
                    <label class="form-label mb-3">
                        <i class="fas fa-calendar-week"></i> Días de clase <span class="text-danger">*</span>
                    </label>
                    <div class="dias-semana" id="diasSemana">
                        <div class="dia-checkbox">
                            <input type="checkbox" id="diaLunes" value="LUNES">
                            <label for="diaLunes">
                                <i class="fas fa-calendar-day"></i><br>
                                <strong>Lunes</strong>
                            </label>
                        </div>
                        <div class="dia-checkbox">
                            <input type="checkbox" id="diaMartes" value="MARTES">
                            <label for="diaMartes">
                                <i class="fas fa-calendar-day"></i><br>
                                <strong>Martes</strong>
                            </label>
                        </div>
                        <div class="dia-checkbox">
                            <input type="checkbox" id="diaMiercoles" value="MIERCOLES">
                            <label for="diaMiercoles">
                                <i class="fas fa-calendar-day"></i><br>
                                <strong>Miércoles</strong>
                            </label>
                        </div>
                        <div class="dia-checkbox">
                            <input type="checkbox" id="diaJueves" value="JUEVES">
                            <label for="diaJueves">
                                <i class="fas fa-calendar-day"></i><br>
                                <strong>Jueves</strong>
                            </label>
                        </div>
                        <div class="dia-checkbox">
                            <input type="checkbox" id="diaViernes" value="VIERNES">
                            <label for="diaViernes">
                                <i class="fas fa-calendar-day"></i><br>
                                <strong>Viernes</strong>
                            </label>
                        </div>
                    </div>
                    <small class="text-muted d-block mt-2">
                        <i class="fas fa-info-circle"></i> Seleccione los días en los que se dictará el curso
                    </small>
                </div>

                <!-- Contenedor de horarios agregados -->
                <div id="horariosContainer" class="mb-3">
                    <p class="text-muted">
                        <i class="fas fa-info-circle"></i> No hay horarios agregados aún
                    </p>
                </div>

                <!-- Mensaje de validación -->
                <div id="validation-message"></div>

                <!-- Botón agregar horario -->
                <button type="button" id="btnAgregarHorario" class="btn btn-outline-primary" disabled>
                    <i class="fas fa-plus"></i> Agregar Horario
                </button>
                <small class="text-muted d-block mt-2">
                    <i class="fas fa-lock"></i> Seleccione días, turno y profesor para habilitar
                </small>
            </div>

            <!-- ========== BOTONES DE ACCIÓN ========== -->
            <div class="text-end">
                <a href="CursoServlet" class="btn btn-secondary btn-lg">
                    <i class="fas fa-times"></i> Cancelar
                </a>
                <button type="submit" id="btnSubmit" class="btn btn-primary btn-lg" disabled>
                    <i class="fas fa-save"></i> 
                    <%= modoEdicion ? "Guardar Cambios" : "Registrar Curso" %>
                </button>
            </div>
        </form>

    </div>

    <!-- Footer -->
    <footer class="bg-dark text-white py-3 mt-5">
        <div class="container text-center">
            <p class="mb-0">&copy; 2025 Sistema Escolar - Todos los derechos reservados</p>
        </div>
    </footer>
    
    <script>
        const CONTEXTPATH = '<%= request.getContextPath() %>';
    </script>

 <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- ========== JAVASCRIPT COMPLETO ========== -->
    <script>
        // ========== VARIABLES GLOBALES ==========
        let horariosAgregados = [];
        let contadorHorarios = 0;
        let nivelSeleccionado = '';
        let turnoSeleccionado = null;

        // ========== INICIALIZAR AL CARGAR ==========
        document.addEventListener('DOMContentLoaded', function() {
            console.log('🚀 Inicializando formulario de registro');
            inicializarEventos();
        });

        // ========== FUNCIÓN PRINCIPAL DE INICIALIZACIÓN ==========
        function inicializarEventos() {
            document.getElementById('selectNivel').addEventListener('change', cambioNivel);
            document.getElementById('selectGrado').addEventListener('change', cambioGrado);
            document.getElementById('selectTurno').addEventListener('change', cambioTurno);
            document.getElementById('selectArea').addEventListener('change', cambioArea);
            document.getElementById('selectCurso').addEventListener('change', cambioCurso);
            document.getElementById('selectProfesor').addEventListener('change', cambioProfesor);
            
            document.querySelectorAll('#diasSemana input[type="checkbox"]').forEach(checkbox => {
                checkbox.addEventListener('change', verificarHabilitarAgregar);
            });
            
            document.getElementById('btnAgregarHorario').addEventListener('click', agregarHorario);
            document.getElementById('formRegistroCurso').addEventListener('input', validarFormulario);
        }

        // ========== 1. CAMBIO DE NIVEL ==========
        function cambioNivel() {
            const selectNivel = document.getElementById('selectNivel');
            const selectGrado = document.getElementById('selectGrado');
            
            nivelSeleccionado = selectNivel.value;
            document.getElementById('inputNivel').value = nivelSeleccionado;
            
            console.log('📚 Nivel seleccionado:', nivelSeleccionado);
            
            if (nivelSeleccionado) {
                selectGrado.disabled = false;
                selectGrado.innerHTML = '<option value="">Cargando grados...</option>';
                
                fetch(CONTEXTPATH + '/RegistroCursoServlet?accion=obtenerGrados&nivel=' + encodeURIComponent(nivelSeleccionado))
                    .then(response => {
                        if (!response.ok) {
                            throw new Error('HTTP error! status: ' + response.status);
                        }
                        return response.json();
                    })
                    .then(data => {
                        selectGrado.innerHTML = '<option value="">-- Seleccione un grado --</option>';
                        
                        if (data && data.length > 0) {
                            data.forEach(grado => {
                                const option = document.createElement('option');
                                option.value = grado.id;
                                option.textContent = grado.nombre + ' - ' + grado.nivel;
                                selectGrado.appendChild(option);
                            });
                            
                            document.getElementById('infoGrado').innerHTML = 
                                '<i class="fas fa-check-circle text-success"></i> Grados cargados correctamente';
                        } else {
                            selectGrado.innerHTML = '<option value="">No hay grados disponibles</option>';
                            mostrarMensaje('No hay grados disponibles para este nivel', 'warning');
                        }
                    })
                    .catch(error => {
                        console.error('❌ Error al cargar grados:', error);
                        selectGrado.innerHTML = '<option value="">Error al cargar grados</option>';
                        selectGrado.disabled = true;
                        mostrarMensaje('Error al cargar grados: ' + error.message, 'danger');
                    });
                
                resetearCamposSiguientes(selectGrado);
            } else {
                selectGrado.disabled = true;
                selectGrado.innerHTML = '<option value="">Seleccione primero un nivel</option>';
                resetearCamposSiguientes(selectGrado);
            }
        }

        // ========== 2. CAMBIO DE GRADO ==========
        function cambioGrado() {
            const selectGrado = document.getElementById('selectGrado');
            const selectTurno = document.getElementById('selectTurno');
            const gradoId = selectGrado.value;
            
            console.log('🎓 Grado seleccionado:', gradoId);
            
            if (gradoId) {
                selectTurno.disabled = false;
                
                const infoGrado = document.getElementById('infoGrado');
                if (infoGrado) {
                    infoGrado.innerHTML = '<i class="fas fa-check-circle text-success"></i> Grado seleccionado. Ahora seleccione un turno';
                }
                
                resetearCamposSiguientes(selectTurno);
            } else {
                selectTurno.disabled = true;
                selectTurno.selectedIndex = 0;
                resetearCamposSiguientes(selectTurno);
                
                const infoGrado = document.getElementById('infoGrado');
                if (infoGrado) {
                    infoGrado.innerHTML = '<i class="fas fa-lock"></i> Se habilitará al seleccionar nivel';
                }
            }
        }

                // ========== 3. CAMBIO DE TURNO ==========
         function cambioTurno() {
             const selectTurno = document.getElementById('selectTurno');
             const selectArea = document.getElementById('selectArea');

             turnoSeleccionado = selectTurno.value;
             console.log(' Turno seleccionado:', turnoSeleccionado);

             if (turnoSeleccionado && nivelSeleccionado) {
                 selectArea.disabled = false;
                 selectArea.innerHTML = '<option value="">Cargando áreas...</option>';

                 fetch(CONTEXTPATH + '/RegistroCursoServlet?accion=obtenerAreas&nivel=' + encodeURIComponent(nivelSeleccionado))
                     .then(response => response.json())
                     .then(data => {
                         console.log('Áreas recibidas del servidor:', data); // DEBUG

                         selectArea.innerHTML = '<option value="">-- Seleccione un área --</option>';

                         if (data && data.length > 0) {
                             data.forEach(area => {
                                 console.log('  Procesando área:', area); // DEBUG
                                 const option = document.createElement('option');

                                 // ¡IMPORTANTE! Usar el campo correcto
                                 // El DAO devuelve 'nombre' no 'area'
                                 option.value = area.nombre;  // ← ¡CORRECTO!
                                 option.textContent = area.nombre;

                                 if (area.descripcion) option.title = area.descripcion;
                                 selectArea.appendChild(option);
                             });
                             console.log('✅ ' + data.length + ' áreas cargadas correctamente');
                         } else {
                             selectArea.innerHTML = '<option value="">No hay áreas disponibles</option>';
                             console.warn(' No se recibieron áreas del servidor');
                         }
                     })
                     .catch(error => {
                         console.error(' Error al cargar áreas:', error);
                         selectArea.innerHTML = '<option value="">Error al cargar áreas</option>';
                         mostrarMensaje('Error al cargar áreas: ' + error.message, 'danger');
                     });

                 resetearCamposSiguientes(selectArea);
             } else {
                 selectArea.disabled = true;
                 selectArea.innerHTML = '<option value="">Seleccione primero un turno</option>';
                 resetearCamposSiguientes(selectArea);
             }
         }
        // ========== 4. CAMBIO DE ÁREA ==========
            function cambioArea() {
            const selectArea = document.getElementById('selectArea');
            const selectCurso = document.getElementById('selectCurso');
            const inputArea = document.getElementById('inputArea');

            // Obtener el valor seleccionado y el texto (nombre)
            const areaValue = selectArea.value;
            const areaText = selectArea.options[selectArea.selectedIndex].text;

            console.log(' CAMBIO DE ÁREA DETECTADO:');
            console.log('  Valor (value):', areaValue);
            console.log('  Texto (nombre):', areaText);
            console.log('  ¿Es undefined?:', areaValue === 'undefined');
            console.log('  ¿Está vacío?:', areaValue === '');

            // Usar el nombre del área (texto), no solo el valor
            const areaNombre = areaText.trim();
            inputArea.value = areaNombre;

            console.log(' Área seleccionada:', areaNombre);

            if (areaValue && areaValue !== '' && areaValue !== 'undefined' && areaNombre !== '-- Seleccione un área --') {
                selectCurso.disabled = false;
                selectCurso.innerHTML = '<option value="">Cargando cursos...</option>';

                console.log(' Enviando petición para obtener cursos del área:', areaNombre);

                // Enviar petición al servlet
                fetch(CONTEXTPATH + '/RegistroCursoServlet?accion=obtenerCursos&area=' + encodeURIComponent(areaNombre))
                    .then(response => {
                        console.log(' Respuesta recibida, status:', response.status);
                        if (!response.ok) {
                            throw new Error('Error en la respuesta del servidor: ' + response.status);
                        }
                        return response.json();
                    })
                    .then(data => {
                        console.log(' Datos recibidos:', data);
                        selectCurso.innerHTML = '<option value="">-- Seleccione un curso --</option>';

                        if (data && data.length > 0) {
                            data.forEach(curso => {
                                const option = document.createElement('option');
                                option.value = curso.nombre;
                                option.textContent = curso.nombre;
                                if (curso.descripcion) option.title = curso.descripcion;
                                if (curso.creditos) option.textContent += ` (${curso.creditos} créditos)`;
                                selectCurso.appendChild(option);
                            });
                            console.log('✅ ' + data.length + ' cursos cargados correctamente');
                        } else {
                            selectCurso.innerHTML = '<option value="">No hay cursos disponibles para esta área</option>';
                            console.warn('️ No se encontraron cursos para el área:', areaNombre);
                            mostrarMensaje('No se encontraron cursos para el área ' + areaNombre, 'warning');
                        }

                        resetearCamposSiguientes(selectCurso);
                    })
                    .catch(error => {
                        console.error(' Error al cargar cursos:', error);
                        selectCurso.innerHTML = '<option value="">Error al cargar cursos</option>';
                        mostrarMensaje('Error al cargar cursos: ' + error.message, 'danger');
                    });
            } else {
                selectCurso.disabled = true;
                selectCurso.innerHTML = '<option value="">Seleccione primero un área válida</option>';
                resetearCamposSiguientes(selectCurso);
                console.warn('️ Área no seleccionada o inválida');
            }
        }

        // ========== 5. CAMBIO DE CURSO ==========
        function cambioCurso() {
            const selectCurso = document.getElementById('selectCurso');
            const selectProfesor = document.getElementById('selectProfesor');
            const area = document.getElementById('inputArea').value;
            const curso = selectCurso.value;
            
            console.log('📘 Curso seleccionado:', curso);
            
            if (curso && area && turnoSeleccionado && nivelSeleccionado) {
                selectProfesor.disabled = false;
                selectProfesor.innerHTML = '<option value="">Cargando profesores...</option>';
                
                const url = CONTEXTPATH + '/RegistroCursoServlet?accion=obtenerProfesores'
                    + '&curso=' + encodeURIComponent(curso)
                    + '&turno=' + encodeURIComponent(turnoSeleccionado)
                    + '&nivel=' + encodeURIComponent(nivelSeleccionado);
                
                fetch(url)
                    .then(response => response.json())
                    .then(data => {
                        selectProfesor.innerHTML = '<option value="">-- Seleccione un profesor --</option>';
                        
                        if (data && data.length > 0) {
                            data.forEach(profesor => {
                                const option = document.createElement('option');
                                option.value = profesor.id;
                                option.textContent = profesor.nombre_completo + ' - ' + profesor.especialidad;
                                selectProfesor.appendChild(option);
                            });
                        } else {
                            selectProfesor.innerHTML = '<option value="">No hay profesores disponibles</option>';
                            mostrarMensaje('No hay profesores disponibles para este curso y turno', 'warning');
                        }
                    })
                    .catch(error => {
                        console.error('❌ Error al cargar profesores:', error);
                        selectProfesor.innerHTML = '<option value="">Error al cargar profesores</option>';
                        mostrarMensaje('Error al cargar profesores', 'danger');
                    });
            } else {
                selectProfesor.disabled = true;
                selectProfesor.innerHTML = '<option value="">Seleccione primero un curso</option>';
            }
        }

        // ========== 6. CAMBIO DE PROFESOR ==========
        function cambioProfesor() {
            console.log('👨‍🏫 Profesor seleccionado:', document.getElementById('selectProfesor').value);
            verificarHabilitarAgregar();
        }

        // ========== VERIFICAR SI HABILITAR BOTÓN AGREGAR ==========
        function verificarHabilitarAgregar() {
            const anyDiaChecked = Array.from(document.querySelectorAll('#diasSemana input[type="checkbox"]'))
                .some(cb => cb.checked);
            const turno = document.getElementById('selectTurno').value;
            const profesor = document.getElementById('selectProfesor').value;
            const btnAgregar = document.getElementById('btnAgregarHorario');

            if (anyDiaChecked && turno && profesor) {
                btnAgregar.disabled = false;
            } else {
                btnAgregar.disabled = true;
            }
            
            validarFormulario();
        }

        // ========== AGREGAR HORARIO ==========
        function agregarHorario() {
            if (document.getElementById('horarioEntry')) {
                return;
            }

            const container = document.createElement('div');
            container.id = 'horarioEntry';
            container.className = 'mt-3 p-3 border rounded bg-light';

            const diasSeleccionados = Array.from(document.querySelectorAll('#diasSemana input[type="checkbox"]'))
                .filter(cb => cb.checked)
                .map(cb => cb.value);

            const diaSelect = document.createElement('select');
            diaSelect.className = 'form-select mb-2';
            diaSelect.id = 'horarioDia';
            diasSeleccionados.forEach(d => {
                const o = document.createElement('option');
                o.value = d;
                o.textContent = d.charAt(0) + d.slice(1).toLowerCase();
                diaSelect.appendChild(o);
            });

            const horaInicio = document.createElement('input');
            horaInicio.type = 'time';
            horaInicio.className = 'form-control mb-2';
            horaInicio.id = 'horarioHoraInicio';

            const horaFin = document.createElement('input');
            horaFin.type = 'time';
            horaFin.className = 'form-control mb-2';
            horaFin.id = 'horarioHoraFin';

            const btnValidar = document.createElement('button');
            btnValidar.type = 'button';
            btnValidar.className = 'btn btn-success me-2';
            btnValidar.innerHTML = '<i class="fas fa-check"></i> Validar y Agregar';

            const btnCancelar = document.createElement('button');
            btnCancelar.type = 'button';
            btnCancelar.className = 'btn btn-secondary';
            btnCancelar.innerHTML = '<i class="fas fa-times"></i> Cancelar';

            container.appendChild(createLabel('Día'));
            container.appendChild(diaSelect);
            container.appendChild(createLabel('Hora inicio'));
            container.appendChild(horaInicio);
            container.appendChild(createLabel('Hora fin'));
            container.appendChild(horaFin);
            container.appendChild(btnValidar);
            container.appendChild(btnCancelar);

            document.getElementById('horariosContainer').prepend(container);

            btnCancelar.addEventListener('click', () => container.remove());

            btnValidar.addEventListener('click', async () => {
                const dia = diaSelect.value;
                const hInicio = horaInicio.value;
                const hFin = horaFin.value;
                const turnoId = document.getElementById('selectTurno').value;
                const profesorId = document.getElementById('selectProfesor').value;

                if (!dia || !hInicio || !hFin) {
                    mostrarMensaje('Complete día, hora inicio y hora fin', 'warning');
                    return;
                }

                if (hInicio >= hFin) {
                    mostrarMensaje('La hora de inicio debe ser anterior a la hora fin', 'warning');
                    return;
                }

                try {
                    const respTurno = await fetch(CONTEXTPATH + '/RegistroCursoServlet?accion=validarHorario'
                        + '&turnoId=' + encodeURIComponent(turnoId)
                        + '&horaInicio=' + encodeURIComponent(hInicio)
                        + '&horaFin=' + encodeURIComponent(hFin));
                    const dataTurno = await respTurno.json();
                    
                    if (!dataTurno.dentro_rango) {
                        mostrarMensaje(dataTurno.mensaje || 'Horario fuera del rango del turno', 'danger');
                        return;
                    }
                } catch (err) {
                    console.error('Error validando turno', err);
                    mostrarMensaje('Error al validar horario en el turno', 'danger');
                    return;
                }

                try {
                    const url = CONTEXTPATH + '/RegistroCursoServlet?accion=validarDisponibilidad'
                        + '&profesorId=' + encodeURIComponent(profesorId)
                        + '&turnoId=' + encodeURIComponent(turnoId)
                        + '&diaSemana=' + encodeURIComponent(dia)
                        + '&horaInicio=' + encodeURIComponent(hInicio)
                        + '&horaFin=' + encodeURIComponent(hFin);
                    const respDispon = await fetch(url);
                    const dataDisp = await respDispon.json();

                    if (!dataDisp.disponible) {
                        mostrarMensaje(dataDisp.mensaje || 'Profesor no disponible para ese horario', 'warning');
                        return;
                    }
                } catch (err) {
                    console.error('Error validando disponibilidad', err);
                    mostrarMensaje('Error al validar disponibilidad del profesor', 'danger');
                    return;
                }

                horariosAgregados.push({
                    id: ++contadorHorarios,
                    dia: dia,
                    hora_inicio: hInicio,
                    hora_fin: hFin
                });

                container.remove();
                renderHorarios();
                mostrarMensaje('Horario agregado correctamente', 'success');
                validarFormulario();
            });
        }

        function createLabel(text) {
            const lbl = document.createElement('label');
            lbl.className = 'form-label mt-2 fw-bold';
            lbl.textContent = text;
            return lbl;
        }

        // ========== RENDERIZAR HORARIOS ==========
        function renderHorarios() {
            const container = document.getElementById('horariosContainer');
            container.innerHTML = '';

            if (horariosAgregados.length === 0) {
                container.innerHTML = '<p class="text-muted"><i class="fas fa-info-circle"></i> No hay horarios agregados aún</p>';
                removeHiddenHorarioInputs();
                return;
            }

            removeHiddenHorarioInputs();
            horariosAgregados.forEach((h, idx) => {
                const item = document.createElement('div');
                item.className = 'horario-item';

                const texto = document.createElement('div');
                texto.innerHTML = '<strong>' + h.dia + '</strong> — ' + h.hora_inicio + ' a ' + h.hora_fin;

                const btnRemove = document.createElement('button');
                btnRemove.type = 'button';
                btnRemove.className = 'btn btn-sm btn-danger btn-remove-horario';
                btnRemove.innerHTML = '<i class="fas fa-trash"></i>';
                btnRemove.addEventListener('click', () => {
                    horariosAgregados.splice(idx, 1);
                    renderHorarios();
                    validarFormulario();
                });

                item.appendChild(texto);
                item.appendChild(btnRemove);
                container.appendChild(item);

                appendHiddenInput('dias[]', h.dia);
                appendHiddenInput('horasInicio[]', h.hora_inicio);
                appendHiddenInput('horasFin[]', h.hora_fin);
            });
        }

        function appendHiddenInput(name, value) {
            const input = document.createElement('input');
            input.type = 'hidden';
            input.name = name;
            input.value = value;
            input.dataset.autocreated = 'true';
            document.getElementById('formRegistroCurso').appendChild(input);
        }

        function removeHiddenHorarioInputs() {
            const form = document.getElementById('formRegistroCurso');
            Array.from(form.querySelectorAll('input[data-autocreated="true"]')).forEach(i => i.remove());
        }

        // ========== VALIDACIÓN GLOBAL ==========
        function validarFormulario() {
            const nivel = document.getElementById('inputNivel').value;
            const grado = document.getElementById('selectGrado').value;
            const turno = document.getElementById('selectTurno').value;
            const curso = document.getElementById('selectCurso').value;
            const profesor = document.getElementById('selectProfesor').value;
            const creditos = document.getElementById('inputCreditos').value;
            const btnSubmit = document.getElementById('btnSubmit');

            const valido = nivel && grado && turno && curso && profesor && creditos && horariosAgregados.length > 0;
            btnSubmit.disabled = !valido;
        }

        // ========== MENSAJES ==========
        function mostrarMensaje(texto, tipo) {
            const div = document.getElementById('validation-message');
            div.style.display = 'block';
            div.className = 'alert alert-' + tipo;
            div.innerHTML = '<i class="fas fa-' + (tipo === 'success' ? 'check' : tipo === 'danger' ? 'exclamation' : 'info') + '-circle"></i> ' + texto;

            setTimeout(() => {
                div.style.display = 'none';
            }, 6000);
        }

        // ========== RESETEAR CAMPOS ==========
        function resetearCamposSiguientes(elemento) {
            const selectGrado = document.getElementById('selectGrado');
            const selectTurno = document.getElementById('selectTurno');
            const selectArea = document.getElementById('selectArea');
            const selectCurso = document.getElementById('selectCurso');
            const selectProfesor = document.getElementById('selectProfesor');

            if (elemento === selectGrado) {
                selectTurno.disabled = true;
                selectTurno.selectedIndex = 0;
                selectArea.disabled = true;
                selectArea.innerHTML = '<option value="">Seleccione primero un turno</option>';
                selectCurso.disabled = true;
                selectCurso.innerHTML = '<option value="">Seleccione primero un área</option>';
                selectProfesor.disabled = true;
                selectProfesor.innerHTML = '<option value="">Seleccione primero un curso</option>';
            }

            if (elemento === selectTurno) {
                selectArea.disabled = true;
                selectArea.innerHTML = '<option value="">Seleccione primero un turno</option>';
                selectCurso.disabled = true;
                selectCurso.innerHTML = '<option value="">Seleccione primero un área</option>';
                selectProfesor.disabled = true;
                selectProfesor.innerHTML = '<option value="">Seleccione primero un curso</option>';
            }

            if (elemento === selectArea) {
                selectCurso.disabled = true;
                selectCurso.innerHTML = '<option value="">Seleccione primero un área</option>';
                selectProfesor.disabled = true;
                selectProfesor.innerHTML = '<option value="">Seleccione primero un curso</option>';
            }

            if (elemento === selectCurso) {
                selectProfesor.disabled = true;
                selectProfesor.innerHTML = '<option value="">Seleccione primero un curso</option>';
            }

            document.querySelectorAll('#diasSemana input[type="checkbox"]').forEach(cb => cb.checked = false);
            horariosAgregados = [];
            contadorHorarios = 0;
            renderHorarios();
            document.getElementById('btnAgregarHorario').disabled = true;
            validarFormulario();
        }

        // ========== EVENTO SUBMIT ==========
        document.getElementById('formRegistroCurso').addEventListener('submit', function(e) {
            if (horariosAgregados.length === 0) {
                e.preventDefault();
                mostrarMensaje('Debe agregar al menos un horario antes de registrar el curso', 'warning');
                return false;
            }
            return true;
        });
        
                // Función para inicializar el formulario en modo edición
        function inicializarFormularioEdicion() {
            // Detectar si estamos en modo edición
            const selectCurso = document.getElementById('selectCurso');
            const selectProfesor = document.getElementById('selectProfesor');
            const selectTurno = document.getElementById('selectTurno');

            // Si hay un curso ya seleccionado (modo edición)
            if (selectCurso && selectCurso.value) {
                console.log('🔧 Detectado modo EDICIÓN - Cargando profesores filtrados');

                // Guardar el profesor que estaba seleccionado
                const profesorSeleccionado = selectProfesor ? selectProfesor.value : null;

                // Esperar un momento para que las variables globales se inicialicen
                setTimeout(() => {
                    // Simular el cambio de curso para cargar profesores filtrados
                    cambioCurso();

                    // Después de cargar los profesores, reseleccionar el profesor original
                    if (profesorSeleccionado) {
                        setTimeout(() => {
                            if (selectProfesor) {
                                selectProfesor.value = profesorSeleccionado;
                                console.log('✅ Profesor reseleccionado:', profesorSeleccionado);
                            }
                        }, 500);
                    }
                }, 300);
            }
        }

        // Ejecutar cuando el DOM esté completamente cargado
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', inicializarFormularioEdicion);
        } else {
            // DOM ya está listo
            inicializarFormularioEdicion();
        }
    </script>
</body>
</html>