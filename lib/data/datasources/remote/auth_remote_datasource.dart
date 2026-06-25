// lib/data/datasources/remote/auth_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:lyrica_flutter/data/models/data_model.dart';
import '../../../core/network/dio_client.dart';

abstract class AuthRemoteDataSource {
  Future<String> login({required String email, required String password});
  Future<UserModel> signup({
    required String name,
    required String email,
    required String password,
  });
  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl(this._dioClient);

  @override
  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioClient.nestDio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return response.data['access_token'] as String;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<UserModel> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioClient.nestDio.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'role': "USER",
        },
      );
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _dioClient.nestDio.get('/users/profile');
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
