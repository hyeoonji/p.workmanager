package com.wintek.wism.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable

private val WismColorScheme = lightColorScheme(
    primary = Primary,
    onPrimary = Background,
    primaryContainer = PrimaryLight,
    secondary = Primary,
    background = Background,
    surface = Background,
    surfaceVariant = Surface,
    onBackground = OnSurface,
    onSurface = OnSurface,
    outline = Border,
    error = Destructive
)

@Composable
fun WismTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = WismColorScheme,
        typography = Typography,
        content = content
    )
}
