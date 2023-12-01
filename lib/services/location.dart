import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class Location {
  dynamic latitude, longitude;

  Location({this.latitude, this.longitude});

  Future<void> getCurrentLocation() async {
    // Check if location permission is granted
    if (await Permission.locationWhenInUse.request().isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        );

        latitude = position.latitude;
        longitude = position.longitude;
      } catch (e) {
        print(e);
      }
    } else {
      // Handle the case when the user denies location permission
      print('Location permission is not granted');
      // You might want to show a message to the user or navigate to settings.
    }
  }
}
