import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lyrica_flutter/core/di/injection.dart';
import 'package:lyrica_flutter/presentation/auth/view/auth_screen.dart';
import 'package:lyrica_flutter/presentation/auth/viewmodel/auth_cubit.dart';
import 'package:lyrica_flutter/presentation/home/view/home_screen.dart';
import 'package:lyrica_flutter/presentation/home/viewmodel/home_cubit.dart';
import 'package:lyrica_flutter/presentation/player/view/player_screen.dart';
import 'package:lyrica_flutter/presentation/player/viewmodel/lyrics_cubit.dart';
import 'package:lyrica_flutter/presentation/player/viewmodel/player_cubit.dart';

final GoRouter router = GoRouter(
  initialLocation: '/auth',

  //  GLOBAL AUTH GUARD (THIS FIXES APP RELOAD ISSUE)
  redirect: (context, state) {
    final authState = context.read<AuthCubit>().state;

    final isLoggedIn = authState is AuthAuthenticated;
    final isAuthRoute = state.matchedLocation == '/auth';

    //  not logged in → force auth
    if (!isLoggedIn && !isAuthRoute) {
      return '/auth';
    }

    //  logged in → block auth page
    if (isLoggedIn && isAuthRoute) {
      return '/';
    }

    return null;
  },

  routes: [
    // ================= AUTH =================
    GoRoute(
      path: '/auth',
      builder: (context, state) {
        return const AuthScreen();
      },
    ),

    // ================= HOME =================
    GoRoute(
      path: '/',
      builder: (context, state) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => getIt<HomeCubit>()),
            BlocProvider(create: (_) => getIt<PlayerCubit>()),
          ],
          child: const HomeScreen(),
        );
      },
    ),

    // ================= PLAYER =================
    GoRoute(
      path: '/player',
      builder: (context, state) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => getIt<HomeCubit>()),
            BlocProvider(create: (_) => getIt<PlayerCubit>()),
            BlocProvider(create: (_) => getIt<LyricsCubit>()),
          ],
          child: const PlayerScreen(),
        );
      },
    ),

    // ================= SYNC =================
    // GoRoute(
    //   path: '/sync',
    //   builder: (context, state) {
    //     return MultiBlocProvider(
    //       providers: [
    //         BlocProvider(create: (_) => getIt<HomeCubit>()),
    //         BlocProvider(create: (_) => getIt<PlayerCubit>()),
    //       ],
    //       child: const SyncScreen(),
    //     );
    //   },
    // ),
  ],
);
