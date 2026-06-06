import 'package:dio/dio.dart';

import '../domain/memo_draft.dart';
import '../domain/memo_repository.dart';
import 'models/comment.dart';
import 'models/memo.dart';
import 'models/memo_project.dart';
import 'models/user_ref.dart';

/// 실서버 메모 리포지토리 (Dio). USE_MOCK_AUTH=false 일 때 사용.
class MemoRepositoryImpl implements MemoRepository {
  MemoRepositoryImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<Memo>> list({
    required MemoScope scope,
    String? category,
    String? priority,
    String? query,
    MemoSort sort = MemoSort.latest,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>('/memos', queryParameters: {
      'scope': scope.name,
      if (category != null && category != '전체') 'category': category,
      'priority': ?priority,
      if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
      'sort': sort.name,
    });
    final items = (res.data!['items'] as List)
        .map((e) => Memo.fromJson(e as Map<String, dynamic>))
        .toList();
    return items;
  }

  @override
  Future<Memo> detail(int id) async {
    final res = await _dio.get<Map<String, dynamic>>('/memos/$id');
    return Memo.fromJson(res.data!);
  }

  @override
  Future<Memo> create(MemoDraft draft) async {
    final res = await _dio.post<Map<String, dynamic>>('/memos', data: draft.toJson());
    return Memo.fromJson(res.data!);
  }

  @override
  Future<Memo> update(int id, MemoDraft draft) async {
    final res = await _dio.put<Map<String, dynamic>>('/memos/$id', data: draft.toJson());
    return Memo.fromJson(res.data!);
  }

  @override
  Future<void> delete(int id) async {
    await _dio.delete('/memos/$id');
  }

  @override
  Future<Memo> setBookmark(int id, {required bool bookmarked}) async {
    if (bookmarked) {
      await _dio.put('/memos/$id/bookmark');
    } else {
      await _dio.delete('/memos/$id/bookmark');
    }
    return detail(id);
  }

  @override
  Future<Memo> markRead(int id) async {
    await _dio.post('/memos/$id/read');
    return detail(id);
  }

  @override
  Future<Comment> addComment(int memoId, String content) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/memos/$memoId/comments',
      data: {'content': content, 'type': 'comment'},
    );
    return Comment.fromJson(res.data!);
  }

  @override
  Future<void> updateComment(int memoId, int commentId, String content) async {
    await _dio.put('/comments/$commentId', data: {'content': content});
  }

  @override
  Future<void> deleteComment(int memoId, int commentId) async {
    await _dio.delete('/comments/$commentId');
  }

  @override
  Future<List<UserRef>> searchUsers(String query) async {
    final res = await _dio.get<List<dynamic>>('/users', queryParameters: {'q': query});
    return res.data!.map((e) => UserRef.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<MemoProject>> searchProjects(String query) async {
    final res = await _dio.get<List<dynamic>>('/projects', queryParameters: {'q': query});
    return res.data!.map((e) => MemoProject.fromJson(e as Map<String, dynamic>)).toList();
  }
}
