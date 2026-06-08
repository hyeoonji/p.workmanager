import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../application/memo_providers.dart';
import '../data/models/memo.dart';
import '../data/models/memo_project.dart';
import '../data/models/user_ref.dart';
import '../domain/memo_draft.dart';
import 'widgets/search_pickers.dart';
import 'widgets/wism_date_picker.dart';

/// 메모 작성/수정 — 디자인(MemoForm) 기반 중앙 모달. 성공 시 true 반환.
Future<bool?> showWriteMemoSheet(BuildContext context, {Memo? edit}) {
  return showDialog<bool>(
    context: context,
    useRootNavigator: true,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (_) => _WriteMemoDialog(edit: edit),
  );
}

class _WriteMemoDialog extends ConsumerStatefulWidget {
  const _WriteMemoDialog({this.edit});
  final Memo? edit;
  @override
  ConsumerState<_WriteMemoDialog> createState() => _WriteMemoDialogState();
}

class _WriteMemoDialogState extends ConsumerState<_WriteMemoDialog> {
  late final TextEditingController _title;
  late final TextEditingController _content;
  late String _priority;
  late String _category;
  MemoProject? _project;
  DateTime? _scheduledDate;
  late List<UserRef> _assignees;
  bool _saving = false;

  bool get _isEdit => widget.edit != null;
  bool get _canSubmit =>
      _title.text.trim().isNotEmpty &&
      (_category != MemoCategory.schedule || _scheduledDate != null);

  @override
  void initState() {
    super.initState();
    final e = widget.edit;
    _title = TextEditingController(text: e?.title ?? '');
    _content = TextEditingController(text: e?.content ?? '');
    _priority = e?.priority ?? MemoPriority.normal;
    _category = e?.category ?? MemoCategory.schedule;
    _project = e?.project;
    _scheduledDate = e?.scheduledDate;
    _assignees = e?.assignees
            .map((a) => UserRef(id: a.userId, name: a.name))
            .toList() ??
        [];
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_canSubmit) return;
    setState(() => _saving = true);
    final draft = MemoDraft(
      title: _title.text.trim(),
      content: _content.text.trim(),
      priority: _priority,
      category: _category,
      projectId: _project?.id,
      scheduledDate:
          _category == MemoCategory.schedule ? _scheduledDate : null,
      assigneeIds: _assignees.map((u) => u.id).toList(),
    );
    try {
      final repo = ref.read(memoRepositoryProvider);
      if (_isEdit) {
        await repo.update(widget.edit!.id, draft);
      } else {
        await repo.create(draft);
      }
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
    final size = MediaQuery.sizeOf(context);
    final width = (size.width * 0.95).clamp(0.0, 480.0);
    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: width,
          maxHeight: size.height * 0.88,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _header(),
            Flexible(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _field('제목',
                      TextField(
                        controller: _title,
                        onChanged: (_) => setState(() {}),
                        style: _inputTextStyle,
                        decoration: _dec('메모 제목을 입력하세요'),
                      )),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _field('중요도',
                            _dropdown(_priority, MemoPriority.all,
                                (v) => setState(() => _priority = v))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _field('카테고리',
                            _dropdown(_category, MemoCategory.all,
                                (v) => setState(() => _category = v))),
                      ),
                    ],
                  ),
                  if (_category == MemoCategory.schedule) ...[
                    const SizedBox(height: 16),
                    _field('일정 일시',
                        WismDatePicker(
                          value: _scheduledDate,
                          onChanged: (d) => setState(() => _scheduledDate = d),
                        )),
                  ],
                  const SizedBox(height: 16),
                  _field('사업 (프로젝트)', _projectField()),
                  const SizedBox(height: 16),
                  _field('내용',
                      TextField(
                        controller: _content,
                        maxLines: 5,
                        style: _inputTextStyle,
                        decoration: _dec('메모 내용을 입력하세요'),
                      )),
                  const SizedBox(height: 16),
                  _field('담당자 태그', _assigneeField()),
                ],
              ),
            ),
            _footer(),
          ],
        ),
      ),
    );
  }

  // ── 헤더 ──
  Widget _header() => Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            Text(_isEdit ? '메모 수정' : '새 메모 작성',
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textTitle)),
            const Spacer(),
            InkWell(
              onTap: () => Navigator.pop(context),
              customBorder: const CircleBorder(),
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                    color: AppColors.background, shape: BoxShape.circle),
                child: const Icon(LucideIcons.x, size: 15, color: AppColors.textSub),
              ),
            ),
          ],
        ),
      );

  // ── 푸터 ──
  Widget _footer() => Container(
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
                  foregroundColor: AppColors.textSub,
                  backgroundColor: AppColors.background,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                ),
                child: const Text('취소',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: (_saving || !_canSubmit) ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.buttonDisabled,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('저장',
                        style:
                            TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      );

  // ── 공통 필드 (라벨 + 위젯) ──
  Widget _field(String label, Widget child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTitle)),
          ),
          child,
        ],
      );

  static const _inputTextStyle =
      TextStyle(fontSize: 14, color: AppColors.textTitle);

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFA0ADB8)),
        isDense: true,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        enabledBorder: _border(AppColors.border, 1),
        focusedBorder: _border(AppColors.primary, 1),
        border: _border(AppColors.border, 1),
      );

  static OutlineInputBorder _border(Color c, double w) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: c, width: w),
      );

  Widget _dropdown(String value, List<String> items, ValueChanged<String> onChanged) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isDense: true,
      icon: const Icon(LucideIcons.chevronDown, size: 16, color: AppColors.textSub),
      style: _inputTextStyle,
      decoration: _dec(''),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (v) => v == null ? null : onChanged(v),
    );
  }

  // 사업: 검색 피커(자동완성) — 디자인 필드 외형으로 표시.
  Widget _projectField() {
    final p = _project;
    final text = p == null
        ? '사업명을 검색하세요'
        : '${p.name}${p.clientName != null ? ' · ${p.clientName}' : ''}';
    return _tapField(
      text: text,
      placeholder: p == null,
      onTap: () async {
        final picked = await pickProject(context);
        if (picked != null) setState(() => _project = picked);
      },
      onClear: p == null ? null : () => setState(() => _project = null),
    );
  }

  // 담당자: 검색 피커 + 칩.
  Widget _assigneeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tapField(
          text: '담당자명을 검색하세요',
          placeholder: true,
          onTap: () async {
            final u = await pickUser(context);
            if (u != null && !_assignees.any((e) => e.id == u.id)) {
              setState(() => _assignees.add(u));
            }
          },
        ),
        if (_assignees.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _assignees.map((u) {
              return Container(
                padding: const EdgeInsets.fromLTRB(8, 3, 6, 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F1FB),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('@${u.name}',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary)),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => setState(() => _assignees.remove(u)),
                      child: const Icon(LucideIcons.x,
                          size: 11, color: AppColors.primary),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _tapField({
    required String text,
    required bool placeholder,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 14,
                      color: placeholder
                          ? const Color(0xFFA0ADB8)
                          : AppColors.textBody)),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: const Icon(LucideIcons.x, size: 16, color: AppColors.textMuted),
              )
            else
              const Icon(LucideIcons.search, size: 16, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
