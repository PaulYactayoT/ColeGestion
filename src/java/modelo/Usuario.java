package modelo;

import java.util.Date;

public class Usuario {
    private int id;
    private int personaId;
    private String username;
    private String password;
    private String rol;
    private int intentosFallidos;
    private Date fechaBloqueo;
    private Date ultimaConexion;
    private Date fechaRegistro;
    private boolean activo;
    private boolean eliminado;

    // Constructores
    public Usuario() {}

    public Usuario(int id, int personaId, String username, String password, String rol) {
        this.id = id;
        this.personaId = personaId;
        this.username = username;
        this.password = password;
        this.rol = rol;
        this.activo = true;
        this.eliminado = false;
        this.intentosFallidos = 0;
        this.fechaRegistro = new Date();
    }

    // Constructor completo para recuperación de base de datos
    public Usuario(int id, int personaId, String username, String password, String rol,
                   int intentosFallidos, Date fechaBloqueo, Date ultimaConexion,
                   Date fechaRegistro, boolean activo, boolean eliminado) {
        this.id = id;
        this.personaId = personaId;
        this.username = username;
        this.password = password;
        this.rol = rol;
        this.intentosFallidos = intentosFallidos;
        this.fechaBloqueo = fechaBloqueo;
        this.ultimaConexion = ultimaConexion;
        this.fechaRegistro = fechaRegistro;
        this.activo = activo;
        this.eliminado = eliminado;
    }

    // Getters y Setters
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

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getRol() {
        return rol;
    }

    public void setRol(String rol) {
        this.rol = rol;
    }

    public int getIntentosFallidos() {
        return intentosFallidos;
    }

    public void setIntentosFallidos(int intentosFallidos) {
        this.intentosFallidos = intentosFallidos;
    }

    public Date getFechaBloqueo() {
        return fechaBloqueo;
    }

    public void setFechaBloqueo(Date fechaBloqueo) {
        this.fechaBloqueo = fechaBloqueo;
    }

    public Date getUltimaConexion() {
        return ultimaConexion;
    }

    public void setUltimaConexion(Date ultimaConexion) {
        this.ultimaConexion = ultimaConexion;
    }

    public Date getFechaRegistro() {
        return fechaRegistro;
    }

    public void setFechaRegistro(Date fechaRegistro) {
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

    // Métodos auxiliares
    public void incrementarIntentosFallidos() {
        this.intentosFallidos++;
    }

    public void resetearIntentosFallidos() {
        this.intentosFallidos = 0;
    }

    public void bloquearUsuario() {
        this.fechaBloqueo = new Date();
        this.activo = false;
    }

    public void desbloquearUsuario() {
        this.fechaBloqueo = null;
        this.activo = true;
        resetearIntentosFallidos();
    }

    public void registrarConexion() {
        this.ultimaConexion = new Date();
    }

    public boolean necesitaResetearPassword() {
        // Lógica para determinar si necesita resetear contraseña
        // Por ejemplo, si lleva más de 90 días sin cambiar
        if (fechaRegistro == null) return false;
        
        Date ahora = new Date();
        long diferencia = ahora.getTime() - fechaRegistro.getTime();
        long dias = diferencia / (1000 * 60 * 60 * 24);
        
        return dias > 90;
    }

    @Override
    public String toString() {
        return "Usuario{" +
                "id=" + id +
                ", personaId=" + personaId +
                ", username='" + username + '\'' +
                ", rol='" + rol + '\'' +
                ", intentosFallidos=" + intentosFallidos +
                ", activo=" + activo +
                ", eliminado=" + eliminado +
                '}';
    }
}