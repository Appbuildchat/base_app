// =============================================================================
// FEEDBACK ENTITY
// =============================================================================
//
// This file defines the Feedback entity for user feedback data
// Used for storing and retrieving feedback from Firestore
//
// Properties:
// - feedbackId: Unique identifier for the feedback
// - userId: ID of the user who submitted the feedback
// - userName: Name of the user who submitted the feedback
// - userEmail: Email of the user who submitted the feedback
// - title: Title/subject of the feedback
// - description: Detailed feedback description
// - category: Category of feedback (bug, feature, improvement, etc.)
// - priority: Priority level (low, medium, high)
// - status: Current status (pending, in_progress, resolved, rejected)
// - attachments: List of attachment URLs (optional)
// - createdAt: Timestamp when feedback was created
// - updatedAt: Timestamp when feedback was last updated
// - adminResponse: Admin's response to the feedback (optional)
// - adminRespondedAt: Timestamp when admin responded (optional)
// =============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'feedback_status.dart';

enum FeedbackCategory {
  bug('Bug Report'),
  feature('Feature Request'),
  improvement('Improvement Suggestion'),
  ui('UI/UX Issue'),
  performance('Performance Issue'),
  other('Other');

  const FeedbackCategory(this.displayName);
  final String displayName;
}

extension FeedbackCategoryExtension on FeedbackCategory {
  IconData get icon {
    switch (this) {
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
        return Icons.help_outline;
    }
  }
}

enum FeedbackPriority {
  low('Low'),
  medium('Medium'),
  high('High'),
  critical('Critical');

  const FeedbackPriority(this.displayName);
  final String displayName;
}

extension FeedbackPriorityExtension on FeedbackPriority {
  Color get color {
    switch (this) {
      case FeedbackPriority.low:
        return const Color(0xFF4CAF50); // Green
      case FeedbackPriority.medium:
        return const Color(0xFFFF9800); // Orange
      case FeedbackPriority.high:
        return const Color(0xFFF44336); // Red
      case FeedbackPriority.critical:
        return const Color(0xFF9C27B0); // Purple
    }
  }
}

class FeedbackEntity {
  final String feedbackId;
  final String userId;
  final String userFirstName;
  final String userLastName;
  final String userEmail;
  final String title;
  final String description;
  final FeedbackCategory category;
  final FeedbackPriority priority;
  final FeedbackStatus status;
  final List<String> attachments;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? adminResponse;
  final DateTime? adminRespondedAt;

  const FeedbackEntity({
    required this.feedbackId,
    required this.userId,
    required this.userFirstName,
    required this.userLastName,
    required this.userEmail,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.attachments,
    required this.createdAt,
    required this.updatedAt,
    this.adminResponse,
    this.adminRespondedAt,
  });

  /// Create FeedbackEntity from Firestore document
  factory FeedbackEntity.fromJson(Map<String, dynamic> json) {
    return FeedbackEntity(
      feedbackId: json['feedbackId'] as String,
      userId: json['userId'] as String,
      userFirstName: json['userFirstName'] as String? ?? '',
      userLastName: json['userLastName'] as String? ?? '',
      userEmail: json['userEmail'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: FeedbackCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => FeedbackCategory.other,
      ),
      priority: FeedbackPriority.values.firstWhere(
        (p) => p.name == json['priority'],
        orElse: () => FeedbackPriority.medium,
      ),
      status: FeedbackStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => FeedbackStatus.pending,
      ),
      attachments: List<String>.from(json['attachments'] ?? []),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      adminResponse: json['adminResponse'] as String?,
      adminRespondedAt: json['adminRespondedAt'] != null
          ? (json['adminRespondedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convert FeedbackEntity to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'feedbackId': feedbackId,
      'userId': userId,
      'userFirstName': userFirstName,
      'userLastName': userLastName,
      'userEmail': userEmail,
      'title': title,
      'description': description,
      'category': category.name,
      'priority': priority.name,
      'status': status.name,
      'attachments': attachments,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'adminResponse': adminResponse,
      'adminRespondedAt': adminRespondedAt != null
          ? Timestamp.fromDate(adminRespondedAt!)
          : null,
    };
  }

  /// Create a copy with updated fields
  FeedbackEntity copyWith({
    String? feedbackId,
    String? userId,
    String? userFirstName,
    String? userLastName,
    String? userEmail,
    String? title,
    String? description,
    FeedbackCategory? category,
    FeedbackPriority? priority,
    FeedbackStatus? status,
    List<String>? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? adminResponse,
    DateTime? adminRespondedAt,
  }) {
    return FeedbackEntity(
      feedbackId: feedbackId ?? this.feedbackId,
      userId: userId ?? this.userId,
      userFirstName: userFirstName ?? this.userFirstName,
      userLastName: userLastName ?? this.userLastName,
      userEmail: userEmail ?? this.userEmail,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      adminResponse: adminResponse ?? this.adminResponse,
      adminRespondedAt: adminRespondedAt ?? this.adminRespondedAt,
    );
  }

  /// Check if feedback has been responded to by admin
  bool get hasAdminResponse =>
      adminResponse != null && adminResponse!.isNotEmpty;

  /// Check if feedback is still pending
  bool get isPending => status == FeedbackStatus.pending;

  /// Check if feedback is complete
  bool get isResolved => status == FeedbackStatus.complete;

  /// Get priority color for UI
  String get priorityColor {
    switch (priority) {
      case FeedbackPriority.low:
        return '#4CAF50'; // Green
      case FeedbackPriority.medium:
        return '#FF9800'; // Orange
      case FeedbackPriority.high:
        return '#F44336'; // Red
      case FeedbackPriority.critical:
        return '#9C27B0'; // Purple
    }
  }

  /// Get status color for UI
  String get statusColor {
    switch (status) {
      case FeedbackStatus.pending:
        return '#FF9800'; // Orange
      case FeedbackStatus.complete:
        return '#4CAF50'; // Green
    }
  }

  /// Get combined user name for display purposes
  String get userName => '$userFirstName $userLastName'.trim();

  @override
  String toString() {
    return 'FeedbackEntity(feedbackId: $feedbackId, title: $title, status: ${status.displayName})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeedbackEntity && other.feedbackId == feedbackId;
  }

  @override
  int get hashCode => feedbackId.hashCode;
}
