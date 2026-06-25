// lib/core/constants/app_constants.dart

class AppConstants {
  AppConstants._();

  // NestJS Backend
  static const String nestBaseUrl = 'http://localhost:3000/api/v1';

  // Jellyfin
  static const String jellyfinBaseUrl = 'http://localhost:8096';
  static const String jellyfinApiKey = 'e016722f52bb45b6bd3b2f72aae5dcaf';
  static const String jellyfinUserId = 'de5b730e50654d93a4f40001eb2dc4a2';

  // LRCLIB
  static const String lrclibBaseUrl = 'https://lrclib.net';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';

  // Audio
  static const int crossfadeDuration = 500;
  static const double defaultVolume = 1.0;
  static const double defaultSpeed = 1.0;

  // Pagination
  static const int pageSize = 20;

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Socket events
  static const String socketJoinRoom = 'join_room';
  static const String socketLeaveRoom = 'leave_room';
  static const String socketSyncPlay = 'sync_play';
  static const String socketSyncPause = 'sync_pause';
  static const String socketSyncSeek = 'sync_seek';
  static const String socketSyncTrack = 'sync_track';
  static const String socketRoomState = 'room_state';
  static const String socketUserJoined = 'user_joined';
  static const String socketUserLeft = 'user_left';
}
