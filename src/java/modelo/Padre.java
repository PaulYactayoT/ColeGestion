package modelo;

public class Padre {
    private int id; // Persona ID
    private String nombres;
    private String apellidos;
    private String correo;
    private String dni;
    private String telefono;
    private String rol;
    private String username;
    
    // Información del alumno asociado
    private int alumnoId;
    private String alumnoCodigo;
    private String alumnoNombre;
    private String gradoNombre;
    
    // Información de relación familiar
    private String parentesco;
    private boolean esContactoPrincipal;
    
    // Constructores
    public Padre() {}
    
    public Padre(int id, String nombres, String apellidos, String username) {
        this.id = id;
        this.nombres = nombres;
        this.apellidos = apellidos;
        this.username = username;
    }
    
    // Getters y Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public String getNombres() { return nombres; }
    public void setNombres(String nombres) { this.nombres = nombres; }
    
    public String getApellidos() { return apellidos; }
    public void setApellidos(String apellidos) { this.apellidos = apellidos; }
    
    public String getNombreCompleto() { 
        return (nombres != null ? nombres : "") + " " + (apellidos != null ? apellidos : ""); 
    }
    
    public String getCorreo() { return correo; }
    public void setCorreo(String correo) { this.correo = correo; }
    
    public String getDni() { return dni; }
    public void setDni(String dni) { this.dni = dni; }
    
    public String getTelefono() { return telefono; }
    public void setTelefono(String telefono) { this.telefono = telefono; }
    
    public String getRol() { return rol; }
    public void setRol(String rol) { this.rol = rol; }
    
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    
    public int getAlumnoId() { return alumnoId; }
    public void setAlumnoId(int alumnoId) { this.alumnoId = alumnoId; }
    
    public String getAlumnoCodigo() { return alumnoCodigo; }
    public void setAlumnoCodigo(String alumnoCodigo) { this.alumnoCodigo = alumnoCodigo; }
    
    public String getAlumnoNombre() { return alumnoNombre; }
    public void setAlumnoNombre(String alumnoNombre) { this.alumnoNombre = alumnoNombre; }
    
    public String getGradoNombre() { return gradoNombre; }
    public void setGradoNombre(String gradoNombre) { this.gradoNombre = gradoNombre; }
    
    public String getParentesco() { return parentesco; }
    public void setParentesco(String parentesco) { this.parentesco = parentesco; }
    
    public boolean isEsContactoPrincipal() { return esContactoPrincipal; }
    public void setEsContactoPrincipal(boolean esContactoPrincipal) { 
        this.esContactoPrincipal = esContactoPrincipal; 
    }
}