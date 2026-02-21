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
            
            String sqlAlumno = "INSERT INTO alumno (persona_id, grado_id, turno_id, codigo_alumno, " +
                              "foto, fecha_ingreso, estado, activo) " +
                              "VALUES (?, ?, ?, ?, ?, CURDATE(), ?, 1)";
            
            psAlumno = con.prepareStatement(sqlAlumno, Statement.RETURN_GENERATED_KEYS);
            psAlumno.setInt(1, personaId);
            psAlumno.setInt(2, alumno.getGradoId());
            
            // Insertar turno_id
            if (alumno.getTurnoId() > 0) {
                psAlumno.setInt(3, alumno.getTurnoId());
            } else {
                psAlumno.setNull(3, Types.INTEGER);
            }
            
            psAlumno.setString(4, codigoAlumno);
           
            // Insertar foto
            if (alumno.getFoto() != null && !alumno.getFoto().isEmpty()) {
                psAlumno.setString(5, alumno.getFoto());
            } else {
                psAlumno.setNull(5, Types.VARCHAR);
            }
            
            // Insertar estado
            if (alumno.getEstado() != null && !alumno.getEstado().isEmpty()) {
                psAlumno.setString(6, alumno.getEstado());
            } else {
                psAlumno.setString(6, "ACTIVO");
            }

            int filasAlumno = psAlumno.executeUpdate();

            // Obtener el ID del alumno recién insertado
            ResultSet rsAlumno = psAlumno.getGeneratedKeys();
            int alumnoId = 0;
            if (rsAlumno.next()) {
                alumnoId = rsAlumno.getInt(1);
            }
            rsAlumno.close();

            // 3. CREAR PERSONA PADRE
            if (alumno.getPadreNombres() != null && !alumno.getPadreNombres().isEmpty() && alumnoId > 0) {
                String sqlPadrePersona = "INSERT INTO persona (tipo, nombres, apellidos, correo, " +
                                         "telefono, dni, activo) " +
                                         "VALUES ('PADRE', ?, ?, ?, ?, ?, 1)";
                PreparedStatement psPadrePersona = con.prepareStatement(sqlPadrePersona, Statement.RETURN_GENERATED_KEYS);
                psPadrePersona.setString(1, alumno.getPadreNombres());
                psPadrePersona.setString(2, alumno.getPadreApellidos());
                psPadrePersona.setString(3, alumno.getPadreCorreo());
                if (alumno.getPadreTelefono() != null && !alumno.getPadreTelefono().isEmpty()) {
                    psPadrePersona.setString(4, alumno.getPadreTelefono());
                } else {
                    psPadrePersona.setNull(4, Types.VARCHAR);
                }
                if (alumno.getPadreDni() != null && !alumno.getPadreDni().isEmpty()) {
                    psPadrePersona.setString(5, alumno.getPadreDni());
                } else {
                    psPadrePersona.setNull(5, Types.VARCHAR);
                }
                psPadrePersona.executeUpdate();

                ResultSet rsPadrePersona = psPadrePersona.getGeneratedKeys();
                int padrePersonaId = 0;
                if (rsPadrePersona.next()) {
                    padrePersonaId = rsPadrePersona.getInt(1);
                }
                rsPadrePersona.close();
                psPadrePersona.close();

                // 4. CREAR RELACION_FAMILIAR
                String sqlRelacion = "INSERT INTO relacion_familiar (persona_id, alumno_id, parentesco, " +
                                     "es_contacto_principal, activo, eliminado) " +
                                     "VALUES (?, ?, ?, 1, 1, 0)";
                PreparedStatement psRelacion = con.prepareStatement(sqlRelacion);
                psRelacion.setInt(1, padrePersonaId);
                psRelacion.setInt(2, alumnoId);
                String parentesco = alumno.getPadreParentesco() != null ? alumno.getPadreParentesco() : "PADRE";
                psRelacion.setString(3, parentesco);
                psRelacion.executeUpdate();
                psRelacion.close();

                System.out.println("Padre registrado: " + alumno.getPadreNombres() + " | alumno_id: " + alumnoId);
            }

            con.commit(); // Confirmar toda la transacción
            
            System.out.println("Alumno agregado correctamente - Turno ID: " + alumno.getTurnoId());
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
    
    // Método para actualizar un alumno existente
    public boolean actualizar(Alumno alumno) {
        Connection con = null;
        PreparedStatement psPersona = null;
        PreparedStatement psAlumno = null;
        
        try {
            con = Conexion.getConnection();
            con.setAutoCommit(false);
            
            // 1. ACTUALIZAR TABLA PERSONA
            String sqlPersona = "UPDATE persona SET nombres = ?, apellidos = ?, correo = ?, " +
                               "telefono = ?, dni = ?, fecha_nacimiento = ?, direccion = ? " +
                               "WHERE id = ?";
            
            psPersona = con.prepareStatement(sqlPersona);
            psPersona.setString(1, alumno.getNombres());
            psPersona.setString(2, alumno.getApellidos());
            psPersona.setString(3, alumno.getCorreo());
            
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
            
            psPersona.setInt(8, alumno.getPersonaId());
            psPersona.executeUpdate();
            
            // 2. ACTUALIZAR TABLA ALUMNO
            String sqlAlumno = "UPDATE alumno SET grado_id = ?, turno_id = ?, foto = ?, estado = ? WHERE id = ?";
            
            psAlumno = con.prepareStatement(sqlAlumno);
            psAlumno.setInt(1, alumno.getGradoId());
            
            // Actualizar turno_id
            if (alumno.getTurnoId() > 0) {
                psAlumno.setInt(2, alumno.getTurnoId());
            } else {
                psAlumno.setNull(2, Types.INTEGER);
            }
            
            // Actualizar foto
            if (alumno.getFoto() != null && !alumno.getFoto().isEmpty()) {
                psAlumno.setString(3, alumno.getFoto());
            } else {
                psAlumno.setNull(3, Types.VARCHAR);
            }
            
            // Actualizar estado
            if (alumno.getEstado() != null && !alumno.getEstado().isEmpty()) {
                psAlumno.setString(4, alumno.getEstado());
            } else {
                psAlumno.setString(4, "ACTIVO");
            }
            
            psAlumno.setInt(5, alumno.getId()); 
            
            int filas = psAlumno.executeUpdate();
            
            con.commit();
            
            System.out.println("Alumno actualizado correctamente - Turno ID: " + alumno.getTurnoId());
            return filas > 0;
            
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
                     "a.grado_id, g.nombre as grado_nombre, g.nivel as grado_nivel, " +
                     "a.turno_id, t.nombre as turno_nombre, " +
                     "a.codigo_alumno, a.foto, a.estado, a.fecha_ingreso " +
                     "FROM alumno a " +
                     "JOIN persona p ON a.persona_id = p.id " +
                     "LEFT JOIN grado g ON a.grado_id = g.id " +
                     "LEFT JOIN turno t ON a.turno_id = t.id " +
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
                     "a.grado_id, g.nombre as grado_nombre, g.nivel as grado_nivel, " +
                     "a.turno_id, t.nombre as turno_nombre, " +
                     "a.codigo_alumno, a.foto, a.estado, a.fecha_ingreso " +
                     "FROM alumno a " +
                     "JOIN persona p ON a.persona_id = p.id " +
                     "LEFT JOIN grado g ON a.grado_id = g.id " +
                     "LEFT JOIN turno t ON a.turno_id = t.id " +
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
                     "a.grado_id, g.nombre as grado_nombre, g.nivel as grado_nivel, " +
                     "a.turno_id, t.nombre as turno_nombre, " +
                     "a.codigo_alumno, a.foto, a.estado, a.fecha_ingreso " +
                     "FROM alumno a " +
                     "JOIN persona p ON a.persona_id = p.id " +
                     "LEFT JOIN grado g ON a.grado_id = g.id " +
                     "LEFT JOIN turno t ON a.turno_id = t.id " +
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
    
    // Método para eliminar (borrado lógico) - también limpia relacion_familiar y persona padre
    public boolean eliminar(int id) {
        Connection con = null;
        try {
            con = Conexion.getConnection();
            con.setAutoCommit(false);

            // 1. Marcar relacion_familiar como eliminada para este alumno
            String sqlRelacion = "UPDATE relacion_familiar SET eliminado = 1, activo = 0 WHERE alumno_id = ?";
            PreparedStatement psRelacion = con.prepareStatement(sqlRelacion);
            psRelacion.setInt(1, id);
            psRelacion.executeUpdate();
            psRelacion.close();

            // 2. Marcar el alumno como eliminado
            String sqlAlumno = "UPDATE alumno SET eliminado = 1, activo = 0 WHERE id = ?";
            PreparedStatement psAlumno = con.prepareStatement(sqlAlumno);
            psAlumno.setInt(1, id);
            int filas = psAlumno.executeUpdate();
            psAlumno.close();

            con.commit();
            return filas > 0;

        } catch (SQLException e) {
            if (con != null) {
                try { con.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            System.err.println("Error al eliminar alumno: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            if (con != null) {
                try { con.setAutoCommit(true); con.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
    
    // Método auxiliar para mapear ResultSet a objeto Alumno
    private Alumno mapearResultSet(ResultSet rs) throws SQLException {
        Alumno a = new Alumno();
        
        // Datos de alumno
        a.setId(rs.getInt("id"));
        a.setPersonaId(rs.getInt("persona_id"));
        a.setGradoId(rs.getInt("grado_id"));
        a.setTurnoId(rs.getInt("turno_id"));
        
        a.setCodigoAlumno(rs.getString("codigo_alumno"));
        a.setFoto(rs.getString("foto")); 
        a.setEstado(rs.getString("estado"));
        
        // Fechas
        if (rs.getDate("fecha_ingreso") != null) {
            a.setFechaIngreso(rs.getDate("fecha_ingreso").toLocalDate());
        }
        if (rs.getDate("fecha_nacimiento") != null) {
            a.setFechaNacimiento(rs.getDate("fecha_nacimiento").toLocalDate());
        }
        
        // Datos de persona
        a.setNombres(rs.getString("nombres"));
        a.setApellidos(rs.getString("apellidos"));
        a.setCorreo(rs.getString("correo"));
        a.setDni(rs.getString("dni"));
        a.setTelefono(rs.getString("telefono"));
        a.setDireccion(rs.getString("direccion"));
        
        // Grado
        a.setGradoNombre(rs.getString("grado_nombre"));
        a.setGradoNivel(rs.getString("grado_nivel"));
        
        // Turno
        a.setTurnoNombre(rs.getString("turno_nombre"));
        
        return a;
    }
    
    // Método para obtener alumnos por curso (para asistencias/notas)
    public List<Alumno> obtenerAlumnosPorCurso(int cursoId) {
        List<Alumno> lista = new ArrayList<>();
        
        String sql = "SELECT DISTINCT a.id, a.persona_id, p.nombres, p.apellidos, p.correo, " +
                     "p.dni, p.telefono, p.direccion, p.fecha_nacimiento, " +
                     "a.grado_id, g.nombre as grado_nombre, " +
                     "a.codigo_alumno, a.estado " +
                     "FROM alumno a " +
                     "JOIN persona p ON a.persona_id = p.id " +
                     "JOIN grado g ON a.grado_id = g.id " +
                     "JOIN curso c ON c.grado_id = a.grado_id " +
                     "WHERE c.id = ? " +
                     "AND a.eliminado = 0 AND a.activo = 1 " +
                     "AND c.activo = 1 " +
                     "ORDER BY p.apellidos, p.nombres";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, cursoId);
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
                a.setDireccion(rs.getString("direccion"));
                
                if (rs.getDate("fecha_nacimiento") != null) {
                    a.setFechaNacimiento(rs.getDate("fecha_nacimiento").toLocalDate());
                }
                
                a.setGradoId(rs.getInt("grado_id"));
                a.setGradoNombre(rs.getString("grado_nombre"));
                a.setCodigoAlumno(rs.getString("codigo_alumno"));
                a.setEstado(rs.getString("estado"));
                
                lista.add(a);
            }
            
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
    
    /**
     * OBTENER ALUMNO POR ID (Alias para obtenerPorId)
     */
    public Alumno obtenerAlumnoPorId(int id) {
        return obtenerPorId(id);
    }
    
    /**
     * OBTENER ALUMNO POR ID DEL PADRE
     */
    public Alumno obtenerAlumnoPorPadreId(int padreId) {
        String sql = "SELECT a.*, " +
                     "CONCAT(p.nombres, ' ', p.apellidos) as nombre_completo, " +
                     "g.nombre as grado_nombre, " +
                     "g.nivel as grado_nivel " +
                     "FROM alumno a " +
                     "INNER JOIN persona p ON a.persona_id = p.id " +
                     "INNER JOIN relacion_familiar rf ON a.id = rf.alumno_id " +
                     "LEFT JOIN grado g ON a.grado_id = g.id " +
                     "WHERE rf.persona_id = ? " +
                     "AND rf.parentesco IN ('PADRE', 'MADRE', 'TUTOR') " +
                     "AND a.activo = 1 " +
                     "AND a.eliminado = 0 " +
                     "AND rf.activo = 1 " +
                     "AND rf.eliminado = 0 " +
                     "LIMIT 1";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, padreId);
            
            System.out.println("Buscando alumno para padreId: " + padreId);
            
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                Alumno alumno = new Alumno();
                alumno.setId(rs.getInt("id"));
                alumno.setPersonaId(rs.getInt("persona_id"));
                alumno.setGradoId(rs.getInt("grado_id"));
                alumno.setCodigoAlumno(rs.getString("codigo_alumno"));
                alumno.setEstado(rs.getString("estado"));
                alumno.setNombreCompleto(rs.getString("nombre_completo"));
                alumno.setGradoNombre(rs.getString("grado_nombre"));
                
                System.out.println("Alumno encontrado: " + alumno.getNombreCompleto());
                
                return alumno;
            } else {
                System.out.println("No se encontró alumno para padreId: " + padreId);
            }
            
        } catch (SQLException e) {
            System.out.println("Error al obtener alumno por padre: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }

    /**
     * OBTENER LISTA DE HIJOS POR PADRE
     */
    public List<Alumno> obtenerHijosPorPadre(int padrePersonaId) {
        List<Alumno> lista = new ArrayList<>();

        String sql = "SELECT a.id, a.persona_id, a.grado_id, a.codigo_alumno, " +
                     "a.fecha_ingreso, a.estado, " +
                     "p.nombres, p.apellidos, p.correo, p.dni, p.telefono, " +
                     "p.direccion, p.fecha_nacimiento, " +
                     "g.nombre as grado_nombre, " +
                     "rf.parentesco, rf.es_contacto_principal " +
                     "FROM alumno a " +
                     "INNER JOIN persona p ON a.persona_id = p.id " +
                     "LEFT JOIN grado g ON a.grado_id = g.id " +
                     "INNER JOIN relacion_familiar rf ON a.id = rf.alumno_id " +
                     "WHERE rf.persona_id = ? " +
                     "AND rf.activo = 1 " +
                     "AND rf.eliminado = 0 " +
                     "AND a.activo = 1 " +
                     "AND a.eliminado = 0 " +
                     "ORDER BY rf.es_contacto_principal DESC, p.apellidos, p.nombres";

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, padrePersonaId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Alumno alumno = new Alumno();

                // Datos de alumno
                alumno.setId(rs.getInt("id"));
                alumno.setPersonaId(rs.getInt("persona_id"));
                alumno.setGradoId(rs.getInt("grado_id"));
                alumno.setCodigoAlumno(rs.getString("codigo_alumno"));
                alumno.setEstado(rs.getString("estado"));

                // Fechas
                if (rs.getDate("fecha_ingreso") != null) {
                    alumno.setFechaIngreso(rs.getDate("fecha_ingreso").toLocalDate());
                }
                if (rs.getDate("fecha_nacimiento") != null) {
                    alumno.setFechaNacimiento(rs.getDate("fecha_nacimiento").toLocalDate());
                }

                // Datos de persona
                alumno.setNombres(rs.getString("nombres"));
                alumno.setApellidos(rs.getString("apellidos"));
                alumno.setCorreo(rs.getString("correo"));
                alumno.setDni(rs.getString("dni"));
                alumno.setTelefono(rs.getString("telefono"));
                alumno.setDireccion(rs.getString("direccion"));

                // Grado
                alumno.setGradoNombre(rs.getString("grado_nombre"));

                lista.add(alumno);
            }

            System.out.println("Hijos encontrados para padre " + padrePersonaId + ": " + lista.size());

        } catch (SQLException e) {
            System.err.println("Error al obtener hijos por padre: " + e.getMessage());
            e.printStackTrace();
        }

        return lista;
    }

}