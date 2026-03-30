package com.romualdsigning.studentgradecalc.data.export

import android.content.Context
import android.net.Uri
import com.romualdsigning.studentgradecalc.domain.model.ExportArtifact
import com.romualdsigning.studentgradecalc.domain.model.ExportDestination
import com.romualdsigning.studentgradecalc.domain.model.ExportFormat
import com.romualdsigning.studentgradecalc.domain.model.ProcessingReport

class WordReportExporter : AbstractReportExporter() {
    override val format: ExportFormat = ExportFormat.WORD

    override suspend fun export(
        context: Context,
        report: ProcessingReport,
        destination: Uri,
        exportDestination: ExportDestination,
    ): ExportArtifact {
        val builder = StringBuilder().apply {
            appendLine("{\\rtf1\\ansi\\deff0")
            appendLine("{\\fonttbl{\\f0 Calibri;}{\\f1 Cambria;}}")
            appendLine("\\viewkind4\\uc1\\pard\\sa180")
            appendLine("\\f1\\fs34\\b Student Grade Report\\b0\\par")
            appendLine("\\f0\\fs20 Generated on ${java.time.LocalDateTime.now()}\\par")
            appendLine("\\par")
            appendLine("\\b Summary\\b0\\par")
            appendLine("Rows processed: ${report.summary.totalRows}\\par")
            appendLine("Average score: ${"%.2f".format(report.summary.average)}\\par")
            appendLine("Median score: ${"%.2f".format(report.summary.median)}\\par")
            appendLine("Pass rate: ${"%.2f".format(report.summary.passRate)}%\\par")
            appendLine("\\par")
            appendLine("\\b Processed Rows\\b0\\par")
            buildGradeRows(report).forEach { row ->
                appendLine("${escapeRtf(row.take(5).joinToString(" | "))}\\par")
                appendLine("${escapeRtf("Status: ${row[6]} | Source: ${row[7]}")}\\par")
                appendLine("${escapeRtf("Reasons: ${row[8].ifBlank { "None" }}")}\\par\\par")
            }
            if (report.issues.isNotEmpty()) {
                appendLine("\\b Issues\\b0\\par")
                buildIssueRows(report).forEach { row ->
                    appendLine("${escapeRtf(row.joinToString(" | "))}\\par")
                }
            }
            appendLine("}")
        }

        return writeBytes(context, destination, builder.toString().toByteArray(), exportDestination)
    }
}
