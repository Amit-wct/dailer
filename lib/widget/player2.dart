import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class Player extends StatefulWidget {
  const Player({super.key, required this.url});

  final String url;
  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  final player = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  String formatTime(int seconds) {
    return '${(Duration(seconds: seconds))}'.split('.')[0].padLeft(2, '0');
  }

  @override
  void initState() {
    super.initState();

    player.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });

    player.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    player.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          // foregroundColor: Colors.green,
          backgroundColor: Colors.green,
          radius: 16,
          child: IconButton(
            icon: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              size: 15,
            ),
            onPressed: () {
              if (isPlaying) {
                player.pause();
              } else {
                player.play(UrlSource(widget.url));
              }
            },
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 20)),
          child: Slider(
            min: 0,
            max: duration.inSeconds.toDouble(),
            value: position.inSeconds.toDouble(),
            onChanged: (value) {
              final position = Duration(seconds: value.toInt());
              player.seek(position);
              player.resume();
            },
          ),
        ),
        Text(
          formatTime(position.inSeconds),
          style: TextStyle(fontSize: 12),
        ),
        Text(
          "/",
          style: TextStyle(fontSize: 12),
        ),
        Text(
          formatTime((duration - position).inSeconds),
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
