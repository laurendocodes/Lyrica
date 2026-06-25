// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:lyrica_flutter/core/theme/app_colors.dart';
// import 'package:lyrica_flutter/presentation/pages/home/home_page.dart';
// import 'package:lyrica_flutter/presentation/pages/playlist/playlist_page.dart';
// import 'package:lyrica_flutter/presentation/pages/jam/sync_room_page.dart';
// import 'package:lyrica_flutter/presentation/pages/search/search_page.dart';
//
// /// Bottom-navigation shell that houses Home, Search, Playlists, and Jam tabs.
// class MainShell extends StatefulWidget {
//   const MainShell({super.key});
//   @override
//   State<MainShell> createState() => _MainShellState();
// }
//
// class _MainShellState extends State<MainShell> {
//   int _currentIndex = 0;
//
//   static const _pages = [
//     HomePage(),
//     SearchPage(),
//     PlaylistPage(),
//     SyncRoomPage(),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundDeep,
//       // IndexedStack keeps every page alive so cubits don't reset
//       body: IndexedStack(index: _currentIndex, children: _pages),
//       bottomNavigationBar: _GlassNavBar(
//         currentIndex: _currentIndex,
//         onTap: (i) => setState(() => _currentIndex = i),
//       ),
//     );
//   }
// }
//
// // ─── Frosted Glass Nav Bar ────────────────────────────────────────────────────
// class _GlassNavBar extends StatelessWidget {
//   final int currentIndex;
//   final ValueChanged<int> onTap;
//   const _GlassNavBar({required this.currentIndex, required this.onTap});
//
//   static const _items = [
//     _NavItem(icon: Icons.home_outlined,       activeIcon: Icons.home_rounded,       label: 'Home'),
//     _NavItem(icon: Icons.search_outlined,     activeIcon: Icons.search_rounded,     label: 'Search'),
//     _NavItem(icon: Icons.library_music_outlined, activeIcon: Icons.library_music_rounded, label: 'Library'),
//     _NavItem(icon: Icons.people_outline_rounded, activeIcon: Icons.people_rounded,  label: 'Jam'),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     final bottom = MediaQuery.of(context).padding.bottom;
//     return ClipRect(
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
//         child: Container(
//           padding: EdgeInsets.only(
//               top: 12, left: 8, right: 8, bottom: bottom + 8),
//           decoration: const BoxDecoration(
//             color: AppColors.glassDark,
//             border: Border(
//               top: BorderSide(color: AppColors.glassBorder, width: 0.8),
//             ),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               for (int i = 0; i < _items.length; i++)
//                 _NavTile(
//                   item: _items[i],
//                   isActive: i == currentIndex,
//                   onTap: () => onTap(i),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _NavItem {
//   final IconData icon;
//   final IconData activeIcon;
//   final String label;
//   const _NavItem(
//       {required this.icon, required this.activeIcon, required this.label});
// }
//
// class _NavTile extends StatelessWidget {
//   final _NavItem item;
//   final bool isActive;
//   final VoidCallback onTap;
//   const _NavTile(
//       {required this.item, required this.isActive, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       behavior: HitTestBehavior.opaque,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 250),
//         curve: Curves.easeOutCubic,
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
//         decoration: isActive
//             ? BoxDecoration(
//                 color: AppColors.accentViolet.withOpacity(0.18),
//                 borderRadius: BorderRadius.circular(14),
//                 border: Border.all(
//                     color: AppColors.accentViolet.withOpacity(0.25),
//                     width: 0.8),
//               )
//             : const BoxDecoration(),
//         child: Column(mainAxisSize: MainAxisSize.min, children: [
//           AnimatedSwitcher(
//             duration: const Duration(milliseconds: 200),
//             child: Icon(
//               isActive ? item.activeIcon : item.icon,
//               key: ValueKey(isActive),
//               color: isActive
//                   ? AppColors.accentViolet
//                   : AppColors.textTertiary,
//               size: 24,
//             ),
//           ),
//           const SizedBox(height: 3),
//           Text(
//             item.label,
//             style: GoogleFonts.inter(
//               fontSize: 10,
//               fontWeight:
//                   isActive ? FontWeight.w700 : FontWeight.w400,
//               color: isActive
//                   ? AppColors.accentViolet
//                   : AppColors.textTertiary,
//               letterSpacing: 0.2,
//             ),
//           ),
//         ]),
//       ),
//     );
//   }
// }
