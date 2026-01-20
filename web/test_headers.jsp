<%-- test_headers.jsp --%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Test de Headers de Seguridad</title>
    <script>
        function checkHeaders() {
            fetch(window.location.href, { method: 'HEAD' })
                .then(response => {
                    const headers = {};
                    response.headers.forEach((value, key) => {
                        headers[key] = value;
                    });
                    
                    document.getElementById('headersOutput').innerHTML = 
                        JSON.stringify(headers, null, 2);
                })
                .catch(error => {
                    document.getElementById('headersOutput').innerHTML = 
                        'Error: ' + error.message;
                });
        }
        
        function checkCSP() {
            const csp = document.querySelector('meta[http-equiv="Content-Security-Policy"]') ||
                       document.querySelector('meta[http-equiv="content-security-policy"]');
            
            if (csp) {
                document.getElementById('cspOutput').innerHTML = 
                    'CSP en meta tag: ' + csp.getAttribute('content');
            } else {
                document.getElementById('cspOutput').innerHTML = 
                    'No se encontró CSP en meta tag';
            }
        }
        
        window.onload = function() {
            checkHeaders();
            checkCSP();
        };
    </script>
</head>
<body>
    <h1>Test de Headers de Seguridad</h1>
    
    <h2>Headers HTTP:</h2>
    <pre id="headersOutput">Cargando...</pre>
    
    <h2>CSP:</h2>
    <pre id="cspOutput">Cargando...</pre>
    
    <button onclick="checkHeaders()">Refrescar Headers</button>
    <button onclick="checkCSP()">Refrescar CSP</button>
    
    <h3>Pruebas de Seguridad:</h3>
    <ul>
        <li><a href="javascript:alert('XSS test')">Prueba XSS 1</a></li>
        <li><a href="#" onclick="alert('XSS test 2')">Prueba XSS 2</a></li>
        <li><iframe src="about:blank" width="300" height="200">Prueba Clickjacking</iframe></li>
    </ul>
</body>
</html>