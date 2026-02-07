package modelo;

import java.sql.Time;
import java.util.Date; 

public class Disponibilidad {
    // ==========================================
    // TUS ATRIBUTOS ORIGINALES
    // ==========================================
    private int id;
    private int profesorId;
    private int turnoId;
    private String turnoNombre;
    private String diaSemana;
    private Time horaInicio;
    private Time horaFin;
    private boolean disponible;
    private String observaciones; // Ya lo tenías, perfecto.

    // --- [LO ÚNICO NUEVO PARA HU-11] ---
    // Necesitamos esto para que en la tabla del Admin salga "Juan Perez"
    private String nombreProfesor; 
    public String getNombreProfesor() { return nombreProfesor; }
    public void setNombreProfesor(String nombreProfesor) { this.nombreProfesor = nombreProfesor; }
    // ------------------------------------

    // TUS CONSTRUCTORES (INTACTOS)
    public Disponibilidad() {
    }

    public Disponibilidad(int profesorId, int turnoId, String diaSemana, Time horaInicio, Time horaFin, boolean disponible) {
        this.profesorId = profesorId;
        this.turnoId = turnoId;
        this.diaSemana = diaSemana;
        this.horaInicio = horaInicio;
        this.horaFin = horaFin;
        this.disponible = disponible;
    }

    // TUS GETTERS Y SETTERS (INTACTOS)
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getProfesorId() { return profesorId; }
    public void setProfesorId(int profesorId) { this.profesorId = profesorId; }

    public int getTurnoId() { return turnoId; }
    public void setTurnoId(int turnoId) { this.turnoId = turnoId; }

    public String getTurnoNombre() { return turnoNombre; }
    public void setTurnoNombre(String turnoNombre) { this.turnoNombre = turnoNombre; }

    public String getDiaSemana() { return diaSemana; }
    public void setDiaSemana(String diaSemana) { this.diaSemana = diaSemana; }

    public Time getHoraInicio() { return horaInicio; }
    public void setHoraInicio(Time horaInicio) { this.horaInicio = horaInicio; }

    public Time getHoraFin() { return horaFin; }
    public void setHoraFin(Time horaFin) { this.horaFin = horaFin; }

    public boolean isDisponible() { return disponible; }
    public void setDisponible(boolean disponible) { this.disponible = disponible; }

    public String getObservaciones() { return observaciones; }
    public void setObservaciones(String observaciones) { this.observaciones = observaciones; }
    
    // TUS MÉTODOS AUXILIARES (QUE NO DEBÍ BORRAR)
    public String getRangoHorasFormateado() {
        if (horaInicio != null && horaFin != null) {
            return horaInicio.toString().substring(0, 5) + " - " + horaFin.toString().substring(0, 5);
        }
        return "No especificado";
    }
    
    public String getResumen() {
        return diaSemana + " - " + turnoNombre + " (" + getRangoHorasFormateado() + ") - " + (disponible ? "DISPONIBLE" : "NO DISPONIBLE");
    }

    @Override
    public String toString() {
        return "Disponibilidad{" + "id=" + id + ", profesorId=" + profesorId + ", diaSemana=" + diaSemana + '}';
    }

    // TUS CAMPOS DE LA HU-10 (INTACTOS)
    private String estado; 
    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    private boolean activo;
    public boolean isActivo() { return activo; }
    public void setActivo(boolean activo) { this.activo = activo; }

    private Date fechaRegistro;
    public Date getFechaRegistro() { return fechaRegistro; }
    public void setFechaRegistro(Date fechaRegistro) { this.fechaRegistro = fechaRegistro; }
}