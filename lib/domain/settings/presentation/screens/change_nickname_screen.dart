// =============================================================================
// CHANGE NICKNAME SCREEN (닉네임 변경 화면)
// =============================================================================
//
// 이 화면은 사용자가 기존 닉네임을 새 닉네임으로 변경할 수 있도록 지원합니다.
//
// 주요 기능:
// 1. 현재 저장된 닉네임을 Firestore에서 불러와 보여줍니다
// 2. 입력된 새 닉네임의 유효성을 검사합니다
// 3. Firestore에 닉네임을 업데이트합니다
// 4. 진행 중 상태를 나타내는 로딩 인디케이터 표시 및 에러/성공 메시지 제공
//
// 사용법:
// - 사용자 프로필 편집 기능의 하위 화면으로 연결
// - context.pop()을 통해 변경 완료 시 이전 화면으로 복귀
//
// UI 구성:
// - 현재 닉네임 표시
// - 새 닉네임 입력 필드 (최대 15자, 유효성 검사 포함)
// - 'Update' 버튼
// - 로딩 중 오버레이 표시
// =============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../../core/widgets/modern_toast.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/themes/app_font_weights.dart';
import '../../../../core/widgets/common_app_bar.dart';
import '../../../../core/themes/app_theme.dart';

class ChangeNicknameScreen extends StatefulWidget {
  const ChangeNicknameScreen({super.key});

  @override
  State<ChangeNicknameScreen> createState() => _ChangeNicknameScreenState();
}

class _ChangeNicknameScreenState extends State<ChangeNicknameScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();

  String? _currentNickname;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentNickname();
  }

  Future<void> _loadCurrentNickname() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        _showToast('Please log in first.');
        if (mounted) context.pop();
        return;
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        setState(() {
          _currentNickname = data?['nickname'] ?? '';
          _nicknameController.text = _currentNickname ?? '';
        });
      }
    } catch (e) {
      _showToast('Failed to load current nickname: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String? _validateNickname(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your nickname';
    } else if (value.trim().length < 2) {
      return 'Nickname must be at least 2 characters';
    } else if (value.trim().length > 15) {
      return 'Nickname must be less than 15 characters';
    } else if (value.contains(' ')) {
      return 'Nickname cannot contain spaces';
    }
    return null;
  }

  Future<void> _updateNickname() async {
    if (!_formKey.currentState!.validate()) return;

    final newNickname = _nicknameController.text.trim();
    if (newNickname == _currentNickname) {
      _showToast('New nickname is the same as current nickname');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        _showToast('Please log in first.');
        return;
      }

      await _firestore.collection('users').doc(user.uid).update({
        'nickname': newNickname,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _showToast('Nickname updated successfully!');
      if (mounted) context.pop();
    } catch (e) {
      _showToast('Failed to update nickname: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showToast(String message) {
    if (message.toLowerCase().contains('success')) {
      ModernToast.showSuccess(context, message);
    } else {
      ModernToast.showError(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CommonAppBarWithBack(title: 'Change Nickname'),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'Current Nickname',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppCommonColors.grey600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppCommonColors.grey100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _currentNickname?.isEmpty ?? true
                              ? 'No nickname set'
                              : _currentNickname!,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: _currentNickname?.isEmpty ?? true
                                ? Colors.grey[600]
                                : AppCommonColors.black.withValues(alpha: 0.87),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'New Nickname',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppCommonColors.grey600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nicknameController,
                        validator: _validateNickname,
                        decoration: InputDecoration(
                          hintText: 'Enter new nickname',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        maxLength: 15,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _updateNickname,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: AppCommonColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: AppCommonColors.white,
                              )
                            : const Text(
                                'Update Nickname',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: AppFontWeights.bold,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }
}
