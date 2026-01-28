package util;

import conexion.Conexion;
import java.sql.*;

public class ResetPasswordUtil {
    
    // ✅ MÉTODO MAIN PARA EJECUTAR
    public static void main(String[] args) {
        System.out.println("=== 🔧 INICIANDO RESET DE CONTRASEÑAS ===");
        resetAllPasswordsToUsername();
        System.out.println("=== ✅ RESET COMPLETADO ===");
    }
    
    public static void resetAllPasswordsToUsername() {
        String selectSQL = "SELECT id, username FROM usuarios WHERE activo = 1";
        String updateSQL = "UPDATE usuarios SET password = ? WHERE id = ?";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement selectStmt = con.prepareStatement(selectSQL);
             PreparedStatement updateStmt = con.prepareStatement(updateSQL);
             ResultSet rs = selectStmt.executeQuery()) {
            
            int contador = 0;
            System.out.println("🔁 Reseteando contraseñas...");
            
            while (rs.next()) {
                int id = rs.getInt("id");
                String username = rs.getString("username");
                
                try {
                    // La contraseña será igual al username
                    String newPassword = username;
                    
                    updateStmt.setString(1, newPassword);
                    updateStmt.setInt(2, id);
                    updateStmt.executeUpdate();
                    
                    contador++;
                    System.out.println("✅ " + username + " -> contraseña: " + username);
                    
                } catch (Exception e) {
                    System.err.println("❌ Error actualizando usuario " + username + ": " + e.getMessage());
                }
            }
            
            System.out.println("🎉 Reset completado. Total usuarios actualizados: " + contador);
            
        } catch (Exception e) {
            System.err.println("💥 Error en el reset: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    // ✅ MÉTODO PARA MIGRAR A SHA256 (SIN DigestUtils)
    public static void migrarASHA256() {
        String selectSQL = "SELECT id, username, password FROM usuarios WHERE activo = 1";
        String updateSQL = "UPDATE usuarios SET password = ? WHERE id = ?";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement selectStmt = con.prepareStatement(selectSQL);
             PreparedStatement updateStmt = con.prepareStatement(updateSQL);
             ResultSet rs = selectStmt.executeQuery()) {
            
            int contador = 0;
            System.out.println("=== 🔐 MIGRANDO A SHA256 ===");
            
            while (rs.next()) {
                int id = rs.getInt("id");
                String username = rs.getString("username");
                String currentPassword = rs.getString("password");
                
                try {
                    // Convertir a SHA256 usando Java nativo
                    String sha256Password = generarSHA256(currentPassword);
                    
                    updateStmt.setString(1, sha256Password);
                    updateStmt.setInt(2, id);
                    updateStmt.executeUpdate();
                    
                    contador++;
                    System.out.println("✅ " + username + " -> SHA256: " + sha256Password.substring(0, 16) + "...");
                    
                } catch (Exception e) {
                    System.err.println("❌ Error migrando usuario " + username + ": " + e.getMessage());
                }
            }
            
            System.out.println("🎉 Migración SHA256 completada. Total usuarios: " + contador);
            
        } catch (Exception e) {
            System.err.println("💥 Error en la migración SHA256: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    // ✅ MÉTODO PARA GENERAR SHA256 CON JAVA NATIVO
    private static String generarSHA256(String input) {
        try {
            java.security.MessageDigest digest = java.security.MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(input.getBytes("UTF-8"));
            
            // Convertir bytes a hexadecimal
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
            
        } catch (Exception e) {
            throw new RuntimeException("Error generando SHA256", e);
        }
    }
    
    // ✅ MÉTODO PARA VERIFICAR EL ESTADO ACTUAL
    public static void verificarEstadoPasswords() {
        String sql = "SELECT id, username, password, LENGTH(password) as len, rol FROM usuarios WHERE activo = 1 ORDER BY id";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            System.out.println("=== 🔍 ESTADO ACTUAL DE CONTRASEÑAS ===");
            int total = 0;
            
            while (rs.next()) {
                int id = rs.getInt("id");
                String username = rs.getString("username");
                String password = rs.getString("password");
                int length = rs.getInt("len");
                String rol = rs.getString("rol");
                
                String tipo = "TEXTO";
                if (password.startsWith("$2a$")) {
                    tipo = "BCRYPT";
                } else if (password.length() == 64 && password.matches("[a-f0-9]{64}")) {
                    tipo = "SHA256";
                }
                
                System.out.printf("ID: %3d | User: %-20s | Rol: %-8s | Tipo: %-6s | Length: %2d%n", 
                    id, username, rol, tipo, length);
                total++;
            }
            
            System.out.println("=========================================");
            System.out.println("Total usuarios activos: " + total);
            
        } catch (Exception e) {
            System.err.println("💥 Error verificando contraseñas: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    // ✅ MÉTODO PARA PROBAR SHA256 CON UN USUARIO ESPECÍFICO
    public static void probarSHA256() {
        System.out.println("=== 🧪 PROBANDO SHA256 ===");
        
        String[] ejemplos = {"admin", "juantapia", "test123"};
        
        for (String ejemplo : ejemplos) {
            String sha256 = generarSHA256(ejemplo);
            System.out.println("Texto: '" + ejemplo + "' -> SHA256: " + sha256);
        }
    }
}