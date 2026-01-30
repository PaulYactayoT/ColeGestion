/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelo;

public class Observacion {
    private int id;
    private int cursoId;
    private int alumnoId;
    private String texto;

    // Extra para mostrar en vista
    private String cursoNombre;
    private String alumnoNombre;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getCursoId() { return cursoId; }
    public void setCursoId(int cursoId) { this.cursoId = cursoId; }

    public int getAlumnoId() { return alumnoId; }
    public void setAlumnoId(int alumnoId) { this.alumnoId = alumnoId; }

    public String getTexto() { return texto; }
    public void setTexto(String texto) { this.texto = texto; }

    public String getCursoNombre() { return cursoNombre; }
    public void setCursoNombre(String cursoNombre) { this.cursoNombre = cursoNombre; }

    public String getAlumnoNombre() { return alumnoNombre; }
    public void setAlumnoNombre(String alumnoNombre) { this.alumnoNombre = alumnoNombre; }
}
