import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F14387F), // rgba(20,56,127,0.06)
            blurRadius: 4,
            offset: Offset(0, 1),
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
                      memo.bookmarked
                          ? LucideIcons.bookmarkCheck
                          : LucideIcons.bookmark,
                      size: 16,
                      color: memo.bookmarked
                          ? AppColors.primary
                          : AppColors.iconInactive,
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 작성자 · 시간 — 한 텍스트로 합쳐 베이스라인 통일
        Flexible(
          child: Text.rich(
            TextSpan(children: [
              TextSpan(
                  text: memo.author.name,
                  style: const TextStyle(color: AppColors.textSub)),
              const TextSpan(text: '  ·  '),
              TextSpan(text: fmtTime(memo.createdAt)),
            ]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ),
        if (memo.commentCount > 0) ...[
          const SizedBox(width: 10),
          const Icon(LucideIcons.messageSquare,
              size: 14, color: AppColors.textMuted),
          const SizedBox(width: 3),
          Text('${memo.commentCount}',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ],
      ],
    );
  }
}
