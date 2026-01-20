/*
 * DAO PARA GESTION DE PROFESORES
 * 
 * Funcionalidades:
 * - CRUD completo de profesores
 * - Consulta por credenciales de usuario
 * - Integracion con sistema de autenticacion
 */
package modelo;

import conexion.Conexion;
import java.sql.*;
import java.util.*;

public class ProfesorDAO {

    /**
     * OBTENER PROFESOR POR NOMBRE DE USUARIO
     * 
     * @param username Nombre de usuario del profesor
     * @return Objeto Profesor con datos completos o null si no existe
     */
    public Profesor obtenerPorUsername(String username) {
        System.out.println("[ProfesorDAO] Buscando profesor para username: " + username);
        
        Profesor profesor = null;
        String sql = "{CALL obtener_profesor_por_username(?)}";

        try (Connection con = Conexion.getConnection();
             CallableStatement cs = con.prepareCall(sql)) {
            
            cs.setString(1, username);
            ResultSet rs = cs.executeQuery();

            if (rs.next()) {
                profesor = mapearProfesor(rs);
                System.out.println("[ProfesorDAO] Profesor encontrado: " + profesor.getNombres() + " " + profesor.getApellidos() + " (ID: " + profesor.getId() + ")");
            } else {
                System.out.println("[ProfesorDAO] No se encontro profesor para username: " + username);
            }

        } catch (Exception e) {
            System.out.println("[ProfesorDAO] Error al buscar profesor por username: " + e.getMessage());
            e.printStackTrace();
        }

        return profesor;
    }

    /**
     * LISTAR TODOS LOS PROFESORES
     * 
     * @return Lista completa de profesores registrados
     */
    public List<Profesor> listar() {
        List<Profesor> lista = new ArrayList<>();
        String sql = "{CALL obtener_profesores()}";

        try (Connection con = Conexion.getConnection();
             CallableStatement cs = con.prepareCall(sql);
             ResultSet rs = cs.executeQuery()) {

            while (rs.next()) {
                lista.add(mapearProfesor(rs));
            }

        } catch (Exception e) {
            System.out.println("Error al listar profesores: " + e.getMessage());
            e.printStackTrace();
        }

        return lista;
    }

    /**
     * AGREGAR NUEVO PROFESOR
     * 
     * @param p Objeto Profesor con datos del nuevo profesor
     * @return true si el registro fue exitoso
     */
    public boolean agregar(Profesor p) {
        String sql = "{CALL crear_profesor(?, ?, ?, ?)}";

        try (Connection con = Conexion.getConnection();
             CallableStatement cs = con.prepareCall(sql)) {

            cs.setString(1, p.getNombres());
            cs.setString(2, p.getApellidos());
            cs.setString(3, p.getCorreo());
            cs.setString(4, p.getEspecialidad());
            
            ResultSet rs = cs.executeQuery();
            if (rs.next()) {
                p.setId(rs.getInt("id"));
                System.out.println("Profesor agregado: " + p.getNombres() + " " + p.getApellidos() + " (ID: " + p.getId() + ")");
                return true;
            }
            return false;

        } catch (Exception e) {
            System.out.println("Error al agregar profesor: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * OBTENER PROFESOR POR ID
     * 
     * @param id Identificador unico del profesor
     * @return Objeto Profesor o null si no existe
     */
    public Profesor obtenerPorId(int id) {
        Profesor p = null;
        String sql = "{CALL obtener_profesor_por_id(?)}";

        try (Connection con = Conexion.getConnection();
             CallableStatement cs = con.prepareCall(sql)) {
            
            cs.setInt(1, id);
            ResultSet rs = cs.executeQuery();

            if (rs.next()) {
                p = mapearProfesor(rs);
            }

        } catch (Exception e) {
            System.out.println("Error al obtener profesor ID " + id + ": " + e.getMessage());
            e.printStackTrace();
        }

        return p;
    }

    /**
     * ACTUALIZAR DATOS DE PROFESOR EXISTENTE
     * 
     * @param p Objeto Profesor con datos actualizados
     * @return true si la actualizacion fue exitosa
     */
    public boolean actualizar(Profesor p) {
        String sql = "{CALL actualizar_profesor(?, ?, ?, ?, ?)}";

        try (Connection con = Conexion.getConnection();
             CallableStatement cs = con.prepareCall(sql)) {

            cs.setInt(1, p.getId());
            cs.setString(2, p.getNombres());
            cs.setString(3, p.getApellidos());
            cs.setString(4, p.getCorreo());
            cs.setString(5, p.getEspecialidad());
            
            int resultado = cs.executeUpdate();
            System.out.println("Profesor actualizado: " + p.getNombres() + " " + p.getApellidos());
            return resultado > 0;

        } catch (Exception e) {
            System.out.println("Error al actualizar profesor: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * ELIMINAR PROFESOR POR ID
     * 
     * @param id Identificador del profesor a eliminar
     * @return true si la eliminacion fue exitosa
     */
    public boolean eliminar(int id) {
        String sql = "{CALL eliminar_profesor(?)}";

        try (Connection con = Conexion.getConnection();
             CallableStatement cs = con.prepareCall(sql)) {

            cs.setInt(1, id);
            int resultado = cs.executeUpdate();
            System.out.println("Profesor eliminado ID: " + id);
            return resultado > 0;

        } catch (Exception e) {
            System.out.println("Error al eliminar profesor ID " + id + ": " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * METODO AUXILIAR PARA MAPEAR RESULTADO DE CONSULTA A OBJETO PROFESOR
     * 
     * @param rs ResultSet con datos de la base de datos
     * @return Objeto Profesor mapeado
     * @throws SQLException Si hay error en el acceso a datos
     */
    private Profesor mapearProfesor(ResultSet rs) throws SQLException {
        Profesor p = new Profesor();
        p.setId(rs.getInt("id"));
        p.setNombres(rs.getString("nombres"));
        p.setApellidos(rs.getString("apellidos"));
        p.setCorreo(rs.getString("correo"));
        p.setEspecialidad(rs.getString("especialidad"));
        return p;
    }
}