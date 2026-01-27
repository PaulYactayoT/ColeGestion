package modelo;

import conexion.Conexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;      
import java.util.TreeSet; 

public class ProfesorDAO {

    /**
     * LISTAR TODOS LOS PROFESORES ACTIVOS
     */
    public List<Profesor> listar() {
        
        List<Profesor> lista = new ArrayList<>();
        String sql = "SELECT " +
                     "    prof.id, " +
                    "    prof.persona_id, " +
                    "    prof.turno_id, " +
                    "    p.nombres, " +
                    "    p.apellidos, " +
                    "    p.correo, " +
                    "    p.telefono, " +
                    "    p.dni, " +
                    "    p.fecha_nacimiento, " +
                    "    p.direccion, " +
                    "    prof.especialidad, " +
                    "    prof.nivel, " +
                    "    prof.codigo_profesor, " +
                    "    prof.fecha_contratacion, " +
                    "    prof.estado, " +
                    "    u.username, " +
                    "    t.nombre as turno_nombre " +
                    "FROM profesor prof " +
                    "JOIN persona p ON prof.persona_id = p.id " +
                    "LEFT JOIN usuario u ON p.id = u.persona_id AND u.rol = 'docente' " +
                    "LEFT JOIN turno t ON prof.turno_id = t.id " +
                    "WHERE prof.eliminado = 0 AND prof.activo = 1 " +
                    "ORDER BY p.apellidos, p.nombres";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            // Agrega esto temporalmente en tu ProfesorDAO.listar()
            System.out.println("Conectando a BD...");

            System.out.println("Conexión exitosa: " + (con != null));
            while (rs.next()) {
                Profesor p = mapearResultSet(rs);
                lista.add(p);
            }
            
        } catch (SQLException e) {
            System.err.println("ERROR en listar profesores: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
        
    }

    /**
     * MÉTODO AUXILIAR PARA MAPEAR RESULT SET
     */
    private Profesor mapearResultSet(ResultSet rs) throws SQLException {
        Profesor p = new Profesor();
        
        p.setId(rs.getInt("id"));
        p.setPersonaId(rs.getInt("persona_id"));
        p.setNombres(rs.getString("nombres"));
        p.setApellidos(rs.getString("apellidos"));
        p.setCorreo(rs.getString("correo"));
        p.setTelefono(rs.getString("telefono"));
        p.setDni(rs.getString("dni"));
        p.setDireccion(rs.getString("direccion"));
        
        
        
        java.sql.Date fechaNac = rs.getDate("fecha_nacimiento");
        if (fechaNac != null) {
            p.setFechaNacimiento(fechaNac);
        }
        
        p.setEspecialidad(rs.getString("especialidad"));
        p.setNivel(rs.getString("nivel")); 
        p.setCodigoProfesor(rs.getString("codigo_profesor"));
        
        java.sql.Date fechaCont = rs.getDate("fecha_contratacion");
        if (fechaCont != null) {
            p.setFechaContratacion(fechaCont);
        }
        
        p.setEstado(rs.getString("estado"));
        p.setUsername(rs.getString("username"));
        
        p.setTurnoId(rs.getInt("turno_id"));
        p.setTurnoNombre(rs.getString("turno_nombre"));

        return p;
    }

    /**
     * OBTENER PROFESOR POR ID
     */
    public Profesor obtenerPorId(int id) {
        String sql = "SELECT " +
                   "    prof.id, " +
                    "    prof.persona_id, " +
                    "    prof.turno_id, " +
                    "    p.nombres, " +
                    "    p.apellidos, " +
                    "    p.correo, " +
                    "    p.telefono, " +
                    "    p.dni, " +
                    "    p.fecha_nacimiento, " +
                    "    p.direccion, " +
                    "    prof.especialidad, " +
                    "    prof.nivel, " + 
                    "    prof.codigo_profesor, " +
                    "    prof.fecha_contratacion, " +
                    "    prof.estado, " +
                    "    u.username, " +
                    "    t.nombre as turno_nombre " +
                    "FROM profesor prof " +
                    "JOIN persona p ON prof.persona_id = p.id " +
                    "LEFT JOIN usuario u ON p.id = u.persona_id AND u.rol = 'docente' " +
                    "LEFT JOIN turno t ON prof.turno_id = t.id " +
                    "WHERE prof.id = ? AND prof.eliminado = 0";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return mapearResultSet(rs);
            }
            
        } catch (SQLException e) {
            System.err.println(" ERROR en obtenerPorId: " + e.getMessage());
        }
        
        return null;
    }

   /**
 * CREAR NUEVO PROFESOR
 */
public boolean crear(Profesor profesor) {
    Connection conn = null;
    PreparedStatement psPersona = null;
    PreparedStatement psProfesor = null;
    PreparedStatement psUsuario = null;
    ResultSet rs = null;
    
    try {
        conn = Conexion.getConnection();
        conn.setAutoCommit(false);
        
        System.out.println("Iniciando creación de profesor: " + profesor.getNombres() + " " + profesor.getApellidos());
        
        // ========== 1. INSERTAR EN PERSONA ==========
        String sqlPersona = "INSERT INTO persona (nombres, apellidos, correo, telefono, dni, " +
                           "fecha_nacimiento, direccion, tipo, activo) " +
                           "VALUES (?, ?, ?, ?, ?, ?, ?, 'PROFESOR', 1)";
        
        psPersona = conn.prepareStatement(sqlPersona, Statement.RETURN_GENERATED_KEYS);
        psPersona.setString(1, profesor.getNombres());
        psPersona.setString(2, profesor.getApellidos());
        psPersona.setString(3, profesor.getCorreo());
        psPersona.setString(4, profesor.getTelefono());
        psPersona.setString(5, profesor.getDni());
        
        if (profesor.getFechaNacimiento() != null) {
            psPersona.setDate(6, new java.sql.Date(profesor.getFechaNacimiento().getTime()));
        } else {
            psPersona.setNull(6, Types.DATE);
        }
        
        psPersona.setString(7, profesor.getDireccion());
        
        int filasPersona = psPersona.executeUpdate();
        System.out.println("Filas insertadas en persona: " + filasPersona);
        
        if (filasPersona == 0) {
            throw new SQLException("No se pudo insertar en persona");
        }
        
        int personaId;
        rs = psPersona.getGeneratedKeys();
        if (rs.next()) {
            personaId = rs.getInt(1);
            profesor.setPersonaId(personaId);
            System.out.println("Persona ID generado: " + personaId);
        } else {
            throw new SQLException("No se pudo obtener el ID de persona");
        }
        rs.close();
        
        // ========== 2. INSERTAR EN PROFESOR ==========
        String sqlProfesor = "INSERT INTO profesor (persona_id, especialidad, nivel, turno_id, codigo_profesor, " +
                    "fecha_contratacion, estado, activo) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, 1)";
        
        psProfesor = conn.prepareStatement(sqlProfesor, Statement.RETURN_GENERATED_KEYS);
        psProfesor.setInt(1, personaId);
        psProfesor.setString(2, profesor.getEspecialidad());

        //NIVEL
        if (profesor.getNivel() != null && !profesor.getNivel().isEmpty()) {
            psProfesor.setString(3, profesor.getNivel());
        } else {
            psProfesor.setNull(3, Types.VARCHAR);
        }
        
        // TURNO
        if (profesor.getTurnoId() > 0) {
            psProfesor.setInt(4, profesor.getTurnoId());
            System.out.println("Asignando turno ID: " + profesor.getTurnoId());
        } else {
            psProfesor.setNull(4, Types.INTEGER);
            System.out.println("Sin turno asignado");
        }
        
        // GENERA CODIGO DE PROFESOR
        String codigoProfesor = profesor.getCodigoProfesor();
        if (codigoProfesor == null || codigoProfesor.trim().isEmpty()) {
            codigoProfesor = generarCodigoProfesor();
            profesor.setCodigoProfesor(codigoProfesor);
        }
        psProfesor.setString(5, codigoProfesor);
        System.out.println("Código profesor: " + codigoProfesor);
        
        // FECHA DE CONTRATACIÓN
        if (profesor.getFechaContratacion() != null) {
            psProfesor.setDate(6, new java.sql.Date(profesor.getFechaContratacion().getTime()));
        } else {
            psProfesor.setDate(6, new java.sql.Date(System.currentTimeMillis()));
        }

        // ESTADO
        String estado = profesor.getEstado();
        if (estado == null || estado.trim().isEmpty()) {
            estado = "ACTIVO";
            profesor.setEstado(estado);
        }
        psProfesor.setString(7, estado);
        
        int filasProfesor = psProfesor.executeUpdate();
        System.out.println("Filas insertadas en profesor: " + filasProfesor);
        
        if (filasProfesor == 0) {
            throw new SQLException("No se pudo insertar en profesor");
        }
        
        rs = psProfesor.getGeneratedKeys();
        if (rs.next()) {
            profesor.setId(rs.getInt(1));
            System.out.println("Profesor ID generado: " + profesor.getId());
        }
        rs.close();
        
        // ========== 3. INSERTAR EN USUARIO ==========
        String sqlUsuario = "INSERT INTO usuario (persona_id, username, password, rol, activo) " +
                           "VALUES (?, ?, ?, 'docente', 1)";
        
        psUsuario = conn.prepareStatement(sqlUsuario);
        psUsuario.setInt(1, personaId);
        
        // USERNAME
        String username = profesor.getUsername();
        if (username == null || username.trim().isEmpty()) {
            if (profesor.getCorreo() != null && !profesor.getCorreo().isEmpty()) {
                username = profesor.getCorreo().split("@")[0];
            } else {
                username = (profesor.getNombres().charAt(0) + profesor.getApellidos().split(" ")[0]).toLowerCase();
                username = username.replaceAll("[^a-z0-9]", "");
            }
            profesor.setUsername(username);
        }
        psUsuario.setString(2, username);
        System.out.println("Username: " + username);
        
        // PASSWORD
        String password;
        if (profesor.getPassword() != null && !profesor.getPassword().trim().isEmpty()) {
            password = profesor.getPassword();
        } else {
            password = profesor.getDni() != null && !profesor.getDni().trim().isEmpty() ? profesor.getDni() : "123456";
        }
        psUsuario.setString(3, encriptarSHA256(password));
        System.out.println("Contraseña encriptada");
        
        int filasUsuario = psUsuario.executeUpdate();
        System.out.println("Filas insertadas en usuario: " + filasUsuario);
        
        if (filasUsuario == 0) {
            throw new SQLException("No se pudo insertar en usuario");
        }
        
        conn.commit();
        System.out.println("Profesor creado exitosamente: " + profesor.getNombreCompleto());
        return true;
        
    } catch (SQLException e) {
        System.err.println("ERROR SQL al crear profesor: " + e.getMessage());
        e.printStackTrace();
        if (conn != null) {
            try {
                conn.rollback();
                System.err.println("Transacción revertida");
            } catch (SQLException ex) {
                System.err.println("Error al revertir transacción: " + ex.getMessage());
            }
        }
        return false;
    } catch (Exception e) {
        System.err.println("ERROR general: " + e.getMessage());
        e.printStackTrace();
        return false;
    } finally {
        try {
            if (rs != null) rs.close();
            if (psPersona != null) psPersona.close();
            if (psProfesor != null) psProfesor.close();
            if (psUsuario != null) psUsuario.close();
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        } catch (SQLException e) {
            System.err.println("Error cerrando recursos: " + e.getMessage());
        }
    }
}

    /**
     * GENERAR CÓDIGO DE PROFESOR ÚNICO
     */
    private String generarCodigoProfesor() {
        String codigo;
        int intentos = 0;
        
        do {
            intentos++;
            int random = (int) (Math.random() * 10000);
            codigo = "PROF-" + String.format("%04d", random);
            
            if (intentos > 10) {
                codigo = "PROF-" + (System.currentTimeMillis() % 10000);
                break;
            }
        } while (existeCodigoProfesor(codigo));
        
        return codigo;
    }

    /**
     * VERIFICAR SI EL CÓDIGO DE PROFESOR YA EXISTE
     */
    private boolean existeCodigoProfesor(String codigo) {
        String sql = "SELECT COUNT(*) as total FROM profesor WHERE codigo_profesor = ?";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, codigo);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("total") > 0;
            }
            
        } catch (SQLException e) {
            System.err.println("Error verificando código: " + e.getMessage());
        }
        
        return false;
    }

    /**
     * ENCRIPTAR SHA-256
     */
    private String encriptarSHA256(String password) {
        try {
            java.security.MessageDigest md = java.security.MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes("UTF-8"));
            StringBuilder hex = new StringBuilder();
            
            for (byte b : hash) {
                hex.append(String.format("%02x", b));
            }
            
            return hex.toString();
        } catch (Exception e) {
            System.err.println("Error encriptando: " + e.getMessage());
            return password;
        }
    }
    /**
 * OBTENER PROFESOR POR USERNAME (Para login) - MÉTODO CORREGIDO
 */
public Profesor obtenerPorUsername(String username) {
    Profesor profesor = null;
    String sql = "SELECT " +
                "    u.username, " +
                "    u.rol, " +
                "    p.id as persona_id, " +
                "    p.nombres, " +
                "    p.apellidos, " +
                "    pr.turno_id, " +  
                "    p.correo, " +    
                "    p.telefono, " +
                "    p.dni, " +
                "    p.fecha_nacimiento, " +
                "    p.direccion, " +
                "    pr.id as profesor_id, " +
                "    pr.especialidad, " +
                "    pr.codigo_profesor, " +
                "    pr.fecha_contratacion, " +
                "    pr.estado " +
                "FROM usuario u " +
                "INNER JOIN persona p ON u.persona_id = p.id " +
                "INNER JOIN profesor pr ON p.id = pr.persona_id " +
                "WHERE u.username = ? " +
                "AND u.rol = 'docente' " +
                "AND u.activo = 1 " +
                "AND u.eliminado = 0 " +
                "AND pr.activo = 1 " +
                "AND pr.eliminado = 0";

    try (Connection conn = Conexion.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ps.setString(1, username);
        System.out.println(" Buscando profesor con username: " + username);
        
        ResultSet rs = ps.executeQuery();
        
        if (rs.next()) {
            profesor = new Profesor();
            
            // Datos de usuario
            profesor.setUsername(rs.getString("username"));
            profesor.setRol(rs.getString("rol"));
            
            // Datos de persona
            profesor.setPersonaId(rs.getInt("persona_id"));
            profesor.setNombres(rs.getString("nombres"));
            profesor.setApellidos(rs.getString("apellidos"));
            profesor.setCorreo(rs.getString("correo"));
            profesor.setTelefono(rs.getString("telefono"));
            profesor.setDni(rs.getString("dni"));
            profesor.setFechaNacimiento(rs.getDate("fecha_nacimiento"));
            profesor.setDireccion(rs.getString("direccion"));
            
            // Datos de profesor
            profesor.setId(rs.getInt("profesor_id"));
            profesor.setEspecialidad(rs.getString("especialidad"));
            profesor.setCodigoProfesor(rs.getString("codigo_profesor"));
            profesor.setFechaContratacion(rs.getDate("fecha_contratacion"));
            profesor.setEstado(rs.getString("estado"));
            
            // Campo turno_id - IMPORTANTE
            profesor.setTurnoId(rs.getInt("turno_id"));
            
            System.out.println(" Profesor encontrado: " + profesor.getNombreCompleto());
            System.out.println(" ID Profesor: " + profesor.getId());
        } else {
            System.out.println(" Profesor no encontrado con username: " + username);
        }
        
    } catch (SQLException e) {
        System.err.println("ERROR SQL en obtenerPorUsername: " + e.getMessage());
        e.printStackTrace();
    }
    
    return profesor;
}

    /**
     * ACTUALIZAR PROFESOR
     */
    public boolean actualizar(Profesor profesor) {
        Connection conn = null;
        PreparedStatement psPersona = null;
        PreparedStatement psProfesor = null;
        PreparedStatement psUsuario = null;
        
        try {
            conn = Conexion.getConnection();
            conn.setAutoCommit(false);
            
            int personaId = obtenerPersonaIdPorProfesorId(profesor.getId());
            if (personaId == 0) {
                throw new SQLException("No se encontró la persona asociada al profesor");
            }
            
            // 1. Actualizar tabla persona
            String sqlPersona = "UPDATE persona SET nombres = ?, apellidos = ?, correo = ?, " +
                               "telefono = ?, dni = ?, fecha_nacimiento = ?, direccion = ? WHERE id = ?";
            
            psPersona = conn.prepareStatement(sqlPersona);
            psPersona.setString(1, profesor.getNombres());
            psPersona.setString(2, profesor.getApellidos());
            psPersona.setString(3, profesor.getCorreo());
            psPersona.setString(4, profesor.getTelefono());
            psPersona.setString(5, profesor.getDni());
            
            if (profesor.getFechaNacimiento() != null) {
                psPersona.setDate(6, new java.sql.Date(profesor.getFechaNacimiento().getTime()));
            } else {
                psPersona.setNull(6, Types.DATE);
            }
            
            psPersona.setString(7, profesor.getDireccion());
            psPersona.setInt(8, personaId);
            psPersona.executeUpdate();
            
            // 2. Actualizar tabla profesor
            
            String sqlProfesor = "UPDATE profesor SET especialidad = ?, nivel = ?, turno_id = ?, codigo_profesor = ?, " +
                      "fecha_contratacion = ?, estado = ? WHERE id = ?";
            
            psProfesor = conn.prepareStatement(sqlProfesor);
            psProfesor.setString(1, profesor.getEspecialidad());
                    
            //NIVEL
            if (profesor.getNivel() != null && !profesor.getNivel().isEmpty()) {
                psProfesor.setString(2, profesor.getNivel());
            } else {
                psProfesor.setNull(2, Types.VARCHAR);
            }
            
            // TURNO
            if (profesor.getTurnoId() > 0) {
                psProfesor.setInt(3, profesor.getTurnoId());
            } else {
                psProfesor.setNull(3, Types.INTEGER);
            }

            psProfesor.setString(4, profesor.getCodigoProfesor());
        
            //FECHA DE CONTRATACION
            if (profesor.getFechaContratacion() != null) {
                psProfesor.setDate(5, new java.sql.Date(profesor.getFechaContratacion().getTime()));
            } else {
                psProfesor.setNull(5, Types.DATE);
            }
            psProfesor.setString(6, profesor.getEstado());
            psProfesor.setInt(7, profesor.getId());
            psProfesor.executeUpdate();
            
            // 3. Actualizar tabla usuario (solo si se proporciona username o password)
            if ((profesor.getUsername() != null && !profesor.getUsername().isEmpty()) ||
                (profesor.getPassword() != null && !profesor.getPassword().isEmpty())) {
                
                StringBuilder sqlUsuario = new StringBuilder("UPDATE usuario SET ");
                List<Object> params = new ArrayList<>();
                
                if (profesor.getUsername() != null && !profesor.getUsername().isEmpty()) {
                    sqlUsuario.append("username = ?, ");
                    params.add(profesor.getUsername());
                }
                
                if (profesor.getPassword() != null && !profesor.getPassword().isEmpty()) {
                    sqlUsuario.append("password = ?, ");
                    params.add(encriptarSHA256(profesor.getPassword()));
                }
                
                sqlUsuario.setLength(sqlUsuario.length() - 2);
                sqlUsuario.append(" WHERE persona_id = ? AND rol = 'docente'");
                params.add(personaId);
                
                psUsuario = conn.prepareStatement(sqlUsuario.toString());
                for (int i = 0; i < params.size(); i++) {
                    psUsuario.setObject(i + 1, params.get(i));
                }
                psUsuario.executeUpdate();
            }
            
            conn.commit();
            System.out.println("Profesor actualizado: " + profesor.getNombreCompleto());
            return true;
            
        } catch (SQLException e) {
            System.err.println("ERROR SQL al actualizar profesor: " + e.getMessage());
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    System.err.println("Error al revertir transacción: " + ex.getMessage());
                }
            }
            return false;
        } finally {
            try {
                if (psPersona != null) psPersona.close();
                if (psProfesor != null) psProfesor.close();
                if (psUsuario != null) psUsuario.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                System.err.println("Error cerrando recursos: " + e.getMessage());
            }
        }
    }

    /**
     * OBTENER PERSONA_ID POR PROFESOR_ID
     */
    private int obtenerPersonaIdPorProfesorId(int profesorId) {
        String sql = "SELECT persona_id FROM profesor WHERE id = ?";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, profesorId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("persona_id");
            }
            
        } catch (Exception e) {
            System.err.println("Error al obtener persona_id: " + e.getMessage());
        }
        
        return 0;
    }

    public boolean eliminar(int id) {
        Connection conn = null;
        PreparedStatement psProfesor = null;
        PreparedStatement psPersona = null;
        PreparedStatement psUsuario = null;
        
        try {
            conn = Conexion.getConnection();
            conn.setAutoCommit(false);
            
            int personaId = obtenerPersonaIdPorProfesorId(id);
            if (personaId == 0) {
                throw new SQLException("No se encontró la persona asociada al profesor");
            }
            
            psProfesor = conn.prepareStatement("UPDATE profesor SET activo = 0, eliminado = 1 WHERE id = ?");
            psProfesor.setInt(1, id);
            psProfesor.executeUpdate();
            
            psPersona = conn.prepareStatement("UPDATE persona SET activo = 0, eliminado = 1 WHERE id = ?");
            psPersona.setInt(1, personaId);
            psPersona.executeUpdate();
            
            psUsuario = conn.prepareStatement("UPDATE usuario SET activo = 0, eliminado = 1 WHERE persona_id = ? AND rol = 'docente'");
            psUsuario.setInt(1, personaId);
            psUsuario.executeUpdate();
            
            conn.commit();
            System.out.println("Profesor eliminado con ID: " + id);
            return true;
            
        } catch (SQLException e) {
            System.err.println("ERROR SQL al eliminar profesor: " + e.getMessage());
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    System.err.println("Error al revertir transacción: " + ex.getMessage());
                }
            }
            return false;
        } finally {
            try {
                if (psProfesor != null) psProfesor.close();
                if (psPersona != null) psPersona.close();
                if (psUsuario != null) psUsuario.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                System.err.println("Error cerrando recursos: " + e.getMessage());
            }
        }
    }

    public List<Profesor> buscar(String criterio) {
        List<Profesor> profesores = new ArrayList<>();
        String sql = "SELECT " +
                   "    prof.id, " +
                    "    prof.persona_id, " +
                    "    prof.turno_id, " +
                    "    p.nombres, " +
                    "    p.apellidos, " +
                    "    p.correo, " +
                    "    p.telefono, " +
                    "    p.dni, " +
                    "    p.fecha_nacimiento, " +
                    "    p.direccion, " +
                    "    prof.especialidad, " +
                    "    prof.nivel, " +
                    "    prof.codigo_profesor, " +
                    "    prof.fecha_contratacion, " +
                    "    prof.estado, " +
                    "    u.username, " +
                    "    t.nombre as turno_nombre " +
                    "FROM profesor prof " +
                    "JOIN persona p ON prof.persona_id = p.id " +
                    "LEFT JOIN usuario u ON p.id = u.persona_id AND u.rol = 'docente' " +
                    "LEFT JOIN turno t ON prof.turno_id = t.id " +
                    "WHERE (p.nombres LIKE ? OR p.apellidos LIKE ? OR " +
                    "CONCAT(p.nombres, ' ', p.apellidos) LIKE ? OR " +
                    "prof.especialidad LIKE ? OR prof.codigo_profesor LIKE ?) " +
                    "AND prof.eliminado = 0 AND prof.activo = 1 " +
                    "ORDER BY p.apellidos, p.nombres";
        try (Connection con = Conexion.getConnection();
             PreparedStatement pstmt = con.prepareStatement(sql)) {
            
            String patron = "%" + criterio + "%";
            pstmt.setString(1, patron);
            pstmt.setString(2, patron);
            pstmt.setString(3, patron);
            pstmt.setString(4, patron);
            pstmt.setString(5, patron);
            
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                Profesor profesor = mapearResultSet(rs);
                profesores.add(profesor);
            }
            
        } catch (SQLException e) {
            System.err.println("Error en buscar: " + e.getMessage());
        }
        
        return profesores;
    }

    public int contar() {
        int total = 0;
        String sql = "SELECT COUNT(*) as total FROM profesor WHERE activo = 1 AND eliminado = 0";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement pstmt = con.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            if (rs.next()) {
                total = rs.getInt("total");
            }
            
        } catch (SQLException e) {
            System.err.println("Error en contar: " + e.getMessage());
        }
        
        return total;
    }
    
    
/**
 * Obtiene todas las áreas únicas disponibles en la base de datos
 * desde la tabla curso (solo el campo 'area')
 */
        public List<String> obtenerEspecialidadesDisponibles() {
            List<String> especialidades = new ArrayList<>();
            String sql = "SELECT DISTINCT area FROM curso WHERE area IS NOT NULL AND area != '' AND activo = 1 AND eliminado = 0 ORDER BY area";

            try (Connection conn = Conexion.getConnection();
                 PreparedStatement pstmt = conn.prepareStatement(sql);
                 ResultSet rs = pstmt.executeQuery()) {

                while (rs.next()) {
                    String area = rs.getString("area");
                    if (area != null && !area.trim().isEmpty()) {
                        especialidades.add(area.trim());
                    }
                }

                System.out.println("Áreas/Especialidades cargadas: " + especialidades.size());

            } catch (SQLException e) {
                System.err.println("Error al obtener especialidades disponibles: " + e.getMessage());
                e.printStackTrace();
            }

            return especialidades;
        }
/**
 * OBTENER TODOS LOS TURNOS DISPONIBLES
 */
public List<Turno> listarTurnos() {
    List<Turno> turnos = new ArrayList<>();
    String sql = "SELECT id, nombre, hora_inicio, hora_fin FROM turno WHERE activo = 1 AND eliminado = 0 ORDER BY nombre";
    
    try (Connection con = Conexion.getConnection();
         PreparedStatement pstmt = con.prepareStatement(sql);
         ResultSet rs = pstmt.executeQuery()) {
        
        while (rs.next()) {
            Turno turno = new Turno();
            turno.setId(rs.getInt("id"));
            turno.setNombre(rs.getString("nombre"));
            turno.setHoraInicio(rs.getTime("hora_inicio"));
            turno.setHoraFin(rs.getTime("hora_fin"));
            turnos.add(turno);
        }
        
    } catch (SQLException e) {
        System.err.println("Error al listar turnos: " + e.getMessage());
    }
    
    return turnos;
}

/**
 * CLASE INTERNA TURNO
 */
public static class Turno {
    private int id;
    private String nombre;
    private java.sql.Time horaInicio;
    private java.sql.Time horaFin;
    
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    
    public java.sql.Time getHoraInicio() { return horaInicio; }
    public void setHoraInicio(java.sql.Time horaInicio) { this.horaInicio = horaInicio; }
    
    public java.sql.Time getHoraFin() { return horaFin; }
    public void setHoraFin(java.sql.Time horaFin) { this.horaFin = horaFin; }
}
    
}