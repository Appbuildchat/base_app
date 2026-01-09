# Code Rules

## MANDATORY Package Management
- ALWAYS use `flutter pub add {package}` for new dependencies
- NEVER manually edit pubspec.yaml for packages
- ALWAYS run `flutter pub get` after adding packages

## Screen Implementation Rules

### Required Imports
```dart
import 'package:flutter/material.dart';
import 'package:your_app/core/themes/color_theme.dart'; // MANDATORY
```

### Screen Structure Pattern
```dart
class [Name]Screen extends StatefulWidget {
  const [Name]Screen({super.key});
  
  @override
  State<[Name]Screen> createState() => _[Name]ScreenState();
}

class _[Name]ScreenState extends State<[Name]Screen> {
  // State variables
  bool _isLoading = false;
  
  // Business logic in screen
  Future<void> _handleAction() async {
    setState(() => _isLoading = true);
    // Implementation
    if (!mounted) return;
    setState(() => _isLoading = false);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
      ),
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    // Simple widgets as methods
    // Complex widgets as separate files
  }
}
```

## Function Implementation Rules

### Business Logic Pattern
```dart
import '../../../core/result.dart';
import '../../../core/app_error_code.dart';

class [FunctionName] {
  static Future<Result<ReturnType>> execute(params) async {
    // 1. Validation
    if (invalid) {
      return Result.failure(AppErrorCode.invalidFormat);
    }
    
    try {
      // 2. Business logic
      return Result.success(data);
    } catch (e) {
      return Result.failure(AppErrorCode.unknown);
    }
  }
}
```

## Entity Implementation Rules

### Firestore Entity Pattern
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class [Name]Entity {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const [Name]Entity({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory [Name]Entity.fromJson(Map<String, dynamic> json) {
    return [Name]Entity(
      id: json['id'] ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
```

## STRICT Rules
- ALWAYS use AppColors theme (never hardcode colors)
- ALWAYS check mounted before setState in async functions
- ALWAYS use Result<T> wrapper for function returns
- ALWAYS handle Timestamp conversions for Firestore dates
- NEVER use Navigator directly (use GoRouter)
- NEVER create documentation files unless requested

## Widget Extraction Rules
- Extract to method (_buildXxx): Simple, stateless UI sections
- Extract to widget file: Complex UI, reusable components, forms with validation