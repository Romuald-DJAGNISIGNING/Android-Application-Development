package com.romualdsigning.studentgradecalc.data.export

import android.content.Context
import com.romualdsigning.studentgradecalc.domain.model.ExportArtifact
import com.romualdsigning.studentgradecalc.domain.model.ExportDestination
import com.romualdsigning.studentgradecalc.domain.model.ExportFormat
import com.romualdsigning.studentgradecalc.domain.model.ProcessingReport
import com.romualdsigning.studentgradecalc.domain.service.ReportShareService

class ReportDeliveryService(
    private val exporterFactory: ReportExporterFactory = ReportExporterFactory(),
    private val shareService: ReportShareService = AndroidIntentShareService(),
) {
    suspend fun export(
        context: Context,
        report: ProcessingReport,
        format: ExportFormat,
        destination: android.net.Uri,
        exportDestination: ExportDestination,
    ): ExportArtifact = exporterFactory.create(format).export(context, report, destination, exportDestination)

    fun share(context: Context, artifact: ExportArtifact) {
        shareService.share(context, artifact)
    }
}
