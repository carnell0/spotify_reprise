import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_reprise/di.dart';
import 'package:spotify_reprise/features/auth/bloc/theme_bloc.dart';
import 'package:spotify_reprise/features/auth/bloc/theme_state.dart';
import 'package:spotify_reprise/features/home/pages/home_content_page.dart';
import 'package:spotify_reprise/features/home/pages/library_page.dart' as library_page;
import 'package:spotify_reprise/features/home/pages/music_page.dart';
import 'package:spotify_reprise/features/home/pages/profile_page.dart';
import 'package:spotify_reprise/features/home/pages/search_page.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  late final AudioHandler _audioHandler;

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
    _audioHandler = sl<AudioHandler>();
    _pages = [
      const HomeContentPage(),
      const SearchPage(),
      const library_page.LibraryPage(),
      const ProfilePage(),
    ];
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _requestStoragePermission();
    }
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
          body: Stack(
            children: [
              _pages[_selectedIndex],
              StreamBuilder<MediaItem?>(
                stream: _audioHandler.mediaItem,
                builder: (context, snapshot) {
                  final mediaItem = snapshot.data;
                  if (mediaItem == null) {
                    return const SizedBox.shrink();
                  }
                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: _buildMiniPlayer(mediaItem, isDarkMode),
                  );
                },
              ),
            ],
          ),
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
              const BottomNavigationBarItem(
                icon: Icon(Icons.library_music),
                label: 'Bibliothèque',
              ),
              const BottomNavigationBarItem(
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

  Widget _buildMiniPlayer(MediaItem mediaItem, bool isDarkMode) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MusicPage()),
        );
      },
      child: Container(
        height: 60,
        color: isDarkMode ? Colors.grey[850] : Colors.grey[300],
        child: Row(
          children: [
            mediaItem.artUri != null
                ? Image.network(
                    mediaItem.artUri.toString(),
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey,
                    child: const Icon(Icons.music_note, color: Colors.white),
                  ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    mediaItem.title,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    mediaItem.artist ?? 'Artiste inconnu',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            StreamBuilder<PlaybackState>(
              stream: _audioHandler.playbackState,
              builder: (context, snapshot) {
                final playing = snapshot.data?.playing ?? false;
                return IconButton(
                  icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                  onPressed: () {
                    if (playing) {
                      _audioHandler.pause();
                    } else {
                      _audioHandler.play();
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}