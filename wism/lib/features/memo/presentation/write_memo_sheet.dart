import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../application/memo_providers.dart';
import '../data/models/memo.dart';
import '../data/models/memo_project.dart';
import '../data/models/user_ref.dart';
import '../domain/memo_draft.dart';
import 'widgets/search_pickers.dart';
import 'widgets/wism_date_picker.dart';

/// 메모 작성/수정 시트. 성공 시 true 반환.
Future<bool?> showWriteMemoSheet(BuildContext context, {Memo? edit}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _WriteMemoSheet(edit: edit),
  );
}

class _WriteMemoSheet extends ConsumerStatefulWidget {
  const _WriteMemoSheet({this.edit});
  final Memo? edit;
  @override
  ConsumerState<_WriteMemoSheet> createState() => _WriteMemoSheetState();
}

class _WriteMemoSheetState extends ConsumerState<_WriteMemoSheet> {
  late final TextEditingController _title;
  late final TextEditingController _content;
  late String _priority;
  late String _category;
  MemoProject? _project;
  DateTime? _scheduledDate;
  late List<UserRef> _assignees;
  bool _saving = false;

  bool get _isEdit => widget.edit != null;

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
    if (_title.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final draft = MemoDraft(
      title: _title.text.trim(),
      content: _content.text.trim(),
      priority: _priority,
      category: _category,
      projectId: _project?.id,
      scheduledDate: _scheduledDate,
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
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: Column(
          children: [
            _header(),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _label('제목'),
                  TextField(
                    controller: _title,
                    decoration: const InputDecoration(hintText: '메모 제목을 입력하세요'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _dropdown('중요도', _priority, MemoPriority.all, (v) => setState(() => _priority = v))),
                      const SizedBox(width: 12),
                      Expanded(child: _dropdown('카테고리', _category, MemoCategory.all, (v) => setState(() => _category = v))),
                    ],
                  ),
                  if (_category == MemoCategory.schedule) ...[
                    const SizedBox(height: 16),
                    _label('일정 날짜'),
                    WismDatePicker(
                      value: _scheduledDate,
                      onChanged: (d) => setState(() => _scheduledDate = d),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _label('사업 (프로젝트)'),
                  _tapField(
                    _project == null
                        ? '사업 선택'
                        : '${_project!.name}${_project!.clientName != null ? ' · ${_project!.clientName}' : ''}',
                    _project == null,
                    () async {
                      final p = await pickProject(context);
                      if (p != null) setState(() => _project = p);
                    },
                    icon: Icons.work_outline,
                    onClear: _project == null ? null : () => setState(() => _project = null),
                  ),
                  const SizedBox(height: 16),
                  _label('내용'),
                  TextField(
                    controller: _content,
                    maxLines: 5,
                    decoration: const InputDecoration(hintText: '메모 내용을 입력하세요'),
                  ),
                  const SizedBox(height: 16),
                  _label('담당자 태그'),
                  _assigneeField(),
                ],
              ),
            ),
            _footer(),
          ],
        ),
      ),
    );
  }

  Widget _header() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
        child: Row(
          children: [
            Text(_isEdit ? '메모 수정' : '새 메모 작성',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const Spacer(),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      );

  Widget _footer() => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text('취소'),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('저장'),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textTitle)),
      );

  Widget _dropdown(String label, String value, List<String> items,
      ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => v == null ? null : onChanged(v),
        ),
      ],
    );
  }

  Widget _tapField(String text, bool isPlaceholder, VoidCallback onTap,
      {required IconData icon, VoidCallback? onClear}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 18),
          suffixIcon: onClear != null
              ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: onClear)
              : const Icon(Icons.chevron_right),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isPlaceholder ? AppColors.textMuted : AppColors.textBody,
          ),
        ),
      ),
    );
  }

  Widget _assigneeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tapField('담당자 검색·추가', true, () async {
          final u = await pickUser(context);
          if (u != null && !_assignees.any((e) => e.id == u.id)) {
            setState(() => _assignees.add(u));
          }
        }, icon: Icons.person_add_alt),
        if (_assignees.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _assignees
                .map((u) => Chip(
                      label: Text('@${u.name}'),
                      onDeleted: () => setState(() => _assignees.remove(u)),
                      backgroundColor: const Color(0xFFE8F1FB),
                      labelStyle: const TextStyle(
                          color: AppColors.primary, fontSize: 12),
                      deleteIconColor: AppColors.primary,
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }

}
