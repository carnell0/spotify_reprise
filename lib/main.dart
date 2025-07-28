import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:spotify_reprise/core/routes/routes.dart';
import 'package:spotify_reprise/features/auth/bloc/theme_bloc.dart';
import 'package:spotify_reprise/features/auth/bloc/theme_state.dart';
import 'package:spotify_reprise/features/auth/pages/splash_screen.dart';
import 'package:spotify_reprise/features/auth/pages/theme_chooser_page.dart';
import 'package:spotify_reprise/features/auth/pages/get_started_page.dart'; // Importez la nouvelle page

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GoRouter _router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding, // Utilisez la route /onboarding pour GetStartedPage
        builder: (context, state) => const GetStartedPage(),
      ),
      GoRoute(
        path: AppRoutes.themeChooser,
        builder: (context, state) => const ThemeChooserPage(),
      ),
      // Assurez-vous d'ajouter les autres routes comme signIn, register, home, etc.,
      // une fois que vous aurez créé les pages correspondantes.
      // Par exemple :
      /*
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) => const SignInPage(), // Supposons que SignInPage existe
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(), // Supposons que RegisterPage existe
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(), // Supposons que HomePage existe
      ),
      */
    ],
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeBloc(),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'Spotify Clone',
            theme: state.themeData,
            routerConfig: _router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}