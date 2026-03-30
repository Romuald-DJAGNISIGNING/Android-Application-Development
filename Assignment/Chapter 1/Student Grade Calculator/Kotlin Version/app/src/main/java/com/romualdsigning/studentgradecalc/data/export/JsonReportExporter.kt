package com.romualdsigning.studentgradecalc.data.export

import android.content.Context
import android.net.Uri
import com.romualdsigning.studentgradecalc.domain.model.ExportArtifact
import com.romualdsigning.studentgradecalc.domain.model.ExportDestination
import com.romualdsigning.studentgradecalc.domain.model.ExportFormat
import com.romualdsigning.studentgradecalc.domain.model.ProcessingReport
import org.json.JSONArray
import org.json.JSONObject

class JsonReportExporter : AbstractReportExporter() {
    override val format: ExportFormat = ExportFormat.JSON

    override suspend fun export(
        context: Context,
        report: ProcessingReport,
        destination: Uri,
        exportDestination: ExportDestination,
    ): ExportArtifact {
        val payload = JSONObject().apply {
            put("generatedAt", java.time.LocalDateTime.now().toString())
            put(
                "summary",
                JSONObject().apply {
                    put("totalRows", report.summary.totalRows)
                    put("gradedRows", report.summary.gradedRows)
                    put("unknownRows", report.summary.unknownRows)
                    put("average", report.summary.average)
                    put("median", report.summary.median)
                    put("passRate", report.summary.passRate)
                    put(
                        "gradeCounts",
                        JSONObject(
                            report.summary.gradeCounts.entries.associate { it.key.label to it.value }
                        ),
                    )
                },
            )
            put(
                "results",
                JSONArray().apply {
                    report.results.forEach { result ->
                        put(
                            JSONObject().apply {
                                put("rowIndex", result.rowIndex)
                                put("name", result.name)
                                put("matricule", result.matricule)
                                put("finalScore", result.finalScore)
                                put("letter", result.letter.label)
                                put("pass", result.pass)
                                put("status", result.status.name)
                                put("source", result.source)
                                put("reasons", JSONArray(result.reasons))
                            },
                        )
                    }
                },
            )
            put(
                "issues",
                JSONArray().apply {
                    report.issues.forEach { issue ->
                        put(
                            JSONObject().apply {
                                put("rowIndex", issue.rowIndex)
                                put("severity", issue.severity.name)
                                put("code", issue.code)
                                put("message", issue.message)
                            },
                        )
                    }
                },
            )
        }

        return writeBytes(context, destination, payload.toString(2).toByteArray(), exportDestination)
    }
}
