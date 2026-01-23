package modelo;

import conexion.Conexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.text.SimpleDateFormat;

public class AlumnoDAO {
    
    // Método para agregar un nuevo alumno (inserción en persona y alumno)
    public boolean agregar(Alumno alumno) {
        Connection con = null;
        PreparedStatement psPersona = null;
        PreparedStatement psAlumno = null;
        ResultSet rs = null;
        
        try {
            con = Conexion.getConnection();
            con.setAutoCommit(false); // Iniciar transacción
            
            // 1. INSERTAR EN TABLA PERSONA
            String sqlPersona = "INSERT INTO persona (tipo, nombres, apellidos, correo, " +
                               "telefono, dni, fecha_nacimiento, direccion, activo) " +
                               "VALUES ('ALUMNO', ?, ?, ?, ?, ?, ?, ?, 1)";
            
            psPersona = con.prepareStatement(sqlPersona, Statement.RETURN_GENERATED_KEYS);
            psPersona.setString(1, alumno.getNombres());
            psPersona.setString(2, alumno.getApellidos());
            psPersona.setString(3, alumno.getCorreo());
            
            // Campos opcionales
            if (alumno.getTelefono() != null && !alumno.getTelefono().isEmpty()) {
                psPersona.setString(4, alumno.getTelefono());
            } else {
                psPersona.setNull(4, Types.VARCHAR);
            }
            
            if (alumno.getDni() != null && !alumno.getDni().isEmpty()) {
                psPersona.setString(5, alumno.getDni());
            } else {
                psPersona.setNull(5, Types.VARCHAR);
            }
            
            if (alumno.getFechaNacimiento() != null) {
                psPersona.setDate(6, Date.valueOf(alumno.getFechaNacimiento()));
            } else {
                psPersona.setNull(6, Types.DATE);
            }
            
            if (alumno.getDireccion() != null && !alumno.getDireccion().isEmpty()) {
                psPersona.setString(7, alumno.getDireccion());
            } else {
                psPersona.setNull(7, Types.VARCHAR);
            }
            
            int filasPersona = psPersona.executeUpdate();
            if (filasPersona == 0) {
                throw new SQLException("Error al insertar en tabla persona");
            }
            
            // Obtener el ID de la persona insertada
            rs = psPersona.getGeneratedKeys();
            int personaId = 0;
            if (rs.next()) {
                personaId = rs.getInt(1);
            }
            
            // 2. INSERTAR EN TABLA ALUMNO
            // Generar código de alumno automático
            String codigoAlumno = "ALU-" + 
                                 new SimpleDateFormat("yyyyMMdd").format(new java.util.Date()) + 
                                 "-" + 
                                 String.format("%03d", personaId);
            
            String sqlAlumno = "INSERT INTO alumno (persona_id, grado_id, codigo_alumno, " +
                              "fecha_ingreso, estado, activo) " +
                              "VALUES (?, ?, ?, CURDATE(), 'ACTIVO', 1)";
            
            psAlumno = con.prepareStatement(sqlAlumno);
            psAlumno.setInt(1, personaId);
            psAlumno.setInt(2, alumno.getGradoId());
            psAlumno.setString(3, codigoAlumno);
            
            int filasAlumno = psAlumno.executeUpdate();
            
            con.commit(); // Confirmar transacción
            return filasAlumno > 0;
            
        } catch (SQLException e) {
            // Revertir en caso de error
            try {
                if (con != null) con.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            System.err.println("Error al agregar alumno: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            // Cerrar recursos
            try { if (rs != null) rs.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (psPersona != null) psPersona.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (psAlumno != null) psAlumno.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (con != null) con.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }
    
    // Método para listar todos los alumnos
    public List<Alumno> listar() {
        List<Alumno> lista = new ArrayList<>();
        String sql = "SELECT a.id, a.persona_id, p.nombres, p.apellidos, p.correo, " +
                     "p.dni, p.telefono, p.direccion, p.fecha_nacimiento, " +
                     "a.grado_id, g.nombre as grado_nombre, " +
                     "a.codigo_alumno, a.estado, a.fecha_ingreso " +
                     "FROM alumno a " +
                     "JOIN persona p ON a.persona_id = p.id " +
                     "LEFT JOIN grado g ON a.grado_id = g.id " +
                     "WHERE a.eliminado = 0 AND a.activo = 1 " +
                     "ORDER BY p.apellidos, p.nombres";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Alumno a = mapearResultSet(rs);
                lista.add(a);
            }
            
        } catch (SQLException e) {
            System.err.println("Error al listar alumnos: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }
    
    // Método para listar alumnos por grado
    public List<Alumno> listarPorGrado(int gradoId) {
        List<Alumno> lista = new ArrayList<>();
        String sql = "SELECT a.id, a.persona_id, p.nombres, p.apellidos, p.correo, " +
                     "p.dni, p.telefono, p.direccion, p.fecha_nacimiento, " +
                     "a.grado_id, g.nombre as grado_nombre, " +
                     "a.codigo_alumno, a.estado, a.fecha_ingreso " +
                     "FROM alumno a " +
                     "JOIN persona p ON a.persona_id = p.id " +
                     "LEFT JOIN grado g ON a.grado_id = g.id " +
                     "WHERE a.grado_id = ? AND a.eliminado = 0 AND a.activo = 1 " +
                     "ORDER BY p.apellidos, p.nombres";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, gradoId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Alumno a = mapearResultSet(rs);
                lista.add(a);
            }
            
        } catch (SQLException e) {
            System.err.println("Error al listar alumnos por grado: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }
    
    // Método para obtener alumno por ID
    public Alumno obtenerPorId(int id) {
        String sql = "SELECT a.id, a.persona_id, p.nombres, p.apellidos, p.correo, " +
                     "p.dni, p.telefono, p.direccion, p.fecha_nacimiento, " +
                     "a.grado_id, g.nombre as grado_nombre, " +
                     "a.codigo_alumno, a.estado, a.fecha_ingreso " +
                     "FROM alumno a " +
                     "JOIN persona p ON a.persona_id = p.id " +
                     "LEFT JOIN grado g ON a.grado_id = g.id " +
                     "WHERE a.id = ? AND a.eliminado = 0";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return mapearResultSet(rs);
            }
            
        } catch (SQLException e) {
            System.err.println("Error al obtener alumno por ID: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    // Método para actualizar alumno
    public boolean actualizar(Alumno alumno) {
        Connection con = null;
        PreparedStatement psPersona = null;
        PreparedStatement psAlumno = null;
        
        try {
            con = Conexion.getConnection();
            con.setAutoCommit(false);
            
            // 1. Actualizar tabla PERSONA
            String sqlPersona = "UPDATE persona SET nombres = ?, apellidos = ?, correo = ?, " +
                               "dni = ?, telefono = ?, direccion = ?, fecha_nacimiento = ? " +
                               "WHERE id = ?";
            
            psPersona = con.prepareStatement(sqlPersona);
            psPersona.setString(1, alumno.getNombres());
            psPersona.setString(2, alumno.getApellidos());
            psPersona.setString(3, alumno.getCorreo());
            
            // Campos opcionales
            if (alumno.getDni() != null && !alumno.getDni().isEmpty()) {
                psPersona.setString(4, alumno.getDni());
            } else {
                psPersona.setNull(4, Types.VARCHAR);
            }
            
            if (alumno.getTelefono() != null && !alumno.getTelefono().isEmpty()) {
                psPersona.setString(5, alumno.getTelefono());
            } else {
                psPersona.setNull(5, Types.VARCHAR);
            }
            
            if (alumno.getDireccion() != null && !alumno.getDireccion().isEmpty()) {
                psPersona.setString(6, alumno.getDireccion());
            } else {
                psPersona.setNull(6, Types.VARCHAR);
            }
            
            if (alumno.getFechaNacimiento() != null) {
                psPersona.setDate(7, Date.valueOf(alumno.getFechaNacimiento()));
            } else {
                psPersona.setNull(7, Types.DATE);
            }
            
            psPersona.setInt(8, alumno.getPersonaId());
            
            int filasPersona = psPersona.executeUpdate();
            
            // 2. Actualizar tabla ALUMNO
            String sqlAlumno = "UPDATE alumno SET grado_id = ? WHERE id = ?";
            
            psAlumno = con.prepareStatement(sqlAlumno);
            psAlumno.setInt(1, alumno.getGradoId());
            psAlumno.setInt(2, alumno.getId());
            
            int filasAlumno = psAlumno.executeUpdate();
            
            con.commit();
            return (filasPersona > 0 && filasAlumno > 0);
            
        } catch (SQLException e) {
            try {
                if (con != null) con.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            System.err.println("Error al actualizar alumno: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            // Cerrar recursos
            try { if (psPersona != null) psPersona.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (psAlumno != null) psAlumno.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (con != null) con.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }
    
    // Método para eliminar alumno (eliminación lógica)
    public boolean eliminar(int id) {
        String sql = "UPDATE alumno SET eliminado = 1, activo = 0 WHERE id = ?";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("Error al eliminar alumno: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // Método auxiliar para mapear ResultSet a objeto Alumno
    private Alumno mapearResultSet(ResultSet rs) throws SQLException {
        Alumno a = new Alumno();
        a.setId(rs.getInt("id"));
        a.setPersonaId(rs.getInt("persona_id"));
        a.setNombres(rs.getString("nombres"));
        a.setApellidos(rs.getString("apellidos"));
        a.setCorreo(rs.getString("correo"));
        a.setDni(rs.getString("dni"));
        a.setTelefono(rs.getString("telefono"));
        a.setDireccion(rs.getString("direccion"));
        
        java.sql.Date fechaNac = rs.getDate("fecha_nacimiento");
        if (fechaNac != null) {
            a.setFechaNacimiento(fechaNac.toLocalDate());
        }
        
        a.setGradoId(rs.getInt("grado_id"));
        a.setGradoNombre(rs.getString("grado_nombre"));
        a.setCodigoAlumno(rs.getString("codigo_alumno"));
        a.setEstado(rs.getString("estado"));
        
        java.sql.Date fechaIng = rs.getDate("fecha_ingreso");
        if (fechaIng != null) {
            a.setFechaIngreso(fechaIng.toLocalDate());
        }
        
        return a;
    }
    
    // Método mejorado para obtener alumnos por curso usando la tabla matricula
    public List<Alumno> obtenerAlumnosPorCurso(int cursoId) {
        List<Alumno> lista = new ArrayList<>();
        
        String sql = "SELECT DISTINCT a.id, a.persona_id, p.nombres, p.apellidos, " +
                     "a.codigo_alumno, g.nombre as grado_nombre, g.nivel, " +
                     "p.correo, p.dni, p.telefono " +
                     "FROM alumno a " +
                     "JOIN persona p ON a.persona_id = p.id " +
                     "JOIN grado g ON a.grado_id = g.id " +
                     "JOIN curso c ON g.id = c.grado_id " +
                     "JOIN matricula m ON a.id = m.alumno_id AND c.id = m.curso_id " +
                     "WHERE c.id = ? AND a.eliminado = 0 AND a.activo = 1 " +
                     "AND p.eliminado = 0 AND p.activo = 1 " +
                     "AND c.eliminado = 0 AND c.activo = 1 " +
                     "AND m.estado = 'INSCRITO' " +
                     "ORDER BY p.apellidos, p.nombres";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, cursoId);
            System.out.println("Buscando alumnos para curso ID: " + cursoId);
            
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Alumno a = new Alumno();
                a.setId(rs.getInt("id"));
                a.setPersonaId(rs.getInt("persona_id"));
                a.setNombres(rs.getString("nombres"));
                a.setApellidos(rs.getString("apellidos"));
                a.setCorreo(rs.getString("correo"));
                a.setDni(rs.getString("dni"));
                a.setTelefono(rs.getString("telefono"));
                a.setCodigoAlumno(rs.getString("codigo_alumno"));
                a.setGradoNombre(rs.getString("grado_nombre") + " - " + rs.getString("nivel"));
                
                lista.add(a);
                System.out.println("Alumno encontrado: " + a.getNombres() + " " + a.getApellidos());
            }
            
            System.out.println("Total alumnos encontrados para curso " + cursoId + ": " + lista.size());
            
        } catch (SQLException e) {
            System.err.println("Error al obtener alumnos por curso: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }
    
    // Método alternativo usando JOIN con matrícula (más directo)
    public List<Alumno> obtenerAlumnosPorCurso2(int cursoId) {
        List<Alumno> lista = new ArrayList<>();
        
        String sql = "SELECT a.id, p.nombres, p.apellidos, a.codigo_alumno, " +
                     "CONCAT(g.nombre, ' - ', g.nivel) as grado_nombre " +
                     "FROM matricula m " +
                     "JOIN alumno a ON m.alumno_id = a.id " +
                     "JOIN persona p ON a.persona_id = p.id " +
                     "JOIN grado g ON a.grado_id = g.id " +
                     "WHERE m.curso_id = ? " +
                     "AND m.estado = 'INSCRITO' " +
                     "AND a.eliminado = 0 AND a.activo = 1 " +
                     "ORDER BY p.apellidos, p.nombres";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, cursoId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Alumno a = new Alumno();
                a.setId(rs.getInt("id"));
                a.setNombres(rs.getString("nombres"));
                a.setApellidos(rs.getString("apellidos"));
                a.setCodigoAlumno(rs.getString("codigo_alumno"));
                a.setGradoNombre(rs.getString("grado_nombre"));
                lista.add(a);
            }
            
        } catch (SQLException e) {
            System.err.println("Error en obtenerAlumnosPorCurso2: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }
}