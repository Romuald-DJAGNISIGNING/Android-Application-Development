package com.romualdsigning.studentgradecalc.data.export

import android.content.Context
import android.net.Uri
import com.github.doyaaaaaken.kotlincsv.dsl.csvWriter
import com.romualdsigning.studentgradecalc.domain.model.ExportArtifact
import com.romualdsigning.studentgradecalc.domain.model.ExportDestination
import com.romualdsigning.studentgradecalc.domain.model.ExportFormat
import com.romualdsigning.studentgradecalc.domain.model.ProcessingReport

class CsvReportExporter : AbstractReportExporter() {
    override val format: ExportFormat = ExportFormat.CSV

    override suspend fun export(
        context: Context,
        report: ProcessingReport,
        destination: Uri,
        exportDestination: ExportDestination,
    ): ExportArtifact {
        val csv = csvWriter().writeAllAsString(listOf(gradeHeaders) + buildGradeRows(report))
        return writeBytes(context, destination, csv.toByteArray(), exportDestination)
    }
}
