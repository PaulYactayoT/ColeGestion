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
    
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Lexend:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
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
        
        /* =========================================
           DISEÑO MODELO 1: GLASS & GRADIENT (MODIFICADO)
           ========================================= */
        .dia-card-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(110px, 1fr));
            gap: 1rem;
        }

        /* Ocultamos el checkbox real */
        .dia-card-input {
            display: none; 
        }

        /* Estilo de la tarjeta (Label) - GLASS STYLE */
        .dia-card-label {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            /* Fondo degradado suave "Glass" */
            background: linear-gradient(145deg, #ffffff, #f0f4f8);
            border: 1px solid rgba(255, 255, 255, 0.8);
            border-radius: 16px; /* Bordes más redondeados */
            padding: 1.5rem 1rem;
            cursor: pointer;
            transition: all 0.3s ease;
            /* Sombra suave 3D */
            box-shadow: 5px 5px 15px rgba(0,0,0,0.05), -5px -5px 15px rgba(255,255,255,0.8);
            color: #64748b;
            text-align: center;
            height: 100%;
            position: relative;
            overflow: hidden;
        }

        /* Detalle decorativo lateral */
        .dia-card-label::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 4px;
            height: 100%;
            background: transparent;
            transition: background 0.3s;
        }

        .dia-card-label i {
            font-size: 1.8rem;
            margin-bottom: 0.8rem;
            color: #94a3b8;
            transition: all 0.3s;
            filter: drop-shadow(0 2px 4px rgba(0,0,0,0.1));
        }

        .dia-card-label span {
            font-weight: 700; /* Texto un poco más grueso */
            font-size: 0.95rem;
            letter-spacing: 0.5px;
        }

        /* Hover Effect - Elevación */
        .dia-card-label:hover {
            transform: translateY(-5px);
            box-shadow: 8px 8px 20px rgba(0,0,0,0.1), -8px -8px 20px rgba(255,255,255,0.9);
        }

        /* ESTADO ACTIVO (CHECKED) - GRADIENT AZUL */
        .dia-card-input:checked + .dia-card-label {
            background: linear-gradient(135deg, #135bec, #60a5fa);
            border: 1px solid transparent;
            color: #ffffff;
            box-shadow: 0 10px 25px rgba(19, 91, 236, 0.4); /* Resplandor azul */
        }

        .dia-card-input:checked + .dia-card-label::before {
            background: rgba(255,255,255,0.3); /* Pequeño brillo lateral */
        }

        .dia-card-input:checked + .dia-card-label i {
            color: #ffffff;
            transform: scale(1.1); /* Icono crece un poco */
            filter: drop-shadow(0 2px 4px rgba(0,0,0,0.2));
        }

        /* ESTADO DESHABILITADO */
        .dia-card-input:disabled + .dia-card-label {
            opacity: 0.6;
            background: #f1f5f9;
            box-shadow: inset 2px 2px 5px rgba(0,0,0,0.05); /* Hundido */
            cursor: not-allowed;
            transform: none;
            border-color: #e2e8f0;
        }
        
        /* Estilos items horario (Lista agregada) */
        .horario-item {
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 0.75rem;
            padding: 1rem;
            margin-bottom: 0.75rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
            transition: all 0.2s;
        }
        
        .horario-item:hover {
            border-color: #cbd5e1;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        }
        
        /* Alertas */
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
        
        /* Títulos y Pasos */
        .section-title {
            color: #135bec;
            font-weight: 600;
            font-size: 1.2rem;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        /* Animación de pasos */
        .step-content {
            animation: fadeIn 0.4s ease-in-out;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .hidden-step {
            display: none;
        }
    </style>
</head>
<body class="bg-[#f6f6f8] text-[#111318] min-h-screen">
    
    <div class="flex h-screen overflow-hidden">
        <aside class="w-64 flex-shrink-0 bg-white border-r border-[#dbdfe6] flex flex-col justify-between">
            <div class="flex flex-col gap-8 p-6">
                <div class="flex items-center gap-3">
                    <div class="bg-primary size-10 rounded-lg flex items-center justify-center text-white">
                        <span class="material-symbols-outlined">school</span>
                    </div>
                    <div class="flex flex-col">
                        <h1 class="text-[#111318] text-lg font-bold">San Antonio</h1>
                        <p class="text-[#616f89] text-xs">Gestión Académica</p>
                    </div>
                </div>
                
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
            
            <div class="p-6 border-t border-[#dbdfe6]">
                <a href="LogoutServlet" 
                   class="flex w-full items-center justify-center gap-2 rounded-lg h-10 px-4 bg-primary text-white text-sm font-bold hover:bg-blue-700">
                    <span class="material-symbols-outlined text-[18px]">logout</span>
                    <span>Cerrar Sesión</span>
                </a>
            </div>
        </aside>
        
        <main class="flex-1 flex flex-col overflow-y-auto">
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
            
            <div class="p-8">
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
                
                <div class="mb-6 bg-gray-200 rounded-full h-2.5 dark:bg-gray-700">
                    <div class="bg-primary h-2.5 rounded-full transition-all duration-500" style="width: 20%" id="progressBar"></div>
                </div>

                <div class="bg-white rounded-xl border border-[#dbdfe6] shadow-sm p-6">
                    <form id="formRegistroCurso" action="RegistroCursoServlet" method="post">
                        <input type="hidden" name="accion" value="registrar">
                        
                        <div id="step1" class="step-content">
                            <div class="section-title">
                                <i class="fas fa-layer-group"></i> Paso 1: Seleccionar Nivel y Grado
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

                            <div class="flex justify-between pt-6 border-t border-gray-200">
                                <a href="CursoServlet" class="px-6 py-3 bg-gray-500 text-white rounded-lg font-semibold hover:bg-gray-600">
                                    <i class="fas fa-arrow-left"></i> Volver al Panel de Cursos
                                </a>
                                <button type="button" onclick="irPaso(2)" class="px-6 py-3 bg-primary text-white rounded-lg font-semibold hover:bg-blue-700">
                                    Siguiente <i class="fas fa-arrow-right"></i>
                                </button>
                            </div>
                        </div>

                        <div id="step2" class="step-content hidden-step">
                            <div class="section-title">
                                <i class="fas fa-clock"></i> Paso 2: Seleccionar Turno
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

                            <div class="flex justify-between pt-6 border-t border-gray-200">
                                <button type="button" onclick="irPaso(1)" class="px-6 py-3 bg-gray-500 text-white rounded-lg font-semibold hover:bg-gray-600">
                                    <i class="fas fa-arrow-left"></i> Volver Atrás
                                </button>
                                <button type="button" onclick="irPaso(3)" class="px-6 py-3 bg-primary text-white rounded-lg font-semibold hover:bg-blue-700">
                                    Siguiente <i class="fas fa-arrow-right"></i>
                                </button>
                            </div>
                        </div>

                        <div id="step3" class="step-content hidden-step">
                            <div class="section-title">
                                <i class="fas fa-book"></i> Paso 3: Seleccionar Área y Curso
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

                            <div class="flex justify-between pt-6 border-t border-gray-200">
                                <button type="button" onclick="irPaso(2)" class="px-6 py-3 bg-gray-500 text-white rounded-lg font-semibold hover:bg-gray-600">
                                    <i class="fas fa-arrow-left"></i> Volver Atrás
                                </button>
                                <button type="button" onclick="irPaso(4)" class="px-6 py-3 bg-primary text-white rounded-lg font-semibold hover:bg-blue-700">
                                    Siguiente <i class="fas fa-arrow-right"></i>
                                </button>
                            </div>
                        </div>

                        <div id="step4" class="step-content hidden-step">
                            <div class="section-title">
                                <i class="fas fa-chalkboard-teacher"></i> Paso 4: Profesor y Detalles
                            </div>

                            <div class="grid grid-cols-1 gap-4 mb-6"> <div>
                                    <label class="block text-sm font-medium mb-2">Profesor <span class="text-red-600">*</span></label>
                                    <select name="profesor" id="selectProfesor" class="w-full p-3 border border-gray-300 rounded-lg" required disabled>
                                        <option value="">Seleccione primero un curso</option>
                                    </select>
                                    <div id="infoDisponibilidad"></div>
                                </div>
                                
                                <div>
                                    <label class="block text-sm font-medium mb-2">Descripción del Curso</label>
                                    <textarea name="descripcion" id="inputDescripcion" 
                                              class="w-full p-3 border border-gray-300 rounded-lg" 
                                              rows="3" placeholder="Breve descripción..."></textarea>
                                </div>
                            </div>

                            <div class="flex justify-between pt-6 border-t border-gray-200">
                                <button type="button" onclick="irPaso(3)" class="px-6 py-3 bg-gray-500 text-white rounded-lg font-semibold hover:bg-gray-600">
                                    <i class="fas fa-arrow-left"></i> Volver Atrás
                                </button>
                                <button type="button" onclick="irPaso(5)" class="px-6 py-3 bg-primary text-white rounded-lg font-semibold hover:bg-blue-700">
                                    Siguiente <i class="fas fa-arrow-right"></i>
                                </button>
                            </div>
                        </div>

                        <div id="step5" class="step-content hidden-step">
                            <div class="section-title">
                                <i class="fas fa-calendar-alt"></i> Paso 5: Seleccionar Días y Horarios
                            </div>

                            <div class="mb-6">
                                <label class="block text-sm font-medium mb-3">Días disponibles del profesor</label>
                                
                                <div class="dia-card-container" id="diasSemana">
                                    <div>
                                        <input type="checkbox" id="diaLunes" value="LUNES" class="dia-card-input" disabled>
                                        <label for="diaLunes" class="dia-card-label">
                                            <i class="fas fa-calendar-alt"></i>
                                            <span>Lunes</span>
                                        </label>
                                    </div>
                                    <div>
                                        <input type="checkbox" id="diaMartes" value="MARTES" class="dia-card-input" disabled>
                                        <label for="diaMartes" class="dia-card-label">
                                            <i class="fas fa-calendar-day"></i>
                                            <span>Martes</span>
                                        </label>
                                    </div>
                                    <div>
                                        <input type="checkbox" id="diaMiercoles" value="MIERCOLES" class="dia-card-input" disabled>
                                        <label for="diaMiercoles" class="dia-card-label">
                                            <i class="fas fa-calendar-week"></i>
                                            <span>Miércoles</span>
                                        </label>
                                    </div>
                                    <div>
                                        <input type="checkbox" id="diaJueves" value="JUEVES" class="dia-card-input" disabled>
                                        <label for="diaJueves" class="dia-card-label">
                                            <i class="far fa-calendar-plus"></i>
                                            <span>Jueves</span>
                                        </label>
                                    </div>
                                    <div>
                                        <input type="checkbox" id="diaViernes" value="VIERNES" class="dia-card-input" disabled>
                                        <label for="diaViernes" class="dia-card-label">
                                            <i class="far fa-calendar-check"></i>
                                            <span>Viernes</span>
                                        </label>
                                    </div>
                                </div>
                                </div>

                            <div id="horariosContainer" class="mb-4">
                                <p class="text-gray-500 text-sm"><i class="fas fa-info-circle"></i> No hay horarios agregados aún</p>
                            </div>

                            <button type="button" id="btnAgregarHorario" 
                                    class="px-6 py-3 bg-primary text-white rounded-lg font-semibold hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed" 
                                    disabled>
                                <i class="fas fa-plus"></i> Agregar Horario
                            </button>

                            <div class="flex justify-between pt-6 border-t border-gray-200 mt-8">
                                <button type="button" onclick="irPaso(4)" class="px-6 py-3 bg-gray-500 text-white rounded-lg font-semibold hover:bg-gray-600">
                                    <i class="fas fa-arrow-left"></i> Volver Atrás
                                </button>
                                <button type="submit" id="btnSubmit" 
                                        class="px-6 py-3 bg-success text-white rounded-lg font-semibold hover:bg-green-700 disabled:opacity-50 disabled:cursor-not-allowed" 
                                        disabled>
                                    <i class="fas fa-save"></i> Registrar Curso
                                </button>
                            </div>
                        </div>

                    </form>
                </div>
            </div>
        </main>
    </div>

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
        
        // ========== FUNCIONES DE WIZARD (TARJETAS) ==========
        function irPaso(paso) {
            // Validaciones antes de avanzar
            if (paso === 2) {
                const nivel = document.getElementById('selectNivel').value;
                const grado = document.getElementById('selectGrado').value;
                if (!nivel || !grado) {
                    mostrarMensaje('Debe seleccionar Nivel y Grado', 'warning');
                    return;
                }
            }
            if (paso === 3) {
                const turno = document.getElementById('selectTurno').value;
                if (!turno) {
                    mostrarMensaje('Debe seleccionar un Turno', 'warning');
                    return;
                }
            }
            if (paso === 4) {
                const area = document.getElementById('selectArea').value;
                const curso = document.getElementById('selectCurso').value;
                if (!area || !curso) {
                    mostrarMensaje('Debe seleccionar Área y Nombre del Curso', 'warning');
                    return;
                }
            }
            if (paso === 5) {
                const profesor = document.getElementById('selectProfesor').value;
                // NOTA: Se eliminó la validación de créditos aquí
                if (!profesor) {
                    mostrarMensaje('Debe seleccionar Profesor', 'warning');
                    return;
                }
            }

            // Ocultar todos los pasos
            document.querySelectorAll('.step-content').forEach(el => el.classList.add('hidden-step'));
            
            // Mostrar paso actual
            document.getElementById('step' + paso).classList.remove('hidden-step');
            
            // Actualizar barra de progreso
            const porcentaje = paso * 20;
            document.getElementById('progressBar').style.width = porcentaje + '%';
        }

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
            
            // Selector ajustado para las nuevas tarjetas (mantiene funcionalidad)
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
            // creditos eliminados de la validacion
            
            document.getElementById('btnSubmit').disabled = !(nivel && grado && turno && area && curso && profesor && horariosAgregados.length > 0);
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