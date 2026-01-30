/*
 * DAO PARA GENERACION DE REPORTES DE ASISTENCIA
 * 
 * Funcionalidades:
 * - Reportes mensuales y trimestrales
 * - Alertas de asistencia baja
 * - Estadisticas por grado y turno
 */
package modelo;

import conexion.Conexion;
import java.sql.*;
import java.util.*;

public class ReporteAsistenciaDAO {

    /**
     * OBTENER REPORTE DE ASISTENCIA POR GRADO Y TURNO
     * 
     * @param gradoId Identificador del grado
     * @param turnoId Identificador del turno
     * @param mes Mes del reporte (1-12)
     * @param anio Ano del reporte
     * @return Lista de mapas con datos estadisticos de asistencia
     */
    public List<Map<String, Object>> obtenerReporteAsistenciaGradoTurno(int gradoId, int turnoId, int mes, int anio) {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql = "{CALL obtener_reporte_asistencia_grado_turno(?, ?, ?, ?)}";
        
        try (Connection con = Conexion.getConnection();
             CallableStatement cs = con.prepareCall(sql)) {
            
            cs.setInt(1, gradoId);
            cs.setInt(2, turnoId);
            cs.setInt(3, mes);
            cs.setInt(4, anio);
            ResultSet rs = cs.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> reporte = new HashMap<>();
                reporte.put("alumnoId", rs.getInt("alumno_id"));
                reporte.put("alumnoNombre", rs.getString("alumno_nombre"));
                reporte.put("totalClases", rs.getInt("total_clases"));
                reporte.put("presentes", rs.getInt("presentes"));
                reporte.put("tardanzas", rs.getInt("tardanzas"));
                reporte.put("ausentes", rs.getInt("ausentes"));
                reporte.put("justificados", rs.getInt("justificados"));
                reporte.put("porcentajeAsistencia", rs.getDouble("porcentaje_asistencia"));
                lista.add(reporte);
            }
            
        } catch (Exception e) {
            System.out.println("Error al obtener reporte de asistencia por grado y turno");
            e.printStackTrace();
        }
        
        return lista;
    }

    /**
     * OBTENER ALERTAS DE ASISTENCIA POR DEBAJO DEL PORCENTAJE MINIMO
     * 
     * @param porcentajeMinimo Porcentaje minimo de asistencia requerido
     * @param turnoId Identificador del turno
     * @return Lista de alertas con alumnos que no cumplen el porcentaje minimo
     */
    public List<Map<String, Object>> obtenerAlertasAsistencia(double porcentajeMinimo, int turnoId) {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql = "{CALL obtener_alertas_asistencia_turno(?, ?)}";
        
        try (Connection con = Conexion.getConnection();
             CallableStatement cs = con.prepareCall(sql)) {
            
            cs.setDouble(1, porcentajeMinimo);
            cs.setInt(2, turnoId);
            ResultSet rs = cs.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> alerta = new HashMap<>();
                alerta.put("alumnoId", rs.getInt("alumno_id"));
                alerta.put("alumnoNombre", rs.getString("alumno_nombre"));
                alerta.put("gradoNombre", rs.getString("grado_nombre"));
                alerta.put("turnoNombre", rs.getString("turno_nombre"));
                alerta.put("totalClases", rs.getInt("total_clases"));
                alerta.put("asistenciasValidas", rs.getInt("asistencias_validas"));
                alerta.put("porcentajeAsistencia", rs.getDouble("porcentaje_asistencia"));
                alerta.put("mes", rs.getInt("mes"));
                alerta.put("anio", rs.getInt("anio"));
                lista.add(alerta);
            }
            
        } catch (Exception e) {
            System.out.println("Error al obtener alertas de asistencia");
            e.printStackTrace();
        }
        
        return lista;
    }

    /**
     * GENERAR REPORTE TRIMESTRAL DE ASISTENCIA
     * 
     * @param gradoId Identificador del grado
     * @param turnoId Identificador del turno
     * @param trimestre Trimestre del reporte (1-4)
     * @param anio Ano del reporte
     * @return Lista de reportes trimestrales con evaluacion de asistencia
     */
    public List<Map<String, Object>> generarReporteTrimestral(int gradoId, int turnoId, int trimestre, int anio) {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql = "{CALL generar_reporte_trimestral_asistencia(?, ?, ?, ?)}";
        
        try (Connection con = Conexion.getConnection();
             CallableStatement cs = con.prepareCall(sql)) {
            
            cs.setInt(1, gradoId);
            cs.setInt(2, turnoId);
            cs.setInt(3, trimestre);
            cs.setInt(4, anio);
            ResultSet rs = cs.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> reporte = new HashMap<>();
                reporte.put("alumnoId", rs.getInt("alumno_id"));
                reporte.put("alumnoNombre", rs.getString("alumno_nombre"));
                reporte.put("gradoNombre", rs.getString("grado_nombre"));
                reporte.put("turnoNombre", rs.getString("turno_nombre"));
                reporte.put("totalClasesTrimestre", rs.getInt("total_clases_trimestre"));
                reporte.put("presentes", rs.getInt("presentes"));
                reporte.put("tardanzas", rs.getInt("tardanzas"));
                reporte.put("ausentes", rs.getInt("ausentes"));
                reporte.put("justificados", rs.getInt("justificados"));
                reporte.put("porcentajeAsistencia", rs.getDouble("porcentaje_asistencia"));
                reporte.put("evaluacion", rs.getString("evaluacion"));
                lista.add(reporte);
            }
            
        } catch (Exception e) {
            System.out.println("Error al generar reporte trimestral");
            e.printStackTrace();
        }
        
        return lista;
    }
}