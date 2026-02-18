/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelo;

import java.time.LocalDateTime;

/**
 * Clase modelo para la entidad Modulo
 * HU-16: Asignación de módulos por rol
 */
public class Modulo {

    private int id;
    private String nombre;
    private String descripcion;
    private String icono;
    private String url;
    private int orden;
    private String rolAplicable;
    private boolean activo;
    private boolean eliminado;
    private transient LocalDateTime fechaRegistro;


    // Campos de asignación (usados al listar para asignar)
    private boolean asignado;
    private boolean puedeVer;
    private boolean puedeCrear;
    private boolean puedeEditar;
    private boolean puedeEliminar;

    // ======================== Constructores ========================
    public Modulo() {}

    public Modulo(int id, String nombre, String descripcion, String icono,
                  String url, int orden, String rolAplicable) {
        this.id           = id;
        this.nombre       = nombre;
        this.descripcion  = descripcion;
        this.icono        = icono;
        this.url          = url;
        this.orden        = orden;
        this.rolAplicable = rolAplicable;
        this.activo       = true;
        this.eliminado    = false;
    }

    // ======================== Getters & Setters ========================
    public int getId()                              { return id; }
    public void setId(int id)                       { this.id = id; }

    public String getNombre()                       { return nombre; }
    public void setNombre(String nombre)            { this.nombre = nombre; }

    public String getDescripcion()                  { return descripcion; }
    public void setDescripcion(String descripcion)  { this.descripcion = descripcion; }

    public String getIcono()                        { return icono; }
    public void setIcono(String icono)              { this.icono = icono; }

    public String getUrl()                          { return url; }
    public void setUrl(String url)                  { this.url = url; }

    public int getOrden()                           { return orden; }
    public void setOrden(int orden)                 { this.orden = orden; }

    public String getRolAplicable()                 { return rolAplicable; }
    public void setRolAplicable(String rolAplicable){ this.rolAplicable = rolAplicable; }

    public boolean isActivo()                       { return activo; }
    public void setActivo(boolean activo)           { this.activo = activo; }

    public boolean isEliminado()                    { return eliminado; }
    public void setEliminado(boolean eliminado)     { this.eliminado = eliminado; }

    public LocalDateTime getFechaRegistro()                 { return fechaRegistro; }
    public void setFechaRegistro(LocalDateTime fechaRegistro) { this.fechaRegistro = fechaRegistro; }

    public boolean isAsignado()                             { return asignado; }
    public void setAsignado(boolean asignado)               { this.asignado = asignado; }

    public boolean isPuedeVer()                             { return puedeVer; }
    public void setPuedeVer(boolean puedeVer)               { this.puedeVer = puedeVer; }

    public boolean isPuedeCrear()                           { return puedeCrear; }
    public void setPuedeCrear(boolean puedeCrear)           { this.puedeCrear = puedeCrear; }

    public boolean isPuedeEditar()                          { return puedeEditar; }
    public void setPuedeEditar(boolean puedeEditar)         { this.puedeEditar = puedeEditar; }

    public boolean isPuedeEliminar()                        { return puedeEliminar; }
    public void setPuedeEliminar(boolean puedeEliminar)     { this.puedeEliminar = puedeEliminar; }

    @Override
    public String toString() {
        return "Modulo{id=" + id + ", nombre='" + nombre + "', rol='" + rolAplicable + "'}";
    }
}