import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/playlist_entity.dart';
import '../../../domain/entities/track_entity.dart';
import '../../../domain/repositories/lyrics_repository.dart';

part 'lyrics_state.dart';

class LyricsCubit extends Cubit<LyricsState> {
  final LyricsRepository _lyricsRepository;
  String? _lastTrackId;

  LyricsCubit(this._lyricsRepository) : super(LyricsInitial());

  Future<void> loadLyrics(TrackEntity track) async {
    if (_lastTrackId == track.id && state is LyricsLoaded) return;
    _lastTrackId = track.id;

    emit(LyricsLoading());
    try {
      final lyrics = await _lyricsRepository.getLyrics(
        trackTitle: track.title,
        artist: track.artist,
        album: track.album,
        duration: track.duration,
      );

      if (lyrics.isEmpty) {
        emit(LyricsNotFound());
      } else {
        emit(LyricsLoaded(lyrics: lyrics));
      }
    } catch (_) {
      emit(LyricsError());
    }
  }

  int getCurrentLineIndex(Duration position) {
    final current = state;
    if (current is! LyricsLoaded) return -1;
    if (!current.lyrics.isSynced) return -1;

    final lines = current.lyrics.lines;
    int activeIndex = -1;

    for (int i = 0; i < lines.length; i++) {
      if (lines[i].timestamp <= position) {
        activeIndex = i;
      } else {
        break;
      }
    }

    return activeIndex;
  }
}
