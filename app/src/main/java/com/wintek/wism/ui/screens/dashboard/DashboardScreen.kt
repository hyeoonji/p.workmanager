package com.wintek.wism.ui.screens.dashboard

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import com.wintek.wism.ui.theme.WismTheme

@Composable
fun DashboardScreen(
    modifier: Modifier = Modifier,
    onPostClick: (Int) -> Unit = {}
) {
    Box(modifier = modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        Text("홈 대시보드 (P-02)")
    }
}

@Preview(showBackground = true)
@Composable
private fun DashboardScreenPreview() {
    WismTheme {
        DashboardScreen()
    }
}
