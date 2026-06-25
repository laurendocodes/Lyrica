// lib/presentation/player/widgets/player_controls.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lyrica_flutter/presentation/player/viewmodel/player_cubit.dart';
import '../../../core/theme/app_theme.dart';

class PlayerProgressBar extends StatelessWidget {
  final PlayerState state;

  const PlayerProgressBar({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final track = state.currentTrack;
    if (track == null) return const SizedBox.shrink();

    final total = track.duration;
    final current = state.position;

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
          ),
          child: Slider(
            value: state.progress,
            onChanged: (value) {
              final position = Duration(
                milliseconds: (value * track.duration.inMilliseconds).round(),
              );
              context.read<PlayerCubit>().seek(position);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(current),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                _formatDuration(total),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

class PlayerControls extends StatelessWidget {
  final PlayerState state;

  const PlayerControls({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PlayerCubit>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Shuffle
        _iconButton(
          icon: Icons.shuffle_rounded,
          color: state.isShuffle
              ? AppColors.accentPrimary
              : AppColors.textSecondary,
          size: 22,
          onTap: cubit.toggleShuffle,
        ),

        // Previous
        _iconButton(
          icon: Icons.skip_previous_rounded,
          color: AppColors.textPrimary,
          size: 36,
          onTap: cubit.skipPrevious,
        ),

        // Play/Pause — the centerpiece
        GestureDetector(
          onTap: cubit.togglePlayPause,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.brandGradient,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentPrimary.withOpacity(0.5),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: state.isLoading
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.textPrimary,
                      ),
                    ),
                  )
                : Icon(
                    state.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: AppColors.textPrimary,
                    size: 36,
                  ),
          ),
        ),

        // Next
        _iconButton(
          icon: Icons.skip_next_rounded,
          color: AppColors.textPrimary,
          size: 36,
          onTap: cubit.skipNext,
        ),

        // Repeat
        _iconButton(
          icon: state.repeatMode == PlayerRepeatMode.one
              ? Icons.repeat_one_rounded
              : Icons.repeat_rounded,
          color: state.repeatMode != PlayerRepeatMode.none
              ? AppColors.accentPrimary
              : AppColors.textSecondary,
          size: 22,
          onTap: () {
            final next =
                PlayerRepeatMode.values[(state.repeatMode.index + 1) %
                    PlayerRepeatMode.values.length];
            cubit.setRepeatMode(next);
          },
        ),
      ],
    );
  }

  Widget _iconButton({
    required IconData icon,
    required Color color,
    double size = 24,
    required VoidCallback onTap,
  }) => GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Icon(icon, color: color, size: size),
    ),
  );
}

class PlayerExtraControls extends StatelessWidget {
  final PlayerState state;

  const PlayerExtraControls({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PlayerCubit>();

    return Row(
      children: [
        const Icon(
          Icons.speed_rounded,
          color: AppColors.textSecondary,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            ),
            child: Slider(
              min: 0.5,
              max: 2.0,
              divisions: 6,
              value: state.speed,
              onChanged: (v) => cubit.setSpeed(v),
            ),
          ),
        ),
        SizedBox(
          width: 38,
          child: Text(
            '${state.speed.toStringAsFixed(1)}x',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
