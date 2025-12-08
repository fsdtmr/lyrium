import 'package:flutter/material.dart';
import 'package:lyrium/controller.dart';
import 'package:lyrium/home.dart';
import 'package:lyrium/widgets/settings.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  packageInfo = await PackageInfo.fromPlatform(
    baseUrl: "https://fsdtmr.github.io/lyrium/",
  );
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
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData.dark(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      title: 'lyrium',
      home: Scaffold(body: const HomePage()),
    );
  }
}
