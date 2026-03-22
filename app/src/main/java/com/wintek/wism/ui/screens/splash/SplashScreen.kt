package com.wintek.wism.ui.screens.splash

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.compose.ui.tooling.preview.Preview
import com.wintek.wism.ui.theme.Primary
import com.wintek.wism.ui.theme.WismTheme
import com.wintek.wism.viewmodel.AuthViewModel
import kotlinx.coroutines.delay

@Composable
fun SplashScreen(
    onNavigateToLogin: () -> Unit,
    onNavigateToMain: () -> Unit,
    viewModel: AuthViewModel = hiltViewModel()
) {
    val state by viewModel.state.collectAsState()

    LaunchedEffect(state.isLoading) {
        if (!state.isLoading) {
            delay(1000)
            if (state.isLoggedIn) {
                onNavigateToMain()
            } else {
                onNavigateToLogin()
            }
        }
    }

    Column(
        modifier = Modifier.fillMaxSize(),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text(
            text = "WISM",
            style = MaterialTheme.typography.headlineLarge,
            color = Primary
        )
        Spacer(modifier = Modifier.height(8.dp))
        Text(
            text = "Wintek Insight System Manager",
            style = MaterialTheme.typography.bodyMedium,
            color = com.wintek.wism.ui.theme.MutedText
        )
    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
private fun SplashScreenPreview() {
    WismTheme {
        SplashScreen(onNavigateToLogin = {}, onNavigateToMain = {})
    }
}
