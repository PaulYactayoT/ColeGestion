/*
 * 
 * Funcionalidades:
 * - CRUD completo de notas academicas
 * - Consultas por alumno y curso
 * - Integracion con stored procedures de base de datos
 * 
 * NOTA: La tabla 'nota' NO tiene curso_id directamente.
 *       El curso_id se obtiene a través de la tabla 'tarea'.
 */
package modelo;

import conexion.Conexion;
import java.sql.*;
import java.util.*;

public class NotaDAO {

    /**
     * AGREGAR NUEVA NOTA ACADEMICA
     * 
     * @param n Objeto Nota con datos de la calificacion
     * @return true si la operacion fue exitosa, false en caso contrario
     */
    public boolean agregar(Nota n) {
        String sql = "{CALL crear_nota(?, ?, ?, ?)}";

        try (Connection con = Conexion.getConnection(); 
             CallableStatement cs = con.prepareCall(sql)) {
            
            cs.setInt(1, n.getCursoId());
            cs.setInt(2, n.getTareaId());
            cs.setInt(3, n.getAlumnoId());
            cs.setDouble(4, n.getNota());

            return cs.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("Error al agregar nota");
            e.printStackTrace();
            return false;
        }
    }

    /**
     * ACTUALIZAR NOTA EXISTENTE
     * 
     * @param n Objeto Nota con datos actualizados
     * @return true si la actualizacion fue exitosa
     */
    public boolean actualizar(Nota n) {
        String sql = "{CALL actualizar_nota(?, ?, ?, ?, ?)}";

        try (Connection con = Conexion.getConnection(); 
             CallableStatement cs = con.prepareCall(sql)) {
            
            cs.setInt(1, n.getId());
            cs.setInt(2, n.getTareaId());
            cs.setInt(3, n.getAlumnoId());
            cs.setDouble(4, n.getNota());
            cs.setInt(5, n.getCursoId());

            return cs.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("Error al actualizar nota");
            e.printStackTrace();
            return false;
        }
    }

    /**
     * ELIMINAR NOTA POR ID
     * 
     * @param id Identificador unico de la nota
     * @return true si la eliminacion fue exitosa
     */
    public boolean eliminar(int id) {
        String sql = "{CALL eliminar_nota(?)}";

        try (Connection con = Conexion.getConnection(); 
             CallableStatement cs = con.prepareCall(sql)) {
            
            cs.setInt(1, id);
            return cs.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("Error al eliminar nota");
            e.printStackTrace();
            return false;
        }
    }

    /**
     * OBTENER NOTA POR ID CON INFORMACION COMPLETA
     * 
     * @param id Identificador de la nota
     * @return Objeto Nota con todos los datos o null si no existe
     */
    public Nota obtenerPorId(int id) {
        Nota n = null;
        String sql = "{CALL obtener_nota_por_id(?)}";

        try (Connection con = Conexion.getConnection(); 
             CallableStatement cs = con.prepareCall(sql)) {
            
            cs.setInt(1, id);
            ResultSet rs = cs.executeQuery();

            if (rs.next()) {
                n = new Nota();
                n.setId(rs.getInt("id"));
                n.setCursoId(rs.getInt("curso_id"));
                n.setTareaId(rs.getInt("tarea_id"));
                n.setAlumnoId(rs.getInt("alumno_id"));
                n.setNota(rs.getDouble("nota"));
                n.setAlumnoNombre(rs.getString("alumno_nombres") + " " + rs.getString("alumno_apellidos"));
                n.setTareaNombre(rs.getString("tarea_nombre"));
                n.setCursoNombre(rs.getString("curso_nombre"));
            }

        } catch (Exception e) {
            System.out.println("Error al obtener nota por id");
            e.printStackTrace();
        }
        return n;
    }

    /**
     * LISTAR NOTAS POR ALUMNO ESPECIFICO
     * 
     * @param alumnoId Identificador del alumno
     * @return Lista de notas del alumno solicitado
     */
    public List<Nota> listarPorAlumno(int alumnoId) {
        List<Nota> lista = new ArrayList<>();
        String sql = "{CALL obtener_notas_por_alumno(?)}";

        try (Connection con = Conexion.getConnection(); 
             CallableStatement cs = con.prepareCall(sql)) {
            
            cs.setInt(1, alumnoId);
            ResultSet rs = cs.executeQuery();

            while (rs.next()) {
                Nota n = new Nota();
                n.setId(rs.getInt("id"));
                n.setCursoId(rs.getInt("curso_id"));
                n.setTareaId(rs.getInt("tarea_id"));
                n.setAlumnoId(rs.getInt("alumno_id"));
                n.setNota(rs.getDouble("nota"));
                n.setTareaNombre(rs.getString("tarea_nombre"));
                n.setCursoNombre(rs.getString("curso_nombre"));
                lista.add(n);
            }

        } catch (Exception e) {
            System.out.println("Error al listar notas por alumno");
            e.printStackTrace();
        }

        return lista;
    }

    /**
     * LISTAR NOTAS POR CURSO ESPECIFICO
     * 
     * @param cursoId Identificador del curso
     * @return Lista de notas del curso solicitado
     */
    public List<Nota> listarPorCurso(int cursoId) {
        List<Nota> lista = new ArrayList<>();
        String sql = "{CALL obtener_notas_por_curso(?)}";

        try (Connection con = Conexion.getConnection(); 
             CallableStatement cs = con.prepareCall(sql)) {
            
            cs.setInt(1, cursoId);
            ResultSet rs = cs.executeQuery();

            while (rs.next()) {
                Nota n = new Nota();
                n.setId(rs.getInt("id"));
                n.setCursoId(rs.getInt("curso_id"));
                n.setTareaId(rs.getInt("tarea_id"));
                n.setAlumnoId(rs.getInt("alumno_id"));
                n.setNota(rs.getDouble("nota"));
                n.setAlumnoNombre(rs.getString("alumno_nombres") + " " + rs.getString("alumno_apellidos"));
                n.setTareaNombre(rs.getString("tarea_nombre"));
                n.setCursoNombre(rs.getString("curso_nombre"));
                lista.add(n);
            }

        } catch (Exception e) {
            System.out.println("Error al listar notas por curso");
            e.printStackTrace();
        }

        return lista;
    }
    
    /**
     * LISTAR NOTAS POR TAREA ESPECIFICA
     * 
     * @param tareaId Identificador de la tarea
     * @return Lista de notas de la tarea solicitada
     */
    public List<Nota> listarPorTarea(int tareaId) {
        List<Nota> lista = new ArrayList<>();
        String sql = "{CALL obtener_notas_por_tarea(?)}";

        try (Connection con = Conexion.getConnection(); 
             CallableStatement cs = con.prepareCall(sql)) {
            
            cs.setInt(1, tareaId);
            ResultSet rs = cs.executeQuery();

            while (rs.next()) {
                Nota n = new Nota();
                n.setId(rs.getInt("id"));
                n.setCursoId(rs.getInt("curso_id"));
                n.setTareaId(rs.getInt("tarea_id"));
                n.setAlumnoId(rs.getInt("alumno_id"));
                n.setNota(rs.getDouble("nota"));
                n.setAlumnoNombre(rs.getString("alumno_nombres") + " " + rs.getString("alumno_apellidos"));
                n.setCursoNombre(rs.getString("curso_nombre"));
                lista.add(n);
            }

        } catch (Exception e) {
            System.out.println("Error al listar notas por tarea");
            e.printStackTrace();
        }

        return lista;
    }
    
    /**
     * OBTENER PROMEDIO DE ALUMNO
     * 
     * @param alumnoId Identificador del alumno
     * @param cursoId Identificador del curso (null para promedio general)
     * @return Promedio de notas del alumno
     */
    public double obtenerPromedioAlumno(int alumnoId, Integer cursoId) {
        double promedio = 0.0;
        String sql = "{CALL obtener_promedio_alumno(?, ?)}";

        try (Connection con = Conexion.getConnection(); 
             CallableStatement cs = con.prepareCall(sql)) {
            
            cs.setInt(1, alumnoId);
            if (cursoId != null) {
                cs.setInt(2, cursoId);
            } else {
                cs.setNull(2, Types.INTEGER);
            }
            
            ResultSet rs = cs.executeQuery();

            if (rs.next()) {
                promedio = rs.getDouble("promedio");
            }

        } catch (Exception e) {
            System.out.println("Error al obtener promedio del alumno");
            e.printStackTrace();
        }

        return promedio;
    }
}