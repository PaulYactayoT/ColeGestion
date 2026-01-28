/*
 * DAO PARA GESTIÓN DE TURNOS ACADÉMICOS
 * 
 * Funcionalidades:
 * - Consulta de turnos activos
 * - Obtención de horarios de turnos
 * - CRUD completo de turnos
 * - Gestión de eliminación lógica
 */
package modelo;

import conexion.Conexion;
import java.sql.*;
import java.time.LocalTime;
import java.time.LocalDateTime;
import java.util.*;

public class TurnoDAO {
    
    /**
     * OBTENER TODOS LOS TURNOS ACTIVOS DEL SISTEMA
     * 
     * @return Lista de turnos con estado activo y no eliminados
     */
    public List<Turno> obtenerTurnosActivos() {
        List<Turno> lista = new ArrayList<>();
        String sql = "SELECT id, nombre, hora_inicio, hora_fin, descripcion, " +
                     "fecha_registro, activo, eliminado " +
                     "FROM turno " +
                     "WHERE activo = 1 AND eliminado = 0 " +
                     "ORDER BY hora_inicio";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Turno turno = mapearResultSet(rs);
                lista.add(turno);
            }
            
        } catch (SQLException e) {
            System.err.println("Error al obtener turnos activos: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }
    
    /**
     * OBTENER TODOS LOS TURNOS (INCLUYENDO INACTIVOS)
     * 
     * @return Lista de todos los turnos no eliminados
     */
    public List<Turno> obtenerTodosTurnos() {
        List<Turno> lista = new ArrayList<>();
        String sql = "SELECT id, nombre, hora_inicio, hora_fin, descripcion, " +
                     "fecha_registro, activo, eliminado " +
                     "FROM turno " +
                     "WHERE eliminado = 0 " +
                     "ORDER BY hora_inicio";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Turno turno = mapearResultSet(rs);
                lista.add(turno);
            }
            
        } catch (SQLException e) {
            System.err.println("Error al obtener todos los turnos: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }
    
    /**
     * OBTENER TURNO POR ID
     * 
     * @param id ID del turno
     * @return Objeto Turno o null si no existe
     */
    public Turno obtenerTurnoPorId(int id) {
        String sql = "SELECT id, nombre, hora_inicio, hora_fin, descripcion, " +
                     "fecha_registro, activo, eliminado " +
                     "FROM turno " +
                     "WHERE id = ? AND eliminado = 0";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapearResultSet(rs);
                }
            }
            
        } catch (SQLException e) {
            System.err.println("Error al obtener turno por ID: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * BUSCAR TURNO POR NOMBRE
     * 
     * @param nombre Nombre del turno
     * @return Objeto Turno o null si no existe
     */
    public Turno buscarPorNombre(String nombre) {
        String sql = "SELECT id, nombre, hora_inicio, hora_fin, descripcion, " +
                     "fecha_registro, activo, eliminado " +
                     "FROM turno " +
                     "WHERE nombre = ? AND eliminado = 0";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, nombre);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapearResultSet(rs);
                }
            }
            
        } catch (SQLException e) {
            System.err.println("Error al buscar turno por nombre: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * CREAR NUEVO TURNO
     * 
     * @param turno Objeto Turno a insertar
     * @return true si se insertó correctamente
     */
    public boolean crear(Turno turno) {
        String sql = "INSERT INTO turno (nombre, hora_inicio, hora_fin, descripcion, activo) " +
                     "VALUES (?, ?, ?, ?, ?)";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setString(1, turno.getNombre());
            ps.setTime(2, Time.valueOf(turno.getHoraInicio()));
            ps.setTime(3, Time.valueOf(turno.getHoraFin()));
            ps.setString(4, turno.getDescripcion());
            ps.setBoolean(5, turno.isActivo());
            
            int filasAfectadas = ps.executeUpdate();
            
            // Obtener el ID generado
            if (filasAfectadas > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        turno.setId(rs.getInt(1));
                    }
                }
                return true;
            }
            
        } catch (SQLException e) {
            System.err.println("Error al crear turno: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * ACTUALIZAR TURNO EXISTENTE
     * 
     * @param turno Objeto Turno con datos actualizados
     * @return true si se actualizó correctamente
     */
    public boolean actualizar(Turno turno) {
        String sql = "UPDATE turno SET nombre = ?, hora_inicio = ?, hora_fin = ?, " +
                     "descripcion = ?, activo = ? " +
                     "WHERE id = ? AND eliminado = 0";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, turno.getNombre());
            ps.setTime(2, Time.valueOf(turno.getHoraInicio()));
            ps.setTime(3, Time.valueOf(turno.getHoraFin()));
            ps.setString(4, turno.getDescripcion());
            ps.setBoolean(5, turno.isActivo());
            ps.setInt(6, turno.getId());
            
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("Error al actualizar turno: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * ELIMINAR TURNO (ELIMINACIÓN LÓGICA)
     * 
     * @param id ID del turno a eliminar
     * @return true si se eliminó correctamente
     */
    public boolean eliminarLogico(int id) {
        String sql = "UPDATE turno SET eliminado = 1, activo = 0 " +
                     "WHERE id = ? AND eliminado = 0";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("Error al eliminar turno: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * ACTIVAR/DESACTIVAR TURNO
     * 
     * @param id ID del turno
     * @param activo Estado deseado
     * @return true si se actualizó correctamente
     */
    public boolean cambiarEstado(int id, boolean activo) {
        String sql = "UPDATE turno SET activo = ? WHERE id = ? AND eliminado = 0";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setBoolean(1, activo);
            ps.setInt(2, id);
            
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("Error al cambiar estado del turno: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * VERIFICAR SI UN TURNO TIENE HORARIOS ASOCIADOS
     * 
     * @param turnoId ID del turno
     * @return true si tiene horarios de clase asociados
     */
    public boolean tieneHorariosAsociados(int turnoId) {
        String sql = "SELECT COUNT(*) as total FROM horario_clase " +
                     "WHERE turno_id = ? AND eliminado = 0";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, turnoId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total") > 0;
                }
            }
            
        } catch (SQLException e) {
            System.err.println("Error al verificar horarios asociados: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    /**
     * OBTENER ESTADÍSTICAS DEL TURNO
     * 
     * @param turnoId ID del turno
     * @return Map con estadísticas (total_horarios, total_cursos, etc.)
     */
    public Map<String, Integer> obtenerEstadisticas(int turnoId) {
        Map<String, Integer> stats = new HashMap<>();
        String sql = "SELECT " +
                     "COUNT(DISTINCT h.id) as total_horarios, " +
                     "COUNT(DISTINCT h.curso_id) as total_cursos, " +
                     "COUNT(DISTINCT h.profesor_id) as total_profesores, " +
                     "COUNT(DISTINCT h.aula_id) as total_aulas " +
                     "FROM horario_clase h " +
                     "WHERE h.turno_id = ? AND h.eliminado = 0";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, turnoId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stats.put("total_horarios", rs.getInt("total_horarios"));
                    stats.put("total_cursos", rs.getInt("total_cursos"));
                    stats.put("total_profesores", rs.getInt("total_profesores"));
                    stats.put("total_aulas", rs.getInt("total_aulas"));
                }
            }
            
        } catch (SQLException e) {
            System.err.println("Error al obtener estadísticas del turno: " + e.getMessage());
            e.printStackTrace();
        }
        
        return stats;
    }
    
    /**
     * MAPEAR RESULTSET A OBJETO TURNO
     * 
     * @param rs ResultSet con datos del turno
     * @return Objeto Turno mapeado
     * @throws SQLException
     */
    private Turno mapearResultSet(ResultSet rs) throws SQLException {
        Turno turno = new Turno();
        turno.setId(rs.getInt("id"));
        turno.setNombre(rs.getString("nombre"));
        
        Time horaInicio = rs.getTime("hora_inicio");
        if (horaInicio != null) {
            turno.setHoraInicio(horaInicio.toLocalTime());
        }
        
        Time horaFin = rs.getTime("hora_fin");
        if (horaFin != null) {
            turno.setHoraFin(horaFin.toLocalTime());
        }
        
        turno.setDescripcion(rs.getString("descripcion"));
        
        Timestamp fechaRegistro = rs.getTimestamp("fecha_registro");
        if (fechaRegistro != null) {
            turno.setFechaRegistro(fechaRegistro.toLocalDateTime());
        }
        
        turno.setActivo(rs.getBoolean("activo"));
        turno.setEliminado(rs.getBoolean("eliminado"));
        
        return turno;
    }
}