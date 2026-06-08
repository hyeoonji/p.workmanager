import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../application/memo_providers.dart';
import '../../data/models/memo_project.dart';
import '../../data/models/user_ref.dart';

const _sheetShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
);

/// 사업(프로젝트) 선택 — 기존 사업 데이터에서 검색.
Future<MemoProject?> pickProject(BuildContext context) {
  return showModalBottomSheet<MemoProject>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: AppColors.surface,
    shape: _sheetShape,
    builder: (_) => const _ProjectPickerSheet(),
  );
}

/// 담당자(유저) 선택 — userData 검색 자동완성.
Future<UserRef?> pickUser(BuildContext context) {
  return showModalBottomSheet<UserRef>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: AppColors.surface,
    shape: _sheetShape,
    builder: (_) => const _UserPickerSheet(),
  );
}

InputDecoration _searchDec(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 14, color: AppColors.iconInactive),
      prefixIcon: const Icon(LucideIcons.search,
          size: 16, color: AppColors.iconInactive),
      prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      isDense: true,
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.skyBlue),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
    );

class _PickerScaffold extends StatelessWidget {
  const _PickerScaffold({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.checkboxBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textTitle)),
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _ProjectPickerSheet extends ConsumerStatefulWidget {
  const _ProjectPickerSheet();
  @override
  ConsumerState<_ProjectPickerSheet> createState() =>
      _ProjectPickerSheetState();
}

class _ProjectPickerSheetState extends ConsumerState<_ProjectPickerSheet> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(projectSearchProvider(_q));
    return _PickerScaffold(
      title: '사업 선택',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              autofocus: true,
              style: const TextStyle(fontSize: 14, color: AppColors.textTitle),
              decoration: _searchDec('사업명 검색'),
              onChanged: (v) => setState(() => _q = v),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: results.when(
              data: (list) => list.isEmpty
                  ? const _EmptyHint('검색 결과가 없습니다')
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: list.length,
                      separatorBuilder: (_, _) => const _PickerDivider(),
                      itemBuilder: (_, i) {
                        final p = list[i];
                        return _PickerTile(
                          leading: const _LeadingIcon(LucideIcons.briefcase),
                          title: p.name,
                          subtitle: p.clientName != null
                              ? '주관업체: ${p.clientName}'
                              : null,
                          onTap: () => Navigator.pop(context, p),
                        );
                      },
                    ),
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (_, _) => const _EmptyHint('검색에 실패했습니다'),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserPickerSheet extends ConsumerStatefulWidget {
  const _UserPickerSheet();
  @override
  ConsumerState<_UserPickerSheet> createState() => _UserPickerSheetState();
}

class _UserPickerSheetState extends ConsumerState<_UserPickerSheet> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(userSearchProvider(_q));
    return _PickerScaffold(
      title: '담당자 선택',
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              autofocus: true,
              style: const TextStyle(fontSize: 14, color: AppColors.textTitle),
              decoration: _searchDec('이름 검색'),
              onChanged: (v) => setState(() => _q = v),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: results.when(
              data: (list) {
                if (_q.trim().isEmpty) {
                  return const _EmptyHint('이름을 입력하세요');
                }
                if (list.isEmpty) return const _EmptyHint('검색 결과가 없습니다');
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const _PickerDivider(),
                  itemBuilder: (_, i) {
                    final u = list[i];
                    return _PickerTile(
                      leading: _Avatar(u.name.characters.first),
                      title: u.name,
                      subtitle: [u.dept, u.position]
                          .where((e) => e != null && e.isNotEmpty)
                          .join(' · '),
                      onTap: () => Navigator.pop(context, u),
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (_, _) => const _EmptyHint('검색에 실패했습니다'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile(
      {required this.leading,
      required this.title,
      this.subtitle,
      required this.onTap});
  final Widget leading;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textTitle)),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon(this.icon);
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
            color: const Color(0xFFEBF3FB),
            borderRadius: BorderRadius.circular(8)),
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: AppColors.primary),
      );
}

class _Avatar extends StatelessWidget {
  const _Avatar(this.initial);
  final String initial;
  @override
  Widget build(BuildContext context) => Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
            color: Color(0xFFEBF3FB), shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Text(initial,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary)),
      );
}

class _PickerDivider extends StatelessWidget {
  const _PickerDivider();
  @override
  Widget build(BuildContext context) => Container(
        height: 1,
        margin: const EdgeInsets.only(left: 64),
        color: AppColors.divider,
      );
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Center(
        child: Text(text,
            style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
      );
}
