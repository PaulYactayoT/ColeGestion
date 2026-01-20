package modelo;

import java.util.List;
import org.junit.Test;
import org.junit.Before;
import org.junit.After;
import org.junit.FixMethodOrder;
import org.junit.runners.MethodSorters;
import static org.junit.Assert.*;

/**
 * SUITE DE PRUEBAS PARA CursoDAO
 * 
 * Pruebas incluidas:
 * - Listar cursos (todos, por grado, por profesor, por nivel, por área)
 * - CRUD completo (Crear, Leer, Actualizar, Eliminar)
 * - Obtener cursos con estadísticas
 * - Buscar cursos
 * - Verificaciones (tareas, horarios, asignación)
 * - Operaciones de activación/desactivación
 * - Cambio de profesor
 * 
 * @author Tu Nombre
 */
@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class CursoDAOTest {
    
    private CursoDAO dao;
    private static int idCursoTest = -1; // Para almacenar ID de pruebas
    
    @Before
    public void setUp() {
        dao = new CursoDAO();
        System.out.println("\n" + "=".repeat(60));
    }
    
    @After
    public void tearDown() {
        System.out.println("=".repeat(60));
    }

    // ========================================================================
    // PRUEBAS DE LISTADO
    // ========================================================================

    @Test
    public void test01_ListarTodos() {
        System.out.println("TEST: Listar todos los cursos");
        
        List<Curso> cursos = dao.listar();
        
        assertNotNull("La lista no debe ser null", cursos);
        assertTrue("Debe haber al menos un curso en la BD", cursos.size() > 0);
        
        System.out.println("✅ Cursos totales encontrados: " + cursos.size());
        
        // Mostrar primeros 5 cursos
        System.out.println("\nPrimeros cursos:");
        cursos.stream()
            .limit(5)
            .forEach(c -> System.out.println("  - " + c.getNombre() + 
                " (ID: " + c.getId() + ", Grado: " + c.getGradoNombre() + ")"));
    }

    @Test
    public void test02_ListarActivos() {
        System.out.println("TEST: Listar solo cursos activos");
        
        List<Curso> cursos = dao.listarActivos();
        
        assertNotNull("La lista no debe ser null", cursos);
        System.out.println("✅ Cursos activos encontrados: " + cursos.size());
        
        // Verificar que todos están activos
        boolean todosActivos = cursos.stream().allMatch(Curso::isActivo);
        assertTrue("Todos los cursos deben estar activos", todosActivos);
    }

    @Test
    public void test03_ListarPorGrado() {
        System.out.println("TEST: Listar cursos por grado");
        
        int gradoId = 15; // 1ero Primaria
        List<Curso> cursos = dao.listarPorGrado(gradoId);
        
        assertNotNull("La lista no debe ser null", cursos);
        System.out.println("📘 Cursos en grado ID " + gradoId + ": " + cursos.size());
        
        for (Curso c : cursos) {
            assertEquals("Todos deben pertenecer al grado " + gradoId, 
                gradoId, c.getGradoId());
            System.out.println("  - " + c.getNombre() + " (" + c.getGradoNombre() + ")");
        }
    }

    @Test
    public void test04_ListarPorProfesor() {
        System.out.println("TEST: Listar cursos por profesor");
        
        int profesorId = 6; // Según tu BD: Juan Tapia
        List<Curso> cursos = dao.listarPorProfesor(profesorId);
        
        assertNotNull("La lista no debe ser null", cursos);
        System.out.println("👨‍🏫 Cursos dictados por profesor ID " + profesorId + 
            ": " + cursos.size());
        
        for (Curso c : cursos) {
            assertEquals("Todos deben ser del profesor " + profesorId, 
                profesorId, c.getProfesorId());
            System.out.println("  - " + c.getNombre() + " (" + c.getGradoNombre() + ")");
        }
    }

    @Test
    public void test05_ListarPorNivel() {
        System.out.println("TEST: Listar cursos por nivel educativo");
        
        String nivel = "PRIMARIA";
        List<Curso> cursos = dao.listarPorNivel(nivel);
        
        assertNotNull("La lista no debe ser null", cursos);
        System.out.println("🎓 Cursos de " + nivel + ": " + cursos.size());
        
        for (Curso c : cursos) {
            System.out.println("  - " + c.getNombre() + " (" + 
                c.getGradoNombre() + " - " + c.getNivel() + ")");
        }
    }

    @Test
    public void test06_ListarPorArea() {
        System.out.println("TEST: Listar cursos por área curricular");
        
        String area = "Humanidades";
        List<Curso> cursos = dao.listarPorArea(area);
        
        assertNotNull("La lista no debe ser null", cursos);
        System.out.println("📚 Cursos del área " + area + ": " + cursos.size());
        
        for (Curso c : cursos) {
            assertEquals("Todos deben ser del área " + area, area, c.getArea());
            System.out.println("  - " + c.getNombre());
        }
    }

    // ========================================================================
    // PRUEBAS DE OBTENCIÓN
    // ========================================================================

    @Test
    public void test07_ObtenerPorId() {
        System.out.println("TEST: Obtener curso por ID");
        
        int idCurso = 14; // Historia
        Curso c = dao.obtenerPorId(idCurso);
        
        assertNotNull("Debe existir el curso con ID " + idCurso, c);
        assertEquals("El ID debe coincidir", idCurso, c.getId());
        
        System.out.println("📌 Curso encontrado:");
        System.out.println("  ID: " + c.getId());
        System.out.println("  Nombre: " + c.getNombre());
        System.out.println("  Grado: " + c.getGradoNombre());
        System.out.println("  Profesor: " + c.getProfesorNombre());
        System.out.println("  Área: " + c.getArea());
        System.out.println("  Créditos: " + c.getCreditos());
    }

    @Test
    public void test08_ObtenerConEstadisticas() {
        System.out.println("TEST: Obtener curso con estadísticas");
        
        int idCurso = 136; // Álgebra
        Curso c = dao.obtenerConEstadisticas(idCurso);
        
        assertNotNull("Debe existir el curso con ID " + idCurso, c);
        
        System.out.println("📊 Curso con estadísticas:");
        System.out.println("  Nombre: " + c.getNombre());
        System.out.println("  Alumnos: " + c.getCantidadAlumnos());
        System.out.println("  Tareas: " + c.getCantidadTareas());
        System.out.println("  Horarios: " + c.getCantidadHorarios());
    }

    @Test
    public void test09_ListarConEstadisticas() {
        System.out.println("TEST: Listar todos los cursos con estadísticas");
        
        List<Curso> cursos = dao.listarConEstadisticas();
        
        assertNotNull("La lista no debe ser null", cursos);
        System.out.println("✅ Cursos con estadísticas: " + cursos.size());
        
        // Mostrar primeros 3
        cursos.stream()
            .limit(3)
            .forEach(c -> System.out.println("  - " + c.getNombre() + 
                " | Alumnos: " + c.getCantidadAlumnos() + 
                " | Tareas: " + c.getCantidadTareas()));
    }

    // ========================================================================
    // PRUEBAS CRUD
    // ========================================================================

    @Test
    public void test10_Agregar() {
        System.out.println("TEST: Agregar nuevo curso");
        
        Curso nuevo = new Curso();
        nuevo.setNombre("Curso JUnit Test");
        nuevo.setGradoId(15);   // 1ero Primaria
        nuevo.setProfesorId(5); // Nick Flores
        nuevo.setCreditos(2);
        
        int nuevoId = dao.agregar(nuevo);
        
        assertTrue("El ID retornado debe ser > 0", nuevoId > 0);
        idCursoTest = nuevoId; // Guardar para otros tests
        
        System.out.println("✅ Curso creado con ID: " + nuevoId);
    }

    @Test
    public void test11_AgregarConArea() {
        System.out.println("TEST: Agregar curso con área");
        
        Curso nuevo = new Curso();
        nuevo.setNombre("Curso JUnit Test con Área");
        nuevo.setGradoId(16);   // 2do Primaria
        nuevo.setProfesorId(6); // Juan Tapia
        nuevo.setCreditos(3);
        nuevo.setArea("Tecnología");
        nuevo.setActivo(true);
        
        int nuevoId = dao.agregarConArea(nuevo);
        
        assertTrue("El ID retornado debe ser > 0", nuevoId > 0);
        System.out.println("✅ Curso con área creado con ID: " + nuevoId);
        
        // Limpiar
        dao.eliminar(nuevoId);
    }

    @Test
    public void test12_Actualizar() {
        System.out.println("TEST: Actualizar curso existente");
        
        // Usar el curso creado en test10
        if (idCursoTest <= 0) {
            System.out.println("⚠️ Primero ejecuta test10_Agregar");
            return;
        }
        
        Curso actualizado = new Curso();
        actualizado.setId(idCursoTest);
        actualizado.setNombre("Curso JUnit Test ACTUALIZADO");
        actualizado.setGradoId(15);
        actualizado.setProfesorId(5);
        actualizado.setCreditos(4); // Cambio
        
        boolean resultado = dao.actualizar(actualizado);
        
        assertTrue("La actualización debe ser exitosa", resultado);
        System.out.println("✏️ Curso actualizado con ID: " + idCursoTest);
        
        // Verificar cambio
        Curso verificacion = dao.obtenerPorId(idCursoTest);
        assertEquals("Los créditos deben haber cambiado", 4, verificacion.getCreditos());
    }

    @Test
    public void test13_ActualizarCompleto() {
        System.out.println("TEST: Actualizar curso completo (con área)");
        
        if (idCursoTest <= 0) {
            System.out.println("⚠️ Primero ejecuta test10_Agregar");
            return;
        }
        
        Curso actualizado = new Curso();
        actualizado.setId(idCursoTest);
        actualizado.setNombre("Curso JUnit Test COMPLETO");
        actualizado.setGradoId(15);
        actualizado.setProfesorId(5);
        actualizado.setCreditos(5);
        actualizado.setArea("Testing");
        actualizado.setActivo(true);
        
        boolean resultado = dao.actualizarCompleto(actualizado);
        
        assertTrue("La actualización completa debe ser exitosa", resultado);
        System.out.println("✏️ Curso actualizado completamente");
    }

    // ========================================================================
    // PRUEBAS DE BÚSQUEDA
    // ========================================================================

    @Test
    public void test14_BuscarPorNombre() {
        System.out.println("TEST: Buscar cursos por nombre");
        
        String termino = "Matemática";
        List<Curso> cursos = dao.buscarPorNombre(termino);
        
        assertNotNull("La lista no debe ser null", cursos);
        System.out.println("🔍 Cursos encontrados con '" + termino + "': " + cursos.size());
        
        for (Curso c : cursos) {
            assertTrue("El nombre debe contener el término de búsqueda",
                c.getNombre().toLowerCase().contains(termino.toLowerCase()));
            System.out.println("  - " + c.getNombre());
        }
    }

    // ========================================================================
    // PRUEBAS DE VERIFICACIÓN
    // ========================================================================

    @Test
    public void test15_VerificarExistencia() {
        System.out.println("TEST: Verificar existencia de curso");
        
        boolean existe = dao.existeCurso(14); // Historia
        assertTrue("El curso 14 debe existir", existe);
        
        boolean noExiste = dao.existeCurso(99999);
        assertFalse("El curso 99999 no debe existir", noExiste);
        
        System.out.println("✅ Verificación de existencia correcta");
    }

    @Test
    public void test16_VerificarAsignacionProfesor() {
        System.out.println("TEST: Verificar asignación curso-profesor");
        
        int cursoId = 136; // Álgebra
        int profesorId = 8; // Según tu BD
        
        boolean asignado = dao.isCursoAssignedToProfesor(cursoId, profesorId);
        
        System.out.println("Curso " + cursoId + " asignado a profesor " + 
            profesorId + ": " + asignado);
    }

    @Test
    public void test17_VerificarTareas() {
        System.out.println("TEST: Verificar si curso tiene tareas");
        
        int cursoId = 136; // Álgebra (debería tener tareas)
        boolean tieneTareas = dao.tieneTareas(cursoId);
        
        System.out.println("Curso " + cursoId + " tiene tareas: " + tieneTareas);
    }

    @Test
    public void test18_VerificarHorarios() {
        System.out.println("TEST: Verificar si curso tiene horarios");
        
        int cursoId = 136; // Álgebra (debería tener horarios)
        boolean tieneHorarios = dao.tieneHorarios(cursoId);
        
        System.out.println("Curso " + cursoId + " tiene horarios: " + tieneHorarios);
    }

    // ========================================================================
    // PRUEBAS DE CONTEO
    // ========================================================================

    @Test
    public void test19_ContarPorProfesor() {
        System.out.println("TEST: Contar cursos por profesor");
        
        int profesorId = 6;
        int cantidad = dao.contarPorProfesor(profesorId);
        
        System.out.println("👨‍🏫 Profesor " + profesorId + " tiene " + 
            cantidad + " cursos asignados");
        
        assertTrue("El profesor debe tener al menos 0 cursos", cantidad >= 0);
    }

    @Test
    public void test20_ContarPorGrado() {
        System.out.println("TEST: Contar cursos por grado");
        
        int gradoId = 25; // 5to Secundaria
        int cantidad = dao.contarPorGrado(gradoId);
        
        System.out.println("📘 Grado " + gradoId + " tiene " + 
            cantidad + " cursos");
        
        assertTrue("El grado debe tener al menos 0 cursos", cantidad >= 0);
    }

    @Test
    public void test21_ContarTotal() {
        System.out.println("TEST: Contar total de cursos activos");
        
        int total = dao.contarTotal();
        
        System.out.println("📊 Total de cursos activos: " + total);
        assertTrue("Debe haber al menos un curso", total > 0);
    }

    // ========================================================================
    // PRUEBAS DE OPERACIONES ESPECIALES
    // ========================================================================

    @Test
    public void test22_DesactivarYActivar() {
        System.out.println("TEST: Desactivar y activar curso");
        
        if (idCursoTest <= 0) {
            System.out.println("⚠️ Primero ejecuta test10_Agregar");
            return;
        }
        
        // Desactivar
        boolean desactivado = dao.desactivar(idCursoTest);
        assertTrue("La desactivación debe ser exitosa", desactivado);
        System.out.println("❌ Curso desactivado");
        
        // Verificar
        Curso c = dao.obtenerPorId(idCursoTest);
        assertFalse("El curso debe estar inactivo", c.isActivo());
        
        // Activar
        boolean activado = dao.activar(idCursoTest);
        assertTrue("La activación debe ser exitosa", activado);
        System.out.println("✅ Curso activado");
        
        // Verificar
        c = dao.obtenerPorId(idCursoTest);
        assertTrue("El curso debe estar activo", c.isActivo());
    }

    @Test
    public void test23_CambiarProfesor() {
        System.out.println("TEST: Cambiar profesor de curso");
        
        if (idCursoTest <= 0) {
            System.out.println("⚠️ Primero ejecuta test10_Agregar");
            return;
        }
        
        int nuevoProfesorId = 7; // Cambiar a otro profesor
        boolean cambiado = dao.cambiarProfesor(idCursoTest, nuevoProfesorId);
        
        assertTrue("El cambio debe ser exitoso", cambiado);
        System.out.println("👨‍🏫 Profesor cambiado a ID: " + nuevoProfesorId);
        
        // Verificar
        Curso c = dao.obtenerPorId(idCursoTest);
        assertEquals("El profesor debe haber cambiado", 
            nuevoProfesorId, c.getProfesorId());
    }

    // ========================================================================
    // PRUEBA DE ELIMINACIÓN (DEBE SER LA ÚLTIMA)
    // ========================================================================

    @Test
    public void test99_Eliminar() {
        System.out.println("TEST: Eliminar curso de prueba");
        
        if (idCursoTest <= 0) {
            System.out.println("⚠️ No hay curso de prueba para eliminar");
            return;
        }
        
        boolean eliminado = dao.eliminar(idCursoTest);
        
        assertTrue("La eliminación debe ser exitosa", eliminado);
        System.out.println("🗑️ Curso eliminado con ID: " + idCursoTest);
        
        // Verificar eliminación
        Curso c = dao.obtenerPorId(idCursoTest);
        assertNull("El curso no debe existir después de eliminarlo", c);
    }

    // ========================================================================
    // PRUEBAS DE RENDIMIENTO (OPCIONALES)
    // ========================================================================

    @Test
    public void testRendimiento_ListarTodos() {
        System.out.println("TEST: Rendimiento - Listar todos");
        
        long inicio = System.currentTimeMillis();
        List<Curso> cursos = dao.listar();
        long fin = System.currentTimeMillis();
        
        long tiempo = fin - inicio;
        System.out.println("⏱️ Tiempo de ejecución: " + tiempo + " ms");
        System.out.println("📊 Cursos recuperados: " + cursos.size());
        
        assertTrue("La consulta debe completarse en menos de 2 segundos", 
            tiempo < 2000);
    }

    @Test
    public void testRendimiento_ConEstadisticas() {
        System.out.println("TEST: Rendimiento - Listar con estadísticas");
        
        long inicio = System.currentTimeMillis();
        List<Curso> cursos = dao.listarConEstadisticas();
        long fin = System.currentTimeMillis();
        
        long tiempo = fin - inicio;
        System.out.println("⏱️ Tiempo de ejecución: " + tiempo + " ms");
        System.out.println("📊 Cursos con estadísticas: " + cursos.size());
        
        assertTrue("La consulta debe completarse en menos de 3 segundos", 
            tiempo < 3000);
    }
}