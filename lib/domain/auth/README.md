# Auth Domain

The Auth domain module handles all authentication functionality. It provides comprehensive authentication features including social login, email authentication, user registration, and account management.

## Folder Structure

```
lib/domain/auth/
├── functions/          # Authentication business logic functions
│   ├── sign_in_with_email.dart            # Email sign in
│   ├── sign_up_with_email.dart            # Email sign up
│   ├── sign_in_with_google.dart           # Google OAuth sign in
│   ├── sign_in_with_apple.dart            # Apple sign in
│   ├── send_password_reset_email.dart     # Password reset
│   ├── delete_user_account.dart           # Account deletion
│   ├── check_user_blocked.dart            # Check if user is blocked
│   ├── check_user_blocked_by_email.dart   # Check blocked status by email
│   ├── fetch_admin_emails.dart            # Fetch admin email list
│   ├── reauthenticate_user.dart           # User reauthentication
│   ├── reauthenticate_with_google.dart    # Google reauthentication
│   └── reauthenticate_with_apple.dart     # Apple reauthentication
├── models/             # Data models
│   ├── google_sign_in_result.dart         # Google sign in result model
│   └── social_sign_in_result.dart         # Social sign in result model
└── presentation/       # UI related code
    └── screens/        # Screen components
        ├── splash_screen.dart             # App launch screen
        ├── onboarding_screen.dart         # User onboarding
        ├── sign_in_and_up_screen.dart     # Combined sign in/up screen
        ├── sign_in_screen.dart            # Email sign in screen
        ├── sign_up_screen.dart            # Email sign up screen
        ├── social_sign_up_screen.dart     # Social sign up screen
        ├── sign_up_complete_screen.dart   # Sign up completion
        ├── next_sign_up_tnc_screen.dart   # Terms and conditions
        ├── forgot_password_screen.dart    # Password reset screen
        └── onboarding/                    # Onboarding components
            ├── onboarding_content.dart
            └── dot_indicators.dart
```

## Key Features

### 1. Email Authentication
- **Sign In** (`functions/sign_in_with_email.dart`): Email and password authentication
- **Sign Up** (`functions/sign_up_with_email.dart`): New user registration with email
- **Password Reset** (`functions/send_password_reset_email.dart`): Send password reset emails

### 2. Social Authentication
- **Google Sign In** (`functions/sign_in_with_google.dart`): OAuth authentication with Google
- **Apple Sign In** (`functions/sign_in_with_apple.dart`): Sign in with Apple ID
- **Social Sign Up** (`presentation/screens/social_sign_up_screen.dart`): Social registration flow

### 3. Account Management
- **Account Deletion** (`functions/delete_user_account.dart`): Permanent account removal
- **Reauthentication** (`functions/reauthenticate_user.dart`): Re-verify user credentials
- **User Blocking** (`functions/check_user_blocked.dart`): Check and manage blocked users

### 4. Admin Features
- **Admin Detection** (`functions/fetch_admin_emails.dart`): Identify admin users
- **User Status** (`functions/check_user_blocked_by_email.dart`): Check user blocking status

## Usage

### Email Sign In
```dart
import '../../domain/auth/functions/sign_in_with_email.dart';

final result = await SignInWithEmail.withEmail('user@example.com', 'password123');
if (result.isSuccess) {
  final user = result.data!;
  // Handle successful login
}
```

### Google Sign In
```dart
import '../../domain/auth/functions/sign_in_with_google.dart';

final result = await signInWithGoogle();
if (result.isSuccess) {
  final user = result.data!;
  // Handle successful Google login
}
```

### Email Sign Up
```dart
import '../../domain/auth/functions/sign_up_with_email.dart';

final result = await signUpWithEmail(
  email: 'user@example.com',
  password: 'password123',
  name: 'John Doe'
);
if (result.isSuccess) {
  // Handle successful registration
}
```

### Password Reset
```dart
import '../../domain/auth/functions/send_password_reset_email.dart';

final result = await sendPasswordResetEmail('user@example.com');
if (result.isSuccess) {
  // Password reset email sent
}
```

### Check User Blocked Status
```dart
import '../../domain/auth/functions/check_user_blocked.dart';

final result = await checkUserBlocked(userId: 'user123');
if (result.isSuccess && result.data == true) {
  // User is blocked
}
```

## Screen Components

### Sign In Flow
- `splash_screen.dart`: App initialization and routing
- `onboarding_screen.dart`: First-time user onboarding
- `sign_in_and_up_screen.dart`: Combined authentication entry point
- `sign_in_screen.dart`: Email/password sign in form

### Sign Up Flow
- `sign_up_screen.dart`: Email registration form
- `social_sign_up_screen.dart`: Social media registration
- `next_sign_up_tnc_screen.dart`: Terms and conditions acceptance
- `sign_up_complete_screen.dart`: Registration completion

### Password Recovery
- `forgot_password_screen.dart`: Password reset request form

## Data Models

### Social Sign In Result
```dart
import '../../models/social_sign_in_result.dart';

// Represents the result of social authentication
class SocialSignInResult {
  final bool isSuccess;
  final String? errorMessage;
  final UserEntity? user;
}
```

### Google Sign In Result
```dart
import '../../models/google_sign_in_result.dart';

// Specific result model for Google authentication
class GoogleSignInResult {
  final bool isSuccess;
  final UserEntity? user;
  final String? error;
}
```

## Important Notes

- All authentication functions use the Result pattern for error handling
- Firebase Auth is integrated with Firestore for user data management
- FCM tokens are automatically updated after successful authentication
- Social authentication supports both new user registration and existing user sign in
- Admin status is determined by checking against a predefined admin email list
- User blocking is enforced at the authentication level
- All UI components follow the app's theme system and design guidelines