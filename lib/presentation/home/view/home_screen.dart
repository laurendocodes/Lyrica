// lib/presentation/home/view/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lyrica_flutter/presentation/home/viewmodel/home_cubit.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/track_entity.dart';
import '../../player/viewmodel/player_cubit.dart';
import '../../shared/widgets/track_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<HomeCubit>();
      cubit.loadHome();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                if (state is HomeLoading || state is HomeInitial) {
                  return _buildSkeleton();
                }
                if (state is HomeError) {
                  return _buildError(state.message);
                }
                if (state is HomeLoaded) {
                  return _buildContent(state);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      snap: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (b) => AppGradients.brand.createShader(b),
              child: const Text(
                'Lyrica',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.search_rounded,
            color: AppColors.textSecondary,
          ),
          onPressed: () => context.go('/search'),
        ),
        IconButton(
          icon: const Icon(
            Icons.people_outline_rounded,
            color: AppColors.textSecondary,
          ),
          onPressed: () => context.go('/sync'),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildContent(HomeLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('Recently Added'),
        _horizontalTrackList(state.recentTracks),
        const SizedBox(height: 8),
        _sectionHeader('Trending'),
        _horizontalTrackList(state.trendingTracks),
        const SizedBox(height: 8),
        _sectionHeader('All Tracks'),
        ...state.recentTracks.asMap().entries.map(
          (e) =>
              _buildTrackTile(e.value, index: e.key, queue: state.recentTracks),
        ),
        const SizedBox(height: 120),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            'See all',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.accentPrimary.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _horizontalTrackList(List<TrackEntity> tracks) {
    return SizedBox(
      height: 185,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tracks.length,
        itemBuilder: (context, i) {
          return TrackCard(
                track: tracks[i],
                onTap: () => _playTrack(tracks[i], queue: tracks, index: i),
              )
              .animate(delay: (i * 50).ms)
              .fadeIn(duration: 300.ms)
              .slideX(begin: 0.1, end: 0);
        },
      ),
    );
  }

  Widget _buildTrackTile(
    TrackEntity track, {
    required int index,
    required List<TrackEntity> queue,
  }) {
    return BlocBuilder<PlayerCubit, PlayerState>(
      buildWhen: (prev, curr) =>
          prev.currentTrack?.id != curr.currentTrack?.id ||
          prev.isPlaying != curr.isPlaying,
      builder: (context, playerState) {
        final isActive = playerState.currentTrack?.id == track.id;
        return TrackTile(
          track: track,
          isActive: isActive,
          isPlaying: isActive && playerState.isPlaying,
          index: index,
          onTap: () => _playTrack(track, queue: queue, index: index),
        );
      },
    );
  }

  void _playTrack(
    TrackEntity track, {
    required List<TrackEntity> queue,
    required int index,
  }) {
    context.read<PlayerCubit>().playTrack(
      track,
      queue: queue,
      queueIndex: index,
    );
    context.go('/player');
  }

  Widget _buildSkeleton() {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceElevated,
      highlightColor: AppColors.glass,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _skeletonBox(
            140,
            20,
            margin: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          ),
          SizedBox(
            height: 185,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, __) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _skeletonBox(140, 140),
                  const SizedBox(height: 8),
                  _skeletonBox(100, 14),
                ],
              ),
            ),
          ),
          ...List.generate(
            6,
            (i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  _skeletonBox(50, 50),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _skeletonBox(double.infinity, 14),
                        const SizedBox(height: 6),
                        _skeletonBox(120, 11),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _skeletonBox(double width, double height, {EdgeInsets? margin}) =>
      Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
        ),
      );

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: AppColors.textDisabled,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => context.read<HomeCubit>().loadHome(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
