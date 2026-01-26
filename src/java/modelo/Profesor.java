package modelo;

import java.util.Date;

public class Profesor {
    private int id;
    private int personaId;
    private String nombres;
    private String apellidos;
    private String correo;
    private String telefono;
    private String dni;
    private Date fechaNacimiento;
    private String direccion;
    private String especialidad;
    private String codigoProfesor;
    private Date fechaContratacion;
    private String estado;
    private String username;
    private String rol;
    private String password; 
    private int turnoId;
    private String turnoNombre; 
    private String nivel;
    // Constructor
    public Profesor() {
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

    public String getCorreo() {
        return correo;
    }

    public void setCorreo(String correo) {
        this.correo = correo;
    }

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }

    public String getDni() {
        return dni;
    }

    public void setDni(String dni) {
        this.dni = dni;
    }

    public Date getFechaNacimiento() {
        return fechaNacimiento;
    }

    public void setFechaNacimiento(Date fechaNacimiento) {
        this.fechaNacimiento = fechaNacimiento;
    }

    public String getDireccion() {
        return direccion;
    }

    public void setDireccion(String direccion) {
        this.direccion = direccion;
    }

    public String getEspecialidad() {
        return especialidad;
    }

    public void setEspecialidad(String especialidad) {
        this.especialidad = especialidad;
    }

    public String getCodigoProfesor() {
        return codigoProfesor;
    }

    public void setCodigoProfesor(String codigoProfesor) {
        this.codigoProfesor = codigoProfesor;
    }

    public Date getFechaContratacion() {
        return fechaContratacion;
    }

    public void setFechaContratacion(Date fechaContratacion) {
        this.fechaContratacion = fechaContratacion;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getRol() {
        return rol;
    }

    public void setRol(String rol) {
        this.rol = rol;
    }

    // Nuevo getter y setter para password
    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
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

    // Método auxiliar
    public String getNombreCompleto() {
        return nombres + " " + apellidos;
    }
    
    public String getNivel() {
    return nivel;
    }

    public void setNivel(String nivel) {
        this.nivel = nivel;
    }
  
}