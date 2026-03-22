package com.wintek.wism.navigation

sealed class Screen(val route: String) {
    object Splash : Screen("splash")
    object Login : Screen("login")
    object Main : Screen("main")
    object Dashboard : Screen("dashboard")
    object AllMemos : Screen("all_memos")
    object MyMemos : Screen("my_memos")
    object Bookmarks : Screen("bookmarks")
    object Profile : Screen("profile")
    object WriteMemo : Screen("write_memo?postId={postId}") {
        fun createRoute(postId: Int? = null) =
            if (postId != null) "write_memo?postId=$postId" else "write_memo"
    }
    object MemoDetail : Screen("memo_detail/{postId}") {
        fun createRoute(postId: Int) = "memo_detail/$postId"
    }
}
