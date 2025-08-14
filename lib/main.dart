import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:async'; // Nécessaire pour StreamSubscription de GoRouterRefreshStream

import 'package:spotify_reprise/core/routes/routes.dart'; // Importe tes constantes de routes
import 'package:spotify_reprise/di.dart' as di; // Importe ton Service Locator
import 'package:spotify_reprise/features/auth/bloc/auth_bloc.dart'; // Importe AuthBloc
import 'package:spotify_reprise/features/auth/bloc/auth_event.dart';
import 'package:spotify_reprise/features/auth/bloc/auth_state.dart'; // Importe AuthState
import 'package:spotify_reprise/features/auth/bloc/theme_bloc.dart'; // Importe ThemeBloc
import 'package:spotify_reprise/features/auth/bloc/theme_state.dart'; // Importe ThemeState

// Pages de ton application
import 'package:spotify_reprise/features/auth/pages/register_page.dart';
import 'package:spotify_reprise/features/auth/pages/sign_in_page.dart';
import 'package:spotify_reprise/features/auth/pages/splash_screen.dart';
import 'package:spotify_reprise/features/auth/pages/theme_chooser_page.dart';
import 'package:spotify_reprise/features/auth/pages/get_started_page.dart';
import 'package:spotify_reprise/features/auth/pages/welcome_auth_page.dart';
import 'package:spotify_reprise/features/home/pages/home_screen.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Assure-toi que ce fichier est correctement généré

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Utilise les options générées
  );

  // Initialisation des dépendances via GetIt
  await di.init(); // Assure-toi que AuthBloc est enregistré ici

  runApp(const MyApp()); // Exécute ton application
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;
  // Obtenez l'instance de AuthBloc directement depuis GetIt ici.
  // Elle doit être disponible car di.init() a été appelé dans main().
  late final AuthBloc _authBloc = di.sl<AuthBloc>();

  @override
  void initState() {
    super.initState();

    // Initialise le AuthBloc avec l'événement de vérification du statut
    // Faites cela ici pour vous assurer qu'il commence à écouter l'état d'authentification
    _authBloc.add(const AuthCheckUserStatus());

    _router = GoRouter(
      initialLocation: AppRoutes.splash, // Commence par la page de splash
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
      // La redirection est gérée ici
      redirect: (context, state) {
        // Accède à l'état actuel de AuthBloc via l'instance disponible
        final authState = _authBloc.state; // Utilisez _authBloc directement
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

        // Si l'utilisateur est connecté et essaie d'aller sur une page publique, redirige vers la page d'accueil
        if (isLoggedIn && goingToPublicPath && currentMatchedLocation != AppRoutes.home) {
          return AppRoutes.home;
        }
        // Si l'utilisateur n'est PAS connecté et essaie d'accéder à une page PROTÉGÉE, redirige vers la page de bienvenue
        if (!isLoggedIn && !goingToPublicPath) {
          return AppRoutes.welcome;
        }

        // Si l'utilisateur est sur la page de splash et est authentifié, on le redirige immédiatement vers la home
        if (currentMatchedLocation == AppRoutes.splash && isLoggedIn) {
          return AppRoutes.home;
        }
        // Si l'utilisateur est sur la page de splash et n'est PAS authentifié, on le redirige vers la page de bienvenue
        if (currentMatchedLocation == AppRoutes.splash && !isLoggedIn) {
          return AppRoutes.welcome;
        }

        // Ne redirige pas si l'état est déjà géré ou si la navigation est normale
        return null;
      },
      // Écoute les changements du AuthBloc pour déclencher la réévaluation de la redirection
      // Nous passons le stream de l'instance de _authBloc que nous avons récupérée de GetIt.
      refreshListenable: GoRouterRefreshStream(_authBloc.stream),
    );
  }

  @override
  void dispose() {
    _authBloc.close(); // Ferme le BLoC lorsque le widget est disposé
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(
          create: (context) => di.sl<ThemeBloc>(), // Récupère ThemeBloc via GetIt
        ),
        BlocProvider<AuthBloc>.value( // Utilisez .value pour l'instance déjà créée
          value: _authBloc, // Fournit l'instance de AuthBloc déjà créée
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          // Ce BlocListener est pour les messages SnackBar, la navigation est gérée par GoRouter.redirect
          return BlocListener<AuthBloc, AuthState>(
            listener: (context, authState) {
              if (!mounted) return;
              if (authState is AuthAuthenticated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Successfully signed in!'), duration: Duration(seconds: 2)),
                );
              } else if (authState is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Authentication Error: \${authState.message}'), duration: const Duration(seconds: 3)),
                );
              } else if (authState is AuthLoading) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Signing in...'), duration: Duration(seconds: 1)),
                );
              }
            },
            child: MaterialApp.router(
              title: 'Spotify Reprise',
              theme: themeState.themeData, // Applique le thème actuel
              routerConfig: _router, // Utilisez l'instance de GoRouter initialisée dans initState
              debugShowCheckedModeBanner: false,
            ),
          );
        },
      ),
    );
  }
}

/// Helper pour [GoRouter] qui écoute un [Stream] (comme le stream d'un BLoC)
/// et notifie les listeners de GoRouter lorsque le stream émet une nouvelle valeur.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    // Émet une notification initiale pour que GoRouter évalue la redirection au démarrage.
    notifyListeners();
    // Écoute le stream et notifie les listeners à chaque nouvelle émission.
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel(); // Annule l'abonnement au stream pour éviter les fuites de mémoire.
    super.dispose();
  }
}