// import 'dart:ui';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:lyrica_flutter/core/theme/app_colors.dart';
// import 'package:lyrica_flutter/core/services/mock_data_service.dart';
// import 'package:lyrica_flutter/features/player/presentation/providers/player_cubit.dart';
// import 'package:lyrica_flutter/models/lyrics_line_model.dart';
//
// class PlayerPage extends StatefulWidget {
//   const PlayerPage({super.key});
//   @override
//   State<PlayerPage> createState() => _PlayerPageState();
// }
//
// class _PlayerPageState extends State<PlayerPage> with TickerProviderStateMixin {
//   late final AnimationController _discCtrl;
//   late final AnimationController _pulseCtrl;
//   late final AnimationController _lyricsCtrl;
//   final ScrollController _lyricsScroll = ScrollController();
//   bool _lyricsOpen = false;
//   int _prevLyricIdx = -1;
//
//   @override
//   void initState() {
//     super.initState();
//     _discCtrl = AnimationController(
//         vsync: this, duration: const Duration(seconds: 18))..repeat();
//     _pulseCtrl = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 1200))
//       ..repeat(reverse: true);
//     _lyricsCtrl = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 450));
//   }
//
//   @override
//   void dispose() {
//     _discCtrl.dispose();
//     _pulseCtrl.dispose();
//     _lyricsCtrl.dispose();
//     _lyricsScroll.dispose();
//     super.dispose();
//   }
//
//   void _toggleLyrics() {
//     setState(() => _lyricsOpen = !_lyricsOpen);
//     if (_lyricsOpen) {
//       _lyricsCtrl.forward();
//     } else {
//       _lyricsCtrl.reverse();
//     }
//   }
//
//   void _scrollToActiveLyric(int idx) {
//     if (!_lyricsScroll.hasClients || idx < 0) return;
//     if (idx == _prevLyricIdx) return;
//     _prevLyricIdx = idx;
//     _lyricsScroll.animateTo(
//       (idx * 52.0).clamp(0.0, _lyricsScroll.position.maxScrollExtent),
//       duration: const Duration(milliseconds: 350),
//       curve: Curves.easeInOut,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<PlayerCubit, PlayerCubitState>(
//       listenWhen: (p, c) =>
//           c is PlayerLoaded &&
//           p is PlayerLoaded &&
//           c.activeLyricIndex != p.activeLyricIndex,
//       listener: (_, state) {
//         if (state is PlayerLoaded) {
//           _scrollToActiveLyric(state.activeLyricIndex);
//           if (state.isPlaying) {
//             _discCtrl.forward();
//           } else {
//             _discCtrl.stop();
//           }
//         }
//       },
//       builder: (context, state) {
//         if (state is PlayerLoading) return _buildLoading();
//         if (state is PlayerError) return _buildError(state.message);
//         if (state is! PlayerLoaded) return _buildEmpty();
//
//         return Scaffold(
//           backgroundColor: Colors.transparent,
//           body: Stack(fit: StackFit.expand, children: [
//             // ── Blurred album art background ──────────────────────────────────
//             CachedNetworkImage(
//               imageUrl: state.currentTrack.coverUrl ?? '',
//               fit: BoxFit.cover,
//               width: double.infinity,
//               height: double.infinity,
//               errorWidget: (_, __, ___) => Container(
//                 decoration: const BoxDecoration(
//                   gradient: AppColors.playerGradient),
//               ),
//             ),
//             BackdropFilter(
//               filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
//               child: Container(color: Colors.black.withOpacity(0.65)),
//             ),
//
//             // ── Main content ──────────────────────────────────────────────────
//             SafeArea(
//               child: Column(children: [
//                 _buildTopBar(context),
//                 Expanded(child: SingleChildScrollView(
//                   physics: const NeverScrollableScrollPhysics(),
//                   child: Column(children: [
//                     const SizedBox(height: 12),
//                     _buildSpinningDisc(state),
//                     const SizedBox(height: 28),
//                     _buildTrackInfo(state),
//                     const SizedBox(height: 24),
//                     _buildProgressBar(context, state),
//                     const SizedBox(height: 20),
//                     _buildControls(context, state),
//                     const SizedBox(height: 16),
//                     _buildLyricsToggle(state),
//                   ]),
//                 )),
//               ]),
//             ),
//
//             // ── Sliding lyrics drawer ─────────────────────────────────────────
//             AnimatedBuilder(
//               animation: _lyricsCtrl,
//               builder: (_, __) {
//                 final frac = CurvedAnimation(
//                     parent: _lyricsCtrl, curve: Curves.easeOutCubic).value;
//                 if (frac == 0) return const SizedBox.shrink();
//                 final screenH = MediaQuery.of(context).size.height;
//                 return Positioned(
//                   bottom: 0,
//                   left: 0, right: 0,
//                   height: screenH * 0.55 * frac,
//                   child: _buildLyricsDrawer(state),
//                 );
//               },
//             ),
//           ]),
//         );
//       },
//     );
//   }
//
//   // ─── Top bar ──────────────────────────────────────────────────────────────
//   Widget _buildTopBar(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//       child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//         GestureDetector(
//           onTap: () => Navigator.of(context).pop(),
//           child: const Icon(Icons.keyboard_arrow_down_rounded,
//               color: Colors.white, size: 32),
//         ),
//         Column(children: [
//           Text('NOW PLAYING',
//               style: GoogleFonts.inter(fontSize: 11, letterSpacing: 2,
//                   color: Colors.white60, fontWeight: FontWeight.w600)),
//         ]),
//         const Icon(Icons.more_horiz_rounded, color: Colors.white70, size: 24),
//       ]),
//     );
//   }
//
//   // ─── Spinning disc ────────────────────────────────────────────────────────
//   Widget _buildSpinningDisc(PlayerLoaded state) {
//     return AnimatedBuilder(
//       animation: _discCtrl,
//       builder: (_, child) => Transform.rotate(
//         angle: _discCtrl.value * 2 * 3.14159,
//         child: child,
//       ),
//       child: AnimatedBuilder(
//         animation: _pulseCtrl,
//         builder: (_, child) => Container(
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             boxShadow: [
//               BoxShadow(
//                 color: AppColors.accentViolet
//                     .withOpacity(0.3 + _pulseCtrl.value * 0.25),
//                 blurRadius: 40 + _pulseCtrl.value * 20,
//                 spreadRadius: 4 + _pulseCtrl.value * 8,
//               ),
//             ],
//           ),
//           child: child,
//         ),
//         child: ClipOval(
//           child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
//             child: Container(
//               width: 240,
//               height: 240,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(color: Colors.white.withOpacity(0.15), width: 2),
//               ),
//               child: ClipOval(
//                 child: CachedNetworkImage(
//                   imageUrl: state.currentTrack.coverUrl ?? '',
//                   fit: BoxFit.cover,
//                   errorWidget: (_, __, ___) => Container(
//                     decoration: const BoxDecoration(
//                       gradient: AppColors.accentGradient),
//                     child: const Icon(Icons.music_note,
//                         color: Colors.white54, size: 60),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ─── Track info ───────────────────────────────────────────────────────────
//   Widget _buildTrackInfo(PlayerLoaded state) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 32),
//       child: Row(children: [
//         Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Text(state.currentTrack.title,
//               maxLines: 1, overflow: TextOverflow.ellipsis,
//               style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800,
//                   color: Colors.white, letterSpacing: -0.4)),
//           const SizedBox(height: 4),
//           Text(state.currentTrack.artistName,
//               maxLines: 1, overflow: TextOverflow.ellipsis,
//               style: GoogleFonts.inter(fontSize: 15, color: Colors.white60,
//                   fontWeight: FontWeight.w500)),
//         ])),
//         BlocBuilder<PlayerCubit, PlayerCubitState>(
//           builder: (ctx, s) {
//             final liked = s is PlayerLoaded &&
//                 ctx.read<PlayerCubit>() != null;
//             return GestureDetector(
//               onTap: () {},
//               child: AnimatedSwitcher(
//                 duration: const Duration(milliseconds: 250),
//                 child: Icon(Icons.favorite_rounded,
//                     key: ValueKey(liked),
//                     color: AppColors.accentRose, size: 26),
//               ),
//             );
//           },
//         ),
//       ]),
//     );
//   }
//
//   // ─── Progress bar ─────────────────────────────────────────────────────────
//   Widget _buildProgressBar(BuildContext context, PlayerLoaded state) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24),
//       child: Column(children: [
//         SliderTheme(
//           data: SliderTheme.of(context).copyWith(
//             trackHeight: 3,
//             thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
//             activeTrackColor: Colors.white,
//             inactiveTrackColor: Colors.white24,
//             thumbColor: Colors.white,
//             overlayColor: Colors.white24,
//           ),
//           child: Slider(
//             value: state.progressFraction,
//             onChanged: (v) {
//               final ms = (v * state.currentTrack.durationMs).round();
//               context.read<PlayerCubit>().seekTo(ms);
//             },
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 8),
//           child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//             Text(state.formattedProgress,
//                 style: GoogleFonts.inter(fontSize: 12, color: Colors.white60)),
//             Text(state.currentTrack.formattedDuration,
//                 style: GoogleFonts.inter(fontSize: 12, color: Colors.white60)),
//           ]),
//         ),
//       ]),
//     );
//   }
//
//   // ─── Controls ─────────────────────────────────────────────────────────────
//   Widget _buildControls(BuildContext context, PlayerLoaded state) {
//     final queue = MockDataService.recentTracks;
//     return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
//       IconButton(
//         icon: const Icon(Icons.skip_previous_rounded, color: Colors.white70, size: 34),
//         onPressed: () => context.read<PlayerCubit>().skipPrevious(queue),
//       ),
//       GestureDetector(
//         onTap: () => context.read<PlayerCubit>().togglePlayPause(),
//         child: AnimatedBuilder(
//           animation: _pulseCtrl,
//           builder: (_, child) => Container(
//             width: 70, height: 70,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.white,
//               boxShadow: [BoxShadow(
//                 color: Colors.white.withOpacity(0.25 + _pulseCtrl.value * 0.1),
//                 blurRadius: 20 + _pulseCtrl.value * 10,
//                 spreadRadius: 2,
//               )],
//             ),
//             child: Icon(
//               state.isPlaying
//                   ? Icons.pause_rounded
//                   : Icons.play_arrow_rounded,
//               color: AppColors.backgroundDeep, size: 36,
//             ),
//           ),
//         ),
//       ),
//       IconButton(
//         icon: const Icon(Icons.skip_next_rounded, color: Colors.white70, size: 34),
//         onPressed: () => context.read<PlayerCubit>().skipNext(queue),
//       ),
//     ]);
//   }
//
//   // ─── Lyrics toggle button ─────────────────────────────────────────────────
//   Widget _buildLyricsToggle(PlayerLoaded state) {
//     return GestureDetector(
//       onTap: _toggleLyrics,
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(20),
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//             decoration: BoxDecoration(
//               color: AppColors.glassLight,
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: AppColors.glassBorder, width: 0.8),
//             ),
//             child: Row(mainAxisSize: MainAxisSize.min, children: [
//               const Icon(Icons.lyrics_outlined, color: Colors.white70, size: 18),
//               const SizedBox(width: 8),
//               Text(_lyricsOpen ? 'Hide Lyrics' : 'Show Lyrics',
//                   style: GoogleFonts.inter(fontSize: 13,
//                       color: Colors.white70, fontWeight: FontWeight.w500)),
//             ]),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ─── Lyrics drawer ────────────────────────────────────────────────────────
//   Widget _buildLyricsDrawer(PlayerLoaded state) {
//     return ClipRRect(
//       borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.black.withOpacity(0.55),
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//             border: Border.all(color: AppColors.glassBorder, width: 0.8),
//           ),
//           child: Column(children: [
//             const SizedBox(height: 10),
//             Container(width: 36, height: 4,
//                 decoration: BoxDecoration(
//                     color: Colors.white30,
//                     borderRadius: BorderRadius.circular(2))),
//             const SizedBox(height: 12),
//             Text('Lyrics', style: GoogleFonts.inter(fontSize: 15,
//                 fontWeight: FontWeight.w700, color: Colors.white70)),
//             const SizedBox(height: 12),
//             Expanded(
//               child: state.lyrics.isEmpty
//                   ? Center(child: Text('No lyrics available',
//                       style: GoogleFonts.inter(
//                           fontSize: 14, color: Colors.white38)))
//                   : ListView.builder(
//                       controller: _lyricsScroll,
//                       physics: const BouncingScrollPhysics(),
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 24, vertical: 8),
//                       itemCount: state.lyrics.length,
//                       itemBuilder: (_, i) {
//                         final active = i == state.activeLyricIndex;
//                         return _LyricLine(
//                             line: state.lyrics[i],
//                             isActive: active);
//                       },
//                     ),
//             ),
//           ]),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLoading() => Scaffold(
//     backgroundColor: AppColors.backgroundDeep,
//     body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
//       CircularProgressIndicator(color: AppColors.accentViolet),
//       const SizedBox(height: 16),
//       Text('Loading…',
//           style: GoogleFonts.inter(color: AppColors.textSecondary)),
//     ])),
//   );
//
//   Widget _buildError(String msg) => Scaffold(
//     backgroundColor: AppColors.backgroundDeep,
//     body: Center(child: Text(msg,
//         style: GoogleFonts.inter(color: AppColors.error))),
//   );
//
//   Widget _buildEmpty() => Scaffold(
//     backgroundColor: AppColors.backgroundDeep,
//     body: Center(child: Text('Select a track to play',
//         style: GoogleFonts.inter(color: AppColors.textTertiary))),
//   );
// }
//
// // ─── Lyric line ───────────────────────────────────────────────────────────────
// class _LyricLine extends StatelessWidget {
//   final LyricLine line;
//   final bool isActive;
//   const _LyricLine({required this.line, required this.isActive});
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedDefaultTextStyle(
//       duration: const Duration(milliseconds: 250),
//       style: GoogleFonts.inter(
//         fontSize: isActive ? 18 : 14,
//         fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
//         color: isActive ? Colors.white : Colors.white38,
//         height: 1.5,
//       ),
//       child: Container(
//         height: 52,
//         alignment: Alignment.center,
//         child: Text(line.text, textAlign: TextAlign.center,
//             maxLines: 2, overflow: TextOverflow.ellipsis),
//       ),
//     );
//   }
// }
