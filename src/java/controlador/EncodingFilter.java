package controlador;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebFilter("/*")
public class EncodingFilter implements Filter {
    
    private static final String ENCODING = "UTF-8";
    
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        System.out.println("Filtro UTF-8 inicializado");
    }
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        
        // Configurar codificación para request y response
        httpRequest.setCharacterEncoding(ENCODING);
        httpResponse.setCharacterEncoding(ENCODING);
        
        // Continuar con la cadena de filtros
        chain.doFilter(request, response);
    }
    
    @Override
    public void destroy() {
        System.out.println("Filtro UTF-8 destruido");
    }
}