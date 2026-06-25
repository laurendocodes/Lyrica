// import 'dart:ui';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:lyrica_flutter/core/theme/app_colors.dart';
// import 'package:lyrica_flutter/core/services/mock_data_service.dart';
// import 'package:lyrica_flutter/features/player/domain/entities/track.dart';
// import 'package:lyrica_flutter/features/player/presentation/providers/player_cubit.dart';
// import 'package:lyrica_flutter/presentation/pages/player/player_page.dart';
//
// class SearchPage extends StatefulWidget {
//   const SearchPage({super.key});
//   @override
//   State<SearchPage> createState() => _SearchPageState();
// }
//
// class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
//   final TextEditingController _ctrl = TextEditingController();
//   final FocusNode _focus = FocusNode();
//   List<Track> _results = MockDataService.recentTracks;
//   bool _hasQuery = false;
//   late final AnimationController _orbCtrl;
//
//   @override
//   void initState() {
//     super.initState();
//     _orbCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 10))
//       ..repeat(reverse: true);
//     _ctrl.addListener(_onQueryChanged);
//     WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
//   }
//
//   void _onQueryChanged() {
//     final q = _ctrl.text.trim();
//     setState(() {
//       _hasQuery = q.isNotEmpty;
//       _results = MockDataService.queryTracks(q);
//     });
//   }
//
//   @override
//   void dispose() {
//     _orbCtrl.dispose();
//     _ctrl.dispose();
//     _focus.dispose();
//     super.dispose();
//   }
//
//   void _openPlayer(Track track) {
//     context.read<PlayerCubit>().playTrack(track);
//     Navigator.of(context).push(PageRouteBuilder(
//       pageBuilder: (_, a, __) => const PlayerPage(),
//       transitionsBuilder: (_, a, __, child) => SlideTransition(
//         position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
//             .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
//         child: child,
//       ),
//       transitionDuration: const Duration(milliseconds: 400),
//     ));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundDeep,
//       body: Stack(children: [
//         // Orbs
//         AnimatedBuilder(
//           animation: _orbCtrl,
//           builder: (_, __) => Stack(children: [
//             Positioned(top: -60 + _orbCtrl.value * 30, right: -50,
//               child: _Orb(size: 230, color: AppColors.orbViolet)),
//             Positioned(bottom: 120 + _orbCtrl.value * 20, left: -40,
//               child: _Orb(size: 170, color: AppColors.orbBlue)),
//           ]),
//         ),
//         SafeArea(child: Column(children: [
//           // Search bar
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
//             child: Row(children: [
//               GestureDetector(
//                 onTap: () => Navigator.of(context).pop(),
//                 child: const Icon(Icons.arrow_back_ios_new_rounded,
//                     color: AppColors.textPrimary, size: 20),
//               ),
//               const SizedBox(width: 12),
//               Expanded(child: _GlassTextField(
//                 controller: _ctrl,
//                 focusNode: _focus,
//                 hasQuery: _hasQuery,
//                 onClear: () => _ctrl.clear(),
//               )),
//             ]),
//           ),
//           // Label
//           Padding(
//             padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
//             child: Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 _hasQuery
//                     ? '${_results.length} result${_results.length == 1 ? '' : 's'}'
//                     : 'Recent tracks',
//                 style: GoogleFonts.inter(fontSize: 12,
//                     color: AppColors.textTertiary, letterSpacing: 0.4),
//               ),
//             ),
//           ),
//           // Results
//           Expanded(
//             child: _results.isEmpty
//                 ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
//                     const Icon(Icons.search_off_rounded,
//                         color: AppColors.textTertiary, size: 52),
//                     const SizedBox(height: 14),
//                     Text('No results for\n"${_ctrl.text}"',
//                         textAlign: TextAlign.center,
//                         style: GoogleFonts.inter(
//                             fontSize: 15, color: AppColors.textSecondary)),
//                   ]))
//                 : ListView.builder(
//                     physics: const BouncingScrollPhysics(),
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     itemCount: _results.length,
//                     itemBuilder: (_, i) => _ResultRow(
//                       track: _results[i],
//                       query: _ctrl.text.trim(),
//                       onTap: () => _openPlayer(_results[i]),
//                     ),
//                   ),
//           ),
//         ])),
//       ]),
//     );
//   }
// }
//
// // ─── Glass text field ────────────────────────────────────────────────────────
// class _GlassTextField extends StatelessWidget {
//   final TextEditingController controller;
//   final FocusNode focusNode;
//   final bool hasQuery;
//   final VoidCallback onClear;
//   const _GlassTextField(
//       {required this.controller, required this.focusNode,
//        required this.hasQuery, required this.onClear});
//
//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(14),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
//         child: Container(
//           decoration: BoxDecoration(
//             color: AppColors.glassMedium,
//             borderRadius: BorderRadius.circular(14),
//             border: Border.all(color: AppColors.glassBorder, width: 0.8),
//           ),
//           child: TextField(
//             controller: controller,
//             focusNode: focusNode,
//             style: GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary),
//             cursorColor: AppColors.accentViolet,
//             decoration: InputDecoration(
//               hintText: 'Songs, artists, albums…',
//               hintStyle: GoogleFonts.inter(fontSize: 15, color: AppColors.textTertiary),
//               prefixIcon: const Icon(Icons.search_rounded,
//                   color: AppColors.textTertiary, size: 20),
//               suffixIcon: hasQuery
//                   ? IconButton(
//                       icon: const Icon(Icons.close_rounded,
//                           color: AppColors.textTertiary, size: 18),
//                       onPressed: onClear)
//                   : null,
//               border: InputBorder.none,
//               contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ─── Result row ──────────────────────────────────────────────────────────────
// class _ResultRow extends StatelessWidget {
//   final Track track;
//   final String query;
//   final VoidCallback onTap;
//   const _ResultRow({required this.track, required this.query, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 10),
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
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(10),
//                   child: CachedNetworkImage(
//                     imageUrl: track.coverUrl ?? '',
//                     width: 50, height: 50, fit: BoxFit.cover,
//                     errorWidget: (_, __, ___) => _placeholder(track),
//                     placeholder: (_, __) => _placeholder(track),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _highlightText(track.title, query),
//                     const SizedBox(height: 3),
//                     Text('${track.artistName} · ${track.albumName}',
//                         maxLines: 1, overflow: TextOverflow.ellipsis,
//                         style: GoogleFonts.inter(
//                             fontSize: 11, color: AppColors.textTertiary)),
//                   ],
//                 )),
//                 const SizedBox(width: 8),
//                 Text(track.formattedDuration,
//                     style: GoogleFonts.inter(
//                         fontSize: 11, color: AppColors.textTertiary)),
//                 const SizedBox(width: 8),
//                 const Icon(Icons.play_circle_outline_rounded,
//                     color: AppColors.accentViolet, size: 22),
//               ]),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _highlightText(String text, String query) {
//     if (query.isEmpty) {
//       return Text(text, maxLines: 1, overflow: TextOverflow.ellipsis,
//           style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600,
//               color: AppColors.textPrimary));
//     }
//     final lo = text.toLowerCase();
//     final qi = query.toLowerCase();
//     final idx = lo.indexOf(qi);
//     if (idx == -1) {
//       return Text(text, maxLines: 1, overflow: TextOverflow.ellipsis,
//           style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600,
//               color: AppColors.textPrimary));
//     }
//     return RichText(maxLines: 1, overflow: TextOverflow.ellipsis,
//       text: TextSpan(
//         style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
//         children: [
//           TextSpan(text: text.substring(0, idx),
//               style: const TextStyle(color: AppColors.textPrimary)),
//           TextSpan(text: text.substring(idx, idx + query.length),
//               style: const TextStyle(color: AppColors.accentViolet)),
//           TextSpan(text: text.substring(idx + query.length),
//               style: const TextStyle(color: AppColors.textPrimary)),
//         ],
//       ),
//     );
//   }
//
//   Widget _placeholder(Track track) {
//     final pairs = [
//       [AppColors.accentViolet, AppColors.accentBlue],
//       [AppColors.accentRose, AppColors.accentViolet],
//       [AppColors.accentCyan, AppColors.accentBlue],
//     ];
//     final idx = track.id.hashCode.abs() % pairs.length;
//     return Container(
//       decoration: BoxDecoration(gradient: LinearGradient(
//         colors: pairs[idx], begin: Alignment.topLeft, end: Alignment.bottomRight)),
//       child: const Icon(Icons.music_note, color: Colors.white54, size: 20),
//     );
//   }
// }
//
// // ─── Orb ─────────────────────────────────────────────────────────────────────
// class _Orb extends StatelessWidget {
//   final double size;
//   final Color color;
//   const _Orb({required this.size, required this.color});
//   @override
//   Widget build(BuildContext context) {
//     return ImageFiltered(
//       imageFilter: ImageFilter.blur(sigmaX: 55, sigmaY: 55),
//       child: Container(
//         width: size, height: size,
//         decoration: BoxDecoration(shape: BoxShape.circle, color: color),
//       ),
//     );
//   }
// }
