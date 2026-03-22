package com.wintek.wism.data.model

enum class Category(val label: String, val value: String) {
    SCHEDULE("일정", "schedule"),
    ISSUE("이슈", "issue"),
    DECISION("결정사항", "decision"),
    MEETING("회의록", "meeting"),
    OTHER("기타", "other");

    companion object {
        fun fromValue(value: String): Category = entries.first { it.value == value }
    }
}

enum class Priority(val label: String, val value: String) {
    URGENT("긴급", "urgent"),
    NORMAL("일반", "normal");

    companion object {
        fun fromValue(value: String): Priority = entries.first { it.value == value }
    }
}

enum class NotificationType(val value: String) {
    COMMENT("comment"),
    MENTION("mention"),
    STATUS("status"),
    URGENT("urgent");

    companion object {
        fun fromValue(value: String): NotificationType = entries.first { it.value == value }
    }
}
