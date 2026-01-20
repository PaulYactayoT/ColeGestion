package modelo;

/**
 * Clase modelo que representa un curso académico en el sistema.
 * Corresponde a la tabla 'curso' de la base de datos.
 * 
 * Un curso está asociado a un grado específico y un profesor responsable.
 * Puede tener múltiples materias asociadas a través de la tabla curso_materia.
 * 
 * @author Tu Nombre
 */
public class Curso {
    // Campos principales de la tabla curso
    private int id;
    private String nombre;
    private int gradoId;
    private int profesorId;
    private int creditos;
    private String area; // Área curricular (Ciencia, Humanidades, Tecnología, etc.)
    private boolean activo;
    
    // Campos adicionales para vistas y reportes (obtenidos con JOINs)
    private String gradoNombre;
    private String profesorNombre;
    private String nivel; // INICIAL, PRIMARIA, SECUNDARIA
    
    // Campos estadísticos
    private int cantidadAlumnos;
    private int cantidadTareas;
    private int cantidadHorarios;
    
    // Constructores
    
    /**
     * Constructor vacío
     */
    public Curso() {
        this.activo = true; // Por defecto activo
    }
    
    /**
     * Constructor con parámetros principales
     */
    public Curso(String nombre, int gradoId, int profesorId, int creditos) {
        this.nombre = nombre;
        this.gradoId = gradoId;
        this.profesorId = profesorId;
        this.creditos = creditos;
        this.activo = true;
    }
    
    /**
     * Constructor con parámetros incluyendo área
     */
    public Curso(String nombre, int gradoId, int profesorId, int creditos, String area) {
        this.nombre = nombre;
        this.gradoId = gradoId;
        this.profesorId = profesorId;
        this.creditos = creditos;
        this.area = area;
        this.activo = true;
    }
    
    /**
     * Constructor completo
     */
    public Curso(int id, String nombre, int gradoId, int profesorId, int creditos, String area, boolean activo) {
        this.id = id;
        this.nombre = nombre;
        this.gradoId = gradoId;
        this.profesorId = profesorId;
        this.creditos = creditos;
        this.area = area;
        this.activo = activo;
    }
    
    // Getters y Setters
    
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public String getNombre() {
        return nombre;
    }
    
    public void setNombre(String nombre) {
        this.nombre = nombre;
    }
    
    public int getGradoId() {
        return gradoId;
    }
    
    public void setGradoId(int gradoId) {
        this.gradoId = gradoId;
    }
    
    public int getProfesorId() {
        return profesorId;
    }
    
    public void setProfesorId(int profesorId) {
        this.profesorId = profesorId;
    }
    
    public int getCreditos() {
        return creditos;
    }
    
    public void setCreditos(int creditos) {
        this.creditos = creditos;
    }
    
    public String getArea() {
        return area;
    }
    
    public void setArea(String area) {
        this.area = area;
    }
    
    public boolean isActivo() {
        return activo;
    }
    
    public void setActivo(boolean activo) {
        this.activo = activo;
    }
    
    // Getters y Setters de campos adicionales
    
    public String getGradoNombre() {
        return gradoNombre;
    }
    
    public void setGradoNombre(String gradoNombre) {
        this.gradoNombre = gradoNombre;
    }
    
    public String getProfesorNombre() {
        return profesorNombre;
    }
    
    public void setProfesorNombre(String profesorNombre) {
        this.profesorNombre = profesorNombre;
    }
    
    public String getNivel() {
        return nivel;
    }
    
    public void setNivel(String nivel) {
        this.nivel = nivel;
    }
    
    // Getters y Setters de campos estadísticos
    
    public int getCantidadAlumnos() {
        return cantidadAlumnos;
    }
    
    public void setCantidadAlumnos(int cantidadAlumnos) {
        this.cantidadAlumnos = cantidadAlumnos;
    }
    
    public int getCantidadTareas() {
        return cantidadTareas;
    }
    
    public void setCantidadTareas(int cantidadTareas) {
        this.cantidadTareas = cantidadTareas;
    }
    
    public int getCantidadHorarios() {
        return cantidadHorarios;
    }
    
    public void setCantidadHorarios(int cantidadHorarios) {
        this.cantidadHorarios = cantidadHorarios;
    }
    
    // Métodos auxiliares
    
    /**
     * Retorna el nombre completo del curso con su grado
     * Ejemplo: "Algebra - 5to SECUNDARIA"
     */
    public String getNombreCompleto() {
        StringBuilder sb = new StringBuilder();
        sb.append(nombre != null ? nombre : "");
        
        if (gradoNombre != null && nivel != null) {
            sb.append(" - ").append(gradoNombre).append(" ").append(nivel);
        } else if (gradoNombre != null) {
            sb.append(" - ").append(gradoNombre);
        }
        
        return sb.toString();
    }
    
    /**
     * Retorna información completa del curso para mostrar
     */
    public String getInformacionCompleta() {
        StringBuilder info = new StringBuilder();
        info.append(getNombreCompleto());
        
        if (profesorNombre != null) {
            info.append(" - Prof. ").append(profesorNombre);
        }
        
        if (area != null) {
            info.append(" (").append(area).append(")");
        }
        
        if (creditos > 0) {
            info.append(" - ").append(creditos).append(" crédito");
            if (creditos != 1) info.append("s");
        }
        
        return info.toString();
    }
    
    /**
     * Retorna el nombre del curso con el profesor
     */
    public String getNombreConProfesor() {
        if (profesorNombre != null) {
            return nombre + " - Prof. " + profesorNombre;
        }
        return nombre;
    }
    
    /**
     * Retorna información estadística del curso
     */
    public String getInformacionEstadistica() {
        StringBuilder info = new StringBuilder();
        info.append(getNombreCompleto());
        
        if (cantidadAlumnos > 0) {
            info.append(" - ").append(cantidadAlumnos).append(" alumno");
            if (cantidadAlumnos != 1) info.append("s");
        }
        
        if (cantidadTareas > 0) {
            info.append(" - ").append(cantidadTareas).append(" tarea");
            if (cantidadTareas != 1) info.append("s");
        }
        
        if (cantidadHorarios > 0) {
            info.append(" - ").append(cantidadHorarios).append(" horario");
            if (cantidadHorarios != 1) info.append("s");
        }
        
        return info.toString();
    }
    
    /**
     * Valida si el curso tiene todos los campos requeridos
     */
    public boolean isValido() {
        return nombre != null && !nombre.trim().isEmpty() &&
               gradoId > 0 &&
               profesorId > 0 &&
               creditos >= 0;
    }
    
    /**
     * Verifica si el curso es de nivel inicial
     */
    public boolean esInicial() {
        return nivel != null && nivel.equalsIgnoreCase("INICIAL");
    }
    
    /**
     * Verifica si el curso es de nivel primaria
     */
    public boolean esPrimaria() {
        return nivel != null && nivel.equalsIgnoreCase("PRIMARIA");
    }
    
    /**
     * Verifica si el curso es de nivel secundaria
     */
    public boolean esSecundaria() {
        return nivel != null && nivel.equalsIgnoreCase("SECUNDARIA");
    }
    
    /**
     * Verifica si el curso es del área de ciencias
     */
    public boolean esAreaCiencia() {
        return area != null && area.equalsIgnoreCase("Ciencia");
    }
    
    /**
     * Verifica si el curso es del área de humanidades
     */
    public boolean esAreaHumanidades() {
        return area != null && area.equalsIgnoreCase("Humanidades");
    }
    
    /**
     * Verifica si el curso es del área de tecnología
     */
    public boolean esAreaTecnologia() {
        return area != null && (area.equalsIgnoreCase("Tecnología") || 
                                 area.equalsIgnoreCase("Tecnologia"));
    }
    
    /**
     * Obtiene el color del área para UI
     */
    public String getColorArea() {
        if (area == null) return "#CCCCCC";
        
        switch (area.toLowerCase()) {
            case "ciencia":
                return "#3498DB"; // Azul
            case "humanidades":
                return "#E74C3C"; // Rojo
            case "tecnología":
            case "tecnologia":
                return "#9B59B6"; // Púrpura
            case "educación":
            case "educacion":
                return "#2ECC71"; // Verde
            case "valores":
                return "#F39C12"; // Naranja
            case "idiomas":
                return "#1ABC9C"; // Turquesa
            default:
                return "#95A5A6"; // Gris
        }
    }
    
    /**
     * Obtiene el ícono del área (nombre de ícono para Font Awesome u otros)
     */
    public String getIconoArea() {
        if (area == null) return "book";
        
        switch (area.toLowerCase()) {
            case "ciencia":
                return "flask";
            case "humanidades":
                return "book-open";
            case "tecnología":
            case "tecnologia":
                return "laptop";
            case "educación":
            case "educacion":
                return "graduation-cap";
            case "valores":
                return "heart";
            case "idiomas":
                return "language";
            default:
                return "book";
        }
    }
    
    /**
     * Retorna información detallada del curso
     */
    public String getInformacionDetallada() {
        StringBuilder info = new StringBuilder();
        info.append("=== INFORMACIÓN DEL CURSO ===\n");
        info.append("Nombre: ").append(nombre).append("\n");
        info.append("Grado: ").append(gradoNombre != null ? gradoNombre : "N/A").append("\n");
        info.append("Nivel: ").append(nivel != null ? nivel : "N/A").append("\n");
        info.append("Profesor: ").append(profesorNombre != null ? profesorNombre : "N/A").append("\n");
        info.append("Área: ").append(area != null ? area : "N/A").append("\n");
        info.append("Créditos: ").append(creditos).append("\n");
        info.append("Estado: ").append(activo ? "Activo" : "Inactivo").append("\n");
        
        if (cantidadAlumnos > 0) {
            info.append("Alumnos inscritos: ").append(cantidadAlumnos).append("\n");
        }
        if (cantidadTareas > 0) {
            info.append("Tareas asignadas: ").append(cantidadTareas).append("\n");
        }
        if (cantidadHorarios > 0) {
            info.append("Horarios programados: ").append(cantidadHorarios).append("\n");
        }
        
        return info.toString();
    }
    
    /**
     * Retorna una descripción corta del curso
     */
    public String getDescripcionCorta() {
        return String.format("%s - %s (%d créditos)", 
                           nombre, 
                           area != null ? area : "Sin área", 
                           creditos);
    }
    
    /**
     * Compara dos cursos por nombre
     */
    public int compareTo(Curso otro) {
        if (otro == null) return 1;
        return this.nombre.compareToIgnoreCase(otro.nombre);
    }
    
    /**
     * ToString mejorado
     */
    @Override
    public String toString() {
        return getNombreCompleto();
    }
    
    /**
     * ToString detallado para debugging
     */
    public String toStringDetallado() {
        return "Curso{" +
                "id=" + id +
                ", nombre='" + nombre + '\'' +
                ", gradoId=" + gradoId +
                ", gradoNombre='" + gradoNombre + '\'' +
                ", nivel='" + nivel + '\'' +
                ", profesorId=" + profesorId +
                ", profesorNombre='" + profesorNombre + '\'' +
                ", creditos=" + creditos +
                ", area='" + area + '\'' +
                ", activo=" + activo +
                '}';
    }
    
    /**
     * Método equals personalizado
     */
    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null || getClass() != obj.getClass()) return false;
        
        Curso curso = (Curso) obj;
        return id == curso.id;
    }
    
    /**
     * Método hashCode personalizado
     */
    @Override
    public int hashCode() {
        return Integer.hashCode(id);
    }
    
    /**
     * Clona el curso (copia superficial)
     */
    public Curso clonar() {
        Curso copia = new Curso();
        copia.setId(this.id);
        copia.setNombre(this.nombre);
        copia.setGradoId(this.gradoId);
        copia.setProfesorId(this.profesorId);
        copia.setCreditos(this.creditos);
        copia.setArea(this.area);
        copia.setActivo(this.activo);
        copia.setGradoNombre(this.gradoNombre);
        copia.setProfesorNombre(this.profesorNombre);
        copia.setNivel(this.nivel);
        return copia;
    }
}