package com.romualdsigning.studentgradecalc.data.export

import android.content.Context
import android.graphics.Paint
import android.graphics.Typeface
import android.graphics.pdf.PdfDocument
import android.net.Uri
import com.romualdsigning.studentgradecalc.domain.model.ExportArtifact
import com.romualdsigning.studentgradecalc.domain.model.ExportDestination
import com.romualdsigning.studentgradecalc.domain.model.ExportFormat
import com.romualdsigning.studentgradecalc.domain.model.ProcessingReport
import java.io.ByteArrayOutputStream

class PdfReportExporter : AbstractReportExporter() {
    override val format: ExportFormat = ExportFormat.PDF

    override suspend fun export(
        context: Context,
        report: ProcessingReport,
        destination: Uri,
        exportDestination: ExportDestination,
    ): ExportArtifact {
        val document = PdfDocument()
        val titlePaint = Paint().apply {
            textSize = 22f
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
        }
        val subtitlePaint = Paint().apply { textSize = 12f }
        val headerPaint = Paint().apply {
            textSize = 12f
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
        }
        val bodyPaint = Paint().apply { textSize = 10f }

        val lines = mutableListOf<String>().apply {
            add("Generated on ${java.time.LocalDateTime.now()}")
            add("Rows processed: ${report.summary.totalRows}")
            add("Average score: ${"%.2f".format(report.summary.average)}")
            add("Median score: ${"%.2f".format(report.summary.median)}")
            add("Pass rate: ${"%.2f".format(report.summary.passRate)}%")
            add("")
            addAll(buildGradeRows(report).map { row -> row.take(7).joinToString(" | ") })
            if (report.issues.isNotEmpty()) {
                add("")
                add("Issues")
                addAll(buildIssueRows(report).map { row -> row.joinToString(" | ") })
            }
        }

        val pageWidth = 595
        val pageHeight = 842
        val left = 36f
        val top = 48f
        val bottom = 40f
        val lineHeight = 16f
        var pageNumber = 1
        var index = 0

        while (index < lines.size) {
            val pageInfo = PdfDocument.PageInfo.Builder(pageWidth, pageHeight, pageNumber).create()
            val page = document.startPage(pageInfo)
            val canvas = page.canvas
            var y = top

            canvas.drawText("Student Grade Report", left, y, titlePaint)
            y += 24f
            canvas.drawText("Multi-format delivery export", left, y, subtitlePaint)
            y += 24f

            while (index < lines.size && y < pageHeight - bottom) {
                val paint = if (lines[index] == "Issues") headerPaint else bodyPaint
                canvas.drawText(lines[index], left, y, paint)
                y += lineHeight
                index++
            }

            document.finishPage(page)
            pageNumber++
        }

        val output = ByteArrayOutputStream()
        document.writeTo(output)
        document.close()
        return writeBytes(context, destination, output.toByteArray(), exportDestination)
    }
}
