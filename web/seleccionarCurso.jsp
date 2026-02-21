<%-- 
    Document   : seleccionarCurso
    Author     : milag
--%>
<%@page import="modelo.Curso"%>
<%@page import="java.util.List"%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    List<Curso> cursos = (List<Curso>) request.getAttribute("cursos");
    String moduloDestino = (String) request.getAttribute("moduloDestino");
    String moduloNombre  = (String) request.getAttribute("moduloNombre");
    String moduloAccion  = (String) request.getAttribute("moduloAccion");
    if (moduloDestino == null) moduloDestino = "";
    if (moduloNombre  == null) moduloNombre  = "Módulo";
    if (moduloAccion  == null) moduloAccion  = "listar";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <%@ include file="includes/head.jsp" %>
    <title>Seleccionar Curso - <%= moduloNombre %></title>
    <style>
        .curso-card {
            background: white;
            border: 1px solid #e5e7eb;
            border-radius: 0.75rem;
            padding: 1.75rem 2rem;
            display: flex;
            align-items: center;
            gap: 1.25rem;
            text-decoration: none;
            transition: all 0.2s;
            color: #1f2937;
        }
        .dark .curso-card {
            background: #1a2233;
            border-color: #374151;
            color: #f3f4f6;
        }
        .curso-card:hover {
            border-color: #0d6efd;
            box-shadow: 0 4px 12px rgba(13, 110, 253, 0.15);
            transform: translateY(-2px);
        }
        .curso-icon {
            background: linear-gradient(135deg, #0d6efd, #6366f1);
            color: white;
            width: 2.75rem;
            height: 2.75rem;
            border-radius: 0.6rem;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }
        .curso-nivel {
            font-size: 0.7rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            padding: 0.2rem 0.6rem;
            border-radius: 9999px;
            background: #eff6ff;
            color: #1d4ed8;
        }
        .dark .curso-nivel {
            background: #1e3a5f;
            color: #93c5fd;
        }
    </style>
</head>
<body class="bg-background-light dark:bg-background-dark text-[#111318] dark:text-white min-h-screen flex flex-col">

    <div class="flex flex-1 h-screen overflow-hidden">
        <%@ include file="includes/sidebarDocente.jsp" %>

        <main class="flex-1 flex flex-col overflow-y-auto">
            <% request.setAttribute("pageTitle", "Seleccionar Curso - " + moduloNombre); %>
            <jsp:include page="includes/header.jsp" />

            <div class="p-8 max-w-4xl mx-auto w-full">

                <!-- Encabezado -->
                <div class="bg-gradient-to-r from-primary to-blue-600 rounded-xl p-8 mb-8 text-white shadow-lg">
                    <div class="flex items-center gap-5">
                        <div class="bg-white/20 rounded-lg p-4">
                            <i class="fas fa-book-open text-4xl"></i>
                        </div>
                        <div>
                            <h2 class="text-3xl font-bold">Seleccionar Curso</h2>
                            <p class="text-blue-100 mt-1 text-lg">Elige un curso para acceder a <strong><%= moduloNombre %></strong></p>
                        </div>
                    </div>
                </div>

                <!-- Lista de cursos -->
                <% if (cursos == null || cursos.isEmpty()) { %>
                    <div class="text-center py-16 text-gray-400">
                        <i class="fas fa-inbox text-5xl mb-4 opacity-30"></i>
                        <p class="text-lg font-medium">No tienes cursos asignados</p>
                        <p class="text-sm mt-1">Contacta al administrador</p>
                    </div>
                <% } else { %>
                    <div class="flex flex-col gap-4">
                        <% for (Curso c : cursos) { %>
                            <a href="<%= request.getContextPath() %>/<%= moduloDestino %>?accion=<%= moduloAccion %>&curso_id=<%= c.getId() %>"
                               class="curso-card">
                                <div class="curso-icon" style="width:3.5rem; height:3.5rem;">
                                    <i class="fas fa-chalkboard text-xl"></i>
                                </div>
                                <div class="flex-1">
                                    <div class="flex items-center gap-3 mb-2">
                                        <span class="font-bold text-xl"><%= c.getNombre() %></span>
                                        <% if (c.getNivel() != null) { %>
                                            <span class="curso-nivel text-sm"><%= c.getNivel() %></span>
                                        <% } %>
                                    </div>
                                    <p class="text-base text-gray-500 dark:text-gray-400">
                                        <i class="fas fa-graduation-cap mr-1"></i>
                                        <%= c.getGradoNombre() != null ? c.getGradoNombre() : "Sin grado" %>
                                    </p>
                                </div>
                                <i class="fas fa-chevron-right text-gray-400 text-xl"></i>
                            </a>
                        <% } %>
                    </div>
                <% } %>

            </div>
        </main>
    </div>

</body>
</html>
