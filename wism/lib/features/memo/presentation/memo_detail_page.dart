import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/utils/formats.dart';
import '../../../shared/widgets/app_dialog.dart';
import '../../../shared/widgets/memo_badges.dart';
import '../../auth/application/auth_controller.dart';
import '../application/memo_providers.dart';
import '../data/models/comment.dart';
import '../data/models/memo.dart';
import 'write_memo_sheet.dart';

class MemoDetailPage extends ConsumerStatefulWidget {
  const MemoDetailPage({super.key, required this.memoId});
  final int memoId;

  @override
  ConsumerState<MemoDetailPage> createState() => _MemoDetailPageState();
}

class _MemoDetailPageState extends ConsumerState<MemoDetailPage> {
  final _commentController = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _refresh() {
    ref.invalidate(memoDetailProvider(widget.memoId));
    ref.invalidate(memoListProvider);
    ref.invalidate(allMemosProvider);
  }

  Future<void> _markRead() async {
    await ref.read(memoRepositoryProvider).markRead(widget.memoId);
    _refresh();
  }

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    try {
      await ref.read(memoRepositoryProvider).addComment(widget.memoId, text);
      _commentController.clear();
      _refresh();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _editComment(Comment c) async {
    final result = await showEditTextDialog(
      context,
      title: '댓글 수정',
      initial: c.content,
      hint: '댓글 내용',
    );
    if (result != null && result.isNotEmpty) {
      await ref
          .read(memoRepositoryProvider)
          .updateComment(widget.memoId, c.id, result);
      _refresh();
    }
  }

  Future<void> _deleteComment(Comment c) async {
    final ok = await showConfirmDialog(
      context,
      title: '댓글을 삭제할까요?',
      confirmText: '삭제',
      confirmColor: AppColors.danger,
    );
    if (ok != true) return;
    await ref
        .read(memoRepositoryProvider)
        .deleteComment(widget.memoId, c.id);
    _refresh();
  }

  Future<void> _delete() async {
    final ok = await showConfirmDialog(
      context,
      title: '메모를 삭제할까요?',
      message: '삭제된 메모는 복구할 수 없습니다.',
      confirmText: '삭제',
      confirmColor: AppColors.danger,
    );
    if (ok != true) return;
    await ref.read(memoRepositoryProvider).delete(widget.memoId);
    ref.invalidate(memoListProvider);
    ref.invalidate(allMemosProvider);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(memoDetailProvider(widget.memoId));
    final currentUserId = ref.watch(authControllerProvider).user?.id;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('메모 상세'),
        centerTitle: true,
        actions: [
          async.maybeWhen(
            data: (m) {
              if (m.author.id != currentUserId) return const SizedBox.shrink();
              return PopupMenuButton<String>(
                onSelected: (v) async {
                  if (v == 'edit') {
                    final saved = await showWriteMemoSheet(context, edit: m);
                    if (saved == true) _refresh();
                  } else if (v == 'delete') {
                    _delete();
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('수정')),
                  PopupMenuItem(value: 'delete', child: Text('삭제')),
                ],
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('메모를 불러오지 못했습니다.')),
        data: (memo) => Column(
          children: [
            Expanded(child: _body(memo)),
            _commentInput(),
          ],
        ),
      ),
    );
  }

  Widget _body(Memo memo) {
    final confirmed = memo.isRead;
    final currentUserId = ref.read(authControllerProvider).user?.id;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.primary.withValues(alpha: 0.08)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (memo.isUrgent) const UrgentBadge(),
                    CategoryBadge(memo.category),
                    if (memo.project != null) ProjectBadge(memo.project!.name),
                  ],
                ),
                const SizedBox(height: 12),
                Text(memo.title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textTitle)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: const Color(0xFFEBF3FB),
                      child: Text(
                        memo.author.name.characters.first,
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(memo.author.name,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSub)),
                    Text(' · ${fmtDateTime(memo.createdAt)}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
                if (memo.scheduledDate != null) ...[
                  const SizedBox(height: 4),
                  Text('일정: ${fmtDate(memo.scheduledDate!)}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.catSchedule)),
                ],
                if (memo.assignees.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: memo.assignees
                        .map((a) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEBF3FB),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text('@${a.name}',
                                  style: const TextStyle(
                                      fontSize: 12, color: AppColors.primary)),
                            ))
                        .toList(),
                  ),
                ],
                const Divider(height: 24),
                Text(
                  (memo.content ?? '').isEmpty ? '내용이 없습니다.' : memo.content!,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textBody, height: 1.6),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // 읽음 확인
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: confirmed ? null : _markRead,
            style: FilledButton.styleFrom(
              backgroundColor:
                  confirmed ? const Color(0xFFE6F4EA) : AppColors.primary,
              disabledBackgroundColor: const Color(0xFFE6F4EA),
            ),
            icon: Icon(Icons.check_circle,
                color: confirmed ? AppColors.catDecision : Colors.white, size: 18),
            label: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                confirmed ? '확인 완료  (읽음 ${memo.readBy}/${memo.totalReaders})' : '읽음 확인',
                style: TextStyle(
                    color: confirmed ? AppColors.catDecision : Colors.white,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('댓글${memo.comments.isNotEmpty ? ' (${memo.comments.length})' : ''}',
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textTitle)),
        const SizedBox(height: 8),
        if (memo.comments.isEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
            ),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 32, color: Color(0xFFD1D9E6)),
                  SizedBox(height: 8),
                  Text('첫 번째 댓글을 남겨보세요',
                      style: TextStyle(color: AppColors.textMuted)),
                ],
              ),
            ),
          )
        else
          ...memo.comments.map((c) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: const Color(0xFFEBF3FB),
                      child: Text(c.author.name.characters.first,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(c.author.name,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(width: 8),
                              Text(fmtTime(c.createdAt),
                                  style: const TextStyle(
                                      fontSize: 12, color: AppColors.textMuted)),
                              if (c.type == 'status') ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFE6F4EA),
                                      borderRadius: BorderRadius.circular(6)),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_circle,
                                          size: 11, color: AppColors.catDecision),
                                      SizedBox(width: 3),
                                      Text('확인 완료',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.catDecision)),
                                    ],
                                  ),
                                ),
                              ],
                              const Spacer(),
                              if (c.author.id == currentUserId)
                                SizedBox(
                                  height: 22,
                                  width: 28,
                                  child: PopupMenuButton<String>(
                                    padding: EdgeInsets.zero,
                                    iconSize: 18,
                                    icon: const Icon(Icons.more_vert,
                                        color: AppColors.textMuted),
                                    onSelected: (v) => v == 'edit'
                                        ? _editComment(c)
                                        : _deleteComment(c),
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(
                                          value: 'edit', child: Text('수정')),
                                      PopupMenuItem(
                                          value: 'delete', child: Text('삭제')),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(c.content,
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textBody,
                                  height: 1.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
      ],
    );
  }

  Widget _commentInput() {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFEBF3FB),
              child: Text(
                (ref.read(authControllerProvider).user?.name ?? '나')
                    .characters
                    .first,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _commentController,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: '댓글을 입력하세요...',
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _sending ? null : _addComment,
              style: IconButton.styleFrom(backgroundColor: AppColors.primary),
              icon: const Icon(Icons.send, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
