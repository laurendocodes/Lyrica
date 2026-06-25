// lib/presentation/search/viewmodel/search_cubit.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/track_entity.dart';
import '../../../domain/repositories/music_repository.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final MusicRepository _musicRepository;
  Timer? _debounce;

  SearchCubit(this._musicRepository) : super(SearchInitial());

  void onQueryChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      emit(SearchInitial());
      return;
    }
    emit(SearchLoading());
    _debounce = Timer(const Duration(milliseconds: 400), () {
      search(query);
    });
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      emit(SearchInitial());
      return;
    }
    emit(SearchLoading());
    try {
      final results = await _musicRepository.searchTracks(query);
      emit(SearchLoaded(results: results, query: query));
    } catch (e) {
      emit(SearchError(message: e.toString()));
    }
  }

  void clear() {
    _debounce?.cancel();
    emit(SearchInitial());
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
