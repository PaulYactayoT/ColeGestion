package modelo;

import java.sql.Time;
import java.util.Date; // <--- [NUEVO] Agregado para la fecha de registro

public class Disponibilidad {
    // ==========================================
    // CÓDIGO ORIGINAL (NO SE HA TOCADO NADA)
    // ==========================================
    private int id;
    private int profesorId;
    private int turnoId;
    private String turnoNombre;
    private String diaSemana;
    private Time horaInicio;
    private Time horaFin;
    private boolean disponible;
    private String observaciones;

    // Se mantiene tu constructor vacío original
    public Disponibilidad() {
    }

    // Se mantiene tu constructor con parámetros original
    public Disponibilidad(int profesorId, int turnoId, String diaSemana, Time horaInicio, Time horaFin, boolean disponible) {
        this.profesorId = profesorId;
        this.turnoId = turnoId;
        this.diaSemana = diaSemana;
        this.horaInicio = horaInicio;
        this.horaFin = horaFin;
        this.disponible = disponible;
    }

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

    public int getTurnoId() {
        return turnoId;
    }

    public void setTurnoId(int turnoId) {
        this.turnoId = turnoId;
    }

    public String getTurnoNombre() {
        return turnoNombre;
    }

    public void setTurnoNombre(String turnoNombre) {
        this.turnoNombre = turnoNombre;
    }

    public String getDiaSemana() {
        return diaSemana;
    }

    public void setDiaSemana(String diaSemana) {
        this.diaSemana = diaSemana;
    }

    public Time getHoraInicio() {
        return horaInicio;
    }

    public void setHoraInicio(Time horaInicio) {
        this.horaInicio = horaInicio;
    }

    public Time getHoraFin() {
        return horaFin;
    }

    public void setHoraFin(Time horaFin) {
        this.horaFin = horaFin;
    }

    public boolean isDisponible() {
        return disponible;
    }

    public void setDisponible(boolean disponible) {
        this.disponible = disponible;
    }

    public String getObservaciones() {
        return observaciones;
    }

    public void setObservaciones(String observaciones) {
        this.observaciones = observaciones;
    }
    
    // Método auxiliar para mostrar rango
    public String getRangoHorasFormateado() {
        if (horaInicio != null && horaFin != null) {
            return horaInicio.toString().substring(0, 5) + " - " + horaFin.toString().substring(0, 5);
        }
        return "No especificado";
    }
    
    // Método para representación en string
    public String getResumen() {
        return diaSemana + " - " + turnoNombre + " (" + getRangoHorasFormateado() + ") - " + (disponible ? "DISPONIBLE" : "NO DISPONIBLE");
    }

    @Override
    public String toString() {
        return "Disponibilidad{" + "id=" + id + ", profesorId=" + profesorId + ", diaSemana=" + diaSemana + '}';
    }

    // ==========================================
    // AGREGADOS PARA HU-10 (AL FINAL DEL ARCHIVO)
    // ==========================================
    
    // 1. Campo Estado (PENDIENTE, APROBADO, RECHAZADO)
    private String estado; 
    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    // 2. Campo Activo (Para borrado lógico si lo usas)
    private boolean activo;
    public boolean isActivo() { return activo; }
    public void setActivo(boolean activo) { this.activo = activo; }

    // 3. Campo Fecha Registro (Auditoría)
    private Date fechaRegistro;
    public Date getFechaRegistro() { return fechaRegistro; }
    public void setFechaRegistro(Date fechaRegistro) { this.fechaRegistro = fechaRegistro; }
}