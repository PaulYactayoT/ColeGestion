package modelo;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

/**
 * Clase que representa un Alumno en el sistema de gestión escolar
 * Mapea la tabla 'alumno' y 'persona' de la base de datos
 */
public class Alumno {
    // Campos de la tabla 'alumno'
    private int id;
    private int personaId;
    private int gradoId;
    private String codigoAlumno;
    private LocalDate fechaIngreso;
    private EstadoAlumno estado; // ACTIVO, INACTIVO, EGRESADO, RETIRADO
    
    // Campos de la tabla 'persona'
    private String nombres;
    private String apellidos;
    private String correo;
    private LocalDate fechaNacimiento;
    private boolean activo;
    
    // Campos adicionales para mostrar información relacionada
    private String gradoNombre;
    private String nivelGrado; // INICIAL, PRIMARIA, SECUNDARIA
    
    // Enum para estados de alumno
    public enum EstadoAlumno {
        ACTIVO("Activo"),
        INACTIVO("Inactivo"),
        EGRESADO("Egresado"),
        RETIRADO("Retirado");
        
        private final String descripcion;
        
        EstadoAlumno(String descripcion) {
            this.descripcion = descripcion;
        }
        
        public String getDescripcion() {
            return descripcion;
        }
        
        public static EstadoAlumno fromString(String text) {
            for (EstadoAlumno e : EstadoAlumno.values()) {
                if (e.name().equalsIgnoreCase(text)) {
                    return e;
                }
            }
            return ACTIVO; // Valor por defecto
        }
    }
    
    // Constructores
    public Alumno() {
        this.activo = true;
        this.estado = EstadoAlumno.ACTIVO;
        this.fechaIngreso = LocalDate.now();
    }
    
    public Alumno(int id, String nombres, String apellidos, int gradoId) {
        this();
        this.id = id;
        this.nombres = nombres;
        this.apellidos = apellidos;
        this.gradoId = gradoId;
    }
    
    public Alumno(String nombres, String apellidos, String correo, 
                  LocalDate fechaNacimiento, int gradoId) {
        this();
        this.nombres = nombres;
        this.apellidos = apellidos;
        this.correo = correo;
        this.fechaNacimiento = fechaNacimiento;
        this.gradoId = gradoId;
    }
    
    // Getters y Setters
    public int getId() { 
        return id; 
    }
    
    public void setId(int id) { 
        this.id = id; 
    }
    
    public int getPersonaId() { 
        return personaId; 
    }
    
    public void setPersonaId(int personaId) { 
        this.personaId = personaId; 
    }
    
    public int getGradoId() { 
        return gradoId; 
    }
    
    public void setGradoId(int gradoId) { 
        this.gradoId = gradoId; 
    }
    
    public String getCodigoAlumno() { 
        return codigoAlumno; 
    }
    
    public void setCodigoAlumno(String codigoAlumno) { 
        this.codigoAlumno = codigoAlumno; 
    }
    
    public LocalDate getFechaIngreso() { 
        return fechaIngreso; 
    }
    
    public void setFechaIngreso(LocalDate fechaIngreso) { 
        this.fechaIngreso = fechaIngreso; 
    }
    
    // Método alternativo para setear fecha de ingreso desde String
    public void setFechaIngresoFromString(String fechaStr) {
        this.fechaIngreso = LocalDate.parse(fechaStr);
    }
    
    // Método para obtener fecha de ingreso formateada
    public String getFechaIngresoFormateada() {
        return fechaIngreso != null ? 
            fechaIngreso.format(DateTimeFormatter.ofPattern("dd/MM/yyyy")) : "";
    }
    
    // Método para obtener fecha de ingreso en formato SQL
    public String getFechaIngresoSQL() {
        return fechaIngreso != null ? fechaIngreso.toString() : "";
    }
    
    public EstadoAlumno getEstado() { 
        return estado; 
    }
    
    public void setEstado(EstadoAlumno estado) { 
        this.estado = estado; 
    }
    
    // Método alternativo para setear estado desde String
    public void setEstadoFromString(String estadoStr) {
        this.estado = EstadoAlumno.fromString(estadoStr);
    }
    
    // Método para obtener estado como String
    public String getEstadoString() {
        return estado != null ? estado.name() : "";
    }
    
    public String getNombres() { 
        return nombres; 
    }
    
    public void setNombres(String nombres) { 
        this.nombres = nombres; 
    }
    
    public String getApellidos() { 
        return apellidos; 
    }
    
    public void setApellidos(String apellidos) { 
        this.apellidos = apellidos; 
    }
    
    // Método para obtener nombre completo
    public String getNombreCompleto() {
        if (apellidos != null && nombres != null) {
            return apellidos + ", " + nombres;
        }
        return nombres != null ? nombres : "";
    }
    
    // Método alternativo para nombre completo (nombre primero)
    public String getNombreCompletoInverso() {
        if (nombres != null && apellidos != null) {
            return nombres + " " + apellidos;
        }
        return nombres != null ? nombres : "";
    }
    
    public String getCorreo() { 
        return correo; 
    }
    
    public void setCorreo(String correo) { 
        this.correo = correo; 
    }
    
    public LocalDate getFechaNacimiento() { 
        return fechaNacimiento; 
    }
    
    public void setFechaNacimiento(LocalDate fechaNacimiento) { 
        this.fechaNacimiento = fechaNacimiento; 
    }
    
    // Método alternativo para setear fecha de nacimiento desde String
    public void setFechaNacimientoFromString(String fechaStr) {
        this.fechaNacimiento = LocalDate.parse(fechaStr);
    }
    
    // Método para obtener fecha de nacimiento formateada
    public String getFechaNacimientoFormateada() {
        return fechaNacimiento != null ? 
            fechaNacimiento.format(DateTimeFormatter.ofPattern("dd/MM/yyyy")) : "";
    }
    
    // Método para obtener fecha de nacimiento en formato SQL
    public String getFechaNacimientoSQL() {
        return fechaNacimiento != null ? fechaNacimiento.toString() : "";
    }
    
    public boolean isActivo() { 
        return activo; 
    }
    
    public void setActivo(boolean activo) { 
        this.activo = activo; 
    }
    
    public String getGradoNombre() { 
        return gradoNombre; 
    }
    
    public void setGradoNombre(String gradoNombre) { 
        this.gradoNombre = gradoNombre; 
    }
    
    public String getNivelGrado() { 
        return nivelGrado; 
    }
    
    public void setNivelGrado(String nivelGrado) { 
        this.nivelGrado = nivelGrado; 
    }
    
    // Métodos de utilidad
    
    /**
     * Calcula la edad del alumno en años
     */
    public int calcularEdad() {
        if (fechaNacimiento != null) {
            return LocalDate.now().getYear() - fechaNacimiento.getYear();
        }
        return 0;
    }
    
    /**
     * Verifica si el alumno está activo en el sistema
     */
    public boolean estaActivo() {
        return activo && estado == EstadoAlumno.ACTIVO;
    }
    
    /**
     * Verifica si el alumno puede asistir a clases
     */
    public boolean puedeAsistir() {
        return estado == EstadoAlumno.ACTIVO;
    }
    
    /**
     * Obtiene información completa del grado (nombre + nivel)
     */
    public String getGradoCompleto() {
        if (gradoNombre != null && nivelGrado != null) {
            return gradoNombre + " - " + nivelGrado;
        }
        return gradoNombre != null ? gradoNombre : "";
    }
    
    /**
     * Obtiene el color CSS según el estado (para interfaz)
     */
    public String getColorEstado() {
        if (estado == null) return "gray";
        switch (estado) {
            case ACTIVO:
                return "green";
            case INACTIVO:
                return "orange";
            case EGRESADO:
                return "blue";
            case RETIRADO:
                return "red";
            default:
                return "gray";
        }
    }
    
    @Override
    public String toString() {
        return String.format(
            "Alumno{id=%d, codigo='%s', nombre='%s', grado='%s', estado=%s, activo=%s}",
            id,
            codigoAlumno != null ? codigoAlumno : "N/A",
            getNombreCompleto(),
            gradoNombre != null ? gradoNombre : "N/A",
            estado != null ? estado.getDescripcion() : "N/A",
            activo
        );
    }
    
    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null || getClass() != obj.getClass()) return false;
        Alumno alumno = (Alumno) obj;
        return id == alumno.id;
    }
    
    @Override
    public int hashCode() {
        return Integer.hashCode(id);
    }
}