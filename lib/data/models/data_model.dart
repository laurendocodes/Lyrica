import '../../domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String username;
  final String email;
  final String? avatar;
  final int followersCount;
  final int followingCount;
  final bool isFollowing;
  final String createdAt;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.avatar,
    this.followersCount = 0,
    this.followingCount = 0,
    this.isFollowing = false,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id']?.toString() ?? '',
    username: json['username'] ?? '',
    email: json['email'] ?? '',
    avatar: json['avatar'],
    followersCount: json['followersCount'] ?? 0,
    followingCount: json['followingCount'] ?? 0,
    isFollowing: json['isFollowing'] ?? false,
    createdAt: json['createdAt'] ?? DateTime.now().toIso8601String(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'avatar': avatar,
    'followersCount': followersCount,
    'followingCount': followingCount,
    'isFollowing': isFollowing,
    'createdAt': createdAt,
  };

  UserEntity toEntity() => UserEntity(
    id: id,
    username: username,
    email: email,
    avatarUrl: avatar,
    followersCount: followersCount,
    followingCount: followingCount,
    isFollowing: isFollowing,
    createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
  );
}
