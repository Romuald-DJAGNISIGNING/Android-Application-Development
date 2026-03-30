package com.romualdsigning.studentgradecalc.ui.state

import android.content.Context
import android.net.Uri
import android.provider.OpenableColumns
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.romualdsigning.studentgradecalc.data.export.ReportDeliveryService
import com.romualdsigning.studentgradecalc.data.io.FileImportService
import com.romualdsigning.studentgradecalc.domain.model.ExportDestination
import com.romualdsigning.studentgradecalc.domain.model.ExportFormat
import com.romualdsigning.studentgradecalc.domain.service.StudentInputParser
import com.romualdsigning.studentgradecalc.domain.usecase.ChartDataBuilder
import com.romualdsigning.studentgradecalc.domain.usecase.GradingEngine
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

class GradeCalculatorViewModel : ViewModel() {
    private val importer: StudentInputParser = FileImportService()
    private val grader = GradingEngine()
    private val chartBuilder = ChartDataBuilder()
    private val deliveryService = ReportDeliveryService()

    private val _uiState = MutableStateFlow(GradeCalculatorUiState())
    val uiState: StateFlow<GradeCalculatorUiState> = _uiState

    fun importFromUri(context: Context, uri: Uri) {
        viewModelScope.launch {
            _uiState.update {
                it.copy(isLoading = true, error = null, deliveryMessage = null, lastArtifact = null)
            }
            runCatching {
                val rows = importer.parse(context, uri)
                val report = grader.batchGrade(rows)
                val chart = chartBuilder.buildGradeDistribution(report)
                val name = resolveDisplayName(context, uri)
                _uiState.update {
                    it.copy(
                        isLoading = false,
                        sourceName = name,
                        report = report,
                        chart = chart,
                        error = null,
                    )
                }
            }.onFailure { throwable ->
                _uiState.update {
                    it.copy(isLoading = false, error = throwable.message ?: "Import failed")
                }
            }
        }
    }

    fun selectExportFormat(format: ExportFormat) {
        _uiState.update { it.copy(selectedExportFormat = format) }
    }

    fun selectExportDestination(destination: ExportDestination) {
        _uiState.update { it.copy(selectedExportDestination = destination) }
    }

    fun exportToUri(context: Context, uri: Uri) {
        val report = _uiState.value.report ?: return
        val format = _uiState.value.selectedExportFormat
        val destination = _uiState.value.selectedExportDestination

        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null, deliveryMessage = null) }
            runCatching {
                val artifact = deliveryService.export(
                    context = context,
                    report = report,
                    format = format,
                    destination = uri,
                    exportDestination = destination,
                )
                val kb = (artifact.sizeBytes ?: 0L) / 1024
                _uiState.update {
                    it.copy(
                        isLoading = false,
                        lastArtifact = artifact,
                        deliveryMessage = "${artifact.format.label} saved to ${artifact.destination.label.lowercase()} (${kb}KB)",
                    )
                }
            }.onFailure { throwable ->
                _uiState.update {
                    it.copy(isLoading = false, error = throwable.message ?: "Export failed")
                }
            }
        }
    }

    fun shareLatestExport(context: Context) {
        val artifact = _uiState.value.lastArtifact ?: return
        runCatching {
            deliveryService.share(context, artifact)
            _uiState.update {
                it.copy(deliveryMessage = "${artifact.displayName} opened in the Android share sheet.")
            }
        }.onFailure { throwable ->
            _uiState.update { it.copy(error = throwable.message ?: "Share failed") }
        }
    }

    fun dismissMessages() {
        _uiState.update { it.copy(error = null, deliveryMessage = null) }
    }

    private fun resolveDisplayName(context: Context, uri: Uri): String {
        val cursor = context.contentResolver.query(
            uri,
            arrayOf(OpenableColumns.DISPLAY_NAME),
            null,
            null,
            null,
        ) ?: return uri.lastPathSegment ?: "Imported file"

        return cursor.use {
            val index = it.getColumnIndex(OpenableColumns.DISPLAY_NAME)
            if (index >= 0 && it.moveToFirst()) {
                it.getString(index)
            } else {
                uri.lastPathSegment ?: "Imported file"
            }
        }
    }
}
