import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../player/viewmodel/player_cubit.dart';
import '../../shared/widgets/track_tile.dart';
import '../viewmodel/search_cubit.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  focusNode: _focus,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                  onChanged: (v) => context.read<SearchCubit>().onQueryChanged(v),
                  decoration: InputDecoration(
                    hintText: 'Search songs, artists, albums…',
                    hintStyle: const TextStyle(color: AppColors.textDisabled),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppColors.textSecondary, size: 22),
                    suffixIcon: ValueListenableBuilder(
                      valueListenable: _ctrl,
                      builder: (_, v, __) => v.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded,
                                  color: AppColors.textDisabled, size: 18),
                              onPressed: () {
                                _ctrl.clear();
                                context.read<SearchCubit>().clear();
                              },
                            )
                          : const SizedBox.shrink(),
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceElevated,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ]),
          ),

          // Results
          Expanded(
            child: BlocBuilder<SearchCubit, SearchState>(
              builder: (context, state) {
                if (state is SearchInitial) return _buildInitialView();
                if (state is SearchLoading) return _buildLoading();
                if (state is SearchError) return _buildError(state.message);
                if (state is SearchLoaded) {
                  return state.results.isEmpty
                      ? _buildEmpty(state.query)
                      : _buildResults(state);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildInitialView() {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.search_rounded, size: 64, color: AppColors.textDisabled),
        const SizedBox(height: 16),
        const Text('Search your music library',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
        const SizedBox(height: 8),
        const Text('Find songs, artists, and albums',
            style: TextStyle(color: AppColors.textDisabled, fontSize: 13)),
        const SizedBox(height: 40),
        // Genre chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(
            spacing: 10, runSpacing: 10,
            children: ['Pop', 'Rock', 'Hip-Hop', 'Jazz', 'Classical',
                       'Electronic', 'R&B', 'Country']
                .map((g) => _GenreChip(label: g, onTap: () {
                      _ctrl.text = g;
                      context.read<SearchCubit>().search(g);
                    }))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(AppColors.accentPrimary),
        ),
      );

  Widget _buildError(String msg) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.textDisabled, size: 48),
          const SizedBox(height: 12),
          Text(msg,
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center),
        ]),
      );

  Widget _buildEmpty(String query) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.music_off_rounded,
              size: 56, color: AppColors.textDisabled),
          const SizedBox(height: 16),
          Text('No results for "$query"',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 15)),
          const SizedBox(height: 8),
          const Text('Try a different search term',
              style: TextStyle(color: AppColors.textDisabled, fontSize: 13)),
        ]),
      );

  Widget _buildResults(SearchLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: Text(
            '${state.results.length} result${state.results.length == 1 ? '' : 's'}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: state.results.length,
            itemBuilder: (context, i) {
              final track = state.results[i];
              return BlocBuilder<PlayerCubit, PlayerState>(
                buildWhen: (p, c) =>
                    p.currentTrack?.id != c.currentTrack?.id ||
                    p.isPlaying != c.isPlaying,
                builder: (context, ps) => TrackTile(
                  track: track,
                  isActive: ps.currentTrack?.id == track.id,
                  isPlaying:
                      ps.currentTrack?.id == track.id && ps.isPlaying,
                  index: i,
                  onTap: () {
                    context.read<PlayerCubit>().playTrack(
                          track,
                          queue: state.results,
                          queueIndex: i,
                        );
                    context.go('/player');
                  },
                ),
              ).animate(delay: (i * 30).ms).fadeIn(duration: 200.ms);
            },
          ),
        ),
      ],
    );
  }
}

class _GenreChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GenreChip({required this.label, required this.onTap});

  static final _colors = [
    [AppColors.accentPrimary, const Color(0xFF6366F1)],
    [AppColors.accentSecondary, const Color(0xFF0EA5E9)],
    [AppColors.accentTertiary, const Color(0xFFDB2777)],
    [const Color(0xFF10B981), const Color(0xFF059669)],
  ];

  @override
  Widget build(BuildContext context) {
    final idx = label.hashCode.abs() % _colors.length;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: _colors[idx]),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13)),
      ),
    );
  }
}
