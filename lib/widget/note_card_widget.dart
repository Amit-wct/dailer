import 'package:Dialer/screens/main_dialer.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import './player2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:intl/intl.dart';
import 'package:Dialer/model/note.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../screens/login.dart';

class NoteCardWidget extends StatefulWidget {
  NoteCardWidget({
    Key? key,
    required this.note,
    required this.index,
  }) : super(key: key);

  final Note note;
  final int index;

  @override
  State<NoteCardWidget> createState() => _NoteCardWidgetState();
}

class _NoteCardWidgetState extends State<NoteCardWidget> {
  String? did1;

  String? extension;

  bool show_player = true;
  bool isLoading = false;

  List<Icon> priorityIcons = [
    const Icon(
      Icons.check_circle_outline,
      color: Colors.grey,
      size: 24,
    ),
    const Icon(
      Icons.low_priority,
      color: Colors.lightGreen,
      size: 24,
    ),
    const Icon(
      Icons.flag,
      color: Colors.orange,
      size: 24,
    ),
    const Icon(
      Icons.crisis_alert,
      color: Colors.red,
      size: 24,
    ),
  ];

  Map<String, Icon> call_types = {
    "Missed": const Icon(
      Icons.call_missed_outgoing,
      color: Colors.red,
      size: 20,
    ),
    "Outgoing": const Icon(
      Icons.call_made,
      color: Colors.green,
      size: 20,
    ),
    "Incoming": const Icon(
      Icons.call_received,
      size: 20,
      color: Colors.blue,
    )
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      isLoading = true;
    });
    _initializeData();
  }

  Future<void> _initializeData() async {
    await CheckRecording();
    setState(() {
      isLoading = false;
    });
  }

  Future<String> _loadExtensionValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('number2') ?? '';
  }

  Future<void> _loadValuesFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    did1 = prefs.getString('number1') ?? '';
    extension = prefs.getString('number2') ?? '';
  }

  Future<String> fetchExt() async {
    String url =
        'https://${Url.text}/pbxlogin.py?l=${Username.text}&p=${Password.text}&a=get_extn';
    print(url);
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      return "";
    }
  }

  Future<void> CheckRecording() async {
    String url =
        'https://${Url.text}/pbxlogin.py?l=${Username.text}&p=${Password.text}&a=test_rec&uid=${widget.note.trkn}';

    print(url);

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      if (response.body == 'file not found\n') {
        setState(() {
          show_player = false;
        });

        print('come check this');
      }
    } else {
      setState(() {
        show_player = false;
        print('object');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    /// Pick colors from the accent colors based on index

    // final time = DateFormat.yMMMd().format(note.createdTime);
    // print(note.createdTime);
    // CheckRecording();
    final time = DateFormat.yMMMd().add_jm().format(widget.note.createdTime);
    print(widget.note.trkn);
    String no_to_show = widget.note.call_type == "Outgoing"
        ? widget.note.phone.toString()
        : widget.note.caller.toString();

    return Card(
      color: Colors.lightGreen[100],
      child: isLoading
          ? const SpinKitWaveSpinner(
              color: Color.fromARGB(255, 114, 189, 71),
              waveColor: Color.fromARGB(230, 147, 197, 132),
              size: 100)
          : Stack(
              children: [
                Container(
                  constraints: const BoxConstraints(minHeight: 70),
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        time,
                        style: TextStyle(color: Colors.grey.shade800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.note.title,
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            no_to_show,
                            style: TextStyle(
                                color: Colors.grey.shade800, fontSize: 16),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: call_types[widget.note.call_type] ??
                                Icon(Icons.abc),
                          ),
                        ],
                      ),
                      show_player
                          ? Player(
                              url:
                                  'https://${Url.text}/pbxlogin.py?l=${Username.text}&p=${Password.text}&a=get_recording&uid=${widget.note.trkn}')
                          : Text('Rec not found')
                    ],
                  ),
                ),
                Positioned(
                    top: 8,
                    right: 12,
                    child: priorityIcons[widget.note.priority]),
                Positioned(
                  bottom: 10,
                  right: 0,
                  child: GestureDetector(
                    onTap: () async {
                      await _loadValuesFromPreferences();
                      String ext = extension!;
                      // print("ext from field pref $ext");
                      if (ext.isEmpty) {
                        ext = await _loadExtensionValue();
                        // print("ext after loadfrom pref $ext");
                      }
                      if (ext.isEmpty) {
                        try {
                          ext = await fetchExt();
                        } catch (e) {
                          MotionToast toast = MotionToast.error(
                            title: const Text(
                              'There is some issue',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            description: Text(
                              'Please check your internet connection',
                              style: TextStyle(fontSize: 12),
                            ),
                            layoutOrientation: ToastOrientation.ltr,
                            animationType: AnimationType.fromRight,
                            dismissable: true,
                          );
                          toast.show(context);
                        }
                        // print("ext after fetch pref $ext");
                      }

                      print("clicked");
                      String callnow =
                          "+$did1,,${ext.replaceAll('\n', '')},,$no_to_show#";
                      print(callnow);
                      if (ext.isNotEmpty) {
                        await FlutterPhoneDirectCaller.callNumber(callnow);
                      }
                    },
                    child: Container(
                      height: 50,
                      width: 48,
                      color: Colors.transparent,
                      child: Icon(
                        Icons.call_sharp,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
