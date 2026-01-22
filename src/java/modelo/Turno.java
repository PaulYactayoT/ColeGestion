/*
 * MODELO DE TURNO ACADÉMICO
 * Representa los turnos escolares (Mañana, Tarde)
 */
package modelo;

import java.time.LocalTime;
import java.time.LocalDateTime;

public class Turno {
    private int id;
    private String nombre;
    private LocalTime horaInicio;
    private LocalTime horaFin;
    private String descripcion;
    private LocalDateTime fechaRegistro;
    private boolean activo;
    private boolean eliminado;

    // Constructores
    public Turno() {
    }

    public Turno(int id, String nombre, LocalTime horaInicio, LocalTime horaFin) {
        this.id = id;
        this.nombre = nombre;
        this.horaInicio = horaInicio;
        this.horaFin = horaFin;
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

    public LocalTime getHoraInicio() {
        return horaInicio;
    }

    public void setHoraInicio(LocalTime horaInicio) {
        this.horaInicio = horaInicio;
    }

    public LocalTime getHoraFin() {
        return horaFin;
    }

    public void setHoraFin(LocalTime horaFin) {
        this.horaFin = horaFin;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
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
    public String getHoraInicioFormateada() {
        return horaInicio != null ? horaInicio.toString() : "";
    }

    public String getHoraFinFormateada() {
        return horaFin != null ? horaFin.toString() : "";
    }

    public String getRangoHorario() {
        return getHoraInicioFormateada() + " - " + getHoraFinFormateada();
    }

    @Override
    public String toString() {
        return nombre + " (" + getRangoHorario() + ")";
    }
}