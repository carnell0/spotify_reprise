import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_reprise/features/auth/bloc/theme_bloc.dart';
import 'package:spotify_reprise/features/auth/bloc/theme_state.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final bool isDarkMode = state.themeData.brightness == Brightness.dark;
        final Color dynamicForegroundColor = isDarkMode ? Colors.white : Colors.black;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Your Favorites',
              style: TextStyle(
                color: dynamicForegroundColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 80,
                  color: dynamicForegroundColor.withOpacity(0.5),
                ),
                const SizedBox(height: 20),
                Text(
                  'No favorites yet?',
                  style: TextStyle(
                    color: dynamicForegroundColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Add songs, artists, and albums to your favorites to see them here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: dynamicForegroundColor.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Naviguer vers la page de recherche pour ajouter des favoris
                  },
                  icon: Icon(Icons.add),
                  label: Text('Explore Music'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor, // Couleur d'accent
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}