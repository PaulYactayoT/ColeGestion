/*
 * DAO PARA GESTION DE JUSTIFICACIONES DE ASISTENCIA
 * 
 * Funcionalidades:
 * - Creacion y aprobacion de justificaciones
 * - Consulta de justificaciones pendientes
 * - Gestion de documentos adjuntos
 */
package modelo;

import conexion.Conexion;
import java.sql.*;
import java.util.*;

public class JustificacionDAO {

    /**
     * CREAR NUEVA JUSTIFICACION DE ASISTENCIA
     * 
     * @param j Objeto Justificacion con datos completos
     * @return true si la creacion fue exitosa
     */
    public boolean crearJustificacion(Justificacion j) {
        String sql = "{CALL crear_justificacion(?, ?, ?, ?, ?)}";
        
        try (Connection con = Conexion.getConnection();
             CallableStatement cs = con.prepareCall(sql)) {
            
            cs.setInt(1, j.getAsistenciaId());
            cs.setString(2, j.getTipoJustificacion());
            cs.setString(3, j.getDescripcion());
            cs.setString(4, j.getDocumentoAdjunto());
            cs.setInt(5, j.getJustificadoPor());
            
            return cs.executeUpdate() > 0;
            
        } catch (Exception e) {
            System.out.println("Error al crear justificacion");
            e.printStackTrace();
            return false;
        }
    }

    /**
     * OBTENER JUSTIFICACIONES PENDIENTES DE REVISION
     * 
     * @return Lista de justificaciones en estado pendiente
     */
    public List<Justificacion> obtenerJustificacionesPendientes() {
        List<Justificacion> lista = new ArrayList<>();
        String sql = "{CALL obtener_justificaciones_pendientes()}";
        
        try (Connection con = Conexion.getConnection();
             CallableStatement cs = con.prepareCall(sql);
             ResultSet rs = cs.executeQuery()) {
            
            while (rs.next()) {
                Justificacion j = new Justificacion();
                j.setId(rs.getInt("id"));
                j.setAsistenciaId(rs.getInt("asistencia_id"));
                j.setTipoJustificacion(rs.getString("tipo_justificacion"));
                j.setDescripcion(rs.getString("descripcion"));
                j.setDocumentoAdjunto(rs.getString("documento_adjunto"));
                j.setFechaJustificacion(rs.getTimestamp("fecha_justificacion"));
                j.setEstado(rs.getString("estado"));
                j.setObservacionesAprobacion(rs.getString("observaciones_aprobacion"));
                j.setAlumnoNombre(rs.getString("alumno_nombre"));
                j.setCursoNombre(rs.getString("curso_nombre"));
                j.setFecha(rs.getString("fecha"));
                j.setHoraClase(rs.getString("hora_clase"));
                j.setPadreNombre(rs.getString("padre_nombre"));
                lista.add(j);
            }
            
        } catch (Exception e) {
            System.out.println("Error al obtener justificaciones pendientes");
            e.printStackTrace();
        }
        
        return lista;
    }

    /**
     * OBTENER JUSTIFICACIONES POR ALUMNO ESPECIFICO
     * 
     * @param alumnoId Identificador del alumno
     * @return Lista de justificaciones del alumno solicitado
     */
    public List<Justificacion> obtenerJustificacionesPorAlumno(int alumnoId) {
        List<Justificacion> lista = new ArrayList<>();
        String sql = "{CALL obtener_justificaciones_por_alumno(?)}";
        
        try (Connection con = Conexion.getConnection();
             CallableStatement cs = con.prepareCall(sql)) {
            
            cs.setInt(1, alumnoId);
            ResultSet rs = cs.executeQuery();
            
            while (rs.next()) {
                Justificacion j = new Justificacion();
                j.setId(rs.getInt("id"));
                j.setAsistenciaId(rs.getInt("asistencia_id"));
                j.setTipoJustificacion(rs.getString("tipo_justificacion"));
                j.setDescripcion(rs.getString("descripcion"));
                j.setDocumentoAdjunto(rs.getString("documento_adjunto"));
                j.setFechaJustificacion(rs.getTimestamp("fecha_justificacion"));
                j.setEstado(rs.getString("estado"));
                j.setObservacionesAprobacion(rs.getString("observaciones_aprobacion"));
                j.setCursoNombre(rs.getString("curso_nombre"));
                j.setFecha(rs.getString("fecha"));
                j.setHoraClase(rs.getString("hora_clase"));
                lista.add(j);
            }
            
        } catch (Exception e) {
            System.out.println("Error al obtener justificaciones por alumno");
            e.printStackTrace();
        }
        
        return lista;
    }

    /**
     * APROBAR JUSTIFICACION DE ASISTENCIA
     * 
     * @param justificacionId Identificador de la justificacion
     * @param aprobadoPor ID del usuario que aprueba la justificacion
     * @param observaciones Comentarios sobre la aprobacion
     * @return true si la aprobacion fue exitosa
     */
    public boolean aprobarJustificacion(int justificacionId, int aprobadoPor, String observaciones) {
        String sql = "{CALL aprobar_justificacion(?, ?, ?)}";
        
        try (Connection con = Conexion.getConnection();
             CallableStatement cs = con.prepareCall(sql)) {
            
            cs.setInt(1, justificacionId);
            cs.setInt(2, aprobadoPor);
            cs.setString(3, observaciones);
            
            return cs.executeUpdate() > 0;
            
        } catch (Exception e) {
            System.out.println("Error al aprobar justificacion");
            e.printStackTrace();
            return false;
        }
    }

    /**
     * RECHAZAR JUSTIFICACION DE ASISTENCIA
     * 
     * @param justificacionId Identificador de la justificacion
     * @param aprobadoPor ID del usuario que rechaza la justificacion
     * @param observaciones Comentarios sobre el rechazo
     * @return true si el rechazo fue exitoso
     */
    public boolean rechazarJustificacion(int justificacionId, int aprobadoPor, String observaciones) {
        String sql = "{CALL rechazar_justificacion(?, ?, ?)}";
        
        try (Connection con = Conexion.getConnection();
             CallableStatement cs = con.prepareCall(sql)) {
            
            cs.setInt(1, justificacionId);
            cs.setInt(2, aprobadoPor);
            cs.setString(3, observaciones);
            
            return cs.executeUpdate() > 0;
            
        } catch (Exception e) {
            System.out.println("Error al rechazar justificacion");
            e.printStackTrace();
            return false;
        }
    }
}