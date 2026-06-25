// lib/presentation/home/viewmodel/home_state.dart
part of 'home_cubit.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeError extends HomeState {
  final String message;
  const HomeError({required this.message});
  @override
  List<Object?> get props => [message];
}

class HomeLoaded extends HomeState {
  final List<TrackEntity> recentTracks;
  final List<TrackEntity> trendingTracks;

  const HomeLoaded({required this.recentTracks, required this.trendingTracks});

  @override
  List<Object?> get props => [recentTracks, trendingTracks];
}
