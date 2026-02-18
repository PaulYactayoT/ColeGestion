package modelo;

import conexion.Conexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Arrays;

/**
 * DAO para gestión de módulos por usuario/rol
 * HU-16: Asignación de módulos por rol
 */
public class ModuloDAO {

    // ===================================================================
    // LISTAR módulos asignados a un usuario (para construir su menú)
    // ===================================================================
    public List<Modulo> listarPorUsuario(int usuarioId) throws SQLException {
        List<Modulo> lista = new ArrayList<>();
        String sql =
            "SELECT m.*, " +
            "       um.puede_ver, um.puede_crear, um.puede_editar, um.puede_eliminar " +
            "FROM modulo m " +
            "INNER JOIN usuario_modulo um ON m.id = um.modulo_id " +
            "WHERE um.usuario_id = ? " +
            "  AND um.activo   = 1 " +
            "  AND m.activo    = 1 " +
            "  AND m.eliminado = 0 " +
            "ORDER BY m.orden ASC";

        try (Connection conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, usuarioId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Modulo m = mapearModulo(rs);
                    m.setPuedeVer(rs.getBoolean("puede_ver"));
                    m.setPuedeCrear(rs.getBoolean("puede_crear"));
                    m.setPuedeEditar(rs.getBoolean("puede_editar"));
                    m.setPuedeEliminar(rs.getBoolean("puede_eliminar"));
                    m.setAsignado(true);
                    lista.add(m);
                }
            }
        }
        return lista;
    }

    // ===================================================================
    // LISTAR módulos disponibles para asignar (versión simplificada)
    // ===================================================================
    public List<Modulo> listarParaAsignacion(int usuarioId, String rol) throws SQLException {
        return listarParaAsignacion(usuarioId, rol, null);
    }

    // ===================================================================
    // LISTAR módulos disponibles para asignar (versión completa)
    //
    // LÓGICA:
    //  - Si el usuario logueado es ADMIN: muestra TODOS los módulos
    //    del rol_aplicable correspondiente al usuario destino.
    //    * docente       → rol_aplicable = 'docente'
    //    * padre         → rol_aplicable = 'padre'
    //    * administrativo → rol_aplicable = 'admin'  (o 'administrativo' si existe)
    //  - Si no es admin: filtra solo por su rol
    // ===================================================================
    public List<Modulo> listarParaAsignacion(int usuarioId, String rol, String rolUsuarioActual) throws SQLException {
        List<Modulo> lista = new ArrayList<>();

        // NOTA: Ya no filtramos por rolBusqueda, mostramos TODOS los módulos disponibles.
        String sql =
            "SELECT m.*, " +
            "  CASE WHEN um.id IS NOT NULL AND um.activo = 1 THEN 1 ELSE 0 END AS asignado, " +
            "  COALESCE(um.puede_ver,      1) AS puede_ver, " +
            "  COALESCE(um.puede_crear,    0) AS puede_crear, " +
            "  COALESCE(um.puede_editar,   0) AS puede_editar, " +
            "  COALESCE(um.puede_eliminar, 0) AS puede_eliminar " +
            "FROM modulo m " +
            "LEFT JOIN usuario_modulo um " +
            "       ON m.id = um.modulo_id AND um.usuario_id = ? " +
            "WHERE m.activo = 1 " +
            "  AND m.eliminado = 0 " +
            "ORDER BY FIELD(m.rol_aplicable, 'admin', 'administrativo', 'docente', 'padre'), m.orden ASC";

        try (Connection conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, usuarioId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Modulo m = mapearModulo(rs);
                    m.setAsignado(rs.getBoolean("asignado"));
                    m.setPuedeVer(rs.getBoolean("puede_ver"));
                    m.setPuedeCrear(rs.getBoolean("puede_crear"));
                    m.setPuedeEditar(rs.getBoolean("puede_editar"));
                    m.setPuedeEliminar(rs.getBoolean("puede_eliminar"));
                    lista.add(m);
                }
            }
        }
        return lista;
    }

    // ===================================================================
    // GUARDAR: reemplaza todas las asignaciones del usuario.
    // ===================================================================
    public boolean asignarModulosMultiples(int usuarioId,
                                           List<Integer> moduloIds,
                                           int asignadoPor) throws SQLException {

        System.out.println("=== DAO asignarModulosMultiples ===");
        System.out.println("usuarioId: " + usuarioId + " | moduloIds: " + moduloIds);

        if (moduloIds == null || moduloIds.isEmpty()) {
            throw new SQLException("Debe seleccionar al menos un módulo.");
        }

        Connection conn = null;
        try {
            conn = Conexion.getConnection();
            conn.setAutoCommit(false);

            // 1. Eliminar asignaciones anteriores
            try (PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM usuario_modulo WHERE usuario_id = ?")) {
                ps.setInt(1, usuarioId);
                int eliminados = ps.executeUpdate();
                System.out.println("Registros eliminados: " + eliminados);
            }

            // 2. Insertar nuevas asignaciones
            String sqlInsert =
                "INSERT INTO usuario_modulo " +
                "  (usuario_id, modulo_id, puede_ver, puede_crear, " +
                "   puede_editar, puede_eliminar, asignado_por, activo) " +
                "VALUES (?, ?, 1, 1, 1, 1, ?, 1)";

            try (PreparedStatement ps = conn.prepareStatement(sqlInsert)) {
                for (Integer moduloId : moduloIds) {
                    ps.setInt(1, usuarioId);
                    ps.setInt(2, moduloId);
                    ps.setInt(3, asignadoPor);
                    ps.addBatch();
                }
                int[] resultados = ps.executeBatch();
                System.out.println("Insertados: " + resultados.length + " registros");
            }

            conn.commit();
            System.out.println("Commit exitoso");
            return true;

        } catch (SQLException e) {
            System.err.println("Error en DAO.asignarModulosMultiples: " + e.getMessage());
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            throw e;
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); }
                catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }

    // ===================================================================
    // ELIMINAR todas las asignaciones de un usuario
    // ===================================================================
    public boolean eliminarModulosDeUsuario(int usuarioId) throws SQLException {
        String sql = "DELETE FROM usuario_modulo WHERE usuario_id = ?";
        try (Connection conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, usuarioId);
            ps.executeUpdate();
            return true;
        }
    }

    // ===================================================================
    // VERIFICAR acceso a una URL específica
    // ===================================================================
    public boolean tieneAcceso(int usuarioId, String url) throws SQLException {
        String sql =
            "SELECT COUNT(*) FROM modulo m " +
            "INNER JOIN usuario_modulo um ON m.id = um.modulo_id " +
            "WHERE um.usuario_id = ? " +
            "  AND m.url        = ? " +
            "  AND um.activo    = 1 " +
            "  AND m.activo     = 1 " +
            "  AND m.eliminado  = 0";

        try (Connection conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, usuarioId);
            ps.setString(2, url);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    // ===================================================================
    // PRIVADO: Resuelve qué rol_aplicable buscar en la tabla modulo.
    //
    //  - docente        → 'docente'
    //  - padre          → 'padre'
    //  - administrativo → busca primero 'administrativo', si no existe, 'admin'
    //                     (porque en el SQL se insertaron módulos con rol_aplicable='admin'
    //                      para los administrativos)
    // ===================================================================
    private String resolverRolBusqueda(String rol) {
        if (rol == null) return "docente";
        switch (rol.toLowerCase().trim()) {
            case "docente":
            case "profesor":
                return "docente";
            case "padre":
            case "padre de familia":
            case "padredefamilia":
                return "padre";
            case "administrativo":
                // Los módulos de administrativo usan rol_aplicable = 'admin'
                // (según el INSERT del SQL: Gestión de Alumnos, Profesores, etc.)
                // Si en tu BD usas 'administrativo', cámbialo aquí
                return "admin";
            case "admin":
                return "admin";
            default:
                return rol.toLowerCase().trim();
        }
    }

    // ===================================================================
    // PRIVADO: Mapea un ResultSet a un objeto Modulo
    // ===================================================================
    private Modulo mapearModulo(ResultSet rs) throws SQLException {
        Modulo m = new Modulo();
        m.setId(rs.getInt("id"));
        m.setNombre(rs.getString("nombre"));
        m.setDescripcion(rs.getString("descripcion"));
        m.setIcono(rs.getString("icono"));
        m.setUrl(rs.getString("url"));
        m.setOrden(rs.getInt("orden"));
        m.setRolAplicable(rs.getString("rol_aplicable"));
        m.setActivo(rs.getBoolean("activo"));
        m.setEliminado(rs.getBoolean("eliminado"));

        Timestamp ts = rs.getTimestamp("fecha_registro");
        if (ts != null) m.setFechaRegistro(ts.toLocalDateTime());

        return m;
    }
}