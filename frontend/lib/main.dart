import 'package:flutter/material.dart';
import 'package:frontend/screens/home.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Distribuidora Anita',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(), // <--- Arranca aquí
    );
  }
}