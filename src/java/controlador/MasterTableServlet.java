package controlador;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import modelo.MasterTable;
import modelo.MasterTableDAO;

@WebServlet("/MasterTableServlet")
public class MasterTableServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private MasterTableDAO dao;

    @Override
    public void init() throws ServletException {
        dao = new MasterTableDAO();
    }
// ============================================================
// INACTIVAR (antes era eliminar)
// ============================================================
private void inactivar(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException, SQLException {
    
    int id = Integer.parseInt(request.getParameter("id"));
    boolean success = dao.eliminar(id);
    
    HttpSession session = request.getSession();
    session.setAttribute(success ? "success" : "error",
        success ? "Registro inactivado correctamente" : "Error al inactivar el registro");
    
    response.sendRedirect("MasterTableServlet?action=listar");
}

// ============================================================
// ELIMINAR LÓGICAMENTE
// ============================================================
private void eliminarLogico(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException, SQLException {
    
    int id = Integer.parseInt(request.getParameter("id"));
    boolean success = dao.eliminarLogico(id);
    
    HttpSession session = request.getSession();
    session.setAttribute(success ? "success" : "error",
        success ? "Registro eliminado correctamente" : "Error al eliminar el registro");
    
    response.sendRedirect("MasterTableServlet?action=listar");
}
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Verificar sesión
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        String action = request.getParameter("action");
        if (action == null) {
            action = "listar";
        }

        try {
            switch (action) {
                case "listar":
                    listar(request, response);
                    break;
                case "ver":
                    ver(request, response);
                    break;
                case "nuevo":
                    mostrarFormularioNuevo(request, response);
                    break;
                case "editar":
                    mostrarFormularioEditar(request, response);
                    break;
                case "guardar":
                    guardar(request, response);
                    break;
                
                case "activar":
                    activar(request, response);
                    break;
                case "buscar":
                    buscar(request, response);
                    break;
                case "categorias":
                    listarCategorias(request, response);
                    break;
                case "valores":
                    listarValoresPorCategoria(request, response);
                    break;
                    // En el switch del processRequest, agrega:

case "eliminarLogico":
    eliminarLogico(request, response);
    break;

// Renombra el case "eliminar" a "inactivar":
case "inactivar":
    inactivar(request, response);
    break;
                default:
                    listar(request, response);
                    break;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Error de base de datos: " + e.getMessage());
            request.getRequestDispatcher("masterTable.jsp").forward(request, response);
        }
    }

    // ============================================================
    // LISTAR TODOS
    // ============================================================
    private void listar(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        
        String statusFilter = request.getParameter("status");
        String categoryFilter = request.getParameter("category");
        
        List<MasterTable> lista = dao.listarTodos(statusFilter, categoryFilter);
        List<MasterTable> categorias = dao.listarCategorias();
        List<String[]> estadisticas = dao.obtenerEstadisticas();
        
        request.setAttribute("listaMasterTable", lista);
        request.setAttribute("categorias", categorias);
        request.setAttribute("estadisticas", estadisticas);
        request.setAttribute("statusFilter", statusFilter);
        request.setAttribute("categoryFilter", categoryFilter);
        request.setAttribute("pageTitle", "Master Table CRUD");
        
        request.getRequestDispatcher("masterTable.jsp").forward(request, response);
    }

    // ============================================================
    // VER DETALLES
    // ============================================================
    private void ver(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        
        int id = Integer.parseInt(request.getParameter("id"));
        MasterTable mt = dao.obtenerPorId(id);
        
        request.setAttribute("masterTable", mt);
        request.setAttribute("pageTitle", "Detalles - Master Table");
        
        request.getRequestDispatcher("masterTableView.jsp").forward(request, response);
    }

    // ============================================================
    // MOSTRAR FORMULARIO NUEVO
    // ============================================================
    private void mostrarFormularioNuevo(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        
        List<MasterTable> categorias = dao.listarCategorias();
        
        request.setAttribute("categorias", categorias);
        request.setAttribute("action", "nuevo");
        request.setAttribute("pageTitle", "Nuevo Registro - Master Table");
        
        request.getRequestDispatcher("masterTableForm.jsp").forward(request, response);
    }

    // ============================================================
    // MOSTRAR FORMULARIO EDITAR
    // ============================================================
    private void mostrarFormularioEditar(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        
        int id = Integer.parseInt(request.getParameter("id"));
        MasterTable mt = dao.obtenerPorId(id);
        List<MasterTable> categorias = dao.listarCategorias();
        
        request.setAttribute("masterTable", mt);
        request.setAttribute("categorias", categorias);
        request.setAttribute("action", "editar");
        request.setAttribute("pageTitle", "Editar Registro - Master Table");
        
        request.getRequestDispatcher("masterTableForm.jsp").forward(request, response);
    }

    // ============================================================
    // GUARDAR (INSERT O UPDATE)
    // ============================================================
    private void guardar(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        
        String idParam = request.getParameter("id");
        MasterTable mt = new MasterTable();
        
        // Datos básicos
        mt.setCategory(request.getParameter("category"));
        mt.setValue(request.getParameter("value"));
        mt.setName(request.getParameter("name"));
        mt.setDescription(request.getParameter("description"));
        
        String orderIndexParam = request.getParameter("orderIndex");
        mt.setOrderIndex(orderIndexParam != null && !orderIndexParam.isEmpty() 
                         ? Integer.parseInt(orderIndexParam) : 0);
        
        // Campos adicionales
        mt.setAdditionalOne(request.getParameter("additionalOne"));
        mt.setAdditionalTwo(request.getParameter("additionalTwo"));
        mt.setAdditionalThree(request.getParameter("additionalThree"));
        mt.setAdditionalFour(request.getParameter("additionalFour"));
        
        boolean success;
        String mensaje;
        
        if (idParam != null && !idParam.isEmpty()) {
            // ACTUALIZAR
            mt.setIdMasterTable(Integer.parseInt(idParam));
            success = dao.actualizar(mt);
            mensaje = success ? "Registro actualizado correctamente" : "Error al actualizar el registro";
        } else {
            // INSERTAR
            success = dao.insertar(mt);
            mensaje = success ? "Registro creado correctamente" : "Error al crear el registro (posiblemente ya existe)";
        }
        
        HttpSession session = request.getSession();
        session.setAttribute(success ? "success" : "error", mensaje);
        
        response.sendRedirect("MasterTableServlet?action=listar");
    }

    // ============================================================
    // ELIMINAR (DESACTIVAR)
    // ============================================================
    private void eliminar(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        
        int id = Integer.parseInt(request.getParameter("id"));
        boolean success = dao.eliminar(id);
        
        HttpSession session = request.getSession();
        String mensaje = success ? "Registro desactivado correctamente" : "Error al desactivar el registro";
        session.setAttribute(success ? "success" : "error", mensaje);
        
        response.sendRedirect("MasterTableServlet?action=listar");
    }

    // ============================================================
    // ACTIVAR
    // ============================================================
    private void activar(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        
        int id = Integer.parseInt(request.getParameter("id"));
        boolean success = dao.activar(id);
        
        HttpSession session = request.getSession();
        String mensaje = success ? "Registro activado correctamente" : "Error al activar el registro";
        session.setAttribute(success ? "success" : "error", mensaje);
        
        response.sendRedirect("MasterTableServlet?action=listar");
    }

    // ============================================================
    // BUSCAR
    // ============================================================
    private void buscar(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        
        String searchTerm = request.getParameter("q");
        List<MasterTable> resultados = dao.buscar(searchTerm);
        List<MasterTable> categorias = dao.listarCategorias();
        
        request.setAttribute("listaMasterTable", resultados);
        request.setAttribute("categorias", categorias);
        request.setAttribute("searchTerm", searchTerm);
        request.setAttribute("pageTitle", "Resultados de búsqueda");
        
        request.getRequestDispatcher("masterTable.jsp").forward(request, response);
    }

    // ============================================================
    // LISTAR CATEGORÍAS
    // ============================================================
   // ============================================================
// LISTAR CATEGORÍAS  ← CAMBIO: redirige a masterTableCategorias.jsp
// ============================================================
private void listarCategorias(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException, SQLException {
    
    List<MasterTable> categorias = dao.listarCategorias();
    
    request.setAttribute("categorias", categorias);
    request.setAttribute("pageTitle", "Categorías - Master Table");
    
    // ✅ CAMBIO CLAVE: forward a masterTableCategorias.jsp (NO masterTable.jsp)
    request.getRequestDispatcher("masterTableCategorias.jsp").forward(request, response);
}

    // ============================================================
    // LISTAR VALORES POR CATEGORÍA
    // ============================================================
    private void listarValoresPorCategoria(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        
        String category = request.getParameter("category");
        List<MasterTable> valores = dao.listarPorCategoria(category);
        List<MasterTable> categorias = dao.listarCategorias();
        
        request.setAttribute("listaMasterTable", valores);
        request.setAttribute("categorias", categorias);
        request.setAttribute("categoryFilter", category);
        request.setAttribute("pageTitle", "Valores de " + category);
        
        request.getRequestDispatcher("masterTable.jsp").forward(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }
}