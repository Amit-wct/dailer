import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:two_stage_d/db/notes_database.dart';
import 'package:two_stage_d/model/note.dart';
import 'package:two_stage_d/screens/edit_note_page.dart';
import 'package:http/http.dart' as http;
import './login.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

  var alertStyle = AlertStyle(
    animationType: AnimationType.grow,
    isCloseButton: false,
    descStyle: TextStyle(fontWeight: FontWeight.w400),
    // animationDuration: Duration(milliseconds: 200),
    alertBorder: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
      side: BorderSide(
        color: Colors.grey,
      ),
    ),
  );

  @override
  void initState() {
    super.initState();

    refreshNote();
  }

  Future refreshNote() async {
    setState(() => isLoading = true);

    this.note = await NotesDatabase.instance.readNote(widget.noteId);

    setState(() => isLoading = false);
  }

  Future<void> sheduleCallback(String dt) async {
    url =
        'http://${Url.text}/pbxlogin.py?l=${Username.text}&p=${Password.text}&a=callback&cbn=${note.phone}&dt=$dt';
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
          actions: [callbackButton(), editButton(), deleteButton()],
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
                    Text(
                      note.title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      DateFormat.yMMMd().format(note.createdTime),
                    ),
                    SizedBox(height: 8),
                    Divider(color: Colors.black),
                    note.description.isEmpty
                        ? Text(
                            "Click on edit button to add something to this note",
                            style: TextStyle(color: Colors.black38),
                          )
                        : Text(
                            note.description,
                          ),
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
          await deleteNoteOnline(widget.noteId);
          Navigator.of(context).pop();
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
            await sheduleCallback(callbackDateTime[1].replaceAll(' ', '_'));
            if (_response.isNotEmpty) {
              _response = _response.replaceAll("'", '"');
              Map<String, dynamic> mapData = jsonDecode(_response);
              print(mapData);
              if (mapData['status'] == "callback scheduled") {
                setState(() {
                  _callbackSchedule = 'call back scheduled';
                });
                Fluttertoast.showToast(
                    msg: "call back scheduled",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0);
              }
            }
          }
        },
      );
}
