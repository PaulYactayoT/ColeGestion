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
public class ImageDAOTest {
    
    public ImageDAOTest() {
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
     * Test of guardarImagen method, of class ImageDAO.
     */
    @Test
    public void testGuardarImagen() {
        System.out.println("guardarImagen");
        ImageDAO dao = new ImageDAO();
        boolean result = dao.guardarImagen(0,"");
        assertFalse("Con id=0 y ruta vacia debe retornar false", result);
    }

    /**
     * Test of listarPorAlumno method, of class ImageDAO.
     */
    @Test
    public void testListarPorAlumno() {
        System.out.println("listarPorAlumno");
        int alumnoId = 999999;
        ImageDAO instance = new ImageDAO();
        List<Imagen> result = instance.listarPorAlumno(alumnoId);
        assertNotNull("ListaPorAlumno no debe devolver null", result);
        assertTrue("Si el alumno no exite, la lista debe ser vacia", result.isEmpty());
    }

    /**
     * Test of eliminarImagen method, of class ImageDAO.
     */
    @Test
    public void testEliminarImagen() {
        System.out.println("eliminarImagen (id inavalido)");
        ImageDAO dao = new ImageDAO();
        boolean ok = dao.eliminarImagen(-1, "c:/no-uso-en-este-caso");  
        assertFalse("Eliminar (-1) debe retornar false si el SP falla", ok);
    }
    }