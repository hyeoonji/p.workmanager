import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../notification/presentation/widgets/notification_bell.dart';
import '../../application/memo_providers.dart';
import '../../domain/memo_repository.dart';
import '../write_memo_sheet.dart';
import 'memo_list_view.dart';

/// 전체/내메모/북마크 탭 공용 스캐폴드 (헤더 + 목록 + 작성 FAB).
class MemoTabScaffold extends ConsumerWidget {
  const MemoTabScaffold({
    super.key,
    required this.title,
    required this.scope,
    this.showFab = true,
  });

  final String title;
  final MemoScope scope;
  final bool showFab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: const [NotificationBell()],
      ),
      body: MemoListView(scope: scope),
      floatingActionButton: showFab
          ? FloatingActionButton(
              onPressed: () async {
                final ok = await showWriteMemoSheet(context);
                if (ok == true) {
                  ref.invalidate(memoListProvider);
                  ref.invalidate(allMemosProvider);
                }
              },
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, size: 26),
            )
          : null,
    );
  }
}
