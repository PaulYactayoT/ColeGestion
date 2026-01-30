package modelo;

public class Tarea {
    private int id;
    private int cursoId;
    private String nombre;
    private String descripcion;
    private String fechaEntrega;
    private boolean activo;
    private String tipo;
    private double peso;
    private String instrucciones;
    private String archivoAdjunto;  
    private String cursoNombre;
    private String gradoNombre;
    
    // Constructor vacío
    public Tarea() {
        this.activo = true;
        this.tipo = "TAREA";
        this.peso = 1.0;
    }
    
    // Constructor con parámetros básicos
    public Tarea(int id, String nombre, String descripcion, String fechaEntrega) {
        this.id = id;
        this.nombre = nombre;
        this.descripcion = descripcion;
        this.fechaEntrega = fechaEntrega;
        this.activo = true;
        this.tipo = "TAREA";
        this.peso = 1.0;
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

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public String getFechaEntrega() {
        return fechaEntrega;
    }

    public void setFechaEntrega(String fechaEntrega) {
        this.fechaEntrega = fechaEntrega;
    }

    public boolean isActivo() {
        return activo;
    }

    public void setActivo(boolean activo) {
        this.activo = activo;
    }

    public String getTipo() {
        return tipo;
    }

    public void setTipo(String tipo) {
        this.tipo = tipo;
    }

    public double getPeso() {
        return peso;
    }

    public void setPeso(double peso) {
        this.peso = peso;
    }

    public String getInstrucciones() {
        return instrucciones;
    }

    public void setInstrucciones(String instrucciones) {
        this.instrucciones = instrucciones;
    }

    public String getArchivoAdjunto() {
        return archivoAdjunto;
    }

    public void setArchivoAdjunto(String archivoAdjunto) {
        this.archivoAdjunto = archivoAdjunto;
    }

    public String getCursoNombre() {
        return cursoNombre;
    }

    public void setCursoNombre(String cursoNombre) {
        this.cursoNombre = cursoNombre;
    }

    public String getGradoNombre() {
        return gradoNombre;
    }

    public void setGradoNombre(String gradoNombre) {
        this.gradoNombre = gradoNombre;
    }
    
    @Override
    public String toString() {
        return "Tarea{" +
                "id=" + id +
                ", cursoId=" + cursoId +
                ", nombre='" + nombre + '\'' +
                ", descripcion='" + descripcion + '\'' +
                ", fechaEntrega='" + fechaEntrega + '\'' +
                ", activo=" + activo +
                ", tipo='" + tipo + '\'' +
                ", peso=" + peso +
                ", archivoAdjunto='" + archivoAdjunto + '\'' +
                '}';
    }
}