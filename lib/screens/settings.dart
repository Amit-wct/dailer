import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/input_field.dart';
import '../components/logout_function.dart';

class SettingsWidget extends StatefulWidget {
  @override
  _SettingsWidget createState() => _SettingsWidget();
}

class _SettingsWidget extends State<SettingsWidget> {
  TextEditingController _number1Controller = TextEditingController();
  TextEditingController _number2Controller = TextEditingController();
  FocusNode focusNode1 = FocusNode();
  FocusNode focusNode2 = FocusNode();

  @override
  void dispose() {
    _number1Controller.dispose();
    _number2Controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadValuesFromPreferences();
  }

  Future<void> _loadValuesFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String number1 = prefs.getString('number1') ?? '';
    String number2 = prefs.getString('number2') ?? '';

    setState(() {
      _number1Controller.text = number1;
      _number2Controller.text = number2;
    });
  }

  Future<void> _saveValuesToPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('number1', _number1Controller.text);
    await prefs.setString('number2', _number2Controller.text);
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
            "About",
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
          // child: Column(
          //   children: [
          //     InputFieldMaker('Enter a fixed number', _number1Controller,
          //         TextInputType.phone, focusNode1),
          //     InputFieldMaker('Enter option', _number2Controller,
          //         TextInputType.phone, focusNode2),
          //     Padding(
          //       padding: const EdgeInsets.all(32.0),
          //       child: ElevatedButton(
          //         style: ElevatedButton.styleFrom(
          //           minimumSize: const Size.fromHeight(50), // NEW
          //         ),
          //         onPressed: () {
          //           int? number1, number2;
          //           setState(() {
          //             number1 = int.tryParse(_number1Controller.text) ?? 0;
          //             number2 = int.tryParse(_number2Controller.text) ?? 0;
          //           });

          //           // Do something with the numbers
          //           print('Number 1: $number1, Number 2: $number2');

          //           _saveValuesToPreferences();
          //           FocusScope.of(context).unfocus();
          //           // Navigator.push(
          //           //   context,
          //           //   MaterialPageRoute(builder: (context) => const MainDialer()),
          //           // );
          //           MotionToast toast = MotionToast.success(
          //             // title: const Text(
          //             //   'Info',
          //             //   style: TextStyle(fontWeight: FontWeight.bold),
          //             // ),
          //             description: const Text(
          //               'settings saved Succesfully',
          //               style: TextStyle(fontSize: 12),
          //             ),
          //             layoutOrientation: ToastOrientation.ltr,
          //             animationType: AnimationType.fromRight,
          //             dismissable: true,
          //             position: MotionToastPosition.bottom,
          //           );
          //           toast.show(context);
          //           Future.delayed(const Duration(seconds: 2)).then((value) {
          //             toast.dismiss();
          //           });
          //         },
          //         child: Text('OK'),
          //       ),
          //     ),
          //   ],
          // ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("This app is used for 2 stage dialing"),
                ],
              ),
              Text("Version : 5.0.0"),
            ],
          ),
        ),
      ),
    );
  }
}
