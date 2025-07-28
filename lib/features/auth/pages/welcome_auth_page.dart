import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Importez pour utiliser BlocBuilder
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:spotify_reprise/core/routes/routes.dart';
import 'package:spotify_reprise/features/auth/bloc/theme_bloc.dart'; // Importez votre ThemeBloc
import 'package:spotify_reprise/features/auth/bloc/theme_state.dart'; // Importez votre ThemeState

class WelcomeAuthPage extends StatelessWidget {
  const WelcomeAuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // BlocBuilder pour réagir aux changements de thème
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        // Déterminer les couleurs dynamiques en fonction du thème actuel
        final bool isDarkMode = state.themeData.brightness == Brightness.dark;
        final Color dynamicBackgroundColor = state.themeData.scaffoldBackgroundColor;
        final Color dynamicForegroundColor = isDarkMode ? Colors.white : Colors.black; // Couleur du texte et icônes

        return Scaffold(
          body: Stack(
            children: [
              // 1. Fond dynamique (couleur basée sur le thème)
              Container(
                color: dynamicBackgroundColor, // La couleur de fond s'adapte au thème
                width: double.infinity,
                height: double.infinity,
              ),

              // 2. Image de Billie Eilish (en bas à gauche, toujours la même image)
              Positioned(
                left: 0,
                bottom: 0,
                width: size.width * 0.7,
                height: size.height * 0.6,
                child: Image.asset(
                  'assets/images/billie_eilish_bg.png', // Chemin de votre image de Billie Eilish
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomLeft,
                ),
              ),

              // 3. Motif de rayures en haut à droite (toujours le même motif)
              Positioned(
                top: 0,
                right: 0,
                width: size.width * 0.5,
                height: size.height * 0.3,
                child: Image.asset(
                  'assets/images/pattern_top_right.png', // Chemin de votre motif du haut
                  fit: BoxFit.fill,
                  alignment: Alignment.topRight,
                ),
              ),

              // 4. Motif de rayures en bas à droite (toujours le même motif)
              Positioned(
                bottom: 0,
                right: 0,
                width: size.width * 0.5,
                height: size.height * 0.3,
                child: Image.asset(
                  'assets/images/pattern_bottom_right.png', // Chemin de votre motif du bas
                  fit: BoxFit.fill,
                  alignment: Alignment.bottomRight,
                ),
              ),

              // Contenu principal de la page (superposé au-dessus du fond)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Flèche de retour et logo Spotify
                    Align(
                      alignment: Alignment.topLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                // Gérer le cas où il n'y a plus de page à pop
                              }
                            },
                            child: Icon(Icons.arrow_back_ios, color: dynamicForegroundColor), // Couleur dynamique
                          ),
                          SvgPicture.asset(
                            'assets/icons/spotify_logo1.svg',
                            height: 40,
                            width: 40,
                            colorFilter: ColorFilter.mode(
                              dynamicForegroundColor, // Couleur dynamique
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 40),
                        ],
                      ),
                    ),
                    // Texte principal
                    Column(
                      children: [
                        Text(
                          'Enjoy Listening To Music',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: dynamicForegroundColor, // Couleur dynamique
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Spotify is a proprietary Swedish audio streaming and media services provider',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: dynamicForegroundColor.withOpacity(0.8), // Couleur dynamique
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    // Boutons "Register" et "Sign in"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              context.go(AppRoutes.register);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor, // Le vert Spotify reste constant
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15.0),
                            ),
                            child: Text(
                              'Register',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white, // Le texte sur le bouton vert reste blanc
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              context.go(AppRoutes.signIn);
                            },
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                side: BorderSide(color: dynamicForegroundColor, width: 1.0), // Bordure dynamique
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15.0),
                            ),
                            child: Text(
                              'Sign in',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: dynamicForegroundColor, // Couleur dynamique
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
