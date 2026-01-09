# Themes

The Themes module provides a comprehensive design system for the Flutter application. It defines consistent styling, spacing, typography, colors, and visual elements used throughout the app to ensure a cohesive user experience.

## Folder Structure

```
lib/core/themes/
├── app_theme.dart              # Main theme configuration and common colors
├── color_theme.dart            # Color palette and theme colors
├── app_typography.dart         # Text styles and typography system
├── app_spacing.dart            # Spacing tokens and layout constants
├── app_dimensions.dart         # Size constants and dimension tokens
├── app_shadows.dart            # Shadow styles and elevation effects
└── app_font_weights.dart       # Font weight definitions
```

## Key Components

### 1. App Theme (`app_theme.dart`)
Central theme configuration providing:
- **AppCommonColors**: Universal colors (white, black, semantic colors)
- **Theme Integration**: Material Design 3 theme setup
- **Global Styling**: App-wide visual consistency

### 2. Color System (`color_theme.dart`)
Comprehensive color palette including:
- **Brand Colors**: Primary brand identity colors
- **Semantic Colors**: Success, error, warning, info colors
- **Neutral Colors**: Grayscale palette for text and backgrounds
- **Theme Variants**: Light and dark theme support

### 3. Typography (`app_typography.dart`)
Text styling system featuring:
- **Heading Styles**: H1-H6 hierarchical text styles
- **Body Text**: Regular content text styles
- **Display Text**: Large promotional or hero text
- **Caption Text**: Small supplementary text
- **Font Weights**: Custom weight definitions

### 4. Spacing System (`app_spacing.dart`)
Layout spacing tokens including:
- **Padding Constants**: Consistent internal spacing
- **Margin Values**: External spacing between elements
- **Gap Sizes**: Space between components
- **Layout Dimensions**: Standard layout measurements

### 5. Dimensions (`app_dimensions.dart`)
Size constants for:
- **Component Sizes**: Button heights, icon sizes
- **Layout Dimensions**: Container widths, heights
- **Responsive Breakpoints**: Screen size thresholds
- **Standard Measurements**: Common UI element sizes

### 6. Shadow System (`app_shadows.dart`)
Elevation and shadow effects:
- **Elevation Levels**: Material Design elevation system
- **Custom Shadows**: Branded shadow styles
- **Depth Effects**: Visual hierarchy through shadows
- **Platform Consistency**: iOS and Android appropriate shadows

### 7. Font Weights (`app_font_weights.dart`)
Typography weight definitions:
- **Weight Constants**: Named font weight values
- **Hierarchy Support**: Weight-based text hierarchy
- **Brand Typography**: Custom weight combinations

## Usage

### Using Colors
```dart
import '../core/themes/app_theme.dart';
import '../core/themes/color_theme.dart';

// Common colors
Container(
  color: AppCommonColors.white,
  child: Text(
    'Hello World',
    style: TextStyle(color: AppCommonColors.black),
  ),
)

// Theme colors (when available)
Container(
  color: AppColors.primary,
  child: Text(
    'Themed Text',
    style: TextStyle(color: AppColors.onPrimary),
  ),
)
```

### Using Typography
```dart
import '../core/themes/app_typography.dart';

// Heading styles
Text(
  'Main Title',
  style: AppTypography.h1,
)

Text(
  'Subtitle',
  style: AppTypography.h3,
)

// Body text
Text(
  'Regular content text goes here...',
  style: AppTypography.body1,
)

// Caption text
Text(
  'Small supplementary text',
  style: AppTypography.caption,
)
```

### Using Spacing
```dart
import '../core/themes/app_spacing.dart';

// Padding
Container(
  padding: EdgeInsets.all(AppSpacing.md),
  child: Column(
    children: [
      Text('First item'),
      SizedBox(height: AppSpacing.sm),
      Text('Second item'),
      SizedBox(height: AppSpacing.lg),
      Text('Third item'),
    ],
  ),
)

// Margins
Container(
  margin: EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,
    vertical: AppSpacing.md,
  ),
  child: Text('Content with margins'),
)
```

### Using Dimensions
```dart
import '../core/themes/app_dimensions.dart';

// Standard button size
SizedBox(
  width: AppDimensions.buttonWidth,
  height: AppDimensions.buttonHeight,
  child: ElevatedButton(
    onPressed: () {},
    child: Text('Standard Button'),
  ),
)

// Icon sizes
Icon(
  Icons.star,
  size: AppDimensions.iconMd,
)
```

### Using Shadows
```dart
import '../core/themes/app_shadows.dart';

// Card with shadow
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    boxShadow: AppShadows.card,
  ),
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Text('Card with shadow'),
  ),
)

// Elevated button shadow
Container(
  decoration: BoxDecoration(
    boxShadow: AppShadows.button,
  ),
  child: ElevatedButton(
    onPressed: () {},
    child: Text('Elevated Button'),
  ),
)
```

### Using Font Weights
```dart
import '../core/themes/app_font_weights.dart';

// Different font weights
Text(
  'Light Text',
  style: TextStyle(fontWeight: AppFontWeights.light),
)

Text(
  'Regular Text',
  style: TextStyle(fontWeight: AppFontWeights.regular),
)

Text(
  'Bold Text',
  style: TextStyle(fontWeight: AppFontWeights.bold),
)
```

## Design System Principles

### Consistency
- Use defined tokens instead of hardcoded values
- Maintain visual hierarchy through consistent sizing
- Apply standard spacing throughout the app

### Accessibility
- Ensure sufficient color contrast ratios
- Support both light and dark themes
- Use semantic color naming for screen readers

### Scalability
- Define responsive breakpoints for different screen sizes
- Use relative sizing where appropriate
- Support dynamic type scaling

### Maintainability
- Centralize all design tokens in theme files
- Use semantic naming conventions
- Document color usage and typography hierarchy

## Theme Integration

### Material Design 3
The theme system integrates with Material Design 3:
- Color scheme generation from brand colors
- Typography scale alignment
- Component theming support
- Dynamic color support

### Custom Components
For custom components, always use theme values:
```dart
// Good - uses theme values
Container(
  padding: EdgeInsets.all(AppSpacing.md),
  decoration: BoxDecoration(
    color: AppCommonColors.white,
    boxShadow: AppShadows.card,
  ),
)

// Avoid - hardcoded values
Container(
  padding: EdgeInsets.all(16.0),
  decoration: BoxDecoration(
    color: Color(0xFFFFFFFF),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 4.0,
        offset: Offset(0, 2),
      ),
    ],
  ),
)
```

## Important Notes

- Always use theme constants instead of hardcoded values
- Maintain consistency across all UI components
- Support both light and dark theme variations
- Follow Material Design 3 guidelines for component styling
- Test theme changes across different screen sizes
- Ensure accessibility compliance with color contrast requirements
- Update theme tokens when design system changes are needed
- Use semantic color names for better maintainability