import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

ShapeBorder _shape() =>
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));

const _inset = EdgeInsets.symmetric(horizontal: 32);

/// 취소 버튼 (radius8, 회색 배경) — 디자인 모달 공통.
ButtonStyle _cancelStyle() => OutlinedButton.styleFrom(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textSub,
      side: const BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(vertical: 13),
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    );

/// 확정 버튼 (radius8) — 디자인 모달 공통.
ButtonStyle _confirmStyle(Color? color) => FilledButton.styleFrom(
      backgroundColor: color ?? AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(vertical: 13),
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    );

/// 확인/취소 다이얼로그 (디자인 모달 톤: 둥근 16, 제목 17, 좌우 균등 버튼).
Future<bool?> showConfirmDialog(
  BuildContext context, {
  required String title,
  String? message,
  String confirmText = '확인',
  String cancelText = '취소',
  Color? confirmColor,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: _shape(),
      insetPadding: _inset,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textTitle)),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(message,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.textSub, height: 1.5)),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    style: _cancelStyle(),
                    child: Text(cancelText),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: _confirmStyle(confirmColor),
                    child: Text(confirmText),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

/// 텍스트 입력 다이얼로그 (댓글 수정 등). 저장 시 입력값, 취소 시 null.
Future<String?> showEditTextDialog(
  BuildContext context, {
  required String title,
  required String initial,
  String? hint,
}) {
  final controller = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: _shape(),
      insetPadding: _inset,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textTitle)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              minLines: 1,
              maxLines: 5,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(hintText: hint),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: _cancelStyle(),
                    child: const Text('취소'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () =>
                        Navigator.pop(ctx, controller.text.trim()),
                    style: _confirmStyle(null),
                    child: const Text('저장'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
