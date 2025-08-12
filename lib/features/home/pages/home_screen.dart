import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_reprise/features/auth/bloc/theme_bloc.dart';
import 'package:spotify_reprise/features/auth/bloc/theme_state.dart';
import 'package:spotify_reprise/features/home/pages/home_content_page.dart';
import 'package:spotify_reprise/features/home/pages/library_page.dart';
import 'package:spotify_reprise/features/home/pages/profile_page.dart';
import 'package:spotify_reprise/features/home/pages/search_page.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  void _requestStoragePermission() async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      print("Permission d'accès au stockage accordée.");
    } else {
      print("Permission d'accès au stockage refusée.");
    }
  }

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeContentPage(),
      const SearchPage(),
      const LibraryPage(),
      const ProfilePage(),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestStoragePermission();
    });
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
        final Color accentColor = Theme.of(context).primaryColor;

        return Scaffold(
          body: _pages[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home_filled),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.library_music),
                label: 'Bibliothèque',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: accentColor,
            unselectedItemColor: dynamicForegroundColor.withOpacity(0.6),
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: dynamicBackgroundColor,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          ),
        );
      },
    );
  }
}