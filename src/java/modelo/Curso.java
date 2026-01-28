package modelo;

import java.sql.Date;

/**
 * MODELO DE CURSO
 * Representa un curso académico con todos sus atributos
 */
public class Curso {
    
    // ========== CAMPOS BÁSICOS ==========
    private int id;
    private String nombre;
    private int gradoId;
    private String gradoNombre;
    private String nivel;
    private int profesorId;
    private String profesorNombre;
    
    // ========== CAMPOS ACADÉMICOS ==========
    private int creditos;
    private int horasSemanales;
    private String area;
    private String descripcion;
    private String ciclo;
    
    // ========== FECHAS ==========
    private Date fechaInicio;
    private Date fechaFin;
    private Date fechaRegistro;
    
    // ========== CAMPOS ADICIONALES ==========
    private Integer turnoId;           // NUEVO: ID del turno
    private String turnoNombre;        // NUEVO: Nombre del turno
    private int totalProfesores;
    private int totalHorarios;
    private int cantidadAlumnos;
    private int cantidadTareas;
    
    // ========== ESTADO ==========
    private boolean activo;
    private boolean eliminado;
    
    // ========== CONSTRUCTORES ==========
    
    public Curso() {
        this.activo = true;
        this.eliminado = false;
    }
    
    public Curso(int id, String nombre, int gradoId, int profesorId, int creditos, String area) {
        this.id = id;
        this.nombre = nombre;
        this.gradoId = gradoId;
        this.profesorId = profesorId;
        this.creditos = creditos;
        this.area = area;
        this.activo = true;
        this.eliminado = false;
    }
    
    // ========== GETTERS Y SETTERS ==========
    
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
    
    public int getGradoId() {
        return gradoId;
    }
    
    public void setGradoId(int gradoId) {
        this.gradoId = gradoId;
    }
    
    public String getGradoNombre() {
        return gradoNombre;
    }
    
    public void setGradoNombre(String gradoNombre) {
        this.gradoNombre = gradoNombre;
    }
    
    public String getNivel() {
        return nivel;
    }
    
    public void setNivel(String nivel) {
        this.nivel = nivel;
    }
    
    public int getProfesorId() {
        return profesorId;
    }
    
    public void setProfesorId(int profesorId) {
        this.profesorId = profesorId;
    }
    
    public String getProfesorNombre() {
        return profesorNombre;
    }
    
    public void setProfesorNombre(String profesorNombre) {
        this.profesorNombre = profesorNombre;
    }
    
    public int getCreditos() {
        return creditos;
    }
    
    public void setCreditos(int creditos) {
        this.creditos = creditos;
    }
    
    public int getHorasSemanales() {
        return horasSemanales;
    }
    
    public void setHorasSemanales(int horasSemanales) {
        this.horasSemanales = horasSemanales;
    }
    
    public String getArea() {
        return area;
    }
    
    public void setArea(String area) {
        this.area = area;
    }
    
    public String getDescripcion() {
        return descripcion;
    }
    
    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }
    
    public String getCiclo() {
        return ciclo;
    }
    
    public void setCiclo(String ciclo) {
        this.ciclo = ciclo;
    }
    
    public Date getFechaInicio() {
        return fechaInicio;
    }
    
    public void setFechaInicio(Date fechaInicio) {
        this.fechaInicio = fechaInicio;
    }
    
    public Date getFechaFin() {
        return fechaFin;
    }
    
    public void setFechaFin(Date fechaFin) {
        this.fechaFin = fechaFin;
    }
    
    public Date getFechaRegistro() {
        return fechaRegistro;
    }
    
    public void setFechaRegistro(Date fechaRegistro) {
        this.fechaRegistro = fechaRegistro;
    }
    
    // ========== NUEVO: GETTERS/SETTERS TURNO ==========
    
    public Integer getTurnoId() {
        return turnoId;
    }
    
    public void setTurnoId(Integer turnoId) {
        this.turnoId = turnoId;
    }
    
    public String getTurnoNombre() {
        return turnoNombre;
    }
    
    public void setTurnoNombre(String turnoNombre) {
        this.turnoNombre = turnoNombre;
    }
    
    // ========== ESTADÍSTICAS ==========
    
    public int getTotalProfesores() {
        return totalProfesores;
    }
    
    public void setTotalProfesores(int totalProfesores) {
        this.totalProfesores = totalProfesores;
    }
    
    public int getTotalHorarios() {
        return totalHorarios;
    }
    
    public void setTotalHorarios(int totalHorarios) {
        this.totalHorarios = totalHorarios;
    }
    
    public int getCantidadAlumnos() {
        return cantidadAlumnos;
    }
    
    public void setCantidadAlumnos(int cantidadAlumnos) {
        this.cantidadAlumnos = cantidadAlumnos;
    }
    
    public int getCantidadTareas() {
        return cantidadTareas;
    }
    
    public void setCantidadTareas(int cantidadTareas) {
        this.cantidadTareas = cantidadTareas;
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
    
    // ========== toString() ==========
    
    @Override
    public String toString() {
        return "Curso{" +
                "id=" + id +
                ", nombre='" + nombre + '\'' +
                ", grado='" + gradoNombre + '\'' +
                ", nivel='" + nivel + '\'' +
                ", profesor='" + profesorNombre + '\'' +
                ", area='" + area + '\'' +
                ", turnoId=" + turnoId +
                ", activo=" + activo +
                '}';
    }
}