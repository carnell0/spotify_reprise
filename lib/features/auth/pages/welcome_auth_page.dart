import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:spotify_reprise/core/routes/routes.dart';
import 'package:spotify_reprise/features/auth/bloc/theme_bloc.dart';
import 'package:spotify_reprise/features/auth/bloc/theme_state.dart';

class WelcomeAuthPage extends StatelessWidget {
  const WelcomeAuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final bool isDarkMode = state.themeData.brightness == Brightness.dark;
        final Color dynamicBackgroundColor = state.themeData.scaffoldBackgroundColor;
        final Color dynamicForegroundColor = isDarkMode ? Colors.white : Colors.black;

        return Scaffold(
          body: Stack(
            children: [
              // 1. Fond dynamique (couleur basée sur le thème)
              Container(
                color: dynamicBackgroundColor,
                width: double.infinity,
                height: double.infinity,
              ),

              // 2. Image de Billie Eilish
              Positioned(
                left: 0,
                bottom: 0,
                width: size.width * 0.7,
                height: size.height * 0.6,
                child: Image.asset(
                  'assets/images/welcome_billie.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomLeft,
                ),
              ),

              // 3. Motif de rayures en haut à droite
              Positioned(
                top: 0,
                right: 0,
                width: size.width * 0.5,
                height: size.height * 0.3,
                child: SvgPicture.asset(
                  'assets/icons/top_pattern.svg',
                  fit: BoxFit.fill,
                  alignment: Alignment.topRight,
                ),
              ),

              // 4. Motif de rayures en bas à droite
              Positioned(
                bottom: 0,
                right: 0,
                width: size.width * 0.5,
                height: size.height * 0.3,
                child: SvgPicture.asset(
                  'assets/icons/bottom_pattern.svg',
                  fit: BoxFit.fill,
                  alignment: Alignment.bottomRight,
                ),
              ),

              // Contenu principal de la page (superposé au-dessus du fond)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start, // Aligne les enfants au début (haut)
                  crossAxisAlignment: CrossAxisAlignment.center, // Centre horizontalement les enfants dans la colonne
                  children: [
                    // Flèche de retour seule, alignée à gauche
                    Align( // Utilisez Align pour positionner la flèche spécifiquement à gauche du Padding
                      alignment: Alignment.topLeft,
                      child: InkWell(
                        onTap: () {
                          context.go(AppRoutes.themeChooser);
                        },
                        child: Icon(Icons.arrow_back_ios, color: dynamicForegroundColor),
                      ),
                    ),

                    const SizedBox(height: 50), // Espace entre la flèche et le logo (ajustez cette valeur)

                    // Logo Spotify (centré horizontalement)
                    SvgPicture.asset(
                      'assets/icons/spotify_logo1.svg',
                      height: 60,
                      width: 60,
                      // colorFilter: ColorFilter.mode(
                      //   dynamicForegroundColor, // Couleur dynamique
                      //   BlendMode.srcIn,
                      // ),
                    ),

                    const SizedBox(height: 50), // Espace entre le logo et le texte principal (ajustez cette valeur)

                    // Texte principal
                    Text(
                      'Enjoy Listening To Music',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: dynamicForegroundColor,
                        fontSize: 24,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Spotify is a proprietary Swedish audio streaming and media services provider',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: dynamicForegroundColor.withOpacity(0.8),
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 15),
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
                              backgroundColor: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 25.0),
                            ),
                            child: Text(
                              'Register',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
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
                                //side: BorderSide(color: dynamicForegroundColor, width: 0),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 25.0),
                            ),
                            child: Text(
                              'Sign in',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: dynamicForegroundColor,
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
