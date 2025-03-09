// main.dart
import 'package:flutter/material.dart';
import 'package:parcial_moviles_1/presentation/home_page/home_page.dart';
import 'presentation/login/login_page.dart';
import 'data/datasources/local_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.initDatabase();
  
  final isValid = await LocalStorage.isSessionValid();

  runApp(MyApp(initialRoute: isValid ? '/home' : '/login'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}