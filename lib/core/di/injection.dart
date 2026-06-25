// lib/core/di/injection.dart
import 'package:get_it/get_it.dart';
import 'package:lyrica_flutter/presentation/player/viewmodel/player_cubit.dart';
import 'package:lyrica_flutter/presentation/sync/viewmodel/sync_cubit.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../network/dio_client.dart';
import '../network/socket_service.dart';
import '../audio/audio_handler.dart';

import '../../data/datasources/local/local_datasource.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/remote/music_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/lyrics_repository_impl.dart';
import '../../data/repositories/music_repository_impl.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/lyrics_repository.dart';
import '../../domain/repositories/music_repository.dart';

import '../../presentation/auth/viewmodel/auth_cubit.dart';

import '../../presentation/player/viewmodel/lyrics_cubit.dart';
import '../../presentation/home/viewmodel/home_cubit.dart';
import '../../presentation/search/viewmodel/search_cubit.dart';

import '../../presentation/profile/viewmodel/profile_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // External
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // Core
  getIt.registerSingleton<DioClient>(DioClient());
  getIt.registerSingleton<SocketService>(SocketService());
  getIt.registerSingleton<LyricaAudioHandler>(LyricaAudioHandler());

  // Data Sources
  getIt.registerSingleton<LocalDataSource>(
    LocalDataSourceImpl(getIt<SharedPreferences>()),
  );
  getIt.registerSingleton<AuthRemoteDataSource>(
    AuthRemoteDataSourceImpl(getIt<DioClient>()),
  );
  getIt.registerSingleton<MusicRemoteDataSource>(
    MusicRemoteDataSourceImpl(getIt<DioClient>()),
  );
  getIt.registerSingleton<LyricsRemoteDataSource>(
    LyricsRemoteDataSourceImpl(getIt<DioClient>()),
  );

  // Repositories
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<LocalDataSource>(),
    ),
  );
  getIt.registerSingleton<MusicRepository>(
    MusicRepositoryImpl(getIt<MusicRemoteDataSource>()),
  );
  getIt.registerSingleton<LyricsRepository>(
    LyricsRepositoryImpl(getIt<LyricsRemoteDataSource>()),
  );

  // Cubits (factories — new instance each time)
  getIt.registerFactory<AuthCubit>(() => AuthCubit(getIt<AuthRepository>()));
  getIt.registerLazySingleton<PlayerCubit>(
    () => PlayerCubit(
      audioHandler: getIt<LyricaAudioHandler>(),
      socketService: getIt<SocketService>(),
    ),
  );
  getIt.registerFactory<LyricsCubit>(
    () => LyricsCubit(getIt<LyricsRepository>()),
  );
  getIt.registerFactory<HomeCubit>(() => HomeCubit(getIt<MusicRepository>()));
  getIt.registerFactory<SearchCubit>(
    () => SearchCubit(getIt<MusicRepository>()),
  );
  getIt.registerFactory<SyncCubit>(
    () => SyncCubit(
      socketService: getIt<SocketService>(),
      audioHandler: getIt<LyricaAudioHandler>(),
    ),
  );
  getIt.registerFactory<ProfileCubit>(
    () => ProfileCubit(getIt<AuthRepository>()),
  );
}
