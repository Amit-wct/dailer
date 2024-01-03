import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';
import '../components/logout_function.dart';
import 'package:http/http.dart' as http;
import 'login.dart';
import 'dart:convert';

class SettingsWidget extends StatefulWidget {
  @override
  _SettingsWidget createState() => _SettingsWidget();
}

class _SettingsWidget extends State<SettingsWidget> {
  String? _response;

  bool isLoading = false;
  Map<String, dynamic>? data;
  List<bool> checkboxValues = [];

  // Variable to track if there are any changes in checkbox values
  bool hasChanges = false;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    initialize();
  }

  initialize() async {
    await loginLogoutQueues();
    isLoading = false;
    initializeCheckboxValues();
  }

  void initializeCheckboxValues() {
    if (data != null && data!.containsKey('queue_status')) {
      final queueStatus = data!['queue_status'] as List<dynamic>;
      checkboxValues = List<bool>.generate(queueStatus.length, (index) {
        final item = queueStatus[index];
        final int value = item[item.keys.first];
        return value == 1;
      });
    }
  }

  Future<void> loginLogoutQueues() async {
    String url =
        'https://${Url.text}/pbxlogin.py?l=${Username.text}&p=${Password.text}&a=queue_login_logout';
    //print(url);

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        _response = response.body;
        _response = _response!.replaceAll("'", "\"");
        data = json.decode(_response!);
      });
    } else {
      setState(() {
        _response = 'Error while fetching queue status: ${response.statusCode}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Queues"),
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
      body: isLoading
          ? Center(
              child: const SpinKitWaveSpinner(
                  color: Color.fromARGB(255, 114, 189, 71),
                  waveColor: Color.fromARGB(230, 147, 197, 132),
                  size: 100),
            )
          : Container(
              margin: EdgeInsets.only(top: 30, left: 50, right: 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Dynamically create checkboxes based on JSON data
                  ...List.generate(
                    checkboxValues.length,
                    (index) => CheckboxListTile(
                      title: Text(data!['queue_status'][index].keys.first),
                      value: checkboxValues[index],
                      onChanged: (bool? newValue) {
                        setState(() {
                          checkboxValues[index] = newValue ?? false;
                          hasChanges =
                              true; // Set changes flag when checkbox value changes
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      // Create a new JSON object with updated values only if there are changes
                      if (hasChanges) {
                        final updatedJson = createUpdatedJson();
                        // Upload the updated JSON values using POST request
                        await uploadUpdatedValues(updatedJson);
                      } else {
                        toastmsg("No changes in checkbox values.");
                      }
                    },
                    child: Text("Save"),
                  ),
                ],
              ),
            ),
    );
  }

  Map<String, dynamic> createUpdatedJson() {
    final updatedValues = <Map<String, dynamic>>[];

    for (int index = 0; index < checkboxValues.length; index++) {
      final queueName = data!['queue_status'][index].keys.first;
      final originalValue = data!['queue_status'][index][queueName];
      final isChecked = checkboxValues[index];

      // Check if the checkbox value has changed
      if (isChecked != (originalValue == 1)) {
        updatedValues.add({queueName: isChecked ? 1 : 0});

        // Update the original data with the new value
        data!['queue_status'][index][queueName] = isChecked ? 1 : 0;
      }
    }

    return {'queue_status': updatedValues};
  }

  Future<void> uploadUpdatedValues(Map<String, dynamic> updatedJson) async {
    try {
      String url =
          'https://${Url.text}/pbxlogin.py?l=${Username.text}&p=${Password.text}&a=upload_updated_values';
      print(url);
      print('updated value : ${json.encode(updatedJson)}');
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'data': json.encode(updatedJson)},
      );

      if (response.statusCode == 200) {
        print("Values uploaded successfully");
        // Reset changes flag after successful upload

        toastmsg(response.body);
        // toastmsg("");
        setState(() {
          hasChanges = false;
        });
        // Add any additional logic you need after successful upload
      } else {
        toastmsg("Error in login/logout change: ${response.statusCode}");
      }
    } catch (error) {
      toastmsg("Error in login/logout change: $error");
    }
  }

  void toastmsg(String msg) {
    MotionToast toast = MotionToast.success(
      description: Text(
        '$msg',
        style: TextStyle(fontSize: 12),
      ),
      layoutOrientation: ToastOrientation.ltr,
      animationType: AnimationType.fromRight,
      dismissable: true,
      position: MotionToastPosition.bottom,
    );
    toast.show(context);
  }
}
