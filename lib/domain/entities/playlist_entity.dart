// lib/domain/entities/playlist_entity.dart
import 'package:equatable/equatable.dart';
import 'track_entity.dart';

class PlaylistEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? coverUrl;
  final List<TrackEntity> tracks;
  final String ownerId;
  final bool isPublic;
  final DateTime createdAt;

  const PlaylistEntity({
    required this.id,
    required this.name,
    this.description,
    this.coverUrl,
    this.tracks = const [],
    required this.ownerId,
    this.isPublic = false,
    required this.createdAt,
  });

  int get trackCount => tracks.length;

  Duration get totalDuration =>
      tracks.fold(Duration.zero, (sum, track) => sum + track.duration);

  @override
  List<Object?> get props => [id, name, ownerId, tracks.length];
}

// lib/domain/entities/lyric_line_entity.dart
class LyricLineEntity {
  final Duration timestamp;
  final String text;

  const LyricLineEntity({required this.timestamp, required this.text});
}

class LyricsEntity {
  final String trackId;
  final String trackTitle;
  final String artist;
  final List<LyricLineEntity> lines;
  final bool isSynced;

  const LyricsEntity({
    required this.trackId,
    required this.trackTitle,
    required this.artist,
    required this.lines,
    this.isSynced = true,
  });

  bool get isEmpty => lines.isEmpty;
}

// lib/domain/entities/sync_room_entity.dart
class SyncRoomEntity {
  final String id;
  final String hostId;
  final String hostName;
  final List<String> participantIds;
  final TrackEntity? currentTrack;
  final Duration position;
  final bool isPlaying;
  final DateTime createdAt;

  const SyncRoomEntity({
    required this.id,
    required this.hostId,
    required this.hostName,
    this.participantIds = const [],
    this.currentTrack,
    this.position = Duration.zero,
    this.isPlaying = false,
    required this.createdAt,
  });

  int get participantCount => participantIds.length;
}
