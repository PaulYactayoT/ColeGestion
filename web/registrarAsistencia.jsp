<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Curso, java.util.List" %>
<%@ page import="modelo.Asistencia, java.util.List" %>
<%
    // Obtener datos del request (seteados por el servlet)
    List<Curso> cursos = (List<Curso>) request.getAttribute("cursos");
    List<Asistencia> asistenciasExistentes = (List<Asistencia>) request.getAttribute("asistenciasExistentes");
    String cursoIdParam = (String) request.getAttribute("cursoIdParam");
    String fechaParam = (String) request.getAttribute("fechaParam");

    // Debug en servidor
    System.out.println("🔄 JSP - cursoIdParam: " + cursoIdParam + ", fechaParam: " + fechaParam);
    System.out.println("🔄 JSP - Cursos recibidos: " + (cursos != null ? cursos.size() : "null"));
    System.out.println("🔄 JSP - Asistencias existentes: " + (asistenciasExistentes != null ? asistenciasExistentes.size() : "0"));
    
    if (cursos != null) {
        for (Curso c : cursos) {
            System.out.println("   - Curso disponible: " + c.getId() + " - " + c.getNombre());
        }
    }

    if (fechaParam == null) {
        fechaParam = java.time.LocalDate.now().toString();
    }
    
    // Crear un mapa de asistencias existentes para fácil acceso
    java.util.Map<Integer, String> estadoAsistenciasMap = new java.util.HashMap<>();
    if (asistenciasExistentes != null) {
        for (Asistencia a : asistenciasExistentes) {
            estadoAsistenciasMap.put(a.getAlumnoId(), a.getEstadoString());
        }
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <title>Registrar Asistencia</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
        <style>
            .estado-seleccionado {
                border: 2px solid #007bff !important;
                background-color: #e7f3ff !important;
            }
            .alumno-item {
                transition: all 0.3s ease;
            }
            .alumno-item:hover {
                background-color: #f8f9fa;
            }
            .btn-estado {
                min-width: 100px;
            }
        </style>
    </head>
    <body>
        <jsp:include page="header.jsp"/>

        <div class="container mt-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2><i class="bi bi-plus-circle"></i> Registrar Asistencia</h2>
                <a href="AsistenciaServlet?accion=verCurso&curso_id=<%= cursoIdParam != null ? cursoIdParam : "" %>" class="btn btn-secondary">
                    <i class="bi bi-arrow-left"></i> Ver Asistencias
                </a>
            </div>

            <!-- Mensajes de éxito/error -->
            <%
                String mensaje = (String) session.getAttribute("mensaje");
                String error = (String) session.getAttribute("error");
                if (mensaje != null) {
            %>
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="bi bi-check-circle"></i> <%= mensaje %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            <%
                    session.removeAttribute("mensaje");
                }
                if (error != null) {
            %>
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="bi bi-exclamation-triangle"></i> <%= error %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            <%
                    session.removeAttribute("error");
                }
            %>

            <div class="card">
                <div class="card-body">
                    <form method="post" action="AsistenciaServlet" id="formAsistencia">
                        <input type="hidden" name="accion" value="registrarGrupal">

                        <div class="row mb-4">
                            <div class="col-md-6">
                                <label for="curso_id" class="form-label">Curso *</label>
                                <select class="form-select" id="curso_id" name="curso_id" required onchange="cargarAlumnos()">
                                    <option value="">Seleccione un curso</option>
                                    <% 
                                    if (cursos != null && !cursos.isEmpty()) {
                                        for (Curso c : cursos) { 
                                            String selected = "";
                                            if (cursoIdParam != null && !cursoIdParam.isEmpty() && 
                                                String.valueOf(c.getId()).equals(cursoIdParam)) {
                                                selected = "selected";
                                                System.out.println("✅ Curso seleccionado: " + c.getId() + " - " + c.getNombre());
                                            }
                                    %>
                                    <option value="<%= c.getId()%>" <%= selected %>>
                                        <%= c.getNombre()%> - <%= c.getGradoNombre() != null ? c.getGradoNombre() : "Grado " + c.getGradoId() %>
                                    </option>
                                    <% 
                                        } 
                                    } else {
                                        System.out.println("❌ JSP - No hay cursos disponibles");
                                    }
                                    %>
                                </select>
                            </div>

                            <div class="col-md-3">
                                <label for="turno_id" class="form-label">Turno *</label>
                                <select class="form-select" id="turno_id" name="turno_id" required onchange="verificarAsistenciasExistentes()">
                                    <option value="1">MAÑANA</option>
                                    <option value="2">TARDE</option>
                                </select>
                            </div>

                            <div class="col-md-3">
                                <label for="fecha" class="form-label">Fecha *</label>
                                <input type="date" class="form-control" id="fecha" name="fecha" 
                                       value="<%= fechaParam %>" required onchange="verificarAsistenciasExistentes()">
                            </div>
                        </div>

                        <div class="row mb-4">
                            <div class="col-md-6">
                                <label for="hora_clase" class="form-label">Hora de Clase *</label>
                                <input type="time" class="form-control" id="hora_clase" name="hora_clase" 
                                       value="08:00" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Acción Rápida</label>
                                <div class="d-flex gap-2">
                                    <button type="button" class="btn btn-outline-success btn-sm" onclick="marcarTodos('PRESENTE')">
                                        <i class="bi bi-check-circle"></i> Todos Presentes
                                    </button>
                                    <button type="button" class="btn btn-outline-warning btn-sm" onclick="marcarTodos('TARDANZA')">
                                        <i class="bi bi-clock"></i> Todos Tardanza
                                    </button>
                                    <button type="button" class="btn btn-outline-danger btn-sm" onclick="marcarTodos('AUSENTE')">
                                        <i class="bi bi-x-circle"></i> Todos Ausentes
                                    </button>
                                </div>
                            </div>
                        </div>

                        <!-- Información del curso seleccionado -->
                        <div id="info-curso" class="alert alert-info" style="display: none;">
                            <i class="bi bi-info-circle"></i>
                            <span id="info-text">Seleccione un curso para ver los alumnos</span>
                        </div>

                        <!-- Lista de alumnos (se cargará dinámicamente) -->
                        <div id="lista-alumnos" class="mb-4">
                            <div class="alert alert-warning">
                                <i class="bi bi-exclamation-triangle"></i> 
                                Seleccione un curso para cargar la lista de alumnos.
                            </div>
                        </div>

                        <div class="d-grid gap-2 d-md-flex justify-content-md-end">
                            <button type="button" class="btn btn-primary" id="btn-guardar" onclick="guardarAsistencias()" disabled>
                                <i class="bi bi-save"></i> Guardar Asistencias
                            </button>
                            <a href="AsistenciaServlet?accion=ver" class="btn btn-secondary">Cancelar</a>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            // Variables globales
            let alumnosData = [];
            let asistenciasExistentesData = {};
            
            // Auto-cargar alumnos si ya hay un curso seleccionado
            document.addEventListener('DOMContentLoaded', function() {
                const cursoSelect = document.getElementById('curso_id');
                const cursoId = cursoSelect.value;
                const fechaInput = document.getElementById('fecha');
                
                console.log("🔄 DOM cargado - Curso seleccionado:", cursoId);
                
                // Inicializar fecha con hoy si está vacía
                if (fechaInput && !fechaInput.value) {
                    const hoy = new Date().toISOString().split('T')[0];
                    fechaInput.value = hoy;
                }
                
                // Si hay un cursoId seleccionado, cargar alumnos automáticamente
                if (cursoId && cursoId !== '') {
                    console.log("🔄 Curso preseleccionado encontrado:", cursoId);
                    
                    // Disparar el evento para cargar los alumnos automáticamente
                    setTimeout(() => {
                        console.log("🚀 Cargando alumnos para curso:", cursoId);
                        cargarAlumnos();
                    }, 500);
                } else {
                    console.log("❌ No hay curso seleccionado automáticamente");
                }
            });

            // Función para cargar alumnos
            function cargarAlumnos() {
                const cursoId = document.getElementById('curso_id').value;
                const cursoTexto = document.getElementById('curso_id').options[document.getElementById('curso_id').selectedIndex].text;
                const infoCurso = document.getElementById('info-curso');
                const listaAlumnos = document.getElementById('lista-alumnos');

                console.log("🎯 Cargando alumnos para curso:", cursoId);

                if (cursoId) {
                    // Mostrar loading
                    listaAlumnos.innerHTML = '<div class="text-center py-4"><div class="spinner-border text-primary" role="status"><span class="visually-hidden">Cargando alumnos...</span></div><p class="mt-2 text-muted">Cargando lista de alumnos...</p></div>';

                    console.log("🔄 Solicitando alumnos para curso:", cursoId);

                    // Realizar petición AJAX
                    fetch('AlumnoServlet?accion=obtenerPorCurso&curso_id=' + cursoId)
                        .then(response => {
                            if (!response.ok) {
                                throw new Error('Error en la respuesta del servidor: ' + response.status);
                            }
                            return response.json();
                        })
                        .then(alumnos => {
                            console.log('✅ Alumnos recibidos:', alumnos);
                            alumnosData = alumnos; // Guardar datos globalmente

                            if (!alumnos || alumnos.length === 0) {
                                listaAlumnos.innerHTML = '<div class="alert alert-warning"><i class="bi bi-exclamation-triangle"></i> No se encontraron alumnos para este curso.</div>';
                                document.getElementById('btn-guardar').disabled = true;
                                return;
                            }

                            // Construir la tabla de alumnos
                            let html = '<h5 class="border-bottom pb-2">Lista de Alumnos</h5>';
                            html += '<div class="table-responsive"><table class="table table-striped">';
                            html += '<thead><tr><th>#</th><th>Alumno</th><th>Estado</th></tr></thead><tbody>';

                            alumnos.forEach((alumno, index) => {
                                // Determinar estado inicial
                                let estadoInicial = '';
                                let estadoPreseleccionado = '';
                                
                                // Verificar si hay asistencias existentes para este alumno
                                if (asistenciasExistentesData[alumno.id]) {
                                    estadoInicial = asistenciasExistentesData[alumno.id];
                                    estadoPreseleccionado = 'selected';
                                }
                                
                                html += '<tr class="alumno-item" id="alumno-' + alumno.id + '">' +
                                        '<td class="text-muted">' + (index + 1) + '</td>' +
                                        '<td><strong>' + alumno.nombres + ' ' + alumno.apellidos + '</strong>' +
                                        '<div class="text-muted small">ID: ' + alumno.id + ' | Código: ' + (alumno.codigo_alumno || 'N/A') + '</div></td>' +
                                        '<td><select class="form-select form-select-sm estado-alumno" ' +
                                        'data-alumno-id="' + alumno.id + '" ' +
                                        'onchange="actualizarEstado(' + alumno.id + ', this.value)" required>' +
                                        '<option value="">Seleccionar</option>' +
                                        '<option value="PRESENTE" ' + (estadoInicial === 'PRESENTE' ? estadoPreseleccionado : '') + '>✅ Presente</option>' +
                                        '<option value="TARDANZA" ' + (estadoInicial === 'TARDANZA' ? estadoPreseleccionado : '') + '>⏰ Tardanza</option>' +
                                        '<option value="AUSENTE" ' + (estadoInicial === 'AUSENTE' ? estadoPreseleccionado : '') + '>❌ Ausente</option>' +
                                        '</select></td></tr>';
                            });

                            html += '</tbody></table></div>';

                            // Agregar botones de acción rápida
                            html += '<div class="mt-3 d-flex gap-2 justify-content-end">' +
                                    '<button type="button" class="btn btn-outline-success btn-sm" onclick="marcarTodos(\'PRESENTE\')">' +
                                    '<i class="bi bi-check-circle"></i> Todos Presentes</button>' +
                                    '<button type="button" class="btn btn-outline-warning btn-sm" onclick="marcarTodos(\'TARDANZA\')">' +
                                    '<i class="bi bi-clock"></i> Todos Tardanza</button>' +
                                    '<button type="button" class="btn btn-outline-danger btn-sm" onclick="marcarTodos(\'AUSENTE\')">' +
                                    '<i class="bi bi-x-circle"></i> Todos Ausentes</button></div>';

                            listaAlumnos.innerHTML = html;

                            // Mostrar información del curso
                            document.getElementById('info-text').innerHTML = '<strong>Curso seleccionado:</strong> ' + cursoTexto + ' | <strong>Total de alumnos:</strong> ' + alumnos.length;
                            infoCurso.style.display = 'block';

                            // Verificar si hay asistencias existentes
                            verificarAsistenciasExistentes();

                            // Habilitar botón de guardar
                            document.getElementById('btn-guardar').disabled = false;

                        })
                        .catch(error => {
                            console.error('❌ Error al cargar alumnos:', error);
                            listaAlumnos.innerHTML = '<div class="alert alert-danger"><i class="bi bi-exclamation-triangle"></i> Error al cargar la lista de alumnos: ' + error.message + '<br><small>Verifica la consola para más detalles</small></div>';
                            document.getElementById('btn-guardar').disabled = true;
                        });

                } else {
                    listaAlumnos.innerHTML = '<div class="alert alert-warning"><i class="bi bi-exclamation-triangle"></i> Seleccione un curso para cargar la lista de alumnos.</div>';
                    infoCurso.style.display = 'none';
                    document.getElementById('btn-guardar').disabled = true;
                }
            }

            // Función para verificar asistencias existentes
            function verificarAsistenciasExistentes() {
                const cursoId = document.getElementById('curso_id').value;
                const fecha = document.getElementById('fecha').value;
                const turnoId = document.getElementById('turno_id').value;
                
                if (!cursoId || !fecha || !turnoId) {
                    return;
                }
                
                console.log("🔍 Verificando asistencias existentes para:", {cursoId, fecha, turnoId});
                
                // Realizar petición para obtener asistencias existentes
                fetch('AsistenciaServlet?accion=verCursoJson&curso_id=' + cursoId + '&fecha=' + fecha + '&turno_id=' + turnoId)
                    .then(response => {
                        if (!response.ok) {
                            throw new Error('Error en la respuesta del servidor: ' + response.status);
                        }
                        return response.json();
                    })
                    .then(asistencias => {
                        console.log('✅ Asistencias existentes recibidas:', asistencias);
                        
                        // Limpiar el mapa de asistencias existentes
                        asistenciasExistentesData = {};
                        
                        // Llenar el mapa con las asistencias existentes
                        asistencias.forEach(asistencia => {
                            asistenciasExistentesData[asistencia.alumnoId] = asistencia.estado;
                        });
                        
                        console.log('📊 Mapa de asistencias:', asistenciasExistentesData);
                        
                        // Si hay alumnos cargados, actualizar sus estados
                        if (alumnosData.length > 0) {
                            actualizarEstadosAlumnos();
                        }
                        
                        // Mostrar mensaje informativo si hay asistencias existentes
                        if (asistencias.length > 0) {
                            mostrarMensajeAsistenciasExistentes(asistencias.length);
                        }
                    })
                    .catch(error => {
                        console.log('ℹ️ No hay asistencias existentes o error:', error.message);
                        // No es un error crítico, solo significa que no hay asistencias
                        asistenciasExistentesData = {};
                    });
            }
            
            // Función para actualizar estados de alumnos
            function actualizarEstadosAlumnos() {
                alumnosData.forEach(alumno => {
                    const estadoSelect = document.querySelector('select[data-alumno-id="' + alumno.id + '"]');
                    if (estadoSelect && asistenciasExistentesData[alumno.id]) {
                        estadoSelect.value = asistenciasExistentesData[alumno.id];
                        
                        // Resaltar la fila del alumno
                        const filaAlumno = document.getElementById('alumno-' + alumno.id);
                        if (filaAlumno) {
                            filaAlumno.classList.add('estado-seleccionado');
                        }
                    }
                });
            }
            
            // Función para mostrar mensaje de asistencias existentes
            function mostrarMensajeAsistenciasExistentes(cantidad) {
                const infoCurso = document.getElementById('info-curso');
                const infoText = document.getElementById('info-text');
                
                if (infoText) {
                    let textoActual = infoText.innerHTML;
                    if (!textoActual.includes('asistencias registradas')) {
                        infoText.innerHTML = textoActual + ' | <strong>Asistencias registradas:</strong> ' + cantidad;
                        infoCurso.classList.remove('alert-info');
                        infoCurso.classList.add('alert-warning');
                    }
                }
            }
            
            // Función para actualizar estado de un alumno
            function actualizarEstado(alumnoId, estado) {
                console.log("📝 Actualizando estado del alumno", alumnoId, "a", estado);
                
                // Resaltar la fila del alumno
                const filaAlumno = document.getElementById('alumno-' + alumnoId);
                if (filaAlumno) {
                    filaAlumno.classList.add('estado-seleccionado');
                }
            }

            // Función para marcar a todos los alumnos con un mismo estado
            function marcarTodos(estado) {
                document.querySelectorAll('.estado-alumno').forEach(select => {
                    select.value = estado;
                    
                    // Resaltar todas las filas
                    const alumnoId = select.getAttribute('data-alumno-id');
                    const filaAlumno = document.getElementById('alumno-' + alumnoId);
                    if (filaAlumno) {
                        filaAlumno.classList.add('estado-seleccionado');
                    }
                });
                
                console.log("✅ Todos los alumnos marcados como:", estado);
            }

            // Función para guardar asistencias
            function guardarAsistencias() {
                console.log("🔄 Procesando guardado de asistencias...");

                // Validar que todos los alumnos tengan estado seleccionado
                const selects = document.querySelectorAll('.estado-alumno');
                const sinSeleccionar = Array.from(selects).filter(select => select.value === '');

                if (sinSeleccionar.length > 0) {
                    alert('❌ Por favor, seleccione el estado para todos los alumnos antes de guardar.');
                    sinSeleccionar[0].focus();
                    return;
                }

                // Validar que haya alumnos cargados
                if (selects.length === 0) {
                    alert('❌ No hay alumnos cargados. Por favor, seleccione un curso primero.');
                    return;
                }

                console.log("✅ Validaciones pasadas, preparando datos...");

                // Mostrar loading en el botón
                const btnGuardar = document.getElementById('btn-guardar');
                const originalText = btnGuardar.innerHTML;
                btnGuardar.innerHTML = '<i class="bi bi-hourglass-split"></i> Guardando...';
                btnGuardar.disabled = true;

                // Crear array de objetos con los estados de los alumnos
                const alumnosArray = [];
                document.querySelectorAll('#lista-alumnos tbody tr').forEach((row) => {
                    const alumnoId = row.querySelector('select[data-alumno-id]').getAttribute('data-alumno-id');
                    const estado = row.querySelector('.estado-alumno').value;
                    alumnosArray.push({
                        alumno_id: parseInt(alumnoId),
                        estado: estado
                    });
                });

                // Eliminar campo JSON anterior si existe
                const existingJsonInput = document.getElementById('alumnos_json');
                if (existingJsonInput) {
                    existingJsonInput.remove();
                }

                // Crear nuevo campo JSON
                const jsonInput = document.createElement('input');
                jsonInput.type = 'hidden';
                jsonInput.name = 'alumnos_json';
                jsonInput.id = 'alumnos_json';
                jsonInput.value = JSON.stringify(alumnosArray);
                document.getElementById('formAsistencia').appendChild(jsonInput);

                console.log("📦 Datos a enviar:", jsonInput.value);
                console.log("🚀 Enviando formulario...");

                // Timeout para evitar que el botón se quede bloqueado
                setTimeout(() => {
                    btnGuardar.innerHTML = originalText;
                    btnGuardar.disabled = false;
                    console.log("⏰ Timeout: Restaurando botón");
                }, 10000);

                // Enviar formulario
                document.getElementById('formAsistencia').submit();
            }
        </script>
    </body>
</html>