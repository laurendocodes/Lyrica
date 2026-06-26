import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/viewmodel/auth_cubit.dart';
import '../../shared/widgets/glass_card.dart';
import '../viewmodel/profile_cubit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileCubit>().loadProfile();
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading || state is ProfileInitial) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.accentPrimary),
              ),
            );
          }
          if (state is ProfileError) {
            return _ErrorView(message: state.message);
          }
          if (state is ProfileLoaded) {
            return _buildProfile(context, state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildProfile(BuildContext context, ProfileLoaded state) {
    final user = state.user;
    return CustomScrollView(
      slivers: [
        // Header with blurred avatar background
        SliverToBoxAdapter(
          child: Stack(
            children: [
              // Ambient glow
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x508B5CF6),
                        AppColors.background,
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Profile',
                              style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary)),
                          IconButton(
                            icon: const Icon(Icons.settings_outlined,
                                color: AppColors.textSecondary),
                            onPressed: () => _showSettings(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Avatar
                      _Avatar(url: user.avatarUrl, name: user.username)
                          .animate()
                          .scale(duration: 400.ms, curve: Curves.elasticOut),

                      const SizedBox(height: 16),
                      Text(user.username,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text(user.email,
                          style: const TextStyle(
                              fontSize: 14, color: AppColors.textSecondary)),

                      const SizedBox(height: 24),

                      // Stats row
                      _StatsRow(user: user),

                      const SizedBox(height: 24),

                      // Tab bar
                      GlassCard(
                        padding: const EdgeInsets.all(4),
                        borderRadius: 14,
                        child: TabBar(
                          controller: _tab,
                          indicator: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: AppColors.brandGradient),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: AppColors.textSecondary,
                          dividerColor: Colors.transparent,
                          tabs: const [
                            Tab(text: 'Following'),
                            Tab(text: 'Followers'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms),
        ),

        // Tab content
        SliverFillRemaining(
          child: TabBarView(
            controller: _tab,
            children: [
              _UserList(
                emptyMessage: "You're not following anyone yet",
                emptyIcon: Icons.person_add_outlined,
                // In a real app, fetch from social repo
                users: const [],
              ),
              _UserList(
                emptyMessage: 'No followers yet',
                emptyIcon: Icons.people_outline_rounded,
                users: const [],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetCtx) => _SettingsSheet(
        onLogout: () {
          Navigator.pop(sheetCtx);
          context.read<AuthCubit>().logout();
          context.go('/auth');
        },
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? url;
  final String name;
  const _Avatar({this.url, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96, height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: AppColors.brandGradient,
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentPrimary.withOpacity(0.4),
            blurRadius: 24, spreadRadius: 4,
          ),
        ],
      ),
      child: url != null
          ? ClipOval(child: Image.network(url!, fit: BoxFit.cover))
          : Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final user;
  const _StatsRow({required this.user});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16),
      borderRadius: 16,
      child: Row(
        children: [
          _stat('${user.followingCount}', 'Following'),
          _divider(),
          _stat('${user.followersCount}', 'Followers'),
          _divider(),
          _stat('—', 'Playlists'),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) => Expanded(
        child: Column(children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
        ]),
      );

  Widget _divider() => Container(
        width: 1, height: 32,
        color: AppColors.glassBorder,
      );
}

class _UserList extends StatelessWidget {
  final String emptyMessage;
  final IconData emptyIcon;
  final List<dynamic> users;
  const _UserList(
      {required this.emptyMessage,
      required this.emptyIcon,
      required this.users});

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(emptyIcon, size: 48, color: AppColors.textDisabled),
          const SizedBox(height: 12),
          Text(emptyMessage,
              style: const TextStyle(color: AppColors.textSecondary)),
        ]),
      );
    }
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (_, i) => _UserTile(user: users[i]),
    );
  }
}

class _UserTile extends StatelessWidget {
  final dynamic user;
  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.accentPrimary,
        child: Text(user.username[0].toUpperCase(),
            style: const TextStyle(color: Colors.white)),
      ),
      title: Text(user.username,
          style: const TextStyle(color: AppColors.textPrimary)),
      subtitle: Text('${user.followersCount} followers',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      trailing: _FollowButton(userId: user.id, isFollowing: user.isFollowing),
    );
  }
}

class _FollowButton extends StatefulWidget {
  final String userId;
  final bool isFollowing;
  const _FollowButton({required this.userId, required this.isFollowing});

  @override
  State<_FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<_FollowButton> {
  late bool _following;

  @override
  void initState() {
    super.initState();
    _following = widget.isFollowing;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _following = !_following),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          gradient: _following ? null : const LinearGradient(colors: AppColors.brandGradient),
          border: _following
              ? Border.all(color: AppColors.textDisabled)
              : null,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          _following ? 'Following' : 'Follow',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _following ? AppColors.textSecondary : Colors.white,
          ),
        ),
      ),
    );
  }
}

class _SettingsSheet extends StatelessWidget {
  final VoidCallback onLogout;
  const _SettingsSheet({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 36, height: 4,
          margin: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
              color: AppColors.textDisabled,
              borderRadius: BorderRadius.circular(2)),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Settings',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ),
        ),
        _tile(Icons.notifications_outlined, 'Notifications', () {}),
        _tile(Icons.lock_outline_rounded, 'Privacy', () {}),
        _tile(Icons.help_outline_rounded, 'Help & Support', () {}),
        const Divider(color: AppColors.glassBorder, height: 24),
        ListTile(
          leading: const Icon(Icons.logout_rounded, color: AppColors.error),
          title: const Text('Sign Out',
              style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w500)),
          onTap: onLogout,
        ),
      ]),
    );
  }

  Widget _tile(IconData icon, String label, VoidCallback onTap) => ListTile(
        leading: Icon(icon, color: AppColors.textSecondary),
        title: Text(label,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 15)),
        trailing: const Icon(Icons.chevron_right_rounded,
            color: AppColors.textDisabled, size: 20),
        onTap: onTap,
      );
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline_rounded,
            color: AppColors.textDisabled, size: 48),
        const SizedBox(height: 12),
        Text(message,
            style: const TextStyle(color: AppColors.textSecondary),
            textAlign: TextAlign.center),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () => context.read<ProfileCubit>().loadProfile(),
          child: const Text('Retry'),
        ),
      ]),
    );
  }
}
