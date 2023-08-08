import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:Dialer/db/notes_database.dart';
import 'package:Dialer/model/note.dart';
import 'package:Dialer/screens/note_detail_page.dart';
import 'package:Dialer/widget/note_card_widget.dart';
import '../components/logout_function.dart';
import 'login.dart';
import 'package:http/http.dart' as http;

class CallNotes extends StatefulWidget {
  @override
  _CallNotesState createState() => _CallNotesState();
}

class _CallNotesState extends State<CallNotes> {
  late List<Note> notes;
  bool isLoading = false;
  String _response = '';
  String url = "";

  @override
  void initState() {
    super.initState();
    testinit();
    refreshNotes();
  }

  @override
  void dispose() {
    // NotesDatabase.instance.close();

    super.dispose();
  }

  Future testinit() async {
    WidgetsFlutterBinding.ensureInitialized();
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future refreshNotes() async {
    setState(() => isLoading = true);

    await fetchData();

    notes = formatNotes(_response) ?? [];
    await NotesDatabase.instance.clearData();

    // notes = notes.where((note) => note.agent == Username.text).toList();
    notes = notes.reversed.toList();
    for (var note in notes) {
      await NotesDatabase.instance.create(note);
    }

    setState(() => isLoading = false);
  }

  Future<void> fetchData() async {
    url =
        'http://${Url.text}/pbxlogin.py?l=${Username.text}&p=${Password.text}&a=fetch_call_notes';
    print(url);
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        _response = response.body;
        print(_response);
      });
    } else {
      setState(() {
        _response = 'Error: ${response.statusCode}';
      });
    }
  }

  List<Note>? formatNotes(String data) {
    if (_response.length > 5) {
      _response = _response.replaceAll("'", '"');

      List newList = json.decode(_response);

      List<Note> notes = newList.map((item) {
        String id = item['id'];
        int unique_id = int.parse(id.substring(id.length - 5, id.length) +
            Random().nextInt(9999).toString());
        int priority = item['priority'];
        String domain = item['domainname'];
        int phone = int.parse(item['destination']);
        String title = item['title'];
        String description = item['description'];
        String agent = item['omuser'];
        String datetimeTemp = item['time'].split("+")[0];
        String call_type = item['call_type'];
        String caller = item['caller'].replaceAll('\n', '');
        print(caller);
        DateTime time = DateTime.parse(datetimeTemp);

        Note temp = Note(
          id: unique_id,
          priority: priority,
          domain: domain,
          phone: phone,
          title: title,
          description: description,
          agent: agent,
          createdTime: time,
          call_type: call_type,
          trkn: id,
          caller: caller,
        );
        return temp;
      }).toList();

      return notes;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(
            'Call Notes',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blueGrey[900],
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.logout,
                color: Colors.white,
              ),
              onPressed: () {
                showLogoutConfirmation(context);
              },
            )
          ],
        ),
        body: Center(
          child: isLoading
              ? CircularProgressIndicator()
              : notes.isEmpty
                  ? Text(
                      'No Notes',
                    )
                  : buildNotes(),
        ),
        // floatingActionButton: FloatingActionButton(
        //   child: Icon(Icons.add),
        //   onPressed: () async {
        //     await Navigator.of(context).push(
        //       MaterialPageRoute(builder: (context) => AddEditNotePage()),
        //     );

        //     refreshNotes();
        //   },
        // ),
      );

  Widget buildNotes() => StaggeredGridView.countBuilder(
        padding: EdgeInsets.all(8),
        itemCount: notes.length,
        staggeredTileBuilder: (index) => StaggeredTile.fit(4),
        crossAxisCount: 4,
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
        itemBuilder: (context, index) {
          final note = notes[index];

          return GestureDetector(
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => NoteDetailPage(noteId: note.id!),
              ));

              refreshNotes();
            },
            child: NoteCardWidget(note: note, index: index),
          );
        },
      );
}
