package modelo;

public class Entrega {
    private int id;
    private int tareaId;
    private int alumnoId;
    private String archivoRuta;
    private String archivoNombre;
    private String fechaEntrega;
    private boolean activo;

    public Entrega() {
    }

    public Entrega(int tareaId, int alumnoId, String archivoRuta, String archivoNombre) {
        this.tareaId = tareaId;
        this.alumnoId = alumnoId;
        this.archivoRuta = archivoRuta;
        this.archivoNombre = archivoNombre;
        this.activo = true;
    }

    // Getters y Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getTareaId() { return tareaId; }
    public void setTareaId(int tareaId) { this.tareaId = tareaId; }
    
    public int getAlumnoId() { return alumnoId; }
    public void setAlumnoId(int alumnoId) { this.alumnoId = alumnoId; }
    
    public String getArchivoRuta() { return archivoRuta; }
    public void setArchivoRuta(String archivoRuta) { this.archivoRuta = archivoRuta; }
    
    public String getArchivoNombre() { return archivoNombre; }
    public void setArchivoNombre(String archivoNombre) { this.archivoNombre = archivoNombre; }
    
    public String getFechaEntrega() { return fechaEntrega; }
    public void setFechaEntrega(String fechaEntrega) { this.fechaEntrega = fechaEntrega; }

    public boolean isActivo() { return activo; }
    public void setActivo(boolean activo) { this.activo = activo; }
}