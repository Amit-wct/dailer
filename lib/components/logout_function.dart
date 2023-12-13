import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../screens/login.dart';
import '../screens/main_dialer.dart';
import 'package:http/http.dart' as http;

void showLogoutConfirmation(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
          TextButton(
            child: Text('OK'),
            onPressed: () async {
              // Perform logout actions here
              // ...

              // Close the app
              await logoutFromQueues();
              SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            },
          ),
        ],
      );
    },
  );
}

Future<void> logoutFromQueues() async {
  String url =
      'https://${Url.text}/pbxlogin.py?l=${Username.text}&p=${Password.text}&a=queue_logout';
  print(url);

  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    print(response.body);
  } else {
    print('Error while logging out from queue: ${response.statusCode}');
  }
}
