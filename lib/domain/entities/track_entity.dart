// lib/domain/entities/track_entity.dart
import 'package:equatable/equatable.dart';

class TrackEntity extends Equatable {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final String? albumArtUrl;
  final String streamUrl;
  final Duration duration;
  final int? year;
  final String? genre;
  final bool isFavorite;
  final DateTime? addedAt;

  const TrackEntity({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.albumArtUrl,
    required this.streamUrl,
    required this.duration,
    this.year,
    this.genre,
    this.isFavorite = false,
    this.addedAt,
  });

  TrackEntity copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? albumArtUrl,
    String? streamUrl,
    Duration? duration,
    int? year,
    String? genre,
    bool? isFavorite,
    DateTime? addedAt,
  }) => TrackEntity(
    id: id ?? this.id,
    title: title ?? this.title,
    artist: artist ?? this.artist,
    album: album ?? this.album,
    albumArtUrl: albumArtUrl ?? this.albumArtUrl,
    streamUrl: streamUrl ?? this.streamUrl,
    duration: duration ?? this.duration,
    year: year ?? this.year,
    genre: genre ?? this.genre,
    isFavorite: isFavorite ?? this.isFavorite,
    addedAt: addedAt ?? this.addedAt,
  );

  String get durationFormatted {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [id, title, artist, album, isFavorite];
}
