package modelo;

import java.sql.Date;
import java.util.*;

public class Curso {
    private int id;
    private String nombre;
    private int creditos;
    private int horasSemanales;
    private String area;
    private String ciclo;
    private Date fechaInicio;
    private Date fechaFin;
    private int gradoId;
    private String gradoNombre;
    private String nivel;
    private int profesorId;
    private String profesorNombre;
    private int totalProfesores;
    private int totalHorarios;
    private int cantidadAlumnos;
    private int cantidadTareas;
    
    // Constructor
    public Curso() {
        this.creditos = 0;
        this.horasSemanales = 0;
        this.totalProfesores = 0;
        this.totalHorarios = 0;
        this.cantidadAlumnos = 0;
        this.cantidadTareas = 0;
    }
    
    // Getters y Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    
    public int getCreditos() { return creditos; }
    public void setCreditos(int creditos) { this.creditos = creditos; }
    
    public int getHorasSemanales() { return horasSemanales; }
    public void setHorasSemanales(int horasSemanales) { this.horasSemanales = horasSemanales; }
    
    public String getArea() { return area; }
    public void setArea(String area) { this.area = area; }
    
    public String getCiclo() { return ciclo; }
    public void setCiclo(String ciclo) { this.ciclo = ciclo; }
    
    public Date getFechaInicio() { return fechaInicio; }
    public void setFechaInicio(Date fechaInicio) { this.fechaInicio = fechaInicio; }
    
    public Date getFechaFin() { return fechaFin; }
    public void setFechaFin(Date fechaFin) { this.fechaFin = fechaFin; }
    
    public int getGradoId() { return gradoId; }
    public void setGradoId(int gradoId) { this.gradoId = gradoId; }
    
    public String getGradoNombre() { return gradoNombre; }
    public void setGradoNombre(String gradoNombre) { this.gradoNombre = gradoNombre; }
    
    public String getNivel() { return nivel; }
    public void setNivel(String nivel) { this.nivel = nivel; }
    
    public int getProfesorId() { return profesorId; }
    public void setProfesorId(int profesorId) { this.profesorId = profesorId; }
    
    public String getProfesorNombre() { return profesorNombre; }
    public void setProfesorNombre(String profesorNombre) { this.profesorNombre = profesorNombre; }
    
    public int getTotalProfesores() { return totalProfesores; }
    public void setTotalProfesores(int totalProfesores) { this.totalProfesores = totalProfesores; }
    
    public int getTotalHorarios() { return totalHorarios; }
    public void setTotalHorarios(int totalHorarios) { this.totalHorarios = totalHorarios; }
    
    public int getCantidadAlumnos() { return cantidadAlumnos; }
    public void setCantidadAlumnos(int cantidadAlumnos) { this.cantidadAlumnos = cantidadAlumnos; }
    
    public int getCantidadTareas() { return cantidadTareas; }
    public void setCantidadTareas(int cantidadTareas) { this.cantidadTareas = cantidadTareas; }
}