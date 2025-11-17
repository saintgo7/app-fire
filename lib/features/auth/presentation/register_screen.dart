import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _organizationController = TextEditingController();
  final _fireStationController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _organizationController.dispose();
    _fireStationController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      organization: _organizationController.text.trim().isEmpty
          ? null
          : _organizationController.text.trim(),
      fireStation: _fireStationController.text.trim().isEmpty
          ? null
          : _fireStationController.text.trim(),
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          '회원가입',
          style: AppTextStyles.titleLarge,
        ),
      ),
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 헤더
                      _buildHeader(context),
                      const SizedBox(height: 32),

                      // 회원가입 폼 카드
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: _buildFormFields(context, auth),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 로그인 화면으로 돌아가기
                      TextButton(
                        onPressed: auth.isLoading
                            ? null
                            : () {
                                Navigator.pop(context);
                              },
                        child: Text(
                          '이미 계정이 있으신가요? 로그인',
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

  /// 헤더
  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        // 타이틀
        Text(
          '소방 점검관 계정 만들기',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.primaryLight,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // 서브타이틀
        Text(
          '계정 정보를 입력해주세요',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.onSurfaceVariantLight,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 폼 필드들
  List<Widget> _buildFormFields(BuildContext context, AuthProvider auth) {
    return [

      // 필수 정보 섹션 헤더
      Text(
        '필수 정보',
        style: AppTextStyles.titleSmall.copyWith(
          color: AppColors.primaryLight,
        ),
      ),
      const SizedBox(height: 16),

      // 이름 (필수)
      TextFormField(
        controller: _nameController,
        textInputAction: TextInputAction.next,
        style: AppTextStyles.bodyLarge,
        decoration: const InputDecoration(
          labelText: '이름 *',
          hintText: '홍길동',
          prefixIcon: Icon(Icons.person),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '이름을 입력해주세요';
          }
          return null;
        },
        enabled: !auth.isLoading,
      ),
      const SizedBox(height: 16),

      // 이메일 (필수)
      TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        style: AppTextStyles.bodyLarge,
        decoration: const InputDecoration(
          labelText: '이메일 *',
          hintText: 'email@example.com',
          prefixIcon: Icon(Icons.email),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '이메일을 입력해주세요';
          }
          if (!value.contains('@') || !value.contains('.')) {
            return '올바른 이메일 형식이 아닙니다';
          }
          return null;
        },
        enabled: !auth.isLoading,
      ),
      const SizedBox(height: 16),

      // 비밀번호 (필수)
      TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        textInputAction: TextInputAction.next,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          labelText: '비밀번호 *',
          hintText: '6자 이상 입력',
          prefixIcon: const Icon(Icons.lock),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
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
      const SizedBox(height: 16),

      // 비밀번호 확인 (필수)
      TextFormField(
        controller: _passwordConfirmController,
        obscureText: _obscurePasswordConfirm,
        textInputAction: TextInputAction.next,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          labelText: '비밀번호 확인 *',
          hintText: '비밀번호를 다시 입력',
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePasswordConfirm
                  ? Icons.visibility_off
                  : Icons.visibility,
            ),
            onPressed: () {
              setState(() {
                _obscurePasswordConfirm = !_obscurePasswordConfirm;
              });
            },
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '비밀번호를 다시 입력해주세요';
          }
          if (value != _passwordController.text) {
            return '비밀번호가 일치하지 않습니다';
          }
          return null;
        },
        enabled: !auth.isLoading,
      ),
      const SizedBox(height: 24),

      // 선택 정보 섹션
      Text(
        '추가 정보 (선택)',
        style: AppTextStyles.titleSmall.copyWith(
          color: AppColors.onSurfaceVariantLight,
        ),
      ),
      const SizedBox(height: 16),

      // 전화번호 (선택)
      TextFormField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.next,
        style: AppTextStyles.bodyLarge,
        decoration: const InputDecoration(
          labelText: '전화번호',
          hintText: '010-1234-5678',
          prefixIcon: Icon(Icons.phone),
        ),
        enabled: !auth.isLoading,
      ),
      const SizedBox(height: 16),

      // 소속 기관 (선택)
      TextFormField(
        controller: _organizationController,
        textInputAction: TextInputAction.next,
        style: AppTextStyles.bodyLarge,
        decoration: const InputDecoration(
          labelText: '소속 기관',
          hintText: '서울소방청',
          prefixIcon: Icon(Icons.business),
        ),
        enabled: !auth.isLoading,
      ),
      const SizedBox(height: 16),

      // 소방서 (선택)
      TextFormField(
        controller: _fireStationController,
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) => _handleRegister(),
        style: AppTextStyles.bodyLarge,
        decoration: const InputDecoration(
          labelText: '소방서',
          hintText: '도봉소방서',
          prefixIcon: Icon(Icons.local_fire_department),
        ),
        enabled: !auth.isLoading,
      ),
      const SizedBox(height: 8),

      // 에러 메시지
      if (auth.errorMessage != null)
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Text(
            auth.errorMessage!,
            style: AppTextStyles.errorMessage,
            textAlign: TextAlign.center,
          ),
        ),
      const SizedBox(height: 32),

      // 회원가입 버튼
      ElevatedButton(
        onPressed: auth.isLoading ? null : _handleRegister,
        child: auth.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : Text(
                '회원가입',
                style: AppTextStyles.labelLarge,
              ),
      ),
    ];
  }
} 