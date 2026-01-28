/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelo;

/**
 * Clase modelo que representa un grado académico en el sistema.
 * Corresponde a la tabla 'grado' de la base de datos.
 * 
 * Niveles válidos: INICIAL, PRIMARIA, SECUNDARIA
 * 
 * @author Tu Nombre
 */
public class Grado {
    // Campos principales de la tabla grado
    private int id;
    private String nombre;
    private String nivel; // ENUM: INICIAL, PRIMARIA, SECUNDARIA
    private int orden; // Orden para visualización
    private boolean activo;
    
    // Campos adicionales para estadísticas y vistas
    private int cantidadAlumnos;
    private int cantidadCursos;
    
    // Constructores
    
    /**
     * Constructor vacío
     */
    public Grado() {
        this.activo = true; // Por defecto activo
    }
    
    /**
     * Constructor con parámetros principales
     */
    public Grado(String nombre, String nivel) {
        this.nombre = nombre;
        this.nivel = nivel;
        this.activo = true;
    }
    
    /**
     * Constructor con parámetros incluyendo orden
     */
    public Grado(String nombre, String nivel, int orden) {
        this.nombre = nombre;
        this.nivel = nivel;
        this.orden = orden;
        this.activo = true;
    }
    
    /**
     * Constructor completo
     */
    public Grado(int id, String nombre, String nivel, int orden, boolean activo) {
        this.id = id;
        this.nombre = nombre;
        this.nivel = nivel;
        this.orden = orden;
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
    
    public String getNivel() {
        return nivel;
    }
    
    public void setNivel(String nivel) {
        this.nivel = nivel;
    }
    
    public int getOrden() {
        return orden;
    }
    
    public void setOrden(int orden) {
        this.orden = orden;
    }
    
    public boolean isActivo() {
        return activo;
    }
    
    public void setActivo(boolean activo) {
        this.activo = activo;
    }
    
    // Getters y Setters de campos adicionales
    
    public int getCantidadAlumnos() {
        return cantidadAlumnos;
    }
    
    public void setCantidadAlumnos(int cantidadAlumnos) {
        this.cantidadAlumnos = cantidadAlumnos;
    }
    
    public int getCantidadCursos() {
        return cantidadCursos;
    }
    
    public void setCantidadCursos(int cantidadCursos) {
        this.cantidadCursos = cantidadCursos;
    }
    
    // Métodos auxiliares
    
    /**
     * Retorna el nombre completo del grado con su nivel
     * Ejemplo: "1ero - PRIMARIA", "3 - INICIAL"
     */
    public String getNombreCompleto() {
        if (nombre != null && nivel != null) {
            return nombre + " - " + nivel;
        }
        return nombre != null ? nombre : "";
    }
    
    /**
     * Retorna una representación en String del grado
     */
    @Override
    public String toString() {
        return getNombreCompleto();
    }
    
    /**
     * Obtiene el nombre del nivel formateado
     * Ejemplo: "Inicial", "Primaria", "Secundaria"
     */
    public String getNivelFormateado() {
        if (nivel == null) return "";
        
        switch (nivel.toUpperCase()) {
            case "INICIAL":
                return "Inicial";
            case "PRIMARIA":
                return "Primaria";
            case "SECUNDARIA":
                return "Secundaria";
            default:
                return nivel;
        }
    }
    
    /**
     * Valida si el grado tiene todos los campos requeridos
     */
    public boolean isValido() {
        return nombre != null && !nombre.trim().isEmpty() &&
               nivel != null && !nivel.trim().isEmpty() &&
               esNivelValido();
    }
    
    /**
     * Verifica si el nivel es válido según el ENUM de la BD
     */
    public boolean esNivelValido() {
        if (nivel == null) return false;
        
        String nivelUpper = nivel.toUpperCase();
        return nivelUpper.equals("INICIAL") || 
               nivelUpper.equals("PRIMARIA") || 
               nivelUpper.equals("SECUNDARIA");
    }
    
    /**
     * Retorna el rango de edades típico para este grado
     */
    public String getRangoEdades() {
        if (nivel == null || nombre == null) return "";
        
        switch (nivel.toUpperCase()) {
            case "INICIAL":
                switch (nombre) {
                    case "3": return "3 años";
                    case "4": return "4 años";
                    case "5": return "5 años";
                    default: return "3-5 años";
                }
            case "PRIMARIA":
                switch (nombre) {
                    case "1ero": return "6 años";
                    case "2do": return "7 años";
                    case "3ero": return "8 años";
                    case "4to": return "9 años";
                    case "5to": return "10 años";
                    case "6to": return "11 años";
                    default: return "6-11 años";
                }
            case "SECUNDARIA":
                switch (nombre) {
                    case "1ero": return "12 años";
                    case "2do": return "13 años";
                    case "3ero": return "14 años";
                    case "4to": return "15 años";
                    case "5to": return "16 años";
                    default: return "12-16 años";
                }
            default:
                return "";
        }
    }
    
    /**
     * Obtiene información estadística del grado
     */
    public String getInformacionEstadistica() {
        StringBuilder info = new StringBuilder();
        info.append(getNombreCompleto());
        
        if (cantidadAlumnos > 0) {
            info.append(" - ").append(cantidadAlumnos).append(" alumno");
            if (cantidadAlumnos != 1) info.append("s");
        }
        
        if (cantidadCursos > 0) {
            info.append(" - ").append(cantidadCursos).append(" curso");
            if (cantidadCursos != 1) info.append("s");
        }
        
        return info.toString();
    }
    
    /**
     * Compara dos grados por su orden
     */
    public int compareTo(Grado otro) {
        if (otro == null) return 1;
        return Integer.compare(this.orden, otro.orden);
    }
    
    /**
     * Verifica si este grado es de nivel inicial
     */
    public boolean esInicial() {
        return nivel != null && nivel.equalsIgnoreCase("INICIAL");
    }
    
    /**
     * Verifica si este grado es de nivel primaria
     */
    public boolean esPrimaria() {
        return nivel != null && nivel.equalsIgnoreCase("PRIMARIA");
    }
    
    /**
     * Verifica si este grado es de nivel secundaria
     */
    public boolean esSecundaria() {
        return nivel != null && nivel.equalsIgnoreCase("SECUNDARIA");
    }
    
    /**
     * Obtiene el color representativo del nivel (útil para UI)
     */
    public String getColorNivel() {
        if (nivel == null) return "#CCCCCC";
        
        switch (nivel.toUpperCase()) {
            case "INICIAL":
                return "#FF6B6B"; // Rojo suave
            case "PRIMARIA":
                return "#4ECDC4"; // Turquesa
            case "SECUNDARIA":
                return "#45B7D1"; // Azul
            default:
                return "#CCCCCC"; // Gris
        }
    }
    
    /**
     * Retorna información detallada del grado
     */
    public String getInformacionDetallada() {
        StringBuilder info = new StringBuilder();
        info.append("Grado: ").append(getNombreCompleto()).append("\n");
        info.append("Nivel: ").append(getNivelFormateado()).append("\n");
        info.append("Orden: ").append(orden).append("\n");
        info.append("Edades: ").append(getRangoEdades()).append("\n");
        info.append("Estado: ").append(activo ? "Activo" : "Inactivo");
        
        if (cantidadAlumnos > 0) {
            info.append("\nAlumnos: ").append(cantidadAlumnos);
        }
        if (cantidadCursos > 0) {
            info.append("\nCursos: ").append(cantidadCursos);
        }
        
        return info.toString();
    }
    
    /**
     * Método equals personalizado
     */
    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null || getClass() != obj.getClass()) return false;
        
        Grado grado = (Grado) obj;
        return id == grado.id;
    }
    
    /**
     * Método hashCode personalizado
     */
    @Override
    public int hashCode() {
        return Integer.hashCode(id);
    }
}