// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:spotify_reprise/core/routes/routes.dart'; // Importe tes constantes de routes
import 'package:spotify_reprise/di.dart' as di; // Importe ton Service Locator
import 'package:spotify_reprise/features/auth/bloc/auth_bloc.dart'; // Importe AuthBloc
import 'package:spotify_reprise/features/auth/bloc/auth_event.dart';
import 'package:spotify_reprise/features/auth/bloc/auth_state.dart'; // Importe AuthState
import 'package:spotify_reprise/features/auth/bloc/theme_bloc.dart'; // Importe ThemeBloc
import 'package:spotify_reprise/features/auth/bloc/theme_state.dart'; // Importe ThemeState
import 'package:spotify_reprise/features/auth/pages/register_page.dart';
import 'package:spotify_reprise/features/auth/pages/sign_in_page.dart';
import 'package:spotify_reprise/features/auth/pages/splash_screen.dart';
import 'package:spotify_reprise/features/auth/pages/theme_chooser_page.dart';
import 'package:spotify_reprise/features/auth/pages/get_started_page.dart';
import 'package:spotify_reprise/features/auth/pages/welcome_auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Assure-toi que ce fichier est bien généré
// TODO: Importe ta HomePage quand elle sera prête
// import 'package:spotify_reprise/features/home/pages/home_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Utilise les options générées
  );

  // Initialisation des dépendances via GetIt
  await di.init();

  runApp(MyApp()); // Exécute ton application
}

class MyApp extends StatelessWidget {
  // Déclare l'instance de GoRouter ici, comme un champ final de la classe.
  final GoRouter _router = GoRouter(
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
      // TODO: Décommenter et implémenter la route pour la page d'accueil (home)
      // GoRoute(
      //   path: AppRoutes.home,
      //   builder: (context, state) => const HomePage(), // Assure-toi que HomePage existe
      // ),
    ],
    // Optionnel: Vous pouvez ajouter une logique de redirection globale ici si besoin
    // redirect: (context, state) {
    //   return null; // Pas de redirection par défaut
    // },
  );

  MyApp({super.key}); // Garde le constructeur non-const

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(
          create: (context) => di.sl<ThemeBloc>(), // Récupère ThemeBloc via GetIt
        ),
        BlocProvider<AuthBloc>(
          create: (context) => di.sl<AuthBloc>()..add(const AuthCheckUserStatus()), // Récupère AuthBloc et vérifie l'état au démarrage
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return BlocListener<AuthBloc, AuthState>(
            listener: (context, authState) {
              final GoRouter router = GoRouter.of(context); // Obtient l'instance du routeur

              if (authState is AuthAuthenticated) {
                // Si authentifié, navigue vers la page d'accueil (ou dashboard)
                // Assure-toi que AppRoutes.home est défini et que HomePage existe
                router.go(AppRoutes.home);
              } else if (authState is AuthUnauthenticated) {
                // Si non authentifié, assure-toi d'être sur une des pages publiques
                final String currentPath = router.routerDelegate.currentConfiguration.uri.path;

                final List<String> publicPaths = [
                  AppRoutes.welcome,
                  AppRoutes.signIn,
                  AppRoutes.register,
                  AppRoutes.splash,
                  AppRoutes.onboarding,
                  AppRoutes.themeChooser,
                ];

                if (!publicPaths.contains(currentPath)) {
                   router.go(AppRoutes.welcome);
                }
              }
            },
            child: MaterialApp.router(
              title: 'Spotify Reprise',
              theme: themeState.themeData, // Utilise le thème du ThemeBloc
              routerConfig: _router, // Référence l'instance de GoRouter déclarée ci-dessus
              debugShowCheckedModeBanner: false,
            ),
          );
        },
      ),
    );
  }
}
