package com.wintek.wism.data.model

data class Comment(
    val id: Int,
    val author: Author,
    val content: String,
    val type: String = "comment",
    val createdAt: String
)
