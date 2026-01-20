/*
 * DAO PARA GESTION DE PADRES/TUTORES
 * 
 * Funcionalidades:
 * - Consulta de datos de padres por credenciales
 * - Asociacion con alumnos correspondientes
 */
package modelo;

import conexion.Conexion;
import java.sql.*;

public class PadreDAO {

    /**
     * OBTENER PADRE/TUTOR POR NOMBRE DE USUARIO
     * 
     * @param username Nombre de usuario del padre
     * @return Objeto Padre con datos completos o null si no existe
     */
    public Padre obtenerPorUsername(String username) {
        Padre p = null;
        String sql = "SELECT u.id, u.username, a.id AS alumno_id, " +
                     "a.nombres, a.apellidos, g.nombre AS grado_nombre " +
                     "FROM usuarios u " +
                     "JOIN alumnos a ON u.username = CONCAT(LOWER(a.nombres), LOWER(a.apellidos)) " +
                     "JOIN grados g ON a.grado_id = g.id " +
                     "WHERE u.username = ? AND u.rol = 'padre'";

        try (Connection con = Conexion.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                p = new Padre();
                p.setId(rs.getInt("id"));
                p.setUsername(rs.getString("username"));
                p.setAlumnoId(rs.getInt("alumno_id"));
                p.setAlumnoNombre(rs.getString("nombres") + " " + rs.getString("apellidos"));
                p.setGradoNombre(rs.getString("grado_nombre"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return p;
    }
}