package modelo;

import conexion.Conexion;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.*;

public class JustificacionDAO {
    
    public int crearJustificacion(Justificacion justificacion) {
        String sql = "INSERT INTO justificacion " +
                     "(asistencia_id, tipo_justificacion, descripcion, documento_adjunto, " +
                     "justificado_por, fecha_justificacion, estado, activo) " +
                     "VALUES (?, ?, ?, ?, ?, ?, 'PENDIENTE', 1)";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setInt(1, justificacion.getAsistenciaId());
            ps.setString(2, justificacion.getTipoJustificacionString());
            ps.setString(3, justificacion.getDescripcion());
            ps.setString(4, justificacion.getDocumentoAdjunto());
            ps.setInt(5, justificacion.getJustificadoPor());
            ps.setTimestamp(6, Timestamp.valueOf(justificacion.getFechaJustificacion()));
            
            int filasAfectadas = ps.executeUpdate();
            
            if (filasAfectadas > 0) {
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    int id = rs.getInt(1);
                    System.out.println("✅ Justificación creada con ID: " + id);
                    return id;
                }
            }
            
        } catch (SQLException e) {
            System.out.println("❌ Error al crear justificación: " + e.getMessage());
            e.printStackTrace();
        }
        
        return 0;
    }
    
    public boolean aprobarJustificacion(int justificacionId, int aprobadoPor, String observaciones) {
        Connection con = null;
        
        try {
            con = Conexion.getConnection();
            con.setAutoCommit(false);
            
            String sqlJustif = "UPDATE justificacion " +
                              "SET estado = 'APROBADO', aprobado_por = ?, " +
                              "fecha_aprobacion = ?, observaciones_aprobacion = ? " +
                              "WHERE id = ?";
            
            try (PreparedStatement ps = con.prepareStatement(sqlJustif)) {
                ps.setInt(1, aprobadoPor);
                ps.setTimestamp(2, Timestamp.valueOf(LocalDateTime.now()));
                ps.setString(3, observaciones);
                ps.setInt(4, justificacionId);
                ps.executeUpdate();
            }
            
            String sqlAsist = "UPDATE asistencia a " +
                             "INNER JOIN justificacion j ON a.id = j.asistencia_id " +
                             "SET a.estado = 'JUSTIFICADO' " +
                             "WHERE j.id = ?";
            
            try (PreparedStatement ps = con.prepareStatement(sqlAsist)) {
                ps.setInt(1, justificacionId);
                ps.executeUpdate();
            }
            
            con.commit();
            System.out.println("✅ Justificación aprobada: " + justificacionId);
            return true;
            
        } catch (SQLException e) {
            if (con != null) {
                try {
                    con.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            System.out.println("❌ Error al aprobar justificación: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            if (con != null) {
                try {
                    con.setAutoCommit(true);
                    con.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }
    
    public boolean rechazarJustificacion(int justificacionId, int aprobadoPor, String observaciones) {
        String sql = "UPDATE justificacion " +
                     "SET estado = 'RECHAZADO', aprobado_por = ?, " +
                     "fecha_aprobacion = ?, observaciones_aprobacion = ? " +
                     "WHERE id = ?";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, aprobadoPor);
            ps.setTimestamp(2, Timestamp.valueOf(LocalDateTime.now()));
            ps.setString(3, observaciones);
            ps.setInt(4, justificacionId);
            
            int filasAfectadas = ps.executeUpdate();
            
            if (filasAfectadas > 0) {
                System.out.println("✅ Justificación rechazada: " + justificacionId);
                return true;
            }
            
        } catch (SQLException e) {
            System.out.println("❌ Error al rechazar justificación: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    public List<Justificacion> obtenerJustificacionesPendientes(int cursoId, int turnoId) {
        List<Justificacion> lista = new ArrayList<>();
        String sql = "SELECT j.*, " +
                     "CONCAT(p.nombres, ' ', p.apellidos) as alumno_nombre, " +
                     "c.nombre as curso_nombre, " +
                     "CONCAT(pj.nombres, ' ', pj.apellidos) as justificador_nombre, " +
                     "a.fecha as fecha_asistencia " +
                     "FROM justificacion j " +
                     "INNER JOIN asistencia a ON j.asistencia_id = a.id " +
                     "INNER JOIN alumno al ON a.alumno_id = al.id " +
                     "INNER JOIN persona p ON al.persona_id = p.id " +
                     "INNER JOIN curso c ON a.curso_id = c.id " +
                     "INNER JOIN persona pj ON j.justificado_por = pj.id " +
                     "WHERE a.curso_id = ? AND a.turno_id = ? " +
                     "AND j.estado = 'PENDIENTE' AND j.activo = 1 " +
                     "ORDER BY j.fecha_justificacion DESC";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, cursoId);
            ps.setInt(2, turnoId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                lista.add(mapearJustificacion(rs));
            }
            
        } catch (SQLException e) {
            System.out.println("❌ Error al obtener justificaciones pendientes: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }
    
    public List<Justificacion> obtenerJustificacionesPorAsistencia(int asistenciaId) {
        List<Justificacion> lista = new ArrayList<>();
        String sql = "SELECT j.*, " +
                     "CONCAT(p.nombres, ' ', p.apellidos) as alumno_nombre, " +
                     "c.nombre as curso_nombre, " +
                     "CONCAT(pj.nombres, ' ', pj.apellidos) as justificador_nombre, " +
                     "CONCAT(pa.nombres, ' ', pa.apellidos) as aprobador_nombre, " +
                     "a.fecha as fecha_asistencia " +
                     "FROM justificacion j " +
                     "INNER JOIN asistencia a ON j.asistencia_id = a.id " +
                     "INNER JOIN alumno al ON a.alumno_id = al.id " +
                     "INNER JOIN persona p ON al.persona_id = p.id " +
                     "INNER JOIN curso c ON a.curso_id = c.id " +
                     "INNER JOIN persona pj ON j.justificado_por = pj.id " +
                     "LEFT JOIN persona pa ON j.aprobado_por = pa.id " +
                     "WHERE j.asistencia_id = ? AND j.activo = 1 " +
                     "ORDER BY j.fecha_justificacion DESC";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, asistenciaId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                lista.add(mapearJustificacion(rs));
            }
            
        } catch (SQLException e) {
            System.out.println("❌ Error al obtener justificaciones: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }
    
    public Justificacion obtenerJustificacionPorId(int id) {
        String sql = "SELECT j.*, " +
                     "CONCAT(p.nombres, ' ', p.apellidos) as alumno_nombre, " +
                     "c.nombre as curso_nombre, " +
                     "CONCAT(pj.nombres, ' ', pj.apellidos) as justificador_nombre, " +
                     "CONCAT(pa.nombres, ' ', pa.apellidos) as aprobador_nombre, " +
                     "a.fecha as fecha_asistencia " +
                     "FROM justificacion j " +
                     "INNER JOIN asistencia a ON j.asistencia_id = a.id " +
                     "INNER JOIN alumno al ON a.alumno_id = al.id " +
                     "INNER JOIN persona p ON al.persona_id = p.id " +
                     "INNER JOIN curso c ON a.curso_id = c.id " +
                     "INNER JOIN persona pj ON j.justificado_por = pj.id " +
                     "LEFT JOIN persona pa ON j.aprobado_por = pa.id " +
                     "WHERE j.id = ?";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return mapearJustificacion(rs);
            }
            
        } catch (SQLException e) {
            System.out.println("❌ Error al obtener justificación: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    public boolean tieneJustificacionPendiente(int asistenciaId) {
        String sql = "SELECT COUNT(*) as total FROM justificacion " +
                     "WHERE asistencia_id = ? AND estado = 'PENDIENTE' AND activo = 1";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, asistenciaId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("total") > 0;
            }
            
        } catch (SQLException e) {
            System.out.println("❌ Error al verificar justificación: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }
    
    private Justificacion mapearJustificacion(ResultSet rs) throws SQLException {
        Justificacion j = new Justificacion();
        j.setId(rs.getInt("id"));
        j.setAsistenciaId(rs.getInt("asistencia_id"));
        j.setTipoJustificacionFromString(rs.getString("tipo_justificacion"));
        j.setDescripcion(rs.getString("descripcion"));
        j.setDocumentoAdjunto(rs.getString("documento_adjunto"));
        j.setJustificadoPor(rs.getInt("justificado_por"));
        
        Timestamp ts = rs.getTimestamp("fecha_justificacion");
        if (ts != null) {
            j.setFechaJustificacion(ts.toLocalDateTime());
        }
        
        j.setEstadoFromString(rs.getString("estado"));
        j.setAprobadoPor(rs.getInt("aprobado_por"));
        
        ts = rs.getTimestamp("fecha_aprobacion");
        if (ts != null) {
            j.setFechaAprobacion(ts.toLocalDateTime());
        }
        
        j.setObservacionesAprobacion(rs.getString("observaciones_aprobacion"));
        j.setActivo(rs.getBoolean("activo"));
        
        j.setAlumnoNombre(rs.getString("alumno_nombre"));
        j.setCursoNombre(rs.getString("curso_nombre"));
        j.setJustificadorNombre(rs.getString("justificador_nombre"));
        
        try {
            j.setAprobadorNombre(rs.getString("aprobador_nombre"));
        } catch (SQLException e) {
        }
        
        try {
            java.sql.Date fecha = rs.getDate("fecha_asistencia");
            if (fecha != null) {
                j.setFechaAsistencia(fecha.toString());
            }
        } catch (SQLException e) {
        }
        
        return j;
    }
}
