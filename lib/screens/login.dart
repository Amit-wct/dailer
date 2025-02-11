import 'dart:convert';

import 'package:Dialer/screens/queue_login.dart';
import 'package:Dialer/services/networking.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import '../components/input_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './navigation.dart';
import 'package:http/http.dart' as http;
import 'package:Dialer/services/location.dart';
import 'cam.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:intl/intl.dart';

final Url = TextEditingController();
final Username = TextEditingController();
final Password = TextEditingController();
FocusNode focusNode_url = FocusNode();
FocusNode focusNode_username = FocusNode();
FocusNode focusNode_password = FocusNode();

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  bool remember_me = false;
  String _response = '';
  String url = "";

  DateTime now = DateTime.now();

  // Format the timestamp

  bool _obscureText = true;
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

  Future<void> fetchData() async {
    url =
        'https://${Url.text}/pbxlogin.py?l=${Username.text}&p=${Password.text}&a=login';
    print(url);
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          _response = response.body;
          print("type");
          print(_response.runtimeType);
        });
      } else {
        setState(() {
          _response = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      // Handle the exception here
      print('hello');
      setState(() {
        _response = '{\'status\': \'No Internet\'}';
      });
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    Url.dispose();
    Username.dispose();
    Password.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadValuesFromPreferences();
  }

  Future<void> getLocationData(timestamp) async {
    Location loc = Location();
    await loc.getCurrentLocation();
    String url =
        'https://${Url.text}/pbxlogin.py?l=${Username.text}&p=${Password.text}&la=${loc.latitude}&lo=${loc.longitude}&tmp=$timestamp&a=save_cordinates';

    print(url);
    NetworkHelper helper = new NetworkHelper(url);
    final data = await helper.getData();
    print(data);
  }

  Future<void> _loadValuesFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String server_url = prefs.getString('server_url') ?? '';
    String username = prefs.getString('username') ?? '';
    String password = prefs.getString('password') ?? '';
    setState(() {
      Url.text = server_url;
      Password.text = password;
      Username.text = username;
    });

    bool? checkboxValue = prefs.getBool('checkboxValue');
    if (checkboxValue != null) {
      setState(() {
        remember_me = checkboxValue;
      });
    }
  }

  Future<void> _saveValuesToPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_url', Url.text);
  }

  Future<void> _saveLoginCreds(String username, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('password', password);
  }

  Future<void> updateCheckboxValue(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('checkboxValue', value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 50),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 20, 30, 25),
                child: Image.asset('./images/logo3.png'),
              ),
              InputFieldMaker(
                  'Enter url', Url, TextInputType.url, focusNode_url),
              InputFieldMaker(
                  'Username', Username, TextInputType.text, focusNode_username),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: TextFormField(
                  focusNode: focusNode_password,
                  obscureText: _obscureText,
                  controller: Password,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                  keyboardType: TextInputType.visiblePassword,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                child: Row(
                  children: [
                    Checkbox(
                      value: this.remember_me,
                      onChanged: (bool? value) {
                        setState(() {
                          remember_me = value!;
                        });
                        if (remember_me) {
                          _saveLoginCreds(Username.text, Password.text);
                        } else {
                          _saveLoginCreds("", "");
                        }
                        updateCheckboxValue(remember_me);
                      },
                    ),
                    Text('Remember me'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50), // NEW
                    ),
                    onPressed: () async {
                      String? alertDesc;
                      String? alertTitle;
                      bool isloginvalid = false;
                      await fetchData();
                      _saveValuesToPreferences();
                      print(_response);
                      if (_response.isNotEmpty) {
                        _response = _response.replaceAll("'", '"');
                        Map<String, dynamic> mapData = jsonDecode(_response);
                        print(mapData);
                        print(mapData['number']);

                        if (mapData['status'] == 'login success') {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();

                          await prefs.setString('number1', mapData['number']);
                          await prefs.setString(
                              'number2', mapData['call_ext'].toString());
                          isloginvalid = true;

                          String formattedTimestamp =
                              DateFormat('yyyy-MM-dd_HH-mm-ss_SSSSSS')
                                  .format(now);

                          print('from flutter still');
                          print(formattedTimestamp);

                          if (mapData['attendance_cord'] == 't') {
                            print('sending cords');

                            getLocationData(formattedTimestamp);
                          }

                          if (mapData['attendance_selfie'] == 't') {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Cam(
                                        timestamp: formattedTimestamp,
                                      )),
                            ).then((result) {
                              if (result != 'captured') {
                                isloginvalid = false;
                                alertDesc = 'Selfie not taken';
                              }
                            });
                          }

                          if (mapData['queues_present'] == 't') {
                            print(mapData['queues'].length);
                            print(mapData['queues']);

                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => QueueLogin(
                                        queues: mapData['queues'],
                                      )),
                            ).then((value) {
                              print(value);
                            });
                          }
                        } else if (mapData['status'] == 'No Internet') {
                          alertDesc = "login failed check internet connection";
                          alertTitle = mapData['status'];
                        } else if (mapData['status'] == 'login failed') {
                          alertDesc = "Incorrect username or password";
                          alertTitle = mapData['status'];
                        }
                      }

                      if (isloginvalid == true) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AppBarPage()),
                        );
                      } else {
                        Alert(
                                style: alertStyle,
                                type: AlertType.error,
                                context: context,
                                title: alertTitle,
                                desc: alertDesc)
                            .show();
                      }
                    },
                    child: Text('Login')),
              ),
              TextButton(
                onPressed: _launchUrl,
                child: Text(
                  'sign up',
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl() async {
    if (!await launch("https://www.warmconnect.in/hosted-pbx.php")) {
      throw Exception('Could not launch');
    }
  }
}
