// This screen displays a list of user feedbacks for admin management
// Features:
// - Tab navigation for Pending/Complete status
// - Search functionality
// - Filter bottom sheet for category and priority
// - Feedback detail modal on tap
// - Quick actions (respond, delete)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:logger/logger.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/themes/app_typography.dart';
import '../../../../core/themes/color_theme.dart';
import '../../../../core/themes/app_dimensions.dart';
import '../../../../core/themes/app_spacing.dart';
import '../../../../core/themes/app_font_weights.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../feedback/entities/feedback_entity.dart';
import '../../../feedback/entities/feedback_status.dart';
import '../../functions/fetch_all_feedbacks.dart';
import '../widgets/feedback/feedback_card.dart';
import '../widgets/feedback/feedback_empty_state.dart';
import '../widgets/feedback/feedback_filter_bottom_sheet.dart';
import '../widgets/feedback/feedback_detail_modal.dart';
import '../../../feedback/functions/update_feedback_status.dart';

class FeedbackListScreen extends StatefulWidget {
  const FeedbackListScreen({super.key});

  @override
  State<FeedbackListScreen> createState() => _FeedbackListScreenState();
}

class _FeedbackListScreenState extends State<FeedbackListScreen>
    with SingleTickerProviderStateMixin {
  final Logger _logger = Logger();
  late TabController _tabController;
  List<FeedbackEntity> _feedbacks = [];
  bool _isLoading = false;
  String _searchQuery = '';
  FeedbackCategory? _selectedCategory;
  FeedbackPriority? _selectedPriority;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFeedbacks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFeedbacks() async {
    setState(() => _isLoading = true);

    try {
      final result = await fetchAllFeedbacksForAdmin(limit: 100);

      if (result.isSuccess) {
        setState(() => _feedbacks = result.data!);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Failed to load feedbacks'),
              backgroundColor: AppColors.accent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading feedbacks: $e'),
            backgroundColor: AppColors.accent,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<FeedbackEntity> get _filteredFeedbacks {
    List<FeedbackEntity> filtered = List.from(_feedbacks);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((feedback) {
        return feedback.title.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            feedback.description.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            feedback.userFirstName.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            feedback.userLastName.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
      }).toList();
    }

    // Apply category filter
    if (_selectedCategory != null) {
      filtered = filtered
          .where((feedback) => feedback.category == _selectedCategory)
          .toList();
    }

    // Apply priority filter
    if (_selectedPriority != null) {
      filtered = filtered
          .where((feedback) => feedback.priority == _selectedPriority)
          .toList();
    }

    // Apply status filter based on current tab
    if (_tabController.index == 1) {
      // Pending tab
      filtered = filtered
          .where((feedback) => feedback.status == FeedbackStatus.pending)
          .toList();
    } else if (_tabController.index == 2) {
      // Complete tab
      filtered = filtered
          .where((feedback) => feedback.status == FeedbackStatus.complete)
          .toList();
    }

    return filtered;
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedCategory = null;
      _selectedPriority = null;
      _searchController.clear();
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FeedbackFilterBottomSheet(
        selectedCategory: _selectedCategory,
        selectedPriority: _selectedPriority,
        onCategorySelected: (category) {
          setState(() => _selectedCategory = category);
        },
        onPrioritySelected: (priority) {
          setState(() => _selectedPriority = priority);
        },
        onClearFilters: _clearFilters,
      ),
    );
  }

  void _showFeedbackDetail(FeedbackEntity feedback) {
    showDialog(
      context: context,
      builder: (context) => FeedbackDetailModal(
        feedback: feedback,
        onRespond: () {
          Navigator.pop(context);
          _respondToFeedback(feedback);
        },
        onStatusChange: () {
          Navigator.pop(context);
          _changeStatus(feedback);
        },
      ),
    );
  }

  void _deleteFeedback(FeedbackEntity feedback) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Feedback'),
        content: Text(
          'Are you sure you want to delete this feedback from ${feedback.userFirstName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _feedbacks.remove(feedback);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Deleted feedback: ${feedback.title}')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppCommonColors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _respondToFeedback(FeedbackEntity feedback) async {
    // TODO: Implement actual feedback response functionality
    _logger.d('DEBUG: Before update - Status: ${feedback.status.name}');

    if (!mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Update status in Firebase first
    final result = await UpdateFeedbackStatus.update(
      feedbackId: feedback.feedbackId,
      newStatus: FeedbackStatus.complete,
    );

    if (!mounted) return;

    if (result.isSuccess) {
      // If Firebase update successful, update local state
      setState(() {
        final index = _feedbacks.indexOf(feedback);
        _logger.d('DEBUG: Found feedback at index: $index');
        if (index != -1) {
          final updatedFeedback = feedback.copyWith(
            status: FeedbackStatus.complete,
            updatedAt: DateTime.now(),
          );
          _feedbacks[index] = updatedFeedback;
          _logger.i(
            'DEBUG: Updated feedback status to: ${updatedFeedback.status.name}',
          );
        }
      });

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Feedback "${feedback.title}" marked as complete'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Show error message if Firebase update failed
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Failed to update feedback: ${result.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _changeStatus(FeedbackEntity feedback) {
    final newStatus = feedback.status == FeedbackStatus.pending
        ? FeedbackStatus.complete
        : FeedbackStatus.pending;

    // TODO: Update status in Firestore
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Status changed to ${newStatus.displayName}')),
    );

    // Update local state
    setState(() {
      final index = _feedbacks.indexOf(feedback);
      if (index != -1) {
        // Create updated feedback with new status
        // Note: This is a simplified approach - you'd need to properly update the entity
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasFilters = _selectedCategory != null || _selectedPriority != null;

    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Feedback Management', style: AppTypography.headline2),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.text,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _loadFeedbacks();
              },
              tooltip: 'Refresh',
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            onTap: (_) => setState(() {}),
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.secondary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'All', icon: _buildTabBadge(_feedbacks.length)),
              Tab(
                text: 'Pending',
                icon: _buildTabBadge(
                  _feedbacks
                      .where((f) => f.status == FeedbackStatus.pending)
                      .length,
                ),
              ),
              Tab(
                text: 'Complete',
                icon: _buildTabBadge(
                  _feedbacks
                      .where((f) => f.status == FeedbackStatus.complete)
                      .length,
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            // Search Bar with Filter Button
            Container(
                  padding: AppSpacing.paddingL,
                  decoration: BoxDecoration(
                    color: AppCommonColors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: AppCommonColors.grey300,
                        width: 0.2,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Search Field
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search feedbacks...',
                            prefixIcon: Icon(
                              Icons.search,
                              color: AppColors.secondary,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: AppDimensions.borderRadiusS,
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.m,
                              vertical: AppSpacing.s,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() => _searchQuery = value);
                          },
                        ),
                      ),

                      AppSpacing.h12,

                      // Filter Button
                      Container(
                        decoration: BoxDecoration(
                          color: hasFilters
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : Colors.grey[100],
                          borderRadius: AppDimensions.borderRadiusS,
                          border: hasFilters
                              ? Border.all(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                )
                              : null,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _showFilterBottomSheet,
                            borderRadius: AppDimensions.borderRadiusS,
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.m),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.filter_list,
                                    color: hasFilters
                                        ? AppColors.primary
                                        : AppColors.secondary,
                                    size: 20,
                                  ),
                                  AppSpacing.h8,
                                  Text(
                                    'Filter',
                                    style: AppTypography.bodyRegular.copyWith(
                                      color: hasFilters
                                          ? AppColors.primary
                                          : AppColors.secondary,
                                      fontWeight: hasFilters
                                          ? AppFontWeights.semiBold
                                          : AppFontWeights.regular,
                                    ),
                                  ),
                                  if (hasFilters) ...[
                                    AppSpacing.h4,
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius:
                                            AppDimensions.borderRadiusS,
                                      ),
                                      child: Text(
                                        '${(_selectedCategory != null ? 1 : 0) + (_selectedPriority != null ? 1 : 0)}',
                                        style: const TextStyle(
                                          color: AppCommonColors.white,
                                          fontSize: 10,
                                          fontWeight: AppFontWeights.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                .animate(delay: 200.ms)
                .fadeIn(duration: 600.ms)
                .slideY(begin: -0.1, end: 0, duration: 600.ms),

            // Feedback List
            Expanded(
              child: _filteredFeedbacks.isEmpty
                  ? const FeedbackEmptyState()
                  : ListView.builder(
                      padding: AppSpacing.paddingL,
                      itemCount: _filteredFeedbacks.length,
                      itemBuilder: (context, index) {
                        final feedback = _filteredFeedbacks[index];
                        return FeedbackCard(
                          feedback: feedback,
                          index: index,
                          onTap: () => _showFeedbackDetail(feedback),
                          onViewDetails: () => _showFeedbackDetail(feedback),
                          onRespond: () => _respondToFeedback(feedback),
                          onDelete: () => _deleteFeedback(feedback),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildTabBadge(int count) {
    if (count == 0) return null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: AppDimensions.borderRadiusS,
      ),
      child: Text(
        count.toString(),
        style: const TextStyle(color: AppCommonColors.white, fontSize: 10),
      ),
    );
  }
}
