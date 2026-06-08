import 'dart:convert';

import 'package:http/http.dart' as http;

class Api {
  static Future<Map<String, dynamic>> getWcaData(String wcaId) async {
    final String baseUrl = 'https://www.worldcubeassociation.org/api/v0/persons/2019ROME03';
    final response = await http.get(Uri.parse(baseUrl));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}



// void main() async {
//   final data = await Api.getWcaData('2019ROME03');
//   print(data);
// }




