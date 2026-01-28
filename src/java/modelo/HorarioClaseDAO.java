/*
 * DAO PARA GESTION DE HORARIOS DE CLASES
 * 
 * Funcionalidades:
 * - Consulta de horarios por curso y profesor
 * - Creación de nuevos horarios académicos
 * - Actualización y eliminación de horarios
 * - Integración con turnos y aulas
 * - Validación de conflictos de horarios
 * 
 * @author Tu Nombre
 */
package modelo;

import conexion.Conexion;
import java.sql.*;
import java.util.*;

public class HorarioClaseDAO {

    /**
     * OBTENER HORARIOS POR CURSO Y TURNO
     * Utiliza el stored procedure: obtener_horarios_por_curso_turno
     * 
     * @param cursoId Identificador del curso
     * @param turnoId Identificador del turno
     * @return Lista de horarios que coinciden con los criterios
     */
    public List<HorarioClase> obtenerHorariosPorCursoTurno(int cursoId, int turnoId) {
        List<HorarioClase> lista = new ArrayList<>();
        String sql = "{CALL obtener_horarios_por_curso_turno(?, ?)}";
        
        try (Connection con = Conexion.getConnection();
             CallableStatement cs = con.prepareCall(sql)) {
            
            cs.setInt(1, cursoId);
            cs.setInt(2, turnoId);
            ResultSet rs = cs.executeQuery();
            
            while (rs.next()) {
                HorarioClase h = new HorarioClase();
                h.setId(rs.getInt("id"));
                h.setCursoId(rs.getInt("curso_id"));
                h.setTurnoId(rs.getInt("turno_id"));
                h.setDiaSemana(rs.getString("dia_semana"));
                h.setHoraInicio(rs.getString("hora_inicio"));
                h.setHoraFin(rs.getString("hora_fin"));
                h.setAulaId(rs.getInt("aula_id"));
                h.setActivo(rs.getBoolean("activo"));
                
                // Campos adicionales del JOIN
                h.setCursoNombre(rs.getString("curso_nombre"));
                h.setTurnoNombre(rs.getString("turno_nombre"));
                h.setAulaNombre(rs.getString("aula_nombre"));
                h.setSedeNombre(rs.getString("sede_nombre"));
                
                lista.add(h);
            }
            
        } catch (SQLException e) {
            System.err.println("Error al obtener horarios por curso y turno: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }

    /**
     * OBTENER HORARIOS POR PROFESOR Y TURNO
     * Utiliza el stored procedure: obtener_horarios_por_profesor_turno
     * 
     * @param profesorId Identificador del profesor
     * @param turnoId Identificador del turno
     * @return Lista de horarios asignados al profesor en el turno especificado
     */
    public List<HorarioClase> obtenerHorariosPorProfesorTurno(int profesorId, int turnoId) {
        List<HorarioClase> lista = new ArrayList<>();
        String sql = "{CALL obtener_horarios_por_profesor_turno(?, ?)}";
        
        try (Connection con = Conexion.getConnection();
             CallableStatement cs = con.prepareCall(sql)) {
            
            cs.setInt(1, profesorId);
            cs.setInt(2, turnoId);
            ResultSet rs = cs.executeQuery();
            
            while (rs.next()) {
                HorarioClase h = new HorarioClase();
                h.setId(rs.getInt("id"));
                h.setCursoId(rs.getInt("curso_id"));
                h.setTurnoId(rs.getInt("turno_id"));
                h.setDiaSemana(rs.getString("dia_semana"));
                h.setHoraInicio(rs.getString("hora_inicio"));
                h.setHoraFin(rs.getString("hora_fin"));
                h.setAulaId(rs.getInt("aula_id"));
                
                // Campos adicionales del JOIN
                h.setCursoNombre(rs.getString("curso_nombre"));
                h.setGradoNombre(rs.getString("grado_nombre"));
                h.setAulaNombre(rs.getString("aula_nombre"));
                h.setTurnoNombre(rs.getString("turno_nombre"));
                
                lista.add(h);
            }
            
        } catch (SQLException e) {
            System.err.println("Error al obtener horarios por profesor y turno: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }

    /**
     * CREAR NUEVO HORARIO DE CLASE
     * Utiliza el stored procedure: crear_horario_clase
     * 
     * @param h Objeto HorarioClase con todos los datos necesarios
     * @return ID del horario creado, o -1 si falla
     */
    public int crearHorarioClase(HorarioClase h) {
        String sql = "{CALL crear_horario_clase(?, ?, ?, ?, ?, ?)}";
        
        try (Connection con = Conexion.getConnection();
             CallableStatement cs = con.prepareCall(sql)) {
            
            cs.setInt(1, h.getCursoId());
            cs.setInt(2, h.getTurnoId());
            cs.setString(3, h.getDiaSemana());
            cs.setString(4, h.getHoraInicio());
            cs.setString(5, h.getHoraFin());
            cs.setInt(6, h.getAulaId());
            
            ResultSet rs = cs.executeQuery();
            if (rs.next()) {
                return rs.getInt("id");
            }
            
        } catch (SQLException e) {
            System.err.println("Error al crear horario de clase: " + e.getMessage());
            e.printStackTrace();
        }
        
        return -1;
    }

    /**
     * OBTENER TODOS LOS HORARIOS ACTIVOS
     * 
     * @return Lista de todos los horarios activos del sistema
     */
    public List<HorarioClase> obtenerTodosLosHorarios() {
        List<HorarioClase> lista = new ArrayList<>();
        String sql = "SELECT h.*, c.nombre as curso_nombre, t.nombre as turno_nombre, " +
                     "a.nombre as aula_nombre, s.nombre as sede_nombre, g.nombre as grado_nombre " +
                     "FROM horario_clase h " +
                     "JOIN curso c ON h.curso_id = c.id " +
                     "JOIN turno t ON h.turno_id = t.id " +
                     "JOIN aula a ON h.aula_id = a.id " +
                     "JOIN sede s ON a.sede_id = s.id " +
                     "JOIN grado g ON c.grado_id = g.id " +
                     "WHERE h.activo = 1 " +
                     "ORDER BY FIELD(h.dia_semana, 'LUNES', 'MARTES', 'MIERCOLES', 'JUEVES', 'VIERNES', 'SABADO'), " +
                     "h.hora_inicio";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                HorarioClase h = mapearResultSet(rs);
                lista.add(h);
            }
            
        } catch (SQLException e) {
            System.err.println("Error al obtener todos los horarios: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }

    /**
     * OBTENER HORARIO POR ID
     * 
     * @param id Identificador del horario
     * @return Objeto HorarioClase o null si no existe
     */
    public HorarioClase obtenerPorId(int id) {
        String sql = "SELECT h.*, c.nombre as curso_nombre, t.nombre as turno_nombre, " +
                     "a.nombre as aula_nombre, s.nombre as sede_nombre, g.nombre as grado_nombre " +
                     "FROM horario_clase h " +
                     "JOIN curso c ON h.curso_id = c.id " +
                     "JOIN turno t ON h.turno_id = t.id " +
                     "JOIN aula a ON h.aula_id = a.id " +
                     "JOIN sede s ON a.sede_id = s.id " +
                     "JOIN grado g ON c.grado_id = g.id " +
                     "WHERE h.id = ?";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return mapearResultSet(rs);
            }
            
        } catch (SQLException e) {
            System.err.println("Error al obtener horario por ID: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }

    /**
     * ACTUALIZAR HORARIO DE CLASE
     * 
     * @param h Objeto HorarioClase con los datos actualizados
     * @return true si la actualización fue exitosa
     */
    public boolean actualizarHorarioClase(HorarioClase h) {
        String sql = "UPDATE horario_clase SET curso_id = ?, turno_id = ?, dia_semana = ?, " +
                     "hora_inicio = ?, hora_fin = ?, aula_id = ?, activo = ? WHERE id = ?";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, h.getCursoId());
            ps.setInt(2, h.getTurnoId());
            ps.setString(3, h.getDiaSemana());
            ps.setString(4, h.getHoraInicio());
            ps.setString(5, h.getHoraFin());
            ps.setInt(6, h.getAulaId());
            ps.setBoolean(7, h.isActivo());
            ps.setInt(8, h.getId());
            
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("Error al actualizar horario de clase: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * ELIMINAR HORARIO DE CLASE (Soft Delete)
     * 
     * @param id Identificador del horario
     * @return true si la eliminación fue exitosa
     */
    public boolean eliminarHorarioClase(int id) {
        String sql = "UPDATE horario_clase SET activo = 0 WHERE id = ?";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("Error al eliminar horario de clase: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * ELIMINAR HORARIO DE CLASE (Hard Delete)
     * Solo usar si realmente necesitas eliminación física
     * 
     * @param id Identificador del horario
     * @return true si la eliminación fue exitosa
     */
    public boolean eliminarHorarioClasePermanente(int id) {
        String sql = "DELETE FROM horario_clase WHERE id = ?";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("Error al eliminar permanentemente horario: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * OBTENER HORARIOS POR DÍA DE LA SEMANA
     * 
     * @param diaSemana Día de la semana (LUNES, MARTES, etc.)
     * @param turnoId Identificador del turno
     * @return Lista de horarios del día especificado
     */
    public List<HorarioClase> obtenerHorariosPorDia(String diaSemana, int turnoId) {
        List<HorarioClase> lista = new ArrayList<>();
        String sql = "SELECT h.*, c.nombre as curso_nombre, t.nombre as turno_nombre, " +
                     "a.nombre as aula_nombre, s.nombre as sede_nombre, g.nombre as grado_nombre " +
                     "FROM horario_clase h " +
                     "JOIN curso c ON h.curso_id = c.id " +
                     "JOIN turno t ON h.turno_id = t.id " +
                     "JOIN aula a ON h.aula_id = a.id " +
                     "JOIN sede s ON a.sede_id = s.id " +
                     "JOIN grado g ON c.grado_id = g.id " +
                     "WHERE h.dia_semana = ? AND h.turno_id = ? AND h.activo = 1 " +
                     "ORDER BY h.hora_inicio";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, diaSemana);
            ps.setInt(2, turnoId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                HorarioClase h = mapearResultSet(rs);
                lista.add(h);
            }
            
        } catch (SQLException e) {
            System.err.println("Error al obtener horarios por día: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }

    /**
     * OBTENER HORARIOS POR AULA
     * 
     * @param aulaId Identificador del aula
     * @return Lista de horarios asignados al aula
     */
    public List<HorarioClase> obtenerHorariosPorAula(int aulaId) {
        List<HorarioClase> lista = new ArrayList<>();
        String sql = "SELECT h.*, c.nombre as curso_nombre, t.nombre as turno_nombre, " +
                     "a.nombre as aula_nombre, s.nombre as sede_nombre, g.nombre as grado_nombre " +
                     "FROM horario_clase h " +
                     "JOIN curso c ON h.curso_id = c.id " +
                     "JOIN turno t ON h.turno_id = t.id " +
                     "JOIN aula a ON h.aula_id = a.id " +
                     "JOIN sede s ON a.sede_id = s.id " +
                     "JOIN grado g ON c.grado_id = g.id " +
                     "WHERE h.aula_id = ? AND h.activo = 1 " +
                     "ORDER BY FIELD(h.dia_semana, 'LUNES', 'MARTES', 'MIERCOLES', 'JUEVES', 'VIERNES', 'SABADO'), " +
                     "h.hora_inicio";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, aulaId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                HorarioClase h = mapearResultSet(rs);
                lista.add(h);
            }
            
        } catch (SQLException e) {
            System.err.println("Error al obtener horarios por aula: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }

    /**
     * VERIFICAR CONFLICTO DE HORARIOS
     * Verifica si existe un conflicto de horario en el aula
     * 
     * @param h HorarioClase a verificar
     * @return true si existe conflicto
     */
    public boolean existeConflictoHorario(HorarioClase h) {
        String sql = "SELECT COUNT(*) as total FROM horario_clase " +
                     "WHERE aula_id = ? AND turno_id = ? AND dia_semana = ? " +
                     "AND activo = 1 " +
                     "AND ((hora_inicio < ? AND hora_fin > ?) OR " +
                     "(hora_inicio < ? AND hora_fin > ?) OR " +
                     "(hora_inicio >= ? AND hora_fin <= ?))";
        
        if (h.getId() > 0) {
            sql += " AND id != ?";
        }
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, h.getAulaId());
            ps.setInt(2, h.getTurnoId());
            ps.setString(3, h.getDiaSemana());
            ps.setString(4, h.getHoraFin());
            ps.setString(5, h.getHoraInicio());
            ps.setString(6, h.getHoraFin());
            ps.setString(7, h.getHoraInicio());
            ps.setString(8, h.getHoraInicio());
            ps.setString(9, h.getHoraFin());
            
            if (h.getId() > 0) {
                ps.setInt(10, h.getId());
            }
            
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("total") > 0;
            }
            
        } catch (SQLException e) {
            System.err.println("Error al verificar conflicto de horario: " + e.getMessage());
            e.printStackTrace();
        }
        
        return false;
    }

    /**
     * OBTENER HORARIOS POR GRADO
     * 
     * @param gradoId Identificador del grado
     * @param turnoId Identificador del turno
     * @return Lista de horarios del grado
     */
    public List<HorarioClase> obtenerHorariosPorGrado(int gradoId, int turnoId) {
        List<HorarioClase> lista = new ArrayList<>();
        String sql = "SELECT h.*, c.nombre as curso_nombre, t.nombre as turno_nombre, " +
                     "a.nombre as aula_nombre, s.nombre as sede_nombre, g.nombre as grado_nombre " +
                     "FROM horario_clase h " +
                     "JOIN curso c ON h.curso_id = c.id " +
                     "JOIN turno t ON h.turno_id = t.id " +
                     "JOIN aula a ON h.aula_id = a.id " +
                     "JOIN sede s ON a.sede_id = s.id " +
                     "JOIN grado g ON c.grado_id = g.id " +
                     "WHERE c.grado_id = ? AND h.turno_id = ? AND h.activo = 1 " +
                     "ORDER BY FIELD(h.dia_semana, 'LUNES', 'MARTES', 'MIERCOLES', 'JUEVES', 'VIERNES', 'SABADO'), " +
                     "h.hora_inicio";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, gradoId);
            ps.setInt(2, turnoId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                HorarioClase h = mapearResultSet(rs);
                lista.add(h);
            }
            
        } catch (SQLException e) {
            System.err.println("Error al obtener horarios por grado: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }

    /**
     * MÉTODO AUXILIAR: Mapear ResultSet a HorarioClase
     * Centraliza la lógica de mapeo para evitar código duplicado
     * 
     * @param rs ResultSet con los datos
     * @return Objeto HorarioClase mapeado
     * @throws SQLException si hay error al leer el ResultSet
     */
    private HorarioClase mapearResultSet(ResultSet rs) throws SQLException {
        HorarioClase h = new HorarioClase();
        h.setId(rs.getInt("id"));
        h.setCursoId(rs.getInt("curso_id"));
        h.setTurnoId(rs.getInt("turno_id"));
        h.setDiaSemana(rs.getString("dia_semana"));
        h.setHoraInicio(rs.getString("hora_inicio"));
        h.setHoraFin(rs.getString("hora_fin"));
        h.setAulaId(rs.getInt("aula_id"));
        h.setActivo(rs.getBoolean("activo"));
        
        // Campos adicionales (si existen en el ResultSet)
        try {
            h.setCursoNombre(rs.getString("curso_nombre"));
            h.setTurnoNombre(rs.getString("turno_nombre"));
            h.setAulaNombre(rs.getString("aula_nombre"));
            h.setSedeNombre(rs.getString("sede_nombre"));
            h.setGradoNombre(rs.getString("grado_nombre"));
        } catch (SQLException e) {
            // Los campos adicionales pueden no existir en algunos queries
        }
        
        return h;
    }

    /**
     * CONTAR HORARIOS POR CURSO
     * 
     * @param cursoId Identificador del curso
     * @return Cantidad de horarios del curso
     */
    public int contarHorariosPorCurso(int cursoId) {
        String sql = "SELECT COUNT(*) as total FROM horario_clase " +
                     "WHERE curso_id = ? AND activo = 1";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, cursoId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("total");
            }
            
        } catch (SQLException e) {
            System.err.println("Error al contar horarios por curso: " + e.getMessage());
            e.printStackTrace();
        }
        
        return 0;
    }
}