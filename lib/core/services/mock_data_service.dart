// import 'package:lyrica_flutter/features/player/domain/entities/track.dart';
// import 'package:lyrica_flutter/features/playlists/domain/entities/playlist.dart';
// import 'package:lyrica_flutter/features/sync/domain/entities/room_member.dart';
// import 'package:lyrica_flutter/features/sync/domain/entities/sync_room.dart';
//
// /// Provides rich, realistic mock data for UI development.
// /// Replace individual methods with real repository calls as the backend matures.
// class MockDataService {
//   MockDataService._();
//
//   // ─── Tracks ────────────────────────────────────────────────────────────────
//
//   static Track get currentTrack => _tracks.first;
//
//   static final List<Track> _tracks = [
//     const Track(
//       id: 't1',
//       title: 'Blinding Lights',
//       artistName: 'The Weeknd',
//       albumName: 'After Hours',
//       coverUrl: 'https://i.scdn.co/image/ab67616d0000b2738863bc11d2aa12b54f5aeb36',
//       durationMs: 200040,
//     ),
//     const Track(
//       id: 't2',
//       title: 'As It Was',
//       artistName: 'Harry Styles',
//       albumName: "Harry's House",
//       coverUrl: 'https://i.scdn.co/image/ab67616d0000b273b46f74097655d7f353caab14',
//       durationMs: 167303,
//     ),
//     const Track(
//       id: 't3',
//       title: 'Flowers',
//       artistName: 'Miley Cyrus',
//       albumName: 'Endless Summer Vacation',
//       coverUrl: 'https://i.scdn.co/image/ab67616d0000b273f429549123d441e2b81fde47',
//       durationMs: 200455,
//     ),
//     const Track(
//       id: 't4',
//       title: 'Kill Bill',
//       artistName: 'SZA',
//       albumName: 'SOS',
//       coverUrl: 'https://i.scdn.co/image/ab67616d0000b273c7e40b0f2fde1dfef6d7adb4',
//       durationMs: 153946,
//     ),
//     const Track(
//       id: 't5',
//       title: 'Anti-Hero',
//       artistName: 'Taylor Swift',
//       albumName: 'Midnights',
//       coverUrl: 'https://i.scdn.co/image/ab67616d0000b273fa747621a53c8e2cc436dee0',
//       durationMs: 200690,
//     ),
//     const Track(
//       id: 't6',
//       title: 'Bad Habit',
//       artistName: 'Steve Lacy',
//       albumName: 'Gemini Rights',
//       coverUrl: 'https://i.scdn.co/image/ab67616d0000b273c5649add07ed3720be9d5526',
//       durationMs: 232279,
//     ),
//     const Track(
//       id: 't7',
//       title: 'Cruel Summer',
//       artistName: 'Taylor Swift',
//       albumName: 'Lover',
//       coverUrl: 'https://i.scdn.co/image/ab67616d0000b273e787cffec20aa2a396a61647',
//       durationMs: 178427,
//     ),
//     const Track(
//       id: 't8',
//       title: 'Calm Down',
//       artistName: 'Rema & Selena Gomez',
//       albumName: 'Rave & Roses Ultra',
//       coverUrl: 'https://i.scdn.co/image/ab67616d0000b2730bf02e7dcf6eb56c2c31ac8a',
//       durationMs: 239048,
//     ),
//   ];
//
//   static List<Track> get recentTracks => _tracks;
//   static List<Track> get searchResults => _tracks;
//
//   static List<Track> queryTracks(String query) {
//     if (query.isEmpty) return _tracks;
//     final q = query.toLowerCase();
//     return _tracks.where((t) =>
//       t.title.toLowerCase().contains(q) ||
//       t.artistName.toLowerCase().contains(q) ||
//       t.albumName.toLowerCase().contains(q),
//     ).toList();
//   }
//
//   // ─── Playlists ──────────────────────────────────────────────────────────────
//
//   static List<Playlist> get playlists => [
//     Playlist(
//       id: 'liked',
//       name: 'Liked Songs',
//       description: 'Your all-time favourites',
//       tracks: [_tracks[0], _tracks[1], _tracks[4], _tracks[6]],
//       isLikedSongs: true,
//       isOwned: true,
//       createdAt: DateTime(2023, 1, 1),
//     ),
//     Playlist(
//       id: 'p1',
//       name: 'Late Night Drive',
//       description: 'Perfect for 2AM highways',
//       tracks: [_tracks[0], _tracks[3], _tracks[5]],
//       isOwned: true,
//       createdAt: DateTime(2024, 3, 12),
//     ),
//     Playlist(
//       id: 'p2',
//       name: 'Morning Glow',
//       description: 'Rise and shine selection',
//       tracks: [_tracks[1], _tracks[2], _tracks[4], _tracks[7]],
//       isOwned: true,
//       createdAt: DateTime(2024, 5, 8),
//     ),
//     Playlist(
//       id: 'p3',
//       name: 'Gym Beast Mode',
//       description: 'Maximum BPM for maximum gains',
//       tracks: [_tracks[4], _tracks[6], _tracks[7]],
//       isOwned: true,
//       createdAt: DateTime(2024, 6, 1),
//     ),
//     Playlist(
//       id: 'p4',
//       name: 'Chill Vibes',
//       description: 'Low-key, high quality',
//       tracks: [_tracks[2], _tracks[3], _tracks[5]],
//       isOwned: false,
//       createdAt: DateTime(2024, 2, 20),
//     ),
//   ];
//
//   // ─── Sync Rooms ─────────────────────────────────────────────────────────────
//
//   static List<SyncRoom> get syncRooms => [
//     SyncRoom(
//       roomId: 'r1',
//       roomName: 'Midnight Sessions 🌙',
//       hostId: 'u1',
//       members: [
//         RoomMember(
//           userId: 'u1',
//           displayName: 'Rennie',
//           isHost: true,
//           isActive: true,
//           joinedAt: DateTime.now().subtract(const Duration(minutes: 32)),
//         ),
//         RoomMember(
//           userId: 'u2',
//           displayName: 'Maya K.',
//           isHost: false,
//           isActive: true,
//           joinedAt: DateTime.now().subtract(const Duration(minutes: 28)),
//         ),
//         RoomMember(
//           userId: 'u3',
//           displayName: 'Alex T.',
//           isHost: false,
//           isActive: true,
//           joinedAt: DateTime.now().subtract(const Duration(minutes: 15)),
//         ),
//         RoomMember(
//           userId: 'u4',
//           displayName: 'Priya S.',
//           isHost: false,
//           isActive: false,
//           joinedAt: DateTime.now().subtract(const Duration(minutes: 10)),
//         ),
//       ],
//       currentTrack: _tracks[0],
//       isPlaying: true,
//       progressMs: 87200,
//       connectionState: SyncConnectionState.connected,
//       maxMembers: 50,
//       isPublic: true,
//       inviteCode: 'LYRICA-MID1',
//     ),
//     SyncRoom(
//       roomId: 'r2',
//       roomName: 'Pop Hits Radio 📻',
//       hostId: 'u5',
//       members: [
//         RoomMember(
//           userId: 'u5',
//           displayName: 'Jordan M.',
//           isHost: true,
//           isActive: true,
//           joinedAt: DateTime.now().subtract(const Duration(hours: 1)),
//         ),
//         RoomMember(
//           userId: 'u6',
//           displayName: 'Sam L.',
//           isHost: false,
//           isActive: true,
//           joinedAt: DateTime.now().subtract(const Duration(minutes: 45)),
//         ),
//       ],
//       currentTrack: _tracks[4],
//       isPlaying: true,
//       progressMs: 112000,
//       connectionState: SyncConnectionState.connected,
//       maxMembers: 20,
//       isPublic: true,
//       inviteCode: 'LYRICA-POP2',
//     ),
//   ];
// }
