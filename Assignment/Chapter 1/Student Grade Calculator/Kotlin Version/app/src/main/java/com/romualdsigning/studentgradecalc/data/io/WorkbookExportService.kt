package com.romualdsigning.studentgradecalc.data.io

import android.content.Context
import android.net.Uri
import com.romualdsigning.studentgradecalc.domain.model.IssueSeverity
import com.romualdsigning.studentgradecalc.domain.model.ProcessingReport
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.apache.poi.ss.usermodel.BorderStyle
import org.apache.poi.ss.usermodel.FillPatternType
import org.apache.poi.ss.usermodel.HorizontalAlignment
import org.apache.poi.ss.usermodel.IndexedColors
import org.apache.poi.ss.usermodel.VerticalAlignment
import org.apache.poi.ss.util.CellRangeAddress
import org.apache.poi.xssf.usermodel.XSSFCellStyle
import org.apache.poi.xssf.usermodel.XSSFFont
import org.apache.poi.xssf.usermodel.XSSFRow
import org.apache.poi.xssf.usermodel.XSSFSheet
import org.apache.poi.xssf.usermodel.XSSFWorkbook
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.util.Locale

class WorkbookExportService {
    suspend fun export(context: Context, report: ProcessingReport, destination: Uri): ExportResult =
        withContext(Dispatchers.IO) {
            XSSFWorkbook().use { workbook ->
                val palette = WorkbookPalette(workbook)
                val grades = workbook.createSheet("Grades")
                val summary = workbook.createSheet("Summary")
                val issues = workbook.createSheet("Issues")
                val chart = workbook.createSheet("ChartData")

                fillGrades(grades, report, palette)
                fillSummary(summary, report, palette)
                fillIssues(issues, report, palette)
                fillChart(chart, report, palette)

                context.contentResolver.openOutputStream(destination)?.use(workbook::write)
                    ?: error("Could not open output stream.")
            }

            val size = context.contentResolver.openFileDescriptor(destination, "r")?.use { it.statSize }
            ExportResult(uri = destination, sizeBytes = size)
        }

    private fun fillGrades(sheet: XSSFSheet, report: ProcessingReport, palette: WorkbookPalette) {
        val header = listOf("Row", "Name", "Matricule", "Final Score", "Letter", "Pass", "Status", "Source", "Reasons")
        decorateSheet(
            sheet = sheet,
            palette = palette,
            title = "Student Grade Report",
            subtitle = "Exported on ${timestamp()}",
            widths = listOf(8, 22, 18, 14, 10, 10, 14, 20, 36),
            lastColumn = header.lastIndex,
        )
        writeHeader(sheet, 3, header, palette)

        report.results.forEachIndexed { index, result ->
            val rowIndex = index + 4
            val row = sheet.createRow(rowIndex).apply { heightInPoints = 24f }
            writeCells(
                row,
                listOf(
                    result.rowIndex,
                    result.name.orEmpty(),
                    result.matricule.orEmpty(),
                    result.finalScore,
                    result.letter.label,
                    if (result.pass) "YES" else "NO",
                    result.status.name,
                    result.source,
                    result.reasons.joinToString(" | "),
                ),
            )

            applyRowStyle(row, header.size, palette.gradeRow(result.letter.label))
            row.getCell(3).cellStyle = palette.gradeNumber(result.letter.label)
            row.getCell(4).cellStyle = palette.gradeBadge(result.letter.label)
            row.getCell(5).cellStyle = palette.passBadge(result.pass)
            row.getCell(8).cellStyle = palette.wrapBody(result.letter.label)
        }
    }

    private fun fillSummary(sheet: XSSFSheet, report: ProcessingReport, palette: WorkbookPalette) {
        decorateSheet(
            sheet = sheet,
            palette = palette,
            title = "Summary",
            subtitle = "Average score, pass rate, and grade counts.",
            widths = listOf(28, 14),
            lastColumn = 1,
        )
        writeHeader(sheet, 3, listOf("Metric", "Value"), palette)

        val summary = report.summary
        val metrics = listOf(
            "Total Rows" to summary.totalRows,
            "Graded Rows" to summary.gradedRows,
            "Unknown Rows" to summary.unknownRows,
            "Average Score" to "%.2f".format(summary.average),
            "Median Score" to "%.2f".format(summary.median),
            "Pass Rate %" to "%.2f".format(summary.passRate),
        )

        metrics.forEachIndexed { index, (label, value) ->
            val row = sheet.createRow(index + 4).apply { heightInPoints = 22f }
            writeCells(row, listOf(label, value.toString()))
            row.getCell(0).cellStyle = palette.metricLabel()
            row.getCell(1).cellStyle = palette.metricValue()
        }

        val startRow = metrics.size + 6
        writeHeader(sheet, startRow, listOf("Grade", "Count"), palette.sectionHeader())
        report.summary.gradeCounts.entries.forEachIndexed { index, (grade, count) ->
            val row = sheet.createRow(startRow + 1 + index).apply { heightInPoints = 22f }
            writeCells(row, listOf(grade.label, count))
            row.getCell(0).cellStyle = palette.gradeBadge(grade.label)
            row.getCell(1).cellStyle = palette.metricValue()
        }
    }

    private fun fillIssues(sheet: XSSFSheet, report: ProcessingReport, palette: WorkbookPalette) {
        decorateSheet(
            sheet = sheet,
            palette = palette,
            title = "Issues",
            subtitle = "Warnings, errors, and fallback cases found during processing.",
            widths = listOf(8, 14, 18, 44),
            lastColumn = 3,
        )
        writeHeader(sheet, 3, listOf("Row", "Severity", "Code", "Message"), palette)

        report.issues.forEachIndexed { index, issue ->
            val row = sheet.createRow(index + 4).apply { heightInPoints = 34f }
            writeCells(row, listOf(issue.rowIndex, issue.severity.name, issue.code, issue.message))
            applyRowStyle(row, 4, palette.severity(issue.severity))
            row.getCell(3).cellStyle = palette.severityWrap(issue.severity)
        }
    }

    private fun fillChart(sheet: XSSFSheet, report: ProcessingReport, palette: WorkbookPalette) {
        decorateSheet(
            sheet = sheet,
            palette = palette,
            title = "Grade Counts",
            subtitle = "Counts used for the chart.",
            widths = listOf(14, 12),
            lastColumn = 1,
        )
        writeHeader(sheet, 3, listOf("Grade", "Count"), palette)

        report.summary.gradeCounts.entries.forEachIndexed { index, (grade, count) ->
            val row = sheet.createRow(index + 4).apply { heightInPoints = 22f }
            writeCells(row, listOf(grade.label, count))
            row.getCell(0).cellStyle = palette.gradeBadge(grade.label)
            row.getCell(1).cellStyle = palette.metricValue()
        }
    }

    private fun decorateSheet(
        sheet: XSSFSheet,
        palette: WorkbookPalette,
        title: String,
        subtitle: String,
        widths: List<Int>,
        lastColumn: Int,
    ) {
        widths.forEachIndexed { index, width -> sheet.setColumnWidth(index, width * 256) }
        sheet.addMergedRegion(CellRangeAddress(0, 0, 0, lastColumn))
        sheet.addMergedRegion(CellRangeAddress(1, 1, 0, lastColumn))
        sheet.createRow(0).apply {
            heightInPoints = 28f
            createCell(0).apply {
                setCellValue(title)
                cellStyle = palette.title()
            }
        }
        sheet.createRow(1).apply {
            heightInPoints = 22f
            createCell(0).apply {
                setCellValue(subtitle)
                cellStyle = palette.subtitle()
            }
        }
        sheet.createFreezePane(0, 4)
        sheet.setZoom(115)
    }

    private fun writeHeader(
        sheet: XSSFSheet,
        rowIndex: Int,
        values: List<String>,
        palette: WorkbookPalette,
    ) = writeHeader(sheet, rowIndex, values, palette.header())

    private fun writeHeader(
        sheet: XSSFSheet,
        rowIndex: Int,
        values: List<String>,
        style: XSSFCellStyle,
    ) {
        val row = sheet.createRow(rowIndex).apply { heightInPoints = 22f }
        values.forEachIndexed { index, value ->
            row.createCell(index).apply {
                setCellValue(value)
                cellStyle = style
            }
        }
    }

    private fun writeCells(row: XSSFRow, values: List<Any?>) {
        values.forEachIndexed { index, value ->
            row.createCell(index).apply {
                when (value) {
                    null -> setCellValue("")
                    is Int -> setCellValue(value.toDouble())
                    is Long -> setCellValue(value.toDouble())
                    is Double -> setCellValue(value)
                    is Float -> setCellValue(value.toDouble())
                    else -> setCellValue(value.toString())
                }
            }
        }
    }

    private fun applyRowStyle(row: XSSFRow, columnCount: Int, style: XSSFCellStyle) {
        repeat(columnCount) { column -> row.getCell(column).cellStyle = style }
    }

    private fun timestamp(): String =
        DateTimeFormatter.ofPattern("MMM d, yyyy HH:mm", Locale.US).format(LocalDateTime.now())
}

private class WorkbookPalette(private val workbook: XSSFWorkbook) {
    // I cache styles once because POI gets slower and noisier if every cell builds its own style.
    private val styles = mutableMapOf<String, XSSFCellStyle>()
    private val fonts = mutableMapOf<String, XSSFFont>()
    private val numberFormat = workbook.creationHelper.createDataFormat().getFormat("0.00")

    fun title(): XSSFCellStyle = style("title") {
        fillForegroundColor = IndexedColors.DARK_BLUE.index
        fillPattern = FillPatternType.SOLID_FOREGROUND
        setFont(font("title", "Cambria", 18, IndexedColors.WHITE.index, bold = true))
        alignment = HorizontalAlignment.CENTER
        verticalAlignment = VerticalAlignment.CENTER
        frame(IndexedColors.DARK_BLUE.index)
    }

    fun subtitle(): XSSFCellStyle = style("subtitle") {
        fillForegroundColor = IndexedColors.GREY_25_PERCENT.index
        fillPattern = FillPatternType.SOLID_FOREGROUND
        setFont(font("subtitle", "Aptos", 11, IndexedColors.DARK_BLUE.index, italic = true))
        alignment = HorizontalAlignment.CENTER
        verticalAlignment = VerticalAlignment.CENTER
        wrapText = true
        frame(IndexedColors.GREY_40_PERCENT.index)
    }

    fun header(): XSSFCellStyle = style("header") {
        fillForegroundColor = IndexedColors.BLUE_GREY.index
        fillPattern = FillPatternType.SOLID_FOREGROUND
        setFont(font("header", "Aptos", 11, IndexedColors.WHITE.index, bold = true))
        alignment = HorizontalAlignment.CENTER
        verticalAlignment = VerticalAlignment.CENTER
        wrapText = true
        frame(IndexedColors.BLUE_GREY.index)
    }

    fun sectionHeader(): XSSFCellStyle = style("section-header") {
        fillForegroundColor = IndexedColors.LIGHT_ORANGE.index
        fillPattern = FillPatternType.SOLID_FOREGROUND
        setFont(font("section-header", "Aptos", 11, IndexedColors.WHITE.index, bold = true))
        alignment = HorizontalAlignment.CENTER
        verticalAlignment = VerticalAlignment.CENTER
        frame(IndexedColors.LIGHT_ORANGE.index)
    }

    fun metricLabel(): XSSFCellStyle = style("metric-label") {
        fillForegroundColor = IndexedColors.LEMON_CHIFFON.index
        fillPattern = FillPatternType.SOLID_FOREGROUND
        setFont(font("metric-label", "Aptos", 11, IndexedColors.DARK_BLUE.index, bold = true))
        frame()
    }

    fun metricValue(): XSSFCellStyle = style("metric-value") {
        fillForegroundColor = IndexedColors.WHITE.index
        fillPattern = FillPatternType.SOLID_FOREGROUND
        setFont(font("metric-value", "Aptos", 11, IndexedColors.DARK_BLUE.index, bold = true))
        alignment = HorizontalAlignment.RIGHT
        frame()
    }

    fun gradeRow(grade: String): XSSFCellStyle {
        val tone = gradeTone(grade)
        return style("grade-row-$grade") {
            fillForegroundColor = tone.fill
            fillPattern = FillPatternType.SOLID_FOREGROUND
            setFont(font("grade-row-font-$grade", "Aptos", 11, tone.font))
            verticalAlignment = VerticalAlignment.CENTER
            frame()
        }
    }

    fun gradeNumber(grade: String): XSSFCellStyle {
        val tone = gradeTone(grade)
        return style("grade-number-$grade") {
            cloneStyleFrom(gradeRow(grade))
            alignment = HorizontalAlignment.RIGHT
            dataFormat = numberFormat
            setFont(font("grade-number-font-$grade", "Aptos", 11, tone.font, bold = true))
        }
    }

    fun gradeBadge(grade: String): XSSFCellStyle {
        val tone = gradeTone(grade)
        return style("grade-badge-$grade") {
            cloneStyleFrom(gradeRow(grade))
            alignment = HorizontalAlignment.CENTER
            setFont(font("grade-badge-font-$grade", "Aptos", 11, tone.font, bold = true))
        }
    }

    fun passBadge(pass: Boolean): XSSFCellStyle =
        style("pass-$pass") {
            fillForegroundColor = if (pass) IndexedColors.LIGHT_GREEN.index else IndexedColors.ROSE.index
            fillPattern = FillPatternType.SOLID_FOREGROUND
            setFont(
                font(
                    key = "pass-font-$pass",
                    name = "Aptos",
                    size = 11,
                    color = if (pass) IndexedColors.DARK_GREEN.index else IndexedColors.DARK_RED.index,
                    bold = true,
                )
            )
            alignment = HorizontalAlignment.CENTER
            verticalAlignment = VerticalAlignment.CENTER
            frame()
        }

    fun wrapBody(grade: String): XSSFCellStyle =
        style("wrap-$grade") {
            cloneStyleFrom(gradeRow(grade))
            wrapText = true
        }

    fun severity(severity: IssueSeverity): XSSFCellStyle {
        val tone = severityTone(severity)
        return style("severity-${severity.name}") {
            fillForegroundColor = tone.fill
            fillPattern = FillPatternType.SOLID_FOREGROUND
            setFont(font("severity-${severity.name}", "Aptos", 11, tone.font, bold = severity != IssueSeverity.INFO))
            verticalAlignment = VerticalAlignment.CENTER
            frame()
        }
    }

    fun severityWrap(severity: IssueSeverity): XSSFCellStyle =
        style("severity-wrap-${severity.name}") {
            cloneStyleFrom(severity(severity))
            wrapText = true
        }

    private fun style(key: String, build: XSSFCellStyle.() -> Unit): XSSFCellStyle =
        styles.getOrPut(key) { workbook.createCellStyle().apply(build) }

    private fun font(
        key: String,
        name: String,
        size: Int,
        color: Short,
        bold: Boolean = false,
        italic: Boolean = false,
    ): XSSFFont = fonts.getOrPut(key) {
        workbook.createFont().apply {
            fontName = name
            fontHeightInPoints = size.toShort()
            this.color = color
            this.bold = bold
            this.italic = italic
        }
    }

    private fun XSSFCellStyle.frame(color: Short = IndexedColors.GREY_25_PERCENT.index) {
        borderTop = BorderStyle.THIN
        borderBottom = BorderStyle.THIN
        borderLeft = BorderStyle.THIN
        borderRight = BorderStyle.THIN
        topBorderColor = color
        bottomBorderColor = color
        leftBorderColor = color
        rightBorderColor = color
    }

    private fun gradeTone(grade: String): Tone =
        when (grade) {
            "A" -> Tone(IndexedColors.SEA_GREEN.index, IndexedColors.WHITE.index)
            "B+", "B" -> Tone(IndexedColors.PALE_BLUE.index, IndexedColors.DARK_BLUE.index)
            "C+", "C" -> Tone(IndexedColors.LIGHT_YELLOW.index, IndexedColors.BROWN.index)
            "D+", "D" -> Tone(IndexedColors.LIGHT_ORANGE.index, IndexedColors.BROWN.index)
            "F", "X" -> Tone(IndexedColors.ROSE.index, IndexedColors.DARK_RED.index)
            else -> Tone(IndexedColors.GREY_25_PERCENT.index, IndexedColors.GREY_80_PERCENT.index)
        }

    private fun severityTone(severity: IssueSeverity): Tone =
        when (severity) {
            IssueSeverity.ERROR -> Tone(IndexedColors.ROSE.index, IndexedColors.DARK_RED.index)
            IssueSeverity.WARNING -> Tone(IndexedColors.LIGHT_YELLOW.index, IndexedColors.BROWN.index)
            IssueSeverity.INFO -> Tone(IndexedColors.PALE_BLUE.index, IndexedColors.DARK_BLUE.index)
        }

    private data class Tone(val fill: Short, val font: Short)
}

data class ExportResult(
    val uri: Uri,
    val sizeBytes: Long?,
)
