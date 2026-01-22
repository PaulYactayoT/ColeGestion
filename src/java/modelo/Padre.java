package modelo;

public class Padre {
    private int id;
    private String nombres;
    private String apellidos;
    private String username;
    private int alumnoId;
    private String alumnoNombre;
    private String alumnoCodigo;
    private String gradoNombre;

    // Getters y setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getNombres() { return nombres; }
    public void setNombres(String nombres) { this.nombres = nombres; }

    public String getApellidos() { return apellidos; }
    public void setApellidos(String apellidos) { this.apellidos = apellidos; }

    public String getNombreCompleto() { return this.nombres + " " + this.apellidos; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public int getAlumnoId() { return alumnoId; }
    public void setAlumnoId(int alumnoId) { this.alumnoId = alumnoId; }

    public String getAlumnoNombre() { return alumnoNombre; }
    public void setAlumnoNombre(String alumnoNombre) { this.alumnoNombre = alumnoNombre; }

    public String getAlumnoCodigo() { return alumnoCodigo; }
    public void setAlumnoCodigo(String alumnoCodigo) { this.alumnoCodigo = alumnoCodigo; }

    public String getGradoNombre() { return gradoNombre; }
    public void setGradoNombre(String gradoNombre) { this.gradoNombre = gradoNombre; }
}