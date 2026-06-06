import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../application/memo_providers.dart';
import '../../data/models/memo_project.dart';
import '../../data/models/user_ref.dart';

/// 사업(프로젝트) 선택 — 기존 사업 데이터에서 검색.
Future<MemoProject?> pickProject(BuildContext context) {
  return showModalBottomSheet<MemoProject>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
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
    builder: (_) => const _UserPickerSheet(),
  );
}

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
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ],
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
  ConsumerState<_ProjectPickerSheet> createState() => _ProjectPickerSheetState();
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
              decoration: const InputDecoration(
                hintText: '사업명 검색',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _q = v),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: results.when(
              data: (list) => ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final p = list[i];
                  return ListTile(
                    title: Text(p.name),
                    subtitle: p.clientName != null ? Text('주관업체: ${p.clientName}') : null,
                    onTap: () => Navigator.pop(context, p),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const Center(child: Text('검색 실패')),
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
              decoration: const InputDecoration(
                hintText: '이름 검색',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _q = v),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: results.when(
              data: (list) {
                if (_q.trim().isEmpty) {
                  return const Center(
                    child: Text('이름을 입력하세요',
                        style: TextStyle(color: AppColors.textMuted)),
                  );
                }
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final u = list[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFEBF3FB),
                        child: Text(
                          u.name.characters.first,
                          style: const TextStyle(
                              color: AppColors.primary, fontSize: 14),
                        ),
                      ),
                      title: Text(u.name),
                      subtitle: Text(
                          [u.dept, u.position].where((e) => e != null).join(' · ')),
                      onTap: () => Navigator.pop(context, u),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const Center(child: Text('검색 실패')),
            ),
          ),
        ],
      ),
    );
  }
}
