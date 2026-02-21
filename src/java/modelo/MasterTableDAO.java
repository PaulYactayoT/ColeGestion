package modelo;

import conexion.Conexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * MasterTableDAO - Gestiona catálogos desde master_table
 * Versión combinada: incluye métodos de gestión completa (CRUD, filtros, estadísticas)
 * y métodos de consulta de catálogo (obtenerCatalogo, obtenerPorValue, existeValue)
 */
public class MasterTableDAO {

    private Connection connection;

    public MasterTableDAO() {
        this.connection = Conexion.getConnection();
    }

    // ============================================================
    // LISTAR TODAS LAS CATEGORÍAS
    // ============================================================
    public List<MasterTable> listarCategorias() throws SQLException {
        List<MasterTable> categorias = new ArrayList<>();

        String sql = "SELECT DISTINCT mt.Category as category_code, " +
                     "MAX(CASE WHEN mt.IdMasterTableParent IS NULL THEN mt.Name ELSE mt.Category END) as category_name, " +
                     "MAX(CASE WHEN mt.IdMasterTableParent IS NULL THEN mt.Description ELSE NULL END) as description, " +
                     "COUNT(CASE WHEN mt.IdMasterTableParent IS NOT NULL THEN 1 END) as total_values, " +
                     "MAX(CASE WHEN mt.IdMasterTableParent IS NULL THEN mt.IdMasterTable ELSE 0 END) as id " +
                     "FROM master_table mt " +
                     "GROUP BY mt.Category " +
                     "ORDER BY mt.Category";

        try (PreparedStatement stmt = connection.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                MasterTable mt = new MasterTable();
                mt.setIdMasterTable(rs.getInt("id"));
                mt.setCategory(rs.getString("category_code"));
                mt.setName(rs.getString("category_name"));
                mt.setDescription(rs.getString("description"));
                mt.setTotalValues(rs.getInt("total_values"));
                categorias.add(mt);
            }
        }
        return categorias;
    }

    // ============================================================
    // LISTAR VALORES POR CATEGORÍA (retorna List<MasterTable>)
    // ============================================================
    public List<MasterTable> listarPorCategoria(String category) throws SQLException {
        List<MasterTable> valores = new ArrayList<>();

        String sql = "SELECT IdMasterTable as id, Value as value, Name as name, " +
                     "Description as description, OrderIndex as order_index, " +
                     "AdditionalOne as additional_one, AdditionalTwo as additional_two, " +
                     "AdditionalThree as additional_three, AdditionalFour as additional_four, " +
                     "Status, Category " +
                     "FROM master_table " +
                     "WHERE Category = ? AND IdMasterTableParent IS NOT NULL " +
                     "AND Status = 'A' " +
                     "ORDER BY OrderIndex, Name";

        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, category);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    MasterTable mt = new MasterTable();
                    mt.setIdMasterTable(rs.getInt("id"));
                    mt.setValue(rs.getString("value"));
                    mt.setName(rs.getString("name"));
                    mt.setDescription(rs.getString("description"));
                    mt.setOrderIndex(rs.getInt("order_index"));
                    mt.setAdditionalOne(rs.getString("additional_one"));
                    mt.setAdditionalTwo(rs.getString("additional_two"));
                    mt.setAdditionalThree(rs.getString("additional_three"));
                    mt.setAdditionalFour(rs.getString("additional_four"));
                    mt.setCategory(category);
                    valores.add(mt);
                }
            }
        }
        return valores;
    }

    // ============================================================
    // OBTENER CATÁLOGO (retorna List<CatalogoItem>) - método de tu amiga
    // ============================================================
    public List<CatalogoItem> obtenerCatalogo(String category) throws SQLException {
        List<CatalogoItem> lista = new ArrayList<>();

        String sql = "SELECT IdMasterTable, Category, Value, Name, Description, OrderIndex, " +
                     "AdditionalOne, AdditionalTwo, AdditionalThree, AdditionalFour " +
                     "FROM master_table " +
                     "WHERE Category = ? AND Status = 'A' " +
                     "ORDER BY OrderIndex ASC, Name ASC";

        try (Connection conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, category);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CatalogoItem item = new CatalogoItem();
                    item.setId(rs.getInt("IdMasterTable"));
                    item.setCategory(rs.getString("Category"));
                    item.setValue(rs.getString("Value"));
                    item.setName(rs.getString("Name"));
                    item.setDescription(rs.getString("Description"));
                    item.setOrderIndex(rs.getInt("OrderIndex"));
                    item.setAdditionalOne(rs.getString("AdditionalOne"));
                    item.setAdditionalTwo(rs.getString("AdditionalTwo"));
                    item.setAdditionalThree(rs.getString("AdditionalThree"));
                    item.setAdditionalFour(rs.getString("AdditionalFour"));
                    lista.add(item);
                }
            }
        }
        return lista;
    }

    // ============================================================
    // OBTENER POR VALUE (category + value) - método de tu amiga
    // ============================================================
    public CatalogoItem obtenerPorValue(String category, String value) throws SQLException {
        String sql = "SELECT IdMasterTable, Category, Value, Name, Description, OrderIndex, " +
                     "AdditionalOne, AdditionalTwo, AdditionalThree, AdditionalFour " +
                     "FROM master_table " +
                     "WHERE Category = ? AND Value = ? AND Status = 'A'";

        try (Connection conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, category);
            ps.setString(2, value);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    CatalogoItem item = new CatalogoItem();
                    item.setId(rs.getInt("IdMasterTable"));
                    item.setCategory(rs.getString("Category"));
                    item.setValue(rs.getString("Value"));
                    item.setName(rs.getString("Name"));
                    item.setDescription(rs.getString("Description"));
                    item.setOrderIndex(rs.getInt("OrderIndex"));
                    item.setAdditionalOne(rs.getString("AdditionalOne"));
                    item.setAdditionalTwo(rs.getString("AdditionalTwo"));
                    item.setAdditionalThree(rs.getString("AdditionalThree"));
                    item.setAdditionalFour(rs.getString("AdditionalFour"));
                    return item;
                }
            }
        }
        return null;
    }

    // ============================================================
    // VERIFICAR SI EXISTE UN VALUE - método de tu amiga
    // ============================================================
    public boolean existeValue(String category, String value) throws SQLException {
        String sql = "SELECT COUNT(*) FROM master_table " +
                     "WHERE Category = ? AND Value = ? AND Status = 'A'";

        try (Connection conn = Conexion.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, category);
            ps.setString(2, value);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }

    // ============================================================
    // OBTENER POR ID
    // ============================================================
    public MasterTable obtenerPorId(int id) throws SQLException {
        MasterTable mt = null;
        String sql = "SELECT * FROM master_table WHERE IdMasterTable = ?";

        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, id);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    mt = mapearResultSet(rs);
                }
            }
        }
        return mt;
    }

    // ============================================================
    // INSERTAR NUEVO VALOR - CON FALLBACK
    // ============================================================
    public boolean insertar(MasterTable mt) throws SQLException {
        try {
            String sql = "{CALL sp_insert_master_value(?, ?, ?, ?, ?, ?, ?)}";
            try (CallableStatement stmt = connection.prepareCall(sql)) {
                stmt.setString(1, mt.getCategory());
                stmt.setString(2, mt.getValue());
                stmt.setString(3, mt.getDescription());
                stmt.setString(4, mt.getName());
                stmt.setInt(5, mt.getOrderIndex());
                stmt.setString(6, mt.getAdditionalOne());
                stmt.setString(7, mt.getAdditionalTwo());

                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        return rs.getInt("success") == 1;
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("SP falló, usando INSERT directo: " + e.getMessage());
            return insertarDirecto(mt);
        }
        return false;
    }

    private boolean insertarDirecto(MasterTable mt) throws SQLException {
        Integer parentId = obtenerIdCategoriaPadre(mt.getCategory());

        String sql = "INSERT INTO master_table " +
                     "(IdMasterTableParent, Category, Value, Name, Description, OrderIndex, " +
                     "AdditionalOne, AdditionalTwo, AdditionalThree, AdditionalFour, " +
                     "DatabaseWebId, HostId, Status, CreatedAt, UpdatedAt) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'ADMIN', '20210130', 'A', NOW(), NOW())";

        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setObject(1, parentId);
            stmt.setString(2, mt.getCategory());
            stmt.setString(3, mt.getValue());
            stmt.setString(4, mt.getName());
            stmt.setString(5, mt.getDescription());
            stmt.setInt(6, mt.getOrderIndex());
            stmt.setString(7, mt.getAdditionalOne());
            stmt.setString(8, mt.getAdditionalTwo());
            stmt.setString(9, mt.getAdditionalThree());
            stmt.setString(10, mt.getAdditionalFour());

            return stmt.executeUpdate() > 0;
        }
    }

    private Integer obtenerIdCategoriaPadre(String category) throws SQLException {
        String sql = "SELECT IdMasterTable FROM master_table WHERE Category = ? AND IdMasterTableParent IS NULL LIMIT 1";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, category);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("IdMasterTable");
                }
            }
        }
        return null;
    }

    // ============================================================
    // ACTUALIZAR VALOR - CON FALLBACK
    // ============================================================
    public boolean actualizar(MasterTable mt) throws SQLException {
        try {
            String sql = "{CALL sp_update_master_value(?, ?, ?, ?, ?, ?, ?)}";
            try (CallableStatement stmt = connection.prepareCall(sql)) {
                stmt.setInt(1, mt.getIdMasterTable());
                stmt.setString(2, mt.getValue());
                stmt.setString(3, mt.getDescription());
                stmt.setString(4, mt.getName());
                stmt.setInt(5, mt.getOrderIndex());
                stmt.setString(6, mt.getAdditionalOne());
                stmt.setString(7, mt.getAdditionalTwo());

                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        return rs.getInt("success") == 1;
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("SP falló, usando UPDATE directo: " + e.getMessage());
            return actualizarDirecto(mt);
        }
        return false;
    }

    private boolean actualizarDirecto(MasterTable mt) throws SQLException {
        String sql = "UPDATE master_table SET " +
                     "Value = ?, Name = ?, Description = ?, OrderIndex = ?, " +
                     "AdditionalOne = ?, AdditionalTwo = ?, AdditionalThree = ?, " +
                     "AdditionalFour = ?, UpdatedAt = NOW() " +
                     "WHERE IdMasterTable = ?";

        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, mt.getValue());
            stmt.setString(2, mt.getName());
            stmt.setString(3, mt.getDescription());
            stmt.setInt(4, mt.getOrderIndex());
            stmt.setString(5, mt.getAdditionalOne());
            stmt.setString(6, mt.getAdditionalTwo());
            stmt.setString(7, mt.getAdditionalThree());
            stmt.setString(8, mt.getAdditionalFour());
            stmt.setInt(9, mt.getIdMasterTable());

            return stmt.executeUpdate() > 0;
        }
    }

    // ============================================================
    // ELIMINAR (DESACTIVAR - cambia Status a 'I') - CON FALLBACK
    // ============================================================
    public boolean eliminar(int id) throws SQLException {
        try {
            String sql = "{CALL sp_delete_master_value(?)}";
            try (CallableStatement stmt = connection.prepareCall(sql)) {
                stmt.setInt(1, id);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) return rs.getInt("success") == 1;
                }
            }
        } catch (SQLException e) {
            String sql = "UPDATE master_table SET Status = 'I', UpdatedAt = NOW() WHERE IdMasterTable = ?";
            try (PreparedStatement stmt = connection.prepareStatement(sql)) {
                stmt.setInt(1, id);
                return stmt.executeUpdate() > 0;
            }
        }
        return false;
    }

    // ============================================================
    // ELIMINAR LÓGICAMENTE (campo eliminado = 1)
    // ============================================================
    public boolean eliminarLogico(int id) throws SQLException {
        String sql = "UPDATE master_table SET eliminado = 1, UpdatedAt = NOW() WHERE IdMasterTable = ?";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        }
    }

    // ============================================================
    // ACTIVAR - CON FALLBACK
    // ============================================================
    public boolean activar(int id) throws SQLException {
        try {
            String sql = "{CALL sp_activate_master_value(?)}";
            try (CallableStatement stmt = connection.prepareCall(sql)) {
                stmt.setInt(1, id);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) return rs.getInt("success") == 1;
                }
            }
        } catch (SQLException e) {
            String sql = "UPDATE master_table SET Status = 'A', UpdatedAt = NOW() WHERE IdMasterTable = ?";
            try (PreparedStatement stmt = connection.prepareStatement(sql)) {
                stmt.setInt(1, id);
                return stmt.executeUpdate() > 0;
            }
        }
        return false;
    }

    // ============================================================
    // BUSCAR VALORES
    // ============================================================
    public List<MasterTable> buscar(String searchTerm) throws SQLException {
        List<MasterTable> resultados = new ArrayList<>();

        String sql = "SELECT IdMasterTable as id, Category as category, Value as value, " +
                     "Name as name, Description as description, OrderIndex as order_index " +
                     "FROM master_table " +
                     "WHERE IdMasterTableParent IS NOT NULL " +
                     "AND (Name LIKE ? OR Value LIKE ? OR Description LIKE ? OR Category LIKE ?) " +
                     "ORDER BY Category, OrderIndex, Name " +
                     "LIMIT 100";

        String term = "%" + searchTerm + "%";

        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, term);
            stmt.setString(2, term);
            stmt.setString(3, term);
            stmt.setString(4, term);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    MasterTable mt = new MasterTable();
                    mt.setIdMasterTable(rs.getInt("id"));
                    mt.setCategory(rs.getString("category"));
                    mt.setValue(rs.getString("value"));
                    mt.setName(rs.getString("name"));
                    mt.setDescription(rs.getString("description"));
                    mt.setOrderIndex(rs.getInt("order_index"));
                    resultados.add(mt);
                }
            }
        }
        return resultados;
    }

    // ============================================================
    // OBTENER ESTADÍSTICAS - CON FALLBACK
    // ============================================================
    public List<String[]> obtenerEstadisticas() throws SQLException {
        List<String[]> stats = new ArrayList<>();

        try {
            String sql = "{CALL sp_master_table_stats()}";
            try (CallableStatement stmt = connection.prepareCall(sql);
                 ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    stats.add(new String[]{rs.getString("metric"), rs.getString("value")});
                }
            }
            if (!stats.isEmpty()) return stats;
        } catch (SQLException e) {
            System.err.println("SP stats falló, usando queries directas");
        }

        String[] queries = {
            "SELECT 'Total Registros' as metric, CAST(COUNT(*) AS CHAR) as value FROM master_table WHERE IdMasterTableParent IS NOT NULL",
            "SELECT 'Registros Activos' as metric, CAST(COUNT(*) AS CHAR) as value FROM master_table WHERE Status = 'A' AND IdMasterTableParent IS NOT NULL",
            "SELECT 'Registros Inactivos' as metric, CAST(COUNT(*) AS CHAR) as value FROM master_table WHERE Status = 'I' AND IdMasterTableParent IS NOT NULL",
            "SELECT 'Total Categorías' as metric, CAST(COUNT(DISTINCT Category) AS CHAR) as value FROM master_table"
        };

        for (String q : queries) {
            try (PreparedStatement stmt = connection.prepareStatement(q);
                 ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    stats.add(new String[]{rs.getString("metric"), rs.getString("value")});
                }
            }
        }

        return stats;
    }

    // ============================================================
    // LISTAR TODOS (CON FILTROS OPCIONALES)
    // ============================================================
    public List<MasterTable> listarTodos(String statusFilter, String categoryFilter) throws SQLException {
        List<MasterTable> lista = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
            "SELECT mt.*, parent.Name as ParentName " +
            "FROM master_table mt " +
            "LEFT JOIN master_table parent ON mt.IdMasterTableParent = parent.IdMasterTable " +
            "WHERE (mt.eliminado = 0 OR mt.eliminado IS NULL) "
        );

        if (statusFilter != null && !statusFilter.isEmpty()) {
            sql.append(" AND mt.Status = ?");
        }
        if (categoryFilter != null && !categoryFilter.isEmpty()) {
            sql.append(" AND mt.Category = ?");
        }

        sql.append(" ORDER BY mt.Category, mt.OrderIndex, mt.Name");

        try (PreparedStatement stmt = connection.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (statusFilter != null && !statusFilter.isEmpty()) {
                stmt.setString(paramIndex++, statusFilter);
            }
            if (categoryFilter != null && !categoryFilter.isEmpty()) {
                stmt.setString(paramIndex++, categoryFilter);
            }
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    lista.add(mapearResultSet(rs));
                }
            }
        }
        return lista;
    }

    // ============================================================
    // MÉTODO HELPER: MAPEAR ResultSet a MasterTable
    // ============================================================
    private MasterTable mapearResultSet(ResultSet rs) throws SQLException {
        MasterTable mt = new MasterTable();
        mt.setIdMasterTable(rs.getInt("IdMasterTable"));
        mt.setIdMasterTableParent(rs.getObject("IdMasterTableParent", Integer.class));
        mt.setCategory(rs.getString("Category"));
        mt.setValue(rs.getString("Value"));
        mt.setDescription(rs.getString("Description"));
        mt.setName(rs.getString("Name"));
        mt.setOrderIndex(rs.getInt("OrderIndex"));
        mt.setAdditionalOne(rs.getString("AdditionalOne"));
        mt.setAdditionalTwo(rs.getString("AdditionalTwo"));
        mt.setAdditionalThree(rs.getString("AdditionalThree"));
        mt.setAdditionalFour(rs.getString("AdditionalFour"));
        mt.setDatabaseWebId(rs.getString("DatabaseWebId"));
        mt.setHostId(rs.getString("HostId"));
        mt.setStatus(rs.getString("Status"));
        mt.setCreatedAt(rs.getTimestamp("CreatedAt"));
        mt.setUpdatedAt(rs.getTimestamp("UpdatedAt"));
        try {
            mt.setParentCategoryName(rs.getString("ParentName"));
        } catch (SQLException e) { /* columna no siempre existe */ }
        return mt;
    }

    // ============================================================
    // CLASE INTERNA: CatalogoItem (de tu amiga)
    // ============================================================
    public static class CatalogoItem {
        private int id;
        private String category;
        private String value;
        private String name;
        private String description;
        private int orderIndex;
        private String additionalOne;
        private String additionalTwo;
        private String additionalThree;
        private String additionalFour;

        public int getId() { return id; }
        public void setId(int id) { this.id = id; }

        public String getCategory() { return category; }
        public void setCategory(String category) { this.category = category; }

        public String getValue() { return value; }
        public void setValue(String value) { this.value = value; }

        public String getName() { return name; }
        public void setName(String name) { this.name = name; }

        public String getDescription() { return description; }
        public void setDescription(String description) { this.description = description; }

        public int getOrderIndex() { return orderIndex; }
        public void setOrderIndex(int orderIndex) { this.orderIndex = orderIndex; }

        public String getAdditionalOne() { return additionalOne; }
        public void setAdditionalOne(String additionalOne) { this.additionalOne = additionalOne; }

        public String getAdditionalTwo() { return additionalTwo; }
        public void setAdditionalTwo(String additionalTwo) { this.additionalTwo = additionalTwo; }

        public String getAdditionalThree() { return additionalThree; }
        public void setAdditionalThree(String additionalThree) { this.additionalThree = additionalThree; }

        public String getAdditionalFour() { return additionalFour; }
        public void setAdditionalFour(String additionalFour) { this.additionalFour = additionalFour; }

        @Override
        public String toString() {
            return "CatalogoItem{value='" + value + "', name='" + name + "'}";
        }
    }
}