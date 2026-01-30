package modelo;

import conexion.Conexion;
import util.PasswordUtils;
import java.sql.*;
import java.util.*;

public class UsuarioDAO {

    /**
     * ===================================================================
     * NUEVO: OBTENER PERSONAS SIN USUARIO (PARA ASIGNACIÓN)
     * ===================================================================
     */
    
    /**
     * Obtener todos los profesores que NO tienen usuario asignado
     */
    public List<PersonaSinUsuario> obtenerProfesoresSinUsuario() {
        List<PersonaSinUsuario> personas = new ArrayList<>();
        
        String sql = "SELECT " +
                    "p.id, " +
                    "p.nombres, " +
                    "p.apellidos, " +
                    "p.correo, " +
                    "p.dni, " +
                    "prof.codigo_profesor, " +
                    "a.nombre as area_nombre, " +
                    "'PROFESOR' as tipo_persona " +
                    "FROM persona p " +
                    "INNER JOIN profesor prof ON p.id = prof.persona_id " +
                    "LEFT JOIN area a ON prof.area_id = a.id " +
                    "LEFT JOIN usuario u ON p.id = u.persona_id " +
                    "WHERE p.activo = 1 " +
                    "AND p.eliminado = 0 " +
                    "AND prof.activo = 1 " +
                    "AND prof.eliminado = 0 " +
                    "AND u.id IS NULL " +
                    "ORDER BY p.apellidos, p.nombres";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                PersonaSinUsuario persona = new PersonaSinUsuario();
                persona.setPersonaId(rs.getInt("id"));
                persona.setNombres(rs.getString("nombres"));
                persona.setApellidos(rs.getString("apellidos"));
                persona.setCorreo(rs.getString("correo"));
                persona.setDni(rs.getString("dni"));
                persona.setCodigo(rs.getString("codigo_profesor"));
                persona.setInformacionAdicional(rs.getString("area_nombre"));
                persona.setTipoPersona(rs.getString("tipo_persona"));
                personas.add(persona);
            }
            
            System.out.println("✅ Profesores sin usuario encontrados: " + personas.size());
            
        } catch (SQLException e) {
            System.err.println("❌ Error al obtener profesores sin usuario: " + e.getMessage());
            e.printStackTrace();
        }
        
        return personas;
    }
    
    /**
     * Obtener todos los alumnos que NO tienen usuario asignado
     */
    public List<PersonaSinUsuario> obtenerAlumnosSinUsuario() {
        List<PersonaSinUsuario> personas = new ArrayList<>();
        
        String sql = "SELECT " +
                    "p.id, " +
                    "p.nombres, " +
                    "p.apellidos, " +
                    "p.correo, " +
                    "p.dni, " +
                    "a.codigo_alumno, " +
                    "g.nombre as grado_nombre, " +
                    "'ALUMNO' as tipo_persona " +
                    "FROM persona p " +
                    "INNER JOIN alumno a ON p.id = a.persona_id " +
                    "LEFT JOIN grado g ON a.grado_id = g.id " +
                    "LEFT JOIN usuario u ON p.id = u.persona_id " +
                    "WHERE p.activo = 1 " +
                    "AND p.eliminado = 0 " +
                    "AND a.activo = 1 " +
                    "AND a.eliminado = 0 " +
                    "AND u.id IS NULL " +
                    "ORDER BY p.apellidos, p.nombres";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                PersonaSinUsuario persona = new PersonaSinUsuario();
                persona.setPersonaId(rs.getInt("id"));
                persona.setNombres(rs.getString("nombres"));
                persona.setApellidos(rs.getString("apellidos"));
                persona.setCorreo(rs.getString("correo"));
                persona.setDni(rs.getString("dni"));
                persona.setCodigo(rs.getString("codigo_alumno"));
                persona.setInformacionAdicional(rs.getString("grado_nombre"));
                persona.setTipoPersona(rs.getString("tipo_persona"));
                personas.add(persona);
            }
            
            System.out.println("✅ Alumnos sin usuario encontrados: " + personas.size());
            
        } catch (SQLException e) {
            System.err.println("❌ Error al obtener alumnos sin usuario: " + e.getMessage());
            e.printStackTrace();
        }
        
        return personas;
    }
    
    /**
     * Obtener todos los administrativos que NO tienen usuario asignado
     */
    public List<PersonaSinUsuario> obtenerAdministrativosSinUsuario() {
        List<PersonaSinUsuario> personas = new ArrayList<>();
        
        String sql = "SELECT " +
                    "p.id, " +
                    "p.nombres, " +
                    "p.apellidos, " +
                    "p.correo, " +
                    "p.dni, " +
                    "adm.codigo_administrativo, " +
                    "adm.cargo, " +
                    "'ADMINISTRATIVO' as tipo_persona " +
                    "FROM persona p " +
                    "INNER JOIN administrativo adm ON p.id = adm.persona_id " +
                    "LEFT JOIN usuario u ON p.id = u.persona_id " +
                    "WHERE p.activo = 1 " +
                    "AND p.eliminado = 0 " +
                    "AND adm.activo = 1 " +
                    "AND adm.eliminado = 0 " +
                    "AND u.id IS NULL " +
                    "ORDER BY p.apellidos, p.nombres";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                PersonaSinUsuario persona = new PersonaSinUsuario();
                persona.setPersonaId(rs.getInt("id"));
                persona.setNombres(rs.getString("nombres"));
                persona.setApellidos(rs.getString("apellidos"));
                persona.setCorreo(rs.getString("correo"));
                persona.setDni(rs.getString("dni"));
                persona.setCodigo(rs.getString("codigo_administrativo"));
                persona.setInformacionAdicional(rs.getString("cargo"));
                persona.setTipoPersona(rs.getString("tipo_persona"));
                personas.add(persona);
            }
            
            System.out.println("✅ Administrativos sin usuario encontrados: " + personas.size());
            
        } catch (SQLException e) {
            System.err.println("❌ Error al obtener administrativos sin usuario: " + e.getMessage());
            e.printStackTrace();
        }
        
        return personas;
    }
    
    /**
     * Obtener información completa de una persona por su ID
     */
    public PersonaSinUsuario obtenerPersonaPorId(int personaId) {
        PersonaSinUsuario persona = null;
        
        String sql = "SELECT " +
                    "p.id, " +
                    "p.nombres, " +
                    "p.apellidos, " +
                    "p.correo, " +
                    "p.dni, " +
                    "p.tipo " +
                    "FROM persona p " +
                    "WHERE p.id = ? " +
                    "AND p.activo = 1 " +
                    "AND p.eliminado = 0";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, personaId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    persona = new PersonaSinUsuario();
                    persona.setPersonaId(rs.getInt("id"));
                    persona.setNombres(rs.getString("nombres"));
                    persona.setApellidos(rs.getString("apellidos"));
                    persona.setCorreo(rs.getString("correo"));
                    persona.setDni(rs.getString("dni"));
                    persona.setTipoPersona(rs.getString("tipo"));
                }
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error al obtener persona por ID: " + e.getMessage());
            e.printStackTrace();
        }
        
        return persona;
    }

    // ===================================================================
    // MÉTODOS EXISTENTES (mantenidos)
    // ===================================================================

    private Usuario mapearUsuario(ResultSet rs) throws SQLException {
        Usuario usuario = new Usuario();
        usuario.setId(rs.getInt("id"));
        usuario.setPersonaId(rs.getInt("persona_id"));
        usuario.setUsername(rs.getString("username"));
        usuario.setPassword(rs.getString("password"));
        usuario.setRol(rs.getString("rol"));
        usuario.setIntentosFallidos(rs.getInt("intentos_fallidos"));
        usuario.setFechaBloqueo(rs.getTimestamp("fecha_bloqueo"));
        usuario.setUltimaConexion(rs.getTimestamp("ultima_conexion"));
        usuario.setFechaRegistro(rs.getTimestamp("fecha_registro"));
        usuario.setActivo(rs.getBoolean("activo"));
        usuario.setEliminado(rs.getBoolean("eliminado"));
        return usuario;
    }

    public Usuario obtenerDatosBloqueo(String username) {
        Usuario usuario = null;
        String sql = "SELECT intentos_fallidos, fecha_bloqueo FROM usuario WHERE username = ? AND eliminado = 0";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    usuario = new Usuario();
                    usuario.setIntentosFallidos(rs.getInt("intentos_fallidos"));
                    usuario.setFechaBloqueo(rs.getTimestamp("fecha_bloqueo"));
                }
            }
            
        } catch (Exception e) {
            System.err.println("Error al obtener datos de bloqueo: " + e.getMessage());
            e.printStackTrace();
        }
        
        return usuario;
    }

    public boolean actualizarUltimaConexion(String username) {
        String sql = "UPDATE usuario SET ultima_conexion = NOW() WHERE username = ?";
        
        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, username);
            int filasAfectadas = ps.executeUpdate();
            return filasAfectadas > 0;
            
        } catch (Exception e) {
            System.err.println("Error al actualizar última conexión: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public List<Usuario> listar() {
        List<Usuario> usuarios = new ArrayList<>();
        String sql = "SELECT * FROM usuario WHERE eliminado = 0";

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                usuarios.add(mapearUsuario(rs));
            }

        } catch (Exception e) {
            System.err.println("Error al listar usuarios: " + e.getMessage());
            e.printStackTrace();
        }

        return usuarios;
    }

    public Usuario obtenerPorId(int id) {
        Usuario usuario = null;
        String sql = "SELECT * FROM usuario WHERE id = ? AND eliminado = 0";

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    usuario = mapearUsuario(rs);
                }
            }

        } catch (Exception e) {
            System.err.println("Error al obtener usuario por ID: " + e.getMessage());
            e.printStackTrace();
        }

        return usuario;
    }

    public Usuario obtenerPorUsername(String username) {
        Usuario usuario = null;
        String sql = "SELECT * FROM usuario WHERE username = ? AND eliminado = 0";

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    usuario = mapearUsuario(rs);
                }
            }

        } catch (Exception e) {
            System.err.println("Error al obtener usuario por username: " + e.getMessage());
            e.printStackTrace();
        }

        return usuario;
    }

    public boolean agregar(Usuario usuario) {
        String sql = "INSERT INTO usuario (persona_id, username, password, rol, intentos_fallidos, fecha_bloqueo, ultima_conexion, fecha_registro, activo, eliminado) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, usuario.getPersonaId());
            ps.setString(2, usuario.getUsername());
            ps.setString(3, usuario.getPassword());
            ps.setString(4, usuario.getRol());
            ps.setInt(5, usuario.getIntentosFallidos());
            
            if (usuario.getFechaBloqueo() != null) {
                ps.setTimestamp(6, new Timestamp(usuario.getFechaBloqueo().getTime()));
            } else {
                ps.setNull(6, Types.TIMESTAMP);
            }
            
            if (usuario.getUltimaConexion() != null) {
                ps.setTimestamp(7, new Timestamp(usuario.getUltimaConexion().getTime()));
            } else {
                ps.setNull(7, Types.TIMESTAMP);
            }
            
            if (usuario.getFechaRegistro() != null) {
                ps.setTimestamp(8, new Timestamp(usuario.getFechaRegistro().getTime()));
            } else {
                ps.setTimestamp(8, new Timestamp(System.currentTimeMillis()));
            }
            
            ps.setBoolean(9, usuario.isActivo());
            ps.setBoolean(10, usuario.isEliminado());

            int filasAfectadas = ps.executeUpdate();
            return filasAfectadas > 0;

        } catch (Exception e) {
            System.err.println("Error al agregar usuario: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public boolean actualizar(Usuario usuario) {
        String sql = "UPDATE usuario SET persona_id = ?, username = ?, password = ?, rol = ?, "
                   + "intentos_fallidos = ?, fecha_bloqueo = ?, ultima_conexion = ?, "
                   + "fecha_registro = ?, activo = ?, eliminado = ? WHERE id = ?";

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, usuario.getPersonaId());
            ps.setString(2, usuario.getUsername());
            ps.setString(3, usuario.getPassword());
            ps.setString(4, usuario.getRol());
            ps.setInt(5, usuario.getIntentosFallidos());
            
            if (usuario.getFechaBloqueo() != null) {
                ps.setTimestamp(6, new Timestamp(usuario.getFechaBloqueo().getTime()));
            } else {
                ps.setNull(6, Types.TIMESTAMP);
            }
            
            if (usuario.getUltimaConexion() != null) {
                ps.setTimestamp(7, new Timestamp(usuario.getUltimaConexion().getTime()));
            } else {
                ps.setNull(7, Types.TIMESTAMP);
            }
            
            if (usuario.getFechaRegistro() != null) {
                ps.setTimestamp(8, new Timestamp(usuario.getFechaRegistro().getTime()));
            } else {
                ps.setNull(8, Types.TIMESTAMP);
            }
            
            ps.setBoolean(9, usuario.isActivo());
            ps.setBoolean(10, usuario.isEliminado());
            ps.setInt(11, usuario.getId());

            int filasAfectadas = ps.executeUpdate();
            return filasAfectadas > 0;

        } catch (Exception e) {
            System.err.println("Error al actualizar usuario: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public boolean eliminar(int id) {
        String sql = "UPDATE usuario SET eliminado = 1, activo = 0 WHERE id = ?";

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            int filasAfectadas = ps.executeUpdate();
            return filasAfectadas > 0;

        } catch (Exception e) {
            System.err.println("Error al eliminar usuario: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public boolean verificarCredencialesConHash(String username, String hashedPasswordFromFrontend) {
        String sql = "SELECT password FROM usuario WHERE username = ? AND activo = 1 AND eliminado = 0";

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String hashedPasswordInDB = rs.getString("password");
                    return hashedPasswordFromFrontend.equals(hashedPasswordInDB);
                }
            }

        } catch (Exception e) {
            System.err.println("Error al verificar credenciales con hash: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    public boolean verificarCredenciales(String username, String plainPassword) {
        String sql = "SELECT password FROM usuario WHERE username = ? AND activo = 1 AND eliminado = 0";

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String hashedPassword = rs.getString("password");
                    return PasswordUtils.checkPassword(plainPassword, hashedPassword);
                }
            }

        } catch (Exception e) {
            System.err.println("Error al verificar credenciales: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    public boolean existeUsuario(String username) {
        String sql = "SELECT COUNT(*) FROM usuario WHERE username = ? AND eliminado = 0";

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }

        } catch (Exception e) {
            System.err.println("Error al verificar existencia de usuario: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    public boolean incrementarIntentoFallido(String username) {
        String sql = "UPDATE usuario SET intentos_fallidos = intentos_fallidos + 1, ultima_conexion = NOW() WHERE username = ?";

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, username);
            int filasAfectadas = ps.executeUpdate();
            return filasAfectadas > 0;

        } catch (Exception e) {
            System.err.println("Error al incrementar intento fallido: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public boolean bloquearUsuario(String username) {
        String sql = "UPDATE usuario SET activo = 0, fecha_bloqueo = NOW(), intentos_fallidos = 3 WHERE username = ?";

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, username);
            int filasAfectadas = ps.executeUpdate();
            return filasAfectadas > 0;

        } catch (Exception e) {
            System.err.println("Error al bloquear usuario: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public boolean resetearIntentosUsuario(String username) {
        String sql = "UPDATE usuario SET intentos_fallidos = 0, fecha_bloqueo = NULL, activo = 1 WHERE username = ?";

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, username);
            int filasAfectadas = ps.executeUpdate();
            return filasAfectadas > 0;

        } catch (Exception e) {
            System.err.println("Error al resetear intentos de usuario: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public boolean estaBloqueado(String username) {
        String sql = "SELECT activo, fecha_bloqueo FROM usuario WHERE username = ? AND eliminado = 0";

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    boolean activo = rs.getBoolean("activo");
                    Timestamp fechaBloqueo = rs.getTimestamp("fecha_bloqueo");
                    return !activo && fechaBloqueo != null;
                }
            }

        } catch (Exception e) {
            System.err.println("Error al verificar bloqueo de usuario: " + e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    public boolean desbloquearUsuariosExpirados(int minutosBloqueo) {
        String sql = "UPDATE usuario SET intentos_fallidos = 0, fecha_bloqueo = NULL, activo = 1 "
                   + "WHERE activo = 0 AND fecha_bloqueo IS NOT NULL "
                   + "AND fecha_bloqueo < DATE_SUB(NOW(), INTERVAL ? MINUTE)";

        try (Connection con = Conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, minutosBloqueo);
            int filas = ps.executeUpdate();
            if (filas > 0) {
                System.out.println("✅ Usuarios desbloqueados automáticamente: " + filas);
            }
            return true;

        } catch (Exception e) {
            System.err.println("Error al desbloquear usuarios expirados: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // ===================================================================
    // CLASE INTERNA: PersonaSinUsuario
    // ===================================================================
    
    public static class PersonaSinUsuario {
        private int personaId;
        private String nombres;
        private String apellidos;
        private String correo;
        private String dni;
        private String codigo; // codigo_profesor, codigo_alumno, etc.
        private String informacionAdicional; // area, grado, cargo, etc.
        private String tipoPersona; // PROFESOR, ALUMNO, ADMINISTRATIVO
        
        // Getters y Setters
        public int getPersonaId() { return personaId; }
        public void setPersonaId(int personaId) { this.personaId = personaId; }
        
        public String getNombres() { return nombres; }
        public void setNombres(String nombres) { this.nombres = nombres; }
        
        public String getApellidos() { return apellidos; }
        public void setApellidos(String apellidos) { this.apellidos = apellidos; }
        
        public String getCorreo() { return correo; }
        public void setCorreo(String correo) { this.correo = correo; }
        
        public String getDni() { return dni; }
        public void setDni(String dni) { this.dni = dni; }
        
        public String getCodigo() { return codigo; }
        public void setCodigo(String codigo) { this.codigo = codigo; }
        
        public String getInformacionAdicional() { return informacionAdicional; }
        public void setInformacionAdicional(String informacionAdicional) { 
            this.informacionAdicional = informacionAdicional; 
        }
        
        public String getTipoPersona() { return tipoPersona; }
        public void setTipoPersona(String tipoPersona) { this.tipoPersona = tipoPersona; }
        
        public String getNombreCompleto() {
            return nombres + " " + apellidos;
        }
        
        public String getDescripcionCompleta() {
            StringBuilder desc = new StringBuilder();
            desc.append(getNombreCompleto());
            if (codigo != null && !codigo.isEmpty()) {
                desc.append(" [").append(codigo).append("]");
            }
            if (informacionAdicional != null && !informacionAdicional.isEmpty()) {
                desc.append(" - ").append(informacionAdicional);
            }
            return desc.toString();
        }
    }
}