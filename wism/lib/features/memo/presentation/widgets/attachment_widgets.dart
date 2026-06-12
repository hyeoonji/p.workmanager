import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';

/// 파일 종류별 아이콘 배지 (디자인 MemoForm/Detail FileTypeIcon).
/// kind: image | pdf | excel | doc | other
class AttachmentTypeIcon extends StatelessWidget {
  const AttachmentTypeIcon(this.kind, {super.key, this.size = 36});
  final String kind;
  final double size;

  @override
  Widget build(BuildContext context) {
    final (icon, color, bg) = switch (kind) {
      'image' => (
          LucideIcons.image,
          AppColors.skyBlue,
          const Color(0xFFEBF3FB)
        ),
      'pdf' => (LucideIcons.fileText, AppColors.danger, const Color(0xFFFEE4E2)),
      'excel' => (
          LucideIcons.fileText,
          AppColors.catDecision,
          const Color(0xFFE6F4EA)
        ),
      'doc' => (
          LucideIcons.fileText,
          AppColors.primary,
          const Color(0xFFEBF3FB)
        ),
      _ => (LucideIcons.file, AppColors.textMuted, const Color(0xFFF0F2F5)),
    };
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: size * 0.5, color: color),
    );
  }
}
