package modelo;

import conexion.Conexion;
import java.sql.*;
import java.util.*;

public class EstadisticasDAO {

    /**
     * OBTENER TOTAL DE ESTUDIANTES ACTIVOS
     */
    public int contarEstudiantesActivos() {
        int total = 0;
        String sql = "{CALL contar_estudiantes_activos()}";

        try (Connection con = Conexion.getConnection(); 
             CallableStatement cs = con.prepareCall(sql)) {
            
            ResultSet rs = cs.executeQuery();
            if (rs.next()) {
                total = rs.getInt("total");
            }

        } catch (Exception e) {
            System.out.println("Error al contar estudiantes activos");
            e.printStackTrace();
        }
        return total;
    }

    /**
     * OBTENER TOTAL DE PROFESORES ACTIVOS
     */
    public int contarProfesoresActivos() {
        int total = 0;
        String sql = "{CALL contar_profesores_activos()}";

        try (Connection con = Conexion.getConnection(); 
             CallableStatement cs = con.prepareCall(sql)) {
            
            ResultSet rs = cs.executeQuery();
            if (rs.next()) {
                total = rs.getInt("total");
            }

        } catch (Exception e) {
            System.out.println("Error al contar profesores activos");
            e.printStackTrace();
        }
        return total;
    }

    /**
     * OBTENER TOTAL DE CURSOS ACTIVOS
     */
    public int contarCursosActivos() {
        int total = 0;
        String sql = "{CALL contar_cursos_activos()}";

        try (Connection con = Conexion.getConnection(); 
             CallableStatement cs = con.prepareCall(sql)) {
            
            ResultSet rs = cs.executeQuery();
            if (rs.next()) {
                total = rs.getInt("total");
            }

        } catch (Exception e) {
            System.out.println("Error al contar cursos activos");
            e.printStackTrace();
        }
        return total;
    }

    /**
     * OBTENER TOTAL DE GRADOS ACTIVOS
     */
    public int contarGradosActivos() {
        int total = 0;
        String sql = "{CALL contar_grados_activos()}";

        try (Connection con = Conexion.getConnection(); 
             CallableStatement cs = con.prepareCall(sql)) {
            
            ResultSet rs = cs.executeQuery();
            if (rs.next()) {
                total = rs.getInt("total");
            }

        } catch (Exception e) {
            System.out.println("Error al contar grados activos");
            e.printStackTrace();
        }
        return total;
    }

    /**
     * OBTENER TODAS LAS ESTADÍSTICAS EN UN SOLO MAP
     */
    public Map<String, Integer> obtenerEstadisticasGenerales() {
        Map<String, Integer> stats = new HashMap<>();
        
        stats.put("totalEstudiantes", contarEstudiantesActivos());
        stats.put("totalProfesores", contarProfesoresActivos());
        stats.put("totalCursos", contarCursosActivos());
        stats.put("totalGrados", contarGradosActivos());
        
        return stats;
    }
}