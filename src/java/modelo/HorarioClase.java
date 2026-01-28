/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelo;

/**
 * Clase modelo que representa un horario de clase en el sistema.
 * Corresponde a la tabla 'horario_clase' de la base de datos.
 * 
 * @author Tu Nombre
 */
public class HorarioClase {
    // Campos principales de la tabla horario_clase
    private int id;
    private int cursoId;
    private int turnoId;
    private String diaSemana; // ENUM: LUNES, MARTES, MIERCOLES, JUEVES, VIERNES, SABADO
    private String horaInicio; // TIME format: HH:mm:ss
    private String horaFin;    // TIME format: HH:mm:ss
    private int aulaId;
    private boolean activo;
    
    // Campos adicionales para mostrar información relacionada en vistas
    // Estos campos se llenan con JOINs en las consultas SQL
    private String cursoNombre;
    private String turnoNombre;
    private String aulaNombre;
    private String sedeNombre;
    private String gradoNombre;
    
    // Constructores
    
    /**
     * Constructor vacío
     */
    public HorarioClase() {
    }
    
    /**
     * Constructor con parámetros principales
     */
    public HorarioClase(int cursoId, int turnoId, String diaSemana, 
                        String horaInicio, String horaFin, int aulaId) {
        this.cursoId = cursoId;
        this.turnoId = turnoId;
        this.diaSemana = diaSemana;
        this.horaInicio = horaInicio;
        this.horaFin = horaFin;
        this.aulaId = aulaId;
        this.activo = true; // Por defecto activo
    }
    
    /**
     * Constructor completo
     */
    public HorarioClase(int id, int cursoId, int turnoId, String diaSemana,
                        String horaInicio, String horaFin, int aulaId, boolean activo) {
        this.id = id;
        this.cursoId = cursoId;
        this.turnoId = turnoId;
        this.diaSemana = diaSemana;
        this.horaInicio = horaInicio;
        this.horaFin = horaFin;
        this.aulaId = aulaId;
        this.activo = activo;
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
    
    public String getDiaSemana() { 
        return diaSemana; 
    }
    
    public void setDiaSemana(String diaSemana) { 
        this.diaSemana = diaSemana; 
    }
    
    public String getHoraInicio() { 
        return horaInicio; 
    }
    
    public void setHoraInicio(String horaInicio) { 
        this.horaInicio = horaInicio; 
    }
    
    public String getHoraFin() { 
        return horaFin; 
    }
    
    public void setHoraFin(String horaFin) { 
        this.horaFin = horaFin; 
    }
    
    public int getAulaId() { 
        return aulaId; 
    }
    
    public void setAulaId(int aulaId) { 
        this.aulaId = aulaId; 
    }
    
    public boolean isActivo() { 
        return activo; 
    }
    
    public void setActivo(boolean activo) { 
        this.activo = activo; 
    }
    
    // Getters y Setters de campos adicionales
    
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
    
    public String getAulaNombre() { 
        return aulaNombre; 
    }
    
    public void setAulaNombre(String aulaNombre) { 
        this.aulaNombre = aulaNombre; 
    }
    
    public String getSedeNombre() { 
        return sedeNombre; 
    }
    
    public void setSedeNombre(String sedeNombre) { 
        this.sedeNombre = sedeNombre; 
    }
    
    public String getGradoNombre() { 
        return gradoNombre; 
    }
    
    public void setGradoNombre(String gradoNombre) { 
        this.gradoNombre = gradoNombre; 
    }
    
    // Métodos auxiliares
    
    /**
     * Retorna una representación en String del horario
     */
    @Override
    public String toString() {
        return "HorarioClase{" +
                "id=" + id +
                ", cursoNombre='" + cursoNombre + '\'' +
                ", diaSemana='" + diaSemana + '\'' +
                ", horaInicio='" + horaInicio + '\'' +
                ", horaFin='" + horaFin + '\'' +
                ", aulaNombre='" + aulaNombre + '\'' +
                ", turnoNombre='" + turnoNombre + '\'' +
                '}';
    }
    
    /**
     * Retorna el rango horario formateado
     */
    public String getRangoHorario() {
        if (horaInicio != null && horaFin != null) {
            return horaInicio.substring(0, 5) + " - " + horaFin.substring(0, 5);
        }
        return "";
    }
    
    /**
     * Retorna información completa del horario para mostrar
     */
    public String getInformacionCompleta() {
        StringBuilder info = new StringBuilder();
        if (cursoNombre != null) info.append(cursoNombre).append(" - ");
        if (gradoNombre != null) info.append(gradoNombre).append(" - ");
        if (diaSemana != null) info.append(diaSemana).append(" ");
        info.append(getRangoHorario());
        if (aulaNombre != null) info.append(" - ").append(aulaNombre);
        return info.toString();
    }
    
    /**
     * Valida si el horario es válido
     */
    public boolean isValido() {
        return cursoId > 0 && 
               turnoId > 0 && 
               aulaId > 0 && 
               diaSemana != null && !diaSemana.isEmpty() &&
               horaInicio != null && !horaInicio.isEmpty() &&
               horaFin != null && !horaFin.isEmpty();
    }
}