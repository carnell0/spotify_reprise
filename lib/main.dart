import 'package:audio_service/audio_service.dart';
import 'package:spotify_reprise/features/home/services/audio_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:spotify_reprise/core/routes/routes.dart';
import 'package:spotify_reprise/di.dart' as di;
import 'package:spotify_reprise/features/auth/bloc/auth_bloc.dart';
import 'package:spotify_reprise/features/auth/bloc/auth_event.dart';
import 'package:spotify_reprise/features/auth/bloc/auth_state.dart';
import 'package:spotify_reprise/features/auth/bloc/theme_bloc.dart';
import 'package:spotify_reprise/features/auth/bloc/theme_state.dart';
import 'package:spotify_reprise/features/auth/pages/register_page.dart';
import 'package:spotify_reprise/features/auth/pages/sign_in_page.dart';
import 'package:spotify_reprise/features/auth/pages/splash_screen.dart';
import 'package:spotify_reprise/features/auth/pages/theme_chooser_page.dart';
import 'package:spotify_reprise/features/auth/pages/get_started_page.dart';
import 'package:spotify_reprise/features/auth/pages/welcome_auth_page.dart';
import 'package:spotify_reprise/features/home/pages/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

late AudioHandler _audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialisation des dépendances via GetIt
  await di.init();

  // Initialisation du service audio
  _audioHandler = await initAudioService();
  di.sl.registerSingleton<AudioHandler>(_audioHandler);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;
  late final AuthBloc _authBloc = di.sl<AuthBloc>();
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    _authBloc.add(const AuthCheckUserStatus());

    _router = GoRouter(
      initialLocation: AppRoutes.splash,
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.onboarding,
          builder: (context, state) => const GetStartedPage(),
        ),
        GoRoute(
          path: AppRoutes.themeChooser,
          builder: (context, state) => const ThemeChooserPage(),
        ),
        GoRoute(
          path: AppRoutes.welcome,
          builder: (context, state) => const WelcomeAuthPage(),
        ),
        GoRoute(
          path: AppRoutes.signIn,
          builder: (context, state) => const SignInPage(),
        ),
        GoRoute(
          path: AppRoutes.register,
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const HomeScreen(),
        ),
      ],
      redirect: (context, state) {
        final authState = _authBloc.state;
        final isLoggedIn = authState is AuthAuthenticated;
        final String currentMatchedLocation = state.matchedLocation;
        final List<String> publicPaths = [
          AppRoutes.welcome,
          AppRoutes.signIn,
          AppRoutes.register,
          AppRoutes.splash,
          AppRoutes.onboarding,
          AppRoutes.themeChooser,
        ];
        final bool goingToPublicPath = publicPaths.contains(currentMatchedLocation);

        if (isLoggedIn && goingToPublicPath && currentMatchedLocation != AppRoutes.home) {
          return AppRoutes.home;
        }
        if (!isLoggedIn && !goingToPublicPath) {
          return AppRoutes.welcome;
        }
        if (currentMatchedLocation == AppRoutes.splash && isLoggedIn) {
          return AppRoutes.home;
        }
        if (currentMatchedLocation == AppRoutes.splash && !isLoggedIn) {
          return AppRoutes.welcome;
        }
        return null;
      },
      refreshListenable: GoRouterRefreshStream(_authBloc.stream),
    );

    // Écouter les changements d'état d'authentification pour mettre à jour l'UI
    _authSubscription = _authBloc.stream.listen((state) {
      if (state is AuthAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully signed in!'), duration: Duration(seconds: 2)),
        );
      } else if (state is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication Error: ${state.message}'), duration: const Duration(seconds: 3)),
        );
      } else if (state is AuthLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signing in...'), duration: Duration(seconds: 1)),
        );
      }
    });
  }

  @override
  void dispose() {
    _authBloc.close();
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(
          create: (context) => di.sl<ThemeBloc>(),
        ),
        BlocProvider<AuthBloc>.value(
          value: _authBloc,
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            title: 'Spotify Reprise',
            theme: themeState.themeData,
            routerConfig: _router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
