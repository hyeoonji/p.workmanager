package com.wintek.wism.ui.screens.profile

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import com.wintek.wism.ui.theme.WismTheme

@Composable
fun ProfileScreen(
    modifier: Modifier = Modifier,
    onLogout: () -> Unit = {}
) {
    Box(modifier = modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        Text("프로필/설정 (P-06)")
    }
}

@Preview(showBackground = true)
@Composable
private fun ProfileScreenPreview() {
    WismTheme {
        ProfileScreen()
    }
}
