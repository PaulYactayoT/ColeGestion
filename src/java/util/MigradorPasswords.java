package util;

import conexion.Conexion;
import java.sql.*;

public class MigradorPasswords {
    
    public static void main(String[] args) {
        migrarPasswords();
    }
    
    public static void migrarPasswords() {
        String selectSQL = "SELECT id, username, password FROM usuarios WHERE password NOT LIKE '$2a$%'";
        String updateSQL = "UPDATE usuarios SET password = ? WHERE id = ?";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement selectStmt = con.prepareStatement(selectSQL);
             PreparedStatement updateStmt = con.prepareStatement(updateSQL);
             ResultSet rs = selectStmt.executeQuery()) {
            
            int contador = 0;
            while (rs.next()) {
                int id = rs.getInt("id");
                String username = rs.getString("username");
                String plainPassword = rs.getString("password");
                
                // Solo migrar si la contraseña no está vacía y no es nula
                if (plainPassword != null && !plainPassword.trim().isEmpty()) {
                    try {
                        String hashedPassword = PasswordUtils.hashPassword(plainPassword);
                        
                        updateStmt.setString(1, hashedPassword);
                        updateStmt.setInt(2, id);
                        updateStmt.executeUpdate();
                        
                        contador++;
                        System.out.println("✅ Migrado usuario: " + username + " (ID: " + id + ")");
                        
                    } catch (Exception e) {
                        System.err.println("❌ Error migrando usuario " + username + ": " + e.getMessage());
                    }
                } else {
                    System.out.println("⚠️  Usuario " + username + " tiene contraseña vacía, omitiendo...");
                }
            }
            
            System.out.println("🎉 Migración completada. Total usuarios migrados: " + contador);
            
        } catch (Exception e) {
            System.err.println("💥 Error en la migración: " + e.getMessage());
            e.printStackTrace();
        }
    }
}