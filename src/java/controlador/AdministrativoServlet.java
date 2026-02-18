/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controlador;

import modelo.AdministrativoDAO;
import modelo.Administrativo;
import modelo.MasterTableDAO;
import modelo.MasterTableDAO.CatalogoItem;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.File;
import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;

/**
 * AdministrativoServlet - Controlador para gestión de personal administrativo
 * Soporta BORRADO LÓGICO: al eliminar solo marca como eliminado=1
 */
@WebServlet("/AdministrativoServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 10,        // 10MB
    maxRequestSize = 1024 * 1024 * 50      // 50MB
)
public class AdministrativoServlet extends HttpServlet {

    private AdministrativoDAO dao;
    private MasterTableDAO masterDao;

    @Override
    public void init() throws ServletException {
        dao = new AdministrativoDAO();
        masterDao = new MasterTableDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        // VALIDACION DE ROL: Solo admin puede gestionar personal administrativo
        String rol = (String) session.getAttribute("rol");
        if (!"admin".equals(rol)) {
            System.out.println("ACCESO DENEGADO (GET): Rol '" + rol + "' intentó acceder a AdministrativoServlet");
            response.sendRedirect("acceso_denegado.jsp");
            return;
        }

        String action = request.getParameter("action");

        try {
            if (action == null) {
                listar(request, response);
            } else {
                switch (action) {
                    case "editar":
                        mostrarFormularioEditar(request, response);
                        break;
                    case "nuevo":
                        mostrarFormularioNuevo(request, response);
                        break;
                    case "eliminar":
                        eliminar(request, response);  // BORRADO LÓGICO
                        break;
                    case "restaurar":
                        restaurar(request, response);
                        break;
                    case "buscar":
                        buscar(request, response);
                        break;
                    case "ver":  
                        mostrarDetalles(request, response);
                        break;
                    default:
                        listar(request, response);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.getSession().setAttribute("error", "Error en base de datos: " + e.getMessage());
            response.sendRedirect("AdministrativoServlet");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        // VALIDACION DE ROL: Solo admin puede gestionar personal administrativo
        String rol = (String) session.getAttribute("rol");
        if (!"admin".equals(rol)) {
            System.out.println("ACCESO DENEGADO (POST): Rol '" + rol + "' intentó acceder a AdministrativoServlet");
            response.sendRedirect("acceso_denegado.jsp");
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String idStr = request.getParameter("id");

        try {
            if (idStr == null || idStr.trim().isEmpty()) {
                insertar(request, response);  // NUEVO REGISTRO
            } else {
                actualizar(request, response);  // ACTUALIZAR EXISTENTE
            }
        } catch (SQLException e) {
            e.printStackTrace();
            session.setAttribute("error", "Error al guardar: " + e.getMessage());
            response.sendRedirect("AdministrativoServlet");
        }
    }

    /**
     * LISTAR administrativos NO eliminados
     */
    private void listar(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        List<Administrativo> lista = dao.listar();  // Solo trae eliminado=0
        request.setAttribute("administrativos", lista);
        request.getRequestDispatcher("administrativoList.jsp").forward(request, response);
    }

    /**
     * BUSCAR administrativos por término
     */
    private void buscar(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        String termino = request.getParameter("q");
        List<Administrativo> lista = dao.buscar(termino);
        request.setAttribute("administrativos", lista);
        request.setAttribute("terminoBusqueda", termino);
        request.getRequestDispatcher("administrativoList.jsp").forward(request, response);
    }

    /**
     * MOSTRAR formulario para nuevo administrativo
     */
    private void mostrarFormularioNuevo(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // Cargar catálogos desde master_table
            List<CatalogoItem> tiposDocumento = masterDao.obtenerCatalogo("TIPO_DOCUMENTO");
            List<CatalogoItem> sexos = masterDao.obtenerCatalogo("SEXO");
            
            request.setAttribute("tiposDocumento", tiposDocumento);
            request.setAttribute("sexos", sexos);
            
        } catch (SQLException e) {
            e.printStackTrace();
            request.getSession().setAttribute("error", "Error al cargar catálogos: " + e.getMessage());
        }
        
        request.getRequestDispatcher("administrativoForm.jsp").forward(request, response);
    }

    /**
     * MOSTRAR formulario de edición con datos cargados
     */
    private void mostrarFormularioEditar(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {

        int id = Integer.parseInt(request.getParameter("id"));
        Administrativo admin = dao.obtenerPorId(id);

        if (admin != null) {
            try {
                // Cargar catálogos desde master_table
                List<CatalogoItem> tiposDocumento = masterDao.obtenerCatalogo("TIPO_DOCUMENTO");
                List<CatalogoItem> sexos = masterDao.obtenerCatalogo("SEXO");
                
                request.setAttribute("tiposDocumento", tiposDocumento);
                request.setAttribute("sexos", sexos);
                
            } catch (SQLException e) {
                e.printStackTrace();
                request.getSession().setAttribute("error", "Error al cargar catálogos: " + e.getMessage());
            }
            
            request.setAttribute("administrativo", admin);
            request.getRequestDispatcher("administrativoForm.jsp").forward(request, response);
        } else {
            request.getSession().setAttribute("error", "Administrativo no encontrado");
            response.sendRedirect("AdministrativoServlet");
        }
    }

    /**
     * INSERTAR nuevo administrativo
     */
    private void insertar(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException, ServletException {

        Administrativo admin = new Administrativo();
        HttpSession session = request.getSession();

        try {
            // DATOS PERSONALES
            admin.setNombres(request.getParameter("nombres"));
            admin.setApellidos(request.getParameter("apellidos"));
            admin.setTipoDocumento(request.getParameter("tipo_documento"));
            admin.setNumeroDocumento(request.getParameter("numero_documento"));
            admin.setSexo(request.getParameter("sexo"));

            String fechaNacStr = request.getParameter("fecha_nacimiento");
            if (fechaNacStr != null && !fechaNacStr.isEmpty()) {
                admin.setFechaNacimiento(LocalDate.parse(fechaNacStr));
            }

            admin.setDireccion(request.getParameter("direccion"));
            admin.setTelefono(request.getParameter("telefono"));
            admin.setCorreo(request.getParameter("correo"));

            // DATOS LABORALES
            admin.setCargo(request.getParameter("cargo"));
            admin.setDepartamento(request.getParameter("departamento"));

            String fechaIngresoStr = request.getParameter("fecha_ingreso");
            if (fechaIngresoStr != null && !fechaIngresoStr.isEmpty()) {
                admin.setFechaIngreso(LocalDate.parse(fechaIngresoStr));
            }

            String estado = request.getParameter("estado");
            admin.setEstado(estado != null ? estado : "ACTIVO");

            // SUBIR FOTO
            Part filePart = request.getPart("foto");
            if (filePart != null && filePart.getSize() > 0) {
                String nombreArchivo = subirFoto(filePart, request);
                admin.setFoto(nombreArchivo);
            }

            // VALIDAR DNI DUPLICADO
            if (dao.existeDNI(admin.getNumeroDocumento(), 0)) {
                session.setAttribute("error", "Ya existe un administrativo con ese DNI");
                response.sendRedirect("AdministrativoServlet?action=nuevo");
                return;
            }

            // INSERTAR
            boolean exito = dao.insertar(admin);

            if (exito) {
                session.setAttribute("mensaje", "✅ Administrativo registrado exitosamente");
            } else {
                session.setAttribute("error", "❌ No se pudo registrar el administrativo");
            }

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "Error al procesar datos: " + e.getMessage());
        }

        response.sendRedirect("AdministrativoServlet");
    }

    /**
     * ACTUALIZAR administrativo existente
     */
    private void actualizar(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException, ServletException {

        HttpSession session = request.getSession();
        int id = Integer.parseInt(request.getParameter("id"));

        Administrativo admin = dao.obtenerPorId(id);
        if (admin == null) {
            session.setAttribute("error", "Administrativo no encontrado");
            response.sendRedirect("AdministrativoServlet");
            return;
        }

        try {
            // ACTUALIZAR DATOS PERSONALES
            admin.setNombres(request.getParameter("nombres"));
            admin.setApellidos(request.getParameter("apellidos"));
            admin.setTipoDocumento(request.getParameter("tipo_documento"));
            admin.setNumeroDocumento(request.getParameter("numero_documento"));
            admin.setSexo(request.getParameter("sexo"));

            String fechaNacStr = request.getParameter("fecha_nacimiento");
            if (fechaNacStr != null && !fechaNacStr.isEmpty()) {
                admin.setFechaNacimiento(LocalDate.parse(fechaNacStr));
            }

            admin.setDireccion(request.getParameter("direccion"));
            admin.setTelefono(request.getParameter("telefono"));
            admin.setCorreo(request.getParameter("correo"));

            // ACTUALIZAR DATOS LABORALES
            admin.setCargo(request.getParameter("cargo"));
            admin.setDepartamento(request.getParameter("departamento"));

            String fechaIngresoStr = request.getParameter("fecha_ingreso");
            if (fechaIngresoStr != null && !fechaIngresoStr.isEmpty()) {
                admin.setFechaIngreso(LocalDate.parse(fechaIngresoStr));
            }

            admin.setEstado(request.getParameter("estado"));

            // SUBIR NUEVA FOTO (si se proporciona)
            Part filePart = request.getPart("foto");
            if (filePart != null && filePart.getSize() > 0) {
                String nombreArchivo = subirFoto(filePart, request);
                admin.setFoto(nombreArchivo);
            }

            // VALIDAR DNI DUPLICADO (excluyendo el actual)
            if (dao.existeDNI(admin.getNumeroDocumento(), id)) {
                session.setAttribute("error", "Ya existe otro administrativo con ese DNI");
                response.sendRedirect("AdministrativoServlet?action=editar&id=" + id);
                return;
            }

            // ACTUALIZAR
            boolean exito = dao.actualizar(admin);

            if (exito) {
                session.setAttribute("mensaje", "✅ Administrativo actualizado exitosamente");
            } else {
                session.setAttribute("error", "❌ No se pudo actualizar el administrativo");
            }

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "Error al actualizar: " + e.getMessage());
        }

        response.sendRedirect("AdministrativoServlet");
    }

    /**
     * ELIMINAR (BORRADO LÓGICO) - Solo marca como eliminado=1
     */
    private void eliminar(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {

        int id = Integer.parseInt(request.getParameter("id"));
        HttpSession session = request.getSession();

        boolean exito = dao.eliminar(id);  // ✅ BORRADO LÓGICO

        if (exito) {
            session.setAttribute("mensaje", "✅ Administrativo eliminado correctamente");
        } else {
            session.setAttribute("error", "❌ No se pudo eliminar el administrativo");
        }

        response.sendRedirect("AdministrativoServlet");
    }

    /**
     * RESTAURAR administrativo eliminado
     */
    private void restaurar(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {

        int id = Integer.parseInt(request.getParameter("id"));
        HttpSession session = request.getSession();

        boolean exito = dao.restaurar(id);

        if (exito) {
            session.setAttribute("mensaje", "✅ Administrativo restaurado correctamente");
        } else {
            session.setAttribute("error", "❌ No se pudo restaurar el administrativo");
        }

        response.sendRedirect("AdministrativoServlet");
    }

    /**
     * SUBIR FOTO del administrativo
     */
    private String subirFoto(Part filePart, HttpServletRequest request) throws IOException {
        String nombreArchivo = System.currentTimeMillis() + "_" + getFileName(filePart);
        String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";

        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        String rutaCompleta = uploadPath + File.separator + nombreArchivo;
        filePart.write(rutaCompleta);

        return nombreArchivo;
    }

    /**
     * OBTENER nombre del archivo subido
     */
    private String getFileName(Part part) {
        String contentDisposition = part.getHeader("content-disposition");
        String[] tokens = contentDisposition.split(";");
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf('=') + 2, token.length() - 1);
            }
        }
        return "archivo.jpg";
    }
    
    /**
 * MOSTRAR DETALLES del administrativo
 */
private void mostrarDetalles(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException, SQLException {

    int id = Integer.parseInt(request.getParameter("id"));
    Administrativo admin = dao.obtenerPorId(id);

    if (admin != null) {
        request.setAttribute("administrativo", admin);
        request.getRequestDispatcher("administrativoDetalle.jsp").forward(request, response);
    } else {
        request.getSession().setAttribute("error", "Administrativo no encontrado");
        response.sendRedirect("AdministrativoServlet");
    }
}
}