package com.wintek.wism.navigation

import androidx.compose.runtime.Composable
import androidx.navigation.NavHostController
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.navArgument
import com.wintek.wism.ui.screens.MainScreen
import com.wintek.wism.ui.screens.auth.LoginScreen
import com.wintek.wism.ui.screens.memo.MemoDetailScreen
import com.wintek.wism.ui.screens.memo.WriteMemoScreen
import com.wintek.wism.ui.screens.splash.SplashScreen

@Composable
fun WismNavGraph(navController: NavHostController) {
    NavHost(
        navController = navController,
        startDestination = Screen.Splash.route
    ) {
        composable(Screen.Splash.route) {
            SplashScreen(
                onNavigateToLogin = {
                    navController.navigate(Screen.Login.route) {
                        popUpTo(Screen.Splash.route) { inclusive = true }
                    }
                },
                onNavigateToMain = {
                    navController.navigate(Screen.Main.route) {
                        popUpTo(Screen.Splash.route) { inclusive = true }
                    }
                }
            )
        }

        composable(Screen.Login.route) {
            LoginScreen(
                onLoginSuccess = {
                    navController.navigate(Screen.Main.route) {
                        popUpTo(Screen.Login.route) { inclusive = true }
                    }
                }
            )
        }

        composable(Screen.Main.route) {
            MainScreen(
                onNavigateToDetail = { postId ->
                    navController.navigate(Screen.MemoDetail.createRoute(postId))
                },
                onNavigateToWrite = { postId ->
                    navController.navigate(Screen.WriteMemo.createRoute(postId))
                },
                onLogout = {
                    navController.navigate(Screen.Login.route) {
                        popUpTo(Screen.Splash.route) { inclusive = true }
                    }
                }
            )
        }

        composable(
            route = Screen.MemoDetail.route,
            arguments = listOf(navArgument("postId") { type = NavType.IntType })
        ) { backStackEntry ->
            val postId = backStackEntry.arguments?.getInt("postId") ?: return@composable
            MemoDetailScreen(
                postId = postId,
                onBack = { navController.popBackStack() },
                onEdit = { navController.navigate(Screen.WriteMemo.createRoute(postId)) }
            )
        }

        composable(
            route = Screen.WriteMemo.route,
            arguments = listOf(navArgument("postId") { type = NavType.StringType; defaultValue = "" })
        ) { backStackEntry ->
            val postIdStr = backStackEntry.arguments?.getString("postId")
            val postId = postIdStr?.toIntOrNull()
            WriteMemoScreen(
                postId = postId,
                onBack = { navController.popBackStack() },
                onSaved = { navController.popBackStack() }
            )
        }
    }
}
