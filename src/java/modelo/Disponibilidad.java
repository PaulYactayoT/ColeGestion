/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelo;

import java.sql.Time;

/**
 * ========================================
 * CLASE DISPONIBILIDAD
 * ========================================
 * Representa los horarios en los que un profesor está disponible para dictar clases.
 * Cada registro de disponibilidad contiene:
 * - El día de la semana (Lunes, Martes, etc.)
 * - El turno (Mañana, Tarde, etc.)
 * - El rango de horas (hora inicio - hora fin)
 * - Si está disponible o no
 * 
 * Esta información se almacena en la tabla 'disponibilidad_profesor' de la base de datos
 * y se relaciona con el profesor mediante profesor_id.
 * ========================================
 */
public class Disponibilidad {
    
    // ===== PROPIEDADES =====
    
    private int id;                  
    private int profesorId;            // ID del profesor al que pertenece esta disponibilidad
    private int turnoId;               // ID del turno (relacionado con tabla turno)
    private String turnoNombre;        // Nombre del turno (Mañana, Tarde, etc.) - para mostrar en la UI
    private String diaSemana;          // Día de la semana (LUNES, MARTES, MIERCOLES, JUEVES, VIERNES, SABADO)
    private Time horaInicio;           // Hora de inicio de la disponibilidad
    private Time horaFin;              // Hora de fin de la disponibilidad
    private boolean disponible;        // Si el profesor está disponible en este horario (true/false)
    private String observaciones;      // Comentarios adicionales sobre esta disponibilidad
    
    // ===== CONSTRUCTOR =====
    
    /**
     * Constructor vacío - Inicializa una disponibilidad sin datos
     * Útil cuando se va a cargar información desde la base de datos
     */
    public Disponibilidad() {
        this.disponible = true; // Por defecto, el horario está disponible
    }
    
    /**
     * Constructor con parámetros principales
     * Útil para crear una nueva disponibilidad rápidamente
     * 
     * @param profesorId ID del profesor
     * @param turnoId ID del turno
     * @param diaSemana Día de la semana
     * @param horaInicio Hora de inicio
     * @param horaFin Hora de fin
     * @param disponible Si está disponible o no
     */
    public Disponibilidad(int profesorId, int turnoId, String diaSemana, 
                         Time horaInicio, Time horaFin, boolean disponible) {
        this.profesorId = profesorId;
        this.turnoId = turnoId;
        this.diaSemana = diaSemana;
        this.horaInicio = horaInicio;
        this.horaFin = horaFin;
        this.disponible = disponible;
    }
    
    // ===== GETTERS Y SETTERS =====
    
    /**
     * Obtiene el ID de la disponibilidad
     * @return ID de la disponibilidad
     */
    public int getId() {
        return id;
    }

    /**
     * Establece el ID de la disponibilidad
     * @param id ID a asignar
     */
    public void setId(int id) {
        this.id = id;
    }

    /**
     * Obtiene el ID del profesor asociado
     * @return ID del profesor
     */
    public int getProfesorId() {
        return profesorId;
    }

    /**
     * Establece el ID del profesor asociado
     * @param profesorId ID del profesor
     */
    public void setProfesorId(int profesorId) {
        this.profesorId = profesorId;
    }

    /**
     * Obtiene el ID del turno
     * @return ID del turno
     */
    public int getTurnoId() {
        return turnoId;
    }

    /**
     * Establece el ID del turno
     * @param turnoId ID del turno
     */
    public void setTurnoId(int turnoId) {
        this.turnoId = turnoId;
    }

    /**
     * Obtiene el nombre del turno (para mostrar en la UI)
     * @return Nombre del turno
     */
    public String getTurnoNombre() {
        return turnoNombre;
    }

    /**
     * Establece el nombre del turno
     * @param turnoNombre Nombre del turno
     */
    public void setTurnoNombre(String turnoNombre) {
        this.turnoNombre = turnoNombre;
    }

    /**
     * Obtiene el día de la semana
     * @return Día de la semana (LUNES, MARTES, etc.)
     */
    public String getDiaSemana() {
        return diaSemana;
    }

    /**
     * Establece el día de la semana
     * @param diaSemana Día de la semana
     */
    public void setDiaSemana(String diaSemana) {
        this.diaSemana = diaSemana;
    }

    /**
     * Obtiene la hora de inicio de la disponibilidad
     * @return Hora de inicio (tipo Time de SQL)
     */
    public Time getHoraInicio() {
        return horaInicio;
    }

    /**
     * Establece la hora de inicio de la disponibilidad
     * @param horaInicio Hora de inicio
     */
    public void setHoraInicio(Time horaInicio) {
        this.horaInicio = horaInicio;
    }

    /**
     * Obtiene la hora de fin de la disponibilidad
     * @return Hora de fin (tipo Time de SQL)
     */
    public Time getHoraFin() {
        return horaFin;
    }

    /**
     * Establece la hora de fin de la disponibilidad
     * @param horaFin Hora de fin
     */
    public void setHoraFin(Time horaFin) {
        this.horaFin = horaFin;
    }

    /**
     * Verifica si el profesor está disponible en este horario
     * @return true si está disponible, false si no
     */
    public boolean isDisponible() {
        return disponible;
    }

    /**
     * Establece si el profesor está disponible en este horario
     * @param disponible true para disponible, false para no disponible
     */
    public void setDisponible(boolean disponible) {
        this.disponible = disponible;
    }

    /**
     * Obtiene las observaciones sobre esta disponibilidad
     * @return Texto de observaciones
     */
    public String getObservaciones() {
        return observaciones;
    }

    /**
     * Establece observaciones sobre esta disponibilidad
     * @param observaciones Texto de observaciones
     */
    public void setObservaciones(String observaciones) {
        this.observaciones = observaciones;
    }
    
    // ===== MÉTODOS AUXILIARES =====
    
    /**
     * Formatea el rango de horas en un string legible
     * Ejemplo: "08:00 - 12:00"
     * @return String con el rango de horas formateado
     */
    public String getRangoHorasFormateado() {
        if (horaInicio != null && horaFin != null) {
            return horaInicio.toString().substring(0, 5) + " - " + 
                   horaFin.toString().substring(0, 5);
        }
        return "No especificado";
    }
    
    /**
     * Obtiene un resumen de la disponibilidad para mostrar en la UI
     * Ejemplo: "LUNES - Mañana (08:00 - 12:00) - DISPONIBLE"
     * @return String con el resumen de la disponibilidad
     */
    public String getResumen() {
        StringBuilder sb = new StringBuilder();
        sb.append(diaSemana != null ? diaSemana : "Sin día");
        sb.append(" - ");
        sb.append(turnoNombre != null ? turnoNombre : "Sin turno");
        sb.append(" (").append(getRangoHorasFormateado()).append(")");
        sb.append(" - ");
        sb.append(disponible ? "DISPONIBLE" : "NO DISPONIBLE");
        return sb.toString();
    }
    
    @Override
    public String toString() {
        return "Disponibilidad{" +
                "id=" + id +
                ", profesorId=" + profesorId +
                ", diaSemana='" + diaSemana + '\'' +
                ", turno='" + turnoNombre + '\'' +
                ", horaInicio=" + horaInicio +
                ", horaFin=" + horaFin +
                ", disponible=" + disponible +
                '}';
    }
}
