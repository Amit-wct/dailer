// // background_task.dart
// import 'package:workmanager/workmanager.dart';

// class BackgroundTask {
//   void callbackDispatcher() {
//     Workmanager().executeTask((task, inputData) {
//       DateTime now = DateTime.now();
//       String formattedTime = "${now.hour}:${now.minute}:${now.second}";

//       print("Background task id ${task} is running at $formattedTime!");
//       return Future.value(true);
//     });
//   }

//   void registerPeriodicTask() {
//     Workmanager().registerPeriodicTask(
//       "1",
//       "simpleTask",
//       frequency: Duration(minutes: 15),
//     );
//   }

//   void startBackgroundTask() {
//     callbackDispatcher(); // Initialize callbackDispatcher
//     registerPeriodicTask(); // Register periodic task
//   }
// }
