import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:spotify_reprise/core/routes/routes.dart'; 
import 'package:spotify_reprise/features/auth/bloc/theme_bloc.dart'; 
import 'package:spotify_reprise/features/auth/bloc/theme_state.dart'; 
import 'package:spotify_reprise/features/auth/pages/splash_screen.dart'; 
import 'package:spotify_reprise/features/auth/pages/theme_chooser_page.dart'; // **À créer**

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GoRouter _router = GoRouter(
    initialLocation: AppRoutes.splash, // Point de départ : Splash Screen
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const Text('Onboarding Page Placeholder'), // Sera remplacé plus tard
      ),
      // **Nouvelle route pour le ThemeChooserPage**
      GoRoute(
        path: AppRoutes.themeChooser,
        builder: (context, state) => const ThemeChooserPage(),
      ),
      // Ajoute d'autres routes ici au fur et à mesure
    ],
  );

  @override
  Widget build(BuildContext context) {
    // Fournit le ThemeBloc à toute l'application
    return BlocProvider(
      create: (context) => ThemeBloc(),
      // Reconstruit MaterialApp chaque fois que le thème change
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'Spotify Clone',
            theme: state.themeData, // Utilise le ThemeData du Bloc
            routerConfig: _router,
            debugShowCheckedModeBanner: false, // Cache le bandeau "Debug"
          );
        },
      ),
    );
  }
}