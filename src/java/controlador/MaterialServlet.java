package controlador;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import modelo.Material;
import modelo.MaterialDAO;
import modelo.Profesor;
import modelo.Curso;
import modelo.CursoDAO;

@WebServlet("/MaterialServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 10,       // 10MB
    maxRequestSize = 1024 * 1024 * 50     // 50MB
)
public class MaterialServlet extends HttpServlet {
    
    private static final String UPLOAD_DIR = "materiales";
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Profesor docente = (Profesor) session.getAttribute("docente");
        
        if (docente == null) {
            response.sendRedirect("index.jsp");
            return;
        }
        
        String accion = request.getParameter("accion");
        
        try {
            switch (accion != null ? accion : "listar") {
                case "listar":
                    listarMateriales(request, response, docente);
                    break;
                case "eliminar":
                    eliminarMaterial(request, response, session);
                    break;
                default:
                    listarMateriales(request, response, docente);
                    break;
            }
        } catch (Exception e) {
            System.err.println("❌ ERROR en MaterialServlet: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("error", "Error al procesar la solicitud: " + e.getMessage());
            response.sendRedirect("docenteDashboard.jsp");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Profesor docente = (Profesor) session.getAttribute("docente");
        
        if (docente == null) {
            response.sendRedirect("index.jsp");
            return;
        }
        
        String accion = request.getParameter("accion");
        
        try {
            if ("subir".equals(accion)) {
                subirMaterial(request, response, session, docente);
            }
        } catch (Exception e) {
            System.err.println("❌ ERROR en MaterialServlet POST: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("error", "Error al subir el material: " + e.getMessage());
            response.sendRedirect("MaterialServlet?accion=listar");
        }
    }
    
    /**
     * LISTAR TODOS LOS MATERIALES DEL DOCENTE
     */
    private void listarMateriales(HttpServletRequest request, HttpServletResponse response, 
                                 Profesor docente) throws ServletException, IOException {
        
        MaterialDAO materialDAO = new MaterialDAO();
        CursoDAO cursoDAO = new CursoDAO();
        
        // Obtener todos los materiales del profesor
        List<Material> materiales = materialDAO.listarPorProfesor(docente.getId());
        
        // Obtener los cursos del docente para el formulario
        List<Curso> cursos = cursoDAO.listarPorProfesor(docente.getId());
        
        request.setAttribute("materiales", materiales);
        request.setAttribute("cursos", cursos);
        
        request.getRequestDispatcher("materialApoyo.jsp").forward(request, response);
    }
    
    /**
     * SUBIR NUEVO MATERIAL
     */
    private void subirMaterial(HttpServletRequest request, HttpServletResponse response,
                              HttpSession session, Profesor docente) 
            throws ServletException, IOException {
        
        try {
            // Obtener parámetros del formulario
            String cursoIdStr = request.getParameter("curso_id");
            String descripcion = request.getParameter("descripcion");
            Part filePart = request.getPart("archivo");
            
            // Validaciones
            if (cursoIdStr == null || cursoIdStr.isEmpty()) {
                session.setAttribute("error", "Debe seleccionar un curso");
                response.sendRedirect("MaterialServlet?accion=listar");
                return;
            }
            
            if (filePart == null || filePart.getSize() == 0) {
                session.setAttribute("error", "Debe seleccionar un archivo");
                response.sendRedirect("MaterialServlet?accion=listar");
                return;
            }
            
            int cursoId = Integer.parseInt(cursoIdStr);
            String nombreArchivo = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            
            // Crear directorio si no existe
            String appPath = request.getServletContext().getRealPath("");
            String uploadPath = appPath + File.separator + UPLOAD_DIR;
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdir();
            }
            
            // Generar nombre único para el archivo
            String timestamp = String.valueOf(System.currentTimeMillis());
            String extension = "";
            int i = nombreArchivo.lastIndexOf('.');
            if (i > 0) {
                extension = nombreArchivo.substring(i);
            }
            String nombreUnico = "material_" + cursoId + "_" + timestamp + extension;
            String rutaCompleta = uploadPath + File.separator + nombreUnico;
            
            // Guardar archivo
            try (InputStream input = filePart.getInputStream()) {
                Files.copy(input, Paths.get(rutaCompleta), StandardCopyOption.REPLACE_EXISTING);
            }
            
            // Crear objeto Material
            Material material = new Material();
            material.setCursoId(cursoId);
            material.setProfesorId(docente.getId());
            material.setNombreArchivo(nombreArchivo);
            material.setRutaArchivo(UPLOAD_DIR + "/" + nombreUnico);
            material.setTipoArchivo(filePart.getContentType());
            material.setTamanioArchivo(filePart.getSize());
            material.setDescripcion(descripcion);
            
            // Guardar en BD
            MaterialDAO materialDAO = new MaterialDAO();
            if (materialDAO.agregar(material)) {
                session.setAttribute("mensaje", "Material subido exitosamente: " + nombreArchivo);
            } else {
                // Si falla BD, eliminar archivo
                Files.deleteIfExists(Paths.get(rutaCompleta));
                session.setAttribute("error", "Error al guardar el material en la base de datos");
            }
            
        } catch (Exception e) {
            System.err.println("❌ ERROR al subir material: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("error", "Error al subir el archivo: " + e.getMessage());
        }
        
        response.sendRedirect("MaterialServlet?accion=listar");
    }
    
    /**
     * ELIMINAR MATERIAL
     */
    private void eliminarMaterial(HttpServletRequest request, HttpServletResponse response,
                                 HttpSession session) throws IOException {
        
        String idStr = request.getParameter("id");
        
        if (idStr != null && !idStr.isEmpty()) {
            try {
                int id = Integer.parseInt(idStr);
                MaterialDAO materialDAO = new MaterialDAO();
                
                // Obtener info del material antes de eliminarlo
                Material material = materialDAO.obtenerPorId(id);
                
                if (materialDAO.eliminar(id)) {
                    // Intentar eliminar archivo físico
                    if (material != null && material.getRutaArchivo() != null) {
                        try {
                            String appPath = request.getServletContext().getRealPath("");
                            File archivo = new File(appPath + File.separator + material.getRutaArchivo());
                            if (archivo.exists()) {
                                archivo.delete();
                            }
                        } catch (Exception e) {
                            System.err.println("⚠️ No se pudo eliminar archivo físico: " + e.getMessage());
                        }
                    }
                    session.setAttribute("mensaje", "Material eliminado exitosamente");
                } else {
                    session.setAttribute("error", "Error al eliminar el material");
                }
            } catch (NumberFormatException e) {
                session.setAttribute("error", "ID de material inválido");
            }
        }
        
        response.sendRedirect("MaterialServlet?accion=listar");
    }
}