package com.wintek.wism.ui.screens

import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material3.Badge
import androidx.compose.material3.BadgedBox
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import com.wintek.wism.ui.theme.WismTheme
import com.wintek.wism.ui.components.BottomNavItem
import com.wintek.wism.ui.components.WismBottomNavBar
import com.wintek.wism.ui.screens.dashboard.DashboardScreen
import com.wintek.wism.ui.screens.memo.AllMemosScreen
import com.wintek.wism.ui.screens.memo.BookmarksScreen
import com.wintek.wism.ui.screens.memo.MyMemosScreen
import com.wintek.wism.ui.screens.profile.ProfileScreen
import com.wintek.wism.ui.theme.Primary

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MainScreen(
    onNavigateToDetail: (Int) -> Unit,
    onNavigateToWrite: (Int?) -> Unit,
    onLogout: () -> Unit
) {
    var currentTab by remember { mutableStateOf(BottomNavItem.HOME) }
    var showNotificationPanel by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(currentTab.label) },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = Color.White
                ),
                actions = {
                    IconButton(onClick = { showNotificationPanel = true }) {
                        BadgedBox(
                            badge = { Badge { Text("0") } }
                        ) {
                            Icon(
                                Icons.Default.Notifications,
                                contentDescription = "알림"
                            )
                        }
                    }
                }
            )
        },
        bottomBar = {
            WismBottomNavBar(
                currentRoute = currentTab.route,
                onItemSelected = { currentTab = it }
            )
        },
        floatingActionButton = {
            FloatingActionButton(
                onClick = { onNavigateToWrite(null) },
                containerColor = Primary,
                contentColor = Color.White,
                shape = CircleShape
            ) {
                Icon(Icons.Default.Edit, contentDescription = "글쓰기")
            }
        }
    ) { innerPadding ->
        val modifier = Modifier.padding(innerPadding)
        when (currentTab) {
            BottomNavItem.HOME -> DashboardScreen(
                modifier = modifier,
                onPostClick = onNavigateToDetail
            )
            BottomNavItem.ALL_MEMOS -> AllMemosScreen(
                modifier = modifier,
                onPostClick = onNavigateToDetail
            )
            BottomNavItem.MY_MEMOS -> MyMemosScreen(
                modifier = modifier,
                onPostClick = onNavigateToDetail
            )
            BottomNavItem.BOOKMARKS -> BookmarksScreen(
                modifier = modifier,
                onPostClick = onNavigateToDetail
            )
            BottomNavItem.PROFILE -> ProfileScreen(
                modifier = modifier,
                onLogout = onLogout
            )
        }
    }
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
private fun MainScreenPreview() {
    WismTheme {
        MainScreen(onNavigateToDetail = {}, onNavigateToWrite = {}, onLogout = {})
    }
}
