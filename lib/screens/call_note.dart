import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:Dialer/db/notes_database.dart';
import 'package:Dialer/model/note.dart';
import 'package:Dialer/screens/note_detail_page.dart';
import 'package:Dialer/widget/note_card_widget.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';
import '../components/logout_function.dart';
import 'login.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CallNotes extends StatefulWidget {
  const CallNotes({super.key});

  @override
  _CallNotesState createState() => _CallNotesState();
}

class _CallNotesState extends State<CallNotes> {
  late List<Note> notes;
  bool isLoading = false;
  String _response = '';
  String url = "";
  bool noInternet = false;
  DateTime? selectedDate;
  DateTime? toDate, fromDate;
  bool isfiltered = false;
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
    if (_response == 'Error: No internet') {
      noInternet = true;
      notes = [];
    } else {
      notes = formatNotes(_response) ?? [];
    }
    await NotesDatabase.instance.clearData();

    // notes = notes.where((note) => note.agent == Username.text).toList();
    notes = notes.reversed.toList();
    for (var note in notes) {
      await NotesDatabase.instance.create(note);
    }

    setState(() => isLoading = false);
  }

  Future<void> fetchData() async {
    // print("from fetchdata $selectedDate");

    if (toDate == null && fromDate == null) {
      url =
          'http://${Url.text}/pbxlogin.py?l=${Username.text}&p=${Password.text}&a=fetch_call_notes&toDate=none&fromDate=none';
      print(url);
    } else {
      String dateTo = toDate.toString().split(' ')[0];
      String dateFrom = fromDate.toString().split(' ')[0];

      url =
          'http://${Url.text}/pbxlogin.py?l=${Username.text}&p=${Password.text}&a=fetch_call_notes&fromDate=$dateFrom&toDate=$dateTo';
      print(url);
    }

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          _response = response.body;
          // print(_response);
        });
      } else {
        setState(() {
          _response = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      _response = 'Error: No internet';
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
        int phone =
            int.parse(item['destination'].replaceAll(RegExp(r'[^0-9]'), ''));
        String title = item['title'];
        String description = item['description'];
        String agent = item['omuser'];
        String datetimeTemp = item['time'].split("+")[0];
        String call_type = item['call_type'];
        String caller = item['caller'].replaceAll('\n', '');
        // print(caller);
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

  void showAlertMessage(String message) {
    MotionToast toast = MotionToast.warning(
      title: const Text(
        'Invalid Date',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      description: Text(
        message,
        style: const TextStyle(fontSize: 12),
      ),
      layoutOrientation: ToastOrientation.ltr,
      animationType: AnimationType.fromRight,
      dismissable: true,
    );
    toast.show(context);
  }

  dynamic searchFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  onTap: () async {
                    DateTime? selectedDate = await showDatePicker(
                      context: context,
                      initialDate: fromDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (selectedDate != null && selectedDate != fromDate) {
                      setState(() {
                        fromDate = selectedDate;
                      });
                    }
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'From Date',
                  ),
                  readOnly: true,
                  controller: TextEditingController(
                    text: fromDate != null
                        ? "${fromDate!.year}-${fromDate!.month.toString().padLeft(2, '0')}-${fromDate!.day.toString().padLeft(2, '0')}"
                        : "",
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  onTap: () async {
                    DateTime? selectedDate = await showDatePicker(
                      context: context,
                      initialDate: toDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (selectedDate != null && selectedDate != toDate) {
                      setState(() {
                        toDate = selectedDate;
                      });
                    }
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'To Date',
                  ),
                  readOnly: true,
                  controller: TextEditingController(
                    text: toDate != null
                        ? "${toDate!.year}-${toDate!.month.toString().padLeft(2, '0')}-${toDate!.day.toString().padLeft(2, '0')}"
                        : "",
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  // Handle the search action here
                  final now = DateTime.now();
                  if (fromDate != null && toDate != null) {
                    // print("Searching from $fromDate to $toDate");

                    if (toDate!.isBefore(fromDate!)) {
                      showAlertMessage('To date cannot be less than from date');
                    } else if (toDate!.isAfter(now)) {
                      showAlertMessage('To date cannot be future date');
                    } else if (fromDate!.isAfter(now)) {
                      showAlertMessage('From date cannot be future date');
                    } else {
                      refreshNotes();
                    }
                  } else {
                    showAlertMessage("To date from date cannot be empty");
                  }
                  isfiltered = true;
                },
                child: const Text('Search'),
              ),
            ],
          ),
          isfiltered
              ? Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        toDate = null;
                        fromDate = null;
                        isfiltered = false;
                      });

                      refreshNotes();
                    },
                    child: const Text("clear filter"),
                  ),
                )
              : const SizedBox(
                  height: 10,
                ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'Call Notes',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blueGrey[900],
          actions: <Widget>[
            IconButton(
              icon: const Icon(
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
              ? const SpinKitWaveSpinner(
                  color: Color.fromARGB(255, 114, 189, 71),
                  waveColor: Color.fromARGB(230, 147, 197, 132),
                  size: 100)
              : noInternet
                  ? const Text('No internet Connection')
                  : notes.isEmpty && !noInternet
                      ? Column(
                          children: [
                            searchFilter(),
                            const SizedBox(
                              height: 20,
                            ),
                            const Center(
                              child: Text(
                                'No Notes',
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            searchFilter(),
                            Expanded(
                              child: buildNotes(),
                            ),
                          ],
                        ),
        ),
        // floatingActionButton: FloatingActionButton(
        //   child: Icon(Icons.filter_alt_off_outlined),
        //   onPressed: () async {
        //     setState(() {
        //       toDate = null;
        //       fromDate = null;
        //     });

        //     refreshNotes();
        //   },
        // ),
      );

  Widget buildNotes() => StaggeredGridView.countBuilder(
        padding: const EdgeInsets.all(8),
        itemCount: notes.length,
        staggeredTileBuilder: (index) => const StaggeredTile.fit(4),
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
