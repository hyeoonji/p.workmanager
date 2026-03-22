package com.wintek.wism.ui.screens.memo

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import com.wintek.wism.ui.theme.WismTheme

@Composable
fun WriteMemoScreen(
    postId: Int? = null,
    onBack: () -> Unit = {},
    onSaved: () -> Unit = {}
) {
    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        Text(if (postId != null) "메모 수정 (P-07)" else "새 메모 작성 (P-07)")
    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
private fun WriteMemoScreenPreview() {
    WismTheme {
        WriteMemoScreen()
    }
}
