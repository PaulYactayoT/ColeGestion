package conexion;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;

public class Conexion {
    
    // URL con parámetros UTF-8
    private static final String URL = "jdbc:mysql://localhost:3306/escugestion?useUnicode=true&characterEncoding=UTF-8&serverTimezone=America/Lima";
    private static final String USER = "root";
    private static final String PASSWORD = "admin123";
    
    public static Connection getConnection() {
        Connection conn = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Establecer conexión
            conn = DriverManager.getConnection(URL, USER, PASSWORD);
            
            // CRÍTICO: Configurar el charset de la sesión MySQL
            try (Statement stmt = conn.createStatement()) {
                stmt.execute("SET NAMES 'utf8mb4'");
                stmt.execute("SET CHARACTER SET utf8mb4");
                stmt.execute("SET character_set_connection=utf8mb4");
            }
            
            return conn;
            
        } catch (ClassNotFoundException e) {
            System.err.println("❌ Error: Driver MySQL no encontrado");
            e.printStackTrace();
            return null;
        } catch (SQLException e) {
            System.err.println("❌ Error de conexión a la base de datos");
            System.err.println("   URL: " + URL);
            System.err.println("   Mensaje: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }
    
    // Método para probar la conexión
    public static void main(String[] args) {
        try (Connection conn = getConnection()) {
            if (conn != null) {
                System.out.println("✅ Conexión exitosa a: " + conn.getCatalog());
                System.out.println("✅ Codificación UTF-8 configurada correctamente");
            } else {
                System.err.println("❌ No se pudo establecer conexión");
            }
        } catch (SQLException e) {
            System.err.println("❌ Error al cerrar conexión: " + e.getMessage());
        }
    }
}