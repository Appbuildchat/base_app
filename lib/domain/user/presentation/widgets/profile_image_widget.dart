import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/themes/color_theme.dart';
import '../../../../core/themes/app_theme.dart';

class ProfileImageWidget extends StatelessWidget {
  final String? profileImagePath;
  final File? selectedImageFile;
  final bool isEditing;
  final Function(File) onImageSelected;

  const ProfileImageWidget({
    super.key,
    this.profileImagePath,
    this.selectedImageFile,
    required this.isEditing,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          _buildProfileImage(),
          if (isEditing)
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _showImagePickerDialog(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: AppCommonColors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    if (selectedImageFile != null) {
      return CircleAvatar(
        radius: 60,
        backgroundColor: AppCommonColors.grey300,
        backgroundImage: FileImage(selectedImageFile!),
      );
    } else if (profileImagePath != null && profileImagePath!.isNotEmpty) {
      return ClipOval(
        child: SizedBox(
          width: 120,
          height: 120,
          child: Image.network(
            profileImagePath!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 120,
                height: 120,
                color: AppCommonColors.grey300,
                child: const Icon(
                  Icons.person,
                  size: 60,
                  color: AppCommonColors.white,
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 120,
                height: 120,
                color: AppCommonColors.grey300,
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: 60,
      backgroundColor: AppCommonColors.grey300,
      child: const Icon(Icons.person, size: 60, color: AppCommonColors.white),
    );
  }

  void _showImagePickerDialog(BuildContext context) {
    if (!isEditing) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Profile Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Select from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromGallery(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromCamera(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromGallery(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      onImageSelected(File(pickedFile.path));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile image has been changed.'),
            backgroundColor: AppCommonColors.green,
          ),
        );
      }
    }
  }

  Future<void> _pickImageFromCamera(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      onImageSelected(File(pickedFile.path));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile image has been changed.'),
            backgroundColor: AppCommonColors.green,
          ),
        );
      }
    }
  }
}
