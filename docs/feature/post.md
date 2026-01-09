# Post Feature Documentation

## Overview
The post feature enables users to create, read, update, and delete content posts within the app. This is a flexible content management system that can be adapted for various types of applications - from social media platforms to blog systems, news feeds, or community forums.

## Core Features (Essential - Always Required)

### Must-Have Screens
1. **Post List Screen** - Browse available posts/content
2. **Post Detail Screen** - View detailed information about a specific post
3. **Add Post Screen** - Create new posts
4. **Edit Post Screen** - Modify existing posts (author only)

### Must-Have Features
- **Basic Post Management**
  - Create, read, update, delete posts
  - Text-based content with rich formatting
  - Basic media upload (images, videos)
  - Author-only delete functionality
  - Draft/published status

- **App Store Compliance** (Mandatory for store approval)
  - Report inappropriate content system
  - Block users functionality
  - Content moderation tools

### Core Domain Structure
Following the project's architecture rules:
```
lib/domain/post/
├── entities/
│   ├── post_entity.dart          # Core post entity
│   └── report_entity.dart        # For moderation
├── functions/
│   ├── create_post.dart
│   ├── fetch_posts.dart
│   ├── update_post.dart
│   ├── delete_post.dart          # Author-only access
│   └── report_post.dart          # Required for App Store
└── presentation/
    ├── screens/
    │   ├── post_list_screen.dart
    │   ├── post_detail_screen.dart
    │   ├── add_post_screen.dart
    │   └── edit_post_screen.dart
    └── widgets/
        ├── post_card.dart
        └── post_form.dart
```

### Basic Entity Structure
```dart
// Minimal required fields for any post system
class PostEntity {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final bool isPublished;
  final bool isReported;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> imageUrls;
  // Additional fields added based on customization needs
}
```

### Technical Implementation References
Use the project's core systems for consistent implementation:

#### Theme System Integration
```dart
// Import theme components
import '@lib/core/themes/color_theme.dart'; // AppColors, AppHSLColors
import '@lib/core/themes/app_theme.dart';    // AppCommonColors, theme config
import '@lib/core/themes/app_spacing.dart';
import '@lib/core/themes/app_typography.dart';

// Example usage in post widgets with complete color system
Container(
  padding: AppSpacing.large, // Use spacing tokens
  decoration: BoxDecoration(
    color: AppColors.background,           // Brand colors
    border: Border.all(
      color: AppCommonColors.grey300,      // Common utility colors
    ),
  ),
  child: Column(
    children: [
      // Post title using brand colors
      Text(
        post.title,
        style: AppTypography.heading.copyWith(
          color: AppColors.text,
        ),
      ),
      // Status indicators using semantic colors
      Container(
        color: post.isPublished 
          ? AppCommonColors.green    // Semantic success color
          : AppCommonColors.orange,  // Semantic warning color
        child: Text(
          post.isPublished ? 'Published' : 'Draft',
          style: AppTypography.bodySmall.copyWith(
            color: AppCommonColors.white,
          ),
        ),
      ),
    ],
  ),
)
```

#### Color Usage Guidelines
- **AppColors**: Use for primary brand colors (primary, secondary, accent, background, text)
- **AppCommonColors**: Use for utility colors (white, black, semantic colors like green/red/orange, grey shades)
- **AppHSLColors**: Use for HSL-based color manipulations and custom color variations

#### Media Upload Integration
```dart
// Import image picker components
import '@lib/core/image_picker/media_picker_widget.dart';
import '@lib/core/image_picker/upload_image.dart';
import '@lib/core/image_picker/media_picker_utils.dart';

// Example usage in post creation
MediaPickerWidget(
  onMediaSelected: (files) => uploadPostImages(files),
  allowMultiple: true,
)
```

## Customizable Features (App-Specific - Choose Based on Use Case)

### Content Enhancement Customizations
- **Rich Content System**
  - Markdown support
  - HTML formatting
  - Code syntax highlighting
  - Embedded media (videos, audio)
  - File attachments

- **Categorization System**
  - Custom category structures
  - Tag-based organization
  - Topic/hashtag support
  - Content classification

### Social Interaction Customizations
- **Engagement Features**
  - Like/reaction system
  - Comment functionality
  - Share/repost options
  - Bookmark/save functionality

- **User Interaction**
  - Follow authors
  - Mention system (@username)
  - User notifications
  - Social sharing integration

### Content Discovery Customizations
- **Search & Filtering**
  - Full-text search
  - Tag/category filtering
  - Author filtering
  - Date range filtering
  - Trending content

- **Recommendation System**
  - Related posts
  - Recommended authors
  - Personalized feed
  - Reading history

### Advanced Features
- **Analytics & Insights**
  - View count tracking
  - Reading time estimation
  - Author analytics
  - Content performance metrics

- **Collaboration Features**
  - Multi-author posts
  - Draft collaboration
  - Editorial workflow
  - Version history

## UI/UX Guidelines

### Design System Integration
- **Colors**: Use the complete color system:
  - `AppColors` from `@lib/core/themes/color_theme.dart` (primary, secondary, accent, background, text)
  - `AppHSLColors` from `@lib/core/themes/color_theme.dart` (HSL variants)
  - `AppCommonColors` from `@lib/core/themes/app_theme.dart` (white, black, semantic colors, grey shades)
- **Spacing**: Apply `@lib/core/themes/app_spacing.dart` tokens for consistent layout
- **Components**: Leverage `@lib/core/themes/app_theme.dart` for AppCard, AppButtons, and existing widgets
- **Typography**: Follow `@lib/core/themes/app_typography.dart` for text hierarchy
- **Dimensions**: Use `@lib/core/themes/app_dimensions.dart` for consistent sizing
- **Shadows**: Apply `@lib/core/themes/app_shadows.dart` for depth and elevation

### Basic Screen Layouts
Following the UI guidelines from `/docs/ui_guideline.md`:

#### Core Layout Pattern
```
┌─────────────────────┐
│      Header         │ (Search, Filter, Actions)
├─────────────────────┤
│   [Categories]      │ (Optional horizontal scroll)
├─────────────────────┤
│                     │
│    Post Feed/List   │ (Main content area)
│                     │
│                     │
└─────────────────────┘
```

#### Basic Post Card Structure
```
┌─────────────────────┐
│   Author Info       │ (Avatar, Name, Date)
├─────────────────────┤
│ Title               │
│ Content Preview     │
│ [Media Thumbnail]   │ (If applicable)
├─────────────────────┤
│ Actions             │ (Like, Comment, Share)
└─────────────────────┘
```

## Implementation Strategy

### Step 1: Core Implementation
1. Create basic domain structure with minimal entities
2. Implement core CRUD operations with author validation
3. Build essential screens with basic UI
4. Add required reporting/blocking features

### Step 2: Customization Layer
1. Identify specific app requirements
2. Extend entities with custom fields
3. Add custom functions for specific features
4. Enhance UI with app-specific components

### Required Integrations (All Apps)
- **Authentication System**: User management and author validation
- **Media Upload System**: Use existing `@lib/core/image_picker/`
  - `media_picker_widget.dart` for camera/gallery selection UI
  - `upload_image.dart` for image upload functionality
  - `media_picker_utils.dart` for utility functions
  - `custom_gallery_screen.dart` for custom gallery interface
- **Report/Block System**: For App Store compliance
- **Rich Text Editor**: For content creation

### Optional Integrations (Choose Based on Need)
- **User Profile System**: Enhanced author information
- **Push Notifications**: User engagement and interactions
- **Analytics**: Usage tracking and content metrics
- **Search System**: Full-text search capabilities

## Customization Examples

### Blog Platform
```dart
class BlogPostEntity extends PostEntity {
  final String excerpt;
  final List<String> tags;
  final String category;
  final int readTimeMinutes;
  final String seoTitle;
  final String metaDescription;
  // + featured image, slug, etc.
}
```

### Social Media Feed
```dart
class SocialPostEntity extends PostEntity {
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final List<String> mentions;
  final List<String> hashtags;
  final String location;
  // + privacy settings, reactions, etc.
}
```

### News/Article System
```dart
class ArticleEntity extends PostEntity {
  final String byline;
  final String source;
  final List<String> categories;
  final bool isBreaking;
  final DateTime publishedAt;
  final String excerpt;
  // + featured status, editor notes, etc.
}
```

## Implementation Guidelines for AI

### Planning Questions to Ask
1. **What type of content will users post?**
2. **Do posts need approval/moderation workflow?**
3. **Should posts support rich media or just text?**
4. **What level of social interaction is needed?**
5. **How should content be organized and discovered?**

### Development Approach
1. Start with core CRUD features and basic entity structure
2. Implement author-only deletion with proper validation
3. Add customizations incrementally based on requirements
4. Follow existing project architecture and UI patterns
5. Test core functionality before adding complex features
6. Ensure App Store compliance features are always included

### Firebase Cost Optimization

#### Data Structure Design
- **Array/Map Field Strategy**: Store likes and comments directly in post document for optimal cost efficiency
  - `List<String> likedUserIds` - Array of user IDs who liked the post
  - `Map<String, Comment> comments` - Comments stored as map field (commentId: Comment object)
  - `int likeCount`, `int commentCount` - Pre-calculated counts for instant display
- **Cost Benefits**: Single document read retrieves all post data instead of multiple subcollection queries
- **Document Size Management**: Monitor 1MB limit, implement comment pagination if needed (split into multiple documents)
- **Denormalization**: Store essential author info (authorName, authorAvatar) in each post document

#### Query Optimization & Pagination
- **Mandatory Pagination**: ALL post list queries must implement cursor-based pagination
- **Page Size Strategy**: Default 10-20 posts per page to control Firebase read costs
- **Pagination Implementation**:
  - Use `limit()` and `startAfter()` for efficient loading
  - Load-more button preferred over infinite scroll for cost control
  - Store last document reference for next page queries
- **Index Strategy**:
  - `(isPublished, createdAt desc)` - Main feed pagination
  - `(authorId, createdAt desc)` - User profile posts
  - `(hashtags array-contains, createdAt desc)` - Hashtag-based searches

#### Real-time vs One-time Reads
- **Post Lists**: Use StreamBuilder with pagination for live feed updates
- **Like/Comment Updates**: Single document updates automatically trigger real-time UI changes
- **Subscription Management**: 
  - Subscribe only to current page of posts (not entire collection)
  - Dispose subscriptions when navigating away from screens
  - Use FutureBuilder for static content like user profiles

#### Concurrent Update Handling
- **Firestore Transactions**: Use for like/comment operations to prevent data conflicts
- **Optimistic Updates**: Update UI immediately, rollback on transaction failure
- **Array Operations**: Use `arrayUnion`/`arrayRemove` for like toggle operations
- **Map Updates**: Use map merge operations for adding/removing comments
- **Error Recovery**: Implement proper retry mechanisms for failed transactions

### Security Considerations
- Validate author ownership for edit/delete operations
- Sanitize user input to prevent XSS attacks
- Implement proper content moderation tools
- Rate limiting for post creation
- Media upload validation and limits

This flexible approach allows the same post foundation to power diverse content applications while maintaining code quality, security, and user experience standards.