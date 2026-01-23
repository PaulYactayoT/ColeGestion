package modelo;

import java.util.Date;

public class Material {
    private int id;
    private int cursoId;
    private int profesorId;
    private String nombreArchivo;
    private String rutaArchivo;
    private String tipoArchivo;
    private long tamanioArchivo;
    private String descripcion;
    private Date fechaSubida;
    private String profesorNombre;
    private String cursoNombre;
    
    // Constructor
    public Material() {}
    
    // Getters y Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getCursoId() { return cursoId; }
    public void setCursoId(int cursoId) { this.cursoId = cursoId; }
    
    public int getProfesorId() { return profesorId; }
    public void setProfesorId(int profesorId) { this.profesorId = profesorId; }
    
    public String getNombreArchivo() { return nombreArchivo; }
    public void setNombreArchivo(String nombreArchivo) { this.nombreArchivo = nombreArchivo; }
    
    public String getRutaArchivo() { return rutaArchivo; }
    public void setRutaArchivo(String rutaArchivo) { this.rutaArchivo = rutaArchivo; }
    
    public String getTipoArchivo() { return tipoArchivo; }
    public void setTipoArchivo(String tipoArchivo) { this.tipoArchivo = tipoArchivo; }
    
    public long getTamanioArchivo() { return tamanioArchivo; }
    public void setTamanioArchivo(long tamanioArchivo) { this.tamanioArchivo = tamanioArchivo; }
    
    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }
    
    public Date getFechaSubida() { return fechaSubida; }
    public void setFechaSubida(Date fechaSubida) { this.fechaSubida = fechaSubida; }
    
    public String getProfesorNombre() { return profesorNombre; }
    public void setProfesorNombre(String profesorNombre) { this.profesorNombre = profesorNombre; }
    
    public String getCursoNombre() { return cursoNombre; }
    public void setCursoNombre(String cursoNombre) { this.cursoNombre = cursoNombre; }
    
    // Métodos adicionales
    public String getExtension() {
        if (nombreArchivo == null) return "";
        int dotIndex = nombreArchivo.lastIndexOf('.');
        if (dotIndex > 0 && dotIndex < nombreArchivo.length() - 1) {
            return nombreArchivo.substring(dotIndex + 1).toUpperCase();
        }
        return "";
    }
    
    public String getTamanioFormateado() {
        if (tamanioArchivo < 1024) {
            return tamanioArchivo + " B";
        } else if (tamanioArchivo < 1024 * 1024) {
            return String.format("%.1f KB", tamanioArchivo / 1024.0);
        } else {
            return String.format("%.1f MB", tamanioArchivo / (1024.0 * 1024.0));
        }
    }
}