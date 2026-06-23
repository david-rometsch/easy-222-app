import 'dart:convert';
import 'package:http/http.dart' as http;

class Api {
  static Future<Map<String, dynamic>> getWcaData(String wcaId) async {
    final url = 'https://www.worldcubeassociation.org/api/v0/persons/$wcaId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception('API error: ${response.statusCode}');
      }

      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      // throw Exception('No internet or request failed');
      throw Exception('Fehler: $e');
    }
  }
}
