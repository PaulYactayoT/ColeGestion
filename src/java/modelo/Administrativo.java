/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelo;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * Clase Administrativo - Representa al personal administrativo de la institución
 * Incluye borrado lógico con campos 'activo' y 'eliminado'
 */
public class Administrativo {
    
    // Identificadores
    private int id;
    private int personaId;
    private String codigoAdministrativo;
    
    // Información laboral
    private String cargo;
    private String departamento;
    private LocalDate fechaIngreso;
    private String estado; // ACTIVO, INACTIVO, LICENCIA, JUBILADO
    
    // Datos de la persona relacionada
    private String nombres;
    private String apellidos;
    private String tipoDocumento;
    private String numeroDocumento;
    private String sexo;
    private LocalDate fechaNacimiento;
    private String direccion;
    private String telefono;
    private String correo;
    private String foto;
    
    // Control de estado y auditoría
    private LocalDateTime fechaRegistro;
    private boolean activo;
    private boolean eliminado;
    
    // Constructor vacío
    public Administrativo() {
        this.activo = true;
        this.eliminado = false;
        this.estado = "ACTIVO";
    }
    
    // Constructor completo
    public Administrativo(int id, int personaId, String cargo, String codigoAdministrativo,
                         LocalDate fechaIngreso, String departamento, String estado,
                         LocalDateTime fechaRegistro, boolean activo, boolean eliminado) {
        this.id = id;
        this.personaId = personaId;
        this.cargo = cargo;
        this.codigoAdministrativo = codigoAdministrativo;
        this.fechaIngreso = fechaIngreso;
        this.departamento = departamento;
        this.estado = estado;
        this.fechaRegistro = fechaRegistro;
        this.activo = activo;
        this.eliminado = eliminado;
    }

    // ============================================================
    // GETTERS Y SETTERS
    // ============================================================
    
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

    public String getCodigoAdministrativo() {
        return codigoAdministrativo;
    }

    public void setCodigoAdministrativo(String codigoAdministrativo) {
        this.codigoAdministrativo = codigoAdministrativo;
    }

    public String getCargo() {
        return cargo;
    }

    public void setCargo(String cargo) {
        this.cargo = cargo;
    }

    public String getDepartamento() {
        return departamento;
    }

    public void setDepartamento(String departamento) {
        this.departamento = departamento;
    }

    public LocalDate getFechaIngreso() {
        return fechaIngreso;
    }

    public void setFechaIngreso(LocalDate fechaIngreso) {
        this.fechaIngreso = fechaIngreso;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
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

    public String getTipoDocumento() {
        return tipoDocumento;
    }

    public void setTipoDocumento(String tipoDocumento) {
        this.tipoDocumento = tipoDocumento;
    }

    public String getNumeroDocumento() {
        return numeroDocumento;
    }

    public void setNumeroDocumento(String numeroDocumento) {
        this.numeroDocumento = numeroDocumento;
    }

    public String getSexo() {
        return sexo;
    }

    public void setSexo(String sexo) {
        this.sexo = sexo;
    }

    public LocalDate getFechaNacimiento() {
        return fechaNacimiento;
    }

    public void setFechaNacimiento(LocalDate fechaNacimiento) {
        this.fechaNacimiento = fechaNacimiento;
    }

    public String getDireccion() {
        return direccion;
    }

    public void setDireccion(String direccion) {
        this.direccion = direccion;
    }

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }

    public String getCorreo() {
        return correo;
    }

    public void setCorreo(String correo) {
        this.correo = correo;
    }

    public String getFoto() {
        return foto;
    }

    public void setFoto(String foto) {
        this.foto = foto;
    }

    public LocalDateTime getFechaRegistro() {
        return fechaRegistro;
    }

    public void setFechaRegistro(LocalDateTime fechaRegistro) {
        this.fechaRegistro = fechaRegistro;
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

    // ============================================================
    // MÉTODOS AUXILIARES
    // ============================================================
    
    /**
     * Retorna el nombre completo del administrativo
     */
    public String getNombreCompleto() {
        return (nombres != null ? nombres : "") + " " + (apellidos != null ? apellidos : "");
    }
    
    /**
     * Retorna el badge de estado con color
     */
    public String getEstadoBadge() {
        switch (estado != null ? estado : "ACTIVO") {
            case "ACTIVO":
                return "<span class='badge bg-success'>Activo</span>";
            case "INACTIVO":
                return "<span class='badge bg-secondary'>Inactivo</span>";
            case "LICENCIA":
                return "<span class='badge bg-warning'>Licencia</span>";
            case "JUBILADO":
                return "<span class='badge bg-info'>Jubilado</span>";
            default:
                return "<span class='badge bg-secondary'>Desconocido</span>";
        }
    }
    
    @Override
    public String toString() {
        return "Administrativo{" +
                "id=" + id +
                ", personaId=" + personaId +
                ", codigoAdministrativo='" + codigoAdministrativo + '\'' +
                ", cargo='" + cargo + '\'' +
                ", departamento='" + departamento + '\'' +
                ", estado='" + estado + '\'' +
                ", nombres='" + nombres + '\'' +
                ", apellidos='" + apellidos + '\'' +
                ", activo=" + activo +
                ", eliminado=" + eliminado +
                '}';
    }
}