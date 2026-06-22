import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:math';

class GetScramble {
  late List<dynamic> _scrambleList;

  Future<void> loadData() async {
    final response = await rootBundle.loadString(
      'assets/scrambles/two_by_two/222scrambles.json',
    );
    // debugPrint(jsonDecode(response).toString());
    _scrambleList = jsonDecode(response);
  }

  Future<String> pickRandomScramble() async {
    return _scrambleList[Random().nextInt(_scrambleList.length)];
  }
}
