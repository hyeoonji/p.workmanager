import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
      message: '삭제된 댓글은 복구할 수 없습니다.',
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
                icon: const Icon(LucideIcons.moreVertical),
                color: AppColors.surface,
                elevation: 8,
                clipBehavior: Clip.antiAlias,
                position: PopupMenuPosition.under,
                constraints: const BoxConstraints(minWidth: 120),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: AppColors.cardBorder),
                ),
                onSelected: (v) async {
                  if (v == 'edit') {
                    final saved = await showWriteMemoSheet(context, edit: m);
                    if (saved == true) _refresh();
                  } else if (v == 'delete') {
                    _delete();
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'edit',
                    height: 44,
                    padding: EdgeInsets.zero,
                    child: _MenuRow(text: '수정', borderBottom: true),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    height: 44,
                    padding: EdgeInsets.zero,
                    child: _MenuRow(text: '삭제', color: AppColors.danger),
                  ),
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
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        color: AppColors.textTitle)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                          color: Color(0xFFEBF3FB), shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Text(
                        memo.author.name.characters.first,
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                        '${memo.author.name} 작성 · ${fmtDate(memo.createdAt)} ${fmtTime(memo.createdAt)}',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF8A94A6))),
                  ],
                ),
                if (memo.scheduledDate != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F1FB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.calendarDays,
                            size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text('일정: ${fmtScheduled(memo.scheduledDate!)}',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary)),
                      ],
                    ),
                  ),
                ],
                if (memo.assignees.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: memo.assignees
                        .map((a) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEBF3FB),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text('@${a.name}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primary)),
                            ))
                        .toList(),
                  ),
                ],
                Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    color: AppColors.divider),
                Text(
                  (memo.content ?? '').isEmpty ? '내용이 없습니다.' : memo.content!,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textBody, height: 1.6),
                ),
              ],
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
                  Icon(LucideIcons.messageSquare,
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
                                      Icon(LucideIcons.checkCircle,
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
                                    color: AppColors.surface,
                                    elevation: 8,
                                    clipBehavior: Clip.antiAlias,
                                    position: PopupMenuPosition.under,
                                    constraints:
                                        const BoxConstraints(minWidth: 120),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: const BorderSide(
                                          color: AppColors.cardBorder),
                                    ),
                                    icon: const Icon(LucideIcons.moreVertical,
                                        color: AppColors.textMuted),
                                    onSelected: (v) => v == 'edit'
                                        ? _editComment(c)
                                        : _deleteComment(c),
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(
                                          value: 'edit',
                                          height: 44,
                                          padding: EdgeInsets.zero,
                                          child: _MenuRow(
                                              text: '수정', borderBottom: true)),
                                      PopupMenuItem(
                                          value: 'delete',
                                          height: 44,
                                          padding: EdgeInsets.zero,
                                          child: _MenuRow(
                                              text: '삭제',
                                              color: AppColors.danger)),
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
          border: Border(top: BorderSide(color: Color(0x1A14387F))),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
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
                onChanged: (_) => setState(() {}),
                style: const TextStyle(fontSize: 14, color: AppColors.textTitle),
                decoration: InputDecoration(
                  hintText: '댓글을 입력하세요...',
                  hintStyle:
                      const TextStyle(fontSize: 14, color: AppColors.textMuted),
                  isDense: true,
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0x1A14387F)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.skyBlue),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0x1A14387F)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _SendButton(
                enabled: !_sending && _commentController.text.trim().isNotEmpty,
                onTap: _addComment),
          ],
        ),
      ),
    );
  }
}

/// 팝업 메뉴 항목 — 흰 카드 메뉴 안의 한 줄(높이 44, 14px w500).
class _MenuRow extends StatelessWidget {
  const _MenuRow(
      {required this.text,
      this.color = AppColors.textTitle,
      this.borderBottom = false});
  final String text;
  final Color color;
  final bool borderBottom;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        height: 44,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: borderBottom
            ? const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.divider)))
            : null,
        child: Text(text,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500, color: color)),
      );
}

/// 댓글 전송 버튼 — 36 원형, 활성 네이비 / 비활성 #D1D9E6.
class _SendButton extends StatelessWidget {
  const _SendButton({required this.enabled, required this.onTap});
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primary : const Color(0xFFD1D9E6),
          shape: BoxShape.circle,
        ),
        child: const Icon(LucideIcons.send, size: 16, color: Colors.white),
      ),
    );
  }
}
