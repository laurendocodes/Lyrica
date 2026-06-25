// lib/presentation/shared/widgets/mini_player.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../player/viewmodel/player_cubit.dart';
import 'glass_card.dart';
import 'track_tile.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, PlayerState>(
      builder: (context, state) {
        if (state.currentTrack == null) return const SizedBox.shrink();

        final track = state.currentTrack!;
        final progress = state.progress;

        return GestureDetector(
          onTap: () => context.go('/player'),
          child: GlassCard(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            borderRadius: 16,
            blur: 20,
            color: AppColors.surfaceElevated.withOpacity(0.9),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    AlbumArtWidget(
                      url: track.albumArtUrl,
                      size: 42,
                      borderRadius: 8,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            track.title,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            track.artist,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Prev
                    _controlBtn(
                      icon: Icons.skip_previous_rounded,
                      onTap: () => context.read<PlayerCubit>().skipPrevious(),
                      size: 28,
                    ),
                    // Play/Pause
                    GestureDetector(
                      onTap: () =>
                          context.read<PlayerCubit>().togglePlayPause(),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: AppColors.brandGradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          state.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: AppColors.textPrimary,
                          size: 22,
                        ),
                      ),
                    ),
                    // Next
                    _controlBtn(
                      icon: Icons.skip_next_rounded,
                      onTap: () => context.read<PlayerCubit>().skipNext(),
                      size: 28,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.waveformInactive,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.accentPrimary,
                    ),
                    minHeight: 2,
                  ),
                ),
              ],
            ),
          ),
        ).animate().slideY(
          begin: 1,
          end: 0,
          duration: 300.ms,
          curve: Curves.easeOut,
        );
      },
    );
  }

  Widget _controlBtn({
    required IconData icon,
    required VoidCallback onTap,
    double size = 24,
  }) => GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Icon(icon, color: AppColors.textSecondary, size: size),
    ),
  );
}
