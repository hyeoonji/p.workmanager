package com.wintek.wism

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.navigation.compose.rememberNavController
import com.wintek.wism.navigation.WismNavGraph
import com.wintek.wism.ui.theme.WismTheme
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            WismTheme {
                val navController = rememberNavController()
                WismNavGraph(navController = navController)
            }
        }
    }
}
