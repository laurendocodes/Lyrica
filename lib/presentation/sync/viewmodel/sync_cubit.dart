// lib/presentation/sync/viewmodel/sync_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/audio/audio_handler.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/socket_service.dart';

part 'sync_state.dart';

class SyncCubit extends Cubit<SyncState> {
  final SocketService _socketService;
  final LyricaAudioHandler _audioHandler;

  SyncCubit({
    required SocketService socketService,
    required LyricaAudioHandler audioHandler,
  }) : _socketService = socketService,
       _audioHandler = audioHandler,
       super(SyncDisconnected());

  void createRoom(String userId, String username) {
    final roomId = 'room_${userId}_${DateTime.now().millisecondsSinceEpoch}';
    _joinRoom(roomId, isHost: true, hostName: username);
  }

  void joinRoom(String roomId) {
    _joinRoom(roomId, isHost: false, hostName: '');
  }

  void _joinRoom(
    String roomId, {
    required bool isHost,
    required String hostName,
  }) {
    _socketService.joinRoom(roomId);

    _socketService.on(AppConstants.socketRoomState, (data) {
      if (data is Map) {
        emit(
          SyncConnected(
            roomId: roomId,
            isHost: isHost,
            participantCount: data['participantCount'] ?? 1,
          ),
        );
      }
    });

    _socketService.on(AppConstants.socketUserJoined, (data) {
      final current = state;
      if (current is SyncConnected) {
        emit(current.copyWith(participantCount: current.participantCount + 1));
      }
    });

    _socketService.on(AppConstants.socketUserLeft, (data) {
      final current = state;
      if (current is SyncConnected) {
        emit(
          current.copyWith(
            participantCount: (current.participantCount - 1).clamp(1, 999),
          ),
        );
      }
    });

    // Listen for sync commands (non-host)
    if (!isHost) {
      _socketService.on(AppConstants.socketSyncPlay, (data) async {
        await _audioHandler.play();
      });

      _socketService.on(AppConstants.socketSyncPause, (data) async {
        await _audioHandler.pause();
      });

      _socketService.on(AppConstants.socketSyncSeek, (data) async {
        if (data is Map && data['position'] != null) {
          await _audioHandler.seek(
            Duration(milliseconds: data['position'] as int),
          );
        }
      });
    }

    emit(SyncConnected(roomId: roomId, isHost: isHost, participantCount: 1));
  }

  void leaveRoom() {
    final current = state;
    if (current is SyncConnected) {
      _socketService.leaveRoom(current.roomId);
    }
    emit(SyncDisconnected());
  }
}
