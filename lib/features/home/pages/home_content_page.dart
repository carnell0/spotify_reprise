import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_reprise/features/auth/bloc/theme_bloc.dart';
import 'package:spotify_reprise/features/auth/bloc/theme_state.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart'; // Importez pour les permissions
import 'package:just_audio/just_audio.dart'; // Pour la lecture audio (si non centralisé dans un service)
import 'dart:typed_data'; // Nécessaire pour Uint8List
=======
import 'package:permission_handler/permission_handler.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:typed_data';
import 'package:spotify_reprise/models/local_song.dart'; // Import du modèle LocalSong partagé

class HomeContentPage extends StatefulWidget {
  const HomeContentPage({super.key});

  @override
  State<HomeContentPage> createState() => _HomeContentPageState();
}

class _HomeContentPageState extends State<HomeContentPage> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<LocalSong> _allSongs = [];
  List<LocalSong> _recentlyPlayed = [];
  List<LocalSong> _mostPlayed = [];
  List<LocalSong> _favoriteSongs = [];

  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndLoadSongs();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _requestPermissionsAndLoadSongs() async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      try {
        final List<SongModel> songs = await _audioQuery.querySongs(
          sortType: SongSortType.DATE_ADDED,
          // Correction ici: Utilisation de DESC pour décroissant, ou DESC_OR_GREATER si on_audio_query le supporte.
          // Si DESC_OR_GREATER pose problème, utilisez juste DESC.
          orderType: OrderType.DESC_OR_GREATER, // Ou OrderType.DESC_OR_GREATER si c'était le but et que ça fonctionne
          uriType: UriType.EXTERNAL,
          ignoreCase: true,
        );

        setState(() {
          _allSongs = songs.map((s) => LocalSong.fromSongModel(s)).toList();

          if (_allSongs.isNotEmpty) {
            // Assurez-vous d'avoir assez de chansons pour éviter les erreurs d'index
            _recentlyPlayed = _allSongs.take(5).toList();
            _mostPlayed = _allSongs.length > 5 ? _allSongs.skip(5).take(5).toList() : [];
            _favoriteSongs = _allSongs.length > 10 ? _allSongs.skip(10).take(3).toList() : [];
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Aucune musique locale trouvée sur l'appareil.")),
              );
            }
          }
        });
      } catch (e) {
        print("Erreur lors de la requête des chansons: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur de chargement des musiques : $e")),
          );
        }
      }
    } else if (status.isDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("La permission de stockage est nécessaire pour lire la musique.")),
        );
      }
      openAppSettings();
    } else if (status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("La permission de stockage est refusée de façon permanente. Veuillez l'activer dans les paramètres.")),
        );
      }
      openAppSettings();
    }
  }

  Future<void> _playSong(LocalSong song) async {
    try {
      if (song.uri.isNotEmpty) {
        await _player.setAudioSource(AudioSource.uri(Uri.parse(song.uri)));
        await _player.play();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lecture de: ${song.title}')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Impossible de lire ce morceau (URI manquante ou invalide).')),
          );
        }
      }
    } catch (e) {
      print("Erreur lors de la lecture: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de lecture: $e')),
        );
      }
    }
  }

  Future<Uint8List?> _getArtwork(int albumId) async {
    if (albumId == 0) return null; // Retourne null si l'ID est 0 (souvent utilisé pour l'absence d'ID)
    return await _audioQuery.queryArtwork(
      albumId,
      ArtworkType.ALBUM,
      format: ArtworkFormat.JPEG,
      size: 200,
      quality: 100,
    );
  }

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
              'Good evening',
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
                icon: Icon(Icons.settings, color: dynamicForegroundColor),
                onPressed: () {
                  // TODO: Gérer les paramètres (rediriger vers ProfilePage ou une page de paramètres)
                },
              ),
            ],
          ),
          body: _allSongs.isEmpty && (_recentlyPlayed.isEmpty && _mostPlayed.isEmpty && _favoriteSongs.isEmpty)
              ? const Center(child: CircularProgressIndicator()) // Indicateur de chargement si aucune musique
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Section "Favoris" (Aperçu) ---
                      if (_favoriteSongs.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Text(
                          'Vos Favoris',
                          style: TextStyle(
                            color: dynamicForegroundColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        AnimatedOpacity(
                          opacity: 1.0,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeIn,
                          child: Wrap(
                            spacing: 12.0,
                            runSpacing: 12.0,
                            children: _favoriteSongs.map((song) => _buildFavoriteItem(song, isDarkMode)).toList(),
                          ),
                        ),
                      ],

                      // --- Section "Récemment Joué" ---
                      if (_recentlyPlayed.isNotEmpty) ...[
                        const SizedBox(height: 30),
                        Text(
                          'Récemment Joué',
                          style: TextStyle(
                            color: dynamicForegroundColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          height: 200,
                          child: PageView.builder(
                            itemCount: _recentlyPlayed.length,
                            controller: PageController(viewportFraction: 0.8),
                            itemBuilder: (context, index) {
                              final song = _recentlyPlayed[index];
                              return Center(
                                child: _buildRecentlyPlayedItem(song, isDarkMode, _playSong),
                              );
                            },
                          ),
                        ),
                      ],

                      // --- Section "Les plus écoutés" ---
                      if (_mostPlayed.isNotEmpty) ...[
                        const SizedBox(height: 30),
                        Text(
                          'Les plus écoutés',
                          style: TextStyle(
                            color: dynamicForegroundColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: _mostPlayed.length,
                          itemBuilder: (context, index) {
                            final song = _mostPlayed[index];
                            return _buildMostPlayedItem(song, isDarkMode, _playSong);
                          },
                        ),
                      ],
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildFavoriteItem(LocalSong song, bool isDarkMode) {
    return GestureDetector(
      onTap: () => _playSong(song),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[850] : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildArtworkWidget(song.albumId, 40, 40, isCircular: false, defaultColor: Colors.redAccent),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                song.title,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentlyPlayedItem(LocalSong song, bool isDarkMode, Function(LocalSong) onPlay) {
    return GestureDetector(
      onTap: () => onPlay(song),
      child: Card(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: _buildArtworkWidget(song.albumId, double.infinity, double.infinity, defaultColor: Colors.purple),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                song.title,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 8.0),
              child: Text(
                song.artist,
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMostPlayedItem(LocalSong song, bool isDarkMode, Function(LocalSong) onPlay) {
    return GestureDetector(
      onTap: () => onPlay(song),
      child: Card(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: _buildArtworkWidget(song.albumId, double.infinity, double.infinity, defaultColor: Colors.teal),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                song.title,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(
                song.artist,
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArtworkWidget(int albumId, double width, double height, {bool isCircular = false, required Color defaultColor}) {
    return FutureBuilder<Uint8List?>(
      future: _getArtwork(albumId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data != null) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(isCircular ? width / 2 : 4),
            child: Image.memory(
              snapshot.data!,
              width: width,
              height: height,
              fit: BoxFit.cover,
            ),
          );
        } else {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: defaultColor,
              shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: isCircular ? null : BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.music_note,
              color: Colors.white.withOpacity(0.7),
              size: width * 0.6 > height * 0.6 ? height * 0.6 : width * 0.6,
            ),
          );
        }
      },
    );
  }
}
