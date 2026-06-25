// lib/domain/entities/user_entity.dart
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final int followersCount;
  final int followingCount;
  final bool isFollowing;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    this.followersCount = 0,
    this.followingCount = 0,
    this.isFollowing = false,
    required this.createdAt,
  });

  UserEntity copyWith({
    String? id,
    String? username,
    String? email,
    String? avatarUrl,
    int? followersCount,
    int? followingCount,
    bool? isFollowing,
    DateTime? createdAt,
  }) => UserEntity(
    id: id ?? this.id,
    username: username ?? this.username,
    email: email ?? this.email,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    followersCount: followersCount ?? this.followersCount,
    followingCount: followingCount ?? this.followingCount,
    isFollowing: isFollowing ?? this.isFollowing,
    createdAt: createdAt ?? this.createdAt,
  );

  @override
  List<Object?> get props => [
    id,
    username,
    email,
    avatarUrl,
    followersCount,
    followingCount,
    isFollowing,
  ];
}
