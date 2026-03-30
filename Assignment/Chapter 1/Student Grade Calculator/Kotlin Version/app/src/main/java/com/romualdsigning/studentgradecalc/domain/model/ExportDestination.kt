package com.romualdsigning.studentgradecalc.domain.model

enum class ExportDestination(
    val label: String,
    val description: String,
) {
    LOCAL(
        label = "Local Device",
        description = "Save the file on this device storage.",
    ),
    CLOUD_PROVIDER(
        label = "Cloud Provider",
        description = "Use a document provider such as Drive or OneDrive through Android's document picker.",
    ),
}
