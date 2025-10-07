// lib/features/home/pages/music_page.dart

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_reprise/di.dart';
import 'package:spotify_reprise/features/auth/bloc/theme_bloc.dart';
import 'package:spotify_reprise/features/auth/bloc/theme_state.dart';
import 'package:rxdart/rxdart.dart';

class MusicPage extends StatefulWidget {
  const MusicPage({super.key});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  late AudioHandler _audioHandler;

  @override
  void initState() {
    super.initState();
    _audioHandler = sl<AudioHandler>();
  }

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _audioHandler.playbackState.map((state) => state.position).distinct(),
        _audioHandler.playbackState.map((state) => state.bufferedPosition).distinct(),
        _audioHandler.mediaItem.map((item) => item?.duration).distinct(),
        (position, bufferedPosition, duration) => PositionData(
          position,
          bufferedPosition,
          duration ?? Duration.zero,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) > 200) {
          Navigator.pop(context);
        }
      },
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          final bool isDarkMode = state.themeData.brightness == Brightness.dark;
          final Color dynamicForegroundColor = isDarkMode ? Colors.white : Colors.black;
          final Color accentColor = Theme.of(context).primaryColor;

          return Scaffold(
            backgroundColor: isDarkMode ? Colors.black : Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.keyboard_arrow_down, color: dynamicForegroundColor),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Text(
                'En cours de lecture',
                style: TextStyle(color: dynamicForegroundColor, fontSize: 16),
              ),
              centerTitle: true,
            ),
            body: StreamBuilder<MediaItem?>(
              stream: _audioHandler.mediaItem,
              builder: (context, snapshot) {
                final mediaItem = snapshot.data;
                if (mediaItem == null) {
                  return const Center(child: Text("Aucune musique en cours"));
                }
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Image de l'album
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            mediaItem.artUri?.toString() ?? 'https://via.placeholder.com/150',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Titre et artiste
                      Column(
                        children: [
                          Text(
                            mediaItem.title,
                            style: TextStyle(
                              color: dynamicForegroundColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            mediaItem.artist ?? 'Artiste inconnu',
                            style: TextStyle(
                              color: dynamicForegroundColor.withOpacity(0.6),
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Barre de progression
                      StreamBuilder<PositionData>(
                        stream: _positionDataStream,
                        builder: (context, snapshot) {
                          final positionData = snapshot.data;
                          return SeekBar(
                            duration: positionData?.duration ?? Duration.zero,
                            position: positionData?.position ?? Duration.zero,
                            bufferedPosition: positionData?.bufferedPosition ?? Duration.zero,
                            onChangeEnd: _audioHandler.seek,
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      // Contrôles de lecture
                      StreamBuilder<PlaybackState>(
                        stream: _audioHandler.playbackState,
                        builder: (context, snapshot) {
                          final playbackState = snapshot.data;
                          final processingState = playbackState?.processingState;
                          final playing = playbackState?.playing ?? false;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(
                                icon: Icon(Icons.shuffle, size: 28, color: dynamicForegroundColor),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: Icon(Icons.skip_previous_rounded, size: 48, color: dynamicForegroundColor),
                                onPressed: _audioHandler.skipToPrevious,
                              ),
                              if (processingState == AudioProcessingState.loading ||
                                  processingState == AudioProcessingState.buffering)
                                Container(
                                  margin: const EdgeInsets.all(8.0),
                                  width: 64.0,
                                  height: 64.0,
                                  child: const CircularProgressIndicator(),
                                )
                              else if (playing != true)
                                IconButton(
                                  icon: Icon(Icons.play_circle_filled_rounded, size: 72, color: accentColor),
                                  onPressed: _audioHandler.play,
                                )
                              else
                                IconButton(
                                  icon: Icon(Icons.pause_circle_filled_rounded, size: 72, color: accentColor),
                                  onPressed: _audioHandler.pause,
                                ),
                              IconButton(
                                icon: Icon(Icons.skip_next_rounded, size: 48, color: dynamicForegroundColor),
                                onPressed: _audioHandler.skipToNext,
                              ),
                              IconButton(
                                icon: Icon(Icons.repeat, size: 28, color: dynamicForegroundColor),
                                onPressed: () {},
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final Duration bufferedPosition;
  final ValueChanged<Duration>? onChanged;
  final ValueChanged<Duration>? onChangeEnd;

  const SeekBar({
    super.key,
    required this.duration,
    required this.position,
    required this.bufferedPosition,
    this.onChanged,
    this.onChangeEnd,
  });

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double? _dragValue;
  late SliderThemeData _sliderThemeData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _sliderThemeData = SliderTheme.of(context).copyWith(
      trackHeight: 2.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SliderTheme(
          data: _sliderThemeData.copyWith(
            thumbShape: HiddenThumbComponentShape(),
            activeTrackColor: Colors.blue.shade100,
            inactiveTrackColor: Colors.grey.shade300,
          ),
          child: ExcludeSemantics(
            child: Slider(
              min: 0.0,
              max: widget.duration.inMilliseconds.toDouble(),
              value: widget.bufferedPosition.inMilliseconds.toDouble(),
              onChanged: (value) {},
            ),
          ),
        ),
        Slider(
          min: 0.0,
          max: widget.duration.inMilliseconds.toDouble(),
          value: _dragValue ?? widget.position.inMilliseconds.toDouble(),
          onChanged: (value) {
            setState(() {
              _dragValue = value;
            });
            if (widget.onChanged != null) {
              widget.onChanged!(Duration(milliseconds: value.round()));
            }
          },
          onChangeEnd: (value) {
            if (widget.onChangeEnd != null) {
              widget.onChangeEnd!(Duration(milliseconds: value.round()));
            }
            _dragValue = null;
          },
        ),
        Positioned(
          right: 16.0,
          bottom: 0.0,
          child: Text(
              RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})')
                      .firstMatch("0${widget.duration}")
                      ?.group(1) ??
                  '0${widget.duration}',
              style: Theme.of(context).textTheme.bodySmall),
        ),
        Positioned(
          left: 16.0,
          bottom: 0.0,
          child: Text(
              RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})')
                      .firstMatch("0${widget.position}")
                      ?.group(1) ??
                  '0${widget.position}',
              style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );
  }
}

class HiddenThumbComponentShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.zero;

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {}
}