package com.romualdsigning.studentgradecalc.data.export

import com.romualdsigning.studentgradecalc.data.io.WorkbookExportService
import com.romualdsigning.studentgradecalc.domain.model.ExportFormat
import com.romualdsigning.studentgradecalc.domain.service.ReportExporter

class ReportExporterFactory(
    private val excelExporter: ReportExporter = WorkbookExportService(),
    private val csvExporter: ReportExporter = CsvReportExporter(),
    private val jsonExporter: ReportExporter = JsonReportExporter(),
    private val pdfExporter: ReportExporter = PdfReportExporter(),
    private val wordExporter: ReportExporter = WordReportExporter(),
) {
    fun create(format: ExportFormat): ReportExporter =
        when (format) {
            ExportFormat.EXCEL -> excelExporter
            ExportFormat.CSV -> csvExporter
            ExportFormat.JSON -> jsonExporter
            ExportFormat.PDF -> pdfExporter
            ExportFormat.WORD -> wordExporter
        }
}
