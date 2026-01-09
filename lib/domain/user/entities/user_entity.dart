// User entity data model for Firestore operations
//
// 이 파일은 Firestore에서 사용자 정보를 읽고 쓰기 위한 데이터 모델(UserEntity)을 정의합니다.
//
// 사용법:
// 1. Firestore에서 가져온 유저 데이터를 `UserEntity.fromJson(json)`으로 파싱합니다.
// 2. 저장할 데이터를 `UserEntity.toJson()`으로 변환합니다.
// 3. 유저 정보를 일부만 수정하고 싶을 경우 `copyWith()`를 사용합니다.
//
// 필수 필드:
// - userId
// - firstName
// - lastName
// - email
//
// 선택 필드:
// - role
// - blockedUsers
// - blockedPosts
// - createdAt
// - updatedAt
// - bio
// - profileImageUrl
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'role.dart';

// 사용자 데이터 모델 클래스
class UserEntity {
  // 필수 필드
  final String userId;
  final String firstName;
  final String lastName;
  final String email;

  // 선택 필드
  final Role? role;
  final String? bio;
  final String? imageUrl;
  final String? nickname;
  final List<String> blockedUsers;
  final List<String> blockedPosts;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? fcmToken;
  final String? authProvider; // 'email', 'google', 'apple', etc.
  final bool adminblocked;

  // 생성자
  UserEntity({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.role,
    this.bio,
    this.imageUrl,
    this.nickname,
    this.blockedUsers = const [],
    this.blockedPosts = const [],
    required this.createdAt,
    required this.updatedAt,
    this.fcmToken,
    this.authProvider,
    this.adminblocked = false,
  });

  // Firestore 문서 → UserEntity 객체 변환
  factory UserEntity.fromJson(Map<String, dynamic> json) {
    final roleValue = json['role'];
    return UserEntity(
      userId: json['userId'] ?? '',
      firstName:
          json['firstName'] ?? json['userName'] ?? '', // Backward compatibility
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      role: roleValue != null
          ? Role.values.firstWhere(
              (e) => e.name == roleValue,
              orElse: () => Role.user,
            )
          : null,
      bio: json['bio'],
      imageUrl: json['imageUrl'],
      nickname: json['nickname'],
      blockedUsers: List<String>.from(json['blockedUsers'] ?? []),
      blockedPosts: List<String>.from(json['blockedPosts'] ?? []),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fcmToken: json['fcmToken'],
      authProvider: json['authProvider'],
      adminblocked: json['adminblocked'] ?? false,
    );
  }

  // UserEntity 객체 → Firestore 문서로 변환
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      if (role != null) 'role': role!.name,
      if (bio != null) 'bio': bio,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (nickname != null) 'nickname': nickname,
      'blockedUsers': blockedUsers,
      'blockedPosts': blockedPosts,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (fcmToken != null) 'fcmToken': fcmToken,
      if (authProvider != null) 'authProvider': authProvider,
      'adminblocked': adminblocked,
    };
  }

  // 편의 메서드: 전체 이름 반환
  String get fullName => '$firstName $lastName'.trim();

  // 일부 필드만 수정된 새로운 UserEntity 객체 생성
  UserEntity copyWith({
    String? userId,
    String? firstName,
    String? lastName,
    String? email,
    Role? role,
    String? bio,
    String? imageUrl,
    String? nickname,
    List<String>? blockedUsers,
    List<String>? blockedPosts,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? fcmToken,
    String? authProvider,
    bool? adminblocked,
  }) {
    return UserEntity(
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      role: role ?? this.role,
      bio: bio ?? this.bio,
      imageUrl: imageUrl ?? this.imageUrl,
      nickname: nickname ?? this.nickname,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      blockedPosts: blockedPosts ?? this.blockedPosts,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fcmToken: fcmToken ?? this.fcmToken,
      authProvider: authProvider ?? this.authProvider,
      adminblocked: adminblocked ?? this.adminblocked,
    );
  }

  // 동일성 비교 연산자 오버라이드
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          email == other.email &&
          role == other.role &&
          bio == other.bio &&
          imageUrl == other.imageUrl &&
          listEquals(blockedUsers, other.blockedUsers) &&
          listEquals(blockedPosts, other.blockedPosts) &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          fcmToken == other.fcmToken &&
          authProvider == other.authProvider &&
          adminblocked == other.adminblocked;

  @override
  int get hashCode => Object.hash(
    userId,
    firstName,
    lastName,
    email,
    role,
    bio,
    imageUrl,
    Object.hashAll(blockedUsers),
    Object.hashAll(blockedPosts),
    createdAt,
    updatedAt,
    fcmToken,
    authProvider,
    adminblocked,
  );
}
