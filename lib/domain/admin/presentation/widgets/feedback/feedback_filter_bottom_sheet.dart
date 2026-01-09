import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/themes/app_theme.dart';
import '../../../../../core/themes/app_typography.dart';
import '../../../../../core/themes/color_theme.dart';
import '../../../../../core/themes/app_dimensions.dart';
import '../../../../../core/themes/app_spacing.dart';
import '../../../../../core/themes/app_font_weights.dart';
import '../../../../../core/themes/app_shadows.dart';
import '../../../../feedback/entities/feedback_entity.dart';

class FeedbackFilterBottomSheet extends StatefulWidget {
  final FeedbackCategory? selectedCategory;
  final FeedbackPriority? selectedPriority;
  final Function(FeedbackCategory?) onCategorySelected;
  final Function(FeedbackPriority?) onPrioritySelected;
  final VoidCallback onClearFilters;

  const FeedbackFilterBottomSheet({
    super.key,
    this.selectedCategory,
    this.selectedPriority,
    required this.onCategorySelected,
    required this.onPrioritySelected,
    required this.onClearFilters,
  });

  @override
  State<FeedbackFilterBottomSheet> createState() =>
      _FeedbackFilterBottomSheetState();
}

class _FeedbackFilterBottomSheetState extends State<FeedbackFilterBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  FeedbackCategory? _tempSelectedCategory;
  FeedbackPriority? _tempSelectedPriority;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tempSelectedCategory = widget.selectedCategory;
    _tempSelectedPriority = widget.selectedPriority;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: AppCommonColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppDimensions.radiusXL),
              topRight: Radius.circular(AppDimensions.radiusXL),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: AppSpacing.paddingVerticalS,
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: AppDimensions.borderRadiusM,
                ),
              ),

              // Title and Clear Button
              Padding(
                padding: AppSpacing.paddingHorizontalL,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter Feedbacks',
                      style: AppTypography.headline3.copyWith(
                        fontWeight: AppFontWeights.bold,
                      ),
                    ),
                    if (_tempSelectedCategory != null ||
                        _tempSelectedPriority != null)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _tempSelectedCategory = null;
                            _tempSelectedPriority = null;
                          });
                        },
                        child: const Text('Clear All'),
                      ),
                  ],
                ),
              ),

              AppSpacing.v16,

              // Tab Bar
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.secondary,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Issue'),
                    Tab(text: 'Priority'),
                  ],
                ),
              ),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // All Tab
                    _buildAllTab(),

                    // Issue Tab
                    _buildIssueTab(),

                    // Priority Tab
                    _buildPriorityTab(),
                  ],
                ),
              ),

              // Apply Button
              Container(
                padding: AppSpacing.paddingL,
                decoration: BoxDecoration(
                  color: AppCommonColors.white,
                  boxShadow: AppShadows.bottomSheet,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onCategorySelected(_tempSelectedCategory);
                      widget.onPrioritySelected(_tempSelectedPriority);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppCommonColors.white,
                      padding: AppSpacing.paddingVerticalM,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppDimensions.borderRadiusM,
                      ),
                    ),
                    child: Text(
                      'Apply Filters',
                      style: AppTypography.bodyRegular.copyWith(
                        fontWeight: AppFontWeights.semiBold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .slideY(begin: 1, end: 0, duration: 300.ms)
        .fadeIn(duration: 300.ms);
  }

  Widget _buildAllTab() {
    final hasFilters =
        _tempSelectedCategory != null || _tempSelectedPriority != null;

    return SingleChildScrollView(
      padding: AppSpacing.paddingL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSpacing.v16,

          // Summary Card
          Container(
            padding: AppSpacing.paddingL,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: AppDimensions.borderRadiusM,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.filter_list, color: AppColors.primary, size: 20),
                    AppSpacing.h8,
                    Text(
                      'Current Filters',
                      style: AppTypography.bodyRegular.copyWith(
                        fontWeight: AppFontWeights.semiBold,
                      ),
                    ),
                  ],
                ),
                AppSpacing.v12,

                if (!hasFilters) ...[
                  Text(
                    'No filters applied',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ] else ...[
                  if (_tempSelectedCategory != null) ...[
                    _buildFilterChip(
                      'Issue: ${_tempSelectedCategory!.displayName}',
                      () => setState(() => _tempSelectedCategory = null),
                    ),
                    AppSpacing.v8,
                  ],
                  if (_tempSelectedPriority != null) ...[
                    _buildFilterChip(
                      'Priority: ${_tempSelectedPriority!.displayName}',
                      () => setState(() => _tempSelectedPriority = null),
                    ),
                  ],
                ],
              ],
            ),
          ),

          AppSpacing.v24,

          // Quick Actions
          Text(
            'Quick Filters',
            style: AppTypography.bodyRegular.copyWith(
              fontWeight: AppFontWeights.semiBold,
            ),
          ),
          AppSpacing.v12,

          Wrap(
            spacing: AppSpacing.s,
            runSpacing: AppSpacing.s,
            children: [
              _buildQuickFilterChip('Bug Reports', Icons.bug_report, () {
                setState(() => _tempSelectedCategory = FeedbackCategory.bug);
                _tabController.animateTo(1);
              }),
              _buildQuickFilterChip('High Priority', Icons.priority_high, () {
                setState(() => _tempSelectedPriority = FeedbackPriority.high);
                _tabController.animateTo(2);
              }),
              _buildQuickFilterChip('Features', Icons.lightbulb_outline, () {
                setState(
                  () => _tempSelectedCategory = FeedbackCategory.feature,
                );
                _tabController.animateTo(1);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIssueTab() {
    return SingleChildScrollView(
      padding: AppSpacing.paddingL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSpacing.v16,

          // All Option
          _buildRadioTile(
            title: 'All Issues',
            subtitle: 'Show all feedback categories',
            value: null,
            groupValue: _tempSelectedCategory,
            onChanged: (value) => setState(() => _tempSelectedCategory = null),
            icon: Icons.all_inclusive,
          ),

          AppSpacing.v8,

          // Category Options
          ...FeedbackCategory.values.map(
            (category) => Column(
              children: [
                _buildRadioTile(
                  title: category.displayName,
                  subtitle: _getCategoryDescription(category),
                  value: category,
                  groupValue: _tempSelectedCategory,
                  onChanged: (value) =>
                      setState(() => _tempSelectedCategory = value),
                  icon: _getCategoryIcon(category),
                ),
                AppSpacing.v8,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityTab() {
    return SingleChildScrollView(
      padding: AppSpacing.paddingL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSpacing.v16,

          // All Option
          _buildRadioTile(
            title: 'All Priorities',
            subtitle: 'Show all priority levels',
            value: null,
            groupValue: _tempSelectedPriority,
            onChanged: (value) => setState(() => _tempSelectedPriority = null),
            icon: Icons.all_inclusive,
          ),

          AppSpacing.v8,

          // Priority Options
          ...FeedbackPriority.values.map(
            (priority) => Column(
              children: [
                _buildRadioTile(
                  title: priority.displayName,
                  subtitle: _getPriorityDescription(priority),
                  value: priority,
                  groupValue: _tempSelectedPriority,
                  onChanged: (value) =>
                      setState(() => _tempSelectedPriority = value),
                  icon: _getPriorityIcon(priority),
                  iconColor: _getPriorityColor(priority),
                ),
                AppSpacing.v8,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioTile<T>({
    required String title,
    required String subtitle,
    required T? value,
    required T? groupValue,
    required Function(T?) onChanged,
    required IconData icon,
    Color? iconColor,
  }) {
    final isSelected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: AppDimensions.borderRadiusM,
      child: Container(
        padding: AppSpacing.paddingM,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppCommonColors.grey,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: AppDimensions.borderRadiusM,
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : AppCommonColors.white,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color:
                  iconColor ??
                  (isSelected ? AppColors.primary : AppColors.secondary),
              size: 24,
            ),
            AppSpacing.h12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyRegular.copyWith(
                      fontWeight: isSelected
                          ? AppFontWeights.semiBold
                          : AppFontWeights.medium,
                      color: isSelected ? AppColors.primary : AppColors.text,
                    ),
                  ),
                  AppSpacing.v4,
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
            if (value != null)
              Radio<T>(
                value: value,
                groupValue: groupValue,
                onChanged: onChanged,
                activeColor: AppColors.primary,
              )
            else
              Radio<String>(
                value: '',
                groupValue: groupValue == null ? '' : 'selected',
                onChanged: (_) => onChanged(null),
                activeColor: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onDelete) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: AppDimensions.borderRadiusM,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(color: AppColors.primary),
          ),
          AppSpacing.h8,
          GestureDetector(
            onTap: onDelete,
            child: Icon(Icons.close, size: 16, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilterChip(
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ActionChip(
      onPressed: onTap,
      avatar: Icon(icon, size: 16),
      label: Text(label),
      backgroundColor: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusM),
    );
  }

  String _getCategoryDescription(FeedbackCategory category) {
    switch (category) {
      case FeedbackCategory.bug:
        return 'Issues and errors in the app';
      case FeedbackCategory.feature:
        return 'New feature suggestions';
      case FeedbackCategory.improvement:
        return 'Enhancements to existing features';
      case FeedbackCategory.ui:
        return 'Design and user interface issues';
      case FeedbackCategory.performance:
        return 'Speed and performance problems';
      case FeedbackCategory.other:
        return 'Other feedback and comments';
    }
  }

  String _getPriorityDescription(FeedbackPriority priority) {
    switch (priority) {
      case FeedbackPriority.low:
        return 'Minor issues or suggestions';
      case FeedbackPriority.medium:
        return 'Important but not urgent';
      case FeedbackPriority.high:
        return 'Needs attention soon';
      case FeedbackPriority.critical:
        return 'Urgent and critical issues';
    }
  }

  IconData _getCategoryIcon(FeedbackCategory category) {
    switch (category) {
      case FeedbackCategory.bug:
        return Icons.bug_report;
      case FeedbackCategory.feature:
        return Icons.lightbulb_outline;
      case FeedbackCategory.improvement:
        return Icons.trending_up;
      case FeedbackCategory.ui:
        return Icons.design_services;
      case FeedbackCategory.performance:
        return Icons.speed;
      case FeedbackCategory.other:
        return Icons.more_horiz;
    }
  }

  IconData _getPriorityIcon(FeedbackPriority priority) {
    switch (priority) {
      case FeedbackPriority.low:
        return Icons.arrow_downward;
      case FeedbackPriority.medium:
        return Icons.remove;
      case FeedbackPriority.high:
        return Icons.arrow_upward;
      case FeedbackPriority.critical:
        return Icons.priority_high;
    }
  }

  Color _getPriorityColor(FeedbackPriority priority) {
    switch (priority) {
      case FeedbackPriority.low:
        return AppCommonColors.green;
      case FeedbackPriority.medium:
        return AppCommonColors.orange;
      case FeedbackPriority.high:
        return AppCommonColors.red;
      case FeedbackPriority.critical:
        return AppCommonColors.purple;
    }
  }
}
