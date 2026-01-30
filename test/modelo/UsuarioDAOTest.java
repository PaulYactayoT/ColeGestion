package modelo;

import java.util.List;
import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import static org.junit.Assert.*;

/**
 *
 * @author milag
 */
public class UsuarioDAOTest {
    
    public UsuarioDAOTest() {
    }
    
    @BeforeClass
    public static void setUpClass() {
    }
    
    @AfterClass
    public static void tearDownClass() {
    }
    
    @Before
    public void setUp() {
    }
    
    @After
    public void tearDown() {
    }

    /**
     * Test of listar method, of class UsuarioDAO.
     */
    @Test
    public void testListar() {
    System.out.println("listar");
    UsuarioDAO instance = new UsuarioDAO();
    List<Usuario> result = instance.listar();
    assertNotNull("listar() no debe devolver null", result);
    if (!result.isEmpty()) {
        Usuario u = result.get(0);
        assertNotNull("id no debe ser null", u.getId());
        assertNotNull("username no debe ser null", u.getUsername());
        assertNotNull("rol no debe ser null", u.getRol());
    }
}

    /**
     * Test of agregar method, of class UsuarioDAO.
     */
    @Test
    public void testAgregar() {
        System.out.println("agregar");
        Usuario u = null;
        UsuarioDAO instance = new UsuarioDAO();
        boolean expResult = false;
        boolean result = instance.agregar(null);
        assertEquals(expResult, result);
        // TODO review the generated test code and remove the default call to fail.
        assertFalse("agregar(null) debe retornar false", result);    }

    /**
     * Test of obtenerPorId method, of class UsuarioDAO.
     */
    @Test
    public void testObtenerPorId() {
        System.out.println("obtenerPorId");
        int id = 0;
        UsuarioDAO instance = new UsuarioDAO();
        Usuario result = instance.obtenerPorId(id);
        assertNull("Si el id no existe, obtenerPorId debe devolver null", result);
    }

    /**
     * Test of actualizar method, of class UsuarioDAO.
     */
    @Test
    public void testActualizar() {
        System.out.println("actualizar");
        UsuarioDAO instance = new UsuarioDAO();
        boolean result = instance.actualizar(null);
        assertFalse("Actualizar(Null) debe retornar false", result);
    }

    /**
     * Test of eliminar method, of class UsuarioDAO.
     */
    @Test
    public void testEliminar() {
        System.out.println("eliminar");
        int id = 0;
        UsuarioDAO instance = new UsuarioDAO();
        boolean result = instance.eliminar(id);
        assertTrue("Eliminar (id inesistente) no debe fallar",result);
    }
}