import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../functions/update_user_field.dart';
import '../../entities/user_entity.dart';
import '../../../../../core/themes/color_theme.dart';
import '../../../../core/themes/app_dimensions.dart';
import '../../../../core/themes/app_spacing.dart';
import '../../../../core/themes/app_font_weights.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/themes/app_shadows.dart';
import '../../../../core/themes/app_typography.dart';
import '../../../../../core/widgets/common_app_bar.dart';
import '../../../../../core/image_picker/media_picker_utils.dart';
import '../../../../../core/image_picker/upload_image.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // 로딩 상태
  bool _isUploadingImage = false;

  // 이미지 선택기
  final ImagePicker _imagePicker = ImagePicker();

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Select Profile Image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogOption(
              dialogContext,
              Icons.perm_media,
              'Select from Gallery',
              () => _pickImageFromSource(ImageSource.gallery),
            ),
            if (!kIsWeb)
              _buildDialogOption(
                dialogContext,
                Icons.camera_alt,
                'Take Photo',
                () => _pickImageFromSource(ImageSource.camera),
              ),
            // Add delete option if user has a profile image
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseAuth.instance.currentUser != null
                  ? FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .snapshots()
                  : null,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.exists) {
                  final userData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  final userEntity = UserEntity.fromJson(userData);

                  if (userEntity.imageUrl != null &&
                      userEntity.imageUrl!.isNotEmpty) {
                    return _buildDialogOption(
                      dialogContext,
                      Icons.delete,
                      'Delete profile image',
                      () => _deleteProfileImage(),
                    );
                  }
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogOption(
    BuildContext dialogContext,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.of(dialogContext).pop();
        onTap();
      },
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: ImagePickerConstants.maxWidth.toDouble(),
        maxHeight: ImagePickerConstants.maxHeight.toDouble(),
        imageQuality: ImagePickerConstants.imageQuality,
      );

      if (pickedFile != null) {
        // Get current image URL from context if available
        if (kIsWeb) {
          // Web: Use XFile directly
          await _uploadProfileImageFromXFile(pickedFile, null);
        } else {
          // Mobile: Convert to File
          await _uploadProfileImage(File(pickedFile.path), null);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    }
  }

  Future<void> _uploadProfileImageFromXFile(
    XFile imageFile,
    String? currentImageUrl,
  ) async {
    setState(() {
      _isUploadingImage = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      // Upload the profile image directly from XFile (web-compatible)
      final uploadResult = await uploadProfileImageFromXFile(
        currentUser.uid,
        imageFile,
        oldImageUrl: currentImageUrl,
      );

      if (uploadResult.isSuccess) {
        // Update user profile with new image URL
        final updateResult = await updateUserField(
          currentUser.uid,
          'imageUrl',
          uploadResult.data!,
        );

        if (updateResult.isSuccess && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile image updated successfully!'),
              backgroundColor: AppCommonColors.green,
            ),
          );
          // Refresh the screen to show updated image
          setState(() {});
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to update profile: ${updateResult.message}',
              ),
              backgroundColor: AppColors.accent,
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: ${uploadResult.message}'),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile image: $e'),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  Future<void> _deleteProfileImage() async {
    setState(() {
      _isUploadingImage = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      // Update user field in Firestore to remove image URL
      final updateResult = await updateUserField(
        currentUser.uid,
        'imageUrl',
        null,
      );

      if (!updateResult.isSuccess) {
        throw Exception('Failed to update profile: ${updateResult.error}');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile image deleted successfully!'),
            backgroundColor: AppCommonColors.green,
          ),
        );
        // Refresh the screen to show updated image
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete profile image: $e'),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  Future<void> _uploadProfileImage(
    File imageFile,
    String? currentImageUrl,
  ) async {
    setState(() {
      _isUploadingImage = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      // Process the image
      final processedFile = await ImageProcessor.processImageFile(imageFile);
      if (processedFile == null) {
        throw Exception('Failed to process image');
      }

      // Upload the profile image
      final uploadResult = await uploadProfileImage(
        currentUser.uid,
        processedFile,
        oldImageUrl: currentImageUrl,
      );

      String imageUrl;
      if (uploadResult.isSuccess) {
        imageUrl = uploadResult.data!;
      } else {
        throw Exception(uploadResult.error);
      }

      // Update user field in Firestore
      final updateResult = await updateUserField(
        currentUser.uid,
        'imageUrl',
        imageUrl,
      );

      if (!updateResult.isSuccess) {
        throw Exception('Failed to update profile: ${updateResult.error}');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile image updated successfully!'),
            backgroundColor: AppCommonColors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile image: $e'),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppCommonColors.grey50,
      appBar: CommonAppBar(
        title: 'flutter_basic_project',
        backgroundColor: AppCommonColors.white,
        foregroundColor: AppCommonColors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseAuth.instance.currentUser != null
            ? FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .snapshots()
            : null,
        builder: (context, snapshot) {
          // Handle authentication state
          if (FirebaseAuth.instance.currentUser == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: AppDimensions.iconXXL * 1.6,
                    color: AppCommonColors.grey500,
                  ),
                  AppSpacing.v16,
                  Text(
                    'Please log in to view your profile',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppCommonColors.grey500,
                    ),
                  ),
                ],
              ),
            );
          }

          // Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  AppSpacing.v16,
                  Text('Loading profile...', style: TextStyle(fontSize: 16)),
                ],
              ),
            );
          }

          // Handle error state
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: AppDimensions.iconXXL * 1.6,
                    color: Colors.red,
                  ),
                  AppSpacing.v16,
                  Text(
                    'Error loading profile: ${snapshot.error}',
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Handle no data state
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_off,
                    size: AppDimensions.iconXXL * 1.6,
                    color: AppCommonColors.grey500,
                  ),
                  AppSpacing.v16,
                  Text(
                    'Profile not found',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppCommonColors.grey500,
                    ),
                  ),
                ],
              ),
            );
          }

          // Parse user data from Firestore document
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final userEntity = UserEntity.fromJson(userData);

          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Header Section
                    _buildProfileHeader(userEntity),
                    AppSpacing.v32,
                    // Information Section
                    _buildInformationSection(userEntity),
                    AppSpacing.v32,
                  ],
                ),
              ),
              // Upload overlay
              if (_isUploadingImage)
                Container(
                  color: AppCommonColors.black.withValues(alpha: 0.3),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppCommonColors.white),
                        AppSpacing.v16,
                        Text(
                          'Updating profile image...',
                          style: TextStyle(
                            color: AppCommonColors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(UserEntity userEntity) {
    return Container(
      decoration: BoxDecoration(
        color: AppCommonColors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: AppShadows.card,
      ),
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
      child: Row(
        children: [
          // Profile Image on the left
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 3,
                  ),
                  boxShadow: AppShadows.primaryShadow(AppColors.primary),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child:
                      userEntity.imageUrl != null &&
                          userEntity.imageUrl!.isNotEmpty
                      ? Image.network(
                          userEntity.imageUrl!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.primary, AppColors.accent],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: AppCommonColors.white,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 100,
                              height: 100,
                              color: AppCommonColors.grey300,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.primary, AppColors.accent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: AppCommonColors.white,
                          ),
                        ),
                ),
              ),
              // Edit icon overlay
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _isUploadingImage ? null : _showImageSourceDialog,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _isUploadingImage
                          ? AppCommonColors.grey400
                          : AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppCommonColors.white,
                        width: 3,
                      ),
                      boxShadow: AppShadows.card,
                    ),
                    child: _isUploadingImage
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppCommonColors.white,
                            ),
                          )
                        : const Icon(
                            Icons.edit,
                            color: AppCommonColors.white,
                            size: 16,
                          ),
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.h24,
          // Nickname and Bio on the right
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Nickname (first row)
                Text(
                  userEntity.nickname?.isNotEmpty == true
                      ? userEntity.nickname!
                      : userEntity.fullName,
                  style: AppTypography.headline2.copyWith(
                    color: AppColors.text,
                    fontWeight: AppFontWeights.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.v8,
                // Bio (second row)
                Text(
                  userEntity.bio?.isNotEmpty == true
                      ? userEntity.bio!
                      : 'No bio available',
                  style: AppTypography.bodyRegular.copyWith(
                    color: userEntity.bio?.isNotEmpty == true
                        ? AppColors.secondary
                        : AppCommonColors.grey400,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformationSection(UserEntity userEntity) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Information',
            style: AppTypography.headline3.copyWith(
              color: AppColors.text,
              fontWeight: AppFontWeights.bold,
            ),
          ),
          AppSpacing.v16,
          _buildInfoCard(
            icon: Icons.person_outline,
            label: 'Username',
            value: userEntity.fullName,
          ),
          AppSpacing.v12,
          _buildInfoCard(
            icon: Icons.phone_outlined,
            label: 'Phone Number',
            value: userEntity.phoneNumber?.isNotEmpty == true
                ? userEntity.phoneNumber!
                : 'No phone number set',
          ),
          AppSpacing.v12,
          _buildInfoCard(
            icon: Icons.email_outlined,
            label: 'Email',
            value: userEntity.email,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isEmpty = value.startsWith('No ') || value.isEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppCommonColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          AppSpacing.h16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppCommonColors.grey600,
                    fontWeight: AppFontWeights.medium,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTypography.bodyRegular.copyWith(
                    color: isEmpty ? AppCommonColors.grey400 : AppColors.text,
                    fontWeight: AppFontWeights.medium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
