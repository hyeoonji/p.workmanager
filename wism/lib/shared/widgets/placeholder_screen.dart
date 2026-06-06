import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// M0 단계 플레이스홀더 화면. 각 마일스톤에서 실제 구현으로 교체.
class PlaceholderScreen extends StatelessWidget {
  final String title;
  final String code;
  const PlaceholderScreen({super.key, required this.title, required this.code});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(code, style: const TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 8),
            Text(
              '$title (준비 중)',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textTitle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
