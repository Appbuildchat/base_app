# User Domain

The User domain module handles all user-related functionality. It provides comprehensive features for user profile management, user data operations, and user interface components for profile display and editing.

## Folder Structure

```
lib/domain/user/
├── entities/           # Data models
│   ├── user_entity.dart              # Main user data model
│   └── role.dart                     # User role enumeration
├── functions/          # Business logic functions
│   ├── fetch_user_details.dart      # Fetch complete user profile
│   ├── fetch_user_field.dart        # Fetch specific user field
│   ├── fetch_users_from_ids.dart    # Fetch multiple users by IDs
│   ├── fetch_blocked_user_ids.dart  # Fetch blocked users list
│   ├── update_user_field.dart       # Update specific user field
│   ├── update_user_username.dart    # Update username
│   ├── update_user_email.dart       # Update email address
│   └── update_user_password.dart    # Update password
└── presentation/       # UI related code
    ├── screens/        # Screen components
    │   └── profile_screen.dart       # User profile screen
    └── widgets/        # Reusable widgets
        ├── profile_image_widget.dart         # Profile picture component
        ├── profile_username_field_widget.dart # Username input field
        ├── profile_bio_field_widget.dart     # Bio input field
        ├── profile_action_button_widget.dart # Profile action buttons
        └── save_button_widget.dart           # Save changes button
```

## Key Features

### 1. User Data Management
- **Fetch User Details** (`functions/fetch_user_details.dart`): Get complete user profile
- **Fetch User Field** (`functions/fetch_user_field.dart`): Get specific profile field
- **Fetch Multiple Users** (`functions/fetch_users_from_ids.dart`): Bulk user data retrieval
- **Blocked Users** (`functions/fetch_blocked_user_ids.dart`): Manage blocked user lists

### 2. Profile Updates
- **Update Field** (`functions/update_user_field.dart`): Generic field update function
- **Update Username** (`functions/update_user_username.dart`): Change display name
- **Update Email** (`functions/update_user_email.dart`): Change email address
- **Update Password** (`functions/update_user_password.dart`): Change account password

### 3. User Interface Components
- **Profile Screen** (`screens/profile_screen.dart`): Main profile management screen
- **Profile Widgets**: Specialized UI components for profile editing
- **Form Components**: Input fields and action buttons

## Data Models

### User Entity
```dart
import '../../entities/user_entity.dart';

class UserEntity {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String? username;
  final String? bio;
  final String? profileImageUrl;
  final String? phoneNumber;
  final Role role;
  final List<String> blockedUsers;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isBlocked;
}
```

### User Role
```dart
import '../../entities/role.dart';

enum Role {
  user,         // Regular user
  admin,        // Administrator
  moderator,    // Content moderator
  premium       // Premium subscriber
}
```

## Usage

### Fetch User Details
```dart
import '../../domain/user/functions/fetch_user_details.dart';

final result = await fetchUserDetails(userId: 'user123');
if (result.isSuccess) {
  final user = result.data!;
  // Use complete user profile
}
```

### Fetch Specific User Field
```dart
import '../../domain/user/functions/fetch_user_field.dart';

final result = await fetchUserField(
  userId: 'user123',
  fieldName: 'username'
);
if (result.isSuccess) {
  final username = result.data!;
  // Use specific field value
}
```

### Fetch Multiple Users
```dart
import '../../domain/user/functions/fetch_users_from_ids.dart';

final result = await fetchUsersFromIds(
  userIds: ['user1', 'user2', 'user3']
);
if (result.isSuccess) {
  final users = result.data!;
  // Use list of user profiles
}
```

### Update User Field
```dart
import '../../domain/user/functions/update_user_field.dart';

final result = await updateUserField(
  userId: 'user123',
  fieldName: 'bio',
  fieldValue: 'Updated bio text'
);
if (result.isSuccess) {
  // Field updated successfully
}
```

### Update Username
```dart
import '../../domain/user/functions/update_user_username.dart';

final result = await updateUserUsername(
  userId: 'user123',
  newUsername: 'newusername'
);
if (result.isSuccess) {
  // Username updated successfully
}
```

### Update Email Address
```dart
import '../../domain/user/functions/update_user_email.dart';

final result = await updateUserEmail(
  userId: 'user123',
  newEmail: 'new@example.com',
  password: 'currentpassword'
);
if (result.isSuccess) {
  // Email updated successfully
}
```

### Update Password
```dart
import '../../domain/user/functions/update_user_password.dart';

final result = await updateUserPassword(
  currentPassword: 'oldpassword',
  newPassword: 'newpassword'
);
if (result.isSuccess) {
  // Password updated successfully
}
```

### Fetch Blocked Users
```dart
import '../../domain/user/functions/fetch_blocked_user_ids.dart';

final result = await fetchBlockedUserIds(userId: 'user123');
if (result.isSuccess) {
  final blockedUserIds = result.data!;
  // Use blocked users list
}
```

## UI Components Usage

### Profile Image Widget
```dart
import '../widgets/profile_image_widget.dart';

ProfileImageWidget(
  imageUrl: user.profileImageUrl,
  size: 100.0,
  onTap: () => // Handle image tap
)
```

### Profile Username Field Widget
```dart
import '../widgets/profile_username_field_widget.dart';

ProfileUsernameFieldWidget(
  initialValue: user.username,
  onChanged: (value) => // Handle username change
)
```

### Profile Bio Field Widget
```dart
import '../widgets/profile_bio_field_widget.dart';

ProfileBioFieldWidget(
  initialValue: user.bio,
  onChanged: (value) => // Handle bio change
)
```

### Profile Action Button Widget
```dart
import '../widgets/profile_action_button_widget.dart';

ProfileActionButtonWidget(
  label: 'Edit Profile',
  onPressed: () => // Handle action
)
```

### Save Button Widget
```dart
import '../widgets/save_button_widget.dart';

SaveButtonWidget(
  isLoading: isUpdating,
  onPressed: () => // Save changes
)
```

## Profile Management Features

### Profile Editing
- Real-time input validation
- Image upload and management
- Field-specific update functions
- Optimistic UI updates
- Error handling and rollback

### User Permissions
- Role-based access control
- Admin-only functions
- User blocking functionality
- Profile privacy settings

### Data Synchronization
- Real-time updates across devices
- Offline capability support
- Conflict resolution
- Change history tracking

## Firebase Integration

### Firestore Operations
- Efficient user data queries
- Batch operations for multiple users
- Real-time listeners for profile changes
- Indexed queries for performance

### Authentication Integration
- Profile updates sync with Firebase Auth
- Email verification workflows
- Password change security
- Account linking support

## Validation and Security

### Input Validation
- Username format and uniqueness
- Email address validation
- Password strength requirements
- Bio content filtering

### Security Measures
- Authentication required for updates
- Rate limiting on profile changes
- Audit logging for sensitive operations
- Data encryption for sensitive fields

## Error Handling

Common scenarios handled:
- Network connectivity issues
- Invalid input data
- Authentication failures
- Permission denied errors
- Concurrent modification conflicts
- File upload failures

## Important Notes

- All functions use the Result pattern for error handling
- User data is stored in Firestore with proper indexing
- Profile images are stored in Firebase Storage
- All UI components follow the app's theme system
- Real-time updates are supported through Firestore listeners
- User blocking is enforced at multiple levels
- Profile changes maintain audit trails
- Sensitive operations require re-authentication