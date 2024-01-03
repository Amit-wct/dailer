import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';
import 'package:rflutter_alert/rflutter_alert.dart' as alert;

class Player extends StatefulWidget {
  const Player({Key? key, required this.url}) : super(key: key);

  final String url;

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  final player = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  bool playingFirst = true;

  String formatTime(int seconds) {
    return '${Duration(seconds: seconds)}'.split('.')[0].padLeft(2, '0');
  }

  @override
  void initState() {
    super.initState();

    player.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = state.playing;
        });
      }
    });

    player.durationStream.listen((newDuration) {
      if (mounted) {
        setState(() {
          duration = newDuration ?? Duration.zero;
        });
      }
    });

    player.positionStream.listen((newPosition) {
      if (mounted) {
        setState(() {
          position = newPosition ?? Duration.zero;
        });
      }
    });
  }

  void toastMsg(String msg) {
    MotionToast toast = MotionToast.success(
      description: Text(
        msg,
        style: const TextStyle(fontSize: 12),
      ),
      layoutOrientation: ToastOrientation.ltr,
      animationType: AnimationType.fromRight,
      dismissable: true,
      position: MotionToastPosition.bottom,
    );
    toast.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.green,
          radius: 16,
          child: IconButton(
            icon: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              size: 15,
            ),
            onPressed: () async {
              try {
                if (playingFirst) {
                  toastMsg("Please wait rec will be played once loaded");
                }
                playingFirst = false;
                if (isPlaying) {
                  await player.pause();
                } else {
                  await player.setUrl(widget.url);
                  await player.play();
                }
              } catch (e, stackTrace) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("File not found"),
                      content: const Text(
                          "Recording for this call is not available at this moment try after some time"),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pop(); // Close the alert dialog
                          },
                          child: const Text("Cancel"),
                        ),
                      ],
                    );
                  },
                );
              }
            },
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 2,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
          ),
          child: Container(
            width: 150,
            child: Slider(
              min: 0,
              max: duration.inSeconds.toDouble(),
              value: position.inSeconds.toDouble(),
              onChanged: (value) {
                final position = Duration(seconds: value.toInt());
                player.seek(position);
                player.play();
              },
            ),
          ),
        ),
        Text(
          formatTime(position.inSeconds),
          style: const TextStyle(fontSize: 10),
        ),
        const Text(
          "/",
          style: TextStyle(fontSize: 10),
        ),
        Text(
          formatTime((duration - position).inSeconds),
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}
