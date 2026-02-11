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
    List<Map<String, Object>> aulas = (List<Map<String, Object>>) request.getAttribute("aulas");

    if (turnos == null) turnos = new ArrayList<>();
    if (aulas == null) aulas = new ArrayList<>();
    
    String mensaje = (String) session.getAttribute("mensaje");
    String error = (String) session.getAttribute("error");
    session.removeAttribute("mensaje");
    session.removeAttribute("error");
%>
<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registro de Curso - Sistema Escolar</title>
    
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
        
        .dia-checkbox input[type="checkbox"] { display: none; }
        
        .dia-checkbox label {
            display: block;
            padding: 1rem;
            background: #dbeafe;
            border: 2px solid #93c5fd;
            border-radius: 0.75rem;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s ease;
            font-weight: 600;
        }
        
        .dia-checkbox input[type="checkbox"]:checked + label {
            background: linear-gradient(135deg, #135bec, #0d47a1);
            color: white;
            border-color: #135bec;
            transform: scale(1.05);
        }
        
        .dia-checkbox input[type="checkbox"]:disabled + label {
            opacity: 0.5;
            cursor: not-allowed;
        }
        
        .horario-item {
            background: linear-gradient(135deg, #dbeafe, #bfdbfe);
            border: 2px solid #93c5fd;
            border-radius: 0.75rem;
            padding: 1.25rem;
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
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
        
        .section-title {
            color: #135bec;
            font-weight: 600;
            font-size: 1.2rem;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
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
                       href="dashboard.jsp">
                        <span class="material-symbols-outlined">dashboard</span>
                        <span class="text-sm">Dashboard</span>
                    </a>
                    <a class="flex items-center gap-3 px-3 py-2 rounded-lg text-[#616f89] hover:bg-gray-100" 
                       href="AlumnoServlet">
                        <i class="fas fa-user-graduate"></i>
                        <span class="text-sm">Estudiantes</span>
                    </a>
                    <a class="flex items-center gap-3 px-3 py-2 rounded-lg text-[#616f89] hover:bg-gray-100" 
                       href="ProfesorServlet">
                        <i class="fas fa-chalkboard-teacher"></i>
                        <span class="text-sm">Profesores</span>
                    </a>
                    <a class="flex items-center gap-3 px-3 py-2 rounded-lg bg-primary/10 text-primary font-medium" 
                       href="CursoServlet">
                        <i class="fas fa-book"></i>
                        <span class="text-sm">Cursos</span>
                    </a>
                    <a class="flex items-center gap-3 px-3 py-2 rounded-lg text-[#616f89] hover:bg-gray-100" 
                       href="GradoServlet">
                        <i class="fas fa-layer-group"></i>
                        <span class="text-sm">Grados</span>
                    </a>
                </nav>
            </div>
            
            <!-- Footer Sidebar -->
            <div class="p-6 border-t border-[#dbdfe6]">
                <a href="LogoutServlet" 
                   class="flex w-full items-center justify-center gap-2 rounded-lg h-10 px-4 bg-primary text-white text-sm font-bold hover:bg-blue-700">
                    <span class="material-symbols-outlined text-[18px]">logout</span>
                    <span>Cerrar Sesión</span>
                </a>
            </div>
        </aside>
        
        <!-- Main Content -->
        <main class="flex-1 flex flex-col overflow-y-auto">
            <!-- TopNavBar -->
            <header class="flex items-center justify-between bg-white border-b border-[#f0f2f4] px-8 py-3 sticky top-0 z-10">
                <div class="flex items-center gap-4 flex-1">
                    <h1 class="text-xl font-bold text-[#111318]">Registro de Curso</h1>
                </div>
                
                <div class="flex items-center gap-4">
                    <button class="p-2 text-[#616f89] hover:bg-gray-100 rounded-lg">
                        <span class="material-symbols-outlined">notifications</span>
                    </button>
                    <div class="flex items-center gap-3">
                        <p class="text-sm font-medium"><%= session.getAttribute("usuario") %></p>
                        <div class="size-10 rounded-full bg-primary flex items-center justify-center text-white">
                            <%= session.getAttribute("usuario").toString().substring(0,1).toUpperCase() %>
                        </div>
                    </div>
                </div>
            </header>
            
            <!-- Main Content -->
            <div class="p-8">
                <!-- Alertas -->
                <% if (error != null) { %>
                <div class="alert-modern alert-danger">
                    <i class="fas fa-exclamation-circle text-xl"></i>
                    <div><strong>Error:</strong> <%= error %></div>
                </div>
                <% } %>
                
                <% if (mensaje != null) { %>
                <div class="alert-modern alert-success">
                    <i class="fas fa-check-circle text-xl"></i>
                    <div><strong>Éxito:</strong> <%= mensaje %></div>
                </div>
                <% } %>
                
                <!-- Formulario -->
                <div class="bg-white rounded-xl border border-[#dbdfe6] shadow-sm p-6">
                    <form id="formRegistroCurso" action="RegistroCursoServlet" method="post">
                        <input type="hidden" name="accion" value="registrar">
                        
                        <!-- PASO 1: NIVEL Y GRADO -->
                        <div class="section-title">
                            <i class="fas fa-layer-group"></i>
                            Paso 1: Seleccionar Nivel y Grado
                        </div>
                        
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
                            <div>
                                <label class="block text-sm font-medium mb-2">Nivel Educativo <span class="text-red-600">*</span></label>
                                <select id="selectNivel" name="nivel" class="w-full p-3 border border-gray-300 rounded-lg" required>
                                    <option value="">-- Seleccione --</option>
                                    <option value="INICIAL">Inicial</option>
                                    <option value="PRIMARIA">Primaria</option> 
                                    <option value="SECUNDARIA">Secundaria</option>
                                </select>
                            </div>

                            <div>
                                <label class="block text-sm font-medium mb-2">Grado <span class="text-red-600">*</span></label>
                                <select name="grado" id="selectGrado" class="w-full p-3 border border-gray-300 rounded-lg" required disabled>
                                    <option value="">Seleccione primero un nivel</option>
                                </select>
                            </div>
                        </div>

                        <!-- PASO 2: TURNO -->
                        <div class="section-title">
                            <i class="fas fa-clock"></i>
                            Paso 2: Seleccionar Turno
                        </div>

                        <div class="mb-6">
                            <label class="block text-sm font-medium mb-2">Turno <span class="text-red-600">*</span></label>
                            <select name="turno" id="selectTurno" class="w-full p-3 border border-gray-300 rounded-lg" required disabled>
                                <option value="">Seleccione primero un grado</option>
                                <% for (Map<String, Object> turno : turnos) { %>
                                    <option value="<%= turno.get("id") %>" 
                                            data-inicio="<%= turno.get("hora_inicio") %>"
                                            data-fin="<%= turno.get("hora_fin") %>">
                                        <%= turno.get("nombre") %> (<%= turno.get("hora_inicio") %> - <%= turno.get("hora_fin") %>)
                                    </option>
                                <% } %>
                            </select>
                        </div>

                        <!-- PASO 3: ÁREA Y CURSO -->
                        <div class="section-title">
                            <i class="fas fa-book"></i>
                            Paso 3: Seleccionar Área y Curso
                        </div>

                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
                            <div>
                                <label class="block text-sm font-medium mb-2">Área Académica <span class="text-red-600">*</span></label>
                                <select id="selectArea" name="area" class="w-full p-3 border border-gray-300 rounded-lg" required disabled>
                                    <option value="">Seleccione primero un turno</option>
                                </select>
                            </div>

                            <div>
                                <label class="block text-sm font-medium mb-2">Nombre del Curso <span class="text-red-600">*</span></label>
                                <select name="curso" id="selectCurso" class="w-full p-3 border border-gray-300 rounded-lg" required disabled>
                                    <option value="">Seleccione primero un área</option>
                                </select>
                            </div>
                        </div>

                        <!-- PASO 4: PROFESOR Y DETALLES -->
                        <div class="section-title">
                            <i class="fas fa-chalkboard-teacher"></i>
                            Paso 4: Profesor y Detalles
                        </div>

                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
                            <div>
                                <label class="block text-sm font-medium mb-2">Profesor <span class="text-red-600">*</span></label>
                                <select name="profesor" id="selectProfesor" class="w-full p-3 border border-gray-300 rounded-lg" required disabled>
                                    <option value="">Seleccione primero un curso</option>
                                </select>
                                <div id="infoDisponibilidad"></div>
                            </div>

                            <div>
                                <label class="block text-sm font-medium mb-2">Créditos <span class="text-red-600">*</span></label>
                                <input type="number" name="creditos" id="inputCreditos" 
                                       class="w-full p-3 border border-gray-300 rounded-lg" 
                                       min="1" max="10" value="1" required>
                            </div>

                            <div class="col-span-2">
                                <label class="block text-sm font-medium mb-2">Descripción del Curso</label>
                                <textarea name="descripcion" id="inputDescripcion" 
                                          class="w-full p-3 border border-gray-300 rounded-lg" 
                                          rows="3" placeholder="Breve descripción..."></textarea>
                            </div>
                        </div>

                        <!-- PASO 5: DÍAS Y HORARIOS -->
                        <div class="section-title">
                            <i class="fas fa-calendar-alt"></i>
                            Paso 5: Seleccionar Días y Horarios
                        </div>

                        <div class="mb-4">
                            <label class="block text-sm font-medium mb-3">Días disponibles del profesor</label>
                            <div class="grid grid-cols-2 md:grid-cols-5 gap-3" id="diasSemana">
                                <div class="dia-checkbox">
                                    <input type="checkbox" id="diaLunes" value="LUNES" disabled>
                                    <label for="diaLunes">
                                        <i class="fas fa-calendar-day"></i><br>
                                        <strong>Lunes</strong>
                                    </label>
                                </div>
                                <div class="dia-checkbox">
                                    <input type="checkbox" id="diaMartes" value="MARTES" disabled>
                                    <label for="diaMartes">
                                        <i class="fas fa-calendar-day"></i><br>
                                        <strong>Martes</strong>
                                    </label>
                                </div>
                                <div class="dia-checkbox">
                                    <input type="checkbox" id="diaMiercoles" value="MIERCOLES" disabled>
                                    <label for="diaMiercoles">
                                        <i class="fas fa-calendar-day"></i><br>
                                        <strong>Miércoles</strong>
                                    </label>
                                </div>
                                <div class="dia-checkbox">
                                    <input type="checkbox" id="diaJueves" value="JUEVES" disabled>
                                    <label for="diaJueves">
                                        <i class="fas fa-calendar-day"></i><br>
                                        <strong>Jueves</strong>
                                    </label>
                                </div>
                                <div class="dia-checkbox">
                                    <input type="checkbox" id="diaViernes" value="VIERNES" disabled>
                                    <label for="diaViernes">
                                        <i class="fas fa-calendar-day"></i><br>
                                        <strong>Viernes</strong>
                                    </label>
                                </div>
                            </div>
                        </div>

                        <!-- Horarios agregados -->
                        <div id="horariosContainer" class="mb-4">
                            <p class="text-gray-500 text-sm">
                                <i class="fas fa-info-circle"></i> No hay horarios agregados aún
                            </p>
                        </div>

                        <!-- Botón agregar horario -->
                        <button type="button" id="btnAgregarHorario" 
                                class="px-6 py-3 bg-primary text-white rounded-lg font-semibold hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed" 
                                disabled>
                            <i class="fas fa-plus"></i> Agregar Horario
                        </button>

                        <!-- BOTONES DE ACCIÓN -->
                        <div class="flex justify-end gap-3 mt-8 pt-6 border-t border-gray-200">
                            <a href="CursoServlet" class="px-6 py-3 bg-gray-500 text-white rounded-lg font-semibold hover:bg-gray-600">
                                <i class="fas fa-times"></i> Cancelar
                            </a>
                            <button type="submit" id="btnSubmit" 
                                    class="px-6 py-3 bg-success text-white rounded-lg font-semibold hover:bg-green-700 disabled:opacity-50 disabled:cursor-not-allowed" 
                                    disabled>
                                <i class="fas fa-save"></i> Registrar Curso
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </main>
    </div>

    <!-- SweetAlert2 -->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    
    <script>
        const CONTEXTPATH = '<%= request.getContextPath() %>';
        
        // ========== VARIABLES GLOBALES ==========
        let horariosAgregados = [];
        let horarioIdCounter = 1;
        let nivelSeleccionado = '';
        let turnoSeleccionado = null;
        let disponibilidadProfesor = [];
        let profesorActual = null;
        
        // ========== LISTA DE AULAS ==========
        const aulasDisponibles = [
            <% for (int i = 0; i < aulas.size(); i++) {
                Map<String, Object> aula = aulas.get(i);
            %>
            {id: <%= aula.get("id") %>, nombre: "<%= aula.get("nombre") %>", capacidad: <%= aula.get("capacidad") %>}<%= i < aulas.size() - 1 ? "," : "" %>
            <% } %>
        ];
        
        // ========== INICIALIZAR ==========
        document.addEventListener('DOMContentLoaded', function() {
            console.log('✅ Sistema inicializado');
            
            document.getElementById('selectNivel').addEventListener('change', cambioNivel);
            document.getElementById('selectGrado').addEventListener('change', cambioGrado);
            document.getElementById('selectTurno').addEventListener('change', cambioTurno);
            document.getElementById('selectArea').addEventListener('change', cambioArea);
            document.getElementById('selectCurso').addEventListener('change', cambioCurso);
            document.getElementById('selectProfesor').addEventListener('change', cambioProfesor);
            document.getElementById('btnAgregarHorario').addEventListener('click', mostrarModalHorario);
            
            document.querySelectorAll('#diasSemana input[type="checkbox"]').forEach(checkbox => {
                checkbox.addEventListener('change', verificarHabilitarAgregar);
            });
            
            document.getElementById('formRegistroCurso').addEventListener('submit', enviarFormulario);
        });

        // ========== 1. CAMBIO DE NIVEL ==========
        function cambioNivel() {
            const selectNivel = document.getElementById('selectNivel');
            const selectGrado = document.getElementById('selectGrado');
            
            nivelSeleccionado = selectNivel.value;
            console.log('📚 Nivel:', nivelSeleccionado);
            
            if (nivelSeleccionado) {
                selectGrado.disabled = false;
                selectGrado.innerHTML = '<option value="">Cargando...</option>';
                
                fetch(CONTEXTPATH + '/RegistroCursoServlet?accion=obtenerGrados&nivel=' + encodeURIComponent(nivelSeleccionado))
                    .then(response => response.json())
                    .then(data => {
                        selectGrado.innerHTML = '<option value="">-- Seleccione --</option>';
                        data.forEach(grado => {
                            const option = document.createElement('option');
                            option.value = grado.id;
                            option.textContent = grado.nombre;
                            selectGrado.appendChild(option);
                        });
                    })
                    .catch(error => {
                        console.error('Error:', error);
                        mostrarMensaje('Error al cargar grados', 'error');
                    });
            } else {
                selectGrado.disabled = true;
            }
        }

        function cambioGrado() {
            const selectTurno = document.getElementById('selectTurno');
            if (document.getElementById('selectGrado').value) {
                selectTurno.disabled = false;
            }
        }

        function cambioTurno() {
            const selectArea = document.getElementById('selectArea');
            turnoSeleccionado = document.getElementById('selectTurno').value;
            
            if (turnoSeleccionado && nivelSeleccionado) {
                selectArea.disabled = false;
                selectArea.innerHTML = '<option value="">Cargando...</option>';
                
                fetch(CONTEXTPATH + '/RegistroCursoServlet?accion=obtenerAreas&nivel=' + encodeURIComponent(nivelSeleccionado))
                    .then(response => response.json())
                    .then(data => {
                        selectArea.innerHTML = '<option value="">-- Seleccione --</option>';
                        data.forEach(area => {
                            const option = document.createElement('option');
                            option.value = area.nombre;
                            option.textContent = area.nombre;
                            selectArea.appendChild(option);
                        });
                    });
            }
        }

        function cambioArea() {
            const selectArea = document.getElementById('selectArea');
            const selectCurso = document.getElementById('selectCurso');
            const selectGrado = document.getElementById('selectGrado');
            
            const area = selectArea.value;
            const gradoId = selectGrado.value;
            
            if (area && gradoId) {
                selectCurso.disabled = false;
                selectCurso.innerHTML = '<option value="">Cargando...</option>';
                
                const url = CONTEXTPATH + '/RegistroCursoServlet?accion=obtenerCursos' +
                            '&area=' + encodeURIComponent(area) +
                            '&grado=' + encodeURIComponent(gradoId) +
                            '&nivel=' + encodeURIComponent(nivelSeleccionado);
                
                fetch(url)
                    .then(response => response.json())
                    .then(data => {
                        selectCurso.innerHTML = '<option value="">-- Seleccione --</option>';
                        data.forEach(curso => {
                            const option = document.createElement('option');
                            option.value = curso.nombre;
                            option.textContent = curso.nombre;
                            selectCurso.appendChild(option);
                        });
                    });
            }
        }

        function cambioCurso() {
            const selectProfesor = document.getElementById('selectProfesor');
            const curso = document.getElementById('selectCurso').value;
            
            if (curso && turnoSeleccionado && nivelSeleccionado) {
                selectProfesor.disabled = false;
                selectProfesor.innerHTML = '<option value="">Cargando...</option>';
                
                const url = CONTEXTPATH + '/RegistroCursoServlet?accion=obtenerProfesores' +
                            '&curso=' + encodeURIComponent(curso) +
                            '&turno=' + encodeURIComponent(turnoSeleccionado) +
                            '&nivel=' + encodeURIComponent(nivelSeleccionado);
                
                fetch(url)
                    .then(response => response.json())
                    .then(data => {
                        selectProfesor.innerHTML = '<option value="">-- Seleccione --</option>';
                        data.forEach(profesor => {
                            const option = document.createElement('option');
                            option.value = profesor.id;
                            option.textContent = profesor.nombre_completo + ' - ' + profesor.especialidad;
                            selectProfesor.appendChild(option);
                        });
                    });
            }
        }

        async function cambioProfesor() {
            const profesorId = document.getElementById('selectProfesor').value;
            
            if (!profesorId || !turnoSeleccionado) {
                limpiarDisponibilidad();
                return;
            }
            
            profesorActual = profesorId;
            
            try {
                const url = CONTEXTPATH + '/RegistroCursoServlet?accion=obtenerDisponibilidadProfesor&profesorId=' + profesorId;
                const response = await fetch(url);
                const data = await response.json();
                
                disponibilidadProfesor = data.filter(d => d.turno_id == turnoSeleccionado);
                
                if (disponibilidadProfesor.length === 0) {
                    mostrarMensaje('Profesor sin disponibilidad en este turno', 'warning');
                    limpiarDisponibilidad();
                } else {
                    mostrarResumenDisponibilidad();
                    actualizarDiasDisponibles();
                }
            } catch (error) {
                console.error('Error:', error);
                limpiarDisponibilidad();
            }
        }

        function actualizarDiasDisponibles() {
            const checkboxes = document.querySelectorAll('#diasSemana input[type="checkbox"]');
            const diasDisponibles = [...new Set(disponibilidadProfesor.map(d => d.dia.toUpperCase()))];
            
            checkboxes.forEach(checkbox => {
                const dia = checkbox.value;
                if (diasDisponibles.includes(dia)) {
                    checkbox.disabled = false;
                    checkbox.checked = false;
                } else {
                    checkbox.disabled = true;
                    checkbox.checked = false;
                }
            });
        }

        function limpiarDisponibilidad() {
            disponibilidadProfesor = [];
            document.getElementById('infoDisponibilidad').innerHTML = '';
            
            document.querySelectorAll('#diasSemana input[type="checkbox"]').forEach(checkbox => {
                checkbox.disabled = true;
                checkbox.checked = false;
            });
            
            verificarHabilitarAgregar();
        }

        function mostrarResumenDisponibilidad() {
            const porDia = {};
            disponibilidadProfesor.forEach(d => {
                if (!porDia[d.dia]) porDia[d.dia] = [];
                porDia[d.dia].push({
                    inicio: d.hora_inicio.substring(0, 5),
                    fin: d.hora_fin.substring(0, 5)
                });
            });
            
            let html = '<div class="bg-blue-50 border border-blue-200 rounded-lg p-3 mt-3">';
            html += '<h6 class="font-semibold text-sm mb-2"><i class="fas fa-calendar-check"></i> Disponibilidad:</h6>';
            html += '<ul class="text-sm space-y-1">';
            
            for (const [dia, horarios] of Object.entries(porDia)) {
                html += '<li><strong>' + dia + ':</strong> ';
                html += horarios.map(h => h.inicio + ' - ' + h.fin).join(', ');
                html += '</li>';
            }
            
            html += '</ul></div>';
            document.getElementById('infoDisponibilidad').innerHTML = html;
        }

        function verificarHabilitarAgregar() {
            const anyDiaChecked = Array.from(document.querySelectorAll('#diasSemana input[type="checkbox"]'))
                .some(cb => cb.checked && !cb.disabled);
            const profesor = document.getElementById('selectProfesor').value;
            
            document.getElementById('btnAgregarHorario').disabled = !(anyDiaChecked && profesor && disponibilidadProfesor.length > 0);
            validarFormulario();
        }

        function mostrarModalHorario() {
            const diasMarcados = Array.from(document.querySelectorAll('#diasSemana input[type="checkbox"]:checked'))
                .map(cb => cb.value);
            
            if (diasMarcados.length === 0) {
                mostrarMensaje('Seleccione al menos un día', 'warning');
                return;
            }
            
            let optionsDias = '';
            diasMarcados.forEach(dia => {
                optionsDias += '<option value="' + dia + '">' + dia + '</option>';
            });
            
            let optionsAulas = '<option value="">-- Seleccione --</option>';
            aulasDisponibles.forEach(aula => {
                optionsAulas += '<option value="' + aula.id + '">' + aula.nombre + ' (Cap: ' + aula.capacidad + ')</option>';
            });
            
            Swal.fire({
                title: '<strong>Agregar Horario de Clase</strong>',
                html: '<div class="text-left space-y-4">' +
                      '<div><label class="block font-medium mb-1">Día:</label>' +
                      '<select id="modalDia" class="w-full p-2 border rounded">' + optionsDias + '</select></div>' +
                      '<div><label class="block font-medium mb-1">Aula:</label>' +
                      '<select id="modalAula" class="w-full p-2 border rounded">' + optionsAulas + '</select></div>' +
                      '<div><label class="block font-medium mb-1">Hora Inicio:</label>' +
                      '<input type="time" id="modalHoraInicio" class="w-full p-2 border rounded">' +
                      '<small class="text-gray-500" id="rangoDisponible"></small></div>' +
                      '<div><label class="block font-medium mb-1">Hora Fin:</label>' +
                      '<input type="time" id="modalHoraFin" class="w-full p-2 border rounded"></div>' +
                      '</div>',
                showCancelButton: true,
                confirmButtonText: 'Agregar',
                cancelButtonText: 'Cancelar',
                width: '600px',
                didOpen: () => {
                    document.getElementById('modalDia').addEventListener('change', function() {
                        const disponible = disponibilidadProfesor.find(d => d.dia.toUpperCase() === this.value);
                        if (disponible) {
                            const inicio = disponible.hora_inicio.substring(0, 5);
                            const fin = disponible.hora_fin.substring(0, 5);
                            document.getElementById('rangoDisponible').innerHTML = 
                                '<i class="fas fa-info-circle"></i> Rango: ' + inicio + ' - ' + fin;
                        }
                    });
                    
                    // Trigger inicial
                    document.getElementById('modalDia').dispatchEvent(new Event('change'));
                },
                preConfirm: () => {
                    const dia = document.getElementById('modalDia').value;
                    const aula = document.getElementById('modalAula').value;
                    const horaInicio = document.getElementById('modalHoraInicio').value;
                    const horaFin = document.getElementById('modalHoraFin').value;
                    
                    if (!dia || !aula || !horaInicio || !horaFin) {
                        Swal.showValidationMessage('Complete todos los campos');
                        return false;
                    }
                    
                    if (horaInicio >= horaFin) {
                        Swal.showValidationMessage('Hora fin debe ser mayor');
                        return false;
                    }
                    
                    const disponible = disponibilidadProfesor.find(d => d.dia.toUpperCase() === dia);
                    if (disponible) {
                        const inicioDisp = disponible.hora_inicio.substring(0, 5);
                        const finDisp = disponible.hora_fin.substring(0, 5);
                        
                        if (horaInicio < inicioDisp || horaFin > finDisp) {
                            Swal.showValidationMessage('Fuera de rango: ' + inicioDisp + ' - ' + finDisp);
                            return false;
                        }
                    }
                    
                    return { dia, aula, horaInicio, horaFin };
                }
            }).then((result) => {
                if (result.isConfirmed) {
                    agregarHorarioALista(result.value);
                }
            });
        }

        function agregarHorarioALista(datos) {
            const nuevoHorario = {
                id: horarioIdCounter++,
                dia: datos.dia,
                hora_inicio: datos.horaInicio,
                hora_fin: datos.horaFin,
                aula_id: parseInt(datos.aula)
            };
            
            horariosAgregados.push(nuevoHorario);
            renderHorarios();
            validarFormulario();
            mostrarMensaje('Horario agregado: ' + datos.dia + ' ' + datos.horaInicio + '-' + datos.horaFin, 'success');
        }

        function renderHorarios() {
            const container = document.getElementById('horariosContainer');
            container.innerHTML = '';
            
            if (horariosAgregados.length === 0) {
                container.innerHTML = '<p class="text-gray-500 text-sm"><i class="fas fa-info-circle"></i> No hay horarios agregados</p>';
                return;
            }
            
            horariosAgregados.forEach(h => {
                const aula = aulasDisponibles.find(a => a.id == h.aula_id);
                const div = document.createElement('div');
                div.className = 'horario-item';
                div.innerHTML = '<div>' +
                    '<i class="fas fa-calendar-day"></i> <strong>' + h.dia + '</strong> - ' +
                    '<i class="fas fa-clock"></i> ' + h.hora_inicio + ' a ' + h.hora_fin + ' - ' +
                    '<i class="fas fa-door-open"></i> ' + (aula ? aula.nombre : 'Aula ' + h.aula_id) +
                    '</div>' +
                    '<button type="button" class="px-3 py-1 bg-red-500 text-white rounded hover:bg-red-600" onclick="eliminarHorario(' + h.id + ')">' +
                    '<i class="fas fa-trash"></i></button>';
                container.appendChild(div);
            });
        }

        function eliminarHorario(id) {
            horariosAgregados = horariosAgregados.filter(h => h.id !== id);
            renderHorarios();
            validarFormulario();
        }

        function validarFormulario() {
            const nivel = document.getElementById('selectNivel').value;
            const grado = document.getElementById('selectGrado').value;
            const turno = document.getElementById('selectTurno').value;
            const area = document.getElementById('selectArea').value;
            const curso = document.getElementById('selectCurso').value;
            const profesor = document.getElementById('selectProfesor').value;
            const creditos = document.getElementById('inputCreditos').value;
            
            document.getElementById('btnSubmit').disabled = !(nivel && grado && turno && area && curso && profesor && creditos && horariosAgregados.length > 0);
        }

        function enviarFormulario(e) {
            if (horariosAgregados.length === 0) {
                e.preventDefault();
                mostrarMensaje('Agregue al menos un horario', 'error');
                return;
            }
            
            const form = e.target;
            
            // Limpiar inputs anteriores
            form.querySelectorAll('input[name="dias[]"]').forEach(input => input.remove());
            form.querySelectorAll('input[name="horasInicio[]"]').forEach(input => input.remove());
            form.querySelectorAll('input[name="horasFin[]"]').forEach(input => input.remove());
            form.querySelectorAll('input[name="aulas[]"]').forEach(input => input.remove());
            
            // Agregar horarios
            horariosAgregados.forEach(h => {
                const inputDia = document.createElement('input');
                inputDia.type = 'hidden';
                inputDia.name = 'dias[]';
                inputDia.value = h.dia;
                form.appendChild(inputDia);
                
                const inputHoraInicio = document.createElement('input');
                inputHoraInicio.type = 'hidden';
                inputHoraInicio.name = 'horasInicio[]';
                inputHoraInicio.value = h.hora_inicio;
                form.appendChild(inputHoraInicio);
                
                const inputHoraFin = document.createElement('input');
                inputHoraFin.type = 'hidden';
                inputHoraFin.name = 'horasFin[]';
                inputHoraFin.value = h.hora_fin;
                form.appendChild(inputHoraFin);
                
                const inputAula = document.createElement('input');
                inputAula.type = 'hidden';
                inputAula.name = 'aulas[]';
                inputAula.value = h.aula_id;
                form.appendChild(inputAula);
            });
            
            console.log('✅ Enviando', horariosAgregados.length, 'horarios');
        }

        function mostrarMensaje(texto, tipo) {
            const iconos = {
                success: 'success',
                error: 'error',
                warning: 'warning',
                info: 'info'
            };
            
            Swal.fire({
                icon: iconos[tipo] || 'info',
                title: texto,
                toast: true,
                position: 'top-end',
                showConfirmButton: false,
                timer: 3000,
                timerProgressBar: true
            });
        }
    </script>
</body>
</html>
