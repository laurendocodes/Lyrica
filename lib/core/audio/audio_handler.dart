import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../../domain/entities/track_entity.dart';

class LyricaAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  List<TrackEntity> _queue = [];
  int _currentIndex = 0;

  LyricaAudioHandler() {
    _init();
  }

  void _init() {
    // Forward player state to audio_service
    _player.playbackEventStream.listen(_broadcastState);
    _player.durationStream.listen((duration) {
      final current = mediaItem.value;
      if (current != null && duration != null) {
        mediaItem.add(current.copyWith(duration: duration));
      }
    });

    // Auto-advance queue
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        skipToNext();
      }
    });
  }

  Future<void> playTrack(
    TrackEntity track, {
    List<TrackEntity>? queue,
    int index = 0,
  }) async {
    if (queue != null) {
      _queue = queue;
      _currentIndex = index;
    } else {
      _queue = [track];
      _currentIndex = 0;
    }

    final item = _trackToMediaItem(track);
    mediaItem.add(item);

    await _player.setAudioSource(AudioSource.uri(Uri.parse(track.streamUrl)));
    await _player.play();
  }

  Future<void> playFromQueue(int index) async {
    if (index < 0 || index >= _queue.length) return;
    _currentIndex = index;
    final track = _queue[index];
    final item = _trackToMediaItem(track);
    mediaItem.add(item);
    await _player.setAudioSource(AudioSource.uri(Uri.parse(track.streamUrl)));
    await _player.play();
  }

  void setQueue(List<TrackEntity> tracks, {int startIndex = 0}) {
    _queue = tracks;
    _currentIndex = startIndex;
    final items = tracks.map(_trackToMediaItem).toList();
    queue.add(items);
  }

  TrackEntity? get currentTrack =>
      _queue.isNotEmpty && _currentIndex < _queue.length
      ? _queue[_currentIndex]
      : null;

  List<TrackEntity> get trackQueue => List.unmodifiable(_queue);
  int get currentIndex => _currentIndex;

  // Expose player stream
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<double> get speedStream => _player.speedStream;
  Stream<double> get volumeStream => _player.volumeStream;
  Duration get position => _player.position;
  Duration? get duration => _player.duration;
  bool get isPlaying => _player.playing;

  Future<void> setSpeed(double speed) => _player.setSpeed(speed);
  Future<void> setVolume(double volume) => _player.setVolume(volume);

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    if (_currentIndex < _queue.length - 1) {
      await playFromQueue(_currentIndex + 1);
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_player.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
    } else if (_currentIndex > 0) {
      await playFromQueue(_currentIndex - 1);
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    if (shuffleMode == AudioServiceShuffleMode.all) {
      final list = List<TrackEntity>.from(_queue);
      list.shuffle();
      final currentTrack = _queue[_currentIndex];
      _queue = [currentTrack, ...list.where((t) => t.id != currentTrack.id)];
      _currentIndex = 0;
      queue.add(_queue.map(_trackToMediaItem).toList());
    }
    await super.setShuffleMode(shuffleMode);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        await _player.setLoopMode(LoopMode.off);
        break;
      case AudioServiceRepeatMode.one:
        await _player.setLoopMode(LoopMode.one);
        break;
      case AudioServiceRepeatMode.all:
        await _player.setLoopMode(LoopMode.all);
        break;
      default:
        break;
    }
    await super.setRepeatMode(repeatMode);
  }

  void _broadcastState(PlaybackEvent event) {
    final isPlaying = _player.playing;
    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (isPlaying) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: isPlaying,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: _currentIndex,
      ),
    );
  }

  MediaItem _trackToMediaItem(TrackEntity track) => MediaItem(
    id: track.id,
    title: track.title,
    artist: track.artist,
    album: track.album,
    duration: track.duration,
    artUri: track.albumArtUrl != null ? Uri.parse(track.albumArtUrl!) : null,
  );

  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    switch (name) {
      case 'syncSeek':
        if (extras?['position'] != null) {
          await seek(Duration(milliseconds: extras!['position'] as int));
        }
        break;
      case 'syncPlay':
        await play();
        break;
      case 'syncPause':
        await pause();
        break;
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
