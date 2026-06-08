import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// 공통 배지 스타일 — 12px Medium, radius 6, padding 2/8 (디자인 BadgeTokens 기준).
Widget _chip(String text, Color fg, Color bg, {Color? border, double letterSpacing = 0}) =>
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: border == null ? null : Border.all(color: border),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          height: 18 / 12, // line-height 18px
          fontWeight: FontWeight.w500,
          color: fg,
          letterSpacing: letterSpacing,
        ),
      ),
    );

/// 카테고리 배지 — 일정=네이비, 이슈=주황. (배지 색 축)
class CategoryBadge extends StatelessWidget {
  const CategoryBadge(this.category, {super.key});
  final String category;
  @override
  Widget build(BuildContext context) => _chip(
        category,
        AppColors.categoryBadgeFg(category),
        AppColors.categoryBadgeBg(category),
      );
}

/// 긴급 배지 — 빨강은 오직 여기에만.
class UrgentBadge extends StatelessWidget {
  const UrgentBadge({super.key});
  @override
  Widget build(BuildContext context) =>
      _chip('긴급', AppColors.urgentFg, AppColors.urgentBg);
}

/// 프로젝트 태그 — 테두리 있음, uppercase + 자간.
class ProjectBadge extends StatelessWidget {
  const ProjectBadge(this.label, {super.key});
  final String label;
  @override
  Widget build(BuildContext context) => _chip(
        label.toUpperCase(),
        AppColors.projectBadgeFg,
        AppColors.projectBadgeBg,
        border: AppColors.projectBadgeBorder,
        letterSpacing: 0.4, // tracking-wide
      );
}
