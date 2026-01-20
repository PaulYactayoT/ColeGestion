/*
 * DAO PARA GESTION DE IMAGENES DE ALUMNOS
 * 
 * Funcionalidades:
 * - Almacenamiento y recuperacion de imagenes
 * - Asociacion de imagenes con alumnos
 * - Eliminacion de archivos fisicos y registros
 */
package modelo;

import java.io.File;
import conexion.Conexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ImageDAO {

    /**
     * GUARDAR NUEVA IMAGEN ASOCIADA A ALUMNO
     * 
     * @param alumnoId Identificador del alumno
     * @param ruta Ruta relativa del archivo de imagen
     * @return true si el guardado fue exitoso
     */
    public boolean guardarImagen(int alumnoId, String ruta) {
        String sql = "INSERT INTO imagenes (alumno_id, ruta) VALUES (?, ?)";
        try (Connection c = Conexion.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, alumnoId);
            ps.setString(2, ruta);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * LISTAR IMAGENES POR ALUMNO ESPECIFICO
     * 
     * @param alumnoId Identificador del alumno
     * @return Lista de imagenes asociadas al alumno
     */
    public List<Imagen> listarPorAlumno(int alumnoId) {
        List<Imagen> lista = new ArrayList<>();
        String sql = "SELECT id, alumno_id, ruta, fecha_subida FROM imagenes WHERE alumno_id = ?";
        try (Connection c = Conexion.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, alumnoId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Imagen img = new Imagen();
                img.setId(rs.getInt("id"));
                img.setAlumnoId(rs.getInt("alumno_id"));
                img.setRuta(rs.getString("ruta"));
                img.setFechaSubida(rs.getTimestamp("fecha_subida"));
                lista.add(img);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return lista;
    }
    
    /**
     * ELIMINAR IMAGEN POR ID Y ARCHIVO FISICO
     * 
     * @param id Identificador de la imagen
     * @param contextPath Ruta del contexto de la aplicacion
     * @return true si la eliminacion fue exitosa
     */
    public boolean eliminarImagen(int id, String contextPath) {
        String sqlSelect = "SELECT ruta FROM imagenes WHERE id = ?";
        String sqlDelete = "DELETE FROM imagenes WHERE id = ?";
        String ruta = null;
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps1 = con.prepareStatement(sqlSelect)) {

            ps1.setInt(1, id);
            ResultSet rs = ps1.executeQuery();
            if (!rs.next()) return false;
            ruta = rs.getString("ruta");

            // 1) Primero eliminar registro BD
            try (PreparedStatement ps2 = con.prepareStatement(sqlDelete)) {
                ps2.setInt(1, id);
                ps2.executeUpdate();
            }

            // 2) Luego borrar el fichero
            // ruta almacena algo como "uploads/imagen123.jpg"
            File f = new File(contextPath, ruta);
            if (f.exists()) {
                f.delete();
            }
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}