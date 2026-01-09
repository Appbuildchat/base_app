// =============================================================================
// PROFILE ACTION BUTTON WIDGET (프로필 액션 버튼 위젯)
// =============================================================================
//
// 프로필 편집/저장 버튼을 담당하는 위젯입니다.
//
// 주요 기능:
// 1. 편집/저장 모드 전환 버튼
// 2. 저장 중 로딩 상태 표시
// 3. 버튼 상태에 따른 텍스트 변경
// 4. 앱바에 들어갈 수 있는 형태
// 5. 프로필 데이터 저장 로직 통합
// 6. 편집 취소 기능
//
// 사용 방법:
// ```dart
// ProfileActionButtonWidget(
//   isEditing: _isEditing,
//   isSaving: _isSaving,
//   usernameController: _usernameController,
//   bioController: _bioController,
//   selectedImageFile: _selectedImageFile,
//   originalUsername: _originalUsername,
//   originalBio: _originalBio,
//   originalImagePath: _originalImagePath,
//   onEditModeChanged: (isEditing) => setState(() => _isEditing = isEditing),
//   onSavingChanged: (isSaving) => setState(() => _isSaving = isSaving),
//   onDataUpdated: (username, bio, imagePath) {
//     setState(() {
//       _currentUsername = username;
//       _currentBio = bio;
//       _profileImagePath = imagePath;
//       _originalUsername = username;
//       _originalBio = bio;
//       _originalImagePath = imagePath;
//       _selectedImageFile = null;
//     });
//   },
//   onImageCleared: () => setState(() => _selectedImageFile = null),
// )
// ```
// =============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../core/themes/color_theme.dart';
import '../../../../core/themes/app_theme.dart';
import '../../functions/update_user_username.dart';
import '../../functions/update_user_field.dart';
import '../../../../core/image_picker/upload_image.dart';
import '../../../../../core/themes/app_font_weights.dart';

class ProfileActionButtonWidget extends StatefulWidget {
  final bool isEditing;
  final bool isSaving;
  final TextEditingController usernameController;
  final TextEditingController bioController;
  final File? selectedImageFile;
  final String originalUsername;
  final String originalBio;
  final String? originalImagePath;
  final Function(bool) onEditModeChanged;
  final Function(bool) onSavingChanged;
  final Function(String, String, String?) onDataUpdated;
  final VoidCallback onImageCleared;

  const ProfileActionButtonWidget({
    super.key,
    required this.isEditing,
    required this.isSaving,
    required this.usernameController,
    required this.bioController,
    this.selectedImageFile,
    required this.originalUsername,
    required this.originalBio,
    this.originalImagePath,
    required this.onEditModeChanged,
    required this.onSavingChanged,
    required this.onDataUpdated,
    required this.onImageCleared,
  });

  @override
  State<ProfileActionButtonWidget> createState() =>
      _ProfileActionButtonWidgetState();
}

class _ProfileActionButtonWidgetState extends State<ProfileActionButtonWidget> {
  void _toggleEditMode() {
    if (widget.isEditing) {
      _saveAllChanges();
    } else {
      widget.onEditModeChanged(true);
    }
  }

  Future<void> _saveAllChanges() async {
    if (widget.usernameController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter a username.'),
            backgroundColor: AppColors.accent,
          ),
        );
      }
      return;
    }

    widget.onSavingChanged(true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      bool hasChanges = false;

      // Save username if changed
      if (widget.usernameController.text.trim() != widget.originalUsername) {
        final result = await updateUserUsername(
          currentUser.uid,
          widget.usernameController.text.trim(),
        );

        if (!result.isSuccess) {
          if (mounted) {
            final errorMsg = result.message ?? result.error;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to change username: $errorMsg'),
                backgroundColor: AppColors.accent,
              ),
            );
          }
          return;
        }
        hasChanges = true;
      }

      // Save bio if changed
      if (widget.bioController.text.trim() != widget.originalBio) {
        final result = await updateUserField<String>(
          currentUser.uid,
          'bio',
          widget.bioController.text.trim(),
        );

        if (!result.isSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to update bio: ${result.error}'),
                backgroundColor: AppColors.accent,
              ),
            );
          }
          return;
        }
        hasChanges = true;
      }

      // Save profile image if changed
      String? newImageUrl;
      if (widget.selectedImageFile != null) {
        final uploadResult = await uploadProfileImage(
          currentUser.uid,
          widget.selectedImageFile!,
          oldImageUrl: widget.originalImagePath,
        );

        if (!uploadResult.isSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to upload image: ${uploadResult.error}'),
                backgroundColor: AppColors.accent,
              ),
            );
          }
          return;
        }

        newImageUrl = uploadResult.data!;

        // Save image URL to Firestore
        final imageUpdateResult = await updateUserField<String>(
          currentUser.uid,
          'imageUrl',
          newImageUrl,
        );

        if (!imageUpdateResult.isSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to save image URL: ${imageUpdateResult.error}',
                ),
                backgroundColor: AppColors.accent,
              ),
            );
          }
          return;
        }

        hasChanges = true;
      }

      // Update data through callback
      final newUsername = widget.usernameController.text.trim();
      final newBio = widget.bioController.text.trim();
      final finalImagePath = newImageUrl ?? widget.originalImagePath;

      widget.onDataUpdated(newUsername, newBio, finalImagePath);
      widget.onImageCleared();
      widget.onEditModeChanged(false);

      if (mounted && hasChanges) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile has been updated successfully.'),
            backgroundColor: AppCommonColors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error occurred while updating profile: $e'),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    } finally {
      widget.onSavingChanged(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isSaving) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return TextButton(
      onPressed: _toggleEditMode,
      child: Text(
        widget.isEditing ? 'Save' : 'Edit',
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: AppFontWeights.semiBold,
        ),
      ),
    );
  }
}
