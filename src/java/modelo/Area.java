
package modelo;

import java.time.LocalDateTime;

public class Area {
    private int id;
    private String nombre;
    private String descripcion;
    private String nivel; 
    private LocalDateTime fechaRegistro;
    private boolean activo;
    private boolean eliminado;

    // Constructores
    public Area() {
    }

    public Area(int id, String nombre) {
        this.id = id;
        this.nombre = nombre;
        this.activo = true;
        this.eliminado = false;
    }

    public Area(int id, String nombre, String descripcion, String nivel) {
        this.id = id;
        this.nombre = nombre;
        this.descripcion = descripcion;
        this.nivel = nivel;
        this.activo = true;
        this.eliminado = false;
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

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public String getNivel() {
        return nivel;
    }

    public void setNivel(String nivel) {
        this.nivel = nivel;
    }

    public LocalDateTime getFechaRegistro() {
        return fechaRegistro;
    }

    public void setFechaRegistro(LocalDateTime fechaRegistro) {
        this.fechaRegistro = fechaRegistro;
    }

    public boolean isActivo() {
        return activo;
    }

    public void setActivo(boolean activo) {
        this.activo = activo;
    }

    public boolean isEliminado() {
        return eliminado;
    }

    public void setEliminado(boolean eliminado) {
        this.eliminado = eliminado;
    }

    // Métodos útiles
    @Override
    public String toString() {
        return nombre;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null || getClass() != obj.getClass()) return false;
        Area area = (Area) obj;
        return id == area.id;
    }

    @Override
    public int hashCode() {
        return Integer.hashCode(id);
    }
}