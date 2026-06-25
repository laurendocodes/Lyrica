// lib/presentation/search/viewmodel/search_state.dart
part of 'search_cubit.dart';

abstract class SearchState extends Equatable {
  const SearchState();
  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchError extends SearchState {
  final String message;
  const SearchError({required this.message});
  @override
  List<Object?> get props => [message];
}

class SearchLoaded extends SearchState {
  final List<TrackEntity> results;
  final String query;
  const SearchLoaded({required this.results, required this.query});
  @override
  List<Object?> get props => [results, query];
}
