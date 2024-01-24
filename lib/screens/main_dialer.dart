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
import 'package:Dialer/widget/dailpad.dart';

String? did1;
String? extension;

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
    did1 = prefs.getString('number1') ?? '';
    extension = prefs.getString('number2') ?? '';
  }

  Future<void> addNoteOnline(String data) async {
    url =
        'https://${Url.text}/pbxlogin.py?l=${Username.text}&p=${Password.text}&a=add_note&d=$data';
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        print('hello');
        return false;
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 16),
              child: SizedBox(
                width: 290,
                child: TextFormField(
                  readOnly: true,
                  // showCursor: true,
                  autofocus: true,
                  style: TextStyle(fontSize: 25),
                  controller: number_to_dial,

                  decoration: InputDecoration(
                    // border: OutlineInputBorder(),
                    hintText: 'Enter number',
                    suffixIcon: IconButton(
                      enableFeedback: true,
                      splashColor: const Color.fromARGB(255, 190, 235, 191),
                      icon: const Icon(
                        Icons.contact_page,
                      ),
                      onPressed: () async {
                        PhoneContact? contact;
                        try {
                          contact =
                              await FlutterContactPicker.pickPhoneContact();
                        } catch (e) {
                          number_to_dial.text = "";
                        }
                        // print(contact!.phoneNumber!.number);
                        if (contact != null)
                          number_to_dial.text = contact.phoneNumber!.number!;
                      },
                    ),
                  ),
                ),
              ),
            ),
            Dailpad(number_to_dial, callNumber),
          ],
        ),
      ),
    );
  }

  void callNumber() async {
    String did = formatNumber(did1!);
    // print(did);
    final String callnow =
        "tel:$did,,$extension,,${number_to_dial.text.replaceAll(RegExp(r'[^0-9]'), '')}#";

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
  }

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
