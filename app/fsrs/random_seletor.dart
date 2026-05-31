import 'dart:convert';
import 'package:flutter/services.dart';

var scrambles = 'assets/scrambles/3x3/333scrambles.json';

Future<List<User>> jason2list() async {
  String jsonString = await rootBundle.loadString('assets/data/users.json'); // nur das pausieren 
  List<dynamic> jsonList = jsonDecode(jsonString);
  return jsonList.map((e) => User.fromJson(e)).toList();z;
}
Future<List<User
