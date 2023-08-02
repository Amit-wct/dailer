import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:two_stage_d/db/notes_database.dart';
import 'package:two_stage_d/model/note.dart';
import 'package:two_stage_d/screens/note_detail_page.dart';
import 'package:two_stage_d/widget/note_card_widget.dart';
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

  int c = 0;
  List<Note>? formatNotes(String data) {
    if (_response.length > 5) {
      List newList = _response.split("|#|");

      List<Note> notes = newList.map((item) {
        List<String> properties = item.split("|&|");
        int id = int.parse(properties[0]);
        int priority = int.parse(properties[1]);
        String domain = properties[2];
        int phone = int.parse(properties[3]);
        String title = properties[4];
        String description = properties[5];
        String agent = properties[6];
        String datetimeTemp = properties[7].split("+")[0];
        String call_type = properties[8].replaceAll('\n', '');

        c++;
        // print(c);
        // print(datetimeTemp);
        DateTime time = DateTime.parse(datetimeTemp);
//   DateTime time = DateTime.now();

        Note temp = Note(
          id: id,
          priority: priority,
          domain: domain,
          phone: phone,
          title: title,
          description: description,
          agent: agent,
          createdTime: time,
          call_type: call_type,
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
          print(note.call_type);
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
