import 'package:flutter/material.dart';
import 'dart:async';
import 'main_page.dart';

// Main entry point of SpywareScan

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// App Name, Color Scheme
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test - Spyware Detector App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 84, 109, 191),
        ),
        useMaterial3: true,
      ),
      home: const MainPage(title: 'SafeScan'),
    );
  }
}
