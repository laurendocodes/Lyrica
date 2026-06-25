import 'package:lyrica_flutter/domain/entities/user_entity.dart';

abstract class SocialRepository {
  Future<void> followUser(String userId);
  Future<void> unfollowUser(String userId);
  Future<List<UserEntity>> getFollowers(String userId);
  Future<List<UserEntity>> getFollowing(String userId);
  Future<UserEntity> getUserProfile(String userId);
}
