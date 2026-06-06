import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:math';

class GetScramble {
  Future<dynamic> loadData() async {
    final response = await rootBundle.loadString(
      'assets/scrambles/two_by_two/222scrambles.json',
    );
    // debugPrint(jsonDecode(response).toString());
    return jsonDecode(response);
  }

  pickRandomScramble() async {
    List<dynamic> scrambleList = await loadData();
    return scrambleList[Random().nextInt(scrambleList.length)];
  }
}
