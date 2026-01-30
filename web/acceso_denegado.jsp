<%-- 
    Document   : acceso_denegado
    Created on : 20 oct. 2025, 2:57:41 p. m.
    Author     : milag
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>ACCESO DENEGADO</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Orbitron:wght@900&family=Rajdhani:wght@700&display=swap');
        
        body {
            background: #000000;
            margin: 0;
            padding: 0;
            overflow: hidden;
            color: #ff0000;
            font-family: 'Rajdhani', sans-serif;
        }
        
        .container {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            text-align: center;
            text-shadow: 0 0 10px #ff0000, 0 0 20px #ff0000;
        }
        
        h1 {
            font-family: 'Orbitron', sans-serif;
            font-size: 4em;
            margin: 0;
            animation: glitch 1s infinite;
            letter-spacing: 5px;
        }
        
        .warning {
            font-size: 2em;
            margin: 20px 0;
            color: #ffffff;
            text-shadow: 0 0 10px #ffffff;
        }
        
        .message {
            font-size: 1.5em;
            border: 2px solid #ff0000;
            padding: 15px;
            margin: 30px auto;
            width: 60%;
            background: rgba(255, 0, 0, 0.1);
            box-shadow: 0 0 30px rgba(255, 0, 0, 0.5);
        }
        
        .flashing {
            animation: flash 0.5s infinite alternate;
        }
        
        .security-notice {
            position: absolute;
            bottom: 20px;
            width: 100%;
            font-size: 1.2em;
            color: #cccccc;
        }
        
        @keyframes glitch {
            0% { transform: translate(0); }
            20% { transform: translate(-2px, 2px); }
            40% { transform: translate(-2px, -2px); }
            60% { transform: translate(2px, 2px); }
            80% { transform: translate(2px, -2px); }
            100% { transform: translate(0); }
        }
        
        @keyframes flash {
            from { opacity: 1; }
            to { opacity: 0.3; }
        }
        
        .scan-line {
            position: absolute;
            width: 100%;
            height: 2px;
            background: #00ff00;
            top: 0;
            animation: scan 3s linear infinite;
            box-shadow: 0 0 10px #00ff00;
        }
        
        @keyframes scan {
            0% { top: 0%; }
            100% { top: 100%; }
        }
        
        .access-code {
            font-family: monospace;
            background: #000;
            padding: 10px;
            margin: 10px;
            border: 1px solid #ff0000;
            color: #00ff00;
        }
    </style>
</head>
<body>
    <div class="scan-line"></div>
    
    <div class="container">
        <h1>⛔ ACCESO DENEGADO ⛔</h1>
        
        <div class="warning flashing">
            ¡ALTO! ZONA RESTRINGIDA
        </div>
        
        <div class="message">
            SU ACCESO HA SIDO BLOQUEADO POR RAZONES DE SEGURIDAD
        </div>
        
        <div class="access-code">
            CÓDIGO DE INCIDENTE: ERR-ACCESS-7842
        </div>
        
        <div class="message">
            SU ACTIVIDAD HA SIDO REGISTRADA Y REPORTADA
        </div>
        
        <div class="security-notice">
            🔒 SISTEMA DE SEGURIDAD ACTIVADO - PROTOCOLO 7 🔒
        </div>
    </div>
    
    <script>
        // Efecto de parpadeo aleatorio
        setInterval(() => {
            document.body.style.background = Math.random() > 0.9 ? '#1a0000' : '#000000';
        }, 100);
        
        // Efecto de sonido (comentado para no molestar)
        // var audio = new Audio('https://assets.mixkit.co/sfx/preview/mixkit-alarm-digital-clock-beep-989.mp3');
        // audio.loop = true;
        // audio.play();
    </script>
</body>
</html>