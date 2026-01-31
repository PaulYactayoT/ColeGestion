package modelo;

import java.time.LocalDateTime;

/**
 * Representa una justificación de asistencia
 */
public class Justificacion {
    
    // Enum para tipo de justificación
    public enum TipoJustificacion {
        ENFERMEDAD,
        EMERGENCIA_FAMILIAR,
        CITA_MEDICA,
        OTRO
    }
    
    // Enum para estado
    public enum EstadoJustificacion {
        PENDIENTE,
        APROBADO,
        RECHAZADO
    }
    
    private int id;
    private int asistenciaId;
    private TipoJustificacion tipoJustificacion;
    private String descripcion;
    private String documentoAdjunto;
    private int justificadoPor;
    private LocalDateTime fechaJustificacion;
    private EstadoJustificacion estado;
    private int aprobadoPor;
    private LocalDateTime fechaAprobacion;
    private String observacionesAprobacion;
    private boolean activo;
    private String alumnoNombre;
    private String cursoNombre;
    private String justificadorNombre;
    private String aprobadorNombre;
    private String fechaAsistencia;
    
    // Constructor
    public Justificacion() {
        this.estado = EstadoJustificacion.PENDIENTE;
        this.fechaJustificacion = LocalDateTime.now();
        this.activo = true;
    }
    
    // Getters y Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getAsistenciaId() { return asistenciaId; }
    public void setAsistenciaId(int asistenciaId) { this.asistenciaId = asistenciaId; }
    
    public TipoJustificacion getTipoJustificacion() { return tipoJustificacion; }
    public void setTipoJustificacion(TipoJustificacion tipoJustificacion) { 
        this.tipoJustificacion = tipoJustificacion; 
    }
    
    public String getTipoJustificacionString() {
        return tipoJustificacion != null ? tipoJustificacion.toString() : null;
    }
    
    public void setTipoJustificacionFromString(String tipo) {
        if (tipo != null && !tipo.isEmpty()) {
            this.tipoJustificacion = TipoJustificacion.valueOf(tipo);
        }
    }
    
    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }
    
    public String getDocumentoAdjunto() { return documentoAdjunto; }
    public void setDocumentoAdjunto(String documentoAdjunto) { 
        this.documentoAdjunto = documentoAdjunto; 
    }
    
    public int getJustificadoPor() { return justificadoPor; }
    public void setJustificadoPor(int justificadoPor) { 
        this.justificadoPor = justificadoPor; 
    }
    
    public LocalDateTime getFechaJustificacion() { return fechaJustificacion; }
    public void setFechaJustificacion(LocalDateTime fechaJustificacion) { 
        this.fechaJustificacion = fechaJustificacion; 
    }
    
    public EstadoJustificacion getEstado() { return estado; }
    public void setEstado(EstadoJustificacion estado) { this.estado = estado; }
    
    public String getEstadoString() {
        return estado != null ? estado.toString() : null;
    }
    
    public void setEstadoFromString(String estado) {
        if (estado != null && !estado.isEmpty()) {
            this.estado = EstadoJustificacion.valueOf(estado);
        }
    }
    
    public int getAprobadoPor() { return aprobadoPor; }
    public void setAprobadoPor(int aprobadoPor) { this.aprobadoPor = aprobadoPor; }
    
    public LocalDateTime getFechaAprobacion() { return fechaAprobacion; }
    public void setFechaAprobacion(LocalDateTime fechaAprobacion) { 
        this.fechaAprobacion = fechaAprobacion; 
    }
    
    public String getObservacionesAprobacion() { return observacionesAprobacion; }
    public void setObservacionesAprobacion(String observacionesAprobacion) { 
        this.observacionesAprobacion = observacionesAprobacion; 
    }
    
    public boolean isActivo() { return activo; }
    public void setActivo(boolean activo) { this.activo = activo; }
    
    // Campos adicionales
    public String getAlumnoNombre() { return alumnoNombre; }
    public void setAlumnoNombre(String alumnoNombre) { this.alumnoNombre = alumnoNombre; }
    
    public String getCursoNombre() { return cursoNombre; }
    public void setCursoNombre(String cursoNombre) { this.cursoNombre = cursoNombre; }
    
    public String getJustificadorNombre() { return justificadorNombre; }
    public void setJustificadorNombre(String justificadorNombre) { 
        this.justificadorNombre = justificadorNombre; 
    }
    
    public String getAprobadorNombre() { return aprobadorNombre; }
    public void setAprobadorNombre(String aprobadorNombre) { 
        this.aprobadorNombre = aprobadorNombre; 
    }
    
    public String getFechaAsistencia() { return fechaAsistencia; }
    public void setFechaAsistencia(String fechaAsistencia) { 
        this.fechaAsistencia = fechaAsistencia; 
    }
    
    /**
     * Verifica si la justificación está pendiente
     */
    public boolean isPendiente() {
        return estado == EstadoJustificacion.PENDIENTE;
    }
    
    /**
     * Verifica si la justificación fue aprobada
     */
    public boolean isAprobada() {
        return estado == EstadoJustificacion.APROBADO;
    }
    
    /**
     * Verifica si tiene documento adjunto
     */
    public boolean tieneDocumento() {
        return documentoAdjunto != null && !documentoAdjunto.isEmpty();
    }
    
    /**
     * Obtiene el tipo de archivo del documento
     */
    public String getTipoArchivo() {
        if (documentoAdjunto == null) return "";
        String ext = documentoAdjunto.substring(documentoAdjunto.lastIndexOf(".") + 1).toLowerCase();
        switch (ext) {
            case "pdf": return "PDF";
            case "jpg":
            case "jpeg":
            case "png": return "Imagen";
            default: return "Archivo";
        }
    }
}