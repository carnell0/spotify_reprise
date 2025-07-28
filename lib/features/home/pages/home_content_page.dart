import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_reprise/features/auth/bloc/theme_bloc.dart';
import 'package:spotify_reprise/features/auth/bloc/theme_state.dart';

class HomeContentPage extends StatelessWidget {
  const HomeContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final bool isDarkMode = state.themeData.brightness == Brightness.dark;
        final Color dynamicForegroundColor = isDarkMode ? Colors.white : Colors.black;
        final Color accentColor = Theme.of(context).primaryColor; // Couleur verte

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent, // Transparente pour laisser le fond personnalisé
            elevation: 0,
            title: Text(
              'Good evening', // Ou 'Bonjour', 'Good morning', etc.
              style: TextStyle(
                color: dynamicForegroundColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.notifications_none, color: dynamicForegroundColor),
                onPressed: () {
                  // TODO: Gérer les notifications
                },
              ),
              IconButton(
                icon: Icon(Icons.history, color: dynamicForegroundColor),
                onPressed: () {
                  // TODO: Gérer l'historique de lecture
                },
              ),
              IconButton(
                icon: Icon(Icons.settings, color: dynamicForegroundColor),
                onPressed: () {
                  // TODO: Gérer les paramètres
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Section "Recently Played"
                  Text(
                    'Recently Played',
                    style: TextStyle(
                      color: dynamicForegroundColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Placeholder pour les éléments récemment joués
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5, // Exemple
                      itemBuilder: (context, index) {
                        return _buildRecentlyPlayedItem(context, isDarkMode, accentColor, index);
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Section "Your Playlists" ou "Made for you"
                  Text(
                    'Made for you',
                    style: TextStyle(
                      color: dynamicForegroundColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(), // Pour éviter le double scroll
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 colonnes
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 0.8, // Ajuste le rapport hauteur/largeur des éléments
                    ),
                    itemCount: 6, // Exemple
                    itemBuilder: (context, index) {
                      return _buildGridItem(context, isDarkMode, accentColor, index);
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentlyPlayedItem(BuildContext context, bool isDarkMode, Color accentColor, int index) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 15),
      child: Column(
        children: [
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage('https://via.placeholder.com/150/FF0000/FFFFFF?text=Album+$index'), // Placeholder image
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Song Title $index',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontSize: 12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, bool isDarkMode, Color accentColor, int index) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                'https://via.placeholder.com/200/0000FF/FFFFFF?text=Playlist+$index', // Placeholder image
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Playlist Name $index',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Text(
              'Description or Artist',
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black54,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}