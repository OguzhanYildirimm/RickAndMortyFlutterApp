import 'package:flutter/material.dart';

import 'home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rick and Morty Flutter App',
      theme: ThemeData().copyWith(
          appBarTheme: const AppBarTheme(color: Colors.deepOrangeAccent)),
      home: const HomePage(),
    );
  }
}
