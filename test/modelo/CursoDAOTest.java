package modelo;

import java.util.List;
import org.junit.Test;
import org.junit.Before;
import org.junit.After;
import org.junit.FixMethodOrder;
import org.junit.runners.MethodSorters;
import static org.junit.Assert.*;

/**
 * SUITE DE PRUEBAS PARA CursoDAO (Actualizado)
 * 
 * Pruebas adaptadas a los métodos disponibles en la versión actual del DAO
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
    // PRUEBAS DE LISTADO (CON LOS MÉTODOS ACTUALES)
    // ========================================================================

    @Test
    public void test01_ListarTodos() {
        System.out.println("TEST: Listar todos los cursos activos (vista)");
        
        List<Curso> cursos = dao.listar();
        
        assertNotNull("La lista no debe ser null", cursos);
        System.out.println("✅ Cursos activos encontrados: " + cursos.size());
        
        // Mostrar primeros 5 cursos
        if (cursos.size() > 0) {
            System.out.println("\nPrimeros 5 cursos:");
            for (int i = 0; i < Math.min(5, cursos.size()); i++) {
                Curso c = cursos.get(i);
                System.out.println("  " + (i+1) + ". " + c.getNombre() + 
                    " (ID: " + c.getId() + ", Grado: " + c.getGradoNombre() + 
                    ", Profesor: " + c.getProfesorNombre() + ")");
            }
        }
    }

    @Test
    public void test02_ListarPorGrado() {
        System.out.println("TEST: Listar cursos por grado");
        
        // Busca un grado que exista - modifica este ID según tu BD
        int gradoId = 1; 
        List<Curso> cursos = dao.listarPorGrado(gradoId);
        
        assertNotNull("La lista no debe ser null", cursos);
        System.out.println("📘 Cursos en grado ID " + gradoId + ": " + cursos.size());
        
        if (cursos.size() > 0) {
            for (Curso c : cursos) {
                System.out.println("  - " + c.getNombre() + 
                    " (ID: " + c.getId() + ", Grado: " + c.getGradoNombre() + ")");
            }
        } else {
            System.out.println("⚠️ No se encontraron cursos para este grado");
        }
    }

    @Test
    public void test03_ListarPorProfesor() {
        System.out.println("TEST: Listar cursos por profesor");
        
        // Busca un profesor que exista - modifica este ID según tu BD
        int profesorId = 1; 
        List<Curso> cursos = dao.listarPorProfesor(profesorId);
        
        assertNotNull("La lista no debe ser null", cursos);
        System.out.println("👨‍🏫 Cursos del profesor ID " + profesorId + ": " + cursos.size());
        
        if (cursos.size() > 0) {
            for (Curso c : cursos) {
                System.out.println("  - " + c.getNombre() + 
                    " (Profesor: " + c.getProfesorNombre() + ")");
            }
        } else {
            System.out.println("⚠️ No se encontraron cursos para este profesor");
        }
    }

    @Test
    public void test04_ListarPorNivel() {
        System.out.println("TEST: Listar cursos por nivel educativo");
        
        String nivel = "PRIMARIA"; // Prueba con "INICIAL", "PRIMARIA" o "SECUNDARIA"
        List<Curso> cursos = dao.listarPorNivel(nivel);
        
        assertNotNull("La lista no debe ser null", cursos);
        System.out.println("🎓 Cursos de nivel " + nivel + ": " + cursos.size());
        
        if (cursos.size() > 0) {
            for (int i = 0; i < Math.min(3, cursos.size()); i++) {
                Curso c = cursos.get(i);
                System.out.println("  " + (i+1) + ". " + c.getNombre() + 
                    " (" + c.getGradoNombre() + ")");
            }
        }
    }

    @Test
    public void test05_ListarPorArea() {
        System.out.println("TEST: Listar cursos por área");
        
        String area = "Matemática"; // Modifica según las áreas de tu BD
        List<Curso> cursos = dao.listarPorArea(area);
        
        assertNotNull("La lista no debe ser null", cursos);
        System.out.println("📚 Cursos del área " + area + ": " + cursos.size());
        
        if (cursos.size() > 0) {
            for (Curso c : cursos) {
                System.out.println("  - " + c.getNombre());
            }
        }
    }

    @Test
    public void test06_BuscarPorNombre() {
        System.out.println("TEST: Buscar cursos por nombre");
        
        String nombre = "Matemática"; // Término de búsqueda
        List<Curso> cursos = dao.buscarPorNombre(nombre);
        
        assertNotNull("La lista no debe ser null", cursos);
        System.out.println("🔍 Cursos encontrados con '" + nombre + "': " + cursos.size());
        
        if (cursos.size() > 0) {
            for (Curso c : cursos) {
                System.out.println("  - " + c.getNombre() + 
                    " (ID: " + c.getId() + ")");
            }
        }
    }

    // ========================================================================
    // PRUEBAS DE OBTENCIÓN
    // ========================================================================

    @Test
    public void test07_ObtenerPorId() {
        System.out.println("TEST: Obtener curso por ID");
        
        // Busca un curso existente - modifica este ID
        int idCurso = 1;
        Curso c = dao.obtenerPorId(idCurso);
        
        if (c != null) {
            assertEquals("El ID debe coincidir", idCurso, c.getId());
            
            System.out.println("📌 Curso encontrado:");
            System.out.println("  ID: " + c.getId());
            System.out.println("  Nombre: " + c.getNombre());
            System.out.println("  Grado: " + c.getGradoNombre());
            System.out.println("  Profesor: " + c.getProfesorNombre());
            System.out.println("  Área: " + c.getArea());
            System.out.println("  Créditos: " + c.getCreditos());
            System.out.println("  Total profesores: " + c.getTotalProfesores());
            System.out.println("  Total horarios: " + c.getTotalHorarios());
        } else {
            System.out.println("⚠️ No se encontró el curso con ID: " + idCurso);
        }
    }

    @Test
    public void test08_ObtenerConEstadisticas() {
        System.out.println("TEST: Obtener curso con estadísticas completas");
        
        // Busca un curso existente - modifica este ID
        int idCurso = 1;
        Curso c = dao.obtenerConEstadisticas(idCurso);
        
        if (c != null) {
            System.out.println("📊 Curso con estadísticas:");
            System.out.println("  Nombre: " + c.getNombre());
            System.out.println("  Alumnos en el grado: " + c.getCantidadAlumnos());
            System.out.println("  Tareas del curso: " + c.getCantidadTareas());
            System.out.println("  Total profesores: " + c.getTotalProfesores());
            System.out.println("  Total horarios: " + c.getTotalHorarios());
        } else {
            System.out.println("⚠️ No se encontró el curso con ID: " + idCurso);
        }
    }

    // ========================================================================
    // PRUEBAS CRUD
    // ========================================================================

    @Test
    public void test09_Agregar() {
        System.out.println("TEST: Agregar nuevo curso");
        
        Curso nuevo = new Curso();
        nuevo.setNombre("Curso de Prueba JUnit");
        nuevo.setGradoId(1);    // Usa un gradoId existente
        nuevo.setProfesorId(1);  // Usa un profesorId existente
        nuevo.setCreditos(3);
        nuevo.setHorasSemanales(4);
        nuevo.setArea("Pruebas");
        nuevo.setCiclo("2024-I");
        
        // Si tu curso acepta fechas, agrégalas
        // nuevo.setFechaInicio(new java.sql.Date(System.currentTimeMillis()));
        // nuevo.setFechaFin(new java.sql.Date(System.currentTimeMillis() + 86400000L * 180));
        
        System.out.println("📝 Intentando crear curso: " + nuevo.getNombre());
        System.out.println("  Grado ID: " + nuevo.getGradoId());
        System.out.println("  Profesor ID: " + nuevo.getProfesorId());
        
        int nuevoId = dao.agregar(nuevo);
        
        if (nuevoId > 0) {
            idCursoTest = nuevoId; // Guardar para otros tests
            System.out.println("✅ Curso creado con ID: " + nuevoId);
        } else {
            System.out.println("❌ No se pudo crear el curso. Verifica:");
            System.out.println("  1. Que existan el gradoId: " + nuevo.getGradoId());
            System.out.println("  2. Que exista el profesorId: " + nuevo.getProfesorId());
            System.out.println("  3. La conexión a la base de datos");
        }
    }

    @Test
    public void test10_Actualizar() {
        System.out.println("TEST: Actualizar curso existente");
        
        // Usar el curso creado en test09 o un existente
        if (idCursoTest <= 0) {
            // Si no hay curso de prueba, usar uno existente
            List<Curso> cursos = dao.listar();
            if (!cursos.isEmpty()) {
                idCursoTest = cursos.get(0).getId();
                System.out.println("⚠️ Usando curso existente para prueba: ID " + idCursoTest);
            } else {
                System.out.println("⚠️ No hay cursos para actualizar. Ejecuta test09 primero.");
                return;
            }
        }
        
        Curso actualizado = new Curso();
        actualizado.setId(idCursoTest);
        actualizado.setNombre("Curso Actualizado " + System.currentTimeMillis());
        actualizado.setGradoId(1);
        actualizado.setProfesorId(1);
        actualizado.setCreditos(4);
        actualizado.setHorasSemanales(5);
        actualizado.setArea("Actualización");
        actualizado.setCiclo("2024-II");
        
        boolean resultado = dao.actualizar(actualizado);
        
        assertTrue("La actualización debe ser exitosa", resultado);
        System.out.println("✏️ Curso actualizado con ID: " + idCursoTest);
        
        // Verificar cambio
        Curso verificacion = dao.obtenerPorId(idCursoTest);
        if (verificacion != null) {
            System.out.println("  Nuevo nombre: " + verificacion.getNombre());
            System.out.println("  Nuevos créditos: " + verificacion.getCreditos());
        }
    }

    // ========================================================================
    // PRUEBAS DE VERIFICACIÓN
    // ========================================================================

    @Test
    public void test11_ExisteCurso() {
        System.out.println("TEST: Verificar existencia de curso");
        
        // Verificar un curso existente
        List<Curso> cursos = dao.listar();
        if (!cursos.isEmpty()) {
            int idExistente = cursos.get(0).getId();
            boolean existe = dao.existeCurso(idExistente);
            assertTrue("El curso " + idExistente + " debe existir", existe);
            System.out.println("✅ Curso " + idExistente + " existe: " + existe);
        }
        
        // Verificar un curso que no existe
        boolean noExiste = dao.existeCurso(999999);
        assertFalse("El curso 999999 no debe existir", noExiste);
        System.out.println("✅ Curro 999999 existe: " + noExiste);
    }

    @Test
    public void test12_IsCursoAssignedToProfesor() {
        System.out.println("TEST: Verificar asignación curso-profesor");
        
        // Usar datos reales de tu BD
        int cursoId = 1;     // Cambia por un curso existente
        int profesorId = 1;  // Cambia por un profesor existente
        
        boolean asignado = dao.isCursoAssignedToProfesor(cursoId, profesorId);
        
        System.out.println("Curso " + cursoId + " asignado a profesor " + 
            profesorId + ": " + asignado);
    }

    @Test
    public void test13_TieneTareas() {
        System.out.println("TEST: Verificar si curso tiene tareas");
        
        // Primero verificar si tenemos el método en el DAO
        try {
            // Buscar un curso que pueda tener tareas
            List<Curso> cursos = dao.listar();
            if (!cursos.isEmpty()) {
                int cursoId = cursos.get(0).getId();
                
                // Intentar usar el método si existe
                // Si no existe, comentar esta prueba o crear el método
                System.out.println("⚠️ El método tieneTareas() no está implementado en tu DAO");
                System.out.println("   Usar: dao.contarTareasPorCurso(cursoId) > 0");
                
              //  int tareas = dao.contarTareasPorCurso(cursoId);
           //     System.out.println("Curso " + cursoId + " tiene " + tareas + " tareas");
            }
        } catch (Exception e) {
            System.out.println("⚠️ Error: " + e.getMessage());
            System.out.println("   Asegúrate de implementar el método en CursoDAO");
        }
    }

    // ========================================================================
    // PRUEBAS DE CONTEO
    // ========================================================================

    @Test
    public void test14_ContarPorProfesor() {
        System.out.println("TEST: Contar cursos por profesor");
        
        int profesorId = 1; // Cambia por un profesor existente
        int cantidad = dao.contarPorProfesor(profesorId);
        
        System.out.println("👨‍🏫 Profesor " + profesorId + " tiene " + 
            cantidad + " cursos asignados");
        
        assertTrue("El profesor debe tener al menos 0 cursos", cantidad >= 0);
    }

    @Test
    public void test15_ContarPorGrado() {
        System.out.println("TEST: Contar cursos por grado");
        
        int gradoId = 1; // Cambia por un grado existente
        int cantidad = dao.contarPorGrado(gradoId);
        
        System.out.println("📘 Grado " + gradoId + " tiene " + 
            cantidad + " cursos");
        
        assertTrue("El grado debe tener al menos 0 cursos", cantidad >= 0);
    }

    @Test
    public void test16_ContarTotal() {
        System.out.println("TEST: Contar total de cursos activos");
        
        int total = dao.contarTotal();
        
        System.out.println("📊 Total de cursos activos: " + total);
        assertTrue("Debe haber al menos 0 cursos", total >= 0);
    }

    // ========================================================================
    // PRUEBAS DE OPERACIONES ESPECIALES
    // ========================================================================

    @Test
    public void test17_CambiarProfesor() {
        System.out.println("TEST: Cambiar profesor de curso");
        
        // Usar un curso existente
        List<Curso> cursos = dao.listar();
        if (cursos.isEmpty()) {
            System.out.println("⚠️ No hay cursos para probar");
            return;
        }
        
        int cursoId = cursos.get(0).getId();
        int profesorOriginal = cursos.get(0).getProfesorId();
        int nuevoProfesorId = 2; // Cambia por otro profesor existente
        
        if (profesorOriginal == nuevoProfesorId) {
            System.out.println("⚠️ El profesor ya es el mismo, buscando otro...");
            nuevoProfesorId = 3; // Otro profesor
        }
        
        boolean cambiado = dao.cambiarProfesor(cursoId, nuevoProfesorId);
        
        if (cambiado) {
            System.out.println("👨‍🏫 Profesor cambiado de " + profesorOriginal + 
                " a " + nuevoProfesorId + " en curso " + cursoId);
            
            // Revertir cambio para no afectar datos
            dao.cambiarProfesor(cursoId, profesorOriginal);
            System.out.println("  ↪ Cambio revertido a profesor original");
        } else {
            System.out.println("❌ No se pudo cambiar el profesor");
        }
    }

    // ========================================================================
    // PRUEBAS DE ELIMINACIÓN (DEBE SER LA ÚLTIMA)
    // ========================================================================

    @Test
    public void test99_Eliminar() {
        System.out.println("TEST: Eliminar curso (eliminación lógica)");
        
        // Crear un curso temporal para eliminar
        Curso temporal = new Curso();
        temporal.setNombre("Curso Temporal a Eliminar");
        temporal.setGradoId(1);
        temporal.setProfesorId(1);
        temporal.setCreditos(1);
        
        int tempId = dao.agregar(temporal);
        
        if (tempId > 0) {
            System.out.println("📝 Curso temporal creado con ID: " + tempId);
            
            // Verificar que existe
            assertTrue("El curso debe existir antes de eliminar", dao.existeCurso(tempId));
            
            // Eliminar
            boolean eliminado = dao.eliminar(tempId);
            
            assertTrue("La eliminación debe ser exitosa", eliminado);
            System.out.println("🗑️ Curso eliminado (lógico) con ID: " + tempId);
            
            // Verificar que ya no está activo
            // Nota: existeCurso verifica activo=1, así que debe dar false
            assertFalse("El curso no debe existir como activo", dao.existeCurso(tempId));
        } else {
            System.out.println("⚠️ No se pudo crear curso temporal para eliminar");
        }
    }

    // ========================================================================
    // PRUEBAS DE RENDIMIENTO
    // ========================================================================

    @Test
    public void testRendimiento_ListarTodos() {
        System.out.println("TEST: Rendimiento - Listar todos los cursos");
        
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
    public void testRendimiento_ObtenerConEstadisticas() {
        System.out.println("TEST: Rendimiento - Obtener curso con estadísticas");
        
        List<Curso> cursos = dao.listar();
        if (cursos.isEmpty()) {
            System.out.println("⚠️ No hay cursos para probar");
            return;
        }
        
        int cursoId = cursos.get(0).getId();
        
        long inicio = System.currentTimeMillis();
        Curso c = dao.obtenerConEstadisticas(cursoId);
        long fin = System.currentTimeMillis();
        
        long tiempo = fin - inicio;
        System.out.println("⏱️ Tiempo de ejecución: " + tiempo + " ms");
        
        if (c != null) {
            System.out.println("📊 Estadísticas obtenidas para: " + c.getNombre());
        }
        
        assertTrue("La consulta debe completarse en menos de 1 segundo", 
            tiempo < 1000);
    }
}