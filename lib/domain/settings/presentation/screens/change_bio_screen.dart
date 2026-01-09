// =============================================================================
// CHANGE BIO SCREEN (소개글 변경 화면)
// =============================================================================
//
// 이 화면은 사용자가 자신의 프로필 소개글(Bio)을 수정할 수 있도록 제공하는 UI입니다.
//
// 주요 기능:
// 1. 현재 저장된 소개글(Bio)을 불러와 사용자에게 보여줍니다
// 2. 사용자는 새로운 소개글을 입력하고 최대 150자까지 저장할 수 있습니다
// 3. 유효성 검사를 통해 빈 입력 또는 글자 수 초과를 방지합니다
// 4. Firebase Firestore에 업데이트된 소개글을 저장합니다
// 5. 업데이트 진행 중에는 로딩 인디케이터가 표시됩니다
//
// 사용법:
// - 사용자 프로필 편집 화면의 하위 화면으로 연결
// - context.pop()으로 이전 화면으로 복귀
//
// UI 구성:
// - AppBar: 뒤로가기 버튼 포함
// - 현재 소개글 섹션 (조건부 렌더링)
// - 텍스트 입력 필드 및 유효성 검사
// - 저장 버튼 (비활성화 조건 포함)
// - CircularProgressIndicator: 저장 중 시 표시
// =============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../../core/widgets/modern_toast.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/themes/app_font_weights.dart';
import '../../../../core/widgets/common_app_bar.dart';

class ChangeBioScreen extends StatefulWidget {
  const ChangeBioScreen({super.key});

  @override
  State<ChangeBioScreen> createState() => _ChangeBioScreenState();
}

class _ChangeBioScreenState extends State<ChangeBioScreen> {
  static const int _maxBioLength = 1000;

  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String? _currentBio;
  bool _isLoading = false;
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _bioController.addListener(_updateCharCount);
    _fetchCurrentBio();
  }

  void _updateCharCount() {
    setState(() {
      _charCount = _bioController.text.length;
    });
  }

  Future<void> _fetchCurrentBio() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    final data = doc.data();
    if (data != null && data['bio'] is String) {
      setState(() {
        _currentBio = data['bio'] as String;
      });
    }
  }

  String? _validateBio(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a bio';
    }
    if (value.length > _maxBioLength) {
      return 'Bio must be less than $_maxBioLength characters';
    }
    return null;
  }

  Future<void> _changeBio(String newBio) async {
    final trimmed = newBio.trim();
    final error = _validateBio(trimmed);
    if (error != null) {
      ModernToast.showError(context, error);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'bio': trimmed,
      });
      if (mounted) {
        ModernToast.showSuccess(context, 'Bio successfully updated');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ModernToast.showError(context, 'Failed to change bio: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildCurrentBioSection() {
    if (_currentBio == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Current bio',
          style: TextStyle(fontWeight: AppFontWeights.medium),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _currentBio!,
            style: const TextStyle(color: Colors.black87),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildBioInputField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _bioController,
          maxLines: 3,
          maxLength: _maxBioLength,
          decoration: const InputDecoration(
            labelText: 'New bio',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.edit_note_outlined),
            counterText: '',
          ),
          validator: _validateBio,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '$_charCount/$_maxBioLength',
            style: TextStyle(
              fontSize: 12,
              color: _charCount > 900
                  ? (_charCount >= 1000 ? Colors.red : Colors.orange)
                  : Colors.grey[600],
            ),
          ),
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
                  _changeBio(_bioController.text);
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
      appBar: const CommonAppBarWithBack(title: 'Change Bio'),
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
                      'Update your bio',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: AppFontWeights.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter a new bio that describes you.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    _buildCurrentBioSection(),
                    _buildBioInputField(),
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
    _bioController.removeListener(_updateCharCount);
    _bioController.dispose();
    super.dispose();
  }
}
