/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelo;

/**
 * Clase que representa un Aula en el sistema de gestión escolar
 * Mapea la tabla 'aula' de la base de datos
 */
public class Aula {
    // Campos que corresponden a las columnas de la tabla 'aula'
    private int id;
    private String nombre;
    private int capacidad;
    private int sedeId;
    private boolean activo;
    
    // Campos adicionales para mostrar información relacionada en vistas
    private String sedeNombre;
    private String sedeDireccion;
    private String sedeTelefono;
    
    // Constructores
    public Aula() {
        this.activo = true; // Por defecto activo
    }
    
    public Aula(int id, String nombre, int capacidad, int sedeId, boolean activo) {
        this.id = id;
        this.nombre = nombre;
        this.capacidad = capacidad;
        this.sedeId = sedeId;
        this.activo = activo;
    }
    
    // Getters y Setters
    public int getId() { 
        return id; 
    }
    
    public void setId(int id) { 
        this.id = id; 
    }
    
    public String getNombre() { 
        return nombre; 
    }
    
    public void setNombre(String nombre) { 
        this.nombre = nombre; 
    }
    
    public int getCapacidad() { 
        return capacidad; 
    }
    
    public void setCapacidad(int capacidad) { 
        this.capacidad = capacidad; 
    }
    
    public int getSedeId() { 
        return sedeId; 
    }
    
    public void setSedeId(int sedeId) { 
        this.sedeId = sedeId; 
    }
    
    public boolean isActivo() { 
        return activo; 
    }
    
    public void setActivo(boolean activo) { 
        this.activo = activo; 
    }
    
    public String getSedeNombre() { 
        return sedeNombre; 
    }
    
    public void setSedeNombre(String sedeNombre) { 
        this.sedeNombre = sedeNombre; 
    }
    
    public String getSedeDireccion() { 
        return sedeDireccion; 
    }
    
    public void setSedeDireccion(String sedeDireccion) { 
        this.sedeDireccion = sedeDireccion; 
    }
    
    public String getSedeTelefono() { 
        return sedeTelefono; 
    }
    
    public void setSedeTelefono(String sedeTelefono) { 
        this.sedeTelefono = sedeTelefono; 
    }
    
    // Métodos de utilidad
    @Override
    public String toString() {
        return String.format("Aula[id=%d, nombre='%s', capacidad=%d, sede='%s', activo=%b]",
                id, nombre, capacidad, sedeNombre != null ? sedeNombre : "N/A", activo);
    }
    
    /**
     * Método para obtener el nombre completo del aula con la sede
     * @return Nombre formateado: "A-101 (Sede Principal)"
     */
    public String getNombreCompleto() {
        if (sedeNombre != null && !sedeNombre.isEmpty()) {
            return nombre + " (" + sedeNombre + ")";
        }
        return nombre;
    }
    
    /**
     * Verifica si el aula está disponible según su estado
     * @return true si está activa, false en caso contrario
     */
    public boolean estaDisponible() {
        return activo;
    }
    
    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null || getClass() != obj.getClass()) return false;
        Aula aula = (Aula) obj;
        return id == aula.id;
    }
    
    @Override
    public int hashCode() {
        return Integer.hashCode(id);
    }
}