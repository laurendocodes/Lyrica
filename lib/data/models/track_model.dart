import '../../core/constants/app_constants.dart';
import '../../domain/entities/track_entity.dart';

class JellyfinTrackModel {
  final String id;
  final String name;
  final List<dynamic>? artistItems;
  final String? album;
  final int? runTimeTicks; // 100-nanosecond units
  final int? productionYear;
  final List<dynamic>? genres;
  final bool? userData;

  const JellyfinTrackModel({
    required this.id,
    required this.name,
    this.artistItems,
    this.album,
    this.runTimeTicks,
    this.productionYear,
    this.genres,
    this.userData,
  });

  factory JellyfinTrackModel.fromJson(Map<String, dynamic> json) =>
      JellyfinTrackModel(
        id: json['Id'] ?? '',
        name: json['Name'] ?? 'Unknown Title',
        artistItems: json['ArtistItems'],
        album: json['Album'],
        runTimeTicks: json['RunTimeTicks'],
        productionYear: json['ProductionYear'],
        genres: json['Genres'],
      );

  String get primaryArtist {
    if (artistItems != null && artistItems!.isNotEmpty) {
      return artistItems!.first['Name'] ?? 'Unknown Artist';
    }
    return 'Unknown Artist';
  }

  Duration get duration {
    if (runTimeTicks == null) return Duration.zero;
    // Jellyfin ticks are 100-nanosecond units
    return Duration(microseconds: runTimeTicks! ~/ 10);
  }

  String get streamUrl =>
      '${AppConstants.jellyfinBaseUrl}/Audio/$id/stream?static=true&api_key=${AppConstants.jellyfinApiKey}';

  String get albumArtUrl =>
      '${AppConstants.jellyfinBaseUrl}/Items/$id/Images/Primary?api_key=${AppConstants.jellyfinApiKey}&fillWidth=512&quality=90';

  TrackEntity toEntity() => TrackEntity(
    id: id,
    title: name,
    artist: primaryArtist,
    album: album,
    albumArtUrl: albumArtUrl,
    streamUrl: streamUrl,
    duration: duration,
    year: productionYear,
    genre: genres?.isNotEmpty == true ? genres!.first.toString() : null,
  );
}

class LrcLibSearchResult {
  final int? id;
  final String? trackName;
  final String? artistName;
  final String? albumName;
  final double? duration;
  final String? plainLyrics;
  final String? syncedLyrics;

  const LrcLibSearchResult({
    this.id,
    this.trackName,
    this.artistName,
    this.albumName,
    this.duration,
    this.plainLyrics,
    this.syncedLyrics,
  });

  factory LrcLibSearchResult.fromJson(Map<String, dynamic> json) =>
      LrcLibSearchResult(
        id: json['id'],
        trackName: json['trackName'],
        artistName: json['artistName'],
        albumName: json['albumName'],
        duration: json['duration']?.toDouble(),
        plainLyrics: json['plainLyrics'],
        syncedLyrics: json['syncedLyrics'],
      );

  bool get hasSyncedLyrics => syncedLyrics != null && syncedLyrics!.isNotEmpty;
  bool get hasPlainLyrics => plainLyrics != null && plainLyrics!.isNotEmpty;
}
