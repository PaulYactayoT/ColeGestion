package modelo;

import java.util.Date;
import java.text.SimpleDateFormat;

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
    private boolean activo;
    private boolean eliminado;
    
    // Datos adicionales (joins)
    private String cursoNombre;
    private String profesorNombre;
    
    // Constructor vacío
    public Material() {
    }
    
    // Constructor con parámetros principales
    public Material(int cursoId, int profesorId, String nombreArchivo, 
                   String rutaArchivo, String tipoArchivo, long tamanioArchivo) {
        this.cursoId = cursoId;
        this.profesorId = profesorId;
        this.nombreArchivo = nombreArchivo;
        this.rutaArchivo = rutaArchivo;
        this.tipoArchivo = tipoArchivo;
        this.tamanioArchivo = tamanioArchivo;
        this.activo = true;
        this.eliminado = false;
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

    public int getProfesorId() {
        return profesorId;
    }

    public void setProfesorId(int profesorId) {
        this.profesorId = profesorId;
    }

    public String getNombreArchivo() {
        return nombreArchivo;
    }

    public void setNombreArchivo(String nombreArchivo) {
        this.nombreArchivo = nombreArchivo;
    }

    public String getRutaArchivo() {
        return rutaArchivo;
    }

    public void setRutaArchivo(String rutaArchivo) {
        this.rutaArchivo = rutaArchivo;
    }

    public String getTipoArchivo() {
        return tipoArchivo;
    }

    public void setTipoArchivo(String tipoArchivo) {
        this.tipoArchivo = tipoArchivo;
    }

    public long getTamanioArchivo() {
        return tamanioArchivo;
    }

    public void setTamanioArchivo(long tamanioArchivo) {
        this.tamanioArchivo = tamanioArchivo;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public Date getFechaSubida() {
        return fechaSubida;
    }

    public void setFechaSubida(Date fechaSubida) {
        this.fechaSubida = fechaSubida;
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

    public String getCursoNombre() {
        return cursoNombre;
    }

    public void setCursoNombre(String cursoNombre) {
        this.cursoNombre = cursoNombre;
    }

    public String getProfesorNombre() {
        return profesorNombre;
    }

    public void setProfesorNombre(String profesorNombre) {
        this.profesorNombre = profesorNombre;
    }
    
    /**
     * Obtener tamaño formateado (KB, MB)
     */
    public String getTamanioFormateado() {
        if (tamanioArchivo < 1024) {
            return tamanioArchivo + " B";
        } else if (tamanioArchivo < 1024 * 1024) {
            return String.format("%.2f KB", tamanioArchivo / 1024.0);
        } else {
            return String.format("%.2f MB", tamanioArchivo / (1024.0 * 1024.0));
        }
    }
    
    /**
     * Obtener extensión del archivo
     */
    public String getExtension() {
        if (nombreArchivo != null && nombreArchivo.contains(".")) {
            return nombreArchivo.substring(nombreArchivo.lastIndexOf(".") + 1).toUpperCase();
        }
        return "ARCHIVO";
    }
    
    /**
     * Obtener fecha formateada
     */
    public String getFechaSubidaFormateada() {
        if (fechaSubida != null) {
            SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
            return sdf.format(fechaSubida);
        }
        return "";
    }
    
    /**
     * Obtener solo la fecha (sin hora)
     */
    public String getFechaSubidaCorta() {
        if (fechaSubida != null) {
            SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
            return sdf.format(fechaSubida);
        }
        return "";
    }
    
    /**
     * Método auxiliar para obtener icono según tipo de archivo
     */
    public String getIcono() {
        String extension = getExtension().toLowerCase();
        if (extension.contains("pdf")) return "bi-file-earmark-pdf";
        if (extension.contains("doc") || extension.contains("docx")) return "bi-file-earmark-word";
        if (extension.contains("xls") || extension.contains("xlsx")) return "bi-file-earmark-excel";
        if (extension.contains("ppt") || extension.contains("pptx")) return "bi-file-earmark-ppt";
        if (extension.contains("jpg") || extension.contains("jpeg") || extension.contains("png") || 
            extension.contains("gif")) return "bi-file-earmark-image";
        if (extension.contains("zip") || extension.contains("rar") || extension.contains("7z")) return "bi-file-earmark-zip";
        if (extension.contains("txt")) return "bi-file-earmark-text";
        return "bi-file-earmark";
    }
}