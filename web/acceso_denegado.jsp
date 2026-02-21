<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Acceso Denegado - San Antonio</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap');

        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Poppins', sans-serif;
            background: #ffffff;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
        }

        .container {
            text-align: center;
            max-width: 500px;
            width: 90%;
            padding: 20px;
        }

        .icon-wrap {
            width: 90px;
            height: 90px;
            background: #eff6ff;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 28px;
        }

        .icon-wrap i {
            font-size: 36px;
            color: #3b82f6;
        }

        h1 {
            font-size: 1.8em;
            font-weight: 700;
            color: #0f172a;
            margin-bottom: 12px;
        }

        .desc {
            font-size: 0.95em;
            color: #64748b;
            line-height: 1.7;
            margin-bottom: 32px;
        }

        .divider {
            width: 50px;
            height: 3px;
            background: #3b82f6;
            border-radius: 10px;
            margin: 0 auto 32px;
        }

        .alert {
            background: #fffbeb;
            border-left: 4px solid #f59e0b;
            border-radius: 8px;
            padding: 16px 20px;
            text-align: left;
            margin-bottom: 36px;
        }

        .alert p {
            font-size: 0.85em;
            color: #78350f;
            line-height: 1.6;
        }

        .alert strong {
            display: block;
            color: #92400e;
            font-size: 0.9em;
            margin-bottom: 4px;
        }

        .btn-primary {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 13px 36px;
            border-radius: 8px;
            font-size: 0.95em;
            font-weight: 600;
            text-decoration: none;
            background: #3b82f6;
            color: white;
            transition: background 0.2s;
        }

        .btn-primary:hover {
            background: #2563eb;
        }

        .footer {
            margin-top: 48px;
            font-size: 0.78em;
            color: #cbd5e1;
        }
    </style>
</head>
<body>

    <div class="container">

        <div class="icon-wrap">
            <i class="fas fa-lock"></i>
        </div>

        <h1>Acceso Denegado</h1>
        <div class="divider"></div>

        <p class="desc">
            No tienes permiso para acceder a esta sección.<br>
            Es posible que no hayas iniciado sesión o que tu rol no tenga acceso aquí.
        </p>

        <div class="alert">
            <strong><i class="fas fa-exclamation-triangle" style="color:#f59e0b; margin-right:6px;"></i> ¿Por qué veo esto?</strong>
            <p>Solo los usuarios con el rol correspondiente pueden ingresar a esta sección. Si crees que es un error, comunícate con el administrador del colegio.</p>
        </div>

        <a href="javascript:history.back()" class="btn-primary">
            <i class="fas fa-arrow-left"></i> Volver atrás
        </a>

        <p class="footer">© 2025 Colegio San Antonio · Sistema Escolar</p>

    </div>

</body>
</html>
