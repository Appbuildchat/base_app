# Community Feature Documentation

## Overview
The community feature enables users to create and participate in topic-based communities within the app. This is a flexible feature system that supports private groups, interest-based communities, local communities, or any social gathering platform where users need approval-based membership and shared content creation.

## Core Features (Essential - Always Required)

### Must-Have Screens
1. **Community List Screen** - Browse available communities with search functionality
2. **Community Detail Screen** - View community info and request to join (2-tier access system)
3. **Create Community Screen** - Create new communities with categories
4. **Community Management Screen** - Manage members and approval requests (accessed via Profile)

### Must-Have Features
- **Basic Community Management**
  - Create, read, update, delete communities
  - Category-based organization
  - Basic media upload (community cover images)
  - List/grid view toggle
  - Search functionality

- **2-Tier Access System** (Core Feature)
  - **Public View**: Basic info (title, description, cover image) + join request button
  - **Member View**: Full access to posts, comments, and community features
  
- **Approval-Based Membership**
  - Join request system
  - Creator approval/rejection workflow
  - Member management tools

- **App Store Compliance** (Mandatory for store approval)
  - Report inappropriate communities
  - Block communities functionality
  - Content moderation tools

### Core Domain Structure
Following the project's architecture rules:
```
lib/domain/community/
├── entities/
│   ├── community_entity.dart          # Core community entity
│   ├── membership_entity.dart         # Membership requests/status
│   └── report_entity.dart             # For moderation
├── functions/
│   ├── create_community.dart
│   ├── fetch_communities.dart
│   ├── search_communities.dart
│   ├── join_community.dart            # Request to join
│   ├── approve_member.dart            # Approve/reject requests
│   ├── update_community.dart
│   ├── delete_community.dart
│   └── report_community.dart          # Required for App Store
└── presentation/
    ├── screens/
    │   ├── community_list_screen.dart
    │   ├── community_detail_screen.dart
    │   ├── create_community_screen.dart
    │   └── community_management_screen.dart
    └── widgets/
        ├── community_card.dart
        ├── membership_request_widget.dart
        └── community_form.dart
```

### Basic Entity Structure
```dart
// Core community entity
class CommunityEntity {
  final String id;
  final String title;
  final String description;
  final String creatorId;
  final String category;
  final String? coverImageUrl;
  final bool isPrivate;
  final bool isActive;
  final bool isReported;
  final int memberCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  // Additional fields added based on customization needs
}

// Membership management entity
class MembershipEntity {
  final String id;
  final String communityId;
  final String userId;
  final MembershipStatus status; // pending, approved, rejected
  final MembershipRole role;     // creator, moderator, member
  final DateTime requestedAt;
  final DateTime? approvedAt;
}
```

## Integration with Post Domain
Once a user becomes an approved member of a community, they gain access to the full post functionality within that community context:

- **Post Creation**: Members can create posts within the community
- **Comments**: Full commenting system on community posts
- **Content Management**: Same CRUD operations as general posts
- **Feed**: Community-specific post feed for members only

## Profile Integration
The Profile screen must include a "My Communities" widget for community creators:

### Profile Widget: My Created Communities
- List of communities created by the user
- Each item shows community name, member count, pending requests count
- Clicking opens Community Management Screen with:
  - Member list and roles
  - Pending join requests (approve/reject)
  - Community settings and moderation tools

## Customizable Features (App-Specific - Choose Based on Use Case)

### Community Enhancement Customizations
- **Advanced Categorization**
  - Nested category structures
  - Tag-based organization
  - Interest matching algorithms
  - Trending categories

- **Privacy & Access Control**
  - Public vs private communities
  - Invitation-only communities
  - Member role hierarchies (creator, moderator, member)
  - Content visibility settings

### Social Features Customizations
- **Community Interaction**
  - Community rating/review system
  - Follow communities without joining
  - Community recommendations
  - Cross-community connections

- **Engagement Features**
  - Event creation within communities
  - Polls and surveys
  - Community announcements
  - Pinned posts system

### Content Management Customizations
- **Advanced Moderation**
  - Automated content filtering
  - Community-specific rules
  - Moderator delegation
  - Content approval workflows

- **Content Organization**
  - Post categories within communities
  - Content archiving
  - Featured content system
  - Resource libraries

### Location-Based Customizations
- **Geographic Features**
  - Location-based community discovery
  - Local community recommendations
  - Geographic boundaries for communities
  - Event location integration

### Notification System Customizations
- **Community Notifications**
  - New member approval alerts
  - Community activity summaries
  - Custom notification preferences
  - Community-specific notification channels

## UI/UX Guidelines

### Design System Integration
- **Colors**: Use AppColors and AppHSLColors throughout
- **Spacing**: Apply AppSpacing tokens for consistent layout
- **Components**: Leverage AppCard, AppButtons, and existing widgets
- **Typography**: Follow AppTypography for text hierarchy

### Basic Screen Layouts
Following the UI guidelines from `/docs/ui_guideline.md`:

#### Core Layout Pattern
```
+---------------------+
|      Header         | (Search, Filter, Create)
+---------------------+
|   [Categories]      | (Horizontal scrollable categories)
+---------------------+
|                     |
|  Community Grid     | (Main content area)
|                     |
|                     |
+---------------------+
```

#### Community Card Structure
```
+---------------------+
|   Cover Image       | (Community visual)
+---------------------+
| Title               |
| Category * Members  |
| Description...      |
|     [Join] [...]    | (Action buttons)
+---------------------+
```

#### 2-Tier Detail View
```
// Non-member view
+---------------------+
|   Cover Image       |
|   Title & Info      |
|   Description       |
|   [Request to Join] |
+---------------------+

// Member view
+---------------------+
|   Cover Image       |
|   Title & Info      |
|   [Create Post]     |
+---------------------+
|   Community Posts   |
|   (Post Feed)       |
+---------------------+
```

## Implementation Strategy

### Step 1: Core Implementation
1. Create basic domain structure with community and membership entities
2. Implement core CRUD operations for communities
3. Build essential screens with 2-tier access system
4. Add required reporting/blocking features
5. Implement approval workflow

### Step 2: Post Domain Integration
1. Extend post functionality to work within community context
2. Add community-specific post filtering
3. Implement community-only post visibility
4. Create community post feed

### Step 3: Profile Integration
1. Add "My Communities" widget to profile screen
2. Implement community management screen
3. Add approval/rejection functionality
4. Create member management tools

### Step 4: Customization Layer
1. Identify specific app requirements
2. Extend entities with custom fields
3. Add custom functions for specific features
4. Enhance UI with app-specific components

### Required Integrations (All Apps)
- **Authentication System**: User management and access control
- **Post Domain**: Content creation and management within communities
- **User Profile System**: Creator community management
- **File Upload System**: Use existing `/lib/core/image_picker/` for cover images
- **Report/Block System**: For App Store compliance

### Optional Integrations (Choose Based on Need)
- **Location Services**: Geographic community features
- **Push Notifications**: Community activity alerts
- **Analytics**: Community engagement tracking
- **Search System**: Advanced community discovery

## Customization Examples

### Interest-Based Communities
```dart
class InterestCommunityEntity extends CommunityEntity {
  final List<String> interests;
  final String difficultyLevel;
  final bool allowsBeginners;
  final List<String> relatedSkills;
  // + learning resources, skill verification, etc.
}
```

### Local Communities
```dart
class LocalCommunityEntity extends CommunityEntity {
  final double latitude;
  final double longitude;
  final double radiusKm;
  final String address;
  final bool requiresLocationVerification;
  // + local events, meetup scheduling, etc.
}
```

### Professional Communities
```dart
class ProfessionalCommunityEntity extends CommunityEntity {
  final String industry;
  final String experienceLevel;
  final bool requiresVerification;
  final List<String> requiredSkills;
  // + career resources, job postings, etc.
}
```

## Implementation Guidelines for AI

### Planning Questions to Ask
1. **What types of communities will users create?**
2. **Should communities be public or require approval?**
3. **Do communities need geographic boundaries?**
4. **What content can members share within communities?**
5. **How should community creators manage their communities?**

### Development Approach
1. Start with core 2-tier access system and approval workflow
2. Integrate with existing Post domain for content functionality
3. Add Profile integration for community management
4. Implement search and categorization features
5. Add customizations incrementally based on requirements
6. Follow existing project architecture and UI patterns
7. Test approval workflow and member management before adding complex features
8. Ensure App Store compliance features are always included

This flexible approach allows the same community foundation to power diverse social applications while maintaining code quality, user experience standards, and seamless integration with existing post functionality.