// lib/models/local_song.dart
import 'package:on_audio_query/on_audio_query.dart';

class LocalSong {
  final int id;
  final String title;
  final String artist;
  final String album;
  final String uri;
  final Duration duration;
  final int albumId;

  const LocalSong({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.uri,
    required this.duration,
    required this.albumId,
  });

  factory LocalSong.fromSongModel(SongModel song) {
    return LocalSong(
      id: song.id,
      title: song.title,
      artist: song.artist ?? 'Unknown Artist',
      album: song.album ?? 'Unknown Album',
      uri: song.uri ?? '',
      duration: Duration(milliseconds: song.duration ?? 0),
      albumId: song.albumId ?? 0,
    );
  }
}