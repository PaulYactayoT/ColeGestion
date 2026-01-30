package modelo;

import java.util.List;
import org.junit.Test;
import static org.junit.Assert.*;

public class ObservacionDAOTest {

    private final ObservacionDAO dao = new ObservacionDAO();
    private final CursoDAO daoCurso = new CursoDAO();
    private final AlumnoDAO daoAlumno = new AlumnoDAO();

    @Test
    public void testAgregarYEliminarObservacion() {
        int cursoId = daoCurso.listar().get(0).getId();
        int alumnoId = daoAlumno.listar().get(0).getId();

        Observacion o = new Observacion();
        o.setCursoId(cursoId);
        o.setAlumnoId(alumnoId);
        o.setTexto("Observación de prueba con JUnit");

        boolean creado = dao.agregar(o);
        assertTrue("La observación debería crearse correctamente", creado);

        List<Observacion> obsAlumno = dao.listarPorAlumno(alumnoId);
        int nuevoId = obsAlumno.stream()
                .filter(ob -> ob.getTexto().equals("Observación de prueba con JUnit"))
                .mapToInt(Observacion::getId)
                .findFirst()
                .orElse(-1);

        assertTrue("La observación insertada debe existir", nuevoId > 0);

        boolean eliminado = dao.eliminar(nuevoId);
        assertTrue("La observación debería eliminarse correctamente", eliminado);
    }

    @Test
    public void testActualizarObservacion() {
        int cursoId = daoCurso.listar().get(0).getId();
        int alumnoId = daoAlumno.listar().get(0).getId();

        Observacion o = new Observacion();
        o.setCursoId(cursoId);
        o.setAlumnoId(alumnoId);
        o.setTexto("Texto inicial");
        dao.agregar(o);

        List<Observacion> obsAlumno = dao.listarPorAlumno(alumnoId);
        int obsId = obsAlumno.stream()
                .filter(ob -> ob.getTexto().equals("Texto inicial"))
                .mapToInt(Observacion::getId)
                .findFirst()
                .orElse(-1);

        assertTrue("Debe existir la observación recién creada", obsId > 0);

        Observacion actualizado = new Observacion();
        actualizado.setId(obsId);
        actualizado.setCursoId(cursoId);
        actualizado.setAlumnoId(alumnoId);
        actualizado.setTexto("Texto actualizado con JUnit");

        boolean modificado = dao.actualizar(actualizado);
        assertTrue("La observación debería actualizarse correctamente", modificado);

        dao.eliminar(obsId);
    }

    @Test
    public void testObtenerPorId() {
        int alumnoId = daoAlumno.listar().get(0).getId();
        Observacion oInsert = new Observacion();
        oInsert.setCursoId(daoCurso.listar().get(0).getId());
        oInsert.setAlumnoId(alumnoId);
        oInsert.setTexto("Observación temporal");
        dao.agregar(oInsert);

        int idObservacion = dao.listarPorAlumno(alumnoId).get(0).getId();
        Observacion o = dao.obtenerPorId(idObservacion);

        assertNotNull("Debe existir la observación con ID " + idObservacion, o);

        dao.eliminar(idObservacion);
    }

    @Test
    public void testListarPorAlumno() {
        int alumnoId = 21;
        List<Observacion> lista = dao.listarPorAlumno(alumnoId);
        assertNotNull(lista);
        System.out.println("👩‍🎓 Observaciones del alumno " + alumnoId + ": " + lista.size());
    }

    @Test
    public void testListarPorCurso() {
        int cursoId = daoCurso.listar().get(0).getId();
        List<Observacion> lista = dao.listarPorCurso(cursoId);
        assertNotNull(lista);
        System.out.println("📘 Observaciones en el curso " + cursoId + ": " + lista.size());
    }
}
