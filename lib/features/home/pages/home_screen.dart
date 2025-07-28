import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_reprise/features/auth/bloc/theme_bloc.dart';
import 'package:spotify_reprise/features/auth/bloc/theme_state.dart';
import 'package:spotify_reprise/features/home/pages/favorites_page.dart';
import 'package:spotify_reprise/features/home/pages/home_content_page.dart';
import 'package:spotify_reprise/features/home/pages/profile_page.dart';
import 'package:spotify_reprise/features/home/pages/search_page.dart';

// Importations des pages pour chaque onglet (à créer plus tard)
// import 'package:spotify_reprise/features/home/pages/home_content_page.dart';
// import 'package:spotify_reprise/features/search/pages/search_page.dart'; // Supposons un dossier 'search'
// import 'package:spotify_reprise/features/favorites/pages/favorites_page.dart'; // Supposons un dossier 'favorites'
// import 'package:spotify_reprise/features/profile/pages/profile_page.dart'; // Déjà dans la structure

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Index de l'onglet actuellement sélectionné

  // Liste des widgets pour chaque onglet de la BottomNavigationBar
  // Ces pages devront être créées dans leurs dossiers 'pages' respectifs
  final List<Widget> _pages = [
    // Remplacer ces place-holders par les véritables pages une fois créées
    const HomeContentPage(), // home_content_page.dart
    const SearchPage(), // search_page.dart
    const FavoritesPage(), // favorites_page.dart
    const ProfilePage(), // profile_page.dart
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final bool isDarkMode = state.themeData.brightness == Brightness.dark;
        final Color dynamicBackgroundColor = state.themeData.scaffoldBackgroundColor;
        final Color dynamicForegroundColor = isDarkMode ? Colors.white : Colors.black;
        final Color accentColor = Theme.of(context).primaryColor; // Couleur verte de Spotify

        return Scaffold(
          // Le contenu de la page actuelle basée sur l'onglet sélectionné
          body: _pages[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home_filled),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: 'Favorites',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: accentColor, // Couleur des icônes/labels sélectionnés
            unselectedItemColor: dynamicForegroundColor.withOpacity(0.6), // Couleur des icônes/labels non sélectionnés
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed, // Pour afficher tous les labels
            backgroundColor: dynamicBackgroundColor, // Couleur de fond de la barre de navigation
            selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
          ),
        );
      },
    );
  }
}