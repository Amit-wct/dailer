import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:Dialer/db/notes_database.dart';
import 'package:Dialer/model/note.dart';
import 'package:Dialer/screens/edit_note_page.dart';
import 'package:http/http.dart' as http;
import './login.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';
import '../widget/date_time_picker.dart';

class NoteDetailPage extends StatefulWidget {
  final int noteId;

  const NoteDetailPage({
    Key? key,
    required this.noteId,
  }) : super(key: key);

  @override
  _NoteDetailPageState createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late Note note;
  bool isLoading = false;
  String _response = '';
  String url = "";
  String _callbackSchedule = '';
  int? num_toast;

  @override
  void initState() {
    super.initState();

    refreshNote();
  }

  Future refreshNote() async {
    setState(() => isLoading = true);
    this.note = await NotesDatabase.instance.readNote(widget.noteId);
    print("here i am");

    print(note.phone);
    num_toast = note.phone;
    setState(() => isLoading = false);
  }

  Future<void> sheduleCallback(String dt) async {
    url =
        'http://${Url.text}/pbxlogin.py?l=${Username.text}&p=${Password.text}&a=callback&cbn=%2B${note.phone}&dt=$dt';
    print(url);
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        _response = response.body;
        print("type");
        print(_response);
      });
    } else {
      setState(() {
        _response = 'Error: ${response.statusCode}';
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [
            callbackButton(),
            editButton(),
            deleteButton(),
          ],
          backgroundColor: Colors.blueGrey[900],
          foregroundColor: Colors.white,
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: EdgeInsets.all(12),
                child: ListView(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[100], // Change the container color
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note.title,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          note.call_type == "Outgoing"
                              ? Text(
                                  "Number:- " + note.phone.toString(),
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                  ),
                                )
                              : Text(
                                  "Number:- " + note.caller.toString(),
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                          Text(
                            "Type:- ${note.call_type}",
                            style: TextStyle(
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            DateFormat.yMMMd()
                                .add_jm()
                                .format(note.createdTime),
                            style: TextStyle(
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Divider(
                      color: Colors.grey, // Change the divider color
                      height: 1, // Adjust the divider height
                      thickness: 1, // Adjust the divider thickness
                      indent: 8, // Adjust the indent of the divider
                      endIndent: 8, // Adjust the end indent of the divider
                    ),
                    SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        print("tapp");
                        if (isLoading) return;

                        await Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => AddEditNotePage(note: note),
                        ));

                        refreshNote();
                      },
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors
                              .lightGreen[100], // Change the container color
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: note.description.isEmpty
                            ? Text(
                                "Click on the edit button to add something to this note",
                                style: TextStyle(
                                  color: Colors.black38,
                                  fontStyle: FontStyle.italic,
                                ),
                              )
                            : Text(
                                note.description,
                              ),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
      );

  Future<void> deleteNoteOnline(int noteid) async {
    url =
        'http://${Url.text}/pbxlogin.py?l=${Username.text}&p=${Password.text}&a=delete_note&d=$noteid';
    print(url);
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      print(response.body);
    } else {
      setState(() {
        _response = 'Error: ${response.statusCode}';
      });
    }
  }

  void showAlert() {
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

  Widget editButton() => IconButton(
      icon: Icon(
        Icons.edit_outlined,
        color: Colors.lightGreen,
      ),
      onPressed: () async {
        if (isLoading) return;

        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddEditNotePage(note: note),
        ));

        refreshNote();
      });

  Widget deleteButton() => IconButton(
        icon: Icon(
          Icons.delete,
          color: Colors.lightGreen,
        ),
        onPressed: () async {
          await NotesDatabase.instance.delete(widget.noteId);
          try {
            await deleteNoteOnline(widget.noteId);
            Navigator.of(context).pop();
          } catch (e) {
            showAlert();
          }
        },
      );

  Widget callbackButton() => IconButton(
        icon: Icon(
          Icons.phone_callback,
          color: Colors.lightGreen,
        ),
        onPressed: () async {
          List callbackDateTime = await showDateTimePicker(context);

          if (callbackDateTime[0] == 1) {
            setState(() => isLoading = true);
            try {
              await sheduleCallback(callbackDateTime[1].replaceAll(' ', '_'));
            } catch (e) {
              showAlert();
            }
            setState(() => isLoading = false);
            if (_response.isNotEmpty) {
              _response = _response.replaceAll("'", '"');
              Map<String, dynamic> mapData = jsonDecode(_response);
              print(mapData);
              if (mapData['status'] == "callback scheduled") {
                setState(() {
                  _callbackSchedule = 'call back scheduled';
                });
                MotionToast toast = MotionToast.success(
                  title: const Text(
                    'Callback Scheduled',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  description: Text(
                    'call back scheduled for the number $num_toast at ${callbackDateTime[1]}',
                    style: TextStyle(fontSize: 12),
                  ),
                  layoutOrientation: ToastOrientation.ltr,
                  animationType: AnimationType.fromRight,
                  dismissable: true,
                );
                toast.show(context);
                Future.delayed(const Duration(seconds: 8)).then((value) {
                  toast.dismiss();
                });
              }
            }
          }
        },
      );
}
