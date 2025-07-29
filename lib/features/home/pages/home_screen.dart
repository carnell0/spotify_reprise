import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_reprise/features/auth/bloc/theme_bloc.dart';
import 'package:spotify_reprise/features/auth/bloc/theme_state.dart';
// Importez vos pages réelles
import 'package:spotify_reprise/features/home/pages/home_content_page.dart';
import 'package:spotify_reprise/features/home/pages/library_page.dart'; // NOUVEL IMPORT
import 'package:spotify_reprise/features/home/pages/profile_page.dart';
import 'package:spotify_reprise/features/home/pages/search_page.dart'; // Assurez-vous d'avoir cette page

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Index de l'onglet actuellement sélectionné

  // Liste des pages pour chaque onglet
  late final List<Widget> _pages; // Déclarez comme 'late final'

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeContentPage(),
      const SearchPage(), // Assurez-vous d'avoir votre SearchPage
      const LibraryPage(), // NOUVELLE PAGE: Votre bibliothèque de musiques locales
      const ProfilePage(),
    ];
  }

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
        final Color dynamicForegroundColor = isDarkMode ? Colors.white : Colors.black;
        final Color dynamicBackgroundColor = isDarkMode ? Colors.black : Colors.white;
        final Color accentColor = Theme.of(context).primaryColor; // Couleur verte de Spotify

        return Scaffold(
          // Le contenu de la page actuelle basée sur l'onglet sélectionné
          body: _pages[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_filled),
                label: 'Home',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
              // CHANGEMENT ICI : ANCIENNEMENT 'Favorites'
              const BottomNavigationBarItem(
                icon: Icon(Icons.library_music), // Nouvelle icône pour la bibliothèque
                label: 'Bibliothèque', // Nouveau label
              ),
              const BottomNavigationBarItem(
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
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          ),
        );
      },
    );
  }
}