package com.romualdsigning.studentgradecalc.domain.service

import android.content.Context
import android.net.Uri
import com.romualdsigning.studentgradecalc.domain.model.StudentInputRow

interface StudentInputParser {
    suspend fun parse(context: Context, uri: Uri): List<StudentInputRow>
}
