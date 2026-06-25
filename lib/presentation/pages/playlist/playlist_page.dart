// import 'dart:ui';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:lyrica_flutter/core/theme/app_colors.dart';
// import 'package:lyrica_flutter/features/player/domain/entities/track.dart';
// import 'package:lyrica_flutter/features/player/presentation/providers/player_cubit.dart';
// import 'package:lyrica_flutter/features/playlists/domain/entities/playlist.dart';
// import 'package:lyrica_flutter/features/playlists/presentation/providers/playlist_cubit.dart';
// import 'package:lyrica_flutter/presentation/pages/player/player_page.dart';
//
// class PlaylistPage extends StatefulWidget {
//   const PlaylistPage({super.key});
//   @override
//   State<PlaylistPage> createState() => _PlaylistPageState();
// }
//
// class _PlaylistPageState extends State<PlaylistPage>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _orbCtrl;
//
//   @override
//   void initState() {
//     super.initState();
//     _orbCtrl = AnimationController(
//         vsync: this, duration: const Duration(seconds: 9))
//       ..repeat(reverse: true);
//     context.read<PlaylistCubit>().loadPlaylists();
//   }
//
//   @override
//   void dispose() {
//     _orbCtrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<PlaylistCubit, PlaylistCubitState>(
//       builder: (context, state) {
//         if (state is PlaylistLoading) {
//           return const _LoadingScaffold();
//         }
//         if (state is PlaylistError) {
//           return _ErrorScaffold(message: state.message);
//         }
//         if (state is! PlaylistLoaded) {
//           return const _LoadingScaffold();
//         }
//
//         // If a playlist is selected, show its detail view
//         if (state.selectedPlaylist != null) {
//           return _PlaylistDetailView(
//             playlist: state.selectedPlaylist!,
//             orbCtrl: _orbCtrl,
//             onBack: () => context.read<PlaylistCubit>().clearSelection(),
//           );
//         }
//
//         // Otherwise show the full library list
//         return _PlaylistLibraryView(
//           state: state,
//           orbCtrl: _orbCtrl,
//         );
//       },
//     );
//   }
// }
//
// // ─── Library List View ────────────────────────────────────────────────────────
// class _PlaylistLibraryView extends StatelessWidget {
//   final PlaylistLoaded state;
//   final AnimationController orbCtrl;
//   const _PlaylistLibraryView({required this.state, required this.orbCtrl});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundDeep,
//       body: Stack(children: [
//         // Orbs
//         AnimatedBuilder(
//           animation: orbCtrl,
//           builder: (_, __) => Stack(children: [
//             Positioned(top: -70 + orbCtrl.value * 40, left: -50,
//               child: _Orb(280, AppColors.orbViolet)),
//             Positioned(bottom: 80 + orbCtrl.value * -20, right: -60,
//               child: _Orb(200, AppColors.orbBlue)),
//           ]),
//         ),
//         SafeArea(child: CustomScrollView(
//           physics: const BouncingScrollPhysics(),
//           slivers: [
//             // Header
//             SliverToBoxAdapter(child: Padding(
//               padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
//               child: Text('Your Library',
//                   style: GoogleFonts.inter(fontSize: 28,
//                       fontWeight: FontWeight.w800, color: AppColors.textPrimary,
//                       letterSpacing: -0.5)),
//             )),
//
//             // Liked Songs Bucket
//             if (state.likedSongsPlaylist != null)
//               SliverToBoxAdapter(child: Padding(
//                 padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
//                 child: _LikedSongsBanner(
//                   playlist: state.likedSongsPlaylist!,
//                   onTap: () => context
//                       .read<PlaylistCubit>()
//                       .selectPlaylist(state.likedSongsPlaylist!),
//                 ),
//               )),
//
//             // Section label
//             SliverToBoxAdapter(child: Padding(
//               padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
//               child: Text('Playlists',
//                   style: GoogleFonts.inter(fontSize: 16,
//                       fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
//             )),
//
//             // Playlist rows
//             SliverList(delegate: SliverChildBuilderDelegate(
//               (ctx, i) {
//                 final pl = state.userPlaylists[i];
//                 return _PlaylistRow(
//                   playlist: pl,
//                   onTap: () => context.read<PlaylistCubit>().selectPlaylist(pl),
//                 );
//               },
//               childCount: state.userPlaylists.length,
//             )),
//
//             const SliverToBoxAdapter(child: SizedBox(height: 120)),
//           ],
//         )),
//       ]),
//     );
//   }
// }
//
// // ─── Liked Songs Banner ───────────────────────────────────────────────────────
// class _LikedSongsBanner extends StatelessWidget {
//   final Playlist playlist;
//   final VoidCallback onTap;
//   const _LikedSongsBanner({required this.playlist, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(18),
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
//           child: Container(
//             height: 100,
//             padding: const EdgeInsets.all(18),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   AppColors.accentViolet.withOpacity(0.5),
//                   AppColors.accentBlue.withOpacity(0.3),
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(18),
//               border: Border.all(color: AppColors.glassBorder, width: 0.8),
//             ),
//             child: Row(children: [
//               const Text('💜', style: TextStyle(fontSize: 36)),
//               const SizedBox(width: 16),
//               Expanded(child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(playlist.name,
//                       style: GoogleFonts.inter(fontSize: 18,
//                           fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
//                   const SizedBox(height: 4),
//                   Text('${playlist.trackCount} songs · ${playlist.formattedTotalDuration}',
//                       style: GoogleFonts.inter(fontSize: 12,
//                           color: AppColors.textSecondary)),
//                 ],
//               )),
//               const Icon(Icons.chevron_right_rounded,
//                   color: AppColors.textSecondary, size: 24),
//             ]),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ─── Playlist Row ─────────────────────────────────────────────────────────────
// class _PlaylistRow extends StatelessWidget {
//   final Playlist playlist;
//   final VoidCallback onTap;
//   const _PlaylistRow({required this.playlist, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(14),
//           child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: AppColors.glassLight,
//                 borderRadius: BorderRadius.circular(14),
//                 border: Border.all(color: AppColors.glassBorder, width: 0.7),
//               ),
//               child: Row(children: [
//                 // Cover
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(10),
//                   child: playlist.tracks.isNotEmpty &&
//                           playlist.tracks.first.coverUrl != null
//                       ? CachedNetworkImage(
//                           imageUrl: playlist.tracks.first.coverUrl!,
//                           width: 56, height: 56, fit: BoxFit.cover,
//                           errorWidget: (_, __, ___) =>
//                               _gradientBox(playlist),
//                         )
//                       : _gradientBox(playlist),
//                 ),
//                 const SizedBox(width: 14),
//                 Expanded(child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(playlist.name, maxLines: 1, overflow: TextOverflow.ellipsis,
//                         style: GoogleFonts.inter(fontSize: 15,
//                             fontWeight: FontWeight.w700,
//                             color: AppColors.textPrimary)),
//                     const SizedBox(height: 3),
//                     Text('${playlist.trackCount} songs',
//                         style: GoogleFonts.inter(fontSize: 12,
//                             color: AppColors.textTertiary)),
//                   ],
//                 )),
//                 const Icon(Icons.chevron_right_rounded,
//                     color: AppColors.textTertiary, size: 20),
//               ]),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _gradientBox(Playlist pl) {
//     final colors = [
//       [AppColors.accentViolet, AppColors.accentBlue],
//       [AppColors.accentRose, AppColors.accentViolet],
//       [AppColors.accentCyan, AppColors.accentBlue],
//       [AppColors.accentAmber, AppColors.accentRose],
//     ];
//     final idx = pl.id.hashCode.abs() % colors.length;
//     return Container(
//       width: 56, height: 56,
//       decoration: BoxDecoration(gradient: LinearGradient(
//         colors: colors[idx],
//         begin: Alignment.topLeft, end: Alignment.bottomRight,
//       )),
//       child: const Icon(Icons.queue_music_rounded,
//           color: Colors.white54, size: 24),
//     );
//   }
// }
//
// // ─── Playlist Detail View ─────────────────────────────────────────────────────
// class _PlaylistDetailView extends StatelessWidget {
//   final Playlist playlist;
//   final AnimationController orbCtrl;
//   final VoidCallback onBack;
//   const _PlaylistDetailView(
//       {required this.playlist, required this.orbCtrl, required this.onBack});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundDeep,
//       body: Stack(children: [
//         AnimatedBuilder(
//           animation: orbCtrl,
//           builder: (_, __) => Stack(children: [
//             Positioned(top: -80 + orbCtrl.value * 30, right: -60,
//               child: _Orb(260, AppColors.orbViolet)),
//             Positioned(bottom: 100, left: -40,
//               child: _Orb(180, AppColors.orbCyan)),
//           ]),
//         ),
//         SafeArea(child: Column(children: [
//           // Top bar
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
//             child: Row(children: [
//               GestureDetector(
//                 onTap: onBack,
//                 child: const Icon(Icons.arrow_back_ios_new_rounded,
//                     color: AppColors.textPrimary, size: 20),
//               ),
//               const SizedBox(width: 12),
//               Expanded(child: Text(playlist.name,
//                   maxLines: 1, overflow: TextOverflow.ellipsis,
//                   style: GoogleFonts.inter(fontSize: 18,
//                       fontWeight: FontWeight.w700,
//                       color: AppColors.textPrimary))),
//             ]),
//           ),
//           const SizedBox(height: 8),
//
//           // Playlist header
//           Padding(
//             padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
//             child: Row(children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: playlist.tracks.isNotEmpty &&
//                         playlist.tracks.first.coverUrl != null
//                     ? CachedNetworkImage(
//                         imageUrl: playlist.tracks.first.coverUrl!,
//                         width: 90, height: 90, fit: BoxFit.cover)
//                     : Container(
//                         width: 90, height: 90,
//                         decoration: const BoxDecoration(
//                           gradient: AppColors.accentGradient),
//                         child: const Icon(Icons.queue_music_rounded,
//                             color: Colors.white54, size: 36)),
//               ),
//               const SizedBox(width: 16),
//               Expanded(child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   if (playlist.isLikedSongs)
//                     const Text('💜', style: TextStyle(fontSize: 22)),
//                   Text(playlist.name,
//                       style: GoogleFonts.inter(fontSize: 18,
//                           fontWeight: FontWeight.w800,
//                           color: AppColors.textPrimary)),
//                   const SizedBox(height: 4),
//                   Text(playlist.description,
//                       maxLines: 2, overflow: TextOverflow.ellipsis,
//                       style: GoogleFonts.inter(fontSize: 12,
//                           color: AppColors.textTertiary)),
//                   const SizedBox(height: 4),
//                   Text(
//                     '${playlist.trackCount} songs · ${playlist.formattedTotalDuration}',
//                     style: GoogleFonts.inter(fontSize: 11,
//                         color: AppColors.textTertiary),
//                   ),
//                 ],
//               )),
//             ]),
//           ),
//
//           const Divider(color: AppColors.glassBorder, height: 1),
//
//           // Track list with swipe-to-delete
//           Expanded(
//             child: playlist.tracks.isEmpty
//                 ? Center(child: Text('No tracks yet',
//                     style: GoogleFonts.inter(color: AppColors.textTertiary)))
//                 : ListView.builder(
//                     physics: const BouncingScrollPhysics(),
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 16, vertical: 8),
//                     itemCount: playlist.tracks.length,
//                     itemBuilder: (ctx, i) {
//                       final track = playlist.tracks[i];
//                       return Dismissible(
//                         key: ValueKey('${playlist.id}_${track.id}'),
//                         direction: DismissDirection.endToStart,
//                         background: _dismissBackground(),
//                         onDismissed: (_) {
//                           ctx.read<PlaylistCubit>().removeTrackFromPlaylist(
//                               playlist.id, track.id);
//                         },
//                         child: _TrackRow(
//                           track: track,
//                           index: i,
//                           onTap: () {
//                             ctx.read<PlayerCubit>().playTrack(track);
//                             Navigator.of(ctx).push(PageRouteBuilder(
//                               pageBuilder: (_, a, __) => const PlayerPage(),
//                               transitionsBuilder: (_, a, __, child) =>
//                                   FadeTransition(opacity: a, child: child),
//                               transitionDuration:
//                                   const Duration(milliseconds: 350),
//                             ));
//                           },
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ])),
//       ]),
//     );
//   }
//
//   Widget _dismissBackground() {
//     return Container(
//       alignment: Alignment.centerRight,
//       padding: const EdgeInsets.only(right: 20),
//       margin: const EdgeInsets.only(bottom: 10),
//       decoration: BoxDecoration(
//         color: AppColors.error.withOpacity(0.25),
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: const Icon(Icons.delete_outline_rounded,
//           color: AppColors.error, size: 26),
//     );
//   }
// }
//
// // ─── Track Row ────────────────────────────────────────────────────────────────
// class _TrackRow extends StatelessWidget {
//   final Track track;
//   final int index;
//   final VoidCallback onTap;
//   const _TrackRow(
//       {required this.track, required this.index, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 8),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(12),
//           child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//               decoration: BoxDecoration(
//                 color: AppColors.glassLight,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: AppColors.glassBorder, width: 0.6),
//               ),
//               child: Row(children: [
//                 Text('${index + 1}',
//                     style: GoogleFonts.inter(fontSize: 13,
//                         color: AppColors.textTertiary,
//                         fontWeight: FontWeight.w500),
//                     textWidthBasis: TextWidthBasis.parent),
//                 const SizedBox(width: 12),
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(8),
//                   child: CachedNetworkImage(
//                     imageUrl: track.coverUrl ?? '',
//                     width: 44, height: 44, fit: BoxFit.cover,
//                     errorWidget: (_, __, ___) => Container(
//                       width: 44, height: 44,
//                       color: AppColors.backgroundSurface,
//                       child: const Icon(Icons.music_note,
//                           color: AppColors.textTertiary, size: 18)),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(track.title, maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: GoogleFonts.inter(fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                             color: AppColors.textPrimary)),
//                     const SizedBox(height: 2),
//                     Text(track.artistName, maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: GoogleFonts.inter(fontSize: 12,
//                             color: AppColors.textTertiary)),
//                   ],
//                 )),
//                 Text(track.formattedDuration,
//                     style: GoogleFonts.inter(fontSize: 11,
//                         color: AppColors.textTertiary)),
//                 const SizedBox(width: 8),
//                 const Icon(Icons.more_vert_rounded,
//                     color: AppColors.textTertiary, size: 18),
//               ]),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ─── Shared ───────────────────────────────────────────────────────────────────
// class _Orb extends StatelessWidget {
//   final double size;
//   final Color color;
//   const _Orb(this.size, this.color);
//   @override
//   Widget build(BuildContext context) {
//     return ImageFiltered(
//       imageFilter: ImageFilter.blur(sigmaX: 55, sigmaY: 55),
//       child: Container(
//           width: size, height: size,
//           decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
//     );
//   }
// }
//
// class _LoadingScaffold extends StatelessWidget {
//   const _LoadingScaffold();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundDeep,
//       body: Center(child: CircularProgressIndicator(
//           color: AppColors.accentViolet)),
//     );
//   }
// }
//
// class _ErrorScaffold extends StatelessWidget {
//   final String message;
//   const _ErrorScaffold({required this.message});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundDeep,
//       body: Center(child: Text(message,
//           style: GoogleFonts.inter(color: AppColors.error))),
//     );
//   }
// }
