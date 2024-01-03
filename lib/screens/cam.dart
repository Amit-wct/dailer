import 'dart:convert';
import 'dart:io';
import 'package:Dialer/screens/login.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';

class Cam extends StatefulWidget {
  final timestamp;
  Cam({required this.timestamp});
  @override
  _CamState createState() => _CamState();
}

class _CamState extends State<Cam> {
  List<CameraDescription>? cameras; //list out the camera available
  CameraController? controller; //controller for camera
  XFile? image; //for captured image
  bool isPictureTaken = false;
  late String uploadURL =
      'https://${Url.text}/pbxlogin.py?l=${Username.text}&p=${Password.text}&tmp=${widget.timestamp}&a=upload_image';

  int camera_front = 1;

  @override
  void initState() {
    loadCamera();
    super.initState();
  }

  @override
  void dispose() {
    // Dispose of the camera controller when the widget is disposed
    controller?.dispose();
    super.dispose();
  }

  loadCamera() async {
    cameras = await availableCameras();
    if (cameras != null) {
      controller =
          CameraController(cameras![camera_front], ResolutionPreset.max);
      //cameras[0] = first camera, change to 1 to another camera
      print(cameras);

      controller!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    } else {
      print("NO any camera found");
    }
  }

  Upload(File imageFile) async {
    var stream = http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();

    var uri = Uri.parse(uploadURL);

    var request = http.MultipartRequest("POST", uri);
    var multipartFile = http.MultipartFile('selfie', stream, length,
        filename: basename(imageFile.path));
    //contentType: new MediaType('image', 'png'));

    request.files.add(multipartFile);
    print('trying to upload now');
    var response = await request.send();
    print(response.statusCode);
    response.stream.transform(utf8.decoder).listen((value) {
      print(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Capture Selfie",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
      body: Center(
          child: Column(children: [
        // ElevatedButton(
        //     onPressed: () {
        //       setState(() {
        //         if (camera_front == 1) {
        //           camera_front = 0;
        //         } else {
        //           camera_front = 1;
        //         }
        //         loadCamera();
        //       });
        //     },
        //     child: camera_front == 1 ? Text('back cam') : Text("front cam")),
        SizedBox(
          height: 20,
        ),
        Container(
            height: 400,
            // width: 400,
            child: controller == null
                ? Center(child: Text("Loading Camera..."))
                : !controller!.value.isInitialized
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : isPictureTaken
                        ? Image.file(
                            File(image!.path),
                            height: 300,
                          )
                        : CameraPreview(controller!)),
        isPictureTaken
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RoundIconButton(
                        childIcon: Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            isPictureTaken = false;
                          });
                        },
                      ),
                      RoundIconButton(
                        childIcon: Icon(Icons.check),
                        onPressed: () async {
                          await Upload(File(image!.path));
                          Navigator.pop(context, 'captured');
                        },
                      ),
                    ],
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: RoundIconButton(
                  childIcon: Icon(Icons.camera),
                  onPressed: () async {
                    try {
                      if (controller != null) {
                        //check if contrller is not null
                        if (controller!.value.isInitialized) {
                          //check if controller is initialized
                          image =
                              await controller!.takePicture(); //capture image
                          setState(() {
                            //update UI
                            isPictureTaken = true;
                          });
                        }
                      }
                    } catch (e) {
                      print(e); //show error
                    }
                  },
                ),
              ),
        // ElevatedButton.icon(
        //     //image capture button
        //     onPressed: () async {
        //       try {
        //         if (controller != null) {
        //           //check if contrller is not null
        //           if (controller!.value.isInitialized) {
        //             //check if controller is initialized
        //             image = await controller!.takePicture(); //capture image
        //             setState(() {
        //               //update UI
        //               isPictureTaken = true;
        //             });
        //           }
        //         }
        //       } catch (e) {
        //         print(e); //show error
        //       }
        //     },
        //     icon: Icon(Icons.camera),
        //     label: Text("Capture"),
        //   ),
      ])),
    );
  }
}

class RoundIconButton extends StatelessWidget {
  const RoundIconButton({this.onPressed, this.childIcon});
  final onPressed;
  final childIcon;
  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      elevation: 6,
      child: childIcon,
      onPressed: onPressed,
      constraints: BoxConstraints.tightFor(width: 56, height: 56),
      shape: CircleBorder(),
      fillColor: Colors.lightGreen,
    );
  }
}
