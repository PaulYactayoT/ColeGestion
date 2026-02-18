<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect("index.jsp");
        return;
    }
    request.setAttribute("pageTitle", "Gestión de Módulos");
%>
<!DOCTYPE html>
<html class="light" lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Módulos - San Antonio</title>
    <%@ include file="includes/head.jsp" %>

    <style>
        /* ====== TARJETA ====== */
        .gm-card {
            border-radius: 14px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.08);
            background: #fff;
            overflow: hidden;
        }
        .dark .gm-card { background: #1a2233; }

        /* ====== CABECERA ====== */
        .gm-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #fff;
            padding: 1.2rem 1.5rem;
        }

        /* ====== TABS DE ROL ====== */
        .rol-tab {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 5px 14px; border-radius: 20px;
            font-size: 0.8rem; font-weight: 600; cursor: pointer;
            border: 2px solid transparent; transition: all .2s;
            background: rgba(255,255,255,0.15); color: #fff;
        }
        .rol-tab:hover  { background: rgba(255,255,255,0.28); }
        .rol-tab.active { background: #fff; color: #667eea; }

        /* ====== FILAS USUARIOS ====== */
        .usuario-row { cursor: pointer; transition: background .15s; }
        .usuario-row:hover    { background: #f0f4ff; }
        .dark .usuario-row:hover { background: #252d3d; }
        .usuario-row.active   { background: #e4e9ff; }
        .dark .usuario-row.active { background: #2a3555; }

        /* ====== BADGES DE ROL ====== */
        .badge-docente        { background:#d1fae5; color:#065f46; }
        .badge-padre          { background:#dbeafe; color:#1e40af; }
        .badge-administrativo { background:#fef3c7; color:#92400e; }
        .dark .badge-docente        { background:#064e3b55; color:#34d399; }
        .dark .badge-padre          { background:#1e3a5f55; color:#93c5fd; }
        .dark .badge-administrativo { background:#78350f55; color:#fcd34d; }

        /* ====== ITEMS MÓDULO ====== */
        .modulo-item {
            display: flex; align-items: center; gap: 12px;
            padding: 13px 15px;
            border: 2px solid #e5e7eb; border-radius: 10px;
            cursor: pointer; transition: all .2s; background: #fff;
        }
        .dark .modulo-item { background: #1e2a3a; border-color: #2d3f54; }
        .modulo-item:hover  { border-color: #667eea; background: #f5f7ff; }
        .dark .modulo-item:hover { background: #253044; }
        .modulo-item.seleccionado {
            border-color: #667eea; background: #eef0ff;
            box-shadow: 0 0 0 3px rgba(102,126,234,.15);
        }
        .dark .modulo-item.seleccionado { background: #2a3555; }

        .modulo-icono {
            width: 42px; height: 42px; flex-shrink: 0;
            background: linear-gradient(135deg, #667eea, #764ba2);
            border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
            color: #fff; font-size: 1.1rem;
        }
        .modulo-item input[type="checkbox"] {
            width: 17px; height: 17px; cursor: pointer;
            flex-shrink: 0; accent-color: #667eea;
        }

        /* ====== PANEL SCROLL ====== */
        #modulosContainer { max-height: 560px; overflow-y: auto; }

        /* ====== BARRA CHECK-ALL ====== */
        .checkall-bar {
            display: none;
            align-items: center; gap: 10px;
            padding: 9px 16px;
            background: #f9fafb; border-bottom: 1px solid #e5e7eb;
            font-size: .84rem;
        }
        .dark .checkall-bar { background: #1e2a3a; border-color: #2d3f54; }
        .checkall-bar.visible { display: flex; }

        /* ====== BOTONES ====== */
        .btn-guardar {
            background: linear-gradient(135deg,#667eea,#764ba2);
            color:#fff; border:none; border-radius:9px;
            padding:.5rem 1.3rem; font-weight:600; font-size:.86rem;
            cursor:pointer; transition:opacity .2s;
            display:inline-flex; align-items:center; gap:6px;
        }
        .btn-guardar:hover    { opacity:.87; }
        .btn-guardar:disabled { background:#9ca3af; cursor:not-allowed; opacity:1; }

        .btn-eliminar {
            background: #ef4444; color:#fff; border:none; border-radius:9px;
            padding:.5rem 1.3rem; font-weight:600; font-size:.86rem;
            cursor:pointer; transition:opacity .2s;
            display:inline-flex; align-items:center; gap:6px;
        }
        .btn-eliminar:hover    { opacity:.85; }
        .btn-eliminar:disabled { background:#9ca3af; cursor:not-allowed; opacity:1; }

        /* ====== ESTADOS VACÍOS ====== */
        .estado-vacio { text-align:center; padding:48px 20px; color:#9ca3af; }
        .estado-vacio i { font-size:3.2rem; opacity:.3; margin-bottom:.8rem; display:block; }

        /* ====== BUSCADOR ====== */
        .buscador-wrap { position:relative; }
        .buscador-wrap i { position:absolute; left:11px; top:50%; transform:translateY(-50%); color:#9ca3af; font-size:.85rem; }
        .buscador-input {
            width:100%; padding:8px 12px 8px 34px;
            border:1.5px solid #e5e7eb; border-radius:8px;
            font-size:.86rem; background:#fff; color:#111;
            outline:none; transition:border .2s;
        }
        .dark .buscador-input { background:#1e2a3a; border-color:#2d3f54; color:#fff; }
        .buscador-input:focus { border-color:#667eea; }

        /* ====== TABLA ====== */
        .gm-table { width:100%; border-collapse:collapse; font-size:.87rem; }
        .gm-table th {
            text-align:left; padding:10px 14px;
            background:#f8f9fa; font-weight:700; color:#374151;
            border-bottom:2px solid #e5e7eb; white-space:nowrap;
        }
        .dark .gm-table th { background:#1e2a3a; color:#9ca3af; border-color:#2d3f54; }
        .gm-table td { padding:10px 14px; border-bottom:1px solid #f3f4f6; vertical-align:middle; }
        .dark .gm-table td { border-color:#1e2a3a; }

        /* ====== ESTADÍSTICAS ====== */
        .stat-card {
            background:#fff; border-radius:12px;
            padding:14px 18px;
            box-shadow:0 2px 12px rgba(0,0,0,0.07);
            display:flex; align-items:center; gap:12px;
        }
        .dark .stat-card { background:#1a2233; }
        .stat-icon {
            width:42px; height:42px; border-radius:10px; flex-shrink:0;
            display:flex; align-items:center; justify-content:center;
            font-size:1.1rem;
        }
        
        .modulo-item {
        display: flex;
        align-items: center;
        padding: 12px;
        border: 2px solid #e5e7eb;
        border-radius: 10px;
        cursor: pointer;
        transition: all 0.2s;
    }
    .modulo-item.seleccionado {
        border-color: #8b5cf6;
        background-color: #f5f3ff;
    }
    .modulo-icono {
        width: 40px;
        height: 40px;
        display: flex;
        align-items: center;
        justify-content: center;
        background: #f3f4f6;
        border-radius: 8px;
        margin-right: 12px;
        color: #6b7280;
    }
    .modulo-item.seleccionado .modulo-icono {
        background: #8b5cf6;
        color: white;
    }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark text-[#111318] dark:text-white min-h-screen">
<div class="flex h-screen overflow-hidden">

    <%@ include file="includes/sidebar.jsp" %>

    <main class="flex-1 flex flex-col overflow-y-auto">
        <%@ include file="includes/header.jsp" %>

        <div class="p-6 space-y-5 max-w-[1440px] mx-auto w-full">

            <%-- ===== TÍTULO ===== --%>
            <div>
                <h2 class="text-2xl font-bold flex items-center gap-2 text-[#111318] dark:text-white">
                    <i class="fas fa-shield-alt text-purple-500"></i>
                    Gestión de Módulos por Usuario
                </h2>
                <p class="text-sm text-[#616f89] dark:text-gray-400 mt-1">
                    Asigna, actualiza o elimina los módulos de acceso para cada usuario registrado.
                </p>
            </div>

            <%-- ===== ESTADÍSTICAS ===== --%>
            <div class="grid grid-cols-2 md:grid-cols-4 gap-3" id="statsBar">
                <div class="stat-card">
                    <div class="stat-icon bg-green-100 dark:bg-green-900/30 text-green-600"><i class="fas fa-chalkboard-teacher"></i></div>
                    <div>
                        <p class="text-xs text-gray-500 dark:text-gray-400">Profesores</p>
                        <p class="font-bold text-lg text-[#111318] dark:text-white" id="cntDocente">0</p>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon bg-blue-100 dark:bg-blue-900/30 text-blue-600"><i class="fas fa-user-friends"></i></div>
                    <div>
                        <p class="text-xs text-gray-500 dark:text-gray-400">Padres</p>
                        <p class="font-bold text-lg text-[#111318] dark:text-white" id="cntPadre">0</p>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon bg-yellow-100 dark:bg-yellow-900/30 text-yellow-600"><i class="fas fa-user-tie"></i></div>
                    <div>
                        <p class="text-xs text-gray-500 dark:text-gray-400">Administrativos</p>
                        <p class="font-bold text-lg text-[#111318] dark:text-white" id="cntAdm">0</p>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon bg-purple-100 dark:bg-purple-900/30 text-purple-600"><i class="fas fa-users"></i></div>
                    <div>
                        <p class="text-xs text-gray-500 dark:text-gray-400">Total</p>
                        <p class="font-bold text-lg text-[#111318] dark:text-white" id="cntTotal">0</p>
                    </div>
                </div>
            </div>

            <%-- ===== GRID PRINCIPAL ===== --%>
            <div class="grid grid-cols-1 lg:grid-cols-12 gap-5">

                <%-- ===== PANEL IZQUIERDO: USUARIOS ===== --%>
                <div class="lg:col-span-5">
                    <div class="gm-card">
                        <%-- Cabecera con tabs de filtro --%>
                        <div class="gm-header">
                            <h5 class="font-bold text-base mb-3 flex items-center gap-2">
                                <i class="fas fa-users"></i> Usuarios Registrados
                            </h5>
                            <div class="flex flex-wrap gap-2">
                                <button class="rol-tab active" onclick="filtrarRol('todos',this)">
                                    <i class="fas fa-th"></i> Todos
                                </button>
                                <button class="rol-tab" onclick="filtrarRol('docente',this)">
                                    <i class="fas fa-chalkboard-teacher"></i> Profesores
                                </button>
                                <button class="rol-tab" onclick="filtrarRol('padre',this)">
                                    <i class="fas fa-user-friends"></i> Padres
                                </button>
                                <button class="rol-tab" onclick="filtrarRol('administrativo',this)">
                                    <i class="fas fa-user-tie"></i> Administrativos
                                </button>
                            </div>
                        </div>

                        <%-- Buscador --%>
                        <div class="p-3 border-b border-gray-200 dark:border-gray-700">
                            <div class="buscador-wrap">
                                <i class="fas fa-search"></i>
                                <input type="text" class="buscador-input"
                                       placeholder="Buscar por nombre o usuario..."
                                       oninput="buscarUsuario(this.value)">
                            </div>
                        </div>

                        <%-- Tabla de usuarios --%>
                        <div style="max-height:480px; overflow-y:auto;">
                            <table class="gm-table">
                                <thead>
                                    <tr>
                                        <th>Nombre / Usuario</th>
                                        <th>Rol</th>
                                        <th class="text-center">Mód.</th>
                                    </tr>
                                </thead>
                                <tbody id="tbUsuarios">
                                    <c:choose>
                                        <c:when test="${empty usuarios}">
                                            <tr>
                                                <td colspan="3">
                                                    <div class="estado-vacio">
                                                        <i class="fas fa-inbox"></i>
                                                        <p class="font-semibold">No hay usuarios registrados</p>
                                                        <p class="text-xs mt-1">Registra usuarios primero para asignarles módulos</p>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach var="u" items="${usuarios}">
                                                <tr class="usuario-row"
                                                    data-id="${u.id}"
                                                    data-rol="${u.rol}"
                                                    data-nombre="${u.nombreCompleto}"
                                                    data-username="${u.username}"
                                                    onclick="seleccionarUsuario(this)">
                                                    <td>
                                                        <span class="font-semibold text-[#111318] dark:text-white block leading-tight">${u.nombreCompleto}</span>
                                                        <span class="text-xs text-gray-400">@${u.username}</span>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${u.rol == 'docente'}">
                                                                <span class="badge-docente inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-xs font-semibold">
                                                                    <i class="fas fa-chalkboard-teacher"></i> Profesor
                                                                </span>
                                                            </c:when>
                                                            <c:when test="${u.rol == 'padre'}">
                                                                <span class="badge-padre inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-xs font-semibold">
                                                                    <i class="fas fa-user-friends"></i> Padre
                                                                </span>
                                                            </c:when>
                                                            <c:when test="${u.rol == 'administrativo'}">
                                                                <span class="badge-administrativo inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-xs font-semibold">
                                                                    <i class="fas fa-user-tie"></i> Administrativo
                                                                </span>
                                                            </c:when>
                                                        </c:choose>
                                                    </td>
                                                    <td class="text-center">
                                                        <span class="modulos-cnt inline-flex items-center justify-center w-7 h-7 rounded-full text-xs font-bold
                                                            ${u.modulosAsignados > 0
                                                              ? 'bg-purple-100 text-purple-700 dark:bg-purple-900/40 dark:text-purple-300'
                                                              : 'bg-gray-100 text-gray-500 dark:bg-gray-700 dark:text-gray-400'}">
                                                            ${u.modulosAsignados}
                                                        </span>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:otherwise>
                                    </c:choose>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <%-- ===== PANEL DERECHO: MÓDULOS ===== --%>
                <div class="lg:col-span-7">
                    <div class="gm-card flex flex-col" style="min-height:400px;">

                        <%-- Cabecera del panel de módulos --%>
                        <div class="gm-header flex justify-between items-start gap-3">
                            <div>
                                <h5 class="font-bold text-base flex items-center gap-2 mb-1">
                                    <i class="fas fa-puzzle-piece"></i> Módulos Disponibles
                                </h5>
                                <p id="lblUsuario" class="text-blue-100 text-sm">
                                    Selecciona un usuario de la lista
                                </p>
                            </div>
                            <div class="flex gap-2 flex-shrink-0 mt-1">
                                <button id="btnEliminar" class="btn-eliminar" disabled onclick="eliminarModulos()">
                                    <i class="fas fa-trash-alt"></i> Eliminar
                                </button>
                                <button id="btnGuardar" class="btn-guardar" disabled onclick="guardarModulos()">
                                    <i class="fas fa-save"></i> Guardar
                                </button>
                            </div>
                        </div>

                        <%-- Barra seleccionar todos --%>
                        <div class="checkall-bar" id="barraCheckAll">
                            <input type="checkbox" id="chkTodos" style="width:16px;height:16px;accent-color:#667eea;"
                                   onchange="toggleTodos(this.checked)">
                            <label for="chkTodos" class="cursor-pointer font-medium text-[#111318] dark:text-white select-none">
                                Seleccionar / Deseleccionar todos
                            </label>
                            <span id="lblContador" class="ml-auto text-purple-600 dark:text-purple-400 font-semibold text-sm"></span>
                        </div>

                        <%-- Contenedor de módulos --%>
                        <div id="modulosContainer" class="flex-1">
                            <div class="estado-vacio">
                                <i class="fas fa-hand-pointer"></i>
                                <p class="font-semibold text-lg text-[#111318] dark:text-white">Selecciona un usuario</p>
                                <p class="text-sm mt-1">Los módulos disponibles aparecerán aquí</p>
                            </div>
                        </div>

                    </div>
                </div>

            </div><%-- fin grid --%>
        </div><%-- fin p-6 --%>
    </main>
</div>

<!-- SweetAlert2 -->
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<script>
// =======================================================
//  ESTADO
// =======================================================
let usuarioActual = null;
let rolActual     = null;
let filtroRol     = 'todos';

// =======================================================
//  INICIALIZACIÓN — contadores por rol
// =======================================================
document.addEventListener('DOMContentLoaded', () => {
    let doc = 0, pad = 0, adm = 0;
    document.querySelectorAll('#tbUsuarios .usuario-row').forEach(r => {
        const rol = r.dataset.rol;
        if (rol === 'docente')         doc++;
        else if (rol === 'padre')      pad++;
        else if (rol === 'administrativo') adm++;
    });
    document.getElementById('cntDocente').textContent = doc;
    document.getElementById('cntPadre').textContent   = pad;
    document.getElementById('cntAdm').textContent     = adm;
    document.getElementById('cntTotal').textContent   = doc + pad + adm;
});

// =======================================================
//  FILTRAR POR ROL
// =======================================================
function filtrarRol(rol, btn) {
    filtroRol = rol;
    document.querySelectorAll('.rol-tab').forEach(t => t.classList.remove('active'));
    btn.classList.add('active');
    aplicarFiltros();
}

// =======================================================
//  BÚSQUEDA
// =======================================================
function buscarUsuario(texto) {
    aplicarFiltros(texto.toLowerCase().trim());
}

function aplicarFiltros(texto = '') {
    document.querySelectorAll('#tbUsuarios .usuario-row').forEach(fila => {
        const rolOk  = filtroRol === 'todos' || fila.dataset.rol === filtroRol;
        const txtOk  = texto === '' ||
                       fila.dataset.nombre.toLowerCase().includes(texto) ||
                       fila.dataset.username.toLowerCase().includes(texto);
        fila.style.display = (rolOk && txtOk) ? '' : 'none';
    });
}
// =======================================================
//  SELECCIONAR USUARIO Y CARGAR MÓDULOS (VERSIÓN CON DEBUG)
// =======================================================
function seleccionarUsuario(el) {
    const id       = el.dataset.id;
    const rol      = el.dataset.rol;
    const nombre   = el.dataset.nombre;
    const username = el.dataset.username;
    
    console.log('=== SELECCIONANDO USUARIO ===');
    console.log('ID:', id);
    console.log('Rol:', rol);
    console.log('Nombre:', nombre);
    console.log('Username:', username);
    
    usuarioActual = id;
    rolActual     = rol;

    // Marcar fila activa
    document.querySelectorAll('.usuario-row').forEach(r => r.classList.remove('active'));
    document.querySelector(`.usuario-row[data-id="${id}"]`)?.classList.add('active');

    // Cabecera
    document.getElementById('lblUsuario').innerHTML =
        `<i class="fas fa-user"></i> <strong>${nombre}</strong> (@${username}) — ` + etiquetaRol(rol);

    // Loading
    document.getElementById('modulosContainer').innerHTML =
        `<div class="flex flex-col items-center justify-center py-16 gap-3 text-gray-400">
            <div class="animate-spin rounded-full h-11 w-11 border-4 border-purple-500 border-t-transparent"></div>
            <span class="text-sm">Cargando módulos...</span>
         </div>`;

    document.getElementById('btnGuardar').disabled  = true;
    document.getElementById('btnEliminar').disabled = true;
    document.getElementById('barraCheckAll').classList.remove('visible');

    // CONSTRUIR URL MANUALMENTE PARA VERIFICAR
    const url = 'ModuloServlet?accion=obtenerModulosUsuario&usuarioId=' + id + '&rol=' + encodeURIComponent(rol);
    console.log('URL del fetch:', url);
    
    // VERSIÓN MEJORADA CON MANEJO DE ERRORES DETALLADO
    fetch(url)
        .then(async response => {
            console.log('Status de respuesta:', response.status);
            console.log('Status text:', response.statusText);
            
            if (!response.ok) {
                const text = await response.text();
                console.error('Respuesta no OK. Texto:', text);
                throw new Error(`HTTP error! status: ${response.status}, texto: ${text.substring(0, 200)}`);
            }
            
            const contentType = response.headers.get('content-type');
            console.log('Content-Type:', contentType);
            
            if (!contentType || !contentType.includes('application/json')) {
                const text = await response.text();
                console.error('No es JSON. Texto recibido:', text.substring(0, 500));
                throw new Error('La respuesta no es JSON. Es: ' + contentType);
            }
            
            return response.json();
        })
        .then(modulos => {
            console.log('✅ Módulos recibidos:', modulos);
            console.log('Cantidad de módulos:', modulos.length);
            
            if (!modulos || modulos.length === 0) {
                document.getElementById('modulosContainer').innerHTML =
                    `<div class="estado-vacio">
                        <i class="fas fa-info-circle"></i>
                        <p class="font-semibold text-[#111318] dark:text-white">No hay módulos disponibles</p>
                        <p class="text-sm mt-1">Verifica que existan módulos en la base de datos</p>
                     </div>`;
                return;
            }
            
            renderizarModulos(modulos);
            document.getElementById('btnGuardar').disabled  = false;
            document.getElementById('btnEliminar').disabled = false;
            document.getElementById('barraCheckAll').classList.add('visible');
            actualizarContador();
        })
        .catch(error => {
            console.error('❌ ERROR COMPLETO:', error);
            
            // Mostrar error detallado en la interfaz
            document.getElementById('modulosContainer').innerHTML =
                `<div class="estado-vacio" style="text-align: left; padding: 20px;">
                    <i class="fas fa-exclamation-triangle text-red-500" style="font-size: 3rem;"></i>
                    <p class="font-bold text-red-600 dark:text-red-400 mt-4">Error al cargar módulos</p>
                    <p class="text-sm text-gray-600 dark:text-gray-400 mt-2">${error.message}</p>
                    <p class="text-xs text-gray-500 dark:text-gray-500 mt-4">Revisa la consola (F12) para más detalles</p>
                    <button onclick="recargarUsuario()" class="mt-4 px-4 py-2 bg-blue-500 text-white rounded-lg">
                        Reintentar
                    </button>
                 </div>`;
        });
}

// Función auxiliar para reintentar
function recargarUsuario() {
    if (usuarioActual) {
        const fila = document.querySelector(`.usuario-row[data-id="${usuarioActual}"]`);
        if (fila) seleccionarUsuario(fila);
    }
}
// =======================================================
//  RENDERIZAR MÓDULOS
// =======================================================
function renderizarModulos(modulos) {
    const container = document.getElementById('modulosContainer');

    if (!modulos || modulos.length === 0) {
        container.innerHTML = '<div class="p-10 text-center text-gray-500">No hay módulos disponibles para este rol</div>';
        return;
    }

    // Agrupar módulos por rolAplicable
    const grupos = {
        'admin':          { titulo: 'Módulos de Administrador',    icono: 'fas fa-cog',               color: '#667eea', items: [] },
        'administrativo': { titulo: 'Módulos de Administrativo',   icono: 'fas fa-user-tie',           color: '#f59e0b', items: [] },
        'docente':        { titulo: 'Módulos de Profesor',         icono: 'fas fa-chalkboard-teacher', color: '#10b981', items: [] },
        'padre':          { titulo: 'Módulos de Padre de Familia', icono: 'fas fa-user-friends',       color: '#3b82f6', items: [] }
    };

    modulos.forEach(function(m) {
        // Gson serializa rolAplicable en camelCase
        var r = (m.rolAplicable || '').toLowerCase().trim();
        if (grupos[r]) {
            grupos[r].items.push(m);
        } else {
            grupos['admin'].items.push(m);
        }
    });

    // Construir HTML usando concatenación, NO template literals con 
    // porque JSP interpreta como Expression Language
    var html = '';

    var orden = ['admin', 'administrativo', 'docente', 'padre'];
    orden.forEach(function(key) {
        var grupo = grupos[key];
        if (grupo.items.length === 0) return;

        html += '<div style="margin-bottom:20px; padding: 0 12px;">';

        // Subtítulo del grupo
        html += '<div style="display:flex; align-items:center; gap:8px; padding:10px 0 8px 0;' +
                'border-bottom: 2px solid #e5e7eb; margin-bottom:10px;">';
        html += '<div style="width:26px;height:26px;border-radius:6px;background:' + grupo.color + ';' +
                'display:flex;align-items:center;justify-content:center;flex-shrink:0;">';
        html += '<i class="' + grupo.icono + '" style="color:#fff;font-size:11px;"></i>';
        html += '</div>';
        html += '<span style="font-size:0.72rem;font-weight:800;letter-spacing:0.08em;' +
                'text-transform:uppercase;color:#6b7280;">' + grupo.titulo + '</span>';
        html += '<span style="margin-left:auto;font-size:0.7rem;color:#9ca3af;">' +
                grupo.items.length + ' módulo' + (grupo.items.length !== 1 ? 's' : '') + '</span>';
        html += '</div>';

        // Grid de módulos
        html += '<div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:10px;">';

        grupo.items.forEach(function(m) {
            var estaAsignado = m.asignado === true || m.asignado === 'true';
            var claseItem    = 'modulo-item' + (estaAsignado ? ' seleccionado' : '');
            var checkeado    = estaAsignado ? 'checked' : '';
            var icono        = m.icono || 'fas fa-circle';
            var nombre       = m.nombre || 'Sin nombre';
            var descripcion  = m.descripcion || '';
            var idModulo     = m.id;

            // Badge de estado
            var badge = estaAsignado
                ? '<span style="font-size:10px;background:#d1fae5;color:#065f46;padding:2px 7px;' +
                  'border-radius:10px;font-weight:700;white-space:nowrap;">✓ Activo</span>'
                : '<span style="font-size:10px;background:#f3f4f6;color:#9ca3af;padding:2px 7px;' +
                  'border-radius:10px;font-weight:600;white-space:nowrap;">Sin asignar</span>';

            html += '<div class="' + claseItem + '" onclick="toggleModulo(this)">';
            html += '<input type="checkbox" value="' + idModulo + '" ' + checkeado +
                    ' onclick="event.stopPropagation(); actualizarContador()">';
            html += '<div class="modulo-icono" style="background:linear-gradient(135deg,' + grupo.color + ',' + grupo.color + 'cc);">';
            html += '<i class="' + icono + '"></i>';
            html += '</div>';
            html += '<div style="flex:1;min-width:0;">';
            html += '<p style="font-weight:700;font-size:0.82rem;color:#111318;line-height:1.2;margin:0 0 2px 0;">' + nombre + '</p>';
            html += '<p style="font-size:0.72rem;color:#9ca3af;margin:0;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">' + descripcion + '</p>';
            html += '</div>';
            html += badge;
            html += '</div>';
        });

        html += '</div>'; // fin grid
        html += '</div>'; // fin grupo
    });

    container.innerHTML = html;
    actualizarContador();
}
// =======================================================
//  TOGGLE MÓDULO
// =======================================================
function toggleModulo(el) {
    const cb = el.querySelector('input[type="checkbox"]');
    cb.checked = !cb.checked;
    el.classList.toggle('seleccionado', cb.checked);
    actualizarContador();
}

// =======================================================
//  SELECCIONAR / DESELECCIONAR TODOS
// =======================================================
function toggleTodos(checked) {
    document.querySelectorAll('#modulosContainer input[type="checkbox"]').forEach(cb => {
        cb.checked = checked;
        cb.closest('.modulo-item')?.classList.toggle('seleccionado', checked);
    });
    actualizarContador();
}

function actualizarContador() {
    const total   = document.querySelectorAll('#modulosContainer input[type="checkbox"]').length;
    const marcados = document.querySelectorAll('#modulosContainer input[type="checkbox"]:checked').length;
    document.getElementById('lblContador').textContent =
        total > 0 ? `${marcados} / ${total} seleccionados` : '';

    const chkTodos = document.getElementById('chkTodos');
    if (total > 0) {
        chkTodos.indeterminate = marcados > 0 && marcados < total;
        chkTodos.checked = marcados === total;
    }
}

// =======================================================
//  GUARDAR MÓDULOS
// =======================================================
function guardarModulos() {
    if (!usuarioActual) return;

    const seleccionados = [...document.querySelectorAll('#modulosContainer input[type="checkbox"]:checked')]
                          .map(cb => cb.value);
    
    console.log('=== GUARDAR MÓDULOS (JS) ===');
    console.log('usuarioActual:', usuarioActual);
    console.log('seleccionados:', seleccionados);

    if (seleccionados.length === 0) {
        Swal.fire({
            icon: 'warning',
            title: 'Sin módulos seleccionados',
            text: 'Debes seleccionar al menos un módulo para guardar.',
            confirmButtonColor: '#667eea'
        });
        return;
    }

    Swal.fire({
        title: '¿Guardar cambios?',
        html: `Se asignarán <strong>${seleccionados.length} módulo(s)</strong> al usuario.`,
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#667eea',
        cancelButtonColor:  '#6b7280',
        confirmButtonText:  '<i class="fas fa-save"></i> Sí, guardar',
        cancelButtonText:   'Cancelar'
    }).then(r => {
        if (!r.isConfirmed) return;

        Swal.fire({ title:'Guardando...', allowOutsideClick:false, didOpen:()=>Swal.showLoading() });

        // FIX: usar application/x-www-form-urlencoded para que Tomcat parsee correctamente
        let params = 'accion=guardarModulos&usuarioId=' + encodeURIComponent(usuarioActual);
        seleccionados.forEach(function(id) { params += '&modulos%5B%5D=' + encodeURIComponent(id); });
        console.log('Params enviados:', params);

        fetch('ModuloServlet', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: params
        })
            .then(async response => {
                console.log('Response status:', response.status);
                if (!response.ok) {
                    const text = await response.text();
                    console.error('Error response:', text);
                    throw new Error('HTTP error ' + response.status);
                }
                return response.json();
            })
            .then(res => {
                console.log('Respuesta del servidor:', res);
                if (res.exito) {
                    actualizarBadgeTabla(usuarioActual, res.cantidadModulos);
                    Swal.fire({
                        icon:'success', title:'¡Guardado!',
                        text: res.mensaje, timer:2000, showConfirmButton:false
                    });
                    const filaActual = document.querySelector(`.usuario-row[data-id="${usuarioActual}"]`);
                    if (filaActual) seleccionarUsuario(filaActual);
                } else {
                    Swal.fire({ icon:'error', title:'Error', text: res.mensaje });
                }
            })
            .catch(error => {
                console.error('Fetch error:', error);
                Swal.fire({ 
                    icon:'error', 
                    title:'Error', 
                    text:'No se pudieron guardar los cambios. Error: ' + error.message 
                });
            });
    });
}

// =======================================================
//  ELIMINAR TODOS LOS MÓDULOS
// =======================================================
function eliminarModulos() {
    if (!usuarioActual) return;

    Swal.fire({
        title: '¿Eliminar todos los módulos?',
        text: 'El usuario quedará sin acceso a ningún módulo.',
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#ef4444',
        cancelButtonColor: '#6b7280',
        confirmButtonText: '<i class="fas fa-trash-alt"></i> Sí, eliminar',
        cancelButtonText: 'Cancelar'
    }).then(r => {
        if (!r.isConfirmed) return;

        Swal.fire({ title: 'Eliminando...', allowOutsideClick: false, didOpen: () => Swal.showLoading() });

        // FIX: usar application/x-www-form-urlencoded
        const paramsEliminar = 'accion=eliminarModulos&usuarioId=' + encodeURIComponent(usuarioActual);

        fetch('ModuloServlet', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: paramsEliminar
        })
            .then(async response => {
                console.log('Response status:', response.status);
                const text = await response.text();
                console.log('Respuesta raw:', text);

                try {
                    return JSON.parse(text);
                } catch (e) {
                    console.error('No es JSON válido:', text.substring(0, 200));
                    throw new Error('El servidor devolvió HTML en lugar de JSON. Posible error interno.');
                }
            })
            .then(res => {
                console.log('Respuesta del servidor:', res);
                if (res.exito) {
                    actualizarBadgeTabla(usuarioActual, 0);
                    Swal.fire({
                        icon: 'success',
                        title: 'Eliminado',
                        text: res.mensaje,
                        timer: 2000,
                        showConfirmButton: false
                    });
                    const filaActual = document.querySelector(`.usuario-row[data-id="${usuarioActual}"]`);
                    if (filaActual) seleccionarUsuario(filaActual);
                } else {
                    Swal.fire({ icon: 'error', title: 'Error', text: res.mensaje });
                }
            })
            .catch(error => {
                console.error('Error completo:', error);
                Swal.fire({
                    icon: 'error',
                    title: 'Error',
                    text: 'No se pudieron eliminar los módulos. ' + error.message
                });
            });
    });
}

// =======================================================
//  ACTUALIZAR BADGE DE CONTADOR EN LA TABLA
// =======================================================
function actualizarBadgeTabla(usuarioId, cantidad) {
    const badge = document.querySelector(`.usuario-row[data-id="${usuarioId}"] .modulos-cnt`);
    if (!badge) return;
    badge.textContent = cantidad;
    badge.className = `modulos-cnt inline-flex items-center justify-center w-7 h-7 rounded-full text-xs font-bold ${
        cantidad > 0
          ? 'bg-purple-100 text-purple-700 dark:bg-purple-900/40 dark:text-purple-300'
          : 'bg-gray-100 text-gray-500 dark:bg-gray-700 dark:text-gray-400'
    }`;
}

// =======================================================
//  UTILIDAD: etiqueta de rol legible
// =======================================================
function etiquetaRol(rol) {
    const m = { docente:'Profesor', padre:'Padre de Familia', administrativo:'Administrativo' };
    return m[rol] || rol;
}
</script>
</body>
</html>
