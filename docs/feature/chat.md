# Chat Feature Documentation

## Overview
The chat feature provides a comprehensive real-time messaging system using Firebase as the backend. This system supports both 1-on-1 conversations and group chats, with rich media sharing capabilities, emoji reactions, and advanced read receipt tracking. The feature is fully integrated with user profiles and follows real-time communication patterns.

## Core Features (Essential - Always Required)

### Must-Have Screens
1. **Chat Room List Screen** - Overview of all conversations with unread indicators
2. **Individual Chat Screen** - Real-time messaging interface for 1-on-1 conversations
3. **Group Chat Screen** - Multi-participant messaging interface
4. **Create Chat Screen** - Start new conversations or create group chats
5. **Chat Settings Screen** - Manage chat preferences and participants

### Must-Have Features
- **Real-time Messaging**
  - Instant message delivery and receipt
  - Firebase Realtime Database integration
  - Message status tracking (sent, delivered, read)
  - Offline message queuing

- **Message Types**
  - Text messages with emoji support
  - Image sharing (photos from gallery/camera)
  - Video sharing
  - File attachments
  - Emoji reactions on messages

- **Read Receipt System**
  - Individual message read indicators ("1" for unread)
  - Chat room list unread count (red badge with white numbers)
  - Real-time read status updates

- **User Integration**
  - Profile-based messaging
  - User presence indicators
  - Profile image and name display
  - Contact management integration

---

### Core Domain Structure
Following the project's architecture rules:
```
lib/domain/chat/
├── entities/
│   ├── chat_room_entity.dart      # Chat room/conversation
│   ├── message_entity.dart        # Individual messages
│   ├── participant_entity.dart    # Chat participants
│   └── read_receipt_entity.dart   # Read status tracking
├── functions/
│   ├── create_chat_room.dart
│   ├── send_message.dart
│   ├── fetch_messages.dart
│   ├── mark_as_read.dart
│   ├── add_reaction.dart
│   └── manage_participants.dart
└── presentation/
    ├── screens/
    │   ├── chat_room_list_screen.dart
    │   ├── individual_chat_screen.dart
    │   ├── group_chat_screen.dart
    │   └── create_chat_screen.dart
    └── widgets/
        ├── message_bubble.dart
        ├── chat_input_field.dart
        ├── media_message.dart
        ├── emoji_reactions.dart
        └── unread_indicator.dart
```

### Core Entity Structures
```dart
// Chat Room Entity
class ChatRoomEntity {
  final String id;
  final String name; // For group chats, null for 1-on-1
  final List<String> participantIds;
  final String lastMessage;
  final String lastMessageSenderId;
  final DateTime lastMessageTime;
  final Map<String, int> unreadCounts; // userId -> unread count
  final bool isGroupChat;
  final String? groupImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
}

// Message Entity
class MessageEntity {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String content;
  final MessageType type; // text, image, video, file
  final String? mediaUrl;
  final Map<String, String> reactions; // userId -> emoji
  final List<String> readBy; // userIds who have read
  final DateTime sentAt;
  final bool isDeleted;
}

// Read Receipt Entity
class ReadReceiptEntity {
  final String messageId;
  final String userId;
  final DateTime readAt;
}
```

## Firebase Integration

### Realtime Database Structure
```json
{
  "chat_rooms": {
    "room_id": {
      "name": "Group Name or null",
      "participants": ["user1", "user2", "user3"],
      "last_message": "Hello there!",
      "last_message_sender": "user1",
      "last_message_time": 1634567890,
      "unread_counts": {
        "user1": 0,
        "user2": 3,
        "user3": 1
      },
      "is_group_chat": true,
      "created_at": 1634567890
    }
  },
  "messages": {
    "room_id": {
      "message_id": {
        "sender_id": "user1",
        "content": "Hello!",
        "type": "text",
        "media_url": null,
        "reactions": {
          "user2": "😍"
        },
        "read_by": ["user1", "user2"],
        "sent_at": 1634567890,
        "is_deleted": false
      }
    }
  },
  "user_presence": {
    "user_id": {
      "is_online": true,
      "last_seen": 1634567890
    }
  }
}
```

## UI/UX Guidelines

### Design System Integration
- **Colors**: Use AppColors, AppHSLColors, and AppCommonColors throughout
  - AppCommonColors: Use for common colors (white, black, grey shades, semantic colors)
  - AppColors and AppHSLColors: Use without specifying exact values (generated files)
- **Spacing**: Apply AppSpacing tokens for consistent layout
- **Components**: Leverage AppCard, AppButtons, and existing widgets
- **Typography**: Follow AppTypography for text hierarchy

### Chat Room List Screen Layout
```
┌─────────────────────────────────┐
│           Chat Rooms            │
│        (Header with search)     │
├─────────────────────────────────┤
│ 👤 John Doe                (3) │
│ "Hey, how are you?"             │
│ 2:30 PM                         │
├─────────────────────────────────┤
│ 👥 Group Chat             (1)  │
│ "Sarah: Sounds good"            │
│ Yesterday                       │
├─────────────────────────────────┤
│ 👤 Jane Smith                  │
│ "Thanks!"                       │
│ Monday                          │
└─────────────────────────────────┘
```

### Individual Chat Screen Layout
```
┌─────────────────────────────────┐
│ ← John Doe              🟢      │
│ (Back, name, online status)     │
├─────────────────────────────────┤
│                                 │
│ 👤 "Hello!"                    │
│    2:30 PM                      │
│                                 │
│                "Hi there!" ✓   │
│                   2:31 PM  1    │
│                                 │
│ 👤 "How are you?"              │
│    2:32 PM                      │
│                                 │
├─────────────────────────────────┤
│ 📷 [Text Input]         😊 ➤   │
│ (Media, input, emoji, send)     │
└─────────────────────────────────┘
```

### Message Bubble Specifications
- **Your messages**: Right-aligned, use AppColors.primary for background
- **Other messages**: Left-aligned, use AppCommonColors.grey100 or similar neutral color
- **Consecutive messages**: Group by sender, show profile image only on first message
- **Time display**: Show minutes (e.g., "2:30 PM") below each message, use AppColors.secondary for text color
- **Read indicators**: 
  - "1" next to your unread messages in chat, use AppCommonColors.red for indicator
  - Disappears when read by recipient
- **Reactions**: Small emoji overlay on bottom-right of message bubble

### Unread Count Indicators
- **Chat Room List**: Use AppCommonColors.red for badge background, AppCommonColors.white for number text (e.g., (3))
- **Individual Messages**: Use AppCommonColors.red for "1" indicator next to timestamp
- **Badge positions**: Top-right of profile images or message areas

## Advanced Features (Customizable)

### Enhanced Messaging
- **Message Search**: Full-text search within conversations
- **Message Threading**: Reply to specific messages
- **Message Forwarding**: Share messages between chats
- **Message Translation**: Multi-language support
- **Voice Messages**: Audio recording and playback
- **Message Scheduling**: Send messages at specific times

### Group Chat Enhancements
- **Admin Controls**: Manage participants, settings
- **Group Permissions**: Control who can send messages/media
- **Group Descriptions**: Add chat purpose and rules
- **Group Invitations**: Share join links
- **Message Pinning**: Highlight important messages

### User Experience Enhancements
- **Message Notifications**: Custom @lib/core/notification/ settings per chat
- **Chat Themes**: Customizable chat appearances
- **Message Backup**: Cloud backup and restore
- **Chat Export**: Export conversation history
- **Typing Indicators**: Show when someone is typing
- **Message Delivery Status**: Detailed delivery confirmation

## Implementation Strategy

### Step 1: Core Chat Infrastructure
1. Set up Firebase Realtime Database structure
2. Create basic domain entities and functions
3. Implement real-time listeners for messages
4. Build basic UI for chat room list and individual chats

### Step 2: Message Features
1. Implement text messaging with real-time updates
2. Add media sharing capabilities
3. Create read receipt tracking system
4. Build emoji reaction functionality

### Step 3: UI Polish
1. Implement message grouping logic
2. Add unread count indicators
3. Create smooth animations and transitions
4. Optimize for performance with large message histories

### Step 4: Advanced Features
1. Add group chat functionality
2. Implement user presence tracking
3. Create chat search and filtering
4. Add notification system integration

### Required Integrations
- **Firebase Realtime Database**: Core messaging infrastructure
- **Firebase Cloud Storage**: Media file storage
- **User Profile System**: Participant information and avatars
- **@lib/core/notification/**: Message alerts
- **@lib/core/image_picker/**: Camera and gallery access

### Optional Integrations
- **Firebase Cloud Functions**: Server-side message processing

## Real-time Implementation Guidelines

### Firebase Listeners
```dart
// Listen to new messages in a chat room
StreamBuilder<List<MessageEntity>>(
  stream: FirebaseDatabase.instance
    .ref('messages/${chatRoomId}')
    .onValue
    .map((event) => _parseMessages(event.snapshot)),
  builder: (context, snapshot) {
    // Update UI with new messages
  },
);

// Update read receipts
await FirebaseDatabase.instance
  .ref('messages/${chatRoomId}/${messageId}/read_by')
  .update({userId: ServerValue.timestamp});
```

### Performance Considerations
- **Message Pagination**: Load messages in chunks (20-50 per load)
- **Image Optimization**: Compress images before upload
- **Offline Support**: Cache recent messages locally
- **Memory Management**: Dispose listeners when screens are inactive

## Implementation Guidelines for AI

### Planning Questions to Ask
1. **What's the maximum group chat size needed?**
2. **Should messages be encrypted end-to-end?**
3. **Do you need message moderation/filtering?**
4. **Should there be chat admin roles and permissions?**
5. **Do you need integration with push notifications?**
6. **Should chat history be persistent or temporary?**

### Development Approach
1. Start with 1-on-1 messaging, then add group functionality
2. Implement core messaging before advanced features
3. Test real-time updates thoroughly across devices
4. Follow Firebase best practices for scalability
5. Ensure offline functionality works smoothly
6. Optimize for battery usage and data consumption

### Testing Strategy
1. Test real-time synchronization across multiple devices
2. Verify read receipt accuracy in various scenarios
3. Test media sharing with different file sizes
4. Validate message ordering and delivery
5. Check performance with large message histories
6. Test offline/online transitions

This comprehensive chat system provides a solid foundation for real-time communication while maintaining flexibility for future enhancements and customizations.