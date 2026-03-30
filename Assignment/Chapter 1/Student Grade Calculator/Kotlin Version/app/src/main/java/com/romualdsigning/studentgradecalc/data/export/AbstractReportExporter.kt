package com.romualdsigning.studentgradecalc.data.export

import android.content.Context
import android.net.Uri
import android.provider.OpenableColumns
import com.romualdsigning.studentgradecalc.domain.model.ExportArtifact
import com.romualdsigning.studentgradecalc.domain.model.ExportDestination
import com.romualdsigning.studentgradecalc.domain.model.ProcessingReport
import com.romualdsigning.studentgradecalc.domain.service.ReportExporter
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.time.LocalDateTime

abstract class AbstractReportExporter : ReportExporter {
    protected val gradeHeaders = listOf(
        "Row",
        "Name",
        "Matricule",
        "Final Score",
        "Letter",
        "Pass",
        "Status",
        "Source",
        "Reasons",
    )

    protected fun buildGradeRows(report: ProcessingReport): List<List<String>> =
        report.results.map { result ->
            listOf(
                result.rowIndex.toString(),
                result.name.orEmpty(),
                result.matricule.orEmpty(),
                result.finalScore?.let { "%.2f".format(it) }.orEmpty(),
                result.letter.label,
                if (result.pass) "YES" else "NO",
                result.status.name,
                result.source,
                result.reasons.joinToString(" | "),
            )
        }

    protected fun buildIssueRows(report: ProcessingReport): List<List<String>> =
        report.issues.map { issue ->
            listOf(
                issue.rowIndex.toString(),
                issue.severity.name,
                issue.code,
                issue.message,
            )
        }

    protected fun escapeRtf(value: String): String =
        value.replace("\\", "\\\\")
            .replace("{", "\\{")
            .replace("}", "\\}")
            .replace("\n", "\\line ")

    protected suspend fun writeBytes(
        context: Context,
        destination: Uri,
        bytes: ByteArray,
        exportDestination: ExportDestination,
    ): ExportArtifact = withContext(Dispatchers.IO) {
        context.contentResolver.openOutputStream(destination)?.use { output ->
            output.write(bytes)
            output.flush()
        } ?: error("Could not open output stream.")

        val size = context.contentResolver.openFileDescriptor(destination, "r")?.use { it.statSize }
        ExportArtifact(
            uri = destination,
            sizeBytes = size,
            format = format,
            destination = exportDestination,
            exportedAt = LocalDateTime.now(),
            displayName = resolveDisplayName(context, destination) ?: format.suggestedFileName(),
        )
    }

    private fun resolveDisplayName(context: Context, uri: Uri): String? {
        val cursor = context.contentResolver.query(
            uri,
            arrayOf(OpenableColumns.DISPLAY_NAME),
            null,
            null,
            null,
        ) ?: return null

        return cursor.use {
            val index = it.getColumnIndex(OpenableColumns.DISPLAY_NAME)
            if (index >= 0 && it.moveToFirst()) it.getString(index) else null
        }
    }
}
