/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelo;

import java.util.Date;

public class Justificacion {
    private int id;
    private int asistenciaId;
    private String tipoJustificacion; // ENFERMEDAD, EMERGENCIA_FAMILIAR, CITA_MEDICA, OTRO
    private String descripcion;
    private String documentoAdjunto;
    private int justificadoPor;
    private Date fechaJustificacion;
    private String estado; // PENDIENTE, APROBADO, RECHAZADO
    private Integer aprobadoPor;
    private Date fechaAprobacion;
    private String observacionesAprobacion;
    private boolean activo;
    
    // Campos adicionales para mostrar en vistas
    private String alumnoNombre;
    private String cursoNombre;
    private String fecha;
    private String horaClase;
    private String padreNombre;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getAsistenciaId() { return asistenciaId; }
    public void setAsistenciaId(int asistenciaId) { this.asistenciaId = asistenciaId; }

    public String getTipoJustificacion() { return tipoJustificacion; }
    public void setTipoJustificacion(String tipoJustificacion) { this.tipoJustificacion = tipoJustificacion; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public String getDocumentoAdjunto() { return documentoAdjunto; }
    public void setDocumentoAdjunto(String documentoAdjunto) { this.documentoAdjunto = documentoAdjunto; }

    public int getJustificadoPor() { return justificadoPor; }
    public void setJustificadoPor(int justificadoPor) { this.justificadoPor = justificadoPor; }

    public Date getFechaJustificacion() { return fechaJustificacion; }
    public void setFechaJustificacion(Date fechaJustificacion) { this.fechaJustificacion = fechaJustificacion; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    public Integer getAprobadoPor() { return aprobadoPor; }
    public void setAprobadoPor(Integer aprobadoPor) { this.aprobadoPor = aprobadoPor; }

    public Date getFechaAprobacion() { return fechaAprobacion; }
    public void setFechaAprobacion(Date fechaAprobacion) { this.fechaAprobacion = fechaAprobacion; }

    public String getObservacionesAprobacion() { return observacionesAprobacion; }
    public void setObservacionesAprobacion(String observacionesAprobacion) { this.observacionesAprobacion = observacionesAprobacion; }

    public boolean isActivo() { return activo; }
    public void setActivo(boolean activo) { this.activo = activo; }

    public String getAlumnoNombre() { return alumnoNombre; }
    public void setAlumnoNombre(String alumnoNombre) { this.alumnoNombre = alumnoNombre; }

    public String getCursoNombre() { return cursoNombre; }
    public void setCursoNombre(String cursoNombre) { this.cursoNombre = cursoNombre; }

    public String getFecha() { return fecha; }
    public void setFecha(String fecha) { this.fecha = fecha; }

    public String getHoraClase() { return horaClase; }
    public void setHoraClase(String horaClase) { this.horaClase = horaClase; }

    public String getPadreNombre() { return padreNombre; }
    public void setPadreNombre(String padreNombre) { this.padreNombre = padreNombre; }
}