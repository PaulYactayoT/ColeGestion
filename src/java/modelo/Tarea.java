/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelo;

public class Tarea {
    private int id;
    private String nombre;
    private String descripcion;
    private boolean activo;
    private String fechaEntrega;
    private int cursoId;
    private String cursoNombre;

    // Getters y Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public boolean isActivo() { return activo; }
    public void setActivo(boolean activo) { this.activo = activo; }

    public String getFechaEntrega() { return fechaEntrega; }
    public void setFechaEntrega(String fechaEntrega) { this.fechaEntrega = fechaEntrega; }

    public int getCursoId() { return cursoId; }
    public void setCursoId(int cursoId) { this.cursoId = cursoId; }
    
    public String getCursoNombre() { return cursoNombre; }

    public void setCursoNombre(String cursoNombre) { this.cursoNombre = cursoNombre; }
}

