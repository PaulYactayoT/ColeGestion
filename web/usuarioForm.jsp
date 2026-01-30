<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="modelo.Usuario" %>
<%@ page import="modelo.UsuarioDAO.PersonaSinUsuario" %>
<%@ page import="java.util.List" %>
<%@ page import="javax.servlet.http.HttpSession" %>

<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    Usuario u = (Usuario) request.getAttribute("usuario");
    boolean esEditar = u != null;
    
    // Obtener listas de personas sin usuario
    List<PersonaSinUsuario> profesoresSinUsuario = 
        (List<PersonaSinUsuario>) request.getAttribute("profesoresSinUsuario");
    List<PersonaSinUsuario> alumnosSinUsuario = 
        (List<PersonaSinUsuario>) request.getAttribute("alumnosSinUsuario");
    List<PersonaSinUsuario> administrativosSinUsuario = 
        (List<PersonaSinUsuario>) request.getAttribute("administrativosSinUsuario");
    
    String username = "";
    String rol = "";
    int id = 0;
    int personaId = 0;
    
    if (esEditar && u != null) {
        username = u.getUsername() != null ? u.getUsername() : "";
        rol = u.getRol() != null ? u.getRol() : "";
        id = u.getId();
        personaId = u.getPersonaId();
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title><%= esEditar ? "Editar Usuario" : "Registrar Usuario"%></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="assets/css/estilos.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/crypto-js/4.1.1/crypto-js.min.js"></script>
    <style>
        :root {
            --primary-color: #4f46e5;
            --primary-dark: #4338ca;
            --success-color: #10b981;
            --danger-color: #ef4444;
            --warning-color: #f59e0b;
        }

        .form-wrapper {
            max-width: 800px;
            margin: 2rem auto;
            padding: 0 15px;
        }

        .form-header {
            background: linear-gradient(135deg, #1f2937, #374151);
            border-radius: 15px 15px 0 0;
            padding: 1.5rem 2rem;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            border-bottom: 3px solid var(--primary-color);
        }

        .form-header h2 {
            color: #ffffff;
            font-weight: 700;
            margin: 0;
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        .form-header .icon {
            width: 50px;
            height: 50px;
            background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 1.5rem;
        }

        .form-card {
            background: white;
            border-radius: 0 0 15px 15px;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
            padding: 2.5rem;
        }

        .section-title {
            color: var(--primary-color);
            font-weight: 600;
            font-size: 1.1rem;
            margin: 1.5rem 0 1rem 0;
            padding-bottom: 0.5rem;
            border-bottom: 2px solid #e5e7eb;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .form-label {
            font-weight: 600;
            color: #374151;
            margin-bottom: 0.5rem;
        }

        .form-label.required::after {
            content: " *";
            color: var(--danger-color);
        }

        .form-control, .form-select {
            border: 2px solid #e5e7eb;
            border-radius: 8px;
            padding: 0.75rem;
            transition: all 0.3s ease;
        }

        .form-control:focus, .form-select:focus {
            border-color: var(--primary-color);
            box-shadow: 0 0 0 0.2rem rgba(79, 70, 229, 0.15);
        }

        .input-group-icon {
            position: relative;
        }

        .input-group-icon i {
            position: absolute;
            left: 15px;
            top: 50%;
            transform: translateY(-50%);
            color: #9ca3af;
            z-index: 10;
        }

        .input-group-icon .form-control,
        .input-group-icon .form-select {
            padding-left: 2.75rem;
        }

        .persona-badge {
            display: inline-block;
            padding: 0.25rem 0.75rem;
            border-radius: 6px;
            font-size: 0.75rem;
            font-weight: 600;
            margin-left: 0.5rem;
        }

        .badge-profesor { background: #dbeafe; color: #1e40af; }
        .badge-alumno { background: #dcfce7; color: #166534; }
        .badge-administrativo { background: #fef3c7; color: #92400e; }

        .persona-info {
            background: #f9fafb;
            border: 1px solid #e5e7eb;
            border-radius: 8px;
            padding: 1rem;
            margin-top: 1rem;
            display: none;
        }

        .persona-info.active {
            display: block;
        }

        .persona-detail {
            display: flex;
            justify-content: space-between;
            padding: 0.5rem 0;
            border-bottom: 1px solid #e5e7eb;
        }

        .persona-detail:last-child {
            border-bottom: none;
        }

        .persona-detail strong {
            color: #374151;
        }

        .persona-detail span {
            color: #6b7280;
        }

        .requisito-cumplido { 
            color: var(--success-color); 
            font-weight: 500; 
        }
        
        .requisito-incumplido { 
            color: var(--danger-color); 
        }
        
        .requisito-pendiente { 
            color: #6c757d; 
        }
        
        .criterio-item { 
            transition: all 0.3s ease; 
            margin-bottom: 5px;
            padding: 2px 5px;
            border-radius: 3px;
            list-style: none;
        }
        
        .requisitos-password {
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            border: 1px solid #dee2e6;
            border-radius: 8px;
        }

        .btn-modern {
            padding: 0.75rem 2rem;
            border-radius: 10px;
            font-weight: 600;
            border: none;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
        }

        .btn-primary-modern {
            background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
            color: white;
        }

        .btn-primary-modern:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 15px rgba(79, 70, 229, 0.3);
            color: white;
        }

        .btn-secondary-modern {
            background: #6b7280;
            color: white;
        }

        .btn-secondary-modern:hover {
            background: #4b5563;
            transform: translateY(-2px);
            color: white;
        }

        .alert-modern {
            border: none;
            border-radius: 10px;
            padding: 1rem 1.25rem;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        .alert-modern i {
            font-size: 1.5rem;
        }

        .help-text {
            color: #6b7280;
            font-size: 0.875rem;
            margin-top: 0.25rem;
        }

        .filter-section {
            background: #f9fafb;
            border: 2px dashed #e5e7eb;
            border-radius: 10px;
            padding: 1.5rem;
            margin-bottom: 1rem;
        }

        .tipo-badge {
            cursor: pointer;
            padding: 0.5rem 1rem;
            border-radius: 8px;
            border: 2px solid #e5e7eb;
            background: white;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            margin: 0.25rem;
        }

        .tipo-badge:hover {
            border-color: var(--primary-color);
            background: #f0f9ff;
        }

        .tipo-badge.active {
            border-color: var(--primary-color);
            background: var(--primary-color);
            color: white;
        }
    </style>
</head>
<body>
    <jsp:include page="header.jsp" />

    <div class="form-wrapper">
        <!-- Mensajes -->
        <% if (session.getAttribute("mensaje") != null) { %>
            <div class="alert alert-success alert-modern alert-dismissible fade show">
                <i class="fas fa-check-circle"></i>
                <div>
                    <%= session.getAttribute("mensaje") %>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <% session.removeAttribute("mensaje"); %>
        <% } %>
        
        <% if (session.getAttribute("error") != null) { %>
            <div class="alert alert-danger alert-modern alert-dismissible fade show">
                <i class="fas fa-exclamation-circle"></i>
                <div>
                    <%= session.getAttribute("error") %>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <% session.removeAttribute("error"); %>
        <% } %>

        <!-- Header del Formulario -->
        <div class="form-header">
            <h2>
                <div class="icon">
                    <i class="fas <%= esEditar ? "fa-user-edit" : "fa-user-plus" %>"></i>
                </div>
                <%= esEditar ? "Editar Usuario" : "Registrar Nuevo Usuario"%>
            </h2>
        </div>

        <!-- Formulario -->
        <div class="form-card">
            <form action="UsuarioServlet" method="post" id="usuarioForm">
                <input type="hidden" name="id" value="<%= id %>">
                <input type="hidden" name="persona_id" id="persona_id_hidden" value="<%= personaId %>">
                <input type="hidden" name="rol" id="rol_hidden" value="<%= rol %>">

                <% if (!esEditar) { %>
                <!-- SECCIÓN: SELECCIONAR PERSONA -->
                <div class="section-title">
                    <i class="fas fa-user-tie"></i>
                    Asociar a Persona
                </div>

                <div class="filter-section">
                    <label class="form-label">Seleccione el tipo de persona:</label>
                    <div class="d-flex flex-wrap gap-2">
                        <div class="tipo-badge" data-tipo="PROFESOR" data-rol="docente">
                            <i class="fas fa-chalkboard-teacher"></i>
                            Profesor
                            <span class="badge bg-primary ms-2"><%= profesoresSinUsuario != null ? profesoresSinUsuario.size() : 0 %></span>
                        </div>
                        <div class="tipo-badge" data-tipo="ALUMNO" data-rol="padre">
                            <i class="fas fa-user-graduate"></i>
                            Alumno (Padre)
                            <span class="badge bg-success ms-2"><%= alumnosSinUsuario != null ? alumnosSinUsuario.size() : 0 %></span>
                        </div>
                        <div class="tipo-badge" data-tipo="ADMINISTRATIVO" data-rol="administrativo">
                            <i class="fas fa-user-cog"></i>
                            Administrativo
                            <span class="badge bg-warning ms-2"><%= administrativosSinUsuario != null ? administrativosSinUsuario.size() : 0 %></span>
                        </div>
                    </div>
                </div>

                <div class="mb-3">
                    <label class="form-label required">Persona:</label>
                    <div class="input-group-icon">
                        <i class="fas fa-user"></i>
                        <select class="form-select" id="persona_id_select" required>
                            <option value="">Primero seleccione un tipo de persona</option>
                        </select>
                    </div>
                    <small class="help-text">
                        <i class="fas fa-info-circle"></i>
                        Solo se muestran personas que NO tienen usuario asignado
                    </small>
                </div>

                <!-- INFO DE PERSONA SELECCIONADA -->
                <div class="persona-info" id="personaInfo">
                    <strong><i class="fas fa-id-card"></i> Información de la Persona:</strong>
                    <div class="persona-detail">
                        <strong>Nombre Completo:</strong>
                        <span id="infoNombre">-</span>
                    </div>
                    <div class="persona-detail">
                        <strong>Correo:</strong>
                        <span id="infoCorreo">-</span>
                    </div>
                    <div class="persona-detail">
                        <strong>DNI:</strong>
                        <span id="infoDni">-</span>
                    </div>
                    <div class="persona-detail">
                        <strong>Código:</strong>
                        <span id="infoCodigo">-</span>
                    </div>
                    <div class="persona-detail">
                        <strong>Información Adicional:</strong>
                        <span id="infoAdicional">-</span>
                    </div>
                </div>
                <% } else { %>
                    <!-- EN EDICIÓN: MOSTRAR PERSONA ASOCIADA (READONLY) -->
                    <div class="alert alert-info">
                        <i class="fas fa-info-circle"></i>
                        <strong>Persona Asociada:</strong> No se puede cambiar en modo edición
                    </div>
                <% } %>

                <hr style="margin: 2rem 0; border-top: 2px solid #e5e7eb;">

                <!-- SECCIÓN: CREDENCIALES -->
                <div class="section-title">
                    <i class="fas fa-key"></i>
                    Credenciales de Acceso
                </div>

                <div class="mb-3">
                    <label class="form-label required">Nombre de Usuario:</label>
                    <div class="input-group-icon">
                        <i class="fas fa-user-circle"></i>
                        <input type="text" 
                               class="form-control" 
                               name="username" 
                               id="username"
                               value="<%= username %>" 
                               required
                               maxlength="50"
                               <%= esEditar ? "readonly" : "" %>
                               placeholder="usuario.profesor">
                    </div>
                    <% if (esEditar) { %>
                        <small class="help-text">
                            <i class="fas fa-lock"></i>
                            El nombre de usuario no se puede modificar
                        </small>
                    <% } else { %>
                        <small class="help-text">
                            <i class="fas fa-lightbulb"></i>
                            Se sugiere usar el formato: nombre.apellido o correo sin @dominio
                        </small>
                    <% } %>
                </div>

                <div class="mb-3">
                    <label class="form-label <%= esEditar ? "" : "required" %>">Contraseña:</label>
                    <div class="input-group-icon">
                        <i class="fas fa-lock"></i>
                        <input type="password" 
                               class="form-control" 
                               name="password" 
                               id="passwordInput" 
                               <%= esEditar ? "" : "required" %>
                               oninput="validarPasswordEnTiempoReal(this.value)"
                               placeholder="<%= esEditar ? "Dejar vacío para mantener contraseña actual" : "Ingrese una contraseña segura"%>">
                    </div>
                    
                    <div id="indicadorPassword" class="help-text mt-2"></div>
                    
                    <div class="requisitos-password mt-2 p-3" style="display: none;" id="requisitosPassword">
                        <strong><i class="fas fa-shield-alt"></i> Requisitos de contraseña segura:</strong>
                        <ul class="mb-0 mt-2" style="padding-left: 1.2em;">
                            <li id="reqLongitud" class="criterio-item requisito-pendiente">
                                <i class="fas fa-circle"></i> Mínimo 8 caracteres
                            </li>
                            <li id="reqMayuscula" class="criterio-item requisito-pendiente">
                                <i class="fas fa-circle"></i> Al menos una letra mayúscula
                            </li>
                            <li id="reqMinuscula" class="criterio-item requisito-pendiente">
                                <i class="fas fa-circle"></i> Al menos una letra minúscula
                            </li>
                            <li id="reqNumero" class="criterio-item requisito-pendiente">
                                <i class="fas fa-circle"></i> Al menos un número
                            </li>
                            <li id="reqEspecial" class="criterio-item requisito-pendiente">
                                <i class="fas fa-circle"></i> Al menos un carácter especial (!@#$%^&*)
                            </li>
                            <li id="reqCriterios" class="criterio-item requisito-pendiente">
                                <i class="fas fa-circle"></i> Cumplir al menos 3 de los 4 criterios anteriores
                            </li>
                        </ul>
                        <div class="mt-2 p-2 bg-white rounded">
                            <small><strong>Criterios cumplidos:</strong> <span id="criteriosCumplidos" class="badge bg-secondary">0</span>/4</small>
                        </div>
                    </div>
                    
                    <% if (esEditar) { %>
                        <small class="help-text">
                            <i class="fas fa-info-circle"></i>
                            Dejar en blanco para mantener la contraseña actual
                        </small>
                    <% } %>
                </div>

                <!-- BOTONES -->
                <div class="d-flex justify-content-between mt-4 pt-3" style="border-top: 2px solid #e5e7eb;">
                    <a href="UsuarioServlet" class="btn-modern btn-secondary-modern">
                        <i class="fas fa-times"></i>
                        Cancelar
                    </a>
                    <button type="submit" class="btn-modern btn-primary-modern" id="submitBtn">
                        <i class="fas <%= esEditar ? "fa-save" : "fa-check" %>"></i>
                        <%= esEditar ? "Actualizar Usuario" : "Registrar Usuario"%>
                    </button>
                </div>
            </form>
        </div>
    </div>

    <footer class="bg-dark text-white py-4 mt-5">
        <div class="container text-center">
            <p class="mb-0">&copy; 2025 Colegio SA - Todos los derechos reservados</p>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        // ===================================================================
        // DATOS DE PERSONAS SIN USUARIO (desde JSP)
        // ===================================================================
        const profesoresSinUsuario = [
            <% if (profesoresSinUsuario != null) {
                for (int i = 0; i < profesoresSinUsuario.size(); i++) {
                    PersonaSinUsuario p = profesoresSinUsuario.get(i);
            %>
            {
                personaId: <%= p.getPersonaId() %>,
                nombres: "<%= p.getNombres() != null ? p.getNombres().replace("\"", "\\\"") : "" %>",
                apellidos: "<%= p.getApellidos() != null ? p.getApellidos().replace("\"", "\\\"") : "" %>",
                correo: "<%= p.getCorreo() != null ? p.getCorreo().replace("\"", "\\\"") : "" %>",
                dni: "<%= p.getDni() != null ? p.getDni().replace("\"", "\\\"") : "" %>",
                codigo: "<%= p.getCodigo() != null ? p.getCodigo().replace("\"", "\\\"") : "" %>",
                infoAdicional: "<%= p.getInformacionAdicional() != null ? p.getInformacionAdicional().replace("\"", "\\\"") : "" %>"
            }<%= i < profesoresSinUsuario.size() - 1 ? "," : "" %>
            <% }
            } %>
        ];

        const alumnosSinUsuario = [
            <% if (alumnosSinUsuario != null) {
                for (int i = 0; i < alumnosSinUsuario.size(); i++) {
                    PersonaSinUsuario p = alumnosSinUsuario.get(i);
            %>
            {
                personaId: <%= p.getPersonaId() %>,
                nombres: "<%= p.getNombres() != null ? p.getNombres().replace("\"", "\\\"") : "" %>",
                apellidos: "<%= p.getApellidos() != null ? p.getApellidos().replace("\"", "\\\"") : "" %>",
                correo: "<%= p.getCorreo() != null ? p.getCorreo().replace("\"", "\\\"") : "" %>",
                dni: "<%= p.getDni() != null ? p.getDni().replace("\"", "\\\"") : "" %>",
                codigo: "<%= p.getCodigo() != null ? p.getCodigo().replace("\"", "\\\"") : "" %>",
                infoAdicional: "<%= p.getInformacionAdicional() != null ? p.getInformacionAdicional().replace("\"", "\\\"") : "" %>"
            }<%= i < alumnosSinUsuario.size() - 1 ? "," : "" %>
            <% }
            } %>
        ];

        const administrativosSinUsuario = [
            <% if (administrativosSinUsuario != null) {
                for (int i = 0; i < administrativosSinUsuario.size(); i++) {
                    PersonaSinUsuario p = administrativosSinUsuario.get(i);
            %>
            {
                personaId: <%= p.getPersonaId() %>,
                nombres: "<%= p.getNombres() != null ? p.getNombres().replace("\"", "\\\"") : "" %>",
                apellidos: "<%= p.getApellidos() != null ? p.getApellidos().replace("\"", "\\\"") : "" %>",
                correo: "<%= p.getCorreo() != null ? p.getCorreo().replace("\"", "\\\"") : "" %>",
                dni: "<%= p.getDni() != null ? p.getDni().replace("\"", "\\\"") : "" %>",
                codigo: "<%= p.getCodigo() != null ? p.getCodigo().replace("\"", "\\\"") : "" %>",
                infoAdicional: "<%= p.getInformacionAdicional() != null ? p.getInformacionAdicional().replace("\"", "\\\"") : "" %>"
            }<%= i < administrativosSinUsuario.size() - 1 ? "," : "" %>
            <% }
            } %>
        ];

        console.log('📊 Profesores sin usuario cargados:', profesoresSinUsuario);
        console.log('📊 Total profesores:', profesoresSinUsuario.length);
        console.log('📊 Alumnos sin usuario cargados:', alumnosSinUsuario);
        console.log('📊 Total alumnos:', alumnosSinUsuario.length);
        console.log('📊 Administrativos sin usuario cargados:', administrativosSinUsuario);
        console.log('📊 Total administrativos:', administrativosSinUsuario.length);

        // ===================================================================
        // MANEJO DE SELECCIÓN DE TIPO DE PERSONA
        // ===================================================================
        const esEdicion = <%= esEditar %>;
        
        if (!esEdicion) {
            document.querySelectorAll('.tipo-badge').forEach(badge => {
                badge.addEventListener('click', function() {
                    console.log('🖱️ Badge clickeado:', this.dataset.tipo);
                    
                    // Remover active de todos
                    document.querySelectorAll('.tipo-badge').forEach(b => b.classList.remove('active'));
                    
                    // Agregar active al seleccionado
                    this.classList.add('active');
                    
                    const tipo = this.dataset.tipo;
                    const rol = this.dataset.rol;
                    
                    // ✅ ACTUALIZAR EL ROL OCULTO
                    document.getElementById('rol_hidden').value = rol;
                    console.log('✅ Rol establecido:', rol);
                    
                    cargarPersonasPorTipo(tipo);
                });
            });
        }

        // ✅ FUNCIÓN CORREGIDA PARA MOSTRAR NOMBRES REALES
        function cargarPersonasPorTipo(tipo) {
            const select = document.getElementById('persona_id_select');
            
            console.log('='.repeat(60));
            console.log('🔄 INICIANDO CARGA DE PERSONAS');
            console.log('='.repeat(60));
            
            // Limpiar select
            select.innerHTML = '';
            console.log('✅ Select limpiado');
            
            let personas = [];
            
            // Determinar qué array usar
            if (tipo === 'PROFESOR') {
                personas = profesoresSinUsuario;
            } else if (tipo === 'ALUMNO') {
                personas = alumnosSinUsuario;
            } else if (tipo === 'ADMINISTRATIVO') {
                personas = administrativosSinUsuario;
            }
            
            console.log('🔍 Tipo seleccionado:', tipo);
            console.log('📊 Total personas encontradas:', personas.length);
            console.log('📊 Array completo:', personas);
            
            // Validar que hay personas
            if (personas.length === 0) {
                const optionVacia = document.createElement('option');
                optionVacia.value = '';
                optionVacia.textContent = 'No hay personas disponibles de este tipo';
                select.appendChild(optionVacia);
                select.disabled = true;
                console.log('⚠️ No hay personas disponibles de tipo:', tipo);
                return;
            }
            
            // Agregar opción por defecto
            const optionDefault = document.createElement('option');
            optionDefault.value = '';
            optionDefault.textContent = '-- Seleccione una persona --';
            select.appendChild(optionDefault);
            console.log('✅ Opción por defecto agregada');
            
            console.log('\n📋 PROCESANDO PERSONAS:');
            console.log('-'.repeat(60));
            
            // ✅ AGREGAR PERSONAS CON VALIDACIÓN DE DATOS MEJORADA
            personas.forEach((p, index) => {
                console.log('\n[' + (index + 1) + '] Procesando persona:', p);
                
                const option = document.createElement('option');
                option.value = p.personaId;
                
                // ✅ VALIDAR que los datos no sean undefined/null/vacíos/false/"false"
                const apellidos = (p.apellidos && 
                                  p.apellidos !== 'false' && 
                                  p.apellidos !== false && 
                                  String(p.apellidos).trim() !== '' &&
                                  String(p.apellidos).trim() !== 'null') 
                                 ? String(p.apellidos).trim() : '';
                                 
                const nombres = (p.nombres && 
                                p.nombres !== 'false' && 
                                p.nombres !== false && 
                                String(p.nombres).trim() !== '' &&
                                String(p.nombres).trim() !== 'null') 
                               ? String(p.nombres).trim() : '';
                               
                const codigo = (p.codigo && String(p.codigo).trim() !== '') ? String(p.codigo).trim() : '';
                const infoAdicional = (p.infoAdicional && String(p.infoAdicional).trim() !== '') ? String(p.infoAdicional).trim() : '';
                
                console.log('  - Apellidos RAW:', p.apellidos);
                console.log('  - Apellidos PROCESADO: "' + apellidos + '"');
                console.log('  - Nombres RAW:', p.nombres);
                console.log('  - Nombres PROCESADO: "' + nombres + '"');
                console.log('  - Código: "' + codigo + '"');
                console.log('  - Info adicional: "' + infoAdicional + '"');
                
                // Construir el texto de la opción
                let textoOpcion = '';
                
                // Priorizar mostrar apellidos y nombres
                if (apellidos !== '' && nombres !== '') {
                    textoOpcion = apellidos + ', ' + nombres;
                    console.log('  ✅ Opción A: Apellido + Nombre = "' + textoOpcion + '"');
                } else if (apellidos !== '') {
                    textoOpcion = apellidos;
                    console.log('  ✅ Opción B: Solo Apellido = "' + textoOpcion + '"');
                } else if (nombres !== '') {
                    textoOpcion = nombres;
                    console.log('  ✅ Opción C: Solo Nombre = "' + textoOpcion + '"');
                } else {
                    textoOpcion = 'Persona ID: ' + p.personaId;
                    console.log('  ⚠️ Opción D: Sin nombre, usando ID = "' + textoOpcion + '"');
                }
                
                // Agregar código si existe
                if (codigo !== '') {
                    textoOpcion = textoOpcion + ' [' + codigo + ']';
                    console.log('  ✅ Agregado código: "' + textoOpcion + '"');
                }
                
                // Agregar información adicional si existe
                if (infoAdicional !== '') {
                    textoOpcion = textoOpcion + ' - ' + infoAdicional;
                    console.log('  ✅ Agregada info adicional: "' + textoOpcion + '"');
                }
                
                console.log('  🎯 TEXTO FINAL: "' + textoOpcion + '"');
                console.log('  🔢 VALOR (ID): ' + p.personaId);
                
                option.textContent = textoOpcion;
                option.dataset.persona = JSON.stringify(p);
                select.appendChild(option);
                
                console.log('  ✅ Opción agregada al select');
            });
            
            select.disabled = false;
            
            console.log('\n' + '='.repeat(60));
            console.log('✅ CARGA COMPLETADA');
            console.log('📊 Total opciones en el select:', select.options.length);
            console.log('📊 Personas procesadas:', personas.length);
            console.log('📊 Tipo:', tipo);
            console.log('='.repeat(60) + '\n');
        }

        // Cuando se selecciona una persona, mostrar su información
        if (!esEdicion) {
            document.getElementById('persona_id_select').addEventListener('change', function() {
                console.log('📝 Select cambiado, valor:', this.value);
                
                const selectedOption = this.options[this.selectedIndex];
                const personaId = this.value;
                
                // Actualizar hidden input
                document.getElementById('persona_id_hidden').value = personaId;
                console.log('✅ Hidden input actualizado:', personaId);
                
                if (personaId && selectedOption.dataset.persona) {
                    const persona = JSON.parse(selectedOption.dataset.persona);
                    console.log('👤 Persona seleccionada:', persona);
                    mostrarInfoPersona(persona);
                    
                    // Auto-sugerir username
                    if (persona.correo && persona.correo.trim() !== '') {
                        const usernamesugerido = persona.correo.split('@')[0];
                        document.getElementById('username').value = usernamesugerido;
                        console.log('✅ Username sugerido:', usernamesugerido);
                    } else if (persona.nombres && persona.apellidos) {
                        // Alternativa: usar primera letra del nombre + apellido
                        const usernamesugerido = (persona.nombres.charAt(0) + persona.apellidos).toLowerCase().replace(/\s/g, '');
                        document.getElementById('username').value = usernamesugerido;
                        console.log('✅ Username alternativo sugerido:', usernamesugerido);
                    }
                } else {
                    console.log('⚠️ No se seleccionó persona válida');
                    ocultarInfoPersona();
                }
            });
        }

        function mostrarInfoPersona(persona) {
            console.log('📋 Mostrando información de persona:', persona);
            
            const nombreCompleto = (persona.nombres || '') + ' ' + (persona.apellidos || '');
            document.getElementById('infoNombre').textContent = nombreCompleto.trim() || '-';
            document.getElementById('infoCorreo').textContent = persona.correo || '-';
            document.getElementById('infoDni').textContent = persona.dni || '-';
            document.getElementById('infoCodigo').textContent = persona.codigo || '-';
            document.getElementById('infoAdicional').textContent = persona.infoAdicional || '-';
            
            document.getElementById('personaInfo').classList.add('active');
            console.log('✅ Información de persona mostrada');
        }

        function ocultarInfoPersona() {
            console.log('🙈 Ocultando información de persona');
            document.getElementById('personaInfo').classList.remove('active');
        }

        // ===================================================================
        // VALIDACIÓN DE CONTRASEÑA
        // ===================================================================
        function encriptarPasswordSHA256(password) {
            return CryptoJS.SHA256(password).toString();
        }

        const textosOriginales = {
            reqLongitud: "Mínimo 8 caracteres",
            reqMayuscula: "Al menos una letra mayúscula",
            reqMinuscula: "Al menos una letra minúscula", 
            reqNumero: "Al menos un número",
            reqEspecial: "Al menos un carácter especial (!@#$%^&*)",
            reqCriterios: "Cumplir al menos 3 de los 4 criterios anteriores"
        };

        function validarPasswordEnTiempoReal(password) {
            const indicador = document.getElementById('indicadorPassword');
            const requisitos = document.getElementById('requisitosPassword');
            const submitBtn = document.getElementById('submitBtn');
            
            if (password.length > 0) {
                requisitos.style.display = 'block';
            } else {
                if (esEdicion) {
                    indicador.innerHTML = '<span class="text-success"><i class="fas fa-check-circle"></i> Se mantendrá la contraseña actual</span>';
                    submitBtn.disabled = false;
                } else {
                    indicador.innerHTML = '<span class="text-warning"><i class="fas fa-exclamation-triangle"></i> Ingrese una contraseña</span>';
                    submitBtn.disabled = true;
                }
                requisitos.style.display = 'none';
                resetearRequisitos();
                return;
            }
            
            const longitudValida = password.length >= 8;
            const tieneMayuscula = /[A-Z]/.test(password);
            const tieneMinuscula = /[a-z]/.test(password);
            const tieneNumero = /[0-9]/.test(password);
            const tieneEspecial = /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(password);
            
            actualizarRequisito('reqLongitud', longitudValida);
            actualizarRequisito('reqMayuscula', tieneMayuscula);
            actualizarRequisito('reqMinuscula', tieneMinuscula);
            actualizarRequisito('reqNumero', tieneNumero);
            actualizarRequisito('reqEspecial', tieneEspecial);
            
            let criteriosCumplidos = 0;
            if (tieneMayuscula) criteriosCumplidos++;
            if (tieneMinuscula) criteriosCumplidos++;
            if (tieneNumero) criteriosCumplidos++;
            if (tieneEspecial) criteriosCumplidos++;
            
            const criteriosValidos = criteriosCumplidos >= 3;
            actualizarRequisito('reqCriterios', criteriosValidos);
            
            document.getElementById('criteriosCumplidos').textContent = criteriosCumplidos;
            
            const esFuerte = longitudValida && criteriosValidos;
            
            if (esFuerte) {
                indicador.innerHTML = '<span class="text-success"><i class="fas fa-check-circle"></i> Contraseña segura</span>';
                submitBtn.disabled = false;
            } else {
                let mensajesError = [];
                if (!longitudValida) mensajesError.push('mínimo 8 caracteres');
                if (!criteriosValidos) mensajesError.push('cumplir 3 de 4 criterios');
                
                indicador.innerHTML = '<span class="text-danger"><i class="fas fa-times-circle"></i> Faltan: ' + mensajesError.join(', ') + '</span>';
                submitBtn.disabled = true;
            }
        }
        
        function actualizarRequisito(elementId, cumple) {
            const elemento = document.getElementById(elementId);
            const textoBase = textosOriginales[elementId];
            
            if (cumple) {
                elemento.className = 'criterio-item requisito-cumplido';
                elemento.innerHTML = '<i class="fas fa-check-circle"></i> ' + textoBase;
            } else {
                elemento.className = 'criterio-item requisito-incumplido';
                elemento.innerHTML = '<i class="fas fa-times-circle"></i> ' + textoBase;
            }
        }
        
        function resetearRequisitos() {
            Object.keys(textosOriginales).forEach(elementId => {
                const elemento = document.getElementById(elementId);
                if (elemento) {
                    elemento.className = 'criterio-item requisito-pendiente';
                    elemento.innerHTML = '<i class="fas fa-circle"></i> ' + textosOriginales[elementId];
                }
            });
            document.getElementById('criteriosCumplidos').textContent = '0';
        }
        
        // ===================================================================
        // ENVÍO DEL FORMULARIO
        // ===================================================================
        document.getElementById('usuarioForm').addEventListener('submit', async function(e) {
            e.preventDefault();
            
            console.log('=== VALIDANDO FORMULARIO ===');
            
            // Validar persona_id solo si NO es edición
            if (!esEdicion) {
                const personaId = document.getElementById('persona_id_hidden').value;
                console.log('🔍 Validando persona_id:', personaId);
                
                if (!personaId || personaId === '0' || personaId === '') {
                    alert('❌ Debe seleccionar una persona para asociar el usuario');
                    return false;
                }
                console.log('✅ Persona ID válido:', personaId);
                
                // Validar que se haya seleccionado un rol
                const rol = document.getElementById('rol_hidden').value;
                console.log('🔍 Validando rol:', rol);
                
                if (!rol || rol === '') {
                    alert('❌ Debe seleccionar un tipo de persona (esto establece el rol automáticamente)');
                    return false;
                }
                console.log('✅ Rol válido:', rol);
            }
            
            const password = document.getElementById('passwordInput').value;
            
            if (!esEdicion && password.length === 0) {
                alert('❌ La contraseña es obligatoria para nuevos usuarios');
                return false;
            }
            
            if (password.length > 0) {
                const longitudValida = password.length >= 8;
                const tieneMayuscula = /[A-Z]/.test(password);
                const tieneMinuscula = /[a-z]/.test(password);
                const tieneNumero = /[0-9]/.test(password);
                const tieneEspecial = /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(password);
                
                let criteriosCumplidos = 0;
                if (tieneMayuscula) criteriosCumplidos++;
                if (tieneMinuscula) criteriosCumplidos++;
                if (tieneNumero) criteriosCumplidos++;
                if (tieneEspecial) criteriosCumplidos++;
                
                const criteriosValidos = criteriosCumplidos >= 3;
                const esFuerte = longitudValida && criteriosValidos;
                
                if (!esFuerte) {
                    alert('❌ La contraseña no cumple con los requisitos de seguridad');
                    return false;
                }

                // Encriptar contraseña
                try {
                    const hashedPassword = encriptarPasswordSHA256(password);
                    document.getElementById('passwordInput').value = hashedPassword;
                    console.log('🔐 Contraseña encriptada con SHA256');
                } catch (error) {
                    alert('❌ Error encriptando la contraseña');
                    console.error('Error:', error);
                    return false;
                }
            }
            
            console.log('✅ Validación exitosa - Enviando formulario');
            this.submit();
        });

        // Mostrar/ocultar requisitos al enfocar
        document.getElementById('passwordInput').addEventListener('focus', function() {
            if (this.value.length > 0) {
                document.getElementById('requisitosPassword').style.display = 'block';
            }
        });
        
        // DEBUG: Al cargar la página
        console.log('🚀 Página cargada - Estado inicial:');
        console.log('Es edición:', esEdicion);
        console.log('Profesores:', profesoresSinUsuario);
        console.log('Alumnos:', alumnosSinUsuario);
        console.log('Administrativos:', administrativosSinUsuario);
    </script>
</body>
</html>
