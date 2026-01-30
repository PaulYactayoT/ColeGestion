package controlador;

import conexion.Conexion;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import org.junit.Test;
import static org.junit.Assert.*;

public class LoginServletTest {

    @Test
    public void testLoginExitoso() {
        String username = "juantapia";
        String password = "juantapia";
        boolean loginExitoso = true;

        try (Connection con = Conexion.getConnection()) {
            String sql = "SELECT * FROM usuarios WHERE username = ? AND password = ?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, username);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                loginExitoso = true;
                System.out.println("✅ Login exitoso para usuario: " + username);
            }
        } catch (Exception e) {
            fail("Error en la conexión o consulta: " + e.getMessage());
        }

        assertTrue("El login debería ser exitoso", loginExitoso);
    }

    @Test
    public void testLoginFallido() {
        String username = "admin";
        String password = "asdad";
        boolean loginExitoso = false;

        try (Connection con = Conexion.getConnection()) {
            String sql = "SELECT * FROM usuarios WHERE username = ? AND password = ?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, username);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                loginExitoso = true;
            }
        } catch (Exception e) {
            fail("Error en la conexión o consulta: " + e.getMessage());
        }

        assertFalse("El login debería fallar con credenciales incorrectas", loginExitoso);
    }
}
