# Admin Domain

The Admin domain module handles administrator functionality. It provides admin-only features such as user management, feedback management, and statistics.

## Folder Structure

```
lib/domain/admin/
├── entities/           # Data models (currently empty)
├── functions/          # Business logic functions
│   ├── fetch_all_users.dart       # Fetch all users
│   ├── fetch_all_feedbacks.dart   # Fetch all feedbacks
│   └── block_user.dart            # Block user
└── presentation/       # UI related code
    ├── screens/        # Screen components
    │   ├── users_screen.dart           # User management screen
    │   ├── feedback_list_screen.dart   # Feedback list screen
    │   └── admin_settings_screen.dart  # Admin settings screen
    └── widgets/        # Reusable widgets
        ├── admin_info_section.dart    # Admin info section
        ├── admin_stat_card.dart       # Statistics card
        ├── admin_stats_grid.dart      # Statistics grid
        ├── role_chip.dart             # Role chip
        ├── feedback/                  # Feedback related widgets
        │   ├── feedback_card.dart
        │   ├── feedback_detail_modal.dart
        │   ├── feedback_empty_state.dart
        │   ├── feedback_filter_bottom_sheet.dart
        │   ├── feedback_stat_card.dart
        │   └── feedback_status_chip.dart
        └── users/                     # User management related widgets
            ├── user_card.dart
            ├── user_empty_state.dart
            ├── user_search_bar.dart
            └── user_stat_card.dart
```

## Key Features

### 1. User Management (`functions/fetch_all_users.dart`, `presentation/screens/users_screen.dart`)
- Fetch all users
- User search and filtering
- User statistics
- User blocking functionality

### 2. Feedback Management (`functions/fetch_all_feedbacks.dart`, `presentation/screens/feedback_list_screen.dart`)
- Fetch all feedbacks
- Filter by feedback status
- View feedback details
- Feedback statistics

### 3. Admin Settings (`presentation/screens/admin_settings_screen.dart`)
- Admin-only settings
- System management features

## Usage

### Fetch User List
```dart
import '../../domain/admin/functions/fetch_all_users.dart';

final result = await fetchAllUsersForAdmin(currentUserId: 'admin123');
if (result.isSuccess) {
  final users = result.data!;
  // Use users list
}
```

### Fetch Feedback List
```dart
import '../../domain/admin/functions/fetch_all_feedbacks.dart';

final result = await fetchAllFeedbacksForAdmin();
if (result.isSuccess) {
  final feedbacks = result.data!;
  // Use feedbacks list
}
```

### Block User
```dart
import '../../domain/admin/functions/block_user.dart';

final result = await blockUser(userId: 'user123');
if (result.isSuccess) {
  // Block successful
}
```

## UI Component Usage

### User Card
```dart
import '../widgets/users/user_card.dart';

UserCard(
  user: userObject,
  onTap: () => // Navigate to user details
)
```

### Feedback Card
```dart
import '../widgets/feedback/feedback_card.dart';

FeedbackCard(
  feedback: feedbackObject,
  onTap: () => // Show feedback detail modal
)
```

## Important Notes

- All functions use the Result pattern for error handling
- Current user admin status must be verified through Firebase Auth
- UI components follow the app's theme system (`AppColors`, `AppTypography`, etc.)
- Includes search, filtering, and sorting functionality
