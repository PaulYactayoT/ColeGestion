package modelo;

import conexion.Conexion;
import java.sql.*;
import java.util.*;

/**
 * DAO PARA GESTIÓN DE OBSERVACIONES ACADÉMICAS - VERSIÓN FINAL ESTABLE
 */
public class ObservacionDAO {

    /**
     * CA-01: FILTRAR ALUMNOS (IMPLEMENTACIÓN FLEXIBLE PARA TURNOS NULL)
     * Busca por grado y turno. Si el turno en la BD es NULL, también lo incluye
     * para evitar que alumnos registrados sin turno queden invisibles.
     */
    public List<Alumno> listarAlumnosPorFiltro(String nivel, int gradoId, int turnoId) {
        List<Alumno> lista = new ArrayList<>();
        // Ajuste clave: Se agrega (a.turno_id = ? OR a.turno_id IS NULL)
        String sql = "SELECT a.id, p.nombres, p.apellidos " +
                     "FROM alumno a " +
                     "INNER JOIN persona p ON a.persona_id = p.id " +
                     "WHERE a.grado_id = ? AND (a.turno_id = ? OR a.turno_id IS NULL) AND a.activo = 1 " + 
                     "ORDER BY p.apellidos ASC";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, gradoId);
            ps.setInt(2, turnoId);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Alumno a = new Alumno();
                a.setId(rs.getInt("id"));
                a.setNombres(rs.getString("nombres"));
                a.setApellidos(rs.getString("apellidos"));
                lista.add(a);
            }
        } catch (Exception e) {
            System.err.println("❌ ERROR SQL FILTRO: " + e.getMessage());
        }
        return lista;
    }

    /**
     * GUARDAR: INSERT DIRECTO
     */
    public boolean agregar(Observacion o) {
        String sql = "INSERT INTO observacion (curso_id, alumno_id, texto, tipo, ruta_evidencia, fecha, activo) " +
                     "VALUES (?, ?, ?, ?, ?, NOW(), 1)";
        try (Connection con = Conexion.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, o.getCursoId());
            ps.setInt(2, o.getAlumnoId());
            ps.setString(3, o.getTexto());
            ps.setString(4, (o.getTipo() != null) ? o.getTipo() : "NEUTRAL");
            ps.setString(5, (o.getRutaEvidencia() != null) ? o.getRutaEvidencia() : "");
            
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("❌ ERROR AL GUARDAR: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public boolean actualizar(Observacion o) {
        String sql = "UPDATE observacion SET alumno_id = ?, texto = ?, tipo = ?, ruta_evidencia = ? WHERE id = ?";
        try (Connection con = Conexion.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, o.getAlumnoId());
            ps.setString(2, o.getTexto());
            ps.setString(3, o.getTipo());
            ps.setString(4, o.getRutaEvidencia()); 
            ps.setInt(5, o.getId());
            
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("❌ ERROR AL ACTUALIZAR: " + e.getMessage());
            return false;
        }
    }

    public List<Observacion> listarPorCurso(int cursoId) {
        List<Observacion> lista = new ArrayList<>();
        String sql = "SELECT o.id, o.curso_id, o.alumno_id, o.texto, o.tipo, o.ruta_evidencia, " +
                     "p.nombres AS alumno_nombres, p.apellidos AS alumno_apellidos " +
                     "FROM observacion o " +
                     "INNER JOIN alumno a ON o.alumno_id = a.id " +
                     "INNER JOIN persona p ON a.persona_id = p.id " +
                     "WHERE o.curso_id = ? AND o.activo = 1 " +
                     "ORDER BY o.id DESC";
        
        try (Connection con = Conexion.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, cursoId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Observacion o = new Observacion();
                o.setId(rs.getInt("id"));
                o.setCursoId(rs.getInt("curso_id"));
                o.setAlumnoId(rs.getInt("alumno_id"));
                o.setTexto(rs.getString("texto"));
                o.setTipo(rs.getString("tipo"));
                o.setRutaEvidencia(rs.getString("ruta_evidencia"));
                o.setAlumnoNombre(rs.getString("alumno_nombres") + " " + rs.getString("alumno_apellidos"));
                lista.add(o);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return lista;
    }

    public boolean eliminar(int id) {
        String sql = "UPDATE observacion SET activo = 0 WHERE id = ?";
        try (Connection con = Conexion.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { return false; }
    }

    public Observacion obtenerPorId(int id) {
        Observacion o = null;
        String sql = "SELECT o.*, p.nombres AS alumno_nombres, p.apellidos AS alumno_apellidos " +
                     "FROM observacion o " +
                     "INNER JOIN alumno a ON o.alumno_id = a.id " +
                     "INNER JOIN persona p ON a.persona_id = p.id " +
                     "WHERE o.id = ?";
        try (Connection con = Conexion.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                o = new Observacion();
                o.setId(rs.getInt("id"));
                o.setCursoId(rs.getInt("curso_id"));
                o.setAlumnoId(rs.getInt("alumno_id"));
                o.setTexto(rs.getString("texto"));
                o.setTipo(rs.getString("tipo"));
                o.setRutaEvidencia(rs.getString("ruta_evidencia"));
                o.setAlumnoNombre(rs.getString("alumno_nombres") + " " + rs.getString("alumno_apellidos"));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return o;
    }

public List<Observacion> listarPorAlumno(int alumnoId) {
    List<Observacion> lista = new ArrayList<>();
    String sql = "SELECT o.id, o.curso_id, o.alumno_id, o.texto, o.tipo, " +
                 "o.ruta_evidencia, c.nombre AS curso_nombre " +
                 "FROM observacion o " +
                 "INNER JOIN curso c ON o.curso_id = c.id " +
                 "WHERE o.alumno_id = ? " +
                 "AND o.activo = 1 AND o.eliminado = 0 " +
                 "ORDER BY o.id DESC";
    try (Connection con = Conexion.getConnection();
         PreparedStatement ps = con.prepareStatement(sql)) {
        ps.setInt(1, alumnoId);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Observacion o = new Observacion();
            o.setId(rs.getInt("id"));
            o.setCursoId(rs.getInt("curso_id"));
            o.setAlumnoId(rs.getInt("alumno_id"));
            o.setTexto(rs.getString("texto"));
            o.setTipo(rs.getString("tipo"));
            o.setRutaEvidencia(rs.getString("ruta_evidencia"));
            o.setCursoNombre(rs.getString("curso_nombre"));
            lista.add(o);
        }
    } catch (Exception e) { 
        e.printStackTrace(); 
    }
    return lista;
}
}