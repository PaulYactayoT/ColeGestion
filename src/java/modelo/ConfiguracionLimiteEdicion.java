package modelo;

import java.time.LocalTime;
import java.time.DayOfWeek;

/**
 * Clase modelo para Configuración de Límites de Edición de Asistencia
 */
public class ConfiguracionLimiteEdicion {
    
    private int id;
    private int cursoId;
    private int turnoId;
    private DayOfWeek diaSemana;
    private LocalTime horaInicioClase;
    private int limiteEdicionMinutos;
    private boolean aplicaTodosCursos;
    private String descripcion;
    private boolean activo;
    
    // Campos adicionales para mostrar información
    private String cursoNombre;
    private String turnoNombre;
    
    // Constructores
    public ConfiguracionLimiteEdicion() {
        this.activo = true;
        this.aplicaTodosCursos = false;
    }
    
    public ConfiguracionLimiteEdicion(int turnoId, DayOfWeek diaSemana, LocalTime horaInicioClase, 
                                     int limiteEdicionMinutos) {
        this();
        this.turnoId = turnoId;
        this.diaSemana = diaSemana;
        this.horaInicioClase = horaInicioClase;
        this.limiteEdicionMinutos = limiteEdicionMinutos;
        this.aplicaTodosCursos = true;
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
    
    public DayOfWeek getDiaSemana() {
        return diaSemana;
    }
    
    public void setDiaSemana(DayOfWeek diaSemana) {
        this.diaSemana = diaSemana;
    }
    
    // Método para setear día desde String
    public void setDiaSemanaFromString(String diaSemanaStr) {
        if (diaSemanaStr != null && !diaSemanaStr.isEmpty()) {
            this.diaSemana = DayOfWeek.valueOf(diaSemanaStr.toUpperCase());
        }
    }
    
    // Método para obtener día como String
    public String getDiaSemanaString() {
        return diaSemana != null ? diaSemana.name() : "";
    }
    
    // Método para obtener día en español
    public String getDiaSemanaEspanol() {
        if (diaSemana == null) return "";
        
        switch (diaSemana) {
            case MONDAY: return "Lunes";
            case TUESDAY: return "Martes";
            case WEDNESDAY: return "Miércoles";
            case THURSDAY: return "Jueves";
            case FRIDAY: return "Viernes";
            case SATURDAY: return "Sábado";
            case SUNDAY: return "Domingo";
            default: return "";
        }
    }
    
    public LocalTime getHoraInicioClase() {
        return horaInicioClase;
    }
    
    public void setHoraInicioClase(LocalTime horaInicioClase) {
        this.horaInicioClase = horaInicioClase;
    }
    
    public int getLimiteEdicionMinutos() {
        return limiteEdicionMinutos;
    }
    
    public void setLimiteEdicionMinutos(int limiteEdicionMinutos) {
        this.limiteEdicionMinutos = limiteEdicionMinutos;
    }
    
    // Método para obtener el límite en formato legible
    public String getLimiteEdicionFormateado() {
        if (limiteEdicionMinutos < 60) {
            return limiteEdicionMinutos + " minutos";
        } else {
            int horas = limiteEdicionMinutos / 60;
            int minutos = limiteEdicionMinutos % 60;
            if (minutos == 0) {
                return horas + (horas == 1 ? " hora" : " horas");
            } else {
                return horas + (horas == 1 ? " hora " : " horas ") + 
                       minutos + " minutos";
            }
        }
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
    
    @Override
    public String toString() {
        return String.format(
            "ConfiguracionLimiteEdicion{id=%d, curso='%s', turno='%s', dia=%s, hora=%s, limite=%d min, todos=%b}",
            id,
            cursoNombre != null ? cursoNombre : "N/A",
            turnoNombre != null ? turnoNombre : "N/A",
            getDiaSemanaEspanol(),
            horaInicioClase != null ? horaInicioClase.toString() : "N/A",
            limiteEdicionMinutos,
            aplicaTodosCursos
        );
    }
}
