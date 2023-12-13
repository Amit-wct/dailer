import 'package:flutter/material.dart';
import '../components/logout_function.dart';
import 'package:http/http.dart' as http;
import 'login.dart';

class SettingsWidget extends StatefulWidget {
  @override
  _SettingsWidget createState() => _SettingsWidget();
}

class _SettingsWidget extends State<SettingsWidget> {
  String? _response;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> loginLogoutQueues(String data) async {
    String url =
        'https://${Url.text}/pbxlogin.py?l=${Username.text}&p=${Password.text}&a=queue_login_logout &queues=$data';
    print(url);

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        _response = response.body;
        print(_response);
      });
    } else {
      setState(() {
        _response = 'Error while logging to queue: ${response.statusCode}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Setting",
          // style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("This app is used for 2 stage dial"),
              ],
            ),
            Text("Version : 7.0.0"),
          ],
        ),
      ),
    );
  }
}
