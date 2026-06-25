import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../constants/app_constants.dart';

typedef SocketEventHandler = void Function(dynamic data);

class SocketService {
  IO.Socket? _socket;
  bool _isConnected = false;

  final Map<String, List<SocketEventHandler>> _handlers = {};

  bool get isConnected => _isConnected;

  void connect(String token) {
    if (_socket != null) return;

    _socket = IO.io(
      AppConstants.nestBaseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .build(),
    );

    _socket!.onConnect((_) {
      _isConnected = true;
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
    });

    _socket!.onError((e) {
      _isConnected = false;
    });

    _socket!.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
    _handlers.clear();
  }

  void on(String event, SocketEventHandler handler) {
    _handlers.putIfAbsent(event, () => []).add(handler);
    _socket?.on(event, handler);
  }

  void off(String event, SocketEventHandler handler) {
    _handlers[event]?.remove(handler);
    _socket?.off(event);
  }

  void emit(String event, dynamic data) {
    if (_isConnected) {
      _socket?.emit(event, data);
    }
  }

  void joinRoom(String roomId) {
    emit(AppConstants.socketJoinRoom, {'roomId': roomId});
  }

  void leaveRoom(String roomId) {
    emit(AppConstants.socketLeaveRoom, {'roomId': roomId});
  }

  void syncPlay(String roomId, Duration position) {
    emit(AppConstants.socketSyncPlay, {
      'roomId': roomId,
      'position': position.inMilliseconds,
    });
  }

  void syncPause(String roomId, Duration position) {
    emit(AppConstants.socketSyncPause, {
      'roomId': roomId,
      'position': position.inMilliseconds,
    });
  }

  void syncSeek(String roomId, Duration position) {
    emit(AppConstants.socketSyncSeek, {
      'roomId': roomId,
      'position': position.inMilliseconds,
    });
  }

  void syncTrack(String roomId, String trackId, Duration position) {
    emit(AppConstants.socketSyncTrack, {
      'roomId': roomId,
      'trackId': trackId,
      'position': position.inMilliseconds,
    });
  }
}
