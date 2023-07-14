// import 'package:http/http.dart' as http;

// Future<void> fetchData() async {
//   String url =
//       'http://${Url.text}/pbxlogin.py?l=${Username.text}&p=${Password.text}&a=login';
//   print(url);
//   final response = await http.get(Uri.parse(url));
//   if (response.statusCode == 200) {
//     setState(() {
//       _response = response.body;
//       print("type");
//       print(_response.runtimeType);
//     });
//   } else {
//     setState(() {
//       _response = 'Error: ${response.statusCode}';
//     });
//   }
// }
