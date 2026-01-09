# Feedback Domain

The Feedback domain module handles all feedback-related functionality. It provides comprehensive features for users to submit feedback, administrators to manage feedback, and systems to track feedback statistics.

## Folder Structure

```
lib/domain/feedback/
├── entities/           # Data models
│   ├── feedback_entity.dart          # Main feedback data model
│   └── feedback_status.dart          # Feedback status enumeration
├── functions/          # Business logic functions
│   ├── submit_feedback.dart          # Submit new feedback
│   ├── fetch_all_feedbacks.dart      # Fetch all feedback (admin)
│   ├── fetch_user_feedbacks.dart     # Fetch user's own feedback
│   ├── fetch_feedbacks_by_category.dart   # Filter by category
│   ├── fetch_feedbacks_by_status.dart     # Filter by status
│   ├── fetch_feedbacks_by_priority.dart   # Filter by priority
│   ├── update_feedback_status.dart        # Update feedback status
│   ├── get_feedback_statistics.dart       # Get feedback statistics
│   └── firebase_error_handler.dart        # Firebase error handling
└── presentation/       # UI related code
    ├── screens/        # Screen components
    │   └── feedback_screen.dart       # Main feedback screen
    └── widgets/        # Reusable widgets
        ├── user_feedback_card.dart           # Feedback card component
        ├── user_feedback_detail_modal.dart   # Feedback detail modal
        └── user_feedback_empty_state.dart    # Empty state component
```

## Key Features

### 1. Feedback Submission (`functions/submit_feedback.dart`, `presentation/screens/feedback_screen.dart`)
- Submit feedback with title, description, and category
- Support for priority levels (low, medium, high)
- Optional file attachments
- User information tracking
- Automatic timestamp management

### 2. Feedback Management
- **Fetch All Feedbacks** (`functions/fetch_all_feedbacks.dart`): Admin access to all feedback
- **User Feedbacks** (`functions/fetch_user_feedbacks.dart`): User's own feedback history
- **Status Updates** (`functions/update_feedback_status.dart`): Change feedback status
- **Statistics** (`functions/get_feedback_statistics.dart`): Feedback analytics

### 3. Filtering and Sorting
- **By Category** (`functions/fetch_feedbacks_by_category.dart`): Filter feedback by type
- **By Status** (`functions/fetch_feedbacks_by_status.dart`): Filter by current status
- **By Priority** (`functions/fetch_feedbacks_by_priority.dart`): Filter by priority level

### 4. UI Components
- **Feedback Card** (`widgets/user_feedback_card.dart`): Display feedback in lists
- **Detail Modal** (`widgets/user_feedback_detail_modal.dart`): Show full feedback details
- **Empty State** (`widgets/user_feedback_empty_state.dart`): No feedback placeholder

## Data Models

### Feedback Entity
```dart
import '../../entities/feedback_entity.dart';

class FeedbackEntity {
  final String feedbackId;
  final String userId;
  final String userName;
  final String userEmail;
  final String title;
  final String description;
  final String category;
  final String priority;
  final FeedbackStatus status;
  final List<String>? attachments;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### Feedback Status
```dart
import '../../entities/feedback_status.dart';

enum FeedbackStatus {
  pending,      // Newly submitted
  inProgress,   // Being reviewed/worked on
  resolved,     // Issue fixed/completed
  rejected      // Not actionable
}
```

## Usage

### Submit New Feedback
```dart
import '../../domain/feedback/functions/submit_feedback.dart';

final result = await submitFeedback(
  userId: currentUser.uid,
  userFirstName: 'John',
  userLastName: 'Doe',
  userEmail: currentUser.email,
  title: 'Bug in profile screen',
  description: 'Detailed description of the issue',
  category: FeedbackCategory.bug,
  priority: FeedbackPriority.medium,
  attachments: ['url1', 'url2'],
);

if (result.isSuccess) {
  // Feedback submitted successfully
}
```

### Fetch User's Feedback
```dart
import '../../domain/feedback/functions/fetch_user_feedbacks.dart';

final result = await fetchUserFeedbacks(userId: currentUser.uid);
if (result.isSuccess) {
  final feedbacks = result.data!;
  // Display user's feedback list
}
```

### Fetch All Feedbacks (Admin)
```dart
import '../../domain/feedback/functions/fetch_all_feedbacks.dart';

final result = await fetchAllFeedbacks();
if (result.isSuccess) {
  final feedbacks = result.data!;
  // Display all feedback for admin
}
```

### Filter Feedback by Status
```dart
import '../../domain/feedback/functions/fetch_feedbacks_by_status.dart';

final result = await fetchFeedbacksByStatus(status: FeedbackStatus.pending);
if (result.isSuccess) {
  final pendingFeedbacks = result.data!;
  // Display pending feedback
}
```

### Update Feedback Status
```dart
import '../../domain/feedback/functions/update_feedback_status.dart';

final result = await updateFeedbackStatus(
  feedbackId: 'feedback123',
  newStatus: FeedbackStatus.resolved
);
if (result.isSuccess) {
  // Status updated successfully
}
```

### Get Feedback Statistics
```dart
import '../../domain/feedback/functions/get_feedback_statistics.dart';

final result = await getFeedbackStatistics();
if (result.isSuccess) {
  final stats = result.data!;
  // Display feedback statistics
}
```

## UI Component Usage

### Feedback Card
```dart
import '../widgets/user_feedback_card.dart';

UserFeedbackCard(
  feedback: feedbackObject,
  onTap: () => // Show feedback details
)
```

### Feedback Detail Modal
```dart
import '../widgets/user_feedback_detail_modal.dart';

UserFeedbackDetailModal(
  feedback: feedbackObject,
  onStatusUpdate: (newStatus) => // Handle status update
)
```

### Empty State
```dart
import '../widgets/user_feedback_empty_state.dart';

UserFeedbackEmptyState(
  onSubmitFeedback: () => // Navigate to feedback form
)
```

## Feedback Categories

Common feedback categories include:
- **Bug**: Software issues and errors
- **Feature**: New feature requests
- **Improvement**: Enhancement suggestions
- **UI/UX**: User interface and experience feedback
- **Performance**: Speed and optimization issues
- **Other**: General feedback

## Priority Levels

- **Low**: Minor issues or suggestions
- **Medium**: Important but not critical issues
- **High**: Critical issues requiring immediate attention

## Important Notes

- All functions use the Result pattern for error handling
- Feedback data is stored in Firestore with proper indexing
- User information is automatically attached to feedback submissions
- Attachments support multiple file types and are stored separately
- Status updates maintain audit trails with timestamps
- Firebase error handling is centralized for consistent error management
- UI components follow the app's theme system and design guidelines