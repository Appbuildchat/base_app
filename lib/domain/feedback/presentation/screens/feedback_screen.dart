// =============================================================================
// FEEDBACK SCREEN
// This screen allows users to submit feedback to the app administrators
// Features:
// 1. Category selection (Bug, Feature Request, General)
// 2. Priority selection (Low, Medium, High, Critical)
// 3. Title and description input
// 4. Form validation
// 5. Submission to Firestore
// Usage:
// - Users access this screen via Settings > Send Feedback
// - Form data is validated before submission
// - Success/error feedback is provided via toast messages
// UI Structure:
// - AppBar with back button
// - Form with dropdown selectors and text fields
// - Submit button with loading state
// =============================================================================

import 'package:flutter/material.dart';
import '../../../../core/widgets/modern_toast.dart';
import '../../../../core/widgets/common_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../entities/feedback_entity.dart';
import '../../entities/feedback_status.dart';
import '../../functions/submit_feedback.dart';
import '../../functions/fetch_user_feedbacks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/user_feedback_detail_modal.dart';
import '../widgets/submit_feedback_tab.dart';
import '../widgets/pending_feedback_tab.dart';
import '../widgets/complete_feedback_tab.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  FeedbackCategory _selectedCategory = FeedbackCategory.other;
  FeedbackPriority _selectedPriority = FeedbackPriority.medium;
  bool _isLoading = false;
  int _descriptionCharCount = 0;

  // My Feedback tab state
  List<FeedbackEntity> _userFeedbacks = [];
  bool _isLoadingFeedbacks = false;
  String? _feedbackError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _descriptionController.addListener(_updateCharCount);
    _loadUserFeedbacks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _descriptionController.removeListener(_updateCharCount);
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateCharCount() {
    setState(() {
      _descriptionCharCount = _descriptionController.text.length;
    });
  }

  List<FeedbackEntity> get _pendingFeedbacks {
    return _userFeedbacks
        .where((feedback) => feedback.status == FeedbackStatus.pending)
        .toList();
  }

  List<FeedbackEntity> get _completeFeedbacks {
    return _userFeedbacks
        .where((feedback) => feedback.status == FeedbackStatus.complete)
        .toList();
  }

  Future<void> _loadUserFeedbacks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isLoadingFeedbacks = true;
      _feedbackError = null;
    });

    try {
      final result = await fetchUserFeedbacks(userId: user.uid, limit: 50);

      if (result.isSuccess) {
        setState(() {
          _userFeedbacks = result.data!;
        });
      } else {
        setState(() {
          _feedbackError = result.message ?? 'Failed to load feedbacks';
        });
      }
    } catch (e) {
      setState(() {
        _feedbackError = 'An error occurred while loading feedbacks';
      });
    } finally {
      setState(() {
        _isLoadingFeedbacks = false;
      });
    }
  }

  void _showFeedbackDetail(FeedbackEntity feedback) {
    showDialog(
      context: context,
      builder: (context) => UserFeedbackDetailModal(feedback: feedback),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CommonAppBarWithBack(
        title: 'Feedback',
        bottom: TabBar(
          controller: _tabController,
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.edit_note, size: 20),
              text: 'Submit',
              height: 60,
            ),
            Tab(
              icon: Icon(Icons.pending_actions, size: 20),
              text: 'Pending',
              height: 60,
            ),
            Tab(
              icon: Icon(Icons.check_circle_outline, size: 20),
              text: 'Complete',
              height: 60,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SubmitFeedbackTab(
            formKey: _formKey,
            titleController: _titleController,
            descriptionController: _descriptionController,
            selectedCategory: _selectedCategory,
            selectedPriority: _selectedPriority,
            descriptionCharCount: _descriptionCharCount,
            isLoading: _isLoading,
            onCategoryChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedCategory = value;
                });
              }
            },
            onPriorityChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedPriority = value;
                });
              }
            },
            onSubmit: _submitFeedback,
          ),
          PendingFeedbackTab(
            pendingFeedbacks: _pendingFeedbacks,
            isLoadingFeedbacks: _isLoadingFeedbacks,
            feedbackError: _feedbackError,
            onRefresh: _loadUserFeedbacks,
            onFeedbackTap: _showFeedbackDetail,
          ),
          CompleteFeedbackTab(
            completeFeedbacks: _completeFeedbacks,
            isLoadingFeedbacks: _isLoadingFeedbacks,
            feedbackError: _feedbackError,
            onRefresh: _loadUserFeedbacks,
            onFeedbackTap: _showFeedbackDetail,
          ),
        ],
      ),
    );
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ModernToast.showError(context, 'Please sign in to submit feedback');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get user information directly from Firestore
      String userFirstName = 'Anonymous';
      String userLastName = '';

      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          final userData = userDoc.data()!;
          userFirstName =
              userData['firstName']?.toString().trim() ?? 'Anonymous';
          userLastName = userData['lastName']?.toString().trim() ?? '';
        } else {
          // User document doesn't exist - show error
          if (mounted) {
            ModernToast.showError(
              context,
              'User profile not found. Please complete your profile setup.',
            );
          }
          return;
        }
      } catch (e) {
        // If Firestore query fails, show error
        if (mounted) {
          ModernToast.showError(
            context,
            'Failed to load user information. Please try again.',
          );
        }
        return;
      }

      final result = await submitFeedback(
        userId: user.uid,
        userFirstName: userFirstName,
        userLastName: userLastName,
        userEmail: user.email ?? '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        priority: _selectedPriority,
        attachments: [],
      );

      if (!mounted) return;

      if (result.isSuccess) {
        ModernToast.showSuccess(
          context,
          'Feedback submitted successfully. Thank you!',
        );

        // Clear the form
        _titleController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedCategory = FeedbackCategory.other;
          _selectedPriority = FeedbackPriority.medium;
          _descriptionCharCount = 0;
        });

        // Refresh user feedbacks and switch to Pending tab
        await _loadUserFeedbacks();
        if (mounted) {
          _tabController.animateTo(1);
        }
      } else {
        ModernToast.showError(
          context,
          result.message ?? 'Failed to submit feedback',
        );
      }
    } catch (e) {
      if (mounted) {
        ModernToast.showError(context, 'An unexpected error occurred');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
