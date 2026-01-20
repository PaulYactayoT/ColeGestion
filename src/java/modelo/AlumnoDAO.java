/*
 * DAO PARA GESTION DE ALUMNOS
 * 
 * Funcionalidades:
 * - CRUD completo de alumnos
 * - Consultas por grado y curso
 * - Integracion con sistema academico
 */
package modelo;

import conexion.Conexion;
import java.sql.*;
import java.util.*;

public class AlumnoDAO {

    /**
     * LISTAR ALUMNOS POR GRADO ACADEMICO
     * 
     * @param gradoId Identificador del grado
     * @return Lista de alumnos pertenecientes al grado especificado
     */
    public List<Alumno> listarPorGrado(int gradoId) {
        List<Alumno> lista = new ArrayList<>();
        String sql = "{CALL obtener_alumnos_por_grado(?)}";

        try (Connection con = Conexion.getConnection(); 
             CallableStatement cs = con.prepareCall(sql)) {
            
            cs.setInt(1, gradoId);
            ResultSet rs = cs.executeQuery();
            
            while (rs.next()) {
                Alumno a = new Alumno();
                a.setId(rs.getInt("id"));
                a.setNombres(rs.getString("nombres"));
                a.setApellidos(rs.getString("apellidos"));
                a.setCorreo(rs.getString("correo"));
                
                // Convertir fecha SQL a LocalDate
                java.sql.Date fechaNac = rs.getDate("fecha_nacimiento");
                if (fechaNac != null) {
                    a.setFechaNacimiento(fechaNac.toLocalDate());
                }
                
                a.setGradoId(rs.getInt("grado_id"));
                
                // Campos adicionales si existen en el SP
                try {
                    a.setCodigoAlumno(rs.getString("codigo_alumno"));
                    a.setEstadoFromString(rs.getString("estado"));
                } catch (SQLException e) {
                    // Campos opcionales, ignorar si no existen
                }
                
                lista.add(a);
            }
            
        } catch (Exception e) {
            System.out.println("Error al listar alumnos por grado: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }

    /**
     * LISTAR TODOS LOS ALUMNOS REGISTRADOS
     * 
     * @return Lista completa de alumnos
     */
    public List<Alumno> listar() {
        List<Alumno> lista = new ArrayList<>();
        String sql = "{CALL obtener_alumnos()}";

        try (Connection con = Conexion.getConnection(); 
             CallableStatement cs = con.prepareCall(sql); 
             ResultSet rs = cs.executeQuery()) {
            
            while (rs.next()) {
                Alumno a = new Alumno();
                a.setId(rs.getInt("id"));
                a.setNombres(rs.getString("nombres"));
                a.setApellidos(rs.getString("apellidos"));
                a.setCorreo(rs.getString("correo"));
                
                // Convertir fecha SQL a LocalDate
                java.sql.Date fechaNac = rs.getDate("fecha_nacimiento");
                if (fechaNac != null) {
                    a.setFechaNacimiento(fechaNac.toLocalDate());
                }
                
                a.setGradoId(rs.getInt("grado_id"));
                
                // Campos adicionales
                try {
                    a.setGradoNombre(rs.getString("grado_nombre"));
                    a.setCodigoAlumno(rs.getString("codigo_alumno"));
                    a.setEstadoFromString(rs.getString("estado"));
                } catch (SQLException e) {
                    // Campos opcionales
                }
                
                lista.add(a);
            }
            
        } catch (Exception e) {
            System.out.println("Error al listar alumnos: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }

    /**
     * AGREGAR NUEVO ALUMNO
     * 
     * @param a Objeto Alumno con datos del nuevo alumno
     * @return true si el registro fue exitoso
     */
    public boolean agregar(Alumno a) {
        String sql = "{CALL crear_alumno(?, ?, ?, ?, ?)}";

        try (Connection con = Conexion.getConnection(); 
             CallableStatement cs = con.prepareCall(sql)) {
            
            cs.setString(1, a.getNombres());
            cs.setString(2, a.getApellidos());
            cs.setString(3, a.getCorreo());
            
            // Convertir LocalDate a SQL Date
            if (a.getFechaNacimiento() != null) {
                cs.setDate(4, java.sql.Date.valueOf(a.getFechaNacimiento()));
            } else {
                cs.setNull(4, java.sql.Types.DATE);
            }
            
            cs.setInt(5, a.getGradoId());
            
            cs.executeUpdate();
            
            System.out.println("Alumno agregado exitosamente: " + a.getNombreCompleto());
            return true;
            
        } catch (SQLException e) {
            System.out.println("Error SQL al agregar alumno:");
            System.out.println("   Código: " + e.getErrorCode());
            System.out.println("   Estado: " + e.getSQLState());
            System.out.println("   Mensaje: " + e.getMessage());
            e.printStackTrace();
            return false;
        } catch (Exception e) {
            System.out.println("Error general al agregar alumno: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * OBTENER ALUMNO POR ID
     * 
     * @param id Identificador unico del alumno
     * @return Objeto Alumno con datos completos
     */
    public Alumno obtenerPorId(int id) {
        Alumno a = null;
        String sql = "{CALL obtener_alumno_por_id(?)}";

        try (Connection con = Conexion.getConnection(); 
             CallableStatement cs = con.prepareCall(sql)) {
            
            cs.setInt(1, id);
            ResultSet rs = cs.executeQuery();
            
            if (rs.next()) {
                a = new Alumno();
                a.setId(rs.getInt("id"));
                a.setNombres(rs.getString("nombres"));
                a.setApellidos(rs.getString("apellidos"));
                a.setCorreo(rs.getString("correo"));
                
                // Convertir fechas
                java.sql.Date fechaNac = rs.getDate("fecha_nacimiento");
                if (fechaNac != null) {
                    a.setFechaNacimiento(fechaNac.toLocalDate());
                }
                
                java.sql.Date fechaIng = rs.getDate("fecha_ingreso");
                if (fechaIng != null) {
                    a.setFechaIngreso(fechaIng.toLocalDate());
                }
                
                a.setGradoId(rs.getInt("grado_id"));
                
                // Campos adicionales
                try {
                    a.setGradoNombre(rs.getString("grado_nombre"));
                    a.setCodigoAlumno(rs.getString("codigo_alumno"));
                    a.setEstadoFromString(rs.getString("estado"));
                } catch (SQLException e) {
                    // Campos opcionales
                }
            }
            
        } catch (Exception e) {
            System.out.println("Error al obtener alumno por ID: " + e.getMessage());
            e.printStackTrace();
        }
        
        return a;
    }

    /**
     * ACTUALIZAR DATOS DE ALUMNO EXISTENTE
     * 
     * @param a Objeto Alumno con datos actualizados
     * @return true si la actualizacion fue exitosa
     */
    public boolean actualizar(Alumno a) {
        String sql = "{CALL actualizar_alumno(?, ?, ?, ?, ?, ?)}";

        try (Connection con = Conexion.getConnection(); 
             CallableStatement cs = con.prepareCall(sql)) {
            
            cs.setInt(1, a.getId());
            cs.setString(2, a.getNombres());
            cs.setString(3, a.getApellidos());
            cs.setString(4, a.getCorreo());
            
            // Convertir LocalDate a SQL Date
            if (a.getFechaNacimiento() != null) {
                cs.setDate(5, java.sql.Date.valueOf(a.getFechaNacimiento()));
            } else {
                cs.setNull(5, java.sql.Types.DATE);
            }
            
            cs.setInt(6, a.getGradoId());
            
            cs.executeUpdate();
            
            System.out.println("Alumno actualizado: " + a.getNombreCompleto());
            return true;
            
        } catch (SQLException e) {
            System.out.println("Error SQL al actualizar alumno:");
            System.out.println("   Código: " + e.getErrorCode());
            System.out.println("   Mensaje: " + e.getMessage());
            e.printStackTrace();
            return false;
        } catch (Exception e) {
            System.out.println("Error general al actualizar alumno: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * ELIMINAR ALUMNO POR ID
     * 
     * @param id Identificador del alumno a eliminar
     * @return true si la eliminacion fue exitosa
     */
    public boolean eliminar(int id) {
        String sql = "{CALL eliminar_alumno(?)}";

        try (Connection con = Conexion.getConnection(); 
             CallableStatement cs = con.prepareCall(sql)) {
            
            cs.setInt(1, id);
            cs.executeUpdate();
            
            System.out.println("Alumno eliminado con ID: " + id);
            return true;
            
        } catch (SQLException e) {
            System.out.println("Error SQL al eliminar alumno:");
            System.out.println("   Código: " + e.getErrorCode());
            System.out.println("   Mensaje: " + e.getMessage());
            e.printStackTrace();
            return false;
        } catch (Exception e) {
            System.out.println("Error general al eliminar alumno: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * OBTENER ALUMNOS POR CURSO ESPECIFICO
     * 
     * @param cursoId Identificador del curso
     * @return Lista de alumnos matriculados en el curso
     */
    public List<Alumno> obtenerAlumnosPorCurso(int cursoId) {
        List<Alumno> lista = new ArrayList<>();
        String sql = "{CALL obtener_alumnos_por_curso(?)}";

        try (Connection con = Conexion.getConnection(); 
             CallableStatement cs = con.prepareCall(sql)) {

            cs.setInt(1, cursoId);
            ResultSet rs = cs.executeQuery();

            while (rs.next()) {
                Alumno a = new Alumno();
                a.setId(rs.getInt("id"));
                a.setNombres(rs.getString("nombres"));
                a.setApellidos(rs.getString("apellidos"));
                a.setCorreo(rs.getString("correo"));
                
                // Convertir fecha
                java.sql.Date fechaNac = rs.getDate("fecha_nacimiento");
                if (fechaNac != null) {
                    a.setFechaNacimiento(fechaNac.toLocalDate());
                }
                
                a.setGradoId(rs.getInt("grado_id"));
                
                // Campos adicionales
                try {
                    a.setGradoNombre(rs.getString("grado_nombre"));
                    a.setCodigoAlumno(rs.getString("codigo_alumno"));
                } catch (SQLException e) {
                    // Campos opcionales
                }
                
                lista.add(a);
            }

            System.out.println("Alumnos encontrados para curso " + cursoId + ": " + lista.size());

        } catch (SQLException e) {
            System.out.println("Error SQL al obtener alumnos por curso:");
            System.out.println("   Codigo: " + e.getErrorCode());
            System.out.println("   Estado: " + e.getSQLState());
            System.out.println("   Mensaje: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            System.out.println("Error general al obtener alumnos por curso");
            e.printStackTrace();
        }

        return lista;
    }
    
    /**
     * BUSCAR ALUMNOS POR NOMBRE O APELLIDO
     * 
     * @param busqueda Texto a buscar
     * @return Lista de alumnos que coinciden con la búsqueda
     */
    public List<Alumno> buscarPorNombre(String busqueda) {
        List<Alumno> lista = new ArrayList<>();
        String sql = "SELECT a.id, p.nombres, p.apellidos, p.correo, p.fecha_nacimiento, " +
                     "a.grado_id, a.codigo_alumno, a.estado, g.nombre as grado_nombre " +
                     "FROM alumno a " +
                     "INNER JOIN persona p ON a.persona_id = p.id " +
                     "LEFT JOIN grado g ON a.grado_id = g.id " +
                     "WHERE p.nombres LIKE ? OR p.apellidos LIKE ? " +
                     "ORDER BY p.apellidos, p.nombres";

        try (Connection con = Conexion.getConnection(); 
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            String patron = "%" + busqueda + "%";
            ps.setString(1, patron);
            ps.setString(2, patron);
            
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Alumno a = new Alumno();
                a.setId(rs.getInt("id"));
                a.setNombres(rs.getString("nombres"));
                a.setApellidos(rs.getString("apellidos"));
                a.setCorreo(rs.getString("correo"));
                
                java.sql.Date fechaNac = rs.getDate("fecha_nacimiento");
                if (fechaNac != null) {
                    a.setFechaNacimiento(fechaNac.toLocalDate());
                }
                
                a.setGradoId(rs.getInt("grado_id"));
                a.setGradoNombre(rs.getString("grado_nombre"));
                a.setCodigoAlumno(rs.getString("codigo_alumno"));
                a.setEstadoFromString(rs.getString("estado"));
                
                lista.add(a);
            }

            System.out.println("Alumnos encontrados en búsqueda: " + lista.size());

        } catch (Exception e) {
            System.out.println("Error al buscar alumnos: " + e.getMessage());
            e.printStackTrace();
        }

        return lista;
    }
}