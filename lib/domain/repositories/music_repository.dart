import '../entities/track_entity.dart';

abstract class MusicRepository {
  Future<List<TrackEntity>> searchTracks(
    String query, {
    int limit = 20,
    int startIndex = 0,
  });
  Future<List<TrackEntity>> getRecentTracks({int limit = 20});
  Future<List<TrackEntity>> getTrendingTracks({int limit = 20});
  Future<TrackEntity> getTrackById(String id);
  String getStreamUrl(String trackId);
  String getAlbumArtUrl(String trackId);
}
