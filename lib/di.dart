import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotify_reprise/features/auth/bloc/auth_bloc.dart';
import 'package:spotify_reprise/features/auth/services/auth_repository.dart';
import 'package:spotify_reprise/features/auth/services/auth_repository_impl.dart';
import 'package:spotify_reprise/features/auth/bloc/theme_bloc.dart'; 

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // Firebase Auth
  sl.registerLazySingleton(() => FirebaseAuth.instance);

  // Auth Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );

  // Auth Bloc
  sl.registerFactory(() => AuthBloc(authRepository: sl()));

  // Theme Bloc <--- AJOUTEZ CETTE SECTION
  sl.registerLazySingleton<ThemeBloc>(() => ThemeBloc());
}