part of 'player_cubit.dart';

enum PlayerRepeatMode { none, one, all }

extension PlayerRepeatModeExtension on PlayerRepeatMode {
  audio_service.AudioServiceRepeatMode toAudioServiceRepeatMode() {
    switch (this) {
      case PlayerRepeatMode.none:
        return audio_service.AudioServiceRepeatMode.none;
      case PlayerRepeatMode.one:
        return audio_service.AudioServiceRepeatMode.one;
      case PlayerRepeatMode.all:
        return audio_service.AudioServiceRepeatMode.all;
    }
  }
}

class PlayerState extends Equatable {
  final TrackEntity? currentTrack;
  final List<TrackEntity> queue;
  final int currentIndex;
  final bool isPlaying;
  final bool isLoading;
  final Duration position;
  final PlayerRepeatMode repeatMode;
  final bool isShuffle;
  final double speed;

  const PlayerState({
    this.currentTrack,
    this.queue = const [],
    this.currentIndex = 0,
    this.isPlaying = false,
    this.isLoading = false,
    this.position = Duration.zero,
    this.repeatMode = PlayerRepeatMode.none,
    this.isShuffle = false,
    this.speed = 1.0,
  });

  PlayerState copyWith({
    TrackEntity? currentTrack,
    List<TrackEntity>? queue,
    int? currentIndex,
    bool? isPlaying,
    bool? isLoading,
    Duration? position,
    PlayerRepeatMode? repeatMode,
    bool? isShuffle,
    double? speed,
  }) => PlayerState(
    currentTrack: currentTrack ?? this.currentTrack,
    queue: queue ?? this.queue,
    currentIndex: currentIndex ?? this.currentIndex,
    isPlaying: isPlaying ?? this.isPlaying,
    isLoading: isLoading ?? this.isLoading,
    position: position ?? this.position,
    repeatMode: repeatMode ?? this.repeatMode,
    isShuffle: isShuffle ?? this.isShuffle,
    speed: speed ?? this.speed,
  );

  double get progress {
    if (currentTrack == null) return 0;
    final total = currentTrack!.duration.inMilliseconds;
    if (total == 0) return 0;
    return (position.inMilliseconds / total).clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => [
    currentTrack,
    currentIndex,
    isPlaying,
    isLoading,
    position,
    repeatMode,
    isShuffle,
    speed,
  ];
}
