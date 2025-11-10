import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 로고 및 제목
              const Icon(
                Icons.local_fire_department,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 24),
              const Text(
                '소방시설 점검',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Fire Safety Inspector',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),

              // 로그인 버튼들
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  final isLoading = authProvider.status == AuthStatus.loading;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 구글 로그인 버튼
                      _SocialLoginButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                final success = await authProvider.signInWithGoogle();
                                if (success && context.mounted) {
                                  Navigator.pushReplacementNamed(context, '/');
                                } else if (context.mounted && authProvider.errorMessage != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(authProvider.errorMessage!)),
                                  );
                                }
                              },
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        icon: 'assets/images/google_logo.png', // 로고 이미지 필요
                        label: 'Google로 계속하기',
                        borderColor: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 12),

                      // 카카오 로그인 버튼
                      _SocialLoginButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                final success = await authProvider.signInWithKakao();
                                if (success && context.mounted) {
                                  Navigator.pushReplacementNamed(context, '/');
                                } else if (context.mounted && authProvider.errorMessage != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(authProvider.errorMessage!)),
                                  );
                                }
                              },
                        backgroundColor: const Color(0xFFFEE500),
                        foregroundColor: Colors.black87,
                        icon: 'assets/images/kakao_logo.png', // 로고 이미지 필요
                        label: '카카오로 계속하기',
                      ),
                      const SizedBox(height: 12),

                      // 네이버 로그인 버튼
                      _SocialLoginButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                final success = await authProvider.signInWithNaver();
                                if (success && context.mounted) {
                                  Navigator.pushReplacementNamed(context, '/');
                                } else if (context.mounted && authProvider.errorMessage != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(authProvider.errorMessage!)),
                                  );
                                }
                              },
                        backgroundColor: const Color(0xFF03C75A),
                        foregroundColor: Colors.white,
                        icon: 'assets/images/naver_logo.png', // 로고 이미지 필요
                        label: '네이버로 계속하기',
                      ),

                      if (isLoading) ...[
                        const SizedBox(height: 24),
                        const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ],
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // 약관 동의 텍스트
              Text(
                '로그인 시 서비스 이용약관 및 개인정보 처리방침에 동의하게 됩니다.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final String icon;
  final String label;
  final Color? borderColor;

  const _SocialLoginButton({
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    required this.label,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: borderColor != null
                ? BorderSide(color: borderColor!)
                : BorderSide.none,
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 아이콘은 나중에 실제 로고 이미지로 교체
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: foregroundColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.login,
                size: 16,
                color: foregroundColor,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: foregroundColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 