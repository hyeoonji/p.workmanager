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
fun BookmarksScreen(
    modifier: Modifier = Modifier,
    onPostClick: (Int) -> Unit = {}
) {
    Box(modifier = modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        Text("북마크 (P-05)")
    }
}

@Preview(showBackground = true)
@Composable
private fun BookmarksScreenPreview() {
    WismTheme {
        BookmarksScreen()
    }
}
