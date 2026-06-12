import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// main()에서 로드한 SharedPreferences 인스턴스를 주입 (override 필수).
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('main()에서 override 되어야 합니다.'),
);

const onboardingSeenKey = 'onboarding_seen';

/// 첫 실행 온보딩 완료 여부. main()에서 실제 값으로 override.
/// 기본 true → 혹시 주입 실패 시 온보딩으로 막히지 않도록.
final onboardingSeenProvider = StateProvider<bool>((ref) => true);

/// 온보딩 완료 처리 — prefs 저장 + 상태 갱신(라우터가 즉시 분기).
Future<void> markOnboardingSeen(WidgetRef ref) async {
  await ref.read(sharedPreferencesProvider).setBool(onboardingSeenKey, true);
  ref.read(onboardingSeenProvider.notifier).state = true;
}
