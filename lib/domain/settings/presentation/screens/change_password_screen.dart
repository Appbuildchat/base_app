// =============================================================================
// CHANGE PASSWORD SCREEN (비밀번호 변경 화면)
// =============================================================================
//
// 이 화면은 사용자가 현재 비밀번호를 입력하고 새로운 비밀번호로 변경할 수 있도록 지원합니다.
//
// 주요 기능:
// 1. 현재 비밀번호를 확인하고 재인증 수행 (Firebase reauthenticate)
// 2. 새로운 비밀번호 유효성 검사 및 일치 여부 확인
// 3. 비밀번호 변경 후 사용자에게 성공/실패 메시지 출력
// 4. 진행 중 상태를 나타내는 로딩 인디케이터 표시
//
// 사용법:
// - 프로필 설정 화면 등에서 연결해 비밀번호 변경 기능 제공
//
// UI 구성:
// - 비밀번호 3종 입력 필드: 현재 / 새 비밀번호 / 새 비밀번호 확인
// - '보이기/숨기기' 토글 아이콘 제공
// - 유효성 검사 및 에러 메시지
// - 저장 버튼 및 로딩 처리
// =============================================================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../../core/widgets/modern_toast.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/validators.dart';
import '../../../../../core/themes/app_font_weights.dart';
import '../../../../../core/themes/app_theme.dart';
import '../../../../../core/widgets/common_app_bar.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _currentPasswordError;
  final Map<String, bool> _obscure = {
    'current': true,
    'new': true,
    'confirm': true,
  };

  void _toggleVisibility(String field) {
    setState(() {
      _obscure[field] = !_obscure[field]!;
    });
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required String fieldKey,
    required FormFieldValidator<String> validator,
    String? errorText,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: _obscure[fieldKey]!,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscure[fieldKey]!
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: () => _toggleVisibility(fieldKey),
        ),
        errorText: errorText,
      ),
      validator: validator,
      onChanged: fieldKey == 'current'
          ? (_) {
              if (_currentPasswordError != null) {
                setState(() {
                  _currentPasswordError = null;
                });
              }
            }
          : null,
    );
  }

  Future<void> _handleChangePassword() async {
    final current = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (newPassword != confirm) {
      ModernToast.showError(context, 'New passwords do not match');
      return;
    }

    if (current == newPassword) {
      ModernToast.showError(
        context,
        'New password cannot be the same as current password',
      );
      return;
    }

    final passwordError = Validators.password(newPassword);
    if (passwordError != null) {
      ModernToast.showError(context, passwordError);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user == null) {
        ModernToast.showError(
          context,
          'You are not authenticated. Please log in again.',
        );
        return;
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: current,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      if (mounted) {
        ModernToast.showSuccess(context, 'Password successfully updated');
        context.pop();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' ||
          e.message?.contains('malformed or has expired') == true) {
        setState(() {
          _currentPasswordError = 'Current password is incorrect';
        });
      } else {
        final message = switch (e.code) {
          'weak-password' => 'The new password is too weak.',
          _ => 'Failed to change password: ${e.message}',
        };
        if (mounted) {
          ModernToast.showError(context, message);
        }
      }
    } catch (e) {
      if (mounted) {
        ModernToast.showError(context, 'An unexpected error occurred: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBarWithBack(title: 'Change Password'),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Update your password',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: AppFontWeights.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter your current password and a new password.',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppCommonColors.grey500,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildPasswordField(
                      label: 'Current password',
                      controller: _currentPasswordController,
                      fieldKey: 'current',
                      errorText: _currentPasswordError,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter your current password'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      label: 'New password',
                      controller: _newPasswordController,
                      fieldKey: 'new',
                      validator: (value) => value == null || value.length < 8
                          ? 'Password must be at least 8 characters'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      label: 'Confirm new password',
                      controller: _confirmPasswordController,
                      fieldKey: 'confirm',
                      validator: (value) => value != _newPasswordController.text
                          ? 'Passwords do not match'
                          : null,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: AppCommonColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: _isLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  _handleChangePassword();
                                }
                              },
                        child: const Text('Update'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: AppCommonColors.black.withValues(alpha: 0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
