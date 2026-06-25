// lib/presentation/player/widgets/lyrics_panel.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/track_entity.dart';
import '../viewmodel/lyrics_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/track_entity.dart';
import '../viewmodel/lyrics_cubit.dart';

class LyricsPanel extends StatefulWidget {
  final Duration position;
  final TrackEntity track;

  const LyricsPanel({super.key, required this.position, required this.track});

  @override
  State<LyricsPanel> createState() => _LyricsPanelState();
}

class _LyricsPanelState extends State<LyricsPanel> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _lineKeys = {};
  int _lastActiveIndex = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LyricsCubit>().loadLyrics(widget.track);
    });
  }

  @override
  void didUpdateWidget(LyricsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.track.id != widget.track.id) {
      context.read<LyricsCubit>().loadLyrics(widget.track);
    }
    _updateScroll();
  }

  void _updateScroll() {
    final state = context.read<LyricsCubit>().state;
    final activeIndex = context.read<LyricsCubit>().getCurrentLineIndex(
      widget.position,
    );

    if (activeIndex != _lastActiveIndex && activeIndex >= 0) {
      _lastActiveIndex = activeIndex;
      final key = _lineKeys[activeIndex];
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(
          key!.currentContext!,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          alignment: 0.4,
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LyricsCubit, LyricsState>(
      builder: (context, state) {
        if (state is LyricsLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.accentPrimary,
              ),
            ),
          );
        }

        if (state is LyricsNotFound || state is LyricsError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.music_note_rounded,
                  color: AppColors.textDisabled,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  state is LyricsError
                      ? 'Failed to load lyrics'
                      : 'No lyrics found',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          );
        }

        if (state is LyricsLoaded) {
          final lyrics = state.lyrics;
          final activeIndex = context.read<LyricsCubit>().getCurrentLineIndex(
            widget.position,
          );

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            itemCount: lyrics.lines.length,
            itemBuilder: (context, i) {
              final line = lyrics.lines[i];
              final isActive = i == activeIndex;
              final isPast = i < activeIndex;

              _lineKeys[i] ??= GlobalKey();

              return Container(
                key: _lineKeys[i],
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: isActive ? 22 : 16,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                    color: isActive
                        ? AppColors.textPrimary
                        : isPast
                        ? AppColors.textDisabled
                        : AppColors.textSecondary,
                    height: 1.4,
                  ),
                  child: Text(line.text, textAlign: TextAlign.center),
                ),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentPrimary,
        secondary: AppColors.accentSecondary,
        tertiary: AppColors.accentTertiary,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.textPrimary,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
      ),
      fontFamily: 'Inter',
      textTheme: _textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.accentPrimary,
        unselectedItemColor: AppColors.textDisabled,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      sliderTheme: SliderThemeData(
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
        activeTrackColor: AppColors.accentPrimary,
        inactiveTrackColor: AppColors.waveformInactive,
        thumbColor: AppColors.textPrimary,
        overlayColor: AppColors.accentPrimary.withOpacity(0.2),
      ),
      iconTheme: const IconThemeData(color: AppColors.textSecondary),
      dividerTheme: const DividerThemeData(
        color: AppColors.glassBorder,
        thickness: 0.5,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static const TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 48,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: -1.5,
      height: 1.1,
    ),
    displayMedium: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: -1,
      height: 1.15,
    ),
    headlineLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      letterSpacing: -0.5,
    ),
    headlineMedium: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      letterSpacing: -0.3,
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    titleLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    titleMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
      letterSpacing: 0.1,
    ),
    titleSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
      letterSpacing: 0.5,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.textDisabled,
      height: 1.4,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      letterSpacing: 0.5,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
      letterSpacing: 1,
    ),
  );
}

// Gradient helpers
class AppGradients {
  AppGradients._();

  static const LinearGradient brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: AppColors.brandGradient,
  );

  static const LinearGradient playerBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: AppColors.playerGradient,
  );

  static const RadialGradient glowPrimary = RadialGradient(
    center: Alignment.center,
    radius: 1.2,
    colors: [Color(0x408B5CF6), Colors.transparent],
  );

  static LinearGradient dynamicFromColor(Color color) => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [color.withOpacity(0.8), AppColors.background],
    stops: const [0.0, 0.6],
  );
}

// class LyricsPanel extends StatefulWidget {
//   final Duration position;
//   final TrackEntity track;
//
//   const LyricsPanel({super.key, required this.position, required this.track});
//
//   @override
//   State<LyricsPanel> createState() => _LyricsPanelState();
// }
//
// class _LyricsPanelState extends State<LyricsPanel> {
//   final ScrollController _scrollController = ScrollController();
//   final Map<int, GlobalKey> _lineKeys = {};
//   int _lastActiveIndex = -1;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<LyricsCubit>().loadLyrics(widget.track);
//     });
//   }
//
//   @override
//   void didUpdateWidget(LyricsPanel oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.track.id != widget.track.id) {
//       context.read<LyricsCubit>().loadLyrics(widget.track);
//     }
//     _updateScroll();
//   }
//
//   void _updateScroll() {
//     final state = context.read<LyricsCubit>().state;
//     final activeIndex = context.read<LyricsCubit>().getCurrentLineIndex(
//       widget.position,
//     );
//
//     if (activeIndex != _lastActiveIndex && activeIndex >= 0) {
//       _lastActiveIndex = activeIndex;
//       final key = _lineKeys[activeIndex];
//       if (key?.currentContext != null) {
//         Scrollable.ensureVisible(
//           key!.currentContext!,
//           duration: const Duration(milliseconds: 400),
//           curve: Curves.easeInOut,
//           alignment: 0.4,
//         );
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<LyricsCubit, LyricsState>(
//       builder: (context, state) {
//         if (state is LyricsLoading) {
//           return const Center(
//             child: CircularProgressIndicator(
//               valueColor: AlwaysStoppedAnimation<Color>(
//                 AppColors.accentPrimary,
//               ),
//             ),
//           );
//         }
//
//         if (state is LyricsNotFound || state is LyricsError) {
//           return Center(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(
//                   Icons.music_note_rounded,
//                   color: AppColors.textDisabled,
//                   size: 48,
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   state is LyricsError
//                       ? 'Failed to load lyrics'
//                       : 'No lyrics found',
//                   style: const TextStyle(
//                     color: AppColors.textSecondary,
//                     fontSize: 15,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }
//
//         if (state is LyricsLoaded) {
//           final lyrics = state.lyrics;
//           final activeIndex = context.read<LyricsCubit>().getCurrentLineIndex(
//             widget.position,
//           );
//
//           return ListView.builder(
//             controller: _scrollController,
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
//             itemCount: lyrics.lines.length,
//             itemBuilder: (context, i) {
//               final line = lyrics.lines[i];
//               final isActive = i == activeIndex;
//               final isPast = i < activeIndex;
//
//               _lineKeys[i] ??= GlobalKey();
//
//               return Container(
//                 key: _lineKeys[i],
//                 margin: const EdgeInsets.symmetric(vertical: 8),
//                 child: AnimatedDefaultTextStyle(
//                   duration: const Duration(milliseconds: 300),
//                   style: TextStyle(
//                     fontSize: isActive ? 22 : 16,
//                     fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
//                     color: isActive
//                         ? AppColors.textPrimary
//                         : isPast
//                         ? AppColors.textDisabled
//                         : AppColors.textSecondary,
//                     height: 1.4,
//                   ),
//                   child: Text(line.text, textAlign: TextAlign.center),
//                 ),
//               );
//             },
//           );
//         }
//
//         return const SizedBox.shrink();
//       },
//     );
//   }
// }
