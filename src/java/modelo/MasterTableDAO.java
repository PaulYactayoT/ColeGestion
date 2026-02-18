/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelo;

import conexion.Conexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * MasterTableDAO - Gestiona catálogos desde master_table
 * Adaptado a la estructura real: IdMasterTable, Category, Value, Name, Description, OrderIndex, Status
 * 
 * @author Ocelot
 */
public class MasterTableDAO {

    /**
     * Obtiene lista de valores de un catálogo específico
     * @param category Nombre de la categoría (ej: "SEXO", "TIPO_DOCUMENTO")
     * @return Lista de opciones del catálogo
     */
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
    
    /**
     * Obtiene un item específico por Value
     */
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
    
    /**
     * Verifica si existe un Value en una categoría
     */
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
    
    /**
     * Clase interna para representar items del catálogo
     */
    public static class CatalogoItem {
        private int id;
        private String category;
        private String value;        // Código corto: M, F, DNI, etc.
        private String name;         // Nombre para mostrar
        private String description;
        private int orderIndex;
        private String additionalOne;
        private String additionalTwo;
        private String additionalThree;
        private String additionalFour;
        
        // Getters y Setters
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
