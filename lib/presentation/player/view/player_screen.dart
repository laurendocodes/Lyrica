// lib/presentation/player/view/player_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lyrica_flutter/presentation/player/widgets/queue_panel.dart';
import '../../../core/theme/app_theme.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/track_tile.dart';
import '../viewmodel/lyrics_cubit.dart';
import '../viewmodel/player_cubit.dart';
import '../widgets/lyrics_panel.dart';
import '../widgets/player_controls.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen>
    with TickerProviderStateMixin {
  late AnimationController _artController;
  late PageController _pageController;
  int _currentPage = 0; // 0=player, 1=lyrics, 2=queue

  @override
  void initState() {
    super.initState();
    _artController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _pageController = PageController();

    // Load lyrics for current track
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final track = context.read<PlayerCubit>().state.currentTrack;
      if (track != null) {
        context.read<LyricsCubit>().loadLyrics(track);
      }
    });
  }

  @override
  void dispose() {
    _artController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, PlayerState>(
      builder: (context, state) {
        if (state.currentTrack == null) {
          return const Scaffold(
            body: Center(
              child: Text(
                'No track playing',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          );
        }

        final track = state.currentTrack!;

        return Scaffold(
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              // Dynamic background from album art color
              _buildBackground(track.albumArtUrl),

              SafeArea(
                child: Column(
                  children: [
                    _buildTopBar(context),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (i) => setState(() => _currentPage = i),
                        children: [
                          _buildMainPlayerPage(state, track),
                          LyricsPanel(position: state.position, track: track),
                          const QueuePanel(),
                        ],
                      ),
                    ),
                    _buildPageIndicator(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackground(String? albumArtUrl) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: AppColors.background),
        if (albumArtUrl != null)
          Opacity(
            opacity: 0.15,
            child: Image.network(
              albumArtUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.accentPrimary.withOpacity(0.1),
                  AppColors.background.withOpacity(0.95),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.go('/'),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textPrimary,
              size: 32,
            ),
          ),
          const Spacer(),
          const Text(
            'Now Playing',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => _showOptions(context),
            icon: const Icon(
              Icons.more_horiz_rounded,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainPlayerPage(PlayerState state, track) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 24),

          // Album art — rotating when playing
          _buildAlbumArt(track, state.isPlaying),

          const SizedBox(height: 32),

          // Track info
          _buildTrackInfo(track, state),

          const SizedBox(height: 28),

          // Progress
          PlayerProgressBar(state: state),

          const SizedBox(height: 24),

          // Controls
          PlayerControls(state: state),

          const SizedBox(height: 20),

          // Speed + Volume
          PlayerExtraControls(state: state),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(track, bool isPlaying) {
    return Center(
      child: AnimatedBuilder(
        animation: _artController,
        builder: (_, child) {
          return Transform.rotate(
            angle: isPlaying ? _artController.value * 2 * 3.14159 : 0,
            child: child,
          );
        },
        child: Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.accentPrimary.withOpacity(0.4),
                blurRadius: 60,
                spreadRadius: 10,
              ),
            ],
          ),
          child: ClipOval(
            child: AlbumArtWidget(
              url: track.albumArtUrl,
              size: 260,
              borderRadius: 130,
            ),
          ),
        ),
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.elasticOut);
  }

  Widget _buildTrackInfo(track, PlayerState state) {
    return Column(
      children: [
        Text(
          track.title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Text(
          track.artist,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
        if (track.album != null) ...[
          const SizedBox(height: 4),
          Text(
            track.album!,
            style: const TextStyle(fontSize: 12, color: AppColors.textDisabled),
          ),
        ],
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final isActive = i == _currentPage;
        return GestureDetector(
          onTap: () => _pageController.animateToPage(
            i,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isActive ? 20 : 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.accentPrimary
                  : AppColors.textDisabled,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.textDisabled,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          _optionTile(Icons.queue_music_rounded, 'View Queue', () {
            Navigator.pop(context);
            _pageController.animateToPage(
              2,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }),
          _optionTile(Icons.people_outline_rounded, 'Start Sync Room', () {
            Navigator.pop(context);
            context.go('/sync');
          }),
          _optionTile(Icons.share_outlined, 'Share Track', () {
            Navigator.pop(context);
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _optionTile(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(
        label,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
      ),
      onTap: onTap,
    );
  }
}
