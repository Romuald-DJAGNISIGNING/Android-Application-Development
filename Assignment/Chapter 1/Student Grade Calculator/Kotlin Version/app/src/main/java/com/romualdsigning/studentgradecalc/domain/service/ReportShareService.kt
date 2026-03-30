package com.romualdsigning.studentgradecalc.domain.service

import android.content.Context
import com.romualdsigning.studentgradecalc.domain.model.ExportArtifact

interface ReportShareService {
    fun share(context: Context, artifact: ExportArtifact)
}
