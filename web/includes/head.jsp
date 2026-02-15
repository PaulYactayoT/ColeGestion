<%-- 
    Document   : head
    Created on : 15 feb. 2026, 8:59:47 a. m.
    Author     : Mila
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- Tailwind CSS -->
<script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>

<!-- Google Fonts -->
<link href="https://fonts.googleapis.com/css2?family=Lexend:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet">

<!-- Font Awesome -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

<!-- Tailwind Config -->
<script id="tailwind-config">
    tailwind.config = {
        darkMode: "class",  // Esto es importante: usa la clase 'dark' en el HTML
        theme: {
            extend: {
                colors: {
                    "primary": "#135bec",
                    "primary-dark": "#0d47a1",
                    "success": "#10b981",
                    "danger": "#ef4444",
                    "warning": "#f59e0b",
                    "info": "#3b82f6",
                    "background-light": "#f6f6f8",
                    "background-dark": "#101622",
                    "card-light": "#ffffff",
                    "card-dark": "#1a2233",
                    "border-light": "#e5e7eb",
                    "border-dark": "#374151",
                    "baby-blue": "#89CFF0",
                },
                fontFamily: {
                    "display": ["Lexend"]
                },
                borderRadius: {
                    "DEFAULT": "0.25rem", 
                    "lg": "0.5rem", 
                    "xl": "0.75rem", 
                    "full": "9999px"
                },
            },
        },
    }
</script>

<!-- Estilos Globales -->
<style>
    body {
        font-family: 'Lexend', sans-serif;
    }
    
    .material-symbols-outlined {
        font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
    }
    
    /* Alertas */
    .alert-modern {
        border-radius: 0.5rem;
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
    
    .alert-info {
        background: linear-gradient(135deg, #dbeafe, #bfdbfe);
        color: #1e40af;
        border-left-color: #3b82f6;
    }
    
    /* Versiones oscuras de alertas */
    .dark .alert-danger {
        background: linear-gradient(135deg, #7f1d1d, #991b1b);
        color: #fecaca;
    }
    
    .dark .alert-success {
        background: linear-gradient(135deg, #064e3b, #065f46);
        color: #d1fae5;
    }
    
    .dark .alert-info {
        background: linear-gradient(135deg, #1e3a8a, #1e40af);
        color: #dbeafe;
    }
    
    /* Botones */
    .btn-modern {
        padding: 0.75rem 1.5rem;
        border-radius: 0.5rem;
        font-weight: 600;
        font-size: 0.95rem;
        border: none;
        transition: all 0.3s ease;
        display: inline-flex;
        align-items: center;
        gap: 0.5rem;
        cursor: pointer;
        text-decoration: none;
    }
    
    .btn-primary-modern {
        background: linear-gradient(135deg, #135bec, #0d47a1);
        color: white;
    }
    
    .btn-primary-modern:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 15px rgba(19, 91, 236, 0.3);
    }
    
    .btn-secondary-modern {
        background: #6b7280;
        color: white;
    }
    
    .btn-secondary-modern:hover {
        background: #4b5563;
        transform: translateY(-2px);
    }
    
    /* Animaciones */
    @keyframes fadeInUp {
        from {
            opacity: 0;
            transform: translateY(30px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
</style>