import 'package:flutter/material.dart';
import 'package:pokeapi_pokedex/screens/home_page.dart';
import 'package:pokeapi_pokedex/themes/theme_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = true;

  void cambiarTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokedex',
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? AppThemes.darkTheme : AppThemes.lightTheme,
      home: MyHomePage(toggleTheme: cambiarTheme, isDarkMode: _isDarkMode),
    );
  }
}
