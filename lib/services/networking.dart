import 'package:http/http.dart' as http;
import 'dart:convert';

class NetworkHelper {
  NetworkHelper(this.url);

  final String url;

  Future getData() async {
    print(url);
    final response = await http.get(Uri.parse(url));
    // print('hello');
    if (response.statusCode == 200) {
      String data = response.body;
      data = data.replaceAll("'", '"');
      Map<String, dynamic> mapData = jsonDecode(data);
      return jsonDecode(data);
    } else {
      print(response.statusCode);
    }
  }
}
