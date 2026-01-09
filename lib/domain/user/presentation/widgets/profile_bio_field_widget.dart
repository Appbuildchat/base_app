import 'package:flutter/material.dart';
import '../../../../../core/themes/app_font_weights.dart';

class ProfileBioFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool isEditing;

  const ProfileBioFieldWidget({
    super.key,
    required this.controller,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bio',
              style: TextStyle(
                fontSize: 16,
                fontWeight: AppFontWeights.semiBold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              enabled: isEditing,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Tell us about yourself',
                border: isEditing
                    ? const OutlineInputBorder()
                    : InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isEditing ? 12 : 0,
                  vertical: 8,
                ),
              ),
              style: TextStyle(
                fontSize: 16,
                color: isEditing ? Colors.black : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
