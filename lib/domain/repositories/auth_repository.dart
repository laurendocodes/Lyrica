import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<String> login({required String email, required String password});
  Future<UserEntity> signup({
    required String username,
    required String email,
    required String password,
  });
  Future<UserEntity> getCurrentUser();
  Future<void> logout();
  Future<String?> getStoredToken();
  bool get isAuthenticated;
}
