// lib/presentation/home/viewmodel/home_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/track_entity.dart';
import '../../../domain/repositories/music_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final MusicRepository _musicRepository;

  HomeCubit(this._musicRepository) : super(HomeInitial());

  Future<void> loadHome() async {
    emit(HomeLoading());
    try {
      final results = await Future.wait([
        _musicRepository.getRecentTracks(limit: 10),
        _musicRepository.getTrendingTracks(limit: 10),
      ]);
      emit(HomeLoaded(recentTracks: results[0], trendingTracks: results[1]));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }
}
