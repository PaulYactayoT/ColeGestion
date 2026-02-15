<%-- 
    Document   : header
    Author     : Ocelot
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Verificar sesión
    if (session == null || session.getAttribute("usuario") == null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
    
    String usuarioHeader = (String) session.getAttribute("usuario");
    String rolHeader     = (String) session.getAttribute("rol");
    String fotoHeader    = (String) session.getAttribute("fotoUsuario");
    
    // Determinar si tiene foto válida
    boolean tieneFoto = fotoHeader != null && !fotoHeader.trim().isEmpty();
    String fotoUrl = tieneFoto ? request.getContextPath() + "/uploads/" + fotoHeader : "";
    
    // Inicial para el avatar de respaldo (cuando no hay foto)
    String inicialAvatar = (usuarioHeader != null && !usuarioHeader.isEmpty()) 
                           ? usuarioHeader.substring(0, 1).toUpperCase() 
                           : "U";
    
    // Obtener preferencia de tema de la cookie (si existe)
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
<!-- Header Superior -->
<header class="flex items-center justify-between bg-white dark:bg-[#1a2233] border-b border-[#f0f2f4] dark:border-gray-700 px-8 py-3 sticky top-0 z-10">
    <div class="flex items-center gap-4 flex-1">
        <div class="flex items-center gap-3">
            <h1 class="text-xl font-bold text-[#111318] dark:text-white">
                <%= request.getAttribute("pageTitle") != null ? request.getAttribute("pageTitle") : "San Antonio" %>
            </h1>
        </div>
    </div>
    
    <div class="flex items-center gap-4 ml-8">
        <!-- Botón de Tema Oscuro/Claro -->
        <button id="themeToggle" 
                class="p-2 text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg transition-colors"
                aria-label="Cambiar tema"
                onclick="toggleTheme()">
            <span id="themeIcon" class="material-symbols-outlined">
                <%= "dark".equals(theme) ? "dark_mode" : "light_mode" %>
            </span>
        </button>
        
        <button class="p-2 text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg relative"
                aria-label="Notificaciones">
            <span class="material-symbols-outlined">notifications</span>
            <span class="absolute top-2 right-2 size-2 bg-red-500 rounded-full border-2 border-white"></span>
        </button>
        
        <button class="p-2 text-[#616f89] hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg"
                aria-label="Configuración">
            <span class="material-symbols-outlined">settings</span>
        </button>
        
        <div class="h-8 w-[1px] bg-gray-200 dark:bg-gray-700 mx-2" aria-hidden="true"></div>
        
        <div class="flex items-center gap-3">
            <div class="text-right hidden md:block">
                <p class="text-sm font-medium text-[#111318] dark:text-white">
                    <%= usuarioHeader %>
                </p>
                <p class="text-xs text-[#616f89] dark:text-gray-400 capitalize">
                    <%= rolHeader != null ? rolHeader : "" %>
                </p>
            </div>
            
            <%-- Avatar: muestra foto si existe, o inicial si no --%>
            <% if (tieneFoto) { %>
                <%-- Con foto: imagen del usuario --%>
                <div class="size-10 rounded-full bg-cover bg-center border-2 border-primary/20 overflow-hidden"
                     aria-label="Foto de perfil de <%= usuarioHeader %>">
                    <img src="<%= fotoUrl %>" 
                         alt="Foto de <%= usuarioHeader %>"
                         style="width:100%; height:100%; object-fit:cover;"
                         onerror="this.parentElement.innerHTML='<span style=\'display:flex;align-items:center;justify-content:center;width:100%;height:100%;background:#2563eb;color:white;font-weight:700;font-size:1rem;\'><%= inicialAvatar %></span>'">
                </div>
            <% } else { %>
                <%-- Sin foto: mostrar inicial del usuario --%>
                <div class="size-10 rounded-full border-2 border-primary/20 bg-blue-600 
                            flex items-center justify-center text-white font-bold text-sm"
                     aria-label="Avatar de <%= usuarioHeader %>">
                    <%= inicialAvatar %>
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