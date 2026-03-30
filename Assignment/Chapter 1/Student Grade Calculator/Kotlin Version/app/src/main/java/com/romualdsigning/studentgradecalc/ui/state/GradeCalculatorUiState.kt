package com.romualdsigning.studentgradecalc.ui.state

import com.romualdsigning.studentgradecalc.domain.model.ChartDataset
import com.romualdsigning.studentgradecalc.domain.model.ExportArtifact
import com.romualdsigning.studentgradecalc.domain.model.ExportDestination
import com.romualdsigning.studentgradecalc.domain.model.ExportFormat
import com.romualdsigning.studentgradecalc.domain.model.ProcessingReport

data class GradeCalculatorUiState(
    val isLoading: Boolean = false,
    val sourceName: String = "No file imported",
    val report: ProcessingReport? = null,
    val chart: ChartDataset = ChartDataset(points = emptyList()),
    val error: String? = null,
    val deliveryMessage: String? = null,
    val lastArtifact: ExportArtifact? = null,
    val selectedExportFormat: ExportFormat = ExportFormat.EXCEL,
    val selectedExportDestination: ExportDestination = ExportDestination.LOCAL,
)
