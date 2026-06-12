import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../application/onboarding_providers.dart';

class _Slide {
  const _Slide(this.icon, this.iconColor, this.iconBg, this.title, this.body);
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String body;
}

const _slides = <_Slide>[
  _Slide(
    LucideIcons.shield,
    AppColors.primary,
    Color(0xFFEBF3FB),
    'WISM에 오신 것을\n환영합니다',
    '중요한 일정·이슈·결정사항을 관리자들이\n함께 공유하고 기록하는 공간입니다.',
  ),
  _Slide(
    LucideIcons.bell,
    Color(0xFFD9822B),
    Color(0xFFFEF3E2),
    '긴급한 일은\n놓치지 않게',
    "홈에서 '미확인 긴급 이슈'를 확인하고,\n[확인 완료]를 누르면 봤다는 기록이 남습니다.",
  ),
  _Slide(
    LucideIcons.plus,
    AppColors.catDecision,
    Color(0xFFE6F4EA),
    '메모는 + 버튼으로',
    "오른쪽 아래 + 버튼으로 메모를 작성하고,\n꼭 봐야 할 사람을 '확인자'로 지정하세요.",
  ),
  _Slide(
    LucideIcons.search,
    Color(0xFF6B5B95),
    Color(0xFFEEEAF6),
    '필요한 건 빠르게',
    '검색·종류별 필터·북마크로 원하는 메모를\n금방 찾을 수 있습니다.',
  ),
];

/// 첫 실행 온보딩 (#1). [onFinish]가 있으면 그걸 호출(도움말의 '다시 보기'),
/// 없으면 첫 실행 모드 → markOnboardingSeen으로 라우터가 분기.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, this.onFinish});
  final VoidCallback? onFinish;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _current = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() {
    if (widget.onFinish != null) {
      widget.onFinish!();
    } else {
      markOnboardingSeen(ref);
    }
  }

  void _next() {
    if (_current < _slides.length - 1) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _current == _slides.length - 1;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 건너뛰기
            SizedBox(
              height: 44,
              child: Align(
                alignment: Alignment.centerRight,
                child: AnimatedOpacity(
                  opacity: isLast ? 0 : 1,
                  duration: const Duration(milliseconds: 150),
                  child: TextButton(
                    onPressed: isLast ? null : _finish,
                    child: const Text('건너뛰기',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _current = i),
                itemBuilder: (_, i) => _slideView(_slides[i]),
              ),
            ),
            // 점 인디케이터
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) {
                final active = i == _current;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : const Color(0xFFD1D8E0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _next,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(isLast ? '시작하기' : '다음',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _slideView(_Slide s) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              color: s.iconBg,
              borderRadius: BorderRadius.circular(36),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(s.icon, size: 56, color: s.iconColor),
          ),
          const SizedBox(height: 32),
          Text(s.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                  color: AppColors.textTitle)),
          const SizedBox(height: 14),
          Text(s.body,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16,
                  height: 1.7,
                  color: AppColors.textBody)),
        ],
      ),
    );
  }
}
