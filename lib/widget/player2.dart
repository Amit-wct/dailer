import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';
import 'package:http/http.dart' as http;

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
  bool playing_first = true;
  bool isRecordingExist = true;
  String? _response;
  Future<void> CheckRecording() async {
    String url =
        widget.url.replaceFirst('a=get_recording', 'a=check_recording');

    print(url);

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        _response = response.body;
        if (_response == 'f\n') {
          isRecordingExist = false;
        } else {
          print('nhi ho raha $_response');
        }
      });
    } else {
      setState(() {
        _response = 'Error: ${response.statusCode}';
      });
    }

    print(_response);
  }

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

  void toastmsg(String msg) {
    MotionToast toast = MotionToast.success(
      description: Text(
        '$msg',
        style: TextStyle(fontSize: 12),
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
            onPressed: () async {
              try {
                if (playing_first) {
                  await CheckRecording();
                  if (isRecordingExist) {
                    toastmsg("Please wait rec will be played once loaded");
                  }
                }
                playing_first = false;
                if (isPlaying) {
                  player.pause();
                } else {
                  if (isRecordingExist) {
                    player.play(UrlSource(widget.url));
                  } else {
                    toastmsg("Recording file not available for this call");
                  }
                }
              } catch (e, stackTrace) {
                print("Error playing audio: $e");
                print("StackTrace: $stackTrace");
              }
            },
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 20)),
          child: Container(
            width: 150,
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
        ),
        Text(
          formatTime(position.inSeconds),
          style: TextStyle(fontSize: 10),
        ),
        Text(
          "/",
          style: TextStyle(fontSize: 10),
        ),
        Text(
          formatTime((duration - position).inSeconds),
          style: TextStyle(fontSize: 10),
        ),
      ],
    );
  }
}
