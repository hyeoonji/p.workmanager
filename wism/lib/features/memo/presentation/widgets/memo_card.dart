import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/utils/formats.dart';
import '../../../../shared/widgets/memo_badges.dart';
import '../../data/models/memo.dart';

/// 디자인(MemoCard) 기반 메모 카드.
class MemoCard extends StatelessWidget {
  const MemoCard({
    super.key,
    required this.memo,
    required this.onTap,
    required this.onBookmark,
  });

  final Memo memo;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (memo.isUrgent) const UrgentBadge(),
                          CategoryBadge(memo.category),
                          if (memo.project != null)
                            ProjectBadge(memo.project!.name),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        memo.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textTitle,
                          height: 1.4,
                        ),
                      ),
                      if ((memo.content ?? '').isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          memo.content!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSub,
                            height: 1.5,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      _meta(),
                    ],
                  ),
                ),
                // 북마크 (우상단)
                GestureDetector(
                  onTap: onBookmark,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, top: 2),
                    child: Icon(
                      memo.bookmarked ? Icons.bookmark : Icons.bookmark_border,
                      size: 18,
                      color: memo.bookmarked
                          ? AppColors.primary
                          : const Color(0xFFAAB4C8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _meta() {
    return DefaultTextStyle(
      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
      child: Row(
        children: [
          Flexible(
            child: Text(
              memo.author.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.textSub),
            ),
          ),
          const _Dot(),
          Text(fmtShort(memo.createdAt)),
          const _Dot(),
          const Icon(Icons.visibility_outlined, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 3),
          Text('${memo.readBy}'),
          if (memo.commentCount > 0) ...[
            const SizedBox(width: 10),
            const Icon(Icons.mode_comment_outlined,
                size: 14, color: AppColors.textMuted),
            const SizedBox(width: 3),
            Text('${memo.commentCount}'),
          ],
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 6),
        child: Text('·', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
      );
}
