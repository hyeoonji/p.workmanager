import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/data/models/app_user.dart';

Future<bool?> showProfileEditSheet(BuildContext context, AppUser user) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _ProfileEditSheet(user: user),
  );
}

class _ProfileEditSheet extends ConsumerStatefulWidget {
  const _ProfileEditSheet({required this.user});
  final AppUser user;
  @override
  ConsumerState<_ProfileEditSheet> createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends ConsumerState<_ProfileEditSheet> {
  late final _name = TextEditingController(text: widget.user.name);
  late final _position = TextEditingController(text: widget.user.position ?? '');
  late final _dept = TextEditingController(text: widget.user.dept ?? '');
  late final _email = TextEditingController(text: widget.user.email ?? '');
  late final _phone = TextEditingController(text: widget.user.phone ?? '');
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _position.dispose();
    _dept.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      await ref.read(authControllerProvider.notifier).updateProfile(
            name: _name.text.trim(),
            position: _position.text.trim().isEmpty ? null : _position.text.trim(),
            dept: _dept.text.trim().isEmpty ? null : _dept.text.trim(),
            email: _email.text.trim().isEmpty ? null : _email.text.trim(),
            phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
          );
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('저장에 실패했습니다.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final initials =
        widget.user.name.characters.take(2).toString();
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
              child: Row(
                children: [
                  const Text('프로필 수정',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LucideIcons.x, size: 20),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: const BoxDecoration(
                              color: Color(0xFFEBF3FB), shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: Text(initials,
                              style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _field('이름', _name),
                  _field('직급', _position, optional: true),
                  _field('부서', _dept, optional: true),
                  _field('이메일', _email, keyboard: TextInputType.emailAddress),
                  _field('전화번호', _phone, keyboard: TextInputType.phone),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.divider)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.background,
                          foregroundColor: AppColors.textSub,
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                        child: const Text('취소',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: _saving ? null : _save,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: AppColors.buttonDisabled,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Text('저장',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c,
      {TextInputType? keyboard, bool optional = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textTitle)),
                if (optional) ...[
                  const SizedBox(width: 4),
                  const Text('(선택)',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textMuted)),
                ],
              ],
            ),
          ),
          TextField(
            controller: c,
            keyboardType: keyboard,
            style: const TextStyle(fontSize: 14, color: AppColors.textTitle),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: AppColors.surface,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              enabledBorder: _border(AppColors.border),
              focusedBorder: _border(AppColors.primary),
              border: _border(AppColors.border),
            ),
          ),
        ],
      ),
    );
  }

  static OutlineInputBorder _border(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c),
      );
}
