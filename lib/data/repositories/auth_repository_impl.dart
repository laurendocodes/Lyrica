import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/local_datasource.dart';
import '../datasources/remote/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final LocalDataSource _localDataSource;

  String? _cachedToken;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required LocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  @override
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final token = await _remoteDataSource.login(
      email: email,
      password: password,
    );
    await _localDataSource.saveToken(token);
    _cachedToken = token;
    return token;
  }

  @override
  Future<UserEntity> signup({
    required String username,
    required String email,
    required String password,
  }) async {
    final userModel = await _remoteDataSource.signup(
      name: username,
      email: email,
      password: password,
    );
    await _localDataSource.saveUser(userModel);
    return userModel.toEntity();
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    final userModel = await _remoteDataSource.getCurrentUser();
    await _localDataSource.saveUser(userModel);
    return userModel.toEntity();
  }

  @override
  Future<void> logout() async {
    _cachedToken = null;
    await _localDataSource.clearAll();
  }

  @override
  Future<String?> getStoredToken() async {
    _cachedToken ??= await _localDataSource.getToken();
    return _cachedToken;
  }

  @override
  bool get isAuthenticated => _cachedToken != null;
}
