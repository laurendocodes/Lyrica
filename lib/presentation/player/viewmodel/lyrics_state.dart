// lib/presentation/player/viewmodel/lyrics_state.dart
part of 'lyrics_cubit.dart';

abstract class LyricsState extends Equatable {
  const LyricsState();
  @override
  List<Object?> get props => [];
}

class LyricsInitial extends LyricsState {}

class LyricsLoading extends LyricsState {}

class LyricsNotFound extends LyricsState {}

class LyricsError extends LyricsState {}

class LyricsLoaded extends LyricsState {
  final LyricsEntity lyrics;
  const LyricsLoaded({required this.lyrics});

  @override
  List<Object?> get props => [lyrics.trackId];
}
