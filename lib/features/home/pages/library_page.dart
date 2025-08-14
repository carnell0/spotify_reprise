import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:spotify_reprise/features/auth/bloc/theme_bloc.dart';
import 'package:spotify_reprise/features/auth/bloc/theme_state.dart';
import 'dart:typed_data'; // Pour Uint8List
import 'package:just_audio/just_audio.dart'; // Pour la lecture audio
import 'dart:math'; // Pour la lecture aléatoire

// Réutiliser le modèle LocalSong de home_content_page.dart
// Idéalement, ce modèle serait dans un fichier séparé partagé (ex: lib/models/local_song.dart)
class LocalSong {
  final int id;
  final String title;
  final String artist;
  final String album;
  final String? uri;
  final Duration duration;
  final int? albumId;

  const LocalSong({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.uri,
    required this.duration,
    this.albumId,
  });

  factory LocalSong.fromSongModel(SongModel song) {
    return LocalSong(
      id: song.id,
      title: song.title,
      artist: song.artist ?? 'Unknown Artist',
      album: song.album ?? 'Unknown Album',
      uri: song.uri,
      duration: Duration(milliseconds: song.duration ?? 0),
      albumId: song.albumId,
    );
  }
}

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<LocalSong> _allSongs = [];
  final AudioPlayer _player = AudioPlayer(); // Lecteur pour la lecture aléatoire

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndLoadSongs();
  }

  @override
  void dispose() {
    _player.dispose(); // Libérez le lecteur audio
    super.dispose();
  }

  Future<bool> _requestAudioPermissions() async {
    // Android 13+ : Permission.audio, sinon Permission.storage
    if (await Permission.audio.isGranted || await Permission.storage.isGranted) {
      return true;
    }
    PermissionStatus status;
    if (await Permission.audio.isDenied || await Permission.audio.isRestricted) {
      status = await Permission.audio.request();
      if (status.isGranted) return true;
    }
    if (await Permission.storage.isDenied || await Permission.storage.isRestricted) {
      status = await Permission.storage.request();
      if (status.isGranted) return true;
    }
    // Si refusé de façon permanente
    if (await Permission.audio.isPermanentlyDenied || await Permission.storage.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Permission refusée de façon permanente. Veuillez l'activer dans les paramètres.")),
        );
        openAppSettings();
      }
    }
    return false;
  }

  Future<void> _requestPermissionsAndLoadSongs() async {
    final hasPermission = await _requestAudioPermissions();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("La permission est nécessaire pour lire la musique.")),
        );
      }
      return;
    }
    try {
      final List<SongModel> songs = await _audioQuery.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
      );
      setState(() {
        _allSongs = songs.map((s) => LocalSong.fromSongModel(s)).toList();
      });
      if (_allSongs.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aucune musique locale trouvée sur l'appareil.")),
        );
      }
    } catch (e) {
      print("Erreur lors de la requête des chansons dans LibraryPage: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de chargement des musiques : $e")),
        );
      }
    }
  }

  Future<Uint8List?> _getArtwork(int id) async {
    return _audioQuery.queryArtwork(id, ArtworkType.AUDIO, size: 200);
  }

  // Fonction de lecture d'un morceau
  Future<void> _playSong(LocalSong song) async {
    try {
      if (song.uri != null && song.uri!.isNotEmpty) {
        await _player.setAudioSource(AudioSource.uri(Uri.parse(song.uri!)));
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

  // Fonction de lecture aléatoire
  Future<void> _shuffleAndPlay() async {
    if (_allSongs.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aucune musique à lire en mode aléatoire.")),
        );
      }
      return;
    }

    // Mélanger la liste des chansons
    List<LocalSong> shuffledSongs = List.from(_allSongs)..shuffle(Random());

    // Créer une playlist à partir des chansons mélangées
    final audioSourceList = shuffledSongs
        .where((song) => song.uri != null && song.uri!.isNotEmpty)
        .map((song) => AudioSource.uri(Uri.parse(song.uri!), tag: song)) // Ajouter la chanson comme tag pour info
        .toList();

    if (audioSourceList.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aucune musique valide trouvée pour la lecture aléatoire.")),
        );
      }
      return;
    }

    try {
      // Définir la source audio comme une playlist concacténée
      await _player.setAudioSource(
        ConcatenatingAudioSource(children: audioSourceList),
        initialIndex: 0,
        initialPosition: Duration.zero,
      );
      await _player.play();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lecture aléatoire démarrée !")),
        );
      }
      // TODO: Ici, vous voudriez mettre à jour un PlayerBloc/Cubit avec la chanson en cours
      // pour afficher la barre de lecture globale.
    } catch (e) {
      print("Erreur lors de la lecture aléatoire: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de lecture aléatoire: $e")),
        );
      }
    }
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
              'Votre Bibliothèque',
              style: TextStyle(
                color: dynamicForegroundColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: _allSongs.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: _allSongs.length,
                  itemBuilder: (context, index) {
                    final song = _allSongs[index];
                    return _buildSongListItem(song, isDarkMode);
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: _shuffleAndPlay,
            backgroundColor: Theme.of(context).primaryColor, // Couleur accent de Spotify
            child: const Icon(Icons.shuffle, color: Colors.white),
          ),
          // Positionnement du FloatingActionButton en bas à gauche
          floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        );
      },
    );
  }

  // Widget pour un élément de la liste de chansons
  Widget _buildSongListItem(LocalSong song, bool isDarkMode) {
    return GestureDetector(
      onTap: () => _playSong(song),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            // Artwork (utilisant le même widget que HomeContentPage)
            _buildArtworkWidget(song.id, 50, 50, defaultColor: Colors.blueGrey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${song.artist} • ${song.album}',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // TODO: Ajouter une icône de menu (trois points) pour des options supplémentaires
            IconButton(
              icon: Icon(Icons.more_vert, color: isDarkMode ? Colors.white70 : Colors.black54),
              onPressed: () {
                // Gérer les options du morceau
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget générique pour charger et afficher l'artwork (copié de HomeContentPage)
  Widget _buildArtworkWidget(int id, double width, double height, {bool isCircular = false, required Color defaultColor}) {
    return FutureBuilder<Uint8List?>(
      future: _getArtwork(id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data != null) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(isCircular ? width / 2 : 4), // Arrondi pour le cercle ou le carré
            child: Image.memory(
              snapshot.data!,
              width: width,
              height: height,
              fit: BoxFit.cover,
            ),
          );
        } else {
          // Fallback artwork (couleur par défaut ou icône)
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