import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/audio/audio_handler.dart';
import '../../../core/network/socket_service.dart';
import '../../../domain/entities/track_entity.dart';
import 'package:audio_service/audio_service.dart' as audio_service;
part 'player_state.dart';

class PlayerCubit extends Cubit<PlayerState> {
  final LyricaAudioHandler _audioHandler;
  final SocketService _socketService;

  StreamSubscription? _positionSub;
  StreamSubscription? _playbackSub;

  String? _activeSyncRoomId;

  PlayerCubit({
    required LyricaAudioHandler audioHandler,
    required SocketService socketService,
  }) : _audioHandler = audioHandler,
       _socketService = socketService,
       super(const PlayerState()) {
    _init();
  }
  Future<void> playTrackAt(int index) async {
    if (index < 0 || index >= state.queue.length) return;

    final track = state.queue[index];

    await playTrack(track, queue: state.queue, queueIndex: index);
  }

  void _init() {
    _positionSub = _audioHandler.positionStream.listen((position) {
      emit(state.copyWith(position: position));
    });

    _playbackSub = _audioHandler.playbackState.listen((playbackState) {
      emit(
        state.copyWith(
          isPlaying: playbackState.playing,
          isLoading:
              playbackState.processingState.name == 'loading' ||
              playbackState.processingState.name == 'buffering',
        ),
      );
    });

    _audioHandler.mediaItem.listen((item) {
      if (item == null) return;
      final index = state.queue.indexWhere((t) => t.id == item.id);

      if (index != -1) {
        emit(state.copyWith(currentIndex: index));
      }
      final track = TrackEntity(
        id: item.id,
        title: item.title,
        artist: item.artist ?? '',
        album: item.album ?? '',
        duration: item.duration ?? Duration.zero,
        albumArtUrl: item.artUri?.toString(),
        streamUrl: '',
      );

      emit(state.copyWith(currentTrack: track));
    });
  }

  Future<void> playTrack(
    TrackEntity track, {
    List<TrackEntity>? queue,
    int queueIndex = 0,
  }) async {
    emit(
      state.copyWith(
        // currentTrack: track,
        queue: queue ?? [track],
        currentIndex: queueIndex,
        isLoading: true,
      ),
    );

    try {
      await _audioHandler.playTrack(track, queue: queue, index: queueIndex);
      emit(state.copyWith(isPlaying: true, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
    // Sync to room if active
    if (_activeSyncRoomId != null) {
      _socketService.syncTrack(_activeSyncRoomId!, track.id, Duration.zero);
    }
  }

  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await _audioHandler.pause();
      if (_activeSyncRoomId != null) {
        _socketService.syncPause(_activeSyncRoomId!, state.position);
      }
    } else {
      await _audioHandler.play();
      if (_activeSyncRoomId != null) {
        _socketService.syncPlay(_activeSyncRoomId!, state.position);
      }
    }
  }

  Future<void> seek(Duration position) async {
    await _audioHandler.seek(position);
    if (_activeSyncRoomId != null) {
      _socketService.syncSeek(_activeSyncRoomId!, position);
    }
  }

  void _syncFromAudio() {
    final item = _audioHandler.mediaItem.value;
    if (item == null) return;

    emit(
      state.copyWith(
        currentTrack: TrackEntity(
          id: item.id,
          title: item.title,
          artist: item.artist ?? '',
          album: item.album ?? '',
          duration: item.duration ?? Duration.zero,
          albumArtUrl: item.artUri?.toString(),
          streamUrl: '',
        ),
      ),
    );
  }

  Future<void> skipNext() async {
    await _audioHandler.skipToNext();
    _syncFromAudio();
  }

  Future<void> skipPrevious() async {
    await _audioHandler.skipToPrevious();
    _syncFromAudio();
  }

  Future<void> setRepeatMode(PlayerRepeatMode mode) async {
    emit(state.copyWith(repeatMode: mode));
    await _audioHandler.setRepeatMode(mode.toAudioServiceRepeatMode());
  }

  Future<void> toggleShuffle() async {
    final newShuffle = !state.isShuffle;

    emit(state.copyWith(isShuffle: newShuffle));

    await _audioHandler.setShuffleMode(
      newShuffle
          ? audio_service.AudioServiceShuffleMode.all
          : audio_service.AudioServiceShuffleMode.none,
    );
  }

  Future<void> setSpeed(double speed) async {
    await _audioHandler.setSpeed(speed);
    emit(state.copyWith(speed: speed));
  }

  void setActiveSyncRoom(String? roomId) {
    _activeSyncRoomId = roomId;
  }

  Duration? get totalDuration => _audioHandler.duration;

  @override
  Future<void> close() {
    _positionSub?.cancel();
    _playbackSub?.cancel();
    return super.close();
  }
}
