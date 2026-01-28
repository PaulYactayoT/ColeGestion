/*
 * DAO PARA GESTION DE TAREAS ACADEMICAS
 * 
 * Funcionalidades:
 * - CRUD completo de tareas
 * - Consultas por alumno y curso
 * - Gestion de fechas de entrega
 */
package modelo;

import conexion.Conexion;
import java.sql.*;
import java.util.*;

public class TareaDAO {

    /**
     * AGREGAR NUEVA TAREA ACADEMICA
     * 
     * @param t Objeto Tarea con datos completos
     * @return true si la creacion fue exitosa
     */
    public boolean agregar(Tarea t) {
        String sql = "{CALL crear_tarea(?, ?, ?, ?, ?)}";

        try (Connection con = Conexion.getConnection(); CallableStatement cs = con.prepareCall(sql)) {
            cs.setString(1, t.getNombre());
            cs.setString(2, t.getDescripcion());
            cs.setString(3, t.getFechaEntrega());
            cs.setBoolean(4, t.isActivo());
            cs.setInt(5, t.getCursoId());

            return cs.executeUpdate() > 0;
        } catch (Exception e) {
            System.out.println("Error al agregar tarea");
            e.printStackTrace();
            return false;
        }
    }

    /**
     * ACTUALIZAR TAREA EXISTENTE
     * 
     * @param t Objeto Tarea con datos actualizados
     * @return true si la actualizacion fue exitosa
     */
    public boolean actualizar(Tarea t) {
        String sql = "{CALL actualizar_tarea(?, ?, ?, ?, ?, ?)}";

        try (Connection con = Conexion.getConnection(); CallableStatement cs = con.prepareCall(sql)) {
            cs.setInt(1, t.getId());
            cs.setString(2, t.getNombre());
            cs.setString(3, t.getDescripcion());
            cs.setString(4, t.getFechaEntrega());
            cs.setBoolean(5, t.isActivo());
            cs.setInt(6, t.getCursoId());

            return cs.executeUpdate() > 0;
        } catch (Exception e) {
            System.out.println("Error al actualizar tarea");
            e.printStackTrace();
            return false;
        }
    }

    /**
     * ELIMINAR TAREA POR ID
     * 
     * @param id Identificador de la tarea
     * @return true si la eliminacion fue exitosa
     */
    public boolean eliminar(int id) {
        String sql = "{CALL eliminar_tarea(?)}";

        try (Connection con = Conexion.getConnection(); CallableStatement cs = con.prepareCall(sql)) {
            cs.setInt(1, id);
            return cs.executeUpdate() > 0;
        } catch (Exception e) {
            System.out.println("Error al eliminar tarea");
            e.printStackTrace();
            return false;
        }
    }

    /**
     * OBTENER TAREA POR ID
     * 
     * @param id Identificador de la tarea
     * @return Objeto Tarea con datos completos o null si no existe
     */
    public Tarea obtenerPorId(int id) {
        Tarea t = null;
        String sql = "{CALL obtener_tarea_por_id(?)}";

        try (Connection con = Conexion.getConnection(); CallableStatement cs = con.prepareCall(sql)) {
            cs.setInt(1, id);
            ResultSet rs = cs.executeQuery();

            if (rs.next()) {
                t = new Tarea();
                t.setId(rs.getInt("id"));
                t.setNombre(rs.getString("nombre"));
                t.setDescripcion(rs.getString("descripcion"));
                t.setFechaEntrega(rs.getString("fecha_entrega"));
                t.setActivo(rs.getBoolean("activo"));
                t.setCursoId(rs.getInt("curso_id"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return t;
    }

    /**
     * LISTAR TAREAS POR ALUMNO ESPECIFICO
     * 
     * @param alumnoId Identificador del alumno
     * @return Lista de tareas asignadas al alumno
     */
    public List<Tarea> listarPorAlumno(int alumnoId) {
        List<Tarea> lista = new ArrayList<>();
        String sql = "{CALL obtener_tareas_por_alumno(?)}";

        try (Connection con = Conexion.getConnection(); CallableStatement cs = con.prepareCall(sql)) {
            cs.setInt(1, alumnoId);
            ResultSet rs = cs.executeQuery();

            while (rs.next()) {
                Tarea t = new Tarea();
                t.setId(rs.getInt("id"));
                t.setNombre(rs.getString("nombre"));
                t.setDescripcion(rs.getString("descripcion"));
                t.setFechaEntrega(rs.getString("fecha_entrega"));
                t.setActivo(rs.getBoolean("activo"));
                t.setCursoNombre(rs.getString("curso_nombre"));
                lista.add(t);
            }

        } catch (Exception e) {
            System.out.println("Error al listar tareas por alumno");
            e.printStackTrace();
        }

        return lista;
    }

    /**
     * LISTAR TAREAS POR CURSO ESPECIFICO
     * 
     * @param cursoId Identificador del curso
     * @return Lista de tareas del curso solicitado
     */
    public List<Tarea> listarPorCurso(int cursoId) {
        List<Tarea> lista = new ArrayList<>();
        String sql = "{CALL obtener_tareas_por_curso(?)}";

        try (Connection con = Conexion.getConnection(); CallableStatement cs = con.prepareCall(sql)) {
            cs.setInt(1, cursoId);
            ResultSet rs = cs.executeQuery();

            while (rs.next()) {
                Tarea t = new Tarea();
                t.setId(rs.getInt("id"));
                t.setNombre(rs.getString("nombre"));
                t.setDescripcion(rs.getString("descripcion"));
                t.setFechaEntrega(rs.getString("fecha_entrega"));
                t.setActivo(rs.getBoolean("activo"));
                t.setCursoId(rs.getInt("curso_id"));
                lista.add(t);
            }

        } catch (Exception e) {
            System.out.println("Error al listar tareas por curso");
            e.printStackTrace();
        }

        return lista;
    }
}