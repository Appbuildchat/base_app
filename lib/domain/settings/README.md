# Settings Domain

The Settings domain module handles all user settings and account management functionality. It provides comprehensive features for users to manage their profiles, change account information, and perform account-related actions.

## Folder Structure

```
lib/domain/settings/
├── functions/          # Business logic functions
│   ├── load_user_profile.dart        # Load user profile data
│   ├── change_username.dart          # Change username functionality
│   ├── change_bio.dart               # Change user bio
│   ├── change_password.dart          # Change user password
│   └── sign_out_with_email.dart      # Sign out functionality
└── presentation/       # UI related code
    └── screens/        # Screen components
        ├── settings_screen.dart          # Main settings screen
        ├── change_username_screen.dart   # Username change screen
        ├── change_nickname_screen.dart   # Nickname change screen
        ├── change_bio_screen.dart        # Bio change screen
        ├── change_phone_screen.dart      # Phone number change screen
        └── change_password_screen.dart   # Password change screen
```

## Key Features

### 1. Profile Management
- **Load Profile** (`functions/load_user_profile.dart`): Fetch current user profile data
- **Change Username** (`functions/change_username.dart`): Update user's display name
- **Change Bio** (`functions/change_bio.dart`): Update user biography
- **Change Password** (`functions/change_password.dart`): Update account password

### 2. Account Management
- **Sign Out** (`functions/sign_out_with_email.dart`): Secure user logout
- **Profile Validation**: Validate profile information before updates
- **Firebase Integration**: Sync changes with Firebase Auth and Firestore

### 3. Settings Screens
- **Main Settings** (`screens/settings_screen.dart`): Central settings hub
- **Profile Editing**: Individual screens for each profile field
- **Security Settings**: Password and authentication management
- **Account Actions**: Logout and account management

## Usage

### Load User Profile
```dart
import '../../domain/settings/functions/load_user_profile.dart';

final result = await loadUserProfile(userId: currentUser.uid);
if (result.isSuccess) {
  final userProfile = result.data!;
  // Use user profile data
}
```

### Change Username
```dart
import '../../domain/settings/functions/change_username.dart';

// Fetch current username
final currentResult = await fetchCurrentUsername();
if (currentResult.isSuccess) {
  final currentUsername = currentResult.data!;
}

// Validate new username
final validationResult = validateUsername('newusername');
if (validationResult.isSuccess) {
  // Change username
  final changeResult = await changeUsername(
    newUsername: 'newusername',
    userId: currentUser.uid
  );
  
  if (changeResult.isSuccess) {
    // Username changed successfully
  }
}
```

### Change User Bio
```dart
import '../../domain/settings/functions/change_bio.dart';

final result = await changeBio(
  newBio: 'This is my new bio',
  userId: currentUser.uid
);

if (result.isSuccess) {
  // Bio updated successfully
}
```

### Change Password
```dart
import '../../domain/settings/functions/change_password.dart';

final result = await changePassword(
  currentPassword: 'oldpassword123',
  newPassword: 'newpassword456'
);

if (result.isSuccess) {
  // Password changed successfully
} else {
  // Handle error (incorrect current password, etc.)
}
```

### Sign Out
```dart
import '../../domain/settings/functions/sign_out_with_email.dart';

final result = await signOutWithEmail();
if (result.isSuccess) {
  // User signed out successfully
  // Navigate to login screen
}
```

## Screen Navigation

### Settings Screen Usage
The main settings screen provides navigation to various setting pages:

```dart
// Navigate to username change screen
context.push('/change-username');

// Navigate to bio change screen
context.push('/change-bio');

// Navigate to password change screen
context.push('/change-password');

// Navigate to phone change screen
context.push('/change-phone');

// Navigate to nickname change screen
context.push('/change-nickname');
```

### Screen Features
- **Input Validation**: Real-time validation for all input fields
- **Loading States**: Show progress indicators during operations
- **Error Handling**: Display user-friendly error messages
- **Success Feedback**: Confirm successful changes to users

## Profile Field Validation

### Username Validation
- Minimum and maximum length requirements
- Alphanumeric characters and specific symbols
- Uniqueness validation against existing users
- Reserved username checking

### Password Validation
- Minimum length requirements
- Character complexity rules
- Current password verification for changes
- Secure password hashing

### Bio Validation
- Maximum character limits
- Content filtering for inappropriate content
- Special character handling

## Account Security

### Password Management
- Current password verification required for changes
- Secure password storage using Firebase Auth
- Password strength requirements enforcement
- Account lockout protection

### Session Management
- Secure logout functionality
- Session token invalidation
- Multi-device session management
- Auto-logout on security events

## Firebase Integration

### Firestore Updates
- Real-time profile synchronization
- Atomic updates for data consistency
- Offline capability support
- Change history tracking

### Firebase Auth Integration
- Profile updates sync with Auth profile
- Email verification for critical changes
- Multi-factor authentication support
- Account recovery options

## Error Handling

Common error scenarios handled:
- Network connectivity issues
- Invalid input validation
- Authentication failures
- Permission errors
- Rate limiting
- Concurrent modification conflicts

## UI/UX Features

### User Experience
- Intuitive navigation between settings
- Clear visual feedback for changes
- Consistent design patterns
- Accessibility support

### Loading States
- Skeleton loading for profile data
- Progress indicators for operations
- Optimistic UI updates where appropriate
- Error state recovery options

## Important Notes

- All functions use the Result pattern for error handling
- Profile changes require user authentication
- Critical changes may require password re-authentication
- All UI components follow the app's theme system
- Settings are synchronized across devices via Firebase
- Offline changes are queued and applied when online
- User data privacy is maintained throughout all operations
- Settings changes are logged for security auditing