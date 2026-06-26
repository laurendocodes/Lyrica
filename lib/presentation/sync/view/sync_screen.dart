import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/viewmodel/auth_cubit.dart';
import '../../player/viewmodel/player_cubit.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/track_tile.dart';
import '../viewmodel/sync_cubit.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  final _roomCodeCtrl = TextEditingController();

  @override
  void dispose() {
    _roomCodeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        // Ambient background
        Positioned(
          top: -60, right: -60,
          child: Container(
            width: 220, height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.accentSecondary.withOpacity(0.2),
                Colors.transparent,
              ]),
            ),
          ),
        ),
        SafeArea(
          child: BlocBuilder<SyncCubit, SyncState>(
            builder: (context, syncState) {
              return syncState is SyncConnected
                  ? _ConnectedView(state: syncState)
                  : _DisconnectedView(roomCodeCtrl: _roomCodeCtrl);
            },
          ),
        ),
      ]),
    );
  }
}

// ── Disconnected ──────────────────────────────────────────────────────────────

class _DisconnectedView extends StatelessWidget {
  final TextEditingController roomCodeCtrl;
  const _DisconnectedView({required this.roomCodeCtrl});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  ShaderMask(
                    shaderCallback: (b) => AppGradients.brand.createShader(b),
                    child: const Icon(Icons.people_rounded,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 10),
                  const Text('Listen Together',
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                ]),
                const SizedBox(height: 6),
                const Text(
                  'Create a room or join one to sync music with friends in real time.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 32),

                // Create room card
                _CreateRoomCard(),
                const SizedBox(height: 16),

                // Join room card
                _JoinRoomCard(ctrl: roomCodeCtrl),
                const SizedBox(height: 32),

                // Friends activity section
                const _FriendsActivity(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CreateRoomCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.brandGradient),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Create a Room',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              SizedBox(height: 2),
              Text('Invite friends to listen with you',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ]),
          ),
        ]),
        const SizedBox(height: 16),
        // Currently playing preview
        BlocBuilder<PlayerCubit, PlayerState>(
          buildWhen: (p, c) => p.currentTrack?.id != c.currentTrack?.id,
          builder: (_, state) {
            if (state.currentTrack != null) {
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.glassDark,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  AlbumArtWidget(
                      url: state.currentTrack!.albumArtUrl, size: 36, borderRadius: 6),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(state.currentTrack!.title,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(state.currentTrack!.artist,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ]),
                  ),
                  const Icon(Icons.music_note_rounded,
                      color: AppColors.accentPrimary, size: 16),
                ]),
              );
            }
            return const Text('No track currently playing',
                style: TextStyle(fontSize: 12, color: AppColors.textDisabled));
          },
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: GlassButton(
            label: 'Create Room',
            icon: Icons.wifi_tethering_rounded,
            onTap: () {
              final authState = context.read<AuthCubit>().state;
              if (authState is AuthAuthenticated) {
                context.read<SyncCubit>().createRoom(
                    authState.user.id, authState.user.username);
              }
            },
          ),
        ),
      ]),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.06, end: 0);
  }
}

class _JoinRoomCard extends StatelessWidget {
  final TextEditingController ctrl;
  const _JoinRoomCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.glass,
              border: Border.all(color: AppColors.glassBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.login_rounded,
                color: AppColors.accentSecondary, size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Join a Room',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              SizedBox(height: 2),
              Text("Enter a friend's room code",
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ]),
          ),
        ]),
        const SizedBox(height: 16),
        TextField(
          controller: ctrl,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 15,
              letterSpacing: 2, fontWeight: FontWeight.w600),
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: 'ROOM-CODE',
            hintStyle: const TextStyle(color: AppColors.textDisabled,
                letterSpacing: 2, fontSize: 14),
            filled: true,
            fillColor: AppColors.glassDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.glassBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.glassBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.accentSecondary, width: 1.5),
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear_rounded,
                  color: AppColors.textDisabled, size: 18),
              onPressed: ctrl.clear,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: GlassButton(
            label: 'Join Room',
            isOutlined: true,
            onTap: () {
              if (ctrl.text.trim().isNotEmpty) {
                context.read<SyncCubit>().joinRoom(ctrl.text.trim());
              }
            },
          ),
        ),
      ]),
    ).animate(delay: 80.ms).fadeIn(duration: 300.ms).slideY(begin: 0.06, end: 0);
  }
}

class _FriendsActivity extends StatelessWidget {
  const _FriendsActivity();

  // Mock data — in a real app this comes from a social feed API
  static final _activities = [
    _Activity('Alex', 'Blinding Lights', 'The Weeknd', '2m ago'),
    _Activity('Sam', 'Levitating', 'Dua Lipa', '15m ago'),
    _Activity('Jordan', 'Stay', 'The Kid LAROI', '1h ago'),
    _Activity('Riley', 'As It Was', 'Harry Styles', '2h ago'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Friends Activity',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary)),
      const SizedBox(height: 4),
      const Text("What your friends are listening to",
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      const SizedBox(height: 16),
      ..._activities.asMap().entries.map((e) => _ActivityTile(
            activity: e.value,
            delay: e.key * 60,
          )),
    ]);
  }
}

class _Activity {
  final String username, track, artist, time;
  const _Activity(this.username, this.track, this.artist, this.time);
}

class _ActivityTile extends StatelessWidget {
  final _Activity activity;
  final int delay;
  const _ActivityTile({required this.activity, required this.delay});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        // Avatar
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppColors.brandGradient[delay % 3],
                AppColors.brandGradient[(delay % 3 + 1) % 3],
              ],
            ),
          ),
          child: Center(
            child: Text(
              activity.username[0].toUpperCase(),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Text
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            RichText(
              text: TextSpan(children: [
                TextSpan(
                  text: activity.username,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                ),
                const TextSpan(
                  text: ' is listening to',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ]),
            ),
            const SizedBox(height: 3),
            Text('${activity.track} · ${activity.artist}',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ),

        // Time + join icon
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(activity.time,
              style: const TextStyle(fontSize: 11, color: AppColors.textDisabled)),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Joining ${activity.username}\'s session...'),
                  backgroundColor: AppColors.accentPrimary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: AppColors.brandGradient),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Join',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ),
          ),
        ]),
      ]),
    ).animate(delay: Duration(milliseconds: delay)).fadeIn(duration: 300.ms).slideX(begin: 0.04, end: 0);
  }
}

// ── Connected ─────────────────────────────────────────────────────────────────

class _ConnectedView extends StatelessWidget {
  final SyncConnected state;
  const _ConnectedView({required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(children: [
        // Room header
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            Row(children: [
              Container(
                width: 12, height: 12,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withOpacity(0.6),
                      blurRadius: 8, spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(state.isHost ? 'You are hosting' : 'Connected as listener',
                  style: const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
              const Spacer(),
              Icon(Icons.people_rounded,
                  color: AppColors.textSecondary, size: 16),
              const SizedBox(width: 4),
              Text('${state.participantCount}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
            ]),
            const SizedBox(height: 16),

            // Room code
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.glassDark,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Room Code',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text(
                      state.roomId.length > 16
                          ? state.roomId.substring(0, 16).toUpperCase()
                          : state.roomId.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: 1.5),
                    ),
                  ]),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: state.roomId));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Room code copied!'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AppColors.accentPrimary,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.glass,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.copy_rounded,
                          color: AppColors.textSecondary, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ).animate().fadeIn(duration: 300.ms),

        const SizedBox(height: 20),

        // Now playing in room
        BlocBuilder<PlayerCubit, PlayerState>(
          buildWhen: (p, c) => p.currentTrack?.id != c.currentTrack?.id || p.isPlaying != c.isPlaying,
          builder: (_, ps) {
            if (ps.currentTrack == null) {
              return const SizedBox.shrink();
            }
            return GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('NOW PLAYING IN ROOM',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDisabled,
                        letterSpacing: 1.5)),
                const SizedBox(height: 12),
                Row(children: [
                  AlbumArtWidget(
                      url: ps.currentTrack!.albumArtUrl,
                      size: 56, borderRadius: 10),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(ps.currentTrack!.title,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(ps.currentTrack!.artist,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textSecondary),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ]),
                  ),
                  if (state.isHost)
                    GestureDetector(
                      onTap: () => context.read<PlayerCubit>().togglePlayPause(),
                      child: Container(
                        width: 44, height: 44,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: AppColors.brandGradient),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          ps.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.white, size: 24,
                        ),
                      ),
                    ),
                ]),
              ]),
            ).animate().fadeIn(duration: 300.ms);
          },
        ),

        const SizedBox(height: 20),

        // Participants list
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Listeners',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: state.participantCount,
                  separatorBuilder: (_, __) => const Divider(
                      color: AppColors.glassBorder, height: 1),
                  itemBuilder: (_, i) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.brandGradient[i % 3],
                      child: Text('L${i + 1}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                    title: Text('Listener ${i + 1}',
                        style: const TextStyle(
                            color: AppColors.textPrimary, fontSize: 14)),
                    trailing: i == 0 && state.isHost
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: AppColors.brandGradient),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('Host',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                          )
                        : null,
                  ),
                ),
              ),
            ]),
          ),
        ),

        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: GlassButton(
            label: 'Leave Room',
            isOutlined: true,
            onTap: () => context.read<SyncCubit>().leaveRoom(),
          ),
        ),
        const SizedBox(height: 20),
      ]),
    );
  }
}
