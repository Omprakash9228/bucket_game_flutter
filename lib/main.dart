import 'package:flutter/material.dart';
import 'game_screen.dart'; // Import your custom game

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bucket Ball Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: GameScreen(), // Use your game here
    );
  }
}
