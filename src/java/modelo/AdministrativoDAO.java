/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelo;

import conexion.Conexion;
import java.sql.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class AdministrativoDAO {

    public List<Administrativo> listar() throws SQLException {
        List<Administrativo> lista = new ArrayList<>();
        
        // ✅ SOLO columnas que EXISTEN en tu BD
        String sql = "SELECT a.id, a.persona_id, a.cargo, a.codigo_administrativo, " +
                     "a.fecha_ingreso, a.departamento, a.foto, a.estado, a.fecha_registro, " +
                     "a.activo, a.eliminado, " +
                     "p.nombres, p.apellidos, p.dni, p.sexo, p.fecha_nacimiento, " +
                     "p.direccion, p.telefono, p.correo " +
                     "FROM administrativo a " +
                     "INNER JOIN persona p ON a.persona_id = p.id " +
                     "WHERE a.eliminado = 0 " +
                     "ORDER BY a.fecha_registro DESC";

        try (Connection conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                lista.add(mapearResultSet(rs));
            }
        }
        return lista;
    }

    public Administrativo obtenerPorId(int id) throws SQLException {
        String sql = "SELECT a.id, a.persona_id, a.cargo, a.codigo_administrativo, " +
                     "a.fecha_ingreso, a.departamento, a.foto, a.estado, a.fecha_registro, " +
                     "a.activo, a.eliminado, " +
                     "p.nombres, p.apellidos, p.dni, p.sexo, p.fecha_nacimiento, " +
                     "p.direccion, p.telefono, p.correo " +
                     "FROM administrativo a " +
                     "INNER JOIN persona p ON a.persona_id = p.id " +
                     "WHERE a.id = ? AND a.eliminado = 0";

        try (Connection conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapearResultSet(rs);
                }
            }
        }
        return null;
    }

    public boolean insertar(Administrativo admin) throws SQLException {
        Connection conn = null;
        try {
            conn = Conexion.getConnection();
            conn.setAutoCommit(false);

            // INSERTAR EN PERSONA (CON sexo)
            String sqlPersona = "INSERT INTO persona (tipo, nombres, apellidos, dni, sexo, " +
                               "fecha_nacimiento, direccion, telefono, correo, activo, eliminado) " +
                               "VALUES ('ADMINISTRATIVO', ?, ?, ?, ?, ?, ?, ?, ?, 1, 0)";

            int personaId;
            try (PreparedStatement psPersona = conn.prepareStatement(sqlPersona, Statement.RETURN_GENERATED_KEYS)) {
                psPersona.setString(1, admin.getNombres());
                psPersona.setString(2, admin.getApellidos());
                psPersona.setString(3, admin.getNumeroDocumento());  // → dni
                psPersona.setString(4, admin.getSexo());  // ✅ SEXO AQUÍ
                psPersona.setDate(5, admin.getFechaNacimiento() != null ? Date.valueOf(admin.getFechaNacimiento()) : null);
                psPersona.setString(6, admin.getDireccion());
                psPersona.setString(7, admin.getTelefono());
                psPersona.setString(8, admin.getCorreo());

                psPersona.executeUpdate();

                ResultSet rs = psPersona.getGeneratedKeys();
                if (rs.next()) {
                    personaId = rs.getInt(1);
                } else {
                    throw new SQLException("Error al obtener ID de persona");
                }
            }

            String codigoAdmin = generarCodigoAdministrativo(conn);

            // INSERTAR EN ADMINISTRATIVO (CON foto)
            String sqlAdmin = "INSERT INTO administrativo (persona_id, cargo, codigo_administrativo, " +
                             "fecha_ingreso, departamento, foto, estado, activo, eliminado) " +
                             "VALUES (?, ?, ?, ?, ?, ?, ?, 1, 0)";

            try (PreparedStatement psAdmin = conn.prepareStatement(sqlAdmin)) {
                psAdmin.setInt(1, personaId);
                psAdmin.setString(2, admin.getCargo());
                psAdmin.setString(3, codigoAdmin);
                psAdmin.setDate(4, admin.getFechaIngreso() != null ? Date.valueOf(admin.getFechaIngreso()) : null);
                psAdmin.setString(5, admin.getDepartamento());
                psAdmin.setString(6, admin.getFoto());  // ← FOTO AQUÍ
                psAdmin.setString(7, admin.getEstado());

                psAdmin.executeUpdate();
            }

            conn.commit();
            return true;

        } catch (SQLException e) {
            if (conn != null) conn.rollback();
            throw e;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }

    public boolean actualizar(Administrativo admin) throws SQLException {
        Connection conn = null;
        try {
            conn = Conexion.getConnection();
            conn.setAutoCommit(false);

            String sqlPersona = "UPDATE persona SET nombres=?, apellidos=?, dni=?, sexo=?, " +
                               "fecha_nacimiento=?, direccion=?, telefono=?, correo=? WHERE id=?";

            try (PreparedStatement psPersona = conn.prepareStatement(sqlPersona)) {
                psPersona.setString(1, admin.getNombres());
                psPersona.setString(2, admin.getApellidos());
                psPersona.setString(3, admin.getNumeroDocumento());  // → dni
                psPersona.setString(4, admin.getSexo());  // ✅ SEXO AQUÍ
                psPersona.setDate(5, admin.getFechaNacimiento() != null ? Date.valueOf(admin.getFechaNacimiento()) : null);
                psPersona.setString(6, admin.getDireccion());
                psPersona.setString(7, admin.getTelefono());
                psPersona.setString(8, admin.getCorreo());
                psPersona.setInt(9, admin.getPersonaId());

                psPersona.executeUpdate();
            }

            // ACTUALIZAR ADMINISTRATIVO (CON foto)
            String sqlAdmin = "UPDATE administrativo SET cargo=?, fecha_ingreso=?, " +
                             "departamento=?, foto=?, estado=?, activo=? WHERE id=?";

            try (PreparedStatement psAdmin = conn.prepareStatement(sqlAdmin)) {
                psAdmin.setString(1, admin.getCargo());
                psAdmin.setDate(2, admin.getFechaIngreso() != null ? Date.valueOf(admin.getFechaIngreso()) : null);
                psAdmin.setString(3, admin.getDepartamento());
                psAdmin.setString(4, admin.getFoto());  // ← FOTO AQUÍ
                psAdmin.setString(5, admin.getEstado());
                psAdmin.setBoolean(6, admin.isActivo());
                psAdmin.setInt(7, admin.getId());

                psAdmin.executeUpdate();
            }

            conn.commit();
            return true;

        } catch (SQLException e) {
            if (conn != null) conn.rollback();
            throw e;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }

    public boolean eliminar(int id) throws SQLException {
        String sql = "UPDATE administrativo SET eliminado = 1, activo = 0 WHERE id = ?";
        try (Connection conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean restaurar(int id) throws SQLException {
        String sql = "UPDATE administrativo SET eliminado = 0, activo = 1 WHERE id = ?";
        try (Connection conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    public List<Administrativo> buscar(String termino) throws SQLException {
        List<Administrativo> lista = new ArrayList<>();
        String sql = "SELECT a.id, a.persona_id, a.cargo, a.codigo_administrativo, " +
                     "a.fecha_ingreso, a.departamento, a.foto, a.estado, a.fecha_registro, " +
                     "a.activo, a.eliminado, " +
                     "p.nombres, p.apellidos, p.dni, p.sexo, p.fecha_nacimiento, " +
                     "p.direccion, p.telefono, p.correo " +
                     "FROM administrativo a " +
                     "INNER JOIN persona p ON a.persona_id = p.id " +
                     "WHERE a.eliminado = 0 " +
                     "AND (p.nombres LIKE ? OR p.apellidos LIKE ? OR p.dni LIKE ? OR a.cargo LIKE ?) " +
                     "ORDER BY a.fecha_registro DESC";

        try (Connection conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            String patron = "%" + termino + "%";
            for (int i = 1; i <= 4; i++) {
                ps.setString(i, patron);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    lista.add(mapearResultSet(rs));
                }
            }
        }
        return lista;
    }

    private String generarCodigoAdministrativo(Connection conn) throws SQLException {
        int anioActual = LocalDate.now().getYear();
        String prefijo = "ADM-" + anioActual + "-";

        String sql = "SELECT MAX(CAST(SUBSTRING(codigo_administrativo, 10) AS UNSIGNED)) AS max_num " +
                     "FROM administrativo WHERE codigo_administrativo LIKE ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, prefijo + "%");
            ResultSet rs = ps.executeQuery();

            int siguienteNumero = 1;
            if (rs.next() && rs.getInt("max_num") > 0) {
                siguienteNumero = rs.getInt("max_num") + 1;
            }

            return String.format("%s%04d", prefijo, siguienteNumero);
        }
    }

    private Administrativo mapearResultSet(ResultSet rs) throws SQLException {
        Administrativo admin = new Administrativo();

        admin.setId(rs.getInt("id"));
        admin.setPersonaId(rs.getInt("persona_id"));
        admin.setCargo(rs.getString("cargo"));
        admin.setCodigoAdministrativo(rs.getString("codigo_administrativo"));

        Date fechaIngreso = rs.getDate("fecha_ingreso");
        admin.setFechaIngreso(fechaIngreso != null ? fechaIngreso.toLocalDate() : null);

        admin.setDepartamento(rs.getString("departamento"));
        admin.setFoto(rs.getString("foto"));  // ← FOTO desde administrativo
        admin.setEstado(rs.getString("estado"));

        Timestamp fechaRegistro = rs.getTimestamp("fecha_registro");
        admin.setFechaRegistro(fechaRegistro != null ? fechaRegistro.toLocalDateTime() : null);

        admin.setActivo(rs.getBoolean("activo"));
        admin.setEliminado(rs.getBoolean("eliminado"));

        // Datos de persona
        admin.setNombres(rs.getString("nombres"));
        admin.setApellidos(rs.getString("apellidos"));
        admin.setNumeroDocumento(rs.getString("dni"));  // dni → numeroDocumento

        Date fechaNacimiento = rs.getDate("fecha_nacimiento");
        admin.setFechaNacimiento(fechaNacimiento != null ? fechaNacimiento.toLocalDate() : null);

        admin.setDireccion(rs.getString("direccion"));
        admin.setTelefono(rs.getString("telefono"));
        admin.setCorreo(rs.getString("correo"));
        admin.setSexo(rs.getString("sexo"));

        return admin;
    }

    public boolean existeDNI(String dni, int idExcluir) throws SQLException {
        String sql = "SELECT COUNT(*) FROM persona p " +
                     "INNER JOIN administrativo a ON p.id = a.persona_id " +
                     "WHERE p.dni = ? AND a.id != ? AND a.eliminado = 0";

        try (Connection conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, dni);
            ps.setInt(2, idExcluir);

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        }
        return false;
    }
}