package modelo;

import conexion.Conexion;
import java.sql.*;
import java.util.*;

public class TareaDAO {

    /**
     * CREAR NUEVA TAREA CON ARCHIVO ADJUNTO
     * @param t Objeto Tarea con datos completos
     * @return true si la creacion fue exitosa
     */
    public boolean agregar(Tarea t) {
        String sql = "INSERT INTO tarea (curso_id, nombre, descripcion, fecha_entrega, tipo, peso, instrucciones, archivo_adjunto, fecha_registro, activo, eliminado) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW(), 1, 0)";

        try (Connection con = Conexion.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, t.getCursoId());
            ps.setString(2, t.getNombre());
            ps.setString(3, t.getDescripcion());
            ps.setString(4, t.getFechaEntrega());
            ps.setString(5, t.getTipo());
            ps.setDouble(6, t.getPeso());
            ps.setString(7, t.getInstrucciones());
            ps.setString(8, t.getArchivoAdjunto()); // NUEVO CAMPO

            int filasAfectadas = ps.executeUpdate();
            System.out.println("Tarea creada - Filas afectadas: " + filasAfectadas);
            return filasAfectadas > 0;
        } catch (Exception e) {
            System.out.println("Error al agregar tarea");
            e.printStackTrace();
            return false;
        }
    }

    /**
     * ACTUALIZAR TAREA EXISTENTE CON ARCHIVO ADJUNTO
     * @param t Objeto Tarea con datos actualizados
     * @return true si la actualizacion fue exitosa
     */
    public boolean actualizar(Tarea t) {
        String sql = "UPDATE tarea SET curso_id = ?, nombre = ?, descripcion = ?, fecha_entrega = ?, " +
                     "tipo = ?, peso = ?, instrucciones = ?, archivo_adjunto = ? " +
                     "WHERE id = ? AND eliminado = 0";

        try (Connection con = Conexion.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, t.getCursoId());
            ps.setString(2, t.getNombre());
            ps.setString(3, t.getDescripcion());
            ps.setString(4, t.getFechaEntrega());
            ps.setString(5, t.getTipo());
            ps.setDouble(6, t.getPeso());
            ps.setString(7, t.getInstrucciones());
            ps.setString(8, t.getArchivoAdjunto()); // NUEVO CAMPO
            ps.setInt(9, t.getId());

            int filasAfectadas = ps.executeUpdate();
            System.out.println("Tarea actualizada - Filas afectadas: " + filasAfectadas);
            return filasAfectadas > 0;
        } catch (Exception e) {
            System.out.println("Error al actualizar tarea");
            e.printStackTrace();
            return false;
        }
    }

    /**
     * CAMBIAR ESTADO ACTIVO/INACTIVO DE UNA TAREA
     * @param id Identificador de la tarea
     * @param activo Nuevo estado (true=activo, false=inactivo)
     * @return true si el cambio fue exitoso
     */
    public boolean cambiarEstado(int id, boolean activo) {
        String sql = "UPDATE tarea SET activo = ? WHERE id = ? AND eliminado = 0";

        try (Connection con = Conexion.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setBoolean(1, activo);
            ps.setInt(2, id);
            
            int filasAfectadas = ps.executeUpdate();
            System.out.println("Cambio de estado - Filas afectadas: " + filasAfectadas);
            
            return filasAfectadas > 0;
        } catch (Exception e) {
            System.out.println("Error al cambiar estado de tarea");
            e.printStackTrace();
            return false;
        }
    }

    /**
     * ELIMINAR TAREA POR ID (eliminación lógica)
     * @param id Identificador de la tarea
     * @return true si la eliminacion fue exitosa
     */
    public boolean eliminar(int id) {
        String sql = "UPDATE tarea SET eliminado = 1, activo = 0 WHERE id = ?";

        try (Connection con = Conexion.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            int filasAfectadas = ps.executeUpdate();
            System.out.println("Tarea eliminada - Filas afectadas: " + filasAfectadas);
            return filasAfectadas > 0;
        } catch (Exception e) {
            System.out.println("Error al eliminar tarea");
            e.printStackTrace();
            return false;
        }
    }

    /**
     * OBTENER TAREA POR ID CON ARCHIVO ADJUNTO
     * @param id Identificador de la tarea
     * @return Objeto Tarea con datos completos o null si no existe
     */
    public Tarea obtenerPorId(int id) {
        Tarea t = null;
        String sql = "SELECT id, curso_id, nombre, descripcion, fecha_entrega, activo, tipo, peso, instrucciones, archivo_adjunto " +
                     "FROM tarea WHERE id = ? AND eliminado = 0";

        try (Connection con = Conexion.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                t = new Tarea();
                t.setId(rs.getInt("id"));
                t.setNombre(rs.getString("nombre"));
                t.setDescripcion(rs.getString("descripcion"));
                t.setFechaEntrega(rs.getString("fecha_entrega"));
                t.setCursoId(rs.getInt("curso_id"));
                t.setActivo(rs.getBoolean("activo"));
                t.setTipo(rs.getString("tipo"));
                t.setPeso(rs.getDouble("peso"));
                t.setInstrucciones(rs.getString("instrucciones"));
                t.setArchivoAdjunto(rs.getString("archivo_adjunto")); // NUEVO CAMPO
            }

        } catch (Exception e) {
            System.out.println("Error al obtener tarea por ID");
            e.printStackTrace();
        }
        return t;
    }

    /**
     * LISTAR TAREAS POR ALUMNO ESPECIFICO
     * @param alumnoId Identificador del alumno
     * @return Lista de tareas asignadas al alumno
     */
    public List<Tarea> listarPorAlumno(int alumnoId) {
        List<Tarea> lista = new ArrayList<>();
        String sql = "{CALL obtener_tareas_por_alumno(?)}";

        try (Connection con = Conexion.getConnection(); 
             CallableStatement cs = con.prepareCall(sql)) {
            cs.setInt(1, alumnoId);
            ResultSet rs = cs.executeQuery();

            while (rs.next()) {
                Tarea t = new Tarea();
                t.setId(rs.getInt("id"));
                t.setNombre(rs.getString("nombre"));
                t.setDescripcion(rs.getString("descripcion"));
                t.setFechaEntrega(rs.getString("fecha_entrega"));
                t.setActivo(true);
                
                try {
                    t.setTipo(rs.getString("tipo"));
                    t.setPeso(rs.getDouble("peso"));
                    t.setInstrucciones(rs.getString("instrucciones"));
                    t.setCursoNombre(rs.getString("curso_nombre"));
                    t.setArchivoAdjunto(rs.getString("archivo_adjunto"));
                } catch (SQLException e) {
                    // Si no existen estos campos, los dejamos con valores por defecto
                }
                
                lista.add(t);
            }

        } catch (Exception e) {
            System.out.println("Error al listar tareas por alumno");
            e.printStackTrace();
        }

        return lista;
    }

    /**
     * LISTAR TAREAS POR CURSO ESPECIFICO (TODAS - activas e inactivas) CON ARCHIVO
     * @param cursoId Identificador del curso
     * @return Lista de tareas del curso solicitado
     */
    public List<Tarea> listarPorCurso(int cursoId) {
        List<Tarea> lista = new ArrayList<>();
        String sql = "SELECT id, curso_id, nombre, descripcion, fecha_entrega, activo, tipo, peso, instrucciones, archivo_adjunto " +
                     "FROM tarea WHERE curso_id = ? AND eliminado = 0 ORDER BY fecha_entrega ASC";

        try (Connection con = Conexion.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, cursoId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Tarea t = new Tarea();
                t.setId(rs.getInt("id"));
                t.setNombre(rs.getString("nombre"));
                t.setDescripcion(rs.getString("descripcion"));
                t.setFechaEntrega(rs.getString("fecha_entrega"));
                t.setCursoId(rs.getInt("curso_id"));
                t.setActivo(rs.getBoolean("activo"));
                t.setTipo(rs.getString("tipo"));
                t.setPeso(rs.getDouble("peso"));
                t.setInstrucciones(rs.getString("instrucciones"));
                t.setArchivoAdjunto(rs.getString("archivo_adjunto")); // NUEVO CAMPO
                
                lista.add(t);
            }

        } catch (Exception e) {
            System.out.println("Error al listar tareas por curso");
            e.printStackTrace();
        }

        return lista;
    }
}