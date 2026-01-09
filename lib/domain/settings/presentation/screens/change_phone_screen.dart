// =============================================================================
// CHANGE PHONE SCREEN (전화번호 변경 화면)
// =============================================================================
//
// 이 화면은 사용자가 기존 전화번호를 새 전화번호로 변경할 수 있도록 지원합니다.
//
// 주요 기능:
// 1. 현재 저장된 전화번호를 Firestore에서 불러와 보여줍니다
// 2. 입력된 새 전화번호의 유효성을 검사합니다
// 3. Firestore에 전화번호를 업데이트합니다
// 4. 진행 중 상태를 나타내는 로딩 인디케이터 표시 및 에러/성공 메시지 제공
//
// 사용법:
// - 사용자 프로필 편집 기능의 하위 화면으로 연결
// - context.pop()을 통해 변경 완료 시 이전 화면으로 복귀
//
// UI 구성:
// - 현재 전화번호 표시
// - 새 전화번호 입력 필드 (10-11자리, 유효성 검사 포함)
// - 'Update' 버튼
// - 로딩 중 오버레이 표시
// =============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/widgets/modern_toast.dart';
import 'package:go_router/go_router.dart';
import 'package:country_code_picker/country_code_picker.dart';
import '../../../../core/themes/app_dimensions.dart';
import '../../../../core/themes/app_font_weights.dart';
import '../../../../core/themes/app_spacing.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/themes/app_shadows.dart';
import '../../../../core/themes/color_theme.dart';
import '../../../../core/themes/app_typography.dart';
import '../../../../core/widgets/common_app_bar.dart';

class ChangePhoneScreen extends StatefulWidget {
  const ChangePhoneScreen({super.key});

  @override
  State<ChangePhoneScreen> createState() => _ChangePhoneScreenState();
}

class _ChangePhoneScreenState extends State<ChangePhoneScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  String? _currentPhone;
  bool _isLoading = false;

  // Phone number field state variables
  String _selectedCountryCode = '+82'; // Default to Korea
  bool _isPhoneFocused = false;
  final FocusNode _phoneFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadCurrentPhone();
    _phoneFocusNode.addListener(() {
      setState(() {
        _isPhoneFocused = _phoneFocusNode.hasFocus;
      });
    });
  }

  Future<void> _loadCurrentPhone() async {
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
        final fullPhoneNumber = data?['phoneNumber'] ?? '';
        setState(() {
          _currentPhone = fullPhoneNumber;

          // Extract country code and phone number
          if (fullPhoneNumber.isNotEmpty) {
            // Try to extract country code (assume it starts with +)
            final countryCodeMatch = RegExp(
              r'^\+\d{1,4}',
            ).firstMatch(fullPhoneNumber);
            if (countryCodeMatch != null) {
              _selectedCountryCode = countryCodeMatch.group(0)!;
              _phoneController.text = fullPhoneNumber.substring(
                _selectedCountryCode.length,
              );
            } else {
              _phoneController.text = fullPhoneNumber;
            }
          }
        });
      }
    } catch (e) {
      _showToast('Failed to load current phone number: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }

    // Remove any non-digit characters for validation
    final digitsOnly = value.trim().replaceAll(RegExp(r'[^\d]'), '');

    // Basic phone number length validation (adjust as needed)
    if (digitsOnly.length < 8 || digitsOnly.length > 15) {
      return 'Phone number must be 8-15 digits';
    }
    return null;
  }

  Future<void> _updatePhone() async {
    if (!_formKey.currentState!.validate()) return;

    final newPhone = '$_selectedCountryCode${_phoneController.text.trim()}';
    if (newPhone == _currentPhone) {
      _showToast('New phone number is the same as current phone number');
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
        'phoneNumber': newPhone,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _showToast('Phone number updated successfully!');
      if (mounted) context.pop();
    } catch (e) {
      _showToast('Failed to update phone number: $e');
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
      appBar: const CommonAppBarWithBack(title: 'Change Phone Number'),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: AppSpacing.paddingXL,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppSpacing.v20,
                      Text(
                        'Current Phone Number',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppCommonColors.grey600,
                        ),
                      ),
                      AppSpacing.v8,
                      Container(
                        padding: AppSpacing.paddingL,
                        decoration: BoxDecoration(
                          color: AppCommonColors.grey100,
                          borderRadius: AppDimensions.borderRadiusS,
                        ),
                        child: Text(
                          _currentPhone?.isEmpty ?? true
                              ? 'No phone number set'
                              : _currentPhone!,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: _currentPhone?.isEmpty ?? true
                                ? AppCommonColors.grey600
                                : AppCommonColors.black.withValues(alpha: 0.87),
                          ),
                        ),
                      ),
                      AppSpacing.v30,
                      Text(
                        'New Phone Number',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppCommonColors.grey600,
                        ),
                      ),
                      AppSpacing.v8,
                      // Phone number input with country code - using ModernTextField structure
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: AppDimensions.borderRadiusL,
                          boxShadow: _isPhoneFocused
                              ? AppShadows.primaryShadow(AppColors.primary)
                              : AppShadows.button,
                        ),
                        child: TextFormField(
                          controller: _phoneController,
                          focusNode: _phoneFocusNode,
                          validator: _validatePhone,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: TextStyle(
                            fontSize: AppDimensions.iconS,
                            fontWeight: AppFontWeights.medium,
                            color: AppColors.text,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            hintText: 'Enter your phone number',
                            prefixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AppSpacing.h12,
                                Icon(
                                  Icons.phone_outlined,
                                  color: AppColors.secondary,
                                  size: AppDimensions.iconM,
                                ),
                                AppSpacing.h4,
                                CountryCodePicker(
                                  onChanged: (countryCode) {
                                    setState(() {
                                      _selectedCountryCode =
                                          countryCode.dialCode!;
                                    });
                                  },
                                  initialSelection: 'KR',
                                  favorite: const ['+82', 'KR', '+1', 'US'],
                                  showCountryOnly: false,
                                  showOnlyCountryWhenClosed: false,
                                  alignLeft: false,
                                  textStyle: TextStyle(
                                    fontSize: 14,
                                    fontWeight: AppFontWeights.medium,
                                    color: AppColors.text,
                                  ),
                                  dialogTextStyle: AppTypography.bodyRegular,
                                  searchStyle: AppTypography.bodyRegular,
                                  searchDecoration: const InputDecoration(
                                    hintText: 'Search country',
                                  ),
                                  dialogBackgroundColor: AppCommonColors.white,
                                  barrierColor: AppCommonColors.black,
                                  backgroundColor: Colors.transparent,
                                  boxDecoration: const BoxDecoration(),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.xs,
                                    vertical: AppSpacing.s,
                                  ),
                                ),
                                Container(
                                  width: AppDimensions.dividerThickness,
                                  height: AppDimensions.iconM,
                                  color: AppColors.secondary.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                                AppSpacing.h8,
                              ],
                            ),
                            labelStyle: TextStyle(
                              fontSize: 10,
                              fontWeight: AppFontWeights.medium,
                              color: _isPhoneFocused
                                  ? AppColors.primary
                                  : AppColors.secondary,
                            ),
                            hintStyle: const TextStyle(
                              fontSize: 10,
                              color: AppCommonColors.grey400,
                            ),
                            filled: true,
                            fillColor: _isPhoneFocused
                                ? AppColors.background
                                : AppCommonColors.grey50,
                            border: OutlineInputBorder(
                              borderRadius: AppDimensions.borderRadiusL,
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: AppDimensions.borderRadiusL,
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: AppDimensions.borderRadiusL,
                              borderSide: BorderSide(
                                color: AppColors.accent,
                                width: 1,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: AppDimensions.borderRadiusL,
                              borderSide: BorderSide(
                                color: AppColors.accent,
                                width: 2,
                              ),
                            ),
                            contentPadding: AppSpacing.textFieldPadding,
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                          ),
                        ),
                      ),
                      AppSpacing.v30,
                      ElevatedButton(
                        onPressed: _isLoading ? null : _updatePhone,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: AppCommonColors.white,
                          padding: AppSpacing.paddingVerticalL,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppDimensions.borderRadiusS,
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: AppCommonColors.white,
                              )
                            : const Text(
                                'Update Phone Number',
                                style: TextStyle(
                                  fontSize: AppDimensions.iconS,
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
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }
}
