# flutter_basic_project - Enterprise Flutter Application Template

A production-ready Flutter project template designed for building enterprise-grade mobile applications. This template provides a solid foundation with best practices, proper structure, and development tools integration.

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.32.4 or higher
- Dart SDK 3.8.1 or higher
- Node.js v22.16.0 (for Claude Code CLI)
- NVM Checking
- IDE with Flutter support (VS Code, Android Studio, IntelliJ)

- gcloud - https://cloud.google.com/sdk/docs/install#deb
   gcloud init
   gcloud auth application-default login

- firebase login


### Initial Setup

1. **Run the initialization script:**
   ```bash
   ./start.sh
   ```
   This script will:
   - Verify and install development dependencies
   - Customize the package name
   - Configure Serena MCP server for Claude Code
   - Set up the Flutter environment

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the application:**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
.
├── lib/                    # Application source code
│   └── main.dart          # Entry point
├── test/                   # Unit and widget tests
├── android/               # Android-specific configuration
├── ios/                   # iOS-specific configuration
├── web/                   # Web-specific configuration
├── linux/                 # Linux desktop configuration
├── macos/                 # macOS desktop configuration
├── windows/               # Windows desktop configuration
├── pubspec.yaml           # Package dependencies
├── analysis_options.yaml  # Linting rules
└── start.sh              # Project initialization script
```

### Recommended Directory Structure (for scaling)
```
lib/
├── main.dart              # App entry point
├── app/                   # Application layer
│   ├── routes/           # Navigation and routing
│   └── themes/           # App themes and styling
├── core/                  # Core functionality
│   ├── constants/        # App constants
│   ├── errors/           # Error handling
│   └── utils/            # Utility functions
├── data/                  # Data layer
│   ├── models/           # Data models
│   ├── repositories/     # Data repositories
│   └── services/         # External services
├── presentation/          # Presentation layer
│   ├── screens/          # Full-page widgets
│   ├── widgets/          # Reusable widgets
│   └── providers/        # State management
└── l10n/                  # Localization files
```

## 🛠️ Development Commands

### Essential Commands
```bash
# Development
flutter run                    # Run on connected device
flutter run -d chrome         # Run on Chrome
flutter run --release         # Run in release mode

# Building
flutter build apk             # Build Android APK
flutter build ios             # Build iOS (macOS only)
flutter build web             # Build for web

# Testing & Quality
flutter test                  # Run tests
flutter analyze               # Analyze code

# Maintenance
flutter clean                 # Clean build artifacts
flutter pub upgrade           # Upgrade dependencies
flutter doctor                # Check Flutter setup
```

## 🎨 Current Implementation

The template includes:
- ✅ Material Design 3 with Material You theming
- ✅ Basic counter demo app with StatefulWidget
- ✅ Cross-platform support (iOS, Android, Web, Desktop)
- ✅ Flutter linting with flutter_lints
- ✅ Hot reload support
- ✅ Serena MCP integration for Claude Code

## 📦 Dependencies

### Production Dependencies
- `flutter` - Core Flutter SDK
- `cupertino_icons: ^1.0.8` - iOS-style icons

### Development Dependencies
- `flutter_test` - Testing framework
- `flutter_lints: ^5.0.0` - Linting rules

## 🏗️ Architecture Guidelines

### State Management Options
The template uses basic StatefulWidget. For production apps, consider:
- **Provider** - Simple and Flutter-recommended
- **Riverpod** - Provider with compile-time safety
- **Bloc** - For complex business logic
- **GetX** - Full-featured with routing and dependencies

### Recommended Patterns
1. **Separation of Concerns** - Keep UI, business logic, and data separate
2. **Dependency Injection** - Use GetIt or Provider for DI
3. **Repository Pattern** - Abstract data sources
4. **Clean Architecture** - Domain, Data, and Presentation layers

## 🧪 Testing Strategy

### Unit Tests
```dart
test/
├── unit/           # Business logic tests
├── widget/         # Widget tests
└── integration/    # Integration tests
```

### Running Tests
```bash
flutter test                          # All tests
flutter test test/unit/              # Unit tests only
flutter test --coverage              # With coverage
```

## 🔧 Configuration

### Environment Configuration
Create `lib/config/` directory for environment-specific settings:
```dart
class AppConfig {
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://api.example.com',
  );
}
```

Run with environment variables:
```bash
flutter run --dart-define=API_URL=https://staging.api.com
```

## 🚢 Deployment

### Android
1. Update `android/app/build.gradle` with signing config
2. Build: `flutter build appbundle`
3. Upload to Google Play Console

### iOS
1. Open in Xcode: `open ios/Runner.xcworkspace`
2. Configure signing & capabilities
3. Build: `flutter build ios`
4. Upload via App Store Connect

### Web
1. Build: `flutter build web`
2. Deploy `build/web/` directory to hosting service

## 🤝 Development Workflow

### With Claude Code & Serena MCP
1. Start Claude Code: `claude code .`
2. Serena MCP provides intelligent code assistance
3. Use symbolic code navigation and editing
4. Automatic project understanding and memory

### Git Workflow
```bash
git checkout -b feature/new-feature
# Make changes
flutter analyze && flutter test
git add .
git commit -m "feat: add new feature"
git push origin feature/new-feature
```

## 📚 Resources

### Flutter Documentation
- [Flutter Documentation](https://docs.flutter.dev/)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
- [Widget Catalog](https://docs.flutter.dev/ui/widgets)

### Architecture & Patterns
- [Flutter Architecture Samples](https://fluttersamples.com/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [BLoC Pattern](https://bloclibrary.dev/)

### Tools & Extensions
- [Flutter DevTools](https://docs.flutter.dev/tools/devtools)
- [VS Code Flutter Extension](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter)
- [Android Studio Flutter Plugin](https://plugins.jetbrains.com/plugin/9212-flutter)

## 🎯 Next Steps for Your Project

1. **Choose State Management** - Select and implement state management solution
2. **Setup Navigation** - Implement routing (go_router recommended)
3. **Add Authentication** - Implement user authentication
4. **Configure CI/CD** - Setup GitHub Actions or other CI/CD
5. **Implement Design System** - Create consistent UI components
6. **Add Analytics** - Integrate analytics (Firebase, Mixpanel)
7. **Setup Error Tracking** - Add Sentry or similar
8. **Internationalization** - Add multi-language support


## App Context

To create a app-context.yml file, you must run claude code on the app lib folder using custom style and command

```bash
claude

/output-styles
```

Select App Context

```bash
/app-context ./lib
```

A app-context.yml file will be created in the directory root.
To change the yaml structure or details, update the example output in the @app-context.md file.


## 📄 License

This template is provided as-is for use in building Flutter applications.
