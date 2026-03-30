package com.romualdsigning.studentgradecalc.domain.service

import android.content.Context
import android.net.Uri
import com.romualdsigning.studentgradecalc.domain.model.ExportArtifact
import com.romualdsigning.studentgradecalc.domain.model.ExportDestination
import com.romualdsigning.studentgradecalc.domain.model.ExportFormat
import com.romualdsigning.studentgradecalc.domain.model.ProcessingReport

interface ReportExporter {
    val format: ExportFormat

    suspend fun export(
        context: Context,
        report: ProcessingReport,
        destination: Uri,
        exportDestination: ExportDestination,
    ): ExportArtifact
}
