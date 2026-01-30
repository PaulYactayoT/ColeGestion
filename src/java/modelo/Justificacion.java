package modelo;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Clase que representa una Justificación de asistencia
 * Permite a los padres justificar ausencias con documentos adjuntos
 */
public class Justificacion {
    
    // Enum para tipos de justificación
    public enum TipoJustificacion {
        ENFERMEDAD("Enfermedad"),
        EMERGENCIA_FAMILIAR("Emergencia Familiar"),
        CITA_MEDICA("Cita Médica"),
        OTRO("Otro");
        
        private final String descripcion;
        
        TipoJustificacion(String descripcion) {
            this.descripcion = descripcion;
        }
        
        public String getDescripcion() {
            return descripcion;
        }
        
        public static TipoJustificacion fromString(String text) {
            for (TipoJustificacion t : TipoJustificacion.values()) {
                if (t.name().equalsIgnoreCase(text)) {
                    return t;
                }
            }
            return OTRO;
        }
    }
    
    // Enum para estados de justificación
    public enum EstadoJustificacion {
        PENDIENTE("Pendiente de revisión"),
        APROBADO("Aprobado"),
        RECHAZADO("Rechazado");
        
        private final String descripcion;
        
        EstadoJustificacion(String descripcion) {
            this.descripcion = descripcion;
        }
        
        public String getDescripcion() {
            return descripcion;
        }
        
        public static EstadoJustificacion fromString(String text) {
            for (EstadoJustificacion e : EstadoJustificacion.values()) {
                if (e.name().equalsIgnoreCase(text)) {
                    return e;
                }
            }
            return PENDIENTE;
        }
    }
    
    // Campos principales
    private int id;
    private int asistenciaId;
    private TipoJustificacion tipoJustificacion;
    private String descripcion;
    private String documentoAdjunto;
    private String nombreArchivo;
    private String tipoArchivo; // PDF, JPG, PNG
    private int justificadoPor;
    private LocalDateTime fechaJustificacion;
    private EstadoJustificacion estado;
    private int aprobadoPor;
    private LocalDateTime fechaAprobacion;
    private String observacionesAprobacion;
    private boolean activo;
    
    // Campos adicionales para mostrar información relacionada
    private String alumnoNombre;
    private String cursoNombre;
    private String justificadorNombre;
    private String aprobadorNombre;
    private String fechaAsistencia;
    
    // Constructores
    public Justificacion() {
        this.activo = true;
        this.estado = EstadoJustificacion.PENDIENTE;
        this.fechaJustificacion = LocalDateTime.now();
    }
    
    public Justificacion(int asistenciaId, TipoJustificacion tipo, String descripcion, 
                         String documentoAdjunto, int justificadoPor) {
        this();
        this.asistenciaId = asistenciaId;
        this.tipoJustificacion = tipo;
        this.descripcion = descripcion;
        this.documentoAdjunto = documentoAdjunto;
        this.justificadoPor = justificadoPor;
    }
    
    // Getters y Setters
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public int getAsistenciaId() {
        return asistenciaId;
    }
    
    public void setAsistenciaId(int asistenciaId) {
        this.asistenciaId = asistenciaId;
    }
    
    public TipoJustificacion getTipoJustificacion() {
        return tipoJustificacion;
    }
    
    public void setTipoJustificacion(TipoJustificacion tipoJustificacion) {
        this.tipoJustificacion = tipoJustificacion;
    }
    
    public void setTipoJustificacionFromString(String tipo) {
        this.tipoJustificacion = TipoJustificacion.fromString(tipo);
    }
    
    public String getTipoJustificacionString() {
        return tipoJustificacion != null ? tipoJustificacion.name() : "";
    }
    
    public String getDescripcion() {
        return descripcion;
    }
    
    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }
    
    public String getDocumentoAdjunto() {
        return documentoAdjunto;
    }
    
    public void setDocumentoAdjunto(String documentoAdjunto) {
        this.documentoAdjunto = documentoAdjunto;
        // Extraer nombre y tipo de archivo
        if (documentoAdjunto != null && !documentoAdjunto.isEmpty()) {
            String[] parts = documentoAdjunto.split("/");
            this.nombreArchivo = parts[parts.length - 1];
            String[] extParts = nombreArchivo.split("\\.");
            if (extParts.length > 1) {
                this.tipoArchivo = extParts[extParts.length - 1].toUpperCase();
            }
        }
    }
    
    public String getNombreArchivo() {
        return nombreArchivo;
    }
    
    public void setNombreArchivo(String nombreArchivo) {
        this.nombreArchivo = nombreArchivo;
    }
    
    public String getTipoArchivo() {
        return tipoArchivo;
    }
    
    public void setTipoArchivo(String tipoArchivo) {
        this.tipoArchivo = tipoArchivo;
    }
    
    public int getJustificadoPor() {
        return justificadoPor;
    }
    
    public void setJustificadoPor(int justificadoPor) {
        this.justificadoPor = justificadoPor;
    }
    
    public LocalDateTime getFechaJustificacion() {
        return fechaJustificacion;
    }
    
    public void setFechaJustificacion(LocalDateTime fechaJustificacion) {
        this.fechaJustificacion = fechaJustificacion;
    }
    
    public String getFechaJustificacionFormateada() {
        return fechaJustificacion != null ? 
               fechaJustificacion.format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")) : "";
    }
    
    public EstadoJustificacion getEstado() {
        return estado;
    }
    
    public void setEstado(EstadoJustificacion estado) {
        this.estado = estado;
    }
    
    public void setEstadoFromString(String estado) {
        this.estado = EstadoJustificacion.fromString(estado);
    }
    
    public String getEstadoString() {
        return estado != null ? estado.name() : "";
    }
    
    public int getAprobadoPor() {
        return aprobadoPor;
    }
    
    public void setAprobadoPor(int aprobadoPor) {
        this.aprobadoPor = aprobadoPor;
    }
    
    public LocalDateTime getFechaAprobacion() {
        return fechaAprobacion;
    }
    
    public void setFechaAprobacion(LocalDateTime fechaAprobacion) {
        this.fechaAprobacion = fechaAprobacion;
    }
    
    public String getFechaAprobacionFormateada() {
        return fechaAprobacion != null ? 
               fechaAprobacion.format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")) : "";
    }
    
    public String getObservacionesAprobacion() {
        return observacionesAprobacion;
    }
    
    public void setObservacionesAprobacion(String observacionesAprobacion) {
        this.observacionesAprobacion = observacionesAprobacion;
    }
    
    public boolean isActivo() {
        return activo;
    }
    
    public void setActivo(boolean activo) {
        this.activo = activo;
    }
    
    // Campos adicionales
    public String getAlumnoNombre() {
        return alumnoNombre;
    }
    
    public void setAlumnoNombre(String alumnoNombre) {
        this.alumnoNombre = alumnoNombre;
    }
    
    public String getCursoNombre() {
        return cursoNombre;
    }
    
    public void setCursoNombre(String cursoNombre) {
        this.cursoNombre = cursoNombre;
    }
    
    public String getJustificadorNombre() {
        return justificadorNombre;
    }
    
    public void setJustificadorNombre(String justificadorNombre) {
        this.justificadorNombre = justificadorNombre;
    }
    
    public String getAprobadorNombre() {
        return aprobadorNombre;
    }
    
    public void setAprobadorNombre(String aprobadorNombre) {
        this.aprobadorNombre = aprobadorNombre;
    }
    
    public String getFechaAsistencia() {
        return fechaAsistencia;
    }
    
    public void setFechaAsistencia(String fechaAsistencia) {
        this.fechaAsistencia = fechaAsistencia;
    }
    
    // Métodos de utilidad
    
    /**
     * Verifica si la justificación está pendiente
     */
    public boolean esPendiente() {
        return estado == EstadoJustificacion.PENDIENTE;
    }
    
    /**
     * Verifica si la justificación fue aprobada
     */
    public boolean esAprobado() {
        return estado == EstadoJustificacion.APROBADO;
    }
    
    /**
     * Verifica si la justificación fue rechazada
     */
    public boolean esRechazado() {
        return estado == EstadoJustificacion.RECHAZADO;
    }
    
    /**
     * Verifica si tiene documento adjunto
     */
    public boolean tieneDocumento() {
        return documentoAdjunto != null && !documentoAdjunto.isEmpty();
    }
    
    /**
     * Verifica si el documento es una imagen
     */
    public boolean esImagen() {
        if (tipoArchivo == null) return false;
        return tipoArchivo.equalsIgnoreCase("JPG") || 
               tipoArchivo.equalsIgnoreCase("JPEG") || 
               tipoArchivo.equalsIgnoreCase("PNG") ||
               tipoArchivo.equalsIgnoreCase("GIF");
    }
    
    /**
     * Verifica si el documento es un PDF
     */
    public boolean esPDF() {
        return tipoArchivo != null && tipoArchivo.equalsIgnoreCase("PDF");
    }
    
    /**
     * Obtiene el color CSS según el estado
     */
    public String getColorEstado() {
        if (estado == null) return "gray";
        switch (estado) {
            case PENDIENTE:
                return "orange";
            case APROBADO:
                return "green";
            case RECHAZADO:
                return "red";
            default:
                return "gray";
        }
    }
    
    /**
     * Obtiene el ícono según el estado
     */
    public String getIconoEstado() {
        if (estado == null) return "⏳";
        switch (estado) {
            case PENDIENTE:
                return "⏳";
            case APROBADO:
                return "✓";
            case RECHAZADO:
                return "✗";
            default:
                return "?";
        }
    }
    
    @Override
    public String toString() {
        return String.format(
            "Justificacion{id=%d, asistenciaId=%d, tipo=%s, estado=%s, fecha=%s}",
            id, asistenciaId, 
            tipoJustificacion != null ? tipoJustificacion.getDescripcion() : "N/A",
            estado != null ? estado.getDescripcion() : "N/A",
            getFechaJustificacionFormateada()
        );
    }
}