import 'package:flutter/material.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:two_stage_d/screens/login.dart';
import '../components/input_field.dart';
import '../db/notes_database.dart';
import '../model/note.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:two_stage_d/components/logout_function.dart';
import 'package:http/http.dart' as http;

class MainDialer extends StatefulWidget {
  const MainDialer({super.key});

  @override
  State<MainDialer> createState() => _MainDialerState();
}

class _MainDialerState extends State<MainDialer> {
  final fixed_no = TextEditingController();
  final extension = TextEditingController();
  final number_to_dial = TextEditingController();
  String _response = '';
  String url = "";

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    fixed_no.dispose();
    extension.dispose();
    number_to_dial.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _loadValuesFromPreferences();
  }

  Future<void> _loadValuesFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String number1 = prefs.getString('number1') ?? '';
    String number2 = prefs.getString('number2') ?? '';

    setState(() {
      fixed_no.text = number1;
      extension.text = number2;
    });
  }

  Future<void> addNoteOnline(String data) async {
    url =
        'http://${Url.text}/pbxlogin.py?l=${Username.text}&p=${Password.text}&a=add_note&d=$data';
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Dialer",
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
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
      backgroundColor: Color.fromRGBO(249, 253, 246, 1),
      body: Container(
        margin: EdgeInsets.only(top: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            InputFieldMaker(
                'Enter a fixed number', fixed_no, TextInputType.phone),
            InputFieldMaker('Enter option', extension, TextInputType.phone),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: TextFormField(
                onEditingComplete: () {
                  FocusScope.of(context).unfocus(); // Dismiss the keyboard
                },
                controller: number_to_dial,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter number to dial',
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.contact_page,
                    ),
                    onPressed: () async {
                      final PhoneContact contact =
                          await FlutterContactPicker.pickPhoneContact();
                      print(contact.phoneNumber!.number);
                      number_to_dial.text = contact.phoneNumber!.number!;
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50), // NEW
                  ),
                  onPressed: () async {
                    String did = fixed_no.text;
                    if (did.length == 12 && did[0] == '9' && did[1] == '1') {
                      did = "+" + did;
                    } else if (did.length < 10) {
                      did = "0" + did;
                    } else {
                      print(did.length);
                      print(did[0]);
                      print(did[1]);
                      print("not if");
                    }
                    final String callnow = "tel:" +
                        did +
                        ",," +
                        extension.text +
                        ",," +
                        number_to_dial.text.replaceAll(RegExp(r'[^0-9]'), '') +
                        "#";

                    print(callnow);
                    await FlutterPhoneDirectCaller.callNumber(callnow);

                    int nump = int.parse(
                        number_to_dial.text.replaceAll(RegExp(r'[^0-9]'), ''));
                    print(nump);
                    await addNote();
                  },
                  child: const Text('Call'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future addNote() async {
    final note = Note(
      title: "${number_to_dial.text} -Outgoing call",
      domain: Url.text,
      priority: 0,
      phone: int.parse(number_to_dial.text.replaceAll(RegExp(r'[^0-9]'), '')),
      description: "",
      agent: Username.text,
      createdTime: DateTime.now(),
    );

    String titleString = note.title.split(" ").join("|-|-|-|");
    String descriptionString = note.description.split(" ").join("|-|-|-|");
    String datetime = "${note.createdTime}".split(" ").join("|-|-|-|");
    String newNoteData =
        "${note.priority}-,-${note.phone}-,-$titleString-,-$descriptionString-,-$datetime";

    addNoteOnline(newNoteData);
    await NotesDatabase.instance.create(note);
  }
}
