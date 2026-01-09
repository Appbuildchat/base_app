// =============================================================================
// CHANGE USERNAME SCREEN (사용자 이름 변경 화면)
// =============================================================================
//
// 이 화면은 사용자가 기존 사용자 이름(Username)을 새 이름으로 변경할 수 있도록 지원합니다.
//
// 주요 기능:
// 1. 현재 저장된 사용자 이름을 Firestore에서 불러와 보여줍니다
// 2. 입력된 새 사용자 이름의 유효성을 검사합니다
// 3. Firestore 및 FirebaseAuth 프로필에 사용자 이름을 동시에 업데이트합니다
// 4. 진행 중 상태를 나타내는 로딩 인디케이터 표시 및 에러/성공 메시지 제공
//
// 사용법:
// - 사용자 프로필 편집 기능의 하위 화면으로 연결
// - context.pop()을 통해 변경 완료 시 이전 화면으로 복귀
//
// UI 구성:
// - 현재 사용자 이름 표시
// - 새 사용자 이름 입력 필드 (최대 20자, 유효성 검사 포함)
// - 'Update' 버튼
// - 로딩 중 오버레이 표시
// =============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../../core/widgets/modern_toast.dart';
import '../../../../core/themes/app_spacing.dart';
import '../../../../core/themes/app_font_weights.dart';
import '../../../../core/widgets/common_app_bar.dart';
import 'package:go_router/go_router.dart';

class ChangeUsernameScreen extends StatefulWidget {
  const ChangeUsernameScreen({super.key});

  @override
  State<ChangeUsernameScreen> createState() => _ChangeUsernameScreenState();
}

class _ChangeUsernameScreenState extends State<ChangeUsernameScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  String? _currentFirstName;
  String? _currentLastName;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentName();
  }

  Future<void> _loadCurrentName() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    final data = doc.data();
    if (data != null) {
      setState(() {
        _currentFirstName = data['firstName'] ?? '';
        _currentLastName = data['lastName'] ?? '';
        _firstNameController.text = _currentFirstName ?? '';
        _lastNameController.text = _currentLastName ?? '';
      });
    }
  }

  String? _validateName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your $fieldName';
    }
    if (value.length < 2) {
      return '$fieldName must be at least 2 characters';
    }
    if (value.length > 20) {
      return '$fieldName must be less than 20 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return '$fieldName can only contain letters and spaces';
    }
    return null;
  }

  Future<void> _changeName(String firstName, String lastName) async {
    final firstNameValidation = _validateName(firstName, 'First name');
    if (firstNameValidation != null) {
      ModernToast.showError(context, firstNameValidation);
      return;
    }

    final lastNameValidation = _validateName(lastName, 'Last name');
    if (lastNameValidation != null) {
      ModernToast.showError(context, lastNameValidation);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final trimmedFirstName = firstName.trim();
      final trimmedLastName = lastName.trim();
      final user = _auth.currentUser;
      if (user == null) {
        ModernToast.showError(context, 'User not logged in');
        return;
      }

      await _firestore.collection('users').doc(user.uid).update({
        'firstName': trimmedFirstName,
        'lastName': trimmedLastName,
      });

      if (mounted) {
        ModernToast.showSuccess(context, 'Name successfully updated');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ModernToast.showError(context, 'Failed to change name: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildCurrentNameSection() {
    if (_currentFirstName == null || _currentLastName == null) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Current name',
          style: TextStyle(fontWeight: AppFontWeights.medium),
        ),
        AppSpacing.v4,
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$_currentFirstName $_currentLastName',
            style: const TextStyle(color: Colors.black87),
          ),
        ),
        AppSpacing.v24,
      ],
    );
  }

  Widget _buildNameInputFields() {
    return Column(
      children: [
        TextFormField(
          controller: _firstNameController,
          maxLength: 20,
          decoration: const InputDecoration(
            labelText: 'First Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person_outline),
            counterText: '',
          ),
          validator: (value) => _validateName(value, 'First name'),
        ),
        AppSpacing.v16,
        TextFormField(
          controller: _lastNameController,
          maxLength: 20,
          decoration: const InputDecoration(
            labelText: 'Last Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person_outline),
            counterText: '',
          ),
          validator: (value) => _validateName(value, 'Last name'),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : () {
                if (_formKey.currentState!.validate()) {
                  _changeName(
                    _firstNameController.text,
                    _lastNameController.text,
                  );
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('Update'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBarWithBack(title: 'Change Name'),
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
                    AppSpacing.v16,
                    const Text(
                      'Update your name',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: AppFontWeights.bold,
                      ),
                    ),
                    AppSpacing.v8,
                    const Text(
                      'Enter your first and last name.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    _buildCurrentNameSection(),
                    _buildNameInputFields(),
                    const SizedBox(height: 32),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }
}
