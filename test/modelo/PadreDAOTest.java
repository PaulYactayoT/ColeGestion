/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/UnitTests/JUnit4TestClass.java to edit this template
 */
package modelo;

import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import static org.junit.Assert.*;

/**
 *
 * @author Jean
 */
public class PadreDAOTest {
    
    public PadreDAOTest() {
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
     * Test of obtenerPorUsername method, of class PadreDAO.
     */
@Test
public void testObtenerPorUsername() {
    System.out.println("obtenerPorUsername");
    String username = "sssss";
    PadreDAO instance = new PadreDAO();
    Padre expResult = null;
    Padre result = instance.obtenerPorUsername(username);
    System.out.println("Resultado obtenido: " + result);
    if (expResult != result) {
        fail("El Username ya existe en la BD");
    } else {
        System.out.println("El Username no se encontró en la BD.");
    }
}
}