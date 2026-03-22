package com.wintek.wism.ui.screens.memo

import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.hilt.navigation.compose.hiltViewModel
import com.wintek.wism.ui.components.MemoList
import com.wintek.wism.ui.theme.WismTheme
import com.wintek.wism.viewmodel.PostViewModel

@Composable
fun MyMemosScreen(
    modifier: Modifier = Modifier,
    onPostClick: (Int) -> Unit = {},
    viewModel: PostViewModel = hiltViewModel()
) {
    val state by viewModel.listState.collectAsState()

    LaunchedEffect(Unit) {
        viewModel.loadMyPosts()
    }

    MemoList(
        modifier = modifier,
        posts = state.posts,
        onPostClick = onPostClick,
        onToggleBookmark = { viewModel.toggleBookmark(it) },
        onSearch = { query ->
            // 클라이언트 필터링은 ViewModel에서 처리하지 않고 리로드
            viewModel.loadMyPosts()
        },
        emptyMessage = "작성한 메모가 없습니다"
    )
}

@Preview(showBackground = true, showSystemUi = true)
@Composable
private fun MyMemosScreenPreview() {
    WismTheme { MyMemosScreen() }
}
