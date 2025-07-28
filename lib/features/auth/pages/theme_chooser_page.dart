import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spotify_reprise/features/auth/bloc/theme_bloc.dart';
import 'package:spotify_reprise/features/auth/bloc/theme_event.dart';

class ThemeChooserPage extends StatelessWidget {
  const ThemeChooserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeBloc = BlocProvider.of<ThemeBloc>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/dua_lipa_wallpaper.png',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/spotify_logo1.svg',
                      height: 60,
                      width: 60,
                      // colorFilter: const ColorFilter.mode(
                      //   Colors.white,
                      //   BlendMode.srcIn,
                      // ),
                    ),
                    const SizedBox(height: 300),
                    Text(
                      'Choose your Mode',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildThemeOption(
                      context,
                      'assets/icons/moon_icon.svg',
                      'Dark Mode',
                      Brightness.dark,
                      themeBloc,
                      isDarkMode,
                    ),
                    const SizedBox(width: 50),
                    _buildThemeOption(
                      context,
                      'assets/icons/sun_icon.svg',
                      'Light Mode',
                      Brightness.light,
                      themeBloc,
                      !isDarkMode,
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox( // Utilisons SizedBox pour donner une largeur infinie au bouton
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Action à effectuer lorsque le bouton "Continue" est pressé
                      // Par exemple, naviguer vers la prochaine page
                      // Navigator.of(context).pushReplacementNamed('/home');
                      print('Bouton Continuer pressé');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor, // Couleur verte de Spotify
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0), // Bords arrondis
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 30.0), // Padding interne pour la hauteur du bouton
                    ),
                    child: Text(
                      'Continue',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String iconPath,
    String title,
    Brightness brightness,
    ThemeBloc themeBloc,
    bool isSelected,
  ) {
    final primaryColor = Theme.of(context).primaryColor;

    return InkWell(
      onTap: () {
        themeBloc.add(ThemeChanged(brightness));
      },
      borderRadius: BorderRadius.circular(50),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryColor
                  : Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? primaryColor
                    : Colors.white.withOpacity(0.2),
                width: 1.0,
              ),
            ),
            child: SvgPicture.asset(
              iconPath,
              colorFilter: ColorFilter.mode(
                isSelected
                    ? Colors.white
                    : Colors.white,
                BlendMode.srcIn,
              ),
              height: 20,
              width: 20,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
