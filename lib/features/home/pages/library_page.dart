import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:spotify_reprise/di.dart';
import 'package:spotify_reprise/features/auth/bloc/theme_bloc.dart';
import 'package:spotify_reprise/features/auth/bloc/theme_state.dart';
import 'package:spotify_reprise/features/home/pages/music_page.dart';
import 'package:spotify_reprise/models/local_song.dart';
import 'dart:typed_data';
import 'package:on_audio_query_forked_carnell/on_audio_query.dart';
import 'package:logger/logger.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<LocalSong> _allSongs = [];
  late AudioHandler _audioHandler;
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _audioHandler = sl<AudioHandler>();
    _requestPermissionsAndLoadSongs();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _requestAudioPermissions() async {
    final Map<Permission, PermissionStatus> statuses = await [
      Permission.audio,
      Permission.storage,
    ].request();

    if (statuses[Permission.audio]!.isGranted || statuses[Permission.storage]!.isGranted) {
      return true;
    }

    if (statuses[Permission.audio]!.isPermanentlyDenied || statuses[Permission.storage]!.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Permission refusée de façon permanente. Veuillez l'activer dans les paramètres.")),
        );
        await openAppSettings();
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
        orderType: OrderType.DESC_OR_GREATER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
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
      _logger.e("Erreur lors de la requête des chansons dans LibraryPage: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de chargement des musiques : $e")),
        );
      }
    }
  }

  Future<Uint8List?> _getArtwork(int albumId) async {
    if (albumId == 0) return null;
    return await _audioQuery.queryArtwork(
      albumId,
      ArtworkType.ALBUM,
      format: ArtworkFormat.JPEG,
      size: 200,
      quality: 100,
    );
  }

  Future<void> _playSong(LocalSong song) async {
    final queue = _allSongs.map((s) => s.toMediaItem()).toList();
    final index = queue.indexWhere((item) => item.id == song.id.toString());
    if (index == -1) return;
    await _audioHandler.updateQueue(queue);
    await _audioHandler.skipToQueueItem(index);
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MusicPage()),
      );
    }
  }

  Future<void> _shuffleAndPlay() async {
    if (_allSongs.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aucune musique à lire en mode aléatoire.")),
        );
      }
      return;
    }
    final queue = _allSongs.map((s) => s.toMediaItem()).toList();
    await _audioHandler.updateQueue(queue);
    await _audioHandler.setShuffleMode(AudioServiceShuffleMode.all);
    await _audioHandler.skipToQueueItem(0);
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MusicPage()),
      );
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
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.shuffle, color: Colors.white),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }

  Widget _buildSongListItem(LocalSong song, bool isDarkMode) {
    return GestureDetector(
      onTap: () => _playSong(song),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            _buildArtworkWidget(song.albumId, 50, 50, defaultColor: Colors.blueGrey),
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
