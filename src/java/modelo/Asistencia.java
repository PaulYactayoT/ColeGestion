package modelo;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Clase que representa una Asistencia en el sistema de gestión escolar
 * Mapea la tabla 'asistencia' de la base de datos
 */
public class Asistencia {
    // Campos que corresponden a las columnas de la tabla 'asistencia'
    private int id;
    private int alumnoId;
    private int cursoId;
    private int turnoId;
    private LocalDate fecha;
    private LocalTime horaClase;
    private EstadoAsistencia estado; // PRESENTE, TARDANZA, AUSENTE, JUSTIFICADO
    private String observaciones;
    private int registradoPor;
    private LocalDateTime fechaRegistro;
    private LocalDateTime fechaActualizacion;
    private boolean activo;
    
    // Campos adicionales para mostrar información relacionada en vistas
    private String alumnoNombre;
    private String alumnoApellidos;
    private String cursoNombre;
    private String turnoNombre;
    private String profesorNombre;
    private String gradoNombre;
    private String sedeNombre;
    private String aulaNombre;
    
    // Enum para estados de asistencia (mejor práctica que String)
    public enum EstadoAsistencia {
        PRESENTE("Presente"),
        TARDANZA("Tardanza"),
        AUSENTE("Ausente"),
        JUSTIFICADO("Justificado");
        
        private final String descripcion;
        
        EstadoAsistencia(String descripcion) {
            this.descripcion = descripcion;
        }
        
        public String getDescripcion() {
            return descripcion;
        }
        
        public static EstadoAsistencia fromString(String text) {
            for (EstadoAsistencia e : EstadoAsistencia.values()) {
                if (e.name().equalsIgnoreCase(text)) {
                    return e;
                }
            }
            return AUSENTE; // Valor por defecto
        }
    }
    
    // Constructores
    public Asistencia() {
        this.activo = true;
        this.fechaRegistro = LocalDateTime.now();
        this.fechaActualizacion = LocalDateTime.now();
    }
    
    public Asistencia(int alumnoId, int cursoId, int turnoId, LocalDate fecha, 
                      LocalTime horaClase, EstadoAsistencia estado) {
        this();
        this.alumnoId = alumnoId;
        this.cursoId = cursoId;
        this.turnoId = turnoId;
        this.fecha = fecha;
        this.horaClase = horaClase;
        this.estado = estado;
    }
    
    // Constructor con String para compatibilidad (convierte a LocalDate/LocalTime)
    public Asistencia(int alumnoId, int cursoId, int turnoId, String fecha, 
                      String horaClase, String estado) {
        this();
        this.alumnoId = alumnoId;
        this.cursoId = cursoId;
        this.turnoId = turnoId;
        this.fecha = LocalDate.parse(fecha);
        this.horaClase = LocalTime.parse(horaClase);
        this.estado = EstadoAsistencia.fromString(estado);
    }
    
    // Getters y Setters
    public int getId() { 
        return id; 
    }
    
    public void setId(int id) { 
        this.id = id; 
    }
    
    public int getAlumnoId() { 
        return alumnoId; 
    }
    
    public void setAlumnoId(int alumnoId) { 
        this.alumnoId = alumnoId; 
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
    
    public LocalDate getFecha() { 
        return fecha; 
    }
    
    public void setFecha(LocalDate fecha) { 
        this.fecha = fecha;
        this.fechaActualizacion = LocalDateTime.now();
    }
    
    // Método alternativo para setear fecha desde String
    public void setFechaFromString(String fechaStr) {
        this.fecha = LocalDate.parse(fechaStr);
        this.fechaActualizacion = LocalDateTime.now();
    }
    
    // Método para obtener fecha como String formateado
    public String getFechaFormateada() {
        return fecha != null ? fecha.format(DateTimeFormatter.ofPattern("dd/MM/yyyy")) : "";
    }
    
    // Método para obtener fecha en formato SQL (yyyy-MM-dd)
    public String getFechaSQL() {
        return fecha != null ? fecha.toString() : "";
    }
    
    public LocalTime getHoraClase() { 
        return horaClase; 
    }
    
    public void setHoraClase(LocalTime horaClase) { 
        this.horaClase = horaClase;
        this.fechaActualizacion = LocalDateTime.now();
    }
    
    // Método alternativo para setear hora desde String
    public void setHoraClaseFromString(String horaStr) {
        this.horaClase = LocalTime.parse(horaStr);
        this.fechaActualizacion = LocalDateTime.now();
    }
    
    // Método para obtener hora como String formateado
    public String getHoraClaseFormateada() {
        return horaClase != null ? horaClase.format(DateTimeFormatter.ofPattern("HH:mm")) : "";
    }
    
    // Método para obtener hora en formato SQL (HH:mm:ss)
    public String getHoraClaseSQL() {
        return horaClase != null ? horaClase.toString() : "";
    }
    
    public EstadoAsistencia getEstado() { 
        return estado; 
    }
    
    public void setEstado(EstadoAsistencia estado) { 
        this.estado = estado;
        this.fechaActualizacion = LocalDateTime.now();
    }
    
    // Método alternativo para setear estado desde String
    public void setEstadoFromString(String estadoStr) {
        this.estado = EstadoAsistencia.fromString(estadoStr);
        this.fechaActualizacion = LocalDateTime.now();
    }
    
    // Método para obtener estado como String
    public String getEstadoString() {
        return estado != null ? estado.name() : "";
    }
    
    public String getObservaciones() { 
        return observaciones; 
    }
    
    public void setObservaciones(String observaciones) { 
        this.observaciones = observaciones;
        this.fechaActualizacion = LocalDateTime.now();
    }
    
    public int getRegistradoPor() { 
        return registradoPor; 
    }
    
    public void setRegistradoPor(int registradoPor) { 
        this.registradoPor = registradoPor; 
    }
    
    public LocalDateTime getFechaRegistro() { 
        return fechaRegistro; 
    }
    
    public void setFechaRegistro(LocalDateTime fechaRegistro) { 
        this.fechaRegistro = fechaRegistro; 
    }
    
    public LocalDateTime getFechaActualizacion() { 
        return fechaActualizacion; 
    }
    
    public void setFechaActualizacion(LocalDateTime fechaActualizacion) { 
        this.fechaActualizacion = fechaActualizacion; 
    }
    
    public boolean isActivo() { 
        return activo; 
    }
    
    public void setActivo(boolean activo) { 
        this.activo = activo; 
    }
    
    // Getters y Setters de campos adicionales
    public String getAlumnoNombre() { 
        return alumnoNombre; 
    }
    
    public void setAlumnoNombre(String alumnoNombre) { 
        this.alumnoNombre = alumnoNombre; 
    }
    
    public String getAlumnoApellidos() { 
        return alumnoApellidos; 
    }
    
    public void setAlumnoApellidos(String alumnoApellidos) { 
        this.alumnoApellidos = alumnoApellidos; 
    }
    
    // Método para obtener nombre completo del alumno
    public String getAlumnoNombreCompleto() {
        if (alumnoApellidos != null && alumnoNombre != null) {
            return alumnoApellidos + ", " + alumnoNombre;
        }
        return alumnoNombre != null ? alumnoNombre : "";
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
    
    public String getProfesorNombre() { 
        return profesorNombre; 
    }
    
    public void setProfesorNombre(String profesorNombre) { 
        this.profesorNombre = profesorNombre; 
    }
    
    public String getGradoNombre() { 
        return gradoNombre; 
    }
    
    public void setGradoNombre(String gradoNombre) { 
        this.gradoNombre = gradoNombre; 
    }
    
    public String getSedeNombre() { 
        return sedeNombre; 
    }
    
    public void setSedeNombre(String sedeNombre) { 
        this.sedeNombre = sedeNombre; 
    }
    
    public String getAulaNombre() { 
        return aulaNombre; 
    }
    
    public void setAulaNombre(String aulaNombre) { 
        this.aulaNombre = aulaNombre; 
    }
    
    // Métodos de utilidad
    
    /**
     * Verifica si la asistencia fue registrada el día de hoy
     */
    public boolean esDeHoy() {
        return fecha != null && fecha.equals(LocalDate.now());
    }
    
    /**
     * Verifica si el alumno asistió (PRESENTE o TARDANZA)
     */
    public boolean asistio() {
        return estado == EstadoAsistencia.PRESENTE || estado == EstadoAsistencia.TARDANZA;
    }
    
    /**
     * Verifica si el estado es válido para estadísticas de asistencia
     */
    public boolean esAsistenciaValida() {
        return estado == EstadoAsistencia.PRESENTE || 
               estado == EstadoAsistencia.TARDANZA || 
               estado == EstadoAsistencia.JUSTIFICADO;
    }
    
    /**
     * Obtiene el color CSS según el estado (para interfaz)
     */
    public String getColorEstado() {
        if (estado == null) return "gray";
        switch (estado) {
            case PRESENTE:
                return "green";
            case TARDANZA:
                return "orange";
            case AUSENTE:
                return "red";
            case JUSTIFICADO:
                return "blue";
            default:
                return "gray";
        }
    }
    
    /**
     * Obtiene el ícono según el estado (para interfaz)
     */
    public String getIconoEstado() {
        if (estado == null) return "❓";
        switch (estado) {
            case PRESENTE:
                return "✓";
            case TARDANZA:
                return "⏰";
            case AUSENTE:
                return "✗";
            case JUSTIFICADO:
                return "📄";
            default:
                return "❓";
        }
    }
    
    @Override
    public String toString() {
        return String.format(
            "Asistencia{id=%d, alumno='%s', curso='%s', turno='%s', fecha=%s, hora=%s, estado=%s, observaciones='%s'}",
            id, 
            getAlumnoNombreCompleto(), 
            cursoNombre != null ? cursoNombre : "N/A",
            turnoNombre != null ? turnoNombre : "N/A",
            getFechaFormateada(),
            getHoraClaseFormateada(),
            estado != null ? estado.getDescripcion() : "N/A",
            observaciones != null ? observaciones : ""
        );
    }
    
    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null || getClass() != obj.getClass()) return false;
        Asistencia that = (Asistencia) obj;
        return id == that.id;
    }
    
    @Override
    public int hashCode() {
        return Integer.hashCode(id);
    }
}