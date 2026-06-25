// lib/presentation/shared/widgets/track_tile.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/track_entity.dart';

class TrackTile extends StatelessWidget {
  final TrackEntity track;
  final bool isActive;
  final bool isPlaying;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;
  final int? index;

  const TrackTile({
    super.key,
    required this.track,
    this.isActive = false,
    this.isPlaying = false,
    this.onTap,
    this.onMoreTap,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.accentPrimary.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? Border.all(
                  color: AppColors.accentPrimary.withOpacity(0.3),
                  width: 0.5,
                )
              : null,
        ),
        child: Row(
          children: [
            // Album art
            _AlbumArt(
              url: track.albumArtUrl,
              size: 50,
              isPlaying: isActive && isPlaying,
            ),
            const SizedBox(width: 12),

            // Track info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    track.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? AppColors.accentPrimary
                          : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    track.artist,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Duration
            Text(
              track.durationFormatted,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textDisabled,
              ),
            ),

            // More
            IconButton(
              onPressed: onMoreTap,
              icon: const Icon(
                Icons.more_vert_rounded,
                color: AppColors.textDisabled,
                size: 18,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).slideX(begin: 0.05, end: 0);
  }
}

class _AlbumArt extends StatelessWidget {
  final String? url;
  final double size;
  final bool isPlaying;

  const _AlbumArt({this.url, required this.size, this.isPlaying = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: url != null
              ? CachedNetworkImage(
                  imageUrl: url!,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => _placeholder(size),
                  errorWidget: (_, __, ___) => _placeholder(size),
                )
              : _placeholder(size),
        ),
        if (isPlaying)
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.equalizer_rounded,
              color: AppColors.accentPrimary,
              size: 22,
            ),
          ),
      ],
    );
  }

  Widget _placeholder(double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Icon(
      Icons.music_note_rounded,
      color: AppColors.textDisabled,
      size: 22,
    ),
  );
}

class AlbumArtWidget extends StatelessWidget {
  final String? url;
  final double size;
  final double borderRadius;

  const AlbumArtWidget({
    super.key,
    this.url,
    required this.size,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: url != null
          ? CachedNetworkImage(
              imageUrl: url!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              placeholder: (_, __) => _shimmer(size),
              errorWidget: (_, __, ___) => _fallback(size),
            )
          : _fallback(size),
    );
  }

  Widget _shimmer(double size) => Shimmer.fromColors(
    baseColor: AppColors.surfaceElevated,
    highlightColor: AppColors.glass,
    child: Container(
      width: size,
      height: size,
      color: AppColors.surfaceElevated,
    ),
  );

  Widget _fallback(double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.accentPrimary, AppColors.accentSecondary],
      ),
    ),
    child: const Icon(
      Icons.music_note_rounded,
      color: AppColors.textPrimary,
      size: 40,
    ),
  );
}

// Horizontal scrolling track card for home screen
class TrackCard extends StatelessWidget {
  final TrackEntity track;
  final VoidCallback? onTap;

  const TrackCard({super.key, required this.track, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Expanded(
        child: Container(
          width: 140,
          margin: const EdgeInsets.only(right: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AlbumArtWidget(
                url: track.albumArtUrl,
                size: 140,
                borderRadius: 12,
              ),
              const SizedBox(height: 8),
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
              const SizedBox(height: 2),
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
      ),
    );
  }
}
