import 'package:flutter/material.dart';
import 'package:two_stage_d/db/notes_database.dart';
import 'package:two_stage_d/model/note.dart';
import 'package:two_stage_d/widget/note_form_widget.dart';
import 'package:http/http.dart' as http;

import 'login.dart';

class AddEditNotePage extends StatefulWidget {
  final Note? note;

  const AddEditNotePage({
    Key? key,
    this.note,
  }) : super(key: key);
  @override
  _AddEditNotePageState createState() => _AddEditNotePageState();
}

class _AddEditNotePageState extends State<AddEditNotePage> {
  final _formKey = GlobalKey<FormState>();
  late String domain;
  late int priority;
  late int phone;

  late String title;
  late String description;
  late String agent;
  late String call_type;

  String _response = '';
  String url = "";
  String updatedNoteData = "";

  @override
  void initState() {
    super.initState();

    domain = widget.note?.domain ?? "";
    priority = widget.note?.priority ?? 0;
    title = widget.note?.title ?? '';
    description = widget.note?.description ?? '';
  }

  Future<void> updateNoteOnline(String data) async {
    url =
        'http://${Url.text}/pbxlogin.py?l=${Username.text}&p=${Password.text}&a=update_notes&d=$data';
    print(url);
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        _response = response.body;
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
          actions: [buildButton()],
          backgroundColor: Colors.blueGrey[900],
          foregroundColor: Colors.white,
        ),
        body: Form(
          key: _formKey,
          child: NoteFormWidget(
            domain: domain,
            priority: priority,
            title: title,
            description: description,
            onChangedNumber: (number) => setState(() => this.priority = number),
            onChangedTitle: (title) => setState(() => this.title = title),
            onChangedDescription: (description) =>
                setState(() => this.description = description),
          ),
        ),
      );

  Widget buildButton() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: IconButton(
        icon: Icon(
          Icons.save,
          color: Colors.lightGreen,
        ),
        onPressed: addOrUpdateNote,
      ),
    );
  }

  void addOrUpdateNote() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.note != null;

      if (isUpdating) {
        await updateNote();
      } else {
        await addNote();
      }

      Navigator.of(context).pop();
    }
  }

  Future updateNote() async {
    final note = widget.note!.copy(
      priority: priority,
      title: title,
      description: description,
    );

    String titleString = note.title.split(" ").join("|-|-|-|");
    String descriptionString = note.description.split(" ").join("|-|-|-|");
    updatedNoteData =
        "${note.id}-,-${note.priority}-,-$titleString-,-$descriptionString";

    await updateNoteOnline(updatedNoteData);
    await NotesDatabase.instance.update(note);
  }

  Future addNote() async {
    final note = Note(
      title: title,
      domain: domain,
      priority: priority,
      phone: phone,
      description: description,
      agent: agent,
      call_type: call_type,
      createdTime: DateTime.now(),
    );

    await NotesDatabase.instance.create(note);
  }
}
