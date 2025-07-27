import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

// On va définir une route pour l'écran de bienvenue ici.
// Pour l'instant, on peut aller directement à une page temporaire ou l'écran d'accueil.
// Plus tard, cette logique vérifiera si l'utilisateur est connecté.
import 'package:spotify_reprise/core/routes/routes.dart'; // Assure-toi que le chemin est correct

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Délai pour afficher le splash screen avant de naviguer
    Future.delayed(const Duration(seconds: 8), () {
      context.go(AppRoutes.themeChooser); 
      //context.go(AppRoutes.onboarding);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fond noir comme dans le design Figma
      body: Center(
        child: SvgPicture.asset(
          'assets/icons/spotify_logo.svg', // Chemin vers ton logo SVG
          height: 200, // Ajuste la taille selon tes préférences
          width: 150,
        ),
      ),
    );
  }
}