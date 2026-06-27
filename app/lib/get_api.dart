import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiNotFoundException implements Exception {}

class Api {
  static Future<Map<String, dynamic>> getWcaData(String wcaId) async {
    final url = 'https://www.worldcubeassociation.org/api/v0/persons/$wcaId';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 404) throw ApiNotFoundException();

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }

    final contentType = response.headers['content-type'] ?? '';
    if (!contentType.contains('application/json')) {
      throw Exception('Unexpected content-type: $contentType');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
