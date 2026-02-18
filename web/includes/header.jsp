<%-- 
    Document   : header
    Author     : Ocelot
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="modelo.Padre, modelo.Alumno, modelo.AlumnoDAO, modelo.Usuario" %>
<%
    // Verificar sesión
    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
    
    String usuarioHeader = (String) session.getAttribute("usuario");
    String rolHeader     = (String) session.getAttribute("rol");
    String fotoHeader    = (String) session.getAttribute("fotoUsuario");
    
    // Variables para mostrar en el header
    String nombreMostrar = usuarioHeader;
    String subtituloMostrar = "";
    String fotoMostrar = fotoHeader;
    String inicialMostrar = usuarioHeader != null && !usuarioHeader.isEmpty() 
                           ? usuarioHeader.substring(0, 1).toUpperCase() 
                           : "U";
    
    // SI ES PADRE: Mostrar información del ALUMNO (hijo)
    if ("padre".equals(rolHeader)) {
        Padre padre = (Padre) session.getAttribute("padre");
        if (padre != null && padre.getAlumnoId() > 0) {
            // CORREGIDO: Usar getAlumnoNombre() que debe devolver "Milagros Candela"
            nombreMostrar = padre.getAlumnoNombre() != null ? padre.getAlumnoNombre() : "Sin alumno";
            subtituloMostrar = padre.getGradoNombre() != null ? padre.getGradoNombre() : "";
            
            // Obtener foto del alumno
            try {
                AlumnoDAO alumnoDAO = new AlumnoDAO();
                Alumno alumno = alumnoDAO.obtenerPorId(padre.getAlumnoId());
                if (alumno != null && alumno.getFoto() != null && !alumno.getFoto().isEmpty()) {
                    fotoMostrar = alumno.getFoto();
                    // CORREGIDO: Usar el nombre completo del alumno para la inicial
                    if (alumno.getNombreCompleto() != null && !alumno.getNombreCompleto().isEmpty()) {
                        inicialMostrar = alumno.getNombreCompleto().substring(0, 1).toUpperCase();
                    }
                }
            } catch (Exception e) {
                System.err.println("Error obteniendo foto del alumno: " + e.getMessage());
            }
        }
    } 
    // SI ES DOCENTE: Mostrar información del profesor
    else if ("docente".equals(rolHeader)) {
        nombreMostrar = usuarioHeader;
        subtituloMostrar = "Docente";
    }
    // SI ES ADMIN: Mostrar información del administrador
    else if ("admin".equals(rolHeader) || "administrativo".equals(rolHeader)) {
        nombreMostrar = usuarioHeader;
        subtituloMostrar = "Administrador";
    }
    
    // Determinar si tiene foto válida
    boolean tieneFoto = fotoMostrar != null && !fotoMostrar.trim().isEmpty();
    String fotoUrl = tieneFoto ? request.getContextPath() + "/uploads/" + fotoMostrar : "";
    
    // Obtener preferencia de tema de la cookie
    String theme = "light";
    Cookie[] cookies = request.getCookies();
    if (cookies != null) {
        for (Cookie cookie : cookies) {
            if ("theme".equals(cookie.getName())) {
                theme = cookie.getValue();
                break;
            }
        }
    }
%>
<!-- Header Superior - CON CLASES DARK CORRECTAS -->
<header class="flex items-center justify-between bg-white dark:bg-card-dark border-b border-border-light dark:border-border-dark px-8 py-3 sticky top-0 z-10 transition-colors duration-200">
    <div class="flex items-center gap-4 flex-1">
        <div class="flex items-center gap-3">
            <h1 class="text-xl font-bold text-slate-900 dark:text-white">
                <%= request.getAttribute("pageTitle") != null ? request.getAttribute("pageTitle") : "San Antonio" %>
            </h1>
        </div>
    </div>
    
    <div class="flex items-center gap-4 ml-8">
        <!-- Botón de Tema Oscuro/Claro -->
        <button id="themeToggle" 
                class="p-2 text-slate-500 dark:text-slate-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg transition-colors"
                aria-label="Cambiar tema"
                onclick="toggleTheme()">
            <span id="themeIcon" class="material-symbols-outlined">
                <%= "dark".equals(theme) ? "dark_mode" : "light_mode" %>
            </span>
        </button>
        
        <!-- Botón de notificaciones -->
        <button class="p-2 text-slate-500 dark:text-slate-400 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg relative"
                aria-label="Notificaciones">
            <span class="material-symbols-outlined">notifications</span>
            <span class="absolute top-2 right-2 size-2 bg-red-500 rounded-full border-2 border-white dark:border-card-dark"></span>
        </button>
        
        <!-- Separador -->
        <div class="h-8 w-[1px] bg-border-light dark:bg-border-dark mx-2" aria-hidden="true"></div>
        
        <!-- Información del ALUMNO (hijo) -->
        <div class="flex items-center gap-3">
            <div class="text-right hidden md:block">
                <p class="text-sm font-medium text-slate-900 dark:text-white">
                    <%= nombreMostrar %> <!-- Ahora debe ser "Milagros Candela" -->
                </p>
                <p class="text-xs text-slate-500 dark:text-slate-400">
                    <%= subtituloMostrar %> <!-- Aquí va el grado -->
                </p>
            </div>
            
            <%-- Avatar con foto o inicial del ALUMNO --%>
            <% if (tieneFoto) { %>
                <div class="size-10 rounded-full border-2 border-primary/20 overflow-hidden dark:border-primary/40">
                    <img src="<%= fotoUrl %>" 
                         alt="Foto de <%= nombreMostrar %>"
                         class="w-full h-full object-cover"
                         onerror="this.onerror=null; this.parentElement.innerHTML='<div class=\'w-full h-full bg-blue-600 flex items-center justify-center text-white font-bold text-sm\'><%= inicialMostrar %></div>';">
                </div>
            <% } else { %>
                <div class="size-10 rounded-full border-2 border-primary/20 bg-blue-600 
                            flex items-center justify-center text-white font-bold text-sm
                            dark:border-primary/40">
                    <%= inicialMostrar %> <!-- Inicial del alumno -->
                </div>
            <% } %>
        </div>
    </div>
</header>

<script>
// Función para cambiar el tema
function toggleTheme() {
    const html = document.documentElement;
    const themeIcon = document.getElementById('themeIcon');
    const isDark = html.classList.contains('dark');
    
    if (isDark) {
        html.classList.remove('dark');
        themeIcon.textContent = 'light_mode';
        setCookie('theme', 'light', 365);
    } else {
        html.classList.add('dark');
        themeIcon.textContent = 'dark_mode';
        setCookie('theme', 'dark', 365);
    }
}

// Función para establecer cookie
function setCookie(name, value, days) {
    const date = new Date();
    date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
    const expires = "expires=" + date.toUTCString();
    document.cookie = name + "=" + value + ";" + expires + ";path=/";
}

// Función para obtener cookie
function getCookie(name) {
    const cookieName = name + "=";
    const cookies = document.cookie.split(';');
    for(let i = 0; i < cookies.length; i++) {
        let cookie = cookies[i].trim();
        if (cookie.indexOf(cookieName) === 0) {
            return cookie.substring(cookieName.length, cookie.length);
        }
    }
    return "";
}

// Aplicar tema guardado al cargar la página
document.addEventListener('DOMContentLoaded', function() {
    const theme = getCookie('theme');
    const html = document.documentElement;
    const themeIcon = document.getElementById('themeIcon');
    
    if (theme === 'dark') {
        html.classList.add('dark');
        if (themeIcon) themeIcon.textContent = 'dark_mode';
    } else {
        html.classList.remove('dark');
        if (themeIcon) themeIcon.textContent = 'light_mode';
    }
});
</script>