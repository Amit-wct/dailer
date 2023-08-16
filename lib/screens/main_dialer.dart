import 'package:flutter/material.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Dialer/screens/login.dart';
import '../components/input_field.dart';
import '../db/notes_database.dart';
import '../model/note.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:Dialer/components/logout_function.dart';
import 'package:http/http.dart' as http;

final fixed_no = TextEditingController();
final extension = TextEditingController();

class MainDialer extends StatefulWidget {
  const MainDialer({super.key});

  @override
  State<MainDialer> createState() => _MainDialerState();
}

class _MainDialerState extends State<MainDialer> {
  final number_to_dial = TextEditingController();
  String _response = '';
  String url = "";
  FocusNode _focusNode = FocusNode();
  FocusNode focusNode_extension = FocusNode();
  FocusNode focusNode_fixed_no = FocusNode();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
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
        body: SingleChildScrollView(
          child: Container(
            child: Container(
              margin: EdgeInsets.only(top: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  InputFieldMaker('Enter a fixed number', fixed_no,
                      TextInputType.phone, focusNode_fixed_no),
                  InputFieldMaker('Enter option', extension,
                      TextInputType.phone, focusNode_extension),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    child: TextFormField(
                      focusNode: _focusNode,
                      onEditingComplete: () {
                        FocusScope.of(context)
                            .unfocus(); // Dismiss the keyboard
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
                          String did = formatNumber(fixed_no.text);
                          print(did);
                          final String callnow =
                              "tel:$did,,${extension.text},,${number_to_dial.text.replaceAll(RegExp(r'[^0-9]'), '')}#";

                          print(callnow);

                          if (number_to_dial.text.length < 3) {
                            MotionToast.warning(
                              // title: const Text(
                              //   'Info',
                              //   style: TextStyle(fontWeight: FontWeight.bold),
                              // ),
                              description: const Text(
                                'Number can\'t be empty',
                                style: TextStyle(fontSize: 12),
                              ),
                              layoutOrientation: ToastOrientation.ltr,
                              animationType: AnimationType.fromRight,
                              dismissable: true,
                              position: MotionToastPosition.bottom,
                            ).show(context);
                          } else {
                            await FlutterPhoneDirectCaller.callNumber(callnow);
                          }
                          // await addNote();
                        },
                        child: const Text('Call'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Future addNote() async {
  //   String phone_v = formatNumber(number_to_dial.text);
  //   print(phone_v);
  //   final note = Note(
  //     title: "${number_to_dial.text}",
  //     domain: Url.text,
  //     priority: 0,
  //     phone: int.parse(phone_v),
  //     description: "",
  //     agent: Username.text,
  //     createdTime: DateTime.now(),
  //     call_type: "Outgoing",
  //     trkn: "Outgoing",
  //   );

  //   String titleString = note.title.split(" ").join("|-|-|-|");
  //   String descriptionString = note.description.split(" ").join("|-|-|-|");
  //   String datetime = "${note.createdTime}".split(" ").join("|-|-|-|");
  //   String newNoteData =
  //       "${note.priority}-,-${note.phone}-,-$titleString-,-$descriptionString-,-$datetime-,-${note.call_type}";

  //   addNoteOnline(newNoteData);
  //   await NotesDatabase.instance.create(note);
  // }

  String formatNumber(String num) {
    num = num.replaceAll(RegExp(r'[^0-9]'), '');
    if (num.length == 12 && num[0] == '9' && num[1] == '1') {
      return "+$num";
    } else if (num.length < 10) {
      return "0$num";
    } else if (num.length == 10) {
      return "+91$num";
    } else {
      return "+$num";
    }
  }
}
