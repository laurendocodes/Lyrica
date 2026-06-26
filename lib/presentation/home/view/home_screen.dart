import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/track_entity.dart';
import '../../player/viewmodel/player_cubit.dart';
import '../../shared/widgets/track_tile.dart';
import '../viewmodel/home_cubit.dart';

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
      context.read<HomeCubit>().loadHome();
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
                if (state is HomeLoading || state is HomeInitial) return _buildSkeleton();
                if (state is HomeError) return _buildError(state.message);
                if (state is HomeLoaded) return _buildContent(state);
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
      expandedHeight: 100,
      floating: true,
      snap: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
        title: ShaderMask(
          shaderCallback: (b) => AppGradients.brand.createShader(b),
          child: const Text('Lyrica',
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1)),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
          onPressed: () => context.go('/search'),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildContent(HomeLoaded state) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader('Recently Added'),
      _horizontalList(state.recentTracks),
      _sectionHeader('Trending Now'),
      _horizontalList(state.trendingTracks),
      _sectionHeader('All Tracks'),
      ...state.recentTracks.asMap().entries.map(
            (e) => _trackTile(e.value, index: e.key, queue: state.recentTracks),
          ),
      const SizedBox(height: 160), // space for mini player + nav
    ]);
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Text(title,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary)),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _horizontalList(List<TrackEntity> tracks) {
    return SizedBox(
      height: 188,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tracks.length,
        itemBuilder: (context, i) {
          final track = tracks[i];
          return TrackCard(
            track: track,
            onTap: () => _play(track, queue: tracks, index: i),
          )
              .animate(delay: (i * 40).ms)
              .fadeIn(duration: 250.ms)
              .slideX(begin: 0.08, end: 0);
        },
      ),
    );
  }

  Widget _trackTile(TrackEntity track,
      {required int index, required List<TrackEntity> queue}) {
    return BlocBuilder<PlayerCubit, PlayerState>(
      // CRITICAL: only rebuild when this track's active/playing status changes
      buildWhen: (p, c) =>
          (p.currentTrack?.id == track.id) != (c.currentTrack?.id == track.id) ||
          (p.isPlaying != c.isPlaying && c.currentTrack?.id == track.id),
      builder: (context, state) {
        final isActive = state.currentTrack?.id == track.id;
        return TrackTile(
          track: track,
          isActive: isActive,
          isPlaying: isActive && state.isPlaying,
          index: index,
          onTap: () => _play(track, queue: queue, index: index),
        );
      },
    );
  }

  void _play(TrackEntity track,
      {required List<TrackEntity> queue, required int index}) {
    // Call on the singleton PlayerCubit — same instance as PlayerScreen
    context.read<PlayerCubit>().playTrack(track, queue: queue, queueIndex: index);
    // Navigate to player
    context.go('/player');
  }

  Widget _buildSkeleton() {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceElevated,
      highlightColor: AppColors.glass,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _skeletonBox(160, 20, margin: const EdgeInsets.fromLTRB(20, 24, 20, 14)),
        SizedBox(
          height: 188,
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
                _skeletonBox(110, 13),
                const SizedBox(height: 4),
                _skeletonBox(80, 11),
              ],
            ),
          ),
        ),
        _skeletonBox(140, 20, margin: const EdgeInsets.fromLTRB(20, 24, 20, 14)),
        ...List.generate(
          6,
          (_) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            child: Row(children: [
              _skeletonBox(50, 50),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _skeletonBox(double.infinity, 13),
                  const SizedBox(height: 6),
                  _skeletonBox(120, 11),
                ]),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _skeletonBox(double w, double h, {EdgeInsets? margin}) => Container(
        width: w, height: h, margin: margin,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
        ),
      );

  Widget _buildError(String msg) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(children: [
            const SizedBox(height: 60),
            const Icon(Icons.wifi_off_rounded, color: AppColors.textDisabled, size: 48),
            const SizedBox(height: 16),
            Text(msg,
                style: const TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => context.read<HomeCubit>().loadHome(),
              child: const Text('Retry'),
            ),
          ]),
        ),
      );
}
