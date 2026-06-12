import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../application/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _idController = TextEditingController();
  final _pwController = TextEditingController();
  final _idFocus = FocusNode();
  final _pwFocus = FocusNode();
  bool _obscure = true;
  bool _autoLogin = true;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _idFocus.addListener(() => setState(() {}));
    _pwFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    _idFocus.dispose();
    _pwFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final id = _idController.text.trim();
    final pw = _pwController.text;
    if (id.isEmpty || pw.isEmpty) {
      setState(() => _error = '사번과 비밀번호를 입력하세요.');
      return;
    }
    FocusScope.of(context).unfocus(); // 키보드 닫기
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).login(id, pw);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.sizeOf(context).height;
    final canSubmit = _idController.text.trim().isNotEmpty &&
        _pwController.text.isNotEmpty;

    return Scaffold(
      body: Column(
        children: [
          // 상단 네이비 그라데이션 + 로고
          Container(
            height: (screenH * 0.35).clamp(220, 320),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF14387F), Color(0xFF0F2A5E)],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/icon/wism_icon.png',
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Wintek Insight System Manager',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFA8B5C8)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 하단 흰색 영역
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('로그인',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textTitle)),
                            const SizedBox(height: 20),
                            _label('사번'),
                            _inputBox(
                              icon: LucideIcons.user,
                              focusNode: _idFocus,
                              controller: _idController,
                              hint: '사번을 입력하세요',
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              onSubmitted: (_) => _pwFocus.requestFocus(),
                            ),
                            const SizedBox(height: 16),
                            _label('비밀번호'),
                            _inputBox(
                              icon: LucideIcons.lock,
                              focusNode: _pwFocus,
                              controller: _pwController,
                              hint: '비밀번호를 입력하세요',
                              obscure: _obscure,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _submit(),
                              trailing: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? LucideIcons.eyeOff
                                      : LucideIcons.eye,
                                  size: 16,
                                  color: AppColors.textMuted,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _autoLoginCheck(),
                            if (_error != null) ...[
                              const SizedBox(height: 12),
                              Text(_error!,
                                  style: const TextStyle(
                                      color: AppColors.danger, fontSize: 13)),
                            ],
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed:
                                    (_loading || !canSubmit) ? null : _submit,
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  disabledBackgroundColor:
                                      const Color(0xFFA0AEC0),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 13),
                                  child: _loading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white))
                                      : const Text('로그인',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // 하단 고정 푸터
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 12, 20, 16),
                      child: Text('Wintek Corp. 임직원 전용 시스템입니다',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textMuted)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textTitle)),
      );

  Widget _inputBox({
    required IconData icon,
    required FocusNode focusNode,
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    Widget? trailing,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    ValueChanged<String>? onSubmitted,
  }) {
    final focused = focusNode.hasFocus;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: focused ? AppColors.primary : AppColors.border,
          width: focused ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon,
              size: 16,
              color: focused ? AppColors.primary : AppColors.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              obscureText: obscure,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              onChanged: (_) => setState(() {}),
              onSubmitted: onSubmitted,
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 13),
                filled: false,
              ).copyWith(hintText: hint),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }

  Widget _autoLoginCheck() {
    return InkWell(
      onTap: () => setState(() => _autoLogin = !_autoLogin),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: _autoLogin ? AppColors.primary : AppColors.surface,
              border: Border.all(
                color: _autoLogin ? AppColors.primary : AppColors.checkboxBorder,
                width: 2,
              ),
            ),
            child: _autoLogin
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 8),
          const Text('자동 로그인',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSub)),
        ],
      ),
    );
  }
}
