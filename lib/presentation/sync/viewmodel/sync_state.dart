part of 'sync_cubit.dart';

abstract class SyncState extends Equatable {
  const SyncState();
  @override
  List<Object?> get props => [];
}

class SyncDisconnected extends SyncState {}

class SyncConnected extends SyncState {
  final String roomId;
  final bool isHost;
  final int participantCount;

  const SyncConnected({
    required this.roomId,
    required this.isHost,
    required this.participantCount,
  });

  SyncConnected copyWith({
    String? roomId,
    bool? isHost,
    int? participantCount,
  }) => SyncConnected(
    roomId: roomId ?? this.roomId,
    isHost: isHost ?? this.isHost,
    participantCount: participantCount ?? this.participantCount,
  );

  @override
  List<Object?> get props => [roomId, isHost, participantCount];
}
