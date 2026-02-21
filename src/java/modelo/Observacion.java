package modelo;

/**
 * ENTIDAD OBSERVACION - VERSIÓN COMPLETA PARA HU-15
 * Esta clase debe tener estos campos exactos para que el DAO y Servlet funcionen.
 */
public class Observacion {
    private int id;
    private int cursoId;
    private int alumnoId;
    private String texto;
    
    // --- ESTOS SON LOS CAMPOS QUE TE FALTAN ---
    private String tipo;           // Para POSITIVA/NEGATIVA
    private String rutaEvidencia;  // Para el nombre del archivo
    
    // Extras para mostrar nombres en las tablas
    private String cursoNombre;
    private String alumnoNombre;

    // Constructor vacío
    public Observacion() {
    }

    // GETTERS Y SETTERS (Indispensables para el Build)
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getCursoId() { return cursoId; }
    public void setCursoId(int cursoId) { this.cursoId = cursoId; }

    public int getAlumnoId() { return alumnoId; }
    public void setAlumnoId(int alumnoId) { this.alumnoId = alumnoId; }

    public String getTexto() { return texto; }
    public void setTexto(String texto) { this.texto = texto; }

    public String getTipo() { return tipo; }
    public void setTipo(String tipo) { this.tipo = tipo; }

    public String getRutaEvidencia() { return rutaEvidencia; }
    public void setRutaEvidencia(String rutaEvidencia) { this.rutaEvidencia = rutaEvidencia; }

    public String getCursoNombre() { return cursoNombre; }
    public void setCursoNombre(String cursoNombre) { this.cursoNombre = cursoNombre; }

    public String getAlumnoNombre() { return alumnoNombre; }
    public void setAlumnoNombre(String alumnoNombre) { this.alumnoNombre = alumnoNombre; }
}