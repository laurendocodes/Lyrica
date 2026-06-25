import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../viewmodel/player_cubit.dart';
import '../../../core/theme/app_theme.dart';

class QueuePanel extends StatelessWidget {
  const QueuePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, PlayerState>(
      builder: (context, state) {
        if (state.queue.isEmpty) {
          return const Center(
            child: Text(
              'Queue is empty',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: state.queue.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final track = state.queue[index];
            final isCurrent = index == state.currentIndex;

            return ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: isCurrent
                  ? AppColors.accentPrimary.withOpacity(0.15)
                  : AppColors.glass,
              leading: isCurrent
                  ? const Icon(Icons.graphic_eq, color: AppColors.accentPrimary)
                  : Text(
                      '${index + 1}',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
              title: Text(
                track.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              subtitle: Text(
                track.artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              onTap: () {
                context.read<PlayerCubit>().playTrackAt(index);
              },
            );
          },
        );
      },
    );
  }
}
