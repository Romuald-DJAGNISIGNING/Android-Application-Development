package com.romualdsigning.studentgradecalc.data.export

import android.content.Context
import android.content.Intent
import androidx.core.net.toUri
import com.romualdsigning.studentgradecalc.domain.model.ExportArtifact
import com.romualdsigning.studentgradecalc.domain.service.ReportShareService

class AndroidIntentShareService : ReportShareService {
    override fun share(context: Context, artifact: ExportArtifact) {
        val intent = Intent(Intent.ACTION_SEND).apply {
            type = artifact.format.mimeType
            putExtra(Intent.EXTRA_STREAM, artifact.uri)
            putExtra(Intent.EXTRA_SUBJECT, "Student Grade Report")
            putExtra(Intent.EXTRA_TEXT, "Student grade report exported as ${artifact.format.label}.")
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }

        context.startActivity(Intent.createChooser(intent, "Share report"))
    }
}
