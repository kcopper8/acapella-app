import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const AcapellaApp());
}

class AcapellaApp extends StatelessWidget {
  const AcapellaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '아카펠라 메이커',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'sans-serif',
      ),
      home: const HomeScreen(),
    );
  }
}
