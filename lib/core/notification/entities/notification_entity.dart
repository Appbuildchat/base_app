/// =============================================================================
/// NOTIFICATION ENTITY (알림 엔티티)
/// =============================================================================
///
/// 알림 데이터를 표현하는 엔티티 클래스입니다.
///
/// 주요 속성:
/// 1. 기본 정보: id, senderId, receiverId, title, body
/// 2. 타임스탬프: sentAt, deliveredAt, readAt
/// 3. 상태: isSuccess, isImportant, isRead
/// 4. 추가 데이터: data, imageUrl, redirectUrl, fcmMessageId
/// 5. 분류: notificationType
/// =============================================================================
class NotificationEntity {
  final String id;
  final String? senderId;
  final String receiverId;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final DateTime sentAt;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final bool isSuccess;
  final bool isImportant;
  final String? imageUrl;
  final String? redirectUrl;
  final String? fcmMessageId;

  NotificationEntity({
    required this.id,
    this.senderId,
    required this.receiverId,
    required this.title,
    required this.body,
    Map<String, dynamic>? data,
    required this.sentAt,
    this.deliveredAt,
    this.readAt,
    required this.isSuccess,
    this.isImportant = false,
    this.imageUrl,
    this.redirectUrl,
    this.fcmMessageId,
  }) : data = data ?? {};

  // 엔티티 복사 및 수정
  NotificationEntity copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    DateTime? sentAt,
    DateTime? deliveredAt,
    DateTime? readAt,
    bool? isSuccess,
    bool? isImportant,
    String? imageUrl,
    String? redirectUrl,
    String? fcmMessageId,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      sentAt: sentAt ?? this.sentAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      readAt: readAt ?? this.readAt,
      isSuccess: isSuccess ?? this.isSuccess,
      isImportant: isImportant ?? this.isImportant,
      imageUrl: imageUrl ?? this.imageUrl,
      redirectUrl: redirectUrl ?? this.redirectUrl,
      fcmMessageId: fcmMessageId ?? this.fcmMessageId,
    );
  }

  // 알림이 읽혔는지 확인
  bool get isRead => readAt != null;

  // 알림이 전달되었는지 확인
  bool get isDelivered => deliveredAt != null;

  // 알림이 성공적으로 전송되었는지 확인
  bool get isSuccessful => isSuccess;

  // 알림이 중요도가 높은지 확인
  bool get isHighPriority => isImportant;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          senderId == other.senderId &&
          receiverId == other.receiverId &&
          title == other.title &&
          body == other.body &&
          sentAt == other.sentAt &&
          isSuccess == other.isSuccess;

  @override
  int get hashCode =>
      id.hashCode ^
      senderId.hashCode ^
      receiverId.hashCode ^
      title.hashCode ^
      body.hashCode ^
      sentAt.hashCode ^
      isSuccess.hashCode;

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'title': title,
      'body': body,
      'data': data,
      'sentAt': sentAt.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'isSuccess': isSuccess,
      'isImportant': isImportant,
      'imageUrl': imageUrl,
      'redirectUrl': redirectUrl,
      'fcmMessageId': fcmMessageId,
      'isRead': isRead,
    };
  }

  // JSON 역직렬화
  factory NotificationEntity.fromJson(Map<String, dynamic> json) {
    return NotificationEntity(
      id: json['id'] as String,
      senderId: json['senderId'] as String?,
      receiverId: json['receiverId'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map? ?? {}),
      sentAt: DateTime.parse(json['sentAt'] as String),
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'] as String)
          : null,
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
      isSuccess: json['isSuccess'] as bool,
      isImportant: json['isImportant'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
      redirectUrl: json['redirectUrl'] as String?,
      fcmMessageId: json['fcmMessageId'] as String?,
    );
  }
}
