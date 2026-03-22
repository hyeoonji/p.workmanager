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
fun MemoDetailScreen(
    postId: Int,
    onBack: () -> Unit = {},
    onEdit: () -> Unit = {}
) {
    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        Text("게시글 상세 #$postId (P-08)")
    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
private fun MemoDetailScreenPreview() {
    WismTheme {
        MemoDetailScreen(postId = 1)
    }
}
