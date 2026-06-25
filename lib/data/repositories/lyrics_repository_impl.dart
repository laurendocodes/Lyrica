import '../../domain/entities/playlist_entity.dart';
import '../../domain/repositories/lyrics_repository.dart';
import '../datasources/remote/music_remote_datasource.dart';

class LyricsRepositoryImpl implements LyricsRepository {
  final LyricsRemoteDataSource _remoteDataSource;

  LyricsRepositoryImpl(this._remoteDataSource);

  @override
  Future<LyricsEntity> getLyrics({
    required String trackTitle,
    required String artist,
    String? album,
    Duration? duration,
  }) async {
    final result = await _remoteDataSource.searchLyrics(
      trackTitle: trackTitle,
      artist: artist,
      album: album,
      duration: duration?.inSeconds.toDouble(),
    );

    if (result == null) {
      return LyricsEntity(
        trackId: '',
        trackTitle: trackTitle,
        artist: artist,
        lines: [],
        isSynced: false,
      );
    }

    if (result.hasSyncedLyrics) {
      return LyricsEntity(
        trackId: result.id?.toString() ?? '',
        trackTitle: trackTitle,
        artist: artist,
        lines: _parseLrc(result.syncedLyrics!),
        isSynced: true,
      );
    }

    if (result.hasPlainLyrics) {
      final lines = result.plainLyrics!
          .split('\n')
          .where((l) => l.trim().isNotEmpty)
          .map((l) => LyricLineEntity(timestamp: Duration.zero, text: l.trim()))
          .toList();
      return LyricsEntity(
        trackId: result.id?.toString() ?? '',
        trackTitle: trackTitle,
        artist: artist,
        lines: lines,
        isSynced: false,
      );
    }

    return LyricsEntity(
      trackId: '',
      trackTitle: trackTitle,
      artist: artist,
      lines: [],
      isSynced: false,
    );
  }

  /// Parses LRC format: [mm:ss.xx] lyric line
  List<LyricLineEntity> _parseLrc(String lrc) {
    final lines = <LyricLineEntity>[];
    final lineRegex = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2,3})\](.*)');

    for (final rawLine in lrc.split('\n')) {
      final match = lineRegex.firstMatch(rawLine.trim());
      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        final centiseconds = int.parse(match.group(3)!.padRight(3, '0'));
        final text = match.group(4)!.trim();

        if (text.isEmpty) continue;

        final timestamp = Duration(
          minutes: minutes,
          seconds: seconds,
          milliseconds: centiseconds,
        );

        lines.add(LyricLineEntity(timestamp: timestamp, text: text));
      }
    }

    lines.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return lines;
  }
}
