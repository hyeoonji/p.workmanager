import '../data/models/comment.dart';
import '../data/models/memo.dart';
import '../data/models/memo_project.dart';
import '../data/models/user_ref.dart';
import 'memo_draft.dart';

/// 메모 목록 조회 범위.
enum MemoScope { all, my, bookmarks }

/// 정렬.
enum MemoSort { latest, oldest, urgentFirst }

abstract class MemoRepository {
  Future<List<Memo>> list({
    required MemoScope scope,
    String? category,
    String? priority,
    String? query,
    MemoSort sort = MemoSort.latest,
  });

  Future<Memo> detail(int id);
  Future<Memo> create(MemoDraft draft);
  Future<Memo> update(int id, MemoDraft draft);
  Future<void> delete(int id);
  Future<Memo> setBookmark(int id, {required bool bookmarked});
  Future<Memo> markRead(int id);
  Future<Comment> addComment(int memoId, String content);
  Future<void> updateComment(int memoId, int commentId, String content);
  Future<void> deleteComment(int memoId, int commentId);

  /// 담당자 태그 자동완성.
  Future<List<UserRef>> searchUsers(String query);

  /// 사업(프로젝트) 자동완성.
  Future<List<MemoProject>> searchProjects(String query);
}
