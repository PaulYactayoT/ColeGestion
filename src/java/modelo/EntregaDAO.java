package modelo;

import conexion.Conexion;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class EntregaDAO {

    /**
     * REGISTRAR UNA NUEVA ENTREGA
     */
    public boolean registrarEntrega(Entrega entrega) {
        String sql = "INSERT INTO entrega (tarea_id, alumno_id, ruta_archivo, nombre_archivo) VALUES (?, ?, ?, ?)";
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, entrega.getTareaId());
            ps.setInt(2, entrega.getAlumnoId());
            ps.setString(3, entrega.getArchivoRuta());
            ps.setString(4, entrega.getArchivoNombre());
            
            int filasAfectadas = ps.executeUpdate();
            return filasAfectadas > 0;
        } catch (Exception e) {
            System.out.println("Error al registrar la entrega: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * VALIDAR SI EL ALUMNO YA ENTREGÓ LA TAREA (Regla de negocio HU-14)
     */
    public boolean existeEntrega(int tareaId, int alumnoId) {
        String sql = "SELECT id FROM entrega WHERE tarea_id = ? AND alumno_id = ? AND activo = 1";
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, tareaId);
            ps.setInt(2, alumnoId);
            ResultSet rs = ps.executeQuery();
            
            return rs.next(); // Retorna true si ya existe un registro
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}