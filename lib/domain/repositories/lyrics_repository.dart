import '../entities/playlist_entity.dart';

abstract class LyricsRepository {
  Future<LyricsEntity> getLyrics({
    required String trackTitle,
    required String artist,
    String? album,
    Duration? duration,
  });
}
