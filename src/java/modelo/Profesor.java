package modelo;

import java.util.Date;
import java.util.List;
import java.util.ArrayList;
import java.util.stream.Collectors;

public class Profesor {
    private int id;
    private int personaId;
    private String nombres;
    private String apellidos;
    private String correo;
    private String telefono;
    private String dni;
    private Date fechaNacimiento;
    private String direccion;
    private int areaId;
    private String areaNombre;
    private String codigoProfesor;
    private Date fechaContratacion;
    private String estado;
    private String username;
    private String rol;
    private String password; 
    private int turnoId;
    private String turnoNombre; 
    private String nivel;
    
    // Lista de disponibilidades del profesor
    // Esta lista almacenará todos los horarios disponibles del docente
    // ========================================
    private List<Disponibilidad> disponibilidades;
    
    // Constructor
    public Profesor() {
        // Inicializar la lista de disponibilidades vacía
        this.disponibilidades = new ArrayList<>();
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

    public String getCorreo() {
        return correo;
    }

    public void setCorreo(String correo) {
        this.correo = correo;
    }

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }

    public String getDni() {
        return dni;
    }

    public void setDni(String dni) {
        this.dni = dni;
    }

    public Date getFechaNacimiento() {
        return fechaNacimiento;
    }

    public void setFechaNacimiento(Date fechaNacimiento) {
        this.fechaNacimiento = fechaNacimiento;
    }

    public String getDireccion() {
        return direccion;
    }

    public void setDireccion(String direccion) {
        this.direccion = direccion;
    }

    public int getAreaId() {
        return areaId;
    }

    public void setAreaId(int areaId) {
        this.areaId = areaId;
    }

    public String getAreaNombre() {
        return areaNombre;
    }

    public void setAreaNombre(String areaNombre) {
        this.areaNombre = areaNombre;
    }

    public String getCodigoProfesor() {
        return codigoProfesor;
    }

    public void setCodigoProfesor(String codigoProfesor) {
        this.codigoProfesor = codigoProfesor;
    }

    public Date getFechaContratacion() {
        return fechaContratacion;
    }

    public void setFechaContratacion(Date fechaContratacion) {
        this.fechaContratacion = fechaContratacion;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getRol() {
        return rol;
    }

    public void setRol(String rol) {
        this.rol = rol;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
    
    public int getTurnoId() {
        return turnoId;
    }

    public void setTurnoId(int turnoId) {
        this.turnoId = turnoId;
    }
    
    public String getTurnoNombre() {
        return turnoNombre;
    }

    public void setTurnoNombre(String turnoNombre) {
        this.turnoNombre = turnoNombre;
    }

    public String getNivel() {
        return nivel;
    }

    public void setNivel(String nivel) {
        this.nivel = nivel;
    }

    /**
     * Obtiene la lista completa de disponibilidades del profesor
     * @return Lista de objetos Disponibilidad
     */
    public List<Disponibilidad> getDisponibilidades() {
        return disponibilidades;
    }

    /**
     * Establece la lista completa de disponibilidades del profesor
     * @param disponibilidades Lista de objetos Disponibilidad a asignar
     */
    public void setDisponibilidades(List<Disponibilidad> disponibilidades) {
        this.disponibilidades = disponibilidades;
    }
    
    /**
     * Agrega una disponibilidad individual a la lista
     * Útil para ir construyendo la lista de horarios uno por uno
     * @param disponibilidad Objeto Disponibilidad a agregar
     */
    public void agregarDisponibilidad(Disponibilidad disponibilidad) {
        this.disponibilidades.add(disponibilidad);
    }

    // Método auxiliar
    public String getNombreCompleto() {
        return nombres + " " + apellidos;
    }
    
    private List<ProfesorNivelArea> asignaciones;
    
    /**
     * Obtiene la lista de asignaciones de nivel-área
     */
    public List<ProfesorNivelArea> getAsignaciones() {
        if (asignaciones == null) {
            asignaciones = new ArrayList<>();
        }
        return asignaciones;
    }
    
    /**
     * Establece la lista de asignaciones
     */
    public void setAsignaciones(List<ProfesorNivelArea> asignaciones) {
        this.asignaciones = asignaciones;
    }
  
    /**
     * Agrega una asignación a la lista
     */
    public void agregarAsignacion(ProfesorNivelArea asignacion) {
        if (this.asignaciones == null) {
            this.asignaciones = new ArrayList<>();
        }
        this.asignaciones.add(asignacion);
    }
    
    /**
     * Verifica si el profesor tiene asignaciones
     */
    public boolean tieneAsignaciones() {
        return asignaciones != null && !asignaciones.isEmpty();
    }
    
    /**
     * Obtiene todas las asignaciones de un nivel específico
     */
    public List<ProfesorNivelArea> getAsignacionesPorNivel(String nivel) {
        List<ProfesorNivelArea> resultado = new ArrayList<>();
        if (asignaciones != null) {
            for (ProfesorNivelArea asig : asignaciones) {
                if (asig.getNivel().equals(nivel)) {
                    resultado.add(asig);
                }
            }
        }
        return resultado;
    }
    
   /**
    * Obtiene una lista de niveles únicos de todas las asignaciones del profesor
    * @return Lista de niveles distintos (sin duplicados)
    */
   public List<String> getNivelesDistintos() {
       if (asignaciones == null || asignaciones.isEmpty()) {
           return new ArrayList<>();
       }

       // Usar Stream para obtener niveles únicos
       return asignaciones.stream()
               .map(ProfesorNivelArea::getNivel)
               .filter(nivel -> nivel != null && !nivel.trim().isEmpty())
               .distinct()
               .collect(Collectors.toList());
   }
    
    /**
     * Obtiene todas las áreas en las que dicta el profesor (sin duplicados)
     */
    public List<Integer> getAreasDistintas() {
        List<Integer> areas = new ArrayList<>();
        if (asignaciones != null) {
            for (ProfesorNivelArea asig : asignaciones) {
                if (!areas.contains(asig.getAreaId())) {
                    areas.add(asig.getAreaId());
                }
            }
        }
        return areas;
    }
    
    /**
     * Verifica si el profesor dicta en un nivel específico
     */
    public boolean dictaEnNivel(String nivel) {
        if (asignaciones != null) {
            for (ProfesorNivelArea asig : asignaciones) {
                if (asig.getNivel().equals(nivel)) {
                    return true;
                }
            }
        }
        return false;
    }
    
    /**
     * Verifica si el profesor dicta un área específica
     */
    public boolean dictaArea(int areaId) {
        if (asignaciones != null) {
            for (ProfesorNivelArea asig : asignaciones) {
                if (asig.getAreaId() == areaId) {
                    return true;
                }
            }
        }
        return false;
    }
 
 
}   