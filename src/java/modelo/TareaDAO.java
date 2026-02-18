package modelo;

import conexion.Conexion;
import java.sql.*;
import java.util.*;

public class TareaDAO {

    /**
     * CREAR NUEVA TAREA
     * Flujo: Se guarda con activo = 1 y eliminado = 0
     */
    public boolean agregar(Tarea t) {
        String sql = "INSERT INTO tarea (curso_id, nombre, descripcion, fecha_entrega, hora_entrega, tipo, peso, instrucciones, archivo_adjunto, fecha_registro, activo, eliminado) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), 1, 0)";

        try (Connection con = Conexion.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, t.getCursoId());
            ps.setString(2, t.getNombre());
            ps.setString(3, t.getDescripcion());
            ps.setString(4, t.getFechaEntrega());
            ps.setString(5, t.getHoraEntrega()); 
            ps.setString(6, t.getTipo());
            ps.setDouble(7, t.getPeso());
            ps.setString(8, t.getInstrucciones());
            ps.setString(9, t.getArchivoAdjunto()); 

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
     * ACTUALIZAR TAREA (EDITAR)
     * Flujo: Si la tarea estaba vencida o inactiva, al editarla le ponemos activo = 1 
     * para que vuelva a estar disponible con el nuevo tiempo.
     */
    public boolean actualizar(Tarea t) {
        // ✅ AQUÍ ESTÁ LA LÓGICA QUE PIDES: ", activo = 1"
        // Esto asegura que al guardar cambios, la tarea se reactive en la BD.
        String sql = "UPDATE tarea SET curso_id = ?, nombre = ?, descripcion = ?, fecha_entrega = ?, hora_entrega = ?, " +
                     "tipo = ?, peso = ?, instrucciones = ?, archivo_adjunto = ?, activo = 1 " + 
                     "WHERE id = ? AND eliminado = 0";

        try (Connection con = Conexion.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, t.getCursoId());
            ps.setString(2, t.getNombre());
            ps.setString(3, t.getDescripcion());
            ps.setString(4, t.getFechaEntrega());
            ps.setString(5, t.getHoraEntrega()); 
            ps.setString(6, t.getTipo());
            ps.setDouble(7, t.getPeso());
            ps.setString(8, t.getInstrucciones());
            ps.setString(9, t.getArchivoAdjunto()); 
            ps.setInt(10, t.getId());

            int filasAfectadas = ps.executeUpdate();
            System.out.println("Tarea actualizada y reactivada - Filas afectadas: " + filasAfectadas);
            return filasAfectadas > 0;
        } catch (Exception e) {
            System.out.println("Error al actualizar tarea");
            e.printStackTrace();
            return false;
        }
    }

    /**
     * CAMBIAR ESTADO (ACTIVAR/DESACTIVAR MANUALMENTE)
     */
    public boolean cambiarEstado(int id, boolean activo) {
        String sql = "UPDATE tarea SET activo = ? WHERE id = ? AND eliminado = 0";

        try (Connection con = Conexion.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setBoolean(1, activo);
            ps.setInt(2, id);
            
            int filasAfectadas = ps.executeUpdate();
            return filasAfectadas > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * ELIMINAR TAREA (BORRADO LÓGICO)
     * Flujo: Pone eliminado = 1 y activo = 0
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
     * OBTENER TAREA POR ID
     */
    public Tarea obtenerPorId(int id) {
        Tarea t = null;
        String sql = "SELECT id, curso_id, nombre, descripcion, fecha_entrega, hora_entrega, activo, tipo, peso, instrucciones, archivo_adjunto " +
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
                t.setHoraEntrega(rs.getString("hora_entrega"));
                t.setCursoId(rs.getInt("curso_id"));
                t.setActivo(rs.getBoolean("activo"));
                t.setTipo(rs.getString("tipo"));
                t.setPeso(rs.getDouble("peso"));
                t.setInstrucciones(rs.getString("instrucciones"));
                t.setArchivoAdjunto(rs.getString("archivo_adjunto")); 
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return t;
    }

    /**
     * LISTAR TAREAS POR ALUMNO
     * Usa el SP para calcular si venció el tiempo
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
                    t.setHoraEntrega(rs.getString("hora_entrega")); 
                    t.setTipo(rs.getString("tipo"));
                    t.setPeso(rs.getDouble("peso"));
                    t.setInstrucciones(rs.getString("instrucciones"));
                    t.setCursoNombre(rs.getString("curso_nombre"));
                    t.setArchivoAdjunto(rs.getString("archivo_adjunto"));
                    
                    // Recuperamos el estado calculado (ACTIVO o FINALIZADO)
                    t.setEstadoCalculado(rs.getString("estado_calculado")); 
                    t.setSegundosRestantes(rs.getLong("segundos_restantes"));
                    
                } catch (SQLException e) {
                    System.out.println("Columna faltante: " + e.getMessage());
                }
                lista.add(t);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return lista;
    }

    /**
     * LISTAR TAREAS POR CURSO (PROFESOR)
     * Aquí mostramos el estado calculado.
     */
    public List<Tarea> listarPorCurso(int cursoId) {
        List<Tarea> lista = new ArrayList<>();
        
        String sql = "SELECT id, curso_id, nombre, descripcion, fecha_entrega, hora_entrega, activo, tipo, peso, instrucciones, archivo_adjunto, " +
                     "CASE " +
                     "   WHEN eliminado = 1 THEN 'ELIMINADO' " +
                     "   WHEN activo = 0 THEN 'CERRADO_MANUAL' " +
                     "   WHEN TIMESTAMP(fecha_entrega, IFNULL(hora_entrega, '23:59:59')) < NOW() THEN 'FINALIZADO' " +
                     "   ELSE 'ACTIVO' " +
                     "END AS estado_calculado, " +
                     "TIMESTAMPDIFF(SECOND, NOW(), TIMESTAMP(fecha_entrega, IFNULL(hora_entrega, '23:59:59'))) AS segundos_restantes " +
                     "FROM tarea WHERE curso_id = ? AND eliminado = 0 " +
                     "ORDER BY fecha_entrega ASC, hora_entrega ASC";

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
                t.setHoraEntrega(rs.getString("hora_entrega")); 
                t.setCursoId(rs.getInt("curso_id"));
                t.setActivo(rs.getBoolean("activo")); // Esto viene de la BD (1 o 0)
                t.setTipo(rs.getString("tipo"));
                t.setPeso(rs.getDouble("peso"));
                t.setInstrucciones(rs.getString("instrucciones"));
                t.setArchivoAdjunto(rs.getString("archivo_adjunto")); 
                
                // Calculamos el estado visual
                t.setEstadoCalculado(rs.getString("estado_calculado"));
                t.setSegundosRestantes(rs.getLong("segundos_restantes"));
                
                lista.add(t);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return lista;
    }
}