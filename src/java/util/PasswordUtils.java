package util;

import org.mindrot.jbcrypt.BCrypt;

public class PasswordUtils {
    
    /**
     * Genera un hash seguro para una contraseña
     * @param plainPassword Contraseña en texto plano
     * @return Contraseña hasheada
     */
    public static String hashPassword(String plainPassword) {
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt());
    }
    
    /**
     * Verifica si una contraseña en texto plano coincide con el hash almacenado
     * @param plainPassword Contraseña en texto plano a verificar
     * @param hashedPassword Hash almacenado en la base de datos
     * @return true si la contraseña coincide, false si no
     */
    public static boolean checkPassword(String plainPassword, String hashedPassword) {
        try {
            return BCrypt.checkpw(plainPassword, hashedPassword);
        } catch (Exception e) {
            System.err.println("Error verificando contraseña: " + e.getMessage());
            return false;
        }
    }
    
    /**
     * Método de prueba para verificar que BCrypt funciona
     */
    public static void main(String[] args) {
        String password = "miContraseña123";
        String hash = hashPassword(password);
        
        System.out.println("Contraseña original: " + password);
        System.out.println("Hash generado: " + hash);
        System.out.println("Verificación exitosa: " + checkPassword(password, hash));
        System.out.println("Verificación fallida: " + checkPassword("contraseñaEquivocada", hash));
    }
}