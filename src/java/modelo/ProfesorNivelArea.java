/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelo;

/**
 *
 * @author milagros
 */

import java.util.Date;

/**
 * Clase que representa una asignación de nivel-área para un profesor
 * Permite que un profesor pueda dictar en múltiples niveles y áreas
 */
public class ProfesorNivelArea {
    
    private int id;
    private int profesorId;
    private String nivel;              // INICIAL, PRIMARIA, SECUNDARIA
    private int areaId;
    private String areaNombre;         // Para mostrar en la interfaz
    private boolean esPrincipal;       // Si es el área principal del profesor
    private Date fechaAsignacion;
    private boolean activo;
    private boolean eliminado;
    private Date fechaRegistro;
    private Date fechaActualizacion;
    
    // Constructores
    public ProfesorNivelArea() {
        this.activo = true;
        this.eliminado = false;
        this.esPrincipal = false;
    }
    
    public ProfesorNivelArea(int profesorId, String nivel, int areaId) {
        this();
        this.profesorId = profesorId;
        this.nivel = nivel;
        this.areaId = areaId;
    }
    
    public ProfesorNivelArea(int profesorId, String nivel, int areaId, boolean esPrincipal) {
        this(profesorId, nivel, areaId);
        this.esPrincipal = esPrincipal;
    }
    
    // Getters y Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getProfesorId() {
        return profesorId;
    }

    public void setProfesorId(int profesorId) {
        this.profesorId = profesorId;
    }

    public String getNivel() {
        return nivel;
    }

    public void setNivel(String nivel) {
        this.nivel = nivel;
    }

    public int getAreaId() {
        return areaId;
    }

    public void setAreaId(int areaId) {
        this.areaId = areaId;
    }

    public String getAreaNombre() {
        return areaNombre;
    }

    public void setAreaNombre(String areaNombre) {
        this.areaNombre = areaNombre;
    }

    public boolean isEsPrincipal() {
        return esPrincipal;
    }

    public void setEsPrincipal(boolean esPrincipal) {
        this.esPrincipal = esPrincipal;
    }

    public Date getFechaAsignacion() {
        return fechaAsignacion;
    }

    public void setFechaAsignacion(Date fechaAsignacion) {
        this.fechaAsignacion = fechaAsignacion;
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

    public Date getFechaRegistro() {
        return fechaRegistro;
    }

    public void setFechaRegistro(Date fechaRegistro) {
        this.fechaRegistro = fechaRegistro;
    }

    public Date getFechaActualizacion() {
        return fechaActualizacion;
    }

    public void setFechaActualizacion(Date fechaActualizacion) {
        this.fechaActualizacion = fechaActualizacion;
    }
    
    // Método toString para debugging
    @Override
    public String toString() {
        return "ProfesorNivelArea{" +
                "id=" + id +
                ", profesorId=" + profesorId +
                ", nivel='" + nivel + '\'' +
                ", areaId=" + areaId +
                ", areaNombre='" + areaNombre + '\'' +
                ", esPrincipal=" + esPrincipal +
                '}';
    }
    
    // Método equals para comparación
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        
        ProfesorNivelArea that = (ProfesorNivelArea) o;
        
        if (profesorId != that.profesorId) return false;
        if (areaId != that.areaId) return false;
        return nivel != null ? nivel.equals(that.nivel) : that.nivel == null;
    }
    
    @Override
    public int hashCode() {
        int result = profesorId;
        result = 31 * result + (nivel != null ? nivel.hashCode() : 0);
        result = 31 * result + areaId;
        return result;
    }
}