import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// 카테고리별 배지 배경색 (디자인 토큰).
const _categoryBg = {
  '일정': Color(0xFFE8F1FB),
  '이슈': Color(0xFFFEE4E2),
  '결정사항': Color(0xFFE6F4EA),
  '회의록': Color(0xFFEEEAF6),
  '기타': Color(0xFFEEF1F5),
};

Widget _chip(String text, Color fg, Color bg) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: fg),
      ),
    );

class CategoryBadge extends StatelessWidget {
  const CategoryBadge(this.category, {super.key});
  final String category;
  @override
  Widget build(BuildContext context) => _chip(
        category,
        AppColors.category(category),
        _categoryBg[category] ?? const Color(0xFFEEF1F5),
      );
}

class UrgentBadge extends StatelessWidget {
  const UrgentBadge({super.key});
  @override
  Widget build(BuildContext context) =>
      _chip('긴급', AppColors.danger, const Color(0xFFFEE4E2));
}

class ProjectBadge extends StatelessWidget {
  const ProjectBadge(this.label, {super.key});
  final String label;
  @override
  Widget build(BuildContext context) =>
      _chip(label, AppColors.textSub, const Color(0xFFEEF1F5));
}
