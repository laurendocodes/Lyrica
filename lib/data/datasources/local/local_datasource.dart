import 'dart:convert';
import 'package:lyrica_flutter/data/models/data_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';

abstract class LocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clearAll();
}

class LocalDataSourceImpl implements LocalDataSource {
  final SharedPreferences _prefs;

  LocalDataSourceImpl(this._prefs);

  @override
  Future<void> saveToken(String token) async {
    await _prefs.setString(AppConstants.accessTokenKey, token);
  }

  @override
  Future<String?> getToken() async {
    return _prefs.getString(AppConstants.accessTokenKey);
  }

  @override
  Future<void> clearToken() async {
    await _prefs.remove(AppConstants.accessTokenKey);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await _prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
  }

  @override
  Future<UserModel?> getUser() async {
    final userJson = _prefs.getString(AppConstants.userKey);
    if (userJson == null) return null;
    return UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
  }

  @override
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
