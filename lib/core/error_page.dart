//package imports
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

//local imports
import 'themes/app_font_weights.dart';

/// Error page
/// Screen displayed when routing errors occur
class ErrorPage extends StatelessWidget {
  final String errorCode;

  const ErrorPage({super.key, required this.errorCode});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        backgroundColor: colorScheme.error,
        foregroundColor: colorScheme.onError,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: colorScheme.error),
            const SizedBox(height: 24),
            Text(
              'Error $errorCode',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: AppFontWeights.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'The requested page could not be found',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.home),
              label: const Text('Go Back to Home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
