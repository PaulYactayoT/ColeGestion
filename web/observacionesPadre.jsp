<%-- 
    Document   : observacionesPadre
    Created on : 20 feb. 2026
    Author     : Ocelot
--%>

<%@page import="modelo.Observacion"%>
<%@page import="java.util.List"%>
<%
    List<Observacion> observaciones = (List<Observacion>) request.getAttribute("observaciones");
    
    String mensaje = (String) session.getAttribute("mensaje");
    String error   = (String) session.getAttribute("error");
    
    if (mensaje != null) session.removeAttribute("mensaje");
    if (error   != null) session.removeAttribute("error");
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <%@ include file="includes/head.jsp" %>
    <title>Observaciones de mi Hijo</title>
    <style>
        /* ============================================================
           LAYOUT
           El sidebar usa: position fixed, w-64 (= 256px), h-full, z-20
           Por eso el main y el header deben arrancar desde 256px
        ============================================================ */
        html, body {
            margin: 0;
            padding: 0;
            height: 100%;
        }

        .main-content {
            margin-left: 256px;   /* w-64 de Tailwind = 256px */
            min-height: 100vh;
            background-color: #f9fafb;
            display: flex;
            flex-direction: column;
        }

        .dark .main-content {
            background-color: #111827;
        }

        .content-area {
            padding: 2rem;
            flex: 1;
        }

        /* ============================================================
           CARD SUPERIOR
        ============================================================ */
        .header-card {
            background: linear-gradient(135deg, #1d4ed8 0%, #1e3a8a 100%);
            border-radius: 0.875rem;
            padding: 1.5rem 2rem;
            margin-bottom: 1.5rem;
            color: white;
            box-shadow: 0 4px 20px rgba(29, 78, 216, 0.35);
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 1rem;
            flex-wrap: wrap;
        }

        .header-card h2 {
            font-size: 1.5rem;
            font-weight: 700;
            margin: 0 0 4px 0;
        }

        .header-card p {
            color: #bfdbfe;
            margin: 0;
            font-size: 0.875rem;
        }

        .total-pill {
            background: rgba(255, 255, 255, 0.2);
            backdrop-filter: blur(8px);
            border-radius: 0.875rem;
            padding: 0.75rem 2rem;
            text-align: center;
            flex-shrink: 0;
        }

        .total-pill .label {
            font-size: 0.7rem;
            text-transform: uppercase;
            letter-spacing: 0.12em;
            display: block;
            opacity: 0.85;
        }

        .total-pill .number {
            font-size: 2.25rem;
            font-weight: 800;
            line-height: 1;
        }

        /* ============================================================
           BOTÓN REGRESAR
        ============================================================ */
        .btn-back {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background-color: white;
            color: #6b7280;
            border: 1px solid #e5e7eb;
            padding: 8px 18px;
            border-radius: 8px;
            font-weight: 500;
            font-size: 14px;
            text-decoration: none;
            transition: all 0.2s;
            margin-bottom: 1.25rem;
        }

        .btn-back:hover {
            background-color: #f3f4f6;
            color: #374151;
        }

        .dark .btn-back {
            background-color: #283044;
            color: #e5e7eb;
            border-color: #4b5563;
        }

        /* ============================================================
           TABLA
        ============================================================ */
        .table-container {
            background: white;
            border-radius: 0.75rem;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
            border: 1px solid #e5e7eb;
            overflow: hidden;
        }

        .dark .table-container {
            background: #1a2233;
            border-color: #374151;
        }

        .custom-table {
            width: 100%;
            border-collapse: collapse;
            table-layout: fixed;
        }

        .col-curso     { width: 20%; }
        .col-tipo      { width: 16%; }
        .col-obs       { width: 42%; }
        .col-evidencia { width: 22%; }

        .custom-table thead th {
            background-color: #0b4eb8;
            color: white;
            font-weight: 600;
            padding: 14px 20px;
            text-align: left;
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 0.06em;
        }

        .dark .custom-table thead th {
            background-color: #1e3a8a;
        }

        .custom-table tbody td {
            padding: 14px 20px;
            border-bottom: 1px solid #f0f0f0;
            color: #374151;
            vertical-align: middle;
            font-size: 14px;
            word-wrap: break-word;
        }

        .dark .custom-table tbody td {
            border-bottom-color: #2d3748;
            color: #e2e8f0;
        }

        .custom-table tbody tr:last-child td {
            border-bottom: none;
        }

        .custom-table tbody tr:hover {
            background-color: #f5f8ff;
        }

        .dark .custom-table tbody tr:hover {
            background-color: #22304a;
        }

        /* ============================================================
           BADGES
        ============================================================ */
        .badge {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 5px 12px;
            border-radius: 99px;
            font-weight: 700;
            font-size: 12px;
            white-space: nowrap;
        }

        .badge-positiva { background: #10b981; color: white; }
        .badge-negativa { background: #ef4444; color: white; }
        .badge-neutral  { background: #6b7280; color: white; }

        /* ============================================================
           OBSERVACIÓN
        ============================================================ */
        .obs-text {
            font-size: 14px;
            color: #374151;
            margin-bottom: 4px;
        }

        .dark .obs-text { color: #e2e8f0; }

        .obs-meta {
            font-size: 11px;
            color: #9ca3af;
            display: flex;
            align-items: center;
            gap: 4px;
        }

        /* ============================================================
           BOTÓN EVIDENCIA
        ============================================================ */
        .btn-evidencia {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background-color: #e0eaff;
            color: #1d4ed8;
            padding: 7px 14px;
            border-radius: 6px;
            font-size: 13px;
            font-weight: 500;
            text-decoration: none;
            transition: all 0.2s;
            white-space: nowrap;
        }

        .btn-evidencia:hover {
            background-color: #1d4ed8;
            color: white;
        }

        .sin-evidencia {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            color: #9ca3af;
            font-size: 13px;
        }

        /* ============================================================
           ESTADO VACÍO
        ============================================================ */
        .empty-state {
            padding: 60px 20px;
            text-align: center;
        }

        .empty-state i {
            font-size: 2.5rem;
            color: #d1d5db;
            display: block;
            margin-bottom: 12px;
        }

        .empty-state .title {
            font-size: 1rem;
            font-weight: 600;
            color: #6b7280;
            margin-bottom: 4px;
        }

        .empty-state .subtitle {
            font-size: 0.875rem;
            color: #9ca3af;
        }

        /* ============================================================
           CAJA INFORMATIVA
        ============================================================ */
        .info-box {
            margin-top: 1.5rem;
            padding: 1rem 1.25rem;
            background-color: #eff6ff;
            border: 1px solid #bfdbfe;
            border-radius: 0.75rem;
            display: flex;
            gap: 12px;
            align-items: flex-start;
        }

        .dark .info-box {
            background-color: rgba(30, 58, 138, 0.15);
            border-color: #1e40af;
        }

        .info-box-icon {
            color: #3b82f6;
            font-size: 1.1rem;
            margin-top: 2px;
            flex-shrink: 0;
        }

        .info-box h4 {
            font-size: 0.9rem;
            font-weight: 600;
            color: #1e40af;
            margin: 0 0 8px 0;
        }

        .dark .info-box h4 { color: #93c5fd; }

        .info-box ul {
            list-style: none;
            padding: 0;
            margin: 0;
            display: flex;
            flex-direction: column;
            gap: 6px;
        }

        .info-box li {
            font-size: 0.8rem;
            color: #1d4ed8;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .dark .info-box li { color: #93c5fd; }

        .mini-badge {
            display: inline-block;
            padding: 2px 10px;
            border-radius: 99px;
            font-size: 10px;
            font-weight: 700;
            color: white;
            flex-shrink: 0;
        }

        /* ============================================================
           ALERTAS
        ============================================================ */
        .alert {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 12px 16px;
            border-radius: 8px;
            margin-bottom: 1rem;
            font-size: 14px;
        }

        .alert-success {
            background-color: #d1fae5;
            border: 1px solid #6ee7b7;
            color: #065f46;
        }

        .alert-error {
            background-color: #fee2e2;
            border: 1px solid #fca5a5;
            color: #991b1b;
        }
    </style>
</head>
<body class="bg-gray-50 dark:bg-gray-900 text-gray-900 dark:text-white">

    <%-- Sidebar (position:fixed, 256px de ancho) --%>
    <%@ include file="includes/sidebarPadre.jsp" %>

    <%-- Main: empieza en 256px para no quedar detrás del sidebar --%>
    <main class="main-content">

        <%-- Header sticky (ocupa todo el ancho del main, ya desplazado) --%>
        <% request.setAttribute("pageTitle", "Observaciones de mi Hijo"); %>
        <jsp:include page="includes/header.jsp" />

        <div class="content-area">

            <%-- Alertas --%>
            <% if (mensaje != null) { %>
            <div class="alert alert-success" role="alert">
                <i class="fas fa-check-circle"></i>
                <span><%= mensaje %></span>
            </div>
            <% } %>

            <% if (error != null) { %>
            <div class="alert alert-error" role="alert">
                <i class="fas fa-exclamation-circle"></i>
                <span><%= error %></span>
            </div>
            <% } %>

            <%-- Card superior --%>
            <div class="header-card">
                <div>
                    <h2>Historial de Observaciones</h2>
                    <p>
                        <i class="fas fa-child mr-1"></i>
                        Consulte el registro de conducta y desempeño de su menor hijo.
                    </p>
                </div>
                <div class="total-pill">
                    <span class="label">Total</span>
                    <span class="number"><%= observaciones != null ? observaciones.size() : 0 %></span>
                </div>
            </div>

            <%-- Tabla --%>
            <div class="table-container">
                <div style="overflow-x: auto;">
                    <table class="custom-table">
                        <thead>
                            <tr>
                                <th class="col-curso">Curso</th>
                                <th class="col-tipo">Tipo</th>
                                <th class="col-obs">Observación</th>
                                <th class="col-evidencia">Evidencia</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (observaciones != null && !observaciones.isEmpty()) {
                                    for (Observacion o : observaciones) {
                                        String badgeClass = "badge ";
                                        String icon = "";

                                        String tipo = o.getTipo() != null ? o.getTipo() : "";
                                        if ("POSITIVA".equals(tipo)) {
                                            badgeClass += "badge-positiva";
                                            icon = "fa-smile";
                                        } else if ("NEGATIVA".equals(tipo)) {
                                            badgeClass += "badge-negativa";
                                            icon = "fa-frown";
                                        } else {
                                            badgeClass += "badge-neutral";
                                            icon = "fa-meh";
                                        }
                            %>
                            <tr>
                                <td class="col-curso">
                                    <strong><%= o.getCursoNombre() != null ? o.getCursoNombre() : "?" %></strong>
                                </td>
                                <td class="col-tipo">
                                    <span class="<%= badgeClass %>">
                                        <i class="fas <%= icon %>"></i>
                                        <%= tipo %>
                                    </span>
                                </td>
                                <td class="col-obs">
                                    <div class="obs-text"><%= o.getTexto() %></div>
                                    <div class="obs-meta">
                                        <i class="far fa-calendar-alt"></i> Registro Oficial
                                    </div>
                                </td>
                                <td class="col-evidencia">
                                    <% if (o.getRutaEvidencia() != null && !o.getRutaEvidencia().isEmpty()) { %>
                                        <a href="assets/evidencias/<%= o.getRutaEvidencia() %>"
                                           target="_blank" class="btn-evidencia">
                                            <i class="fas fa-paperclip"></i> Ver Evidencia
                                        </a>
                                    <% } else { %>
                                        <span class="sin-evidencia">
                                            <i class="fas fa-paperclip"></i> Sin archivo
                                        </span>
                                    <% } %>
                                </td>
                            </tr>
                            <%
                                    }
                                } else {
                            %>
                            <tr>
                                <td colspan="4">
                                    <div class="empty-state">
                                        <i class="fas fa-comment-slash"></i>
                                        <div class="title">No hay observaciones registradas</div>
                                        <div class="subtitle">No se han registrado observaciones para su hijo hasta el momento.</div>
                                    </div>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <%-- Caja informativa --%>
            <div class="info-box">
                <i class="fas fa-info-circle info-box-icon"></i>
                <div>
                    <h4>Información importante:</h4>
                    <ul>
                        <li>
                            <span class="mini-badge" style="background:#10b981;">POSITIVAS</span>
                            Destacan logros y buen comportamiento.
                        </li>
                        <li>
                            <span class="mini-badge" style="background:#ef4444;">NEGATIVAS</span>
                            Indican áreas de mejora o incidentes.
                        </li>
                        <li>
                            <span class="mini-badge" style="background:#6b7280;">NEUTRALES</span>
                            Son de carácter informativo.
                        </li>
                        <li>
                            <i class="fas fa-lock" style="color:#3b82f6; font-size:12px;"></i>
                            Las observaciones son visibles solo para los padres del alumno.
                        </li>
                    </ul>
                </div>
            </div>

        </div><%-- /content-area --%>
    </main>

    <script>
        // Auto-ocultar alertas tras 5 segundos
        setTimeout(function () {
            document.querySelectorAll('[role="alert"]').forEach(function (el) {
                el.style.transition = 'opacity 0.5s';
                el.style.opacity = '0';
                setTimeout(function () { el.remove(); }, 500);
            });
        }, 5000);
    </script>
</body>
</html>
