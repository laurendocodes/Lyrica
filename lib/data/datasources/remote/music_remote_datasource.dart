import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../models/track_model.dart';

abstract class MusicRemoteDataSource {
  Future<List<JellyfinTrackModel>> searchTracks(
    String query, {
    int limit = 20,
    int startIndex = 0,
  });
  Future<List<JellyfinTrackModel>> getItems({
    String? sortBy,
    int limit = 20,
    int startIndex = 0,
  });
  Future<JellyfinTrackModel> getTrackById(String id);
}

class MusicRemoteDataSourceImpl implements MusicRemoteDataSource {
  final DioClient _dioClient;

  MusicRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<JellyfinTrackModel>> searchTracks(
    String query, {
    int limit = 20,
    int startIndex = 0,
  }) async {
    try {
      final response = await _dioClient.jellyfinDio.get(
        '/Users/${AppConstants.jellyfinUserId}/Items',
        queryParameters: {
          'searchTerm': query,
          'includeItemTypes': 'Audio',
          'recursive': true,
          'limit': limit,
          'startIndex': startIndex,
          'api_key': AppConstants.jellyfinApiKey,
          'Fields': 'RunTimeTicks,ArtistItems,Album,Genres,ProductionYear',
        },
      );
      final items = response.data['Items'] as List<dynamic>? ?? [];
      return items
          .map(
            (item) => JellyfinTrackModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<JellyfinTrackModel>> getItems({
    String? sortBy,
    int limit = 20,
    int startIndex = 0,
  }) async {
    try {
      final response = await _dioClient.jellyfinDio.get(
        '/Users/${AppConstants.jellyfinUserId}/Items',
        queryParameters: {
          'includeItemTypes': 'Audio',
          'recursive': true,
          'limit': limit,
          'startIndex': startIndex,
          'sortBy': sortBy ?? 'DateCreated',
          'sortOrder': 'Descending',
          'api_key': AppConstants.jellyfinApiKey,
          'Fields': 'RunTimeTicks,ArtistItems,Album,Genres,ProductionYear',
        },
      );
      final items = response.data['Items'] as List<dynamic>? ?? [];
      return items
          .map(
            (item) => JellyfinTrackModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<JellyfinTrackModel> getTrackById(String id) async {
    try {
      final response = await _dioClient.jellyfinDio.get(
        '/Users/${AppConstants.jellyfinUserId}/Items/$id',
        queryParameters: {
          'api_key': AppConstants.jellyfinApiKey,
          'Fields': 'RunTimeTicks,ArtistItems,Album,Genres,ProductionYear',
        },
      );
      return JellyfinTrackModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

// lib/data/datasources/remote/lyrics_remote_datasource.dart
abstract class LyricsRemoteDataSource {
  Future<LrcLibSearchResult?> searchLyrics({
    required String trackTitle,
    required String artist,
    String? album,
    double? duration,
  });
}

class LyricsRemoteDataSourceImpl implements LyricsRemoteDataSource {
  final DioClient _dioClient;

  LyricsRemoteDataSourceImpl(this._dioClient);

  @override
  Future<LrcLibSearchResult?> searchLyrics({
    required String trackTitle,
    required String artist,
    String? album,
    double? duration,
  }) async {
    try {
      final response = await _dioClient.lrclibDio.get(
        '/api/search',
        queryParameters: {
          'track_name': trackTitle,
          'artist_name': artist,
          if (album != null) 'album_name': album,
        },
      );

      final results = response.data as List<dynamic>;
      if (results.isEmpty) return null;

      // Find best match by duration if provided
      if (duration != null && results.length > 1) {
        results.sort((a, b) {
          final aDiff = ((a['duration'] ?? 0.0) - duration).abs();
          final bDiff = ((b['duration'] ?? 0.0) - duration).abs();
          return aDiff.compareTo(bDiff);
        });
      }

      return LrcLibSearchResult.fromJson(results.first as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
