package controlador;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import modelo.Asistencia;
import modelo.AsistenciaDAO;
import modelo.Curso;
import modelo.CursoDAO;
import modelo.Profesor;
import modelo.Padre;

public class AsistenciaServlet extends HttpServlet {

    /**
     * METODO GET - MANEJA SOLICITUDES DE CONSULTA Y NAVEGACION
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String rol = (String) session.getAttribute("rol");
        String accion = request.getParameter("accion");
        
        if (accion == null) {
            accion = "ver";
        }

        System.out.println("AsistenciaServlet GET - Acción: " + accion + ", Rol: " + rol);

        // VALIDACIÓN DE PERMISOS POR ROL
        if (!validarAccesoRol(rol, accion)) {
            System.out.println("ACCESO DENEGADO: Rol " + rol + " intentó acceder con acción: " + accion);
            response.sendRedirect("acceso_denegado.jsp");
            return;
        }

        try {
            switch (accion) {
                case "ver":
                    if ("docente".equals(rol)) {
                        verCursosDocente(request, response);
                    } else if ("padre".equals(rol)) {
                        verAsistenciasPadre(request, response);
                    } else if ("admin".equals(rol)) {
                        // Admin puede ver ambas vistas
                        response.sendRedirect("dashboard.jsp");
                    }
                    break;
                case "verCurso":
                    verAsistenciasCurso(request, response);
                    break;
                case "registrar":
                    mostrarFormRegistro(request, response);
                    break;
                case "reportes":
                    mostrarReportes(request, response);
                    break;
                case "verPadre":
                    verAsistenciasPadreDetalle(request, response);
                    break;
                default:
                    response.sendRedirect("dashboard.jsp");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "Error en AsistenciaServlet: " + e.getMessage());
            response.sendRedirect("error.jsp");
        }
    }

    /**
     * METODO POST - PROCESA ENVIOS DE FORMULARIOS (REGISTRO DE ASISTENCIAS)
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String rol = (String) session.getAttribute("rol");
        String accion = request.getParameter("accion");
        
        if (accion == null) {
            accion = "registrar";
        }

        System.out.println("AsistenciaServlet POST - Acción: " + accion + ", Rol: " + rol);

        // VALIDACIÓN DE PERMISOS POR ROL
        if (!validarAccesoRol(rol, accion)) {
            System.out.println("ACCESO DENEGADO POST: Rol " + rol + " intentó acceder con acción: " + accion);
            response.sendRedirect("acceso_denegado.jsp");
            return;
        }

        System.out.println("INICIANDO DO POST ASISTENCIA");
        System.out.println("Accion: " + accion);

        try {
            switch (accion) {
                case "registrarGrupal":
                    System.out.println("Ejecutando registrarAsistenciaGrupal...");
                    registrarAsistenciaGrupal(request, response);
                    break;
                default:
                    System.out.println("Accion no reconocida: " + accion);
                    response.sendRedirect("AsistenciaServlet?accion=ver");
            }
        } catch (Exception e) {
            System.out.println("Error en doPost:");
            e.printStackTrace();
            session.setAttribute("error", "Error al procesar asistencia: " + e.getMessage());
            response.sendRedirect("AsistenciaServlet?accion=ver");
        }
    }

    /**
     * VALIDAR ACCESO POR ROL Y ACCIÓN
     */
    private boolean validarAccesoRol(String rol, String accion) {
        if (rol == null) return false;

        switch (rol) {
            case "admin":
                // Admin puede realizar todas las acciones
                return true;
                
            case "docente":
                // Docente puede ver, verCurso, registrar y registrarGrupal
                return "ver".equals(accion) || "verCurso".equals(accion) || 
                       "registrar".equals(accion) || "registrarGrupal".equals(accion);
                
            case "padre":
                // Padre solo puede ver y verPadre (sus propias asistencias)
                return "ver".equals(accion) || "verPadre".equals(accion);
                
            default:
                return false;
        }
    }

    /**
     * MOSTRAR CURSOS ASIGNADOS AL DOCENTE PARA GESTION DE ASISTENCIAS
     */
    private void verCursosDocente(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Profesor docente = (Profesor) session.getAttribute("docente");

        if (docente == null) {
            session.setAttribute("error", "Sesion expirada. Por favor inicie sesion nuevamente.");
            response.sendRedirect("index.jsp");
            return;
        }

        try {
            System.out.println("Buscando cursos para profesor: " + docente.getNombres() + " " + 
                             docente.getApellidos() + " (ID: " + docente.getId() + ")");

            CursoDAO cursoDAO = new CursoDAO();
            List<Curso> cursos = cursoDAO.listarPorProfesor(docente.getId());

            System.out.println("Cursos encontrados: " + (cursos != null ? cursos.size() : 0));

            request.setAttribute("misCursos", cursos);
            request.getRequestDispatcher("asistenciasDocente.jsp").forward(request, response);

        } catch (Exception e) {
            System.out.println("Error en verCursosDocente:");
            e.printStackTrace();
            session.setAttribute("error", "Error al cargar los cursos: " + e.getMessage());
            response.sendRedirect("docenteDashboard.jsp");
        }
    }

    /**
     * MOSTRAR ASISTENCIAS DE UN CURSO ESPECIFICO EN FECHA DETERMINADA
     */
    private void verAsistenciasCurso(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        String rol = (String) session.getAttribute("rol");
        
        try {
            int cursoId = Integer.parseInt(request.getParameter("curso_id"));
            String fecha = request.getParameter("fecha");
            int turnoId = request.getParameter("turno_id") != null
                    ? Integer.parseInt(request.getParameter("turno_id")) : 1;

            // VALIDACIÓN CRÍTICA PARA DOCENTE: Verificar que el docente tiene acceso a este curso
            if ("docente".equals(rol)) {
                Profesor docente = (Profesor) session.getAttribute("docente");
                if (docente != null) {
                    CursoDAO cursoDAO = new CursoDAO();
                    if (!isCursoAssignedToProfesor(cursoId, docente.getId())) {
                        session.setAttribute("error", "No tienes permisos para acceder a este curso.");
                        response.sendRedirect("acceso_denegado.jsp");
                        return;
                    }
                }
            }

            if (fecha == null) {
                fecha = java.time.LocalDate.now().toString();
            }

            System.out.println("Buscando asistencias para curso: " + cursoId + ", fecha: " + fecha);

            AsistenciaDAO asistenciaDAO = new AsistenciaDAO();
            List<Asistencia> asistencias = asistenciaDAO.obtenerAsistenciasPorCursoTurnoFecha(cursoId, turnoId, fecha);

            CursoDAO cursoDAO = new CursoDAO();
            Curso curso = cursoDAO.obtenerPorId(cursoId);

            request.setAttribute("asistencias", asistencias);
            request.setAttribute("cursoId", cursoId);
            request.setAttribute("fecha", fecha);
            request.setAttribute("curso", curso);
            request.setAttribute("turnoId", turnoId);

            request.getRequestDispatcher("asistenciasCurso.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            session.setAttribute("error", "Parámetros inválidos");
            response.sendRedirect("AsistenciaServlet?accion=ver");
        } catch (Exception e) {
            session.setAttribute("error", "Error al cargar asistencias: " + e.getMessage());
            response.sendRedirect("AsistenciaServlet?accion=ver");
        }
    }

    /**
     * MOSTRAR ASISTENCIAS DEL ALUMNO PARA VISTA DE PADRES/TUTORES
     */
    private void verAsistenciasPadre(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Padre padre = (Padre) session.getAttribute("padre");

        if (padre == null) {
            session.setAttribute("error", "Sesion expirada. Por favor inicie sesion nuevamente.");
            response.sendRedirect("index.jsp");
            return;
        }

        try {
            // EL PADRE SIEMPRE VE LAS ASISTENCIAS DE SU HIJO
            int alumnoId = padre.getAlumnoId();
            
            // Validación adicional por si viene parámetro (debe coincidir con su hijo)
            String alumnoIdParam = request.getParameter("alumno_id");
            if (alumnoIdParam != null) {
                try {
                    int paramAlumnoId = Integer.parseInt(alumnoIdParam);
                    if (paramAlumnoId != alumnoId) {
                        System.out.println("ADVERTENCIA: Padre intentó acceder a asistencias de alumno ID: " + 
                                         paramAlumnoId + " pero su hijo es ID: " + alumnoId);
                        // Ignoramos el parámetro y continuamos con el alumnoId del padre
                    }
                } catch (NumberFormatException e) {
                    // Parámetro inválido, continuamos con el alumnoId del padre
                }
            }

            int mes = request.getParameter("mes") != null
                    ? Integer.parseInt(request.getParameter("mes")) : java.time.LocalDate.now().getMonthValue();
            int anio = request.getParameter("anio") != null
                    ? Integer.parseInt(request.getParameter("anio")) : java.time.LocalDate.now().getYear();

            System.out.println("Cargando asistencias para alumno (hijo del padre): " + alumnoId + 
                             ", Padre: " + padre.getUsername() + ", Alumno: " + padre.getAlumnoNombre());

            AsistenciaDAO asistenciaDAO = new AsistenciaDAO();
            List<Asistencia> asistencias = asistenciaDAO.obtenerAsistenciasPorAlumnoTurno(alumnoId, 1, mes, anio);
            Map<String, Object> resumen = asistenciaDAO.obtenerResumenAsistenciaAlumnoTurno(alumnoId, 1, mes, anio);

            System.out.println("Asistencias encontradas: " + (asistencias != null ? asistencias.size() : 0));

            request.setAttribute("asistencias", asistencias);
            request.setAttribute("resumen", resumen);
            request.setAttribute("mes", mes);
            request.setAttribute("anio", anio);
            request.setAttribute("alumnoId", alumnoId); // Siempre el del hijo del padre

        } catch (Exception e) {
            System.out.println("Error en verAsistenciasPadre:");
            e.printStackTrace();
            session.setAttribute("error", "Error al cargar asistencias: " + e.getMessage());
        }

        request.getRequestDispatcher("asistenciasPadre.jsp").forward(request, response);
    }

    /**
     * VISTA DETALLADA DE ASISTENCIAS PARA PADRES
     */
    private void verAsistenciasPadreDetalle(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        verAsistenciasPadre(request, response);
    }

    /**
     * MOSTRAR FORMULARIO DE REGISTRO DE ASISTENCIAS GRUPALES
     */
    private void mostrarFormRegistro(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Profesor docente = (Profesor) session.getAttribute("docente");

        System.out.println("INICIANDO MOSTRAR FORM REGISTRO");

        if (docente == null) {
            System.out.println("ERROR: No hay docente en sesion");
            session.setAttribute("error", "Sesion expirada. Por favor inicie sesion nuevamente.");
            response.sendRedirect("index.jsp");
            return;
        }

        try {
            String cursoIdParam = request.getParameter("curso_id");
            String fechaParam = request.getParameter("fecha");

            CursoDAO cursoDAO = new CursoDAO();
            List<Curso> cursos = cursoDAO.listarPorProfesor(docente.getId());

            // Validar que el curso solicitado pertenece al docente
            if (cursoIdParam != null && !cursoIdParam.isEmpty()) {
                int cursoId = Integer.parseInt(cursoIdParam);
                boolean cursoValido = false;
                for (Curso curso : cursos) {
                    if (curso.getId() == cursoId) {
                        cursoValido = true;
                        break;
                    }
                }
                
                if (!cursoValido) {
                    session.setAttribute("error", "No tienes permisos para acceder a este curso.");
                    response.sendRedirect("AsistenciaServlet?accion=ver");
                    return;
                }
            }

            if (cursos == null || cursos.isEmpty()) {
                session.setAttribute("error", "No tienes cursos asignados.");
                response.sendRedirect("docenteDashboard.jsp");
                return;
            }

            if ((cursoIdParam == null || cursoIdParam.isEmpty()) && !cursos.isEmpty()) {
                cursoIdParam = String.valueOf(cursos.get(0).getId());
            }

            request.setAttribute("cursos", cursos);
            request.setAttribute("cursoIdParam", cursoIdParam);
            request.setAttribute("fechaParam", fechaParam);

            request.getRequestDispatcher("registrarAsistencia.jsp").forward(request, response);

        } catch (Exception e) {
            System.out.println("Error en mostrarFormRegistro:");
            session.setAttribute("error", "Error al cargar cursos: " + e.getMessage());
            response.sendRedirect("AsistenciaServlet?accion=ver");
        }
    }

    /**
     * MOSTRAR PAGINA DE REPORTES ESTADISTICOS DE ASISTENCIAS
     */
    private void mostrarReportes(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("reportesAsistencia.jsp").forward(request, response);
    }

    /**
     * REGISTRO GRUPAL DE ASISTENCIAS
     */
    private void registrarAsistenciaGrupal(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();

        System.out.println("INICIANDO REGISTRO GRUPAL");

        try {
            int cursoId = Integer.parseInt(request.getParameter("curso_id"));
            int turnoId = Integer.parseInt(request.getParameter("turno_id"));
            String fecha = request.getParameter("fecha");
            String horaClase = request.getParameter("hora_clase");
            String alumnosJson = request.getParameter("alumnos_json");

            // VALIDACIÓN CRÍTICA: Verificar que el docente tiene acceso a este curso
            Profesor docente = (Profesor) session.getAttribute("docente");
            if (docente == null) {
                session.setAttribute("error", "Sesión expirada.");
                response.sendRedirect("index.jsp");
                return;
            }

            if (!isCursoAssignedToProfesor(cursoId, docente.getId())) {
                session.setAttribute("error", "No tienes permisos para registrar asistencias en este curso.");
                response.sendRedirect("acceso_denegado.jsp");
                return;
            }

            int registradoPor = docente.getId();

            if (alumnosJson == null || alumnosJson.isEmpty()) {
                session.setAttribute("error", "No se recibieron datos de alumnos");
                response.sendRedirect("AsistenciaServlet?accion=registrar");
                return;
            }

            AsistenciaDAO asistenciaDAO = new AsistenciaDAO();
            boolean resultado = asistenciaDAO.registrarAsistenciaGrupal(cursoId, turnoId, fecha, horaClase, alumnosJson, registradoPor);

            if (resultado) {
                session.setAttribute("mensaje", "Asistencias grupales registradas correctamente");
            } else {
                session.setAttribute("error", "Error al registrar las asistencias grupales");
            }

            response.sendRedirect("AsistenciaServlet?accion=verCurso&curso_id=" + cursoId + "&fecha=" + fecha);

        } catch (Exception e) {
            session.setAttribute("error", "Error al registrar asistencias grupales: " + e.getMessage());
            response.sendRedirect("AsistenciaServlet?accion=registrar");
        }
    }

    /**
     * METODO AUXILIAR PARA VERIFICAR ASIGNACIÓN CURSO-PROFESOR
     */
    private boolean isCursoAssignedToProfesor(int cursoId, int profesorId) {
        String sql = "SELECT COUNT(*) as count FROM cursos WHERE id = ? AND profesor_id = ?";
        
        try (java.sql.Connection con = conexion.Conexion.getConnection();
             java.sql.PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, cursoId);
            ps.setInt(2, profesorId);
            java.sql.ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("count") > 0;
            }
            
        } catch (Exception e) {
            System.out.println("Error al verificar asignación curso-profesor: " + e.getMessage());
        }
        
        return false;
    }
}