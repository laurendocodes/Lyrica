// import 'dart:math';
// import 'dart:ui';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:lyrica_flutter/core/theme/app_colors.dart';
// import 'package:lyrica_flutter/features/sync/domain/entities/room_member.dart';
// import 'package:lyrica_flutter/features/sync/domain/entities/sync_room.dart';
// import 'package:lyrica_flutter/features/sync/presentation/providers/sync_cubit.dart';
//
// class SyncRoomPage extends StatefulWidget {
//   const SyncRoomPage({super.key});
//   @override
//   State<SyncRoomPage> createState() => _SyncRoomPageState();
// }
//
// class _SyncRoomPageState extends State<SyncRoomPage>
//     with TickerProviderStateMixin {
//   late final AnimationController _orbCtrl;
//   late final AnimationController _pulseCtrl;
//
//   @override
//   void initState() {
//     super.initState();
//     _orbCtrl = AnimationController(
//         vsync: this, duration: const Duration(seconds: 10))
//       ..repeat(reverse: true);
//     _pulseCtrl = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 1800))
//       ..repeat(reverse: true);
//     context.read<SyncCubit>().loadRooms();
//   }
//
//   @override
//   void dispose() {
//     _orbCtrl.dispose();
//     _pulseCtrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<SyncCubit, SyncCubitState>(
//       builder: (context, state) {
//         if (state is SyncLoading || state is SyncInitial) {
//           return _loadingScaffold();
//         }
//         if (state is SyncConnecting) {
//           return _connectingScaffold(state.room.roomName);
//         }
//         if (state is SyncInRoom) {
//           return _buildInRoomView(context, state);
//         }
//         if (state is SyncRoomsLoaded) {
//           return _buildRoomsListView(context, state);
//         }
//         if (state is SyncError) {
//           return _errorScaffold(state.message);
//         }
//         return _loadingScaffold();
//       },
//     );
//   }
//
//   // ─── Room Discovery ──────────────────────────────────────────────────────
//   Widget _buildRoomsListView(BuildContext context, SyncRoomsLoaded state) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundDeep,
//       body: Stack(children: [
//         AnimatedBuilder(
//           animation: _orbCtrl,
//           builder: (_, __) => Stack(children: [
//             Positioned(top: -60 + _orbCtrl.value * 30, left: -50,
//               child: _Orb(240, AppColors.orbViolet)),
//             Positioned(bottom: 100 + _orbCtrl.value * -20, right: -50,
//               child: _Orb(190, AppColors.orbCyan)),
//           ]),
//         ),
//         SafeArea(child: CustomScrollView(
//           physics: const BouncingScrollPhysics(),
//           slivers: [
//             SliverToBoxAdapter(child: Padding(
//               padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
//               child: Column(crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Lyrica Jam',
//                       style: GoogleFonts.inter(fontSize: 28,
//                           fontWeight: FontWeight.w800,
//                           color: AppColors.textPrimary, letterSpacing: -0.5)),
//                   const SizedBox(height: 4),
//                   Text('Listen together in real time',
//                       style: GoogleFonts.inter(fontSize: 13,
//                           color: AppColors.textTertiary)),
//                   const SizedBox(height: 20),
//                   // Create room button
//                   _GlassButton(
//                     label: '+ Create a Room',
//                     onTap: () => _showCreateRoomDialog(context),
//                     gradient: const LinearGradient(
//                       colors: [AppColors.accentViolet, AppColors.accentBlue]),
//                   ),
//                   const SizedBox(height: 24),
//                   Text('Live Rooms',
//                       style: GoogleFonts.inter(fontSize: 16,
//                           fontWeight: FontWeight.w700,
//                           color: AppColors.textPrimary)),
//                 ],
//               ),
//             )),
//
//             SliverList(delegate: SliverChildBuilderDelegate(
//               (ctx, i) => _RoomCard(
//                 room: state.rooms[i],
//                 pulseCtrl: _pulseCtrl,
//                 onJoin: () => ctx.read<SyncCubit>().joinRoom(
//                     state.rooms[i], 'me'),
//               ),
//               childCount: state.rooms.length,
//             )),
//
//             const SliverToBoxAdapter(child: SizedBox(height: 120)),
//           ],
//         )),
//       ]),
//     );
//   }
//
//   // ─── In-Room View ────────────────────────────────────────────────────────
//   Widget _buildInRoomView(BuildContext context, SyncInRoom state) {
//     final room = state.room;
//     return Scaffold(
//       backgroundColor: AppColors.backgroundDeep,
//       body: Stack(children: [
//         // Dynamic album blurred bg
//         if (room.currentTrack?.coverUrl != null)
//           Opacity(
//             opacity: 0.18,
//             child: CachedNetworkImage(
//               imageUrl: room.currentTrack!.coverUrl!,
//               width: double.infinity, height: double.infinity, fit: BoxFit.cover,
//               errorWidget: (_, __, ___) => const SizedBox.shrink(),
//             ),
//           ),
//         BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
//           child: Container(color: AppColors.backgroundDeep.withOpacity(0.80)),
//         ),
//
//         // Animated connection pulse orb
//         AnimatedBuilder(
//           animation: _pulseCtrl,
//           builder: (_, __) {
//             final v = _pulseCtrl.value;
//             return Center(child: Opacity(
//               opacity: 0.06 + v * 0.06,
//               child: Container(
//                 width: 340 + v * 40, height: 340 + v * 40,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: AppColors.accentViolet.withOpacity(0.5),
//                 ),
//               ),
//             ));
//           },
//         ),
//
//         SafeArea(child: Column(children: [
//           // Top bar
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 GestureDetector(
//                   onTap: () => context.read<SyncCubit>().leaveRoom(),
//                   child: _glassChip(
//                     child: Row(mainAxisSize: MainAxisSize.min, children: [
//                       const Icon(Icons.logout_rounded,
//                           color: AppColors.textSecondary, size: 16),
//                       const SizedBox(width: 6),
//                       Text('Leave', style: GoogleFonts.inter(
//                           fontSize: 13, color: AppColors.textSecondary)),
//                     ]),
//                   ),
//                 ),
//                 _ConnectionPulseDot(state: room.connectionState),
//                 _glassChip(child: GestureDetector(
//                   onTap: () {
//                     if (room.inviteCode != null) {
//                       Clipboard.setData(
//                           ClipboardData(text: room.inviteCode!));
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Invite code copied!',
//                             style: GoogleFonts.inter()),
//                           backgroundColor: AppColors.accentViolet,
//                           duration: const Duration(seconds: 2)),
//                       );
//                     }
//                   },
//                   child: Row(mainAxisSize: MainAxisSize.min, children: [
//                     const Icon(Icons.copy_rounded,
//                         color: AppColors.textSecondary, size: 14),
//                     const SizedBox(width: 6),
//                     Text(room.inviteCode ?? 'No code',
//                         style: GoogleFonts.inter(
//                             fontSize: 12, color: AppColors.textSecondary,
//                             fontWeight: FontWeight.w600)),
//                   ]),
//                 )),
//               ],
//             ),
//           ),
//
//           const SizedBox(height: 20),
//
//           // Room name
//           Text(room.roomName,
//               style: GoogleFonts.inter(fontSize: 22,
//                   fontWeight: FontWeight.w800,
//                   color: AppColors.textPrimary, letterSpacing: -0.4)),
//           const SizedBox(height: 4),
//           Text('${room.listenerCount} listening',
//               style: GoogleFonts.inter(fontSize: 13,
//                   color: AppColors.textTertiary)),
//
//           const SizedBox(height: 28),
//
//           // Current track
//           if (room.currentTrack != null)
//             _CurrentTrackWidget(room: room, pulseCtrl: _pulseCtrl),
//
//           const SizedBox(height: 32),
//
//           // Listener bubbles
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Listeners',
//                     style: GoogleFonts.inter(fontSize: 15,
//                         fontWeight: FontWeight.w700,
//                         color: AppColors.textPrimary)),
//                 const SizedBox(height: 16),
//                 Wrap(
//                   spacing: 16,
//                   runSpacing: 16,
//                   children: room.members.map((m) =>
//                       _ListenerBubble(member: m, pulseTick: state.pulseTick))
//                       .toList(),
//                 ),
//               ],
//             ),
//           ),
//         ])),
//       ]),
//     );
//   }
//
//   void _showCreateRoomDialog(BuildContext context) {
//     final ctrl = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (ctx) => BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
//         child: AlertDialog(
//           backgroundColor: AppColors.backgroundSurface,
//           shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//               side: const BorderSide(color: AppColors.glassBorder)),
//           title: Text('Create a Room', style: GoogleFonts.inter(
//               fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
//           content: TextField(
//             controller: ctrl,
//             style: GoogleFonts.inter(color: AppColors.textPrimary),
//             cursorColor: AppColors.accentViolet,
//             decoration: InputDecoration(
//               hintText: 'Room name…',
//               hintStyle: GoogleFonts.inter(color: AppColors.textTertiary),
//               filled: true,
//               fillColor: AppColors.glassLight,
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide.none,
//               ),
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(ctx).pop(),
//               child: Text('Cancel', style: GoogleFonts.inter(
//                   color: AppColors.textTertiary)),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.accentViolet,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10)),
//               ),
//               onPressed: () {
//                 final name = ctrl.text.trim();
//                 if (name.isNotEmpty) {
//                   Navigator.of(ctx).pop();
//                   context.read<SyncCubit>().createRoom(
//                     roomName: name,
//                     userId: 'me',
//                     displayName: 'You',
//                   );
//                 }
//               },
//               child: Text('Create', style: GoogleFonts.inter(
//                   color: Colors.white, fontWeight: FontWeight.w700)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _loadingScaffold() => Scaffold(
//     backgroundColor: AppColors.backgroundDeep,
//     body: Center(child: CircularProgressIndicator(
//         color: AppColors.accentViolet)),
//   );
//
//   Widget _connectingScaffold(String roomName) => Scaffold(
//     backgroundColor: AppColors.backgroundDeep,
//     body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
//       CircularProgressIndicator(color: AppColors.accentViolet),
//       const SizedBox(height: 20),
//       Text('Joining $roomName…',
//           style: GoogleFonts.inter(color: AppColors.textSecondary)),
//     ])),
//   );
//
//   Widget _errorScaffold(String msg) => Scaffold(
//     backgroundColor: AppColors.backgroundDeep,
//     body: Center(child: Text(msg,
//         style: GoogleFonts.inter(color: AppColors.error))),
//   );
//
//   Widget _glassChip({required Widget child}) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(20),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//           decoration: BoxDecoration(
//             color: AppColors.glassLight,
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(color: AppColors.glassBorder, width: 0.7),
//           ),
//           child: child,
//         ),
//       ),
//     );
//   }
// }
//
// // ─── Current Track Widget ─────────────────────────────────────────────────────
// class _CurrentTrackWidget extends StatelessWidget {
//   final SyncRoom room;
//   final AnimationController pulseCtrl;
//   const _CurrentTrackWidget({required this.room, required this.pulseCtrl});
//
//   @override
//   Widget build(BuildContext context) {
//     final track = room.currentTrack!;
//     final progress = room.durationMs > 0
//         ? (room.progressMs / room.durationMs).clamp(0.0, 1.0)
//         : 0.0;
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(20),
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
//           child: Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: AppColors.glassMedium,
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: AppColors.glassBorder, width: 0.8),
//             ),
//             child: Row(children: [
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: CachedNetworkImage(
//                   imageUrl: track.coverUrl ?? '',
//                   width: 60, height: 60, fit: BoxFit.cover,
//                   errorWidget: (_, __, ___) => Container(
//                       width: 60, height: 60,
//                       color: AppColors.backgroundSurface,
//                       child: const Icon(Icons.music_note,
//                           color: AppColors.textTertiary)),
//                 ),
//               ),
//               const SizedBox(width: 14),
//               Expanded(child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis,
//                       style: GoogleFonts.inter(fontSize: 15,
//                           fontWeight: FontWeight.w700,
//                           color: AppColors.textPrimary)),
//                   const SizedBox(height: 3),
//                   Text(track.artistName, maxLines: 1, overflow: TextOverflow.ellipsis,
//                       style: GoogleFonts.inter(fontSize: 12,
//                           color: AppColors.textTertiary)),
//                   const SizedBox(height: 8),
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(4),
//                     child: LinearProgressIndicator(
//                       value: progress,
//                       backgroundColor: Colors.white12,
//                       valueColor: const AlwaysStoppedAnimation<Color>(
//                           AppColors.accentViolet),
//                       minHeight: 3,
//                     ),
//                   ),
//                 ],
//               )),
//               const SizedBox(width: 10),
//               Icon(room.isPlaying
//                   ? Icons.graphic_eq_rounded
//                   : Icons.pause_rounded,
//                   color: AppColors.accentViolet, size: 22),
//             ]),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// extension _RoomExt on SyncRoom {
//   int get durationMs => currentTrack?.durationMs ?? 0;
// }
//
// // ─── Room Card (discovery) ────────────────────────────────────────────────────
// class _RoomCard extends StatelessWidget {
//   final SyncRoom room;
//   final AnimationController pulseCtrl;
//   final VoidCallback onJoin;
//   const _RoomCard(
//       {required this.room, required this.pulseCtrl, required this.onJoin});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(18),
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
//           child: Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: AppColors.glassLight,
//               borderRadius: BorderRadius.circular(18),
//               border: Border.all(color: AppColors.glassBorder, width: 0.8),
//             ),
//             child: Column(crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(children: [
//                   Expanded(child: Text(room.roomName, maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: GoogleFonts.inter(fontSize: 16,
//                           fontWeight: FontWeight.w700,
//                           color: AppColors.textPrimary))),
//                   AnimatedBuilder(
//                     animation: pulseCtrl,
//                     builder: (_, __) => Container(
//                       width: 8, height: 8,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: AppColors.online,
//                         boxShadow: [BoxShadow(
//                           color: AppColors.online.withOpacity(
//                               0.4 + pulseCtrl.value * 0.4),
//                           blurRadius: 6 + pulseCtrl.value * 4,
//                           spreadRadius: 1,
//                         )],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 6),
//                   Text('LIVE', style: GoogleFonts.inter(fontSize: 10,
//                       fontWeight: FontWeight.w700,
//                       color: AppColors.online, letterSpacing: 1)),
//                 ]),
//                 if (room.currentTrack != null) ...[
//                   const SizedBox(height: 10),
//                   Row(children: [
//                     const Icon(Icons.music_note_rounded,
//                         color: AppColors.textTertiary, size: 14),
//                     const SizedBox(width: 6),
//                     Expanded(child: Text(
//                       '${room.currentTrack!.title} — ${room.currentTrack!.artistName}',
//                       maxLines: 1, overflow: TextOverflow.ellipsis,
//                       style: GoogleFonts.inter(fontSize: 12,
//                           color: AppColors.textSecondary))),
//                   ]),
//                 ],
//                 const SizedBox(height: 14),
//                 Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     // Member avatars
//                     SizedBox(
//                       height: 28,
//                       child: Stack(
//                         children: [
//                           for (int i = 0;
//                               i < min(4, room.members.length); i++)
//                             Positioned(
//                               left: i * 20.0,
//                               child: Container(
//                                 width: 28, height: 28,
//                                 decoration: BoxDecoration(
//                                   shape: BoxShape.circle,
//                                   gradient: LinearGradient(
//                                     colors: _avatarColors(i)),
//                                   border: Border.all(
//                                       color: AppColors.backgroundDeep,
//                                       width: 1.5),
//                                 ),
//                                 child: Center(child: Text(
//                                   room.members[i].displayName[0].toUpperCase(),
//                                   style: GoogleFonts.inter(fontSize: 11,
//                                       fontWeight: FontWeight.w700,
//                                       color: Colors.white),
//                                 )),
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                     Text('${room.listenerCount} listening',
//                         style: GoogleFonts.inter(fontSize: 12,
//                             color: AppColors.textTertiary)),
//                     GestureDetector(
//                       onTap: onJoin,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 18, vertical: 8),
//                         decoration: BoxDecoration(
//                           gradient: const LinearGradient(
//                             colors: [AppColors.accentViolet,
//                               AppColors.accentBlue]),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Text('Join', style: GoogleFonts.inter(
//                             fontSize: 13, fontWeight: FontWeight.w700,
//                             color: Colors.white)),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   List<Color> _avatarColors(int idx) {
//     final palettes = [
//       [AppColors.accentViolet, AppColors.accentBlue],
//       [AppColors.accentRose, AppColors.accentViolet],
//       [AppColors.accentCyan, AppColors.accentBlue],
//       [AppColors.accentAmber, AppColors.accentRose],
//     ];
//     return palettes[idx % palettes.length];
//   }
// }
//
// // ─── Listener Bubble ──────────────────────────────────────────────────────────
// class _ListenerBubble extends StatelessWidget {
//   final RoomMember member;
//   final int pulseTick;
//   const _ListenerBubble({required this.member, required this.pulseTick});
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(mainAxisSize: MainAxisSize.min, children: [
//       Stack(children: [
//         AnimatedContainer(
//           duration: const Duration(milliseconds: 600),
//           width: member.isHost ? 62 : 52,
//           height: member.isHost ? 62 : 52,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             gradient: LinearGradient(
//               colors: member.isHost
//                   ? [AppColors.accentViolet, AppColors.accentBlue]
//                   : [AppColors.backgroundSurface, AppColors.backgroundMid],
//             ),
//             border: Border.all(
//               color: member.isActive
//                   ? AppColors.online
//                   : AppColors.glassBorder,
//               width: member.isHost ? 2.5 : 1.5,
//             ),
//             boxShadow: member.isActive
//                 ? [BoxShadow(
//                     color: AppColors.online.withOpacity(0.35),
//                     blurRadius: 10,
//                     spreadRadius: 1,
//                   )]
//                 : [],
//           ),
//           child: Center(child: Text(
//             member.displayName[0].toUpperCase(),
//             style: GoogleFonts.inter(
//                 fontSize: member.isHost ? 20 : 16,
//                 fontWeight: FontWeight.w800,
//                 color: Colors.white),
//           )),
//         ),
//         if (member.isHost)
//           Positioned(bottom: 0, right: 0, child: Container(
//             width: 18, height: 18,
//             decoration: BoxDecoration(
//               color: AppColors.accentAmber,
//               shape: BoxShape.circle,
//               border: Border.all(color: AppColors.backgroundDeep, width: 1.5),
//             ),
//             child: const Icon(Icons.star_rounded,
//                 color: Colors.white, size: 11),
//           )),
//       ]),
//       const SizedBox(height: 6),
//       Text(
//         member.isHost ? '${member.displayName}\n(Host)' : member.displayName,
//         textAlign: TextAlign.center,
//         maxLines: 2,
//         style: GoogleFonts.inter(
//             fontSize: 11,
//             color: member.isActive
//                 ? AppColors.textSecondary
//                 : AppColors.textTertiary),
//       ),
//     ]);
//   }
// }
//
// // ─── Connection pulse dot ─────────────────────────────────────────────────────
// class _ConnectionPulseDot extends StatelessWidget {
//   final SyncConnectionState state;
//   const _ConnectionPulseDot({required this.state});
//
//   @override
//   Widget build(BuildContext context) {
//     final color = state == SyncConnectionState.connected
//         ? AppColors.online
//         : state == SyncConnectionState.connecting
//             ? AppColors.warning
//             : AppColors.error;
//     final label = state == SyncConnectionState.connected
//         ? 'LIVE'
//         : state == SyncConnectionState.connecting
//             ? 'CONNECTING'
//             : 'OFFLINE';
//     return Row(mainAxisSize: MainAxisSize.min, children: [
//       Container(
//         width: 8, height: 8,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle, color: color,
//           boxShadow: [BoxShadow(
//             color: color.withOpacity(0.6), blurRadius: 6, spreadRadius: 1)],
//         ),
//       ),
//       const SizedBox(width: 6),
//       Text(label, style: GoogleFonts.inter(
//           fontSize: 11, fontWeight: FontWeight.w700,
//           color: color, letterSpacing: 1)),
//     ]);
//   }
// }
//
// // ─── Glass Button ─────────────────────────────────────────────────────────────
// class _GlassButton extends StatelessWidget {
//   final String label;
//   final VoidCallback onTap;
//   final Gradient? gradient;
//   const _GlassButton({required this.label, required this.onTap, this.gradient});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(vertical: 14),
//         decoration: BoxDecoration(
//           gradient: gradient,
//           color: gradient == null ? AppColors.glassLight : null,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: AppColors.glassBorder, width: 0.8),
//         ),
//         child: Center(child: Text(label, style: GoogleFonts.inter(
//             fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white))),
//       ),
//     );
//   }
// }
//
// // ─── Orb ─────────────────────────────────────────────────────────────────────
// class _Orb extends StatelessWidget {
//   final double size;
//   final Color color;
//   const _Orb(this.size, this.color);
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
