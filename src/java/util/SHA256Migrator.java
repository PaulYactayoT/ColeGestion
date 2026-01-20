package util;

import conexion.Conexion;
import java.sql.*;
import java.security.MessageDigest;

public class SHA256Migrator {
    
    // ✅ MÉTODO MAIN PARA EJECUTAR
    public static void main(String[] args) {
        System.out.println("=== 🔐 INICIANDO MIGRACIÓN A SHA256 ===");
        migrarASHA256();
        System.out.println("=== ✅ MIGRACIÓN COMPLETADA ===");
    }
    
    public static void migrarASHA256() {
        String selectSQL = "SELECT id, username, password FROM usuarios WHERE activo = 1";
        String updateSQL = "UPDATE usuarios SET password = ? WHERE id = ?";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement selectStmt = con.prepareStatement(selectSQL);
             PreparedStatement updateStmt = con.prepareStatement(updateSQL);
             ResultSet rs = selectStmt.executeQuery()) {
            
            int contador = 0;
            int errores = 0;
            System.out.println("🔁 Migrando contraseñas a SHA256...");
            
            while (rs.next()) {
                int id = rs.getInt("id");
                String username = rs.getString("username");
                String currentPassword = rs.getString("password");
                
                try {
                    // Si la contraseña ya es SHA256 (64 caracteres hex), saltar
                    if (currentPassword != null && currentPassword.length() == 64 && 
                        currentPassword.matches("[a-fA-F0-9]{64}")) {
                        System.out.println("⏭️  " + username + " -> Ya es SHA256, omitiendo");
                        continue;
                    }
                    
                    // Convertir a SHA256
                    String sha256Password = generarSHA256(currentPassword);
                    
                    updateStmt.setString(1, sha256Password);
                    updateStmt.setInt(2, id);
                    updateStmt.executeUpdate();
                    
                    contador++;
                    System.out.println("✅ " + username + " -> SHA256: " + sha256Password);
                    
                } catch (Exception e) {
                    errores++;
                    System.err.println("❌ Error migrando usuario " + username + ": " + e.getMessage());
                }
            }
            
            System.out.println("🎉 Migración completada.");
            System.out.println("✅ Usuarios migrados: " + contador);
            System.out.println("❌ Errores: " + errores);
            
        } catch (Exception e) {
            System.err.println("💥 Error en la migración: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    // ✅ GENERAR SHA256 CON JAVA NATIVO
    private static String generarSHA256(String input) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
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
    
    // ✅ VERIFICAR ESTADO DE MIGRACIÓN
    public static void verificarMigracion() {
        String sql = "SELECT username, password, LENGTH(password) as len, " +
                    "CASE " +
                    "  WHEN password REGEXP '^[a-f0-9]{64}$' THEN 'SHA256' " +
                    "  WHEN password LIKE '$2a$%' THEN 'BCRYPT' " +
                    "  ELSE 'TEXTO_PLANO' " +
                    "END as tipo " +
                    "FROM usuarios WHERE activo = 1 " +
                    "ORDER BY tipo, username";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            System.out.println("=== 🔍 VERIFICACIÓN DE MIGRACIÓN SHA256 ===");
            
            int sha256Count = 0;
            int bcryptCount = 0;
            int textoCount = 0;
            
            while (rs.next()) {
                String username = rs.getString("username");
                String password = rs.getString("password");
                String tipo = rs.getString("tipo");
                
                switch(tipo) {
                    case "SHA256": sha256Count++; break;
                    case "BCRYPT": bcryptCount++; break;
                    case "TEXTO_PLANO": textoCount++; break;
                }
                
                System.out.printf("User: %-20s | Tipo: %-12s | Hash: %s%n", 
                    username, tipo, 
                    tipo.equals("SHA256") ? password.substring(0, 16) + "..." : 
                    tipo.equals("TEXTO_PLANO") ? password : "[HASH_BCRYPT]");
            }
            
            System.out.println("============================================");
            System.out.println("📊 RESUMEN:");
            System.out.println("✅ SHA256: " + sha256Count + " usuarios");
            System.out.println("🔐 BCRYPT: " + bcryptCount + " usuarios");
            System.out.println("📝 TEXTO PLANO: " + textoCount + " usuarios");
            System.out.println("📈 TOTAL: " + (sha256Count + bcryptCount + textoCount) + " usuarios");
            
        } catch (Exception e) {
            System.err.println("💥 Error en verificación: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    // ✅ PROBAR CONVERSIÓN SHA256
    public static void probarConversiones() {
        System.out.println("=== 🧪 PRUEBAS DE CONVERSIÓN SHA256 ===");
        
        String[] pruebas = {
            "admin", "juantapia", "milagroscandela", 
            "luisgarcia", "test123", "password"
        };
        
        for (String texto : pruebas) {
            String sha256 = generarSHA256(texto);
            System.out.printf("'%-20s' -> %s%n", texto, sha256);
        }
    }
    
    // ✅ MIGRAR USUARIO ESPECÍFICO
    public static void migrarUsuarioEspecifico(String username) {
        String selectSQL = "SELECT id, password FROM usuarios WHERE username = ? AND activo = 1";
        String updateSQL = "UPDATE usuarios SET password = ? WHERE id = ?";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement selectStmt = con.prepareStatement(selectSQL);
             PreparedStatement updateStmt = con.prepareStatement(updateSQL)) {
            
            selectStmt.setString(1, username);
            ResultSet rs = selectStmt.executeQuery();
            
            if (rs.next()) {
                int id = rs.getInt("id");
                String currentPassword = rs.getString("password");
                
                String sha256Password = generarSHA256(currentPassword);
                
                updateStmt.setString(1, sha256Password);
                updateStmt.setInt(2, id);
                int filas = updateStmt.executeUpdate();
                
                if (filas > 0) {
                    System.out.println("✅ Usuario '" + username + "' migrado a SHA256: " + sha256Password);
                } else {
                    System.out.println("❌ No se pudo migrar usuario '" + username + "'");
                }
                
            } else {
                System.out.println("❌ Usuario '" + username + "' no encontrado");
            }
            
        } catch (Exception e) {
            System.err.println("💥 Error migrando usuario específico: " + e.getMessage());
            e.printStackTrace();
        }
    }
}