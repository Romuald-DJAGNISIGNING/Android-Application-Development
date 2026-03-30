package com.romualdsigning.studentgradecalc.domain.model

import android.net.Uri
import java.time.LocalDateTime

data class ExportArtifact(
    val uri: Uri,
    val sizeBytes: Long?,
    val format: ExportFormat,
    val destination: ExportDestination,
    val exportedAt: LocalDateTime,
    val displayName: String,
)
