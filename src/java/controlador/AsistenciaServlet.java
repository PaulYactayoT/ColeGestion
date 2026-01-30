package controlador;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.time.LocalTime;
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
import modelo.Alumno;
import modelo.AlumnoDAO;
import modelo.ConfiguracionLimiteDAO;

public class AsistenciaServlet extends HttpServlet {
    
    private ConfiguracionLimiteDAO configuracionDAO;
    
    @Override
    public void init() throws ServletException {
        configuracionDAO = new ConfiguracionLimiteDAO();
    }

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
            System.out.println(" ACCESO DENEGADO: Rol " + rol + " intentó acceder con acción: " + accion);
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
                        response.sendRedirect("dashboard.jsp");
                    }
                    break;
                case "verCurso":
                    verAsistenciasCurso(request, response);
                    break;
                case "registrar":
                    mostrarFormRegistro(request, response);
                    break;
                case "verificarLimite": 
                    verificarLimiteEdicion(request, response);
                    break;
                case "reportes":
                    mostrarReportes(request, response);
                    break;
                case "verPadre":
                    verAsistenciasPadreDetalle(request, response);
                    break;
                case "verCursoJson":
                    verAsistenciasCursoJson(request, response);
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

        System.out.println(" AsistenciaServlet POST - Acción: " + accion + ", Rol: " + rol);

        // VALIDACIÓN DE PERMISOS POR ROL
        if (!validarAccesoRol(rol, accion)) {
            System.out.println(" ACCESO DENEGADO POST: Rol " + rol + " intentó acceder con acción: " + accion);
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
    
    // ═══════════════════════════════════════════════════════════════════
    //VERIFICAR LÍMITE DE EDICIÓN (ENDPOINT AJAX)
    // ═══════════════════════════════════════════════════════════════════
    
    /**
     * Verifica si se puede editar una asistencia según límites configurados
     * Responde en formato JSON para llamadas AJAX
     */
    private void verificarLimiteEdicion(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            int cursoId = Integer.parseInt(request.getParameter("cursoId"));
            int turnoId = Integer.parseInt(request.getParameter("turnoId"));
            LocalDate fecha = LocalDate.parse(request.getParameter("fecha"));
            LocalTime horaClase = LocalTime.parse(request.getParameter("horaClase"));
            
            boolean puedeEditar = configuracionDAO.puedeEditarAsistencia(cursoId, turnoId, fecha, horaClase);
            String mensaje = configuracionDAO.obtenerMensajeTiempoLimite(cursoId, turnoId, fecha, horaClase);
            
            // Responder en JSON
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            PrintWriter out = response.getWriter();
            
            String json = String.format(
                "{\"puedeEditar\": %b, \"mensaje\": \"%s\"}", 
                puedeEditar, 
                mensaje.replace("\"", "\\\"").replace("\n", "\\n")
            );
            
            out.print(json);
            out.flush();
            
            System.out.println(" Verificación de límite: puedeEditar=" + puedeEditar);
            
        } catch (Exception e) {
            System.out.println(" Error al verificar límite: " + e.getMessage());
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\": \"" + e.getMessage() + "\"}");
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
                       "registrar".equals(accion) || "registrarGrupal".equals(accion) ||
                       "verCursoJson".equals(accion) || "verificarLimite".equals(accion); // ← AGREGADO verificarLimite
                
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
                fecha = LocalDate.now().toString();
            }

            System.out.println("Buscando asistencias para curso: " + cursoId + ", fecha: " + fecha + ", turno: " + turnoId);

            AsistenciaDAO asistenciaDAO = new AsistenciaDAO();
            List<Asistencia> asistencias = asistenciaDAO.obtenerAsistenciasPorCursoTurnoFecha(cursoId, turnoId, fecha);

            CursoDAO cursoDAO = new CursoDAO();
            Curso curso = cursoDAO.obtenerPorId(cursoId);

            System.out.println("Asistencias encontradas: " + (asistencias != null ? asistencias.size() : 0));

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
     * RETORNAR ASISTENCIAS EN FORMATO JSON
     */
    private void verAsistenciasCursoJson(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            int cursoId = Integer.parseInt(request.getParameter("curso_id"));
            String fecha = request.getParameter("fecha");
            int turnoId = request.getParameter("turno_id") != null
                    ? Integer.parseInt(request.getParameter("turno_id")) : 1;

            if (fecha == null) {
                fecha = LocalDate.now().toString();
            }

            System.out.println("Obteniendo asistencias JSON para curso: " + cursoId + ", fecha: " + fecha);

            AsistenciaDAO asistenciaDAO = new AsistenciaDAO();
            List<Asistencia> asistencias = asistenciaDAO.obtenerAsistenciasPorCursoTurnoFecha(cursoId, turnoId, fecha);

            // Configurar respuesta como JSON
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            
            PrintWriter out = response.getWriter();
            StringBuilder json = new StringBuilder();
            json.append("[");
            
            if (asistencias != null && !asistencias.isEmpty()) {
                for (int i = 0; i < asistencias.size(); i++) {
                    Asistencia a = asistencias.get(i);
                    json.append("{");
                    json.append("\"id\":").append(a.getId()).append(",");
                    json.append("\"alumnoId\":").append(a.getAlumnoId()).append(",");
                    json.append("\"alumnoNombre\":\"").append(a.getAlumnoNombre() != null ? a.getAlumnoNombre() : "").append("\",");
                    json.append("\"alumnoApellidos\":\"").append(a.getAlumnoApellidos() != null ? a.getAlumnoApellidos() : "").append("\",");
                    json.append("\"estado\":\"").append(a.getEstadoString()).append("\",");
                    json.append("\"horaClase\":\"").append(a.getHoraClaseFormateada()).append("\",");
                    json.append("\"observaciones\":\"").append(a.getObservaciones() != null ? a.getObservaciones() : "").append("\",");
                    json.append("\"fechaRegistro\":\"").append(a.getFechaRegistroFormateada()).append("\"");
                    json.append("}");
                    
                    if (i < asistencias.size() - 1) {
                        json.append(",");
                    }
                }
            }
            
            json.append("]");
            out.print(json.toString());
            out.flush();
            
            System.out.println("JSON enviado con " + (asistencias != null ? asistencias.size() : 0) + " asistencias");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error al obtener asistencias: " + e.getMessage());
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
                    ? Integer.parseInt(request.getParameter("mes")) : LocalDate.now().getMonthValue();
            int anio = request.getParameter("anio") != null
                    ? Integer.parseInt(request.getParameter("anio")) : LocalDate.now().getYear();

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
            request.setAttribute("alumnoId", alumnoId);

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
            String turnoIdParam = request.getParameter("turno_id");
            String horaClaseParam = request.getParameter("hora_clase");

            CursoDAO cursoDAO = new CursoDAO();
            List<Curso> cursos = cursoDAO.listarPorProfesor(docente.getId());

            // Validar que el curso solicitado pertenece al docente
            Curso cursoSeleccionado = null;
            if (cursoIdParam != null && !cursoIdParam.isEmpty()) {
                int cursoId = Integer.parseInt(cursoIdParam);
                boolean cursoValido = false;
                for (Curso curso : cursos) {
                    if (curso.getId() == cursoId) {
                        cursoValido = true;
                        cursoSeleccionado = curso;
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
                cursoSeleccionado = cursos.get(0);
            }
            
            // ═══════════════════════════════════════════════════════════════════
            // VERIFICAR LÍMITE DE EDICIÓN
            // ═══════════════════════════════════════════════════════════════════
            
            boolean puedeEditar = true;
            String mensajeLimite = "";
            
            if (cursoSeleccionado != null && fechaParam != null && !fechaParam.isEmpty() && 
                turnoIdParam != null && !turnoIdParam.isEmpty() && 
                horaClaseParam != null && !horaClaseParam.isEmpty()) {
                
                try {
                    LocalDate fecha = LocalDate.parse(fechaParam);
                    LocalTime horaClase = LocalTime.parse(horaClaseParam);
                    int turnoId = Integer.parseInt(turnoIdParam);
                    
                    puedeEditar = configuracionDAO.puedeEditarAsistencia(
                        cursoSeleccionado.getId(), turnoId, fecha, horaClase
                    );
                    
                    mensajeLimite = configuracionDAO.obtenerMensajeTiempoLimite(
                        cursoSeleccionado.getId(), turnoId, fecha, horaClase
                    );
                    
                    System.out.println(" Verificación límite: puedeEditar=" + puedeEditar + ", mensaje=" + mensajeLimite);
                    
                } catch (Exception e) {
                    System.out.println(" Error al verificar límite: " + e.getMessage());
                    // Si hay error, permitir edición por defecto
                    puedeEditar = true;
                    mensajeLimite = "No se pudo verificar el límite de tiempo.";
                }
            }
            
            // ═══════════════════════════════════════════════════════════════════
            
            // OBTENER ALUMNOS DEL CURSO SELECCIONADO USANDO LA TABLA MATRICULA
            List<Alumno> alumnos = new java.util.ArrayList<>();
            if (cursoSeleccionado != null) {
                System.out.println("Curso seleccionado para obtener alumnos: " + cursoSeleccionado.getId() + " - " + cursoSeleccionado.getNombre());
                
                // PRIMERO: Intentar obtener alumnos usando la tabla matricula
                alumnos = obtenerAlumnosPorCursoMatricula(cursoSeleccionado.getId());
                
                System.out.println("Alumnos obtenidos via matrícula: " + alumnos.size());
                
                // SI NO HAY ALUMNOS: Intentar método alternativo
                if (alumnos.isEmpty()) {
                    alumnos = obtenerAlumnosPorCursoAlternativo(cursoSeleccionado.getId());
                    System.out.println("Alumnos obtenidos via alternativo: " + alumnos.size());
                }
                
                // SI TODAVÍA NO HAY: Mostrar mensaje de error
                if (alumnos.isEmpty()) {
                    System.out.println("ADVERTENCIA: No se encontraron alumnos para el curso " + cursoSeleccionado.getNombre());
                    session.setAttribute("advertencia", "No se encontraron alumnos matriculados en este curso. Verifique que los alumnos estén correctamente matriculados.");
                }
            }

            // OBTENER ASISTENCIAS EXISTENTES PARA ESTA FECHA, CURSO Y TURNO (si hay parámetros)
            List<Asistencia> asistenciasExistentes = null;
            if (cursoSeleccionado != null && fechaParam != null && !fechaParam.isEmpty() && 
                turnoIdParam != null && !turnoIdParam.isEmpty()) {
                try {
                    AsistenciaDAO asistenciaDAO = new AsistenciaDAO();
                    asistenciasExistentes = asistenciaDAO.obtenerAsistenciasPorCursoTurnoFecha(
                        cursoSeleccionado.getId(), 
                        Integer.parseInt(turnoIdParam), 
                        fechaParam
                    );
                    System.out.println("Asistencias existentes encontradas: " + (asistenciasExistentes != null ? asistenciasExistentes.size() : 0));
                } catch (Exception e) {
                    System.out.println("Error al obtener asistencias existentes: " + e.getMessage());
                }
            }

            request.setAttribute("cursos", cursos);
            request.setAttribute("alumnos", alumnos);
            request.setAttribute("cursoIdParam", cursoIdParam);
            request.setAttribute("fechaParam", fechaParam);
            request.setAttribute("turnoIdParam", turnoIdParam);
            request.setAttribute("horaClaseParam", horaClaseParam);
            request.setAttribute("cursoSeleccionado", cursoSeleccionado);
            request.setAttribute("asistenciasExistentes", asistenciasExistentes);
            
            // ← NUEVO: Pasar información de límites a la vista
            request.setAttribute("puedeEditar", puedeEditar);
            request.setAttribute("mensajeLimite", mensajeLimite);

            request.getRequestDispatcher("registrarAsistencia.jsp").forward(request, response);

        } catch (Exception e) {
            System.out.println("Error en mostrarFormRegistro:");
            e.printStackTrace();
            session.setAttribute("error", "Error al cargar cursos: " + e.getMessage());
            response.sendRedirect("AsistenciaServlet?accion=ver");
        }
    }
    
    /**
     * MÉTODO AUXILIAR: OBTENER ALUMNOS POR CURSO USANDO TABLA MATRICULA
     */
    private List<Alumno> obtenerAlumnosPorCursoMatricula(int cursoId) {
        List<Alumno> alumnos = new java.util.ArrayList<>();
        
        try {
            String sql = "SELECT a.id, p.nombres, p.apellidos, a.codigo_alumno, " +
                        "CONCAT(g.nombre, ' - ', g.nivel) as grado_nombre " +
                        "FROM matricula m " +
                        "JOIN alumno a ON m.alumno_id = a.id " +
                        "JOIN persona p ON a.persona_id = p.id " +
                        "JOIN curso c ON m.curso_id = c.id " +
                        "JOIN grado g ON a.grado_id = g.id " +
                        "WHERE m.curso_id = ? " +
                        "AND m.estado = 'INSCRITO' " +
                        "AND a.eliminado = 0 AND a.activo = 1 " +
                        "AND c.eliminado = 0 AND c.activo = 1 " +
                        "ORDER BY p.apellidos, p.nombres";
            
            java.sql.Connection con = conexion.Conexion.getConnection();
            java.sql.PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, cursoId);
            java.sql.ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Alumno a = new Alumno();
                a.setId(rs.getInt("id"));
                a.setNombres(rs.getString("nombres"));
                a.setApellidos(rs.getString("apellidos"));
                a.setCodigoAlumno(rs.getString("codigo_alumno"));
                a.setGradoNombre(rs.getString("grado_nombre"));
                alumnos.add(a);
            }
            
            rs.close();
            ps.close();
            con.close();
            
        } catch (Exception e) {
            System.out.println("Error en obtenerAlumnosPorCursoMatricula: " + e.getMessage());
            e.printStackTrace();
        }
        
        return alumnos;
    }
    
    /**
     * MÉTODO AUXILIAR: OBTENER ALUMNOS POR CURSO (MÉTODO ALTERNATIVO)
     */
    private List<Alumno> obtenerAlumnosPorCursoAlternativo(int cursoId) {
        List<Alumno> alumnos = new java.util.ArrayList<>();
        
        try {
            // Método alternativo: Obtener alumnos del mismo grado que el curso
            String sql = "SELECT a.id, p.nombres, p.apellidos, a.codigo_alumno, " +
                        "CONCAT(g.nombre, ' - ', g.nivel) as grado_nombre " +
                        "FROM alumno a " +
                        "JOIN persona p ON a.persona_id = p.id " +
                        "JOIN curso c ON a.grado_id = c.grado_id " +
                        "JOIN grado g ON a.grado_id = g.id " +
                        "WHERE c.id = ? " +
                        "AND a.eliminado = 0 AND a.activo = 1 " +
                        "AND p.eliminado = 0 AND p.activo = 1 " +
                        "ORDER BY p.apellidos, p.nombres";
            
            java.sql.Connection con = conexion.Conexion.getConnection();
            java.sql.PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, cursoId);
            java.sql.ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Alumno a = new Alumno();
                a.setId(rs.getInt("id"));
                a.setNombres(rs.getString("nombres"));
                a.setApellidos(rs.getString("apellidos"));
                a.setCodigoAlumno(rs.getString("codigo_alumno"));
                a.setGradoNombre(rs.getString("grado_nombre"));
                alumnos.add(a);
            }
            
            rs.close();
            ps.close();
            con.close();
            
        } catch (Exception e) {
            System.out.println("Error en obtenerAlumnosPorCursoAlternativo: " + e.getMessage());
            e.printStackTrace();
        }
        
        return alumnos;
    }

    /**
     * MOSTRAR PAGINA DE REPORTES ESTADISTICOS DE ASISTENCIAS
     */
    private void mostrarReportes(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("reportesAsistencia.jsp").forward(request, response);
    }

    // ═══════════════════════════════════════════════════════════════════
    // ← MODIFICADO: REGISTRO GRUPAL CON VALIDACIÓN DE LÍMITES
    // ═══════════════════════════════════════════════════════════════════
    
    /**
     * REGISTRO GRUPAL DE ASISTENCIAS
     * MODIFICADO: Ahora valida límites de tiempo antes de registrar
     */
    private void registrarAsistenciaGrupal(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();

        System.out.println("INICIANDO REGISTRO GRUPAL");

        // Variables para poder usarlas en caso de error
        String fechaStr = null;
        int cursoId = 0;
        int turnoId = 0;
        String horaClase = null;

        try {
            cursoId = Integer.parseInt(request.getParameter("curso_id"));
            turnoId = Integer.parseInt(request.getParameter("turno_id"));
            fechaStr = request.getParameter("fecha");
            horaClase = request.getParameter("hora_clase");
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

            // ═══════════════════════════════════════════════════════════════════
            //  VALIDAR LÍMITE DE TIEMPO ANTES DE REGISTRAR
            // ═══════════════════════════════════════════════════════════════════
            
            LocalDate fecha = LocalDate.parse(fechaStr);
            LocalTime horaClaseTime = LocalTime.parse(horaClase);
            
            boolean puedeEditar = configuracionDAO.puedeEditarAsistencia(
                cursoId, turnoId, fecha, horaClaseTime
            );
            
            if (!puedeEditar) {
                String mensajeLimite = configuracionDAO.obtenerMensajeTiempoLimite(
                    cursoId, turnoId, fecha, horaClaseTime
                );
                
                System.out.println(" BLOQUEO: No se puede registrar asistencia. " + mensajeLimite);
                
                session.setAttribute("error", "⏱️ No se puede registrar/editar la asistencia. " + mensajeLimite);
                
                // Redirigir al formulario con los parámetros
                String redirectUrl = "AsistenciaServlet?accion=registrar";
                redirectUrl += "&curso_id=" + cursoId;
                redirectUrl += "&turno_id=" + turnoId;
                redirectUrl += "&fecha=" + fechaStr;
                redirectUrl += "&hora_clase=" + horaClase;
                response.sendRedirect(redirectUrl);
                return;
            }
            
            System.out.println(" Límite de tiempo verificado: Puede editar");
            
            // ═══════════════════════════════════════════════════════════════════

            int registradoPor = docente.getId();

            // Validar parámetros obligatorios
            if (alumnosJson == null || alumnosJson.trim().isEmpty()) {
                session.setAttribute("error", "No se recibieron datos de alumnos");
                // Redirigir manteniendo los parámetros
                String redirectUrl = "AsistenciaServlet?accion=registrar";
                redirectUrl += "&curso_id=" + cursoId;
                redirectUrl += "&turno_id=" + turnoId;
                redirectUrl += "&fecha=" + (fechaStr != null ? fechaStr : "");
                redirectUrl += "&hora_clase=" + (horaClase != null ? horaClase : "");
                response.sendRedirect(redirectUrl);
                return;
            }

            AsistenciaDAO asistenciaDAO = new AsistenciaDAO();
            boolean resultado = asistenciaDAO.registrarAsistenciaGrupal(
                cursoId, turnoId, fecha, horaClase, alumnosJson, registradoPor
            );

            if (resultado) {
                session.setAttribute("mensaje", " Asistencias grupales registradas correctamente");
                System.out.println(" Asistencias guardadas correctamente para curso: " + cursoId + ", fecha: " + fechaStr);
            } else {
                session.setAttribute("error", "Error al registrar las asistencias grupales");
                System.out.println(" Error al guardar asistencias para curso: " + cursoId + ", fecha: " + fechaStr);
            }

            // Redirigir a la vista de asistencias del curso
            response.sendRedirect("AsistenciaServlet?accion=verCurso&curso_id=" + cursoId + 
                                "&fecha=" + fechaStr + "&turno_id=" + turnoId);

        } catch (java.time.format.DateTimeParseException e) {
            session.setAttribute("error", "Formato de fecha u hora incorrecto. Use YYYY-MM-DD y HH:mm");
            String redirectUrl = "AsistenciaServlet?accion=registrar";
            redirectUrl += "&curso_id=" + cursoId;
            redirectUrl += "&turno_id=" + turnoId;
            redirectUrl += "&hora_clase=" + (horaClase != null ? horaClase : "");
            response.sendRedirect(redirectUrl);
            
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("error", "Error al registrar asistencias grupales: " + e.getMessage());
            String redirectUrl = "AsistenciaServlet?accion=registrar";
            redirectUrl += "&curso_id=" + cursoId;
            redirectUrl += "&turno_id=" + turnoId;
            redirectUrl += "&fecha=" + (fechaStr != null ? fechaStr : "");
            redirectUrl += "&hora_clase=" + (horaClase != null ? horaClase : "");
            response.sendRedirect(redirectUrl);
        }
    }

    /**
     * METODO AUXILIAR PARA VERIFICAR ASIGNACIÓN CURSO-PROFESOR
     */
    private boolean isCursoAssignedToProfesor(int cursoId, int profesorId) {
        String sql = "SELECT COUNT(*) as count FROM curso WHERE id = ? AND profesor_id = ?";
        
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