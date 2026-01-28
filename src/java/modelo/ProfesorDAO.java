package modelo;

import conexion.Conexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

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
                    "    prof.area_id, " +
                    "    a.nombre as area_nombre, " +
                    "    p.nombres, " +
                    "    p.apellidos, " +
                    "    p.correo, " +
                    "    p.telefono, " +
                    "    p.dni, " +
                    "    p.fecha_nacimiento, " +
                    "    p.direccion, " +
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
                    "LEFT JOIN area a ON prof.area_id = a.id " +
                    "WHERE prof.eliminado = 0 AND prof.activo = 1 " +
                    "ORDER BY p.apellidos, p.nombres";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
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
        
        p.setAreaId(rs.getInt("area_id"));
        p.setAreaNombre(rs.getString("area_nombre"));
        
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
                    "    prof.area_id, " +
                    "    a.nombre as area_nombre, " +
                    "    p.nombres, " +
                    "    p.apellidos, " +
                    "    p.correo, " +
                    "    p.telefono, " +
                    "    p.dni, " +
                    "    p.fecha_nacimiento, " +
                    "    p.direccion, " +
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
                    "LEFT JOIN area a ON prof.area_id = a.id " +
                    "WHERE prof.id = ? AND prof.eliminado = 0";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return mapearResultSet(rs);
            }
            
        } catch (SQLException e) {
            System.err.println("ERROR en obtenerPorId: " + e.getMessage());
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
        String sqlProfesor = "INSERT INTO profesor (persona_id, area_id, nivel, turno_id, codigo_profesor, " +
                    "fecha_contratacion, estado, activo) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, 1)";
        
        psProfesor = conn.prepareStatement(sqlProfesor, Statement.RETURN_GENERATED_KEYS);
        psProfesor.setInt(1, personaId);
        
        // USAR DIRECTAMENTE area_id
        if (profesor.getAreaId() > 0) {
            psProfesor.setInt(2, profesor.getAreaId());
            System.out.println("Asignando área ID: " + profesor.getAreaId());
        } else {
            psProfesor.setNull(2, Types.INTEGER);
            System.out.println("Sin área asignada");
        }

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
        System.out.println(" Profesor creado exitosamente: " + profesor.getNombreCompleto());
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
 * OBTENER PROFESOR POR USERNAME (Para login)
 */
public Profesor obtenerPorUsername(String username) {
    Profesor profesor = null;
    String sql = "SELECT " +
                "    u.username, u.rol, p.id as persona_id, " +
                "    p.nombres, p.apellidos, pr.turno_id, p.correo, " +
                "    p.telefono, p.dni, p.fecha_nacimiento, p.direccion, " +
                "    pr.id as profesor_id, pr.area_id, a.nombre as area_nombre, " +
                "    pr.codigo_profesor, pr.fecha_contratacion, pr.estado " +
                "FROM usuario u " +
                "INNER JOIN persona p ON u.persona_id = p.id " +
                "INNER JOIN profesor pr ON p.id = pr.persona_id " +
                "LEFT JOIN area a ON pr.area_id = a.id " +
                "WHERE u.username = ? " +
                "AND u.rol = 'docente' " +
                "AND u.activo = 1 AND u.eliminado = 0 " +
                "AND pr.activo = 1 AND pr.eliminado = 0";

    try (Connection conn = Conexion.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ps.setString(1, username);
        ResultSet rs = ps.executeQuery();
        
        if (rs.next()) {
            profesor = new Profesor();
            profesor.setUsername(rs.getString("username"));
            profesor.setRol(rs.getString("rol"));
            profesor.setPersonaId(rs.getInt("persona_id"));
            profesor.setNombres(rs.getString("nombres"));
            profesor.setApellidos(rs.getString("apellidos"));
            profesor.setCorreo(rs.getString("correo"));
            profesor.setTelefono(rs.getString("telefono"));
            profesor.setDni(rs.getString("dni"));
            profesor.setFechaNacimiento(rs.getDate("fecha_nacimiento"));
            profesor.setDireccion(rs.getString("direccion"));
            profesor.setId(rs.getInt("profesor_id"));
            profesor.setAreaId(rs.getInt("area_id"));
            profesor.setAreaNombre(rs.getString("area_nombre"));
            profesor.setCodigoProfesor(rs.getString("codigo_profesor"));
            profesor.setFechaContratacion(rs.getDate("fecha_contratacion"));
            profesor.setEstado(rs.getString("estado"));
            profesor.setTurnoId(rs.getInt("turno_id"));
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
            String sqlProfesor = "UPDATE profesor SET area_id = ?, nivel = ?, turno_id = ?, codigo_profesor = ?, " +
                      "fecha_contratacion = ?, estado = ? WHERE id = ?";
            
            psProfesor = conn.prepareStatement(sqlProfesor);
            
            if (profesor.getAreaId() > 0) {
                psProfesor.setInt(1, profesor.getAreaId());
            } else {
                psProfesor.setNull(1, Types.INTEGER);
            }
                    
            if (profesor.getNivel() != null && !profesor.getNivel().isEmpty()) {
                psProfesor.setString(2, profesor.getNivel());
            } else {
                psProfesor.setNull(2, Types.VARCHAR);
            }
            
            if (profesor.getTurnoId() > 0) {
                psProfesor.setInt(3, profesor.getTurnoId());
            } else {
                psProfesor.setNull(3, Types.INTEGER);
            }

            psProfesor.setString(4, profesor.getCodigoProfesor());
        
            if (profesor.getFechaContratacion() != null) {
                psProfesor.setDate(5, new java.sql.Date(profesor.getFechaContratacion().getTime()));
            } else {
                psProfesor.setNull(5, Types.DATE);
            }
            psProfesor.setString(6, profesor.getEstado());
            psProfesor.setInt(7, profesor.getId());
            psProfesor.executeUpdate();
            
            // 3. Actualizar tabla usuario
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
            System.out.println(" Profesor actualizado: " + profesor.getNombreCompleto());
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
                   "    prof.id, prof.persona_id, prof.turno_id, prof.area_id, " +
                    "    a.nombre as area_nombre, p.nombres, p.apellidos, p.correo, " +
                    "    p.telefono, p.dni, p.fecha_nacimiento, p.direccion, " +
                    "    prof.nivel, prof.codigo_profesor, prof.fecha_contratacion, " +
                    "    prof.estado, u.username, t.nombre as turno_nombre " +
                    "FROM profesor prof " +
                    "JOIN persona p ON prof.persona_id = p.id " +
                    "LEFT JOIN usuario u ON p.id = u.persona_id AND u.rol = 'docente' " +
                    "LEFT JOIN turno t ON prof.turno_id = t.id " +
                    "LEFT JOIN area a ON prof.area_id = a.id " +
                    "WHERE (p.nombres LIKE ? OR p.apellidos LIKE ? OR " +
                    "CONCAT(p.nombres, ' ', p.apellidos) LIKE ? OR " +
                    "a.nombre LIKE ? OR prof.codigo_profesor LIKE ?) " +
                    "AND prof.eliminado = 0 AND prof.activo = 1 " +
                    "ORDER BY p.apellidos, p.nombres";
        try (Connection con = Conexion.getConnection();
             PreparedStatement pstmt = con.prepareStatement(sql)) {
            
            String patron = "%" + criterio + "%";
            for (int i = 1; i <= 5; i++) {
                pstmt.setString(i, patron);
            }
            
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                profesores.add(mapearResultSet(rs));
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
 *  LISTAR ÁREAS - Usa AreaDAO
 */
public List<Area> listarAreas() {
    AreaDAO areaDAO = new AreaDAO();
    return areaDAO.obtenerAreasActivas();
}

/**
 * LISTAR TURNOS - Usa TurnoDAO
 */
public List<Turno> listarTurnos() {
    TurnoDAO turnoDAO = new TurnoDAO();
    return turnoDAO.obtenerTurnosActivos();
}
    
}