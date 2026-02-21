package modelo;

import java.sql.Timestamp;

public class MasterTable {
    private int idMasterTable;
    private Integer idMasterTableParent;
    private String category;
    private String value;
    private String description;
    private String name;
    private int orderIndex;
    private String additionalOne;
    private String additionalTwo;
    private String additionalThree;
    private String additionalFour;
    private String databaseWebId;
    private String hostId;
    private String status;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    // Para mostrar el nombre de la categoría padre
    private String parentCategoryName;
    private int totalValues; // Para estadísticas

    // Constructor vacío
    public MasterTable() {
        this.status = "A";
        this.databaseWebId = "ADMIN";
        this.hostId = "20210130";
        this.orderIndex = 0;
    }

    // Constructor completo
    public MasterTable(int idMasterTable, Integer idMasterTableParent, String category, 
                      String value, String description, String name, int orderIndex,
                      String additionalOne, String additionalTwo, String additionalThree, 
                      String additionalFour, String status) {
        this.idMasterTable = idMasterTable;
        this.idMasterTableParent = idMasterTableParent;
        this.category = category;
        this.value = value;
        this.description = description;
        this.name = name;
        this.orderIndex = orderIndex;
        this.additionalOne = additionalOne;
        this.additionalTwo = additionalTwo;
        this.additionalThree = additionalThree;
        this.additionalFour = additionalFour;
        this.status = status;
        this.databaseWebId = "ADMIN";
        this.hostId = "20210130";
    }

    // Getters y Setters
    public int getIdMasterTable() {
        return idMasterTable;
    }

    public void setIdMasterTable(int idMasterTable) {
        this.idMasterTable = idMasterTable;
    }

    public Integer getIdMasterTableParent() {
        return idMasterTableParent;
    }

    public void setIdMasterTableParent(Integer idMasterTableParent) {
        this.idMasterTableParent = idMasterTableParent;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getOrderIndex() {
        return orderIndex;
    }

    public void setOrderIndex(int orderIndex) {
        this.orderIndex = orderIndex;
    }

    public String getAdditionalOne() {
        return additionalOne;
    }

    public void setAdditionalOne(String additionalOne) {
        this.additionalOne = additionalOne;
    }

    public String getAdditionalTwo() {
        return additionalTwo;
    }

    public void setAdditionalTwo(String additionalTwo) {
        this.additionalTwo = additionalTwo;
    }

    public String getAdditionalThree() {
        return additionalThree;
    }

    public void setAdditionalThree(String additionalThree) {
        this.additionalThree = additionalThree;
    }

    public String getAdditionalFour() {
        return additionalFour;
    }

    public void setAdditionalFour(String additionalFour) {
        this.additionalFour = additionalFour;
    }

    public String getDatabaseWebId() {
        return databaseWebId;
    }

    public void setDatabaseWebId(String databaseWebId) {
        this.databaseWebId = databaseWebId;
    }

    public String getHostId() {
        return hostId;
    }

    public void setHostId(String hostId) {
        this.hostId = hostId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getParentCategoryName() {
        return parentCategoryName;
    }

    public void setParentCategoryName(String parentCategoryName) {
        this.parentCategoryName = parentCategoryName;
    }

    public int getTotalValues() {
        return totalValues;
    }

    public void setTotalValues(int totalValues) {
        this.totalValues = totalValues;
    }

    // Método para determinar si es una categoría (padre)
    public boolean isCategory() {
        return this.idMasterTableParent == null;
    }

    // Método para determinar si está activo
    public boolean isActive() {
        return "A".equals(this.status);
    }

    @Override
    public String toString() {
        return "MasterTable{" +
                "idMasterTable=" + idMasterTable +
                ", category='" + category + '\'' +
                ", value='" + value + '\'' +
                ", name='" + name + '\'' +
                ", status='" + status + '\'' +
                '}';
    }
}