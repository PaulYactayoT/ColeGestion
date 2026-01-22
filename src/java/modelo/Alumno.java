package modelo;

import java.time.LocalDate;

public class Alumno {
    private int id;
    private int personaId;
    private String nombres;
    private String apellidos;
    private String correo;
    private String dni;
    private String telefono;
    private String direccion;
    private LocalDate fechaNacimiento;
    private int gradoId;
    private String gradoNombre;
    private String codigoAlumno;
    private String estado;
    private LocalDate fechaIngreso;
    
    // Constructores
    public Alumno() {}
    
    public Alumno(int id, int personaId, String nombres, String apellidos, String correo, 
                  String dni, String telefono, String direccion, LocalDate fechaNacimiento, 
                  int gradoId, String gradoNombre, String codigoAlumno, String estado, 
                  LocalDate fechaIngreso) {
        this.id = id;
        this.personaId = personaId;
        this.nombres = nombres;
        this.apellidos = apellidos;
        this.correo = correo;
        this.dni = dni;
        this.telefono = telefono;
        this.direccion = direccion;
        this.fechaNacimiento = fechaNacimiento;
        this.gradoId = gradoId;
        this.gradoNombre = gradoNombre;
        this.codigoAlumno = codigoAlumno;
        this.estado = estado;
        this.fechaIngreso = fechaIngreso;
    }
    
    // Getters y Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getPersonaId() { return personaId; }
    public void setPersonaId(int personaId) { this.personaId = personaId; }
    
    public String getNombres() { return nombres; }
    public void setNombres(String nombres) { this.nombres = nombres; }
    
    public String getApellidos() { return apellidos; }
    public void setApellidos(String apellidos) { this.apellidos = apellidos; }
    
    public String getCorreo() { return correo; }
    public void setCorreo(String correo) { this.correo = correo; }
    
    public String getDni() { return dni; }
    public void setDni(String dni) { this.dni = dni; }
    
    public String getTelefono() { return telefono; }
    public void setTelefono(String telefono) { this.telefono = telefono; }
    
    public String getDireccion() { return direccion; }
    public void setDireccion(String direccion) { this.direccion = direccion; }
    
    public LocalDate getFechaNacimiento() { return fechaNacimiento; }
    public void setFechaNacimiento(LocalDate fechaNacimiento) { this.fechaNacimiento = fechaNacimiento; }
    
    public int getGradoId() { return gradoId; }
    public void setGradoId(int gradoId) { this.gradoId = gradoId; }
    
    public String getGradoNombre() { return gradoNombre; }
    public void setGradoNombre(String gradoNombre) { this.gradoNombre = gradoNombre; }
    
    public String getCodigoAlumno() { return codigoAlumno; }
    public void setCodigoAlumno(String codigoAlumno) { this.codigoAlumno = codigoAlumno; }
    
    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }
    
    public LocalDate getFechaIngreso() { return fechaIngreso; }
    public void setFechaIngreso(LocalDate fechaIngreso) { this.fechaIngreso = fechaIngreso; }
    
    // Método auxiliar
    public String getNombreCompleto() {
        return nombres + " " + apellidos;
    }
}