package com.romualdsigning.studentgradecalc.ui.screens

import android.graphics.Color
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.slideInVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.AutoAwesome
import androidx.compose.material.icons.rounded.AutoGraph
import androidx.compose.material.icons.rounded.Description
import androidx.compose.material.icons.rounded.Download
import androidx.compose.material.icons.rounded.RuleFolder
import androidx.compose.material.icons.rounded.UploadFile
import androidx.compose.material.icons.rounded.Verified
import androidx.compose.material.icons.rounded.WarningAmber
import androidx.compose.material.icons.rounded.WorkspacePremium
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color as ComposeColor
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.lifecycle.viewmodel.compose.viewModel
import com.github.mikephil.charting.charts.PieChart
import com.github.mikephil.charting.components.Legend
import com.github.mikephil.charting.data.PieData
import com.github.mikephil.charting.data.PieDataSet
import com.github.mikephil.charting.data.PieEntry
import com.romualdsigning.studentgradecalc.domain.model.ChartPoint
import com.romualdsigning.studentgradecalc.domain.model.GradeResult
import com.romualdsigning.studentgradecalc.domain.model.IssueSeverity
import com.romualdsigning.studentgradecalc.domain.model.ProcessingSummary
import com.romualdsigning.studentgradecalc.domain.model.ValidationIssue
import com.romualdsigning.studentgradecalc.ui.state.GradeCalculatorViewModel
import java.util.Locale

@Composable
fun GradeCalculatorScreen(viewModel: GradeCalculatorViewModel = viewModel()) {
    val context = LocalContext.current
    val uiState by viewModel.uiState.collectAsState()

    val importLauncher = rememberLauncherForActivityResult(ActivityResultContracts.OpenDocument()) { uri ->
        uri?.let { viewModel.importFromUri(context, it) }
    }
    val exportLauncher = rememberLauncherForActivityResult(
        ActivityResultContracts.CreateDocument("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
    ) { uri ->
        uri?.let { viewModel.exportToUri(context, it) }
    }

    Surface(modifier = Modifier.fillMaxSize(), color = MaterialTheme.colorScheme.background) {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(
                    brush = Brush.verticalGradient(
                        listOf(
                            ComposeColor(0xFFF7F1E7),
                            ComposeColor(0xFFF9F5EE),
                            ComposeColor(0xFFF0EAE0),
                        )
                    )
                ),
        ) {
            Backdrop()
            LazyColumn(
                modifier = Modifier.fillMaxSize(),
                contentPadding = PaddingValues(horizontal = 16.dp, vertical = 18.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp),
            ) {
                item { RevealCard { HeroHeader() } }
                item {
                    RevealCard(index = 1) {
                        ActionPanel(
                            sourceName = uiState.sourceName,
                            isLoading = uiState.isLoading,
                            canExport = uiState.report != null,
                            error = uiState.error,
                            exportMessage = uiState.exportMessage,
                            onImport = {
                                importLauncher.launch(
                                    arrayOf("text/*", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
                                )
                            },
                            onExport = { exportLauncher.launch("student_grade_report.xlsx") },
                        )
                    }
                }
                uiState.report?.let { report ->
                    item { RevealCard(index = 2) { SummarySection(report.summary) } }
                    item { RevealCard(index = 3) { ChartSection(uiState.chart.points) } }
                    item { RevealCard(index = 4) { ResultsPreview(report.results) } }
                    item { RevealCard(index = 5) { IssuesSection(report.issues) } }
                }
            }
        }
    }
}

@Composable
private fun Backdrop() {
    Box(modifier = Modifier.fillMaxSize()) {
        GlowOrb(
            modifier = Modifier.align(Alignment.TopStart).padding(start = 8.dp, top = 12.dp),
            size = 180.dp,
            colors = listOf(ComposeColor(0x55B8743C), ComposeColor(0x00B8743C)),
        )
        GlowOrb(
            modifier = Modifier.align(Alignment.TopEnd).padding(top = 96.dp),
            size = 220.dp,
            colors = listOf(ComposeColor(0x4424706A), ComposeColor(0x0024706A)),
        )
        GlowOrb(
            modifier = Modifier.align(Alignment.BottomCenter).padding(bottom = 24.dp),
            size = 210.dp,
            colors = listOf(ComposeColor(0x3318314F), ComposeColor(0x0018314F)),
        )
    }
}

@Composable
private fun GlowOrb(modifier: Modifier, size: Dp, colors: List<ComposeColor>) {
    Box(
        modifier = modifier
            .size(size)
            .background(brush = Brush.radialGradient(colors), shape = CircleShape),
    )
}

@Composable
private fun HeroHeader() {
    Card(
        shape = RoundedCornerShape(30.dp),
        colors = CardDefaults.cardColors(containerColor = ComposeColor.Transparent),
        elevation = CardDefaults.cardElevation(defaultElevation = 8.dp),
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(
                    brush = Brush.linearGradient(
                        listOf(
                            ComposeColor(0xFF10233A),
                            ComposeColor(0xFF1A3550),
                            ComposeColor(0xFF2A556D),
                        )
                    )
                )
                .padding(22.dp),
        ) {
            BoxWithConstraints {
                val wide = maxWidth > 720.dp
                val content: @Composable () -> Unit = {
                    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                        HeroChip(icon = Icons.Rounded.AutoAwesome, label = "Student Grade Calculator")
                        Text(
                            text = "Student Grade\nCalculator",
                            style = MaterialTheme.typography.displayMedium,
                            color = ComposeColor.White,
                        )
                        Text(
                            text = "Import class marks, check the results, and export the final report.",
                            style = MaterialTheme.typography.bodyLarge,
                            color = ComposeColor(0xFFE7EEF7),
                        )
                        Row(
                            modifier = Modifier.horizontalScroll(rememberScrollState()),
                            horizontalArrangement = Arrangement.spacedBy(10.dp),
                        ) {
                            HeroPill("Input", "CSV and XLSX files")
                            HeroPill("Output", "Summary and Excel report")
                            HeroPill("Pass Mark", "65 and above")
                        }
                    }
                }
                val note: @Composable () -> Unit = {
                    Column(
                        modifier = Modifier
                            .clip(RoundedCornerShape(24.dp))
                            .background(ComposeColor.White.copy(alpha = 0.10f))
                            .border(1.dp, ComposeColor.White.copy(alpha = 0.12f), RoundedCornerShape(24.dp))
                            .padding(18.dp),
                        verticalArrangement = Arrangement.spacedBy(10.dp),
                    ) {
                        Text(
                            text = "Quick notes",
                            style = MaterialTheme.typography.titleMedium,
                            color = ComposeColor.White,
                        )
                        Text(
                            text = "The app checks each row, calculates the final mark, and lists missing or invalid data before export.",
                            style = MaterialTheme.typography.bodyMedium,
                            color = ComposeColor(0xFFE3ECF6),
                        )
                        HeroMetric("Main Sheets", "Grades, summary, issues, chart")
                        HeroMetric("Rule Used", "Invalid rows are marked X")
                    }
                }

                if (wide) {
                    Row(horizontalArrangement = Arrangement.spacedBy(18.dp)) {
                        Box(modifier = Modifier.weight(1.5f)) { content() }
                        Box(modifier = Modifier.weight(1f)) { note() }
                    }
                } else {
                    Column(verticalArrangement = Arrangement.spacedBy(16.dp)) {
                        content()
                        note()
                    }
                }
            }
        }
    }
}

@Composable
private fun HeroChip(icon: ImageVector, label: String) {
    Row(
        modifier = Modifier
            .clip(RoundedCornerShape(999.dp))
            .background(ComposeColor(0x29B8743C))
            .padding(horizontal = 14.dp, vertical = 9.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        androidx.compose.material3.Icon(icon, contentDescription = null, tint = ComposeColor(0xFFF6D0A7))
        Text(text = label, style = MaterialTheme.typography.labelLarge, color = ComposeColor.White)
    }
}

@Composable
private fun HeroPill(title: String, value: String) {
    Column(
        modifier = Modifier
            .clip(RoundedCornerShape(20.dp))
            .background(ComposeColor.White.copy(alpha = 0.10f))
            .padding(horizontal = 14.dp, vertical = 12.dp),
    ) {
        Text(text = title.uppercase(Locale.US), style = MaterialTheme.typography.labelMedium, color = ComposeColor(0xFFF6D0A7))
        Text(text = value, style = MaterialTheme.typography.bodyMedium, color = ComposeColor.White)
    }
}

@Composable
private fun HeroMetric(label: String, value: String) {
    Column(verticalArrangement = Arrangement.spacedBy(2.dp)) {
        Text(text = label.uppercase(Locale.US), style = MaterialTheme.typography.labelMedium, color = ComposeColor(0xFFF6D0A7))
        Text(text = value, style = MaterialTheme.typography.titleMedium, color = ComposeColor.White)
    }
}

@Composable
private fun ActionPanel(
    sourceName: String,
    isLoading: Boolean,
    canExport: Boolean,
    error: String?,
    exportMessage: String?,
    onImport: () -> Unit,
    onExport: () -> Unit,
) {
    EditorialPanel(
        eyebrow = "Import",
        title = "Load marks, calculate grades, and export the result.",
        subtitle = "Import CSV or XLSX, keep the latest duplicate row, and list any issue before export.",
    ) {
        Column(verticalArrangement = Arrangement.spacedBy(14.dp)) {
            Row(
                modifier = Modifier.horizontalScroll(rememberScrollState()),
                horizontalArrangement = Arrangement.spacedBy(10.dp),
            ) {
                FeatureChip(icon = Icons.Rounded.RuleFolder, label = "Grade rules")
                FeatureChip(icon = Icons.Rounded.AutoGraph, label = "Summary chart")
                FeatureChip(icon = Icons.Rounded.Description, label = "Excel export")
            }

            Row(horizontalArrangement = Arrangement.spacedBy(12.dp), modifier = Modifier.fillMaxWidth()) {
                Button(
                    onClick = onImport,
                    modifier = Modifier.weight(1f),
                    colors = ButtonDefaults.buttonColors(containerColor = ComposeColor(0xFF18314F)),
                ) {
                    androidx.compose.material3.Icon(Icons.Rounded.UploadFile, contentDescription = null)
                    Spacer(modifier = Modifier.width(8.dp))
                    Text("Import file")
                }
                OutlinedButton(
                    onClick = onExport,
                    enabled = canExport && !isLoading,
                    modifier = Modifier.weight(1f),
                ) {
                    androidx.compose.material3.Icon(Icons.Rounded.Download, contentDescription = null)
                    Spacer(modifier = Modifier.width(8.dp))
                    Text("Export workbook")
                }
            }

            if (isLoading) {
                LinearProgressIndicator(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(999.dp)),
                    color = ComposeColor(0xFFB8743C),
                    trackColor = ComposeColor(0xFFE8DDD0),
                )
            }

            StatusCard(
                title = "Source file",
                body = sourceName,
                accent = ComposeColor(0xFF18314F),
                icon = Icons.Rounded.Description,
            )
            StatusCard(
                title = "Processing rule",
                body = "If the same student appears more than once, the last row is kept. Invalid or missing marks are marked X.",
                accent = ComposeColor(0xFF24706A),
                icon = Icons.Rounded.Verified,
            )
            error?.let {
                StatusCard(
                    title = "Current alert",
                    body = it,
                    accent = ComposeColor(0xFFA33B2F),
                    icon = Icons.Rounded.WarningAmber,
                )
            }
            exportMessage?.let {
                StatusCard(
                    title = "Latest export",
                    body = it,
                    accent = ComposeColor(0xFF336C4F),
                    icon = Icons.Rounded.WorkspacePremium,
                )
            }
        }
    }
}

@Composable
private fun FeatureChip(icon: ImageVector, label: String) {
    Row(
        modifier = Modifier
            .clip(RoundedCornerShape(999.dp))
            .background(ComposeColor(0xFFF4ECE0))
            .padding(horizontal = 12.dp, vertical = 9.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        androidx.compose.material3.Icon(icon, contentDescription = null, tint = ComposeColor(0xFFB8743C))
        Text(text = label, style = MaterialTheme.typography.labelLarge, color = ComposeColor(0xFF243142))
    }
}

@Composable
private fun StatusCard(title: String, body: String, accent: ComposeColor, icon: ImageVector) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(24.dp))
            .background(accent.copy(alpha = 0.07f))
            .border(1.dp, accent.copy(alpha = 0.12f), RoundedCornerShape(24.dp))
            .padding(16.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        Box(
            modifier = Modifier
                .size(42.dp)
                .clip(RoundedCornerShape(14.dp))
                .background(accent.copy(alpha = 0.12f)),
            contentAlignment = Alignment.Center,
        ) {
            androidx.compose.material3.Icon(icon, contentDescription = null, tint = accent)
        }
        Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
            Text(text = title, style = MaterialTheme.typography.labelLarge, color = accent)
            Text(text = body, style = MaterialTheme.typography.bodyMedium, color = ComposeColor(0xFF2E3A48))
        }
    }
}

@Composable
private fun SummarySection(summary: ProcessingSummary) {
    val cards = listOf(
        SummaryCardData("Rows Processed", summary.totalRows.toString(), "Rows found in the file", ComposeColor(0xFF18314F)),
        SummaryCardData("Average Score", "%.2f".format(summary.average), "Mean of graded scores", ComposeColor(0xFF24706A)),
        SummaryCardData("Median Score", "%.2f".format(summary.median), "Middle graded score", ComposeColor(0xFFB8743C)),
        SummaryCardData("Pass Rate", "%.2f%%".format(summary.passRate), "Students with 65 and above", ComposeColor(0xFF72408C)),
    )

    EditorialPanel(
        eyebrow = "Summary",
        title = "Main values from the current file.",
        subtitle = "This section shows the total rows, average, median, and pass rate.",
    ) {
        Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
            cards.chunked(2).forEach { row ->
                Row(horizontalArrangement = Arrangement.spacedBy(12.dp), modifier = Modifier.fillMaxWidth()) {
                    row.forEach { card ->
                        SummaryCard(data = card, modifier = Modifier.weight(1f))
                    }
                    if (row.size == 1) {
                        Spacer(modifier = Modifier.weight(1f))
                    }
                }
            }
        }
    }
}

private data class SummaryCardData(
    val label: String,
    val value: String,
    val note: String,
    val accent: ComposeColor,
)

@Composable
private fun SummaryCard(data: SummaryCardData, modifier: Modifier = Modifier) {
    Card(
        modifier = modifier,
        shape = RoundedCornerShape(24.dp),
        colors = CardDefaults.cardColors(containerColor = data.accent),
        elevation = CardDefaults.cardElevation(defaultElevation = 6.dp),
    ) {
        Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
            Text(text = data.label, color = ComposeColor.White.copy(alpha = 0.84f), style = MaterialTheme.typography.labelLarge)
            Text(text = data.value, color = ComposeColor.White, style = MaterialTheme.typography.headlineMedium)
            Text(text = data.note, color = ComposeColor.White.copy(alpha = 0.82f), style = MaterialTheme.typography.bodyMedium)
        }
    }
}

@Composable
private fun ChartSection(points: List<ChartPoint>) {
    EditorialPanel(
        eyebrow = "Grades",
        title = "Grade distribution",
        subtitle = "The chart and bars show the number of students in each grade.",
    ) {
        if (points.isEmpty()) {
            Text("No chart data available.", style = MaterialTheme.typography.bodyLarge)
        } else {
            val total = points.fold(0) { sum, current -> sum + current.count }
            Column(verticalArrangement = Arrangement.spacedBy(16.dp)) {
                ChartCard(points)
                points.forEach { point ->
                    LegendBar(point = point, total = total)
                }
            }
        }
    }
}

@Composable
private fun ChartCard(points: List<ChartPoint>) {
    Card(
        shape = RoundedCornerShape(28.dp),
        colors = CardDefaults.cardColors(containerColor = ComposeColor(0xFFF7F1E7)),
    ) {
        AndroidView(
            modifier = Modifier
                .fillMaxWidth()
                .height(300.dp)
                .padding(8.dp),
            factory = { context ->
                PieChart(context).apply {
                    description.isEnabled = false
                    setHoleColor(Color.TRANSPARENT)
                    holeRadius = 52f
                    transparentCircleRadius = 58f
                    setEntryLabelColor(Color.WHITE)
                    setEntryLabelTextSize(12f)
                    setDrawCenterText(true)
                    centerText = "Grades"
                    setCenterTextSize(16f)
                    legend.verticalAlignment = Legend.LegendVerticalAlignment.BOTTOM
                    legend.horizontalAlignment = Legend.LegendHorizontalAlignment.CENTER
                    legend.orientation = Legend.LegendOrientation.HORIZONTAL
                    legend.isWordWrapEnabled = true
                }
            },
            update = { chart ->
                val entries = points.map { PieEntry(it.count.toFloat(), it.label) }
                val dataSet = PieDataSet(entries, "Grades").apply {
                    sliceSpace = 3f
                    valueTextSize = 12f
                    valueTextColor = Color.WHITE
                    colors = listOf(
                        Color.parseColor("#18314F"),
                        Color.parseColor("#24706A"),
                        Color.parseColor("#B8743C"),
                        Color.parseColor("#72408C"),
                        Color.parseColor("#2E5D91"),
                        Color.parseColor("#A33B2F"),
                        Color.parseColor("#8A5A2A"),
                        Color.parseColor("#7B8BA4"),
                    )
                }
                chart.data = PieData(dataSet)
                chart.invalidate()
            },
        )
    }
}

@Composable
private fun LegendBar(point: ChartPoint, total: Int) {
    val ratio = if (total == 0) 0f else point.count.toFloat() / total.toFloat()
    val accent = gradeTone(point.label)

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(22.dp))
            .background(ComposeColor.White)
            .border(1.dp, ComposeColor(0xFFE6DCCC), RoundedCornerShape(22.dp))
            .padding(14.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Box(
                modifier = Modifier
                    .size(14.dp)
                    .clip(CircleShape)
                    .background(accent),
            )
            Spacer(modifier = Modifier.width(10.dp))
            Text(text = "Grade ${point.label}", style = MaterialTheme.typography.titleMedium, color = ComposeColor(0xFF1A2431))
            Spacer(modifier = Modifier.weight(1f))
            Text(text = "${point.count} students", style = MaterialTheme.typography.bodyMedium, color = ComposeColor(0xFF596270))
        }
        LinearProgressIndicator(
            progress = { ratio },
            modifier = Modifier
                .fillMaxWidth()
                .height(10.dp)
                .clip(RoundedCornerShape(999.dp)),
            color = accent,
            trackColor = ComposeColor(0xFFF0E5D7),
        )
        Text(
            text = "${(ratio * 100f).toStringAsFixed(1)}% of the processed class",
            style = MaterialTheme.typography.bodySmall,
            color = ComposeColor(0xFF697386),
        )
    }
}

@Composable
private fun ResultsPreview(results: List<GradeResult>) {
    // I cap the on-screen preview so larger classes stay smooth on mobile.
    val preview = results.take(15)
    val widths = listOf(70.dp, 180.dp, 150.dp, 100.dp, 90.dp, 80.dp, 165.dp)
    val headers = listOf("Row", "Name", "Matricule", "Score", "Letter", "Pass", "Source")

    EditorialPanel(
        eyebrow = "Preview",
        title = "Processed rows",
        subtitle = "First rows from the processed file.",
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .horizontalScroll(rememberScrollState()),
        ) {
            Row(
                modifier = Modifier
                    .clip(RoundedCornerShape(topStart = 22.dp, topEnd = 22.dp))
                    .background(ComposeColor(0xFF18314F)),
            ) {
                headers.forEachIndexed { index, value ->
                    PreviewCell(widths[index], value, textColor = ComposeColor.White, fontWeight = FontWeight.Bold)
                }
            }
            preview.forEachIndexed { index, item ->
                val background = if (index % 2 == 0) ComposeColor(0xFFFFFCF6) else ComposeColor(0xFFF7F1E8)
                Row(
                    modifier = Modifier
                        .background(background)
                        .padding(vertical = 2.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    PreviewCell(widths[0], item.rowIndex.toString())
                    PreviewCell(widths[1], item.name.orEmpty().ifBlank { "-" })
                    PreviewCell(widths[2], item.matricule.orEmpty().ifBlank { "-" })
                    PreviewCell(widths[3], item.finalScore?.toStringAsFixed(2) ?: "-", textAlign = TextAlign.End)
                    Box(modifier = Modifier.width(widths[4]).padding(horizontal = 12.dp, vertical = 10.dp)) {
                        GradeBadge(item.letter.label)
                    }
                    PreviewCell(widths[5], if (item.pass) "Yes" else "No")
                    PreviewCell(widths[6], item.source)
                }
                HorizontalDivider(color = ComposeColor(0xFFEAE1D4))
            }
        }
    }
}

@Composable
private fun PreviewCell(
    width: Dp,
    text: String,
    textColor: ComposeColor = ComposeColor(0xFF243142),
    fontWeight: FontWeight = FontWeight.Medium,
    textAlign: TextAlign = TextAlign.Start,
) {
    Text(
        text = text,
        modifier = Modifier.width(width).padding(horizontal = 12.dp, vertical = 12.dp),
        style = MaterialTheme.typography.bodyMedium,
        color = textColor,
        fontWeight = fontWeight,
        textAlign = textAlign,
    )
}

@Composable
private fun GradeBadge(letter: String) {
    val tone = gradeTone(letter)
    Text(
        text = letter,
        modifier = Modifier
            .clip(RoundedCornerShape(999.dp))
            .background(tone.copy(alpha = 0.12f))
            .padding(horizontal = 12.dp, vertical = 6.dp),
        style = MaterialTheme.typography.labelLarge,
        color = tone,
    )
}

@Composable
private fun IssuesSection(issues: List<ValidationIssue>) {
    EditorialPanel(
        eyebrow = "Issues",
        title = "Rows that need attention",
        subtitle = "Missing, invalid, or duplicate data is listed here.",
    ) {
        if (issues.isEmpty()) {
            Text("No issues were found in this file.", style = MaterialTheme.typography.bodyLarge)
        } else {
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                issues.take(25).forEach { issue ->
                    IssueCard(issue)
                }
                if (issues.size > 25) {
                    Text(
                        text = "Showing the first 25 issues.",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.primary,
                    )
                }
            }
        }
    }
}

@Composable
private fun IssueCard(issue: ValidationIssue) {
    val accent = when (issue.severity) {
        IssueSeverity.ERROR -> ComposeColor(0xFFA33B2F)
        IssueSeverity.WARNING -> ComposeColor(0xFF9C6A1B)
        IssueSeverity.INFO -> ComposeColor(0xFF2A5B85)
    }

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(22.dp))
            .background(accent.copy(alpha = 0.08f))
            .border(1.dp, accent.copy(alpha = 0.12f), RoundedCornerShape(22.dp)),
    ) {
        Box(modifier = Modifier.width(6.dp).height(110.dp).background(accent))
        Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                androidx.compose.material3.Icon(Icons.Rounded.WarningAmber, contentDescription = null, tint = accent)
                Spacer(modifier = Modifier.width(10.dp))
                Text(text = issue.code, color = accent, style = MaterialTheme.typography.titleMedium)
                Spacer(modifier = Modifier.weight(1f))
                Text(
                    text = "Row ${issue.rowIndex}",
                    modifier = Modifier
                        .clip(RoundedCornerShape(999.dp))
                        .background(accent.copy(alpha = 0.12f))
                        .padding(horizontal = 10.dp, vertical = 6.dp),
                    color = accent,
                    style = MaterialTheme.typography.labelLarge,
                )
            }
            Text(text = issue.message, style = MaterialTheme.typography.bodyMedium, color = ComposeColor(0xFF2F3745))
        }
    }
}

@Composable
private fun EditorialPanel(
    eyebrow: String,
    title: String,
    subtitle: String,
    content: @Composable () -> Unit,
) {
    Card(
        shape = RoundedCornerShape(30.dp),
        colors = CardDefaults.cardColors(containerColor = ComposeColor.White.copy(alpha = 0.93f)),
        elevation = CardDefaults.cardElevation(defaultElevation = 8.dp),
    ) {
        Column(modifier = Modifier.padding(22.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
            Text(text = eyebrow.uppercase(Locale.US), style = MaterialTheme.typography.labelMedium, color = ComposeColor(0xFFB8743C))
            Text(text = title, style = MaterialTheme.typography.headlineMedium, color = ComposeColor(0xFF18212E))
            Text(text = subtitle, style = MaterialTheme.typography.bodyMedium, color = ComposeColor(0xFF596270))
            Spacer(modifier = Modifier.height(10.dp))
            content()
        }
    }
}

@Composable
private fun RevealCard(index: Int = 0, content: @Composable () -> Unit) {
    AnimatedVisibility(
        visible = true,
        enter = fadeIn() + slideInVertically(initialOffsetY = { it / 4 }),
    ) {
        Box(modifier = Modifier.padding(top = index.dp)) {
            content()
        }
    }
}

private fun gradeTone(letter: String): ComposeColor =
    when (letter) {
        "A" -> ComposeColor(0xFF24706A)
        "B+", "B" -> ComposeColor(0xFF1C5C84)
        "C+", "C" -> ComposeColor(0xFFB8743C)
        "D+", "D" -> ComposeColor(0xFF8A5A2A)
        "F", "X" -> ComposeColor(0xFFA33B2F)
        else -> ComposeColor(0xFF6B7280)
    }

private fun Float.toStringAsFixed(decimals: Int): String = "%.${decimals}f".format(this)

private fun Double.toStringAsFixed(decimals: Int): String = "%.${decimals}f".format(this)
