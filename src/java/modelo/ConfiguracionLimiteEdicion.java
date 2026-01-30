package modelo;

import java.time.LocalTime;
import java.time.format.DateTimeFormatter;

/**
 * Clase para configurar límites de edición de asistencia por turno
 * Define cuánto tiempo después de iniciar la clase se puede editar la asistencia
 */
public class ConfiguracionLimiteEdicion {
    
    public enum DiaSemana {
        LUNES, MARTES, MIERCOLES, JUEVES, VIERNES, SABADO, DOMINGO;
        
        public static DiaSemana fromString(String text) {
            for (DiaSemana dia : DiaSemana.values()) {
                if (dia.name().equalsIgnoreCase(text)) {
                    return dia;
                }
            }
            return LUNES;
        }
    }
    
    private int id;
    private int cursoId;
    private int turnoId;
    private DiaSemana diaSemana;
    private LocalTime horaInicioClase;
    private int limiteEdicionMinutos; // Minutos después del inicio para editar
    private boolean aplicaTodosCursos;
    private String descripcion;
    private boolean activo;
    
    // Campos adicionales
    private String cursoNombre;
    private String turnoNombre;
    
    // Constructores
    public ConfiguracionLimiteEdicion() {
        this.activo = true;
        this.limiteEdicionMinutos = 120; // 2 horas por defecto
        this.aplicaTodosCursos = false;
    }
    
    public ConfiguracionLimiteEdicion(int cursoId, int turnoId, DiaSemana dia, 
                                     LocalTime horaInicio, int limiteMinutos) {
        this();
        this.cursoId = cursoId;
        this.turnoId = turnoId;
        this.diaSemana = dia;
        this.horaInicioClase = horaInicio;
        this.limiteEdicionMinutos = limiteMinutos;
    }
    
    // Getters y Setters
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public int getCursoId() {
        return cursoId;
    }
    
    public void setCursoId(int cursoId) {
        this.cursoId = cursoId;
    }
    
    public int getTurnoId() {
        return turnoId;
    }
    
    public void setTurnoId(int turnoId) {
        this.turnoId = turnoId;
    }
    
    public DiaSemana getDiaSemana() {
        return diaSemana;
    }
    
    public void setDiaSemana(DiaSemana diaSemana) {
        this.diaSemana = diaSemana;
    }
    
    public void setDiaSemanaFromString(String dia) {
        this.diaSemana = DiaSemana.fromString(dia);
    }
    
    public String getDiaSemanaString() {
        return diaSemana != null ? diaSemana.name() : "";
    }
    
    public LocalTime getHoraInicioClase() {
        return horaInicioClase;
    }
    
    public void setHoraInicioClase(LocalTime horaInicioClase) {
        this.horaInicioClase = horaInicioClase;
    }
    
    public String getHoraInicioClaseFormateada() {
        return horaInicioClase != null ? 
               horaInicioClase.format(DateTimeFormatter.ofPattern("HH:mm")) : "";
    }
    
    public int getLimiteEdicionMinutos() {
        return limiteEdicionMinutos;
    }
    
    public void setLimiteEdicionMinutos(int limiteEdicionMinutos) {
        this.limiteEdicionMinutos = limiteEdicionMinutos;
    }
    
    public boolean isAplicaTodosCursos() {
        return aplicaTodosCursos;
    }
    
    public void setAplicaTodosCursos(boolean aplicaTodosCursos) {
        this.aplicaTodosCursos = aplicaTodosCursos;
    }
    
    public String getDescripcion() {
        return descripcion;
    }
    
    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }
    
    public boolean isActivo() {
        return activo;
    }
    
    public void setActivo(boolean activo) {
        this.activo = activo;
    }
    
    public String getCursoNombre() {
        return cursoNombre;
    }
    
    public void setCursoNombre(String cursoNombre) {
        this.cursoNombre = cursoNombre;
    }
    
    public String getTurnoNombre() {
        return turnoNombre;
    }
    
    public void setTurnoNombre(String turnoNombre) {
        this.turnoNombre = turnoNombre;
    }
    
    // Métodos de utilidad
    
    /**
     * Calcula la hora límite para editar
     */
    public LocalTime getHoraLimiteEdicion() {
        if (horaInicioClase == null) return null;
        return horaInicioClase.plusMinutes(limiteEdicionMinutos);
    }
    
    /**
     * Obtiene descripción del límite en formato legible
     */
    public String getDescripcionLimite() {
        int horas = limiteEdicionMinutos / 60;
        int minutos = limiteEdicionMinutos % 60;
        
        if (horas > 0 && minutos > 0) {
            return horas + " hora" + (horas > 1 ? "s" : "") + " y " + 
                   minutos + " minuto" + (minutos > 1 ? "s" : "");
        } else if (horas > 0) {
            return horas + " hora" + (horas > 1 ? "s" : "");
        } else {
            return minutos + " minuto" + (minutos > 1 ? "s" : "");
        }
    }
    
    @Override
    public String toString() {
        return String.format(
            "ConfiguracionLimite{id=%d, curso=%s, turno=%s, dia=%s, hora=%s, limite=%d min}",
            id, cursoNombre, turnoNombre, diaSemana, getHoraInicioClaseFormateada(), limiteEdicionMinutos
        );
    }
}