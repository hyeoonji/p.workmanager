package com.wintek.wism.ui.components

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Bookmark
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.ListAlt
import androidx.compose.material.icons.filled.NoteAlt
import androidx.compose.material.icons.filled.Person
import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.tooling.preview.Preview
import com.wintek.wism.ui.theme.WismTheme
import com.wintek.wism.ui.theme.TextSecondary
import com.wintek.wism.ui.theme.Primary

enum class BottomNavItem(
    val label: String,
    val icon: ImageVector,
    val route: String
) {
    HOME("홈", Icons.Default.Home, "dashboard"),
    ALL_MEMOS("전체", Icons.Default.ListAlt, "all_memos"),
    MY_MEMOS("내 글", Icons.Default.NoteAlt, "my_memos"),
    BOOKMARKS("북마크", Icons.Default.Bookmark, "bookmarks"),
    PROFILE("프로필", Icons.Default.Person, "profile")
}

@Composable
fun WismBottomNavBar(
    currentRoute: String,
    onItemSelected: (BottomNavItem) -> Unit
) {
    NavigationBar(
        containerColor = com.wintek.wism.ui.theme.Background
    ) {
        BottomNavItem.entries.forEach { item ->
            val selected = currentRoute == item.route
            NavigationBarItem(
                selected = selected,
                onClick = { onItemSelected(item) },
                icon = { Icon(item.icon, contentDescription = item.label) },
                label = { Text(item.label) },
                colors = NavigationBarItemDefaults.colors(
                    selectedIconColor = Primary,
                    selectedTextColor = Primary,
                    unselectedIconColor = TextSecondary,
                    unselectedTextColor = TextSecondary,
                    indicatorColor = Primary.copy(alpha = 0.1f)
                )
            )
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun WismBottomNavBarPreview() {
    WismTheme {
        WismBottomNavBar(currentRoute = "dashboard", onItemSelected = {})
    }
}
