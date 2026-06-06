import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../../memo/application/memo_providers.dart';

typedef ProfileStats = ({int memos, int comments, int bookmarks});

/// 활동 통계 (내 메모 / 댓글 / 북마크) — 메모 데이터에서 파생.
final profileStatsProvider = FutureProvider.autoDispose<ProfileStats>((ref) async {
  final memos = await ref.watch(allMemosProvider.future);
  final myId = ref.watch(authControllerProvider).user?.id;
  final myMemos = memos.where((m) => m.author.id == myId).length;
  final bookmarks = memos.where((m) => m.bookmarked).length;
  final comments = memos.fold<int>(
    0,
    (sum, m) => sum + m.comments.where((c) => c.author.id == myId).length,
  );
  return (memos: myMemos, comments: comments, bookmarks: bookmarks);
});

/// 푸시 알림 설정 (로컬, 인메모리 — 추후 영속화).
final pushEnabledProvider =
    NotifierProvider<PushEnabledNotifier, bool>(PushEnabledNotifier.new);

class PushEnabledNotifier extends Notifier<bool> {
  @override
  bool build() => true;
  void set(bool value) => state = value;
}
