// import 'dart:ui';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:lyrica_flutter/core/theme/app_colors.dart';
// import 'package:lyrica_flutter/core/services/mock_data_service.dart';
// import 'package:lyrica_flutter/features/player/domain/entities/track.dart';
// import 'package:lyrica_flutter/features/player/presentation/providers/player_cubit.dart';
// import 'package:lyrica_flutter/features/playlists/domain/entities/playlist.dart';
// import 'package:lyrica_flutter/features/playlists/presentation/providers/playlist_cubit.dart';
// import 'package:lyrica_flutter/presentation/pages/player/player_page.dart';
//
// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
//   late final AnimationController _orbController;
//   final TextEditingController _searchController = TextEditingController();
//   bool _searchFocused = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _orbController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 8),
//     )..repeat(reverse: true);
//   }
//
//   @override
//   void dispose() {
//     _orbController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   void _openPlayer(BuildContext ctx, Track track) {
//     ctx.read<PlayerCubit>().playTrack(track);
//     Navigator.of(ctx).push(
//       PageRouteBuilder(
//         pageBuilder: (_, a, b) => const PlayerPage(),
//         transitionsBuilder: (_, a, b, child) => SlideTransition(
//           position: Tween<Offset>(
//             begin: const Offset(0, 1),
//             end: Offset.zero,
//           ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
//           child: child,
//         ),
//         transitionDuration: const Duration(milliseconds: 450),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final playlists = MockDataService.playlists;
//     final recentTracks = MockDataService.recentTracks;
//
//     return Scaffold(
//       backgroundColor: AppColors.backgroundDeep,
//       extendBodyBehindAppBar: true,
//       body: Stack(
//         children: [
//           // ── Ambient Orbs ──────────────────────────────────────────────────────
//           _AmbientOrbs(controller: _orbController),
//
//           // ── Main Scroll ───────────────────────────────────────────────────────
//           SafeArea(
//             child: CustomScrollView(
//               physics: const BouncingScrollPhysics(),
//               slivers: [
//                 SliverToBoxAdapter(
//                   child: Padding(
//                     padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         _buildHeader(),
//                         const SizedBox(height: 20),
//                         _buildSearchBar(context),
//                         const SizedBox(height: 32),
//                         _buildSectionTitle('Recently Played'),
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 // ── Recent Tracks Horizontal Row ────────────────────────────────
//                 SliverToBoxAdapter(
//                   child: SizedBox(
//                     height: 210,
//                     child: ListView.separated(
//                       scrollDirection: Axis.horizontal,
//                       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                       itemCount: recentTracks.length,
//                       separatorBuilder: (_, __) => const SizedBox(width: 14),
//                       itemBuilder: (ctx, i) =>
//                           _TrackCard(track: recentTracks[i], onTap: () => _openPlayer(ctx, recentTracks[i])),
//                     ),
//                   ),
//                 ),
//
//                 SliverToBoxAdapter(
//                   child: Padding(
//                     padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
//                     child: _buildSectionTitle('Your Playlists'),
//                   ),
//                 ),
//
//                 // ── Playlists Quick-Access Grid ─────────────────────────────────
//                 SliverPadding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   sliver: SliverGrid(
//                     delegate: SliverChildBuilderDelegate(
//                       (ctx, i) => _PlaylistGridItem(
//                         playlist: playlists[i],
//                         onTap: () {
//                           ctx.read<PlaylistCubit>().selectPlaylist(playlists[i]);
//                           Navigator.of(ctx).pushNamed('/playlist');
//                         },
//                       ),
//                       childCount: playlists.length,
//                     ),
//                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2,
//                       mainAxisSpacing: 14,
//                       crossAxisSpacing: 14,
//                       childAspectRatio: 1.55,
//                     ),
//                   ),
//                 ),
//
//                 const SliverToBoxAdapter(child: SizedBox(height: 120)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildHeader() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               _greeting(),
//               style: GoogleFonts.inter(
//                 fontSize: 13, color: AppColors.textTertiary, letterSpacing: 0.5,
//               ),
//             ),
//             const SizedBox(height: 2),
//             Text(
//               'Lyrica',
//               style: GoogleFonts.inter(
//                 fontSize: 30, fontWeight: FontWeight.w800,
//                 color: AppColors.textPrimary, letterSpacing: -1,
//               ),
//             ),
//           ],
//         ),
//         _GlassIconButton(
//           icon: Icons.notifications_none_rounded,
//           onTap: () {},
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSearchBar(BuildContext context) {
//     return GestureDetector(
//       onTap: () => Navigator.of(context).pushNamed('/search'),
//       child: _GlassContainer(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         child: Row(
//           children: [
//             const Icon(Icons.search_rounded, color: AppColors.textTertiary, size: 20),
//             const SizedBox(width: 12),
//             Text(
//               'Search songs, artists, albums…',
//               style: GoogleFonts.inter(
//                 fontSize: 14, color: AppColors.textTertiary,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSectionTitle(String title) {
//     return Text(
//       title,
//       style: GoogleFonts.inter(
//         fontSize: 18, fontWeight: FontWeight.w700,
//         color: AppColors.textPrimary, letterSpacing: -0.3,
//       ),
//     );
//   }
//
//   String _greeting() {
//     final h = DateTime.now().hour;
//     if (h < 12) return 'Good morning ☀️';
//     if (h < 17) return 'Good afternoon 🎵';
//     return 'Good evening 🌙';
//   }
// }
//
// // ─── Track Card ─────────────────────────────────────────────────────────────────
//
// class _TrackCard extends StatelessWidget {
//   final Track track;
//   final VoidCallback onTap;
//
//   const _TrackCard({required this.track, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: SizedBox(
//         width: 140,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Album Art
//             ClipRRect(
//               borderRadius: BorderRadius.circular(14),
//               child: CachedNetworkImage(
//                 imageUrl: track.coverUrl ?? '',
//                 width: 140,
//                 height: 140,
//                 fit: BoxFit.cover,
//                 placeholder: (_, __) => Container(
//                   color: AppColors.backgroundSurface,
//                   child: const Icon(Icons.music_note, color: AppColors.textTertiary),
//                 ),
//                 errorWidget: (_, __, ___) => _AlbumPlaceholder(track: track),
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               track.title,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: GoogleFonts.inter(
//                 fontSize: 13, fontWeight: FontWeight.w600,
//                 color: AppColors.textPrimary,
//               ),
//             ),
//             const SizedBox(height: 2),
//             Text(
//               track.artistName,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: GoogleFonts.inter(
//                 fontSize: 11, color: AppColors.textTertiary,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ─── Playlist Grid Item ──────────────────────────────────────────────────────
//
// class _PlaylistGridItem extends StatelessWidget {
//   final Playlist playlist;
//   final VoidCallback onTap;
//
//   const _PlaylistGridItem({required this.playlist, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         child: Stack(
//           fit: StackFit.expand,
//           children: [
//             // Background
//             if (playlist.tracks.isNotEmpty && playlist.tracks.first.coverUrl != null)
//               CachedNetworkImage(
//                 imageUrl: playlist.tracks.first.coverUrl!,
//                 fit: BoxFit.cover,
//                 errorWidget: (_, __, ___) => Container(color: AppColors.backgroundSurface),
//               )
//             else
//               Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [AppColors.accentViolet, AppColors.accentBlue],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                 ),
//               ),
//
//             // Frosted overlay
//             BackdropFilter(
//               filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
//               child: Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [Colors.transparent, Colors.black.withOpacity(0.75)],
//                   ),
//                 ),
//               ),
//             ),
//
//             // Text
//             Padding(
//               padding: const EdgeInsets.all(12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   if (playlist.isLikedSongs)
//                     const Text('💜', style: TextStyle(fontSize: 18)),
//                   Text(
//                     playlist.name,
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     style: GoogleFonts.inter(
//                       fontSize: 13, fontWeight: FontWeight.w700,
//                       color: AppColors.textPrimary,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     '${playlist.trackCount} songs',
//                     style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ─── Ambient Orbs ────────────────────────────────────────────────────────────
//
// class _AmbientOrbs extends StatelessWidget {
//   final AnimationController controller;
//   const _AmbientOrbs({required this.controller});
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: controller,
//       builder: (_, __) {
//         final t = controller.value;
//         return Stack(
//           children: [
//             Positioned(
//               top: -80 + t * 40,
//               left: -60 + t * 30,
//               child: _Orb(size: 280, color: AppColors.orbViolet),
//             ),
//             Positioned(
//               top: 180 + t * -20,
//               right: -80,
//               child: _Orb(size: 220, color: AppColors.orbBlue),
//             ),
//             Positioned(
//               bottom: 100 + t * 30,
//               left: 40 + t * -20,
//               child: _Orb(size: 180, color: AppColors.orbCyan),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
//
// class _Orb extends StatelessWidget {
//   final double size;
//   final Color color;
//   const _Orb({required this.size, required this.color});
//
//   @override
//   Widget build(BuildContext context) {
//     return ImageFiltered(
//       imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
//       child: Container(
//         width: size,
//         height: size,
//         decoration: BoxDecoration(shape: BoxShape.circle, color: color),
//       ),
//     );
//   }
// }
//
// // ─── Shared Glass Primitives ─────────────────────────────────────────────────
//
// class _GlassContainer extends StatelessWidget {
//   final Widget child;
//   final EdgeInsetsGeometry? padding;
//   final BorderRadius? borderRadius;
//
//   const _GlassContainer({
//     required this.child,
//     this.padding,
//     this.borderRadius,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: borderRadius ?? BorderRadius.circular(16),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
//         child: Container(
//           padding: padding,
//           decoration: BoxDecoration(
//             color: AppColors.glassLight,
//             borderRadius: borderRadius ?? BorderRadius.circular(16),
//             border: Border.all(color: AppColors.glassBorder, width: 1.0),
//           ),
//           child: child,
//         ),
//       ),
//     );
//   }
// }
//
// class _GlassIconButton extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback onTap;
//
//   const _GlassIconButton({required this.icon, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: _GlassContainer(
//         padding: const EdgeInsets.all(10),
//         borderRadius: BorderRadius.circular(12),
//         child: Icon(icon, color: AppColors.textPrimary, size: 22),
//       ),
//     );
//   }
// }
//
// class _AlbumPlaceholder extends StatelessWidget {
//   final Track track;
//   const _AlbumPlaceholder({required this.track});
//
//   @override
//   Widget build(BuildContext context) {
//     final colors = [
//       [AppColors.accentViolet, AppColors.accentBlue],
//       [AppColors.accentRose, AppColors.accentViolet],
//       [AppColors.accentCyan, AppColors.accentBlue],
//       [AppColors.accentAmber, AppColors.accentRose],
//     ];
//     final idx = track.id.hashCode % colors.length;
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: colors[idx],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//       ),
//       child: const Center(child: Icon(Icons.music_note, color: Colors.white54, size: 32)),
//     );
//   }
// }
