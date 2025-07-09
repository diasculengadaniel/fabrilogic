import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const FabriLogicApp());
}

class FabriLogicApp extends StatelessWidget {
  const FabriLogicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FabriLogic',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: const HomeScreen(),
    );
  }
}
