import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/problem.dart';

class ProblemLoader {
  static Future<Problem> loadLevel(int level) async {
    final data = await rootBundle.loadString('assets/levels/level$level.json');
    final jsonData = jsonDecode(data);
    return Problem.fromJson(jsonData);
  }
}
