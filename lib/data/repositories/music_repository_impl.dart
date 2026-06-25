import '../../domain/entities/track_entity.dart';
import '../../domain/repositories/music_repository.dart';
import '../datasources/remote/music_remote_datasource.dart';
import '../../core/constants/app_constants.dart';

class MusicRepositoryImpl implements MusicRepository {
  final MusicRemoteDataSource _remoteDataSource;

  MusicRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<TrackEntity>> searchTracks(
    String query, {
    int limit = 20,
    int startIndex = 0,
  }) async {
    final models = await _remoteDataSource.searchTracks(
      query,
      limit: limit,
      startIndex: startIndex,
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<TrackEntity>> getRecentTracks({int limit = 20}) async {
    final models = await _remoteDataSource.getItems(
      sortBy: 'DateCreated',
      limit: limit,
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<TrackEntity>> getTrendingTracks({int limit = 20}) async {
    final models = await _remoteDataSource.getItems(
      sortBy: 'PlayCount',
      limit: limit,
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<TrackEntity> getTrackById(String id) async {
    final model = await _remoteDataSource.getTrackById(id);
    return model.toEntity();
  }

  @override
  String getStreamUrl(String trackId) =>
      '${AppConstants.jellyfinBaseUrl}/Audio/$trackId/stream?static=true&api_key=${AppConstants.jellyfinApiKey}';

  @override
  String getAlbumArtUrl(String trackId) =>
      '${AppConstants.jellyfinBaseUrl}/Items/$trackId/Images/Primary?api_key=${AppConstants.jellyfinApiKey}&fillWidth=512&quality=90';
}
