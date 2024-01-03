import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'login.dart';

class QueueLogin extends StatefulWidget {
  final List queues;

  QueueLogin({required this.queues});

  @override
  _QueueLoginState createState() => _QueueLoginState();
}

class _QueueLoginState extends State<QueueLogin> {
  late List<bool> checkedStates;

  String? _response = 'Continuing without queue login';

  Future<void> loginToQueues(String data) async {
    String url =
        'https://${Url.text}/pbxlogin.py?l=${Username.text}&p=${Password.text}&a=queue_login&queues=$data';
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
  void initState() {
    super.initState();
    // Initialize checkedStates based on the length of queues
    checkedStates = List.generate(widget.queues.length, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Queue Login",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < widget.queues.length; i++)
              Row(
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Checkbox(
                    value: checkedStates[i],
                    onChanged: (value) {
                      setState(() {
                        checkedStates[i] = value!;
                      });
                    },
                  ),
                  Text(widget.queues[i]),
                ],
              ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // Add your button click logic here
                String queues = '';
                for (int i = 0; i < widget.queues.length; i++) {
                  if (checkedStates[i])
                    queues = queues + '-${widget.queues[i]}';
                  print(
                      '${widget.queues[i]} Checkbox state: ${checkedStates[i]}');
                }
                print(queues);
                print('check this');
                if (queues != '') await loginToQueues(queues);
                // print(_response);
                // print('hello');

                // toastmsg(_response!);
                // Alert(
                //         // style: alertStyle,
                //         type: AlertType.error,
                //         context: context,
                //         // title: alertTitle,
                //         desc: _response)
                //     .show();

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Login Alert"),
                      content: Text(_response ?? "No response"),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.pop(context);
                          },
                          child: Text('OK'),
                        ),
                      ],
                    );
                  },
                );

                // Navigator.pop(context, _response);
              },
              child: Text('Login to Queue'),
            ),
          ],
        ),
      ),
    );
  }

//   void toastmsg(String msg) {
//     MotionToast toast = MotionToast.success(
//       description: Text(
//         '$msg',
//         style: TextStyle(fontSize: 12),
//       ),
//       layoutOrientation: ToastOrientation.ltr,
//       animationType: AnimationType.fromRight,
//       dismissable: true,
//       position: MotionToastPosition.bottom,
//     );
//     toast.show(context);
//   }
}
