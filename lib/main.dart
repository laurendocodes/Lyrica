import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lyrica_flutter/core/di/injection.dart';
import 'package:lyrica_flutter/core/router/go_router.dart';
import 'package:lyrica_flutter/core/theme/app_theme.dart';

import 'package:lyrica_flutter/presentation/pages/home/home_page.dart';
import 'package:lyrica_flutter/presentation/shell/main_shell.dart';
import 'package:window_manager/window_manager.dart';

// ── Desktop lyric widget imports (preserved) ────────────────────────────────
import 'dart:async';
import 'package:lyrica_flutter/models/lyrics_line_model.dart';
import 'package:lyrica_flutter/services/lyrics_service.dart';
import 'package:lyrica_flutter/services/lyrics_widget.dart';
import 'package:flutter/material.dart';
import 'presentation/auth/view/auth_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'presentation/auth/view/auth_screen.dart';
import 'presentation/auth/viewmodel/auth_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();

  final authCubit = getIt<AuthCubit>();
  await authCubit.checkAuth();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthCubit>()..checkAuth(),
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Lyrica',
            theme: ThemeData.dark(),

            routerConfig: router,
          );
        },
      ),
    );
  }
}

class LyricaApp extends StatelessWidget {
  const LyricaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider<AuthCubit>(create: (_) => getIt<AuthCubit>())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Lyrica',
        theme: ThemeData.dark(),
        home: const AuthScreen(),
      ),
    );
  }
}

// class _DesktopLyricaBody extends StatefulWidget {
//   const _DesktopLyricaBody();
//   @override
//   State<_DesktopLyricaBody> createState() => _DesktopLyricaBodyState();
// }
//
// class _DesktopLyricaBodyState extends State<_DesktopLyricaBody> {
//   List<LyricLine> _lyrics = [];
//   Duration _currentPlaybackPosition = Duration.zero;
//   Timer? _pollingTimer;
//   String _currentSongName = '';
//   String _currentArtistName = '';
//   String _currentMood = 'calm';
//
//   @override
//   void initState() {
//     super.initState();
//     _pollingTimer = Timer.periodic(
//       const Duration(milliseconds: 500),
//       (_) => _pollSpotify(),
//     );
//   }
//
//   Future<void> _fetchNewLyrics(String artist, String song) async {
//     setState(() {
//       _lyrics = [
//         LyricLine(timestamp: Duration.zero, text: 'Analyzing song vibe…'),
//       ];
//       _currentMood = 'calm';
//     });
//     final svc = LyricsService();
//     final res = await svc.fetchSyncedLyrics(artist, song);
//     setState(() {
//       _lyrics = res.lyrics;
//       _currentMood = res.mood;
//     });
//   }
//
//   Future<void> _pollSpotify() async {
//     const script = '''
// if application "Spotify" is running then
//   tell application "Spotify"
//     if player state is playing then
//       set trackName to name of current track
//       set artistName to artist of current track
//       set playerPos to player position
//       return trackName & "|" & artistName & "|" & playerPos
//     else
//       return "PAUSED"
//     end if
//   end tell
// else
//   return "NOT_RUNNING"
// end if''';
//     try {
//       final result = await Process.run('osascript', ['-e', script]);
//       if (result.exitCode != 0) return;
//       final output = result.stdout.toString().trim();
//       if (output == 'PAUSED' || output == 'NOT_RUNNING') return;
//       final parts = output.split('|');
//       if (parts.length != 3) return;
//       final song = parts[0];
//       final artist = parts[1];
//       final raw = double.tryParse(parts[2]) ?? 0.0;
//       final pos = raw > 1000
//           ? Duration(milliseconds: raw.round())
//           : Duration(milliseconds: (raw * 1000).round());
//       if (song != _currentSongName || artist != _currentArtistName) {
//         _currentSongName = song;
//         _currentArtistName = artist;
//         _fetchNewLyrics(artist, song);
//       }
//       setState(() => _currentPlaybackPosition = pos);
//     } catch (e) {
//       debugPrint('AppleScript error: $e');
//     }
//   }
//
//   @override
//   void dispose() {
//     _pollingTimer?.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(backgroundColor: Colors.transparent, body: HomePage());
//   }
// }
