import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/theme/app_colors.dart';
import '../features/memo/application/memo_providers.dart';
import '../features/memo/domain/memo_repository.dart';

/// 메인 셸 (P-02) — 디자인(MobileTabBar) 기반 하단 탭 5개.
class MainShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  const MainShell({super.key, required this.navigationShell});

  static const _tabs = [
    (icon: LucideIcons.house, label: '홈'),
    (icon: LucideIcons.fileText, label: '전체'),
    (icon: LucideIcons.bookOpen, label: '내 메모'),
    (icon: LucideIcons.bookmark, label: '북마크'),
    (icon: LucideIcons.user, label: '프로필'),
  ];

  void _onTap(int index, WidgetRef ref) {
    // 전체(1)/내메모(2) 탭을 누르면 해당 목록의 필터·정렬 초기화 (#6)
    if (index == 1) {
      ref.read(memoListResetProvider(MemoScope.all).notifier).state++;
    } else if (index == 2) {
      ref.read(memoListResetProvider(MemoScope.my).notifier).state++;
    }
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = navigationShell.currentIndex;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.primary.withValues(alpha: 0.1)),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final t = _tabs[i];
                final selected = i == current;
                final color =
                    selected ? AppColors.primary : AppColors.iconInactive;
                return Expanded(
                  child: InkWell(
                    onTap: () => _onTap(i, ref),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(t.icon, size: 20, color: color),
                        const SizedBox(height: 4),
                        Text(
                          t.label,
                          style: TextStyle(
                            fontSize: 12,
                            color: color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
