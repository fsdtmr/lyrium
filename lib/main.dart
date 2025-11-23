import 'package:flutter/material.dart';
import 'package:lyrium/controller.dart';
import 'package:lyrium/home.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => MusicController(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      theme: ThemeData.dark(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      title: 'lyrium',
      home: Scaffold(body: const HomePage()),
    );
  }
}
