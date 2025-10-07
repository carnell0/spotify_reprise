import 'package:on_audio_query_forked_carnell/on_audio_query.dart';
import 'package:audio_service/audio_service.dart';

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

  // Conversion en `MediaItem` pour `audio_service`
  MediaItem toMediaItem() {
    return MediaItem(
      id: id.toString(),
      title: title,
      artist: artist,
      album: album,
      duration: duration,
      artUri: albumId != 0 ? Uri.parse('content://media/external/audio/albumart/$albumId') : null,
      extras: {'uri': uri},
    );
  }
}
