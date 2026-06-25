// lib/presentation/profile/viewmodel/profile_state.dart
part of 'profile_cubit.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError({required this.message});
  @override
  List<Object?> get props => [message];
}

class ProfileLoaded extends ProfileState {
  final UserEntity user;
  const ProfileLoaded({required this.user});
  @override
  List<Object?> get props => [user];
}
