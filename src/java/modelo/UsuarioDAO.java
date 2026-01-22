package modelo;

import conexion.Conexion;
import util.PasswordUtils;
import java.sql.*;
import java.util.*;

public class UsuarioDAO {

    // Método para mapear un ResultSet a un objeto Usuario
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

    // Método para obtener datos de bloqueo (FALTANTE)
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

    // Método para actualizar última conexión (FALTANTE)
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

    // Resto de métodos existentes...
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
            ps.setString(3, usuario.getPassword()); // Ya debe venir encriptada
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
}