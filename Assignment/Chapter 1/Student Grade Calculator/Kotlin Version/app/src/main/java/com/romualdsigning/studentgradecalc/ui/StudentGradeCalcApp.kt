package com.romualdsigning.studentgradecalc.ui

import androidx.compose.runtime.Composable
import com.romualdsigning.studentgradecalc.ui.screens.GradeCalculatorScreen
import com.romualdsigning.studentgradecalc.ui.theme.StudentGradeCalcTheme

@Composable
fun StudentGradeCalcApp() {
    StudentGradeCalcTheme {
        GradeCalculatorScreen()
    }
}
