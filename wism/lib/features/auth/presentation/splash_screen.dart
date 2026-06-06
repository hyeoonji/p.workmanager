import 'package:flutter/material.dart';

/// 토큰 검증 중 표시. 분기는 라우터 redirect(인증 상태)가 처리.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF14387F), Color(0xFF0F2A5E)],
          ),
        ),
        child: Stack(
          children: [
            // 중앙 브랜드
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 32,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.shield_outlined,
                        color: Colors.white, size: 44),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'WISM',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 2.4,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Wintek Insight System Manager',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFA8B5C8)),
                  ),
                ],
              ),
            ),
            // 하단 스피너 + 카피라이트
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(Colors.white70),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text('© 2026 Wintek Corp.',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.55))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
