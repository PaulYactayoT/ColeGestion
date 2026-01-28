package controlador;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/crossdomain.xml")
public class CrossDomainServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/xml");
        response.setCharacterEncoding("UTF-8");
        
        String xml = "<?xml version=\"1.0\"?>\n" +
                    "<!DOCTYPE cross-domain-policy SYSTEM \"http://www.adobe.com/xml/dtds/cross-domain-policy.dtd\">\n" +
                    "<cross-domain-policy>\n" +
                    "  <site-control permitted-cross-domain-policies=\"none\"/>\n" +
                    "  <allow-access-from domain=\"*\"/>\n" +
                    "  <allow-http-request-headers-from domain=\"*\" headers=\"*\"/>\n" +
                    "</cross-domain-policy>";
        
        response.getWriter().write(xml);
    }
}