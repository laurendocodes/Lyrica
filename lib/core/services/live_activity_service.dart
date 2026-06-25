// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';
// import 'package:lyrica_flutter/features/player/domain/entities/track.dart';
//
// /// Bridge service that invokes the iOS Live Activity MethodChannel.
// /// On non-iOS platforms all calls are silently no-ops.
// class LiveActivityService {
//   LiveActivityService._();
//
//   static const MethodChannel _channel = MethodChannel('lyrica/live_activity');
//
//   static Future<void> startActivity({
//     required Track track,
//     required int progressMs,
//     required bool isPlaying,
//   }) async {
//     if (!_isSupported) return;
//     try {
//       await _channel.invokeMethod<void>('startLiveActivity', {
//         'title':       track.title,
//         'artistName':  track.artistName,
//         'coverUrl':    track.coverUrl ?? '',
//         'progressMs':  progressMs,
//         'durationMs':  track.durationMs,
//         'isPlaying':   isPlaying,
//       });
//     } on PlatformException catch (e) {
//       debugPrint('[LiveActivityService] startActivity failed: ${e.message}');
//     } on MissingPluginException {
//       debugPrint('[LiveActivityService] Plugin not registered – iOS only.');
//     }
//   }
//
//   static Future<void> updateActivity({
//     required int progressMs,
//     required bool isPlaying,
//     String? title,
//     String? artistName,
//     String? coverUrl,
//     int? durationMs,
//   }) async {
//     if (!_isSupported) return;
//     try {
//       await _channel.invokeMethod<void>('updateLiveActivity', {
//         'progressMs': progressMs,
//         'isPlaying':  isPlaying,
//         if (title      != null) 'title':      title,
//         if (artistName != null) 'artistName': artistName,
//         if (coverUrl   != null) 'coverUrl':   coverUrl,
//         if (durationMs != null) 'durationMs': durationMs,
//       });
//     } on PlatformException catch (e) {
//       debugPrint('[LiveActivityService] updateActivity failed: ${e.message}');
//     } on MissingPluginException {
//       debugPrint('[LiveActivityService] Plugin not registered – iOS only.');
//     }
//   }
//
//   static Future<void> endActivity() async {
//     if (!_isSupported) return;
//     try {
//       await _channel.invokeMethod<void>('endLiveActivity');
//     } on PlatformException catch (e) {
//       debugPrint('[LiveActivityService] endActivity failed: ${e.message}');
//     } on MissingPluginException {
//       debugPrint('[LiveActivityService] Plugin not registered – iOS only.');
//     }
//   }
//
//   static bool get _isSupported =>
//       defaultTargetPlatform == TargetPlatform.iOS;
// }
