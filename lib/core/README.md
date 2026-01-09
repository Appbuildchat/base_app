# Core

The Core module provides fundamental utilities, services, and components that are used throughout the Flutter application. It contains essential functionality including error handling, validation, UI components, and infrastructure services.

## Folder Structure

```
lib/core/
├── app_error_code.dart         # Centralized error code definitions
├── error_page.dart             # Error page UI component
├── result.dart                 # Result pattern for error handling
├── validators.dart             # Input validation utilities
├── image_picker/               # Image selection and upload functionality
│   ├── upload_image.dart
│   ├── media_picker_utils.dart
│   ├── media_picker_widget.dart
│   └── custom_gallery_screen.dart
├── notification/               # Push notification management
│   ├── config/
│   ├── entities/
│   └── function/
├── providers/                  # State management providers
│   └── role_provider.dart
├── router/                     # App navigation and routing
│   ├── app_router.dart
│   ├── auth_guard.dart
│   ├── general_routes.dart
│   └── shell_routes.dart
├── shell/                      # App shell and navigation structure
│   ├── main_shell.dart
│   └── tab_utils.dart
├── themes/                     # Design system and theming
│   ├── app_theme.dart
│   ├── color_theme.dart
│   ├── app_typography.dart
│   ├── app_spacing.dart
│   ├── app_dimensions.dart
│   ├── app_shadows.dart
│   └── app_font_weights.dart
└── widgets/                    # Reusable UI components
    ├── loading_overlay.dart
    ├── modern_button.dart
    ├── modern_dropdown.dart
    ├── modern_text_field.dart
    ├── modern_toast.dart
    ├── skeleton_loader.dart
    └── skeletons/
```

## Key Components

### 1. Error Management
- **App Error Code** (`app_error_code.dart`): Centralized error definitions with user-friendly messages
- **Error Page** (`error_page.dart`): Standardized error display component
- **Result Pattern** (`result.dart`): Type-safe error handling pattern

### 2. Validation System
- **Validators** (`validators.dart`): Input validation utilities for forms and user input

### 3. Image Management
- **Image Picker** (`image_picker/`): Complete image selection, processing, and upload system

### 4. Navigation & Routing
- **Router** (`router/`): App navigation with authentication guards and deep linking
- **Shell** (`shell/`): Navigation shell with tab management

### 5. Notifications
- **Notification** (`notification/`): Push notification system with FCM integration

### 6. Design System
- **Themes** (`themes/`): Comprehensive theming system with colors, typography, and spacing

### 7. State Management
- **Providers** (`providers/`): Application state providers for global state management

### 8. UI Components
- **Widgets** (`widgets/`): Reusable UI components following the design system

## Usage

### Error Handling with Result Pattern
```dart
import '../core/result.dart';
import '../core/app_error_code.dart';

// Function returning Result
Future<Result<User>> fetchUser(String userId) async {
  try {
    final user = await userService.getUser(userId);
    return Result.success(user);
  } catch (e) {
    return Result.failure(
      AppErrorCode.networkError,
      message: 'Failed to fetch user',
    );
  }
}

// Using the Result
final result = await fetchUser('123');
if (result.isSuccess) {
  final user = result.data!;
  // Handle success
} else {
  // Handle error
  print('Error: ${result.errorMessage}');
}
```

### Input Validation
```dart
import '../core/validators.dart';

// Email validation
String? emailError = Validators.validateEmail('user@example.com');
if (emailError != null) {
  // Show error message
}

// Password validation
String? passwordError = Validators.validatePassword('password123');
if (passwordError != null) {
  // Show password requirements
}

// Custom validation
String? customError = Validators.validateRequired('', 'Username');
```

### Using Modern UI Components
```dart
import '../core/widgets/modern_button.dart';
import '../core/widgets/modern_text_field.dart';
import '../core/widgets/loading_overlay.dart';

// Modern button
ModernButton(
  text: 'Submit',
  onPressed: () {
    // Handle button press
  },
  isLoading: isSubmitting,
),

// Modern text field
ModernTextField(
  label: 'Email',
  hint: 'Enter your email',
  validator: Validators.validateEmail,
  onChanged: (value) {
    // Handle text change
  },
),

// Loading overlay
LoadingOverlay(
  isLoading: isProcessing,
  child: YourContentWidget(),
)
```

## Error Code System

### Predefined Error Categories
```dart
enum AppErrorCode {
  // Data handling errors
  dataParseError,
  dataFormatError,
  typeCastError,
  
  // Network errors
  networkError,
  timeoutError,
  connectionError,
  
  // Authentication errors
  authenticationError,
  permissionDenied,
  sessionExpired,
  
  // Validation errors
  validationError,
  invalidInput,
  missingRequiredField,
  
  // General errors
  unknownError,
  operationFailed,
}
```

### Error Display
```dart
import '../core/error_page.dart';

// Show error page
ErrorPage(
  error: AppErrorCode.networkError,
  onRetry: () {
    // Handle retry action
  },
)
```

## Validation Utilities

### Available Validators
- **Email validation**: RFC-compliant email format checking
- **Password validation**: Strength requirements and security checks
- **Phone validation**: Phone number format validation
- **Required field validation**: Non-empty field validation
- **URL validation**: Valid URL format checking
- **Custom validators**: Extensible validation system

### Custom Validator Example
```dart
class CustomValidators {
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    
    return null;
  }
}
```

## State Management

### Role Provider Example
```dart
import '../core/providers/role_provider.dart';

// Using role provider
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<RoleProvider>(
      builder: (context, roleProvider, child) {
        if (roleProvider.isAdmin) {
          return AdminPanel();
        } else {
          return UserPanel();
        }
      },
    );
  }
}
```

## UI Component System

### Modern Components
All UI components follow the design system:
- Consistent styling and theming
- Built-in loading states
- Error state handling
- Accessibility support
- Responsive design

### Skeleton Loading
```dart
import '../core/widgets/skeleton_loader.dart';

SkeletonLoader(
  isLoading: isLoadingData,
  child: ActualContent(),
  skeleton: SkeletonWidget(
    height: 200,
    borderRadius: 8,
  ),
)
```

### Toast Notifications
```dart
import '../core/widgets/modern_toast.dart';

ModernToast.show(
  context,
  message: 'Operation completed successfully',
  type: ToastType.success,
);
```

## Integration Guidelines

### Using Core Components
1. Always use the Result pattern for operations that can fail
2. Use validators for all user input
3. Follow the error code system for consistent error handling
4. Use modern UI components instead of basic Flutter widgets
5. Apply theming consistently across all components

### Best Practices
- Import core utilities at the beginning of files
- Use type-safe error handling with Result pattern
- Implement proper validation for all forms
- Follow the established theming system
- Use skeleton loading for better user experience
- Handle all error states gracefully

## Dependencies

### Core Dependencies
The core module relies on these key packages:
- `firebase_storage`: For image upload functionality
- `image_picker`: For image selection
- `go_router`: For navigation
- `flutter_animate`: For animations
- `provider`: For state management

### Platform-Specific Setup
Some core features require platform-specific configuration:
- Image picker permissions (iOS/Android)
- Push notification setup
- Deep linking configuration

## Important Notes

- The core module provides the foundation for all app functionality
- All components use the Result pattern for consistent error handling
- The validation system ensures data integrity across the app
- UI components follow Material Design 3 guidelines
- The theming system enables consistent visual design
- Error handling provides user-friendly feedback
- State management is centralized through providers
- Navigation uses type-safe routing with authentication guards
- Image handling includes optimization and cloud storage
- All components support both light and dark themes