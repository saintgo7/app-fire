import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 로고 및 타이틀
                      _buildHeader(context),
                      const SizedBox(height: 48),

                      // 로그인 카드
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // 이메일 입력
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  style: AppTextStyles.bodyLarge,
                                  decoration: const InputDecoration(
                                    labelText: '이메일',
                                    hintText: 'email@example.com',
                                    prefixIcon: Icon(Icons.email),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '이메일을 입력해주세요';
                                    }
                                    if (!value.contains('@')) {
                                      return '올바른 이메일 형식이 아닙니다';
                                    }
                                    return null;
                                  },
                                  enabled: !auth.isLoading,
                                ),
                                const SizedBox(height: 20),

                                // 비밀번호 입력
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _handleLogin(),
                                  style: AppTextStyles.bodyLarge,
                                  decoration: InputDecoration(
                                    labelText: '비밀번호',
                                    hintText: '비밀번호를 입력하세요',
                                    prefixIcon: const Icon(Icons.lock),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '비밀번호를 입력해주세요';
                                    }
                                    if (value.length < 6) {
                                      return '비밀번호는 6자 이상이어야 합니다';
                                    }
                                    return null;
                                  },
                                  enabled: !auth.isLoading,
                                ),
                                const SizedBox(height: 8),

                                // 에러 메시지
                                if (auth.errorMessage != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      auth.errorMessage!,
                                      style: AppTextStyles.errorMessage,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                const SizedBox(height: 32),

                                // 로그인 버튼
                                ElevatedButton(
                                  onPressed: auth.isLoading ? null : _handleLogin,
                                  child: auth.isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          '로그인',
                                          style: AppTextStyles.labelLarge,
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 회원가입 버튼
                      TextButton(
                        onPressed: auth.isLoading
                            ? null
                            : () {
                                Navigator.pushNamed(context, '/register');
                              },
                        child: Text(
                          '계정이 없으신가요? 회원가입',
                          style: AppTextStyles.labelLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 헤더 (로고 + 타이틀)
  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        // 로고 아이콘
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryLight.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.local_fire_department,
            size: 56,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),

        // 타이틀
        Text(
          '소방 안전 점검',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.primaryLight,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // 서브타이틀
        Text(
          '안전한 사회를 위한 첫걸음',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.onSurfaceVariantLight,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
} 