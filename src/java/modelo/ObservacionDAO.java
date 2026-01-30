/*
 * DAO PARA GESTION DE OBSERVACIONES ACADEMICAS
 * 
 * Funcionalidades:
 * - CRUD de observaciones sobre alumnos
 * - Consultas por alumno y curso
 * - Registro de comentarios academicos y conductuales
 */
package modelo;

import conexion.Conexion;
import java.sql.*;
import java.util.*;

public class ObservacionDAO {

    /**
     * AGREGAR NUEVA OBSERVACION ACADEMICA
     * 
     * @param o Objeto Observacion con texto y referencias
     * @return true si el registro fue exitoso
     */
    public boolean agregar(Observacion o) {
        String sql = "{CALL crear_observacion(?, ?, ?)}";

        try (Connection con = Conexion.getConnection(); CallableStatement cs = con.prepareCall(sql)) {
            cs.setInt(1, o.getCursoId());
            cs.setInt(2, o.getAlumnoId());
            cs.setString(3, o.getTexto());
            return cs.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("Error al agregar observacion");
            e.printStackTrace();
            return false;
        }
    }

    /**
     * ACTUALIZAR OBSERVACION EXISTENTE
     * 
     * @param o Objeto Observacion con datos actualizados
     * @return true si la actualizacion fue exitosa
     */
    public boolean actualizar(Observacion o) {
        String sql = "{CALL actualizar_observacion(?, ?, ?, ?)}";

        try (Connection con = Conexion.getConnection(); CallableStatement cs = con.prepareCall(sql)) {
            cs.setInt(1, o.getId());
            cs.setInt(2, o.getAlumnoId());
            cs.setString(3, o.getTexto());
            cs.setInt(4, o.getCursoId());
            return cs.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("Error al actualizar observacion");
            e.printStackTrace();
            return false;
        }
    }

    /**
     * ELIMINAR OBSERVACION POR ID
     * 
     * @param id Identificador unico de la observacion
     * @return true si la eliminacion fue exitosa
     */
    public boolean eliminar(int id) {
        String sql = "{CALL eliminar_observacion(?)}";

        try (Connection con = Conexion.getConnection(); CallableStatement cs = con.prepareCall(sql)) {
            cs.setInt(1, id);
            return cs.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("Error al eliminar observacion");
            e.printStackTrace();
            return false;
        }
    }

    /**
     * OBTENER OBSERVACION POR ID CON INFORMACION COMPLETA
     * 
     * @param id Identificador de la observacion
     * @return Objeto Observacion con datos completos o null si no existe
     */
    public Observacion obtenerPorId(int id) {
        Observacion o = null;
        String sql = "{CALL obtener_observacion_por_id(?)}";

        try (Connection con = Conexion.getConnection(); CallableStatement cs = con.prepareCall(sql)) {
            cs.setInt(1, id);
            ResultSet rs = cs.executeQuery();

            if (rs.next()) {
                o = new Observacion();
                o.setId(rs.getInt("id"));
                o.setCursoId(rs.getInt("curso_id"));
                o.setAlumnoId(rs.getInt("alumno_id"));
                o.setTexto(rs.getString("texto"));
                o.setAlumnoNombre(rs.getString("alumno_nombres") + " " + rs.getString("alumno_apellidos"));
                o.setCursoNombre(rs.getString("curso_nombre"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return o;
    }

    /**
     * LISTAR OBSERVACIONES POR ALUMNO ESPECIFICO
     * 
     * @param alumnoId Identificador del alumno
     * @return Lista de observaciones del alumno solicitado
     */
    public List<Observacion> listarPorAlumno(int alumnoId) {
        List<Observacion> lista = new ArrayList<>();
        String sql = "{CALL obtener_observaciones_por_alumno(?)}";

        try (Connection con = Conexion.getConnection(); CallableStatement cs = con.prepareCall(sql)) {
            cs.setInt(1, alumnoId);
            ResultSet rs = cs.executeQuery();

            while (rs.next()) {
                Observacion o = new Observacion();
                o.setId(rs.getInt("id"));
                o.setCursoId(rs.getInt("curso_id"));
                o.setAlumnoId(rs.getInt("alumno_id"));
                o.setTexto(rs.getString("texto"));
                o.setCursoNombre(rs.getString("curso_nombre"));
                lista.add(o);
            }

        } catch (Exception e) {
            System.out.println("Error al listar observaciones por alumno");
            e.printStackTrace();
        }

        return lista;
    }

    /**
     * LISTAR OBSERVACIONES POR CURSO ESPECIFICO
     * 
     * @param cursoId Identificador del curso
     * @return Lista de observaciones del curso solicitado
     */
    public List<Observacion> listarPorCurso(int cursoId) {
        List<Observacion> lista = new ArrayList<>();
        String sql = "{CALL obtener_observaciones_por_curso(?)}";

        try (Connection con = Conexion.getConnection(); CallableStatement cs = con.prepareCall(sql)) {
            cs.setInt(1, cursoId);
            ResultSet rs = cs.executeQuery();
            while (rs.next()) {
                Observacion o = new Observacion();
                o.setId(rs.getInt("id"));
                o.setCursoId(rs.getInt("curso_id"));
                o.setAlumnoId(rs.getInt("alumno_id"));
                o.setTexto(rs.getString("texto"));
                o.setAlumnoNombre(rs.getString("alumno_nombres") + " " + rs.getString("alumno_apellidos"));
                lista.add(o);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return lista;
    }
}