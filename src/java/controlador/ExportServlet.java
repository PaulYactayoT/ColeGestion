/*
 * SERVLET PARA EXPORTACION DE REPORTES EN FORMATOS PDF Y EXCEL
 * 
 * Funcionalidades: Exportar notas, tareas y observaciones a PDF/Excel
 * Roles: Admin, Docente, Padre (segun el reporte)
 * Integracion: Uso de Apache POI (Excel) y iText (PDF)
 */
package controlador;

import modelo.NotaDAO;
import modelo.TareaDAO;
import modelo.ObservacionDAO;
import modelo.Nota;
import modelo.Tarea;
import modelo.Observacion;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.ServletOutputStream;

// Apache POI para Excel
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFRow;

// iText 5 para PDF
import com.itextpdf.text.Document;
import com.itextpdf.text.DocumentException;
import com.itextpdf.text.pdf.PdfWriter;
import com.itextpdf.text.pdf.PdfPTable;

@WebServlet("/ExportServlet")
public class ExportServlet extends HttpServlet {

    /**
     * METODO GET - GENERAR Y DESCARGAR REPORTES
     * 
     * Parametros:
     * - report: Tipo de reporte (notas, tareas, observaciones)
     * - type: Formato (pdf, xlsx)
     * - alumno_id: ID del alumno para filtrar
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String report = request.getParameter("report");   // "notas", "tareas" u "observaciones"
        String type   = request.getParameter("type");     // "pdf"  o "xlsx"
        String alumId = request.getParameter("alumno_id");
        int alumnoId  = alumId != null ? Integer.parseInt(alumId) : 0;

        // Abrir stream de respuesta una vez
        ServletOutputStream out = response.getOutputStream();
        try {
            switch (report) {
                case "notas":
                    List<Nota> notas = new NotaDAO().listarPorAlumno(alumnoId);
                    if ("pdf".equals(type)) {
                        response.setContentType("application/pdf");
                        response.setHeader("Content-Disposition","attachment; filename=notas.pdf");
                        exportNotasPdf(notas, out);
                    } else {
                        response.setContentType(
                          "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
                        response.setHeader("Content-Disposition","attachment; filename=notas.xlsx");
                        exportNotasExcel(notas, out);
                    }
                    break;

                case "tareas":
                    List<Tarea> tareas = new TareaDAO().listarPorAlumno(alumnoId);
                    if ("pdf".equals(type)) {
                        response.setContentType("application/pdf");
                        response.setHeader("Content-Disposition","attachment; filename=tareas.pdf");
                        exportTareasPdf(tareas, out);
                    } else {
                        response.setContentType(
                          "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
                        response.setHeader("Content-Disposition","attachment; filename=tareas.xlsx");
                        exportTareasExcel(tareas, out);
                    }
                    break;

                case "observaciones":
                    List<Observacion> obs = new ObservacionDAO().listarPorAlumno(alumnoId);
                    if ("pdf".equals(type)) {
                        response.setContentType("application/pdf");
                        response.setHeader("Content-Disposition","attachment; filename=observaciones.pdf");
                        exportObsPdf(obs, out);
                    } else {
                        response.setContentType(
                          "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
                        response.setHeader("Content-Disposition","attachment; filename=observaciones.xlsx");
                        exportObsExcel(obs, out);
                    }
                    break;

                default:
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Reporte desconocido.");
                    return;
            }
            out.flush();  // Asegurar que todo se envie
        } catch (Exception ex) {
            ex.printStackTrace();
            response.reset(); // Limpiar cabeceras/stream
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                               "Error generando el reporte: " + ex.getMessage());
        } finally {
            out.close();
        }
    }

    // --- METODOS PARA EXPORTACION A EXCEL (APACHE POI) ---

    /**
     * EXPORTAR NOTAS A EXCEL
     */
    private void exportNotasExcel(List<Nota> lista, ServletOutputStream out) throws IOException {
        XSSFWorkbook wb = new XSSFWorkbook();
        XSSFSheet sheet = wb.createSheet("Notas");
        XSSFRow header = sheet.createRow(0);
        header.createCell(0).setCellValue("Curso");
        header.createCell(1).setCellValue("Tarea");
        header.createCell(2).setCellValue("Nota");
        int rowNum = 1;
        for (Nota n : lista) {
            XSSFRow row = sheet.createRow(rowNum++);
            row.createCell(0).setCellValue(n.getCursoNombre());
            row.createCell(1).setCellValue(n.getTareaNombre());
            row.createCell(2).setCellValue(n.getNota());
        }
        wb.write(out);
        wb.close();   // Cerrar workbook, no el stream
    }

    /**
     * EXPORTAR TAREAS A EXCEL
     */
    private void exportTareasExcel(List<Tarea> lista, ServletOutputStream out) throws IOException {
        XSSFWorkbook wb = new XSSFWorkbook();
        XSSFSheet sheet = wb.createSheet("Tareas");
        XSSFRow header = sheet.createRow(0);
        header.createCell(0).setCellValue("Curso");
        header.createCell(1).setCellValue("Nombre");
        header.createCell(2).setCellValue("Descripcion");
        header.createCell(3).setCellValue("Fecha Entrega");
        header.createCell(4).setCellValue("Activo");
        int rowNum = 1;
        for (Tarea t : lista) {
            XSSFRow row = sheet.createRow(rowNum++);
            row.createCell(0).setCellValue(t.getCursoNombre());
            row.createCell(1).setCellValue(t.getNombre());
            row.createCell(2).setCellValue(t.getDescripcion());
            row.createCell(3).setCellValue(t.getFechaEntrega());
            row.createCell(4).setCellValue(t.isActivo() ? "Si" : "No");
        }
        wb.write(out);
        wb.close();
    }

    /**
     * EXPORTAR OBSERVACIONES A EXCEL
     */
    private void exportObsExcel(List<Observacion> lista, ServletOutputStream out) throws IOException {
        XSSFWorkbook wb = new XSSFWorkbook();
        XSSFSheet sheet = wb.createSheet("Observaciones");
        XSSFRow header = sheet.createRow(0);
        header.createCell(0).setCellValue("Curso");
        header.createCell(1).setCellValue("Observacion");
        int rowNum = 1;
        for (Observacion o : lista) {
            XSSFRow row = sheet.createRow(rowNum++);
            row.createCell(0).setCellValue(o.getCursoNombre());
            row.createCell(1).setCellValue(o.getTexto());
        }
        wb.write(out);
        wb.close();
    }

    // --- METODOS PARA EXPORTACION A PDF (ITEXT) ---

    /**
     * EXPORTAR NOTAS A PDF
     */
    private void exportNotasPdf(List<Nota> lista, ServletOutputStream out) throws IOException {
        Document doc = new Document();
        try {
            PdfWriter.getInstance(doc, out);
            doc.open();
            PdfPTable table = new PdfPTable(3);
            table.addCell("Curso");
            table.addCell("Tarea");
            table.addCell("Nota");
            for (Nota n : lista) {
                table.addCell(n.getCursoNombre());
                table.addCell(n.getTareaNombre());
                table.addCell(String.valueOf(n.getNota()));
            }
            doc.add(table);
        } catch (DocumentException e) {
            throw new IOException(e);
        } finally {
            doc.close();
        }
    }

    /**
     * EXPORTAR TAREAS A PDF
     */
    private void exportTareasPdf(List<Tarea> lista, ServletOutputStream out) throws IOException {
        Document doc = new Document();
        try {
            PdfWriter.getInstance(doc, out);
            doc.open();
            PdfPTable table = new PdfPTable(5);
            table.addCell("Curso");
            table.addCell("Nombre");
            table.addCell("Descripcion");
            table.addCell("Fecha Entrega");
            table.addCell("Activo");
            for (Tarea t : lista) {
                table.addCell(t.getCursoNombre());
                table.addCell(t.getNombre());
                table.addCell(t.getDescripcion());
                table.addCell(t.getFechaEntrega());
                table.addCell(t.isActivo() ? "Si" : "No");
            }
            doc.add(table);
        } catch (DocumentException e) {
            throw new IOException(e);
        } finally {
            doc.close();
        }
    }

    /**
     * EXPORTAR OBSERVACIONES A PDF
     */
    private void exportObsPdf(List<Observacion> lista, ServletOutputStream out) throws IOException {
        Document doc = new Document();
        try {
            PdfWriter.getInstance(doc, out);
            doc.open();
            PdfPTable table = new PdfPTable(2);
            table.addCell("Curso");
            table.addCell("Observacion");
            for (Observacion o : lista) {
                table.addCell(o.getCursoNombre());
                table.addCell(o.getTexto());
            }
            doc.add(table);
        } catch (DocumentException e) {
            throw new IOException(e);
        } finally {
            doc.close();
        }
    }
}