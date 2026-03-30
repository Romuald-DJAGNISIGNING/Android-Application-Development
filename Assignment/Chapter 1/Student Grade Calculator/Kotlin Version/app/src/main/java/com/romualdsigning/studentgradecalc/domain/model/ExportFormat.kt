package com.romualdsigning.studentgradecalc.domain.model

enum class ExportFormat(
    val label: String,
    val extension: String,
    val mimeType: String,
) {
    EXCEL(
        label = "Excel",
        extension = "xlsx",
        mimeType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    ),
    CSV(
        label = "CSV",
        extension = "csv",
        mimeType = "text/csv",
    ),
    JSON(
        label = "JSON",
        extension = "json",
        mimeType = "application/json",
    ),
    PDF(
        label = "PDF",
        extension = "pdf",
        mimeType = "application/pdf",
    ),
    WORD(
        label = "Word (RTF)",
        extension = "rtf",
        mimeType = "application/rtf",
    );

    fun suggestedFileName(stem: String = "student_grade_report"): String = "$stem.$extension"
}
