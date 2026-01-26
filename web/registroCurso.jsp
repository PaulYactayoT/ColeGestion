<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>

<%
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

    // ========== VALIDACIÓN DEFENSIVA ==========
    List<Map<String, Object>> cursos = (List<Map<String, Object>>) request.getAttribute("cursos");
    List<Map<String, Object>> grados = (List<Map<String, Object>>) request.getAttribute("grados");
    List<Map<String, Object>> turnos = (List<Map<String, Object>>) request.getAttribute("turnos");
    
    // Inicializar listas vacías si son null
    if (cursos == null) {
        cursos = new ArrayList<>();
        System.out.println("WARNING: Lista de cursos es NULL");
    }
    if (grados == null) {
        grados = new ArrayList<>();
        System.out.println("WARNING: Lista de grados es NULL");
    }
    if (turnos == null) {
        turnos = new ArrayList<>();
        System.out.println("WARNING: Lista de turnos es NULL");
    }
    
    System.out.println("JSP - Cursos disponibles: " + cursos.size());
    System.out.println("JSP - Grados disponibles: " + grados.size());
    System.out.println("JSP - Turnos disponibles: " + turnos.size());
    
    String mensaje = (String) session.getAttribute("mensaje");
    String error = (String) session.getAttribute("error");
    session.removeAttribute("mensaje");
    session.removeAttribute("error");
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registro de Curso - Sistema Escolar</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="assets/css/estilos.css">
    
    <style>
        .card-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        
        .horario-item {
            background: #f8f9fa;
            border: 1px solid #dee2e6;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 10px;
            position: relative;
        }
        
        .horario-item:hover {
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        
        .btn-remove-horario {
            position: absolute;
            top: 10px;
            right: 10px;
        }
        
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
            padding: 10px;
            border: 2px solid #dee2e6;
            border-radius: 8px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .dia-checkbox input[type="checkbox"]:checked + label {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-color: #667eea;
        }
        
        .form-section {
            background: white;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        .section-title {
            font-size: 1.1em;
            font-weight: 600;
            color: #667eea;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 2px solid #667eea;
        }
        
        #validation-message {
            display: none;
            margin-top: 10px;
            padding: 10px;
            border-radius: 5px;
        }
    </style>
</head>
<body class="dashboard-page">

    <jsp:include page="header.jsp" />

    <div class="container mt-4 mb-5">
        
        <!-- Título -->
        <div class="row mb-4">
            <div class="col-12">
                <div class="d-flex justify-content-between align-items-center">
                    <h2><i class="fas fa-book-open"></i> Registro de Curso</h2>
                    <a href="CursoServlet" class="btn btn-secondary">
                        <i class="fas fa-arrow-left"></i> Volver a Cursos
                    </a>
                </div>
            </div>
        </div>

        <!-- Mensajes -->
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

        <!-- Formulario -->
        <form id="formRegistroCurso" action="RegistroCursoServlet" method="post">
            <input type="hidden" name="accion" value="registrar">

            <!-- Sección 1: Información Básica -->
            <div class="form-section">
                <div class="section-title">
                    <i class="fas fa-info-circle"></i> Información Básica del Curso
                </div>

                <div class="row">
                    <!-- Curso -->
                    <div class="col-md-6 mb-3">
                        <label class="form-label">
                            <i class="fas fa-book"></i> Nombre del Curso <span class="text-danger">*</span>
                        </label>
                        <select name="curso" id="selectCurso" class="form-select" required>
                            <option value="">-- Seleccione un curso --</option>
                            <% 
                            if (cursos != null && !cursos.isEmpty()) {
                                for (Map<String, Object> curso : cursos) { 
                                    String nombreCurso = (String) curso.get("nombre");
                                    String areaCurso = (String) curso.get("area");

                                    // Escapar caracteres especiales para evitar problemas en HTML
                                    if (nombreCurso != null && areaCurso != null) {
                            %>
                                        <option value="<%= nombreCurso %>" data-area="<%= areaCurso %>">
                                            <%= nombreCurso %> - <%= areaCurso %>
                                        </option>
                            <% 
                                    }
                                }
                            } else {
                            %>
                                <option value="" disabled>No hay cursos disponibles</option>
                            <% } %>
                        </select>
                        <% if (cursos == null || cursos.isEmpty()) { %>
                            <small class="text-danger">⚠️ No se pudieron cargar los cursos</small>
                        <% } %>
                    </div>

                    <!-- Área (oculto) -->
                    <input type="hidden" name="area" id="inputArea">

                    <!-- Grado -->
                    <div class="col-md-6 mb-3">
                        <label class="form-label">
                            <i class="fas fa-graduation-cap"></i> Grado <span class="text-danger">*</span>
                        </label>
                        <select name="grado" id="selectGrado" class="form-select" required>
                            <option value="">-- Seleccione un grado --</option>
                            <% if (grados != null) {
                                for (Map<String, Object> grado : grados) { %>
                                    <option value="<%= grado.get("id") %>">
                                        <%= grado.get("nombre") %> - <%= grado.get("nivel") %>
                                    </option>
                            <% }} %>
                        </select>
                    </div>

                   <!-- Profesor -->
                    <div class="col-md-6 mb-3">
                        <label class="form-label">
                            <i class="fas fa-chalkboard-teacher"></i> Profesor <span class="text-danger">*</span>
                        </label>
                        <select name="profesor" id="selectProfesor" class="form-select" required disabled>
                            <option value="">Seleccione primero un turno y curso</option> 
                        </select>
                        <small class="text-muted">Los profesores se filtran según el turno y curso seleccionados</small>  
                    </div>

                    <!-- Turno -->
                    <div class="col-md-6 mb-3">
                        <label class="form-label">
                            <i class="fas fa-clock"></i> Turno <span class="text-danger">*</span>
                        </label>
                        <select name="turno" id="selectTurno" class="form-select" required>
                            <option value="">-- Seleccione un turno --</option>
                            <% if (turnos != null) {
                                for (Map<String, Object> turno : turnos) { %>
                                    <option value="<%= turno.get("id") %>" 
                                            data-inicio="<%= turno.get("hora_inicio") %>"
                                            data-fin="<%= turno.get("hora_fin") %>">
                                        <%= turno.get("nombre") %> 
                                        (<%= turno.get("hora_inicio") %> - <%= turno.get("hora_fin") %>)
                                    </option>
                            <% }} %>
                        </select>
                    </div>

                    <!-- Créditos -->
                    <div class="col-md-6 mb-3">
                        <label class="form-label">
                            <i class="fas fa-star"></i> Créditos <span class="text-danger">*</span>
                        </label>
                        <input type="number" name="creditos" id="inputCreditos" 
                               class="form-control" min="0" max="10" value="1" required>
                        <small class="text-muted">Valor entre 0 y 10</small>
                    </div>

                    <!-- Descripción -->
                    <div class="col-md-12 mb-3">
                        <label class="form-label">
                            <i class="fas fa-align-left"></i> Descripción
                        </label>
                        <textarea name="descripcion" id="inputDescripcion" 
                                  class="form-control" rows="3" 
                                  placeholder="Breve descripción del curso..."></textarea>
                    </div>
                </div>
            </div>

            <!-- Sección 2: Horarios -->
            <div class="form-section">
                <div class="section-title">
                    <i class="fas fa-calendar-alt"></i> Configuración de Horarios
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
                                Lunes
                            </label>
                        </div>
                        <div class="dia-checkbox">
                            <input type="checkbox" id="diaMartes" value="MARTES">
                            <label for="diaMartes">
                                <i class="fas fa-calendar-day"></i><br>
                                Martes
                            </label>
                        </div>
                        <div class="dia-checkbox">
                            <input type="checkbox" id="diaMiercoles" value="MIERCOLES">
                            <label for="diaMiercoles">
                                <i class="fas fa-calendar-day"></i><br>
                                Miércoles
                            </label>
                        </div>
                        <div class="dia-checkbox">
                            <input type="checkbox" id="diaJueves" value="JUEVES">
                            <label for="diaJueves">
                                <i class="fas fa-calendar-day"></i><br>
                                Jueves
                            </label>
                        </div>
                        <div class="dia-checkbox">
                            <input type="checkbox" id="diaViernes" value="VIERNES">
                            <label for="diaViernes">
                                <i class="fas fa-calendar-day"></i><br>
                                Viernes
                            </label>
                        </div>
                    </div>
                </div>

                <!-- Contenedor de horarios -->
                <div id="horariosContainer">
                    <!-- Los horarios se agregarán dinámicamente aquí -->
                </div>

                <!-- Mensaje de validación -->
                <div id="validation-message"></div>

                <!-- Botón agregar horario -->
                <button type="button" id="btnAgregarHorario" class="btn btn-outline-primary" disabled>
                    <i class="fas fa-plus"></i> Agregar Horario
                </button>
                <small class="text-muted d-block mt-2">
                    <i class="fas fa-info-circle"></i> Seleccione días, turno y profesor para habilitar
                </small>
            </div>

            <!-- Botones de acción -->
            <div class="text-end">
                <a href="CursoServlet" class="btn btn-secondary">
                    <i class="fas fa-times"></i> Cancelar
                </a>
                <button type="submit" id="btnSubmit" class="btn btn-primary" disabled>
                    <i class="fas fa-save"></i> Registrar Curso
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

  
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script>
        // Variables globales
        let horariosAgregados = [];
        let contadorHorarios = 0;

        // Al cargar la página
        document.addEventListener('DOMContentLoaded', function() {
            inicializarEventos();
        });

        function inicializarEventos() {
            // ========== Cargar profesores cuando cambien CURSO o TURNO ==========
            const selectCurso = document.getElementById('selectCurso');
            const selectTurno = document.getElementById('selectTurno');
            const selectProfesor = document.getElementById('selectProfesor');

            // Función auxiliar para cargar profesores
            function actualizarProfesores() {
                const cursoNombre = selectCurso.value;
                const turnoId = selectTurno.value;

                if (cursoNombre && turnoId) {
                    cargarProfesoresPorTurno(turnoId, cursoNombre);
                } else if (!turnoId && cursoNombre) {
                    selectProfesor.innerHTML = '<option value="">Primero seleccione un turno</option>';
                    selectProfesor.disabled = true;
                } else if (!cursoNombre && turnoId) {
                    selectProfesor.innerHTML = '<option value="">Primero seleccione un curso</option>';
                    selectProfesor.disabled = true;
                } else {
                    selectProfesor.innerHTML = '<option value="">Seleccione curso y turno primero</option>';
                    selectProfesor.disabled = true;
                }
            }

            // Evento al cambiar TURNO
            selectTurno.addEventListener('change', actualizarProfesores);

            // Evento al cambiar CURSO
            selectCurso.addEventListener('change', function() {
                const cursoNombre = this.value;
                const area = this.options[this.selectedIndex].getAttribute('data-area');

                if (cursoNombre && area) {
                    document.getElementById('inputArea').value = area;
                } else {
                    document.getElementById('inputArea').value = '';
                }

                actualizarProfesores();
            });

            // Resto de eventos
            document.querySelectorAll('#diasSemana input[type="checkbox"]').forEach(checkbox => {
                checkbox.addEventListener('change', verificarHabilitarAgregar);
            });

            selectProfesor.addEventListener('change', verificarHabilitarAgregar);
            document.getElementById('btnAgregarHorario').addEventListener('click', agregarHorario);

            // Validación en tiempo real del formulario
            document.getElementById('formRegistroCurso').addEventListener('input', function() {
                const curso = selectCurso.value;
                const grado = document.getElementById('selectGrado').value;
                const profesor = selectProfesor.value;
                const turno = selectTurno.value;
                const creditos = document.getElementById('inputCreditos').value;

                const camposBasicos = curso && grado && profesor && turno && creditos;
                const tieneHorarios = horariosAgregados.length > 0;

                document.getElementById('btnSubmit').disabled = !(camposBasicos && tieneHorarios);
            });

            // Validación al enviar
            document.getElementById('formRegistroCurso').addEventListener('submit', function(e) {
                if (horariosAgregados.length === 0) {
                    e.preventDefault();
                    mostrarMensaje('Debe agregar al menos un horario', 'danger');
                    return false;
                }
            });
        }

        function cargarProfesoresPorTurno(turnoId, cursoNombre) {
            console.log('Cargando profesores para turno:', turnoId, 'curso:', cursoNombre);

            const selectProfesor = document.getElementById('selectProfesor');
            selectProfesor.innerHTML = '<option value="">Cargando profesores...</option>';
            selectProfesor.disabled = true;

            const url = 'RegistroCursoServlet?accion=obtenerProfesores&turno=' + turnoId + '&curso=' + encodeURIComponent(cursoNombre);

            fetch(url)
                .then(response => {
                    if (!response.ok) {
                        throw new Error('HTTP error! status: ' + response.status);
                    }
                    return response.json();
                })
                .then(data => {
                    selectProfesor.innerHTML = '<option value="">-- Seleccione un profesor --</option>';

                    if (data && data.length > 0) {
                        data.forEach(profesor => {
                            const option = document.createElement('option');
                            option.value = profesor.id;
                            option.textContent = profesor.nombre_completo + ' - ' + profesor.especialidad;
                            selectProfesor.appendChild(option);
                        });
                        selectProfesor.disabled = false;
                    } else {
                        selectProfesor.innerHTML = '<option value="">No hay profesores disponibles</option>';
                    }
                })
                .catch(error => {
                    console.error('ERROR:', error);
                    selectProfesor.innerHTML = '<option value="">Error al cargar profesores</option>';
                    mostrarMensaje('Error: ' + error.message, 'danger');
                });
        }

        function verificarHabilitarAgregar() {
            const diasSeleccionados = obtenerDiasSeleccionados();
            const turno = document.getElementById('selectTurno').value;
            const profesor = document.getElementById('selectProfesor').value;

            const habilitar = diasSeleccionados.length > 0 && turno && profesor;
            document.getElementById('btnAgregarHorario').disabled = !habilitar;
        }

        function obtenerDiasSeleccionados() {
            const dias = [];
            document.querySelectorAll('#diasSemana input[type="checkbox"]:checked').forEach(checkbox => {
                dias.push(checkbox.value);
            });
            return dias;
        }

        function agregarHorario() {
            const diasSeleccionados = obtenerDiasSeleccionados();
            const turnoSelect = document.getElementById('selectTurno');
            const profesorSelect = document.getElementById('selectProfesor');

            if (diasSeleccionados.length === 0) {
                mostrarMensaje('Seleccione al menos un día', 'warning');
                return;
            }

            if (!turnoSelect.value) {
                mostrarMensaje('Seleccione un turno', 'warning');
                return;
            }

            if (!profesorSelect.value) {
                mostrarMensaje('Seleccione un profesor', 'warning');
                return;
            }

            const turnoId = turnoSelect.value;
            const turnoNombre = turnoSelect.options[turnoSelect.selectedIndex].text;
            const horaInicio = turnoSelect.options[turnoSelect.selectedIndex].getAttribute('data-inicio');
            const horaFin = turnoSelect.options[turnoSelect.selectedIndex].getAttribute('data-fin');

            mostrarModalHorario(diasSeleccionados, turnoId, turnoNombre, horaInicio, horaFin);
        }

        function mostrarModalHorario(dias, turnoId, turnoNombre, horaMinima, horaMaxima) {
            const dia = dias[0];

            const html = '<div class="modal fade" id="modalHorario" tabindex="-1" data-bs-backdrop="static" data-bs-keyboard="false">' +
                '<div class="modal-dialog">' +
                    '<div class="modal-content">' +
                        '<div class="modal-header">' +
                            '<h5 class="modal-title"><i class="fas fa-clock"></i> Configurar Horario - ' + dia + '</h5>' +
                            '<button type="button" class="btn-close" data-bs-dismiss="modal"></button>' +
                        '</div>' +
                        '<div class="modal-body">' +
                            '<p class="text-muted">Turno: ' + turnoNombre + '</p>' +
                            '<div class="mb-3">' +
                                '<label for="modalHoraInicio" class="form-label">Hora de inicio</label>' +
                                '<input type="time" id="modalHoraInicio" class="form-control" min="' + horaMinima + '" max="' + horaMaxima + '" value="' + horaMinima + '" required>' +
                            '</div>' +
                            '<div class="mb-3">' +
                                '<label for="modalHoraFin" class="form-label">Hora de fin</label>' +
                                '<input type="time" id="modalHoraFin" class="form-control" min="' + horaMinima + '" max="' + horaMaxima + '" value="' + horaMaxima + '" required>' +
                            '</div>' +
                            '<div id="modalValidacion" class="alert" style="display:none;"></div>' +
                        '</div>' +
                        '<div class="modal-footer">' +
                            '<button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>' +
                            '<button type="button" class="btn btn-primary" id="btnConfirmarHorario"><i class="fas fa-check"></i> Agregar</button>' +
                        '</div>' +
                    '</div>' +
                '</div>' +
            '</div>';

            const modalAnterior = document.getElementById('modalHorario');
            if (modalAnterior) {
                const instanceAnterior = bootstrap.Modal.getInstance(modalAnterior);
                if (instanceAnterior) instanceAnterior.dispose();
                modalAnterior.remove();
            }

            document.body.insertAdjacentHTML('beforeend', html);

            const modalElement = document.getElementById('modalHorario');
            const modal = new bootstrap.Modal(modalElement);

            document.getElementById('btnConfirmarHorario').addEventListener('click', function() {
                confirmarHorario(dia, turnoId, modal);
            });

            modalElement.addEventListener('hidden.bs.modal', function () {
                modalElement.remove();
            });

            modal.show();
        }

        function confirmarHorario(dia, turnoId, modalInstance) {
            const horaInicio = document.getElementById('modalHoraInicio').value;
            const horaFin = document.getElementById('modalHoraFin').value;
            const profesorId = document.getElementById('selectProfesor').value;

            if (!horaInicio || !horaFin) {
                mostrarValidacionModal('Complete todos los horarios', 'warning');
                return;
            }

            if (horaInicio >= horaFin) {
                mostrarValidacionModal('La hora de fin debe ser mayor a la hora de inicio', 'danger');
                return;
            }

            validarDisponibilidadProfesor(profesorId, turnoId, dia, horaInicio, horaFin, function(disponible, mensaje) {
                if (disponible) {
                    const horario = {
                        id: contadorHorarios++,
                        dia: dia,
                        turnoId: turnoId,
                        horaInicio: horaInicio,
                        horaFin: horaFin
                    };

                    horariosAgregados.push(horario);
                    renderizarHorarios();
                    modalInstance.hide();

                    const checkbox = document.querySelector('#diasSemana input[value="' + dia + '"]');
                    if (checkbox) checkbox.checked = false;

                    verificarHabilitarAgregar();
                    mostrarMensaje('Horario agregado correctamente', 'success');
                    document.getElementById('btnSubmit').disabled = false;
                } else {
                    mostrarValidacionModal(mensaje, 'danger');
                }
            });
        }

        function validarDisponibilidadProfesor(profesorId, turnoId, dia, horaInicio, horaFin, callback) {
            const params = new URLSearchParams({
                accion: 'validarDisponibilidad',
                profesorId: profesorId,
                turnoId: turnoId,
                diaSemana: dia,
                horaInicio: horaInicio,
                horaFin: horaFin
            });

            fetch('RegistroCursoServlet?' + params.toString())
                .then(response => response.json())
                .then(data => callback(data.disponible, data.mensaje))
                .catch(error => {
                    console.error('Error:', error);
                    callback(false, 'Error al validar disponibilidad');
                });
        }

        function mostrarValidacionModal(texto, tipo) {
            const div = document.getElementById('modalValidacion');
            div.className = 'alert alert-' + tipo;
            div.textContent = texto;
            div.style.display = 'block';

            setTimeout(() => div.style.display = 'none', 4000);
        }

        function renderizarHorarios() {
            const container = document.getElementById('horariosContainer');

            if (horariosAgregados.length === 0) {
                container.innerHTML = '<p class="text-muted"><i class="fas fa-info-circle"></i> No hay horarios agregados</p>';
                document.getElementById('btnSubmit').disabled = true;
                return;
            }

            container.innerHTML = '';

            horariosAgregados.forEach(horario => {
                const div = document.createElement('div');
                div.className = 'horario-item';
                div.innerHTML = '<button type="button" class="btn btn-sm btn-danger btn-remove-horario" onclick="eliminarHorario(' + horario.id + ')">' +
                    '<i class="fas fa-times"></i></button>' +
                    '<div class="row">' +
                        '<div class="col-md-4"><strong><i class="fas fa-calendar-day"></i> ' + horario.dia + '</strong></div>' +
                        '<div class="col-md-4"><i class="fas fa-clock"></i> ' + horario.horaInicio + '</div>' +
                        '<div class="col-md-4"><i class="fas fa-clock"></i> ' + horario.horaFin + '</div>' +
                    '</div>' +
                    '<input type="hidden" name="dias[]" value="' + horario.dia + '">' +
                    '<input type="hidden" name="horasInicio[]" value="' + horario.horaInicio + '">' +
                    '<input type="hidden" name="horasFin[]" value="' + horario.horaFin + '">';
                container.appendChild(div);
            });

            const curso = document.getElementById('selectCurso').value;
            const grado = document.getElementById('selectGrado').value;
            const profesor = document.getElementById('selectProfesor').value;
            const turno = document.getElementById('selectTurno').value;
            const creditos = document.getElementById('inputCreditos').value;

            const camposBasicos = curso && grado && profesor && turno && creditos;
            document.getElementById('btnSubmit').disabled = !(camposBasicos && horariosAgregados.length > 0);
        }

        function eliminarHorario(id) {
            horariosAgregados = horariosAgregados.filter(h => h.id !== id);
            renderizarHorarios();
            if (horariosAgregados.length === 0) {
                document.getElementById('btnSubmit').disabled = true;
            }
            mostrarMensaje('Horario eliminado', 'info');
        }

        function mostrarMensaje(texto, tipo) {
            const div = document.getElementById('validation-message');
            div.className = 'alert alert-' + tipo;
            div.textContent = texto;
            div.style.display = 'block';
            setTimeout(() => div.style.display = 'none', 3000);
        }
    </script>

</body>
</html>
                                         
                                       