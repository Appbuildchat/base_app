// =============================================================================
// SUBMIT FEEDBACK TAB WIDGET
// Separated widget for the feedback submission form tab
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/themes/app_dimensions.dart';
import '../../../../core/themes/app_spacing.dart';
import '../../../../core/themes/app_font_weights.dart';
import '../../../../core/widgets/modern_text_field.dart';
import '../../../../core/widgets/modern_button.dart';
import '../../../../core/widgets/modern_dropdown.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../entities/feedback_entity.dart';

class SubmitFeedbackTab extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final FeedbackCategory selectedCategory;
  final FeedbackPriority selectedPriority;
  final int descriptionCharCount;
  final bool isLoading;
  final ValueChanged<FeedbackCategory?> onCategoryChanged;
  final ValueChanged<FeedbackPriority?> onPriorityChanged;
  final VoidCallback onSubmit;

  const SubmitFeedbackTab({
    super.key,
    required this.formKey,
    required this.titleController,
    required this.descriptionController,
    required this.selectedCategory,
    required this.selectedPriority,
    required this.descriptionCharCount,
    required this.isLoading,
    required this.onCategoryChanged,
    required this.onPriorityChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LoadingOverlay(
      isLoading: isLoading,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'We value your feedback',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: AppFontWeights.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                AppSpacing.v8,
                Text(
                  'Help us improve the app by sharing your thoughts, reporting bugs, or suggesting new features.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                AppSpacing.v32,

                // Category Selection
                ModernDropdown<FeedbackCategory>(
                  labelText: 'Category',
                  value: selectedCategory,
                  items: FeedbackCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Row(
                        children: [
                          Icon(category.icon, size: AppDimensions.iconS),
                          AppSpacing.h12,
                          Text(category.displayName),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: onCategoryChanged,
                ),
                AppSpacing.v20,

                // Priority Selection
                ModernDropdown<FeedbackPriority>(
                  labelText: 'Priority',
                  value: selectedPriority,
                  items: FeedbackPriority.values.map((priority) {
                    return DropdownMenuItem(
                      value: priority,
                      child: Row(
                        children: [
                          Container(
                            width: AppDimensions.iconXS,
                            height: AppDimensions.iconXS,
                            decoration: BoxDecoration(
                              color: priority.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          AppSpacing.h12,
                          Text(priority.displayName),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: onPriorityChanged,
                ),
                AppSpacing.v20,

                // Title Input
                ModernTextField(
                  controller: titleController,
                  labelText: 'Title',
                  hintText: 'Brief summary of your feedback',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    if (value.trim().length < 3) {
                      return 'Title must be at least 3 characters';
                    }
                    if (value.trim().length > 100) {
                      return 'Title must be less than 100 characters';
                    }
                    return null;
                  },
                ),
                AppSpacing.v20,

                // Description Input
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ModernTextField(
                      controller: descriptionController,
                      labelText: 'Description',
                      hintText:
                          'Provide detailed information about your feedback',
                      maxLines: 6,
                      inputFormatters: [LengthLimitingTextInputFormatter(1000)],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a description';
                        }
                        if (value.trim().length < 10) {
                          return 'Description must be at least 10 characters';
                        }
                        if (value.trim().length > 1000) {
                          return 'Description must be less than 1000 characters';
                        }
                        return null;
                      },
                    ),
                    AppSpacing.v8,
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '$descriptionCharCount/1000',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.v24,

                // Submit Button
                ModernButton(
                  text: 'Submit Feedback',
                  onPressed: onSubmit,
                  isLoading: isLoading,
                  type: ModernButtonType.primary,
                  customColor: theme.colorScheme.primary,
                ),
                AppSpacing.v16,

                // Info Text
                Text(
                  'Your feedback is anonymous and will be reviewed by our team. We may reach out if we need more information.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                AppSpacing.v24,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
